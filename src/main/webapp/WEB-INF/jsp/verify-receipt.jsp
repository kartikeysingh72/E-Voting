<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Verify Receipt - E-Voting Platform"/>
</jsp:include>

<div class="row justify-content-center">
    <div class="col-md-6">
        <h2 class="text-center mb-4"><i class="bi bi-receipt"></i> Verify Vote Receipt</h2>

        <c:if test="${error != null}">
            <div class="alert alert-danger alert-dismissible fade show">
                <i class="bi bi-exclamation-triangle"></i> ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- Search Form -->
        <div class="card shadow-sm mb-4">
            <div class="card-body">
                <p class="text-muted">Enter the receipt token you received after casting your vote to verify it was counted.</p>
                <form method="POST" action="${pageContext.request.contextPath}/verify-receipt">
                    <input type="hidden" name="_csrf" value="${csrfToken}">
                    <div class="input-group">
                        <input type="text" name="receiptToken" class="form-control" required
                               placeholder="Enter your receipt token (e.g., EV-1-A1B2C3...)"
                               value="${param.receiptToken}">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-search"></i> Verify
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Verification Result -->
        <c:if test="${verified == true}">
            <div class="card shadow-sm border-success">
                <div class="card-body text-center">
                    <i class="bi bi-check-circle-fill text-success" style="font-size: 3rem;"></i>
                    <h4 class="text-success mt-2">Vote Verified!</h4>
                    <p class="text-muted">Your vote has been counted and recorded.</p>

                    <div class="bg-light rounded p-3 text-start">
                        <table class="table table-sm mb-0">
                            <tr><td class="fw-bold">Election:</td><td>${vote.electionTitle}</td></tr>
                            <tr><td class="fw-bold">Candidate:</td><td>${vote.candidateName}</td></tr>
                            <tr><td class="fw-bold">Timestamp:</td><td>${vote.timestamp}</td></tr>
                            <tr><td class="fw-bold">Receipt:</td><td><code>${vote.receiptToken}</code></td></tr>
                        </table>
                    </div>
                </div>
            </div>
        </c:if>

        <c:if test="${verified == false}">
            <div class="card shadow-sm border-danger">
                <div class="card-body text-center">
                    <i class="bi bi-x-circle-fill text-danger" style="font-size: 3rem;"></i>
                    <h4 class="text-danger mt-2">Receipt Not Found</h4>
                    <p class="text-muted">No vote was found with this receipt token. Please check the token and try again.</p>
                </div>
            </div>
        </c:if>
    </div>
</div>

<jsp:include page="footer.jsp"/>
