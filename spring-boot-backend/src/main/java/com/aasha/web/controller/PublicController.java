package com.aasha.web.controller;

import com.aasha.web.dto.DashboardStats;
import com.aasha.web.entity.Camp;
import com.aasha.web.service.RecordService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class PublicController {

    private final RecordService recordService;

    public PublicController(RecordService recordService) {
        this.recordService = recordService;
    }

    @GetMapping("/stats")
    public ResponseEntity<DashboardStats> getStats() {
        return ResponseEntity.ok(recordService.getStats());
    }

    @GetMapping("/camps")
    public ResponseEntity<List<Camp>> getActiveCamps() {
        return ResponseEntity.ok(recordService.getActiveCamps());
    }
}
