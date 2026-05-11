# E2E QA Agent Memory

## App Configuration

**Staging Environment URL:**
```
https://coaching-platform-staging.up.railway.app
```

**Local Development URL:**
```
http://localhost:5173
```

## Test Credentials

### Primary Test User (ACTIVE)
- **Email:** taleem@yopmail.com
- **Password:** Umar@123!@#
- **Role:** Student
- **Status:** ✅ VERIFIED WORKING (2026-05-06)

### Admin User
- **Email:** admin@example.com
- **Password:** AdminPassword123!
- **Role:** Admin

## UI Element Selectors

### Login Page
- Email input: `[data-testid="email-input"]` or `input[type="email"]`
- Password input: `[data-testid="password-input"]` or `input[type="password"]`
- Login button: `[data-testid="login-button"]` or `button:contains("Sign In")`
- Error message: `.error-message` or `[role="alert"]`

### Dashboard
- Dashboard header: `h1:contains("Dashboard")`
- User profile: `[data-testid="user-profile"]`
- Start assessment button: `[data-testid="start-assessment"]`

### Assessment Flow
- Assessment progress: `[data-testid="progress-bar"]`
- Question text: `[data-testid="question-text"]`
- Answer options: `[data-testid^="option-"]`
- Next button: `[data-testid="next-button"]`
- Submit button: `[data-testid="submit-button"]`

## Known Test Scenarios

### Login Tests
1. **Valid email/password** → redirects to Dashboard
2. **Invalid password** → shows error message
3. **Non-existent email** → shows error message
4. **Empty fields** → shows validation error

### Baseline Assessment
1. **Full assessment flow** → completes all questions
2. **Skip questions** → allowed for optional questions
3. **Submit assessment** → calculates baseline score
4. **NEW USER GATING RULE:** Only baseline assessment shown to new users
5. **COMPLETION GATING:** Baseline NOT shown again after first completion

### Training Flow
1. **View training modules** → lists available modules
2. **Start module** → enters training module
3. **Complete module** → tracks completion

## Known Issues / Flaky Areas

- **Issue:** Login page sometimes takes 2-3s to load
- **Workaround:** Use `wait_for` with 5000ms timeout on login button
- **Status:** Under investigation (possible API latency)

## Test Run History

| Date | Feature | Method | Result | Duration | Scenarios | Steps | Notes |
|------|---------|--------|--------|----------|-----------|-------|-------|
| 2026-05-06 10:03 | login.feature | MCP (CDP) | ✅ PASSED | 13.2s | 2/2 | 11/11 | MCP Chrome DevTools test - 15 MCP calls executed |
| 2026-05-06 14:58 | login.feature | Script | ✅ PASSED | 13.9s | 2/2 | 11/11 | Feature verification script test |
| 2026-05-06 | signup.feature | TBD | Pending | — | — | — | Scheduled for next run |
| 2026-05-06 | onboarding.feature | TBD | Pending | — | — | — | Scheduled for next run |
| 2026-05-06 | baseline_assessment.feature | TBD | Pending | — | — | — | Scheduled for next run |

## Testing Approach

**Method:** Gherkin BDD Feature File Verification  
**Source of Truth:** ONLY .feature files (no custom test cases)  
**Screenshot Capture:** DISABLED  
**Report Format:** Markdown with pass/fail per feature file step  

Process:
1. Read .feature file scenarios
2. Execute each scenario step exactly as specified
3. Verify behavior matches .feature specification
4. Report: Feature → Scenario → Steps → Pass/Fail
5. Save results to feature-verification-[name].md
6. Do NOT modify or create custom test cases
7. Do NOT capture screenshots or visual artifacts

## Baseline Assessment Gating Rules ⭐ CRITICAL

### User Journey Requirement:
1. **New User (First Login):**
   - Only Baseline Assessment shown
   - Cannot access training modules until baseline completed
   - Baseline is MANDATORY for all new users

2. **After Baseline Completion:**
   - Baseline assessment is HIDDEN
   - User can access all training modules
   - Baseline is NOT shown again in dashboard
   - User cannot re-attempt baseline (one-time only)

3. **Implementation Details:**
   - **Status Field:** User must have `baseline_completed = true`
   - **Visibility Logic:** Show baseline ONLY if `baseline_completed = false`
   - **Access Control:** Training modules locked if baseline not completed
   - **UI Display:** Dashboard shows "Baseline Assessment" only if not completed

### Testing Scenarios:
- ✅ New user sees ONLY baseline assessment
- ✅ Baseline hidden after completion
- ✅ Training modules unlocked after baseline
- ✅ Cannot re-access baseline after completion
- ✅ User score/results persisted

## Debug Tips

- **Check console errors:** `list_console_messages` on failures
- **Network debugging:** `list_network_requests` to see API calls
- **Page wait time:** Most pages load in <1s, assessment in <2s
- **Note:** Screenshots disabled - focus on functional verification only
