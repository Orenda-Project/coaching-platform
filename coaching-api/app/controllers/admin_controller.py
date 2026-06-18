"""Admin management API endpoints for system administration."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from app.database import get_db
from app.services.admin_service import AdminService
from app.services.admin_feedback_service import AdminFeedbackService
from app.services.admin_analytics_service import AdminAnalyticsService
from app.services.admin_content_service import AdminContentService
from app.services.admin_scenario_service import AdminScenarioService

router = APIRouter(prefix="/api/admin", tags=["admin"])


# ===== Request/Response Models =====

class AdminUserRequest(BaseModel):
    """Request for creating/updating admin user."""

    user_id: str
    role: str = Field(default="super_admin", description="super_admin or regional_admin")


class AdminUserResponse(BaseModel):
    """Admin user response."""

    id: str
    user_id: str
    role: str
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class FieldIssueRequest(BaseModel):
    """Request for creating field issue."""

    description: str = Field(..., min_length=10, description="Issue description (min 10 chars)")
    reported_by: str = Field(..., description="User ID of reporter")
    assigned_to: Optional[str] = Field(None, description="User ID of assignee (optional)")


class FieldIssueUpdateRequest(BaseModel):
    """Request for updating field issue."""

    description: Optional[str] = None
    status: Optional[str] = Field(None, description="open, in_progress, resolved, closed")
    assigned_to: Optional[str] = None


class FieldIssueResponse(BaseModel):
    """Field issue response."""

    id: str
    description: str
    status: str
    reported_by: str
    assigned_to: Optional[str]
    created_at: str
    updated_at: str
    resolved_at: Optional[str]

    class Config:
        from_attributes = True


class RegionRequest(BaseModel):
    """Request for creating/updating region."""

    name: str = Field(..., min_length=2, description="Region name")
    parent_id: Optional[str] = Field(None, description="Parent region ID (optional)")
    is_active: Optional[bool] = Field(True, description="Is region active")


class RegionResponse(BaseModel):
    """Region response."""

    id: str
    name: str
    parent_id: Optional[str]
    is_active: bool
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class PaginatedResponse(BaseModel):
    """Generic paginated response."""

    items: List[dict]
    total: int
    limit: int
    offset: int


# ===== ADMIN USER ENDPOINTS (4 endpoints) =====

@router.post("/users", response_model=AdminUserResponse, status_code=201)
async def create_admin_user(
    request: AdminUserRequest,
    db: Session = Depends(get_db)
):
    """
    Create a new admin user.

    Args:
        request: Admin user creation request

    Returns:
        Created admin user
    """
    service = AdminService(db)

    # Check if user_id already has admin record
    existing = service.get_admin_user_by_user_id(request.user_id)
    if existing:
        raise HTTPException(
            status_code=409,
            detail="User is already an admin"
        )

    admin_user = service.create_admin_user(request.user_id, request.role)
    if not admin_user:
        raise HTTPException(
            status_code=400,
            detail="Invalid role or failed to create admin user"
        )

    return admin_user.to_dict()


@router.get("/users/{admin_id}", response_model=AdminUserResponse)
async def get_admin_user(
    admin_id: str,
    db: Session = Depends(get_db)
):
    """Get admin user by ID."""
    service = AdminService(db)
    admin_user = service.get_admin_user_by_id(admin_id)

    if not admin_user:
        raise HTTPException(status_code=404, detail="Admin user not found")

    return admin_user.to_dict()


@router.get("/users", response_model=dict)
async def list_admin_users(
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    List all admin users with pagination.

    Args:
        limit: Number of results (max 1000)
        offset: Results offset

    Returns:
        Admin users list with total count
    """
    service = AdminService(db)
    admins, total = service.get_all_admin_users(limit=limit, offset=offset)

    return {
        "users": [a.to_dict() for a in admins],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.put("/users/{admin_id}/role", response_model=AdminUserResponse)
async def update_admin_user_role(
    admin_id: str,
    request: AdminUserRequest,
    db: Session = Depends(get_db)
):
    """
    Update admin user role.

    Args:
        admin_id: Admin user ID
        request: New role

    Returns:
        Updated admin user
    """
    service = AdminService(db)
    admin_user = service.update_admin_user_role(admin_id, request.role)

    if not admin_user:
        raise HTTPException(
            status_code=404,
            detail="Admin user not found or invalid role"
        )

    return admin_user.to_dict()


# ===== FIELD ISSUE ENDPOINTS (4 endpoints) =====

@router.post("/issues", response_model=FieldIssueResponse, status_code=201)
async def create_field_issue(
    request: FieldIssueRequest,
    db: Session = Depends(get_db)
):
    """
    Create a new field issue.

    Args:
        request: Field issue creation request

    Returns:
        Created field issue
    """
    service = AdminService(db)
    issue = service.create_field_issue(
        description=request.description,
        reported_by=request.reported_by,
        assigned_to=request.assigned_to
    )

    if not issue:
        raise HTTPException(
            status_code=400,
            detail="Failed to create field issue (invalid reporter/assignee)"
        )

    return issue.to_dict()


@router.get("/issues/{issue_id}", response_model=FieldIssueResponse)
async def get_field_issue(
    issue_id: str,
    db: Session = Depends(get_db)
):
    """Get field issue by ID."""
    service = AdminService(db)
    issue = service.get_field_issue_by_id(issue_id)

    if not issue:
        raise HTTPException(status_code=404, detail="Field issue not found")

    return issue.to_dict()


@router.get("/issues", response_model=dict)
async def list_field_issues(
    status: Optional[str] = Query(None, description="Filter by status"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    List field issues with optional status filter.

    Args:
        status: Optional status filter (open, in_progress, resolved, closed)
        limit: Number of results (max 1000)
        offset: Results offset

    Returns:
        Field issues list with total count
    """
    service = AdminService(db)
    issues, total = service.get_all_field_issues(status=status, limit=limit, offset=offset)

    return {
        "issues": [i.to_dict() for i in issues],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.put("/issues/{issue_id}", response_model=FieldIssueResponse)
async def update_field_issue(
    issue_id: str,
    request: FieldIssueUpdateRequest,
    db: Session = Depends(get_db)
):
    """
    Update field issue.

    Args:
        issue_id: Field issue ID
        request: Update data

    Returns:
        Updated field issue
    """
    service = AdminService(db)

    update_data = {k: v for k, v in request.dict().items() if v is not None}
    issue = service.update_field_issue(issue_id, **update_data)

    if not issue:
        raise HTTPException(
            status_code=404,
            detail="Field issue not found or invalid update"
        )

    return issue.to_dict()


# ===== REGION ENDPOINTS (4 endpoints) =====

@router.post("/regions", response_model=RegionResponse, status_code=201)
async def create_region(
    request: RegionRequest,
    db: Session = Depends(get_db)
):
    """
    Create a new region.

    Args:
        request: Region creation request

    Returns:
        Created region
    """
    service = AdminService(db)

    # Check if region name already exists
    existing = service.get_region_by_name(request.name)
    if existing:
        raise HTTPException(
            status_code=409,
            detail="Region with this name already exists"
        )

    # Validate parent_id if provided
    if request.parent_id:
        parent = service.get_region_by_id(request.parent_id)
        if not parent:
            raise HTTPException(
                status_code=400,
                detail="Parent region not found"
            )

    region = service.create_region(name=request.name, parent_id=request.parent_id)
    if not region:
        raise HTTPException(
            status_code=400,
            detail="Failed to create region"
        )

    return region.to_dict()


@router.get("/regions/{region_id}", response_model=RegionResponse)
async def get_region(
    region_id: str,
    db: Session = Depends(get_db)
):
    """Get region by ID."""
    service = AdminService(db)
    region = service.get_region_by_id(region_id)

    if not region:
        raise HTTPException(status_code=404, detail="Region not found")

    return region.to_dict()


@router.get("/regions", response_model=dict)
async def list_regions(
    active_only: bool = Query(False, description="Filter to active regions"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    List regions with optional filtering.

    Args:
        active_only: Filter to active regions only
        limit: Number of results (max 1000)
        offset: Results offset

    Returns:
        Regions list with total count
    """
    service = AdminService(db)
    regions, total = service.get_all_regions(active_only=active_only, limit=limit, offset=offset)

    return {
        "regions": [r.to_dict() for r in regions],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.put("/regions/{region_id}", response_model=RegionResponse)
async def update_region(
    region_id: str,
    request: RegionRequest,
    db: Session = Depends(get_db)
):
    """
    Update region.

    Args:
        region_id: Region ID
        request: Update data

    Returns:
        Updated region
    """
    service = AdminService(db)

    # Validate parent_id if provided
    if request.parent_id:
        parent = service.get_region_by_id(request.parent_id)
        if not parent:
            raise HTTPException(
                status_code=400,
                detail="Parent region not found"
            )

    update_data = {k: v for k, v in request.dict().items() if v is not None}
    region = service.update_region(region_id, **update_data)

    if not region:
        raise HTTPException(
            status_code=404,
            detail="Region not found or name already exists"
        )

    return region.to_dict()


# ===== DELETE ENDPOINTS =====

@router.delete("/users/{admin_id}", status_code=204)
async def delete_admin_user(
    admin_id: str,
    db: Session = Depends(get_db)
):
    """Delete admin user."""
    service = AdminService(db)
    success = service.delete_admin_user(admin_id)

    if not success:
        raise HTTPException(status_code=404, detail="Admin user not found")

    return None


@router.delete("/issues/{issue_id}", status_code=204)
async def delete_field_issue(
    issue_id: str,
    db: Session = Depends(get_db)
):
    """Delete field issue."""
    service = AdminService(db)
    success = service.delete_field_issue(issue_id)

    if not success:
        raise HTTPException(status_code=404, detail="Field issue not found")

    return None


@router.delete("/regions/{region_id}", status_code=204)
async def delete_region(
    region_id: str,
    db: Session = Depends(get_db)
):
    """Delete region."""
    service = AdminService(db)
    success = service.delete_region(region_id)

    if not success:
        raise HTTPException(status_code=404, detail="Region not found")

    return None


@router.get("/health")
async def health_check():
    """Health check for admin service."""
    return {
        "status": "healthy",
        "service": "admin",
    }


# ===== REQUEST MODELS FOR NEW ENDPOINTS =====

class ModuleRequest(BaseModel):
    """Request for creating/updating a module."""
    title: str
    description: Optional[str] = None
    desired_outcomes: Optional[str] = None
    competencies: Optional[str] = None
    is_mandatory: bool = False
    order_number: Optional[int] = None


class TrainingRequest(BaseModel):
    """Request for creating/updating a training unit."""
    module_id: str
    title: str
    description: Optional[str] = None
    main_concepts: Optional[str] = None
    is_common: bool = True
    persona_required: Optional[str] = None
    order_number: Optional[int] = None


class TrainingContentRequest(BaseModel):
    """Request for creating training content."""
    training_id: str
    format_type: str = "video"
    content_url: str


class AssessmentRequest(BaseModel):
    """Request for creating/updating an assessment."""
    title: Optional[str] = None
    type: str
    training_id: Optional[str] = None
    question_type: Optional[str] = "mcq"
    passing_score: Optional[int] = 80
    max_attempts: Optional[int] = 3
    description: Optional[str] = None


class OptionData(BaseModel):
    """Single option within a question."""
    id: Optional[str] = None
    text: str
    is_correct: bool = False
    order: Optional[int] = None


class QuestionData(BaseModel):
    """Single question with options."""
    id: Optional[str] = None
    question_text: str
    question_type: str = "mcq"
    order_number: Optional[int] = None
    max_score: int = 1
    options: List[OptionData] = []


class BulkQuestionsRequest(BaseModel):
    """Bulk questions upsert request."""
    questions: List[QuestionData]


class ScenarioRequest(BaseModel):
    """Request for creating/updating a scenario."""
    training_id: Optional[str] = None
    unit_id: Optional[str] = None  # alias for training_id (frontend compat)
    order_number: Optional[int] = None
    situation: str
    question: str
    difficulty: str = "medium"
    feedback_slides: Optional[Any] = None
    reveal_content: Optional[str] = None
    deep_content: Optional[str] = None
    is_active: bool = True


class ScenarioOptionData(BaseModel):
    """Single scenario option."""
    id: Optional[str] = None
    letter: Optional[str] = None
    text: str
    is_correct: bool = False
    rationale: Optional[str] = None
    principle_tag: Optional[str] = None


class ScenarioOptionsRequest(BaseModel):
    """Bulk scenario options upsert request."""
    options: List[ScenarioOptionData]


# ===== FEEDBACK ENDPOINTS =====

@router.get("/feedback", response_model=dict)
async def get_feedback(
    days: int = Query(30, ge=1, le=365),
    category: Optional[str] = Query(None),
    rating: Optional[int] = Query(None, ge=1, le=5),
    persona: Optional[str] = Query(None),
    limit: int = Query(500, ge=1, le=5000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    """Get feedback records with KPIs."""
    service = AdminFeedbackService(db)
    return service.get_feedback(
        days=days, category=category, rating=rating,
        persona=persona, limit=limit, offset=offset,
    )


# ===== ANALYTICS ENDPOINTS =====

@router.get("/analytics/dashboard", response_model=dict)
async def get_analytics_dashboard(
    region: Optional[str] = Query(None),
    persona: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """Get pre-aggregated analytics dashboard data."""
    service = AdminAnalyticsService(db)
    return service.get_dashboard(region=region, persona=persona)


# ===== MODULE ENDPOINTS =====

@router.get("/modules", response_model=dict)
async def list_modules(db: Session = Depends(get_db)):
    """List all modules ordered by order_number."""
    service = AdminContentService(db)
    return {"modules": service.list_modules()}


@router.post("/modules", response_model=dict, status_code=201)
async def create_module(request: ModuleRequest, db: Session = Depends(get_db)):
    """Create a new module."""
    service = AdminContentService(db)
    return service.create_module(request.dict())


@router.put("/modules/{module_id}", response_model=dict)
async def update_module(module_id: str, request: ModuleRequest, db: Session = Depends(get_db)):
    """Update a module."""
    service = AdminContentService(db)
    result = service.update_module(module_id, request.dict(exclude_unset=True))
    if not result:
        raise HTTPException(status_code=404, detail="Module not found")
    return result


@router.delete("/modules/{module_id}", status_code=204)
async def delete_module(module_id: str, db: Session = Depends(get_db)):
    """Delete a module."""
    service = AdminContentService(db)
    if not service.delete_module(module_id):
        raise HTTPException(status_code=404, detail="Module not found")
    return None


# ===== TRAINING ENDPOINTS =====

@router.get("/trainings", response_model=dict)
async def list_trainings(
    module_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """List trainings, optionally filtered by module_id."""
    service = AdminContentService(db)
    return {"trainings": service.list_trainings(module_id=module_id)}


@router.post("/trainings", response_model=dict, status_code=201)
async def create_training(request: TrainingRequest, db: Session = Depends(get_db)):
    """Create a new training unit."""
    service = AdminContentService(db)
    return service.create_training(request.dict())


@router.put("/trainings/{training_id}", response_model=dict)
async def update_training(training_id: str, request: TrainingRequest, db: Session = Depends(get_db)):
    """Update a training unit."""
    service = AdminContentService(db)
    result = service.update_training(training_id, request.dict(exclude_unset=True))
    if not result:
        raise HTTPException(status_code=404, detail="Training not found")
    return result


@router.delete("/trainings/{training_id}", status_code=204)
async def delete_training(training_id: str, db: Session = Depends(get_db)):
    """Delete a training unit."""
    service = AdminContentService(db)
    if not service.delete_training(training_id):
        raise HTTPException(status_code=404, detail="Training not found")
    return None


# ===== TRAINING CONTENT ENDPOINTS =====

@router.get("/training-content", response_model=dict)
async def list_training_content(
    training_id: str = Query(...),
    db: Session = Depends(get_db),
):
    """List training content for a specific training."""
    service = AdminContentService(db)
    return {"content": service.list_training_content(training_id)}


@router.post("/training-content", response_model=dict, status_code=201)
async def create_training_content(request: TrainingContentRequest, db: Session = Depends(get_db)):
    """Create a new training content entry."""
    service = AdminContentService(db)
    return service.create_training_content(request.dict())


@router.delete("/training-content/{content_id}", status_code=204)
async def delete_training_content(content_id: str, db: Session = Depends(get_db)):
    """Delete a training content entry."""
    service = AdminContentService(db)
    if not service.delete_training_content(content_id):
        raise HTTPException(status_code=404, detail="Training content not found")
    return None


# ===== ASSESSMENT ENDPOINTS =====

@router.get("/assessments", response_model=dict)
async def list_assessments(
    training_id: Optional[str] = Query(None),
    type: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """List assessments, optionally filtered by training_id and/or type."""
    service = AdminContentService(db)
    return {"assessments": service.list_assessments(training_id=training_id, assessment_type=type)}


@router.post("/assessments", response_model=dict, status_code=201)
async def create_assessment(request: AssessmentRequest, db: Session = Depends(get_db)):
    """Create a new assessment."""
    service = AdminContentService(db)
    return service.create_assessment(request.dict())


@router.put("/assessments/{assessment_id}", response_model=dict)
async def update_assessment(assessment_id: str, request: AssessmentRequest, db: Session = Depends(get_db)):
    """Update an assessment."""
    service = AdminContentService(db)
    result = service.update_assessment(assessment_id, request.dict(exclude_unset=True))
    if not result:
        raise HTTPException(status_code=404, detail="Assessment not found")
    return result


# ===== QUESTION ENDPOINTS =====

@router.get("/assessments/{assessment_id}/questions", response_model=dict)
async def get_questions(assessment_id: str, db: Session = Depends(get_db)):
    """Get all questions for an assessment."""
    service = AdminContentService(db)
    return {"questions": service.get_questions_by_assessment(assessment_id)}


@router.put("/assessments/{assessment_id}/questions", response_model=dict)
async def bulk_upsert_questions(
    assessment_id: str,
    request: BulkQuestionsRequest,
    db: Session = Depends(get_db),
):
    """Bulk upsert questions for an assessment."""
    service = AdminContentService(db)
    try:
        questions = service.bulk_upsert_questions(
            assessment_id,
            [q.dict() for q in request.questions],
        )
        return {"questions": questions}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.delete("/questions/{question_id}", status_code=204)
async def delete_question(question_id: str, db: Session = Depends(get_db)):
    """Delete a question."""
    service = AdminContentService(db)
    if not service.delete_question(question_id):
        raise HTTPException(status_code=404, detail="Question not found")
    return None


# ===== SCENARIO ENDPOINTS =====

@router.get("/scenarios", response_model=dict)
async def list_scenarios(
    training_id: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """List scenarios, optionally filtered by training_id (unit_id)."""
    service = AdminScenarioService(db)
    return {"scenarios": service.list_scenarios(training_id=training_id)}


@router.post("/scenarios", response_model=dict, status_code=201)
async def create_scenario(request: ScenarioRequest, db: Session = Depends(get_db)):
    """Create a new scenario."""
    service = AdminScenarioService(db)
    data = request.dict()
    # Resolve training_id: accept either training_id or unit_id
    if not data.get("training_id") and data.get("unit_id"):
        data["training_id"] = data["unit_id"]
    data.pop("unit_id", None)
    return service.create_scenario(data)


@router.put("/scenarios/{scenario_id}", response_model=dict)
async def update_scenario(scenario_id: str, request: ScenarioRequest, db: Session = Depends(get_db)):
    """Update a scenario."""
    service = AdminScenarioService(db)
    data = request.dict(exclude_unset=True)
    if not data.get("training_id") and data.get("unit_id"):
        data["training_id"] = data["unit_id"]
    data.pop("unit_id", None)
    result = service.update_scenario(scenario_id, data)
    if not result:
        raise HTTPException(status_code=404, detail="Scenario not found")
    return result


@router.delete("/scenarios/{scenario_id}", status_code=204)
async def delete_scenario(scenario_id: str, db: Session = Depends(get_db)):
    """Delete a scenario."""
    service = AdminScenarioService(db)
    if not service.delete_scenario(scenario_id):
        raise HTTPException(status_code=404, detail="Scenario not found")
    return None


@router.post("/scenarios/{scenario_id}/options", response_model=dict)
async def upsert_scenario_options(
    scenario_id: str,
    request: ScenarioOptionsRequest,
    db: Session = Depends(get_db),
):
    """Upsert options for a scenario."""
    service = AdminScenarioService(db)
    try:
        options = service.upsert_options(
            scenario_id,
            [o.dict() for o in request.options],
        )
        return {"options": options}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
