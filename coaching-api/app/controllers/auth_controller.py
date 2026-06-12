"""Authentication API endpoints."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional, List, Any
from app.database import get_db
from app.services.auth_service import AuthService

router = APIRouter(prefix="/api/auth", tags=["auth"])


# Request/Response Models
class SignupRequest(BaseModel):
    email: str
    full_name: Optional[str] = None
    phone: Optional[str] = None
    user_id: Optional[str] = None  # Supabase auth user ID


class SignupResponse(BaseModel):
    id: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    phone: Optional[str] = None
    role: Optional[str] = "learner"
    created_at: Optional[str] = None

    class Config:
        from_attributes = True


class ProfileRequest(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    role: Optional[str] = None
    persona: Optional[str] = None
    baseline_completed: Optional[bool] = None
    baseline_score: Optional[float] = None
    endline_completed: Optional[bool] = None
    endline_score: Optional[float] = None
    weak_modules: Optional[List[str]] = None
    baseline_attempt_count: Optional[int] = None
    endline_attempt_count: Optional[int] = None
    region: Optional[str] = None
    sub_region: Optional[str] = None
    school_id: Optional[str] = None
    teacher_ids: Optional[List[str]] = None
    qualifications: Optional[Any] = None
    experiences: Optional[Any] = None


class ProfileResponse(BaseModel):
    id: str
    user_id: Optional[str] = None
    full_name: Optional[str] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    role: Optional[str] = "learner"
    is_active: Optional[bool] = True
    persona: Optional[str] = None
    baseline_completed: Optional[bool] = False
    baseline_score: Optional[float] = None
    endline_completed: Optional[bool] = False
    endline_score: Optional[float] = None
    weak_modules: Optional[List[str]] = None
    baseline_attempt_count: Optional[int] = 0
    endline_attempt_count: Optional[int] = 0
    region: Optional[str] = None
    sub_region: Optional[str] = None
    school_id: Optional[str] = None
    teacher_ids: Optional[List[str]] = None
    qualifications: Optional[Any] = None
    experiences: Optional[Any] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

    class Config:
        from_attributes = True


class UserResponse(BaseModel):
    id: str
    email: Optional[str] = None
    email_confirmed_at: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None
    profile: Optional[ProfileResponse] = None

    class Config:
        from_attributes = True


class SessionResponse(BaseModel):
    user: Optional[UserResponse] = None
    authenticated: bool
    message: str


class CertificateRequest(BaseModel):
    user_id: str
    certificate_id: str
    persona: Optional[str] = None


class CertificateResponse(BaseModel):
    id: str
    user_id: str
    certificate_id: str
    persona: Optional[str]
    issued_at: Optional[str]

    class Config:
        from_attributes = True


# Endpoints
@router.post("/signup", response_model=SignupResponse, status_code=201)
async def signup(request: SignupRequest, db: Session = Depends(get_db)):
    service = AuthService(db)
    if service.user_exists(request.email):
        raise HTTPException(status_code=409, detail="User with this email already exists")

    import uuid
    user_id = request.user_id or str(uuid.uuid4())
    user = service.create_user(user_id, request.email)
    if not user:
        raise HTTPException(status_code=500, detail="Failed to create user")

    profile = service.create_profile(user_id, full_name=request.full_name, phone=request.phone)
    if not profile:
        service.delete_user(user_id)
        raise HTTPException(status_code=400, detail="Invalid profile data (duplicate phone?)")

    return {
        "id": user.id,
        "email": user.email,
        "full_name": profile.full_name,
        "phone": profile.phone,
        "role": profile.role,
        "created_at": user.created_at.isoformat(),
    }


@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: str, db: Session = Depends(get_db)):
    service = AuthService(db)
    user = service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user.to_dict()


@router.get("/users/email/{email}", response_model=UserResponse)
async def get_user_by_email(email: str, db: Session = Depends(get_db)):
    service = AuthService(db)
    user = service.get_user_by_email(email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user.to_dict()


@router.get("/profile/{user_id}", response_model=ProfileResponse)
async def get_profile(user_id: str, db: Session = Depends(get_db)):
    service = AuthService(db)
    profile = service.get_profile(user_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile.to_dict()


@router.put("/profile/{user_id}", response_model=ProfileResponse)
async def update_profile(user_id: str, request: ProfileRequest, db: Session = Depends(get_db)):
    service = AuthService(db)
    user = service.get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = {k: v for k, v in request.dict().items() if v is not None}
    profile = service.update_profile(user_id, **update_data)
    if not profile:
        raise HTTPException(status_code=400, detail="Failed to update profile (duplicate phone?)")
    return profile.to_dict()


@router.get("/roles/{user_id}")
async def get_roles(user_id: str, db: Session = Depends(get_db)):
    service = AuthService(db)
    roles = service.get_user_roles(user_id)
    return {"roles": roles}


@router.get("/certificate/{user_id}", response_model=CertificateResponse)
async def get_certificate(user_id: str, db: Session = Depends(get_db)):
    service = AuthService(db)
    cert = service.get_certificate(user_id)
    if not cert:
        raise HTTPException(status_code=404, detail="Certificate not found")
    return cert.to_dict()


@router.post("/certificate", response_model=CertificateResponse)
async def upsert_certificate(request: CertificateRequest, db: Session = Depends(get_db)):
    service = AuthService(db)
    cert = service.upsert_certificate(request.user_id, request.certificate_id, request.persona)
    if not cert:
        raise HTTPException(status_code=500, detail="Failed to create certificate")
    return cert.to_dict()


@router.post("/email-confirm/{user_id}")
async def confirm_email(user_id: str, db: Session = Depends(get_db)):
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
async def delete_user(user_id: str, db: Session = Depends(get_db)):
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
    service = AuthService(db)
    users, total = service.list_users(limit=limit, offset=offset)
    return {
        "users": [u.to_dict() for u in users],
        "total": total,
        "limit": limit,
        "offset": offset,
    }


@router.post("/session", response_model=SessionResponse)
async def get_session(user_id: Optional[str] = None, db: Session = Depends(get_db)):
    if not user_id:
        return {"user": None, "authenticated": False, "message": "Not authenticated"}
    service = AuthService(db)
    user = service.get_user_by_id(user_id)
    if not user:
        return {"user": None, "authenticated": False, "message": "User not found"}
    return {"user": user.to_dict(), "authenticated": True, "message": "User authenticated"}


@router.get("/health")
async def health_check():
    return {"status": "healthy", "service": "auth"}
