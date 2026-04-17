package com.evoting.servlet;

import com.evoting.dao.VoteDAO;
import com.evoting.model.Vote;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Verifies a vote receipt token (audit trail).
 * Anyone with a receipt token can verify their vote was counted.
 */
public class VerifyReceiptServlet extends HttpServlet {

    private final VoteDAO voteDAO = new VoteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.getRequestDispatcher("/WEB-INF/jsp/verify-receipt.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String receiptToken = req.getParameter("receiptToken");

        if (receiptToken == null || receiptToken.trim().isEmpty()) {
            req.setAttribute("error", "Please enter a receipt token.");
            req.getRequestDispatcher("/WEB-INF/jsp/verify-receipt.jsp").forward(req, resp);
            return;
        }

        try {
            Vote vote = voteDAO.findByReceiptToken(receiptToken.trim());

            if (vote != null) {
                req.setAttribute("vote", vote);
                req.setAttribute("verified", true);
            } else {
                req.setAttribute("verified", false);
                req.setAttribute("error", "No vote found with this receipt token.");
            }

            req.getRequestDispatcher("/WEB-INF/jsp/verify-receipt.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Verification failed: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/verify-receipt.jsp").forward(req, resp);
        }
    }
}
