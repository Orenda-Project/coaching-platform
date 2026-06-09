"""Admin management API endpoints for system administration."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional, List
from app.database import get_db
from app.services.admin_service import AdminService

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
