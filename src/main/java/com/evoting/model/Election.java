package com.evoting.model;

import java.time.LocalDateTime;

/**
 * Election entity representing a voting event.
 */
public class Election {

    private int electionId;
    private String title;
    private String description;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private String status; // SCHEDULED, ACTIVE, COMPLETED, CANCELLED
    private int createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Election() {}

    public Election(String title, String description, LocalDateTime startDate,
                    LocalDateTime endDate, int createdBy) {
        this.title = title;
        this.description = description;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = "SCHEDULED";
        this.createdBy = createdBy;
    }

    // --- Getters and Setters ---

    public int getElectionId() { return electionId; }
    public void setElectionId(int electionId) { this.electionId = electionId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDateTime getStartDate() { return startDate; }
    public void setStartDate(LocalDateTime startDate) { this.startDate = startDate; }

    public LocalDateTime getEndDate() { return endDate; }
    public void setEndDate(LocalDateTime endDate) { this.endDate = endDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    /**
     * Check if the election is currently active (within date range and ACTIVE status).
     */
    public boolean isActive() {
        LocalDateTime now = LocalDateTime.now();
        return "ACTIVE".equals(status) && now.isAfter(startDate) && now.isBefore(endDate);
    }

    /**
     * Check if voting is open (either status is ACTIVE or we're within the date window).
     */
    public boolean isVotingOpen() {
        LocalDateTime now = LocalDateTime.now();
        if ("ACTIVE".equals(status)) {
            return now.isAfter(startDate) && now.isBefore(endDate);
        }
        if ("SCHEDULED".equals(status)) {
            return now.isAfter(startDate) && now.isBefore(endDate);
        }
        return false;
    }

    /**
     * Check if the election has ended.
     */
    public boolean isCompleted() {
        return "COMPLETED".equals(status) || LocalDateTime.now().isAfter(endDate);
    }
}
