package com.evoting.servlet;

import com.evoting.dao.ElectionDAO;
import com.evoting.dao.VoteDAO;
import com.evoting.dao.VoterDAO;
import com.evoting.dao.CandidateDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Admin Dashboard - shows summary statistics.
 */
public class AdminDashboardServlet extends HttpServlet {

    private final VoterDAO voterDAO = new VoterDAO();
    private final ElectionDAO electionDAO = new ElectionDAO();
    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final VoteDAO voteDAO = new VoteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            req.setAttribute("totalVoters", voterDAO.getCount());
            req.setAttribute("approvedVoters", voterDAO.getApprovedCount());
            req.setAttribute("totalElections", electionDAO.getCount());
            req.setAttribute("activeElections", electionDAO.getActiveCount());
            req.setAttribute("totalCandidates", candidateDAO.getCount());
            req.setAttribute("totalVotes", voteDAO.getTotalVoteCount());

            req.setAttribute("pendingVoters", voterDAO.findByStatus("PENDING"));
            req.setAttribute("activeElectionList", electionDAO.findActiveElections());

            req.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load dashboard: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp").forward(req, resp);
        }
    }
}
