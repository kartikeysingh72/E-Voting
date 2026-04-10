package com.evoting.dao;

import com.evoting.model.Voter;
import com.evoting.util.DBUtil;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Voter operations.
 * All queries use PreparedStatement to prevent SQL injection.
 */
public class VoterDAO {

    /**
     * Register a new voter.
     * @return generated voter_id, or -1 on failure
     */
    public int register(Voter voter) throws SQLException {
        String sql = "INSERT INTO voters (name, email, phone, dob, voter_id_number, password_hash) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, voter.getName());
            ps.setString(2, voter.getEmail());
            ps.setString(3, voter.getPhone());
            ps.setDate(4, Date.valueOf(voter.getDob()));
            ps.setString(5, voter.getVoterIdNumber());
            ps.setString(6, voter.getPasswordHash());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Find voter by email.
     */
    public Voter findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM voters WHERE email = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Find voter by voter_id_number.
     */
    public Voter findByVoterIdNumber(String voterIdNumber) throws SQLException {
        String sql = "SELECT * FROM voters WHERE voter_id_number = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, voterIdNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Find voter by primary key.
     */
    public Voter findById(int voterId) throws SQLException {
        String sql = "SELECT * FROM voters WHERE voter_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voterId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Mark voter email as verified.
     */
    public boolean verifyEmail(String email) throws SQLException {
        String sql = "UPDATE voters SET is_verified = TRUE WHERE email = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Approve or reject a voter (admin action).
     */
    public boolean updateApprovalStatus(int voterId, boolean approved) throws SQLException {
        String sql = "UPDATE voters SET is_approved = ?, status = ? WHERE voter_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, approved);
            ps.setString(2, approved ? "APPROVED" : "REJECTED");
            ps.setInt(3, voterId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Get all voters (admin view).
     */
    public List<Voter> findAll() throws SQLException {
        String sql = "SELECT * FROM voters ORDER BY created_at DESC";
        List<Voter> voters = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                voters.add(mapRow(rs));
            }
        }
        return voters;
    }

    /**
     * Get all voters with a specific status.
     */
    public List<Voter> findByStatus(String status) throws SQLException {
        String sql = "SELECT * FROM voters WHERE status = ? ORDER BY created_at DESC";
        List<Voter> voters = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    voters.add(mapRow(rs));
                }
            }
        }
        return voters;
    }

    /**
     * Get total voter count.
     */
    public int getCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM voters";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    /**
     * Get count of approved voters.
     */
    public int getApprovedCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM voters WHERE is_approved = TRUE";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    /**
     * Check if voter has already voted in a specific election.
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

    // --- Row mapper ---
    private Voter mapRow(ResultSet rs) throws SQLException {
        Voter v = new Voter();
        v.setVoterId(rs.getInt("voter_id"));
        v.setName(rs.getString("name"));
        v.setEmail(rs.getString("email"));
        v.setPhone(rs.getString("phone"));
        v.setDob(rs.getDate("dob").toLocalDate());
        v.setVoterIdNumber(rs.getString("voter_id_number"));
        v.setPasswordHash(rs.getString("password_hash"));
        v.setVerified(rs.getBoolean("is_verified"));
        v.setApproved(rs.getBoolean("is_approved"));
        v.setStatus(rs.getString("status"));
        v.setCreatedAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null);
        v.setUpdatedAt(rs.getTimestamp("updated_at") != null ? rs.getTimestamp("updated_at").toLocalDateTime() : null);
        return v;
    }
}
