package com.evoting.dao;

import com.evoting.model.Election;
import com.evoting.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Election operations.
 */
public class ElectionDAO {

    /**
     * Create a new election.
     * @return generated election_id, or -1 on failure
     */
    public int create(Election election) throws SQLException {
        String sql = "INSERT INTO elections (title, description, start_date, end_date, status, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, election.getTitle());
            ps.setString(2, election.getDescription());
            ps.setTimestamp(3, Timestamp.valueOf(election.getStartDate()));
            ps.setTimestamp(4, Timestamp.valueOf(election.getEndDate()));
            ps.setString(5, election.getStatus());
            ps.setInt(6, election.getCreatedBy());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
    }

    /**
     * Find election by ID.
     */
    public Election findById(int electionId) throws SQLException {
        String sql = "SELECT * FROM elections WHERE election_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    /**
     * Get all elections.
     */
    public List<Election> findAll() throws SQLException {
        String sql = "SELECT * FROM elections ORDER BY created_at DESC";
        List<Election> elections = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                elections.add(mapRow(rs));
            }
        }
        return elections;
    }

    /**
     * Get elections by status.
     */
    public List<Election> findByStatus(String status) throws SQLException {
        String sql = "SELECT * FROM elections WHERE status = ? ORDER BY start_date DESC";
        List<Election> elections = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    elections.add(mapRow(rs));
                }
            }
        }
        return elections;
    }

    /**
     * Get active elections (for voter ballot view).
     */
    public List<Election> findActiveElections() throws SQLException {
        String sql = "SELECT * FROM elections WHERE status IN ('ACTIVE', 'SCHEDULED') " +
                     "AND start_date <= NOW() AND end_date >= NOW() ORDER BY start_date ASC";
        List<Election> elections = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                elections.add(mapRow(rs));
            }
        }
        return elections;
    }

    /**
     * Get completed elections (for results view).
     */
    public List<Election> findCompletedElections() throws SQLException {
        String sql = "SELECT * FROM elections WHERE status = 'COMPLETED' OR end_date < NOW() ORDER BY end_date DESC";
        List<Election> elections = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                elections.add(mapRow(rs));
            }
        }
        return elections;
    }

    /**
     * Update election status.
     */
    public boolean updateStatus(int electionId, String status) throws SQLException {
        String sql = "UPDATE elections SET status = ? WHERE election_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, electionId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Update election details.
     */
    public boolean update(Election election) throws SQLException {
        String sql = "UPDATE elections SET title = ?, description = ?, start_date = ?, end_date = ?, status = ? " +
                     "WHERE election_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, election.getTitle());
            ps.setString(2, election.getDescription());
            ps.setTimestamp(3, Timestamp.valueOf(election.getStartDate()));
            ps.setTimestamp(4, Timestamp.valueOf(election.getEndDate()));
            ps.setString(5, election.getStatus());
            ps.setInt(6, election.getElectionId());
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete an election.
     */
    public boolean delete(int electionId) throws SQLException {
        String sql = "DELETE FROM elections WHERE election_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, electionId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Get total election count.
     */
    public int getCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM elections";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    /**
     * Get active election count.
     */
    public int getActiveCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM elections WHERE status IN ('ACTIVE', 'SCHEDULED') " +
                     "AND start_date <= NOW() AND end_date >= NOW()";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    private Election mapRow(ResultSet rs) throws SQLException {
        Election e = new Election();
        e.setElectionId(rs.getInt("election_id"));
        e.setTitle(rs.getString("title"));
        e.setDescription(rs.getString("description"));
        e.setStartDate(rs.getTimestamp("start_date").toLocalDateTime());
        e.setEndDate(rs.getTimestamp("end_date").toLocalDateTime());
        e.setStatus(rs.getString("status"));
        e.setCreatedBy(rs.getInt("created_by"));
        e.setCreatedAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null);
        e.setUpdatedAt(rs.getTimestamp("updated_at") != null ? rs.getTimestamp("updated_at").toLocalDateTime() : null);
        return e;
    }
}
