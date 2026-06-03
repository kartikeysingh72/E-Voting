<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Login - E-Voting Platform"/>
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-5 col-md-7">

            <c:if test="${error != null}">
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="bi bi-exclamation-circle me-2"></i>${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${success != null}">
                <div class="alert alert-success">
                    <i class="bi bi-check-circle me-2"></i>${success}
                </div>
            </c:if>

            <div class="ev-card">
                <div class="card-body p-4 p-md-5">
                    <div class="text-center mb-4">
                        <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                             style="width:56px;height:56px;background:var(--ev-blue-100);color:var(--ev-blue-600);">
                            <i class="bi bi-box-arrow-in-right fs-4"></i>
                        </div>
                        <h3 class="fw-800 text-navy mb-1">Welcome Back</h3>
                        <p class="text-slate small mb-0">Sign in to access the platform.</p>
                    </div>

                    <!-- Tabs -->
                    <ul class="nav nav-pills nav-fill mb-4 gap-2" role="tablist"
                        style="background:var(--ev-slate-100); border-radius:var(--ev-radius-sm); padding:4px;">
                        <li class="nav-item">
                            <button class="nav-link ${role != 'admin' ? 'active' : ''} rounded-3"
                                    data-bs-toggle="pill" data-bs-target="#voterLogin" type="button" role="tab">
                                <i class="bi bi-person me-1"></i>Voter Login
                            </button>
                        </li>
                        <li class="nav-item">
                            <button class="nav-link ${role == 'admin' ? 'active' : ''} rounded-3"
                                    data-bs-toggle="pill" data-bs-target="#adminLogin" type="button" role="tab">
                                <i class="bi bi-shield-lock me-1"></i>Admin Login
                            </button>
                        </li>
                    </ul>

                    <div class="tab-content">
                        <!-- Voter Login Tab -->
                        <div class="tab-pane ${role != 'admin' ? 'show active' : ''}" id="voterLogin">
                            <form method="POST" action="${pageContext.request.contextPath}/login">
                                <input type="hidden" name="role" value="voter">
                                <input type="hidden" name="_csrf" value="${csrfToken}">

                                <div class="mb-3">
                                    <label class="form-label">Email Address</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                        <input type="email" name="email" class="form-control" required
                                               placeholder="your@email.com" value="${param.email}">
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label class="form-label">Password</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                        <input type="password" name="password" class="form-control" required
                                               placeholder="Enter your password">
                                    </div>
                                    <div class="form-text">
                                        <i class="bi bi-info-circle me-1"></i>OTP verification required after login.
                                    </div>
                                </div>

                                <button type="submit" class="btn btn-primary w-100 btn-lg">
                                    <i class="bi bi-arrow-right-circle me-2"></i>Continue to OTP
                                </button>
                            </form>
                        </div>

                        <!-- Admin Login Tab -->
                        <div class="tab-pane ${role == 'admin' ? 'show active' : ''}" id="adminLogin">
                            <form method="POST" action="${pageContext.request.contextPath}/login">
                                <input type="hidden" name="role" value="admin">
                                <input type="hidden" name="_csrf" value="${csrfToken}">

                                <div class="mb-3">
                                    <label class="form-label">Admin Username</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-person-badge"></i></span>
                                        <input type="text" name="username" class="form-control" required
                                               placeholder="Admin username" value="${param.username}">
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label class="form-label">Password</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                        <input type="password" name="password" class="form-control" required
                                               placeholder="Admin password">
                                    </div>
                                </div>

                                <button type="submit" class="btn btn-danger w-100 btn-lg">
                                    <i class="bi bi-shield-lock me-2"></i>Admin Login
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <p class="text-center mt-4 mb-0">
                <span class="text-slate small">Don't have an account?</span>
                <a href="${pageContext.request.contextPath}/register" class="fw-600 ms-1">Register here</a>
            </p>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
