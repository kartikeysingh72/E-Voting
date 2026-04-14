package com.evoting.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Voter Authentication Filter.
 * Ensures that only authenticated voters can access /voter/* resources.
 */
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        if (session == null || session.getAttribute("voter") == null) {
            // Not authenticated - redirect to login
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login?error=auth_required");
            return;
        }

        chain.doFilter(request, response);
    }
}
