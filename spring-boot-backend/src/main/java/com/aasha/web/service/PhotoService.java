package com.aasha.web.service;

import com.aasha.web.dto.ImageStorageReference;
import com.aasha.web.entity.NormalRecord;
import com.aasha.web.entity.CriticalRecord;
import com.aasha.web.repository.CriticalRecordRepository;
import com.aasha.web.repository.NormalRecordRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;

@Service
public class PhotoService {

    private static final Logger log = LoggerFactory.getLogger(PhotoService.class);

    private final NormalRecordRepository normalRepo;
    private final CriticalRecordRepository criticalRepo;
    private final MinioStorageService minio;
    private final Path uploadDir;

    private final Map<String, byte[]> temporaryStore = new ConcurrentHashMap<>();

    public PhotoService(NormalRecordRepository normalRepo, CriticalRecordRepository criticalRepo,
                        MinioStorageService minio) throws IOException {
        this.normalRepo = normalRepo;
        this.criticalRepo = criticalRepo;
        this.minio = minio;
        String userDir = System.getProperty("user.dir");
        this.uploadDir = Paths.get(userDir, "uploads", "photos");
        Files.createDirectories(uploadDir);
        log.info("Upload directory: {}", uploadDir.toAbsolutePath());
    }

    public ImageStorageReference uploadNormalPhoto(String recordId, MultipartFile file) throws Exception {
        String fileName = UUID.randomUUID() + getExtension(file);
        Path filePath = uploadDir.resolve(recordId).resolve(fileName);
        Files.createDirectories(filePath.getParent());
        Files.write(filePath, file.getBytes());
        minio.put(recordId + "/" + fileName, file.getBytes(),
                file.getContentType() != null ? file.getContentType() : "image/jpeg");

        String photoUrl = "/uploads/" + recordId + "/" + fileName;

        normalRepo.findById(recordId).ifPresent(record -> {
            record.setPhotoUrl(photoUrl);
            normalRepo.save(record);
        });

        String assetId = UUID.randomUUID().toString();
        temporaryStore.put(assetId, file.getBytes());

        return new ImageStorageReference("local", recordId, assetId, "image", "stored", "public",
                file.getContentType() != null ? file.getContentType() : "image/jpeg", (int) file.getSize());
    }

    public ImageStorageReference uploadCriticalPhoto(String recordId, MultipartFile file) throws Exception {
        String fileName = "critical/" + recordId + "/" + UUID.randomUUID() + getExtension(file);
        Path filePath = uploadDir.resolve(fileName);
        Files.createDirectories(filePath.getParent());
        Files.write(filePath, file.getBytes());
        minio.put(fileName, file.getBytes(),
                file.getContentType() != null ? file.getContentType() : "image/jpeg");

        String photoUrl = "/api/v1/images/file/" + fileName;

        criticalRepo.findById(recordId).ifPresent(record -> {
            record.setPhotoUrl(photoUrl);
            criticalRepo.save(record);
        });

        String assetId = UUID.randomUUID().toString();
        temporaryStore.put(assetId, file.getBytes());

        return new ImageStorageReference("local", recordId, assetId, "image", "stored", "public",
                file.getContentType() != null ? file.getContentType() : "image/jpeg", (int) file.getSize());
    }

    public ImageStorageReference uploadCriticalClothing(String recordId, MultipartFile file) throws Exception {
        String fileName = "critical-clothing/" + recordId + "/" + UUID.randomUUID() + getExtension(file);
        Path filePath = uploadDir.resolve(fileName);
        Files.createDirectories(filePath.getParent());
        Files.write(filePath, file.getBytes());
        minio.put(fileName, file.getBytes(),
                file.getContentType() != null ? file.getContentType() : "image/jpeg");

        String photoUrl = "/api/v1/images/file/" + fileName;

        criticalRepo.findById(recordId).ifPresent(record -> {
            record.setClothingPhotoUrl(photoUrl);
            criticalRepo.save(record);
        });

        String assetId = UUID.randomUUID().toString();
        temporaryStore.put(assetId, file.getBytes());

        return new ImageStorageReference("local", recordId, assetId, "image", "stored", "public",
                file.getContentType() != null ? file.getContentType() : "image/jpeg", (int) file.getSize());
    }

    public ImageStorageReference uploadMatchInput(String requestId, MultipartFile file) throws Exception {
        String fileName = "match-input/" + requestId + "/" + UUID.randomUUID() + getExtension(file);
        Path filePath = uploadDir.resolve(fileName);
        Files.createDirectories(filePath.getParent());
        Files.write(filePath, file.getBytes());
        minio.put(fileName, file.getBytes(),
                file.getContentType() != null ? file.getContentType() : "image/jpeg");

        String assetId = UUID.randomUUID().toString();
        temporaryStore.put(assetId, file.getBytes());

        return new ImageStorageReference("local", requestId, assetId, "image", "stored", "private",
                file.getContentType() != null ? file.getContentType() : "image/jpeg", (int) file.getSize());
    }

    public byte[] getImageBytes(String path) throws IOException {
        Path filePath = uploadDir.resolve(path);
        log.info("Looking for file: {} (absolute: {})", filePath, filePath.toAbsolutePath());
        if (Files.exists(filePath)) {
            log.info("File found, reading bytes");
            return Files.readAllBytes(filePath);
        }
        log.warn("File not found: {}", filePath.toAbsolutePath());
        byte[] fromMinio = minio.get(path);
        if (fromMinio != null) {
            return fromMinio;
        }
        return temporaryStore.get(path);
    }

    /** MinIO fallback read; null when missing or MinIO unavailable. */
    public byte[] getMinioBytes(String objectKey) {
        return minio.get(objectKey);
    }

    public String getImageUrl(String storageId) {
        NormalRecord normal = normalRepo.findById(storageId).orElse(null);
        if (normal != null && normal.getPhotoUrl() != null) {
            return normal.getPhotoUrl();
        }
        CriticalRecord critical = criticalRepo.findById(storageId).orElse(null);
        if (critical != null && critical.getPhotoUrl() != null) {
            return critical.getPhotoUrl();
        }
        return null;
    }

    public void deleteTemporary(String assetId) {
        temporaryStore.remove(assetId);
    }

    private String getExtension(MultipartFile file) {
        String original = file.getOriginalFilename();
        if (original != null && original.contains(".")) {
            return original.substring(original.lastIndexOf("."));
        }
        return ".jpg";
    }
}
