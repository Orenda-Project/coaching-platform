"""Admin content CRUD service — modules, trainings, content, assessments, questions."""

from sqlalchemy import select, delete
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Optional, List, Dict, Any, Tuple
import uuid

from app.models.training import (
    Module, Training, TrainingContent, AssessmentContent, Question, Option,
)


class AdminContentService:
    """Service for admin content management (CRUD)."""

    def __init__(self, db: Session):
        self.db = db

    # ===== MODULES =====

    def list_modules(self) -> List[Dict]:
        modules = self.db.execute(
            select(Module).order_by(Module.order_number)
        ).scalars().all()
        return [m.to_dict() for m in modules]

    def create_module(self, data: Dict[str, Any]) -> Dict:
        module = Module(
            id=data.get("id") or str(uuid.uuid4()),
            title=data["title"],
            description=data.get("description"),
            is_mandatory=data.get("is_mandatory", False),
            order_number=data.get("order_number"),
            competencies=data.get("competencies"),
            desired_outcomes=data.get("desired_outcomes"),
            persona_required=data.get("persona_required", []),
        )
        self.db.add(module)
        self.db.commit()
        self.db.refresh(module)
        return module.to_dict()

    def update_module(self, module_id: str, data: Dict[str, Any]) -> Optional[Dict]:
        module = self.db.get(Module, module_id)
        if not module:
            return None
        for key in ("title", "description", "is_mandatory", "order_number", "competencies", "desired_outcomes", "persona_required"):
            if key in data:
                setattr(module, key, data[key])
        self.db.commit()
        self.db.refresh(module)
        return module.to_dict()

    def delete_module(self, module_id: str) -> bool:
        module = self.db.get(Module, module_id)
        if not module:
            return False
        self.db.delete(module)
        self.db.commit()
        return True

    # ===== TRAININGS =====

    def list_trainings(self, module_id: Optional[str] = None) -> List[Dict]:
        query = select(Training).order_by(Training.order_number)
        if module_id:
            query = query.filter(Training.module_id == module_id)
        trainings = self.db.execute(query).scalars().all()
        result = []
        for t in trainings:
            d = {
                "id": t.id,
                "module_id": t.module_id,
                "title": t.title,
                "description": t.description,
                "order_number": t.order_number,
                "is_common": t.is_common,
                "persona_required": t.persona_required,
                "main_concepts": t.main_concepts,
                "max_attempts": t.max_attempts,
                "quiz_unlock_requires_content": t.quiz_unlock_requires_content,
            }
            result.append(d)
        return result

    def create_training(self, data: Dict[str, Any]) -> Dict:
        training = Training(
            id=data.get("id") or str(uuid.uuid4()),
            module_id=data["module_id"],
            title=data["title"],
            description=data.get("description"),
            order_number=data.get("order_number"),
            is_common=data.get("is_common", False),
            persona_required=data.get("persona_required"),
            main_concepts=data.get("main_concepts"),
            max_attempts=data.get("max_attempts", 3),
            quiz_unlock_requires_content=data.get("quiz_unlock_requires_content", True),
        )
        self.db.add(training)
        self.db.commit()
        self.db.refresh(training)
        return {
            "id": training.id,
            "module_id": training.module_id,
            "title": training.title,
            "description": training.description,
            "order_number": training.order_number,
            "is_common": training.is_common,
            "persona_required": training.persona_required,
            "main_concepts": training.main_concepts,
            "max_attempts": training.max_attempts,
            "quiz_unlock_requires_content": training.quiz_unlock_requires_content,
        }

    def update_training(self, training_id: str, data: Dict[str, Any]) -> Optional[Dict]:
        training = self.db.get(Training, training_id)
        if not training:
            return None
        for key in ("title", "description", "order_number", "is_common",
                     "persona_required", "main_concepts", "max_attempts",
                     "quiz_unlock_requires_content", "module_id"):
            if key in data:
                setattr(training, key, data[key])
        self.db.commit()
        self.db.refresh(training)
        return {
            "id": training.id,
            "module_id": training.module_id,
            "title": training.title,
            "description": training.description,
            "order_number": training.order_number,
            "is_common": training.is_common,
            "persona_required": training.persona_required,
            "main_concepts": training.main_concepts,
            "max_attempts": training.max_attempts,
            "quiz_unlock_requires_content": training.quiz_unlock_requires_content,
        }

    def delete_training(self, training_id: str) -> bool:
        training = self.db.get(Training, training_id)
        if not training:
            return False
        self.db.delete(training)
        self.db.commit()
        return True

    # ===== TRAINING CONTENT =====

    def list_training_content(self, training_id: str) -> List[Dict]:
        rows = self.db.execute(
            select(TrainingContent).filter(TrainingContent.training_id == training_id)
        ).scalars().all()
        return [{
            "id": c.id,
            "training_id": c.training_id,
            "format_type": c.format_type,
            "content_url": c.content_url,
            "duration_minutes": c.duration_minutes,
            "extra_data": c.extra_data,
        } for c in rows]

    def create_training_content(self, data: Dict[str, Any]) -> Dict:
        content = TrainingContent(
            id=data.get("id") or str(uuid.uuid4()),
            training_id=data["training_id"],
            format_type=data.get("format_type"),
            content_url=data.get("content_url"),
            duration_minutes=data.get("duration_minutes"),
            extra_data=data.get("extra_data"),
        )
        self.db.add(content)
        self.db.commit()
        self.db.refresh(content)
        return {
            "id": content.id,
            "training_id": content.training_id,
            "format_type": content.format_type,
            "content_url": content.content_url,
            "duration_minutes": content.duration_minutes,
            "extra_data": content.extra_data,
        }

    def delete_training_content(self, content_id: str) -> bool:
        content = self.db.get(TrainingContent, content_id)
        if not content:
            return False
        self.db.delete(content)
        self.db.commit()
        return True

    # ===== ASSESSMENTS =====

    def list_assessments(self, training_id: Optional[str] = None, assessment_type: Optional[str] = None) -> List[Dict]:
        query = select(AssessmentContent)
        if training_id:
            query = query.filter(AssessmentContent.training_id == training_id)
        if assessment_type:
            query = query.filter(AssessmentContent.type == assessment_type)
        rows = self.db.execute(query).scalars().all()
        return [a.to_dict() for a in rows]

    def create_assessment(self, data: Dict[str, Any]) -> Dict:
        assessment = AssessmentContent(
            id=data.get("id") or str(uuid.uuid4()),
            type=data["type"],
            training_id=data.get("training_id"),
            title=data.get("title"),
            description=data.get("description"),
            passing_score=data.get("passing_score", 80),
            max_attempts=data.get("max_attempts", 3),
        )
        self.db.add(assessment)
        self.db.commit()
        self.db.refresh(assessment)
        return assessment.to_dict()

    def update_assessment(self, assessment_id: str, data: Dict[str, Any]) -> Optional[Dict]:
        assessment = self.db.get(AssessmentContent, assessment_id)
        if not assessment:
            return None
        for key in ("type", "training_id", "title", "description", "passing_score", "max_attempts"):
            if key in data:
                setattr(assessment, key, data[key])
        self.db.commit()
        self.db.refresh(assessment)
        return assessment.to_dict()

    # ===== QUESTIONS + OPTIONS (bulk upsert) =====

    def get_questions_by_assessment(self, assessment_id: str) -> List[Dict]:
        questions = self.db.execute(
            select(Question)
            .filter(Question.assessment_id == assessment_id)
            .order_by(Question.order_number)
        ).scalars().all()
        return [q.to_dict() for q in questions]

    def bulk_upsert_questions(self, assessment_id: str, questions_data: List[Dict]) -> List[Dict]:
        """
        Bulk upsert questions and their options for an assessment.
        Deletes questions not in the incoming list, upserts the rest.
        """
        # Verify assessment exists
        assessment = self.db.get(AssessmentContent, assessment_id)
        if not assessment:
            raise ValueError(f"Assessment {assessment_id} not found")

        incoming_ids = {q.get("id") for q in questions_data if q.get("id")}

        # Delete questions not in incoming list
        existing = self.db.execute(
            select(Question).filter(Question.assessment_id == assessment_id)
        ).scalars().all()
        for eq in existing:
            if eq.id not in incoming_ids:
                self.db.delete(eq)

        # Upsert each question
        result = []
        for qdata in questions_data:
            q_id = qdata.get("id") or str(uuid.uuid4())
            question = self.db.get(Question, q_id)
            if question:
                question.question_text = qdata["question_text"]
                question.question_type = qdata.get("question_type", "mcq")
                question.order_number = qdata.get("order_number")
                question.max_score = qdata.get("max_score", 1)
                question.correct_answer = qdata.get("correct_answer")
            else:
                question = Question(
                    id=q_id,
                    assessment_id=assessment_id,
                    question_text=qdata["question_text"],
                    question_type=qdata.get("question_type", "mcq"),
                    order_number=qdata.get("order_number"),
                    max_score=qdata.get("max_score", 1),
                    correct_answer=qdata.get("correct_answer"),
                )
                self.db.add(question)

            # Handle options
            option_ids = {o.get("id") for o in qdata.get("options", []) if o.get("id")}
            existing_opts = self.db.execute(
                select(Option).filter(Option.question_id == q_id)
            ).scalars().all()
            for eo in existing_opts:
                if eo.id not in option_ids:
                    self.db.delete(eo)

            for odata in qdata.get("options", []):
                o_id = odata.get("id") or str(uuid.uuid4())
                option = self.db.get(Option, o_id)
                if option:
                    option.option_text = odata["text"]
                    option.is_correct = odata.get("is_correct", False)
                    option.order_number = odata.get("order")
                else:
                    option = Option(
                        id=o_id,
                        question_id=q_id,
                        option_text=odata["text"],
                        is_correct=odata.get("is_correct", False),
                        order_number=odata.get("order"),
                    )
                    self.db.add(option)

            self.db.flush()
            result.append(q_id)

        self.db.commit()

        # Return fresh data
        return self.get_questions_by_assessment(assessment_id)

    def delete_question(self, question_id: str) -> bool:
        question = self.db.get(Question, question_id)
        if not question:
            return False
        self.db.delete(question)
        self.db.commit()
        return True
