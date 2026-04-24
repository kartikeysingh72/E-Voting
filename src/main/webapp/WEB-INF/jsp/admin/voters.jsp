<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../header.jsp">
    <jsp:param name="title" value="Voter Approval - Admin"/>
</jsp:include>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-person-check"></i> Voter Approval</h2>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Dashboard
    </a>
</div>

<c:if test="${success != null}"><div class="alert alert-success">${success}</div></c:if>
<c:if test="${error != null}"><div class="alert alert-danger">${error}</div></c:if>

<!-- Status Filter -->
<div class="mb-3">
    <a href="${pageContext.request.contextPath}/admin/voters" class="btn btn-sm ${selectedStatus == null ? 'btn-primary' : 'btn-outline-primary'}">All</a>
    <a href="${pageContext.request.contextPath}/admin/voters?status=PENDING" class="btn btn-sm ${selectedStatus == 'PENDING' ? 'btn-warning' : 'btn-outline-warning'}">Pending</a>
    <a href="${pageContext.request.contextPath}/admin/voters?status=APPROVED" class="btn btn-sm ${selectedStatus == 'APPROVED' ? 'btn-success' : 'btn-outline-success'}">Approved</a>
    <a href="${pageContext.request.contextPath}/admin/voters?status=REJECTED" class="btn btn-sm ${selectedStatus == 'REJECTED' ? 'btn-danger' : 'btn-outline-danger'}">Rejected</a>
</div>

<div class="card shadow-sm">
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr>
                        <th>#</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>DOB</th>
                        <th>Voter ID</th>
                        <th>Email Verified</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="voter" items="${voters}" varStatus="status">
                        <tr>
                            <td>${status.count}</td>
                            <td>${voter.name}</td>
                            <td><small>${voter.email}</small></td>
                            <td><small>${voter.phone}</small></td>
                            <td><small>${voter.dob}</small></td>
                            <td><small>${voter.voterIdNumber}</small></td>
                            <td>
                                <c:choose>
                                    <c:when test="${voter.verified}">
                                        <span class="badge bg-success">Yes</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary">No</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="badge bg-${voter.status == 'APPROVED' ? 'success' : voter.status == 'REJECTED' ? 'danger' : 'warning'}">
                                    ${voter.status}
                                </span>
                            </td>
                            <td>
                                <c:if test="${voter.status == 'PENDING' && voter.verified}">
                                    <form method="POST" action="${pageContext.request.contextPath}/admin/voters" class="d-inline">
                                        <input type="hidden" name="_csrf" value="${csrfToken}">
                                        <input type="hidden" name="voterId" value="${voter.voterId}">
                                        <input type="hidden" name="action" value="approve">
                                        <button type="submit" class="btn btn-success btn-sm" title="Approve">
                                            <i class="bi bi-check-lg"></i>
                                        </button>
                                    </form>
                                    <form method="POST" action="${pageContext.request.contextPath}/admin/voters" class="d-inline">
                                        <input type="hidden" name="_csrf" value="${csrfToken}">
                                        <input type="hidden" name="voterId" value="${voter.voterId}">
                                        <input type="hidden" name="action" value="reject">
                                        <button type="submit" class="btn btn-danger btn-sm" title="Reject"
                                                onclick="return confirm('Reject this voter?')">
                                            <i class="bi bi-x-lg"></i>
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${voter.status == 'PENDING' && !voter.verified}">
                                    <small class="text-muted">Awaiting email verification</small>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <c:if test="${empty voters}">
            <p class="text-center text-muted py-3">No voters found.</p>
        </c:if>
    </div>
</div>

<jsp:include page="../footer.jsp"/>
