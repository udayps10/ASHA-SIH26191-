package com.aasha.web.controller;

import com.aasha.web.dto.AuthRequest;
import com.aasha.web.dto.AuthResponse;
import com.aasha.web.entity.AppUser;
import com.aasha.web.repository.UserRepository;
import com.aasha.web.service.JwtService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserRepository userRepo;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;

    public AuthController(UserRepository userRepo, JwtService jwtService, PasswordEncoder passwordEncoder) {
        this.userRepo = userRepo;
        this.jwtService = jwtService;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody AuthRequest request) {
        if (userRepo.existsByEmail(request.getEmail())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email already registered"));
        }

        AppUser user = new AppUser();
        user.setUid(UUID.randomUUID().toString());
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setRole("user");
        user.setApproved(true);
        userRepo.save(user);

        String token = jwtService.generateToken(user.getUid(), user.getEmail(), user.getRole());
        return ResponseEntity.ok(new AuthResponse(token, user.getUid(), user.getName(), user.getEmail(), user.getRole(), user.getApproved()));
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
        var userOpt = userRepo.findByEmail(request.getEmail());
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(401).body(Map.of("error", "Invalid email or password"));
        }

        AppUser user = userOpt.get();
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            return ResponseEntity.status(401).body(Map.of("error", "Invalid email or password"));
        }

        if ("official".equals(user.getRole()) && !Boolean.TRUE.equals(user.getApproved())) {
            return ResponseEntity.status(403).body(Map.of("error", "Account pending approval"));
        }

        String token = jwtService.generateToken(user.getUid(), user.getEmail(), user.getRole());
        return ResponseEntity.ok(new AuthResponse(token, user.getUid(), user.getName(), user.getEmail(), user.getRole(), user.getApproved()));
    }

    @GetMapping("/profile")
    public ResponseEntity<?> profile(@RequestHeader("Authorization") String authHeader) {
        String uid = extractUid(authHeader);
        if (uid == null) return ResponseEntity.status(401).body(Map.of("error", "Unauthorized"));

        var userOpt = userRepo.findById(uid);
        if (userOpt.isEmpty()) return ResponseEntity.status(404).body(Map.of("error", "User not found"));

        AppUser user = userOpt.get();
        return ResponseEntity.ok(Map.of(
            "uid", user.getUid(),
            "name", user.getName(),
            "email", user.getEmail(),
            "role", user.getRole(),
            "approved", user.getApproved(),
            "organization", user.getOrganization() != null ? user.getOrganization() : ""
        ));
    }

    private String extractUid(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) return null;
        try {
            return jwtService.getUid(authHeader.substring(7));
        } catch (Exception e) {
            return null;
        }
    }
}
