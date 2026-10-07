import json
from typing import Any

from .scoring import CandidateRecord


class FirestoreUnavailable(Exception):
    pass


def initialize_firestore_client() -> Any:
    """Initialize Firebase Admin once using ADC/GOOGLE_APPLICATION_CREDENTIALS."""
    try:
        import firebase_admin
        from firebase_admin import firestore

        if not firebase_admin._apps:
            # Firebase Admin resolves GOOGLE_APPLICATION_CREDENTIALS or the
            # normal Google Application Default Credentials chain here.
            firebase_admin.initialize_app()
        return firestore.client()
    except Exception as exc:
        # Never include credential paths or credential contents in this error.
        raise FirestoreUnavailable("Firebase Admin credentials unavailable") from exc


class FirestoreRecordDataSource:
    """Server-side Firestore reader using an already initialized client.

    DEPRECATED: Production matching now uses candidates provided in the request.
    """

    def __init__(self, firestore_client: Any = None):
        if firestore_client is None:
            raise FirestoreUnavailable("Firestore client is not initialized")
        self._client = firestore_client

    def fetch_recent(self, limit: int) -> list[CandidateRecord]:
        records: list[CandidateRecord] = []
        for collection, record_type in (
            ("normal_records", "normal"),
            ("critical_records", "critical"),
        ):
            try:
                documents = self._client.collection(collection).limit(limit).stream()
                records.extend(
                    _candidate_from_firestore(doc.id, doc.to_dict(), record_type)
                    for doc in documents
                )
            except Exception as exc:
                raise FirestoreUnavailable(str(exc)) from exc
        return records


class DemoRecordDataSource:
    """Small non-mock-ranking dataset used only when explicitly enabled locally."""

    def fetch_recent(self, limit: int) -> list[CandidateRecord]:
        return [
            CandidateRecord(
                "demo_normal_001",
                "normal",
                "Rahul Sharma",
                24,
                "Demo Relief Camp A",
                "AT_CAMP",
                "Demo Officer",
                "+91 90000 00001",
                additional_details="blue shirt, black jeans",
                found_location="Mumbai",
            ),
            CandidateRecord(
                "demo_normal_002",
                "normal",
                "Rahul S.",
                25,
                "Demo Relief Camp B",
                "FOUND",
                "Demo Officer 2",
                "+91 90000 00002",
                additional_details="blue shirt",
                found_location="Mumbai",
            ),
            CandidateRecord(
                "demo_normal_003",
                "normal",
                "Rakesh Kumar",
                31,
                "Demo Relief Camp C",
                "IDENTIFIED",
                "Demo Officer 3",
                "+91 90000 00003",
                additional_details="red jacket",
                found_location="Delhi",
            ),
            CandidateRecord(
                "demo_critical_001",
                "critical",
                "Rahul Sharma",
                24,
                "Demo Relief Camp Critical",
                "CRITICAL",
                "Critical Officer",
                "+91 90000 00004",
                last_known_clothing="blue shirt and black jeans",
                found_location="Mumbai",
                additional_details="near the western gate",
            ),
        ][:limit]


def _candidate_from_firestore(
    record_id: str, data: dict, record_type: str
) -> CandidateRecord:
    image_storage_id = _storage_id_from_data(data)
    return CandidateRecord(
        record_id=record_id,
        record_type=record_type,
        name=str(data.get("name", "")),
        age=int(data.get("age", 0)),
        camp_name=str(data.get("campName", data.get("camp_name", ""))),
        status=str(data.get("status", "")),
        officer_name=str(data.get("officerName", data.get("officer_name", ""))),
        officer_contact=str(
            data.get("officerContact", data.get("officer_contact", ""))
        ),
        photo_url=data.get("photoUrl", data.get("photo_url"))
        if record_type == "normal"
        else None,
        image_storage_id=image_storage_id,
        last_known_clothing=data.get(
            "lastKnownClothing", data.get("last_known_clothing")
        ),
        found_location=data.get("foundLocation", data.get("found_location")),
        additional_details=data.get("additionalDetails", data.get("additional_details")),
    )


def _storage_id_from_data(data: dict) -> str | None:
    """Read only the opaque image reference needed by backend matching.

    Firestore records may contain the Step 11B reference as a string or as the
    provider-neutral response map. No provider URL or raw document is copied.
    """
    for key in (
        "photoStorageId",
        "photo_storage_id",
        "imageStorageId",
        "image_storage_id",
    ):
        value = data.get(key)
        if isinstance(value, str) and value.strip():
            return value
    # SyncService stores the provider-neutral image reference as JSON in
    # photoUrl/photo_url. It remains an opaque backend-only value.
    for key in ("photoUrl", "photo_url"):
        value = data.get(key)
        if isinstance(value, str):
            try:
                decoded = json.loads(value)
            except (TypeError, ValueError):
                decoded = None
            if isinstance(decoded, dict):
                storage_id = decoded.get("storageId") or decoded.get("storage_id")
                if isinstance(storage_id, str) and storage_id.strip():
                    return storage_id
    for key in (
        "photoReference",
        "photo_reference",
        "imageReference",
        "image_reference",
    ):
        value = data.get(key)
        if isinstance(value, dict):
            storage_id = value.get("storageId") or value.get("storage_id")
            if isinstance(storage_id, str) and storage_id.strip():
                return storage_id
    return None
