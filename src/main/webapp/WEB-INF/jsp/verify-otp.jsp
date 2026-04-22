<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Verify OTP - E-Voting Platform"/>
</jsp:include>

<div class="row justify-content-center">
    <div class="col-md-5">
        <c:if test="${error != null}">
            <div class="alert alert-danger alert-dismissible fade show">
                <i class="bi bi-exclamation-triangle"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="card shadow-sm">
            <div class="card-body p-4 text-center">
                <i class="bi bi-envelope-check text-primary" style="font-size: 3rem;"></i>
                <h3 class="mt-3">Verify OTP</h3>
                <p class="text-muted">
                    Enter the 6-digit OTP sent to<br>
                    <strong>${email}</strong>
                </p>

                <form method="POST" action="${pageContext.request.contextPath}/otp">
                    <input type="hidden" name="_csrf" value="${csrfToken}">
                    <input type="hidden" name="purpose" value="${purpose}">

                    <div class="mb-4">
                        <input type="text" name="otpCode" class="form-control form-control-lg text-center"
                               maxlength="6" pattern="[0-9]{6}" required autofocus
                               placeholder="Enter 6-digit OTP"
                               style="letter-spacing: 10px; font-size: 1.5rem;">
                    </div>

                    <button type="submit" class="btn btn-primary btn-lg w-100 mb-3">
                        <i class="bi bi-check-circle"></i> Verify OTP
                    </button>
                </form>

                <div class="d-flex justify-content-between">
                    <a href="${pageContext.request.contextPath}/otp?action=send&email=${email}&purpose=${purpose}"
                       class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-arrow-repeat"></i> Resend OTP
                    </a>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-secondary btn-sm">
                        <i class="bi bi-arrow-left"></i> Back to Login
                    </a>
                </div>

                <div class="alert alert-info mt-3 small">
                    <i class="bi bi-info-circle"></i> OTP is valid for 10 minutes. Check your spam folder if you don't see the email.
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
