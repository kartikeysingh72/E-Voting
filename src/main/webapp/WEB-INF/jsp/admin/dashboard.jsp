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
    <!-- Header -->
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

    <!-- Calculate derived values -->
    <c:set var="pendingCount" value="${totalVoters - approvedVoters}"/>
    <c:set var="approvalRate" value="${totalVoters > 0 ? (approvedVoters * 100 / totalVoters) : 0}"/>
    <c:set var="turnoutRate" value="${approvedVoters > 0 ? (totalVotes * 100 / approvedVoters) : 0}"/>

    <!-- Hero Stats Section -->
    <div class="row g-4 mb-4">
        <!-- Voter Stats Card with Circular Progress -->
        <div class="col-lg-4 col-md-6">
            <div class="ev-card h-100 dash-hero-card">
                <div class="card-body p-4">
                    <div class="d-flex align-items-start justify-content-between mb-3">
                        <div>
                            <h6 class="text-slate text-uppercase small fw-700 mb-1">Voter Registration</h6>
                            <h2 class="fw-800 text-navy mb-0">${totalVoters}</h2>
                            <p class="text-slate small mb-0">Total registered voters</p>
                        </div>
                        <div class="dash-icon-circle dash-icon-blue">
                            <i class="bi bi-people-fill"></i>
                        </div>
                    </div>
                    <div class="dash-progress-container">
                        <div class="d-flex justify-content-between small mb-2">
                            <span class="text-slate">Approval Rate</span>
                            <span class="fw-700 text-success">${approvalRate}%</span>
                        </div>
                        <div class="ev-progress" style="height:10px;">
                            <div class="progress-bar bg-success" style="width:${approvalRate}%"></div>
                        </div>
                    </div>
                    <div class="row mt-3 g-2">
                        <div class="col-6">
                            <div class="dash-mini-stat dash-mini-success">
                                <i class="bi bi-person-check-fill"></i>
                                <div>
                                    <div class="fw-700">${approvedVoters}</div>
                                    <div class="text-muted small">Approved</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="dash-mini-stat dash-mini-warning">
                                <i class="bi bi-hourglass-split"></i>
                                <div>
                                    <div class="fw-700">${pendingCount}</div>
                                    <div class="text-muted small">Pending</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Election Stats Card -->
        <div class="col-lg-4 col-md-6">
            <div class="ev-card h-100 dash-hero-card">
                <div class="card-body p-4">
                    <div class="d-flex align-items-start justify-content-between mb-3">
                        <div>
                            <h6 class="text-slate text-uppercase small fw-700 mb-1">Elections</h6>
                            <h2 class="fw-800 text-navy mb-0">${totalElections}</h2>
                            <p class="text-slate small mb-0">Total elections created</p>
                        </div>
                        <div class="dash-icon-circle dash-icon-green">
                            <i class="bi bi-calendar2-event-fill"></i>
                        </div>
                    </div>
                    <div class="dash-progress-container">
                        <div class="d-flex justify-content-between small mb-2">
                            <span class="text-slate">Currently Active</span>
                            <span class="fw-700 text-primary">${activeElections}</span>
                        </div>
                        <div class="ev-progress" style="height:10px;">
                            <div class="progress-bar bg-primary" style="width:${totalElections > 0 ? (activeElections * 100 / totalElections) : 0}%"></div>
                        </div>
                    </div>
                    <div class="row mt-3 g-2">
                        <div class="col-6">
                            <div class="dash-mini-stat dash-mini-primary">
                                <i class="bi bi-lightning-charge-fill"></i>
                                <div>
                                    <div class="fw-700">${activeElections}</div>
                                    <div class="text-muted small">Active</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="dash-mini-stat dash-mini-info">
                                <i class="bi bi-calendar-check"></i>
                                <div>
                                    <div class="fw-700">${totalElections - activeElections}</div>
                                    <div class="text-muted small">Completed</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Voting Stats Card -->
        <div class="col-lg-4 col-md-6">
            <div class="ev-card h-100 dash-hero-card">
                <div class="card-body p-4">
                    <div class="d-flex align-items-start justify-content-between mb-3">
                        <div>
                            <h6 class="text-slate text-uppercase small fw-700 mb-1">Voter Turnout</h6>
                            <h2 class="fw-800 text-navy mb-0">${totalVotes}</h2>
                            <p class="text-slate small mb-0">Total ballots cast</p>
                        </div>
                        <div class="dash-icon-circle dash-icon-amber">
                            <i class="bi bi-check2-all"></i>
                        </div>
                    </div>
                    <div class="dash-progress-container">
                        <div class="d-flex justify-content-between small mb-2">
                            <span class="text-slate">Turnout Rate</span>
                            <span class="fw-700 ${turnoutRate >= 50 ? 'text-success' : 'text-warning'}">${turnoutRate}%</span>
                        </div>
                        <div class="ev-progress" style="height:10px;">
                            <div class="progress-bar ${turnoutRate >= 50 ? 'bg-success' : 'bg-warning'}" style="width:${turnoutRate}%"></div>
                        </div>
                    </div>
                    <div class="row mt-3 g-2">
                        <div class="col-6">
                            <div class="dash-mini-stat dash-mini-amber">
                                <i class="bi bi-person-vcard-fill"></i>
                                <div>
                                    <div class="fw-700">${totalCandidates}</div>
                                    <div class="text-muted small">Candidates</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="dash-mini-stat dash-mini-red">
                                <i class="bi bi-graph-up-arrow"></i>
                                <div>
                                    <div class="fw-700">${turnoutRate}%</div>
                                    <div class="text-muted small">Participation</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick Stats Bar -->
    <div class="ev-card mb-4">
        <div class="card-body py-3">
            <div class="row g-0 text-center">
                <div class="col-md-3 col-6 border-end">
                    <div class="d-flex align-items-center justify-content-center gap-3 py-2">
                        <div class="dash-quick-icon dash-quick-blue">
                            <i class="bi bi-people"></i>
                        </div>
                        <div class="text-start">
                            <div class="fw-800 fs-4 text-navy">${totalVoters}</div>
                            <div class="text-slate small">Registered</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-6 border-end">
                    <div class="d-flex align-items-center justify-content-center gap-3 py-2">
                        <div class="dash-quick-icon dash-quick-green">
                            <i class="bi bi-person-check"></i>
                        </div>
                        <div class="text-start">
                            <div class="fw-800 fs-4 text-navy">${approvedVoters}</div>
                            <div class="text-slate small">Approved</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-6 border-end border-md-0">
                    <div class="d-flex align-items-center justify-content-center gap-3 py-2">
                        <div class="dash-quick-icon dash-quick-amber">
                            <i class="bi bi-calendar-event"></i>
                        </div>
                        <div class="text-start">
                            <div class="fw-800 fs-4 text-navy">${activeElections}</div>
                            <div class="text-slate small">Active Elections</div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="d-flex align-items-center justify-content-center gap-3 py-2">
                        <div class="dash-quick-icon dash-quick-red">
                            <i class="bi bi-check2-square"></i>
                        </div>
                        <div class="text-start">
                            <div class="fw-800 fs-4 text-navy">${totalVotes}</div>
                            <div class="text-slate small">Votes Cast</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Two Column Layout -->
    <div class="row g-4">
        <!-- Pending Voter Approvals -->
        <div class="col-lg-6">
            <div class="ev-card h-100">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center gap-2">
                        <div class="dash-header-icon dash-header-warning">
                            <i class="bi bi-exclamation-circle"></i>
                        </div>
                        <span class="fw-700">Pending Approvals</span>
                        <c:if test="${pendingCount > 0}">
                            <span class="badge bg-warning text-dark">${pendingCount}</span>
                        </c:if>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/voters" class="btn btn-sm btn-outline-primary">View All</a>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${!empty pendingVoters}">
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
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5">
                                <div class="dash-empty-icon">
                                    <i class="bi bi-check-circle"></i>
                                </div>
                                <p class="text-slate mb-0">All voters are approved!</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Active Elections -->
        <div class="col-lg-6">
            <div class="ev-card h-100">
                <div class="card-header d-flex align-items-center gap-2">
                    <div class="dash-header-icon dash-header-success">
                        <i class="bi bi-lightning-charge"></i>
                    </div>
                    <span class="fw-700">Active Elections</span>
                    <c:if test="${activeElections > 0}">
                        <span class="badge bg-success">${activeElections}</span>
                    </c:if>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${!empty activeElectionList}">
                            <div class="d-flex flex-column gap-3">
                                <c:forEach var="election" items="${activeElectionList}">
                                    <div class="dash-election-item">
                                        <div class="d-flex align-items-center justify-content-between">
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="dash-election-status">
                                                    <span class="dash-status-dot"></span>
                                                </div>
                                                <div>
                                                    <div class="fw-600">${election.title}</div>
                                                    <div class="text-slate small">
                                                        <i class="bi bi-clock me-1"></i>Ends: ${election.endDate}
                                                    </div>
                                                </div>
                                            </div>
                                            <span class="badge bg-success">Live</span>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5">
                                <div class="dash-empty-icon">
                                    <i class="bi bi-calendar-x"></i>
                                </div>
                                <p class="text-slate mb-0">No active elections at the moment.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp"/>
