package com.evoting.dao;

import com.evoting.model.FaceVerification;
import com.evoting.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for FaceVerification audit log operations.
 */
public class FaceVerificationDAO {

    /**
     * Save a face verification record.
     * @return generated verification_id, or -1 on failure
     */
    public int save(FaceVerification verification) throws SQLException {
        String sql = "INSERT INTO face_verifications (voter_id, action, match_score, threshold_used, " +
                     "passed, bypass_token, ip_address, user_agent) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, verification.getVoterId());
            ps.setString(2, verification.getAction());
            if (verification.getMatchScore() != null) {
                ps.setBigDecimal(3, verification.getMatchScore());
            } else {
                ps.setNull(3, Types.DECIMAL);
            }
            ps.setBigDecimal(4, verification.getThresholdUsed());
            ps.setBoolean(5, verification.isPassed());
            ps.setString(6, verification.getBypassToken());
            ps.setString(7, verification.getIpAddress());
            ps.setString(8, verification.getUserAgent());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Find verification records for a voter (most recent first).
     */
    public List<FaceVerification> findByVoterId(int voterId, int limit) throws SQLException {
        String sql = "SELECT * FROM face_verifications WHERE voter_id = ? ORDER BY created_at DESC LIMIT ?";
        List<FaceVerification> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voterId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }

    /**
     * Count recent failed verification attempts for a voter.
     */
    public int countRecentFailures(int voterId, int hours) throws SQLException {
        String sql = "SELECT COUNT(*) FROM face_verifications " +
                     "WHERE voter_id = ? AND passed = FALSE AND action = 'LOGIN_VOTE' " +
                     "AND created_at >= NOW() - INTERVAL ? HOUR";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voterId);
            ps.setInt(2, hours);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    /**
     * Find a bypass token record that has not been used yet.
     */
    public FaceVerification findUnusedBypassToken(String token) throws SQLException {
        String sql = "SELECT * FROM face_verifications WHERE bypass_token = ? AND bypass_used = FALSE " +
                     "ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Mark a bypass token as used.
     */
    public boolean markBypassUsed(int verificationId) throws SQLException {
        String sql = "UPDATE face_verifications SET bypass_used = TRUE WHERE verification_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, verificationId);
            return ps.executeUpdate() > 0;
        }
    }

    // --- Row mapper ---
    private FaceVerification mapRow(ResultSet rs) throws SQLException {
        FaceVerification v = new FaceVerification();
        v.setVerificationId(rs.getInt("verification_id"));
        v.setVoterId(rs.getInt("voter_id"));
        v.setAction(rs.getString("action"));
        v.setMatchScore(rs.getBigDecimal("match_score"));
        v.setThresholdUsed(rs.getBigDecimal("threshold_used"));
        v.setPassed(rs.getBoolean("passed"));
        v.setBypassToken(rs.getString("bypass_token"));
        v.setBypassUsed(rs.getBoolean("bypass_used"));
        v.setIpAddress(rs.getString("ip_address"));
        v.setUserAgent(rs.getString("user_agent"));
        v.setCreatedAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null);
        return v;
    }
}
