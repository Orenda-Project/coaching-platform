# User Profile System

## Overview

The profile system allows coaches to view and edit their personal information, learning progress, and achievement metrics.

## User Profile Page

**Route:** `/profile` (protected route, authenticated users only)

## Sections

### 1. Personal Information (Editable)

**Fields:**
- `full_name` — User's full name
- `phone` — Contact phone number
- `school_id` — School or organization identifier

**Edit Mode:**
- Click "Edit" button to enable editing
- Fields become editable inputs
- "Save" button saves changes to `profiles` table
- "Cancel" button discards changes and returns to view mode
- Toast notification on success/error

**API:**
```sql
UPDATE profiles SET
  full_name = 'New Name',
  phone = '+1234567890',
  school_id = 'SCHOOL-001'
WHERE id = user_id;
```

### 2. Account Information (Read-Only)

**Fields:**
- `email` — Email from auth.users (read-only)
- `created_at` — Account creation date (read-only)

These fields cannot be edited from the profile page; email changes require auth verification.

### 3. Learning Profile

**Fields:**
- `persona` — Current coaching level (A/B/C/D) with color badge
- `baseline_score` — Baseline assessment score (%)
- `baseline_attempt_count` — Number of baseline attempts
- `endline_score` — Endline assessment score (%)
- `endline_attempt_count` — Number of endline attempts

**Status Display:**
- Baseline: "Not started" / "In progress" / "Completed"
- Endline: "Not available" (until all modules passed) / "In progress" / "Completed"

### 4. Progress Metrics

**Fields:**
- `weak_modules` — Array of module titles where user scored <70% on baseline
- `achievement_level` — Derived from persona (e.g., "Proficient Coach")
- `modules_completed` — Count of passed modules (derived from training_progress)

**Weak Modules:**
- Listed as chips/badges if any exist
- Empty state: "No weak modules — strong foundation!"
- Clicking a weak module could navigate to that module (future enhancement)

---

## Data Model

**profiles Table:**
```sql
id UUID PRIMARY KEY (fk auth.users)
user_id UUID FK (auth.users.id) UNIQUE
email TEXT (from auth.users, denormalized)
full_name TEXT
phone TEXT
school_id TEXT
persona TEXT CHECK (IN ('A','B','C','D'))
baseline_completed BOOLEAN
baseline_score INT (0-100)
baseline_attempt_count INT
endline_completed BOOLEAN
endline_score INT (0-100)
endline_attempt_count INT
weak_modules TEXT[] (array of module titles)
region TEXT
created_at TIMESTAMPTZ
updated_at TIMESTAMPTZ
```

---

## Edit Mode Behavior

### Entering Edit Mode
1. Click "Edit" button
2. Forms unlock for input
3. "Save" and "Cancel" buttons appear
4. Current values populate fields

### Saving Changes
1. Client-side validation (required fields)
2. Call `supabase.from("profiles").update({...}).eq("id", user.id)`
3. On success:
   - Toast: "Profile updated successfully"
   - Refresh profile context (call `refreshProfile()`)
   - Return to view mode
4. On error:
   - Toast: "Failed to update profile. Please try again."
   - Keep edit mode open for retry

### Canceling Edit
1. Click "Cancel" button
2. All changes discarded
3. Return to view mode with original values

---

## Permissions & Security

- **View own profile:** Authenticated user can view their own profile
- **Edit own profile:** Authenticated user can edit their own profile only
- **View others' profiles:** Not implemented (future: admin feature for coach management)
- **Email changes:** Require auth re-verification (not in profile page)

RLS Policy (profiles table):
```sql
-- Authenticated users can read own profile
CREATE POLICY "Users can read own profile" ON profiles
  FOR SELECT
  USING (auth.uid() = user_id);

-- Authenticated users can update own profile
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Admins can read all profiles
CREATE POLICY "Admins can read all profiles" ON profiles
  FOR SELECT
  USING (has_role(auth.uid(), 'admin'));
```

---

## Integration Points

### AuthContext
Profile page uses `useAuth()` hook:
```typescript
const { user, profile, refreshProfile } = useAuth();
```

### Learning Progress
Profile displays derived metrics from:
- `training_progress` table for modules completed
- `baseline_responses` / `endline_responses` for scores (future)

### Certificates
Once endline passed, user can navigate to `/certificate` to view/download their certificate.

---

## Future Enhancements

- **Weak module quick-link:** Click module name → navigate to that module
- **Achievement badges:** Visual badges for milestones (modules completed, time invested, etc.)
- **Learning history:** Timeline of assessment attempts with scores
- **Goals setting:** User-defined coaching development goals
- **Preferences:** Theme, notification settings, calendar integrations
- **Admin profile view:** Admins can view/edit coach profiles for management
- **Regional assignment:** User-region mapping visible in profile

---

## Accessibility

- All form inputs have associated labels
- Edit/Cancel/Save buttons clearly labeled
- Read-only fields marked as disabled (not in tab order)
- Toast notifications announce status changes
- Error messages include guidance for remediation

---

**Last Updated:** 2026-04-14
