package com.aasha.web.service;

import com.aasha.web.dto.MatchAiRequest;
import com.aasha.web.dto.MatchAiResponse;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Service
public class AiMatchingClient {
    private final RestTemplate restTemplate;
    private final String aiUrl;

    public AiMatchingClient(
            RestTemplate restTemplate,
            @Value("${matching.ai-url:http://localhost:8000/api/v1/match}") String aiUrl
    ) {
        this.restTemplate = restTemplate;
        this.aiUrl = aiUrl;
    }

    public MatchAiResponse rank(MatchAiRequest request) {
        try {
                ResponseEntity<MatchAiResponse> response = restTemplate.postForEntity(
                    aiUrl, request, MatchAiResponse.class);
            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                throw new MatchingServiceException("AI matching service returned an empty response");
            }
            return response.getBody();
        } catch (RestClientException error) {
            throw new MatchingServiceException("AI matching service is unavailable", error);
        }
    }

    public MatchAiResponse more(Map<String, Object> request) {
        try {
            ResponseEntity<MatchAiResponse> response = restTemplate.postForEntity(
                    aiUrl + "/more", request, MatchAiResponse.class);
            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                throw new MatchingServiceException("AI matching service returned an empty response");
            }
            return response.getBody();
        } catch (RestClientException error) {
            throw new MatchingServiceException("AI matching service is unavailable", error);
        }
    }

    public static class MatchingServiceException extends RuntimeException {
        public MatchingServiceException(String message) { super(message); }
        public MatchingServiceException(String message, Throwable cause) { super(message, cause); }
    }
}