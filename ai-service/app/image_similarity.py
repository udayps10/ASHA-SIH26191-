from __future__ import annotations

import math
import threading
import time
from abc import ABC, abstractmethod
from io import BytesIO
from typing import Any, Callable

from PIL import Image, UnidentifiedImageError

try:
    import torch
    from transformers import CLIPImageProcessor, CLIPVisionModelWithProjection
except (ImportError, OSError):
    torch = None
    CLIPImageProcessor = None
    CLIPVisionModelWithProjection = None

from .image_storage import validate_image


class ImageEmbeddingError(Exception):
    """Raised when an image cannot be embedded or compared."""


class ImageEmbeddingCache(ABC):
    """Provider-neutral cache that can later be replaced by a vector store."""

    @abstractmethod
    def get(self, key: str) -> list[float] | None: ...

    @abstractmethod
    def set(self, key: str, embedding: list[float]) -> None: ...


class InMemoryImageEmbeddingCache(ImageEmbeddingCache):
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


class ImageSimilarityService:
    """General visual embedding service, deliberately separate from ranking.

    CLIP visual embeddings describe broad visual similarity. They are not face
    identification, identity verification, or a probability of a match.
    """

    DEFAULT_MODEL = "openai/clip-vit-base-patch32"

    def __init__(
        self,
        model_name: str | None = None,
        cache: ImageEmbeddingCache | None = None,
        model: Any = None,
        processor: Any = None,
    ):
        self.model_name = model_name or self.DEFAULT_MODEL
        self.cache = cache or InMemoryImageEmbeddingCache()
        self._model = model
        self._processor = processor
        self.embedding_dimensions: int | None = None

    @property
    def model_ready(self) -> bool:
        return self._model is not None and self._processor is not None

    def load(self) -> None:
        if self.model_ready:
            return
        if CLIPImageProcessor is None or CLIPVisionModelWithProjection is None:
            raise ImageEmbeddingError("CLIP libraries are not installed")
        try:
            self._processor = CLIPImageProcessor.from_pretrained(self.model_name)
            self._model = CLIPVisionModelWithProjection.from_pretrained(self.model_name)
            self._model.eval()
            self.embedding_dimensions = int(self._model.config.projection_dim)
        except Exception as exc:
            self._model = None
            self._processor = None
            raise ImageEmbeddingError("Image embedding model failed to load") from exc

    def encode(self, data: bytes) -> list[float]:
        self._require_ready()
        try:
            image = Image.open(BytesIO(data)).convert("RGB")
            inputs = self._processor(images=image, return_tensors="pt")

            with torch.no_grad():
                output = self._model(**inputs)
                vector = output.image_embeds[0]
                vector = torch.nn.functional.normalize(vector, p=2, dim=0)
            embedding = [float(value) for value in vector.cpu().tolist()]
            self.embedding_dimensions = len(embedding)
            return embedding
        except (UnidentifiedImageError, OSError, ValueError) as exc:
            raise ImageEmbeddingError("Invalid or corrupted image") from exc
        except Exception as exc:
            raise ImageEmbeddingError("Image embedding failed") from exc

    def encode_validated(
        self,
        data: bytes,
        filename: str,
        content_type: str,
    ) -> list[float]:
        try:
            validate_image(data, filename, content_type)
        except ValueError as exc:
            raise ImageEmbeddingError(str(exc)) from exc
        return self.encode(data)

    def embedding_for_storage(
        self,
        storage_id: str,
        storage_service: Any,
        timing_callback: Callable[[str, float], None] | None = None,
    ) -> list[float]:
        """Retrieve and embed an image server-side; never expose it to clients."""
        cached = self.cache.get(storage_id)
        if cached is not None:
            return cached
        try:
            retrieval_started = time.perf_counter()
            data = storage_service.get_private_image(storage_id)
            if timing_callback is not None:
                timing_callback(
                    "image retrieval",
                    (time.perf_counter() - retrieval_started) * 1000,
                )
        except Exception as exc:
            raise ImageEmbeddingError("Private image retrieval failed") from exc
        embedding_started = time.perf_counter()
        embedding = self.encode(data)
        if timing_callback is not None:
            timing_callback(
                "embedding generation",
                (time.perf_counter() - embedding_started) * 1000,
            )
        self.cache.set(storage_id, embedding)
        return embedding

    @staticmethod
    def similarity(embedding_a: list[float], embedding_b: list[float]) -> float:
        if not embedding_a or len(embedding_a) != len(embedding_b):
            raise ImageEmbeddingError("Embeddings must be non-empty and equal in size")
        norm_a = math.sqrt(sum(value * value for value in embedding_a))
        norm_b = math.sqrt(sum(value * value for value in embedding_b))
        if norm_a == 0 or norm_b == 0:
            raise ImageEmbeddingError("Cannot compare a zero-length embedding")
        cosine = sum(a * b for a, b in zip(embedding_a, embedding_b)) / (norm_a * norm_b)
        return max(0.0, min(1.0, (cosine + 1.0) / 2.0))

    @staticmethod
    def percentage(embedding_a: list[float], embedding_b: list[float]) -> float:
        return ImageSimilarityService.similarity(embedding_a, embedding_b) * 100.0

    def _require_ready(self) -> None:
        if not self.model_ready:
            raise ImageEmbeddingError("Image embedding model is not ready")
