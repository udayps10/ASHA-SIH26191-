package com.aasha.web.controller;

import com.aasha.web.dto.AlertRequest;
import com.aasha.web.dto.AlertResponse;
import com.aasha.web.service.AlertService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/alerts")
public class AlertController {
    private final AlertService service;

    public AlertController(AlertService service) { this.service = service; }

    @GetMapping("/active")
    public ResponseEntity<List<AlertResponse>> active() {
        return ResponseEntity.ok(service.activeAlerts());
    }

    @GetMapping
    @PreAuthorize("hasRole('OFFICIAL')")
    public ResponseEntity<List<AlertResponse>> all() {
        return ResponseEntity.ok(service.allAlerts());
    }

    @PostMapping
    @PreAuthorize("hasRole('OFFICIAL')")
    public ResponseEntity<AlertResponse> create(@Valid @RequestBody AlertRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PatchMapping("/{id}/active")
    @PreAuthorize("hasRole('OFFICIAL')")
    public ResponseEntity<AlertResponse> setActive(
            @PathVariable Long id,
            @RequestBody Map<String, Boolean> request
    ) {
        if (!request.containsKey("active") || request.get("active") == null) {
            throw new IllegalArgumentException("active is required");
        }
        return ResponseEntity.ok(service.setActive(id, request.get("active")));
    }

    @ExceptionHandler({IllegalArgumentException.class})
    public ResponseEntity<Map<String, String>> badRequest(IllegalArgumentException exception) {
        return ResponseEntity.badRequest().body(Map.of("error", exception.getMessage()));
    }

    @ExceptionHandler(AlertService.AlertNotFoundException.class)
    public ResponseEntity<Void> notFound() { return ResponseEntity.notFound().build(); }
}