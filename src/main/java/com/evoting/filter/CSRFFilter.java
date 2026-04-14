package com.evoting.filter;

import com.evoting.util.CSRFUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * CSRF Protection Filter.
 * For POST requests, validates the CSRF token.
 * Also sets security headers on all responses.
 */
public class CSRFFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Proactively generate CSRF token and expose as request attribute for JSP forms
        HttpSession session = httpRequest.getSession(true);
        request.setAttribute("csrfToken", CSRFUtil.getToken(session));

        // Set security headers
        httpResponse.setHeader("X-Content-Type-Options", "nosniff");
        httpResponse.setHeader("X-Frame-Options", "DENY");
        httpResponse.setHeader("X-XSS-Protection", "1; mode=block");
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");

        // Skip CSRF for GET, HEAD, OPTIONS requests
        String method = httpRequest.getMethod();
        if ("GET".equalsIgnoreCase(method) || "HEAD".equalsIgnoreCase(method) ||
            "OPTIONS".equalsIgnoreCase(method)) {
            chain.doFilter(request, response);
            return;
        }

        // Skip CSRF for AJAX endpoints (they use session-based auth)
        String uri = httpRequest.getRequestURI();
        if (uri.contains("/api/") || uri.endsWith("/live-stats")) {
            chain.doFilter(request, response);
            return;
        }

        // Validate CSRF token for POST/PUT/DELETE
        if (!CSRFUtil.validateToken(httpRequest)) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "CSRF token validation failed. Please refresh the page and try again.");
            return;
        }

        chain.doFilter(request, response);
    }
}
