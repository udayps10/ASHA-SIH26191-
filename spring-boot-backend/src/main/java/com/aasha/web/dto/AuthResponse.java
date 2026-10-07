package com.aasha.web.dto;

public class AuthResponse {
    private String token;
    private String uid;
    private String name;
    private String email;
    private String role;
    private Boolean approved;

    public AuthResponse() {}

    public AuthResponse(String token, String uid, String name, String email, String role, Boolean approved) {
        this.token = token;
        this.uid = uid;
        this.name = name;
        this.email = email;
        this.role = role;
        this.approved = approved;
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public String getUid() { return uid; }
    public void setUid(String uid) { this.uid = uid; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public Boolean getApproved() { return approved; }
    public void setApproved(Boolean approved) { this.approved = approved; }
}
