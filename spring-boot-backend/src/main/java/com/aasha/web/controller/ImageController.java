package com.aasha.web.controller;

import com.aasha.web.dto.ImageStorageReference;
import com.aasha.web.service.PhotoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/images")
public class ImageController {

    private static final Logger log = LoggerFactory.getLogger(ImageController.class);
    private final PhotoService photoService;

    public ImageController(PhotoService photoService) {
        this.photoService = photoService;
    }

    @PostMapping("/normal")
    public ResponseEntity<?> uploadNormalPhoto(
            @RequestParam("record_id") String recordId,
            @RequestParam("file") MultipartFile file) {
        try {
            log.info("Uploading normal photo for record: {}", recordId);
            ImageStorageReference ref = photoService.uploadNormalPhoto(recordId, file);
            return ResponseEntity.ok(ref.toJson());
        } catch (Exception e) {
            log.error("Failed to upload normal photo", e);
            return ResponseEntity.badRequest().body(Map.of("detail", "Image upload failed: " + e.getMessage()));
        }
    }

    @PostMapping("/critical")
    public ResponseEntity<?> uploadCriticalPhoto(
            @RequestParam("record_id") String recordId,
            @RequestParam("file") MultipartFile file) {
        try {
            log.info("Uploading critical photo for record: {}", recordId);
            ImageStorageReference ref = photoService.uploadCriticalPhoto(recordId, file);
            return ResponseEntity.ok(ref.toJson());
        } catch (Exception e) {
            log.error("Failed to upload critical photo", e);
            return ResponseEntity.badRequest().body(Map.of("detail", "Image upload failed: " + e.getMessage()));
        }
    }

    @PostMapping("/critical-clothing")
    public ResponseEntity<?> uploadCriticalClothing(
            @RequestParam("record_id") String recordId,
            @RequestParam("file") MultipartFile file) {
        try {
            log.info("Uploading critical clothing photo for record: {}", recordId);
            ImageStorageReference ref = photoService.uploadCriticalClothing(recordId, file);
            return ResponseEntity.ok(ref.toJson());
        } catch (Exception e) {
            log.error("Failed to upload critical clothing photo", e);
            return ResponseEntity.badRequest().body(Map.of("detail", "Image upload failed: " + e.getMessage()));
        }
    }

    @PostMapping("/match-input")
    public ResponseEntity<?> uploadMatchInput(
            @RequestParam("request_id") String requestId,
            @RequestParam("file") MultipartFile file) {
        try {
            log.info("Uploading match input photo for request: {}", requestId);
            ImageStorageReference ref = photoService.uploadMatchInput(requestId, file);
            return ResponseEntity.ok(ref.toJson());
        } catch (Exception e) {
            log.error("Failed to upload match input photo", e);
            return ResponseEntity.badRequest().body(Map.of("detail", "Image upload failed: " + e.getMessage()));
        }
    }

    @GetMapping("/url")
    public ResponseEntity<?> getImageUrl(@RequestParam("storage_id") String storageId) {
        String url = photoService.getImageUrl(storageId);
        if (url != null) {
            return ResponseEntity.ok(Map.of("url", url));
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/bytes/{assetId}")
    public ResponseEntity<byte[]> getImageBytes(@PathVariable String assetId) {
        try {
            byte[] bytes = photoService.getImageBytes(assetId);
            if (bytes != null) {
                return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_TYPE, MediaType.IMAGE_JPEG_VALUE)
                    .body(bytes);
            }
        } catch (Exception e) {
            log.error("Failed to get image bytes", e);
        }
        return ResponseEntity.notFound().build();
    }

    @DeleteMapping("/temporary/{assetId}")
    public ResponseEntity<?> deleteTemporary(@PathVariable String assetId) {
        photoService.deleteTemporary(assetId);
        return ResponseEntity.ok(Map.of("status", "deleted"));
    }

    @GetMapping("/file/{*path}")
    public ResponseEntity<byte[]> serveFile(@PathVariable String path) {
        try {
            String clean = path.startsWith("/") ? path.substring(1) : path;
            java.nio.file.Path filePath = java.nio.file.Paths.get("uploads", "photos", clean);
            java.nio.file.Path absolutePath = filePath.toAbsolutePath();
            log.info("Serving file: {}", absolutePath);
            if (java.nio.file.Files.exists(absolutePath)) {
                byte[] bytes = java.nio.file.Files.readAllBytes(absolutePath);
                String contentType = path.endsWith(".png") ? "image/png" : "image/jpeg";
                return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_TYPE, contentType)
                    .body(bytes);
            }
            byte[] fromMinio = photoService.getMinioBytes(clean);
            if (fromMinio != null) {
                String contentType = path.endsWith(".png") ? "image/png" : "image/jpeg";
                return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_TYPE, contentType)
                    .body(fromMinio);
            }
            log.warn("File not found: {}", absolutePath);
        } catch (Exception e) {
            log.error("Failed to serve file: {}", path, e);
        }
        return ResponseEntity.notFound().build();
    }
}
