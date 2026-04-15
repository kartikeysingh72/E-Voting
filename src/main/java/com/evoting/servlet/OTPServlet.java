package com.evoting.servlet;

import com.evoting.dao.OTPDAO;
import com.evoting.dao.VoterDAO;
import com.evoting.model.OTP;
import com.evoting.util.EmailUtil;
import com.evoting.util.OTPUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Handles OTP sending and verification for registration and login.
 * GET: Show OTP input form or send OTP.
 * POST: Verify OTP.
 */
public class OTPServlet extends HttpServlet {

    private final OTPDAO otpDAO = new OTPDAO();
    private final VoterDAO voterDAO = new VoterDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String purpose = req.getParameter("purpose");
        HttpSession session = req.getSession(false);

        if ("verify".equals(action)) {
            // Show OTP verification form
            String email = session != null ? (String) session.getAttribute("pendingVerificationEmail") : null;
            if (email == null) {
                email = session != null ? (String) session.getAttribute("loginEmail") : null;
            }
            req.setAttribute("email", email);
            req.setAttribute("purpose", purpose != null ? purpose : "LOGIN");
            req.getRequestDispatcher("/WEB-INF/jsp/verify-otp.jsp").forward(req, resp);
            return;
        }

        if ("send".equals(action)) {
            // Send/resend OTP
            String email = req.getParameter("email");
            purpose = purpose != null ? purpose : "LOGIN";

            if (email == null || email.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            try {
                // Invalidate old OTPs
                otpDAO.invalidateAll(email, purpose);

                // Generate new OTP
                String otpCode = OTPUtil.generateOTP();
                OTP otp = new OTP(email, otpCode, purpose);
                otpDAO.store(otp);

                boolean sent = EmailUtil.sendOTPEmail(email, otpCode, purpose.toLowerCase());

                session = req.getSession(true);
                if ("REGISTRATION".equals(purpose)) {
                    session.setAttribute("pendingVerificationEmail", email);
                } else {
                    session.setAttribute("loginEmail", email);
                }
                session.setAttribute("otpSent", sent);

                resp.sendRedirect(req.getContextPath() + "/otp?action=verify&purpose=" + purpose);

            } catch (Exception e) {
                e.printStackTrace();
                req.setAttribute("error", "Failed to send OTP: " + e.getMessage());
                req.getRequestDispatcher("/WEB-INF/jsp/verify-otp.jsp").forward(req, resp);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String otpCode = req.getParameter("otpCode");
        String purpose = req.getParameter("purpose");
        HttpSession session = req.getSession(false);

        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String email;
        if ("REGISTRATION".equals(purpose)) {
            email = (String) session.getAttribute("pendingVerificationEmail");
        } else {
            email = (String) session.getAttribute("loginEmail");
        }

        if (email == null || otpCode == null) {
            req.setAttribute("error", "Session expired. Please try again.");
            req.getRequestDispatcher("/WEB-INF/jsp/verify-otp.jsp").forward(req, resp);
            return;
        }

        try {
            OTP otp = otpDAO.findLatestValid(email, purpose);

            if (otp == null) {
                req.setAttribute("error", "No valid OTP found. Please request a new one.");
                req.setAttribute("email", email);
                req.setAttribute("purpose", purpose);
                req.getRequestDispatcher("/WEB-INF/jsp/verify-otp.jsp").forward(req, resp);
                return;
            }

            if (otp.isExpired()) {
                req.setAttribute("error", "OTP has expired. Please request a new one.");
                req.setAttribute("email", email);
                req.setAttribute("purpose", purpose);
                req.getRequestDispatcher("/WEB-INF/jsp/verify-otp.jsp").forward(req, resp);
                return;
            }

            if (!otp.getOtpCode().equals(otpCode)) {
                req.setAttribute("error", "Invalid OTP. Please try again.");
                req.setAttribute("email", email);
                req.setAttribute("purpose", purpose);
                req.getRequestDispatcher("/WEB-INF/jsp/verify-otp.jsp").forward(req, resp);
                return;
            }

            // OTP verified successfully
            otpDAO.markUsed(otp.getId());

            if ("REGISTRATION".equals(purpose)) {
                // Mark voter email as verified
                voterDAO.verifyEmail(email);
                session.removeAttribute("pendingVerificationEmail");
                session.removeAttribute("pendingVoterId");
                session.removeAttribute("otpSent");

                req.setAttribute("success", "Registration successful! Your account is pending admin approval.");
                req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
            } else {
                // LOGIN OTP verified - create session
                com.evoting.model.Voter voter = voterDAO.findByEmail(email);
                if (voter != null) {
                    session.setAttribute("voter", voter);
                    session.removeAttribute("loginEmail");
                    session.removeAttribute("otpSent");
                    resp.sendRedirect(req.getContextPath() + "/voter/vote");
                } else {
                    req.setAttribute("error", "Voter not found.");
                    req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Verification failed: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/verify-otp.jsp").forward(req, resp);
        }
    }
}
