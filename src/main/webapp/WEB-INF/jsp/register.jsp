<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Register - E-Voting Platform"/>
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-6 col-md-8">

            <c:if test="${error != null}">
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="bi bi-exclamation-circle me-2"></i>${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- Card -->
            <div class="ev-card">
                <div class="card-body p-4 p-md-5">
                    <div class="text-center mb-4">
                        <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                             style="width:56px;height:56px;background:var(--ev-blue-100);color:var(--ev-blue-600);">
                            <i class="bi bi-person-plus fs-4"></i>
                        </div>
                        <h3 class="fw-800 text-navy mb-1">Create Voter Account</h3>
                        <p class="text-slate small mb-0">You must be 18 years or older to register.</p>
                        <p class="text-slate small mb-0 mt-1">
                            <i class="bi bi-camera-video me-1"></i>A face capture step will follow after form submission.
                        </p>
                    </div>

                    <form method="POST" action="${pageContext.request.contextPath}/register" novalidate>
                        <input type="hidden" name="_csrf" value="${csrfToken}">

                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-person me-1"></i>Full Name</label>
                            <input type="text" name="name" class="form-control" required
                                   placeholder="Enter your full name" value="${param.name}"
                                   aria-describedby="nameHelp">
                        </div>

                        <div class="row g-3">
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><i class="bi bi-envelope me-1"></i>Email</label>
                                <input type="email" name="email" class="form-control" required
                                       placeholder="e.g., yourid@shiats.edu.in" value="${param.email}">
                                <div class="form-text">Must be a university email (@shiats.edu.in). OTP will be sent here.</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><i class="bi bi-phone me-1"></i>Phone</label>
                                <input type="tel" name="phone" class="form-control" required
                                       placeholder="+91-XXXXXXXXXX" value="${param.phone}">
                            </div>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">
                                    <i class="bi bi-calendar me-1"></i>Date of Birth
                                    <span class="badge bg-info ms-1" id="ageBadge">18+ required</span>
                                </label>
                                <input type="date" name="dob" class="form-control" required value="${param.dob}"
                                       id="dobInput" max="" aria-describedby="dobHelp">
                                <div class="form-text" id="dobHelp"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><i class="bi bi-card-heading me-1"></i>P ID Number</label>
                                <input type="text" name="pidNumber" class="form-control" required
                                       placeholder="e.g., P1234567" value="${param.pidNumber}">
                            </div>
                        </div>

                        <div class="row g-3">
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><i class="bi bi-lock me-1"></i>Password</label>
                                <input type="password" name="password" class="form-control" required
                                       placeholder="Min 8 characters" minlength="8" id="pwdInput">
                                <div class="form-text" id="pwdStrength"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><i class="bi bi-lock-fill me-1"></i>Confirm Password</label>
                                <input type="password" name="confirmPassword" class="form-control" required
                                       placeholder="Re-enter password" id="pwdConfirm">
                            </div>
                        </div>

                        <div class="form-check mb-4">
                            <input type="checkbox" class="form-check-input" id="agreeTerms" required>
                            <label class="form-check-label small" for="agreeTerms">
                                I confirm the information provided is accurate and I agree to the terms of service.
                            </label>
                        </div>

                        <button type="submit" class="btn btn-primary w-100 btn-lg">
                            <i class="bi bi-person-plus me-2"></i>Register &amp; Capture Face
                        </button>
                    </form>
                </div>
            </div>

            <p class="text-center mt-4 mb-0">
                <span class="text-slate small">Already registered?</span>
                <a href="${pageContext.request.contextPath}/login" class="fw-600 ms-1">Login here</a>
            </p>
        </div>
    </div>
</div>

<script>
// Age calculation
document.getElementById('dobInput').addEventListener('change', function() {
    const dob = new Date(this.value);
    const today = new Date();
    let age = today.getFullYear() - dob.getFullYear();
    const m = today.getMonth() - dob.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) age--;
    const badge = document.getElementById('ageBadge');
    const help = document.getElementById('dobHelp');
    if (age >= 18) {
        badge.className = 'badge bg-success ms-1';
        badge.textContent = 'Age: ' + age + ' ✓';
        help.textContent = '';
    } else {
        badge.className = 'badge bg-danger ms-1';
        badge.textContent = 'Age: ' + age + ' (Under 18)';
        help.textContent = 'You must be at least 18 years old.';
        help.className = 'form-text text-danger';
    }
});

// Password strength indicator
document.getElementById('pwdInput').addEventListener('input', function() {
    const v = this.value;
    const el = document.getElementById('pwdStrength');
    if (v.length === 0) { el.textContent = ''; return; }
    if (v.length < 8) { el.innerHTML = '<span class="text-danger">Too short (min 8 chars)</span>'; }
    else if (v.length >= 12 && /[A-Z]/.test(v) && /[0-9]/.test(v)) { el.innerHTML = '<span class="text-success">Strong password</span>'; }
    else { el.innerHTML = '<span class="text-warning">Acceptable password</span>'; }
});
</script>

<jsp:include page="footer.jsp"/>
