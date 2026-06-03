package com.evoting.model;

import java.time.LocalDateTime;

/**
 * Face embedding template entity.
 * Stores the ArcFace embedding vector (not raw images) for a voter.
 */
public class FaceTemplate {

    private int templateId;
    private int voterId;
    private String embeddingJson;
    private String modelVersion;
    private LocalDateTime capturedAt;
    private boolean isActive;

    public FaceTemplate() {}

    public FaceTemplate(int voterId, String embeddingJson, String modelVersion) {
        this.voterId = voterId;
        this.embeddingJson = embeddingJson;
        this.modelVersion = modelVersion;
        this.isActive = true;
    }

    public int getTemplateId() { return templateId; }
    public void setTemplateId(int templateId) { this.templateId = templateId; }

    public int getVoterId() { return voterId; }
    public void setVoterId(int voterId) { this.voterId = voterId; }

    public String getEmbeddingJson() { return embeddingJson; }
    public void setEmbeddingJson(String embeddingJson) { this.embeddingJson = embeddingJson; }

    public String getModelVersion() { return modelVersion; }
    public void setModelVersion(String modelVersion) { this.modelVersion = modelVersion; }

    public LocalDateTime getCapturedAt() { return capturedAt; }
    public void setCapturedAt(LocalDateTime capturedAt) { this.capturedAt = capturedAt; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}
