<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Election Results - E-Voting Platform"/>
</jsp:include>

<div class="container py-4">
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h2 class="fw-800 text-navy mb-0">Election Results</h2>
            <p class="text-slate small mb-0">Public view of election outcomes and vote tallies.</p>
        </div>
    </div>

    <c:if test="${error != null}">
        <div class="alert alert-danger"><i class="bi bi-exclamation-circle me-2"></i>${error}</div>
    </c:if>

    <!-- Election Selector -->
    <div class="ev-card mb-4">
        <div class="card-body">
            <form method="GET" action="${pageContext.request.contextPath}/results" class="row g-3 align-items-end">
                <div class="col-md-6">
                    <label class="form-label fw-600"><i class="bi bi-calendar-event me-1"></i>Select Election</label>
                    <select name="electionId" class="form-select" onchange="this.form.submit()">
                        <option value="">-- Choose Election --</option>
                        <c:forEach var="e" items="${completedElections}">
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
    <c:choose>
        <c:when test="${empty completedElections}">
            <div class="ev-card">
                <div class="card-body text-center py-5">
                    <i class="bi bi-bar-chart text-slate" style="font-size:3rem;"></i>
                    <h5 class="fw-700 mt-3">No Results Available</h5>
                    <p class="text-slate">There are no completed elections to display yet.</p>
                </div>
            </div>
        </c:when>
        <c:when test="${election == null}">
            <div class="ev-card">
                <div class="card-body text-center py-5">
                    <i class="bi bi-hand-index-thumb text-primary" style="font-size:3rem;"></i>
                    <h5 class="fw-700 mt-3">Select an Election</h5>
                    <p class="text-slate">Choose an election from the dropdown above to view its results.</p>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Election Header -->
            <div class="ev-card mb-4">
                <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-calendar-check text-primary"></i>
                        <div>
                            <span class="fw-700">${election.title}</span>
                            <span class="badge ms-2 bg-success">${election.status}</span>
                        </div>
                    </div>
                    <span class="text-slate small">${totalVotes} total vote(s) cast</span>
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
                                                <c:if test="${c.party != null && !empty c.party}">
                                                    <span class="text-slate small ms-2">(${c.party})</span>
                                                </c:if>
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
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="footer.jsp"/>
