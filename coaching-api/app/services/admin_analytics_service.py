"""Admin analytics service — replicates the 5-query aggregation from AdminAnalytics.tsx server-side."""

from sqlalchemy import select
from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional
from collections import defaultdict

from app.models.user import UserProfile
from app.models.training import Module, Training, AssessmentContent
from app.models.training_progress import TrainingProgress


class AdminAnalyticsService:
    """Service for admin analytics dashboard aggregation."""

    def __init__(self, db: Session):
        self.db = db

    def get_dashboard(
        self,
        region: Optional[str] = None,
        persona: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Build the full analytics dashboard data.

        Replaces the 5 parallel Supabase queries + client-side aggregation
        with a single server-side computation.

        Returns dict with 'coaches' list (pre-aggregated CoachRow objects).
        """
        # 1. Fetch all profiles
        profile_query = select(UserProfile).order_by(UserProfile.created_at.desc())
        if region:
            profile_query = profile_query.filter(UserProfile.region == region)
        if persona:
            profile_query = profile_query.filter(UserProfile.persona == persona)
        profiles = self.db.execute(profile_query).scalars().all()

        # 2. Fetch all training_progress
        progress_rows = self.db.execute(select(TrainingProgress)).scalars().all()

        # 3. Fetch all trainings
        trainings = self.db.execute(select(Training)).scalars().all()

        # 4. Fetch all modules
        modules = self.db.execute(select(Module)).scalars().all()

        # 5. Fetch all assessments (for type mapping)
        assessments = self.db.execute(select(AssessmentContent)).scalars().all()

        # Build lookup maps
        progress_by_user: Dict[str, List[Dict]] = defaultdict(list)
        for tp in progress_rows:
            progress_by_user[tp.user_id].append({
                "user_id": tp.user_id,
                "training_id": tp.training_id,
                "passed": tp.passed or False,
                "score": tp.score,
                "attempt_count": tp.attempt_count or 0,
                "tab_switch_count": tp.tab_switch_count or 0,
                "fullscreen_violations": tp.fullscreen_violations or 0,
                "flagged_for_review": tp.flagged_for_review or False,
                "content_completed": tp.content_completed or False,
            })

        trainings_map: Dict[str, Dict] = {}
        total_by_persona: Dict[str, int] = defaultdict(int)
        for t in trainings:
            trainings_map[t.id] = {
                "title": t.title,
                "module_id": t.module_id,
                "persona_required": t.persona_required,
            }
            key = t.persona_required or "all"
            total_by_persona[key] += 1

        modules_map: Dict[str, str] = {m.id: m.title for m in modules}

        assessment_map: Dict[str, str] = {}
        for a in assessments:
            if a.training_id:
                assessment_map[a.training_id] = a.type

        def get_quiz_type(training_id: str) -> str:
            at = assessment_map.get(training_id, "")
            if at == "baseline":
                return "baseline"
            if at == "endline":
                return "endline"
            return "module"

        def build_module_details(user_trainings: List[Dict]) -> List[Dict]:
            module_data: Dict[str, Dict] = {}
            module_progress: Dict[str, Dict] = {}

            for ut in user_trainings:
                training = trainings_map.get(ut["training_id"])
                if not training or not training["module_id"]:
                    continue

                mid = training["module_id"]
                if mid not in module_data:
                    module_data[mid] = {"title": modules_map.get(mid, "Unknown Module"), "units": []}
                    module_progress[mid] = {"completed": 0, "total": 0}

                quiz_type = get_quiz_type(ut["training_id"])
                module_data[mid]["units"].append({
                    "unitId": ut["training_id"],
                    "unitTitle": training["title"],
                    "passed": ut["passed"],
                    "tabSwitches": ut["tab_switch_count"],
                    "quizType": quiz_type,
                    "score": ut["score"],
                    "attemptCount": ut["attempt_count"],
                })

                module_progress[mid]["total"] += 1
                if ut["passed"]:
                    module_progress[mid]["completed"] += 1

            result = []
            for mid, info in module_data.items():
                module_scores = [
                    u["score"] for u in info["units"]
                    if u["quizType"] == "module" and u["score"] is not None
                ]
                avg_score = (
                    round(sum(module_scores) / len(module_scores))
                    if module_scores else None
                )
                result.append({
                    "moduleId": mid,
                    "moduleTitle": info["title"],
                    "unitsCompleted": module_progress[mid]["completed"],
                    "unitsTotal": module_progress[mid]["total"],
                    "units": info["units"],
                    "avgScore": avg_score,
                })
            return result

        # Build coach rows
        coaches: List[Dict[str, Any]] = []
        for p in profiles:
            tp = progress_by_user.get(p.id, [])
            passed_count = sum(1 for r in tp if r["passed"])
            started_count = len(tp)

            # Avg quiz score (module quiz only)
            module_scores = [
                r["score"] for r in tp
                if get_quiz_type(r["training_id"]) == "module" and r["score"] is not None
            ]
            avg_quiz = round(sum(module_scores) / len(module_scores)) if module_scores else None

            total_tabs = sum(r["tab_switch_count"] for r in tp)
            flagged = any(r["flagged_for_review"] for r in tp)
            total_trainings = total_by_persona.get(p.persona or "all", 0)

            module_details = build_module_details(tp)
            modules_completed = sum(
                1 for m in module_details
                if m["unitsCompleted"] == m["unitsTotal"] and m["unitsTotal"] > 0
            )

            # Tab switch breakdown
            tab_breakdown = {"baseline": 0, "module": 0, "endline": 0}
            for r in tp:
                qt = get_quiz_type(r["training_id"])
                tab_breakdown[qt] += r["tab_switch_count"]

            coaches.append({
                "id": p.id,
                "full_name": p.full_name,
                "phone": p.phone,
                "region": p.region,
                "sub_region": p.sub_region,
                "school_id": p.school_id,
                "persona": p.persona,
                "baseline_completed": p.baseline_completed or False,
                "baseline_score": p.baseline_score,
                "baseline_attempt_count": p.baseline_attempt_count or 0,
                "endline_completed": p.endline_completed or False,
                "endline_score": p.endline_score,
                "endline_attempt_count": p.endline_attempt_count or 0,
                "weak_modules": p.weak_modules or [],
                "created_at": p.created_at.isoformat() if p.created_at else None,
                "trainings_passed": passed_count,
                "trainings_started": started_count,
                "trainings_total": total_trainings,
                "modulesCompleted": modules_completed,
                "avg_quiz_score": avg_quiz,
                "total_tab_switches": total_tabs,
                "tabSwitchBreakdown": tab_breakdown,
                "flagged": flagged,
                "moduleDetails": module_details,
            })

        return {"coaches": coaches}
