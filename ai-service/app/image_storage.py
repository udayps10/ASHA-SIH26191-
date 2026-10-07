from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum
from io import BytesIO
from typing import Optional
from uuid import uuid4


class ImageAccessType(str, Enum):
    PUBLIC_NORMAL_RESULT = "public_normal_result"
    PRIVATE_CRITICAL = "private_critical"
    TEMPORARY_MATCH_INPUT = "temporary_match_input"


class ImageCategory(str, Enum):
    NORMAL_PHOTO = "normal_photo"
    CRITICAL_PHOTO = "critical_photo"
    CRITICAL_CLOTHING = "critical_clothing"
    MATCH_INPUT = "match_input"


@dataclass(frozen=True)
class StoredImage:
    """Opaque provider-independent storage metadata."""

    storage_id: str
    category: ImageCategory
    access_type: ImageAccessType
    content_type: str
    size_bytes: int
    provider: str = "local"
    asset_id: str | None = None
    resource_type: str = "image"
    delivery_type: str = "private"

    def to_reference(self) -> dict[str, str | int]:
        return {
            "provider": self.provider,
            "storageId": self.storage_id,
            "assetId": self.asset_id or self.storage_id,
            "resourceType": self.resource_type,
            "deliveryType": self.delivery_type,
            "accessType": self.access_type.value,
            "contentType": self.content_type,
            "sizeBytes": self.size_bytes,
        }


class ImageStorageService(ABC):
    @abstractmethod
    def upload_normal_photo(
        self, data: bytes, filename: str, content_type: str, stable_id: str | None = None
    ) -> StoredImage: ...

    @abstractmethod
    def upload_critical_photo(
        self, data: bytes, filename: str, content_type: str, stable_id: str | None = None
    ) -> StoredImage: ...

    @abstractmethod
    def upload_critical_clothing(
        self, data: bytes, filename: str, content_type: str, stable_id: str | None = None
    ) -> StoredImage: ...

    @abstractmethod
    def upload_match_input(
        self, data: bytes, filename: str, content_type: str, stable_id: str | None = None
    ) -> StoredImage: ...

    @abstractmethod
    def get_private_image(self, storage_id: str) -> bytes: ...

    @abstractmethod
    def delete_image(self, storage_id: str) -> None: ...

    @abstractmethod
    def public_image_url(self, storage_id: str) -> str: ...


class InMemoryImageStorageService(ImageStorageService):
    """Test-only storage; no cloud upload is performed by Step 11A."""

    def __init__(self):
        self._images: dict[str, tuple[StoredImage, bytes]] = {}

    def upload_normal_photo(self, data, filename, content_type, stable_id=None):
        return self._store(
            data, ImageCategory.NORMAL_PHOTO, ImageAccessType.PUBLIC_NORMAL_RESULT, content_type
        )

    def upload_critical_photo(self, data, filename, content_type, stable_id=None):
        return self._store(
            data, ImageCategory.CRITICAL_PHOTO, ImageAccessType.PRIVATE_CRITICAL, content_type
        )

    def upload_critical_clothing(self, data, filename, content_type, stable_id=None):
        return self._store(
            data,
            ImageCategory.CRITICAL_CLOTHING,
            ImageAccessType.PRIVATE_CRITICAL,
            content_type,
        )

    def upload_match_input(self, data, filename, content_type, stable_id=None):
        return self._store(
            data, ImageCategory.MATCH_INPUT, ImageAccessType.TEMPORARY_MATCH_INPUT, content_type
        )

    def get_private_image(self, storage_id):
        stored = self._images.get(storage_id)
        if stored is None:
            raise KeyError("Image not found")
        return stored[1]

    def public_image_url(self, storage_id: str) -> str:
        """In-memory test fallback: returns a data URI placeholder."""
        stored = self._images.get(storage_id)
        if stored is None:
            raise KeyError("Image not found")
        return f"memory://{storage_id}"

    def delete_image(self, storage_id):
        self._images.pop(storage_id, None)

    def _store(self, data, category, access_type, content_type):
        storage_id = f"local-image-{uuid4()}"
        image = StoredImage(storage_id, category, access_type, content_type, len(data))
        self._images[storage_id] = (image, data)
        return image


MAX_IMAGE_SIZE_BYTES = 10 * 1024 * 1024
ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}


class BackendImageStorageService(InMemoryImageStorageService):
    """Read only backend-owned photo paths, never arbitrary URLs or files."""
    def get_private_image(self, storage_id: str) -> bytes:
        from pathlib import Path
        root = Path(__file__).resolve().parents[2] / 'spring-boot-backend' / 'uploads' / 'photos'
        # app/image_storage.py -> project root is parents[2].
        for prefix in ('/uploads/', '/api/v1/images/file/'):
            if storage_id.startswith(prefix):
                target = (root / storage_id[len(prefix):]).resolve()
                if not target.is_relative_to(root.resolve()):
                    raise ValueError('Invalid photo path')
                return target.read_bytes()
        return super().get_private_image(storage_id)


def validate_image(data: bytes, filename: str, content_type: Optional[str]) -> None:
    if len(data) > MAX_IMAGE_SIZE_BYTES:
        raise ValueError("Image exceeds the 10 MB limit")
    extension = filename.lower().rsplit(".", 1)[-1] if "." in filename else ""
    allowed_extensions = {"jpg", "jpeg", "png", "webp"}
    if extension not in allowed_extensions or content_type not in ALLOWED_IMAGE_TYPES:
        raise ValueError("Unsupported image type")
    try:
        from PIL import Image

        with Image.open(BytesIO(data)) as image:
            image.verify()
    except Exception as exc:
        raise ValueError("Unreadable image format") from exc
