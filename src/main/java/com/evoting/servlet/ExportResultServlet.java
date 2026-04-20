package com.evoting.servlet;

import com.evoting.dao.CandidateDAO;
import com.evoting.dao.ElectionDAO;
import com.evoting.dao.VoteDAO;
import com.evoting.model.Candidate;
import com.evoting.model.Election;

import com.opencsv.CSVWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.List;

/**
 * Exports election results as CSV.
 * PDF export would use iText but CSV is simpler and universally readable.
 */
public class ExportResultServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final VoteDAO voteDAO = new VoteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String electionIdStr = req.getParameter("electionId");
        String format = req.getParameter("format");

        if (electionIdStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Election ID required");
            return;
        }

        try {
            int electionId = Integer.parseInt(electionIdStr);
            Election election = electionDAO.findById(electionId);
            List<Candidate> candidates = candidateDAO.findByElectionIdWithVotes(electionId);
            int totalVotes = voteDAO.getVoteCountByElection(electionId);

            if ("csv".equals(format)) {
                exportCSV(resp, election, candidates, totalVotes);
            } else {
                exportHTML(resp, election, candidates, totalVotes);
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Export failed");
        }
    }

    private void exportCSV(HttpServletResponse resp, Election election,
                           List<Candidate> candidates, int totalVotes) throws IOException {

        resp.setContentType("text/csv");
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"results_" + election.getTitle().replaceAll("\\s+", "_") + ".csv\"");

        try (CSVWriter writer = new CSVWriter(resp.getWriter())) {
            // Header
            writer.writeNext(new String[]{"Election", election.getTitle()});
            writer.writeNext(new String[]{"Total Votes", String.valueOf(totalVotes)});
            writer.writeNext(new String[]{});

            // Column headers
            writer.writeNext(new String[]{"Candidate", "Party", "Votes", "Percentage"});

            // Data rows
            for (Candidate c : candidates) {
                double percent = totalVotes > 0 ? ((double) c.getVoteCount() / totalVotes) * 100 : 0;
                writer.writeNext(new String[]{
                        c.getName(),
                        c.getParty(),
                        String.valueOf(c.getVoteCount()),
                        String.format("%.1f%%", percent)
                });
            }
        }
    }

    private void exportHTML(HttpServletResponse resp, Election election,
                            List<Candidate> candidates, int totalVotes) throws IOException {

        resp.setContentType("text/html");

        PrintWriter out = resp.getWriter();
        out.println("<html><head><title>Results - " + election.getTitle() + "</title>");
        out.println("<style>body{font-family:Arial;padding:20px}table{border-collapse:collapse;width:100%}");
        out.println("th,td{border:1px solid #ddd;padding:8px;text-align:left}th{background:#2563eb;color:white}</style></head>");
        out.println("<body><h1>" + election.getTitle() + " - Results</h1>");
        out.println("<p>Total Votes: " + totalVotes + "</p>");
        out.println("<table><tr><th>Candidate</th><th>Party</th><th>Votes</th><th>Percentage</th></tr>");

        for (Candidate c : candidates) {
            double percent = totalVotes > 0 ? ((double) c.getVoteCount() / totalVotes) * 100 : 0;
            out.println("<tr><td>" + c.getName() + "</td><td>" + c.getParty() + "</td><td>" +
                    c.getVoteCount() + "</td><td>" + String.format("%.1f%%", percent) + "</td></tr>");
        }

        out.println("</table></body></html>");
    }
}
