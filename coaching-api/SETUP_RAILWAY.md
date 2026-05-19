# Railway PostgreSQL Setup

## Current Status

✅ Railway services created:
- `coaching-content-api` (FastAPI app) — Ready for code
- `Postgres` (Database) — Already running in your project
- `coaching-platform` (Frontend) — Production app, unchanged

## Get Database Connection String

Choose one:

### Option A: Via Railway CLI
```bash
# Navigate to project
cd /Users/mac/Desktop/data/Taleemabad/coaching-platform

# Get the Postgres DATABASE_URL
railway variables --service Postgres
```

Look for: `DATABASE_URL=postgresql://...`

### Option B: Via Railway UI
1. Go to https://railway.app/dashboard
2. Select `coaching-platform` project
3. Click `Postgres` service
4. Go to `Variables` tab
5. Copy `DATABASE_URL`

## Configure Local Environment

```bash
cd coaching-api

# Create .env file
cat > .env << EOF
DATABASE_URL=postgresql://user:pass@host:5432/coaching_content
API_VERSION=1.0
ENVIRONMENT=development
LOG_LEVEL=info
EOF

# Replace DATABASE_URL with actual value from above
nano .env
```

## Verify Connection

```bash
# Install dependencies
pip install -r requirements.txt

# Test database connection
python -c "
from app.config import settings
from sqlalchemy import create_engine
engine = create_engine(settings.database_url)
with engine.connect() as conn:
    print('✅ Database connection successful!')
"
```

## Create Schema

```bash
# Apply Alembic migration
alembic upgrade head

# Verify tables created
python -c "
from app.database import engine
from sqlalchemy import inspect
inspector = inspect(engine)
tables = inspector.get_table_names()
print(f'✅ Tables created: {len(tables)}')
for table in sorted(tables):
    print(f'   - {table}')
"
```

Expected output:
```
✅ Tables created: 7
   - modules
   - options
   - questions
   - scenario_options
   - scenarios
   - training_content
   - trainings
```

## Test Locally

```bash
# Start server
uvicorn app.main:app --reload

# In another terminal, test endpoints
curl http://localhost:8000/api/export/health
```

Expected response:
```json
{
  "status": "ok",
  "version": "1.0",
  "environment": "development",
  "timestamp": "2026-05-18T10:30:00"
}
```

## Troubleshooting

### "Connection refused"
- Check DATABASE_URL is correct
- Verify PostgreSQL is running (railway logs)
- Ensure you have network access

### "Table already exists"
- Schema was already created
- Run: `alembic downgrade base && alembic upgrade head` to reset

### "Authentication failed"
- Verify DATABASE_URL has correct password
- Check it's copied fully (sometimes truncated)

---

**Next:** Create `scripts/migrate_content.py` to import data from Supabase
