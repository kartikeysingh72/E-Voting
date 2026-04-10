package com.evoting.dao;

import com.evoting.model.Candidate;
import com.evoting.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Candidate operations.
 */
public class CandidateDAO {

    /**
     * Add a new candidate.
     * @return generated candidate_id, or -1 on failure
     */
    public int add(Candidate candidate) throws SQLException {
        String sql = "INSERT INTO candidates (election_id, name, party, bio, photo_url, symbol_url) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, candidate.getElectionId());
            ps.setString(2, candidate.getName());
            ps.setString(3, candidate.getParty());
            ps.setString(4, candidate.getBio());
            ps.setString(5, candidate.getPhotoUrl());
            ps.setString(6, candidate.getSymbolUrl());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Find candidate by ID.
     */
    public Candidate findById(int candidateId) throws SQLException {
        String sql = "SELECT * FROM candidates WHERE candidate_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, candidateId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Get all candidates for a specific election.
     */
    public List<Candidate> findByElectionId(int electionId) throws SQLException {
        String sql = "SELECT * FROM candidates WHERE election_id = ? ORDER BY name ASC";
        List<Candidate> candidates = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    candidates.add(mapRow(rs));
                }
            }
        }
        return candidates;
    }

    /**
     * Get candidates with vote counts for a specific election.
     */
    public List<Candidate> findByElectionIdWithVotes(int electionId) throws SQLException {
        String sql = "SELECT c.*, COALESCE(v.vote_count, 0) AS vote_count " +
                     "FROM candidates c " +
                     "LEFT JOIN (SELECT candidate_id, COUNT(*) AS vote_count FROM votes WHERE election_id = ? GROUP BY candidate_id) v " +
                     "ON c.candidate_id = v.candidate_id " +
                     "WHERE c.election_id = ? " +
                     "ORDER BY vote_count DESC, c.name ASC";
        List<Candidate> candidates = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, electionId);
            ps.setInt(2, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Candidate c = mapRow(rs);
                    c.setVoteCount(rs.getInt("vote_count"));
                    candidates.add(c);
                }
            }
        }
        return candidates;
    }

    /**
     * Update candidate details.
     */
    public boolean update(Candidate candidate) throws SQLException {
        String sql = "UPDATE candidates SET name = ?, party = ?, bio = ?, photo_url = ?, symbol_url = ? " +
                     "WHERE candidate_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, candidate.getName());
            ps.setString(2, candidate.getParty());
            ps.setString(3, candidate.getBio());
            ps.setString(4, candidate.getPhotoUrl());
            ps.setString(5, candidate.getSymbolUrl());
            ps.setInt(6, candidate.getCandidateId());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete a candidate.
     */
    public boolean delete(int candidateId) throws SQLException {
        String sql = "DELETE FROM candidates WHERE candidate_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, candidateId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Get total candidate count.
     */
    public int getCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM candidates";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    private Candidate mapRow(ResultSet rs) throws SQLException {
        Candidate c = new Candidate();
        c.setCandidateId(rs.getInt("candidate_id"));
        c.setElectionId(rs.getInt("election_id"));
        c.setName(rs.getString("name"));
        c.setParty(rs.getString("party"));
        c.setBio(rs.getString("bio"));
        c.setPhotoUrl(rs.getString("photo_url"));
        c.setSymbolUrl(rs.getString("symbol_url"));
        c.setCreatedAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null);
        return c;
    }
}
