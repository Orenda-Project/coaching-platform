# Quick Start Guide — Phase 1 (Scenario-First Learning)

**Last Updated:** 2026-04-14
**Status:** Ready for immediate testing

---

## 1. Pre-Flight Checks

```bash
# Verify all dependencies installed
npm install

# Check Node version (should be 18+)
node --version

# Verify Supabase CLI installed
supabase --version

# Start Docker Desktop (required for local Supabase)
# macOS: Open Docker app from Applications
```

---

## 2. Start Local Development

### A. Start Supabase (Local)

```bash
# Terminal 1: Start Supabase containers & apply migrations
supabase start

# Should output URLs like:
# API URL: http://127.0.0.1:54321
# Studio: http://127.0.0.1:54323
# ...

# Check migration status
supabase status
```

**Studio Access:** Open http://127.0.0.1:54323 in browser

### B. Create Local Environment File

```bash
# Create .env.local file in project root
cat > .env.local << 'EOF'
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkeHh4eHh4eHh4eHh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2MTAwMDAwMDAsImV4cCI6MTk5OTk5OTk5OX0.SUPAXXX
EOF
```

**Note:** Use the anon key from `supabase start` output above

### C. Start Dev Server

```bash
# Terminal 2: Start dev server
npm run dev

# Should output:
#   VITE v5.x.x  building for development
#   ➜  Local:   http://localhost:5173/
```

**App Access:** Open http://localhost:5173 in browser

---

## 3. Create Test User Accounts

### Method A: Via Auth UI (Easier)

1. Navigate to http://localhost:5173/signup
2. Sign up with test credentials:
   - Email: `coach-a@test.local`
   - Password: `TestPass123!`
3. Complete onboarding (school_id required)
4. Repeat for other accounts:
   - `admin@test.local` (Super Admin)
   - `coach-b@test.local` (Coach B)
   - `regional@test.local` (Regional Admin)

### Method B: Via Supabase Studio (More Control)

1. Open Studio: http://127.0.0.1:54323
2. Go to **Authentication** → **Users**
3. Click **Add user**
4. Set email and password
5. Click **Create user**

Then assign roles:

1. Go to **SQL Editor**
2. Run SQL:
```sql
-- For Super Admin
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin' FROM auth.users WHERE email = 'admin@test.local'
ON CONFLICT DO NOTHING;

-- For Coach A
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'user' FROM auth.users WHERE email = 'coach-a@test.local'
ON CONFLICT DO NOTHING;

-- For Coach B
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'user' FROM auth.users WHERE email = 'coach-b@test.local'
ON CONFLICT DO NOTHING;

-- For Regional Admin
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'regional_admin' FROM auth.users WHERE email = 'regional@test.local'
ON CONFLICT DO NOTHING;
```

---

## 4. Admin Setup — Create Scenario Content

### Step 1: Log in as Super Admin

- Email: `admin@test.local`
- Password: `TestPass123!`

### Step 2: Create Test Region

1. Click **Admin** button (top right of Dashboard)
2. Navigate to **Regions** section
3. Click **Add Region**
4. Fill form:
   - Name: `Test Region 1`
   - Code: `TEST-R1`
   - Coordinates: `{"lat": 33.6844, "lng": 73.0479}`
5. Click **Save Region**

### Step 3: Create Scenario in Unit

1. Go back to **Admin** panel
2. Select **Modules**
3. Click on a module (e.g., "Module 1 - Ethics")
4. Select a unit (e.g., "Unit 1 - Introduction")
5. Click **Scenarios** button
6. Click **Add Scenario**
7. Fill form:
   - Situation: `"You observe a colleague sharing student data without consent."`
   - Question: `"What is your immediate action?"`
   - Difficulty: `medium`
   - Feedback Slides: `[{"title":"Why This Matters","body":"Data protection is fundamental..."}]`
   - Reveal Content: `"The principle is confidentiality."`
   - Deep Content: `"GDPR requires explicit consent for data sharing."`
   - Active: `ON` ✓
8. Click **Save Scenario**

### Step 4: Add Scenario Options (A/B/C/D)

1. In scenario list, click **Options** button
2. Fill 4 options:

**Option A (Correct):**
- Text: `"Report immediately to compliance"`
- Rationale: `"This is correct per policy"`
- Principle Tag: `Confidentiality`
- Mark Correct: ✓

**Option B (Incorrect):**
- Text: `"Ask colleague for explanation"`
- Rationale: `"This delays escalation"`
- Principle Tag: `Integrity`
- Mark Correct: ✗

**Option C (Incorrect):**
- Text: `"Do nothing; assume vendor approved"`
- Rationale: `"Passive approach violates duty"`
- Principle Tag: `Accountability`
- Mark Correct: ✗

**Option D (Incorrect):**
- Text: `"Inform student after sharing"`
- Rationale: `"Should notify immediately"`
- Principle Tag: `Transparency`
- Mark Correct: ✗

3. Click **Save Options**

---

## 5. User Testing — Complete Scenario Flow

### Step 1: Log in as Coach A

- Email: `coach-a@test.local`
- Password: `TestPass123!`

### Step 2: Complete Baseline (if needed)

1. See "Baseline Assessment Required" card
2. Click **Attempt Baseline Assessment**
3. Answer baseline questions (will assign persona)
4. Complete assessment

### Step 3: View Profile

1. Click **Profile** button in Dashboard header
2. See all profile sections:
   - Personal Information (editable)
   - Account Information (read-only)
   - Learning Profile (persona, baseline/endline status)
   - Progress Metrics (weak modules)
3. Click **Edit** to modify name/phone
4. Click **Save** to persist changes

### Step 4: Complete Scenario Flow

1. Return to Dashboard
2. Find unit with scenarios you created
3. Click **Attempt** button on the unit
4. **Phase 1 - Scenario:**
   - See situation, question, 4 options
   - Click option A (correct answer)
   - Click **Submit Decision**

5. **Phase 2 - Feedback:**
   - See "✓ Correct" badge
   - See rationale: "This is correct per policy"
   - See principle tag: "Confidentiality"
   - Click **Continue**

6. **Phase 3 - Reveal:**
   - See slide: "Why This Matters"
   - Body: "Data protection is fundamental..."
   - Click **Next** or **Done**

7. **Phase 4 - Depth:**
   - See collapsed "Read More" section
   - Click to expand
   - See full deep content: "GDPR requires..."
   - Click **Continue**

8. **Phase 5 - Summary:**
   - See results: "1/1 correct"
   - See scenario breakdown
   - See time spent
   - Click **Back to Dashboard**

---

## 6. Verify Analytics

### In Supabase Studio:

1. Open Studio: http://127.0.0.1:54323
2. Go to **scenario_responses** table
   - Filter by user_id (Coach A)
   - Should see 1 row with:
     - `scenario_id`: matches your scenario
     - `chosen_option`: "A"
     - `is_correct`: true
     - `time_spent_seconds`: (positive number)

3. Go to **analytics_events** table
   - Filter by user_id (Coach A)
   - Should see events:
     - `scenario_viewed`
     - `decision_submitted`
     - `feedback_viewed`
     - `read_more_clicked`

---

## 7. Build for Production

```bash
# Build optimized production bundle
npm run build

# Should output:
# ✓ built in X.XXs

# Preview production build locally
npm run preview

# Open http://localhost:4173
```

---

## 8. Common Commands

```bash
# Development
npm run dev              # Start dev server
npm run build            # Build production
npm run preview          # Preview production build
npm run lint             # Run ESLint
npm run test             # Run Vitest
npm run test:watch       # Vitest watch mode

# Supabase
supabase start           # Start local Supabase
supabase stop            # Stop containers (preserves data)
supabase reset           # Wipe and reapply all migrations
supabase status          # Show URLs and keys
supabase db push         # Push migrations to remote

# Git
git status               # Check branch and changes
git diff                 # Show what changed
git log --oneline        # Show recent commits
git push                 # Push to remote
```

---

## 9. Troubleshooting

### Issue: Port 5173 already in use

```bash
# Find and kill process on port 5173
lsof -ti :5173 | xargs kill -9

# Or use different port
npm run dev -- --port 5174
```

### Issue: Supabase won't start (Docker error)

```bash
# Make sure Docker Desktop is running
# macOS: Open Applications → Docker

# Or restart Supabase
supabase stop
supabase start
```

### Issue: Types.ts out of sync with database

```bash
# Regenerate types from local Supabase
supabase gen types typescript --local > src/integrations/supabase/types.ts
```

### Issue: Migrations won't apply

```bash
# Check migration status
supabase db reset --local
# This wipes data and reapplies all migrations

# Or push to remote
supabase db push --include-all
```

### Issue: Console shows "Cannot find module" errors

```bash
# Clear node_modules and reinstall
rm -rf node_modules
npm install

# Clear Vite cache
rm -rf .vite dist

# Restart dev server
npm run dev
```

---

## 10. Quick Reference

| Component | Location | Route |
|-----------|----------|-------|
| Dashboard | `src/pages/Dashboard.tsx` | `/dashboard` |
| Profile | `src/pages/Profile.tsx` | `/profile` |
| Scenario Flow | `src/pages/ScenarioFlow.tsx` | `/training/:trainingId/scenario` |
| Admin Regions | `src/pages/admin/AdminRegions.tsx` | `/admin/regions` |
| Admin Scenarios | `src/pages/admin/AdminScenarios.tsx` | `/admin/units/:unitId/scenarios` |
| Admin Options | `src/pages/admin/AdminScenarioOptions.tsx` | `/admin/scenarios/:scenarioId/options` |

| Database Table | Purpose |
|---|---|
| `scenarios` | Learning scenarios |
| `scenario_options` | A/B/C/D choices |
| `scenario_responses` | User decisions |
| `analytics_events` | Event tracking |
| `regions` | Geographic regions |
| `user_regions` | User-region mapping |

---

## 11. Next Steps

1. ✅ Follow steps 1–6 above to set up and test
2. ✅ Review `TESTING_CHECKLIST_PHASE_1.md` for comprehensive test paths
3. ✅ Check `PHASE_1_COMPLETION_SUMMARY.md` for architecture details
4. ✅ Review `SESSION_SUMMARY_2026_04_14.md` for what was built

**All Phase 1 code is committed to:** `feature/coachcert-architecture-redesign` (commit fb8c90a)

**Ready to test!** 🚀
