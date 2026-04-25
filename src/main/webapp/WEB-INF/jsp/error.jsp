<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Error - E-Voting Platform"/>
</jsp:include>

<div class="row justify-content-center">
    <div class="col-md-6 text-center py-5">
        <i class="bi bi-exclamation-triangle text-danger" style="font-size: 5rem;"></i>
        <h2 class="mt-3">Oops! Something went wrong.</h2>
        <p class="text-muted">
            ${requestScope['jakarta.servlet.error.message'] != null ?
              requestScope['jakarta.servlet.error.message'] :
              'An unexpected error occurred. Please try again.'}
        </p>
        <a href="${pageContext.request.contextPath}/" class="btn btn-primary me-2">
            <i class="bi bi-house"></i> Go Home
        </a>
        <a href="javascript:history.back()" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-left"></i> Go Back
        </a>
    </div>
</div>

<jsp:include page="footer.jsp"/>
