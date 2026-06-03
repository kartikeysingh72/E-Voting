<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../header.jsp">
    <jsp:param name="title" value="Manage Candidates - Admin"/>
</jsp:include>

<!-- Sidebar -->
<div class="ev-sidebar" id="adminSidebar">
    <div class="sidebar-heading">Main</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard" class="sidebar-link"><i class="bi bi-grid-1x2"></i>Dashboard</a>
    <a href="${pageContext.request.contextPath}/admin/elections" class="sidebar-link"><i class="bi bi-calendar-event"></i>Elections</a>
    <a href="${pageContext.request.contextPath}/admin/candidates" class="sidebar-link active"><i class="bi bi-person-vcard"></i>Candidates</a>
    <div class="sidebar-heading">Management</div>
    <a href="${pageContext.request.contextPath}/admin/voters" class="sidebar-link"><i class="bi bi-people"></i>Voter Approvals</a>
    <a href="${pageContext.request.contextPath}/admin/results" class="sidebar-link"><i class="bi bi-bar-chart-fill"></i>Results</a>
</div>
<button class="btn btn-outline-secondary d-lg-none position-fixed" style="top:68px;left:8px;z-index:101;"
        onclick="document.getElementById('adminSidebar').classList.toggle('show')"><i class="bi bi-list"></i></button>

<!-- Main Content -->
<div class="ev-main">
    <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
        <div>
            <h2 class="fw-800 text-navy mb-0">Candidates</h2>
            <p class="text-slate small mb-0">Add and manage candidates for each election.</p>
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
            <form method="GET" action="${pageContext.request.contextPath}/admin/candidates" class="row g-3 align-items-end">
                <div class="col-md-6">
                    <label class="form-label"><i class="bi bi-calendar-event me-1"></i>Select Election</label>
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
    <div class="row g-4">
        <!-- Add/Edit Candidate Form -->
        <div class="col-lg-4">
            <div class="ev-card">
                <div class="card-header d-flex align-items-center gap-2">
                    <i class="bi bi-${candidate != null ? 'pencil-square' : 'person-plus'} text-primary"></i>
                    <span class="fw-700">${candidate != null ? 'Edit Candidate' : 'Add Candidate'}</span>
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
                            <label class="form-label"><i class="bi bi-person me-1"></i>Candidate Name</label>
                            <input type="text" name="name" class="form-control" required
                                   placeholder="Full name"
                                   value="${candidate != null ? candidate.name : ''}">
                        </div>

                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-building me-1"></i>Party / Group</label>
                            <input type="text" name="party" class="form-control" required
                                   placeholder="Party or independent"
                                   value="${candidate != null ? candidate.party : ''}">
                        </div>

                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-card-text me-1"></i>Bio / Manifesto</label>
                            <textarea name="bio" class="form-control" rows="2"
                                      placeholder="Short bio or campaign statement...">${candidate != null ? candidate.bio : ''}</textarea>
                        </div>

                        <!-- Photo Upload Target -->
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-camera me-1"></i>Candidate Photo</label>
                            <div class="ev-dropzone" id="photoDropzone">
                                <i class="bi bi-cloud-arrow-up" style="font-size:1.5rem;color:var(--ev-slate-400);"></i>
                                <span class="small text-slate">Drag &amp; drop or click to upload</span>
                                <input type="url" name="photoUrl" class="form-control form-control-sm mt-2"
                                       placeholder="Or paste image URL here..."
                                       value="${candidate != null ? candidate.photoUrl : ''}">
                            </div>
                        </div>

                        <!-- Symbol Upload Target -->
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-shield-check me-1"></i>Party Symbol</label>
                            <div class="ev-dropzone" id="symbolDropzone">
                                <i class="bi bi-cloud-arrow-up" style="font-size:1.5rem;color:var(--ev-slate-400);"></i>
                                <span class="small text-slate">Drag &amp; drop or click to upload</span>
                                <input type="url" name="symbolUrl" class="form-control form-control-sm mt-2"
                                       placeholder="Or paste symbol URL here..."
                                       value="${candidate != null ? candidate.symbolUrl : ''}">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-${candidate != null ? 'pencil' : 'person-plus'} me-1"></i>
                            ${candidate != null ? 'Update Candidate' : 'Add Candidate'}
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Candidate List -->
        <div class="col-lg-8">
            <div class="ev-card">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-people text-primary"></i>
                        <span class="fw-700">Candidates for: ${selectedElection.title}</span>
                    </div>
                    <span class="badge bg-primary">${candidates.size()} candidates</span>
                </div>
                <div class="card-body p-0">
                    <c:choose>
                        <c:when test="${!empty candidates}">
                            <div class="table-responsive">
                                <table class="table ev-table mb-0">
                                    <thead>
                                        <tr>
                                            <th>Candidate</th>
                                            <th>Party</th>
                                            <th>Bio</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="c" items="${candidates}">
                                            <tr>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <c:choose>
                                                            <c:when test="${c.photoUrl != null && !empty c.photoUrl}">
                                                                <img src="${c.photoUrl}" class="rounded-circle" style="width:36px;height:36px;object-fit:cover;border:2px solid var(--ev-slate-200);">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="rounded-circle d-flex align-items-center justify-content-center"
                                                                     style="width:36px;height:36px;background:var(--ev-slate-100);color:var(--ev-slate-400);font-size:.8rem;font-weight:700;">
                                                                    ${c.name.substring(0,1)}
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <strong>${c.name}</strong>
                                                    </div>
                                                </td>
                                                <td><span class="badge bg-info">${c.party}</span></td>
                                                <td>
                                                    <small class="text-slate">
                                                        ${c.bio != null ? (c.bio.length() > 40 ? c.bio.substring(0,40).concat('...') : c.bio) : '-'}
                                                    </small>
                                                </td>
                                                <td>
                                                    <div class="d-flex gap-1">
                                                        <a href="${pageContext.request.contextPath}/admin/candidates?action=edit&id=${c.candidateId}&electionId=${selectedElectionId}"
                                                           class="btn btn-sm btn-outline-primary btn-icon" title="Edit">
                                                            <i class="bi bi-pencil"></i>
                                                        </a>
                                                        <form method="POST" action="${pageContext.request.contextPath}/admin/candidates" class="d-inline"
                                                              onsubmit="return confirm('Delete this candidate?')">
                                                            <input type="hidden" name="_csrf" value="${csrfToken}">
                                                            <input type="hidden" name="action" value="delete">
                                                            <input type="hidden" name="id" value="${c.candidateId}">
                                                            <input type="hidden" name="electionId" value="${selectedElectionId}">
                                                            <button type="submit" class="btn btn-sm btn-outline-danger btn-icon" title="Delete">
                                                                <i class="bi bi-trash"></i>
                                                            </button>
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
                                <i class="bi bi-person-plus text-slate" style="font-size:2.5rem;"></i>
                                <p class="text-slate mt-2 mb-0">No candidates added yet. Use the form to add candidates.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
    </c:if>
</div>

<script>
// Drag-and-drop visual feedback for dropzones
document.querySelectorAll('.ev-dropzone').forEach(function(zone) {
    zone.addEventListener('dragover', function(e) {
        e.preventDefault();
        zone.classList.add('dragover');
    });
    zone.addEventListener('dragleave', function() {
        zone.classList.remove('dragover');
    });
    zone.addEventListener('drop', function(e) {
        e.preventDefault();
        zone.classList.remove('dragover');
        if (e.dataTransfer.files.length > 0) {
            var reader = new FileReader();
            reader.onload = function(ev) {
                var input = zone.querySelector('input[type="url"]');
                if (input) input.value = ev.target.result;
            };
            reader.readAsDataURL(e.dataTransfer.files[0]);
        }
    });
});
</script>

<jsp:include page="../footer.jsp"/>
