from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.controllers import export_controller, quiz_controller, auth_controller, assessment_controller, training_controller

# Create FastAPI app
app = FastAPI(
    title=settings.api_title,
    description=settings.api_description,
    version=settings.api_version,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure based on your frontend domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(export_controller.router)
app.include_router(quiz_controller.router)
app.include_router(auth_controller.router)
app.include_router(assessment_controller.router)
app.include_router(training_controller.router)


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
