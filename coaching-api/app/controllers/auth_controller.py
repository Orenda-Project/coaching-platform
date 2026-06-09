"""Authentication API endpoints."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional
from app.database import get_db
from app.services.auth_service import AuthService

router = APIRouter(prefix="/api/auth", tags=["auth"])


# Request/Response Models
class SignupRequest(BaseModel):
    """User signup request."""

    email: str
    full_name: Optional[str] = None
    phone: Optional[str] = None


class SignupResponse(BaseModel):
    """Signup response with user data."""

    id: str
    email: str
    full_name: Optional[str]
    phone: Optional[str]
    role: str
    created_at: str

    class Config:
        from_attributes = True


class ProfileRequest(BaseModel):
    """Profile update request."""

    full_name: Optional[str] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    role: Optional[str] = None


class ProfileResponse(BaseModel):
    """User profile response."""

    id: str
    user_id: str
    full_name: Optional[str]
    phone: Optional[str]
    avatar_url: Optional[str]
    bio: Optional[str]
    role: str
    is_active: bool
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


class UserResponse(BaseModel):
    """User response."""

    id: str
    email: str
    email_confirmed_at: Optional[str]
    created_at: str
    updated_at: str
    profile: Optional[ProfileResponse] = None

    class Config:
        from_attributes = True


class SessionResponse(BaseModel):
    """Session/auth status response."""

    user: Optional[UserResponse] = None
    authenticated: bool
    message: str


# Endpoints
@router.post("/signup", response_model=SignupResponse, status_code=201)
async def signup(
    request: SignupRequest,
    db: Session = Depends(get_db)
):
    """
    Create a new user account.

    This endpoint creates both a user record and a profile.
    In a real implementation, Supabase auth.signUp() is called first,
    then this endpoint is called with the user_id from Supabase.

    Args:
        request: Signup request with email, full_name, phone

    Returns:
        Created user with profile
    """
    service = AuthService(db)

    # Check if user already exists
    if service.user_exists(request.email):
        raise HTTPException(
            status_code=409,
            detail="User with this email already exists"
        )

    # In production, user_id comes from Supabase auth.signUp()
    # For demo purposes, we generate a placeholder
    import uuid
    user_id = str(uuid.uuid4())

    # Create user
    user = service.create_user(user_id, request.email)
    if not user:
        raise HTTPException(
            status_code=500,
            detail="Failed to create user"
        )

    # Create profile
    profile = service.create_profile(
        user_id,
        full_name=request.full_name,
        phone=request.phone
    )
    if not profile:
        # Clean up user if profile creation fails
        service.delete_user(user_id)
        raise HTTPException(
            status_code=400,
            detail="Invalid profile data (duplicate phone?)"
        )

    return {
        "id": user.id,
        "email": user.email,
        "full_name": profile.full_name,
        "phone": profile.phone,
        "role": profile.role,
        "created_at": user.created_at.isoformat(),
    }


@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    db: Session = Depends(get_db)
):
    """Get user by ID."""
    service = AuthService(db)
    user = service.get_user_by_id(user_id)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return user.to_dict()


@router.get("/users/email/{email}", response_model=UserResponse)
async def get_user_by_email(
    email: str,
    db: Session = Depends(get_db)
):
    """Get user by email."""
    service = AuthService(db)
    user = service.get_user_by_email(email)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return user.to_dict()


@router.get("/profile/{user_id}", response_model=ProfileResponse)
async def get_profile(
    user_id: str,
    db: Session = Depends(get_db)
):
    """Get user profile."""
    service = AuthService(db)
    profile = service.get_profile(user_id)

    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    return profile.to_dict()


@router.put("/profile/{user_id}", response_model=ProfileResponse)
async def update_profile(
    user_id: str,
    request: ProfileRequest,
    db: Session = Depends(get_db)
):
    """
    Update user profile.

    Args:
        user_id: User ID
        request: Profile update data

    Returns:
        Updated profile
    """
    service = AuthService(db)

    # Verify user exists
    user = service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Update profile
    update_data = {k: v for k, v in request.dict().items() if v is not None}
    profile = service.update_profile(user_id, **update_data)

    if not profile:
        raise HTTPException(
            status_code=400,
            detail="Failed to update profile (duplicate phone?)"
        )

    return profile.to_dict()


@router.post("/email-confirm/{user_id}")
async def confirm_email(
    user_id: str,
    db: Session = Depends(get_db)
):
    """Confirm user email address."""
    service = AuthService(db)
    user = service.confirm_email(user_id)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "message": "Email confirmed",
        "user_id": user.id,
        "email": user.email,
        "email_confirmed_at": user.email_confirmed_at.isoformat() if user.email_confirmed_at else None,
    }


@router.delete("/users/{user_id}", status_code=204)
async def delete_user(
    user_id: str,
    db: Session = Depends(get_db)
):
    """Delete user and profile."""
    service = AuthService(db)
    success = service.delete_user(user_id)

    if not success:
        raise HTTPException(status_code=404, detail="User not found")

    return None


@router.get("/users", response_model=dict)
async def list_users(
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """
    List all users with pagination.

    Args:
        limit: Number of results (max 1000)
        offset: Results offset

    Returns:
        Users list with total count
    """
    service = AuthService(db)
    users, total = service.list_users(limit=limit, offset=offset)

    return {
        "users": [u.to_dict() for u in users],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.post("/session", response_model=SessionResponse)
async def get_session(
    user_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Get session information.

    In production, this validates the JWT token from the request.
    For now, it checks if a user_id is provided and valid.

    Args:
        user_id: User ID to check session for

    Returns:
        Session status with user data if authenticated
    """
    if not user_id:
        return {
            "user": None,
            "authenticated": False,
            "message": "Not authenticated",
        }

    service = AuthService(db)
    user = service.get_user_by_id(user_id)

    if not user:
        return {
            "user": None,
            "authenticated": False,
            "message": "User not found",
        }

    return {
        "user": user.to_dict(),
        "authenticated": True,
        "message": "User authenticated",
    }


@router.get("/health")
async def health_check():
    """Health check for auth service."""
    return {
        "status": "healthy",
        "service": "auth",
    }
