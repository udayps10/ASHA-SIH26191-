import pytest
from app.scoring import CandidateRecord, MatchScoringConfig, MatchScoringService, ScoredCandidate
from app.text_similarity import TextSimilarityService

@pytest.fixture
def scoring_service():
    similarity = TextSimilarityService()
    # Using specific weights for testing renormalization
    config = MatchScoringConfig(
        name_weight=0.25,
        age_weight=0.15,
        location_weight=0.10,
        details_weight=0.15,
        clip_weight=0.05,
        face_weight=0.30
    )
    return MatchScoringService(similarity, config)

def test_renormalization_missing_face(scoring_service):
    query = {"name": "Rahul", "age": 25}
    candidate = CandidateRecord("1", "normal", "Rahul", 25)

    # Metadata only (no CLIP, no Face)
    scored_meta = scoring_service.score(query, candidate)
    # Expected score: 100 since Name (1.0) and Age (1.0) are the only active components
    assert scored_meta.match_score == pytest.approx(100.0)
    assert scored_meta.face_score is None
    assert scored_meta.clip_score is None

def test_ranking_influence_face(scoring_service):
    query = {"name": "Rahul", "age": 25}
    candidate = CandidateRecord("1", "normal", "Rahul", 25)

    # Strong Face Similarity
    scored_high = scoring_service.score(query, candidate, face_score=0.95)
    # Weak Face Similarity
    scored_low = scoring_service.score(query, candidate, face_score=0.30)

    assert scored_high.match_score > scored_low.match_score
    assert "face" in scored_high.explanation.lower()

def test_clip_as_secondary_signal(scoring_service):
    query = {"name": "Rahul", "age": 25}
    candidate = CandidateRecord("1", "normal", "Rahul", 25)

    # High CLIP (0.9), Low Face (0.3)
    scored_clip_heavy = scoring_service.score(query, candidate, clip_score=0.9, face_score=0.3)
    # Low CLIP (0.3), High Face (0.9)
    scored_face_heavy = scoring_service.score(query, candidate, clip_score=0.3, face_score=0.9)

    # Face has 30% weight, CLIP has 5%. Face-heavy should rank much higher.
    assert scored_face_heavy.match_score > scored_clip_heavy.match_score

def test_explanation_face_priority(scoring_service):
    query = {"name": "Rahul", "age": 25}
    candidate = CandidateRecord("1", "normal", "Rahul", 25)

    # Both strong
    scored = ScoredCandidate(candidate, 95.0, 1.0, 1.0, 1.0, 1.0, clip_score=0.9, face_score=0.9)
    explained = scoring_service.explain(query, scored)
    assert "face" in explained.explanation
    # CLIP ("visuals") should NOT be in explanation if face is present and strong
    assert "visuals" not in explained.explanation

def test_critical_record_sanitization(scoring_service):
    # This is more of an integration check for _public_result, but we can verify ScoredCandidate handles it
    candidate = CandidateRecord("crit_1", "critical", "Rahul", 25, image_storage_id="secret_id")
    scored = scoring_service.score({"name": "Rahul"}, candidate, face_score=0.9)

    assert scored.candidate.record_type == "critical"
    # The actual sanitization happens in main.py:_public_result, which we test in test_matching_engine.py
    # But we verify here that face_score exists internally for a critical record
    assert scored.face_score == 0.9
