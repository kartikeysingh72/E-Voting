<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Register - E-Voting Platform"/>
</jsp:include>

<div class="row justify-content-center">
    <div class="col-md-6">
        <c:if test="${error != null}">
            <div class="alert alert-danger alert-dismissible fade show">
                <i class="bi bi-exclamation-triangle"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="card shadow-sm">
            <div class="card-body p-4">
                <h3 class="text-center mb-4"><i class="bi bi-person-plus"></i> Voter Registration</h3>
                <p class="text-muted text-center small">Fill in your details to register as a voter. You must be 18+ years old.</p>

                <form method="POST" action="${pageContext.request.contextPath}/register">
                    <input type="hidden" name="_csrf" value="${csrfToken}">

                    <div class="mb-3">
                        <label class="form-label"><i class="bi bi-person"></i> Full Name</label>
                        <input type="text" name="name" class="form-control" required
                               placeholder="Enter your full name" value="${param.name}">
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="bi bi-envelope"></i> Email</label>
                            <input type="email" name="email" class="form-control" required
                                   placeholder="your@email.com" value="${param.email}">
                            <div class="form-text">OTP will be sent to this email for verification.</div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="bi bi-phone"></i> Phone</label>
                            <input type="tel" name="phone" class="form-control" required
                                   placeholder="+91-XXXXXXXXXX" value="${param.phone}">
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="bi bi-calendar"></i> Date of Birth</label>
                            <input type="date" name="dob" class="form-control" required value="${param.dob}">
                            <div class="form-text">Must be 18 years or older.</div>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="bi bi-card-heading"></i> Voter ID Number</label>
                            <input type="text" name="voterIdNumber" class="form-control" required
                                   placeholder="e.g., ABC1234567" value="${param.voterIdNumber}">
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="bi bi-lock"></i> Password</label>
                            <input type="password" name="password" class="form-control" required
                                   placeholder="Min 8 characters" minlength="8">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><i class="bi bi-lock-fill"></i> Confirm Password</label>
                            <input type="password" name="confirmPassword" class="form-control" required
                                   placeholder="Re-enter password">
                        </div>
                    </div>

                    <div class="form-check mb-3">
                        <input type="checkbox" class="form-check-input" id="agreeTerms" required>
                        <label class="form-check-label" for="agreeTerms">
                            I confirm the information provided is accurate and I agree to the terms of service.
                        </label>
                    </div>

                    <button type="submit" class="btn btn-primary w-100 btn-lg">
                        <i class="bi bi-person-plus"></i> Register &amp; Verify Email
                    </button>
                </form>

                <p class="text-center mt-3 mb-0">
                    <small>Already registered?
                        <a href="${pageContext.request.contextPath}/login">Login here</a>
                    </small>
                </p>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
