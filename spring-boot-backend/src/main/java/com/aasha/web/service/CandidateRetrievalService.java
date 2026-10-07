package com.aasha.web.service;

import com.aasha.web.dto.MatchCandidate;
import com.aasha.web.entity.CriticalRecord;
import com.aasha.web.entity.NormalRecord;
import com.aasha.web.repository.CriticalRecordRepository;
import com.aasha.web.repository.NormalRecordRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.data.domain.PageRequest;

@Service
public class CandidateRetrievalService {
    private final NormalRecordRepository normalRepository;
    private final CriticalRecordRepository criticalRepository;
    private final int maxCandidates;
    private final int ageTolerance;

    public CandidateRetrievalService(
            NormalRecordRepository normalRepository,
            CriticalRecordRepository criticalRepository,
            @Value("${matching.candidate-pool-size:100}") int maxCandidates,
            @Value("${matching.age-tolerance:5}") int ageTolerance
    ) {
        this.normalRepository = normalRepository;
        this.criticalRepository = criticalRepository;
        this.maxCandidates = Math.max(1, maxCandidates);
        this.ageTolerance = Math.max(0, ageTolerance);
    }

    public List<MatchCandidate> retrieve(String name, Integer age, String location, String details) {
        PageRequest retrievalLimit = PageRequest.of(0, maxCandidates);
        Map<String, MatchCandidate> candidates = new LinkedHashMap<>();
        addNormal(candidates, normalRepository.findTop20ByOrderByCreatedAtDesc());
        addCritical(candidates, criticalRepository.findTop20ByOrderByCreatedAtDesc());

        if (name != null && !name.isBlank()) {
            addNormal(candidates, normalRepository.findByNameContainingLimited(name.trim(), retrievalLimit));
            addCritical(candidates, criticalRepository.findByNameContainingLimited(name.trim(), retrievalLimit));
            for (String token : name.trim().split("\\s+")) {
                if (token.length() >= 2) {
                    addNormal(candidates, normalRepository.findByToken(token, retrievalLimit));
                    addCritical(candidates, criticalRepository.findByToken(token, retrievalLimit));
                }
            }
        }
        if (age != null) {
            addNormal(candidates, normalRepository.findByAgeBetween(age - ageTolerance, age + ageTolerance, retrievalLimit));
            addCritical(candidates, criticalRepository.findByAgeBetween(age - ageTolerance, age + ageTolerance, retrievalLimit));
        }
        if (location != null && !location.isBlank()) {
            addNormal(candidates, normalRepository.findByLocationContaining(location.trim(), retrievalLimit));
            addCritical(candidates, criticalRepository.findByLocationContaining(location.trim(), retrievalLimit));
        }

        return candidates.values().stream().limit(maxCandidates).toList();
    }

    private void addNormal(Map<String, MatchCandidate> target, List<NormalRecord> records) {
        records.forEach(record -> {
            String key = "normal:" + record.getId();
            target.putIfAbsent(key, new MatchCandidate(
                record.getId(), "normal", record.getName(), record.getAge(), record.getCampName(),
                record.getStatus(), record.getOfficerName(), record.getOfficerContact(),
                record.getPhotoUrl(), null, null, record.getAdditionalDetails()));
        });
    }

    private void addCritical(Map<String, MatchCandidate> target, List<CriticalRecord> records) {
        records.forEach(record -> {
            String key = "critical:" + record.getId();
            target.putIfAbsent(key, new MatchCandidate(
                record.getId(), "critical", record.getName(), record.getAge(), record.getCampName(),
                record.getStatus(), record.getOfficerName(), record.getOfficerContact(), null,
                record.getLastKnownClothing(), record.getFoundLocation(), record.getAdditionalDetails()));
        });
    }
}