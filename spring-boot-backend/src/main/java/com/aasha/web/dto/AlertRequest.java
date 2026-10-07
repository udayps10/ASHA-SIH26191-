package com.aasha.web.dto;

import jakarta.validation.constraints.NotBlank;

public class AlertRequest {
    @NotBlank
    private String title;
    private String message;
    @NotBlank
    private String type;
    @NotBlank
    private String severity;
    private String district;
    private String state;
    private Double latitude;
    private Double longitude;
    private Double radiusKm;
    private Boolean active = true;

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }
    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public Double getRadiusKm() { return radiusKm; }
    public void setRadiusKm(Double radiusKm) { this.radiusKm = radiusKm; }
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
}