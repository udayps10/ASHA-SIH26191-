import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / ".venv"))

from app.data_sources import DemoRecordDataSource, FirestoreRecordDataSource
from app.main import _normal_photo_url, _page, _public_result, _rank_candidates
from app.scoring import CandidateRecord, MatchScoringConfig, MatchScoringService
from app.text_similarity import TextSimilarityService


class FakeEncoder:
    def encode(self, text, normalize_embeddings=True):
        words = set(text.lower().split())
        vocabulary = ["rahul", "sharma", "blue", "shirt", "black", "jeans", "mumbai", "red", "delhi"]
        return [1.0 if word in words else 0.0 for word in vocabulary]


def test_non_biometric_candidates_are_ranked_by_components():
    scoring = MatchScoringService(TextSimilarityService(encoder=FakeEncoder()))
    query = {
        "name": "Rahul Sharma",
        "age": 24,
        "last_known_location": "Mumbai",
        "additional_details": "Blue shirt, black jeans",
    }

    normal_candidates = [
        candidate
        for candidate in DemoRecordDataSource().fetch_recent(100)
        if candidate.record_type == "normal"
    ]
    ranked = sorted(
        (scoring.score(query, candidate) for candidate in normal_candidates),
        key=lambda result: result.match_score,
        reverse=True,
    )

    assert ranked[0].candidate.record_id == "demo_normal_001"
    assert ranked[0].match_score > ranked[1].match_score
    assert ranked[1].match_score > ranked[-1].match_score
    assert ranked[0].name_score == 1.0
    assert ranked[0].age_score == 1.0


def test_age_score_is_explainable_and_deterministic():
    scoring = MatchScoringService(TextSimilarityService(encoder=FakeEncoder()))
    query = {"name": "Rahul Sharma", "age": 24}
    candidates = DemoRecordDataSource().fetch_recent(3)
    exact = scoring.score(query, candidates[0])
    one_year = scoring.score(query, candidates[1])
    assert exact.age_score == 1.0
    assert one_year.age_score == 0.9


def test_firestore_mapping_keeps_critical_photo_private():
    class Document:
        def __init__(self, record_id, data):
            self.id = record_id
            self._data = data

        def to_dict(self):
            return self._data

    class Query:
        def __init__(self, documents):
            self.documents = documents

        def limit(self, _limit):
            return self

        def stream(self):
            return iter(self.documents)

    class Client:
        def collection(self, name):
            return Query([
                Document(
                    "critical-1",
                    {
                        "name": "Rahul Sharma",
                        "age": 24,
                        "campName": "Camp",
                        "photoUrl": "secret-photo-url",
                        "clothingPhotoUrl": "secret-clothing-url",
                        "lastKnownClothing": "blue shirt",
                    },
                )
            ] if name == "critical_records" else [])

    records = FirestoreRecordDataSource(Client()).fetch_recent(10)
    assert records[0].record_type == "critical"
    assert records[0].photo_url is None
    assert records[0].last_known_clothing == "blue shirt"


def test_json_normal_photo_reference_is_used_for_internal_image_matching():
    class Document:
        id = "normal-1"

        def to_dict(self):
            return {
                "name": "Rahul Sharma",
                "age": 24,
                "photoUrl": '{"provider":"cloudinary","storageId":"cloudinary|image|upload|normal/1"}',
            }

    class Query:
        def limit(self, _limit):
            return self

        def stream(self):
            return iter([Document()])

    class Client:
        def collection(self, _name):
            return Query()

    records = FirestoreRecordDataSource(Client()).fetch_recent(10)
    assert records[0].image_storage_id == "cloudinary|image|upload|normal/1"


def test_normal_photo_reference_is_converted_to_public_url_without_exposing_storage_id(monkeypatch):
    import app.main as main

    class Storage:
        def public_image_url(self, storage_id):
            assert storage_id == "cloudinary|image|upload|normal/1"
            return "https://res.cloudinary.com/test/image/upload/normal/1"

    monkeypatch.setattr(main, "_image_storage", Storage())
    encoded = '{"provider":"cloudinary","storageId":"cloudinary|image|upload|normal/1"}'
    url = _normal_photo_url(encoded)
    assert url.startswith("https://")
    assert "storageId" not in url


def _candidate(record_id, record_type="normal", image_storage_id=None):
    return CandidateRecord(
        record_id=record_id,
        record_type=record_type,
        name="Rahul Sharma",
        age=24,
        found_location="Mumbai",
        additional_details="blue shirt",
        image_storage_id=image_storage_id,
        photo_url="normal-photo-url" if record_type == "normal" else None,
    )


class FakeImageService:
    model_name = "fake-clip"

    def __init__(self, embeddings):
        self.embeddings = embeddings
        self.calls = []
        self.cache = FakeCache()

    def encode(self, key):
        lookup = key.decode("utf-8", errors="replace") if isinstance(key, bytes) else key
        self.calls.append(lookup)
        return self.embeddings.get(lookup, [0.0])

    def embedding_for_storage(self, storage_id, _storage, timing_callback=None):
        self.calls.append(storage_id)
        cached = self.cache.get(storage_id)
        if cached is not None:
            return cached
        embedding = self.embeddings[storage_id]
        self.cache.set(storage_id, embedding)
        return embedding

    @staticmethod
    def similarity(first, second):
        return 1.0 if first == second else 0.0


class FakeStorage:
    def __init__(self):
        self.deleted = []

    def delete_image(self, storage_id):
        self.deleted.append(storage_id)


class FakeCache:
    def __init__(self):
        self.values = {}

    def get(self, key):
        return self.values.get(key)

    def set(self, key, value):
        self.values[key] = value


def test_image_signal_changes_relative_ranking_and_breakdown_stays_internal(monkeypatch):
    import app.main as main

    scoring = MatchScoringService(TextSimilarityService(encoder=FakeEncoder()), MatchScoringConfig())
    image_service = FakeImageService({"user": [1.0], "same": [1.0], "different": [0.0]})
    storage = FakeStorage()
    monkeypatch.setattr(main, "_scoring", scoring)
    monkeypatch.setattr(main, "_image_similarity", image_service)
    monkeypatch.setattr(main, "_image_storage", storage)

    ranked = _rank_candidates(
        {
            "name": "Rahul Sharma",
            "age": 24,
            "last_known_location": "Mumbai",
            "additional_details": "blue shirt",
            "photo": "user",
        },
        [_candidate("different", image_storage_id="different"), _candidate("same", image_storage_id="same")],
    )

    assert ranked[0].candidate.record_id == "same"
    assert ranked[0].clip_score == 1.0
    assert ranked[1].clip_score == 0.0
    assert "image_score" not in _public_result(ranked[0]).model_dump()
    assert storage.deleted == []
    assert image_service.calls.count("user") == 1


def test_missing_images_use_valid_metadata_only_scores(monkeypatch):
    import app.main as main

    scoring = MatchScoringService(TextSimilarityService(encoder=FakeEncoder()))
    image_service = FakeImageService({"user": [1.0]})
    storage = FakeStorage()
    monkeypatch.setattr(main, "_scoring", scoring)
    monkeypatch.setattr(main, "_image_similarity", image_service)
    monkeypatch.setattr(main, "_image_storage", storage)

    query = {
        "name": "Rahul Sharma",
        "age": 24,
        "last_known_location": "Mumbai",
        "additional_details": "blue shirt",
        "photo": "user",
    }
    with_image = _rank_candidates(query, [_candidate("with", image_storage_id="user")])[0]
    without_candidate = CandidateRecord(
        record_id="without",
        record_type="normal",
        name="Rahul S.",
        age=25,
        found_location="Mumbai",
        additional_details="blue shirt",
    )
    without_image = _rank_candidates(query, [without_candidate])[0]
    metadata_only = scoring.score(query, without_candidate)

    assert with_image.match_score > without_image.match_score
    assert without_image.clip_score is None
    assert without_image.match_score == metadata_only.match_score
    assert without_image.match_score > 0


def test_critical_image_can_rank_internally_but_private_fields_are_sanitized(monkeypatch):
    import app.main as main

    scoring = MatchScoringService(TextSimilarityService(encoder=FakeEncoder()))
    image_service = FakeImageService({"user": [1.0], "critical-ref": [1.0]})
    storage = FakeStorage()
    monkeypatch.setattr(main, "_scoring", scoring)
    monkeypatch.setattr(main, "_image_similarity", image_service)
    monkeypatch.setattr(main, "_image_storage", storage)

    ranked = _rank_candidates(
        {"name": "Rahul Sharma", "age": 24, "photo": "user"},
        [_candidate("critical", "critical", "critical-ref")],
    )
    payload = _public_result(ranked[0]).model_dump(exclude_none=False)
    serialized = repr(payload)
    assert ranked[0].match_score > 0
    assert payload["photo_url"] is None
    assert "critical-ref" not in serialized
    assert "embedding" not in serialized.lower()


def test_clip_is_limited_to_the_centralized_metadata_shortlist(monkeypatch):
    import app.main as main

    config = MatchScoringConfig(image_shortlist_size=1)
    scoring = MatchScoringService(TextSimilarityService(encoder=FakeEncoder()), config)
    image_service = FakeImageService(
        {"user": [1.0], "best-image": [1.0], "other-image": [1.0]}
    )
    storage = FakeStorage()
    monkeypatch.setattr(main, "_scoring", scoring)
    monkeypatch.setattr(main, "_image_similarity", image_service)
    monkeypatch.setattr(main, "_image_storage", storage)

    best = _candidate("best", image_storage_id="best-image")
    other = CandidateRecord(
        record_id="other",
        record_type="normal",
        name="Different Person",
        age=60,
        found_location="Delhi",
        additional_details="red jacket",
        image_storage_id="other-image",
    )
    _rank_candidates(
        {
            "name": "Rahul Sharma",
            "age": 24,
            "last_known_location": "Mumbai",
            "additional_details": "blue shirt",
            "photo": "user",
        },
        [best, other],
    )

    assert image_service.calls.count("user") == 1
    assert image_service.calls.count("best-image") == 1
    assert "other-image" not in image_service.calls


def test_pagination_uses_the_existing_ranked_order_and_top_three_page_size():
    scoring = MatchScoringService(TextSimilarityService(encoder=FakeEncoder()))
    query = {"name": "Rahul Sharma", "age": 24}
    ranked = [
        scoring.score(query, _candidate(f"candidate-{index}"))
        for index in range(5)
    ]

    first = _page("session-1", ranked, 0)
    second = _page("session-1", ranked, 3)

    assert first.request_id == second.request_id == "session-1"
    assert len(first.results) == 3
    assert first.has_more is True
    assert first.next_page_token == "3"
    assert len(second.results) == 2
    assert second.has_more is False
    assert second.next_page_token is None
    assert {item.record_id for item in first.results}.isdisjoint(
        {item.record_id for item in second.results}
    )
