from sqlalchemy import Column, String, Integer, Boolean, Text, ForeignKey, ARRAY, JSON, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Module(Base):
    """Training module."""

    __tablename__ = "modules"

    id = Column(String, primary_key=True)
    title = Column(String, nullable=False)
    description = Column(Text)
    is_mandatory = Column(Boolean, default=False)
    order_number = Column(Integer)
    competencies = Column(String)
    persona_required = Column(ARRAY(String), default=[])
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    trainings = relationship("Training", back_populates="module", cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "is_mandatory": self.is_mandatory,
            "order_number": self.order_number,
            "competencies": self.competencies,
            "persona_required": self.persona_required,
        }


class Training(Base):
    """Training unit (formerly called modules in UI)."""

    __tablename__ = "trainings"

    id = Column(String, primary_key=True)
    module_id = Column(String, ForeignKey("modules.id"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text)
    order_number = Column(Integer)
    is_common = Column(Boolean, default=False)
    persona_required = Column(String, nullable=True)
    main_concepts = Column(Text, nullable=True)
    max_attempts = Column(Integer, default=3)
    quiz_unlock_requires_content = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    module = relationship("Module", back_populates="trainings")
    content = relationship("TrainingContent", back_populates="training", cascade="all, delete-orphan")
    assessments = relationship("AssessmentContent", back_populates="training", cascade="all, delete-orphan")
    scenarios = relationship("Scenario", back_populates="training", cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id": self.id,
            "module_id": self.module_id,
            "title": self.title,
            "description": self.description,
            "order_number": self.order_number,
            "is_common": self.is_common,
            "persona_required": self.persona_required,
            "main_concepts": self.main_concepts,
            "max_attempts": self.max_attempts,
            "quiz_unlock_requires_content": self.quiz_unlock_requires_content,
            "content": [c.to_dict() for c in self.content],
            "quiz": {
                "passing_score_percent": 80,
                "max_attempts": self.max_attempts or 3,
                "questions": [],  # Questions now fetched via assessments
            },
            "scenarios": [s.to_dict() for s in self.scenarios],
        }


class TrainingContent(Base):
    """Video, slides, or other content for a training."""

    __tablename__ = "training_content"

    id = Column(String, primary_key=True)
    training_id = Column(String, ForeignKey("trainings.id"), nullable=False)
    format_type = Column(String)  # 'slides', 'video', 'scenario'
    content_url = Column(String)
    duration_minutes = Column(Integer)
    extra_data = Column(JSON)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    training = relationship("Training", back_populates="content")

    def to_dict(self):
        return {
            "id": self.id,
            "format_type": self.format_type,
            "content_url": self.content_url,
            "metadata": {
                "duration_minutes": self.duration_minutes,
                "type_label": self._get_type_label(),
            },
        }

    def _get_type_label(self):
        labels = {
            "slides": "Slides (Google Slides)",
            "video": "Video",
            "scenario": "Scenario",
        }
        return labels.get(self.format_type, self.format_type)


class AssessmentContent(Base):
    """Assessment/quiz definition (content table, NOT user tracking)."""

    __tablename__ = "assessments"

    id = Column(String, primary_key=True)
    type = Column(String)  # baseline, endline, module_quiz
    training_id = Column(String, ForeignKey("trainings.id"), nullable=True)
    title = Column(String, nullable=True)
    description = Column(Text, nullable=True)
    passing_score = Column(Integer, default=80)
    max_attempts = Column(Integer, default=3)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now())

    training = relationship("Training", back_populates="assessments")
    questions = relationship("Question", back_populates="assessment", cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id": self.id,
            "type": self.type,
            "training_id": self.training_id,
            "title": self.title,
            "description": self.description,
            "passing_score": self.passing_score,
            "max_attempts": self.max_attempts,
        }


class Question(Base):
    """Quiz question linked to an assessment."""

    __tablename__ = "questions"

    id = Column(String, primary_key=True)
    assessment_id = Column(String, ForeignKey("assessments.id"), nullable=False)
    question_type = Column(String)  # 'mcq', 'open'
    question_text = Column(Text, nullable=False)
    order_number = Column(Integer)
    max_score = Column(Integer, default=1)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    assessment = relationship("AssessmentContent", back_populates="questions")
    options = relationship("Option", back_populates="question", cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id": self.id,
            "question_text": self.question_text,
            "question_type": self.question_type,
            "order_number": self.order_number,
            "options": [o.to_dict() for o in self.options],
        }


class Option(Base):
    """Answer option for a multiple-choice question."""

    __tablename__ = "options"

    id = Column(String, primary_key=True)
    question_id = Column(String, ForeignKey("questions.id"), nullable=False)
    option_text = Column(Text, nullable=False)
    is_correct = Column(Boolean, default=False)
    order_number = Column(Integer)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    question = relationship("Question", back_populates="options")

    def to_dict(self):
        return {
            "id": self.id,
            "text": self.option_text,
            "is_correct": self.is_correct,
            "order": self.order_number,
        }


class Scenario(Base):
    """Scenario-based learning content."""

    __tablename__ = "export_scenarios"

    id = Column(String, primary_key=True)
    training_id = Column(String, ForeignKey("trainings.id"), nullable=False)
    situation = Column(Text)
    question = Column(Text)
    difficulty = Column(String)  # 'easy', 'medium', 'hard'
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    training = relationship("Training", back_populates="scenarios")
    options = relationship("ScenarioOption", back_populates="scenario", cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id": self.id,
            "situation": self.situation,
            "question": self.question,
            "difficulty": self.difficulty,
            "options": [o.to_dict() for o in self.options],
        }


class ScenarioOption(Base):
    """Option for a scenario."""

    __tablename__ = "export_scenario_options"

    id = Column(String, primary_key=True)
    scenario_id = Column(String, ForeignKey("export_scenarios.id"), nullable=False)
    letter = Column(String)  # 'a', 'b', 'c', 'd'
    option_text = Column(Text)
    is_correct = Column(Boolean, default=False)
    rationale = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    scenario = relationship("Scenario", back_populates="options")

    def to_dict(self):
        return {
            "letter": self.letter,
            "text": self.option_text,
            "is_correct": self.is_correct,
            "rationale": self.rationale,
        }
