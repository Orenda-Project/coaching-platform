# E2E Testing Setup & Execution Guide

**Feature:** Feedback Chatbot (feature/feedback-chatbot)  
**Test Suite:** T1–T12 (12 comprehensive scenarios)  
**Time Estimate:** 45–60 minutes  
**Status:** Ready to test

---

## 1. Start Testing Environment

### Prerequisites

- Docker Desktop running
- Node.js 18+ installed
- `npm` available

### Launch Commands

```bash
# Terminal 1: Start Supabase
supabase start

# Wait 30 seconds for containers to initialize, then:
supabase status  # Verify healthy

# Terminal 2: Start dev server
npm run dev
# App will be available at http://localhost:5173
```

**Verify:**
- Dev server ready: http://localhost:5173 loads
- Supabase console: http://127.0.0.1:54321 accessible

---

## 2. Create Test Accounts

### In Supabase Console (http://127.0.0.1:54321)

1. Go to **Authentication** → **Users**
2. Click **+ Add User** and create:

   **User 1: Coach A (Non-Admin)**
   - Email: `coach.a@test.local`
   - Password: `Test1234!`
   - Click **Save**

   **User 2: Admin**
   - Email: `admin@test.local`
   - Password: `Test1234!`
   - Click **Save**

3. **Make Admin an admin:**
   - Go to **SQL Editor**
   - Copy and paste:
   ```sql
   INSERT INTO user_roles (user_id, role)
   SELECT id, 'admin'::app_role 
   FROM auth.users WHERE email = 'admin@test.local';
   ```
   - Click **Execute**

**Verify:** Both users appear in Authentication → Users list

---

## 3. Run E2E Tests (T1–T12)

### Reference Documents

**Main Test Report:** `docs/testing/E2E_TEST_RUN_REPORT.md`
- Open this file and follow step-by-step
- Check off each step as you complete it
- Mark PASS/FAIL for each test
- Note any issues observed

**Quick Reference:** `docs/testing/E2E_FEEDBACK_CHATBOT.md`
- Original test specification
- Use if you need more detail on what to verify

### Test Order & Time Allocation

| Test | Name | Duration | Location |
|------|------|----------|----------|
| T1 | Button Visibility | 5 min | Multiple routes |
| T2 | Happy Path Flow | 70 sec | /dashboard |
| T3 | Minimal Input | 30 sec | /training/{id} |
| T4 | Mobile Responsive | 5 min | Any page (mobile mode) |
| T5 | Cooldown Enforcement | 65 sec | /dashboard |
| T6 | Error Handling | 5 min | /dashboard |
| T7 | Double-Submit Protection | 5 min | /dashboard |
| T8 | Navigation Cleanup | 5 min | /dashboard |
| T9 | Admin KPIs & Table | 5 min | /admin/feedback |
| T10 | Admin Filters | 10 min | /admin/feedback |
| T11 | RLS Verification | 5 min | DevTools |
| T12 | Data Persistence | 5 min | /admin/feedback |

**Total: ~45–60 minutes**

### Testing Tips

1. **Test in order:** T1–T8 first (user features), then T9–T12 (admin features)
2. **Keep multiple tabs open:**
   - Tab 1: App (http://localhost:5173)
   - Tab 2: Supabase console (http://127.0.0.1:54321)
3. **Long-running tests:** T5 requires 65 seconds real-time. Do this early, then proceed with other tests while waiting.
4. **DevTools tests (T6, T7, T11):** Press F12 to open DevTools
5. **Mobile tests (T4):** Press Ctrl+Shift+M to toggle device emulation

### Common Routes

- **User tests (T1–T8):**
  - Login as Coach A: `coach.a@test.local` / `Test1234!`
  - Dashboard: http://localhost:5173/dashboard
  - Training: Find a module in dashboard, click to enter
  - Assessment: http://localhost:5173/assessment/baseline (button should NOT appear)
  - Quiz: http://localhost:5173/module-quiz/{moduleId} (button should NOT appear)

- **Admin tests (T9–T12):**
  - Login as Admin: `admin@test.local` / `Test1234!`
  - Admin panel: http://localhost:5173/admin/feedback

---

## 4. Fill Out Test Report

### File: `docs/testing/E2E_TEST_RUN_REPORT.md`

For each test (T1–T12):

1. **Follow the steps** listed in the report
2. **Check off** each step as you complete it: `[ ]` → `[x]`
3. **Mark result:** PASS or FAIL
4. **Add notes** for any issues, observations, or interesting findings

### Example

```markdown
### T1: Feedback Button Visibility

- [x] Log in as Coach A
- [x] Visit /dashboard → button visible
- [x] Visit /profile → button visible
- [x] Visit /assessment/baseline → button NOT visible
- [x] Visit /module-quiz/{id} → button NOT visible
- [x] Visit /admin/feedback → button NOT visible

**Result:** PASS

**Notes:**
- Button positioned correctly at bottom-right
- Icon is clearly visible
- Title tooltip shows "Share feedback"
```

---

## 5. Sign Off & Commit

### After All Tests Complete

1. **Review the report:**
   - All 12 tests have pass/fail marked
   - Notes added for any failures
   - Sign-off section filled (tester name, date)

2. **Commit results:**
   ```bash
   git add docs/testing/E2E_TEST_RUN_REPORT.md
   git commit -m "test(e2e): feedback chatbot T1–T12 complete

   All 12 tests [PASSED/mixed results]
   Tester: [Your Name]
   Date: 2026-04-28
   
   [Summary of any failures or notes]"
   ```

3. **Push to GitHub:**
   ```bash
   git push
   ```

---

## 6. After Testing

### If All Tests PASS ✅

1. Results are committed to branch
2. Ready to merge PR #31 to staging
3. Follow staging deployment procedure (see below)

### If Any Test FAILS ❌

1. Note the failure details in the report
2. Create a GitHub issue:
   - Title: `[BUG] Feedback chatbot: <test name> failed`
   - Description: Copy failure details from test report
3. Investigate the issue
4. Fix in the feature branch
5. Commit fix: `git commit -m "fix(feedback): <issue description>"`
6. Re-run the failing test
7. Once all pass, continue to merge

### Staging Deployment (After Tests Pass)

1. **Merge PR to staging:**
   ```bash
   git checkout staging
   git merge feature/feedback-chatbot
   git push
   ```

2. **Deploy to staging via Railway:**
   - Connect Railway to GitHub
   - Deploy from staging branch
   - Monitor deployment logs

3. **Run smoke tests on staging:**
   - Repeat T1, T2, T9 (quick validation)
   - Verify database has migration applied

4. **Get stakeholder feedback:**
   - Coaches: Does the flow work? Is it helpful?
   - Admins: Do the KPIs and filters work correctly?

5. **Merge to main:**
   ```bash
   git checkout main
   git merge staging
   git push
   ```

---

## Troubleshooting

### Dev Server Not Responding

```bash
# Check if running
lsof -i :5173

# Kill if stuck
lsof -i :5173 | awk 'NR==2 {print $2}' | xargs kill -9

# Restart
npm run dev
```

### Supabase Not Healthy

```bash
# Check status
supabase status

# Restart
supabase stop
supabase start

# Reset if needed (deletes local data!)
supabase db reset
```

### Test Account Not Working

1. Verify in Supabase console: Authentication → Users
2. Check if email matches exactly: `coach.a@test.local` (case-sensitive)
3. Try creating a new test user if the first fails
4. Check browser console (F12) for login errors

### App Loads But Feedback Button Missing

1. Ensure you're logged in (check dashboard shows coach name)
2. Check you're on an allowed route (not /assessment/*, /module-quiz/*, /admin/*)
3. Open console (F12) and check for errors
4. Verify useFeedback hook is imported in FeedbackChatbot.tsx

---

## Key Files

```
docs/testing/
├── E2E_FEEDBACK_CHATBOT.md          ← Original test spec
├── E2E_TEST_RUN_REPORT.md            ← Use THIS for testing (checklist)
└── TESTING_SETUP.md                  ← You are here

src/components/feedback/
├── FeedbackChatbot.tsx               ← Main component
└── FeedbackBubble.tsx                ← Message bubbles

src/hooks/
└── useFeedback.ts                    ← Submit hook

src/pages/admin/
└── AdminFeedback.tsx                 ← Admin view

supabase/migrations/
└── 20260506000000_feedback_chatbot.sql ← Database schema
```

---

## Questions?

- **About tests:** See `docs/testing/E2E_FEEDBACK_CHATBOT.md`
- **About code:** See `docs/FEEDBACK_CHATBOT_SUMMARY.md`
- **About setup:** Ask in team Slack or GitHub PR #31

---

**Good luck with testing! 🚀**
