<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Error - E-Voting Platform"/>
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="ev-card">
                <div class="card-body text-center p-5">
                    <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                         style="width:72px;height:72px;background:var(--ev-red-100);color:var(--ev-red-600);">
                        <i class="bi bi-exclamation-triangle-fill" style="font-size:2.5rem;"></i>
                    </div>
                    <h3 class="fw-800 text-navy mb-2">Something Went Wrong</h3>
                    <c:if test="${requestScope['jakarta.servlet.error.message'] != null}">
                        <div class="alert alert-danger small mb-3">
                            ${requestScope['jakarta.servlet.error.message']}
                        </div>
                    </c:if>
                    <p class="text-slate small mb-4">
                        An unexpected error occurred. Please try again or contact the administrator.
                    </p>
                    <div class="d-flex justify-content-center gap-2">
                        <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                            <i class="bi bi-house me-1"></i>Go Home
                        </a>
                        <a href="javascript:history.back()" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left me-1"></i>Go Back
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="footer.jsp"/>
