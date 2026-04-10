package com.evoting.dao;

import com.evoting.model.OTP;
import com.evoting.util.DBUtil;

import java.sql.*;

/**
 * Data Access Object for OTP store operations.
 */
public class OTPDAO {

    /**
     * Store a new OTP.
     */
    public boolean store(OTP otp) throws SQLException {
        String sql = "INSERT INTO otp_store (email, otp_code, purpose) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, otp.getEmail());
            ps.setString(2, otp.getOtpCode());
            ps.setString(3, otp.getPurpose());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Verify OTP: find the most recent unused OTP for the given email and purpose.
     */
    public OTP findLatestValid(String email, String purpose) throws SQLException {
        String sql = "SELECT * FROM otp_store WHERE email = ? AND purpose = ? AND is_used = FALSE " +
                     "ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, purpose);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    OTP otp = new OTP();
                    otp.setId(rs.getInt("id"));
                    otp.setEmail(rs.getString("email"));
                    otp.setOtpCode(rs.getString("otp_code"));
                    otp.setPurpose(rs.getString("purpose"));
                    otp.setUsed(rs.getBoolean("is_used"));
                    otp.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    otp.setExpiresAt(rs.getTimestamp("expires_at").toLocalDateTime());
                    return otp;
                }
            }
        }
        return null;
    }

    /**
     * Mark OTP as used.
     */
    public boolean markUsed(int otpId) throws SQLException {
        String sql = "UPDATE otp_store SET is_used = TRUE WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, otpId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Invalidate all OTPs for an email (when a new one is sent).
     */
    public boolean invalidateAll(String email, String purpose) throws SQLException {
        String sql = "UPDATE otp_store SET is_used = TRUE WHERE email = ? AND purpose = ? AND is_used = FALSE";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, purpose);
            ps.executeUpdate(); // Don't care about count
        }
        return true;
    }
}
