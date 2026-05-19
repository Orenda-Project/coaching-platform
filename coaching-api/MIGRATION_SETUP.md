# Data Migration Setup Guide

## Current Status

✅ **Infrastructure Ready:**
- Railway PostgreSQL: Connected and verified
- FastAPI Backend: Scaffolded with SQLAlchemy ORM
- Database Schema: 7 tables created (`export_modules`, `export_trainings`, etc.)
- Migration Script: Built with Typer CLI

❌ **Missing Credentials:**
- Supabase Service Role Key (needed to read data from production)

---

## Step 1: Get Supabase Service Role Key

To migrate your training content from Supabase to Railway PostgreSQL, you need the Supabase service role key:

### Instructions:
1. Go to Supabase Dashboard: https://app.supabase.com/
2. Select project: **agziuwqpkfmxtospfxns** (coaching-platform)
3. Navigate to: **Settings → API → Project API keys**
4. Find the **service_role** key (labeled as "Secret")
   - This is a long JWT token starting with `eyJ...`
   - **DO NOT** share this publicly
5. Copy the full key

### Add to .env:

Edit `coaching-api/.env` and update:

```env
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Replace the placeholder with your actual service role key.

---

## Step 2: Test Connection

Verify Supabase is accessible:

```bash
cd coaching-api
source venv/bin/activate
python scripts/migrate_content.py --dry-run
```

### Expected Output:
```
============================================================
Migration Mode: DRY RUN
============================================================

📊 Fetching Supabase data...
✓ Supabase totals:
  - modules: 6 rows
  - trainings: ~60 rows
  - questions: ~60 rows
  - options: ~240 rows
  - scenarios: N rows
  - scenario_options: N rows
  Total: ~400 rows
```

---

## Step 3: Run Migration

Once dry-run succeeds, execute the actual migration:

```bash
python scripts/migrate_content.py --commit
```

### What It Does:
1. Fetches all data from Supabase (read-only)
2. Transforms data to match Railway PostgreSQL schema
3. Inserts into `export_*` tables using upsert (handles duplicates)
4. Validates row counts match source

### If It Fails:
- Check `.env` has valid `SUPABASE_SERVICE_KEY`
- Verify `DATABASE_URL` points to Railway PostgreSQL
- Check that no rows violate foreign key constraints

---

## Step 4: Verify Data

Query Railway PostgreSQL to confirm data:

```bash
python3 << 'EOF'
from app.database import SessionLocal
from app.models.training import Module

db = SessionLocal()
modules = db.query(Module).all()
print(f"✅ Modules in Railway: {len(modules)}")
for m in modules:
    print(f"   - {m.title} ({len(m.trainings)} trainings)")
EOF
```

---

## Common Issues

### "Invalid API key" error
- **Cause:** Service role key is wrong or expired
- **Fix:** Double-check key from Supabase Settings → API

### "UNIQUE constraint violation"
- **Cause:** Data already exists in Railway PostgreSQL
- **Fix:** Run migration script again (upsert handles duplicates)

### "Connection refused" to Railway
- **Cause:** Using internal hostname from local machine
- **Fix:** `.env` should use public URL: `viaduct.proxy.rlwy.net:29190`

---

## Next Steps

After successful migration:

1. **Test Export API:** `GET /api/export/complete` should return all modules
2. **Deploy to Railway:** Push branch and Railway auto-deploys
3. **Monitor:** Check Railway logs for any errors

---

## Architecture

```
Supabase (Source)
    ↓
Migration Script (Python)
    ↓
Railway PostgreSQL (Destination)
    ↓
FastAPI Backend (Export Service)
    ↓
Internal Teams (JSON API)
```

The migration is **one-time** (idempotent). Run it multiple times if needed — upsert handles duplicates.

---

## Questions?

See `MIGRATION_NEXT_STEPS.md` for the full roadmap.
