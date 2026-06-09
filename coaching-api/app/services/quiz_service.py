from sqlalchemy import select
from sqlalchemy.orm import Session
from app.models import Module, Question, Scenario, Training


class QuizService:
    """Service to fetch and transform quiz data for random question selection."""

    def __init__(self, db: Session):
        self.db = db

    def get_all_modules_with_question_counts(self):
        """Get all modules with question statistics."""
        modules = self.db.execute(
            select(Module).order_by(Module.order_number)
        ).scalars().all()

        result = []
        for module in modules:
            trainings = self.db.execute(
                select(Training)
                .filter(Training.module_id == module.id)
            ).scalars().all()

            training_ids = [t.id for t in trainings]

            mcq_count = self.db.execute(
                select(Question)
                .filter(Question.training_id.in_(training_ids))
                .filter(Question.question_type == "mcq")
            ).scalars().all()

            scenario_count = self.db.execute(
                select(Scenario)
                .filter(Scenario.training_id.in_(training_ids))
            ).scalars().all()

            result.append({
                "id": module.id,
                "title": module.title,
                "description": module.description,
                "order_number": module.order_number,
                "mcq_count": len(mcq_count),
                "scenario_count": len(scenario_count),
                "total_questions": len(mcq_count) + len(scenario_count),
            })

        return result

    def get_all_questions_for_module(self, module_id: str):
        """Get all questions (MCQ and scenarios) for a module, separated by type."""
        module = self.db.execute(
            select(Module).filter(Module.id == module_id)
        ).scalar_one_or_none()

        if not module:
            return None

        # Fetch all trainings for this module
        trainings = self.db.execute(
            select(Training)
            .filter(Training.module_id == module_id)
            .order_by(Training.order_number)
        ).scalars().all()

        training_ids = [t.id for t in trainings]

        # Fetch MCQ questions
        mcq_questions = self.db.execute(
            select(Question)
            .filter(Question.training_id.in_(training_ids))
            .filter(Question.question_type == "mcq")
            .order_by(Question.order_number)
        ).scalars().all()

        # Fetch scenario questions
        scenarios = self.db.execute(
            select(Scenario)
            .filter(Scenario.training_id.in_(training_ids))
            .order_by(Scenario.created_at)
        ).scalars().all()

        return {
            "mcq": [self._question_to_dict(q) for q in mcq_questions],
            "scenarios": [self._scenario_to_dict(s) for s in scenarios],
        }

    def get_randomized_quiz(self, module_id: str):
        """Get all questions for a module (for random selection on client side)."""
        return self.get_all_questions_for_module(module_id)

    def _question_to_dict(self, question: Question) -> dict:
        """Convert Question model to dict format for API response."""
        return {
            "id": question.id,
            "question_type": "mcq",
            "question_text": question.question_text,
            "order_number": question.order_number,
            "options": [
                {
                    "id": opt.id,
                    "letter": chr(65 + i),  # A, B, C, D
                    "text": opt.option_text,
                    "is_correct": opt.is_correct,
                }
                for i, opt in enumerate(sorted(question.options, key=lambda x: x.order_number or 0))
            ],
        }

    def _scenario_to_dict(self, scenario: Scenario) -> dict:
        """Convert Scenario model to dict format for API response."""
        return {
            "id": scenario.id,
            "question_type": "scenario",
            "situation": scenario.situation,
            "question_text": scenario.question,
            "difficulty": scenario.difficulty,
            "options": [
                {
                    "id": opt.id,
                    "letter": opt.letter.upper() if opt.letter else "",
                    "text": opt.option_text,
                    "is_correct": opt.is_correct,
                    "rationale": opt.rationale,
                }
                for opt in sorted(scenario.options, key=lambda x: x.letter or "")
            ],
        }
