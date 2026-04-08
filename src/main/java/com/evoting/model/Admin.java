package com.evoting.model;

import java.time.LocalDateTime;

/**
 * Admin entity representing a system administrator.
 */
public class Admin {

    private int adminId;
    private String username;
    private String passwordHash;
    private String fullName;
    private String role;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Admin() {}

    public Admin(String username, String passwordHash, String fullName, String role) {
        this.username = username;
        this.passwordHash = passwordHash;
        this.fullName = fullName;
        this.role = role;
    }

    // --- Getters and Setters ---

    public int getAdminId() { return adminId; }
    public void setAdminId(int adminId) { this.adminId = adminId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public boolean isSuperAdmin() {
        return "SUPER_ADMIN".equals(role);
    }
}
