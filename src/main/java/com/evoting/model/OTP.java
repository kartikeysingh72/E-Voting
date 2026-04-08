package com.evoting.model;

import java.time.LocalDateTime;

/**
 * OTP entity for email-based verification.
 */
public class OTP {

    private int id;
    private String email;
    private String otpCode;
    private String purpose; // REGISTRATION, LOGIN
    private boolean isUsed;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;

    public OTP() {}

    public OTP(String email, String otpCode, String purpose) {
        this.email = email;
        this.otpCode = otpCode;
        this.purpose = purpose;
        this.isUsed = false;
    }

    // --- Getters and Setters ---

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getOtpCode() { return otpCode; }
    public void setOtpCode(String otpCode) { this.otpCode = otpCode; }

    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }

    public boolean isUsed() { return isUsed; }
    public void setUsed(boolean used) { isUsed = used; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }

    /**
     * Check if OTP is expired.
     */
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }

    /**
     * Check if OTP is valid (not used and not expired).
     */
    public boolean isValid() {
        return !isUsed && !isExpired();
    }
}
