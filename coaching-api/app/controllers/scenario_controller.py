"""Scenario API endpoints."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional, List
from app.database import get_db
from app.services.scenario_service import ScenarioService

router = APIRouter(prefix="/api/scenarios", tags=["scenarios"])


# Request/Response Models
class SaveResponseRequest(BaseModel):
    """Request to save a scenario response."""

    selected_option_id: str

    class Config:
        json_schema_extra = {
            "example": {
                "selected_option_id": "option-1"
            }
        }


class UpdateResponseRequest(BaseModel):
    """Request to update a scenario response."""

    selected_option_id: str


class ScenarioOptionResponse(BaseModel):
    """Scenario option in response."""

    id: str
    scenario_id: str
    option_text: str
    feedback: Optional[str]
    is_optimal: bool
    order_number: int
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class ScenarioResponse(BaseModel):
    """Scenario response model."""

    id: str
    unit_id: str
    title: str
    description: Optional[str]
    situation: str
    order_number: int
    created_at: str
    updated_at: str
    options: List[ScenarioOptionResponse]

    class Config:
        from_attributes = True


class UserScenarioResponse(BaseModel):
    """User's response to a scenario."""

    id: str
    user_id: str
    scenario_id: str
    selected_option_id: str
    timestamp: str

    class Config:
        from_attributes = True


class ScenarioStatsResponse(BaseModel):
    """Scenario completion stats for a user."""

    unit_id: str
    user_id: str
    total_scenarios: int
    completed_scenarios: int
    optimal_responses: int
    percentage_optimal: float


# Endpoints
@router.get("/{scenario_id}", response_model=ScenarioResponse)
async def get_scenario(
    scenario_id: str,
    db: Session = Depends(get_db)
) -> ScenarioResponse:
    """
    Get a specific scenario with all response options.

    **Path Parameters:**
    - `scenario_id`: Unique scenario identifier

    **Response Includes:**
    - Scenario context and situation
    - All available response options
    - Metadata about each option (optimal status, feedback, order)
    """
    service = ScenarioService(db)
    scenario = service.get_scenario(scenario_id)

    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")

    return scenario


@router.get("/unit/{unit_id}", response_model=List[ScenarioResponse])
async def get_unit_scenarios(
    unit_id: str,
    db: Session = Depends(get_db)
) -> List[ScenarioResponse]:
    """
    Get all scenarios for a training unit/module.

    Returns scenarios ordered by `order_number` for consistent sequencing.

    **Path Parameters:**
    - `unit_id`: Training unit/module identifier

    **Ordering:**
    Scenarios are returned in ascending order by `order_number`.
    """
    service = ScenarioService(db)
    scenarios = service.get_scenarios(unit_id)

    return scenarios


@router.post("/{scenario_id}/respond/{user_id}", response_model=UserScenarioResponse, status_code=201)
async def respond_to_scenario(
    scenario_id: str,
    user_id: str,
    request: SaveResponseRequest,
    db: Session = Depends(get_db)
) -> UserScenarioResponse:
    """
    Record a user's response to a scenario.

    A user can respond to the same scenario multiple times.

    **Path Parameters:**
    - `scenario_id`: The scenario ID
    - `user_id`: The responding user ID

    **Request Body:**
    ```json
    {
        "selected_option_id": "option-1"
    }
    ```

    **Response:**
    Returns the saved response with timestamp.
    """
    service = ScenarioService(db)
    response = service.save_response(user_id, scenario_id, request.selected_option_id)

    if not response:
        raise HTTPException(status_code=400, detail="Failed to save response")

    return response


@router.get("/{scenario_id}/user/{user_id}", response_model=UserScenarioResponse)
async def get_user_response_for_scenario(
    scenario_id: str,
    user_id: str,
    db: Session = Depends(get_db)
) -> UserScenarioResponse:
    """
    Get a user's response to a specific scenario.

    Returns the most recent response if the user has responded multiple times.

    **Path Parameters:**
    - `scenario_id`: The scenario ID
    - `user_id`: The user ID
    """
    service = ScenarioService(db)
    response = service.get_user_response_for_scenario(user_id, scenario_id)

    if not response:
        raise HTTPException(status_code=404, detail="User has not responded to this scenario")

    return response


@router.put("/{scenario_id}/respond/{response_id}", response_model=UserScenarioResponse)
async def update_response(
    response_id: str,
    request: UpdateResponseRequest,
    db: Session = Depends(get_db)
) -> UserScenarioResponse:
    """
    Update a user's response to a scenario.

    **Path Parameters:**
    - `response_id`: The response ID to update

    **Request Body:**
    ```json
    {
        "selected_option_id": "option-2"
    }
    ```
    """
    service = ScenarioService(db)
    response = service.update_response(response_id, request.selected_option_id)

    if not response:
        raise HTTPException(status_code=404, detail="Response not found")

    return response


@router.get("/user/{user_id}/responses", response_model=dict)
async def get_user_responses(
    user_id: str,
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
) -> dict:
    """
    Get all scenario responses by a user with pagination.

    **Path Parameters:**
    - `user_id`: The user ID

    **Query Parameters:**
    - `limit`: Number of results (1-1000, default 100)
    - `offset`: Results offset for pagination (default 0)

    **Response:**
    - `responses`: List of user responses
    - `total`: Total count
    - `limit`: Requested limit
    - `offset`: Requested offset
    """
    service = ScenarioService(db)
    responses, total = service.get_user_responses_paginated(user_id, limit, offset)

    return {
        "responses": [r.to_dict() for r in responses],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.get("/{scenario_id}/responses", response_model=dict)
async def get_scenario_responses(
    scenario_id: str,
    limit: int = Query(1000, ge=1, le=10000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
) -> dict:
    """
    Get all responses to a specific scenario (from all users).

    Useful for analyzing how users collectively respond to scenarios.

    **Path Parameters:**
    - `scenario_id`: The scenario ID

    **Query Parameters:**
    - `limit`: Maximum results (1-10000, default 1000)
    - `offset`: Results offset for pagination
    """
    service = ScenarioService(db)
    responses = service.get_scenario_responses(scenario_id)

    # Manual pagination
    paginated = responses[offset:offset + limit]

    return {
        "responses": [r.to_dict() for r in paginated],
        "total": len(responses),
        "limit": limit,
        "offset": offset,
    }


@router.get("/option/{option_id}/feedback", response_model=dict)
async def get_option_feedback(
    option_id: str,
    db: Session = Depends(get_db)
) -> dict:
    """
    Get feedback for a specific scenario option.

    **Path Parameters:**
    - `option_id`: The option ID

    **Response:**
    - `feedback`: Feedback text for the option
    - `is_optimal`: Whether this is the optimal response
    """
    service = ScenarioService(db)
    option = service.get_option(option_id)

    if not option:
        raise HTTPException(status_code=404, detail="Option not found")

    return {
        "option_id": option_id,
        "feedback": option.feedback,
        "is_optimal": option.is_optimal,
    }


@router.get("/{scenario_id}/optimal", response_model=ScenarioOptionResponse)
async def get_optimal_response(
    scenario_id: str,
    db: Session = Depends(get_db)
) -> ScenarioOptionResponse:
    """
    Get the optimal/recommended response for a scenario.

    **Path Parameters:**
    - `scenario_id`: The scenario ID

    **Response:**
    Returns the option marked as `is_optimal=true`.
    """
    service = ScenarioService(db)
    option = service.get_optimal_option(scenario_id)

    if not option:
        raise HTTPException(status_code=404, detail="No optimal option defined for this scenario")

    return option


@router.get("/unit/{unit_id}/stats/{user_id}", response_model=ScenarioStatsResponse)
async def get_user_scenario_stats(
    unit_id: str,
    user_id: str,
    db: Session = Depends(get_db)
) -> ScenarioStatsResponse:
    """
    Get scenario completion statistics for a user in a unit.

    **Path Parameters:**
    - `unit_id`: The training unit/module ID
    - `user_id`: The user ID

    **Response Includes:**
    - `total_scenarios`: Total scenarios in unit
    - `completed_scenarios`: Scenarios responded to by user
    - `optimal_responses`: Responses that selected optimal option
    - `percentage_optimal`: Percentage of responses that were optimal
    """
    service = ScenarioService(db)
    stats = service.get_user_scenario_stats(user_id, unit_id)

    return stats
