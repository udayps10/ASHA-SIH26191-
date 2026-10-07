package com.aasha.web.dto;

public class SearchRequest {
    private String name = "";
    private Integer age = 0;
    private String lastKnownLocation = "";
    private String additionalDetails = "";
    private String photo;
    private String phone = "";

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    public String getLastKnownLocation() { return lastKnownLocation; }
    public void setLastKnownLocation(String lastKnownLocation) { this.lastKnownLocation = lastKnownLocation; }
    public String getAdditionalDetails() { return additionalDetails; }
    public void setAdditionalDetails(String additionalDetails) { this.additionalDetails = additionalDetails; }
    public String getPhoto() { return photo; }
    public void setPhoto(String photo) { this.photo = photo; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public boolean hasName() {
        return name != null && !name.trim().isEmpty();
    }

    public String getTrimmedName() {
        return name != null ? name.trim() : "";
    }
}
