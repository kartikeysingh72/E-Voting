package com.evoting.servlet;

import com.evoting.dao.VoterDAO;
import com.evoting.model.Voter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Admin servlet for approving/rejecting voter registrations (KYC-like).
 */
public class AdminVoterApprovalServlet extends HttpServlet {

    private final VoterDAO voterDAO = new VoterDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            String status = req.getParameter("status");
            List<Voter> voters;

            if (status != null && !status.isEmpty()) {
                voters = voterDAO.findByStatus(status);
                req.setAttribute("selectedStatus", status);
            } else {
                voters = voterDAO.findAll();
            }

            req.setAttribute("voters", voters);
            req.getRequestDispatcher("/WEB-INF/jsp/admin/voters.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load voters: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/admin/voters.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String voterIdStr = req.getParameter("voterId");

        try {
            if (voterIdStr != null) {
                int voterId = Integer.parseInt(voterIdStr);

                if ("approve".equals(action)) {
                    if (voterDAO.updateApprovalStatus(voterId, true)) {
                        req.setAttribute("success", "Voter approved successfully!");
                    } else {
                        req.setAttribute("error", "Failed to approve voter.");
                    }
                } else if ("reject".equals(action)) {
                    if (voterDAO.updateApprovalStatus(voterId, false)) {
                        req.setAttribute("success", "Voter rejected.");
                    } else {
                        req.setAttribute("error", "Failed to reject voter.");
                    }
                } else if ("delete".equals(action)) {
                    if (voterDAO.delete(voterId)) {
                        req.setAttribute("success", "Voter #" + voterId + " and all related data deleted.");
                    } else {
                        req.setAttribute("error", "Failed to delete voter.");
                    }
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
