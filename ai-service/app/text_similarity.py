import math
from typing import Any


class TextSimilarityService:
    """Loads one Sentence Transformer and reuses it for the process lifetime."""

    def __init__(self, model_name: str = "all-MiniLM-L6-v2", encoder: Any = None):
        self.model_name = model_name
        self._model = encoder
        if self._model is None:
            from sentence_transformers import SentenceTransformer

            self._model = SentenceTransformer(model_name)

    @property
    def ready(self) -> bool:
        return self._model is not None

    def encode(self, text: str) -> list[float]:
        if not text.strip():
            return []
        vector = self._model.encode(text, normalize_embeddings=True)
        return vector.tolist() if hasattr(vector, "tolist") else list(vector)

    def similarity(self, text_a: str, text_b: str) -> float:
        if not text_a.strip() or not text_b.strip():
            return 0.0
        vector_a = self.encode(text_a)
        vector_b = self.encode(text_b)
        if not vector_a or not vector_b or len(vector_a) != len(vector_b):
            return 0.0
        dot = sum(a * b for a, b in zip(vector_a, vector_b))
        magnitude_a = math.sqrt(sum(value * value for value in vector_a))
        magnitude_b = math.sqrt(sum(value * value for value in vector_b))
        if magnitude_a == 0 or magnitude_b == 0:
            return 0.0
        return max(0.0, min(1.0, dot / (magnitude_a * magnitude_b)))
