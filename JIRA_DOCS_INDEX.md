# Jira Integration Documentation Index

**Last Updated:** 2026-05-13
**Status:** ✅ Complete & Ready for Use

## 📚 All Documentation Files

### 1. **JIRA_WORKFLOW_AUTOMATION.md** (Main Reference)
   **Location:** `/Users/mac/Desktop/data/Taleemabad/coaching-platform/JIRA_WORKFLOW_AUTOMATION.md`
   
   **Contents:**
   - Default ticket configuration (fields, defaults)
   - Workflow transitions (In Progress → QA → Done)
   - Transition IDs for all statuses
   - Slash command definitions (`/jira-ticket`, `/jira-qa`, `/jira-done`)
   - GitHub integration details
   - Status update matrix
   
   **For:** Architects, lead developers, documentation reference

---

### 2. **docs/JIRA_SLASH_COMMANDS.md** (Developer Implementation)
   **Location:** `/Users/mac/Desktop/data/Taleemabad/coaching-platform/docs/JIRA_SLASH_COMMANDS.md`
   
   **Contents:**
   - Complete implementation guide
   - Step-by-step code examples (TypeScript)
   - Composio tool reference
   - Error handling patterns
   - Testing checklist
   - Usage examples with responses
   
   **For:** Backend developers implementing slash commands, integrators

---

### 3. **.claude/skills/jira-ticket/SKILL.md** (Skill Definition)
   **Location:** `/Users/mac/Desktop/data/Taleemabad/coaching-platform/.claude/skills/jira-ticket/SKILL.md`
   
   **Contents:**
   - Slash command syntax (TL;DR reference)
   - Command signatures for all three commands
   - Output formats
   - Field reference
   - Transition matrix
   - Troubleshooting quick reference
   
   **For:** Claude Code users, quick reference

---

### 4. **docs/JIRA_INTEGRATION_SETUP.md** (Setup & Overview)
   **Location:** `/Users/mac/Desktop/data/Taleemabad/coaching-platform/docs/JIRA_INTEGRATION_SETUP.md`
   
   **Contents:**
   - Quick start guide
   - Connection setup instructions
   - Complete workflow example
   - Best practices
   - Troubleshooting guide
   - Historical reference (MC20-18324)
   
   **For:** All team members, new developers, onboarding

---

### 5. **JIRA_DOCS_INDEX.md** (This File)
   **Location:** `/Users/mac/Desktop/data/Taleemabad/coaching-platform/JIRA_DOCS_INDEX.md`
   
   **Contents:**
   - Overview of all documentation
   - How to use each file
   - Quick reference guide
   
   **For:** Navigation and understanding document relationships

---

## 🎯 Quick Navigation

### I want to...

**Create a new Jira ticket:**
→ See: `docs/JIRA_INTEGRATION_SETUP.md` → Quick Start

**Implement the slash commands:**
→ See: `docs/JIRA_SLASH_COMMANDS.md` → Full Implementation Guide

**Understand the workflow:**
→ See: `JIRA_WORKFLOW_AUTOMATION.md` → Workflow Transitions

**Update ticket status:**
→ See: `.claude/skills/jira-ticket/SKILL.md` → `/jira-qa` and `/jira-done` commands

**Troubleshoot a problem:**
→ See: `docs/JIRA_INTEGRATION_SETUP.md` → Troubleshooting

**Set up Jira connection:**
→ See: `docs/JIRA_INTEGRATION_SETUP.md` → Connection & Prerequisites

---

## 📖 Document Purpose Map

```
Team Members / Developers
    ↓
    ├─ Want quick reference → .claude/skills/jira-ticket/SKILL.md
    ├─ Need setup help → docs/JIRA_INTEGRATION_SETUP.md
    └─ Want examples → docs/JIRA_INTEGRATION_SETUP.md (Workflow Example)

Backend Developers / Implementers
    ↓
    ├─ Need code examples → docs/JIRA_SLASH_COMMANDS.md
    ├─ Need Composio reference → docs/JIRA_SLASH_COMMANDS.md (Tool Reference)
    └─ Need error patterns → docs/JIRA_SLASH_COMMANDS.md (Error Handling)

Architects / Leads
    ↓
    ├─ Need complete reference → JIRA_WORKFLOW_AUTOMATION.md
    ├─ Need transition IDs → JIRA_WORKFLOW_AUTOMATION.md (Transition Matrix)
    └─ Need defaults → JIRA_WORKFLOW_AUTOMATION.md (Ticket Creation Defaults)

New Team Members
    ↓
    └─ Start here → docs/JIRA_INTEGRATION_SETUP.md
```

---

## ✅ What's Configured

### Default Ticket Fields
- **Project:** MC20 (Mission Control 2.0)
- **Type:** Story
- **Assignee:** Jalal Khan (jalal.khan@taleemabad.com)
- **Component:** Engineering (ID: 10105)
- **Epic:** MC20-9877 (Product & Engineering)
- **Work Days:** 3

### Status Workflow
```
Backlog → In Progress → QA → Done
   ↓          ↓         ↓      ↓
  Auto    /jira-ticket /jira-qa /jira-done
```

### Transition IDs
- **In Progress:** 31
- **QA:** 51
- **Done:** 41

### GitHub Integration
- 🌿 Branch links (clickable in Jira)
- 🔗 PR links (direct to GitHub)
- Auto-formatted comments with details

---

## 🚀 Getting Started (30 seconds)

### 1. Verify Connection
```bash
composio link jira
```

### 2. Create Your First Ticket
```bash
/jira-ticket "My Feature" "Description here" "COACH-my-feature" "42"
```

### 3. Move Through Workflow
```bash
/jira-qa MC20-18325      # Code review done
/jira-done MC20-18325    # Merged to main
```

---

## 📋 Ticket Creation Checklist

- [ ] Title is descriptive
- [ ] Description explains what needs to be built
- [ ] GitHub branch name starts with `COACH-`
- [ ] GitHub PR number is correct
- [ ] Composio Jira connection is active
- [ ] Ticket created successfully (ticket key returned)
- [ ] Ticket appears in MC20 project with "In Progress" status
- [ ] GitHub links are visible in Jira ticket

---

## 🔗 File Relationships

```
JIRA_INTEGRATION_SETUP.md (Overview & Setup)
         ↓
         ├─→ JIRA_WORKFLOW_AUTOMATION.md (Main Reference)
         ├─→ docs/JIRA_SLASH_COMMANDS.md (Implementation)
         └─→ .claude/skills/jira-ticket/SKILL.md (Quick Reference)

All files reference each other for complete understanding
```

---

## 📞 Support

### Connection Issues
→ Run: `composio link jira` and `composio link github`

### Command Not Working
→ Check: `docs/JIRA_INTEGRATION_SETUP.md` → Troubleshooting

### Need Code Examples
→ See: `docs/JIRA_SLASH_COMMANDS.md` → Implementation

### Need Architecture Overview
→ Read: `JIRA_WORKFLOW_AUTOMATION.md` → Full guide

---

## Version History

| Date | Change | File |
|------|--------|------|
| 2026-05-13 | Created complete documentation set | All files |
| 2026-05-13 | Reference ticket: MC20-18324 | JIRA_WORKFLOW_AUTOMATION.md |
| 2026-05-13 | Slash commands ready for use | All files |

---

## 🎓 Learning Path

**New to Jira integration?**

1. Start: `docs/JIRA_INTEGRATION_SETUP.md`
2. Practice: Create a test ticket with `/jira-ticket`
3. Reference: `.claude/skills/jira-ticket/SKILL.md` when needed
4. Deep dive: `JIRA_WORKFLOW_AUTOMATION.md` for complete understanding

---

## ✨ Key Features

✅ **One-command ticket creation** with all defaults
✅ **Automatic "In Progress" status** on creation
✅ **GitHub integration** (branch + PR links)
✅ **Workflow automation** (In Progress → QA → Done)
✅ **Consistent configuration** across all tickets
✅ **Zero-setup needed** (just use `/jira-ticket`)

---

**Last Updated:** 2026-05-13
**Status:** ✅ Ready for Production Use
**Reference:** MC20-18324 (Randomize scenario answers, lock practice section, rename to Practice Section)
