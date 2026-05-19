# Neo Backend Audio Limit Fix

## Problem
Frontend is getting 404 errors when audio file exceeds backend audio size limit, instead of a proper error response.

## Root Cause
- Backend (neo-start edge function) is returning 404 instead of appropriate HTTP status code for audio limit
- 404 means "not found" — users think endpoint is broken, not that audio is too large
- Frontend can't distinguish between "endpoint doesn't exist" vs "audio too large"

## Frontend Fix (Applied)
✅ Better error message handling in NeoAnalysis.tsx:
- If 404 + file size > 10MB → suggest shorter recording
- If 413 or 429 → show "Audio limit exceeded"
- Recording time warning → shows amber warning after 5 minutes

## Backend Fix Needed (Tell Neo Person)

### What to Fix
In `supabase/functions/neo-start/index.ts`, add audio size validation:

**Option A: Return proper HTTP status**
```
If file size > limit:
  Return 413 Payload Too Large (standard HTTP)
  Body: { error: "Audio file exceeds 10MB limit. Please record a shorter debrief (under 5 minutes)." }
```

**Option B: Return custom error (if 413 won't work)**
```
If file size > limit:
  Return 400 Bad Request (or 422 Unprocessable Entity)
  Body: { error: "Audio limit exceeded", code: "AUDIO_TOO_LARGE", max_size_mb: 10 }
```

**Option C: Return 429 (if tracking quota)**
```
If audio quota exceeded:
  Return 429 Too Many Requests
  Body: { error: "Daily audio upload limit reached", retry_after: 3600 }
```

### Why Not 404
- 404 = "resource not found" (endpoint missing)
- Audio limit error = 413, 400, 422, or 429
- Frontend needs correct status code to show right message to user

### Testing
1. Send audio file > 10MB to neo-start endpoint
2. Should NOT get 404
3. Should get 413/400/422/429 with clear error message
4. Frontend will then show: "Audio file too large. Please record a shorter debrief."

### Current Audio Size Limit
**Question for Neo person:** What is the current limit? (Is it 10MB, 5MB, 100MB?)
- Frontend warning currently triggers at 5 minutes (~15-20MB at typical bitrate)
- If backend limit is different, adjust frontend warning threshold

---

## Testing the Fix

### Test 1: Normal Recording (Should Work)
1. Record 30-60 seconds of audio
2. Click Stop & Upload
3. Should upload successfully → Neo analysis starts

### Test 2: Long Recording (Should Show Warning)
1. Record 5+ minutes continuously
2. Should see amber warning: "⚠️ Long recording (5+ min). Consider stopping and uploading to avoid upload issues."
3. Click Stop
4. Try Upload
5. If file > backend limit → should see helpful error message (not generic "404")

### Test 3: Offline Recording (Should Auto-Sync)
1. DevTools Network → Offline
2. Record 1 minute
3. Click Stop & Upload
4. Should see: "Audio saved offline — will upload when connection returns"
5. DevTools Network → Online
6. Should auto-upload silently
7. Should NOT see any 404 error

---

## Commit Message (When Neo Person Fixes)
```
Fix: Return proper error code for audio size limit in neo-start

Previously returned 404 when audio exceeded size limit, confusing users
into thinking the endpoint was broken. Now returns 413 Payload Too Large
with clear error message: "Audio file exceeds 10MB limit. Please record
a shorter debrief (under 5 minutes)."

Frontend warning now triggers at 5 minutes to catch large recordings
before upload attempt.
```

---

## Files Modified
- `src/components/observation/NeoAnalysis.tsx` — Better error handling + recording time warning
- `supabase/functions/neo-start/index.ts` — (Todo: neo-start backend fix)

## Deployed To
- Frontend: Staging (2026-05-15, merged to main after testing)
- Backend: Waiting for neo-start fix from backend team
