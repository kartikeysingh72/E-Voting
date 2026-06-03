<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Verify OTP - E-Voting Platform"/>
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-5 col-md-6">

            <c:if test="${error != null}">
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="bi bi-exclamation-circle me-2"></i>${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <div class="ev-card">
                <div class="card-body p-4 p-md-5 text-center">
                    <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                         style="width:56px;height:56px;background:var(--ev-blue-100);color:var(--ev-blue-600);">
                        <i class="bi bi-envelope-paper fs-4"></i>
                    </div>
                    <h3 class="fw-800 text-navy mb-1">Verify Your Identity</h3>
                    <p class="text-slate small mb-4">
                        We've sent a 6-digit code to<br>
                        <strong class="text-navy">${email != null ? email : 'your email'}</strong>
                    </p>

                    <form method="POST" action="${pageContext.request.contextPath}/otp" id="otpForm">
                        <input type="hidden" name="_csrf" value="${csrfToken}">
                        <input type="hidden" name="purpose" value="${purpose}">
                        <input type="hidden" name="otpCode" id="otpHidden">

                        <div class="ev-otp-group mb-4" id="otpInputs">
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-digit" aria-label="Digit 1" autofocus>
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-digit" aria-label="Digit 2">
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-digit" aria-label="Digit 3">
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-digit" aria-label="Digit 4">
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-digit" aria-label="Digit 5">
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-digit" aria-label="Digit 6">
                        </div>

                        <button type="submit" class="btn btn-primary btn-lg w-100 mb-3" id="verifyBtn">
                            <i class="bi bi-check-circle me-2"></i>Verify OTP
                        </button>
                    </form>

                    <div class="d-flex align-items-center justify-content-center gap-2">
                        <span class="text-slate small" id="countdownText">Resend available in</span>
                        <span class="badge bg-secondary" id="countdownTimer">02:00</span>
                    </div>
                    <a href="#" id="resendLink" class="small fw-600 d-none mt-2"
                       onclick="resendOTP(); return false;">
                        <i class="bi bi-arrow-clockwise me-1"></i>Resend OTP
                    </a>
                </div>
            </div>

            <c:if test="${otpSent != null && !otpSent}">
                <div class="alert alert-warning mt-3 text-center small">
                    <i class="bi bi-info-circle me-1"></i>Email could not be sent. Check your OTP in the database or contact admin.
                </div>
            </c:if>
        </div>
    </div>
</div>

<script>
// OTP digit input behavior
const digits = document.querySelectorAll('.otp-digit');
digits.forEach((input, i) => {
    input.addEventListener('input', function() {
        this.value = this.value.replace(/[^0-9]/g, '');
        if (this.value && i < digits.length - 1) digits[i + 1].focus();
        updateHidden();
    });
    input.addEventListener('keydown', function(e) {
        if (e.key === 'Backspace' && !this.value && i > 0) { digits[i - 1].focus(); }
    });
    input.addEventListener('paste', function(e) {
        e.preventDefault();
        const paste = (e.clipboardData || window.clipboardData).getData('text').replace(/[^0-9]/g, '');
        for (let j = 0; j < Math.min(paste.length, digits.length); j++) {
            digits[j].value = paste[j];
        }
        updateHidden();
        if (paste.length >= digits.length) digits[digits.length - 1].focus();
    });
});

function updateHidden() {
    let code = '';
    digits.forEach(d => code += d.value);
    document.getElementById('otpHidden').value = code;
}

// Countdown timer
let seconds = 120;
const timerEl = document.getElementById('countdownTimer');
const textEl = document.getElementById('countdownText');
const linkEl = document.getElementById('resendLink');
const timer = setInterval(() => {
    seconds--;
    const m = String(Math.floor(seconds / 60)).padStart(2, '0');
    const s = String(seconds % 60).padStart(2, '0');
    timerEl.textContent = m + ':' + s;
    if (seconds <= 0) {
        clearInterval(timer);
        textEl.textContent = '';
        timerEl.classList.add('d-none');
        linkEl.classList.remove('d-none');
    }
}, 1000);

function resendOTP() {
    window.location.href = '${pageContext.request.contextPath}/otp?action=send&email=${email}&purpose=${purpose}';
}
</script>

<jsp:include page="footer.jsp"/>
