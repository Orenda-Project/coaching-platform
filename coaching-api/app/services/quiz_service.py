import random

from sqlalchemy import select
from sqlalchemy.orm import Session
from app.models import Module, Question, ExportScenario, Training, AssessmentContent


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

            # Find assessments for these trainings (module_quiz type)
            assessment_ids = self._get_assessment_ids_for_trainings(training_ids, "module_quiz")

            mcq_count = self.db.execute(
                select(Question)
                .filter(Question.assessment_id.in_(assessment_ids))
                .filter(Question.question_type == "mcq")
            ).scalars().all() if assessment_ids else []

            scenario_count = self.db.execute(
                select(ExportScenario)
                .filter(ExportScenario.training_id.in_(training_ids))
            ).scalars().all() if training_ids else []

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

        # Find assessments for these trainings (module_quiz type)
        assessment_ids = self._get_assessment_ids_for_trainings(training_ids, "module_quiz")

        # Fetch MCQ questions via assessments
        mcq_questions = self.db.execute(
            select(Question)
            .filter(Question.assessment_id.in_(assessment_ids))
            .filter(Question.question_type == "mcq")
            .order_by(Question.order_number)
        ).scalars().all() if assessment_ids else []

        # Fetch scenario questions (still from export_scenarios)
        scenarios = self.db.execute(
            select(ExportScenario)
            .filter(ExportScenario.training_id.in_(training_ids))
            .order_by(ExportScenario.created_at)
        ).scalars().all() if training_ids else []

        return {
            "mcq": [self._question_to_dict(q) for q in mcq_questions],
            "scenarios": [self._scenario_to_dict(s) for s in scenarios],
        }

    def get_randomized_quiz(self, module_id: str):
        """Get all questions for a module (for random selection on client side)."""
        return self.get_all_questions_for_module(module_id)

    def get_assessment_questions(self, assessment_type: str):
        """Get questions for a baseline or endline assessment.

        Looks up assessments table by type, then fetches all questions
        for matching assessment_ids from questions table with their options.
        """
        # Look up assessments by type (baseline/endline)
        assessments = self.db.execute(
            select(AssessmentContent)
            .filter(AssessmentContent.type == assessment_type)
        ).scalars().all()

        if not assessments:
            return None

        assessment_ids = [a.id for a in assessments]

        # Get all questions for matching assessment_ids
        questions = self.db.execute(
            select(Question)
            .filter(Question.assessment_id.in_(assessment_ids))
            .order_by(Question.order_number)
        ).scalars().all()

        if not questions:
            return None

        return {
            "assessment_id": assessments[0].id,
            "questions": [self._assessment_question_to_dict(q) for q in questions],
        }

    def get_training_questions(self, training_id: str):
        """Get all questions + options for a specific training."""
        training = self.db.execute(
            select(Training).filter(Training.id == training_id)
        ).scalar_one_or_none()

        if not training:
            return None

        # Find assessments for this training
        assessment_ids = self._get_assessment_ids_for_trainings([training_id], "module_quiz")

        questions = self.db.execute(
            select(Question)
            .filter(Question.assessment_id.in_(assessment_ids))
            .order_by(Question.order_number)
        ).scalars().all() if assessment_ids else []

        scenarios = self.db.execute(
            select(ExportScenario)
            .filter(ExportScenario.training_id == training_id)
            .order_by(ExportScenario.created_at)
        ).scalars().all()

        return {
            "training_id": training_id,
            "mcq": [self._question_to_dict(q) for q in questions],
            "scenarios": [self._scenario_to_dict(s) for s in scenarios],
        }

    def _get_assessment_ids_for_trainings(self, training_ids: list, assessment_type: str) -> list:
        """Helper: get assessment IDs for given training IDs and type."""
        if not training_ids:
            return []

        assessments = self.db.execute(
            select(AssessmentContent)
            .filter(AssessmentContent.training_id.in_(training_ids))
            .filter(AssessmentContent.type == assessment_type)
        ).scalars().all()

        return [a.id for a in assessments]

    def _assessment_question_to_dict(self, question: Question) -> dict:
        """Convert Question model to assessment-compatible dict format.

        Returns a shape matching what the frontend Assessment.tsx expects:
        {id, question_text, question_type, order_number, options: [{id, option_text, is_correct, question_id}]}
        """
        return {
            "id": question.id,
            "question_text": question.question_text,
            "question_type": question.question_type,
            "order_number": question.order_number,
            "assessment_id": question.assessment_id,
            "options": [
                {
                    "id": opt.id,
                    "option_text": opt.option_text,
                    "is_correct": opt.is_correct,
                    "question_id": question.id,
                    "order_number": opt.order_number,
                }
                for opt in self._shuffled(question.options)
            ],
        }

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
                for i, opt in enumerate(self._shuffled(question.options))
            ],
        }

    def _scenario_to_dict(self, scenario: ExportScenario) -> dict:
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
                for opt in self._shuffled(scenario.options)
            ],
        }

    @staticmethod
    def _shuffled(items) -> list:
        """Return a shuffled copy of items (does not mutate the original)."""
        copied = list(items)
        random.shuffle(copied)
        return copied
