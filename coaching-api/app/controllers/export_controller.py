from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
from app.database import get_db
from app.services.module_service import ModuleService
from app.config import settings

router = APIRouter(prefix="/api/export", tags=["export"])


@router.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "ok",
        "version": settings.api_version,
        "environment": settings.environment,
        "timestamp": datetime.utcnow().isoformat(),
    }


@router.get("/complete")
async def export_complete(db: Session = Depends(get_db)):
    """Export all training content."""
    service = ModuleService(db)
    modules = service.fetch_all_modules()

    if not modules:
        raise HTTPException(status_code=404, detail="No modules found")

    return {
        "modules": [m.to_dict() for m in modules],
        "export_metadata": {
            "version": settings.api_version,
            "exported_at": datetime.utcnow().isoformat(),
            "source": "coaching-platform-postgresql",
            "total_stats": {
                "modules": len(modules),
                "trainings": sum(len(m.trainings) for m in modules),
                "questions": sum(
                    len(t.questions) for m in modules for t in m.trainings
                ),
                "scenarios": sum(
                    len(t.scenarios) for m in modules for t in m.trainings
                ),
            },
        },
    }


@router.get("/modules")
async def list_modules(db: Session = Depends(get_db)):
    """List all modules (minimal info)."""
    service = ModuleService(db)
    modules = service.fetch_all_modules()

    if not modules:
        raise HTTPException(status_code=404, detail="No modules found")

    return {
        "modules": [
            {
                "id": m.id,
                "title": m.title,
                "description": m.description,
                "order_number": m.order_number,
                "unit_count": len(m.trainings),
                "question_count": sum(len(t.questions) for t in m.trainings),
            }
            for m in modules
        ]
    }


@router.get("/modules/{module_id}")
async def get_module(module_id: str, db: Session = Depends(get_db)):
    """Get single module with all content."""
    service = ModuleService(db)
    module = service.fetch_module_by_id(module_id)

    if not module:
        raise HTTPException(status_code=404, detail="Module not found")

    return module.to_dict()


@router.get("/trainings/{training_id}")
async def get_training(training_id: str, db: Session = Depends(get_db)):
    """Get single training with questions and scenarios."""
    service = ModuleService(db)
    training = service.fetch_training_by_id(training_id)

    if not training:
        raise HTTPException(status_code=404, detail="Training not found")

    return training.to_dict()
