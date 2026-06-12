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
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:8080", "http://localhost:8081", "http://localhost:3000"],
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
    """Create tables that don't exist yet."""
    from app.database import engine, Base
    # Import all models to register them
    import app.models  # noqa: F401
    Base.metadata.create_all(bind=engine)


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
