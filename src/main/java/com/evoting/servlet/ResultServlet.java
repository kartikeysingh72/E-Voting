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
            // Always load all completed elections for the dropdown
            List<Election> completedElections = electionDAO.findCompletedElections();
            req.setAttribute("completedElections", completedElections);

            String electionIdStr = req.getParameter("electionId");

            if (electionIdStr != null && !electionIdStr.isEmpty()) {
                // Show results for a specific election
                int electionId = Integer.parseInt(electionIdStr);
                Election election = electionDAO.findById(electionId);

                if (election == null) {
                    req.setAttribute("error", "Election not found.");
                } else {
                    List<Candidate> candidates = candidateDAO.findByElectionIdWithVotes(electionId);
                    int totalVotes = voteDAO.getVoteCountByElection(electionId);

                    req.setAttribute("election", election);
                    req.setAttribute("candidates", candidates);
                    req.setAttribute("totalVotes", totalVotes);
                }
            }

            req.getRequestDispatcher("/WEB-INF/jsp/results.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load results: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/results.jsp").forward(req, resp);
        }
    }
}
