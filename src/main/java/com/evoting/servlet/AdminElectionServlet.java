package com.evoting.servlet;

import com.evoting.dao.ElectionDAO;
import com.evoting.model.Admin;
import com.evoting.model.Election;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Admin servlet for creating and managing elections.
 * GET: List all elections / show edit form.
 * POST: Create, update, or change election status.
 */
public class AdminElectionServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private static final DateTimeFormatter DTF = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            String action = req.getParameter("action");

            if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Election election = electionDAO.findById(id);
                req.setAttribute("election", election);
            }

            List<Election> elections = electionDAO.findAll();
            req.setAttribute("elections", elections);
            req.getRequestDispatcher("/WEB-INF/jsp/admin/elections.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load elections: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/admin/elections.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Admin admin = (Admin) session.getAttribute("admin");
        String action = req.getParameter("action");

        try {
            if ("create".equals(action)) {
                String title = req.getParameter("title");
                String description = req.getParameter("description");
                String startDateStr = req.getParameter("startDate");
                String endDateStr = req.getParameter("endDate");

                if (title == null || title.trim().isEmpty()) {
                    req.setAttribute("error", "Election title is required.");
                    doGet(req, resp);
                    return;
                }

                LocalDateTime startDate = LocalDateTime.parse(startDateStr, DTF);
                LocalDateTime endDate = LocalDateTime.parse(endDateStr, DTF);

                if (!endDate.isAfter(startDate)) {
                    req.setAttribute("error", "End date must be after start date.");
                    doGet(req, resp);
                    return;
                }

                Election election = new Election(title.trim(), description, startDate, endDate, admin.getAdminId());
                int id = electionDAO.create(election);

                if (id > 0) {
                    req.setAttribute("success", "Election created successfully!");
                } else {
                    req.setAttribute("error", "Failed to create election.");
                }

            } else if ("update".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String title = req.getParameter("title");
                String description = req.getParameter("description");
                String startDateStr = req.getParameter("startDate");
                String endDateStr = req.getParameter("endDate");
                String status = req.getParameter("status");

                Election election = electionDAO.findById(id);
                election.setTitle(title);
                election.setDescription(description);
                election.setStartDate(LocalDateTime.parse(startDateStr, DTF));
                election.setEndDate(LocalDateTime.parse(endDateStr, DTF));
                election.setStatus(status);

                if (electionDAO.update(election)) {
                    req.setAttribute("success", "Election updated successfully!");
                } else {
                    req.setAttribute("error", "Failed to update election.");
                }

            } else if ("status".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String status = req.getParameter("status");

                if (electionDAO.updateStatus(id, status)) {
                    req.setAttribute("success", "Election status updated to: " + status);
                } else {
                    req.setAttribute("error", "Failed to update election status.");
                }

            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                if (electionDAO.delete(id)) {
                    req.setAttribute("success", "Election deleted successfully!");
                } else {
                    req.setAttribute("error", "Failed to delete election.");
                }
            }

            doGet(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error: " + e.getMessage());
            doGet(req, resp);
        }
    }
}
