package com.aasha.web.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "saved_searches")
public class SavedSearch {

    @Id
    @Column(length = 36)
    private String id;

    @Column(name = "user_phone", nullable = false, length = 20)
    private String userPhone;

    @Column(name = "search_name", nullable = false)
    private String searchName;

    @Column(name = "search_age")
    private Integer searchAge;

    @Column(name = "search_location")
    private String searchLocation;

    @Column(name = "search_additional_details", columnDefinition = "TEXT")
    private String searchAdditionalDetails;

    @Column(name = "record_type", length = 20)
    private String recordType = "BOTH";

    @Column(nullable = false)
    private Boolean active = true;

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
    public String getUserPhone() { return userPhone; }
    public void setUserPhone(String userPhone) { this.userPhone = userPhone; }
    public String getSearchName() { return searchName; }
    public void setSearchName(String searchName) { this.searchName = searchName; }
    public Integer getSearchAge() { return searchAge; }
    public void setSearchAge(Integer searchAge) { this.searchAge = searchAge; }
    public String getSearchLocation() { return searchLocation; }
    public void setSearchLocation(String searchLocation) { this.searchLocation = searchLocation; }
    public String getSearchAdditionalDetails() { return searchAdditionalDetails; }
    public void setSearchAdditionalDetails(String searchAdditionalDetails) { this.searchAdditionalDetails = searchAdditionalDetails; }
    public String getRecordType() { return recordType; }
    public void setRecordType(String recordType) { this.recordType = recordType; }
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
