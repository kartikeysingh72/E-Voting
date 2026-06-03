package com.evoting.dao;

import com.evoting.model.FaceTemplate;
import com.evoting.util.DBUtil;

import java.sql.*;

/**
 * Data Access Object for FaceTemplate operations.
 */
public class FaceTemplateDAO {

    /**
     * Save a new face template.
     * @return generated template_id, or -1 on failure
     */
    public int save(FaceTemplate template) throws SQLException {
        String sql = "INSERT INTO face_templates (voter_id, embedding_json, model_version) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, template.getVoterId());
            ps.setString(2, template.getEmbeddingJson());
            ps.setString(3, template.getModelVersion());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Find the active face template for a voter.
     */
    public FaceTemplate findActiveByVoterId(int voterId) throws SQLException {
        String sql = "SELECT * FROM face_templates WHERE voter_id = ? AND is_active = TRUE " +
                     "ORDER BY captured_at DESC LIMIT 1";
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
     * Check if a voter has any active face template.
     */
    public boolean voterHasTemplate(int voterId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM face_templates WHERE voter_id = ? AND is_active = TRUE";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voterId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }

    /**
     * Deactivate all face templates for a voter (for re-registration).
     */
    public boolean deactivateAll(int voterId) throws SQLException {
        String sql = "UPDATE face_templates SET is_active = FALSE WHERE voter_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voterId);
            return ps.executeUpdate() >= 0;
        }
    }

    // --- Row mapper ---
    private FaceTemplate mapRow(ResultSet rs) throws SQLException {
        FaceTemplate t = new FaceTemplate();
        t.setTemplateId(rs.getInt("template_id"));
        t.setVoterId(rs.getInt("voter_id"));
        t.setEmbeddingJson(rs.getString("embedding_json"));
        t.setModelVersion(rs.getString("model_version"));
        t.setCapturedAt(rs.getTimestamp("captured_at") != null ? rs.getTimestamp("captured_at").toLocalDateTime() : null);
        t.setActive(rs.getBoolean("is_active"));
        return t;
    }
}
