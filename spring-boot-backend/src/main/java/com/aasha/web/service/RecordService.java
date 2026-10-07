package com.aasha.web.service;

import com.aasha.web.dto.DashboardStats;
import com.aasha.web.entity.Camp;
import com.aasha.web.entity.CriticalRecord;
import com.aasha.web.entity.NormalRecord;
import com.aasha.web.repository.CampRepository;
import com.aasha.web.repository.CriticalRecordRepository;
import com.aasha.web.repository.NormalRecordRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RecordService {

    private static final Logger log = LoggerFactory.getLogger(RecordService.class);

    private final NormalRecordRepository normalRecordRepo;
    private final CriticalRecordRepository criticalRecordRepo;
    private final CampRepository campRepo;

    public RecordService(NormalRecordRepository normalRecordRepo,
                         CriticalRecordRepository criticalRecordRepo,
                         CampRepository campRepo) {
        this.normalRecordRepo = normalRecordRepo;
        this.criticalRecordRepo = criticalRecordRepo;
        this.campRepo = campRepo;
    }

    public List<NormalRecord> searchNormalRecords(String name, Integer age) {
        log.info("Searching normal records: name={}, age={}", name, age);
        if (name != null && !name.trim().isEmpty() && age != null) {
            return normalRecordRepo.findByNameAndAge(name.trim(), age);
        }
        if (name != null && !name.trim().isEmpty()) {
            return normalRecordRepo.findByNameContaining(name.trim());
        }
        return normalRecordRepo.findTop20ByOrderByCreatedAtDesc();
    }

    public List<CriticalRecord> searchCriticalRecords(String name, Integer age) {
        log.info("Searching critical records: name={}, age={}", name, age);
        if (name != null && !name.trim().isEmpty() && age != null) {
            return criticalRecordRepo.findByNameAndAge(name.trim(), age);
        }
        if (name != null && !name.trim().isEmpty()) {
            return criticalRecordRepo.findByNameContaining(name.trim());
        }
        return criticalRecordRepo.findTop20ByOrderByCreatedAtDesc();
    }

    public List<Camp> getActiveCamps() {
        return campRepo.findByActiveTrue();
    }

    public List<Camp> getAllCamps() {
        return campRepo.findAll();
    }

    public List<Camp> searchCamps(String query) {
        if (query == null || query.trim().isEmpty()) {
            return getActiveCamps();
        }
        return campRepo.search(query.trim());
    }

    public DashboardStats getStats() {
        DashboardStats stats = new DashboardStats();
        stats.setTotalNormalRecords(normalRecordRepo.count());
        stats.setTotalCriticalRecords(criticalRecordRepo.count());
        stats.setTotalCamps(campRepo.count());
        stats.setAtCampCount(normalRecordRepo.countByStatus("AT_CAMP"));
        stats.setIdentifiedCount(criticalRecordRepo.countByStatus("IDENTIFIED"));
        stats.setUnidentifiedCount(criticalRecordRepo.countByStatus("UNIDENTIFIED"));
        return stats;
    }

    public List<NormalRecord> getRecentNormalRecords() {
        return normalRecordRepo.findTop20ByOrderByCreatedAtDesc();
    }

    public List<CriticalRecord> getRecentCriticalRecords() {
        return criticalRecordRepo.findTop20ByOrderByCreatedAtDesc();
    }
}
