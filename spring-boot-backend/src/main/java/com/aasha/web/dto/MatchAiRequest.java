package com.aasha.web.dto;

import java.util.List;

public record MatchAiRequest(
        String name,
        Integer age,
        String lastKnownLocation,
        String additionalDetails,
        String photo,
        List<MatchCandidate> candidates
) {}