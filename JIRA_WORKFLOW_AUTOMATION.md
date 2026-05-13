# Jira Workflow Automation Rules

**Last Updated:** 2026-05-13

## Ticket Creation Defaults

All new tickets in **MC20 (Mission Control 2.0)** project should be created with these settings:

### Always Set These Fields:

```json
{
  "project": "MC20",
  "issuetype": "Story",
  "summary": "[Feature Title]",
  "assignee": "Jalal Khan",
  "additional_properties": {
    "components": [{"id": "10105"}],
    "customfield_10014": "MC20-9877",
    "customfield_10026": 3
  }
}
```

**Breakdown:**
- **Project:** MC20 (Mission Control 2.0)
- **Type:** Story (issue type)
- **Assignee:** Jalal Khan (jalal.khan@taleemabad.com)
- **Component:** Engineering (ID: `10105`)
- **Epic:** MC20-9877 (customfield_10014)
- **Work Days:** 3 (customfield_10026)

---

## Workflow Transitions

### 1. **Ticket Created** → Immediately Move to "In Progress"

**Status Path:** Backlog → **In Progress**

**Transition ID:** `31`

**When:** Immediately after ticket creation

**Example:**
```bash
composio execute JIRA_TRANSITION_ISSUE \
  -d '{"issue_id_or_key": "MC20-XXXXX", "transition_id_or_name": "31"}'
```

### 2. **During QA** → Move to "QA" Status

**Status Path:** In Progress → **QA**

**Transition ID:** `51`

**When:** When code is ready for QA testing

**Example:**
```bash
composio execute JIRA_TRANSITION_ISSUE \
  -d '{"issue_id_or_key": "MC20-XXXXX", "transition_id_or_name": "51"}'
```

### 3. **After Merge to Main** → Move to "Done"

**Status Path:** QA → **Done**

**Transition ID:** `41`

**When:** After PR is merged to main branch

**Example:**
```bash
composio execute JIRA_TRANSITION_ISSUE \
  -d '{"issue_id_or_key": "MC20-XXXXX", "transition_id_or_name": "41"}'
```

---

## Available Transitions Matrix

| From Status | Transition Name | Transition ID | To Status |
|------------|-----------------|---------------|-----------|
| Backlog | Backlog | 11 | Backlog |
| Backlog | Selected for Development | 21 | Selected for Development |
| Any | In Progress | 31 | In Progress |
| Any | Done | 41 | Done |
| Any | QA | 51 | QA |

---

## Automation Script Template

```bash
#!/bin/bash
# Create and automate ticket workflow

ISSUE_KEY="MC20-XXXXX"

# Step 1: Create ticket (handled by Composio)
# Ticket should start in "Backlog" status

# Step 2: Immediately transition to In Progress
composio execute JIRA_TRANSITION_ISSUE \
  -d "{\"issue_id_or_key\": \"$ISSUE_KEY\", \"transition_id_or_name\": \"31\"}"
echo "✅ Ticket moved to In Progress"

# Step 3: [After development complete] Move to QA
# composio execute JIRA_TRANSITION_ISSUE \
#   -d "{\"issue_id_or_key\": \"$ISSUE_KEY\", \"transition_id_or_name\": \"51\"}"
# echo "✅ Ticket moved to QA"

# Step 4: [After main merge] Move to Done
# composio execute JIRA_TRANSITION_ISSUE \
#   -d "{\"issue_id_or_key\": \"$ISSUE_KEY\", \"transition_id_or_name\": \"41\"}"
# echo "✅ Ticket moved to Done"
```

---

## Example: Full Workflow

```
1. Create ticket with defaults
   Status: Backlog

2. Transition to In Progress (ID: 31) — IMMEDIATE
   Status: In Progress

3. [Dev complete] Transition to QA (ID: 51)
   Status: QA

4. [QA passes] Transition to Done (ID: 41)
   Status: Done
```

---

## Current Ticket Reference

**MC20-18324** — "Randomize scenario answers, lock practice section, rename to Practice Section"

- ✅ Assignee: Jalal Khan
- ✅ Component: Engineering (ID: 10105)
- ✅ Epic: MC20-9877
- ✅ Work Days: 3
- ✅ Status: **In Progress** (transitioned on 2026-05-13)

---

## Slash Command: `/jira-ticket`

Use this slash command to create a fully configured Jira ticket with all defaults, GitHub integration, and initial status transition in one go.

### Usage

```bash
/jira-ticket "Feature Title" "[Optional: Feature Description]" "[Optional: GitHub Branch]" "[Optional: GitHub PR #]"
```

### Examples

**Basic (Title only):**
```bash
/jira-ticket "Implement dark mode"
```

**With Description:**
```bash
/jira-ticket "Implement dark mode" "Add dark theme support across all pages with localStorage persistence"
```

**With GitHub Integration:**
```bash
/jira-ticket "Implement dark mode" "Add dark theme support" "COACH-dark-mode" "42"
```

### What This Command Does (Automated)

1. ✅ **Creates Jira Ticket** with:
   - Project: MC20 (Mission Control 2.0)
   - Type: Story
   - Assignee: **Jalal Khan**
   - Component: **Engineering** (ID: 10105)
   - Epic: **MC20-9877**
   - Work Days: **3**
   - Status: Backlog (initial)

2. ✅ **Transitions to "In Progress"** immediately
   - Transition ID: 31
   - Status: In Progress

3. ✅ **Adds GitHub Links** (if provided):
   - Branch: Adds to description & comments as clickable link
   - PR: Adds PR number and link
   - Format: 🌿 Branch | 🔗 PR #N with direct GitHub URL

4. ✅ **Returns Ticket Key** (e.g., MC20-18325)

### Returns

```
✅ Jira Ticket Created: MC20-18325
🔗 URL: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: In Progress
🌿 GitHub Branch: COACH-dark-mode (optional)
🔗 GitHub PR: #42 (optional)
```

---

## Status Update Slash Commands

### `/jira-qa MC20-XXXXX`

Move ticket from "In Progress" to "QA" status.

**What it does:**
- Transition ID: 51
- Status: In Progress → QA
- Adds comment: "Moved to QA for testing"

**Example:**
```bash
/jira-qa MC20-18325
```

**Returns:**
```
✅ MC20-18325 moved to QA
🔗 URL: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: QA
```

---

### `/jira-done MC20-XXXXX`

Move ticket from "QA" to "Done" status (marks as completed).

**What it does:**
- Transition ID: 41
- Status: QA → Done
- Adds comment: "Merged to main - Completed"
- Sets resolution: "Done"

**Example:**
```bash
/jira-done MC20-18325
```

**Returns:**
```
✅ MC20-18325 moved to Done
🔗 URL: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: Done
```

---

## Full Workflow with Slash Commands

### Step-by-Step Example

**1. Create Ticket at Start of Feature Work:**
```bash
/jira-ticket "Randomize scenario answers" "Implement Fisher-Yates shuffle and lock practice section" "COACH-training-flow-improvements" "90"
```
Returns: `✅ MC20-18324 | Status: In Progress`

**2. Move to QA When Code is Ready:**
```bash
/jira-qa MC20-18324
```
Returns: `✅ MC20-18324 | Status: QA`

**3. Move to Done After Main Merge:**
```bash
/jira-done MC20-18324
```
Returns: `✅ MC20-18324 | Status: Done`

---

## Implementation Architecture

### Backend (Composio Integration)

The slash commands are implemented as:

```typescript
// Pseudo-code for /jira-ticket command
async function createJiraTicketSlash(args: {
  title: string;
  description?: string;
  githubBranch?: string;
  githubPR?: string;
}) {
  // Step 1: Create Jira ticket
  const ticket = await JIRA_CREATE_ISSUE({
    project: "MC20",
    issuetype: "Story",
    summary: args.title,
    description: args.description,
    assignee: "Jalal Khan",
    additional_properties: {
      components: [{ id: "10105" }],        // Engineering
      customfield_10014: "MC20-9877",        // Epic
      customfield_10026: 3                   // Work Days
    }
  });

  // Step 2: Transition to In Progress
  await JIRA_TRANSITION_ISSUE({
    issue_id_or_key: ticket.key,
    transition_id_or_name: "31"              // In Progress
  });

  // Step 3: Add GitHub links if provided
  if (args.githubBranch || args.githubPR) {
    await JIRA_ADD_COMMENT({
      issue_id_or_key: ticket.key,
      comment: formatGitHubLinks(args.githubBranch, args.githubPR)
    });
  }

  return {
    key: ticket.key,
    status: "In Progress",
    url: ticket.browser_url
  };
}
```

### Available Status Transitions

| Command | From Status | To Status | Transition ID | Field Updates |
|---------|------------|-----------|---------------|----------------|
| `/jira-ticket` | — | In Progress | 31 | All defaults + GitHub links |
| `/jira-qa` | In Progress | QA | 51 | Adds QA comment |
| `/jira-done` | QA | Done | 41 | Sets resolution = Done |

---

## Field Reference

### Default Ticket Fields

| Field | Value | Field ID |
|-------|-------|----------|
| Project | MC20 | — |
| Issue Type | Story | — |
| Assignee | Jalal Khan | — |
| Component | Engineering | 10105 |
| Epic Link | MC20-9877 | customfield_10014 |
| Work Days | 3 | customfield_10026 |

### GitHub Integration Fields

| Element | Location | Format |
|---------|----------|--------|
| Branch | Description + Comment | 🌿 `COACH-branch-name` |
| PR | Description + Comment | 🔗 `#90` + https://github.com/.../pull/90 |
| Commits | Description | Listed in PR details |

---

## Troubleshooting

### Issue: Ticket created but not moved to "In Progress"

**Solution:** Check Composio Jira connection status:
```bash
composio link jira
```

### Issue: GitHub links not appearing

**Solution:** Ensure branch/PR numbers are correctly formatted:
- Branch: `COACH-feature-name` (lowercase, hyphens)
- PR: `42` (numeric only, no hash required in slash command)

### Issue: Wrong assignee or component

**Solution:** Update defaults in `JIRA_WORKFLOW_AUTOMATION.md` and re-run command. Or manually edit the ticket:
```bash
composio execute JIRA_EDIT_ISSUE \
  -d '{"issue_id_or_key": "MC20-XXXXX", "assignee": "New Person"}'
```

---

## Notes for Future Automation

When implementing autonomous Jira ticket creation via Composio:

1. Create ticket with all default fields (see "Ticket Creation Defaults" above)
2. Immediately transition to "In Progress" with transition ID `31`
3. Add GitHub links to description and comments if provided
4. Update status based on workflow events:
   - QA ready → `/jira-qa` command or transition ID `51`
   - Merged to main → `/jira-done` command or transition ID `41`

This ensures consistent ticket lifecycle across the project.
