# Jira Integration Setup - Complete Guide

**Last Updated:** 2026-05-13
**Status:** Fully Configured & Ready
**Connected Services:** Jira + GitHub via Composio

---

## Overview

The coaching platform has full Jira automation integrated via Composio MCP for creating and managing tickets. This guide covers:

1. ✅ **Slash Commands** — `/jira-ticket`, `/jira-qa`, `/jira-done`
2. ✅ **Default Configuration** — Auto-assigned to Jalal Khan, Engineering component, Epic MC20-9877
3. ✅ **Status Workflow** — In Progress → QA → Done
4. ✅ **GitHub Integration** — Branch & PR links attached automatically

---

## Quick Start

### Step 1: Verify Jira Connection

```bash
composio link jira
```

This confirms your Jira account is connected to Composio.

### Step 2: Create First Ticket

```bash
/jira-ticket "Implement dark mode" "Add dark theme support" "COACH-dark-mode" "42"
```

Returns:
```
✅ Jira Ticket Created: MC20-18325
🔗 Browse: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: In Progress
🌿 Branch: COACH-dark-mode
🔗 PR: #42
```

### Step 3: Move Through Workflow

```bash
/jira-qa MC20-18325      # When code review passed
/jira-done MC20-18325    # When merged to main
```

---

## Slash Commands Reference

### `/jira-ticket` — Create & Auto-Configure

**Usage:**
```
/jira-ticket "Title" "[Description]" "[Branch]" "[PR#]"
```

**What it does:**
- ✅ Creates Story in MC20 project
- ✅ Sets assignee: Jalal Khan
- ✅ Sets component: Engineering
- ✅ Sets epic: MC20-9877
- ✅ Sets work days: 3
- ✅ Transitions to "In Progress" immediately
- ✅ Adds GitHub links (if provided)

**Example:**
```
/jira-ticket "Randomize scenario answers" "Implement Fisher-Yates shuffle and lock practice section" "COACH-training-flow-improvements" "90"
```

---

### `/jira-qa` — Move to QA Status

**Usage:**
```
/jira-qa MC20-XXXXX
```

**What it does:**
- ✅ Transitions: In Progress → QA
- ✅ Adds comment: "Moved to QA for testing"
- ✅ Updates timestamp

**Example:**
```
/jira-qa MC20-18324
```

---

### `/jira-done` — Mark as Completed

**Usage:**
```
/jira-done MC20-XXXXX
```

**What it does:**
- ✅ Transitions: QA → Done
- ✅ Sets resolution: Done
- ✅ Adds comment: "Merged to main - Completed"
- ✅ Updates timestamp

**Example:**
```
/jira-done MC20-18324
```

---

## Complete Workflow Example

### Scenario: Implement Dark Mode Feature

#### 1️⃣ **Start Development** (Day 1)
```bash
/jira-ticket "Implement dark mode" "Add dark theme with localStorage support and system preference detection" "COACH-dark-mode" "42"
```

**Result:**
```
✅ MC20-18325 created in "In Progress"
🔗 https://orendatrust.atlassian.net/browse/MC20-18325
🌿 Branch: COACH-dark-mode
🔗 PR: #42
```

#### 2️⃣ **Code Review Passed** (Day 3)
```bash
/jira-qa MC20-18325
```

**Result:**
```
✅ MC20-18325 → QA
📊 Status: QA
Comment: "Moved to QA for testing"
```

#### 3️⃣ **QA Passed & Merged** (Day 5)
```bash
/jira-done MC20-18325
```

**Result:**
```
✅ MC20-18325 → Done
📊 Status: Done
Comment: "Merged to main - Completed"
```

---

## Default Ticket Configuration

Every ticket created via `/jira-ticket` includes:

| Field | Value | Purpose |
|-------|-------|---------|
| Project | MC20 | Mission Control 2.0 |
| Type | Story | Feature work |
| Assignee | Jalal Khan | Owner/Reviewer |
| Component | Engineering | Team responsibility |
| Epic | MC20-9877 | Strategic initiative |
| Work Days | 3 | Time estimate |
| Initial Status | In Progress | Immediate activation |

---

## Project Settings

### MC20 Project Details
- **Key:** MC20
- **Name:** Mission Control 2.0
- **Type:** Software Project
- **Board:** Agile (Kanban)

### Epic Details
- **Key:** MC20-9877
- **Name:** Product & Engineering
- **Status:** In Progress
- **Priority:** High

### Component Details
- **ID:** 10105
- **Name:** Engineering
- **Description:** For all the engineering tasks

---

## GitHub Integration

When you provide branch & PR to `/jira-ticket`:

### What Gets Linked

| Element | Location | Format | Example |
|---------|----------|--------|---------|
| Branch | Description | Code format | `COACH-dark-mode` |
| PR | Description | Link format | `[PR #42](https://github.com/.../pull/42)` |
| PR URL | Comment | Clickable | Full GitHub PR URL |
| Commit List | Comment | Auto-detected | From PR metadata |

### Example GitHub Links in Jira

**Description Section:**
```
🌿 GitHub Branch: `COACH-dark-mode`

🔗 GitHub PR: #42
https://github.com/taleemabad/coaching-platform/pull/42
```

**Comments Section:**
```
🌿 **GitHub Branch:** COACH-dark-mode

🔗 **GitHub PR:** #42
https://github.com/taleemabad/coaching-platform/pull/42

**Changes Included:**
- Implement dark mode UI
- Add theme toggle
- Persist preference to localStorage
- Detect system preference
```

---

## Status Transitions

### Transition Matrix

```
┌─────────────┐
│   Backlog   │ ← New tickets start here
└──────┬──────┘
       │ /jira-ticket (automatic)
       ▼
┌─────────────────┐
│  In Progress    │ ← Development active
└────────┬────────┘
         │ /jira-qa
         ▼
     ┌─────┐
     │ QA  │ ← Testing in progress
     └──┬──┘
        │ /jira-done
        ▼
┌──────────┐
│   Done   │ ← Merged to main
└──────────┘
```

### Transition Details

| Command | From | To | Transition ID | Auto-Added Comment |
|---------|------|----|----|---|
| `/jira-ticket` | — | In Progress | 31 | (description only) |
| `/jira-qa` | In Progress | QA | 51 | "Moved to QA for testing" |
| `/jira-done` | QA | Done | 41 | "Merged to main - Completed" |

---

## Connection & Prerequisites

### Required Setup

✅ **Jira Connected:**
```bash
composio link jira
```

✅ **GitHub Connected:**
```bash
composio link github
```

✅ **Permissions:**
- Create Issue in MC20 project
- Transition Issues
- Add Comments to Issues

### Verify Connection

```bash
# Check Jira connection
composio whoami jira

# Check GitHub connection
composio whoami github
```

---

## Error Troubleshooting

### Problem: "Jira not connected"

**Solution:**
```bash
composio link jira
# Follow OAuth flow to authenticate
```

### Problem: Ticket not created

**Solution:**
- Verify Jira connection: `composio link jira`
- Check MC20 project exists
- Verify you have "Create Issue" permission

### Problem: GitHub links not showing

**Solution:**
- Ensure branch name is lowercase with hyphens
- Ensure PR number is numeric only
- Links are created in Description section

### Problem: Wrong assignee or component

**Solution:**
- Defaults are hardcoded in SKILL.md
- To change: Update JIRA_WORKFLOW_AUTOMATION.md
- To override single ticket: Manually edit in Jira UI

---

## File Reference Guide

### Main Documentation

| File | Purpose | Audience |
|------|---------|----------|
| [JIRA_WORKFLOW_AUTOMATION.md](../JIRA_WORKFLOW_AUTOMATION.md) | Complete automation guide | Architects, DevOps |
| [docs/JIRA_SLASH_COMMANDS.md](./JIRA_SLASH_COMMANDS.md) | Implementation guide | Developers, Integrators |
| [.claude/skills/jira-ticket/SKILL.md](../.claude/skills/jira-ticket/SKILL.md) | Skill definition | AI/Claude users |

### Configuration Files

| File | Contains |
|------|----------|
| `JIRA_WORKFLOW_AUTOMATION.md` | Defaults, transitions, status IDs |
| `.claude/skills/jira-ticket/SKILL.md` | Slash command specs |
| `docs/JIRA_SLASH_COMMANDS.md` | Developer implementation |
| `docs/JIRA_INTEGRATION_SETUP.md` | This file (setup & overview) |

---

## Best Practices

### ✅ Do

- Use `/jira-ticket` at the **start** of feature development
- Include GitHub branch & PR when you have them
- Use `/jira-qa` when code review is **approved**
- Use `/jira-done` immediately after **merging to main**
- Reference the ticket key in PR title: `MC20-18325: Feature name`

### ❌ Don't

- Manually edit defaults (they're optimized)
- Create tickets for non-engineering work (MC20 = Engineering)
- Skip status updates (automation relies on them)
- Create duplicate tickets (check MC20 backlog first)

---

## Automation Benefits

By using these slash commands, you get:

| Benefit | How It Works |
|---------|-------------|
| **Consistency** | Every ticket has same defaults |
| **Speed** | One command creates + configures ticket |
| **Traceability** | GitHub links built-in |
| **Workflow** | Status transitions automated |
| **Reporting** | Epic MC20-9877 aggregates all work |

---

## Example Commands (Copy & Paste)

### Create a New Feature Ticket
```bash
/jira-ticket "Feature name here" "Brief description" "COACH-feature-name" "42"
```

### Move Existing Ticket to QA
```bash
/jira-qa MC20-18325
```

### Move Ticket to Done
```bash
/jira-done MC20-18325
```

---

## Support & Questions

### Where to Find Help

1. **Jira Integration Issues:** See "Troubleshooting" above
2. **Slash Command Questions:** See [JIRA_SLASH_COMMANDS.md](./JIRA_SLASH_COMMANDS.md)
3. **Workflow Questions:** See [JIRA_WORKFLOW_AUTOMATION.md](../JIRA_WORKFLOW_AUTOMATION.md)
4. **Composio Connection:** `composio link jira` and `composio link github`

### Report a Bug

If a slash command fails:
1. Check Jira connection: `composio link jira`
2. Verify GitHub connection: `composio link github`
3. Try the command again
4. If still failing, screenshot the error and report

---

## Historical Reference

**Created:** 2026-05-13
**Reference Ticket:** MC20-18324 (Randomize scenario answers, lock practice section, rename to Practice Section)
**Test Status:** ✅ All automated commands verified working
**GitHub PR:** [#90](https://github.com/taleemabad/coaching-platform/pull/90)

---

## Next Steps

1. ✅ Verify Jira connection: `composio link jira`
2. ✅ Create your first ticket: `/jira-ticket "Your feature" "Description"`
3. ✅ Move through workflow: `/jira-qa` → `/jira-done`
4. ✅ Reference in PRs: Use MC20-XXXXX in titles

**You're all set!** Start creating tickets with `/jira-ticket` 🚀
