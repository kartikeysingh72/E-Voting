<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Login - E-Voting Platform"/>
</jsp:include>

<div class="row justify-content-center">
    <div class="col-md-5">
        <!-- Success/Error Messages -->
        <c:if test="${success != null}">
            <div class="alert alert-success alert-dismissible fade show">
                <i class="bi bi-check-circle"></i> ${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${error != null}">
            <div class="alert alert-danger alert-dismissible fade show">
                <i class="bi bi-exclamation-triangle"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${param.error == 'auth_required'}">
            <div class="alert alert-warning">
                <i class="bi bi-lock"></i> Please login to continue.
            </div>
        </c:if>

        <div class="card shadow-sm">
            <div class="card-body p-4">
                <h3 class="text-center mb-4"><i class="bi bi-box-arrow-in-right"></i> Login</h3>

                <!-- Tab Navigation -->
                <ul class="nav nav-tabs mb-4" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link ${role != 'admin' ? 'active' : ''}" data-bs-toggle="tab" href="#voterLogin">
                            <i class="bi bi-person"></i> Voter Login
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link ${role == 'admin' ? 'active' : ''}" data-bs-toggle="tab" href="#adminLogin">
                            <i class="bi bi-shield-lock"></i> Admin Login
                        </a>
                    </li>
                </ul>

                <div class="tab-content">
                    <!-- Voter Login Form -->
                    <div class="tab-pane ${role != 'admin' ? 'active' : ''}" id="voterLogin">
                        <form method="POST" action="${pageContext.request.contextPath}/login">
                            <input type="hidden" name="role" value="voter">
                            <input type="hidden" name="_csrf" value="${csrfToken}">

                            <div class="mb-3">
                                <label class="form-label">Email Address</label>
                                <input type="email" name="email" class="form-control" required
                                       placeholder="your@email.com">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Password</label>
                                <input type="password" name="password" class="form-control" required
                                       placeholder="Enter your password">
                            </div>
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="bi bi-arrow-right-circle"></i> Login &amp; Verify OTP
                            </button>
                        </form>
                        <p class="text-center mt-3 mb-0">
                            <small>Don't have an account?
                                <a href="${pageContext.request.contextPath}/register">Register here</a>
                            </small>
                        </p>
                    </div>

                    <!-- Admin Login Form -->
                    <div class="tab-pane ${role == 'admin' ? 'active' : ''}" id="adminLogin">
                        <form method="POST" action="${pageContext.request.contextPath}/login">
                            <input type="hidden" name="role" value="admin">
                            <input type="hidden" name="_csrf" value="${csrfToken}">

                            <div class="mb-3">
                                <label class="form-label">Admin Username</label>
                                <input type="text" name="username" class="form-control" required
                                       placeholder="Admin username">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Password</label>
                                <input type="password" name="password" class="form-control" required
                                       placeholder="Admin password">
                            </div>
                            <button type="submit" class="btn btn-danger w-100">
                                <i class="bi bi-shield-check"></i> Admin Login
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
