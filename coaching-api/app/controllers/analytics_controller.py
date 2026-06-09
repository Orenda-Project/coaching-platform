"""Analytics API endpoints."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional, List
from app.database import get_db
from app.services.analytics_service import AnalyticsService

router = APIRouter(prefix="/api/analytics", tags=["analytics"])


# Request/Response Models
class LogEventRequest(BaseModel):
    """Request to log an analytics event."""

    event_type: str
    event_data: Optional[dict] = Field(default=None, description="Event metadata")

    class Config:
        json_schema_extra = {
            "example": {
                "event_type": "quiz_completed",
                "event_data": {
                    "module_id": "module-1",
                    "score": 85,
                    "duration_seconds": 300
                }
            }
        }


class UpdateMetricsRequest(BaseModel):
    """Request to update user metrics."""

    quiz_attempts: Optional[int] = None
    modules_passed: Optional[int] = None
    total_score: Optional[float] = None


class IncrementMetricRequest(BaseModel):
    """Request to increment a metric."""

    metric_name: str  # quiz_attempts, modules_passed, total_score
    increment: int = Field(default=1, ge=1)


class AnalyticsEventResponse(BaseModel):
    """Analytics event in response."""

    id: str
    user_id: str
    event_type: str
    event_data: dict
    timestamp: str

    class Config:
        from_attributes = True


class UserMetricsResponse(BaseModel):
    """User metrics response."""

    id: str
    user_id: str
    quiz_attempts: int
    modules_passed: int
    total_score: float
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class DashboardDataResponse(BaseModel):
    """Dashboard data for user."""

    user_id: str
    metrics: Optional[UserMetricsResponse]
    recent_events: List[AnalyticsEventResponse]


# Endpoints
@router.post("/events/{user_id}", response_model=AnalyticsEventResponse, status_code=201)
async def log_event(
    user_id: str,
    request: LogEventRequest,
    db: Session = Depends(get_db)
) -> AnalyticsEventResponse:
    """
    Log an analytics event for a user.

    **Event Types:**
    - `quiz_started` - User starts a quiz
    - `quiz_completed` - User completes and submits a quiz
    - `module_viewed` - User views a training module
    - `scenario_responded` - User responds to a scenario
    - `assessment_completed` - User completes assessment

    **Example Event Data:**
    ```json
    {
        "module_id": "module-1",
        "score": 85,
        "duration_seconds": 300,
        "attempt_number": 1
    }
    ```
    """
    service = AnalyticsService(db)
    event = service.log_event(user_id, request.event_type, request.event_data)

    if not event:
        raise HTTPException(status_code=400, detail="Failed to log event")

    return event


@router.get("/events/{user_id}", response_model=dict)
async def get_user_events(
    user_id: str,
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
) -> dict:
    """
    Get all events for a user with pagination.

    **Query Parameters:**
    - `limit`: Number of results (1-1000, default 100)
    - `offset`: Results offset for pagination (default 0)

    **Response:**
    - `events`: List of analytics events
    - `total`: Total count of events for user
    - `limit`: Requested limit
    - `offset`: Requested offset
    """
    service = AnalyticsService(db)
    events, total = service.get_user_events(user_id, limit, offset)

    return {
        "events": [e.to_dict() for e in events],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.get("/events/{user_id}/type/{event_type}", response_model=List[AnalyticsEventResponse])
async def get_events_by_type(
    user_id: str,
    event_type: str,
    limit: int = Query(100, ge=1, le=1000),
    db: Session = Depends(get_db)
) -> List[AnalyticsEventResponse]:
    """
    Get events of a specific type for a user.

    **Path Parameters:**
    - `event_type`: Type of event to filter (quiz_completed, module_viewed, etc.)

    **Supported Event Types:**
    - `quiz_started`
    - `quiz_completed`
    - `module_viewed`
    - `scenario_responded`
    - `assessment_completed`
    """
    service = AnalyticsService(db)
    events = service.get_events_by_type(user_id, event_type, limit)

    return events


@router.get("/metrics/{user_id}", response_model=UserMetricsResponse)
async def get_user_metrics(
    user_id: str,
    db: Session = Depends(get_db)
) -> UserMetricsResponse:
    """
    Get aggregated metrics for a user.

    Returns user's overall statistics:
    - `quiz_attempts`: Total quiz submissions
    - `modules_passed`: Number of completed modules
    - `total_score`: Aggregate score
    """
    service = AnalyticsService(db)
    metrics = service.get_user_metrics(user_id)

    if not metrics:
        raise HTTPException(status_code=404, detail="User metrics not found")

    return metrics


@router.put("/metrics/{user_id}", response_model=UserMetricsResponse)
async def update_user_metrics(
    user_id: str,
    request: UpdateMetricsRequest,
    db: Session = Depends(get_db)
) -> UserMetricsResponse:
    """
    Update user metrics with new values.

    **Example:**
    ```json
    {
        "quiz_attempts": 5,
        "modules_passed": 3,
        "total_score": 425
    }
    ```

    All fields are optional. Only provided fields will be updated.
    """
    service = AnalyticsService(db)
    updates = {k: v for k, v in request.model_dump().items() if v is not None}

    if not updates:
        raise HTTPException(status_code=400, detail="No metrics to update")

    metrics = service.update_metrics(user_id, updates)

    if not metrics:
        raise HTTPException(status_code=400, detail="Failed to update metrics")

    return metrics


@router.post("/metrics/{user_id}/increment", response_model=UserMetricsResponse)
async def increment_metric(
    user_id: str,
    request: IncrementMetricRequest,
    db: Session = Depends(get_db)
) -> UserMetricsResponse:
    """
    Increment a user metric by a given amount.

    **Example:**
    ```json
    {
        "metric_name": "quiz_attempts",
        "increment": 1
    }
    ```

    **Supported Metrics:**
    - `quiz_attempts` - Increment quiz submission counter
    - `modules_passed` - Increment module completion counter
    - `total_score` - Increment aggregate score
    """
    service = AnalyticsService(db)
    metrics = service.increment_metric(user_id, request.metric_name, request.increment)

    if not metrics:
        raise HTTPException(status_code=400, detail="Failed to increment metric")

    return metrics


@router.get("/modules/{module_id}", response_model=List[AnalyticsEventResponse])
async def get_module_analytics(
    module_id: str,
    limit: int = Query(1000, ge=1, le=10000),
    db: Session = Depends(get_db)
) -> List[AnalyticsEventResponse]:
    """
    Get all analytics events related to a specific module.

    Returns events from all users for the given module.

    **Query Parameters:**
    - `limit`: Maximum results (1-10000, default 1000)
    """
    service = AnalyticsService(db)
    events = service.get_module_analytics(module_id, limit)

    return events


@router.get("/dashboard/{user_id}", response_model=DashboardDataResponse)
async def get_user_dashboard(
    user_id: str,
    db: Session = Depends(get_db)
) -> DashboardDataResponse:
    """
    Get aggregated dashboard data for a user.

    Includes:
    - Current metrics (quiz attempts, modules passed, total score)
    - Recent events (last 10)
    - Module-specific event summaries
    """
    service = AnalyticsService(db)
    data = service.get_dashboard_data(user_id)

    return {
        "user_id": user_id,
        "metrics": data["metrics"],
        "recent_events": data["recent_events"],
    }


@router.get("/", response_model=dict)
async def get_all_analytics(
    limit: int = Query(1000, ge=1, le=10000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
) -> dict:
    """
    Get all analytics events across all users (admin only).

    **Query Parameters:**
    - `limit`: Number of results (1-10000, default 1000)
    - `offset`: Results offset for pagination

    **Security:** Requires admin authentication (recommended)
    """
    service = AnalyticsService(db)
    events, total = service.get_all_analytics(limit, offset)

    return {
        "events": [e.to_dict() for e in events],
        "total": total,
        "limit": limit,
        "offset": offset,
    }
