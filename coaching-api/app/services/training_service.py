"""Training service for managing training modules and progress."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime
from typing import Optional, List
import uuid
from app.models import Training, TrainingProgress, Module, TrainingContent
from app.models.training_progress import ModuleQuizAttempt


class TrainingService:
    """Service for training and progress management."""

    def __init__(self, db: Session):
        self.db = db

    def get_all_modules(self) -> List[Module]:
        """Get all modules ordered by order_number."""
        return list(self.db.execute(
            select(Module).order_by(Module.order_number)
        ).scalars().all())

    def get_training(self, training_id: str) -> Optional[Training]:
        """Get training by ID."""
        return self.db.execute(
            select(Training).filter(Training.id == training_id)
        ).scalar_one_or_none()

    def get_training_content(self, training_id: str) -> List[TrainingContent]:
        """Get training content excluding audio format type."""
        return list(self.db.execute(
            select(TrainingContent)
            .filter(TrainingContent.training_id == training_id)
            .filter(TrainingContent.format_type != "audio")
        ).scalars().all())

    def get_module_trainings(self, module_id: str, limit: int = 100, offset: int = 0) -> tuple[List[Training], int]:
        from sqlalchemy import func

        total = self.db.execute(
            select(func.count(Training.id)).filter(Training.module_id == module_id)
        ).scalar() or 0

        trainings = self.db.execute(
            select(Training)
            .filter(Training.module_id == module_id)
            .order_by(Training.order_number)
            .limit(limit)
            .offset(offset)
        ).scalars().all()

        return list(trainings), total

    def get_all_trainings(self, limit: int = 100, offset: int = 0) -> tuple[List[Training], int]:
        from sqlalchemy import func

        total = self.db.execute(
            select(func.count(Training.id))
        ).scalar() or 0

        trainings = self.db.execute(
            select(Training)
            .order_by(Training.order_number)
            .limit(limit)
            .offset(offset)
        ).scalars().all()

        return list(trainings), total

    def get_user_progress(self, user_id: str, training_id: str) -> Optional[TrainingProgress]:
        return self.db.execute(
            select(TrainingProgress).filter(
                TrainingProgress.user_id == user_id,
                TrainingProgress.training_id == training_id
            )
        ).scalar_one_or_none()

    def create_progress(self, user_id: str, training_id: str) -> Optional[TrainingProgress]:
        existing = self.get_user_progress(user_id, training_id)
        if existing:
            return existing

        try:
            progress = TrainingProgress(
                id=str(uuid.uuid4()),
                user_id=user_id,
                training_id=training_id,
                progress_percentage=0.0,
                is_completed=False,
            )
            self.db.add(progress)
            self.db.commit()
            self.db.refresh(progress)
            return progress
        except IntegrityError:
            self.db.rollback()
            return None

    def update_progress(self, user_id: str, training_id: str, progress_percentage: float) -> Optional[TrainingProgress]:
        progress = self.get_user_progress(user_id, training_id)

        if not progress:
            progress = self.create_progress(user_id, training_id)
            if not progress:
                return None

        try:
            progress.progress_percentage = min(100.0, max(0.0, progress_percentage))
            self.db.commit()
            self.db.refresh(progress)
            return progress
        except Exception:
            self.db.rollback()
            return None

    def mark_complete(self, user_id: str, training_id: str) -> Optional[TrainingProgress]:
        progress = self.get_user_progress(user_id, training_id)

        if not progress:
            progress = self.create_progress(user_id, training_id)
            if not progress:
                return None

        try:
            progress.progress_percentage = 100.0
            progress.is_completed = True
            progress.passed = True
            progress.content_completed = True
            progress.completed_at = datetime.utcnow()
            self.db.commit()
            self.db.refresh(progress)
            return progress
        except Exception:
            self.db.rollback()
            return None

    def get_user_all_progress(self, user_id: str, limit: int = 100, offset: int = 0) -> tuple[List[TrainingProgress], int]:
        from sqlalchemy import func

        total = self.db.execute(
            select(func.count(TrainingProgress.id)).filter(TrainingProgress.user_id == user_id)
        ).scalar() or 0

        progress_list = self.db.execute(
            select(TrainingProgress)
            .filter(TrainingProgress.user_id == user_id)
            .order_by(TrainingProgress.updated_at.desc())
            .limit(limit)
            .offset(offset)
        ).scalars().all()

        return list(progress_list), total

    def get_module_progress(self, user_id: str, module_id: str) -> dict:
        trainings, _ = self.get_module_trainings(module_id, limit=1000)

        if not trainings:
            return {
                "module_id": module_id,
                "total_trainings": 0,
                "completed_trainings": 0,
                "overall_progress": 0.0,
            }

        total = len(trainings)
        completed = 0
        total_progress = 0.0

        for training in trainings:
            progress = self.get_user_progress(user_id, training.id)
            if progress:
                total_progress += progress.progress_percentage
                if progress.is_completed:
                    completed += 1

        overall_progress = (total_progress / (total * 100.0) * 100.0) if total > 0 else 0.0

        return {
            "module_id": module_id,
            "total_trainings": total,
            "completed_trainings": completed,
            "overall_progress": round(overall_progress, 2),
        }

    def delete_progress(self, user_id: str, training_id: str) -> bool:
        progress = self.get_user_progress(user_id, training_id)
        if not progress:
            return False

        try:
            self.db.delete(progress)
            self.db.commit()
            return True
        except Exception:
            self.db.rollback()
            return False

    def reset_progress(self, user_id: str, training_id: str) -> Optional[TrainingProgress]:
        progress = self.get_user_progress(user_id, training_id)
        if not progress:
            return None

        try:
            progress.progress_percentage = 0.0
            progress.is_completed = False
            progress.completed_at = None
            self.db.commit()
            self.db.refresh(progress)
            return progress
        except Exception:
            self.db.rollback()
            return None

    # --- Module Quiz Attempt methods ---

    def get_module_quiz_attempt(self, user_id: str, module_id: str) -> Optional[ModuleQuizAttempt]:
        """Get existing quiz attempt record for user + module."""
        return self.db.execute(
            select(ModuleQuizAttempt).filter(
                ModuleQuizAttempt.user_id == user_id,
                ModuleQuizAttempt.module_id == module_id,
            )
        ).scalar_one_or_none()

    def upsert_module_quiz_attempt(
        self,
        user_id: str,
        module_id: str,
        score: float,
        passed: bool,
    ) -> Optional[ModuleQuizAttempt]:
        """Create or update a module quiz attempt record."""
        existing = self.get_module_quiz_attempt(user_id, module_id)

        try:
            if existing:
                existing.score = score
                existing.best_score = max(score, existing.best_score or 0)
                existing.passed = passed or existing.passed
                existing.attempt_count = (existing.attempt_count or 0) + 1
                if passed and not existing.completed_at:
                    existing.completed_at = datetime.utcnow()
                self.db.commit()
                self.db.refresh(existing)
                return existing
            else:
                attempt = ModuleQuizAttempt(
                    id=str(uuid.uuid4()),
                    user_id=user_id,
                    module_id=module_id,
                    score=score,
                    best_score=score,
                    passed=passed,
                    attempt_count=1,
                    completed_at=datetime.utcnow() if passed else None,
                )
                self.db.add(attempt)
                self.db.commit()
                self.db.refresh(attempt)
                return attempt
        except Exception:
            self.db.rollback()
            return None
