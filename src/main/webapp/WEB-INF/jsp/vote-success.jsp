<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Vote Cast Successfully - E-Voting Platform"/>
</jsp:include>

<div class="row justify-content-center">
    <div class="col-md-6">
        <c:if test="${success == true}">
            <div class="card shadow-sm border-success">
                <div class="card-body p-4 text-center">
                    <i class="bi bi-check-circle-fill text-success" style="font-size: 4rem;"></i>
                    <h2 class="mt-3 text-success">Vote Cast Successfully!</h2>
                    <p class="text-muted">Your vote has been recorded for the election:</p>
                    <h5 class="text-primary">${electionTitle}</h5>

                    <div class="bg-light rounded p-3 my-3">
                        <p class="mb-1">Your vote receipt token:</p>
                        <div class="bg-white border rounded p-3 mb-2">
                            <code class="fs-5 text-dark">${receiptToken}</code>
                        </div>
                        <p class="small text-danger mb-0">
                            <i class="bi bi-exclamation-triangle"></i>
                            <strong>Save this token!</strong> You can use it to verify your vote was counted.
                        </p>
                    </div>

                    <button onclick="navigator.clipboard.writeText('${receiptToken}').then(() => alert('Copied!'))"
                            class="btn btn-outline-primary btn-sm mb-3">
                        <i class="bi bi-clipboard"></i> Copy Receipt Token
                    </button>

                    <div class="d-flex justify-content-center gap-3">
                        <a href="${pageContext.request.contextPath}/verify-receipt" class="btn btn-primary">
                            <i class="bi bi-search"></i> Verify Receipt
                        </a>
                        <a href="${pageContext.request.contextPath}/results" class="btn btn-outline-secondary">
                            <i class="bi bi-bar-chart"></i> View Results
                        </a>
                    </div>
                </div>
            </div>
        </c:if>

        <c:if test="${success != true}">
            <div class="card shadow-sm">
                <div class="card-body text-center">
                    <i class="bi bi-exclamation-triangle text-warning" style="font-size: 3rem;"></i>
                    <h4 class="mt-3">Something went wrong</h4>
                    <p class="text-muted">Your vote may not have been recorded. Please try again.</p>
                    <a href="${pageContext.request.contextPath}/voter/vote" class="btn btn-primary">
                        <i class="bi bi-arrow-left"></i> Back to Ballot
                    </a>
                </div>
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="footer.jsp"/>
