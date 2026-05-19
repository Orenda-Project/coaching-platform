from sqlalchemy import select
from sqlalchemy.orm import Session
from app.models import Module, Training


class ModuleService:
    """Service to fetch and transform training module data."""

    def __init__(self, db: Session):
        self.db = db

    def fetch_all_modules(self):
        """Fetch all modules with trainings, content, and questions."""
        modules = self.db.execute(
            select(Module).order_by(Module.order_number)
        ).scalars().all()

        # Populate trainings for each module
        for module in modules:
            module.trainings = self.db.execute(
                select(Training)
                .filter(Training.module_id == module.id)
                .order_by(Training.order_number)
            ).scalars().all()

        return modules

    def fetch_module_by_id(self, module_id: str):
        """Fetch single module with all children."""
        module = self.db.execute(
            select(Module).filter(Module.id == module_id)
        ).scalar_one_or_none()

        if not module:
            return None

        module.trainings = self.db.execute(
            select(Training)
            .filter(Training.module_id == module.id)
            .order_by(Training.order_number)
        ).scalars().all()

        return module

    def fetch_training_by_id(self, training_id: str):
        """Fetch single training with all content and questions."""
        training = self.db.execute(
            select(Training).filter(Training.id == training_id)
        ).scalar_one_or_none()

        return training

    def count_modules(self) -> int:
        """Count total modules."""
        return self.db.execute(select(Module)).scalars().all().__len__()

    def count_trainings(self) -> int:
        """Count total trainings."""
        return self.db.execute(select(Training)).scalars().all().__len__()
