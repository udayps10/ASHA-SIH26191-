import pytest
from app.scoring import CandidateRecord, MatchScoringConfig, MatchScoringService, ScoredCandidate
from app.text_similarity import TextSimilarityService

@pytest.fixture
def scoring_service():
    similarity = TextSimilarityService()
    config = MatchScoringConfig(
        threshold_strong=90.0,
        threshold_possible=75.0,
        threshold_weak=60.0
    )
    return MatchScoringService(similarity, config)

def test_filtering_and_labeling(scoring_service):
    query = {"name": "Rahul", "age": 25}
    candidate = CandidateRecord("1", "normal", "Rahul", 25)

    # Strong Match (95.0)
    # The actual score might vary based on MiniLM, so let's mock it for precise testing
    scored_strong = ScoredCandidate(candidate, 95.0, 1.0, 1.0, 0.0, 0.0)
    explained_strong = scoring_service.explain(query, scored_strong)
    assert explained_strong.match_label == "Strong Match"

    # Possible Match (80.0)
    scored_possible = ScoredCandidate(candidate, 80.0, 0.8, 0.8, 0.0, 0.0)
    explained_possible = scoring_service.explain(query, scored_possible)
    assert explained_possible.match_label == "Possible Match"

    # Weak Match (65.0)
    scored_weak = ScoredCandidate(candidate, 65.0, 0.6, 0.6, 0.0, 0.0)
    explained_weak = scoring_service.explain(query, scored_weak)
    assert explained_weak.match_label == "Weak Match"

    # Hidden (55.0)
    scored_hidden = ScoredCandidate(candidate, 55.0, 0.5, 0.5, 0.0, 0.0)
    explained_hidden = scoring_service.explain(query, scored_hidden)
    assert explained_hidden.match_label is None

def test_explanation_generation(scoring_service):
    query = {"name": "Rahul", "age": 25}
    candidate = CandidateRecord("1", "normal", "Rahul", 25)

    # Multiple signals
    scored = ScoredCandidate(candidate, 90.0, 0.9, 0.95, 0.0, 0.0, clip_score=0.85, face_score=0.9)
    explained = scoring_service.explain(query, scored)
    assert "face" in explained.explanation
    assert "name" in explained.explanation
    assert "age" in explained.explanation
    assert "Strong similarity in face, name and age." == explained.explanation

    # Single signal
    scored_single = ScoredCandidate(candidate, 70.0, 0.9, 0.5, 0.0, 0.0)
    explained_single = scoring_service.explain(query, scored_single)
    assert "Strong similarity in name." == explained_single.explanation

    # No signal (below 0.8)
    scored_none = ScoredCandidate(candidate, 65.0, 0.7, 0.7, 0.0, 0.0)
    explained_none = scoring_service.explain(query, scored_none)
    assert explained_none.explanation is None
