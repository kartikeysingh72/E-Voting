package com.evoting.servlet;

import com.evoting.dao.CandidateDAO;
import com.evoting.dao.ElectionDAO;
import com.evoting.dao.VoteDAO;
import com.evoting.dao.VoterDAO;
import com.evoting.model.Candidate;
import com.evoting.model.Election;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Admin results servlet - view detailed results with ability to declare/lock results.
 */
public class AdminResultServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final VoteDAO voteDAO = new VoteDAO();
    private final VoterDAO voterDAO = new VoterDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            String electionIdStr = req.getParameter("electionId");

            if (electionIdStr != null) {
                int electionId = Integer.parseInt(electionIdStr);
                Election election = electionDAO.findById(electionId);
                List<Candidate> candidates = candidateDAO.findByElectionIdWithVotes(electionId);
                int totalVotes = voteDAO.getVoteCountByElection(electionId);
                int approvedVoters = voterDAO.getApprovedCount();
                double turnoutPercent = approvedVoters > 0 ?
                        ((double) totalVotes / approvedVoters) * 100 : 0;

                req.setAttribute("election", election);
                req.setAttribute("candidates", candidates);
                req.setAttribute("totalVotes", totalVotes);
                req.setAttribute("approvedVoters", approvedVoters);
                req.setAttribute("turnoutPercent", String.format("%.1f", turnoutPercent));
            }

            List<Election> allElections = electionDAO.findAll();
            req.setAttribute("allElections", allElections);
            req.getRequestDispatcher("/WEB-INF/jsp/admin/results.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load results: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/admin/results.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        try {
            if ("declare".equals(action)) {
                int electionId = Integer.parseInt(req.getParameter("electionId"));
                electionDAO.updateStatus(electionId, "COMPLETED");
                req.setAttribute("success", "Results declared! Election locked.");
            }
            doGet(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error: " + e.getMessage());
            doGet(req, resp);
        }
    }
}
