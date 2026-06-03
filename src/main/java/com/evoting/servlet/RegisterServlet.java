package com.evoting.servlet;

import com.evoting.dao.OTPDAO;
import com.evoting.dao.VoterDAO;
import com.evoting.model.OTP;
import com.evoting.model.Voter;
import com.evoting.util.BCryptUtil;
import com.evoting.util.EmailUtil;
import com.evoting.util.OTPUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.Period;
import java.util.Arrays;
import java.util.List;

/**
 * Handles voter registration.
 * GET: Show registration form.
 * POST: Process registration, validate age 18+, send email OTP.
 */
public class RegisterServlet extends HttpServlet {

    // Allowed university email domains
    private static final List<String> ALLOWED_EMAIL_DOMAINS = Arrays.asList(
        "@shiats.edu.in"
    );

    private final VoterDAO voterDAO = new VoterDAO();
    private final OTPDAO otpDAO = new OTPDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String dobStr = req.getParameter("dob");
        String pidNumber = req.getParameter("pidNumber");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // --- Validation ---
        if (name == null || name.trim().isEmpty()) {
            req.setAttribute("error", "Name is required.");
            req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
            return;
        }

        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            req.setAttribute("error", "Valid email is required.");
            req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
            return;
        }

        // Validate university email domain
        String emailLower = email.trim().toLowerCase();
        boolean domainAllowed = false;
        for (String domain : ALLOWED_EMAIL_DOMAINS) {
            if (emailLower.endsWith(domain.toLowerCase())) {
                domainAllowed = true;
                break;
            }
        }
        if (!domainAllowed) {
            req.setAttribute("error", "Only university email addresses are allowed (e.g., yourid@shiats.edu.in).");
            req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
            return;
        }

        if (password == null || password.length() < 8) {
            req.setAttribute("error", "Password must be at least 8 characters.");
            req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
            return;
        }

        // Age validation (must be 18+)
        LocalDate dob;
        try {
            dob = LocalDate.parse(dobStr);
            int age = Period.between(dob, LocalDate.now()).getYears();
            if (age < 18) {
                req.setAttribute("error", "You must be at least 18 years old to register.");
                req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
                return;
            }
        } catch (Exception e) {
            req.setAttribute("error", "Invalid date of birth.");
            req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
            return;
        }

        try {
            // Check if email already exists
            if (voterDAO.findByEmail(email) != null) {
                req.setAttribute("error", "Email already registered.");
                req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
                return;
            }

            // Check if P ID number already exists
            if (voterDAO.findByPidNumber(pidNumber) != null) {
                req.setAttribute("error", "P ID number already registered.");
                req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
                return;
            }

            // Hash password and create voter
            String passwordHash = BCryptUtil.hashPassword(password);
            Voter voter = new Voter(name.trim(), email.trim(), phone.trim(), dob, pidNumber.trim(), passwordHash);
            int voterId = voterDAO.register(voter);

            if (voterId > 0) {
                // Generate and send OTP
                String otpCode = OTPUtil.generateOTP();
                OTP otp = new OTP(email.trim(), otpCode, "REGISTRATION");
                otpDAO.store(otp);
                EmailUtil.sendOTPEmail(email.trim(), otpCode, "registration");

                // Store email in session for OTP verification
                HttpSession session = req.getSession(true);
                session.setAttribute("pendingVerificationEmail", email.trim());

                // Redirect to OTP verification page
                resp.sendRedirect(req.getContextPath() + "/otp");
            } else {
                req.setAttribute("error", "Registration failed. Please try again.");
                req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "An error occurred: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/jsp/register.jsp").forward(req, resp);
        }
    }
}
