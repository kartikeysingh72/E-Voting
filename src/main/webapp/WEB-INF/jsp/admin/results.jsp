<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../header.jsp">
    <jsp:param name="title" value="Election Results - Admin"/>
</jsp:include>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-bar-chart"></i> Election Results</h2>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Dashboard
    </a>
</div>

<c:if test="${success != null}"><div class="alert alert-success">${success}</div></c:if>
<c:if test="${error != null}"><div class="alert alert-danger">${error}</div></c:if>

<!-- Election Selector -->
<div class="card shadow-sm mb-4">
    <div class="card-body">
        <form method="GET" action="${pageContext.request.contextPath}/admin/results" class="row g-2 align-items-end">
            <div class="col-md-6">
                <label class="form-label">Select Election</label>
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
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
            <div>
                <h4 class="mb-0">${election.title}</h4>
                <small>Status: ${election.status}</small>
            </div>
            <div>
                <a href="${pageContext.request.contextPath}/admin/export?electionId=${election.electionId}&format=csv"
                   class="btn btn-light btn-sm">
                    <i class="bi bi-download"></i> Export CSV
                </a>
            </div>
        </div>
        <div class="card-body">
            <!-- Stats Row -->
            <div class="row mb-3">
                <div class="col-md-3">
                    <div class="text-center p-3 bg-light rounded">
                        <h3 class="text-primary mb-0">${totalVotes}</h3>
                        <small class="text-muted">Total Votes</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="text-center p-3 bg-light rounded">
                        <h3 class="text-success mb-0">${approvedVoters}</h3>
                        <small class="text-muted">Eligible Voters</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="text-center p-3 bg-light rounded">
                        <h3 class="text-info mb-0">${turnoutPercent}%</h3>
                        <small class="text-muted">Voter Turnout</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="text-center p-3 bg-light rounded">
                        <h3 class="text-warning mb-0">${candidates.size()}</h3>
                        <small class="text-muted">Candidates</small>
                    </div>
                </div>
            </div>

            <!-- Results Table -->
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead class="table-dark">
                        <tr><th>#</th><th>Candidate</th><th>Party</th><th>Votes</th><th>%</th><th>Progress</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach var="c" items="${candidates}" varStatus="s">
                            <tr class="${s.first ? 'table-success' : ''}">
                                <td>${s.count}</td>
                                <td>
                                    <strong>${c.name}</strong>
                                    <c:if test="${s.first && totalVotes > 0}">
                                        <span class="badge bg-success ms-1">Winner</span>
                                    </c:if>
                                </td>
                                <td>${c.party}</td>
                                <td><strong>${c.voteCount}</strong></td>
                                <td>${totalVotes > 0 ? String.format("%.1f", (c.voteCount * 100.0 / totalVotes)) : '0.0'}%</td>
                                <td style="width:25%">
                                    <div class="progress" style="height:20px">
                                        <div class="progress-bar ${s.first ? 'bg-success' : 'bg-primary'}"
                                             style="width:${totalVotes > 0 ? (c.voteCount * 100.0 / totalVotes) : 0}%">
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- Declare Results -->
            <c:if test="${election.status != 'COMPLETED'}">
                <div class="text-center mt-3">
                    <form method="POST" action="${pageContext.request.contextPath}/admin/results" class="d-inline"
                          onsubmit="return confirm('Declare results? This will lock the election and no more votes can be cast.')">
                        <input type="hidden" name="_csrf" value="${csrfToken}">
                        <input type="hidden" name="action" value="declare">
                        <input type="hidden" name="electionId" value="${election.electionId}">
                        <button type="submit" class="btn btn-success btn-lg">
                            <i class="bi bi-trophy"></i> Declare Results
                        </button>
                    </form>
                </div>
            </c:if>

            <c:if test="${election.status == 'COMPLETED'}">
                <div class="alert alert-success text-center mt-3">
                    <i class="bi bi-check-circle"></i> Results have been declared. Election is locked.
                </div>
            </c:if>
        </div>
    </div>
</c:if>

<jsp:include page="../footer.jsp"/>
