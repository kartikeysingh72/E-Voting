<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../header.jsp">
    <jsp:param name="title" value="Election Results - Admin"/>
</jsp:include>

<!-- Sidebar -->
<div class="ev-sidebar" id="adminSidebar">
    <div class="sidebar-heading">Main</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-link"><i class="bi bi-grid-1x2"></i>Dashboard</a>
    <a href="${pageContext.request.contextPath}/admin/elections" class="sidebar-link"><i class="bi bi-calendar-event"></i>Elections</a>
    <a href="${pageContext.request.contextPath}/admin/candidates" class="sidebar-link"><i class="bi bi-person-vcard"></i>Candidates</a>
    <div class="sidebar-heading">Management</div>
    <a href="${pageContext.request.contextPath}/admin/voters" class="sidebar-link"><i class="bi bi-people"></i>Voter Approvals</a>
    <a href="${pageContext.request.contextPath}/admin/results" class="sidebar-link active"><i class="bi bi-bar-chart-fill"></i>Results</a>
</div>
<button class="btn btn-outline-secondary d-lg-none position-fixed" style="top:68px;left:8px;z-index:101;"
        onclick="document.getElementById('adminSidebar').classList.toggle('show')"><i class="bi bi-list"></i></button>

<!-- Main Content -->
<div class="ev-main">
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h2 class="fw-800 text-navy mb-0">Results Studio</h2>
            <p class="text-slate small mb-0">Analyze turnout, view live tallies, and declare official results.</p>
        </div>
    </div>

    <c:if test="${success != null}">
        <div class="alert alert-success"><i class="bi bi-check-circle me-2"></i>${success}</div>
    </c:if>
    <c:if test="${error != null}">
        <div class="alert alert-danger"><i class="bi bi-exclamation-circle me-2"></i>${error}</div>
    </c:if>

    <!-- Election Selector -->
    <div class="ev-card mb-4">
        <div class="card-body">
            <form method="GET" action="${pageContext.request.contextPath}/admin/results" class="row g-3 align-items-end">
                <div class="col-md-6">
                    <label class="form-label"><i class="bi bi-calendar-event me-1"></i>Select Election</label>
                    <select name="electionId" class="form-select" onchange="this.form.submit()">
                        <option value="">-- Choose Election --</option>
                        <c:forEach var="e" items="${allElections}">
                            <option value="${e.electionId}" ${election != null && e.electionId == election.electionId ? 'selected' : ''}>
                                ${e.title} (${e.status})
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </form>
        </div>
    </div>

    <!-- Results Display -->
    <c:if test="${election != null}">
        <!-- Header Card -->
        <div class="ev-card mb-4">
            <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-bar-chart-fill text-primary"></i>
                    <div>
                        <span class="fw-700">${election.title}</span>
                        <span class="badge ms-2 ${election.status == 'ACTIVE' ? 'bg-success' : election.status == 'COMPLETED' ? 'bg-secondary' : 'bg-primary'}">
                            ${election.status}
                        </span>
                    </div>
                </div>
                <!-- Export Dropdown -->
                <div class="dropdown">
                    <button class="btn btn-sm btn-outline-primary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="bi bi-download me-1"></i>Export Results
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/export?electionId=${election.electionId}&format=csv">
                            <i class="bi bi-filetype-csv me-2"></i>Export as CSV
                        </a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/export?electionId=${election.electionId}&format=html">
                            <i class="bi bi-filetype-html me-2"></i>Export as HTML
                        </a></li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Analytics Metric Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3 col-sm-6">
                <div class="ev-metric">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <div class="metric-icon blue"><i class="bi bi-check2-square"></i></div>
                    </div>
                    <div class="metric-value">${totalVotes}</div>
                    <div class="metric-label">Total Votes Cast</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="ev-metric">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <div class="metric-icon green"><i class="bi bi-people"></i></div>
                    </div>
                    <div class="metric-value">${approvedVoters}</div>
                    <div class="metric-label">Eligible Voters</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="ev-metric">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <div class="metric-icon amber"><i class="bi bi-graph-up-arrow"></i></div>
                    </div>
                    <div class="metric-value">${turnoutPercent}%</div>
                    <div class="metric-label">Voter Turnout</div>
                </div>
            </div>
            <div class="col-md-3 col-sm-6">
                <div class="ev-metric">
                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <div class="metric-icon blue"><i class="bi bi-person-vcard"></i></div>
                    </div>
                    <div class="metric-value">${candidates.size()}</div>
                    <div class="metric-label">Candidates</div>
                </div>
            </div>
        </div>

        <!-- Turnout Progress Bar -->
        <div class="ev-card mb-4">
            <div class="card-header d-flex align-items-center gap-2">
                <i class="bi bi-graph-up text-primary"></i>
                <span class="fw-700">Voter Turnout</span>
            </div>
            <div class="card-body">
                <div class="d-flex align-items-center justify-content-between mb-2">
                    <span class="small fw-600">${totalVotes} of ${approvedVoters} eligible voters</span>
                    <span class="badge bg-primary">${turnoutPercent}%</span>
                </div>
                <div class="ev-progress">
                    <div class="progress-bar bg-primary" style="width:${turnoutPercent}%"></div>
                </div>
            </div>
        </div>

        <!-- Candidate Results -->
        <div class="ev-card mb-4">
            <div class="card-header d-flex align-items-center gap-2">
                <i class="bi bi-trophy text-warning"></i>
                <span class="fw-700">Candidate Tallies</span>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${!empty candidates}">
                        <c:forEach var="c" items="${candidates}" varStatus="s">
                            <div class="mb-3 ${!s.last ? 'pb-3 border-bottom' : ''}">
                                <div class="d-flex align-items-center justify-content-between mb-2">
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="fw-700 small" style="width:20px;color:var(--ev-slate-400);">${s.count}</span>
                                        <div>
                                            <span class="fw-700">${c.name}</span>
                                            <c:if test="${s.first && totalVotes > 0}">
                                                <span class="badge bg-success ms-2"><i class="bi bi-trophy me-1"></i>Leading</span>
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="d-flex align-items-center gap-3">
                                        <span class="small text-slate fw-600">${c.voteCount} votes</span>
                                        <span class="badge ${s.first ? 'bg-success' : 'bg-primary'}" style="min-width:52px;text-align:center;">
                                            ${totalVotes > 0 ? String.format("%.1f", (c.voteCount * 100.0 / totalVotes)) : '0.0'}%
                                        </span>
                                    </div>
                                </div>
                                <div class="ev-progress">
                                    <div class="progress-bar ${s.first ? 'bg-success' : 'bg-primary'}"
                                         style="width:${totalVotes > 0 ? (c.voteCount * 100.0 / totalVotes) : 0}%">
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-4">
                            <i class="bi bi-inbox text-slate" style="font-size:2rem;"></i>
                            <p class="text-slate mt-2 mb-0">No candidates found for this election.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Declare Results -->
        <c:if test="${election.status != 'COMPLETED'}">
            <div class="ev-card">
                <div class="card-body text-center">
                    <i class="bi bi-shield-check text-primary mb-2" style="font-size:2rem;"></i>
                    <h5 class="fw-700 text-navy">Declare Official Results</h5>
                    <p class="text-slate small mb-3">This will finalize the election results and lock the election. No more votes can be cast after declaring.</p>
                    <form method="POST" action="${pageContext.request.contextPath}/admin/results" class="d-inline"
                          onsubmit="return confirm('Are you sure? This will permanently lock the election and declare official results.')">
                        <input type="hidden" name="_csrf" value="${csrfToken}">
                        <input type="hidden" name="action" value="declare">
                        <input type="hidden" name="electionId" value="${election.electionId}">
                        <button type="submit" class="btn btn-success btn-lg">
                            <i class="bi bi-trophy me-2"></i>Declare Official Results
                        </button>
                    </form>
                </div>
            </div>
        </c:if>

        <c:if test="${election.status == 'COMPLETED'}">
            <div class="ev-card">
                <div class="card-body text-center" style="background:var(--ev-green-50);border-radius:var(--ev-radius-lg);">
                    <i class="bi bi-check-circle-fill text-success mb-2" style="font-size:2.5rem;"></i>
                    <h5 class="fw-700 text-navy">Results Declared</h5>
                    <p class="text-slate small mb-0">This election has been finalized and locked. Official results are published.</p>
                </div>
            </div>
        </c:if>
    </c:if>
</div>

<jsp:include page="../footer.jsp"/>
