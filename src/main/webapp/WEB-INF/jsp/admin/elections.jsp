<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../header.jsp">
    <jsp:param name="title" value="Manage Elections - Admin"/>
</jsp:include>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-ballot"></i> Manage Elections</h2>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Dashboard
    </a>
</div>

<c:if test="${success != null}">
    <div class="alert alert-success">${success}</div>
</c:if>
<c:if test="${error != null}">
    <div class="alert alert-danger">${error}</div>
</c:if>

<div class="row">
    <!-- Create/Edit Election Form -->
    <div class="col-md-4">
        <div class="card shadow-sm">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">
                    ${election != null ? 'Edit Election' : 'Create New Election'}
                </h5>
            </div>
            <div class="card-body">
                <form method="POST" action="${pageContext.request.contextPath}/admin/elections">
                    <input type="hidden" name="_csrf" value="${csrfToken}">
                    <input type="hidden" name="action" value="${election != null ? 'update' : 'create'}">
                    <c:if test="${election != null}">
                        <input type="hidden" name="id" value="${election.electionId}">
                    </c:if>

                    <div class="mb-3">
                        <label class="form-label">Election Title</label>
                        <input type="text" name="title" class="form-control" required
                               value="${election != null ? election.title : ''}">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <textarea name="description" class="form-control" rows="2">${election != null ? election.description : ''}</textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Start Date &amp; Time</label>
                        <input type="datetime-local" name="startDate" class="form-control" required
                               value="${election != null ? election.startDate : ''}">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">End Date &amp; Time</label>
                        <input type="datetime-local" name="endDate" class="form-control" required
                               value="${election != null ? election.endDate : ''}">
                    </div>

                    <c:if test="${election != null}">
                        <div class="mb-3">
                            <label class="form-label">Status</label>
                            <select name="status" class="form-select">
                                <option value="SCHEDULED" ${election.status == 'SCHEDULED' ? 'selected' : ''}>Scheduled</option>
                                <option value="ACTIVE" ${election.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                                <option value="COMPLETED" ${election.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                <option value="CANCELLED" ${election.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                            </select>
                        </div>
                    </c:if>

                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-${election != null ? 'pencil' : 'plus'}"></i>
                        ${election != null ? 'Update Election' : 'Create Election'}
                    </button>
                </form>
            </div>
        </div>
    </div>

    <!-- Election List -->
    <div class="col-md-8">
        <div class="card shadow-sm">
            <div class="card-header"><h5 class="mb-0">All Elections</h5></div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr><th>Title</th><th>Start</th><th>End</th><th>Status</th><th>Actions</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="e" items="${elections}">
                                <tr>
                                    <td><strong>${e.title}</strong></td>
                                    <td><small>${e.startDate}</small></td>
                                    <td><small>${e.endDate}</small></td>
                                    <td>
                                        <span class="badge bg-${e.status == 'ACTIVE' ? 'success' : e.status == 'COMPLETED' ? 'secondary' : e.status == 'CANCELLED' ? 'danger' : 'primary'}">
                                            ${e.status}
                                        </span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/admin/elections?action=edit&id=${e.electionId}"
                                           class="btn btn-sm btn-outline-primary">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/candidates?electionId=${e.electionId}"
                                           class="btn btn-sm btn-outline-info">
                                            <i class="bi bi-people"></i>
                                        </a>
                                        <form method="POST" action="${pageContext.request.contextPath}/admin/elections" class="d-inline"
                                              onsubmit="return confirm('Delete this election?')">
                                            <input type="hidden" name="_csrf" value="${csrfToken}">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${e.electionId}">
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp"/>
