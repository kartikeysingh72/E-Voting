<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Face Verification - E-Voting Platform"/>
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-6 col-md-8">
            <div class="ev-card">
                <div class="card-body p-4 p-md-5">
                    <div class="text-center mb-4">
                        <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                             style="width:56px;height:56px;background:var(--ev-green-100);color:var(--ev-green-600);">
                            <i class="bi bi-shield-check fs-4"></i>
                        </div>
                        <h3 class="fw-800 text-navy mb-1">Face Verification</h3>
                        <p class="text-slate small mb-0">Verify your identity to access the ballot.</p>
                    </div>

                    <div id="errorBox" class="alert alert-danger d-none">
                        <i class="bi bi-exclamation-circle me-2"></i><span id="errorMsg"></span>
                    </div>

                    <c:if test="${modelError}">
                        <div class="alert alert-warning">
                            <i class="bi bi-exclamation-triangle me-2"></i>
                            <strong>Face recognition model is not loaded.</strong><br>
                            The ONNX model may not be deployed correctly. Please ensure the model file exists at
                            <code>src/main/resources/models/arcface_r100.onnx</code> and restart the server.
                        </div>
                    </c:if>

                    <c:if test="${noTemplate}">
                        <div class="alert alert-warning">
                            <i class="bi bi-person-x me-2"></i>
                            <strong>No face template found for your account.</strong><br>
                            Your face was not registered during the registration process.
                            Please contact an administrator for assistance.
                        </div>
                    </c:if>

                    <div id="successBox" class="alert alert-success d-none">
                        <i class="bi bi-check-circle me-2"></i>Identity verified! Redirecting to ballot...
                    </div>

                    <!-- Attempt counter -->
                    <div class="text-center mb-3">
                        <span class="badge bg-info" id="attemptBadge">
                            Attempt <span id="currentAttempt">1</span> of ${maxAttempts}
                        </span>
                    </div>

                    <!-- Camera Container -->
                    <div class="face-camera-container position-relative mx-auto mb-4" style="max-width:400px;">
                        <div class="ratio ratio-4x3 rounded overflow-hidden border border-2 border-secondary-subtle">
                            <video id="webcamVideo" autoplay playsinline muted class="w-100 h-100"
                                   style="object-fit:cover;transform:scaleX(-1);"></video>
                        </div>
                        <!-- Oval overlay guide -->
                        <div class="face-oval-overlay position-absolute top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center"
                             style="pointer-events:none;">
                            <div class="face-oval-guide" style="width:180px;height:240px;border:3px dashed rgba(5,150,105,.6);border-radius:50%;"></div>
                        </div>
                        <canvas id="captureCanvas" class="d-none"></canvas>
                    </div>

                    <div class="text-center mb-3">
                        <p class="text-slate small mb-0">
                            <i class="bi bi-info-circle me-1"></i>
                            Look directly at the camera. Good lighting improves accuracy.
                        </p>
                    </div>

                    <div class="d-grid gap-2">
                        <button id="verifyBtn" class="btn btn-success btn-lg" disabled>
                            <i class="bi bi-shield-check me-2"></i>Verify Face
                        </button>
                    </div>

                    <!-- Loading spinner -->
                    <div id="loadingSpinner" class="text-center mt-3 d-none">
                        <div class="spinner-border text-success" role="status">
                            <span class="visually-hidden">Verifying...</span>
                        </div>
                        <p class="text-slate small mt-2 mb-0">Verifying identity...</p>
                    </div>

                    <!-- Bypass token form (shown after max attempts) -->
                    <div id="bypassSection" class="mt-4 d-none">
                        <hr>
                        <h6 class="fw-700 text-navy mb-2">
                            <i class="bi bi-key me-1"></i>Admin Bypass Token
                        </h6>
                        <p class="text-slate small mb-2">Enter a bypass token provided by your administrator.</p>
                        <form id="bypassForm">
                            <div class="input-group">
                                <input type="text" id="bypassToken" class="form-control"
                                       placeholder="Enter bypass token" required>
                                <button type="submit" class="btn btn-outline-primary">Submit</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Expose CSRF token for AJAX requests -->
<meta name="csrf-token" content="${csrfToken}">
<script src="${pageContext.request.contextPath}/js/face-verify.js"></script>

<jsp:include page="footer.jsp"/>
