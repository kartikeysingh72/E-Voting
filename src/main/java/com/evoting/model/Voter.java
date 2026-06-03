package com.evoting.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Voter entity representing a registered voter in the system.
 */
public class Voter {

    private int voterId;
    private String name;
    private String email;
    private String phone;
    private LocalDate dob;
    private String pidNumber;
    private String passwordHash;
    private boolean isVerified;
    private boolean isApproved;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Voter() {}

    public Voter(String name, String email, String phone, LocalDate dob,
                 String pidNumber, String passwordHash) {
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.dob = dob;
        this.pidNumber = pidNumber;
        this.passwordHash = passwordHash;
        this.isVerified = false;
        this.isApproved = false;
        this.status = "PENDING";
    }

    // --- Getters and Setters ---

    public int getVoterId() { return voterId; }
    public void setVoterId(int voterId) { this.voterId = voterId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public LocalDate getDob() { return dob; }
    public void setDob(LocalDate dob) { this.dob = dob; }

    public String getPidNumber() { return pidNumber; }
    public void setPidNumber(String pidNumber) { this.pidNumber = pidNumber; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public boolean isVerified() { return isVerified; }
    public void setVerified(boolean verified) { isVerified = verified; }

    public boolean isApproved() { return isApproved; }
    public void setApproved(boolean approved) { isApproved = approved; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    /**
     * Check if the voter is eligible to vote (verified + approved + 18+).
     */
    public boolean isEligible() {
        return isVerified && isApproved && "APPROVED".equals(status);
    }

    /**
     * Calculate age from date of birth.
     */
    public int getAge() {
        return java.time.Period.between(dob, LocalDate.now()).getYears();
    }
}
