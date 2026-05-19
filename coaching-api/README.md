# Coaching Platform Content Export API

A FastAPI service that extracts training content from the coaching platform and exposes it via REST API endpoints for internal teams.

## Quick Start

### Local Development

**1. Install dependencies:**
```bash
cd coaching-api
pip install -r requirements.txt
```

**2. Set up environment:**
```bash
cp .env.example .env
# Edit .env with your database URL
```

**3. Create database and run migrations:**
```bash
# Using Alembic
alembic upgrade head
```

**4. Start development server:**
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**5. Access API:**
- Swagger UI: http://localhost:8000/docs
- Health check: http://localhost:8000/api/export/health
- OpenAPI schema: http://localhost:8000/openapi.json

---

## API Endpoints

### Health Check
```
GET /api/export/health
```
Returns: Service status, version, environment

### Complete Export
```
GET /api/export/complete
```
Returns: All 6 modules with trainings, content, and questions

### List Modules
```
GET /api/export/modules
```
Returns: Modules with metadata (minimal info)

### Get Module
```
GET /api/export/modules/{module_id}
```
Returns: Single module with all children

### Get Training
```
GET /api/export/trainings/{training_id}
```
Returns: Single training with questions and scenarios

---

## Project Structure

```
coaching-api/
├── app/
│   ├── main.py                  # FastAPI app
│   ├── config.py                # Settings
│   ├── database.py              # SQLAlchemy setup
│   ├── models/
│   │   ├── __init__.py
│   │   └── training.py          # ORM models
│   ├── services/
│   │   ├── __init__.py
│   │   └── module_service.py    # Business logic
│   ├── controllers/
│   │   ├── __init__.py
│   │   └── export_controller.py # Route handlers
│   └── utils/
│       └── __init__.py
├── migrations/                  # Alembic database migrations
│   ├── versions/
│   │   └── 001_create_training_schema.py
│   ├── env.py
│   └── alembic.ini
├── tests/                       # Test suite
├── requirements.txt             # Python dependencies
├── .env.example                 # Environment template
├── Dockerfile                   # Docker image
├── railway.toml                 # Railway deployment config
└── README.md
```

---

## Data Migration (Supabase → Railway PostgreSQL)

To migrate training content from Supabase to Railway PostgreSQL, run the migration script (to be created next):

```bash
python scripts/migrate_content.py --dry-run    # Preview what will be migrated
python scripts/migrate_content.py --commit    # Execute migration
```

---

## Deployment

### Railway

The service is configured to deploy on Railway via Docker.

**Prerequisites:**
- Docker image built and pushed
- Railway PostgreSQL service linked (via `railway.toml`)
- Environment variables set in Railway

**Deploy:**
```bash
railway up
```

**Check logs:**
```bash
railway logs
```

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `DATABASE_URL` | `postgresql://...` | PostgreSQL connection string |
| `API_VERSION` | `1.0` | API version |
| `ENVIRONMENT` | `development` | Environment (development, staging, production) |
| `LOG_LEVEL` | `info` | Logging level |

---

## Testing

Run tests:
```bash
pytest
```

Run with coverage:
```bash
pytest --cov=app
```

---

## Next Steps

1. **Set up Railway PostgreSQL** and get connection string
2. **Run migrations** to create schema
3. **Create data migration script** to import from Supabase
4. **Test locally** with seed data
5. **Deploy to Railway** and test
6. **Share API URL** with internal teams

---

## Support

For issues or questions:
- Check health endpoint: `/api/export/health`
- Review API docs: `/docs`
- Check logs: `railway logs` or `docker logs`

---

## Future Features

- [ ] ZIP file export
- [ ] CSV export for questions
- [ ] Filtering by persona
- [ ] Pagination for large exports
- [ ] Caching for performance
- [ ] Assessment endpoints
- [ ] Certificate tracking
- [ ] Analytics integration
