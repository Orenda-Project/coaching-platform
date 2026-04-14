# Coaching Platform Documentation

Welcome to the Coaching Platform documentation hub. This directory contains all guides, architecture docs, feature references, and testing checklists organized by category.

---

## 🚀 Quick Start

**New to the project?** Start here:

- **[Getting Started](SETUP/QUICK_START.md)** — Local development setup, running the dev server, creating test accounts
- **[Quick Verify](TESTING/QUICK_VERIFY.md)** — Quick sanity checks to confirm everything works

---

## 📚 Documentation by Category

### Architecture & Design
Learn how the system is structured and why design decisions were made.

- **[System Architecture](ARCHITECTURE/COACHING_PLATFORM_ARCHITECTURE.md)** — Complete system design, database schema, API patterns, user flows
- **[Executive Summary](ARCHITECTURE/COACHING_PLATFORM_EXECUTIVE_SUMMARY.md)** — Business context, problem statement, solution overview
- **[Roadmap](ARCHITECTURE/COACHING_PLATFORM_ROADMAP.md)** — Phase-by-phase planning: Phase 1 (complete ✓), Phase 2, Phase 3

### Setup & Environment
Configure your local development environment and understand deployment.

- **[Quick Start](SETUP/QUICK_START.md)** — Step-by-step local setup with Supabase and npm
- **[Setup Checklist](SETUP/SETUP_CHECKLIST.md)** — Staging/production infrastructure setup
- **[Environment Summary](DEPLOYMENT/ENVIRONMENT_SUMMARY.md)** — GitHub branches, Railway projects, Supabase details
- **[Deployment Guide](DEPLOYMENT/DEPLOYMENT.md)** — Staging → Production workflow, GitHub Actions, rollback procedures

### Features
Detailed guides on how each major feature works.

- **[Assessment System](FEATURES/ASSESSMENT_SYSTEM.md)** — Baseline, Endline, Module Quiz assessments
- **[Learning Flow](FEATURES/LEARNING_FLOW.md)** — Scenario-First learning model (Phase 1)
- **[User Profiles](FEATURES/PROFILE_SYSTEM.md)** — Profile management, editing, data persistence
- **[Analytics](FEATURES/ANALYTICS.md)** — Event tracking, data collection, dashboard metrics

### Testing
Run E2E tests, verify functionality, ensure quality before deployment.

- **[Testing Checklist](TESTING/TESTING_CHECKLIST_PHASE_1.md)** — Comprehensive Phase 1 test cases with step-by-step instructions
- **[Quick Verify](TESTING/QUICK_VERIFY.md)** — 5-minute smoke tests
- **[Staging Verification](TESTING/STAGING_VERIFICATION.md)** — Confirm staging environment is ready

### Reference
Technical references and standards.

- **[Development Standards](REFERENCE/DEVELOPMENT_STANDARDS.md)** — Git workflow, code standards, PR requirements
- **[Project Map](REFERENCE/PROJECT_MAP.md)** — Codebase overview, key thresholds, file structure
- **[Theme System](REFERENCE/THEME_SYSTEM.md)** — CSS variables, color system, design consistency
- **[Glossary](REFERENCE/GLOSSARY.md)** — Term definitions and concepts

### Phase 1 Documentation
Complete Phase 1 (Scenario-First Learning) implementation details.

- **[Phase 1 Index](PHASE_1/PHASE_1_DOCUMENTATION_INDEX.md)** — Navigation hub for Phase 1 docs with workflows and quick links
- **[Phase 1 Completion](PHASE_1/PHASE_1_COMPLETION_SUMMARY.md)** — What was built, database schema, components, routes
- **[Session Summary](PHASE_1/SESSION_SUMMARY_2026_04_14.md)** — Deliverables overview, technical highlights, patterns applied

---

## 🎯 By Role

### **For Developers**
1. Read: [System Architecture](ARCHITECTURE/COACHING_PLATFORM_ARCHITECTURE.md)
2. Setup: [Quick Start](SETUP/QUICK_START.md)
3. Code: Review [Development Standards](REFERENCE/DEVELOPMENT_STANDARDS.md)
4. Test: [Testing Checklist](TESTING/TESTING_CHECKLIST_PHASE_1.md)

### **For QA Engineers**
1. Setup: [Quick Start](SETUP/QUICK_START.md)
2. Test: [Testing Checklist](TESTING/TESTING_CHECKLIST_PHASE_1.md) (detailed test cases)
3. Verify: [Staging Verification](TESTING/STAGING_VERIFICATION.md)
4. Report: Use issue template in GitHub

### **For Project Managers**
1. Overview: [Executive Summary](ARCHITECTURE/COACHING_PLATFORM_EXECUTIVE_SUMMARY.md)
2. Timeline: [Roadmap](ARCHITECTURE/COACHING_PLATFORM_ROADMAP.md)
3. Status: [Phase 1 Completion](PHASE_1/PHASE_1_COMPLETION_SUMMARY.md)
4. Next: [Phase 2 in Roadmap](ARCHITECTURE/COACHING_PLATFORM_ROADMAP.md#phase-2-regional-admin--content-personalization)

### **For DevOps / Infrastructure**
1. Setup: [Environment Summary](DEPLOYMENT/ENVIRONMENT_SUMMARY.md)
2. Deploy: [Deployment Guide](DEPLOYMENT/DEPLOYMENT.md)
3. Troubleshoot: [Deployment Guide - Troubleshooting](DEPLOYMENT/DEPLOYMENT.md#troubleshooting)
4. Standards: [Development Standards](REFERENCE/DEVELOPMENT_STANDARDS.md)

### **For Stakeholders**
1. Context: [Executive Summary](ARCHITECTURE/COACHING_PLATFORM_EXECUTIVE_SUMMARY.md)
2. Progress: [Phase 1 Completion](PHASE_1/PHASE_1_COMPLETION_SUMMARY.md)
3. Timeline: [Roadmap](ARCHITECTURE/COACHING_PLATFORM_ROADMAP.md)
4. Demo: Ask dev team to follow [Quick Start](SETUP/QUICK_START.md)

---

## 📖 Reading Guide

**New to the codebase?**
1. Start with [System Architecture](ARCHITECTURE/COACHING_PLATFORM_ARCHITECTURE.md) — big picture
2. Read [Executive Summary](ARCHITECTURE/COACHING_PLATFORM_EXECUTIVE_SUMMARY.md) — context & goals
3. Follow [Quick Start](SETUP/QUICK_START.md) — hands-on setup
4. Explore [Phase 1 Completion](PHASE_1/PHASE_1_COMPLETION_SUMMARY.md) — what's built

**Making a code change?**
1. Check [Development Standards](REFERENCE/DEVELOPMENT_STANDARDS.md) — rules & git workflow
2. Review [Project Map](REFERENCE/PROJECT_MAP.md) — file structure & patterns
3. Make changes, test locally
4. Follow [Testing Checklist](TESTING/TESTING_CHECKLIST_PHASE_1.md) if Phase 1 related
5. Create PR per standards

**Deploying to production?**
1. Read [Deployment Guide](DEPLOYMENT/DEPLOYMENT.md) — complete workflow
2. Check [Staging Verification](TESTING/STAGING_VERIFICATION.md) — confirm ready
3. Follow staging → main process
4. Keep [Environment Summary](DEPLOYMENT/ENVIRONMENT_SUMMARY.md) for reference

---

## Key Concepts

### **Assessment System**
- **Baseline:** Initial assessment (60% pass) → assigns persona (A/B/C/D) + weak modules
- **Endline:** Final assessment (70% pass) → issues certificate (only 16 MCQ count toward score, 4 open-ended for review)
- **Module Quiz:** Per-module assessment (80% pass) → unlocks next module

### **Learning Model**
- **Scenario-First:** Users make decisions on real scenarios first, then see feedback and optional deep learning content
- **Phase flow:** Scenario → Feedback → Reveal slides → Expandable depth → Summary

### **Persona System**
- **A:** 75%+ on baseline (advanced coach)
- **B:** 70-74% (proficient coach)
- **C:** 65-69% (developing coach)
- **D:** 60-64% (beginning coach)

### **Weak Modules**
Modules where user scored <70% on baseline assessment. Flagged for remedial training and required completion before endline.

---

## 🔗 Quick Links

| Need | Link |
|------|------|
| Start developing | [Quick Start](SETUP/QUICK_START.md) |
| Understand architecture | [System Architecture](ARCHITECTURE/COACHING_PLATFORM_ARCHITECTURE.md) |
| Run tests | [Testing Checklist](TESTING/TESTING_CHECKLIST_PHASE_1.md) |
| Deploy code | [Deployment Guide](DEPLOYMENT/DEPLOYMENT.md) |
| View roadmap | [Roadmap](ARCHITECTURE/COACHING_PLATFORM_ROADMAP.md) |
| Development rules | [Development Standards](REFERENCE/DEVELOPMENT_STANDARDS.md) |
| Code structure | [Project Map](REFERENCE/PROJECT_MAP.md) |

---

## 📋 Site Map

```
docs/
├── README.md (you are here)
├── ARCHITECTURE/
│   ├── COACHING_PLATFORM_ARCHITECTURE.md
│   ├── COACHING_PLATFORM_EXECUTIVE_SUMMARY.md
│   └── COACHING_PLATFORM_ROADMAP.md
├── SETUP/
│   ├── QUICK_START.md
│   └── SETUP_CHECKLIST.md
├── DEPLOYMENT/
│   ├── DEPLOYMENT.md
│   └── ENVIRONMENT_SUMMARY.md
├── FEATURES/
│   ├── ASSESSMENT_SYSTEM.md
│   ├── LEARNING_FLOW.md
│   ├── PROFILE_SYSTEM.md
│   └── ANALYTICS.md
├── TESTING/
│   ├── TESTING_CHECKLIST_PHASE_1.md
│   ├── QUICK_VERIFY.md
│   └── STAGING_VERIFICATION.md
├── REFERENCE/
│   ├── DEVELOPMENT_STANDARDS.md
│   ├── PROJECT_MAP.md
│   ├── THEME_SYSTEM.md
│   └── GLOSSARY.md
└── PHASE_1/
    ├── PHASE_1_DOCUMENTATION_INDEX.md
    ├── PHASE_1_COMPLETION_SUMMARY.md
    └── SESSION_SUMMARY_2026_04_14.md
```

---

## 🆘 Need Help?

- **Can't find what you need?** Check the [Glossary](REFERENCE/GLOSSARY.md)
- **Problem with setup?** See [Quick Start - Troubleshooting](SETUP/QUICK_START.md#troubleshooting)
- **Deployment issue?** Check [Deployment Guide - Troubleshooting](DEPLOYMENT/DEPLOYMENT.md#troubleshooting)
- **Questions about code?** Review [Project Map](REFERENCE/PROJECT_MAP.md)
- **Feedback?** Open an issue on GitHub

---

**Last Updated:** 2026-04-14
**Status:** Comprehensive documentation with Phase 1 complete and Phase 2 planned
