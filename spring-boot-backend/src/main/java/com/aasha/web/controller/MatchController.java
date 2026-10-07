package com.aasha.web.controller;

import com.aasha.web.dto.MatchAiRequest;
import com.aasha.web.dto.MatchAiResponse;
import com.aasha.web.service.AiMatchingClient;
import com.aasha.web.service.CandidateRetrievalService;
import com.aasha.web.service.PhotoService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/v1/match")
public class MatchController {

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(MatchController.class);
    private final CandidateRetrievalService candidates;
    private final AiMatchingClient ai;
    private final PhotoService photoService;

    public MatchController(CandidateRetrievalService candidates, AiMatchingClient ai, PhotoService photoService) {
        this.candidates = candidates;
        this.ai = ai;
        this.photoService = photoService;
    }

    @PostMapping
    public ResponseEntity<MatchAiResponse> findMatches(@RequestBody Map<String, Object> body) {
        String name = text(body.get("name"));
        Integer age = number(body.get("age"));
        String location = text(body.get("lastKnownLocation"));
        if (location.isEmpty()) location = text(body.get("last_known_location"));
        String details = text(body.get("additionalDetails"));
        if (details.isEmpty()) details = text(body.get("additional_details"));
        String photo = text(body.get("photo"));

        try {
            String photoData = null;
            if (!photo.isEmpty()) {
                try {
                    byte[] image = photoService.getImageBytes(photo);
                    if (image != null) photoData = Base64.getEncoder().encodeToString(image);
                } catch (Exception e) {
                    log.error("Failed to read temporary photo: {}", photo, e);
                }
            }

            var candidatesList = candidates.retrieve(name, age, location, details);
            log.info("Retrieved {} candidates for AI ranking", candidatesList.size());

            MatchAiResponse response;
            try {
                response = ai.rank(new MatchAiRequest(
                    name, age, location.isEmpty() ? null : location,
                    details.isEmpty() ? null : details,
                    photoData,
                    candidatesList));
            } catch (RuntimeException unavailable) {
                response = localFallback(name, age, candidatesList);
            }

            if (response.getResults() != null) {
                for (var result : response.getResults()) {
                    if (result.getCampName() == null) result.setCampName("");
                    if (result.getOfficerName() == null) result.setOfficerName("");
                    if (result.getOfficerContact() == null) result.setOfficerContact("");
                    if (result.getName() == null) result.setName("");
                    if (result.getPhotoUrl() == null && candidatesList != null) {
                        candidatesList.stream().filter(c -> Objects.equals(c.recordId(), result.getRecordId()))
                                .findFirst().ifPresent(c -> result.setPhotoUrl(c.photoUrl()));
                    }
                }
            }
            return ResponseEntity.ok(response);
        } finally {
            if (!photo.isEmpty()) {
                try {
                    photoService.deleteTemporary(photo);
                } catch (Exception e) {
                    log.warn("Failed to delete temporary photo: {}", photo);
                }
            }
        }
    }

    @PostMapping("/more")
    public ResponseEntity<MatchAiResponse> getMoreMatches(@RequestBody Map<String, Object> body) {
        return ResponseEntity.ok(ai.more(body));
    }

    private String text(Object value) { return value == null ? "" : value.toString().trim(); }
    private Integer number(Object value) { return value instanceof Number ? ((Number) value).intValue() : null; }

    private MatchAiResponse localFallback(String query, Integer age, List<com.aasha.web.dto.MatchCandidate> candidates) {
        MatchAiResponse response = new MatchAiResponse();
        response.setRequestId(UUID.randomUUID().toString());
        List<MatchAiResponse.Result> results = new ArrayList<>();
        String q = query == null ? "" : query.toLowerCase();
        for (var candidate : candidates) {
            double score = 35;
            String candidateName = candidate.name() == null ? "" : candidate.name().toLowerCase();
            if (!q.isBlank() && candidateName.equals(q)) score += 55;
            else if (!q.isBlank() && candidateName.contains(q)) score += 40;
            if (age != null && candidate.age() != null) score += Math.max(0, 15 - Math.abs(age - candidate.age()) * 3);
            var result = new MatchAiResponse.Result();
            result.setRecordId(candidate.recordId()); result.setName(candidate.name()); result.setAge(candidate.age());
            result.setCampName(candidate.campName() == null ? "" : candidate.campName()); result.setOfficerName(candidate.officerName() == null ? "" : candidate.officerName());
            result.setOfficerContact(candidate.officerContact() == null ? "" : candidate.officerContact()); result.setStatus(candidate.status());
            result.setRecordType(candidate.recordType()); result.setMatchScore((double) Math.min(99, Math.round(score)));
            result.setPhotoUrl(candidate.photoUrl());
            results.add(result);
        }
        response.setResults(results); response.setHasMore(false);
        return response;
    }
}
