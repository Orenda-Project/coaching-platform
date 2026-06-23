import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.controllers import export_controller, quiz_controller, auth_controller, assessment_controller, training_controller, analytics_controller, admin_controller, coaching_controller
# Temporarily disabled: scenario_controller has import error (depends on Scenario model conflict)
# from app.controllers import scenario_controller

# Create FastAPI app
app = FastAPI(
    title=settings.api_title,
    description=settings.api_description,
    version=settings.api_version,
)

# CORS middleware - must be added FIRST for proper precedence
_cors_origins = [
    # Local development
    "http://localhost:5173",
    "http://localhost:8080",
    "http://localhost:8081",
    "http://localhost:3000",
    # Railway staging
    "https://coaching-platform-staging.up.railway.app",
    # Railway production
    "https://coaching-platform-production.up.railway.app",
    "https://coaching-platform-production-43ff.up.railway.app",
]
# Allow extra origins from env (comma-separated)
_extra = os.environ.get("CORS_ORIGINS", "")
if _extra:
    _cors_origins.extend([o.strip() for o in _extra.split(",") if o.strip()])

app.add_middleware(
    CORSMiddleware,
    allow_origins=_cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],
    allow_headers=["*"],
    max_age=3600,  # Cache preflight for 1 hour
)

# Include routers
app.include_router(export_controller.router)
app.include_router(quiz_controller.router)
app.include_router(auth_controller.router)
app.include_router(assessment_controller.router)
app.include_router(training_controller.router)

# Phase 4: Analytics & Scenarios APIs
app.include_router(analytics_controller.router)
# Temporarily disabled: scenario_controller has import error
# app.include_router(scenario_controller.router)

# Phase 5: Admin Management APIs
app.include_router(admin_controller.router)

# Phase 3: Coaching APIs
# app.include_router(observation_controller.router)  # Old Phase 3 observation controller (disabled)
app.include_router(coaching_controller.router)


@app.on_event("startup")
async def startup_event():
    """Create tables that don't exist yet and apply incremental migrations."""
    import logging
    from app.database import engine, Base
    import app.models  # noqa: F401
    try:
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        logging.getLogger(__name__).warning(f"create_all partially failed (tables may already exist): {e}")

    # Incremental migrations — idempotent, safe to run on every startup
    _migrations = [
        # 004: visit scheduling time columns
        "ALTER TABLE cot_observations ADD COLUMN IF NOT EXISTS arrival_time varchar",
        "ALTER TABLE cot_observations ADD COLUMN IF NOT EXISTS departure_time varchar",
        "ALTER TABLE cot_observations ADD COLUMN IF NOT EXISTS planned_date varchar",
        "ALTER TABLE cot_observations ADD COLUMN IF NOT EXISTS visit_type varchar",
        # 005: profiles cluster columns
        "ALTER TABLE profiles ADD COLUMN IF NOT EXISTS punjab_cluster varchar",
        "ALTER TABLE profiles ADD COLUMN IF NOT EXISTS rawalpindi_cluster varchar",
    ]
    with engine.connect() as conn:
        for sql in _migrations:
            try:
                conn.execute(__import__('sqlalchemy').text(sql))
            except Exception as e:
                logging.getLogger(__name__).warning(f"Migration skipped: {e}")
        conn.commit()


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": "Coaching Platform Content Export API",
        "version": settings.api_version,
        "docs": "/docs",
    }


@app.get("/health")
async def health_check():
    """Health check endpoint for Railway deployment."""
    return {
        "status": "healthy",
        "version": settings.api_version,
    }
