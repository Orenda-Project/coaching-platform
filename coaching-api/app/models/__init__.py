from app.models.training import (
    Module,
    Training,
    TrainingContent,
    AssessmentContent,
    Question,
    Option,
    Scenario as ExportScenario,
    ScenarioOption as ExportScenarioOption,
)
from app.models.user import User, UserProfile, UserRole
from app.models.assessment import Assessment, AssessmentResponse, AssessmentAttempt
from app.models.training_progress import TrainingProgress, ModuleQuizAttempt
from app.models.certificate import Certificate
from app.models.analytics import AnalyticsEvent, UserMetrics
# Temporarily disabled: Scenario class conflicts with ExportScenario from training.py
# These are for Phase 3 Coaching APIs (not yet in use)
# from app.models.scenario import Scenario, ScenarioOption, ScenarioResponse
from app.models.admin import AdminUser, AdminRole, FieldIssue, FieldIssueStatus, Region
from app.models.observation import CotObservation, TeacherDcScore

__all__ = [
    "Module",
    "Training",
    "TrainingContent",
    "AssessmentContent",
    "Question",
    "Option",
    "ExportScenario",
    "ExportScenarioOption",
    "User",
    "UserProfile",
    "UserRole",
    "Assessment",
    "AssessmentResponse",
    "AssessmentAttempt",
    "TrainingProgress",
    "ModuleQuizAttempt",
    "Certificate",
    "AnalyticsEvent",
    "UserMetrics",
    # "Scenario",  # Temporarily disabled (conflicts with ExportScenario)
    # "ScenarioOption",
    # "ScenarioResponse",
    "AdminUser",
    "AdminRole",
    "FieldIssue",
    "FieldIssueStatus",
    "Region",
    "CotObservation",
    "TeacherDcScore",
]
