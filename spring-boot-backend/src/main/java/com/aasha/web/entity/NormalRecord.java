package com.aasha.web.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "normal_records")
public class NormalRecord {

    @Id
    @Column(length = 36)
    private String id;

    @Column(nullable = false)
    private String name;

    private Integer age;

    @Column(name = "photo_url", columnDefinition = "TEXT")
    private String photoUrl;

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

    @Column(length = 50)
    private String status = "AT_CAMP";

    @Column(name = "additional_details", columnDefinition = "TEXT")
    private String additionalDetails;

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
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdditionalDetails() { return additionalDetails; }
    public void setAdditionalDetails(String additionalDetails) { this.additionalDetails = additionalDetails; }
    public LocalDateTime getFoundAt() { return foundAt; }
    public void setFoundAt(LocalDateTime foundAt) { this.foundAt = foundAt; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
