package com.aasha.web.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "critical_records")
public class CriticalRecord {

    @Id
    @Column(length = 36)
    private String id;

    @Column(nullable = false)
    private String name;

    private Integer age;

    @Column(name = "photo_url", columnDefinition = "TEXT")
    private String photoUrl;

    @Column(name = "clothing_photo_url", columnDefinition = "TEXT")
    private String clothingPhotoUrl;

    @Column(name = "last_known_clothing", length = 500)
    private String lastKnownClothing;

    @Column(name = "camp_id", length = 36)
    private String campId;

    @Column(name = "camp_name")
    private String campName;

    @Column(name = "officer_uid")
    private String officerUid;

    @Column(name = "officer_name")
    private String officerName;

    @Column(name = "officer_contact")
    private String officerContact;

    @Column(name = "found_location", length = 500)
    private String foundLocation;

    @Column(name = "found_latitude")
    private Double foundLatitude;

    @Column(name = "found_longitude")
    private Double foundLongitude;

    @Column(name = "additional_details", columnDefinition = "TEXT")
    private String additionalDetails;

    @Column(length = 50)
    private String status = "UNIDENTIFIED";

    @Column(name = "found_at")
    private LocalDateTime foundAt;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public String getClothingPhotoUrl() { return clothingPhotoUrl; }
    public void setClothingPhotoUrl(String clothingPhotoUrl) { this.clothingPhotoUrl = clothingPhotoUrl; }
    public String getLastKnownClothing() { return lastKnownClothing; }
    public void setLastKnownClothing(String lastKnownClothing) { this.lastKnownClothing = lastKnownClothing; }
    public String getCampId() { return campId; }
    public void setCampId(String campId) { this.campId = campId; }
    public String getCampName() { return campName; }
    public void setCampName(String campName) { this.campName = campName; }
    public String getOfficerUid() { return officerUid; }
    public void setOfficerUid(String officerUid) { this.officerUid = officerUid; }
    public String getOfficerName() { return officerName; }
    public void setOfficerName(String officerName) { this.officerName = officerName; }
    public String getOfficerContact() { return officerContact; }
    public void setOfficerContact(String officerContact) { this.officerContact = officerContact; }
    public String getFoundLocation() { return foundLocation; }
    public void setFoundLocation(String foundLocation) { this.foundLocation = foundLocation; }
    public Double getFoundLatitude() { return foundLatitude; }
    public void setFoundLatitude(Double foundLatitude) { this.foundLatitude = foundLatitude; }
    public Double getFoundLongitude() { return foundLongitude; }
    public void setFoundLongitude(Double foundLongitude) { this.foundLongitude = foundLongitude; }
    public String getAdditionalDetails() { return additionalDetails; }
    public void setAdditionalDetails(String additionalDetails) { this.additionalDetails = additionalDetails; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getFoundAt() { return foundAt; }
    public void setFoundAt(LocalDateTime foundAt) { this.foundAt = foundAt; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
