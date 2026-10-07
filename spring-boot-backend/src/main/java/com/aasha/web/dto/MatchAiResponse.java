package com.aasha.web.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public class MatchAiResponse {
    @JsonProperty("request_id")
    private String requestId;
    private List<Result> results;
    @JsonProperty("has_more")
    private boolean hasMore;
    @JsonProperty("next_page_token")
    private String nextPageToken;

    public String getRequestId() { return requestId; }
    public void setRequestId(String requestId) { this.requestId = requestId; }
    public List<Result> getResults() { return results; }
    public void setResults(List<Result> results) { this.results = results; }
    public boolean isHasMore() { return hasMore; }
    public void setHasMore(boolean hasMore) { this.hasMore = hasMore; }
    public String getNextPageToken() { return nextPageToken; }
    public void setNextPageToken(String nextPageToken) { this.nextPageToken = nextPageToken; }

    public static class Result {
        @JsonProperty("record_id") private String recordId;
        private String name;
        private Integer age;
        @JsonProperty("camp_name") private String campName;
        @JsonProperty("officer_name") private String officerName;
        @JsonProperty("officer_contact") private String officerContact;
        private String status;
        @JsonProperty("match_score") private Double matchScore;
        @JsonProperty("record_type") private String recordType;
        @JsonProperty("photo_url") private String photoUrl;
        @JsonProperty("last_known_clothing") private String lastKnownClothing;
        @JsonProperty("match_label") private String matchLabel;
        private String explanation;

        public String getRecordId() { return recordId; }
        public void setRecordId(String value) { recordId = value; }
        public String getName() { return name; }
        public void setName(String value) { name = value; }
        public Integer getAge() { return age; }
        public void setAge(Integer value) { age = value; }
        public String getCampName() { return campName; }
        public void setCampName(String value) { campName = value; }
        public String getOfficerName() { return officerName; }
        public void setOfficerName(String value) { officerName = value; }
        public String getOfficerContact() { return officerContact; }
        public void setOfficerContact(String value) { officerContact = value; }
        public String getStatus() { return status; }
        public void setStatus(String value) { status = value; }
        public Double getMatchScore() { return matchScore; }
        public void setMatchScore(Double value) { matchScore = value; }
        public String getRecordType() { return recordType; }
        public void setRecordType(String value) { recordType = value; }
        public String getPhotoUrl() { return photoUrl; }
        public void setPhotoUrl(String value) { photoUrl = value; }
        public String getLastKnownClothing() { return lastKnownClothing; }
        public void setLastKnownClothing(String value) { lastKnownClothing = value; }
        public String getMatchLabel() { return matchLabel; }
        public void setMatchLabel(String value) { matchLabel = value; }
        public String getExplanation() { return explanation; }
        public void setExplanation(String value) { explanation = value; }
    }
}