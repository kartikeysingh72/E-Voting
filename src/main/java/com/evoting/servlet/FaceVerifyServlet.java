package com.evoting.servlet;

import com.evoting.dao.FaceTemplateDAO;
import com.evoting.dao.FaceVerificationDAO;
import com.evoting.model.FaceTemplate;
import com.evoting.model.FaceVerification;
import com.evoting.model.Voter;
import com.evoting.util.FaceEmbeddingUtil;
import com.google.gson.Gson;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

/**
 * Handles face verification before allowing access to the ballot.
 * GET: Show face verification UI with webcam feed.
 * POST: Receive base64-encoded face image, match against stored embedding.
 */
public class FaceVerifyServlet extends HttpServlet {

    private final FaceTemplateDAO faceTemplateDAO = new FaceTemplateDAO();
    private final FaceVerificationDAO faceVerificationDAO = new FaceVerificationDAO();
    private final Gson gson = new Gson();

    private static final double DEFAULT_THRESHOLD = 0.60;
    private static final int DEFAULT_MAX_ATTEMPTS = 3;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("voter") == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=auth_required");
            return;
        }

        // If already face-verified, redirect to ballot
        if (Boolean.TRUE.equals(session.getAttribute("faceVerified"))) {
            resp.sendRedirect(req.getContextPath() + "/voter/vote");
            return;
        }

        // Check if face model is loaded
        if (!FaceEmbeddingUtil.isModelLoaded()) {
            req.setAttribute("modelError", true);
        }

        // Check if voter has a registered face template
        Voter voter = (Voter) session.getAttribute("voter");
        try {
            if (!faceTemplateDAO.voterHasTemplate(voter.getVoterId())) {
                req.setAttribute("noTemplate", true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Get config from ServletContext
        double threshold = getThreshold(req);
        int maxAttempts = getMaxAttempts(req);

        req.setAttribute("maxAttempts", maxAttempts);
        req.setAttribute("threshold", threshold);

        req.getRequestDispatcher("/WEB-INF/jsp/face-verify.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("voter") == null) {
            result.put("success", false);
            result.put("error", "Session expired. Please login again.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        // Check if face model is loaded
        if (!FaceEmbeddingUtil.isModelLoaded()) {
            result.put("success", false);
            result.put("error", "Face recognition model is not available. Please contact the administrator.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        Voter voter = (Voter) session.getAttribute("voter");
        int voterId = voter.getVoterId();
        double threshold = getThreshold(req);
        int maxAttempts = getMaxAttempts(req);

        // Track attempts in session
        Integer attempts = (Integer) session.getAttribute("faceVerifyAttempts");
        if (attempts == null) attempts = 0;

        if (attempts >= maxAttempts) {
            result.put("locked", true);
            result.put("error", "Maximum verification attempts exceeded. Please contact an administrator for a bypass token.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            // Handle bypass token submission
            String bypassToken = req.getParameter("bypassToken");
            if (bypassToken != null && !bypassToken.trim().isEmpty()) {
                FaceVerification bypassRecord = faceVerificationDAO.findUnusedBypassToken(bypassToken.trim());
                if (bypassRecord != null && bypassRecord.getVoterId() == voterId) {
                    // Mark token as used
                    faceVerificationDAO.markBypassUsed(bypassRecord.getVerificationId());
                    session.setAttribute("faceVerified", true);
                    session.setAttribute("bypassVerified", true);
                    session.removeAttribute("faceVerifyAttempts");

                    result.put("success", true);
                    result.put("redirect", req.getContextPath() + "/voter/vote");
                } else {
                    result.put("success", false);
                    result.put("error", "Invalid or expired bypass token.");
                }
                resp.getWriter().write(gson.toJson(result));
                return;
            }

            String base64Image = req.getParameter("image");
            if (base64Image == null || base64Image.isEmpty()) {
                result.put("success", false);
                result.put("error", "No image data received.");
                resp.getWriter().write(gson.toJson(result));
                return;
            }

            // Strip data URI prefix
            if (base64Image.contains(",")) {
                base64Image = base64Image.split(",")[1];
            }

            byte[] imageBytes = Base64.getDecoder().decode(base64Image);
            BufferedImage image = ImageIO.read(new ByteArrayInputStream(imageBytes));
            if (image == null) {
                result.put("success", false);
                result.put("error", "Could not read image data.");
                resp.getWriter().write(gson.toJson(result));
                return;
            }

            // Load stored template
            FaceTemplate storedTemplate = faceTemplateDAO.findActiveByVoterId(voterId);
            if (storedTemplate == null) {
                result.put("success", false);
                result.put("error", "No face template found. Please contact support.");
                resp.getWriter().write(gson.toJson(result));
                return;
            }

            // Extract live embedding
            float[] liveEmbedding = FaceEmbeddingUtil.extractEmbedding(image);
            float[] storedEmbedding = FaceEmbeddingUtil.jsonToEmbedding(storedTemplate.getEmbeddingJson());

            // Compute cosine similarity
            double similarity = FaceEmbeddingUtil.cosineSimilarity(storedEmbedding, liveEmbedding);
            boolean passed = similarity >= threshold;

            // Log verification attempt
            FaceVerification verification = new FaceVerification(
                    voterId, "LOGIN_VOTE",
                    BigDecimal.valueOf(similarity),
                    BigDecimal.valueOf(threshold),
                    passed
            );
            verification.setIpAddress(req.getRemoteAddr());
            verification.setUserAgent(req.getHeader("User-Agent"));
            faceVerificationDAO.save(verification);

            if (passed) {
                session.setAttribute("faceVerified", true);
                session.removeAttribute("faceVerifyAttempts");
                result.put("success", true);
                result.put("redirect", req.getContextPath() + "/voter/vote");
            } else {
                attempts++;
                session.setAttribute("faceVerifyAttempts", attempts);
                int remaining = maxAttempts - attempts;

                if (remaining <= 0) {
                    result.put("locked", true);
                    result.put("error", "Maximum verification attempts exceeded. Please contact an administrator for a bypass token.");
                } else {
                    result.put("success", false);
                    result.put("score", String.format("%.2f", similarity));
                    result.put("attemptsRemaining", remaining);
                    result.put("error", "Face did not match. " + remaining + " attempt(s) remaining.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("error", "Verification failed: " + e.getMessage());
        }

        resp.getWriter().write(gson.toJson(result));
    }

    private double getThreshold(HttpServletRequest req) {
        Object val = req.getServletContext().getAttribute("face.similarity.threshold");
        return val instanceof Double ? (Double) val : DEFAULT_THRESHOLD;
    }

    private int getMaxAttempts(HttpServletRequest req) {
        Object val = req.getServletContext().getAttribute("face.max.attempts");
        return val instanceof Integer ? (Integer) val : DEFAULT_MAX_ATTEMPTS;
    }
}
