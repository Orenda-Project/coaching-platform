# API Migration Implementation Plan

**Project:** Supabase → PostgreSQL REST API Migration  
**Status:** Planning Phase  
**Timeline:** 5 weeks  
**Team:** 1-2 engineers  
**Start Date:** Week of 2026-06-15  
**Target Completion:** Week of 2026-07-20  

---

## Overview

Phased migration of 50+ frontend files from direct Supabase queries to REST API calls via FastAPI backend. The goal is to:

1. ✅ Maintain zero-downtime (backward compatibility during migration)
2. ✅ Preserve all existing functionality
3. ✅ Improve performance, testability, and maintainability
4. ✅ Establish clean API contracts for future frontend/backend separation

**Key Constraint:** Quiz API (Domain 8) is already complete. We build around it.

---

## Phase Architecture

### Phase Dependency Graph

```
Phase 1: Auth & Users
    ↓
Phase 2: Observations & Coaching (depends on Auth)
    ↓ 
Phase 3: Training & Content (can run parallel with Phase 2)
    ↓
Phase 4: Smart Schedule (can run parallel)
    ↓
Phase 5: Final Cleanup & Testing
```

**Sequential:** Phase 1 must complete before other phases  
**Parallel:** Phases 2-4 can run in parallel once Phase 1 complete  
**Optional Parallel:** Phase 3 & 4 don't depend on Phase 2

---

## Phase 1: Auth & Users (1 week)

**Start:** Week of 2026-06-15  
**End:** Week of 2026-06-22  
**Priority:** CRITICAL (dependency for all other phases)  
**Files:** 3  
**Effort:** 1 engineer, 5 days

### Scope: Auth Domain

**Frontend Files to Refactor:**
1. src/contexts/AuthContext.tsx
2. src/hooks/useAdminRole.ts
3. src/hooks/useCoachRole.ts

**Backend (FastAPI) Deliverables:**
1. `/api/users/profile` (GET) — Fetch current user profile
2. `/api/users/profile` (PUT) — Update profile
3. `/api/users/me/role` (GET) — Get current user role
4. `/api/users/{user_id}` (GET) — Fetch user by ID (admin only)
5. User authentication middleware (JWT validation)

### Detailed Tasks

#### Backend Tasks (Days 1-2)

**Day 1: Setup & Core Models**
```python
# File: app/models/user.py (NEW)
class User(Base):
    __tablename__ = "profiles"
    id = Column(UUID, primary_key=True)
    email = Column(String, unique=True)
    phone = Column(String, unique=True)
    full_name = Column(String)
    role = Column(String, default="teacher")
    region = Column(String)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())
```

**Day 1: User Service**
```python
# File: app/services/user_service.py (NEW)
class UserService:
    def get_profile(self, user_id: str) -> User:
        return db.query(User).filter(User.id == user_id).first()
    
    def update_profile(self, user_id: str, data: dict) -> User:
        user = self.get_profile(user_id)
        for key, value in data.items():
            setattr(user, key, value)
        db.commit()
        return user
    
    def get_user_role(self, user_id: str) -> str:
        user = self.get_profile(user_id)
        return user.role if user else None
```

**Day 2: User Controller & Auth Middleware**
```python
# File: app/controllers/user_controller.py (NEW)
router = APIRouter(prefix="/api/users", tags=["users"])

@router.get("/profile")
async def get_profile(user_id: str = Depends(get_current_user)):
    service = UserService(db)
    user = service.get_profile(user_id)
    return {"status": "success", "data": user}

@router.put("/profile")
async def update_profile(data: UpdateProfileRequest, user_id: str = Depends(get_current_user)):
    service = UserService(db)
    user = service.update_profile(user_id, data.dict())
    return {"status": "success", "data": user}

@router.get("/me/role")
async def get_role(user_id: str = Depends(get_current_user)):
    service = UserService(db)
    role = service.get_user_role(user_id)
    return {"status": "success", "data": {"role": role}}
```

**Day 2: JWT Middleware**
```python
# File: app/middleware/auth.py (NEW)
from jose import jwt
from app.config import settings

def get_current_user(token: str = Depends(HTTPBearer())) -> str:
    try:
        payload = jwt.decode(token.credentials, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token")
        return user_id
    except JWTError:
        raise HTTPException(status_code=401, detail="Unauthorized")
```

#### Frontend Tasks (Days 3-5)

**Day 3: Create useProfile Hook**
```typescript
// File: src/hooks/useProfile.ts (NEW)
import { userApiClient } from "@/lib/userApiClient";

export function useProfile() {
  const [profile, setProfile] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchProfile = useCallback(async () => {
    try {
      setLoading(true);
      const data = await userApiClient.getProfile();
      setProfile(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  const updateProfile = useCallback(async (updates) => {
    try {
      const updated = await userApiClient.updateProfile(updates);
      setProfile(updated);
      return updated;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  }, []);

  useEffect(() => {
    fetchProfile();
  }, []);

  return { profile, loading, error, updateProfile, refetch: fetchProfile };
}
```

**Day 3: Create userApiClient**
```typescript
// File: src/lib/userApiClient.ts (NEW)
export class UserApiClient {
  private apiUrl: string;

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  async getProfile(): Promise<UserProfile> {
    const response = await this.fetchWithAuth(`${this.apiUrl}/api/users/profile`);
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    return data.data;
  }

  async updateProfile(updates: Partial<UserProfile>): Promise<UserProfile> {
    const response = await this.fetchWithAuth(`${this.apiUrl}/api/users/profile`, {
      method: "PUT",
      body: JSON.stringify(updates),
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    return data.data;
  }

  async getUserRole(): Promise<{ role: string }> {
    const response = await this.fetchWithAuth(`${this.apiUrl}/api/users/me/role`);
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    return data.data;
  }

  private async fetchWithAuth(url: string, options?: RequestInit): Promise<Response> {
    const token = await this.getJWT();
    return fetch(url, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}`,
        ...options?.headers,
      },
    });
  }

  private async getJWT(): Promise<string> {
    // Get JWT from Supabase auth session
    const { data } = await supabase.auth.getSession();
    return data.session?.access_token || "";
  }
}

export const userApiClient = new UserApiClient();
```

**Day 4: Refactor AuthContext**
```typescript
// File: src/contexts/AuthContext.tsx (MODIFIED)
import { useProfile } from "@/hooks/useProfile";

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState(null);
  const [user, setUser] = useState(null);
  const { profile, updateProfile, refetch: refetchProfile } = useProfile();
  const [loading, setLoading] = useState(true);

  // Remove direct Supabase .from("profiles") calls
  // Use useProfile hook instead
  
  const signUp = async (email: string, password: string, phone: string, fullName?: string) => {
    // Step 1: Create auth user via Supabase
    const { data: signUpData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: { emailRedirectTo: window.location.origin },
    });

    if (authError) return { error: authError };

    // Step 2: Create profile via API (not RPC anymore)
    if (signUpData.user?.id) {
      try {
        await userApiClient.createProfile({
          user_id: signUpData.user.id,
          phone,
          full_name: fullName || null,
        });
      } catch (err) {
        return { error: err };
      }
    }

    return { error: null };
  };

  return (
    <AuthContext.Provider value={{
      session,
      user,
      profile,
      loading,
      signUp,
      signIn,
      signOut,
      updateProfile,
      refreshProfile: refetchProfile,
    }}>
      {children}
    </AuthContext.Provider>
  );
}
```

**Day 5: Refactor useAdminRole & useCoachRole**
```typescript
// File: src/hooks/useAdminRole.ts (MODIFIED)
import { userApiClient } from "@/lib/userApiClient";

export function useAdminRole() {
  const [role, setRole] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchRole = async () => {
      try {
        const data = await userApiClient.getUserRole();
        setRole(data.role);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };
    fetchRole();
  }, []);

  return { role, loading, error };
}
```

### Testing for Phase 1

**Backend Unit Tests:**
```python
# File: tests/test_user_service.py
def test_get_profile():
    service = UserService(db)
    user = service.get_profile("test-user-id")
    assert user.id == "test-user-id"
    assert user.email == "test@example.com"

def test_update_profile():
    service = UserService(db)
    updated = service.update_profile("test-user-id", {"phone": "1234567"})
    assert updated.phone == "1234567"
```

**Frontend Unit Tests:**
```typescript
// File: tests/unit/userApiClient.test.ts
describe("UserApiClient", () => {
  it("should fetch profile", async () => {
    const client = new UserApiClient("http://localhost:8000");
    const profile = await client.getProfile();
    expect(profile).toHaveProperty("id");
  });

  it("should update profile", async () => {
    const client = new UserApiClient("http://localhost:8000");
    const updated = await client.updateProfile({ phone: "1234567" });
    expect(updated.phone).toBe("1234567");
  });
});
```

**Integration Tests:**
```typescript
// File: tests/integration/auth.test.ts
describe("Auth Flow with API", () => {
  it("should signup and fetch profile via API", async () => {
    // 1. Signup via Supabase auth
    const signupResult = await auth.signUp(...);
    
    // 2. Fetch profile via API
    const profile = await userApiClient.getProfile();
    
    // 3. Verify profile exists
    expect(profile.id).toBe(signupResult.user.id);
  });
});
```

**E2E Test:**
```typescript
// File: tests/e2e/auth.e2e.test.ts
describe("Auth E2E", () => {
  it("should complete signup → login → profile load", async () => {
    // Step 1: Signup
    cy.visit("/signup");
    cy.get("[data-testid=email]").type("test@example.com");
    cy.get("[data-testid=password]").type("password123");
    cy.get("[data-testid=phone]").type("1234567890");
    cy.get("[data-testid=submit]").click();

    // Step 2: Check profile loaded
    cy.get("[data-testid=profile-name]").should("be.visible");
  });
});
```

### Acceptance Criteria for Phase 1

- [ ] All AuthContext Supabase calls replaced with API calls
- [ ] useAdminRole and useCoachRole use API instead of Supabase
- [ ] All unit tests pass (backend + frontend)
- [ ] All integration tests pass
- [ ] E2E auth flow works end-to-end
- [ ] No functionality broken (backward compatible)
- [ ] JWT token validation works
- [ ] Error handling consistent with API spec

### Rollback Plan (Phase 1)

If Phase 1 breaks Auth:
1. Revert AuthContext.tsx to use Supabase directly
2. Keep API endpoints as-is (no harm)
3. Debug Auth issues in isolation
4. Retry when root cause resolved

---

## Phase 2: Observations & Coaching (2 weeks, can start when Phase 1 done)

**Start:** Week of 2026-06-22  
**End:** Week of 2026-07-06  
**Priority:** HIGHEST (14 files, core coaching feature)  
**Files:** 14  
**Effort:** 2 engineers, 10 days

### Scope: Observations Domain

**Frontend Files to Refactor:**
1. src/components/observation/CoachingHubTab.tsx
2. src/components/observation/HotsRubricForm.tsx
3. src/components/observation/FicoRubricForm.tsx
4. src/components/observation/DebriefForm.tsx
5. src/components/observation/SmartScheduleTab.tsx
6. src/components/observation/DraftObservationsTab.tsx
7. src/components/observation/NeoAnalysis.tsx
8. src/components/observation/ScheduleDialog.tsx
9. src/components/observation/QuickObservationPanel.tsx
10. src/components/observation/ReportIssueButton.tsx
11. src/data/observations.ts
12. (3 additional observation components)

**Backend (FastAPI) Deliverables:**
1. `/api/observations` (GET) — List observations
2. `/api/observations` (POST) — Create observation
3. `/api/observations/{id}` (GET) — Get single observation
4. `/api/observations/{id}/status` (PATCH) — Update status
5. `/api/observations/{id}/rubric/hots` (PATCH) — Update HOTS rubric
6. `/api/observations/{id}/rubric/fico` (PATCH) — Update FICO rubric
7. `/api/observations/{id}/debrief` (PATCH) — Update debrief notes
8. `/api/observations/{id}` (DELETE) — Delete observation

### Detailed Tasks (2 Engineers, Parallel)

**Engineer 1: Backend (Days 1-4)**

**Day 1-2: Models & Service**
```python
# File: app/models/observation.py (NEW)
class CotObservation(Base):
    __tablename__ = "cot_observations"
    id = Column(UUID, primary_key=True)
    observer_id = Column(UUID, ForeignKey("profiles.id"))
    teacher_id = Column(UUID, ForeignKey("profiles.id"))
    school = Column(String)
    grade = Column(String)
    status = Column(String, default="Draft")  # Draft, Submitted
    hots_rubric = Column(JSON)
    fico_rubric = Column(JSON)
    hots_notes = Column(Text)
    fico_notes = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())

# File: app/services/observation_service.py (NEW)
class ObservationService:
    def list_observations(self, user_id: str, role: str, skip: int, limit: int):
        query = db.query(CotObservation)
        if role != "super_admin":
            query = query.filter(CotObservation.observer_id == user_id)
        return query.offset(skip).limit(limit).all()
    
    def get_observation(self, obs_id: str, user_id: str) -> CotObservation:
        obs = db.query(CotObservation).filter(CotObservation.id == obs_id).first()
        if not obs:
            raise HTTPException(status_code=404, detail="Not found")
        if obs.observer_id != user_id and obs.teacher_id != user_id:
            raise HTTPException(status_code=403, detail="Forbidden")
        return obs
    
    def create_observation(self, user_id: str, data: dict) -> CotObservation:
        obs = CotObservation(
            observer_id=user_id,
            teacher_id=data["teacher_id"],
            school=data["school"],
            grade=data["grade"],
        )
        db.add(obs)
        db.commit()
        return obs
    
    def update_hots_rubric(self, obs_id: str, rubric: dict) -> CotObservation:
        obs = db.query(CotObservation).filter(CotObservation.id == obs_id).first()
        obs.hots_rubric = rubric
        db.commit()
        return obs
    
    def delete_observation(self, obs_id: str):
        obs = db.query(CotObservation).filter(CotObservation.id == obs_id).first()
        if obs.status != "Draft":
            raise HTTPException(status_code=400, detail="Cannot delete submitted observation")
        db.delete(obs)
        db.commit()
```

**Day 3-4: Controller & Router**
```python
# File: app/controllers/observation_controller.py (NEW)
router = APIRouter(prefix="/api/observations", tags=["observations"])

@router.get("")
async def list_observations(
    skip: int = 0,
    limit: int = 20,
    status: str = None,
    user_id: str = Depends(get_current_user),
    role: str = Depends(get_current_role),
):
    service = ObservationService(db)
    obs = service.list_observations(user_id, role, skip, limit)
    return {
        "status": "success",
        "data": {
            "observations": obs,
            "total_count": len(obs),
            "skip": skip,
            "limit": limit,
        }
    }

@router.post("")
async def create_observation(data: CreateObservationRequest, user_id: str = Depends(get_current_user)):
    service = ObservationService(db)
    obs = service.create_observation(user_id, data.dict())
    return {"status": "success", "data": obs}

@router.get("/{observation_id}")
async def get_observation(observation_id: str, user_id: str = Depends(get_current_user)):
    service = ObservationService(db)
    obs = service.get_observation(observation_id, user_id)
    return {"status": "success", "data": obs}

@router.patch("/{observation_id}/rubric/hots")
async def update_hots_rubric(observation_id: str, rubric: dict, user_id: str = Depends(get_current_user)):
    service = ObservationService(db)
    obs = service.update_hots_rubric(observation_id, rubric)
    return {"status": "success", "data": obs}

@router.delete("/{observation_id}")
async def delete_observation(observation_id: str, user_id: str = Depends(get_current_user)):
    service = ObservationService(db)
    service.delete_observation(observation_id)
    return {"status": "success"}
```

**Engineer 2: Frontend (Days 1-4)**

**Day 1-2: Create observationApiClient**
```typescript
// File: src/lib/observationApiClient.ts (NEW)
export class ObservationApiClient {
  private apiUrl: string;

  constructor(apiUrl?: string) {
    this.apiUrl = apiUrl || import.meta.env.VITE_API_URL || "http://localhost:8000";
  }

  async listObservations(skip = 0, limit = 20, filters?: object) {
    const params = new URLSearchParams({ skip, limit, ...filters });
    const response = await this.fetchWithAuth(`${this.apiUrl}/api/observations?${params}`);
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    return data.data;
  }

  async getObservation(observationId: string) {
    const response = await this.fetchWithAuth(`${this.apiUrl}/api/observations/${observationId}`);
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    return data.data;
  }

  async createObservation(observation: object) {
    const response = await this.fetchWithAuth(`${this.apiUrl}/api/observations`, {
      method: "POST",
      body: JSON.stringify(observation),
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    return data.data;
  }

  async updateHotsRubric(observationId: string, rubric: object) {
    const response = await this.fetchWithAuth(
      `${this.apiUrl}/api/observations/${observationId}/rubric/hots`,
      {
        method: "PATCH",
        body: JSON.stringify(rubric),
      }
    );
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    return data.data;
  }

  async deleteObservation(observationId: string) {
    const response = await this.fetchWithAuth(
      `${this.apiUrl}/api/observations/${observationId}`,
      { method: "DELETE" }
    );
    if (!response.ok) {
      const data = await response.json();
      throw new Error(data.message);
    }
    return { status: "success" };
  }

  private async fetchWithAuth(url: string, options?: RequestInit): Promise<Response> {
    const token = await this.getJWT();
    return fetch(url, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}`,
        ...options?.headers,
      },
    });
  }

  private async getJWT(): Promise<string> {
    const { data } = await supabase.auth.getSession();
    return data.session?.access_token || "";
  }
}

export const observationApiClient = new ObservationApiClient();
```

**Day 2-3: Create useObservations Hook**
```typescript
// File: src/hooks/useObservations.ts (NEW)
export function useObservations() {
  const [observations, setObservations] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const list = useCallback(async (skip = 0, limit = 20, filters?: object) => {
    setLoading(true);
    setError(null);
    try {
      const data = await observationApiClient.listObservations(skip, limit, filters);
      setObservations(data.observations);
      return data;
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, []);

  const get = useCallback(async (id: string) => {
    try {
      return await observationApiClient.getObservation(id);
    } catch (err) {
      setError(err.message);
    }
  }, []);

  const create = useCallback(async (obs: object) => {
    try {
      const created = await observationApiClient.createObservation(obs);
      setObservations([...observations, created]);
      return created;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  }, [observations]);

  const updateHotsRubric = useCallback(async (id: string, rubric: object) => {
    try {
      const updated = await observationApiClient.updateHotsRubric(id, rubric);
      const newObs = observations.map(o => o.id === id ? updated : o);
      setObservations(newObs);
      return updated;
    } catch (err) {
      setError(err.message);
      throw err;
    }
  }, [observations]);

  const delete_ = useCallback(async (id: string) => {
    try {
      await observationApiClient.deleteObservation(id);
      setObservations(observations.filter(o => o.id !== id));
    } catch (err) {
      setError(err.message);
      throw err;
    }
  }, [observations]);

  return {
    observations,
    loading,
    error,
    list,
    get,
    create,
    updateHotsRubric,
    delete: delete_,
  };
}
```

**Day 3-4: Refactor Components (in parallel)**

Replace `.from('cot_observations')` calls in:
- CoachingHubTab.tsx
- HotsRubricForm.tsx
- FicoRubricForm.tsx
- etc.

Example:
```typescript
// Before: src/components/observation/CoachingHubTab.tsx
const { error } = await (supabase as any)
  .from('cot_observations')
  .delete()
  .eq('id', id);

// After:
const { delete: deleteObs } = useObservations();
await deleteObs(id);
```

### Testing for Phase 2

Similar structure to Phase 1:
- Unit tests for observationApiClient
- Integration tests for observation flow
- E2E tests for create → view → edit → delete observation

### Acceptance Criteria for Phase 2

- [ ] All 14 observation components refactored
- [ ] All Supabase `.from('cot_observations')` calls replaced
- [ ] CRUD operations work via API
- [ ] HOTS/FICO/debrief updates work
- [ ] Delete observation works (with validation)
- [ ] Unit + integration + E2E tests pass
- [ ] Performance no worse than Supabase (likely better)
- [ ] Error handling matches API spec

---

## Phase 3: Training & Content (1 week, can parallel Phase 2)

**Start:** Week of 2026-06-29  
**End:** Week of 2026-07-06  
**Priority:** MEDIUM  
**Files:** 2  
**Effort:** 1 engineer, 3-4 days

**Scope:**
1. src/components/training/TrainingContentViewer.tsx
2. src/lib/seedModule*.ts (migrate to seed API)

**Backend:** Create `/api/trainings/{trainingId}/content` endpoint

---

## Phase 4: Smart Schedule (1 week, can parallel Phase 2-3)

**Start:** Week of 2026-06-29  
**End:** Week of 2026-07-06  
**Priority:** LOW  
**Files:** 1  
**Effort:** 1 engineer, 1-2 days

**Scope:**
1. src/components/observation/SmartScheduleTab.tsx

**Backend:** Create `/api/schedule/teacher-dc-scores` endpoint

---

## Phase 5: Final Cleanup & Testing (1 week)

**Start:** Week of 2026-07-06  
**End:** Week of 2026-07-20  
**Priority:** CRITICAL  
**Effort:** 2 engineers, 5 days

### Tasks

**Day 1: Comprehensive Testing**
- [ ] Run full E2E test suite (all phases)
- [ ] Test all endpoints in staging environment
- [ ] Verify no regressions in existing features
- [ ] Load testing (performance validation)

**Day 2: Documentation**
- [ ] Create API client migration guide (frontend devs)
- [ ] Document all API endpoints (OpenAPI/Swagger already auto-generated)
- [ ] Update CLAUDE.md with API standards
- [ ] Create troubleshooting guide

**Day 3: Cleanup**
- [ ] Remove any remaining Supabase direct queries
- [ ] Clean up temporary workarounds/comments
- [ ] Ensure no unused imports
- [ ] Code review all changes

**Day 4-5: Deployment & Monitoring**
- [ ] Deploy to staging
- [ ] Smoke test in staging
- [ ] Deploy to production
- [ ] Monitor logs for errors
- [ ] Verify all metrics normal

---

## Parallel Path: Field Issues & User Roles (Weeks 2-4)

While Phases 2-3 are running, can also complete:

**Field Issues:** `/api/field-issues` endpoint + ReportIssueButton.tsx refactor  
**User Roles:** `/api/users/me/role` endpoint + useAdminRole/useCoachRole already done in Phase 1  
**Analytics:** `/api/analytics/event` endpoint + useAnalytics.ts refactor

**These are lower priority and can be done in parallel:**
- Field Issues: 1-2 days
- User Roles: Already done in Phase 1
- Analytics: 1 day

---

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Auth breaks during Phase 1 | Medium | Critical | Extensive E2E testing, rollback plan ready |
| Performance regression | Low | High | Load testing in staging, API optimizations ready |
| Data loss during migration | Low | Critical | Backward compatibility, dual-read strategy |
| JWT token issues | Medium | High | JWT middleware extensively tested |
| Missing edge cases | Medium | Medium | Comprehensive testing, code review |

---

## Success Metrics

**By End of Phase 5:**

- ✅ 100% of Supabase queries migrated to REST API
- ✅ All unit tests passing (>80% coverage)
- ✅ All integration tests passing
- ✅ All E2E tests passing
- ✅ Zero functionality regressions
- ✅ Performance same or better than Supabase
- ✅ API documented (OpenAPI/Swagger)
- ✅ Team can extend API for new features

---

## Resource Allocation

**Total Effort:** ~40-50 engineer-days

**Week 1 (Phase 1):** 1 engineer (5 days) + 1 engineer (2 days QA)  
**Week 2-3 (Phases 2-4):** 2 engineers (10 days each) + 1 engineer (parallel field issues, analytics)  
**Week 4-5 (Phase 5):** 2 engineers (5 days each) for testing, cleanup, deployment  

**Recommended:** 2-3 engineers working in parallel

---

## File Organization Post-Migration

```
Backend (coaching-api/app):
├── controllers/
│   ├── user_controller.py ✅
│   ├── observation_controller.py (Phase 2)
│   ├── field_issue_controller.py (Parallel)
│   ├── training_controller.py (Phase 3)
│   ├── schedule_controller.py (Phase 4)
│   ├── analytics_controller.py (Parallel)
│   ├── quiz_controller.py ✅
│   └── export_controller.py ✅
├── services/
│   ├── user_service.py (Phase 1)
│   ├── observation_service.py (Phase 2)
│   ├── field_issue_service.py (Parallel)
│   ├── training_service.py (Phase 3)
│   ├── schedule_service.py (Phase 4)
│   ├── analytics_service.py (Parallel)
│   ├── quiz_service.py ✅
│   └── module_service.py ✅
├── models/
│   ├── user.py (Phase 1)
│   ├── observation.py (Phase 2)
│   ├── field_issue.py (Parallel)
│   ├── training.py ✅
│   ├── quiz.py ✅
│   └── analytics.py (Parallel)
└── middleware/
    ├── auth.py (Phase 1)
    ├── error_handling.py
    └── logging.py

Frontend (src):
├── lib/
│   ├── userApiClient.ts (Phase 1)
│   ├── observationApiClient.ts (Phase 2)
│   ├── fieldIssueApiClient.ts (Parallel)
│   ├── trainingApiClient.ts (Phase 3)
│   ├── scheduleApiClient.ts (Phase 4)
│   ├── analyticsApiClient.ts (Parallel)
│   └── quizApiClient.ts ✅
├── hooks/
│   ├── useProfile.ts (Phase 1)
│   ├── useObservations.ts (Phase 2)
│   ├── useFieldIssues.ts (Parallel)
│   ├── useTraining.ts (Phase 3)
│   ├── useSchedule.ts (Phase 4)
│   ├── useAnalytics.ts (Parallel)
│   └── useQuiz.ts ✅
└── tests/
    ├── unit/
    ├── integration/
    └── e2e/
```

---

## Go-Live Checklist

Before going live to production:

- [ ] All phases complete and tested
- [ ] All E2E tests passing in staging
- [ ] Performance validated (load testing done)
- [ ] No data loss (backward compat verified)
- [ ] Team trained on new API structure
- [ ] Monitoring & alerting configured
- [ ] Rollback plan tested and ready
- [ ] API documentation complete
- [ ] All merge requests code-reviewed and approved

---

**Document Version:** 1.0  
**Last Updated:** 2026-06-09  
**Next Update:** After Phase 1 completion (2026-06-22)
