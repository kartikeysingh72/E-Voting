package com.evoting.model;

import java.time.LocalDateTime;

/**
 * Vote entity representing a cast ballot.
 */
public class Vote {

    private int voteId;
    private int voterId;
    private int electionId;
    private int candidateId;
    private String receiptToken;
    private LocalDateTime timestamp;

    // Transient fields for display
    private String candidateName;
    private String electionTitle;

    public Vote() {}

    public Vote(int voterId, int electionId, int candidateId, String receiptToken) {
        this.voterId = voterId;
        this.electionId = electionId;
        this.candidateId = candidateId;
        this.receiptToken = receiptToken;
    }

    // --- Getters and Setters ---

    public int getVoteId() { return voteId; }
    public void setVoteId(int voteId) { this.voteId = voteId; }

    public int getVoterId() { return voterId; }
    public void setVoterId(int voterId) { this.voterId = voterId; }

    public int getElectionId() { return electionId; }
    public void setElectionId(int electionId) { this.electionId = electionId; }

    public int getCandidateId() { return candidateId; }
    public void setCandidateId(int candidateId) { this.candidateId = candidateId; }

    public String getReceiptToken() { return receiptToken; }
    public void setReceiptToken(String receiptToken) { this.receiptToken = receiptToken; }

    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }

    public String getCandidateName() { return candidateName; }
    public void setCandidateName(String candidateName) { this.candidateName = candidateName; }

    public String getElectionTitle() { return electionTitle; }
    public void setElectionTitle(String electionTitle) { this.electionTitle = electionTitle; }
}
