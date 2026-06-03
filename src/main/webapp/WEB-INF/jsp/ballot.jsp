<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Cast Your Vote - E-Voting Platform"/>
</jsp:include>

<div class="container py-4">

    <c:if test="${error != null}">
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-circle me-2"></i>${error}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:choose>
        <%-- ==================== STEP A: Election Selection ==================== --%>
        <c:when test="${selectedElection == null}">
            <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
                <div>
                    <h2 class="fw-800 text-navy mb-0">Active Elections</h2>
                    <p class="text-slate small mb-0">Select an election to view the ballot and cast your vote.</p>
                </div>
                <span class="badge bg-primary fs-6">${elections.size()} election(s)</span>
            </div>

            <c:choose>
                <c:when test="${empty elections}">
                    <div class="ev-card">
                        <div class="card-body text-center py-5">
                            <i class="bi bi-calendar-x text-slate" style="font-size:3rem;"></i>
                            <h5 class="fw-700 mt-3">No Active Elections</h5>
                            <p class="text-slate">There are no elections currently open for voting.</p>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="row g-4">
                        <c:forEach var="election" items="${elections}">
                            <div class="col-md-6">
                                <div class="ev-election-card ${election.status == 'VOTED' ? 'voted' : ''} h-100">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h5 class="fw-700 text-navy mb-0">${election.title}</h5>
                                        <c:choose>
                                            <c:when test="${election.status == 'VOTED'}">
                                                <span class="voted-badge"><i class="bi bi-check-circle-fill"></i> Vote Cast</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-success">Open</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <p class="text-slate small mb-3" style="display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
                                        ${election.description}
                                    </p>
                                    <div class="d-flex gap-3 small text-slate mb-3">
                                        <span><i class="bi bi-calendar-event me-1"></i>${election.startDate}</span>
                                        <span><i class="bi bi-clock me-1"></i>Ends ${election.endDate}</span>
                                    </div>
                                    <c:if test="${election.status != 'VOTED'}">
                                        <a href="${pageContext.request.contextPath}/voter/vote?electionId=${election.electionId}"
                                           class="btn btn-primary btn-sm w-100">
                                            <i class="bi bi-arrow-right-circle me-1"></i>View Ballot
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </c:when>

        <%-- ==================== STEP B: Candidate Ballot ==================== --%>
        <c:otherwise>
            <!-- Back link -->
            <a href="${pageContext.request.contextPath}/voter/vote" class="btn btn-outline-secondary btn-sm mb-3">
                <i class="bi bi-arrow-left me-1"></i>Back to Elections
            </a>

            <div class="ev-card mb-4">
                <div class="card-body py-3">
                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                        <div>
                            <h3 class="fw-800 text-navy mb-0">${selectedElection.title}</h3>
                            <p class="text-slate small mb-0">${selectedElection.description}</p>
                        </div>
                        <span class="badge bg-success">Voting Open</span>
                    </div>
                </div>
            </div>

            <c:choose>
                <c:when test="${hasVoted}">
                    <div class="ev-card">
                        <div class="card-body text-center py-5">
                            <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                                 style="width:64px;height:64px;background:var(--ev-green-100);color:var(--ev-green-600);">
                                <i class="bi bi-check-circle-fill" style="font-size:2rem;"></i>
                            </div>
                            <h4 class="fw-700">You Have Already Voted</h4>
                            <p class="text-slate">Your ballot for this election has been recorded.</p>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <form method="POST" action="${pageContext.request.contextPath}/voter/vote" id="voteForm">
                        <input type="hidden" name="_csrf" value="${csrfToken}">
                        <input type="hidden" name="electionId" value="${selectedElection.electionId}">
                        <input type="hidden" name="candidateId" id="selectedCandidateId">

                        <div class="row g-4" id="candidateGrid">
                            <c:forEach var="candidate" items="${candidates}">
                                <div class="col-md-6 col-lg-4">
                                    <div class="ev-candidate-card h-100" onclick="selectCandidate(${candidate.candidateId}, '${candidate.name}')"
                                         data-candidate-id="${candidate.candidateId}" data-candidate-name="${candidate.name}">
                                        <div class="check-indicator">
                                            <i class="bi bi-check2" style="font-size:.8rem;"></i>
                                        </div>
                                        <div class="d-flex align-items-center gap-3 mb-3">
                                            <c:choose>
                                                <c:when test="${candidate.photoUrl != null && !candidate.photoUrl.isEmpty()}">
                                                    <img src="${candidate.photoUrl}" alt="${candidate.name}" class="candidate-photo">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="candidate-photo d-flex align-items-center justify-content-center">
                                                        <i class="bi bi-person-fill text-slate" style="font-size:1.5rem;"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div>
                                                <h6 class="fw-700 mb-0 text-navy">${candidate.name}</h6>
                                                <span class="badge bg-info mt-1">${candidate.party}</span>
                                            </div>
                                        </div>
                                        <c:if test="${candidate.bio != null && !candidate.bio.isEmpty()}">
                                            <p class="text-slate small mb-2" style="display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden;">
                                                ${candidate.bio}
                                            </p>
                                        </c:if>
                                        <c:if test="${candidate.symbolUrl != null && !candidate.symbolUrl.isEmpty()}">
                                            <div class="mt-auto pt-2" style="border-top:1px solid var(--ev-slate-200);">
                                                <div class="text-slate" style="font-size:.65rem;text-transform:uppercase;letter-spacing:.04em;font-weight:600;margin-bottom:.35rem;">Party Symbol</div>
                                                <img src="${candidate.symbolUrl}" alt="${candidate.party} symbol" class="party-symbol">
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="d-flex justify-content-center mt-4">
                            <button type="button" class="btn btn-primary btn-lg px-5" id="submitVoteBtn"
                                    onclick="showConfirmModal()" disabled>
                                <i class="bi bi-check2-circle me-2"></i>Submit Vote
                            </button>
                        </div>
                    </form>

                    <!-- Confirmation Modal -->
                    <div class="modal fade ev-modal" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title fw-700" id="confirmModalLabel">
                                        <i class="bi bi-exclamation-triangle text-warning me-2"></i>Confirm Your Vote
                                    </h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <p class="mb-2">You are about to vote for:</p>
                                    <div class="p-3 rounded-3" style="background:var(--ev-blue-50); border:1px solid var(--ev-blue-100);">
                                        <strong class="text-navy" id="confirmCandidateName"></strong>
                                    </div>
                                    <p class="text-danger small mt-3 mb-0">
                                        <i class="bi bi-exclamation-circle me-1"></i>
                                        <strong>This action cannot be undone.</strong> You will not be able to change your vote.
                                    </p>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                                    <button type="button" class="btn btn-primary" onclick="submitVote()">
                                        <i class="bi bi-check-circle me-1"></i>Confirm Vote
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </c:otherwise>
    </c:choose>
</div>

<script>
let selectedId = null;
let selectedName = '';

function selectCandidate(id, name) {
    selectedId = id;
    selectedName = name;
    document.getElementById('selectedCandidateId').value = id;
    document.getElementById('submitVoteBtn').disabled = false;

    // Update visual state
    document.querySelectorAll('.ev-candidate-card').forEach(card => {
        card.classList.toggle('selected', parseInt(card.dataset.candidateId) === id);
    });
}

function showConfirmModal() {
    if (!selectedId) return;
    document.getElementById('confirmCandidateName').textContent = selectedName;
    new bootstrap.Modal(document.getElementById('confirmModal')).show();
}

function submitVote() {
    bootstrap.Modal.getInstance(document.getElementById('confirmModal')).hide();
    document.getElementById('voteForm').submit();
}
</script>

<jsp:include page="footer.jsp"/>
