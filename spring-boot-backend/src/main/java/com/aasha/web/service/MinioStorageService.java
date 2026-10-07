package com.aasha.web.service;

import io.minio.BucketExistsArgs;
import io.minio.GetObjectArgs;
import io.minio.GetObjectResponse;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.StatObjectArgs;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

import java.io.ByteArrayInputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;

/**
 * MinIO object storage for photos. Every failure degrades gracefully to
 * "unavailable" so the app keeps serving from local disk when MinIO is down.
 * Object keys mirror the local path under uploads/photos (e.g.
 * "{recordId}/{file}", "critical/{recordId}/{file}") so URLs never change.
 */
@Service
public class MinioStorageService {

    private static final Logger log = LoggerFactory.getLogger(MinioStorageService.class);

    private final MinioClient minioClient;
    private final String bucket;
    private final Path localRoot;

    private volatile boolean available = false;

    public MinioStorageService(MinioClient minioClient,
                               @Value("${minio.bucket}") String bucket) {
        this.minioClient = minioClient;
        this.bucket = bucket;
        this.localRoot = Paths.get("uploads", "photos");
    }

    @PostConstruct
    void init() {
        try {
            if (!minioClient.bucketExists(BucketExistsArgs.builder().bucket(bucket).build())) {
                minioClient.makeBucket(MakeBucketArgs.builder().bucket(bucket).build());
                log.info("MinIO created bucket {}", bucket);
            }
            available = true;
            log.info("MinIO ready (bucket={})", bucket);
        } catch (Exception e) {
            available = false;
            log.warn("MinIO unavailable ({}), using local disk only", e.getMessage());
        }
    }

    public boolean isAvailable() {
        return available;
    }

    /** Store bytes under objectKey. Returns false if skipped or failed. */
    public boolean put(String objectKey, byte[] bytes, String contentType) {
        if (!available) {
            return false;
        }
        try {
            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(bucket)
                    .object(objectKey)
                    .stream(new ByteArrayInputStream(bytes), bytes.length, -1)
                    .contentType(contentType != null ? contentType : "application/octet-stream")
                    .build());
            return true;
        } catch (Exception e) {
            log.warn("MinIO put failed for {}: {}", objectKey, e.getMessage());
            return false;
        }
    }

    /** Read object bytes, or null if unavailable/missing. */
    public byte[] get(String objectKey) {
        if (!available || objectKey == null || objectKey.isBlank()) {
            return null;
        }
        try (GetObjectResponse response = minioClient.getObject(GetObjectArgs.builder()
                .bucket(bucket)
                .object(objectKey)
                .build())) {
            return response.readAllBytes();
        } catch (Exception e) {
            log.debug("MinIO get miss for {}: {}", objectKey, e.getMessage());
            return null;
        }
    }

    private boolean exists(String objectKey) {
        try {
            minioClient.statObject(StatObjectArgs.builder().bucket(bucket).object(objectKey).build());
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * One-time pass at boot: copy every local file under uploads/photos into
     * MinIO when the object is not already there. Never fails startup.
     */
    @EventListener(ApplicationReadyEvent.class)
    public void migrateLocalFiles() {
        if (!available || !Files.isDirectory(localRoot)) {
            return;
        }
        int copied = 0;
        try (Stream<Path> paths = Files.walk(localRoot)) {
            for (Path file : (Iterable<Path>) paths.filter(Files::isRegularFile)::iterator) {
                String key = localRoot.relativize(file).toString().replace('\\', '/');
                if (exists(key)) {
                    continue;
                }
                if (put(key, Files.readAllBytes(file), contentType(key))) {
                    copied++;
                }
            }
        } catch (Exception e) {
            log.warn("MinIO local migration stopped: {}", e.getMessage());
        }
        if (copied > 0) {
            log.info("MinIO migration copied {} local file(s) into bucket {}", copied, bucket);
        }
    }

    public static String contentType(String key) {
        return key != null && key.toLowerCase().endsWith(".png") ? "image/png" : "image/jpeg";
    }
}
