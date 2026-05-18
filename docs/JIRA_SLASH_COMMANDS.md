# Jira Slash Commands - Developer Guide

**Last Updated:** 2026-05-13
**Status:** Ready for Implementation
**Connection:** Composio (Jira + GitHub MCP)

---

## Quick Reference

### Create Ticket (Start of Feature)
```
/jira-ticket "Feature Title" "Description" "COACH-branch" "PR#"
```

### Move to QA (Code Ready)
```
/jira-qa MC20-XXXXX
```

### Move to Done (Merged to Main)
```
/jira-done MC20-XXXXX
```

---

## 1. Create Jira Ticket - `/jira-ticket`

### Command Signature
```bash
/jira-ticket <title> [description] [branch] [pr_number]
```

### Parameters

| Name | Type | Required | Example | Notes |
|------|------|----------|---------|-------|
| title | string | ✅ Yes | "Randomize scenario answers" | Feature title |
| description | string | ❌ Optional | "Implement Fisher-Yates shuffle" | Feature details |
| branch | string | ❌ Optional | "COACH-training-flow" | GitHub branch name |
| pr_number | number | ❌ Optional | 90 | GitHub PR number |

### Implementation Steps

#### Step 1: Parse Arguments
```typescript
function parseJiraTicketCommand(input: string) {
  // Extract: title (required), description, branch, pr
  // Format: /jira-ticket "Title" "Desc" "branch" "pr"
  const args = parseQuotedArgs(input);
  return {
    title: args[0],           // Required
    description: args[1] || null,
    branch: args[2] || null,
    pr: args[3] || null
  };
}
```

#### Step 2: Create Jira Ticket
```typescript
async function createJiraTicket(args) {
  const ticket = await composioExecute('JIRA_CREATE_ISSUE', {
    issue_id_or_key: "MC20",
    summary: args.title,
    description: args.description || "",
    assignee: "Jalal Khan",
    additional_properties: {
      components: [{ id: "10590" }],          // Team Coaching
      customfield_10014: "MC20-9877",          // Epic
      customfield_10026: 3                     // Work Days
    }
  });
  return ticket;
}
```

#### Step 3: Transition to In Progress
```typescript
async function transitionToInProgress(ticketKey: string) {
  await composioExecute('JIRA_TRANSITION_ISSUE', {
    issue_id_or_key: ticketKey,
    transition_id_or_name: "31"  // In Progress
  });
}
```

#### Step 4: Add GitHub Links (Optional)
```typescript
async function addGitHubLinks(ticketKey: string, branch?: string, pr?: number) {
  if (!branch && !pr) return;

  const comment = formatGitHubComment(branch, pr);
  await composioExecute('JIRA_ADD_COMMENT', {
    issue_id_or_key: ticketKey,
    comment: comment
  });
}

function formatGitHubComment(branch?: string, pr?: number): string {
  let comment = "**Development Links:**\n\n";

  if (branch) {
    comment += `🌿 **GitHub Branch:** \`${branch}\`\n`;
  }

  if (pr) {
    const prUrl = `https://github.com/taleemabad/coaching-platform/pull/${pr}`;
    comment += `🔗 **GitHub PR:** #${pr}\n${prUrl}\n`;
  }

  return comment;
}
```

#### Step 5: Return Result
```typescript
function formatTicketCreatedResponse(ticket: any, branch?: string, pr?: number) {
  let response = `✅ Jira Ticket Created: ${ticket.key}\n`;
  response += `🔗 Browse: ${ticket.browser_url}\n`;
  response += `📊 Status: In Progress\n`;
  response += `🎯 Assigned: Jalal Khan\n`;
  response += `🏷️  Component: Engineering\n`;
  response += `📌 Epic: MC20-9877\n`;

  if (branch) response += `🌿 Branch: ${branch}\n`;
  if (pr) response += `🔗 PR: #${pr}\n`;

  return response;
}
```

### Usage Examples

**Minimal (Title Only):**
```
/jira-ticket "Implement dark mode"
```

**With Description:**
```
/jira-ticket "Implement dark mode" "Add dark theme support with localStorage persistence"
```

**With GitHub Integration:**
```
/jira-ticket "Randomize scenario answers" "Implement Fisher-Yates shuffle and lock practice section" "COACH-training-flow-improvements" "90"
```

### Success Response
```
✅ Jira Ticket Created: MC20-18325
🔗 Browse: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: In Progress
🎯 Assigned: Jalal Khan
🏷️  Component: Engineering
📌 Epic: MC20-9877
🌿 Branch: COACH-training-flow-improvements
🔗 PR: #90
```

---

## 2. Move to QA - `/jira-qa`

### Command Signature
```bash
/jira-qa <ticket_key>
```

### Parameters

| Name | Type | Required | Example | Notes |
|------|------|----------|---------|-------|
| ticket_key | string | ✅ Yes | MC20-18325 | Jira ticket key |

### Implementation

```typescript
async function moveToQA(ticketKey: string) {
  // Validate ticket exists
  const ticket = await composioExecute('JIRA_GET_ISSUE', {
    issue_key: ticketKey
  });

  if (!ticket) throw new Error(`Ticket ${ticketKey} not found`);

  // Transition to QA
  await composioExecute('JIRA_TRANSITION_ISSUE', {
    issue_id_or_key: ticketKey,
    transition_id_or_name: "51"  // QA
  });

  // Add comment
  await composioExecute('JIRA_ADD_COMMENT', {
    issue_id_or_key: ticketKey,
    comment: "Moved to QA for testing\n\n✅ Code review passed\n✅ Ready for QA testing"
  });

  return formatQAResponse(ticketKey);
}

function formatQAResponse(ticketKey: string) {
  return `✅ ${ticketKey} moved to QA\n` +
         `🔗 Browse: https://orendatrust.atlassian.net/browse/${ticketKey}\n` +
         `📊 Status: QA\n` +
         `⏱️  Updated: ${new Date().toISOString()}`;
}
```

### Usage Examples

```
/jira-qa MC20-18325
/jira-qa MC20-18324
```

### Success Response
```
✅ MC20-18325 moved to QA
🔗 Browse: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: QA
⏱️  Updated: 2026-05-13T18:30:45.123Z
```

---

## 3. Move to Done - `/jira-done`

### Command Signature
```bash
/jira-done <ticket_key>
```

### Parameters

| Name | Type | Required | Example | Notes |
|------|------|----------|---------|-------|
| ticket_key | string | ✅ Yes | MC20-18325 | Jira ticket key |

### Implementation

```typescript
async function moveToDone(ticketKey: string) {
  // Validate ticket exists
  const ticket = await composioExecute('JIRA_GET_ISSUE', {
    issue_key: ticketKey
  });

  if (!ticket) throw new Error(`Ticket ${ticketKey} not found`);

  // Transition to Done
  await composioExecute('JIRA_TRANSITION_ISSUE', {
    issue_id_or_key: ticketKey,
    transition_id_or_name: "41"  // Done
  });

  // Add comment
  await composioExecute('JIRA_ADD_COMMENT', {
    issue_id_or_key: ticketKey,
    comment: "✅ Merged to main - Completed\n\n" +
             "- QA testing passed\n" +
             "- PR merged to main\n" +
             "- Deployed to production"
  });

  return formatDoneResponse(ticketKey);
}

function formatDoneResponse(ticketKey: string) {
  return `✅ ${ticketKey} moved to Done\n` +
         `🔗 Browse: https://orendatrust.atlassian.net/browse/${ticketKey}\n` +
         `📊 Status: Done\n` +
         `⏱️  Updated: ${new Date().toISOString()}`;
}
```

### Usage Examples

```
/jira-done MC20-18325
/jira-done MC20-18324
```

### Success Response
```
✅ MC20-18325 moved to Done
🔗 Browse: https://orendatrust.atlassian.net/browse/MC20-18325
📊 Status: Done
⏱️  Updated: 2026-05-13T18:45:22.456Z
```

---

## Error Handling

### Invalid Ticket Key
```typescript
try {
  const ticket = await JIRA_GET_ISSUE(ticketKey);
  if (!ticket) throw new Error("Not found");
} catch (error) {
  return `❌ Ticket ${ticketKey} not found\n💡 Check the key and try again`;
}
```

### Already in Target Status
```typescript
if (ticket.status.name === "In Progress") {
  return `⚠️  ${ticketKey} is already "In Progress"\n💡 Use /jira-qa to move to QA`;
}
```

### Connection Error
```typescript
if (!composioConnected) {
  return `❌ Jira not connected\n💡 Run: composio link jira`;
}
```

---

## Composio Tool Reference

### JIRA_CREATE_ISSUE
```json
{
  "project": "MC20",
  "issuetype": "Story",
  "summary": "Feature title",
  "description": "Feature description",
  "assignee": "Jalal Khan",
  "additional_properties": {
    "components": [{"id": "10105"}],
    "customfield_10014": "MC20-9877",
    "customfield_10026": 3
  }
}
```

### JIRA_TRANSITION_ISSUE
```json
{
  "issue_id_or_key": "MC20-18325",
  "transition_id_or_name": "31"  // 31=In Progress, 51=QA, 41=Done
}
```

### JIRA_ADD_COMMENT
```json
{
  "issue_id_or_key": "MC20-18325",
  "comment": "Your comment here (supports Markdown)"
}
```

### JIRA_GET_ISSUE
```json
{
  "issue_key": "MC20-18325",
  "fields": ["status", "assignee", "components"]
}
```

---

## Testing Checklist

- [ ] `/jira-ticket` creates ticket with correct defaults
- [ ] Ticket transitions to "In Progress" immediately
- [ ] GitHub links are clickable and formatted correctly
- [ ] `/jira-qa` moves ticket from In Progress → QA
- [ ] `/jira-done` moves ticket from QA → Done
- [ ] Comments are added with proper formatting
- [ ] Error messages are helpful and actionable
- [ ] Composio connection is verified before each command

---

## FAQ

**Q: Can I create a ticket without a GitHub branch?**
A: Yes! Just use: `/jira-ticket "Title" "Description"` GitHub links are optional.

**Q: What if I specify wrong parameters?**
A: The command will show a helpful error. GitHub branch/PR are optional, so only title is required.

**Q: Can I bulk create tickets?**
A: Yes! Run `/jira-ticket` multiple times in sequence. Each gets a new MC20-XXXXX key.

**Q: How do I find the ticket key?**
A: The response includes the key (e.g., MC20-18325). Use it with `/jira-qa` and `/jira-done`.

**Q: What if Jira connection fails?**
A: Run `composio link jira` to re-authenticate, then try again.

---

## Related Documentation

- [JIRA_WORKFLOW_AUTOMATION.md](../JIRA_WORKFLOW_AUTOMATION.md) — Full workflow guide
- [.claude/skills/jira-ticket/SKILL.md](../.claude/skills/jira-ticket/SKILL.md) — Skill definition
- [Composio Setup Guide](../docs/integration/COMPOSIO_SETUP.md) — Connection details
