package com.evoting.servlet;

import com.evoting.dao.CandidateDAO;
import com.evoting.dao.ElectionDAO;
import com.evoting.model.Candidate;
import com.evoting.model.Election;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;

/**
 * Admin servlet for managing candidates.
 * Supports adding, editing, deleting candidates and photo upload.
 */
public class AdminCandidateServlet extends HttpServlet {

    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final ElectionDAO electionDAO = new ElectionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            String electionIdStr = req.getParameter("electionId");
            List<Election> elections = electionDAO.findAll();
            req.setAttribute("elections", elections);

            if (electionIdStr != null) {
                int electionId = Integer.parseInt(electionIdStr);
                Election election = electionDAO.findById(electionId);
                List<Candidate> candidates = candidateDAO.findByElectionId(electionId);
                req.setAttribute("selectedElection", election);
                req.setAttribute("candidates", candidates);
                req.setAttribute("selectedElectionId", electionId);
            }

            String action = req.getParameter("action");
            if ("edit".equals(action) && req.getParameter("id") != null) {
                int id = Integer.parseInt(req.getParameter("id"));
                Candidate candidate = candidateDAO.findById(id);
                req.setAttribute("candidate", candidate);
            }

            req.getRequestDispatcher("/WEB-INF/jsp/admin/candidates.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Failed to load candidates: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/admin/candidates.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        try {
            if ("add".equals(action)) {
                int electionId = Integer.parseInt(req.getParameter("electionId"));
                String name = req.getParameter("name");
                String party = req.getParameter("party");
                String bio = req.getParameter("bio");
                String photoUrl = req.getParameter("photoUrl");
                String symbolUrl = req.getParameter("symbolUrl");

                if (name == null || name.trim().isEmpty() || party == null || party.trim().isEmpty()) {
                    req.setAttribute("error", "Candidate name and party are required.");
                    req.setAttribute("selectedElectionId", electionId);
                    doGet(req, resp);
                    return;
                }

                Candidate candidate = new Candidate(electionId, name.trim(), party.trim(), bio);
                candidate.setPhotoUrl(photoUrl);
                candidate.setSymbolUrl(symbolUrl);

                int id = candidateDAO.add(candidate);
                if (id > 0) {
                    req.setAttribute("success", "Candidate added successfully!");
                } else {
                    req.setAttribute("error", "Failed to add candidate.");
                }
                req.setAttribute("selectedElectionId", electionId);

            } else if ("update".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                int electionId = Integer.parseInt(req.getParameter("electionId"));
                String name = req.getParameter("name");
                String party = req.getParameter("party");
                String bio = req.getParameter("bio");
                String photoUrl = req.getParameter("photoUrl");
                String symbolUrl = req.getParameter("symbolUrl");

                Candidate candidate = candidateDAO.findById(id);
                candidate.setName(name);
                candidate.setParty(party);
                candidate.setBio(bio);
                candidate.setPhotoUrl(photoUrl);
                candidate.setSymbolUrl(symbolUrl);

                if (candidateDAO.update(candidate)) {
                    req.setAttribute("success", "Candidate updated successfully!");
                } else {
                    req.setAttribute("error", "Failed to update candidate.");
                }
                req.setAttribute("selectedElectionId", electionId);

            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                int electionId = Integer.parseInt(req.getParameter("electionId"));
                if (candidateDAO.delete(id)) {
                    req.setAttribute("success", "Candidate deleted successfully!");
                } else {
                    req.setAttribute("error", "Failed to delete candidate.");
                }
                req.setAttribute("selectedElectionId", electionId);
            }

            doGet(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error: " + e.getMessage());
            doGet(req, resp);
        }
    }
}
