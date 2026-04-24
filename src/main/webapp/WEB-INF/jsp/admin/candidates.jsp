<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../header.jsp">
    <jsp:param name="title" value="Manage Candidates - Admin"/>
</jsp:include>

<div class="d-flex justify-content-between align-items-center mb-4">
    <h2><i class="bi bi-people"></i> Manage Candidates</h2>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline-secondary">
        <i class="bi bi-arrow-left"></i> Dashboard
    </a>
</div>

<c:if test="${success != null}"><div class="alert alert-success">${success}</div></c:if>
<c:if test="${error != null}"><div class="alert alert-danger">${error}</div></c:if>

<!-- Election Selector -->
<div class="card shadow-sm mb-4">
    <div class="card-body">
        <form method="GET" action="${pageContext.request.contextPath}/admin/candidates" class="row g-2 align-items-end">
            <div class="col-md-6">
                <label class="form-label">Select Election</label>
                <select name="electionId" class="form-select" onchange="this.form.submit()">
                    <option value="">-- Choose Election --</option>
                    <c:forEach var="e" items="${elections}">
                        <option value="${e.electionId}" ${e.electionId == selectedElectionId ? 'selected' : ''}>
                            ${e.title} (${e.status})
                        </option>
                    </c:forEach>
                </select>
            </div>
        </form>
    </div>
</div>

<c:if test="${selectedElectionId != null}">
<div class="row">
    <!-- Add/Edit Candidate Form -->
    <div class="col-md-4">
        <div class="card shadow-sm">
            <div class="card-header bg-primary text-white">
                <h5 class="mb-0">${candidate != null ? 'Edit Candidate' : 'Add Candidate'}</h5>
            </div>
            <div class="card-body">
                <form method="POST" action="${pageContext.request.contextPath}/admin/candidates">
                    <input type="hidden" name="_csrf" value="${csrfToken}">
                    <input type="hidden" name="action" value="${candidate != null ? 'update' : 'add'}">
                    <input type="hidden" name="electionId" value="${selectedElectionId}">
                    <c:if test="${candidate != null}">
                        <input type="hidden" name="id" value="${candidate.candidateId}">
                    </c:if>

                    <div class="mb-3">
                        <label class="form-label">Candidate Name</label>
                        <input type="text" name="name" class="form-control" required
                               value="${candidate != null ? candidate.name : ''}">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Party / Group</label>
                        <input type="text" name="party" class="form-control" required
                               value="${candidate != null ? candidate.party : ''}">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Bio / Manifesto</label>
                        <textarea name="bio" class="form-control" rows="2">${candidate != null ? candidate.bio : ''}</textarea>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Photo URL</label>
                        <input type="url" name="photoUrl" class="form-control"
                               value="${candidate != null ? candidate.photoUrl : ''}"
                               placeholder="https://...">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Symbol URL</label>
                        <input type="url" name="symbolUrl" class="form-control"
                               value="${candidate != null ? candidate.symbolUrl : ''}"
                               placeholder="https://...">
                    </div>

                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-${candidate != null ? 'pencil' : 'plus'}"></i>
                        ${candidate != null ? 'Update Candidate' : 'Add Candidate'}
                    </button>
                </form>
            </div>
        </div>
    </div>

    <!-- Candidate List -->
    <div class="col-md-8">
        <div class="card shadow-sm">
            <div class="card-header"><h5 class="mb-0">Candidates for: ${selectedElection.title}</h5></div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${!empty candidates}">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-light">
                                    <tr><th>Name</th><th>Party</th><th>Bio</th><th>Actions</th></tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="c" items="${candidates}">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <c:if test="${c.photoUrl != null && !empty c.photoUrl}">
                                                        <img src="${c.photoUrl}" class="rounded-circle me-2" style="width:35px;height:35px;object-fit:cover;">
                                                    </c:if>
                                                    <strong>${c.name}</strong>
                                                </div>
                                            </td>
                                            <td><span class="badge bg-info">${c.party}</span></td>
                                            <td><small class="text-muted">${c.bio}</small></td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/admin/candidates?action=edit&id=${c.candidateId}&electionId=${selectedElectionId}"
                                                   class="btn btn-sm btn-outline-primary">
                                                    <i class="bi bi-pencil"></i>
                                                </a>
                                                <form method="POST" action="${pageContext.request.contextPath}/admin/candidates" class="d-inline"
                                                      onsubmit="return confirm('Delete this candidate?')">
                                                    <input type="hidden" name="_csrf" value="${csrfToken}">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="${c.candidateId}">
                                                    <input type="hidden" name="electionId" value="${selectedElectionId}">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger">
                                                        <i class="bi bi-trash"></i>
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted text-center">No candidates added yet. Use the form to add candidates.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>
</c:if>

<jsp:include page="../footer.jsp"/>
