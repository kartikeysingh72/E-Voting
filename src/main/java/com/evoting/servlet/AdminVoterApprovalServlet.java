package com.evoting.servlet;

import com.evoting.dao.FaceTemplateDAO;
import com.evoting.dao.FaceVerificationDAO;
import com.evoting.dao.VoterDAO;
import com.evoting.model.FaceVerification;
import com.evoting.model.Voter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Admin servlet for approving/rejecting voter registrations (KYC-like).
 * Also provides face registration status and bypass token issuance.
 */
public class AdminVoterApprovalServlet extends HttpServlet {

    private final VoterDAO voterDAO = new VoterDAO();
    private final FaceTemplateDAO faceTemplateDAO = new FaceTemplateDAO();
    private final FaceVerificationDAO faceVerificationDAO = new FaceVerificationDAO();

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

            // Build face status and failure count maps
            Map<Integer, Boolean> faceStatusMap = new HashMap<>();
            Map<Integer, Integer> failureCountMap = new HashMap<>();
            for (Voter v : voters) {
                faceStatusMap.put(v.getVoterId(), faceTemplateDAO.voterHasTemplate(v.getVoterId()));
                failureCountMap.put(v.getVoterId(), faceVerificationDAO.countRecentFailures(v.getVoterId(), 24));
            }

            req.setAttribute("voters", voters);
            req.setAttribute("faceStatusMap", faceStatusMap);
            req.setAttribute("failureCountMap", failureCountMap);
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
                } else if ("issueBypass".equals(action)) {
                    // Generate a one-time bypass token
                    String bypassToken = UUID.randomUUID().toString().replace("-", "").substring(0, 32);

                    FaceVerification bypassRecord = new FaceVerification(
                            voterId, "ADMIN_BYPASS",
                            null,
                            new BigDecimal("0.0000"),
                            true
                    );
                    bypassRecord.setBypassToken(bypassToken);
                    bypassRecord.setIpAddress(req.getRemoteAddr());
                    bypassRecord.setUserAgent(req.getHeader("User-Agent"));

                    int savedId = faceVerificationDAO.save(bypassRecord);
                    if (savedId > 0) {
                        req.setAttribute("success", "Bypass token issued for voter #" + voterId);
                        req.setAttribute("bypassToken", bypassToken);
                        req.setAttribute("bypassVoterId", voterId);
                    } else {
                        req.setAttribute("error", "Failed to issue bypass token.");
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
