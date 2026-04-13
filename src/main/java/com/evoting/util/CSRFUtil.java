package com.evoting.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * CSRF (Cross-Site Request Forgery) protection utility.
 * Generates and validates per-session CSRF tokens.
 */
public class CSRFUtil {

    private static final String CSRF_TOKEN_ATTR = "CSRF_TOKEN";
    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * Generate a new CSRF token and store it in the session.
     */
    public static String generateToken(HttpSession session) {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(CSRF_TOKEN_ATTR, token);
        return token;
    }

    /**
     * Get the current CSRF token from session (generate if not present).
     */
    public static String getToken(HttpSession session) {
        String token = (String) session.getAttribute(CSRF_TOKEN_ATTR);
        if (token == null) {
            token = generateToken(session);
        }
        return token;
    }

    /**
     * Validate the CSRF token from the request against the session token.
     */
    public static boolean validateToken(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;

        String sessionToken = (String) session.getAttribute(CSRF_TOKEN_ATTR);
        String requestToken = request.getParameter("_csrf");

        if (sessionToken == null || requestToken == null) return false;
        return sessionToken.equals(requestToken);
    }

    /**
     * Get a hidden HTML input field containing the CSRF token.
     */
    public static String getHiddenInput(HttpSession session) {
        return "<input type='hidden' name='_csrf' value='" + getToken(session) + "' />";
    }
}
