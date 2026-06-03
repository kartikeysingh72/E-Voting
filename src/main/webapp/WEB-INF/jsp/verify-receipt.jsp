<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Verify Receipt - E-Voting Platform"/>
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-6 col-md-8">
            <div class="text-center mb-4">
                <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                     style="width:56px;height:56px;background:var(--ev-blue-100);color:var(--ev-blue-600);">
                    <i class="bi bi-shield-check fs-4"></i>
                </div>
                <h2 class="fw-800 text-navy mb-1">Verify Your Vote</h2>
                <p class="text-slate small">Enter your receipt token to confirm your vote was counted.</p>
            </div>

            <div class="ev-card mb-4">
                <div class="card-body p-4">
                    <form method="POST" action="${pageContext.request.contextPath}/verify-receipt">
                        <input type="hidden" name="_csrf" value="${csrfToken}">
                        <div class="mb-3">
                            <label class="form-label">Receipt Token</label>
                            <input type="text" name="receiptToken" class="form-control" required
                                   placeholder="Paste your receipt token..."
                                   value="${param.receiptToken}" style="font-family:monospace; font-size:.85rem;">
                        </div>
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-search me-2"></i>Verify Token
                        </button>
                    </form>
                </div>
            </div>

            <c:if test="${vote != null}">
                <div class="ev-certificate mb-4">
                    <div class="d-flex align-items-center gap-2 mb-4">
                        <i class="bi bi-patch-check-fill" style="font-size:1.5rem;"></i>
                        <div>
                            <div class="fw-700" style="font-size:1.1rem;">Vote Verified</div>
                            <div style="font-size:.75rem; color:var(--ev-slate-400);">This receipt is valid and was recorded in the system.</div>
                        </div>
                    </div>
                    <div class="row g-3">
                        <div class="col-sm-6">
                            <div class="cert-label">Election</div>
                            <div class="cert-value">${vote.electionTitle}</div>
                        </div>
                        <div class="col-sm-6">
                            <div class="cert-label">Candidate</div>
                            <div class="cert-value">${vote.candidateName}</div>
                        </div>
                        <div class="col-12">
                            <div class="cert-label">Timestamp</div>
                            <div class="cert-value">${vote.timestamp}</div>
                        </div>
                    </div>
                </div>
                <div class="alert alert-info small">
                    <i class="bi bi-shield-lock me-1"></i>
                    <strong>Privacy Notice:</strong> No voter identification data is stored or tied to this record.
                    This token only confirms that a valid vote was cast in the specified election.
                </div>
            </c:if>

            <c:if test="${error != null}">
                <div class="alert alert-danger">
                    <i class="bi bi-x-circle me-2"></i>${error}
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
