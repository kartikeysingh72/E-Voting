package com.evoting.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Face Verification Filter.
 * Ensures that voters have passed face verification before accessing the ballot (/voter/vote).
 * Runs after AuthFilter (which checks for login session).
 */
public class FaceVerifiedFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        // If no session or no voter, let AuthFilter handle it
        if (session == null || session.getAttribute("voter") == null) {
            chain.doFilter(request, response);
            return;
        }

        // Check if face verification has been passed
        if (Boolean.TRUE.equals(session.getAttribute("faceVerified"))) {
            chain.doFilter(request, response);
            return;
        }

        // Check if voter has a bypass token in session
        if (session.getAttribute("bypassVerified") != null &&
                Boolean.TRUE.equals(session.getAttribute("bypassVerified"))) {
            chain.doFilter(request, response);
            return;
        }

        // Not face-verified -- redirect to face verification
        httpResponse.sendRedirect(httpRequest.getContextPath() + "/face/verify");
    }
}
