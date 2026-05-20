# Database Migration — Next Steps

## Current Status ✅

The FastAPI backend and Alembic migrations are configured and ready. All Python dependencies are installed.

**Issues Resolved:**
- ✅ psycopg driver configured (Python 3.14 compatible)
- ✅ SQLAlchemy ORM models defined (7 tables)
- ✅ Alembic migrations created
- ✅ Database configuration module

## Database Connection Issue

The Railway PostgreSQL internal hostname (`postgres.railway.internal`) is only accessible **from within Railway's network**. 

From local development, you must use the **public Railway PostgreSQL URL** instead.

### Option A: Use Railway Public URL (Recommended for Initial Setup)

1. **Get the public Railway PostgreSQL URL:**
   ```bash
   railway link  # Select coaching-platform project
   railway variables --service Postgres | grep DATABASE_URL
   ```

   Look for a URL like: `postgresql://postgres:password@host.railway.app:5432/railway`

2. **Set environment variable:**
   ```bash
   export DATABASE_URL='postgresql://postgres:password@host.railway.app:5432/railway'
   ```

3. **Run migration:**
   ```bash
   source venv/bin/activate
   alembic upgrade head
   ```

4. **Verify schema created:**
   ```bash
   psql $DATABASE_URL -c "\dt"
   ```

   Should show:
   ```
   modules
   trainings
   training_content
   questions
   options
   scenarios
   scenario_options
   ```

### Option B: Use Railway's Private URL from Docker

When deployed to Railway, the internal hostname `postgres.railway.internal:5432` will work automatically. No changes needed.

## Next Steps After Migration

1. **Test API locally:**
   ```bash
   uvicorn app.main:app --reload
   # Visit: http://localhost:8000/docs
   ```

2. **Build data migration script** (`scripts/migrate_content.py`):
   - Connect to Supabase (read-only)
   - Extract all training content
   - Transform and insert into Railway PostgreSQL
   - Validate counts match

3. **Deploy to Railway:**
   ```bash
   railway up
   ```

---

**Questions?** See SETUP_RAILWAY.md or README.md for more details.

