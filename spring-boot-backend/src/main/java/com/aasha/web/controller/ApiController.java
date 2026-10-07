package com.aasha.web.controller;

import com.aasha.web.entity.Camp;
import com.aasha.web.entity.CriticalRecord;
import com.aasha.web.entity.NormalRecord;
import com.aasha.web.repository.CampRepository;
import com.aasha.web.repository.CriticalRecordRepository;
import com.aasha.web.repository.NormalRecordRepository;
import com.aasha.web.service.NotificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
public class ApiController {

    private final CampRepository campRepo;
    private final NormalRecordRepository normalRepo;
    private final CriticalRecordRepository criticalRepo;
    private final NotificationService notificationService;

    public ApiController(CampRepository campRepo, NormalRecordRepository normalRepo, CriticalRecordRepository criticalRepo, NotificationService notificationService) {
        this.campRepo = campRepo;
        this.normalRepo = normalRepo;
        this.criticalRepo = criticalRepo;
        this.notificationService = notificationService;
    }

    // ==================== CAMPS ====================

    @GetMapping("/camps/list")
    public ResponseEntity<List<Camp>> listCamps() {
        return ResponseEntity.ok(campRepo.findAll());
    }

    @GetMapping("/camps/list/active")
    public ResponseEntity<List<Camp>> listActiveCamps() {
        return ResponseEntity.ok(campRepo.findByActiveTrue());
    }

    @PostMapping("/camps")
    public ResponseEntity<Camp> createCamp(@RequestBody Camp camp) {
        camp.setId(UUID.randomUUID().toString());
        return ResponseEntity.ok(campRepo.save(camp));
    }

    @PutMapping("/camps/{id}")
    public ResponseEntity<Camp> updateCamp(@PathVariable String id, @RequestBody Camp camp) {
        camp.setId(id);
        return ResponseEntity.ok(campRepo.save(camp));
    }

    @DeleteMapping("/camps/{id}")
    public ResponseEntity<?> deleteCamp(@PathVariable String id) {
        campRepo.deleteById(id);
        return ResponseEntity.ok(Map.of("status", "deleted"));
    }

    // ==================== NORMAL RECORDS ====================

    @GetMapping("/normal-records/list")
    public ResponseEntity<List<NormalRecord>> listNormalRecords() {
        return ResponseEntity.ok(normalRepo.findTop20ByOrderByCreatedAtDesc());
    }

    @GetMapping("/normal-records/{id}")
    public ResponseEntity<NormalRecord> getNormalRecord(@PathVariable String id) {
        return normalRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/normal-records")
    public ResponseEntity<NormalRecord> createNormalRecord(@RequestBody NormalRecord record) {
        record.setId(UUID.randomUUID().toString());
        NormalRecord saved = normalRepo.save(record);

        notificationService.onNewRecordCreated(
            saved.getId(), "NORMAL", saved.getName(), saved.getAge(),
            saved.getCampName(), saved.getOfficerName(), saved.getOfficerContact()
        );

        return ResponseEntity.ok(saved);
    }

    @PutMapping("/normal-records/{id}")
    public ResponseEntity<NormalRecord> updateNormalRecord(@PathVariable String id, @RequestBody NormalRecord record) {
        record.setId(id);
        return ResponseEntity.ok(normalRepo.save(record));
    }

    @PatchMapping("/normal-records/{id}/status")
    public ResponseEntity<?> updateNormalStatus(@PathVariable String id, @RequestBody Map<String, String> body) {
        var record = normalRepo.findById(id);
        if (record.isEmpty()) return ResponseEntity.notFound().build();
        NormalRecord r = record.get();
        r.setStatus(body.get("status"));
        normalRepo.save(r);
        return ResponseEntity.ok(Map.of("status", "updated"));
    }

    @DeleteMapping("/normal-records/{id}")
    public ResponseEntity<?> deleteNormalRecord(@PathVariable String id) {
        normalRepo.deleteById(id);
        return ResponseEntity.ok(Map.of("status", "deleted"));
    }

    // ==================== CRITICAL RECORDS ====================

    @GetMapping("/critical-records/list")
    public ResponseEntity<List<CriticalRecord>> listCriticalRecords() {
        return ResponseEntity.ok(criticalRepo.findTop20ByOrderByCreatedAtDesc());
    }

    @GetMapping("/critical-records/{id}")
    public ResponseEntity<CriticalRecord> getCriticalRecord(@PathVariable String id) {
        return criticalRepo.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/critical-records")
    public ResponseEntity<CriticalRecord> createCriticalRecord(@RequestBody CriticalRecord record) {
        record.setId(UUID.randomUUID().toString());
        CriticalRecord saved = criticalRepo.save(record);

        notificationService.onNewRecordCreated(
            saved.getId(), "CRITICAL", saved.getName(), saved.getAge(),
            saved.getCampName(), saved.getOfficerName(), saved.getOfficerContact()
        );

        return ResponseEntity.ok(saved);
    }

    @PutMapping("/critical-records/{id}")
    public ResponseEntity<CriticalRecord> updateCriticalRecord(@PathVariable String id, @RequestBody CriticalRecord record) {
        record.setId(id);
        return ResponseEntity.ok(criticalRepo.save(record));
    }

    @PatchMapping("/critical-records/{id}/status")
    public ResponseEntity<?> updateCriticalStatus(@PathVariable String id, @RequestBody Map<String, String> body) {
        var record = criticalRepo.findById(id);
        if (record.isEmpty()) return ResponseEntity.notFound().build();
        CriticalRecord r = record.get();
        r.setStatus(body.get("status"));
        criticalRepo.save(r);
        return ResponseEntity.ok(Map.of("status", "updated"));
    }

    @DeleteMapping("/critical-records/{id}")
    public ResponseEntity<?> deleteCriticalRecord(@PathVariable String id) {
        criticalRepo.deleteById(id);
        return ResponseEntity.ok(Map.of("status", "deleted"));
    }

    // ==================== SYNC BULK OPERATIONS ====================

    @PostMapping("/sync/camps")
    public ResponseEntity<?> syncCamps(@RequestBody List<Camp> camps) {
        for (Camp camp : camps) {
            if (camp.getId() == null || camp.getId().isEmpty()) {
                camp.setId(UUID.randomUUID().toString());
            }
            campRepo.save(camp);
        }
        return ResponseEntity.ok(Map.of("synced", camps.size()));
    }

    @PostMapping("/sync/normal-records")
    public ResponseEntity<?> syncNormalRecords(@RequestBody List<NormalRecord> records) {
        for (NormalRecord record : records) {
            if (record.getId() == null || record.getId().isEmpty()) {
                record.setId(UUID.randomUUID().toString());
            }
            normalRepo.save(record);
        }
        return ResponseEntity.ok(Map.of("synced", records.size()));
    }

    @PostMapping("/sync/critical-records")
    public ResponseEntity<?> syncCriticalRecords(@RequestBody List<CriticalRecord> records) {
        for (CriticalRecord record : records) {
            if (record.getId() == null || record.getId().isEmpty()) {
                record.setId(UUID.randomUUID().toString());
            }
            criticalRepo.save(record);
        }
        return ResponseEntity.ok(Map.of("synced", records.size()));
    }
}
