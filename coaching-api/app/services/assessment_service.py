"""Assessment service for managing quizzes and grading."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime
from typing import Optional, List, Dict, Any
import uuid
from app.models import Assessment, AssessmentResponse, AssessmentAttempt, User


class AssessmentService:
    """Service for assessment and quiz operations."""

    def __init__(self, db: Session):
        self.db = db

    def create_assessment(self, user_id: str, module_id: str) -> Optional[Assessment]:
        """
        Create a new assessment for a user and module.

        Args:
            user_id: User ID
            module_id: Module ID

        Returns:
            Created Assessment object or None if error
        """
        try:
            assessment = Assessment(
                id=str(uuid.uuid4()),
                user_id=user_id,
                module_id=module_id,
                status="in_progress",
                attempt_number=1,
            )
            self.db.add(assessment)
            self.db.commit()
            self.db.refresh(assessment)
            return assessment
        except IntegrityError:
            self.db.rollback()
            return None

    def get_assessment(self, assessment_id: str) -> Optional[Assessment]:
        """Get assessment by ID with all responses."""
        return self.db.execute(
            select(Assessment).filter(Assessment.id == assessment_id)
        ).scalar_one_or_none()

    def get_user_assessments(self, user_id: str, limit: int = 100, offset: int = 0) -> tuple[List[Assessment], int]:
        """
        Get all assessments for a user with pagination.

        Args:
            user_id: User ID
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (assessments list, total count)
        """
        from sqlalchemy import func

        # Get total count
        total = self.db.execute(
            select(func.count(Assessment.id)).filter(Assessment.user_id == user_id)
        ).scalar() or 0

        # Get paginated results
        assessments = self.db.execute(
            select(Assessment)
            .filter(Assessment.user_id == user_id)
            .order_by(Assessment.created_at.desc())
            .limit(limit)
            .offset(offset)
        ).scalars().all()

        return list(assessments), total

    def submit_assessment(
        self,
        assessment_id: str,
        responses: List[Dict[str, Any]]
    ) -> Optional[Assessment]:
        """
        Submit assessment with answers.

        Args:
            assessment_id: Assessment ID
            responses: List of response dicts with question_id and user_answer

        Returns:
            Updated Assessment or None if not found
        """
        assessment = self.get_assessment(assessment_id)
        if not assessment:
            return None

        try:
            # Add responses to assessment
            for response_data in responses:
                response = AssessmentResponse(
                    id=str(uuid.uuid4()),
                    assessment_id=assessment_id,
                    question_id=response_data.get("question_id"),
                    user_answer=response_data.get("user_answer"),
                )
                self.db.add(response)

            # Update assessment status
            assessment.status = "submitted"
            assessment.submitted_at = datetime.utcnow()

            self.db.commit()
            self.db.refresh(assessment)
            return assessment
        except Exception:
            self.db.rollback()
            return None

    def evaluate_responses(
        self,
        assessment_id: str,
        answer_key: Dict[str, Any]
    ) -> Optional[Assessment]:
        """
        Evaluate responses against answer key and compute score.

        Args:
            assessment_id: Assessment ID
            answer_key: Dict mapping question_id to correct_answer

        Returns:
            Assessment with scored responses or None
        """
        assessment = self.get_assessment(assessment_id)
        if not assessment:
            return None

        try:
            total_points = 0
            correct_count = 0

            for response in assessment.responses:
                question_id = response.question_id
                if question_id in answer_key:
                    correct_answer = answer_key[question_id]
                    # Simple string comparison; can be extended for complex scoring
                    is_correct = str(response.user_answer).strip() == str(correct_answer).strip()
                    response.is_correct = is_correct
                    response.points_earned = 1.0 if is_correct else 0.0
                    total_points += response.points_earned
                    if is_correct:
                        correct_count += 1

            # Calculate score as percentage
            if len(assessment.responses) > 0:
                score = (total_points / len(assessment.responses)) * 100
                assessment.score = round(score, 2)
                assessment.status = "graded"

            self.db.commit()
            self.db.refresh(assessment)
            return assessment
        except Exception:
            self.db.rollback()
            return None

    def check_pass_fail(self, score: float, passing_percentage: float = 80.0) -> bool:
        """
        Check if score passes threshold.

        Args:
            score: Numerical score (0-100)
            passing_percentage: Passing threshold (default 80%)

        Returns:
            True if passed, False otherwise
        """
        return score >= passing_percentage

    def get_assessment_results(self, assessment_id: str) -> Optional[Dict[str, Any]]:
        """
        Get detailed results for an assessment.

        Args:
            assessment_id: Assessment ID

        Returns:
            Results dict with score, pass/fail, response breakdown
        """
        assessment = self.get_assessment(assessment_id)
        if not assessment:
            return None

        passed = self.check_pass_fail(assessment.score) if assessment.score is not None else None

        return {
            "assessment_id": assessment.id,
            "user_id": assessment.user_id,
            "module_id": assessment.module_id,
            "score": assessment.score,
            "passed": passed,
            "attempt_number": assessment.attempt_number,
            "status": assessment.status,
            "submitted_at": assessment.submitted_at.isoformat() if assessment.submitted_at else None,
            "response_count": len(assessment.responses),
            "correct_responses": sum(1 for r in assessment.responses if r.is_correct),
            "responses": [r.to_dict() for r in assessment.responses],
        }

    def get_assessment_history(
        self,
        user_id: str,
        limit: int = 10
    ) -> List[Assessment]:
        """
        Get recent assessment history for a user.

        Args:
            user_id: User ID
            limit: Number of recent assessments to return

        Returns:
            List of recent assessments
        """
        assessments = self.db.execute(
            select(Assessment)
            .filter(Assessment.user_id == user_id)
            .order_by(Assessment.created_at.desc())
            .limit(limit)
        ).scalars().all()

        return list(assessments)

    def create_attempt(
        self,
        assessment_id: str,
        score: Optional[float] = None,
        passed: Optional[bool] = None
    ) -> Optional[AssessmentAttempt]:
        """
        Create an attempt record (for tracking retakes).

        Args:
            assessment_id: Assessment ID
            score: Score for this attempt
            passed: Whether this attempt passed

        Returns:
            Created AssessmentAttempt or None
        """
        assessment = self.get_assessment(assessment_id)
        if not assessment:
            return None

        try:
            attempt = AssessmentAttempt(
                id=str(uuid.uuid4()),
                assessment_id=assessment_id,
                attempt_number=assessment.attempt_number,
                score=score,
                passed=passed,
                submitted_at=datetime.utcnow() if score is not None else None,
            )
            self.db.add(attempt)
            self.db.commit()
            self.db.refresh(attempt)
            return attempt
        except Exception:
            self.db.rollback()
            return None

    def update_assessment(
        self,
        assessment_id: str,
        **kwargs
    ) -> Optional[Assessment]:
        """
        Update assessment fields.

        Args:
            assessment_id: Assessment ID
            **kwargs: Fields to update

        Returns:
            Updated Assessment or None
        """
        assessment = self.get_assessment(assessment_id)
        if not assessment:
            return None

        allowed_fields = {"score", "status", "attempt_number"}
        try:
            for key, value in kwargs.items():
                if key in allowed_fields:
                    setattr(assessment, key, value)

            self.db.commit()
            self.db.refresh(assessment)
            return assessment
        except Exception:
            self.db.rollback()
            return None

    def delete_assessment(self, assessment_id: str) -> bool:
        """
        Delete assessment and all associated data.

        Args:
            assessment_id: Assessment ID

        Returns:
            True if deleted, False if not found
        """
        assessment = self.get_assessment(assessment_id)
        if not assessment:
            return False

        try:
            self.db.delete(assessment)
            self.db.commit()
            return True
        except Exception:
            self.db.rollback()
            return False

    def get_module_assessments(
        self,
        module_id: str,
        limit: int = 100,
        offset: int = 0
    ) -> tuple[List[Assessment], int]:
        """
        Get all assessments for a specific module.

        Args:
            module_id: Module ID
            limit: Number of results
            offset: Results offset

        Returns:
            Tuple of (assessments list, total count)
        """
        from sqlalchemy import func

        total = self.db.execute(
            select(func.count(Assessment.id)).filter(Assessment.module_id == module_id)
        ).scalar() or 0

        assessments = self.db.execute(
            select(Assessment)
            .filter(Assessment.module_id == module_id)
            .order_by(Assessment.created_at.desc())
            .limit(limit)
            .offset(offset)
        ).scalars().all()

        return list(assessments), total
