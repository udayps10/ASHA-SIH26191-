from __future__ import annotations

import threading
import time
from abc import ABC, abstractmethod
from io import BytesIO
from typing import Any, Callable

import numpy as np
from PIL import Image

try:
    import cv2
    import insightface
    from insightface.app import FaceAnalysis
except ImportError:
    cv2 = None
    insightface = None
    FaceAnalysis = None


class FaceEmbeddingError(Exception):
    """Raised when a face cannot be embedded or compared."""


class FaceEmbeddingCache(ABC):
    """Provider-neutral cache for face embeddings."""

    @abstractmethod
    def get(self, key: str) -> list[float] | None: ...

    @abstractmethod
    def set(self, key: str, embedding: list[float]) -> None: ...


class InMemoryFaceEmbeddingCache(FaceEmbeddingCache):
    def __init__(self):
        self._values: dict[str, list[float]] = {}
        self._lock = threading.Lock()

    def get(self, key: str) -> list[float] | None:
        with self._lock:
            value = self._values.get(key)
            return list(value) if value is not None else None

    def set(self, key: str, embedding: list[float]) -> None:
        with self._lock:
            self._values[key] = list(embedding)


class FaceSimilarityService:
    """Standalone face recognition and embedding service.

    Uses InsightFace (ArcFace) for high-accuracy face embedding.
    This service is isolated from the CLIP image similarity service.
    """

    DEFAULT_MODEL_PACK = "buffalo_l"

    def __init__(
        self,
        model_pack: str | None = None,
        cache: FaceEmbeddingCache | None = None,
    ):
        self.model_pack = model_pack or self.DEFAULT_MODEL_PACK
        self.cache = cache or InMemoryFaceEmbeddingCache()
        self._app: FaceAnalysis | None = None
        self.embedding_dimensions: int | None = None
        self._load_lock = threading.Lock()

    @property
    def is_ready(self) -> bool:
        return self._app is not None

    def load_model(self) -> None:
        """Load the FaceAnalysis model pack once."""
        if self.is_ready:
            return

        if FaceAnalysis is None:
            raise FaceEmbeddingError("InsightFace or dependencies not installed")

        with self._load_lock:
            if self._app is not None:
                return
            try:
                # Use CPU only as per development environment requirements
                app = FaceAnalysis(
                    name=self.model_pack, providers=["CPUExecutionProvider"]
                )
                # ctx_id=0 for CPU or the index of the GPU. det_size is spatial size for detection.
                app.prepare(ctx_id=0, det_size=(640, 640))
                self._app = app

                # Probing dimensions by doing a dummy zero-array if possible,
                # but typically ArcFace is 512.
                self.embedding_dimensions = 512
            except Exception as exc:
                self._app = None
                raise FaceEmbeddingError(f"Face model failed to load: {exc}") from exc

    def get_embedding(self, data: bytes) -> list[float]:
        """Detect exactly one face and return its normalized embedding."""
        self._require_ready()

        try:
            # Convert bytes to OpenCV format (BGR)
            image_pil = Image.open(BytesIO(data)).convert("RGB")
            image_np = np.array(image_pil)
            image_bgr = cv2.cvtColor(image_np, cv2.COLOR_RGB2BGR)

            faces = self._app.get(image_bgr)

            if not faces:
                raise FaceEmbeddingError("No face detected")

            if len(faces) > 1:
                raise FaceEmbeddingError("Multiple faces detected")

            face = faces[0]
            # InsightFace embeddings are usually already normalized, but we enforce it.
            embedding = face.normed_embedding
            if embedding is None:
                # Fallback to raw embedding if normed isn't present
                embedding = face.embedding
                norm = np.linalg.norm(embedding)
                if norm > 0:
                    embedding = embedding / norm

            embedding_list = embedding.tolist()
            self.embedding_dimensions = len(embedding_list)
            return embedding_list

        except FaceEmbeddingError:
            raise
        except Exception as exc:
            raise FaceEmbeddingError(f"Face embedding failed: {exc}") from exc

    def embedding_for_storage(
        self,
        storage_id: str,
        storage_service: Any,
        timing_callback: Callable[[str, float], None] | None = None,
    ) -> list[float]:
        """Retrieve and embed a face from storage with caching."""
        cached = self.cache.get(storage_id)
        if cached is not None:
            return cached

        try:
            retrieval_started = time.perf_counter()
            data = storage_service.get_private_image(storage_id)
            if timing_callback is not None:
                timing_callback(
                    "face image retrieval",
                    (time.perf_counter() - retrieval_started) * 1000,
                )
        except Exception as exc:
            raise FaceEmbeddingError(f"Image retrieval failed: {exc}") from exc

        embedding_started = time.perf_counter()
        embedding = self.get_embedding(data)
        if timing_callback is not None:
            timing_callback(
                "face embedding generation",
                (time.perf_counter() - embedding_started) * 1000,
            )
        self.cache.set(storage_id, embedding)
        return embedding

    @staticmethod
    def similarity(embedding_a: list[float], embedding_b: list[float]) -> float:
        """Normalized cosine similarity between two face embeddings."""
        if not embedding_a or len(embedding_a) != len(embedding_b):
            raise FaceEmbeddingError("Embeddings must be non-empty and equal in size")

        vec_a = np.array(embedding_a)
        vec_b = np.array(embedding_b)

        norm_a = np.linalg.norm(vec_a)
        norm_b = np.linalg.norm(vec_b)

        if norm_a == 0 or norm_b == 0:
            raise FaceEmbeddingError("Cannot compare zero-length embedding")

        cosine = np.dot(vec_a, vec_b) / (norm_a * norm_b)
        # Scale cosine (-1 to 1) to (0 to 1) for consistent face_similarity metric
        return float(max(0.0, min(1.0, (cosine + 1.0) / 2.0)))

    def _require_ready(self) -> None:
        if not self.is_ready:
            raise FaceEmbeddingError("Face similarity service is not ready")
