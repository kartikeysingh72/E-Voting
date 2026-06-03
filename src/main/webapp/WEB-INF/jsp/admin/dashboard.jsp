<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../header.jsp">
    <jsp:param name="title" value="Admin Dashboard - E-Voting Platform"/>
</jsp:include>

<!-- Sidebar -->
<div class="ev-sidebar" id="adminSidebar">
    <div class="sidebar-heading">Main</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-link active">
        <i class="bi bi-grid-1x2"></i>Dashboard
    </a>
    <a href="${pageContext.request.contextPath}/admin/elections" class="sidebar-link">
        <i class="bi bi-calendar-event"></i>Elections
    </a>
    <a href="${pageContext.request.contextPath}/admin/candidates" class="sidebar-link">
        <i class="bi bi-person-vcard"></i>Candidates
    </a>
    <div class="sidebar-heading">Management</div>
    <a href="${pageContext.request.contextPath}/admin/voters" class="sidebar-link">
        <i class="bi bi-people"></i>Voter Approvals
    </a>
    <a href="${pageContext.request.contextPath}/admin/results" class="sidebar-link">
        <i class="bi bi-bar-chart-fill"></i>Results
    </a>
</div>
<button class="btn btn-outline-secondary d-lg-none position-fixed" style="top:68px;left:8px;z-index:101;"
        onclick="document.getElementById('adminSidebar').classList.toggle('show')">
    <i class="bi bi-list"></i>
</button>

<!-- Main Content -->
<div class="ev-main">
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h2 class="fw-800 text-navy mb-0">Dashboard</h2>
            <p class="text-slate small mb-0">Overview of platform activity and key metrics.</p>
        </div>
        <span class="text-slate small"><i class="bi bi-clock me-1"></i>${java.time.LocalDate.now()}</span>
    </div>

    <c:if test="${error != null}">
        <div class="alert alert-danger"><i class="bi bi-exclamation-circle me-2"></i>${error}</div>
    </c:if>

    <!-- Metric Cards -->
    <div class="row g-4 mb-4">
        <div class="col-md-4 col-sm-6">
            <div class="ev-metric">
                <div class="d-flex align-items-center justify-content-between mb-2">
                    <div class="metric-icon blue"><i class="bi bi-people"></i></div>
                    <span class="badge bg-info">Total</span>
                </div>
                <div class="metric-value">${totalVoters}</div>
                <div class="metric-label">Registered Voters</div>
            </div>
        </div>
        <div class="col-md-4 col-sm-6">
            <div class="ev-metric">
                <div class="d-flex align-items-center justify-content-between mb-2">
                    <div class="metric-icon green"><i class="bi bi-person-check"></i></div>
                    <span class="badge bg-success">Approved</span>
                </div>
                <div class="metric-value">${approvedVoters}</div>
                <div class="metric-label">Approved Voters</div>
            </div>
        </div>
        <div class="col-md-4 col-sm-6">
            <div class="ev-metric">
                <div class="d-flex align-items-center justify-content-between mb-2">
                    <div class="metric-icon amber"><i class="bi bi-hourglass-split"></i></div>
                    <span class="badge bg-warning">Pending</span>
                </div>
                <div class="metric-value">${totalVoters - approvedVoters}</div>
                <div class="metric-label">Pending Approvals</div>
            </div>
        </div>
        <div class="col-md-4 col-sm-6">
            <div class="ev-metric">
                <div class="d-flex align-items-center justify-content-between mb-2">
                    <div class="metric-icon blue"><i class="bi bi-calendar-event"></i></div>
                    <span class="badge bg-primary">Total</span>
                </div>
                <div class="metric-value">${totalElections}</div>
                <div class="metric-label">Total Elections</div>
            </div>
        </div>
        <div class="col-md-4 col-sm-6">
            <div class="ev-metric">
                <div class="d-flex align-items-center justify-content-between mb-2">
                    <div class="metric-icon green"><i class="bi bi-lightning-charge"></i></div>
                    <span class="badge bg-success">Live</span>
                </div>
                <div class="metric-value">${activeElections}</div>
                <div class="metric-label">Active Elections</div>
            </div>
        </div>
        <div class="col-md-4 col-sm-6">
            <div class="ev-metric">
                <div class="d-flex align-items-center justify-content-between mb-2">
                    <div class="metric-icon red"><i class="bi bi-check2-square"></i></div>
                    <span class="badge bg-secondary">Cast</span>
                </div>
                <div class="metric-value">${totalVotes}</div>
                <div class="metric-label">Ballots Cast</div>
            </div>
        </div>
    </div>

    <!-- Pending Voter Approvals -->
    <c:if test="${!empty pendingVoters}">
        <div class="ev-card mb-4">
            <div class="card-header d-flex align-items-center justify-content-between">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-exclamation-circle text-warning"></i>
                    <span class="fw-700">Pending Voter Approvals</span>
                </div>
                <a href="${pageContext.request.contextPath}/admin/voters" class="btn btn-sm btn-outline-primary">View All</a>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table ev-table mb-0">
                        <thead>
                            <tr><th>Name</th><th>Email</th><th>P ID</th><th>Actions</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="voter" items="${pendingVoters}" end="4">
                                <tr>
                                    <td><strong>${voter.name}</strong></td>
                                    <td><small class="text-slate">${voter.email}</small></td>
                                    <td><code>${voter.pidNumber}</code></td>
                                    <td>
                                        <div class="d-flex gap-1">
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
                                                <button type="submit" class="btn btn-danger btn-sm">Reject</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </c:if>

    <!-- Active Elections -->
    <c:if test="${!empty activeElectionList}">
        <div class="ev-card">
            <div class="card-header d-flex align-items-center gap-2">
                <i class="bi bi-lightning-charge text-success"></i>
                <span class="fw-700">Active Elections</span>
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <c:forEach var="election" items="${activeElectionList}">
                        <div class="col-md-6">
                            <div class="d-flex align-items-center justify-content-between p-3 rounded-3"
                                 style="background:var(--ev-slate-50); border:1px solid var(--ev-slate-200);">
                                <div>
                                    <div class="fw-600 small">${election.title}</div>
                                    <div class="text-slate" style="font-size:.7rem;">Ends: ${election.endDate}</div>
                                </div>
                                <span class="badge bg-success">Active</span>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </c:if>
</div>

<jsp:include page="../footer.jsp"/>
