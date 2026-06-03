<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="WEB-INF/jsp/header.jsp">
    <jsp:param name="title" value="E-Voting Platform - Secure Digital Democracy"/>
</jsp:include>

<!-- Hero Section -->
<section class="ev-hero">
    <div class="container position-relative">
        <div class="row align-items-center">
            <div class="col-lg-7">
                <div class="hero-badge">
                    <span class="dot"></span>
                    Secure &middot; Anonymous &middot; Verifiable
                </div>
                <h1 class="mb-3">
                    Trusted Digital Voting<br>
                    <span style="color:var(--ev-blue-500)">for Every Community</span>
                </h1>
                <p class="lead mb-4">
                    A secure, transparent, and auditable e-voting platform for college elections,
                    society polls, and local body elections. Every vote counts. Every vote is verified.
                </p>
                <div class="d-flex flex-wrap gap-3">
                    <c:choose>
                        <c:when test="${sessionScope.voter != null}">
                            <a href="${pageContext.request.contextPath}/voter/vote" class="btn btn-primary btn-lg">
                                <i class="bi bi-check2-circle me-2"></i>Cast Your Vote
                            </a>
                        </c:when>
                        <c:when test="${sessionScope.admin != null}">
                            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-primary btn-lg">
                                <i class="bi bi-grid me-2"></i>Go to Dashboard
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-lg">
                                <i class="bi bi-person-plus me-2"></i>Voter Portal
                            </a>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-lg">
                                <i class="bi bi-shield-lock me-2"></i>Admin Portal
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="col-lg-5 d-none d-lg-block text-center mt-5 mt-lg-0">
                <div style="font-size:8rem; opacity:.15;"><i class="bi bi-check2-square"></i></div>
            </div>
        </div>
    </div>
</section>

<!-- Public Verify Receipt Bar -->
<section class="py-4" style="background:var(--ev-white); border-bottom:1px solid var(--ev-slate-200);">
    <div class="container">
        <div class="row align-items-center justify-content-center">
            <div class="col-lg-8">
                <div class="d-flex align-items-center gap-3 flex-wrap">
                    <div class="d-flex align-items-center gap-2 text-nowrap">
                        <i class="bi bi-shield-check text-primary fs-5"></i>
                        <span class="fw-700" style="font-size:.9rem;">Verify Your Vote</span>
                    </div>
                    <form action="${pageContext.request.contextPath}/verify-receipt" method="POST" class="d-flex flex-grow-1 gap-2">
                        <input type="hidden" name="_csrf" value="${csrfToken}">
                        <input type="text" name="receiptToken" class="form-control form-control-sm"
                               placeholder="Paste your receipt token here..." aria-label="Receipt token">
                        <button type="submit" class="btn btn-primary btn-sm text-nowrap">
                            <i class="bi bi-search me-1"></i>Verify
                        </button>
                    </form>
                    <a href="${pageContext.request.contextPath}/results" class="btn btn-outline-secondary btn-sm text-nowrap">
                        <i class="bi bi-bar-chart me-1"></i>View Results
                    </a>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Features -->
<section class="py-5">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="section-title mb-2">Why Trust E-Voting?</h2>
            <p class="text-slate" style="max-width:500px; margin:0 auto;">
                Built with enterprise-grade security to ensure every election is fair, transparent, and verifiable.
            </p>
        </div>
        <div class="row g-4">
            <div class="col-md-4">
                <div class="ev-card ev-feature h-100">
                    <div class="feature-icon" style="background:var(--ev-blue-100); color:var(--ev-blue-600);">
                        <i class="bi bi-fingerprint"></i>
                    </div>
                    <h5>Two-Factor Authentication</h5>
                    <p>Every voter login requires password + email OTP verification. No unauthorized access.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="ev-card ev-feature h-100">
                    <div class="feature-icon" style="background:var(--ev-green-100); color:var(--ev-green-600);">
                        <i class="bi bi-shield-lock"></i>
                    </div>
                    <h5>One Person, One Vote</h5>
                    <p>Database-enforced unique constraint ensures no voter can cast more than one ballot per election.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="ev-card ev-feature h-100">
                    <div class="feature-icon" style="background:var(--ev-amber-100); color:var(--ev-amber-500);">
                        <i class="bi bi-receipt"></i>
                    </div>
                    <h5>Verifiable Audit Trail</h5>
                    <p>Every vote generates a unique receipt token. Verify your vote was counted without revealing your identity.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- How It Works -->
<section class="py-5" style="background:var(--ev-white);">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="section-title mb-2">How It Works</h2>
            <p class="text-slate">Four simple steps to cast your vote securely.</p>
        </div>
        <div class="row g-4 text-center">
            <div class="col-md-3 col-6">
                <div class="mb-3">
                    <span class="d-inline-flex align-items-center justify-content-center rounded-circle fw-800"
                          style="width:48px;height:48px;background:var(--ev-blue-100);color:var(--ev-blue-600);font-size:1.1rem;">1</span>
                </div>
                <h6 class="fw-700">Register</h6>
                <p class="text-slate small">Sign up with your details and verify your email via OTP.</p>
            </div>
            <div class="col-md-3 col-6">
                <div class="mb-3">
                    <span class="d-inline-flex align-items-center justify-content-center rounded-circle fw-800"
                          style="width:48px;height:48px;background:var(--ev-blue-100);color:var(--ev-blue-600);font-size:1.1rem;">2</span>
                </div>
                <h6 class="fw-700">Get Approved</h6>
                <p class="text-slate small">Admin verifies your identity through the KYC approval workflow.</p>
            </div>
            <div class="col-md-3 col-6">
                <div class="mb-3">
                    <span class="d-inline-flex align-items-center justify-content-center rounded-circle fw-800"
                          style="width:48px;height:48px;background:var(--ev-green-100);color:var(--ev-green-600);font-size:1.1rem;">3</span>
                </div>
                <h6 class="fw-700">Cast Your Vote</h6>
                <p class="text-slate small">Login securely with OTP, select your candidate, and submit your ballot.</p>
            </div>
            <div class="col-md-3 col-6">
                <div class="mb-3">
                    <span class="d-inline-flex align-items-center justify-content-center rounded-circle fw-800"
                          style="width:48px;height:48px;background:var(--ev-green-100);color:var(--ev-green-600);font-size:1.1rem;">4</span>
                </div>
                <h6 class="fw-700">Verify Receipt</h6>
                <p class="text-slate small">Use your receipt token to confirm your vote was counted.</p>
            </div>
        </div>
    </div>
</section>

<jsp:include page="WEB-INF/jsp/footer.jsp"/>
