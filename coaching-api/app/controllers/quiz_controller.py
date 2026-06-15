from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
from random import sample
from app.database import get_db
from app.services.quiz_service import QuizService
from app.config import settings

router = APIRouter(prefix="/api/quiz", tags=["quiz"])


@router.get("/modules")
async def list_quiz_modules(db: Session = Depends(get_db)):
    """List all quiz modules with question counts."""
    service = QuizService(db)
    modules = service.get_all_modules_with_question_counts()

    if not modules:
        raise HTTPException(status_code=404, detail="No modules found")

    return {
        "modules": modules,
        "total_modules": len(modules),
        "export_metadata": {
            "version": settings.api_version,
            "exported_at": datetime.utcnow().isoformat(),
        },
    }


@router.get("/module/{module_id}/questions")
async def get_module_questions(module_id: str, db: Session = Depends(get_db)):
    """Get all questions for a module (MCQ and scenarios), separated by type."""
    service = QuizService(db)
    questions_data = service.get_all_questions_for_module(module_id)

    if questions_data is None:
        raise HTTPException(status_code=404, detail="Module not found")

    mcq_questions = questions_data["mcq"]
    scenario_questions = questions_data["scenarios"]

    return {
        "module_id": module_id,
        "mcq_count": len(mcq_questions),
        "scenario_count": len(scenario_questions),
        "total_questions": len(mcq_questions) + len(scenario_questions),
        "mcq": mcq_questions,
        "scenarios": scenario_questions,
    }


@router.get("/module/{module_id}/random")
async def get_randomized_quiz(module_id: str, db: Session = Depends(get_db)):
    """Get randomized 16 MCQ + 4 scenarios for a module."""
    service = QuizService(db)
    questions_data = service.get_randomized_quiz(module_id)

    if questions_data is None:
        raise HTTPException(status_code=404, detail="Module not found")

    mcq_questions = questions_data["mcq"]
    scenario_questions = questions_data["scenarios"]

    # Randomize selection: 16 MCQ + 4 scenarios
    selected_mcq = sample(mcq_questions, min(16, len(mcq_questions)))
    selected_scenarios = sample(scenario_questions, min(4, len(scenario_questions)))

    # Combine and shuffle
    all_selected = selected_mcq + selected_scenarios
    shuffled_questions = sample(all_selected, len(all_selected))

    return {
        "module_id": module_id,
        "total_questions": len(shuffled_questions),
        "mcq_selected": len(selected_mcq),
        "scenarios_selected": len(selected_scenarios),
        "questions": shuffled_questions,
        "export_metadata": {
            "version": settings.api_version,
            "exported_at": datetime.utcnow().isoformat(),
        },
    }


@router.get("/assessment/{assessment_type}/questions")
async def get_assessment_questions(assessment_type: str, db: Session = Depends(get_db)):
    """Get questions with options for a baseline or endline assessment.

    Looks up assessment_definitions by type, fetches questions from export_questions
    for matching training_ids, and returns them with nested options.
    """
    if assessment_type not in ("baseline", "endline"):
        raise HTTPException(status_code=400, detail="Invalid assessment type. Must be 'baseline' or 'endline'.")

    service = QuizService(db)
    result = service.get_assessment_questions(assessment_type)

    if result is None:
        raise HTTPException(status_code=404, detail=f"No {assessment_type} assessment found.")

    return result


@router.get("/training/{training_id}/questions")
async def get_training_questions(training_id: str, db: Session = Depends(get_db)):
    """Get all questions + options for a specific training (for TrainingModule quiz)."""
    service = QuizService(db)
    result = service.get_training_questions(training_id)

    if result is None:
        raise HTTPException(status_code=404, detail="Training not found")

    return result
