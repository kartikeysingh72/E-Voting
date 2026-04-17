package com.evoting.servlet;

import com.evoting.dao.CandidateDAO;
import com.evoting.dao.ElectionDAO;
import com.evoting.dao.VoteDAO;
import com.evoting.model.Candidate;
import com.evoting.model.Election;
import com.evoting.model.Vote;
import com.evoting.model.Voter;
import com.evoting.util.OTPUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * Handles vote casting for authenticated voters.
 * GET: Show ballot with active elections and candidates.
 * POST: Cast vote (one per voter per election, DB-enforced).
 */
public class VoteServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final VoteDAO voteDAO = new VoteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Voter voter = (Voter) session.getAttribute("voter");

        try {
            // Get active elections
            List<Election> activeElections = electionDAO.findActiveElections();

            // For each election, check if voter has already voted and load candidates
            for (Election election : activeElections) {
                boolean hasVoted = voteDAO.hasVoted(voter.getVoterId(), election.getElectionId());
                if (hasVoted) {
                    election.setStatus("VOTED"); // Custom status for UI
                }
            }

            // If a specific election is selected, load its candidates
            String electionIdStr = req.getParameter("electionId");
            if (electionIdStr != null) {
                int electionId = Integer.parseInt(electionIdStr);
                Election election = electionDAO.findById(electionId);
                List<Candidate> candidates = candidateDAO.findByElectionId(electionId);
                boolean hasVoted = voteDAO.hasVoted(voter.getVoterId(), electionId);

                req.setAttribute("selectedElection", election);
                req.setAttribute("candidates", candidates);
                req.setAttribute("hasVoted", hasVoted);
            }

            req.setAttribute("elections", activeElections);
            req.getRequestDispatcher("/WEB-INF/jsp/ballot.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load elections: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/ballot.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Voter voter = (Voter) session.getAttribute("voter");

        String electionIdStr = req.getParameter("electionId");
        String candidateIdStr = req.getParameter("candidateId");

        if (electionIdStr == null || candidateIdStr == null) {
            req.setAttribute("error", "Please select a candidate.");
            doGet(req, resp);
            return;
        }

        try {
            int electionId = Integer.parseInt(electionIdStr);
            int candidateId = Integer.parseInt(candidateIdStr);

            // Verify election exists and is open
            Election election = electionDAO.findById(electionId);
            if (election == null || !election.isVotingOpen()) {
                req.setAttribute("error", "This election is not currently open for voting.");
                doGet(req, resp);
                return;
            }

            // Check if already voted (double protection - app level + DB unique constraint)
            if (voteDAO.hasVoted(voter.getVoterId(), electionId)) {
                req.setAttribute("error", "You have already voted in this election.");
                doGet(req, resp);
                return;
            }

            // Verify candidate belongs to this election
            Candidate candidate = candidateDAO.findById(candidateId);
            if (candidate == null || candidate.getElectionId() != electionId) {
                req.setAttribute("error", "Invalid candidate selection.");
                doGet(req, resp);
                return;
            }

            // Generate unique receipt token
            String receiptToken = OTPUtil.generateReceiptToken(electionId, voter.getVoterId());

            // Cast the vote
            Vote vote = new Vote(voter.getVoterId(), electionId, candidateId, receiptToken);
            boolean success = voteDAO.castVote(vote);

            if (success) {
                // Invalidate session after voting (security measure)
                req.setAttribute("success", true);
                req.setAttribute("receiptToken", receiptToken);
                req.setAttribute("electionTitle", election.getTitle());
                req.setAttribute("candidateName", candidate.getName());
                req.getRequestDispatcher("/WEB-INF/jsp/vote-success.jsp").forward(req, resp);

                // Invalidate session after showing receipt
                // (voter needs to re-login to vote in another election)
            } else {
                req.setAttribute("error", "Failed to cast vote. Please try again.");
                doGet(req, resp);
            }

        } catch (java.sql.SQLIntegrityConstraintViolationException e) {
            req.setAttribute("error", "You have already voted in this election.");
            doGet(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "An error occurred while casting your vote: " + e.getMessage());
            doGet(req, resp);
        }
    }
}
