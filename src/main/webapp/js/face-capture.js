/**
 * Face capture page JavaScript.
 * Handles webcam access, frame capture, and server submission.
 */
(function() {
    'use strict';

    const video = document.getElementById('webcamVideo');
    const canvas = document.getElementById('captureCanvas');
    const captureBtn = document.getElementById('captureBtn');
    const retakeBtn = document.getElementById('retakeBtn');
    const errorBox = document.getElementById('errorBox');
    const errorMsg = document.getElementById('errorMsg');
    const successBox = document.getElementById('successBox');
    const loadingSpinner = document.getElementById('loadingSpinner');

    let stream = null;
    let captured = false;

    // Initialize webcam
    async function initCamera() {
        try {
            if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                showError('Your browser does not support camera access. Please use a modern browser (Chrome, Firefox, Safari, Edge).');
                return;
            }

            stream = await navigator.mediaDevices.getUserMedia({
                video: {
                    facingMode: 'user',
                    width: { ideal: 640 },
                    height: { ideal: 480 }
                },
                audio: false
            });

            video.srcObject = stream;
            video.onloadedmetadata = function() {
                video.play();
                captureBtn.disabled = false;
            };

        } catch (err) {
            if (err.name === 'NotAllowedError') {
                showError('Camera access was denied. Please allow camera permissions and reload the page.');
            } else if (err.name === 'NotFoundError') {
                showError('No camera found. Please connect a camera and reload the page.');
            } else {
                showError('Camera error: ' + err.message);
            }
        }
    }

    // Capture frame from video
    function captureFrame() {
        if (!video.videoWidth) return null;

        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;

        const ctx = canvas.getContext('2d');
        // Mirror the capture (video is displayed mirrored)
        ctx.translate(canvas.width, 0);
        ctx.scale(-1, 1);
        ctx.drawImage(video, 0, 0);

        return canvas.toDataURL('image/png');
    }

    // Submit captured image to server
    async function submitCapture(base64Image) {
        captureBtn.disabled = true;
        captureBtn.classList.add('d-none');
        retakeBtn.classList.add('d-none');
        loadingSpinner.classList.remove('d-none');

        // Read CSRF token from meta tag
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';

        try {
            const params = new URLSearchParams({ image: base64Image, _csrf: csrfToken });

            const resp = await fetch(window.location.pathname, {
                method: 'POST',
                body: params,
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            });

            const data = await resp.json();

            if (data.success) {
                successBox.classList.remove('d-none');
                // Stop camera
                if (stream) {
                    stream.getTracks().forEach(t => t.stop());
                }
                // Redirect after brief delay
                setTimeout(function() {
                    window.location.href = data.redirect;
                }, 1000);
            } else {
                showError(data.error || 'Face capture failed. Please try again.');
                resetCaptureUI();
            }

        } catch (err) {
            showError('Network error: ' + err.message);
            resetCaptureUI();
        }
    }

    function showError(msg) {
        errorBox.classList.remove('d-none');
        errorMsg.textContent = msg;
    }

    function hideError() {
        errorBox.classList.add('d-none');
        errorMsg.textContent = '';
    }

    function resetCaptureUI() {
        loadingSpinner.classList.add('d-none');
        captureBtn.classList.remove('d-none');
        captureBtn.disabled = false;
        retakeBtn.classList.add('d-none');
        captured = false;
    }

    // Event listeners
    captureBtn.addEventListener('click', function() {
        hideError();
        const base64 = captureFrame();
        if (base64) {
            captured = true;
            retakeBtn.classList.remove('d-none');
            submitCapture(base64);
        } else {
            showError('Could not capture frame. Please ensure the camera is active.');
        }
    });

    retakeBtn.addEventListener('click', function() {
        hideError();
        resetCaptureUI();
    });

    // Cleanup on page unload
    window.addEventListener('beforeunload', function() {
        if (stream) {
            stream.getTracks().forEach(t => t.stop());
        }
    });

    // Start camera on page load
    initCamera();
})();
