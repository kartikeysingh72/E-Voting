package com.evoting.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Face verification audit log entity.
 * Records every face match attempt (registration or voting) for auditing.
 */
public class FaceVerification {

    private int verificationId;
    private int voterId;
    private String action;
    private BigDecimal matchScore;
    private BigDecimal thresholdUsed;
    private boolean passed;
    private String bypassToken;
    private boolean bypassUsed;
    private String ipAddress;
    private String userAgent;
    private LocalDateTime createdAt;

    public FaceVerification() {}

    public FaceVerification(int voterId, String action, BigDecimal matchScore,
                            BigDecimal thresholdUsed, boolean passed) {
        this.voterId = voterId;
        this.action = action;
        this.matchScore = matchScore;
        this.thresholdUsed = thresholdUsed;
        this.passed = passed;
        this.bypassUsed = false;
    }

    public int getVerificationId() { return verificationId; }
    public void setVerificationId(int verificationId) { this.verificationId = verificationId; }

    public int getVoterId() { return voterId; }
    public void setVoterId(int voterId) { this.voterId = voterId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public BigDecimal getMatchScore() { return matchScore; }
    public void setMatchScore(BigDecimal matchScore) { this.matchScore = matchScore; }

    public BigDecimal getThresholdUsed() { return thresholdUsed; }
    public void setThresholdUsed(BigDecimal thresholdUsed) { this.thresholdUsed = thresholdUsed; }

    public boolean isPassed() { return passed; }
    public void setPassed(boolean passed) { this.passed = passed; }

    public String getBypassToken() { return bypassToken; }
    public void setBypassToken(String bypassToken) { this.bypassToken = bypassToken; }

    public boolean isBypassUsed() { return bypassUsed; }
    public void setBypassUsed(boolean bypassUsed) { this.bypassUsed = bypassUsed; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
