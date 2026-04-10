package com.evoting.dao;

import com.evoting.model.Vote;
import com.evoting.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for Vote operations.
 */
public class VoteDAO {

    /**
     * Cast a vote.
     * Uses unique constraint (voter_id, election_id) to prevent double voting.
     * @return true if vote was successfully cast
     */
    public boolean castVote(Vote vote) throws SQLException {
        String sql = "INSERT INTO votes (voter_id, election_id, candidate_id, receipt_token) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vote.getVoterId());
            ps.setInt(2, vote.getElectionId());
            ps.setInt(3, vote.getCandidateId());
            ps.setString(4, vote.getReceiptToken());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Check if a voter has already voted in an election.
     */
    public boolean hasVoted(int voterId, int electionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM votes WHERE voter_id = ? AND election_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voterId);
            ps.setInt(2, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    /**
     * Get total vote count for an election.
     */
    public int getVoteCountByElection(int electionId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM votes WHERE election_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /**
     * Get vote count per candidate for an election.
     * @return Map of candidate_id -> vote_count
     */
    public Map<Integer, Integer> getVoteCountsByCandidate(int electionId) throws SQLException {
        String sql = "SELECT candidate_id, COUNT(*) AS cnt FROM votes WHERE election_id = ? GROUP BY candidate_id";
        Map<Integer, Integer> counts = new HashMap<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    counts.put(rs.getInt("candidate_id"), rs.getInt("cnt"));
                }
            }
        }
        return counts;
    }

    /**
     * Verify a receipt token (audit trail).
     */
    public Vote findByReceiptToken(String receiptToken) throws SQLException {
        String sql = "SELECT v.*, c.name AS candidate_name, e.title AS election_title " +
                     "FROM votes v " +
                     "JOIN candidates c ON v.candidate_id = c.candidate_id " +
                     "JOIN elections e ON v.election_id = e.election_id " +
                     "WHERE v.receipt_token = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, receiptToken);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Vote v = new Vote();
                    v.setVoteId(rs.getInt("vote_id"));
                    v.setVoterId(rs.getInt("voter_id"));
                    v.setElectionId(rs.getInt("election_id"));
                    v.setCandidateId(rs.getInt("candidate_id"));
                    v.setReceiptToken(rs.getString("receipt_token"));
                    v.setTimestamp(rs.getTimestamp("timestamp").toLocalDateTime());
                    v.setCandidateName(rs.getString("candidate_name"));
                    v.setElectionTitle(rs.getString("election_title"));
                    return v;
                }
            }
        }
        return null;
    }

    /**
     * Get all votes for an election (admin).
     */
    public List<Vote> findByElectionId(int electionId) throws SQLException {
        String sql = "SELECT v.*, c.name AS candidate_name, e.title AS election_title " +
                     "FROM votes v " +
                     "JOIN candidates c ON v.candidate_id = c.candidate_id " +
                     "JOIN elections e ON v.election_id = e.election_id " +
                     "WHERE v.election_id = ? ORDER BY v.timestamp DESC";
        List<Vote> votes = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Vote v = new Vote();
                    v.setVoteId(rs.getInt("vote_id"));
                    v.setVoterId(rs.getInt("voter_id"));
                    v.setElectionId(rs.getInt("election_id"));
                    v.setCandidateId(rs.getInt("candidate_id"));
                    v.setReceiptToken(rs.getString("receipt_token"));
                    v.setTimestamp(rs.getTimestamp("timestamp").toLocalDateTime());
                    v.setCandidateName(rs.getString("candidate_name"));
                    v.setElectionTitle(rs.getString("election_title"));
                    votes.add(v);
                }
            }
        }
        return votes;
    }

    /**
     * Get total votes cast across all elections.
     */
    public int getTotalVoteCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM votes";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }
}
