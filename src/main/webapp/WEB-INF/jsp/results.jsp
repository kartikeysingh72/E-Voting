<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Election Results - E-Voting Platform"/>
</jsp:include>

<h2 class="mb-4"><i class="bi bi-bar-chart"></i> Election Results</h2>

<c:if test="${error != null}">
    <div class="alert alert-danger">${error}</div>
</c:if>

<!-- Specific Election Results -->
<c:if test="${election != null}">
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">${election.title}</h4>
            <small>${election.description}</small>
        </div>
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-4">
                    <div class="text-center p-3 bg-light rounded">
                        <h3 class="text-primary mb-0">${totalVotes}</h3>
                        <small class="text-muted">Total Votes</small>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center p-3 bg-light rounded">
                        <h3 class="text-success mb-0">${election.status}</h3>
                        <small class="text-muted">Status</small>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="text-center p-3 bg-light rounded">
                        <h3 class="text-info mb-0">${election.endDate}</h3>
                        <small class="text-muted">Ended On</small>
                    </div>
                </div>
            </div>

            <!-- Results Table -->
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead class="table-dark">
                        <tr>
                            <th>#</th>
                            <th>Candidate</th>
                            <th>Party</th>
                            <th>Votes</th>
                            <th>Percentage</th>
                            <th>Progress</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="candidate" items="${candidates}" varStatus="status">
                            <tr class="${status.first ? 'table-success' : ''}">
                                <td>${status.count}</td>
                                <td>
                                    <strong>${candidate.name}</strong>
                                    <c:if test="${status.first && totalVotes > 0}">
                                        <span class="badge bg-success ms-1"><i class="bi bi-trophy"></i> Winner</span>
                                    </c:if>
                                </td>
                                <td>${candidate.party}</td>
                                <td><strong>${candidate.voteCount}</strong></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${totalVotes > 0}">
                                            ${String.format("%.1f", (candidate.voteCount * 100.0 / totalVotes))}%
                                        </c:when>
                                        <c:otherwise>0%</c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="width: 30%;">
                                    <div class="progress">
                                        <div class="progress-bar ${status.first ? 'bg-success' : 'bg-primary'}"
                                             style="width: ${totalVotes > 0 ? (candidate.voteCount * 100.0 / totalVotes) : 0}%"></div>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/results" class="btn btn-outline-secondary mb-4">
        <i class="bi bi-arrow-left"></i> All Elections
    </a>
</c:if>

<!-- Election List -->
<c:if test="${election == null}">
    <div class="row g-3">
        <c:forEach var="e" items="${completedElections}">
            <div class="col-md-6">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <h5>${e.title}</h5>
                        <p class="text-muted small">${e.description}</p>
                        <small class="text-muted">
                            <i class="bi bi-calendar"></i> Ended: ${e.endDate}
                        </small>
                    </div>
                    <div class="card-footer bg-transparent">
                        <a href="${pageContext.request.contextPath}/results?electionId=${e.electionId}"
                           class="btn btn-primary">
                            <i class="bi bi-bar-chart"></i> View Results
                        </a>
                    </div>
                </div>
            </div>
        </c:forEach>

        <c:if test="${empty completedElections}">
            <div class="col-12 text-center py-5">
                <i class="bi bi-hourglass text-muted" style="font-size: 3rem;"></i>
                <h5 class="mt-3 text-muted">No Completed Elections Yet</h5>
                <p class="text-muted">Results will appear here once elections are completed.</p>
            </div>
        </c:if>
    </div>
</c:if>

<jsp:include page="footer.jsp"/>
