import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parents[1] / ".venv"))

from app.cloudinary_storage import CloudinaryImageStorageService
from app.image_storage import ImageAccessType, ImageCategory


class FakeUploader:
    def __init__(self):
        self.uploads = []
        self.deletes = []

    def upload(self, data, **options):
        self.uploads.append((data, options))
        size = len(data.getbuffer()) if hasattr(data, "getbuffer") else len(data)
        return {
            "public_id": options["public_id"],
            "resource_type": "image",
            "bytes": size,
        }

    def destroy(self, public_id, **options):
        self.deletes.append((public_id, options))
        return {"result": "ok"}


def test_cloudinary_configuration_and_asset_policies(monkeypatch):
    monkeypatch.setenv("CLOUDINARY_CLOUD_NAME", "test-cloud")
    monkeypatch.setenv("CLOUDINARY_API_KEY", "test-key")
    monkeypatch.setenv("CLOUDINARY_API_SECRET", "secret-must-not-be-logged")
    uploader = FakeUploader()
    storage = CloudinaryImageStorageService(uploader=uploader)

    # Valid 1x1 JPEG bytes; validation is covered separately in Step 11A.
    data = bytes.fromhex("ffd8ffe000104a46494600010100000100010000ffdb004300")
    # Use a valid test implementation boundary without making a cloud call.
    import app.cloudinary_storage as module
    monkeypatch.setattr(module, "validate_image", lambda *args: None)

    normal = storage.upload_normal_photo(data, "ignored.jpg", "image/jpeg", stable_id="record-1")
    critical = storage.upload_critical_photo(data, "ignored.jpg", "image/jpeg", stable_id="record-2")
    clothing = storage.upload_critical_clothing(data, "ignored.jpg", "image/jpeg", stable_id="record-3")
    temporary = storage.upload_match_input(data, "ignored.jpg", "image/jpeg", stable_id="request-1")

    assert normal.category is ImageCategory.NORMAL_PHOTO
    assert normal.access_type is ImageAccessType.PUBLIC_NORMAL_RESULT
    assert critical.access_type is ImageAccessType.PRIVATE_CRITICAL
    assert clothing.access_type is ImageAccessType.PRIVATE_CRITICAL
    assert temporary.access_type is ImageAccessType.TEMPORARY_MATCH_INPUT
    assert uploader.uploads[0][1]["public_id"] == "disasterconnect/normal/record-1"
    assert uploader.uploads[1][1]["type"] == "authenticated"
    assert uploader.uploads[2][1]["public_id"] == "disasterconnect/critical_clothing/record-3"
    assert uploader.uploads[3][1]["public_id"] == "disasterconnect/match_input/request-1"
    assert "secret-must-not-be-logged" not in repr(normal.to_reference())

    storage.delete_image(temporary.storage_id)
    assert uploader.deletes[0][0] == "disasterconnect/match_input/request-1"
    assert uploader.deletes[0][1]["type"] == "authenticated"


def test_invalid_image_is_rejected_before_cloudinary(monkeypatch):
    monkeypatch.setenv("CLOUDINARY_CLOUD_NAME", "test-cloud")
    monkeypatch.setenv("CLOUDINARY_API_KEY", "test-key")
    monkeypatch.setenv("CLOUDINARY_API_SECRET", "secret")
    uploader = FakeUploader()
    storage = CloudinaryImageStorageService(uploader=uploader)
    with pytest.raises(ValueError):
        storage.upload_normal_photo(b"not-an-image", "bad.exe", "application/octet-stream")
    assert uploader.uploads == []
