import sys
from io import BytesIO
from pathlib import Path
from types import SimpleNamespace

sys.path.insert(0, str(Path(__file__).parents[1] / ".venv"))

import pytest
import torch
from PIL import Image

from app.image_similarity import (
    ImageEmbeddingError,
    ImageSimilarityService,
    InMemoryImageEmbeddingCache,
)


def image_bytes(color):
    output = BytesIO()
    Image.new("RGB", (4, 4), color).save(output, format="PNG")
    return output.getvalue()


class FakeProcessor:
    def __call__(self, *, images, return_tensors):
        pixel = torch.tensor(list(images.getpixel((0, 0))), dtype=torch.float32)
        return {"pixel_values": pixel.unsqueeze(0)}


class FakeModel:
    config = SimpleNamespace(projection_dim=3)

    def eval(self):
        return self

    def __call__(self, **inputs):
        return SimpleNamespace(image_embeds=inputs["pixel_values"])


def service():
    return ImageSimilarityService(
        model=FakeModel(),
        processor=FakeProcessor(),
        cache=InMemoryImageEmbeddingCache(),
    )


def test_model_ready_and_valid_image_embedding():
    embedding_service = service()
    embedding = embedding_service.encode_validated(
        image_bytes("blue"), "person.png", "image/png"
    )
    assert embedding_service.model_ready
    assert embedding_service.embedding_dimensions == 3
    assert len(embedding) == 3


def test_same_image_is_high_and_different_image_is_lower():
    embedding_service = service()
    blue = embedding_service.encode(image_bytes("blue"))
    same_blue = embedding_service.encode(image_bytes("blue"))
    red = embedding_service.encode(image_bytes("red"))
    assert embedding_service.similarity(blue, same_blue) > 0.99
    assert embedding_service.similarity(blue, red) < embedding_service.similarity(blue, same_blue)


def test_similarity_is_normalized_and_percentage_is_not_probability():
    value = ImageSimilarityService.similarity([1.0, 0.0], [0.0, 1.0])
    assert 0.0 <= value <= 1.0
    assert ImageSimilarityService.percentage([1.0, 0.0], [1.0, 0.0]) == 100.0


def test_invalid_image_fails_cleanly():
    with pytest.raises(ImageEmbeddingError, match="Unreadable|Invalid|Unsupported"):
        service().encode_validated(b"not-an-image", "bad.png", "image/png")


def test_storage_embedding_uses_cache_and_stays_backend_side():
    class PrivateStorage:
        def __init__(self):
            self.calls = 0

        def get_private_image(self, storage_id):
            self.calls += 1
            assert storage_id == "private-storage-id"
            return image_bytes("blue")

    storage = PrivateStorage()
    embedding_service = service()
    first = embedding_service.embedding_for_storage("private-storage-id", storage)
    second = embedding_service.embedding_for_storage("private-storage-id", storage)
    assert first == second
    assert storage.calls == 1
    assert "private-storage-id" not in repr(first)


def test_uncached_candidate_is_embedded_once_then_reused():
    class PrivateStorage:
        def __init__(self):
            self.calls = 0

        def get_private_image(self, storage_id):
            self.calls += 1
            return image_bytes("blue")

    storage = PrivateStorage()
    embedding_service = service()
    embedding_service.embedding_for_storage("candidate-ref", storage)
    embedding_service.embedding_for_storage("candidate-ref", storage)
    assert storage.calls == 1
