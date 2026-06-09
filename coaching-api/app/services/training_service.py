"""Training service for managing training modules and progress."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime
from typing import Optional, List
import uuid
from app.models import Training, TrainingProgress, Module


class TrainingService:
    """Service for training and progress management."""

    def __init__(self, db: Session):
        self.db = db

    def get_training(self, training_id: str) -> Optional[Training]:
        """Get training by ID."""
        return self.db.execute(
            select(Training).filter(Training.id == training_id)
        ).scalar_one_or_none()

    def get_module_trainings(self, module_id: str, limit: int = 100, offset: int = 0) -> tuple[List[Training], int]:
        """
        Get all trainings for a module.

        Args:
            module_id: Module ID
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (trainings list, total count)
        """
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
        """
        Get all trainings.

        Args:
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (trainings list, total count)
        """
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

    def get_user_progress(
        self,
        user_id: str,
        training_id: str
    ) -> Optional[TrainingProgress]:
        """
        Get user's progress for a specific training.

        Args:
            user_id: User ID
            training_id: Training ID

        Returns:
            TrainingProgress object or None
        """
        return self.db.execute(
            select(TrainingProgress).filter(
                TrainingProgress.user_id == user_id,
                TrainingProgress.training_id == training_id
            )
        ).scalar_one_or_none()

    def create_progress(
        self,
        user_id: str,
        training_id: str
    ) -> Optional[TrainingProgress]:
        """
        Create initial progress record for a user and training.

        Args:
            user_id: User ID
            training_id: Training ID

        Returns:
            Created TrainingProgress or None
        """
        # Check if progress already exists
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

    def update_progress(
        self,
        user_id: str,
        training_id: str,
        progress_percentage: float
    ) -> Optional[TrainingProgress]:
        """
        Update user's progress percentage for a training.

        Args:
            user_id: User ID
            training_id: Training ID
            progress_percentage: Progress as percentage (0-100)

        Returns:
            Updated TrainingProgress or None
        """
        progress = self.get_user_progress(user_id, training_id)

        if not progress:
            # Create if doesn't exist
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

    def mark_complete(
        self,
        user_id: str,
        training_id: str
    ) -> Optional[TrainingProgress]:
        """
        Mark training as completed for a user.

        Args:
            user_id: User ID
            training_id: Training ID

        Returns:
            Updated TrainingProgress or None
        """
        progress = self.get_user_progress(user_id, training_id)

        if not progress:
            # Create if doesn't exist
            progress = self.create_progress(user_id, training_id)
            if not progress:
                return None

        try:
            progress.progress_percentage = 100.0
            progress.is_completed = True
            progress.completed_at = datetime.utcnow()
            self.db.commit()
            self.db.refresh(progress)
            return progress
        except Exception:
            self.db.rollback()
            return None

    def get_user_all_progress(
        self,
        user_id: str,
        limit: int = 100,
        offset: int = 0
    ) -> tuple[List[TrainingProgress], int]:
        """
        Get all training progress for a user.

        Args:
            user_id: User ID
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (progress list, total count)
        """
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

    def get_module_progress(
        self,
        user_id: str,
        module_id: str
    ) -> dict:
        """
        Get user's aggregated progress for all trainings in a module.

        Args:
            user_id: User ID
            module_id: Module ID

        Returns:
            Dict with progress statistics
        """
        # Get all trainings in module
        trainings, _ = self.get_module_trainings(module_id, limit=1000)

        if not trainings:
            return {
                "module_id": module_id,
                "total_trainings": 0,
                "completed_trainings": 0,
                "overall_progress": 0.0,
            }

        # Get progress for each training
        total = len(trainings)
        completed = 0
        total_progress = 0.0

        for training in trainings:
            progress = self.get_user_progress(user_id, training.id)
            if progress:
                total_progress += progress.progress_percentage
                if progress.is_completed:
                    completed += 1
            else:
                total_progress += 0.0

        overall_progress = (total_progress / (total * 100.0) * 100.0) if total > 0 else 0.0

        return {
            "module_id": module_id,
            "total_trainings": total,
            "completed_trainings": completed,
            "overall_progress": round(overall_progress, 2),
        }

    def delete_progress(self, user_id: str, training_id: str) -> bool:
        """
        Delete progress record.

        Args:
            user_id: User ID
            training_id: Training ID

        Returns:
            True if deleted, False if not found
        """
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
        """
        Reset progress for a training (set to 0%).

        Args:
            user_id: User ID
            training_id: Training ID

        Returns:
            Reset TrainingProgress or None
        """
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
