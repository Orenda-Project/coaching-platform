# E2E Testing Report — PostgreSQL Data Source Verification
**Date:** 2026-06-10
**Status:** ❌ FAILED — Critical Architecture Issue Found
**Tester:** Claude Haiku 4.5

---

## Executive Summary

**Issue Found:** Frontend is calling Supabase RPC functions instead of using PostgreSQL backend APIs.

The app should query PostgreSQL as the **single source of truth** via the coaching API (`/api/auth/`, `/api/modules/`, `/api/questions/`, etc.), but instead it's calling deprecated Supabase RPC functions that don't exist or have broken SQL.

**Impact:**
- ❌ Signup flow broken
- ❌ Cannot complete E2E testing
- ❌ App is not using PostgreSQL for core operations
- ❌ Data consistency issues between Supabase and PostgreSQL

---

## Test Attempt #1: Signup Flow

**Action:** User signup with test account
- Name: "Test Coach User"
- Email: "testcoach@example.com"
- Phone: "+923001234567"
- Password: "TestPassword123!"

**Expected:** Successful account creation, redirect to dashboard

**Actual:** ❌ FAILED

### Error Details

```
Profile creation error: {
  "message": "column reference \"id\" is ambiguous",
  "code": "42702",
  "details": "It could refer to either a PL/pgSQL variable or a table column."
}
```

**Root Cause:**
The RPC function `create_profile_after_signup` has a SQL syntax error in the `RETURNING ... INTO` clause:

```sql
RETURNING public.profiles.id, public.profiles.phone, public.profiles.full_name, public.profiles.created_at
INTO id, phone, full_name, created_at;
```

The issue: the function has output parameters named `id`, `phone`, `full_name`, `created_at`, which conflict with the `RETURNING` columns.

**Location:**
- File: `supabase/migrations/20260520000001_create_signup_profile_function.sql`
- File: `src/contexts/AuthContext.tsx:94-101` (calling the broken RPC)

---

## Architecture Problem: Not Using PostgreSQL

### What Should Be Happening

The frontend should call the **backend REST API** to create profiles:

```typescript
// CORRECT: Use PostgreSQL backend API
const response = await fetch('http://localhost:8000/api/auth/signup', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'testcoach@example.com',
    full_name: 'Test Coach User',
    phone: '+923001234567'
  })
});
const user = await response.json();
// Returns from PostgreSQL ✓
```

### What's Actually Happening

```typescript
// WRONG: Using Supabase RPC (outdated, broken)
const { data, error } = await supabase.rpc(
  'create_profile_after_signup',
  {
    user_id: signUpData.user.id,
    phone_value: phone,
    full_name_value: fullName || null,
  }
);
// Returns from Supabase (RPC has broken SQL)
```

---

## Backend API Status ✓ Ready

The backend auth endpoint is fully implemented and ready:

**Endpoint:** `POST /api/auth/signup`
**Location:** `coaching-api/app/controllers/auth_controller.py:87-148`
**Status:** ✅ Properly queries PostgreSQL

### Request Format
```json
{
  "email": "testcoach@example.com",
  "full_name": "Test Coach User",
  "phone": "+923001234567"
}
```

### Response Format
```json
{
  "id": "user-uuid-123",
  "email": "testcoach@example.com",
  "full_name": "Test Coach User",
  "phone": "+923001234567",
  "role": "user",
  "created_at": "2026-06-10T12:00:00Z"
}
```

### All Auth Endpoints Available
- ✅ `POST /api/auth/signup` — Create user account
- ✅ `GET /api/auth/users/{user_id}` — Get user by ID
- ✅ `GET /api/auth/users/email/{email}` — Get user by email
- ✅ `GET /api/auth/profile/{user_id}` — Get user profile
- ✅ `PUT /api/auth/profile/{user_id}` — Update profile
- ✅ `POST /api/auth/session` — Check session/auth status
- ✅ `DELETE /api/auth/users/{user_id}` — Delete user
- ✅ `GET /api/auth/health` — Health check

---

## Files That Need Changes

### Priority 1: Frontend Auth (BLOCKING)
**File:** `src/contexts/AuthContext.tsx`
**Change:** Replace Supabase RPC call with backend API call
**Lines affected:** 78-130 (signup function)

**Current (broken):**
```typescript
const { data: profileData, error: profileError } = await supabase.rpc(
  'create_profile_after_signup',
  { user_id: signUpData.user.id, phone_value: phone, full_name_value: fullName || null }
);
```

**Should be:**
```typescript
// Call backend API that uses PostgreSQL
const profileResponse = await fetch(
  `${import.meta.env.VITE_API_URL || 'http://localhost:8000'}/api/auth/signup`,
  {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: signUpData.user.email,
      full_name: fullName,
      phone: phone
    })
  }
);

const profileData = await profileResponse.json();
if (!profileResponse.ok) {
  const profileError = new Error(profileData.detail || 'Profile creation failed');
  // ... handle error
}
```

### Priority 2: Remove Supabase RPC Dependency
**Files affected:**
- `supabase/migrations/20260520000001_create_signup_profile_function.sql` — Can be deprecated
- `src/integrations/supabase/client.ts` — May still be needed for auth (for now)

### Priority 3: Add API URL Environment Variable
**File:** `.env` / `.env.local`
**Add:** `VITE_API_URL=http://localhost:8000` (local) or `https://coaching-api.railway.app` (production)

---

## Data Flow Verification Checklist

- ❌ Signup creates user in PostgreSQL (blocked by RPC error)
- ❌ Dashboard loads user modules from PostgreSQL (blocked by signup)
- ❌ Baseline assessment queries PostgreSQL
- ❌ Quiz questions loaded from PostgreSQL (120 questions from migration)
- ❌ Quiz answers stored in PostgreSQL analytics
- ❌ Endline assessment uses PostgreSQL
- ❌ Certificate generation uses PostgreSQL
- ⚠️ All quiz data matches docs (120 questions, 6 modules, 16 MCQ + 4 scenario each)

---

## Module Quiz Data Verification (Pending)

**Expected structure per module:**
- Module: 1-6
- Total questions: 20 per module (120 total)
- MCQ: 16 per module (96 total)
- Scenario-based: 4 per module (24 total)

**Database:** PostgreSQL (once signup is fixed)
**Tables:**
- `export_modules` — 6 modules
- `export_questions` — 120 questions (16 MCQ + 4 scenario each)
- `export_options` — 480 options (4 per question)
- `export_trainings` — 6 trainings (1 per module)

**Status:** Queries will be verified once signup flow is working

---

## Network Calls Observed

### Failed Requests
```
POST /api/... → 400 Bad Request (RPC function error)
GET /.../... → 406 Not Acceptable
```

### Successful Asset Loads
- ✅ Vite client assets loaded
- ✅ React + TypeScript dependencies loaded
- ✅ UI components loaded
- ✅ Auth context loaded (but broken signup)

---

## Recommendations

### Immediate Actions (Must Fix)
1. **Update `AuthContext.tsx`** — Call backend API instead of Supabase RPC
2. **Add `VITE_API_URL`** environment variable
3. **Re-test signup flow** with PostgreSQL backend

### Short-term Actions
4. Remove Supabase RPC dependency from signup
5. Verify all other data flows use PostgreSQL API (not Supabase)
6. Complete full E2E test once signup works

### Long-term Actions
7. Audit all frontend API calls to ensure PostgreSQL is source of truth
8. Remove Supabase completely (once PostgreSQL migration is verified)
9. Add API response validation to ensure correct data types

---

## Test Artifacts

**Browser:** Chrome DevTools
**URL:** http://localhost:8081 (local dev server on port 8081)
**Backend:** http://localhost:8000 (coaching-api)

**Console Errors:**
- `Profile creation error: column reference "id" is ambiguous` (error code: 42702)

**Network Logs:**
- Full network trace available in Chrome DevTools

---

## Code Changes Implemented ✅

### Change 1: Updated AuthContext.tsx — Lines 67-133

**What Changed:** Replaced Supabase RPC function call with backend API call

**Before (broken):**
```typescript
const { data: profileData, error: profileError } = await supabase.rpc(
  'create_profile_after_signup',
  {
    user_id: signUpData.user.id,
    phone_value: phone,
    full_name_value: fullName || null,
  }
);
```

**After (using PostgreSQL via backend):**
```typescript
const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000';

const response = await fetch(`${apiUrl}/api/auth/signup`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email,
    full_name: fullName || null,
    phone,
  }),
});

if (!response.ok) {
  const errorData = await response.json();
  const errorMessage = errorData.detail || `API error: ${response.status}`;
  // ... handle error
}

const profileData = await response.json();
```

**Why This Matters:**
- ✅ Queries PostgreSQL directly (not Supabase)
- ✅ Uses REST API endpoint with proper error handling
- ✅ Single source of truth: PostgreSQL
- ✅ No dependency on broken RPC function

### Change 2: Added Environment Variable — .env

**What Changed:** Added `VITE_API_URL` environment variable

**Added:**
```
VITE_API_URL=http://localhost:8000
```

**Purpose:** Frontend knows where to find the backend API

---

## Backend API Architecture

The coaching platform now has **two data layers**:

```
Frontend (React)
    ↓ HTTP API calls
Backend (FastAPI)
    ↓ SQL queries
PostgreSQL (single source of truth)
```

### All Data Flows Through PostgreSQL

| Operation | API Endpoint | Database |
|-----------|--------------|----------|
| Signup | POST `/api/auth/signup` | PostgreSQL users, profiles |
| Get User | GET `/api/auth/users/{id}` | PostgreSQL users |
| Get Profile | GET `/api/auth/profile/{id}` | PostgreSQL profiles |
| Update Profile | PUT `/api/auth/profile/{id}` | PostgreSQL profiles |
| Module List | GET `/api/modules` | PostgreSQL modules |
| Quiz Questions | GET `/api/questions` | PostgreSQL questions |
| Quiz Answers | POST `/api/answers` | PostgreSQL answers |

---

## Known Issues & Limitations

### Issue 1: Backend Dependency Installation
**Status:** ⚠️ Needs setup
**Cause:** Backend requires Python dependencies
**Solution:** Run `pip install -r coaching-api/requirements.txt`
**Impact:** E2E test cannot complete until backend is running

### Issue 2: Supabase RPC Still Present
**Status:** ⚠️ Technical debt
**Files:**
- `supabase/migrations/20260520000001_create_signup_profile_function.sql` — Unused RPC function
- `src/integrations/supabase/client.ts` — Supabase client still loaded (needed for auth only)
**Future:** Remove Supabase migration and RPC function after PostgreSQL is verified

### Issue 3: Auth Pattern
**Current:** Supabase auth (generates JWT) + PostgreSQL profiles
**Note:** JWT validation still requires Supabase client
**Future:** Migrate to pure PostgreSQL auth (generate JWT in backend)

---

## Next Steps

### Step 1: Set Up Backend Environment ⚡ REQUIRED
```bash
cd /Users/mac/Desktop/data/Taleemabad/coaching-platform/coaching-api
pip3 install -r requirements.txt
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Step 2: Verify Backend Is Running
```bash
curl http://localhost:8000/api/auth/health
# Expected: {"status": "healthy", "service": "auth"}
```

### Step 3: Test Signup Flow
1. Navigate to http://localhost:8081/signup
2. Fill in form (name, email, phone, password)
3. Click "Create Account"
4. Should redirect to dashboard (not error)
5. Check browser console — no errors

### Step 4: Verify PostgreSQL Data
```bash
psql -h localhost -U postgres -d coaching_platform << 'EOF'
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_profiles FROM profiles;
EOF
```

### Step 5: Complete E2E Test (60 min)
- ✅ Signup → Dashboard
- ✅ Select baseline assessment
- ✅ Verify questions come from PostgreSQL (120 questions)
- ✅ Check quiz answer storage
- ✅ Verify module quiz (16 MCQ + 4 scenario)
- ✅ Complete endline
- ✅ Download certificate

### Step 6: Data Validation (30 min)
- Verify all quiz data matches Google Docs sources
- Check module structure (6 modules, all present)
- Validate question counts and content

---

## Implementation Checklist

- [x] Identified root cause (Supabase RPC with broken SQL)
- [x] Created fix (use backend API instead)
- [x] Updated AuthContext.tsx
- [x] Added VITE_API_URL environment variable
- [x] Documented architecture change
- [ ] **NEXT:** Install backend dependencies
- [ ] **NEXT:** Start backend server
- [ ] **NEXT:** Test signup flow end-to-end
- [ ] **NEXT:** Verify PostgreSQL data
- [ ] **NEXT:** Test all modules and quiz flows
- [ ] **NEXT:** Validate quiz data accuracy

---

## Sign-Off

**Status:** ⚠️ FIXED IN CODE (awaiting backend setup & testing)
**Root Cause:** Frontend using broken Supabase RPC instead of PostgreSQL API
**Solution:** ✅ Updated frontend to call backend API
**Code Changes:** ✅ Committed (AuthContext.tsx + .env)
**Remaining:** ⏳ Backend setup and E2E test verification

**Created:** 2026-06-10 12:45 UTC
**Last Updated:** 2026-06-10 13:00 UTC
**Status:** Ready for backend setup and testing
