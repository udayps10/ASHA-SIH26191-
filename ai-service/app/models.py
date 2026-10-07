from typing import Optional

from pydantic import AliasChoices, BaseModel, ConfigDict, Field


class MatchRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    name: str = Field(default="")
    age: Optional[int] = Field(default=None, ge=0, le=120)
    last_known_location: Optional[str] = Field(
        default=None,
        validation_alias=AliasChoices("last_known_location", "lastKnownLocation"),
    )
    additional_details: Optional[str] = Field(
        default=None,
        validation_alias=AliasChoices("additional_details", "additionalDetails"),
    )
    photo: Optional[str] = None
    candidates: list["CandidateInput"] = Field(default_factory=list)


class CandidateInput(BaseModel):
    record_id: str
    record_type: str
    name: str
    age: Optional[int] = None
    camp_name: str = ""
    status: str = ""
    officer_name: str = ""
    officer_contact: str = ""
    photo_url: Optional[str] = None
    last_known_clothing: Optional[str] = None
    found_location: Optional[str] = None
    additional_details: Optional[str] = None


class MatchMoreRequest(BaseModel):
    request_id: str = Field(
        ..., validation_alias=AliasChoices("request_id", "requestId")
    )
    page_token: str = Field(
        ..., validation_alias=AliasChoices("page_token", "pageToken")
    )


class MatchResult(BaseModel):
    record_id: str
    name: str
    age: int
    camp_name: str
    officer_name: str
    officer_contact: str
    status: str
    match_score: float
    record_type: str
    photo_url: Optional[str] = None
    last_known_clothing: Optional[str] = None
    match_label: Optional[str] = None
    explanation: Optional[str] = None


class MatchResponse(BaseModel):
    request_id: str
    results: list[MatchResult]
    has_more: bool
    next_page_token: Optional[str] = None
