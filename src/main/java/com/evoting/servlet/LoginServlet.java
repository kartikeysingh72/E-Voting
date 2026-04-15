package com.evoting.servlet;

import com.evoting.dao.AdminDAO;
import com.evoting.dao.VoterDAO;
import com.evoting.model.Admin;
import com.evoting.model.Voter;
import com.evoting.util.BCryptUtil;
import com.evoting.util.EmailUtil;
import com.evoting.util.OTPUtil;
import com.evoting.dao.OTPDAO;
import com.evoting.model.OTP;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Handles voter and admin login.
 * GET: Show login form.
 * POST: Authenticate and redirect based on role.
 * Voter login: password check + OTP 2FA.
 * Admin login: password check only.
 */
public class LoginServlet extends HttpServlet {

    private final VoterDAO voterDAO = new VoterDAO();
    private final AdminDAO adminDAO = new AdminDAO();
    private final OTPDAO otpDAO = new OTPDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // If already logged in as voter, redirect
        if (session != null && session.getAttribute("voter") != null) {
            resp.sendRedirect(req.getContextPath() + "/voter/vote");
            return;
        }

        // If already logged in as admin, redirect
        if (session != null && session.getAttribute("admin") != null) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role = req.getParameter("role");
        String email = req.getParameter("email");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        HttpSession session = req.getSession(true);

        if ("admin".equals(role)) {
            handleAdminLogin(req, resp, username, password, session);
        } else {
            handleVoterLogin(req, resp, email, password, session);
        }
    }

    private void handleVoterLogin(HttpServletRequest req, HttpServletResponse resp,
                                  String email, String password, HttpSession session)
            throws ServletException, IOException {

        if (email == null || email.isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
            return;
        }

        try {
            Voter voter = voterDAO.findByEmail(email);

            if (voter == null || !BCryptUtil.checkPassword(password, voter.getPasswordHash())) {
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
                return;
            }

            if (!voter.isVerified()) {
                req.setAttribute("error", "Email not verified. Please complete registration verification.");
                req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
                return;
            }

            if (!voter.isApproved()) {
                req.setAttribute("error", "Your account is pending admin approval. Please wait.");
                req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
                return;
            }

            if ("REJECTED".equals(voter.getStatus())) {
                req.setAttribute("error", "Your account has been rejected. Contact administrator.");
                req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
                return;
            }

            // Password verified - now send OTP for 2FA
            String otpCode = OTPUtil.generateOTP();
            OTP otp = new OTP(email, otpCode, "LOGIN");
            otpDAO.invalidateAll(email, "LOGIN");
            otpDAO.store(otp);

            boolean emailSent = EmailUtil.sendOTPEmail(email, otpCode, "login");

            session.setAttribute("loginEmail", email);
            session.setAttribute("otpSent", emailSent);

            resp.sendRedirect(req.getContextPath() + "/otp?action=verify&purpose=LOGIN");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Login failed: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
        }
    }

    private void handleAdminLogin(HttpServletRequest req, HttpServletResponse resp,
                                  String username, String password, HttpSession session)
            throws ServletException, IOException {

        if (username == null || username.isEmpty() || password == null || password.isEmpty()) {
            req.setAttribute("error", "Username and password are required.");
            req.setAttribute("role", "admin");
            req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
            return;
        }

        try {
            Admin admin = adminDAO.findByUsername(username);

            if (admin == null || !BCryptUtil.checkPassword(password, admin.getPasswordHash())) {
                req.setAttribute("error", "Invalid admin credentials.");
                req.setAttribute("role", "admin");
                req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
                return;
            }

            // Admin authenticated
            session.setAttribute("admin", admin);
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Login failed: " + e.getMessage());
            req.setAttribute("role", "admin");
            req.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(req, resp);
        }
    }
}
