package com.evoting.servlet;

import com.evoting.dao.CandidateDAO;
import com.evoting.dao.ElectionDAO;
import com.evoting.dao.VoteDAO;
import com.evoting.model.Candidate;
import com.evoting.model.Election;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Displays election results for completed elections.
 * Accessible to all users (public results page).
 */
public class ResultServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final VoteDAO voteDAO = new VoteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            String electionIdStr = req.getParameter("electionId");

            if (electionIdStr != null) {
                // Show results for specific election
                int electionId = Integer.parseInt(electionIdStr);
                Election election = electionDAO.findById(electionId);

                if (election == null) {
                    req.setAttribute("error", "Election not found.");
                    req.getRequestDispatcher("/WEB-INF/jsp/results.jsp").forward(req, resp);
                    return;
                }

                List<Candidate> candidates = candidateDAO.findByElectionIdWithVotes(electionId);
                int totalVotes = voteDAO.getVoteCountByElection(electionId);

                // Calculate percentage for each candidate
                for (Candidate c : candidates) {
                    if (totalVotes > 0) {
                        c.setVoteCount(c.getVoteCount()); // already set from query
                    }
                }

                req.setAttribute("election", election);
                req.setAttribute("candidates", candidates);
                req.setAttribute("totalVotes", totalVotes);
            }

            // List all completed elections
            List<Election> completedElections = electionDAO.findCompletedElections();
            req.setAttribute("completedElections", completedElections);

            req.getRequestDispatcher("/WEB-INF/jsp/results.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load results: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/results.jsp").forward(req, resp);
        }
    }
}
