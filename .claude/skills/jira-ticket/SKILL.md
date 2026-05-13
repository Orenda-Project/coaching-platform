# Slash Command: `/jira-ticket`

## Overview

Fully automates Jira ticket creation with:
- ✅ Default fields (assignee, component, epic)
- ✅ Immediate "In Progress" status transition
- ✅ GitHub branch & PR linking
- ✅ Comprehensive description with acceptance criteria

## Usage

### Basic (Title Only)
```
/jira-ticket "Feature Title"
```

### With Description
```
/jira-ticket "Feature Title" "Detailed description of what needs to be built"
```

### With GitHub Integration
```
/jira-ticket "Feature Title" "Description" "COACH-branch-name" "42"
```

**Parameters:**
- `title` (required): Feature title for the ticket
- `description` (optional): Detailed feature description
- `branch` (optional): GitHub branch name (e.g., `COACH-dark-mode`)
- `pr` (optional): GitHub PR number (e.g., `42`)

## What It Does

### 1. Create Jira Ticket (MC20 Project)
- **Type:** Story
- **Assignee:** Jalal Khan
- **Component:** Team Coaching (ID: 10590)
- **Epic:** MC20-9877
- **Work Days:** 3

### 2. Transition Status
Automatically moves from "Backlog" → **"In Progress"**

### 3. Add GitHub Links (Optional)
If branch/PR provided:
- Adds 🌿 Branch link to description
- Adds 🔗 PR link to description
- Creates clickable comments with full URLs

## Output

```
✅ Jira Ticket Created: MC20-18325
🔗 Browse: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: In Progress
🎯 Assigned: Jalal Khan
🏷️  Component: Engineering
📌 Epic: MC20-9877
```

**With GitHub:**
```
✅ Jira Ticket Created: MC20-18325
🔗 Browse: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: In Progress
🌿 Branch: COACH-dark-mode
🔗 PR: #42 → https://github.com/taleemabad/coaching-platform/pull/42
```

---

# Slash Command: `/jira-qa`

## Overview

Moves a ticket from "In Progress" → "QA" status for testing.

## Usage

```
/jira-qa MC20-18325
```

**Parameters:**
- `ticket-key` (required): Jira ticket key (e.g., MC20-18325)

## What It Does

- Transitions status: In Progress → **QA**
- Adds comment: "Moved to QA for testing"
- Updates timestamp

## Output

```
✅ MC20-18325 moved to QA
🔗 Browse: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: QA
⏱️  Updated: 2026-05-13 18:30:45
```

---

# Slash Command: `/jira-done`

## Overview

Moves a ticket from "QA" → "Done" status (marks as completed after main merge).

## Usage

```
/jira-done MC20-18325
```

**Parameters:**
- `ticket-key` (required): Jira ticket key (e.g., MC20-18325)

## What It Does

- Transitions status: QA → **Done**
- Sets resolution: "Done"
- Adds comment: "Merged to main - Completed"
- Updates timestamp

## Output

```
✅ MC20-18325 moved to Done
🔗 Browse: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: Done
⏱️  Updated: 2026-05-13 18:45:22
```

---

## Full Workflow Example

### 1. Start Feature Development
```
/jira-ticket "Implement dark mode" "Add dark theme support with localStorage" "COACH-dark-mode" "42"
```
✅ Creates `MC20-18325` in "In Progress" with GitHub links

### 2. Code Review Passed → QA
```
/jira-qa MC20-18325
```
✅ Moves to "QA" for testing

### 3. QA Passed → Merge to Main
```
/jira-done MC20-18325
```
✅ Moves to "Done" after merge

---

## Default Ticket Configuration

All tickets created via `/jira-ticket` include:

```json
{
  "project": "MC20",
  "type": "Story",
  "assignee": "Jalal Khan (jalal.khan@taleemabad.com)",
  "component": "Engineering (ID: 10105)",
  "epic": "MC20-9877 (Product & Engineering)",
  "workDays": 3,
  "status": "In Progress (automatic)"
}
```

---

## GitHub Integration

When you provide branch & PR:

**Description includes:**
- 🌿 Branch name (code-formatted)
- 🔗 PR number with direct link
- Commit details (if available)

**Comments include:**
- Full GitHub branch URL
- Full GitHub PR URL
- Changes summary

---

## Transition Matrix

| Command | From Status | To Status | Transition ID |
|---------|------------|-----------|---------------|
| `/jira-ticket` | Backlog | In Progress | 31 |
| `/jira-qa` | In Progress | QA | 51 |
| `/jira-done` | QA | Done | 41 |

---

## Error Handling

### Invalid Ticket Key
```
❌ MC20-XXXXX not found
💡 Check the ticket key and try again
```

### Already in Target Status
```
⚠️  MC20-18325 is already in "In Progress"
💡 Use /jira-qa to move to QA
```

### Composio Connection Error
```
❌ Failed to connect to Jira
💡 Run: composio link jira
```

---

## Tips & Tricks

### Bulk Create with GitHub
```bash
# Create multiple tickets in quick succession
/jira-ticket "Feature 1" "" "COACH-feature-1" "50"
/jira-ticket "Feature 2" "" "COACH-feature-2" "51"
/jira-ticket "Feature 3" "" "COACH-feature-3" "52"
```

### Copy Ticket Key to Clipboard
After creating, the ticket key is returned. Use it for status updates:
```
/jira-qa MC20-18325
/jira-done MC20-18325
```

### View Full Ticket Details
Click the returned URL to view the ticket in Jira:
```
https://orendatrust.atlassian.net/browse/MC20-18325
```

---

## Reference: All Available Fields

| Field | Value | Notes |
|-------|-------|-------|
| Project | MC20 | Mission Control 2.0 |
| Type | Story | Always Story |
| Summary | Your Title | Auto-populated |
| Description | Your Description | Optional, markdown supported |
| Assignee | Jalal Khan | Always Jalal Khan |
| Component | Engineering | Always Engineering (ID: 10105) |
| Epic Link | MC20-9877 | Always Product & Engineering epic |
| Work Days | 3 | Default estimate |
| GitHub Branch | Your Branch | Optional, clickable link |
| GitHub PR | Your PR # | Optional, clickable link |

---

## Implementation Details

### Composio Tools Used

1. **Create Ticket:**
   - Tool: `JIRA_CREATE_ISSUE`
   - Fields: project, issuetype, summary, assignee, components, epic

2. **Transition Status:**
   - Tool: `JIRA_TRANSITION_ISSUE`
   - IDs: 31 (In Progress), 51 (QA), 41 (Done)

3. **Add GitHub Links:**
   - Tool: `JIRA_ADD_COMMENT`
   - Format: Markdown with clickable URLs

### Connection Requirements

- ✅ Jira connected via Composio
- ✅ GitHub connected via Composio
- ✅ User permissions: Create Issue, Transition Issue, Add Comments

### Verify Connection

```bash
composio link jira      # Verify Jira connection
composio link github    # Verify GitHub connection
```

---

## Troubleshooting

### "Assignee not found"
- Make sure "Jalal Khan" is an active user in Jira
- Alternative: Manually assign after creation

### "Component not found"
- Engineering component ID: `10105`
- If changed, update JIRA_WORKFLOW_AUTOMATION.md

### "Epic not found"
- Epic key: `MC20-9877` (Product & Engineering)
- If changed, update customfield_10014 value

### "GitHub links not clickable"
- Ensure branch name uses lowercase with hyphens
- Ensure PR number is numeric only
- Links are created in description and comments

---

## See Also

- [JIRA_WORKFLOW_AUTOMATION.md](../../JIRA_WORKFLOW_AUTOMATION.md) — Full automation guide
- [GitHub PR Workflow](../../docs/development/GITHUB_WORKFLOW.md) — PR standards
- [Composio Integration](../../docs/integration/COMPOSIO_SETUP.md) — Tool setup
