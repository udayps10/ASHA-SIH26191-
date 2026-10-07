package com.aasha.web.service;

import com.aasha.web.entity.SavedSearch;
import com.aasha.web.repository.SavedSearchRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);
    private final SavedSearchRepository savedSearchRepo;
    private final RestTemplate restTemplate;

    @Value("${n8n.webhook-url:}")
    private String n8nWebhookUrl;

    public NotificationService(SavedSearchRepository savedSearchRepo) {
        this.savedSearchRepo = savedSearchRepo;
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(3000);
        factory.setReadTimeout(15000);
        this.restTemplate = new RestTemplate(factory);
    }

    public void onNewRecordCreated(String recordId, String recordType, String name, Integer age, String campName, String officerName, String officerContact) {
        if (n8nWebhookUrl == null || n8nWebhookUrl.isEmpty()) {
            log.info("n8n webhook URL not configured, skipping notification");
            return;
        }

        List<SavedSearch> matchingSearches = savedSearchRepo.findMatchingByName(name);
        log.info("Found {} matching saved searches for name: {}", matchingSearches.size(), name);

        for (SavedSearch search : matchingSearches) {
            try {
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);

                Map<String, Object> payload = Map.of(
                    "recordId", recordId,
                    "recordType", recordType,
                    "name", name,
                    "age", age != null ? age : 0,
                    "campName", campName != null ? campName : "",
                    "officerName", officerName != null ? officerName : "",
                    "officerContact", officerContact != null ? officerContact : "",
                    "savedSearchId", search.getId(),
                    "userPhone", search.getUserPhone(),
                    "searchName", search.getSearchName()
                );

                HttpEntity<Map<String, Object>> request = new HttpEntity<>(payload, headers);
                ResponseEntity<String> response = restTemplate.postForEntity(n8nWebhookUrl, request, String.class);
                log.info("Notification workflow completed for saved search {}: status={} (delivery not confirmed)", search.getId(), response.getStatusCode());

            } catch (Exception e) {
                log.error("Failed to call n8n webhook for saved search {}: {}", search.getId(), e.getMessage());
            }
        }
    }
}
