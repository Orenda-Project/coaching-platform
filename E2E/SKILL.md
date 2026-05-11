---
name: e2e-gherkin-executor
description: Execute Gherkin BDD test scenarios using Chrome DevTools MCP
type: skill
allowed-tools: |
  mcp__chrome-devtools__navigate_page,
  mcp__chrome-devtools__take_screenshot,
  mcp__chrome-devtools__click,
  mcp__chrome-devtools__fill,
  mcp__chrome-devtools__fill_form,
  mcp__chrome-devtools__wait_for,
  mcp__chrome-devtools__evaluate_script,
  mcp__chrome-devtools__list_console_messages,
  mcp__chrome-devtools__list_network_requests,
  mcp__chrome-devtools__press_key,
  mcp__chrome-devtools__list_pages,
  mcp__chrome-devtools__select_page
---

# E2E Gherkin BDD Executor with Chrome DevTools MCP

This skill teaches Claude to read Gherkin `.feature` files from the `E2E/features/` directory and execute each scenario step-by-step using Chrome DevTools MCP tools. Claude acts as the BDD interpreter and browser driver, tracking pass/fail per step and writing results to `E2E/reports/`.

## How to Use

1. **Start Chrome with debugging enabled:**
   ```bash
   google-chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug
   ```

2. **Invoke the skill and specify a feature file:**
   ```
   Run E2E tests for login.feature
   ```

3. **Claude will:**
   - Read `E2E/features/login.feature`
   - Parse each Gherkin scenario and step
   - Execute each step via Chrome MCP tools
   - Log results to `E2E/reports/YYYY-MM-DD-HH-MM-run.md`

## Step-to-MCP Tool Mapping

| Gherkin Step | MCP Tool | Action |
|--------------|----------|--------|
| `Given I am on [URL]` | `navigate_page` | Navigate to URL |
| `When I click [element]` | `click` | Click element by selector |
| `When I fill [field] with [value]` | `fill` | Fill input field |
| `When I submit the form` | `fill_form` | Submit HTML form |
| `When I press [key]` | `press_key` | Press keyboard key |
| `When I wait for [selector]` | `wait_for` | Wait for element to appear |
| `Then I should see [text]` | `evaluate_script` | Assert text in DOM |
| `Then I should see [selector]` | `evaluate_script` | Assert element visible |
| `Then I take a screenshot` | `take_screenshot` | Screenshot page |
| On error | `list_console_messages` | Capture JS console logs |
| On error | `list_network_requests` | Capture network requests |

## Execution Flow

```
1. Read .feature file
   ↓
2. Parse scenarios (skip Background, read steps in order)
   ↓
3. For each scenario:
   a. Note scenario name
   b. Execute each step:
      - Map Gherkin to MCP tool
      - Call MCP tool
      - If success → mark step PASS
      - If error → capture console + network, mark step FAIL, continue to next scenario
   ↓
4. Write report to E2E/reports/YYYY-MM-DD-HH-MM-run.md with:
   - Scenario name + status (PASS / FAIL)
   - Each step with status + output
   - Debug info (console logs, network requests) for failed steps
```

## Report Format

```markdown
# E2E Test Run Report
**Date:** 2026-05-06 15:30  
**Feature:** login.feature  
**Environment:** https://coaching-platform-staging.up.railway.app  

## Results
- ✅ Scenario: Valid login with email
- ❌ Scenario: Invalid password

### Scenario: Valid login with email
| Step | Status | Details |
|------|--------|---------|
| Given I am on https://coaching-platform-staging.up.railway.app | PASS | Navigated |
| When I click [data-testid=email-input] | PASS | Clicked |
| When I fill [data-testid=email-input] with user@example.com | PASS | Filled |
| When I click [data-testid=login-button] | PASS | Clicked |
| Then I should see Dashboard | PASS | Text found in DOM |

### Scenario: Invalid password
| Step | Status | Details |
|------|--------|---------|
| Given I am on https://coaching-platform-staging.up.railway.app | PASS | Navigated |
| When I fill [data-testid=email-input] with user@example.com | PASS | Filled |
| When I fill [data-testid=password-input] with wrong | PASS | Filled |
| When I click [data-testid=login-button] | PASS | Clicked |
| Then I should see Error message | **FAIL** | Text not found in DOM |

**Debug Info:**
- Console: [No errors]
- Network: POST /api/auth/login → 401 Unauthorized
```

## 🔐 Baseline Assessment Gating Logic - CRITICAL REQUIREMENT

### Business Rule:
The baseline assessment is the mandatory first step for all new users. Once completed, it should never be shown again.

### Implementation:
```
User Login Flow:
├─ New User (baseline_completed = false)
│  ├─ Dashboard shows ONLY: "Start Baseline Assessment" button
│  ├─ Training modules: LOCKED/HIDDEN
│  └─ User MUST complete baseline to proceed
│
└─ Returning User (baseline_completed = true)
   ├─ Dashboard shows: Training modules + profile
   ├─ Baseline assessment: HIDDEN
   └─ User can access all features
```

### Test Scenarios to Verify:
1. **New User Access:**
   - Login as new user → Should see ONLY baseline assessment
   - Training modules should be locked/grayed out
   - "Start Baseline Assessment" button prominently displayed

2. **Baseline Completion:**
   - Complete all 18 questions → Submit
   - Receive completion confirmation
   - Score calculated and stored

3. **Post-Completion:**
   - User logs in again → Baseline should be HIDDEN
   - Dashboard shows training modules instead
   - User cannot access baseline assessment page again
   - Attempting to access baseline → Redirected to training

4. **Access Control:**
   - Cannot access `/assessment/baseline` after completion
   - Cannot access training modules before completion
   - Module unlock status syncs with baseline status
   - User role updated with baseline completion flag

### Data Model:
```javascript
user.baseline_assessment = {
  completed: boolean,           // true/false
  completion_date: timestamp,   // ISO date when completed
  score: number,               // 0-100 percentage
  answers: [array],            // Question responses
  time_taken: number           // Seconds to complete
}
```

### CSS/Selector Strategy:
```
New User State:
- Show: [data-testid="baseline-cta"]
- Hide: [data-testid="training-modules"]
- Disable: .training-module-card

Baseline Complete State:
- Hide: [data-testid="baseline-cta"]
- Show: [data-testid="training-modules"]
- Enable: .training-module-card
```

## Known Variables

These are available in `E2E/memory.md` and should be used in scenarios:

- **App URL:** `https://coaching-platform-staging.up.railway.app`
- **Test User Email:** `test@example.com`
- **Test User Password:** From secure storage
- **UI Selectors:** Element IDs and data-testid attributes
- **Baseline Gating:** Users without `baseline_completed = true` can only access baseline assessment
