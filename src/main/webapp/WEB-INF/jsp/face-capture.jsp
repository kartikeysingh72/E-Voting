<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="header.jsp">
    <jsp:param name="title" value="Face Capture - E-Voting Platform"/>
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-lg-6 col-md-8">
            <div class="ev-card">
                <div class="card-body p-4 p-md-5">
                    <div class="text-center mb-4">
                        <div class="d-inline-flex align-items-center justify-content-center rounded-circle mb-3"
                             style="width:56px;height:56px;background:var(--ev-blue-100);color:var(--ev-blue-600);">
                            <i class="bi bi-camera-video fs-4"></i>
                        </div>
                        <h3 class="fw-800 text-navy mb-1">Face Registration</h3>
                        <p class="text-slate small mb-0">Position your face in the oval guide and capture a photo.</p>
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

                    <div id="successBox" class="alert alert-success d-none">
                        <i class="bi bi-check-circle me-2"></i>Face captured successfully! Redirecting...
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
                            <div class="face-oval-guide" style="width:180px;height:240px;border:3px dashed rgba(37,99,235,.6);border-radius:50%;"></div>
                        </div>
                        <canvas id="captureCanvas" class="d-none"></canvas>
                    </div>

                    <!-- Instructions -->
                    <div class="text-center mb-3">
                        <p class="text-slate small mb-0">
                            <i class="bi bi-info-circle me-1"></i>
                            Ensure good lighting and remove sunglasses/masks.
                        </p>
                    </div>

                    <!-- Capture Button -->
                    <div class="d-grid gap-2">
                        <button id="captureBtn" class="btn btn-primary btn-lg" disabled>
                            <i class="bi bi-camera me-2"></i>Capture Face
                        </button>
                        <button id="retakeBtn" class="btn btn-outline-secondary d-none">
                            <i class="bi bi-arrow-counterclockwise me-2"></i>Retake
                        </button>
                    </div>

                    <!-- Loading spinner -->
                    <div id="loadingSpinner" class="text-center mt-3 d-none">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Processing...</span>
                        </div>
                        <p class="text-slate small mt-2 mb-0">Extracting face features...</p>
                    </div>
                </div>
            </div>

            <p class="text-center mt-3 text-slate small">
                <i class="bi bi-shield-lock me-1"></i>
                Only a mathematical representation of your face is stored -- not the image itself.
            </p>
        </div>
    </div>
</div>

<!-- Expose CSRF token for AJAX requests -->
<meta name="csrf-token" content="${csrfToken}">
<script src="${pageContext.request.contextPath}/js/face-capture.js"></script>

<jsp:include page="footer.jsp"/>
