package com.aasha.web.controller;

import com.aasha.web.dto.SosRequest;
import com.aasha.web.dto.SosResponse;
import com.aasha.web.dto.SosStatusRequest;
import com.aasha.web.service.UserSosService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/sos")
public class UserSosController {
    private final UserSosService service;

    public UserSosController(UserSosService service) { this.service = service; }

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<SosResponse> create(
            @Valid @RequestBody SosRequest request,
            Authentication authentication
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(service.create(request, authentication.getName()));
    }

    @GetMapping
    @PreAuthorize("hasRole('OFFICIAL')")
    public ResponseEntity<List<SosResponse>> all(@RequestParam(required = false) String status) {
        return ResponseEntity.ok(service.all(status));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('OFFICIAL')")
    public ResponseEntity<SosResponse> get(@PathVariable String id) {
        return ResponseEntity.ok(service.get(id));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasRole('OFFICIAL')")
    public ResponseEntity<SosResponse> updateStatus(
            @PathVariable String id,
            @Valid @RequestBody SosStatusRequest request
    ) {
        return ResponseEntity.ok(service.updateStatus(id, request));
    }

    @ExceptionHandler({IllegalArgumentException.class})
    public ResponseEntity<Map<String, String>> badRequest(IllegalArgumentException exception) {
        return ResponseEntity.badRequest().body(Map.of("error", exception.getMessage()));
    }

    @ExceptionHandler(UserSosService.SosConflictException.class)
    public ResponseEntity<Map<String, String>> conflict(UserSosService.SosConflictException exception) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(Map.of("error", exception.getMessage()));
    }

    @ExceptionHandler(UserSosService.SosNotFoundException.class)
    public ResponseEntity<Void> notFound() { return ResponseEntity.notFound().build(); }
}