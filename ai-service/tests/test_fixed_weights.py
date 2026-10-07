from app.scoring import MatchScoringService, CandidateRecord

class Similarity:
    def similarity(self, a, b):
        return 1.0 if a == b else 0.0

def test_name_age_only_does_not_renormalize():
    scoring = MatchScoringService(Similarity())
    candidate = CandidateRecord('1', 'normal', 'Example', 30)
    assert scoring.score({'name': 'Example', 'age': 30}, candidate).match_score == 40
    assert scoring.score({'name': 'Example', 'age': 35}, candidate).match_score == 32.5

def test_all_weights_and_prototype_cap():
    scoring = MatchScoringService(Similarity())
    candidate = CandidateRecord('1', 'normal', 'Example', 30, camp_name='Camp', additional_details='Blue shirt')
    query = {'name': 'Example', 'age': 30, 'last_known_location': 'Camp', 'additional_details': 'Blue shirt'}
    assert scoring.score(query, candidate, clip_score=1, face_score=1).match_score == 99
    metadata = scoring.score(query, candidate)
    assert metadata.match_score == 65
    assert scoring.add_image_scores(query, metadata, clip_score=1, face_score=0.8).match_score == 94
