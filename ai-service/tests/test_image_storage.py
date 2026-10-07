from io import BytesIO
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / ".venv"))

import pytest
from PIL import Image

from app.image_storage import (
    ALLOWED_IMAGE_TYPES,
    ImageAccessType,
    ImageCategory,
    InMemoryImageStorageService,
    MAX_IMAGE_SIZE_BYTES,
    validate_image,
)


def image_bytes(format_name):
    output = BytesIO()
    Image.new("RGB", (2, 2), "blue").save(output, format=format_name)
    return output.getvalue()


@pytest.mark.parametrize("format_name,content_type,extension", [
    ("JPEG", "image/jpeg", "jpg"),
    ("PNG", "image/png", "png"),
    ("WEBP", "image/webp", "webp"),
])
def test_valid_images(format_name, content_type, extension):
    validate_image(image_bytes(format_name), f"person.{extension}", content_type)


def test_unsupported_and_oversized_images_are_rejected():
    with pytest.raises(ValueError, match="Unsupported"):
        validate_image(b"MZ" + b"x" * 20, "person.exe", "application/octet-stream")
    with pytest.raises(ValueError, match="10 MB"):
        validate_image(b"x" * (MAX_IMAGE_SIZE_BYTES + 1), "person.jpg", "image/jpeg")


def test_categories_and_private_access_are_explicit():
    storage = InMemoryImageStorageService()
    normal = storage.upload_normal_photo(b"normal", "normal.jpg", "image/jpeg")
    critical = storage.upload_critical_photo(b"critical", "critical.jpg", "image/jpeg")
    clothing = storage.upload_critical_clothing(b"clothing", "clothing.jpg", "image/jpeg")
    temporary = storage.upload_match_input(b"input", "input.jpg", "image/jpeg")

    assert normal.category is ImageCategory.NORMAL_PHOTO
    assert normal.access_type is ImageAccessType.PUBLIC_NORMAL_RESULT
    assert critical.access_type is ImageAccessType.PRIVATE_CRITICAL
    assert clothing.access_type is ImageAccessType.PRIVATE_CRITICAL
    assert temporary.access_type is ImageAccessType.TEMPORARY_MATCH_INPUT
