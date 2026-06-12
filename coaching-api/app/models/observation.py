"""Observation scheduling and Teacher DC Score models.

These map to the Supabase production tables used by the observation scheduler.
The previous Phase 3 COT reflection models (category/response/rating) were unused
and had a conflicting schema — they have been replaced with the actual production schema.
"""

import uuid
from sqlalchemy import Column, String, Float, DateTime, JSON, Index
from sqlalchemy.sql import func
from app.database import Base


class CotObservation(Base):
    """Classroom observation visit — used by the observation scheduler."""

    __tablename__ = "cot_observations"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    observer_id = Column(String, nullable=False, index=True)
    teacher_name = Column(String, nullable=False)
    school_name = Column(String, nullable=False)
    subject = Column(String)
    grade = Column(String)
    topic = Column(String, nullable=True)
    framework = Column(String)  # FICO, HOTS
    date = Column(String)
    visit_purpose = Column(String)
    status = Column(String, default="Scheduled")  # Scheduled, Draft, Submitted, Approved
    region = Column(String)
    week = Column(String, nullable=True)
    visit_type = Column(String, nullable=True)
    planned_date = Column(String, nullable=True)
    arrival_time = Column(String, nullable=True)
    departure_time = Column(String, nullable=True)
    total_score = Column(Float, nullable=True)
    submitted_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    def to_dict(self):
        return {
            "id": self.id,
            "observer_id": self.observer_id,
            "teacher_name": self.teacher_name,
            "school_name": self.school_name,
            "subject": self.subject,
            "grade": self.grade,
            "topic": self.topic,
            "framework": self.framework,
            "date": self.date,
            "visit_purpose": self.visit_purpose,
            "status": self.status,
            "region": self.region,
            "week": self.week,
            "visit_type": self.visit_type,
            "planned_date": self.planned_date,
            "arrival_time": self.arrival_time,
            "departure_time": self.departure_time,
            "total_score": self.total_score,
            "submitted_at": self.submitted_at.isoformat() if self.submitted_at else None,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class TeacherDcScore(Base):
    """Teacher DC score record from classroom observations."""

    __tablename__ = "teacher_dc_scores"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    teacher_name = Column(String, nullable=False)
    school_name = Column(String, nullable=False)
    region = Column(String, nullable=False, index=True)
    grade = Column(String)
    subject = Column(String)
    total_score = Column(Float, nullable=False)
    framework = Column(String)
    scored_at = Column(DateTime(timezone=True))
    raw_results = Column(JSON, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    def to_dict(self):
        return {
            "id": self.id,
            "teacher_name": self.teacher_name,
            "school_name": self.school_name,
            "region": self.region,
            "grade": self.grade,
            "subject": self.subject,
            "total_score": self.total_score,
            "framework": self.framework,
            "scored_at": self.scored_at.isoformat() if self.scored_at else None,
            "raw_results": self.raw_results,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
