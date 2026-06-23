"""
Tests for GET /api/coaching/observations/{id} and PATCH /api/coaching/observations/{id}

Uses an in-memory SQLite database so no external Postgres is required.
"""

import sys
import os
import uuid
import pytest

# Allow importing from the coaching-api package
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from fastapi.testclient import TestClient

from app.database import Base, get_db
from app.main import app
from app.models.observation import CotObservation


# ---------------------------------------------------------------------------
# Test database setup — StaticPool ensures all connections share one in-memory DB
# ---------------------------------------------------------------------------

TEST_ENGINE = create_engine(
    "sqlite:///:memory:",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestSession = sessionmaker(autocommit=False, autoflush=False, bind=TEST_ENGINE)


def override_get_db():
    db = TestSession()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


@pytest.fixture(autouse=True)
def setup_db():
    """Create only the cot_observations table (avoid ARRAY-type tables that SQLite can't handle)."""
    CotObservation.__table__.create(bind=TEST_ENGINE, checkfirst=True)
    yield
    CotObservation.__table__.drop(bind=TEST_ENGINE, checkfirst=True)


@pytest.fixture
def client():
    return TestClient(app)


@pytest.fixture
def sample_observation():
    """Insert a sample observation and return its ID."""
    db = TestSession()
    obs_id = str(uuid.uuid4())
    obs = CotObservation(
        id=obs_id,
        observer_id="observer-1",
        teacher_name="Test Teacher",
        school_name="Test School",
        subject="Math",
        grade="Grade 3",
        framework="FICO",
        date="2026-06-15",
        visit_purpose="Routine",
        status="Scheduled",
        region="Lahore",
    )
    db.add(obs)
    db.commit()
    db.close()
    return obs_id


# ---------------------------------------------------------------------------
# GET /api/coaching/observations/{observation_id}
# ---------------------------------------------------------------------------

class TestGetObservation:
    def test_get_existing_observation(self, client, sample_observation):
        """GET returns 200 with all fields for an existing observation."""
        resp = client.get(f"/api/coaching/observations/{sample_observation}")
        assert resp.status_code == 200
        data = resp.json()
        assert data["id"] == sample_observation
        assert data["teacher_name"] == "Test Teacher"
        assert data["school_name"] == "Test School"
        assert data["status"] == "Scheduled"
        # Verify new columns are present (nullable defaults)
        assert "fico_rubric" in data
        assert "hots_rubric" in data
        assert "neo_status" in data
        assert "dc_status" in data
        assert "notes_for_teacher" in data

    def test_get_nonexistent_observation(self, client):
        """GET returns 404 for a non-existent ID."""
        resp = client.get(f"/api/coaching/observations/{uuid.uuid4()}")
        assert resp.status_code == 404


# ---------------------------------------------------------------------------
# PATCH /api/coaching/observations/{observation_id}
# ---------------------------------------------------------------------------

class TestPatchObservation:
    def test_patch_status_only(self, client, sample_observation):
        """PATCH with status only changes status and updated_at."""
        resp = client.patch(
            f"/api/coaching/observations/{sample_observation}",
            json={"status": "Draft"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "Draft"
        assert data["updated_at"] is not None

    def test_patch_rubric_and_score(self, client, sample_observation):
        """PATCH with JSONB rubric + total_score + proficiency_level stores correctly."""
        rubric = {"section_b": {"B1": "yes", "B2": "partial"}}
        resp = client.patch(
            f"/api/coaching/observations/{sample_observation}",
            json={
                "fico_rubric": rubric,
                "total_score": 72.5,
                "proficiency_level": "Proficient",
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["fico_rubric"] == rubric
        assert data["total_score"] == 72.5
        assert data["proficiency_level"] == "Proficient"

    def test_patch_notes_fields(self, client, sample_observation):
        """PATCH with notes fields stores correctly."""
        resp = client.patch(
            f"/api/coaching/observations/{sample_observation}",
            json={
                "notes_for_teacher": "Good lesson delivery",
                "hots_notes": "Strong critical thinking observed",
            },
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["notes_for_teacher"] == "Good lesson delivery"
        assert data["hots_notes"] == "Strong critical thinking observed"

    def test_patch_nonexistent_observation(self, client):
        """PATCH returns 404 for a non-existent ID."""
        resp = client.patch(
            f"/api/coaching/observations/{uuid.uuid4()}",
            json={"status": "Draft"},
        )
        assert resp.status_code == 404

    def test_patch_empty_body(self, client, sample_observation):
        """PATCH with empty body returns 200 and updates updated_at."""
        resp = client.patch(
            f"/api/coaching/observations/{sample_observation}",
            json={},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["id"] == sample_observation
        assert data["updated_at"] is not None

    def test_patch_submitted_sets_submitted_at(self, client, sample_observation):
        """PATCH with status=Submitted auto-sets submitted_at if not provided."""
        resp = client.patch(
            f"/api/coaching/observations/{sample_observation}",
            json={"status": "Submitted"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "Submitted"
        assert data["submitted_at"] is not None

    def test_patch_preserves_unset_fields(self, client, sample_observation):
        """PATCH only changes provided fields, others stay the same."""
        # Set notes first
        client.patch(
            f"/api/coaching/observations/{sample_observation}",
            json={"notes_for_teacher": "First note"},
        )
        # Now patch only status — notes should remain
        resp = client.patch(
            f"/api/coaching/observations/{sample_observation}",
            json={"status": "Draft"},
        )
        data = resp.json()
        assert data["status"] == "Draft"
        assert data["notes_for_teacher"] == "First note"


class TestPatchObservationNeoFields:
    def test_patch_neo_task_id_and_processing_status(self, client, sample_observation):
        """PATCH with neo_task_id + neo_status=processing persists correctly."""
        resp = client.patch(
            f"/api/coaching/observations/{sample_observation}",
            json={"neo_task_id": "task-abc123", "neo_status": "processing"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["neo_task_id"] == "task-abc123"
        assert data["neo_status"] == "processing"

    def test_patch_neo_results_on_completion(self, client, sample_observation):
        """PATCH with neo_status=completed + neo_results dict persists and round-trips."""
        neo_results = {
            "overall_score": 75,
            "grade": "Proficient",
            "section_scores": {"S1": 12, "S2": 18},
        }
        resp = client.patch(
            f"/api/coaching/observations/{sample_observation}",
            json={"neo_status": "completed", "neo_results": neo_results},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["neo_status"] == "completed"
        assert data["neo_results"]["overall_score"] == 75
        assert data["neo_results"]["grade"] == "Proficient"
        assert data["neo_results"]["section_scores"]["S1"] == 12

    def test_patch_neo_error_on_failure(self, client, sample_observation):
        """PATCH with neo_status=failed + neo_error string persists correctly."""
        resp = client.patch(
            f"/api/coaching/observations/{sample_observation}",
            json={"neo_status": "failed", "neo_error": "Audio too short"},
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["neo_status"] == "failed"
        assert data["neo_error"] == "Audio too short"
