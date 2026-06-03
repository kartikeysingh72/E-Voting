# E-Voting Platform — Project Initiation Document

**Project Name:** E-Voting Platform
**Version:** 1.0.0
**Document Type:** Project Initiation Document (PID)
**Status:** Active

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Initial Requirements](#2-initial-requirements)
3. [Technical Foundation](#3-technical-foundation)
4. [Project Goals](#4-project-goals)
5. [Stakeholder Analysis](#5-stakeholder-analysis)
6. [Risk Assessment](#6-risk-assessment)
7. [Development Approach](#7-development-approach)
8. [Resource Planning](#8-resource-planning)
9. [Success Criteria](#9-success-criteria)
10. [Initial Design Decisions](#10-initial-design-decisions)

---

## 1. Project Overview

### 1.1 Purpose

The E-Voting Platform is a secure, web-based electronic voting system designed to digitize and modernize the electoral process for **college elections, society polls, and local body elections**. It replaces traditional paper-based balloting with a fully digital, auditable, and verifiable voting experience that ensures every vote is counted accurately while maintaining voter anonymity.

### 1.2 Scope

The platform encompasses two primary user portals:

| Portal | Scope |
|---|---|
| **Voter Portal** | Self-registration, email OTP verification, admin approval workflow, two-factor login, ballot casting, receipt-based vote verification |
| **Admin Portal** | Election creation and management, candidate onboarding (with photos and party symbols), voter KYC approval, real-time results monitoring, result declaration, CSV/HTML export |

The platform is initially scoped for institutional deployment at a single university (SHUATS), with architecture designed to support multi-institution expansion.

### 1.3 Objectives

1. **Eliminate paper ballots** by providing a fully digital voting process accessible from any web browser
2. **Ensure one-person-one-vote integrity** through application-level checks and database-enforced unique constraints
3. **Provide verifiable audit trails** via unique receipt tokens that allow voters to confirm their vote was counted without revealing their identity
4. **Reduce election administration overhead** with automated registration workflows, digital approval processes, and instant result computation
5. **Maintain ballot secrecy** while enabling post-election auditing through cryptographic receipt tokens

### 1.4 Out of Scope (v1.0)

- Mobile native applications (responsive web only)
- Blockchain-based vote recording
- Multi-language support
- Biometric authentication
- Real-time vote counting display to voters during active elections
- Multi-tenant deployment (single institution per instance)

---

## 2. Initial Requirements

### 2.1 Functional Requirements

| ID | Requirement | Priority |
|---|---|---|
| FR-01 | Voter self-registration with name, email, phone, date of birth, P ID Number, and password | Critical |
| FR-02 | Email OTP verification during registration (6-digit code, 10-minute expiry) | Critical |
| FR-03 | Admin KYC approval workflow (approve/reject pending voters) | Critical |
| FR-04 | Two-factor authentication for voter login (password + email OTP) | Critical |
| FR-05 | Password-only authentication for admin login | Critical |
| FR-06 | Ballot display showing all active elections and candidates with photos, party names, bios, and party symbols | Critical |
| FR-07 | One-click candidate selection with visual confirmation modal before vote submission | Critical |
| FR-08 | One-person-one-vote enforcement per election (application + database layer) | Critical |
| FR-09 | Unique 64-character receipt token generated for each vote cast | Critical |
| FR-10 | Public receipt verification portal (token lookup confirms vote was counted) | Critical |
| FR-11 | Admin election management (create, edit, activate, complete elections) | High |
| FR-12 | Admin candidate management (add candidates with photo URL and party symbol URL) | High |
| FR-13 | Admin results dashboard with per-candidate vote tallies, percentages, and progress bars | High |
| FR-14 | Result declaration (admin marks election as COMPLETED, locks further changes) | High |
| FR-15 | CSV and HTML export of election results | Medium |
| FR-16 | Public results page with election selector dropdown for viewing completed election outcomes | High |
| FR-17 | Admin dashboard with aggregate metrics (registered voters, approved voters, pending approvals, total elections, active elections, ballots cast) | High |
| FR-18 | University email domain restriction during registration (whitelist-based) | High |
| FR-19 | Age verification (voter must be 18+ years old) | Critical |
| FR-20 | Session-based authentication with 30-minute inactivity timeout | Critical |

### 2.2 Non-Functional Requirements

| ID | Requirement | Target |
|---|---|---|
| NFR-01 | **Security** — BCrypt password hashing (cost factor 12) | All passwords never stored in plaintext |
| NFR-02 | **Security** — CSRF protection on all POST requests | Per-session tokens validated by filter |
| NFR-03 | **Security** — SQL injection prevention | 100% PreparedStatement usage across all DAOs |
| NFR-04 | **Security** — HTTP security headers | X-Frame-Options, X-XSS-Protection, X-Content-Type-Options, Cache-Control on every response |
| NFR-05 | **Security** — HttpOnly session cookies | Cookie config in web.xml |
| NFR-06 | **Usability** — Responsive design | Bootstrap 5 grid, functional on mobile/tablet/desktop |
| NFR-07 | **Usability** — Modern, accessible UI | Inter font, consistent design system, Bootstrap Icons |
| NFR-08 | **Performance** — Database indexing | Indexes on email, status, election_id for sub-second query response |
| NFR-09 | **Reliability** — Database connection pooling | Configurable pool size (default: 10 connections) |
| NFR-10 | **Maintainability** — MVC architecture | Clear separation: Servlet → DAO → MySQL → JSP |
| NFR-11 | **Maintainability** — Externalized configuration | Database credentials and SMTP config in app.properties |
| NFR-12 | **Portability** — WAR packaging | Single deployable artifact compatible with any Jakarta EE servlet container |

---

## 3. Technical Foundation

### 3.1 Technology Stack Decisions

| Layer | Technology | Version | Rationale |
|---|---|---|---|
| **Language** | Java | 17 (LTS) | Industry-standard enterprise language; long-term support |
| **Web Framework** | Jakarta Servlets + JSP + JSTL | 6.0 / 3.1 / 3.0 | Lightweight, no heavy framework overhead; native to Jakarta EE |
| **UI Framework** | Bootstrap | 5.3.2 | Rapid responsive frontend development; no build step required |
| **Icons** | Bootstrap Icons | 1.11.3 | Consistent iconography with Bootstrap |
| **Typography** | Inter | Google Fonts | Clean, modern typeface optimized for screen readability |
| **Database** | MySQL | 8.0+ | Mature relational database; wide hosting support |
| **JDBC Driver** | MySQL Connector/J | 8.2.0 | Official MySQL JDBC driver |
| **Servlet Container** | Apache Tomcat | 11.0.22 | Reference implementation for Jakarta EE 10; lightweight |
| **Build Tool** | Maven | 3.x | Standard Java build automation; dependency management |
| **Password Hashing** | jBCrypt | 0.4 | Industry-standard adaptive hashing; cost-factor configurable |
| **Email (OTP)** | Jakarta Mail | 2.0.1 | Standard JavaMail API for SMTP |
| **JSON** | Gson | 2.10.1 | Lightweight JSON serialization for AJAX endpoints |
| **File Upload** | Commons FileUpload + IO | 1.5 / 2.15.1 | Standard library for multipart form handling |
| **CSV Export** | OpenCSV | 5.9 | Purpose-built CSV writing library |
| **PDF Export** | iText | 8.0.2 | Full-featured PDF generation |

**Why not Spring Boot?**
The project was intentionally built on raw Jakarta Servlets rather than Spring Boot to:
- Minimize abstraction layers for educational transparency
- Demonstrate deep understanding of HTTP, servlet lifecycle, filter chains, and JDBC
- Reduce dependency footprint (single WAR, no auto-configuration magic)
- Allow complete control over request/response processing

### 3.2 Architecture Planning

The platform follows a classic **Model-View-Controller (MVC)** pattern:

```
Browser → Filter Chain → Servlet (Controller) → DAO (Model) → MySQL
                                              ↘ JSP (View) ↗
```

**Layer responsibilities:**

| Layer | Components | Responsibility |
|---|---|---|
| **Presentation** | JSP + Bootstrap 5 + CSS design system | HTML rendering, responsive layout, user interaction |
| **Controller** | 13 Jakarta Servlets | Request routing, input validation, session management, response forwarding |
| **Security** | 3 Servlet Filters (CSRF, Auth, AdminAuth) | Cross-cutting security concerns applied declaratively via web.xml |
| **Data Access** | 6 DAO classes | Parameterized SQL queries, row mapping, connection management |
| **Model** | 6 POJO/entity classes | Data structures representing database tables |
| **Utility** | 5 utility classes | Password hashing, email sending, OTP generation, CSRF tokens, DB connections |
| **Database** | MySQL (6 tables + indexes + constraints) | Persistent storage, referential integrity, uniqueness enforcement |

### 3.3 Development Environment Setup

| Component | Specification |
|---|---|
| Operating System | macOS (primary), cross-platform compatible |
| JDK | OpenJDK 17 |
| IDE | Eclipse or IntelliJ IDEA |
| Servlet Container | Apache Tomcat 11.0.22 (Homebrew on macOS) |
| Database | MySQL 8.0+ (localhost:3306) |
| SMTP Provider | Gmail SMTP (smtp.gmail.com:587 with STARTTLS) |
| Build Command | `mvn package -DskipTests -q` |
| Deploy Path | `{TOMCAT_HOME}/webapps/e-voting.war` |
| Application URL | `http://localhost:8080/e-voting/` |

**Project directory structure:**

```
E-Voting/
├── pom.xml                          Maven configuration
├── sql/
│   └── schema.sql                   Database DDL + seed data
├── src/main/
│   ├── java/com/evoting/
│   │   ├── dao/                     6 DAO classes
│   │   ├── filter/                  3 Servlet filters
│   │   ├── model/                   6 Entity classes
│   │   ├── servlet/                 13 Servlets
│   │   └── util/                    5 Utility classes
│   ├── resources/
│   │   └── app.properties           Externalized configuration
│   └── webapp/
│       ├── WEB-INF/
│       │   ├── jsp/                 15 JSP view files
│       │   └── web.xml              Servlet/filter/session config
│       ├── css/
│       │   └── style.css            Design system (329 lines)
│       └── index.jsp                Landing page
└── TECHNICAL_DOCUMENTATION.md       Comprehensive technical docs
```

### 3.4 Database Schema Foundation

Six core tables with defined relationships:

| Table | Records | Key Constraints |
|---|---|---|
| `admins` | Admin accounts | `UNIQUE(username)` |
| `voters` | Registered voters | `UNIQUE(email)`, `UNIQUE(pid_number)` |
| `elections` | Election events | `FK → admins(created_by)` |
| `candidates` | Candidates per election | `FK → elections(election_id)`, `ON DELETE CASCADE` |
| `votes` | Cast ballots | `UNIQUE(voter_id, election_id)`, `UNIQUE(receipt_token)`, `FK → voters/elections/candidates` |
| `otp_store` | Temporary OTP codes | 10-minute expiry, single-use enforcement |

---

## 4. Project Goals

### 4.1 Short-Term Goals (v1.0)

| Goal | Description |
|---|---|
| Complete voter lifecycle | Register → OTP verify → Admin approve → Login with 2FA → Vote → Receipt |
| Admin election management | Create elections, manage candidates (with photos/symbols), approve voters |
| Secure ballot casting | Zero-bias candidate cards, one-click selection, confirmation modal, double-vote prevention |
| Result transparency | Per-election public results with candidate tallies, percentages, and progress bars |
| Receipt auditability | Public verification portal confirming vote inclusion without revealing voter identity |
| Modern UI/UX | Responsive Bootstrap 5 design with consistent design system across all pages |
| Security hardening | CSRF, BCrypt, OTP 2FA, security headers, SQL injection prevention |

### 4.2 Long-Term Goals (Future Phases)

| Phase | Goal |
|---|---|
| **Phase 2** | Multi-tenant support (multiple institutions on one deployment) |
| **Phase 2** | Email-based result notifications to voters |
| **Phase 3** | Ranked-choice / preferential voting method support |
| **Phase 3** | Real-time turnout monitoring dashboard during active elections |
| **Phase 4** | Mobile-responsive bottom navigation for small screens |
| **Phase 4** | PDF receipt generation for voters |
| **Phase 5** | Blockchain-anchored vote hash for additional tamper evidence |
| **Phase 5** | Multi-language UI support |

---

## 5. Stakeholder Analysis

### 5.1 Primary Stakeholders

| Stakeholder | Role | Expectations |
|---|---|---|
| **University Administration** | Project sponsor / decision-maker | Reliable, secure voting that reduces administrative burden; audit-ready results; institutional branding |
| **Election Officers (Admins)** | Platform operators | Intuitive admin dashboard; efficient voter approval workflow; clear result visualization; CSV/HTML export for records |
| **Student Voters** | End users | Simple registration; fast login with OTP; clean ballot interface; receipt confirmation; ability to verify vote was counted |
| **Candidates** | Election participants | Fair presentation on ballot (photo, party, bio, symbol); transparent result publication |

### 5.2 Secondary Stakeholders

| Stakeholder | Role | Expectations |
|---|---|---|
| **IT Department** | Infrastructure & deployment | Easy WAR deployment on existing Tomcat; MySQL database setup; minimal maintenance |
| **University Legal/Compliance** | Regulatory oversight | Audit trail integrity; data privacy; compliance with institutional election rules |
| **Faculty Advisors** | Election oversight | Transparency in vote counting; ability to review results; confidence in system integrity |
| **Future Developers** | Maintenance & extension | Clean code architecture; comprehensive documentation; well-defined package structure |

### 5.3 Stakeholder Communication

| Audience | Communication Approach |
|---|---|
| Non-technical stakeholders | Canvas-based visual documents, high-level flow diagrams, plain-language summaries |
| Technical team | Javadoc, technical documentation with Mermaid diagrams, code-level architecture docs |
| University IT | Deployment guides, configuration reference (app.properties, web.xml), schema DDL |

---

## 6. Risk Assessment

### 6.1 Security Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| SQL Injection | Medium | Critical | 100% PreparedStatement usage across all 6 DAO classes; no string concatenation in queries |
| Cross-Site Request Forgery | Medium | High | Per-session CSRF tokens generated by CSRFUtil; validated by CSRFFilter on every POST |
| Credential theft | Low | Critical | BCrypt hashing (cost 12); never store plaintext passwords |
| Session hijacking | Low | High | HttpOnly session cookies; 30-minute inactivity timeout |
| Clickjacking | Low | Medium | X-Frame-Options: DENY on every response |
| Unauthorized registration | Medium | High | University email domain whitelist validation |
| Double voting | Low | Critical | Two-layer defense: application-level hasVoted() check + database UNIQUE constraint |

### 6.2 Operational Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Email OTP delivery failure | Medium | High | OTP resend capability; configurable SMTP settings; clear error messaging |
| Database connection exhaustion | Low | High | Connection pool with configurable size (default 10); connection reuse pattern |
| Tomcat misconfiguration | Low | Medium | Comprehensive deployment documentation; externalized app.properties |
| Single point of failure (single server) | Medium | High | Future: load balancer + clustered deployment; current: regular database backups |

### 6.3 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Jakarta EE namespace migration issues | Low | Medium | Pinned versions (Servlet 6.0, JSP 3.1); Tomcat 11 verified compatible |
| Browser compatibility | Low | Medium | Bootstrap 5 provides cross-browser support; progressive enhancement |
| Scalability under high concurrent load | Medium | Medium | Database indexing strategy; connection pooling; stateless servlet design |

---

## 7. Development Approach

### 7.1 Methodology: Iterative Development

The project follows an **iterative development approach** with feature-driven increments:

```
Iteration 1 → Core infrastructure (DB schema, DAO layer, auth filters)
Iteration 2 → Voter registration + OTP verification flow
Iteration 3 → Admin login + voter approval workflow
Iteration 4 → Ballot casting + double-vote prevention
Iteration 5 → Receipt generation + public verification
Iteration 6 → Admin election/candidate management
Iteration 7 → Result computation + declaration + export
Iteration 8 → UI/UX redesign (design system, admin sidebar, modern cards)
Iteration 9 → Feature enhancements (domain validation, P ID rename, election selector, symbols)
```

### 7.2 Project Timeline

| Phase | Duration | Deliverables |
|---|---|---|
| **Foundation** | Week 1–2 | Database schema, DAO layer, utility classes, web.xml configuration |
| **Authentication** | Week 3–4 | Registration, OTP verification, login (voter + admin), logout, session management |
| **Voting Core** | Week 5–6 | Election listing, candidate ballot, vote casting, double-vote prevention, receipt generation |
| **Admin Features** | Week 7–8 | Dashboard, election CRUD, candidate CRUD with photo/symbol upload, voter approval |
| **Results & Verification** | Week 9 | Result computation, declaration, CSV/HTML export, public verification, public results |
| **UI/UX Polish** | Week 10–11 | Complete redesign with design system, sidebar navigation, metric cards, progress bars |
| **Hardening** | Week 12 | Security audit, email domain validation, P ID rebranding, documentation, deployment testing |

### 7.3 Version Control

- **Tool:** Git
- **Repository:** Local Git repository (initialized at project root)
- **Branch strategy:** `main` branch for stable releases
- **Ignore rules:** `.gitignore` configured for build outputs, IDE files, environment files, OS files

---

## 8. Resource Planning

### 8.1 Team Roles

| Role | Responsibilities | Skills Required |
|---|---|---|
| **Full-Stack Developer** | Servlet/JSP development, database design, UI implementation, security | Java 17, Jakarta Servlets, JSP/JSTL, MySQL, HTML/CSS/Bootstrap, JDBC |
| **System Administrator** | Tomcat deployment, MySQL setup, SMTP configuration, server management | Linux/macOS administration, Tomcat, MySQL, networking |
| **QA Tester** | Functional testing, security testing, cross-browser testing, load testing | Manual testing, security awareness, browser dev tools |
| **UI/UX Designer** | Design system, responsive layouts, accessibility, user flow optimization | Bootstrap 5, CSS custom properties, UX principles |
| **Project Manager** | Requirements gathering, stakeholder communication, timeline tracking | Agile methodology, documentation, communication |

### 8.2 Infrastructure Requirements

| Resource | Specification | Purpose |
|---|---|---|
| **Development machine** | macOS/Linux, JDK 17, Maven, MySQL, Tomcat 11 | Local development and testing |
| **Database server** | MySQL 8.0+, minimum 512MB RAM, 1GB storage | Persistent data storage |
| **Application server** | Apache Tomcat 11.0.22, minimum 1GB RAM | WAR deployment and HTTP serving |
| **SMTP service** | Gmail account with App Password or institutional SMTP relay | OTP email delivery |
| **Production server** | VPS or cloud instance (AWS EC2, DigitalOcean) | Public-facing deployment |

### 8.3 Software Dependencies (Maven Managed)

All dependencies are declared in `pom.xml` and automatically resolved by Maven:

| Category | Dependencies |
|---|---|
| **Jakarta EE** | Servlet API 6.0, JSP API 3.1, JSTL API 3.0 + GlassFish impl 3.0.1 |
| **Database** | MySQL Connector/J 8.2.0 |
| **Security** | jBCrypt 0.4 |
| **Email** | Jakarta Mail 2.0.1 |
| **Utilities** | Gson 2.10.1, Commons FileUpload 1.5, Commons IO 2.15.1 |
| **Export** | OpenCSV 5.9, iText 8.0.2 |

---

## 9. Success Criteria

### 9.1 Functional Success Criteria

| Criterion | Verification Method |
|---|---|
| Voter can complete full registration → OTP → approval → login → vote → receipt cycle | End-to-end manual testing |
| No voter can cast more than one vote per election | Attempt double-vote; verify error + DB constraint |
| Receipt token verification correctly confirms vote inclusion | Verify valid token → shows election + candidate; invalid token → not found |
| Admin can create election, add candidates, approve voters, and declare results | Full admin workflow testing |
| Public results page displays completed election results with accurate tallies | Compare displayed results with direct database query |
| CSV/HTML export produces accurate, complete result files | Export results; compare with on-screen tallies |

### 9.2 Security Success Criteria

| Criterion | Verification Method |
|---|---|
| All passwords stored as BCrypt hashes (never plaintext) | Database inspection |
| CSRF tokens validated on every POST request | Submit form without token → verify HTTP 403 |
| No SQL injection possible via any input field | Attempt injection on all form fields; verify no execution |
| Security headers present on every HTTP response | Inspect response headers via browser dev tools |
| Sessions expire after 30 minutes of inactivity | Leave session idle; verify redirect to login |
| Only university email domains can register | Attempt registration with non-whitelisted domain; verify rejection |

### 9.3 Usability Success Criteria

| Criterion | Verification Method |
|---|---|
| All pages render correctly on mobile, tablet, and desktop | Responsive testing across viewport sizes |
| Registration form provides real-time age and password feedback | Interactive form testing |
| Ballot page shows clear visual selection indicator and confirmation modal | Cast a vote; verify UX flow |
| Admin sidebar navigation provides consistent access to all management pages | Navigate all admin pages; verify active state highlighting |
| Error messages are user-friendly and actionable | Trigger validation errors; verify message clarity |

### 9.4 Performance Success Criteria

| Criterion | Target |
|---|---|
| Page load time (server response) | < 500ms for all pages |
| Database query response | < 200ms for standard queries |
| OTP email delivery | < 10 seconds from submission |
| Concurrent voter support | 50+ simultaneous voters without degradation |

---

## 10. Initial Design Decisions

### 10.1 Server-Side Rendering (JSP) over Client-Side Framework

| Aspect | Decision | Rationale |
|---|---|---|
| **Rendering** | Server-side (JSP + JSTL) | No build step for frontend; simpler deployment; SEO-friendly; no API layer needed |
| **Alternative considered** | React/Vue SPA + REST API | Rejected due to added complexity (Node.js build, CORS, JWT management, separate deployment) |
| **Trade-off** | Less interactive than SPA | Acceptable for voting use case; forms and page navigation are sufficient |

### 10.2 Jakarta Servlets over Spring Boot

| Aspect | Decision | Rationale |
|---|---|---|
| **Framework** | Raw Jakarta Servlets 6.0 | Educational transparency; minimal abstraction; full control over request lifecycle |
| **Alternative considered** | Spring Boot | Rejected to avoid auto-configuration overhead, annotation-heavy patterns, and dependency injection complexity |
| **Trade-off** | More boilerplate code | Acceptable; explicit configuration in web.xml provides clarity |

### 10.3 MySQL over PostgreSQL

| Aspect | Decision | Rationale |
|---|---|---|
| **Database** | MySQL 8.0+ | Wide hosting availability; familiar to development team; sufficient for project scale |
| **Alternative considered** | PostgreSQL | Rejected due to additional setup complexity; MySQL CHECK constraints and unique indexes are sufficient |
| **Trade-off** | Fewer advanced features | Acceptable; no need for JSON columns, GIS, or full-text search in v1.0 |

### 10.4 BCrypt over Argon2

| Aspect | Decision | Rationale |
|---|---|---|
| **Hashing** | BCrypt (cost 12) | Widely supported in Java ecosystem; proven track record; jBCrypt library is lightweight |
| **Alternative considered** | Argon2 | Rejected due to limited Java library maturity; BCrypt is NIST-recommended and sufficient |
| **Trade-off** | Slower than simple hashes | Intentional; BCrypt's cost factor provides brute-force resistance |

### 10.5 Email OTP over SMS OTP

| Aspect | Decision | Rationale |
|---|---|---|
| **2FA method** | Email-based OTP | No SMS gateway cost; university students have reliable email access; Jakarta Mail is standard |
| **Alternative considered** | SMS OTP (Twilio, etc.) | Rejected due to cost per message and third-party dependency |
| **Trade-off** | Slower delivery than SMS | Acceptable; 10-minute expiry provides ample window |

### 10.6 Receipt Token over Vote Hash

| Aspect | Decision | Rationale |
|---|---|---|
| **Audit trail** | Random 64-char hex token | Simple to verify; no cryptographic knowledge needed by voters; unique per vote |
| **Alternative considered** | SHA-256 hash of vote data | Rejected because hash could theoretically be reversed to reveal voter-candidate link |
| **Trade-off** | Token doesn't prove vote integrity mathematically | Acceptable; database integrity + admin oversight provides sufficient trust |

### 10.7 University Email Domain Restriction

| Aspect | Decision | Rationale |
|---|---|---|
| **Registration** | Whitelist-based domain validation | Ensures only institutional members can register; prevents external abuse |
| **Implementation** | `List<String> ALLOWED_EMAIL_DOMAINS` in RegisterServlet | Easy to extend for additional institutions; configuration-driven |
| **Trade-off** | Limits platform to single institution per config | Acceptable for v1.0; multi-tenant support planned for Phase 2 |

### 10.8 Per-Election Results Selector

| Aspect | Decision | Rationale |
|---|---|---|
| **Public results** | Election selector dropdown (one election at a time) | Cleaner UX than displaying all results simultaneously; mirrors admin results pattern |
| **Alternative considered** | Show all completed elections at once | Rejected due to page length with many elections; poor mobile experience |
| **Trade-off** | Requires one additional click to view results | Acceptable; auto-submit on dropdown change minimizes friction |

### 10.9 Minimal Footer Design

| Aspect | Decision | Rationale |
|---|---|---|
| **Footer** | Clean border separator only (no text or links) | Removes generic boilerplate; navigation already available in header |
| **Trade-off** | No secondary navigation in footer | Acceptable; header provides all necessary links |

---

*This document serves as the foundational reference for the E-Voting Platform project. It should be reviewed and updated as the project evolves through future development phases.*
