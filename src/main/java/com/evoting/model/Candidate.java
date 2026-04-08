package com.evoting.model;

import java.time.LocalDateTime;

/**
 * Candidate entity representing a candidate in an election.
 */
public class Candidate {

    private int candidateId;
    private int electionId;
    private String name;
    private String party;
    private String bio;
    private String photoUrl;
    private String symbolUrl;
    private LocalDateTime createdAt;

    // Transient field - populated from vote count queries
    private int voteCount;

    public Candidate() {}

    public Candidate(int electionId, String name, String party, String bio) {
        this.electionId = electionId;
        this.name = name;
        this.party = party;
        this.bio = bio;
    }

    // --- Getters and Setters ---

    public int getCandidateId() { return candidateId; }
    public void setCandidateId(int candidateId) { this.candidateId = candidateId; }

    public int getElectionId() { return electionId; }
    public void setElectionId(int electionId) { this.electionId = electionId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getParty() { return party; }
    public void setParty(String party) { this.party = party; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }

    public String getSymbolUrl() { return symbolUrl; }
    public void setSymbolUrl(String symbolUrl) { this.symbolUrl = symbolUrl; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public int getVoteCount() { return voteCount; }
    public void setVoteCount(int voteCount) { this.voteCount = voteCount; }
}
