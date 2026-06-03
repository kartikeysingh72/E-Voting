/**
 * Face verification page JavaScript.
 * Handles webcam access, frame capture, verification, and bypass token submission.
 */
(function() {
    'use strict';

    const video = document.getElementById('webcamVideo');
    const canvas = document.getElementById('captureCanvas');
    const verifyBtn = document.getElementById('verifyBtn');
    const errorBox = document.getElementById('errorBox');
    const errorMsg = document.getElementById('errorMsg');
    const successBox = document.getElementById('successBox');
    const loadingSpinner = document.getElementById('loadingSpinner');
    const currentAttemptEl = document.getElementById('currentAttempt');
    const attemptBadge = document.getElementById('attemptBadge');
    const bypassSection = document.getElementById('bypassSection');
    const bypassForm = document.getElementById('bypassForm');
    const bypassTokenInput = document.getElementById('bypassToken');

    let stream = null;
    let currentAttempt = 1;

    // Initialize webcam
    async function initCamera() {
        try {
            if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                showError('Your browser does not support camera access. Please use a modern browser.');
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
                verifyBtn.disabled = false;
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
        ctx.translate(canvas.width, 0);
        ctx.scale(-1, 1);
        ctx.drawImage(video, 0, 0);

        return canvas.toDataURL('image/png');
    }

    // Submit for verification
    async function submitVerify(base64Image) {
        verifyBtn.disabled = true;
        loadingSpinner.classList.remove('d-none');

        // Read CSRF token from meta tag
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';

        try {
            const resp = await fetch(window.location.pathname, {
                method: 'POST',
                body: new URLSearchParams({ image: base64Image, _csrf: csrfToken }),
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            });

            const data = await resp.json();

            if (data.success) {
                successBox.classList.remove('d-none');
                if (stream) {
                    stream.getTracks().forEach(t => t.stop());
                }
                setTimeout(function() {
                    window.location.href = data.redirect;
                }, 800);

            } else if (data.locked) {
                showError(data.error);
                verifyBtn.classList.add('d-none');
                bypassSection.classList.remove('d-none');
                attemptBadge.className = 'badge bg-danger';
                attemptBadge.textContent = 'Locked';
                if (stream) {
                    stream.getTracks().forEach(t => t.stop());
                }

            } else {
                showError(data.error || 'Verification failed. Please try again.');
                currentAttempt++;
                currentAttemptEl.textContent = currentAttempt;
                verifyBtn.disabled = false;
            }

        } catch (err) {
            showError('Network error: ' + err.message);
            verifyBtn.disabled = false;
        }

        loadingSpinner.classList.add('d-none');
    }

    // Submit bypass token
    async function submitBypass(token) {
        loadingSpinner.classList.remove('d-none');
        bypassForm.querySelector('button').disabled = true;

        // Read CSRF token from meta tag
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';

        try {
            const resp = await fetch(window.location.pathname, {
                method: 'POST',
                body: new URLSearchParams({ bypassToken: token, _csrf: csrfToken }),
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            });

            const data = await resp.json();

            if (data.success) {
                successBox.classList.remove('d-none');
                bypassSection.classList.add('d-none');
                setTimeout(function() {
                    window.location.href = data.redirect;
                }, 800);
            } else {
                showError(data.error || 'Invalid or expired bypass token.');
                bypassForm.querySelector('button').disabled = false;
            }

        } catch (err) {
            showError('Network error: ' + err.message);
            bypassForm.querySelector('button').disabled = false;
        }

        loadingSpinner.classList.add('d-none');
    }

    function showError(msg) {
        errorBox.classList.remove('d-none');
        errorMsg.textContent = msg;
    }

    function hideError() {
        errorBox.classList.add('d-none');
        errorMsg.textContent = '';
    }

    // Event listeners
    verifyBtn.addEventListener('click', function() {
        hideError();
        const base64 = captureFrame();
        if (base64) {
            submitVerify(base64);
        } else {
            showError('Could not capture frame. Please ensure the camera is active.');
        }
    });

    bypassForm.addEventListener('submit', function(e) {
        e.preventDefault();
        hideError();
        const token = bypassTokenInput.value.trim();
        if (token) {
            submitBypass(token);
        }
    });

    window.addEventListener('beforeunload', function() {
        if (stream) {
            stream.getTracks().forEach(t => t.stop());
        }
    });

    initCamera();
})();
