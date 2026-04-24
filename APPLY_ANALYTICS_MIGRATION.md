# Apply Analytics Migration to Supabase

**Problem:** `analytics_events` table doesn't exist in your Supabase database

**Status:** Migration file exists, just needs to be applied

---

## ✅ Solution: Apply Migration

### Option 1: Via Supabase Dashboard (Easiest)

1. Go to Supabase Studio → Your Project
2. Click **SQL Editor**
3. Click **New Query**
4. Copy the migration SQL from:
   ```
   supabase/migrations/20260425000001_scenario_first_foundation.sql
   ```
5. Paste the entire file contents into the editor
6. Click **Run**
7. Wait for it to complete
8. Refresh the Tables page → should see `analytics_events` ✅

### Option 2: Via CLI (If Docker/Supabase Local)

```bash
# If using local Supabase
supabase db reset
# This will apply ALL migrations in order
```

### Option 3: Via Railway/Production

If your staging/production is on Railway:
1. Merge the feature branch to staging
2. Railway will auto-run migrations during deploy
3. The `analytics_events` table will be created

---

## 🔍 Verify the Table Exists

After applying migration, run this in Supabase SQL Editor:

```sql
-- Check if table exists
SELECT * FROM analytics_events LIMIT 1;
-- Should return: (no rows) or empty result

-- Check table structure
SELECT * FROM information_schema.tables 
WHERE table_name = 'analytics_events';
-- Should show the table details
```

---

## 📋 What the Migration Creates

**Table:** `analytics_events`

**Columns:**
```sql
- id (UUID, primary key)
- user_id (UUID, foreign key to profiles)
- event_type (TEXT) - "scenario_viewed", "decision_submitted", etc.
- scenario_id (UUID, optional)
- unit_id (UUID, optional)
- metadata (JSONB) - Custom event data
- created_at (TIMESTAMP)
```

**Indexes:**
- idx_analytics_events_user_id
- idx_analytics_events_created_at
- idx_analytics_events_scenario_id
- idx_analytics_events_unit_id

**RLS Policies:**
- Authenticated users can INSERT events
- Admins can READ all events

---

## 🚀 After Migration is Applied

1. **Test tracking:**
   - Use the `/admin/analytics` page
   - Open a scenario
   - Check Supabase SQL Editor:
   ```sql
   SELECT * FROM analytics_events ORDER BY created_at DESC LIMIT 5;
   ```
   - Should show events from your activity

2. **Verify dashboard:**
   - Navigate to `/admin/analytics`
   - Should load without errors
   - Should show coach data and analytics

3. **Check for errors:**
   - Open browser DevTools (F12)
   - Go to Console tab
   - Should NOT see `[analytics]` warnings

---

## 📍 Migration File Location

**Path:** `supabase/migrations/20260425000001_scenario_first_foundation.sql`

**Size:** ~8KB

**Contains:**
- scenarios table
- scenario_options table
- scenario_responses table
- **analytics_events table** ← this one
- regions table
- user_regions table
- All RLS policies

---

## ⚠️ Troubleshooting

### Migration Fails with "Table already exists"
- The table was partially created
- Delete and re-run the migration
- Or run: `DROP TABLE IF EXISTS analytics_events CASCADE;` first

### Can't see analytics_events in table list
- Refresh the Supabase page (Cmd+R or Ctrl+R)
- Check if there are any SQL errors
- Verify the migration file ran completely

### `/admin/analytics` page shows errors
- Make sure migration is fully applied
- Clear browser cache
- Restart your dev server

---

## Next Steps

1. ✅ Apply the migration (one of the 3 options above)
2. ✅ Verify table exists in Supabase
3. ✅ Test `/admin/analytics` page
4. ✅ Trigger an event by using a scenario
5. ✅ Query the table to see the event was recorded

---

**Timeline:** 2-5 minutes to apply and verify
