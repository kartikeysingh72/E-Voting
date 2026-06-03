<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Vote Successful - E-Voting Platform"/>
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-6 col-md-8">

            <!-- Success Alert -->
            <div class="ev-card mb-4">
                <div class="card-body text-center p-5">
                    <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                         style="width:72px;height:72px;background:var(--ev-green-100);color:var(--ev-green-600);">
                        <i class="bi bi-check-circle-fill" style="font-size:2.5rem;"></i>
                    </div>
                    <h2 class="fw-800 text-navy mb-2">Vote Recorded Successfully</h2>
                    <p class="text-slate mb-4">
                        Your ballot for <strong class="text-navy">${electionTitle}</strong> has been securely recorded.
                    </p>
                    <p class="small text-slate mb-0">
                        You voted for: <strong class="text-navy">${candidateName}</strong>
                    </p>
                </div>
            </div>

            <!-- Receipt Token Card -->
            <div class="ev-card">
                <div class="card-header d-flex align-items-center gap-2">
                    <i class="bi bi-receipt text-primary"></i>
                    Your Audit Receipt Token
                </div>
                <div class="card-body">
                    <p class="text-slate small mb-3">
                        Save this token securely. It is your <strong>only anonymous proof</strong> that your vote was counted.
                        No voter identity is tied to this token.
                    </p>
                    <div class="ev-receipt-box mb-3" id="receiptBox">${receiptToken}</div>
                    <div class="d-flex gap-2">
                        <button class="btn btn-primary flex-grow-1" onclick="copyToken()">
                            <i class="bi bi-clipboard me-2" id="copyIcon"></i><span id="copyText">Copy to Clipboard</span>
                        </button>
                        <a href="${pageContext.request.contextPath}/verify-receipt" class="btn btn-outline-secondary">
                            <i class="bi bi-shield-check me-1"></i>Verify Now
                        </a>
                    </div>
                </div>
            </div>

            <!-- Info Card -->
            <div class="alert alert-info mt-4">
                <i class="bi bi-info-circle me-2"></i>
                <strong>What is this token?</strong> This unique 64-character code anonymously proves your vote was counted.
                You can verify it anytime at the <a href="${pageContext.request.contextPath}/verify-receipt">receipt verification page</a>.
            </div>

            <div class="text-center mt-4">
                <a href="${pageContext.request.contextPath}/" class="btn btn-outline-secondary">
                    <i class="bi bi-house me-1"></i>Return Home
                </a>
            </div>
        </div>
    </div>
</div>

<script>
function copyToken() {
    const token = document.getElementById('receiptBox').textContent.trim();
    navigator.clipboard.writeText(token).then(() => {
        document.getElementById('copyIcon').className = 'bi bi-check2 me-2';
        document.getElementById('copyText').textContent = 'Copied!';
        setTimeout(() => {
            document.getElementById('copyIcon').className = 'bi bi-clipboard me-2';
            document.getElementById('copyText').textContent = 'Copy to Clipboard';
        }, 2000);
    });
}
</script>

<jsp:include page="footer.jsp"/>
