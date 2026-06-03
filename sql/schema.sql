-- ============================================================
-- E-Voting Platform Database Schema
-- MySQL 8.0+
-- ============================================================

DROP DATABASE IF EXISTS e_voting;
CREATE DATABASE e_voting CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE e_voting;

-- ============================================================
-- Admin Table
-- ============================================================
CREATE TABLE admins (
    admin_id        INT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(50)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    full_name       VARCHAR(100) NOT NULL,
    role            VARCHAR(20)  NOT NULL DEFAULT 'ADMIN',
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- Voters Table
-- ============================================================
CREATE TABLE voters (
    voter_id        INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    phone           VARCHAR(15)  NOT NULL,
    dob             DATE         NOT NULL,
    pid_number      VARCHAR(50)  NOT NULL UNIQUE COMMENT 'University P ID Number',
    password_hash   VARCHAR(255) NOT NULL,
    is_verified     BOOLEAN      NOT NULL DEFAULT FALSE COMMENT 'Email OTP verified',
    is_approved     BOOLEAN      NOT NULL DEFAULT FALSE COMMENT 'Admin approved (KYC)',
    status          VARCHAR(20)  NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING, APPROVED, REJECTED',
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- Elections Table
-- ============================================================
CREATE TABLE elections (
    election_id     INT AUTO_INCREMENT PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    start_date      DATETIME     NOT NULL,
    end_date        DATETIME     NOT NULL,
    status          VARCHAR(20)  NOT NULL DEFAULT 'SCHEDULED' COMMENT 'SCHEDULED, ACTIVE, COMPLETED, CANCELLED',
    created_by      INT          NOT NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_election_admin FOREIGN KEY (created_by) REFERENCES admins(admin_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- Candidates Table
-- ============================================================
CREATE TABLE candidates (
    candidate_id    INT AUTO_INCREMENT PRIMARY KEY,
    election_id     INT          NOT NULL,
    name            VARCHAR(100) NOT NULL,
    party           VARCHAR(100) NOT NULL,
    bio             TEXT,
    photo_url       VARCHAR(500),
    symbol_url      VARCHAR(500),
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_candidate_election FOREIGN KEY (election_id) REFERENCES elections(election_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- Votes Table
-- ============================================================
CREATE TABLE votes (
    vote_id         INT AUTO_INCREMENT PRIMARY KEY,
    voter_id        INT          NOT NULL,
    election_id     INT          NOT NULL,
    candidate_id    INT          NOT NULL,
    receipt_token   VARCHAR(64)  NOT NULL UNIQUE COMMENT 'Unique audit-trail token',
    timestamp       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- One vote per voter per election
    CONSTRAINT uq_voter_election UNIQUE (voter_id, election_id),

    CONSTRAINT fk_vote_voter     FOREIGN KEY (voter_id)     REFERENCES voters(voter_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_vote_election  FOREIGN KEY (election_id)  REFERENCES elections(election_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_vote_candidate FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- OTP Store Table
-- ============================================================
CREATE TABLE otp_store (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    email           VARCHAR(150) NOT NULL,
    otp_code        VARCHAR(6)   NOT NULL,
    purpose         VARCHAR(20)  NOT NULL DEFAULT 'LOGIN' COMMENT 'REGISTRATION, LOGIN',
    is_used         BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at      TIMESTAMP    NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL 10 MINUTE),

    INDEX idx_otp_email (email, is_used, created_at DESC)
) ENGINE=InnoDB;

-- ============================================================
-- Default Admin Account
-- Password: admin123 (BCrypt hashed)
-- ============================================================
INSERT INTO admins (username, password_hash, full_name, role)
VALUES ('admin', '$2a$12$9H8EGDuLFWowd26jT30DyekBKoU9AzG2CSuBM.MW93SLghDyG22sy', 'System Administrator', 'SUPER_ADMIN');

-- ============================================================
-- Indexes for performance
-- ============================================================
CREATE INDEX idx_voters_email    ON voters(email);
CREATE INDEX idx_elections_status ON elections(status);
CREATE INDEX idx_candidates_election ON candidates(election_id);
CREATE INDEX idx_votes_election  ON votes(election_id);

-- ============================================================
-- Face Templates Table (stores embeddings, NOT raw images)
-- ============================================================
CREATE TABLE face_templates (
    template_id     INT AUTO_INCREMENT PRIMARY KEY,
    voter_id        INT          NOT NULL,
    embedding_json  LONGTEXT     NOT NULL COMMENT 'JSON array of float[512] ArcFace embedding',
    model_version   VARCHAR(50)  NOT NULL DEFAULT 'arcface-onnx-1.0',
    captured_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_face_voter FOREIGN KEY (voter_id) REFERENCES voters(voter_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- Face Verifications Audit Log
-- ============================================================
CREATE TABLE face_verifications (
    verification_id INT AUTO_INCREMENT PRIMARY KEY,
    voter_id        INT          NOT NULL,
    action          VARCHAR(30)  NOT NULL COMMENT 'REGISTRATION, LOGIN_VOTE, ADMIN_BYPASS',
    match_score     DECIMAL(5,4) NULL COMMENT 'Cosine similarity score (0.0000-1.0000)',
    threshold_used  DECIMAL(5,4) NOT NULL DEFAULT 0.6000,
    passed          BOOLEAN      NOT NULL DEFAULT FALSE,
    bypass_token    VARCHAR(64)  NULL COMMENT 'Admin-issued one-time bypass token',
    bypass_used     BOOLEAN      NOT NULL DEFAULT FALSE COMMENT 'Whether this bypass token has been consumed',
    ip_address      VARCHAR(45)  NULL,
    user_agent      VARCHAR(500) NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_face_verif_voter (voter_id, created_at DESC),
    CONSTRAINT fk_face_verif_voter FOREIGN KEY (voter_id) REFERENCES voters(voter_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- Alter Voters: add face registration flag
-- ============================================================
ALTER TABLE voters ADD COLUMN face_registered BOOLEAN NOT NULL DEFAULT FALSE
    COMMENT 'Whether face embedding has been captured';
