# Sub-Region Feature Implementation

## Overview
Added sub-region field to both the onboarding flow and user profile management.

## Changes Made

### 1. Onboarding Flow (`src/pages/Onboarding.tsx`)
- Added `subRegion` state variable
- Added `SUB_REGIONS` constant with options: `["Nilore", "Tarnol", "Sihala", "B.K", "Urban-I", "Urban-II"]`
- Added sub-region validation (required) in `handleSubmit`
- Added sub-region to the profile update payload
- Added UI field after region selection with icon and help text

### 2. Profile Page (`src/pages/Profile.tsx`)
- Added `sub_region` to form state object
- Added `SUB_REGIONS` constant matching signup
- Added `MapPin` icon import
- Added sub-region field to edit mode (select dropdown)
- Added sub-region field to view mode (read-only display)
- Integrated sub-region loading from profile data
- Integrated sub-region save to database

### 3. SignUp Changes (`src/pages/SignUp.tsx`)
- **REMOVED:** Sub-region field from signup form (moved to onboarding)
- **REMOVED:** Sub-region state variable
- **REMOVED:** Sub-region validation
- **REMOVED:** Select/SelectContent/SelectItem/SelectTrigger/SelectValue imports (no longer needed)
- Simplified form to: full name, email, phone, password only

### 4. AuthContext Changes (`src/contexts/AuthContext.tsx`)
- **REMOVED:** `subRegion` parameter from `signUp` function signature
- **REMOVED:** coach_assignments insert logic (sub-region now captured in onboarding)
- Simplified signup to just create auth user with metadata

### 5. Database Migration
- Created migration file: `20260508000001_add_sub_region_to_profiles.sql`
- Adds `sub_region TEXT` column to profiles table
- Creates index on `(region, sub_region)` for query optimization

## User Journey

### Signup → Onboarding
1. User signs up (full name, email, phone, password) in SignUp.tsx
2. User redirected to onboarding page
3. User must select Region (required)
4. **NEW:** User must select Sub-Region (required) - appears after region field
5. User can fill optional fields (school, teachers, qualifications, experiences)
6. On submit, both region and sub_region are saved to profiles table
7. User redirected to dashboard

### Edit Profile
1. User navigates to Profile page
2. Clicks Edit button
3. Region dropdown (existing)
4. **NEW:** Sub-Region dropdown with same options
5. Can edit sub-region and save changes
6. View mode displays selected sub-region

## Sub-Region Options
- Nilore
- Tarnol
- Sihala
- B.K
- Urban-I
- Urban-II

## Database Schema
```sql
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS sub_region TEXT;

CREATE INDEX idx_profiles_region_sub_region
  ON public.profiles(region, sub_region);
```

## Testing Checklist
- [ ] Signup form no longer shows sub-region field
- [ ] Signup only requires: full name, email, phone, password
- [ ] Onboarding loads with empty sub-region field
- [ ] Onboarding requires sub-region selection (before submit)
- [ ] Onboarding saves sub-region to profiles.sub_region
- [ ] Profile page loads sub-region from profile data on page load
- [ ] Profile edit mode allows changing sub-region via dropdown
- [ ] Profile saves sub-region changes to database
- [ ] Profile view mode displays sub-region correctly

## Notes
- Sub-region moved from signup to onboarding flow (cleaner UX)
- Sub-region is required in onboarding (must select from dropdown)
- Both onboarding and profile use identical sub-region list for consistency
- SignUp is now simpler (core auth only)
- Coach assignment logic can be added separately if needed
- No RTL or internationalization yet (can be added later)
