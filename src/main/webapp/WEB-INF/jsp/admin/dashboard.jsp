<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../header.jsp">
    <jsp:param name="title" value="Admin Dashboard - E-Voting Platform"/>
</jsp:include>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-speedometer2"></i> Admin Dashboard</h2>
    <div>
        <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-outline-primary me-2">
            <i class="bi bi-ballot"></i> Elections
        </a>
        <a href="${pageContext.request.contextPath}/admin/candidates" class="btn btn-outline-primary me-2">
            <i class="bi bi-people"></i> Candidates
        </a>
        <a href="${pageContext.request.contextPath}/admin/voters" class="btn btn-outline-primary me-2">
            <i class="bi bi-person-check"></i> Voters
        </a>
        <a href="${pageContext.request.contextPath}/admin/results" class="btn btn-outline-primary">
            <i class="bi bi-bar-chart"></i> Results
        </a>
    </div>
</div>

<c:if test="${error != null}">
    <div class="alert alert-danger">${error}</div>
</c:if>

<!-- Stats Cards -->
<div class="row g-3 mb-4">
    <div class="col-md-2">
        <div class="card text-white bg-primary text-center">
            <div class="card-body">
                <h3>${totalVoters}</h3>
                <small>Total Voters</small>
            </div>
        </div>
    </div>
    <div class="col-md-2">
        <div class="card text-white bg-success text-center">
            <div class="card-body">
                <h3>${approvedVoters}</h3>
                <small>Approved Voters</small>
            </div>
        </div>
    </div>
    <div class="col-md-2">
        <div class="card text-white bg-info text-center">
            <div class="card-body">
                <h3>${totalElections}</h3>
                <small>Total Elections</small>
            </div>
        </div>
    </div>
    <div class="col-md-2">
        <div class="card text-white bg-warning text-center">
            <div class="card-body">
                <h3>${activeElections}</h3>
                <small>Active Elections</small>
            </div>
        </div>
    </div>
    <div class="col-md-2">
        <div class="card text-white bg-secondary text-center">
            <div class="card-body">
                <h3>${totalCandidates}</h3>
                <small>Candidates</small>
            </div>
        </div>
    </div>
    <div class="col-md-2">
        <div class="card text-white bg-dark text-center">
            <div class="card-body">
                <h3>${totalVotes}</h3>
                <small>Votes Cast</small>
            </div>
        </div>
    </div>
</div>

<div class="row g-4">
    <!-- Pending Voter Approvals -->
    <div class="col-md-6">
        <div class="card shadow-sm">
            <div class="card-header bg-warning text-dark">
                <h5 class="mb-0"><i class="bi bi-person-exclamation"></i> Pending Voter Approvals</h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${!empty pendingVoters}">
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr><th>Name</th><th>Email</th><th>Action</th></tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="voter" items="${pendingVoters}" end="4">
                                        <tr>
                                            <td>${voter.name}</td>
                                            <td><small>${voter.email}</small></td>
                                            <td>
                                                <form method="POST" action="${pageContext.request.contextPath}/admin/voters" class="d-inline">
                                                    <input type="hidden" name="_csrf" value="${csrfToken}">
                                                    <input type="hidden" name="voterId" value="${voter.voterId}">
                                                    <input type="hidden" name="action" value="approve">
                                                    <button type="submit" class="btn btn-success btn-sm">
                                                        <i class="bi bi-check"></i>
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <a href="${pageContext.request.contextPath}/admin/voters?status=PENDING" class="btn btn-outline-warning btn-sm">
                            View All Pending (${pendingVoters.size()})
                        </a>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted mb-0 text-center"><i class="bi bi-check-circle"></i> No pending approvals</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Active Elections -->
    <div class="col-md-6">
        <div class="card shadow-sm">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0"><i class="bi bi-lightning"></i> Active Elections</h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${!empty activeElectionList}">
                        <c:forEach var="election" items="${activeElectionList}">
                            <div class="d-flex justify-content-between align-items-center border-bottom py-2">
                                <div>
                                    <strong>${election.title}</strong>
                                    <br><small class="text-muted">Ends: ${election.endDate}</small>
                                </div>
                                <a href="${pageContext.request.contextPath}/admin/results?electionId=${election.electionId}"
                                   class="btn btn-outline-primary btn-sm">
                                    <i class="bi bi-bar-chart"></i> Live Stats
                                </a>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted mb-0 text-center"><i class="bi bi-inbox"></i> No active elections</p>
                        <div class="text-center mt-2">
                            <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-primary btn-sm">
                                <i class="bi bi-plus"></i> Create Election
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../footer.jsp"/>
