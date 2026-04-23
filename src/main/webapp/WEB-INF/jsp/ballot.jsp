<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Cast Your Vote - E-Voting Platform"/>
</jsp:include>

<h2 class="mb-4"><i class="bi bi-check2-circle"></i> Cast Your Vote</h2>
<p class="text-muted">Welcome, <strong>${sessionScope.voter.name}</strong>! Select an election and cast your vote below.</p>

<c:if test="${error != null}">
    <div class="alert alert-danger alert-dismissible fade show">
        <i class="bi bi-exclamation-triangle"></i> ${error}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<!-- Election List -->
<c:if test="${selectedElection == null}">
    <div class="row g-3">
        <c:forEach var="election" items="${elections}">
            <div class="col-md-6">
                <div class="card shadow-sm h-100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start">
                            <h5 class="card-title">${election.title}</h5>
                            <c:choose>
                                <c:when test="${election.status == 'VOTED'}">
                                    <span class="badge bg-success"><i class="bi bi-check"></i> Voted</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-primary"><i class="bi bi-clock"></i> Open</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <p class="card-text text-muted">${election.description}</p>
                        <small class="text-muted">
                            <i class="bi bi-calendar"></i>
                            Ends: ${election.endDate}
                        </small>
                    </div>
                    <div class="card-footer bg-transparent">
                        <c:choose>
                            <c:when test="${election.status == 'VOTED'}">
                                <span class="text-success"><i class="bi bi-check-circle"></i> You have already voted</span>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/voter/vote?electionId=${election.electionId}"
                                   class="btn btn-primary">
                                    <i class="bi bi-arrow-right"></i> View Ballot
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </c:forEach>

        <c:if test="${empty elections}">
            <div class="col-12 text-center py-5">
                <i class="bi bi-inbox text-muted" style="font-size: 3rem;"></i>
                <h5 class="mt-3 text-muted">No Active Elections</h5>
                <p class="text-muted">There are no elections currently open for voting.</p>
                <a href="${pageContext.request.contextPath}/results" class="btn btn-outline-primary">
                    <i class="bi bi-bar-chart"></i> View Results
                </a>
            </div>
        </c:if>
    </div>
</c:if>

<!-- Ballot for Selected Election -->
<c:if test="${selectedElection != null && !hasVoted}">
    <div class="card shadow-sm">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0"><i class="bi bi-ballot"></i> ${selectedElection.title}</h4>
            <small>Select one candidate and submit your vote.</small>
        </div>
        <div class="card-body">
            <form method="POST" action="${pageContext.request.contextPath}/voter/vote" id="voteForm">
                <input type="hidden" name="_csrf" value="${csrfToken}">
                <input type="hidden" name="electionId" value="${selectedElection.electionId}">

                <c:forEach var="candidate" items="${candidates}">
                    <div class="card mb-3 candidate-card" onclick="selectCandidate(${candidate.candidateId})">
                        <div class="card-body d-flex align-items-center">
                            <input type="radio" name="candidateId" value="${candidate.candidateId}"
                                   id="cand_${candidate.candidateId}" class="form-check-input me-3"
                                   style="width: 20px; height: 20px;" required>
                            <div class="flex-grow-1">
                                <h5 class="mb-1">${candidate.name}</h5>
                                <span class="badge bg-info">${candidate.party}</span>
                                <c:if test="${candidate.bio != null && !empty candidate.bio}">
                                    <p class="text-muted mt-1 mb-0 small">${candidate.bio}</p>
                                </c:if>
                            </div>
                            <c:if test="${candidate.photoUrl != null && !empty candidate.photoUrl}">
                                <img src="${candidate.photoUrl}" alt="${candidate.name}"
                                     class="rounded-circle ms-3" style="width:60px;height:60px;object-fit:cover;">
                            </c:if>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty candidates}">
                    <div class="text-center py-4 text-muted">
                        <p>No candidates registered for this election yet.</p>
                    </div>
                </c:if>

                <c:if test="${!empty candidates}">
                    <div class="text-center mt-3">
                        <button type="submit" class="btn btn-success btn-lg px-5" id="submitBtn" disabled>
                            <i class="bi bi-check2-all"></i> Submit My Vote
                        </button>
                    </div>
                </c:if>
            </form>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/voter/vote" class="btn btn-outline-secondary mt-3">
        <i class="bi bi-arrow-left"></i> Back to Elections
    </a>
</c:if>

<c:if test="${selectedElection != null && hasVoted}">
    <div class="alert alert-success">
        <i class="bi bi-check-circle-fill"></i> You have already voted in this election.
        <a href="${pageContext.request.contextPath}/voter/vote">Go back to elections</a>
    </div>
</c:if>

<script>
function selectCandidate(id) {
    document.getElementById('cand_' + id).checked = true;
    document.getElementById('submitBtn').disabled = false;
    document.querySelectorAll('.candidate-card').forEach(c => c.classList.remove('border-primary', 'border-2'));
    document.getElementById('cand_' + id).closest('.candidate-card').classList.add('border-primary', 'border-2');
}
</script>

<jsp:include page="footer.jsp"/>
