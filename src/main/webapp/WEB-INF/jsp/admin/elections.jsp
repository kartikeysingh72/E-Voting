<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../header.jsp">
    <jsp:param name="title" value="Manage Elections - Admin"/>
</jsp:include>

<!-- Sidebar -->
<div class="ev-sidebar" id="adminSidebar">
    <div class="sidebar-heading">Main</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-link"><i class="bi bi-grid-1x2"></i>Dashboard</a>
    <a href="${pageContext.request.contextPath}/admin/elections" class="sidebar-link active"><i class="bi bi-calendar-event"></i>Elections</a>
    <a href="${pageContext.request.contextPath}/admin/candidates" class="sidebar-link"><i class="bi bi-person-vcard"></i>Candidates</a>
    <div class="sidebar-heading">Management</div>
    <a href="${pageContext.request.contextPath}/admin/voters" class="sidebar-link"><i class="bi bi-people"></i>Voter Approvals</a>
    <a href="${pageContext.request.contextPath}/admin/results" class="sidebar-link"><i class="bi bi-bar-chart-fill"></i>Results</a>
</div>
<button class="btn btn-outline-secondary d-lg-none position-fixed" style="top:68px;left:8px;z-index:101;"
        onclick="document.getElementById('adminSidebar').classList.toggle('show')"><i class="bi bi-list"></i></button>

<!-- Main Content -->
<div class="ev-main">
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h2 class="fw-800 text-navy mb-0">Elections</h2>
            <p class="text-slate small mb-0">Create and manage electoral polls.</p>
        </div>
    </div>

    <c:if test="${success != null}">
        <div class="alert alert-success"><i class="bi bi-check-circle me-2"></i>${success}</div>
    </c:if>
    <c:if test="${error != null}">
        <div class="alert alert-danger"><i class="bi bi-exclamation-circle me-2"></i>${error}</div>
    </c:if>

    <div class="row g-4">
        <!-- Election Creator Form -->
        <div class="col-lg-4">
            <div class="ev-card">
                <div class="card-header d-flex align-items-center gap-2">
                    <i class="bi bi-${election != null ? 'pencil-square' : 'plus-circle'} text-primary"></i>
                    <span class="fw-700">${election != null ? 'Edit Election' : 'Create Election'}</span>
                </div>
                <div class="card-body">
                    <form method="POST" action="${pageContext.request.contextPath}/admin/elections">
                        <input type="hidden" name="_csrf" value="${csrfToken}">
                        <input type="hidden" name="action" value="${election != null ? 'update' : 'create'}">
                        <c:if test="${election != null}">
                            <input type="hidden" name="id" value="${election.electionId}">
                        </c:if>

                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-type me-1"></i>Election Title</label>
                            <input type="text" name="title" class="form-control" required
                                   placeholder="e.g. Student Council 2026"
                                   value="${election != null ? election.title : ''}">
                        </div>

                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-text-paragraph me-1"></i>Description</label>
                            <textarea name="description" class="form-control" rows="3"
                                      placeholder="Brief description of this election...">${election != null ? election.description : ''}</textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-calendar-check me-1"></i>Start Date &amp; Time</label>
                            <input type="datetime-local" name="startDate" class="form-control" required
                                   value="${election != null ? election.startDate : ''}">
                        </div>

                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-calendar-x me-1"></i>End Date &amp; Time</label>
                            <input type="datetime-local" name="endDate" class="form-control" required
                                   value="${election != null ? election.endDate : ''}">
                        </div>

                        <c:if test="${election != null}">
                            <div class="mb-3">
                                <label class="form-label"><i class="bi bi-flag me-1"></i>Status</label>
                                <select name="status" class="form-select">
                                    <option value="SCHEDULED" ${election.status == 'SCHEDULED' ? 'selected' : ''}>Scheduled</option>
                                    <option value="ACTIVE" ${election.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                                    <option value="COMPLETED" ${election.status == 'COMPLETED' ? 'selected' : ''}>Completed</option>
                                    <option value="CANCELLED" ${election.status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
                                </select>
                            </div>
                        </c:if>

                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-${election != null ? 'pencil' : 'plus-lg'} me-1"></i>
                            ${election != null ? 'Update Election' : 'Create Election'}
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Election List -->
        <div class="col-lg-8">
            <div class="ev-card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-collection text-primary"></i>
                        <span class="fw-700">All Elections</span>
                    </div>
                    <span class="badge bg-primary">${elections.size()} total</span>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${empty elections}">
                            <div class="text-center py-5">
                                <i class="bi bi-calendar-x text-slate" style="font-size:2.5rem;"></i>
                                <p class="text-slate mt-2 mb-0">No elections created yet.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table ev-table mb-0">
                                    <thead>
                                        <tr>
                                            <th>Title</th>
                                            <th>Start</th>
                                            <th>End</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="e" items="${elections}">
                                            <tr>
                                                <td>
                                                    <strong>${e.title}</strong>
                                                    <c:if test="${e.description != null && !empty e.description}">
                                                        <div class="text-slate" style="font-size:.75rem;">
                                                            ${e.description.length() > 50 ? e.description.substring(0,50).concat('...') : e.description}
                                                        </div>
                                                    </c:if>
                                                </td>
                                                <td><small class="text-slate">${e.startDate}</small></td>
                                                <td><small class="text-slate">${e.endDate}</small></td>
                                                <td>
                                                    <span class="badge ${e.status == 'ACTIVE' ? 'bg-success' : e.status == 'COMPLETED' ? 'bg-secondary' : e.status == 'CANCELLED' ? 'bg-danger' : 'bg-primary'}">
                                                        ${e.status}
                                                    </span>
                                                </td>
                                                <td>
                                                    <div class="d-flex gap-1">
                                                        <a href="${pageContext.request.contextPath}/admin/elections?action=edit&id=${e.electionId}"
                                                           class="btn btn-sm btn-outline-primary btn-icon" title="Edit">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/admin/candidates?electionId=${e.electionId}"
                                                           class="btn btn-sm btn-outline-info btn-icon" title="Candidates">
                                                            <i class="bi bi-people"></i>
                                                        </a>
                                                        <form method="POST" action="${pageContext.request.contextPath}/admin/elections" class="d-inline"
                                                              onsubmit="return confirm('Delete this election? This cannot be undone.')">
                                                            <input type="hidden" name="_csrf" value="${csrfToken}">
                                                            <input type="hidden" name="action" value="delete">
                                                            <input type="hidden" name="id" value="${e.electionId}">
                                                            <button type="submit" class="btn btn-sm btn-outline-danger btn-icon" title="Delete">
                                                                <i class="bi bi-trash"></i>
                                                            </button>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp"/>
