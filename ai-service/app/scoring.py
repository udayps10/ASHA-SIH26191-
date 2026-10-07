import re
from dataclasses import dataclass
from typing import Optional

from .text_similarity import TextSimilarityService


@dataclass(frozen=True)
class MatchScoringConfig:
    # Step 12D: Updated Prototype Weights
    # Face is the primary identity signal; CLIP is a secondary visual anchor.
    name_weight: float = 0.25
    age_weight: float = 0.15
    location_weight: float = 0.10
    details_weight: float = 0.15
    clip_weight: float = 0.05
    face_weight: float = 0.30

    # Prototype performance bound for image work. Metadata still ranks every
    # candidate; CLIP/Face are applied only to this shortlist.
    image_shortlist_size: int = 30

    # Step 13: Initial Prototype Thresholds
    threshold_strong: float = 90.0
    threshold_possible: float = 75.0
    threshold_weak: float = 60.0


@dataclass(frozen=True)
class CandidateRecord:
    record_id: str
    record_type: str
    name: str
    age: int
    camp_name: str = ""
    status: str = ""
    officer_name: str = ""
    officer_contact: str = ""
    photo_url: Optional[str] = None
    # Backend-only opaque storage reference. Never serialize this to a client.
    image_storage_id: Optional[str] = None
    last_known_clothing: Optional[str] = None
    found_location: Optional[str] = None
    additional_details: Optional[str] = None

    def searchable_text(self) -> str:
        values = [
            self.name,
            str(self.age),
            self.camp_name,
            self.status,
            self.last_known_clothing or "",
            self.found_location or "",
            self.additional_details or "",
        ]
        return " ".join(value for value in values if value).strip()


@dataclass(frozen=True)
class ScoredCandidate:
    candidate: CandidateRecord
    match_score: float
    name_score: float
    age_score: float
    location_score: float
    details_score: float
    clip_score: Optional[float] = None
    face_score: Optional[float] = None
    match_label: Optional[str] = None
    explanation: Optional[str] = None


def normalize_text(value: Optional[str]) -> str:
    return re.sub(
        r"\s+", " ", re.sub(r"[^a-z0-9 ]", " ", (value or "").lower())
    ).strip()


class MatchScoringService:
    def __init__(
        self,
        similarity: TextSimilarityService,
        config: MatchScoringConfig = MatchScoringConfig(),
    ):
        self.similarity = similarity
        self.config = config

    def score(
        self,
        query: dict,
        candidate: CandidateRecord,
        clip_score: Optional[float] = None,
        face_score: Optional[float] = None,
    ) -> ScoredCandidate:
        name_score = self._name_score(query.get("name", ""), candidate.name)
        age_score = self._age_score(query.get("age"), candidate.age)
        location_score = self._text_score(
            query.get("last_known_location"),
            candidate.found_location or candidate.camp_name,
        )
        details_score = self._text_score(
            query.get("additional_details"),
            " ".join(
                value
                for value in [candidate.last_known_clothing, candidate.additional_details]
                if value
            ),
        )

        components = [
            (name_score, self.config.name_weight),
        ]

        # Only include age in scoring if both query and candidate have it
        if query.get("age") is not None and candidate.age > 0:
            components.append((age_score, self.config.age_weight))

        if query.get("last_known_location") and (
            candidate.found_location or candidate.camp_name
        ):
            components.append((location_score, self.config.location_weight))
        if query.get("additional_details") and (
            candidate.last_known_clothing or candidate.additional_details
        ):
            components.append((details_score, self.config.details_weight))

        # Image components are active only when successfully compared.
        # Missing categories contribute zero; fixed weights are never redistributed.
        if clip_score is not None:
            components.append((max(0.0, min(1.0, clip_score)), self.config.clip_weight))
        if face_score is not None:
            components.append((max(0.0, min(1.0, face_score)), self.config.face_weight))

        weight_total = sum(weight for _, weight in components)
        final_score = (
            100 * sum(score * weight for score, weight in components)
            if weight_total
            else 0.0
        )
        scored = ScoredCandidate(
            candidate,
            min(99.0, round(final_score, 2)),
            name_score,
            age_score,
            location_score,
            details_score,
            None if clip_score is None else round(max(0.0, min(1.0, clip_score)), 6),
            None if face_score is None else round(max(0.0, min(1.0, face_score)), 6),
        )
        return self.explain(query, scored)

    def add_image_scores(
        self,
        query: dict,
        metadata_score: ScoredCandidate,
        clip_score: Optional[float] = None,
        face_score: Optional[float] = None,
    ) -> ScoredCandidate:
        """Add visual similarities without recomputing text embeddings."""
        components = [
            (metadata_score.name_score, self.config.name_weight),
        ]
        candidate = metadata_score.candidate

        if query.get("age") is not None and candidate.age > 0:
            components.append((metadata_score.age_score, self.config.age_weight))

        if query.get("last_known_location") and (
            candidate.found_location or candidate.camp_name
        ):
            components.append((metadata_score.location_score, self.config.location_weight))
        if query.get("additional_details") and (
            candidate.last_known_clothing or candidate.additional_details
        ):
            components.append((metadata_score.details_score, self.config.details_weight))

        if clip_score is not None:
            components.append((max(0.0, min(1.0, clip_score)), self.config.clip_weight))
        if face_score is not None:
            components.append((max(0.0, min(1.0, face_score)), self.config.face_weight))

        weight_total = sum(weight for _, weight in components)
        final_score = 100 * sum(score * weight for score, weight in components) if weight_total else 0.0

        scored = ScoredCandidate(
            candidate,
            min(99.0, round(final_score, 2)),
            metadata_score.name_score,
            metadata_score.age_score,
            metadata_score.location_score,
            metadata_score.details_score,
            None if clip_score is None else round(max(0.0, min(1.0, clip_score)), 6),
            None if face_score is None else round(max(0.0, min(1.0, face_score)), 6),
        )
        return self.explain(query, scored)

    def explain(self, query: dict, scored: ScoredCandidate) -> ScoredCandidate:
        """Generate a user-facing label and a short explanation of the match."""
        score = scored.match_score
        if score >= self.config.threshold_strong:
            label = "Strong Match"
        elif score >= self.config.threshold_possible:
            label = "Possible Match"
        elif score >= self.config.threshold_weak:
            label = "Weak Match"
        else:
            label = None  # Should be filtered out

        signals = []
        if scored.face_score is not None and scored.face_score > 0.8:
            signals.append("face")
        elif scored.clip_score is not None and scored.clip_score > 0.85:
            # CLIP is mentioned only if face isn't strong or is missing
            signals.append("visuals")

        if scored.name_score > 0.8:
            signals.append("name")
        if scored.age_score > 0.9:
            signals.append("age")
        if scored.location_score > 0.8:
            signals.append("location")
        if scored.details_score > 0.8:
            signals.append("details")

        explanation = None
        if signals:
            if len(signals) == 1:
                explanation = f"Strong similarity in {signals[0]}."
            elif len(signals) == 2:
                explanation = f"Strong similarity in {signals[0]} and {signals[1]}."
            else:
                explanation = f"Strong similarity in {', '.join(signals[:-1])} and {signals[-1]}."

        return ScoredCandidate(
            candidate=scored.candidate,
            match_score=scored.match_score,
            name_score=scored.name_score,
            age_score=scored.age_score,
            location_score=scored.location_score,
            details_score=scored.details_score,
            clip_score=scored.clip_score,
            face_score=scored.face_score,
            match_label=label,
            explanation=explanation,
        )

    def _name_score(self, query_name: str, candidate_name: str) -> float:
        query_normalized = normalize_text(query_name)
        candidate_normalized = normalize_text(candidate_name)
        if not query_normalized or not candidate_normalized:
            return 0.0
        if query_normalized == candidate_normalized:
            return 1.0
        query_tokens = set(query_normalized.split())
        candidate_tokens = set(candidate_normalized.split())
        token_score = len(query_tokens & candidate_tokens) / max(
            len(query_tokens), len(candidate_tokens)
        )
        semantic_score = self.similarity.similarity(
            query_normalized, candidate_normalized
        )
        return max(token_score, semantic_score)

    def _text_score(self, query_text: Optional[str], candidate_text: str) -> float:
        if not query_text or not candidate_text:
            return 0.0
        query_normalized = normalize_text(query_text)
        candidate_normalized = normalize_text(candidate_text)
        if query_normalized == candidate_normalized:
            return 1.0
        return self.similarity.similarity(query_normalized, candidate_normalized)

    @staticmethod
    def _age_score(query_age: Optional[int], candidate_age: int) -> float:
        if query_age is None:
            return 0.0
        return max(0.0, 1.0 - abs(query_age - candidate_age) / 10.0)

