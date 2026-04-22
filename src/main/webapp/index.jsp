<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="WEB-INF/jsp/header.jsp">
    <jsp:param name="title" value="E-Voting Platform - Secure Digital Democracy"/>
</jsp:include>

<!-- Hero Section -->
<div class="text-center py-5 mb-4 bg-primary text-white rounded-3">
    <h1 class="display-4 fw-bold"><i class="bi bi-check2-square"></i> E-Voting Platform</h1>
    <p class="lead">Secure, transparent, and accessible digital voting for everyone.</p>
    <c:if test="${sessionScope.voter == null && sessionScope.admin == null}">
        <a href="${pageContext.request.contextPath}/register" class="btn btn-light btn-lg me-2 mt-3">
            <i class="bi bi-person-plus"></i> Register to Vote
        </a>
        <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-lg mt-3">
            <i class="bi bi-box-arrow-in-right"></i> Login
        </a>
    </c:if>
</div>

<!-- Features -->
<div class="row g-4 mb-5">
    <div class="col-md-4">
        <div class="card h-100 border-0 shadow-sm">
            <div class="card-body text-center">
                <i class="bi bi-shield-lock text-primary" style="font-size: 3rem;"></i>
                <h5 class="card-title mt-3">Secure Voting</h5>
                <p class="card-text text-muted">BCrypt password hashing, Email OTP verification, and CSRF protection ensure your vote is safe.</p>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card h-100 border-0 shadow-sm">
            <div class="card-body text-center">
                <i class="bi bi-fingerprint text-success" style="font-size: 3rem;"></i>
                <h5 class="card-title mt-3">One Person, One Vote</h5>
                <p class="card-text text-muted">Database-enforced unique constraints prevent double voting. Every vote counts exactly once.</p>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card h-100 border-0 shadow-sm">
            <div class="card-body text-center">
                <i class="bi bi-receipt-cutoff text-warning" style="font-size: 3rem;"></i>
                <h5 class="card-title mt-3">Verifiable Receipt</h5>
                <p class="card-text text-muted">Get a unique receipt token after voting. Verify your vote was counted using our receipt checker.</p>
            </div>
        </div>
    </div>
</div>

<!-- How It Works -->
<div class="bg-light rounded-3 p-4 mb-5">
    <h3 class="text-center mb-4"><i class="bi bi-list-check"></i> How It Works</h3>
    <div class="row text-center">
        <div class="col-md-3">
            <div class="bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-2" style="width:50px;height:50px;font-size:1.5rem;font-weight:bold;">1</div>
            <h6>Register</h6>
            <p class="small text-muted">Sign up with your details and verify your email via OTP.</p>
        </div>
        <div class="col-md-3">
            <div class="bg-success text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-2" style="width:50px;height:50px;font-size:1.5rem;font-weight:bold;">2</div>
            <h6>Get Approved</h6>
            <p class="small text-muted">Admin reviews and approves your voter registration.</p>
        </div>
        <div class="col-md-3">
            <div class="bg-warning text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-2" style="width:50px;height:50px;font-size:1.5rem;font-weight:bold;">3</div>
            <h6>Cast Vote</h6>
            <p class="small text-muted">Login with OTP, select your candidate, and submit your vote.</p>
        </div>
        <div class="col-md-3">
            <div class="bg-info text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-2" style="width:50px;height:50px;font-size:1.5rem;font-weight:bold;">4</div>
            <h6>Get Receipt</h6>
            <p class="small text-muted">Receive a unique token to verify your vote was counted.</p>
        </div>
    </div>
</div>

<!-- Quick Links -->
<div class="row g-3">
    <div class="col-md-6">
        <a href="${pageContext.request.contextPath}/results" class="text-decoration-none">
            <div class="card border-primary h-100">
                <div class="card-body text-center">
                    <i class="bi bi-bar-chart-line text-primary" style="font-size: 2rem;"></i>
                    <h5 class="mt-2">View Results</h5>
                    <p class="text-muted mb-0">See election results for completed polls</p>
                </div>
            </div>
        </a>
    </div>
    <div class="col-md-6">
        <a href="${pageContext.request.contextPath}/verify-receipt" class="text-decoration-none">
            <div class="card border-success h-100">
                <div class="card-body text-center">
                    <i class="bi bi-search text-success" style="font-size: 2rem;"></i>
                    <h5 class="mt-2">Verify Your Vote</h5>
                    <p class="text-muted mb-0">Enter your receipt token to confirm your vote</p>
                </div>
            </div>
        </a>
    </div>
</div>

<jsp:include page="WEB-INF/jsp/footer.jsp"/>
