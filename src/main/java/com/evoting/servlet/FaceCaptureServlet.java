package com.evoting.servlet;

import com.evoting.dao.FaceTemplateDAO;
import com.evoting.dao.VoterDAO;
import com.evoting.dao.OTPDAO;
import com.evoting.model.FaceTemplate;
import com.evoting.model.OTP;
import com.evoting.util.EmailUtil;
import com.evoting.util.FaceEmbeddingUtil;
import com.evoting.util.OTPUtil;
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
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

/**
 * Handles face capture during voter registration.
 * GET: Show face capture UI with webcam feed.
 * POST: Receive base64-encoded face image, extract embedding, save to DB.
 */
public class FaceCaptureServlet extends HttpServlet {

    private final FaceTemplateDAO faceTemplateDAO = new FaceTemplateDAO();
    private final VoterDAO voterDAO = new VoterDAO();
    private final OTPDAO otpDAO = new OTPDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("pendingVoterId") == null) {
            resp.sendRedirect(req.getContextPath() + "/register");
            return;
        }

        // Check if face model is loaded
        if (!FaceEmbeddingUtil.isModelLoaded()) {
            req.setAttribute("modelError", true);
        }

        req.getRequestDispatcher("/WEB-INF/jsp/face-capture.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("pendingVoterId") == null) {
            result.put("success", false);
            result.put("error", "Session expired. Please register again.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        // Check if face model is loaded
        if (!FaceEmbeddingUtil.isModelLoaded()) {
            result.put("success", false);
            result.put("error", "Face recognition model is not available. Please contact the administrator to deploy the ONNX model.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            // Read base64 image from request body
            String base64Image = req.getParameter("image");
            if (base64Image == null || base64Image.isEmpty()) {
                result.put("success", false);
                result.put("error", "No image data received.");
                resp.getWriter().write(gson.toJson(result));
                return;
            }

            // Strip data URI prefix if present (e.g., "data:image/png;base64,")
            if (base64Image.contains(",")) {
                base64Image = base64Image.split(",")[1];
            }

            // Decode to BufferedImage
            byte[] imageBytes = Base64.getDecoder().decode(base64Image);
            BufferedImage image = ImageIO.read(new ByteArrayInputStream(imageBytes));
            if (image == null) {
                result.put("success", false);
                result.put("error", "Could not read image data.");
                resp.getWriter().write(gson.toJson(result));
                return;
            }

            int voterId = (int) session.getAttribute("pendingVoterId");
            String email = (String) session.getAttribute("pendingVerificationEmail");

            // Check if face already registered
            if (faceTemplateDAO.voterHasTemplate(voterId)) {
                result.put("success", false);
                result.put("error", "Face already registered for this account.");
                resp.getWriter().write(gson.toJson(result));
                return;
            }

            // Extract face embedding
            float[] embedding = FaceEmbeddingUtil.extractEmbedding(image);
            String embeddingJson = FaceEmbeddingUtil.embeddingToJson(embedding);

            // Save template
            FaceTemplate template = new FaceTemplate(voterId, embeddingJson, FaceEmbeddingUtil.getModelVersion());
            int templateId = faceTemplateDAO.save(template);

            if (templateId > 0) {
                // Mark voter as face-registered
                voterDAO.updateFaceRegistered(voterId, true);

                // Now generate and send OTP for email verification
                String otpCode = OTPUtil.generateOTP();
                OTP otp = new OTP(email, otpCode, "REGISTRATION");
                otpDAO.store(otp);

                boolean emailSent = EmailUtil.sendOTPEmail(email, otpCode, "registration");
                session.setAttribute("otpSent", emailSent);

                result.put("success", true);
                result.put("redirect", req.getContextPath() + "/otp?action=verify&purpose=REGISTRATION");
            } else {
                result.put("success", false);
                result.put("error", "Failed to save face template. Please try again.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("error", "Face capture failed: " + e.getMessage());
        }

        resp.getWriter().write(gson.toJson(result));
    }
}
