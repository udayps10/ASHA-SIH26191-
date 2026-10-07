package com.aasha.web.controller;

import com.aasha.web.service.PhotoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Serves normal photos at /uploads/{recordId}/{fileName} with local-disk
 * first and MinIO fallback, so URLs keep working when the local file is gone
 * (e.g. fresh container without a volume). Wins over the static /uploads/**
 * resource handler because controller mappings take precedence; the URL
 * contract is unchanged.
 */
@RestController
public class UploadsController {

    private static final Logger log = LoggerFactory.getLogger(UploadsController.class);

    private final PhotoService photoService;

    public UploadsController(PhotoService photoService) {
        this.photoService = photoService;
    }

    @GetMapping("/uploads/{recordId}/{fileName}")
    public ResponseEntity<byte[]> serve(@PathVariable String recordId, @PathVariable String fileName) {
        try {
            Path absolutePath = Paths.get("uploads", "photos", recordId, fileName).toAbsolutePath();
            if (Files.exists(absolutePath)) {
                return ok(Files.readAllBytes(absolutePath), fileName);
            }
            byte[] fromMinio = photoService.getMinioBytes(recordId + "/" + fileName);
            if (fromMinio != null) {
                return ok(fromMinio, fileName);
            }
            log.warn("Upload not found locally or in MinIO: {}", absolutePath);
        } catch (Exception e) {
            log.error("Failed to serve upload {}/{}", recordId, fileName, e);
        }
        return ResponseEntity.notFound().build();
    }

    private static ResponseEntity<byte[]> ok(byte[] bytes, String fileName) {
        String contentType = fileName.toLowerCase().endsWith(".png") ? "image/png" : "image/jpeg";
        return ResponseEntity.ok().header(HttpHeaders.CONTENT_TYPE, contentType).body(bytes);
    }
}
