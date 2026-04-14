package com.evoting.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Admin Authentication Filter.
 * Ensures that only authenticated admins can access /admin/* resources.
 */
public class AdminAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        if (session == null || session.getAttribute("admin") == null) {
            // Not authenticated as admin - redirect to admin login
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login?role=admin&error=auth_required");
            return;
        }

        chain.doFilter(request, response);
    }
}
