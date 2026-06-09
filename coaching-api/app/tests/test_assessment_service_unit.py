"""Unit tests for AssessmentService."""

import pytest
from datetime import datetime
from sqlalchemy.orm import Session
from app.models import Assessment, AssessmentResponse, AssessmentAttempt, User
from app.services.assessment_service import AssessmentService


@pytest.fixture
def service(test_db: Session) -> AssessmentService:
    """Create AssessmentService instance."""
    # Create test user
    user = User(id="test-user-1", email="test@example.com")
    test_db.add(user)
    test_db.commit()

    return AssessmentService(test_db)


class TestAssessmentServiceCreation:
    """Tests for assessment creation."""

    def test_create_assessment_success(self, service, test_db):
        """Test creating a new assessment."""
        result = service.create_assessment("test-user-1", "module-123")

        assert result is not None
        assert result.user_id == "test-user-1"
        assert result.module_id == "module-123"
        assert result.status == "in_progress"
        assert result.attempt_number == 1
        assert result.score is None
        assert result.submitted_at is None

    def test_create_assessment_generates_id(self, service, test_db):
        """Test that created assessment has unique ID."""
        result1 = service.create_assessment("test-user-1", "module-123")
        result2 = service.create_assessment("test-user-1", "module-456")

        assert result1.id != result2.id
        assert len(result1.id) == 36  # UUID string format

    def test_create_assessment_with_invalid_user(self, service, test_db):
        """Test creating assessment with non-existent user."""
        # This should still create the assessment (no FK constraint in service)
        result = service.create_assessment("non-existent-user", "module-123")
        assert result is not None


class TestAssessmentServiceRetrieval:
    """Tests for retrieving assessments."""

    def test_get_assessment_by_id(self, service, test_db):
        """Test retrieving assessment by ID."""
        created = service.create_assessment("test-user-1", "module-123")
        retrieved = service.get_assessment(created.id)

        assert retrieved is not None
        assert retrieved.id == created.id
        assert retrieved.user_id == "test-user-1"

    def test_get_nonexistent_assessment(self, service, test_db):
        """Test retrieving non-existent assessment returns None."""
        result = service.get_assessment("non-existent-id")
        assert result is None

    def test_get_user_assessments(self, service, test_db):
        """Test retrieving all assessments for a user."""
        a1 = service.create_assessment("test-user-1", "module-1")
        a2 = service.create_assessment("test-user-1", "module-2")
        a3 = service.create_assessment("test-user-1", "module-3")

        assessments, total = service.get_user_assessments("test-user-1")

        assert len(assessments) == 3
        assert total == 3
        assert all(a.user_id == "test-user-1" for a in assessments)

    def test_get_user_assessments_pagination(self, service, test_db):
        """Test pagination of user assessments."""
        for i in range(5):
            service.create_assessment("test-user-1", f"module-{i}")

        # Get first page
        assessments, total = service.get_user_assessments("test-user-1", limit=2, offset=0)
        assert len(assessments) == 2
        assert total == 5

        # Get second page
        assessments, total = service.get_user_assessments("test-user-1", limit=2, offset=2)
        assert len(assessments) == 2

        # Get third page (partial)
        assessments, total = service.get_user_assessments("test-user-1", limit=2, offset=4)
        assert len(assessments) == 1

    def test_get_user_assessments_empty(self, service, test_db):
        """Test retrieving assessments for user with none."""
        assessments, total = service.get_user_assessments("non-existent-user")
        assert len(assessments) == 0
        assert total == 0


class TestAssessmentServiceSubmission:
    """Tests for submitting assessments."""

    def test_submit_assessment(self, service, test_db):
        """Test submitting assessment with responses."""
        assessment = service.create_assessment("test-user-1", "module-123")

        responses = [
            {"question_id": "q1", "user_answer": "A"},
            {"question_id": "q2", "user_answer": "B"},
        ]

        result = service.submit_assessment(assessment.id, responses)

        assert result is not None
        assert result.status == "submitted"
        assert result.submitted_at is not None
        assert len(result.responses) == 2

    def test_submit_assessment_nonexistent(self, service, test_db):
        """Test submitting non-existent assessment."""
        responses = [{"question_id": "q1", "user_answer": "A"}]
        result = service.submit_assessment("non-existent", responses)
        assert result is None

    def test_submit_assessment_empty_responses(self, service, test_db):
        """Test submitting assessment with empty responses."""
        assessment = service.create_assessment("test-user-1", "module-123")
        result = service.submit_assessment(assessment.id, [])

        assert result is not None
        assert result.status == "submitted"
        assert len(result.responses) == 0


class TestAssessmentServiceGrading:
    """Tests for evaluating and grading assessments."""

    def test_evaluate_responses_all_correct(self, service, test_db):
        """Test evaluating assessment with all correct answers."""
        assessment = service.create_assessment("test-user-1", "module-123")
        responses = [
            {"question_id": "q1", "user_answer": "A"},
            {"question_id": "q2", "user_answer": "B"},
        ]
        service.submit_assessment(assessment.id, responses)

        answer_key = {"q1": "A", "q2": "B"}
        result = service.evaluate_responses(assessment.id, answer_key)

        assert result is not None
        assert result.score == 100.0
        assert result.status == "graded"
        assert all(r.is_correct for r in result.responses)

    def test_evaluate_responses_partial_correct(self, service, test_db):
        """Test evaluating assessment with partial correct answers."""
        assessment = service.create_assessment("test-user-1", "module-123")
        responses = [
            {"question_id": "q1", "user_answer": "A"},
            {"question_id": "q2", "user_answer": "X"},
        ]
        service.submit_assessment(assessment.id, responses)

        answer_key = {"q1": "A", "q2": "B"}
        result = service.evaluate_responses(assessment.id, answer_key)

        assert result.score == 50.0
        assert result.responses[0].is_correct is True
        assert result.responses[1].is_correct is False

    def test_evaluate_responses_all_wrong(self, service, test_db):
        """Test evaluating assessment with all wrong answers."""
        assessment = service.create_assessment("test-user-1", "module-123")
        responses = [
            {"question_id": "q1", "user_answer": "X"},
            {"question_id": "q2", "user_answer": "Y"},
        ]
        service.submit_assessment(assessment.id, responses)

        answer_key = {"q1": "A", "q2": "B"}
        result = service.evaluate_responses(assessment.id, answer_key)

        assert result.score == 0.0
        assert all(not r.is_correct for r in result.responses)

    def test_check_pass_fail_passing_score(self, service, test_db):
        """Test pass/fail check with passing score."""
        assert service.check_pass_fail(80.0) is True
        assert service.check_pass_fail(90.0) is True
        assert service.check_pass_fail(100.0) is True

    def test_check_pass_fail_failing_score(self, service, test_db):
        """Test pass/fail check with failing score."""
        assert service.check_pass_fail(79.9) is False
        assert service.check_pass_fail(50.0) is False
        assert service.check_pass_fail(0.0) is False

    def test_check_pass_fail_custom_threshold(self, service, test_db):
        """Test pass/fail check with custom threshold."""
        assert service.check_pass_fail(60.0, 60.0) is True
        assert service.check_pass_fail(59.9, 60.0) is False

    def test_get_assessment_results(self, service, test_db):
        """Test getting detailed assessment results."""
        assessment = service.create_assessment("test-user-1", "module-123")
        responses = [
            {"question_id": "q1", "user_answer": "A"},
            {"question_id": "q2", "user_answer": "B"},
        ]
        service.submit_assessment(assessment.id, responses)
        service.evaluate_responses(assessment.id, {"q1": "A", "q2": "B"})

        results = service.get_assessment_results(assessment.id)

        assert results is not None
        assert results["assessment_id"] == assessment.id
        assert results["score"] == 100.0
        assert results["passed"] is True
        assert results["correct_responses"] == 2
        assert results["response_count"] == 2

    def test_get_assessment_results_nonexistent(self, service, test_db):
        """Test getting results for non-existent assessment."""
        result = service.get_assessment_results("non-existent")
        assert result is None


class TestAssessmentServiceHistory:
    """Tests for assessment history."""

    def test_get_assessment_history(self, service, test_db):
        """Test retrieving assessment history."""
        for i in range(5):
            service.create_assessment("test-user-1", f"module-{i}")

        history = service.get_assessment_history("test-user-1", limit=10)

        assert len(history) == 5
        assert all(a.user_id == "test-user-1" for a in history)

    def test_get_assessment_history_with_limit(self, service, test_db):
        """Test assessment history with limit."""
        for i in range(10):
            service.create_assessment("test-user-1", f"module-{i}")

        history = service.get_assessment_history("test-user-1", limit=3)

        assert len(history) == 3

    def test_get_assessment_history_empty(self, service, test_db):
        """Test history for user with no assessments."""
        history = service.get_assessment_history("non-existent")
        assert len(history) == 0


class TestAssessmentServiceAttempts:
    """Tests for attempt tracking."""

    def test_create_attempt(self, service, test_db):
        """Test creating attempt record."""
        assessment = service.create_assessment("test-user-1", "module-123")

        attempt = service.create_attempt(assessment.id, score=85.0, passed=True)

        assert attempt is not None
        assert attempt.assessment_id == assessment.id
        assert attempt.score == 85.0
        assert attempt.passed is True

    def test_create_attempt_nonexistent_assessment(self, service, test_db):
        """Test creating attempt for non-existent assessment."""
        result = service.create_attempt("non-existent", score=85.0, passed=True)
        assert result is None


class TestAssessmentServiceUpdates:
    """Tests for updating assessments."""

    def test_update_assessment_score(self, service, test_db):
        """Test updating assessment score."""
        assessment = service.create_assessment("test-user-1", "module-123")

        updated = service.update_assessment(assessment.id, score=85.5)

        assert updated is not None
        assert updated.score == 85.5

    def test_update_assessment_status(self, service, test_db):
        """Test updating assessment status."""
        assessment = service.create_assessment("test-user-1", "module-123")

        updated = service.update_assessment(assessment.id, status="graded")

        assert updated is not None
        assert updated.status == "graded"

    def test_update_assessment_multiple_fields(self, service, test_db):
        """Test updating multiple assessment fields."""
        assessment = service.create_assessment("test-user-1", "module-123")

        updated = service.update_assessment(
            assessment.id,
            score=90.0,
            status="graded",
            attempt_number=2
        )

        assert updated.score == 90.0
        assert updated.status == "graded"
        assert updated.attempt_number == 2

    def test_update_nonexistent_assessment(self, service, test_db):
        """Test updating non-existent assessment."""
        result = service.update_assessment("non-existent", score=85.0)
        assert result is None


class TestAssessmentServiceDeletion:
    """Tests for deleting assessments."""

    def test_delete_assessment(self, service, test_db):
        """Test deleting assessment."""
        assessment = service.create_assessment("test-user-1", "module-123")
        success = service.delete_assessment(assessment.id)

        assert success is True

        # Verify deleted
        retrieved = service.get_assessment(assessment.id)
        assert retrieved is None

    def test_delete_nonexistent_assessment(self, service, test_db):
        """Test deleting non-existent assessment."""
        success = service.delete_assessment("non-existent")
        assert success is False

    def test_delete_assessment_with_responses(self, service, test_db):
        """Test deleting assessment cascades to responses."""
        assessment = service.create_assessment("test-user-1", "module-123")
        responses = [
            {"question_id": "q1", "user_answer": "A"},
            {"question_id": "q2", "user_answer": "B"},
        ]
        service.submit_assessment(assessment.id, responses)

        success = service.delete_assessment(assessment.id)
        assert success is True

        # Verify assessment and responses deleted
        retrieved = service.get_assessment(assessment.id)
        assert retrieved is None


class TestAssessmentServiceModuleQueries:
    """Tests for module-level queries."""

    def test_get_module_assessments(self, service, test_db):
        """Test getting all assessments for a module."""
        for user_id in ["user-1", "user-2"]:
            user = User(id=user_id, email=f"{user_id}@example.com")
            test_db.add(user)
            test_db.commit()
            for i in range(3):
                service.create_assessment(user_id, "module-123")

        assessments, total = service.get_module_assessments("module-123")

        assert total == 6
        assert len(assessments) == 6
        assert all(a.module_id == "module-123" for a in assessments)

    def test_get_module_assessments_pagination(self, service, test_db):
        """Test module assessments pagination."""
        for i in range(5):
            service.create_assessment("test-user-1", "module-123")

        assessments, total = service.get_module_assessments("module-123", limit=2, offset=0)

        assert total == 5
        assert len(assessments) == 2

    def test_get_module_assessments_empty(self, service, test_db):
        """Test getting assessments for module with none."""
        assessments, total = service.get_module_assessments("non-existent-module")
        assert len(assessments) == 0
        assert total == 0
