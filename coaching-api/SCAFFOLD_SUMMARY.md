# FastAPI Content Export Service - Scaffold Complete ✅

**Date:** 2026-05-18  
**Commit:** 17b2427  
**Branch:** `feature/content-export-api-fastapi`  
**Status:** Week 1, Day 1-2 Complete

---

## What Was Scaffolded

### ✅ Project Structure
```
coaching-api/
├── app/
│   ├── main.py                  # FastAPI app with CORS
│   ├── config.py                # Settings from env vars
│   ├── database.py              # SQLAlchemy + session factory
│   ├── models/training.py       # 7 ORM models
│   ├── services/module_service.py    # Business logic
│   └── controllers/export_controller.py  # 5 API routes
├── migrations/                  # Alembic setup (ready for schema)
│   └── versions/001_create_training_schema.py
├── tests/                       # Test directory (ready)
├── requirements.txt             # All dependencies
├── .env.example                 # Configuration template
├── Dockerfile                   # Docker image
├── railway.toml                 # Railway deployment config
└── README.md                    # Quick start guide
```

### ✅ FastAPI Endpoints (Implemented)
- `GET /` — Root endpoint
- `GET /api/export/health` — Health check (returns status, version, env)
- `GET /api/export/complete` — Full export (all 6 modules with content)
- `GET /api/export/modules` — Module list (minimal, fast)
- `GET /api/export/modules/{id}` — Single module detail
- `GET /api/export/trainings/{id}` — Single training with questions

### ✅ Database Models (7 Tables)
1. `modules` — Training modules (6 total)
2. `trainings` — Training units per module
3. `training_content` — Videos, slides, scenarios
4. `questions` — Quiz questions (20 per module)
5. `options` — Multiple choice answers
6. `scenarios` — Scenario-based learning
7. `scenario_options` — Answers for scenarios

All with proper foreign keys, timestamps, and indexes.

### ✅ Services & Controllers
- **ModuleService** — Fetch and query modules with relations
- **ExportController** — Route handlers + JSON assembly
- **Database** — SQLAlchemy setup + session factory
- **Config** — Environment variable management

### ✅ Deployment Ready
- **Dockerfile** — Multi-stage build, optimized
- **railway.toml** — Auto-deployment config
- **requirements.txt** — 13 pinned dependencies
- **Alembic** — Database migration framework

---

## What's NOT Done Yet (Your Implementation)

### 🔄 Week 1 Days 3-7

1. **Data Migration Script** (`scripts/migrate_content.py`)
   - Read from Supabase: modules, trainings, content, questions, scenarios
   - Transform to Railway PostgreSQL schema
   - Validate row counts, handle errors gracefully
   - Dry-run and commit modes
   - **Your task:** Write the transformation logic

2. **Run Migrations** (once Railway PostgreSQL is ready)
   - Get DATABASE_URL from Railway
   - Set in `.env`
   - Run: `alembic upgrade head`
   - **Your task:** Execute and verify schema created

3. **Seed Data via Migration Script**
   - Import all training content from Supabase
   - Verify counts match
   - **Your task:** Run and troubleshoot

4. **Test API Locally**
   - `python -m pip install -r requirements.txt`
   - `uvicorn app.main:app --reload`
   - Call endpoints in Swagger UI (`/docs`)
   - **Your task:** Manual testing

5. **Test with Supabase Data** (post-migration)
   - Verify `/api/export/complete` returns all modules
   - Check response time, data integrity
   - **Your task:** Validation

---

## How to Get Started

### Step 1: Set Up Environment
```bash
cd coaching-api
cp .env.example .env
```

### Step 2: Get Railway PostgreSQL Connection
Option A: Via Railway CLI
```bash
railway link  # Select coaching-platform project
railway variables  # Find DATABASE_URL
```

Option B: Via Railway UI
- Go to coaching-platform → coaching-content-db (PostgreSQL)
- Copy DATABASE_URL from variables

### Step 3: Update .env
```bash
# Edit .env with your DATABASE_URL
DATABASE_URL=postgresql://user:pass@host:5432/coaching_content
```

### Step 4: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 5: Create Schema
```bash
alembic upgrade head
```

Verify:
```bash
# Should show tables created
psql $DATABASE_URL -c "\dt"
```

### Step 6: Test Locally
```bash
uvicorn app.main:app --reload
```

Visit: http://localhost:8000/docs

---

## Next: Data Migration Script

You need to create `scripts/migrate_content.py` that:

1. **Connects to Supabase** (read-only)
   ```python
   import supabase
   supabase_client = supabase.create_client(url, key)
   ```

2. **Reads training content tables**
   - `modules`
   - `trainings`
   - `training_content`
   - `questions`
   - `options`
   - `scenarios` (if exists)

3. **Transforms to Railway PostgreSQL schema**
   - Generate UUIDs for IDs (if needed)
   - Map Supabase columns → Railway schema
   - Handle null values

4. **Inserts into Railway PostgreSQL**
   ```python
   from sqlalchemy import create_engine
   engine = create_engine(DATABASE_URL)
   session = Session(engine)
   for row in supabase_data:
       session.add(Module(**row))
   session.commit()
   ```

5. **Validates**
   ```python
   # Compare counts
   supabase_count = supabase_client.from('modules').select('*').count
   railway_count = session.query(Module).count()
   assert supabase_count == railway_count
   ```

6. **Supports dry-run**
   ```bash
   python scripts/migrate_content.py --dry-run   # Preview
   python scripts/migrate_content.py --commit    # Execute
   ```

---

## Architecture Decisions (Locked In)

✅ **FastAPI** — Lightweight, async-ready, great for APIs  
✅ **SQLAlchemy ORM** — Type-safe, migrations support  
✅ **Alembic** — Database versioning like Supabase  
✅ **Docker** — Railway deployment ready  
✅ **Service/Controller pattern** — Separation of concerns  
✅ **Railway PostgreSQL** — Foundation for future migration  

---

## Files Ready for You to Fill In

### `coaching-api/scripts/migrate_content.py` (NEW — you'll create)
```python
import typer
import sqlalchemy as sa
from sqlalchemy.orm import Session
import supabase

app = typer.Typer()

@app.command()
def migrate(dry_run: bool = False):
    """Migrate content from Supabase to Railway PostgreSQL"""
    # Your implementation here
    pass

if __name__ == "__main__":
    app()
```

### `coaching-api/tests/test_export_api.py` (NEW — you'll create)
```python
import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/api/export/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_export_complete():
    # Your test here
    pass
```

---

## Command Reference

```bash
# Development
cd coaching-api
uvicorn app.main:app --reload

# Database
alembic upgrade head          # Apply migrations
alembic downgrade -1          # Rollback

# Testing
pytest                        # Run all tests
pytest -v                     # Verbose
pytest --cov=app             # With coverage

# Migration
python scripts/migrate_content.py --dry-run   # Preview
python scripts/migrate_content.py --commit    # Execute

# Deployment
railway up                    # Deploy to Railway
railway logs                  # View logs
```

---

## Next Phase

Once data is migrated:
1. ✅ Test API endpoints with real data
2. ✅ Share API URL with internal team
3. ✅ Deploy to Railway (staging first)
4. ✅ Performance testing + optimization
5. ✅ Documentation + handoff

---

## Success Criteria (Week 1 End)

- [ ] Railway PostgreSQL created and connected
- [ ] FastAPI deployed locally and starts without errors
- [ ] Schema created via Alembic
- [ ] All training content imported from Supabase
- [ ] `/api/export/complete` returns valid JSON with 6 modules
- [ ] Data counts verified (modules, questions, scenarios match)
- [ ] All API endpoints tested in Swagger UI
- [ ] No errors in coaching platform (still on Supabase, unchanged)
- [ ] Tests written and passing
- [ ] README updated with real examples

---

## You're Now Ready!

✅ **Scaffolding:** Complete  
✅ **Database Schema:** Ready  
✅ **API Endpoints:** Ready  
✅ **Deployment Config:** Ready  

**Your job:** Implement data migration + testing.

Get the Railway PostgreSQL connection string and you can start immediately.

Good luck! 🚀
