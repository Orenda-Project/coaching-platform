"""Observation scheduling and Teacher DC Score models.

These map to the Supabase production tables used by the observation scheduler.
The previous Phase 3 COT reflection models (category/response/rating) were unused
and had a conflicting schema — they have been replaced with the actual production schema.
"""

import uuid
from sqlalchemy import Column, String, Float, Text, DateTime, JSON, Index
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

    # Rubric & scoring
    fico_rubric = Column(JSON, nullable=True)
    hots_rubric = Column(JSON, nullable=True)
    proficiency_level = Column(String, nullable=True)
    notes_for_teacher = Column(Text, nullable=True)
    hots_notes = Column(Text, nullable=True)

    # Neo (debrief) integration
    neo_status = Column(String, nullable=True)
    neo_task_id = Column(String, nullable=True)
    neo_requested_at = Column(DateTime(timezone=True), nullable=True)
    neo_completed_at = Column(DateTime(timezone=True), nullable=True)
    neo_results = Column(JSON, nullable=True)
    neo_error = Column(Text, nullable=True)
    neo_audio_url = Column(Text, nullable=True)

    # DC (Digital Coach) integration
    dc_status = Column(String, nullable=True)
    dc_task_id = Column(String, nullable=True)
    dc_requested_at = Column(DateTime(timezone=True), nullable=True)
    dc_completed_at = Column(DateTime(timezone=True), nullable=True)
    dc_results = Column(JSON, nullable=True)
    dc_error = Column(Text, nullable=True)
    dc_audio_s3_key = Column(String, nullable=True)

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
            # Rubric & scoring
            "fico_rubric": self.fico_rubric,
            "hots_rubric": self.hots_rubric,
            "proficiency_level": self.proficiency_level,
            "notes_for_teacher": self.notes_for_teacher,
            "hots_notes": self.hots_notes,
            # Neo integration
            "neo_status": self.neo_status,
            "neo_task_id": self.neo_task_id,
            "neo_requested_at": self.neo_requested_at.isoformat() if self.neo_requested_at else None,
            "neo_completed_at": self.neo_completed_at.isoformat() if self.neo_completed_at else None,
            "neo_results": self.neo_results,
            "neo_error": self.neo_error,
            "neo_audio_url": self.neo_audio_url,
            # DC integration
            "dc_status": self.dc_status,
            "dc_task_id": self.dc_task_id,
            "dc_requested_at": self.dc_requested_at.isoformat() if self.dc_requested_at else None,
            "dc_completed_at": self.dc_completed_at.isoformat() if self.dc_completed_at else None,
            "dc_results": self.dc_results,
            "dc_error": self.dc_error,
            "dc_audio_s3_key": self.dc_audio_s3_key,
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
