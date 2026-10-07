package com.aasha.web.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record MatchCandidate(
        @JsonProperty("record_id") String recordId,
        @JsonProperty("record_type") String recordType,
        String name,
        Integer age,
        @JsonProperty("camp_name") String campName,
        String status,
        @JsonProperty("officer_name") String officerName,
        @JsonProperty("officer_contact") String officerContact,
        @JsonProperty("photo_url") String photoUrl,
        @JsonProperty("last_known_clothing") String lastKnownClothing,
        @JsonProperty("found_location") String foundLocation,
        @JsonProperty("additional_details") String additionalDetails
) {}