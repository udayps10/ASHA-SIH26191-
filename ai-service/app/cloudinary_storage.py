import os
import re
from io import BytesIO
from typing import Any

from .image_storage import (
    ImageAccessType,
    ImageCategory,
    ImageStorageService,
    StoredImage,
    validate_image,
)


class CloudinaryConfigurationError(Exception):
    pass


class CloudinaryImageStorageService(ImageStorageService):
    """Cloudinary adapter behind the Step 11A storage abstraction."""

    def __init__(self, uploader: Any = None):
        cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME")
        api_key = os.getenv("CLOUDINARY_API_KEY")
        api_secret = os.getenv("CLOUDINARY_API_SECRET")
        if not cloud_name or not api_key or not api_secret:
            raise CloudinaryConfigurationError("Cloudinary credentials are unavailable")
        import cloudinary
        import cloudinary.uploader

        cloudinary.config(
            cloud_name=cloud_name, api_key=api_key, api_secret=api_secret, secure=True
        )
        self._cloudinary = cloudinary
        self._uploader = uploader or cloudinary.uploader
        self._api_key = api_key

    def upload_normal_photo(self, data, filename, content_type, stable_id=None):
        return self._upload(
            data,
            filename,
            content_type,
            stable_id,
            "disasterconnect/normal",
            ImageCategory.NORMAL_PHOTO,
            ImageAccessType.PUBLIC_NORMAL_RESULT,
            "upload",
        )

    def upload_critical_photo(self, data, filename, content_type, stable_id=None):
        return self._upload(
            data,
            filename,
            content_type,
            stable_id,
            "disasterconnect/critical",
            ImageCategory.CRITICAL_PHOTO,
            ImageAccessType.PRIVATE_CRITICAL,
            "authenticated",
        )

    def upload_critical_clothing(self, data, filename, content_type, stable_id=None):
        return self._upload(
            data,
            filename,
            content_type,
            stable_id,
            "disasterconnect/critical_clothing",
            ImageCategory.CRITICAL_CLOTHING,
            ImageAccessType.PRIVATE_CRITICAL,
            "authenticated",
        )

    def upload_match_input(self, data, filename, content_type, stable_id=None):
        return self._upload(
            data,
            filename,
            content_type,
            stable_id,
            "disasterconnect/match_input",
            ImageCategory.MATCH_INPUT,
            ImageAccessType.TEMPORARY_MATCH_INPUT,
            "authenticated",
        )

    def get_private_image(self, storage_id):
        public_id, delivery_type = self._parse_storage_id(storage_id)
        from cloudinary.utils import private_download_url
        import requests

        extension = "jpg"
        url = private_download_url(
            public_id, format=extension, resource_type="image", type=delivery_type
        )
        response = requests.get(url, timeout=20)
        response.raise_for_status()
        return response.content

    def public_image_url(self, storage_id):
        """Return a delivery URL only for normal public-result assets.

        Critical and temporary authenticated references are deliberately not
        convertible through this method.
        """
        public_id, delivery_type = self._parse_storage_id(storage_id)
        if delivery_type != "upload":
            raise ValueError("Only normal public images can be delivered")
        from cloudinary.utils import cloudinary_url

        url, _ = cloudinary_url(
            public_id,
            resource_type="image",
            type="upload",
            secure=True,
        )
        return url

    def delete_image(self, storage_id):
        public_id, delivery_type = self._parse_storage_id(storage_id)
        result = self._uploader.destroy(
            public_id,
            resource_type="image",
            type=delivery_type,
            invalidate=True,
        )
        if result.get("result") not in {"ok", "not found"}:
            raise RuntimeError("Cloudinary image deletion failed")

    def _upload(
        self,
        data,
        filename,
        content_type,
        stable_id,
        folder,
        category,
        access_type,
        delivery_type,
    ):
        validate_image(data, filename, content_type)
        safe_id = _safe_id(stable_id or filename.rsplit(".", 1)[0])
        public_id = f"{folder}/{safe_id}"
        result = self._uploader.upload(
            BytesIO(data),
            public_id=public_id,
            resource_type="image",
            type=delivery_type,
            overwrite=True,
            use_filename=False,
            unique_filename=False,
        )
        actual_public_id = result.get("public_id", public_id)
        resource_type = result.get("resource_type", "image")
        storage_id = f"cloudinary|{resource_type}|{delivery_type}|{actual_public_id}"
        return StoredImage(
            storage_id=storage_id,
            category=category,
            access_type=access_type,
            content_type=content_type,
            size_bytes=int(result.get("bytes", len(data))),
            provider="cloudinary",
            asset_id=actual_public_id,
            resource_type=resource_type,
            delivery_type=delivery_type,
        )

    @staticmethod
    def _parse_storage_id(storage_id):
        parts = storage_id.split("|", 3)
        if len(parts) != 4 or parts[0] != "cloudinary":
            raise ValueError("Invalid storage reference")
        return parts[3], parts[2]


def _safe_id(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9_-]", "_", value)[:120] or "asset"
