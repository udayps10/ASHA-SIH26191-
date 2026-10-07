import json
from typing import Optional

from fastapi import FastAPI, HTTPException

from .models import CandidateInput, MatchMoreRequest, MatchRequest, MatchResponse, MatchResult
from .scoring import MatchScoringService, ScoredCandidate, CandidateRecord

app = FastAPI(title="DisasterConnect AI Matching Engine")

_scoring = None
_image_similarity = None
_face_similarity = None
_image_storage = None

PAGE_SIZE = 3
MAX_SESSIONS = 100
_ranked_sessions: dict[str, list[ScoredCandidate]] = {}


def _clean_sessions():
    """Simple LRU-like cleanup to prevent memory leaks."""
    if len(_ranked_sessions) > MAX_SESSIONS:
        # Remove oldest 20% of sessions
        keys_to_remove = list(_ranked_sessions.keys())[:20]
        for key in keys_to_remove:
            _ranked_sessions.pop(key, None)


def _get_services():
    global _scoring, _image_similarity, _face_similarity, _image_storage
    if _scoring is None:
        from .text_similarity import TextSimilarityService
        from .image_similarity import ImageSimilarityService
        from .face_similarity import FaceSimilarityService
        from .image_storage import BackendImageStorageService
        _scoring = MatchScoringService(TextSimilarityService())
        _image_similarity = ImageSimilarityService()
        try:
            _image_similarity.load()
        except Exception:
            _image_similarity = None
        try:
            _face_similarity = FaceSimilarityService()
            _face_similarity.load_model()
        except Exception:
            _face_similarity = None
        _image_storage = BackendImageStorageService()
    return _scoring, _image_similarity, _face_similarity, _image_storage


def _normal_photo_url(encoded: Optional[str]) -> Optional[str]:
    if not encoded:
        return None
    try:
        ref = json.loads(encoded)
    except (TypeError, ValueError):
        return None
    if not isinstance(ref, dict):
        return None
    storage_id = ref.get("storageId") or ref.get("storage_id")
    if not storage_id:
        return None
    if _image_storage is None:
        return None
    try:
        return _image_storage.public_image_url(storage_id)
    except Exception:
        return None


def _public_result(scored: ScoredCandidate) -> MatchResult:
    candidate = scored.candidate
    return MatchResult(
        record_id=candidate.record_id,
        name=candidate.name,
        age=candidate.age,
        camp_name=candidate.camp_name,
        officer_name=candidate.officer_name,
        officer_contact=candidate.officer_contact,
        status=candidate.status,
        match_score=scored.match_score,
        record_type=candidate.record_type,
        photo_url=(
            _normal_photo_url(candidate.photo_url)
            if candidate.record_type == "normal"
            else None
        ),
        last_known_clothing=candidate.last_known_clothing,
        match_label=scored.match_label,
        explanation=scored.explanation,
    )


def _rank_candidates(query: dict, candidates: list) -> list[ScoredCandidate]:
    scoring, image_similarity, face_similarity, image_storage = _get_services()
    metadata_scored = [
        scoring.score(query, candidate) for candidate in candidates
    ]

    has_photo = query.get("photo") is not None
    if not has_photo:
        return metadata_scored

    photo_raw = query["photo"]
    if isinstance(photo_raw, str):
        import base64 as _b64
        try:
            decoded = _b64.b64decode(photo_raw, validate=True)
            _JPEG = b'\xff\xd8\xff'
            _PNG = b'\x89PNG'
            _WEBP = b'RIFF'
            if len(decoded) > 100 and (decoded[:3] == _JPEG or decoded[:4] == _PNG or decoded[:4] == _WEBP):
                photo_bytes = decoded
            else:
                photo_bytes = photo_raw.encode("utf-8")
        except Exception:
            photo_bytes = photo_raw.encode("utf-8")
    else:
        photo_bytes = photo_raw

    user_clip_embedding = None
    user_face_embedding = None

    if image_similarity is not None:
        try:
            user_clip_embedding = image_similarity.encode(photo_bytes)
        except Exception:
            user_clip_embedding = None

    if face_similarity is not None:
        try:
            user_face_embedding = face_similarity.get_embedding(photo_bytes)
        except Exception:
            user_face_embedding = None

    metadata_scored.sort(key=lambda s: s.match_score, reverse=True)
    shortlist = metadata_scored[:scoring.config.image_shortlist_size]

    results = []
    for scored in metadata_scored:
        candidate = scored.candidate
        clip_score = None
        face_score = None

        if scored in shortlist and candidate.image_storage_id:
            if user_clip_embedding is not None:
                try:
                    candidate_embedding = image_similarity.embedding_for_storage(
                        candidate.image_storage_id, image_storage
                    )
                    clip_score = image_similarity.similarity(user_clip_embedding, candidate_embedding)
                except Exception:
                    clip_score = None

            if user_face_embedding is not None and face_similarity is not None:
                try:
                    candidate_face_embedding = face_similarity.embedding_for_storage(
                        candidate.image_storage_id, image_storage
                    )
                    face_score = face_similarity.similarity(user_face_embedding, candidate_face_embedding)
                except Exception:
                    face_score = None

        updated = scoring.add_image_scores(query, scored, clip_score=clip_score, face_score=face_score)
        results.append(updated)

    results.sort(key=lambda s: s.match_score, reverse=True)
    return results


def _page(request_id: str, ranked: list[ScoredCandidate], offset: int) -> MatchResponse:
    page_items = ranked[offset : offset + PAGE_SIZE]
    has_more = offset + PAGE_SIZE < len(ranked)
    return MatchResponse(
        request_id=request_id,
        results=[_public_result(scored) for scored in page_items],
        has_more=has_more,
        next_page_token=str(offset + PAGE_SIZE) if has_more else None,
    )


@app.post("/api/v1/match", response_model=MatchResponse)
@app.post("/match", response_model=MatchResponse, include_in_schema=False)
def match_missing_person(request: MatchRequest):
    _clean_sessions()
    query = request.model_dump(exclude_none=True)
    candidates = [_candidate_from_input(candidate) for candidate in request.candidates]
    ranked = _rank_candidates(query, candidates)
    request_id = __import__("uuid").uuid4().hex
    _ranked_sessions[request_id] = ranked
    return _page(request_id, ranked, 0)


@app.post("/api/v1/match/more", response_model=MatchResponse)
@app.post("/match/more", response_model=MatchResponse, include_in_schema=False)
def match_more(request: MatchMoreRequest):
    try:
        offset = int(request.page_token)
    except ValueError as error:
        raise HTTPException(status_code=400, detail="Invalid page token") from error
    ranked = _ranked_sessions.get(request.request_id)
    if ranked is None:
        raise HTTPException(status_code=404, detail="Matching request not found")
    return _page(request.request_id, ranked, offset)


def _candidate_from_input(candidate: CandidateInput) -> CandidateRecord:
    import json

    # Extract image_storage_id if available in photo_url JSON
    image_storage_id = None
    if candidate.photo_url and candidate.photo_url.startswith(('/uploads/', '/api/v1/images/file/')):
        image_storage_id = candidate.photo_url
    if candidate.photo_url:
        try:
            decoded = json.loads(candidate.photo_url)
            if isinstance(decoded, dict):
                image_storage_id = decoded.get("storageId") or decoded.get("storage_id")
        except (TypeError, ValueError):
            pass

    return CandidateRecord(
        record_id=candidate.record_id,
        record_type=candidate.record_type,
        name=candidate.name,
        age=candidate.age or 0,
        camp_name=candidate.camp_name,
        status=candidate.status,
        officer_name=candidate.officer_name,
        officer_contact=candidate.officer_contact,
        photo_url=candidate.photo_url,
        image_storage_id=image_storage_id,
        last_known_clothing=candidate.last_known_clothing,
        found_location=candidate.found_location,
        additional_details=candidate.additional_details,
    )


@app.get("/api/v1/health")
@app.get("/health")
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
