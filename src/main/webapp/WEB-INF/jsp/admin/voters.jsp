<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../header.jsp">
    <jsp:param name="title" value="Voter Approvals - Admin"/>
</jsp:include>

<div class="ev-sidebar" id="adminSidebar">
    <div class="sidebar-heading">Main</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-link"><i class="bi bi-grid-1x2"></i>Dashboard</a>
    <a href="${pageContext.request.contextPath}/admin/elections" class="sidebar-link"><i class="bi bi-calendar-event"></i>Elections</a>
    <a href="${pageContext.request.contextPath}/admin/candidates" class="sidebar-link"><i class="bi bi-person-vcard"></i>Candidates</a>
    <div class="sidebar-heading">Management</div>
    <a href="${pageContext.request.contextPath}/admin/voters" class="sidebar-link active"><i class="bi bi-people"></i>Voter Approvals</a>
    <a href="${pageContext.request.contextPath}/admin/results" class="sidebar-link"><i class="bi bi-bar-chart-fill"></i>Results</a>
</div>
<button class="btn btn-outline-secondary d-lg-none position-fixed" style="top:68px;left:8px;z-index:101;"
        onclick="document.getElementById('adminSidebar').classList.toggle('show')"><i class="bi bi-list"></i></button>

<div class="ev-main">
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h2 class="fw-800 text-navy mb-0">Voter Approvals</h2>
            <p class="text-slate small mb-0">Review and manage voter registration requests.</p>
        </div>
    </div>

    <c:if test="${error != null}">
        <div class="alert alert-danger"><i class="bi bi-exclamation-circle me-2"></i>${error}</div>
    </c:if>
    <c:if test="${success != null}">
        <div class="alert alert-success"><i class="bi bi-check-circle me-2"></i>${success}</div>
    </c:if>

    <!-- Bypass Token Modal -->
    <c:if test="${bypassToken != null}">
        <div class="alert alert-info border">
            <h6 class="fw-700 mb-2"><i class="bi bi-key me-1"></i>Bypass Token Issued (Voter #${bypassVoterId})</h6>
            <div class="d-flex align-items-center gap-2">
                <code class="flex-grow-1 bg-light p-2 rounded" id="bypassTokenText" style="font-size:.85rem;">${bypassToken}</code>
                <button class="btn btn-sm btn-primary" onclick="copyBypassToken()">
                    <i class="bi bi-clipboard me-1"></i>Copy
                </button>
            </div>
            <p class="text-muted small mt-2 mb-0">Share this token with the voter. It can only be used once.</p>
        </div>
    </c:if>

    <!-- Status Filter -->
    <div class="d-flex gap-2 mb-3 flex-wrap">
        <a href="${pageContext.request.contextPath}/admin/voters" class="btn btn-sm ${status == null ? 'btn-primary' : 'btn-outline-secondary'}">All</a>
        <a href="${pageContext.request.contextPath}/admin/voters?status=PENDING" class="btn btn-sm ${status == 'PENDING' ? 'btn-warning' : 'btn-outline-secondary'}">Pending</a>
        <a href="${pageContext.request.contextPath}/admin/voters?status=APPROVED" class="btn btn-sm ${status == 'APPROVED' ? 'btn-success' : 'btn-outline-secondary'}">Approved</a>
        <a href="${pageContext.request.contextPath}/admin/voters?status=REJECTED" class="btn btn-sm ${status == 'REJECTED' ? 'btn-danger' : 'btn-outline-secondary'}">Rejected</a>
    </div>

    <div class="ev-card">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table ev-table mb-0">
                    <thead>
                        <tr>
                            <th>Voter</th><th>Email</th><th>Phone</th><th>DOB</th>
                            <th>P ID</th><th>Face</th><th>Failures</th><th>Status</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty voters}">
                                <tr><td colspan="9" class="text-center py-4 text-slate">No voters found.</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="voter" items="${voters}">
                                    <tr>
                                        <td><strong>${voter.name}</strong></td>
                                        <td><small>${voter.email}</small></td>
                                        <td><small>${voter.phone}</small></td>
                                        <td><small>${voter.dob}</small></td>
                                        <td><code style="font-size:.75rem;">${voter.pidNumber}</code></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${faceStatusMap[voter.voterId]}">
                                                    <span class="badge bg-success"><i class="bi bi-check-lg"></i> Yes</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary"><i class="bi bi-x-lg"></i> No</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:set var="failCount" value="${failureCountMap[voter.voterId]}"/>
                                            <c:choose>
                                                <c:when test="${failCount > 0}">
                                                    <span class="badge bg-warning text-dark">${failCount} (24h)</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-slate small">0</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge ${voter.status == 'APPROVED' ? 'bg-success' : voter.status == 'REJECTED' ? 'bg-danger' : 'bg-warning'}">
                                                ${voter.status}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="d-flex gap-1 flex-wrap">
                                                <c:if test="${voter.status == 'PENDING' && voter.verified}">
                                                    <form method="POST" action="${pageContext.request.contextPath}/admin/voters" class="d-inline">
                                                        <input type="hidden" name="_csrf" value="${csrfToken}">
                                                        <input type="hidden" name="voterId" value="${voter.voterId}">
                                                        <input type="hidden" name="action" value="approve">
                                                        <button type="submit" class="btn btn-success btn-sm">
                                                            <i class="bi bi-check-lg me-1"></i>Approve
                                                        </button>
                                                    </form>
                                                    <form method="POST" action="${pageContext.request.contextPath}/admin/voters" class="d-inline">
                                                        <input type="hidden" name="_csrf" value="${csrfToken}">
                                                        <input type="hidden" name="voterId" value="${voter.voterId}">
                                                        <input type="hidden" name="action" value="reject">
                                                        <button type="submit" class="btn btn-danger btn-sm">
                                                            <i class="bi bi-x-lg me-1"></i>Reject
                                                        </button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${voter.status == 'PENDING' && !voter.verified}">
                                                    <span class="text-slate small">Email not verified</span>
                                                </c:if>
                                                <c:if test="${voter.status == 'APPROVED' && faceStatusMap[voter.voterId]}">
                                                    <form method="POST" action="${pageContext.request.contextPath}/admin/voters" class="d-inline">
                                                        <input type="hidden" name="_csrf" value="${csrfToken}">
                                                        <input type="hidden" name="voterId" value="${voter.voterId}">
                                                        <input type="hidden" name="action" value="issueBypass">
                                                        <button type="submit" class="btn btn-outline-primary btn-sm"
                                                                title="Issue one-time bypass token for face verification">
                                                            <i class="bi bi-key me-1"></i>Bypass
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
function copyBypassToken() {
    var text = document.getElementById('bypassTokenText').textContent;
    navigator.clipboard.writeText(text).then(function() {
        alert('Bypass token copied to clipboard!');
    });
}
</script>

<jsp:include page="../footer.jsp"/>
