# 🔐 BASELINE ASSESSMENT GATING - CRITICAL REQUIREMENT

**Document Date:** 2026-05-06  
**Status:** ⭐ CRITICAL REQUIREMENT  
**Scope:** All new users + baseline assessment system

---

## 📋 REQUIREMENT SUMMARY

### The Rule:
1. **New users (first login):** Only baseline assessment is shown
2. **After baseline completion:** Baseline assessment is NEVER shown again
3. **Access control:** Training modules are locked until baseline is completed

---

## 🎯 USER JOURNEY

### Stage 1: New User (First Login)
```
User Logs In
    ↓
Check: Is baseline_completed = true?
    ↓ NO (New User)
    ↓
SHOW: Only Baseline Assessment
HIDE: All training modules
DISABLE: Training module buttons
    ↓
User Completes Baseline Assessment
    ↓
Set: baseline_completed = true
Save: Baseline score, answers, completion date
    ↓
PROCEED: Next stage
```

### Stage 2: Returning User (After Baseline Complete)
```
User Logs In
    ↓
Check: Is baseline_completed = true?
    ↓ YES (Returning User)
    ↓
HIDE: Baseline Assessment link
SHOW: Training modules + Dashboard
ENABLE: All training module buttons
    ↓
User Can Access:
  ✓ Training modules
  ✓ Module quizzes
  ✓ Progress tracking
  ✗ Baseline assessment (locked permanently)
```

---

## 🔧 TECHNICAL IMPLEMENTATION

### Database Fields Required:
```sql
users table:
  - baseline_completed: BOOLEAN (default: false)
  - baseline_score: INTEGER (0-100, nullable until completed)
  - baseline_completed_at: TIMESTAMP (nullable)
  - baseline_answers: JSON (array of answer selections)
  - baseline_time_taken: INTEGER (seconds, nullable)
```

### API Endpoints:
```
POST /api/baseline/submit
  Request: { answers: [1,2,3,...], time_taken: 1200 }
  Response: { score: 88, completed: true, message: "Success" }
  Side Effect: Sets user.baseline_completed = true

GET /api/user/progress
  Response: { baseline_completed: true, modules: [...] }
  Use: To determine UI state on login

GET /api/user/baseline
  Response: { 403 Forbidden } if baseline_completed = false
  Use: Prevent baseline re-access after completion
```

### Frontend Logic:
```javascript
// On dashboard load
if (user.baseline_completed) {
  // Show training dashboard
  renderTrainingModules();
  hideBaselineAssessment();
} else {
  // Show baseline assessment only
  renderBaselineAssessment();
  hideTrainingModules();
  disableAllModuleButtons();
}

// When baseline submitted
async function submitBaseline(answers) {
  const response = await post('/api/baseline/submit', { answers });
  if (response.score !== null) {
    localStorage.setItem('baseline_completed', 'true');
    user.baseline_completed = true;
    window.location.reload(); // Refresh to show new dashboard
  }
}

// Block direct access to baseline after completion
// Route: /assessment/baseline
if (user.baseline_completed) {
  redirect('/dashboard'); // Prevent re-access
}
```

---

## ✅ TEST CASES

### Test Case 1: New User Sees Only Baseline
**Precondition:** New user account (baseline_completed = false)

| Step | Action | Expected | Status |
|------|--------|----------|--------|
| 1 | Login with new account | Dashboard loads | ✓ |
| 2 | Check page content | "Baseline Assessment" visible | ✓ |
| 3 | Check training modules | Locked/grayed out or hidden | ✓ |
| 4 | Try to click module button | Disabled or redirects to baseline | ✓ |
| 5 | Check URL structure | No `/modules/` access | ✓ |

---

### Test Case 2: Baseline Completion Updates State
**Precondition:** User on baseline assessment page

| Step | Action | Expected | Status |
|------|--------|----------|--------|
| 1 | Answer all 18 questions | Progress bar reaches 100% | ✓ |
| 2 | Click Submit | Success message appears | ✓ |
| 3 | Check database | baseline_completed = true | ✓ |
| 4 | Check score | Score calculated (0-100) | ✓ |
| 5 | Check timestamp | completion_date recorded | ✓ |

---

### Test Case 3: Baseline Hidden After Completion
**Precondition:** User has baseline_completed = true

| Step | Action | Expected | Status |
|------|--------|----------|--------|
| 1 | Logout and login | Dashboard loads | ✓ |
| 2 | Check dashboard | Baseline link NOT visible | ✓ |
| 3 | Check page | Training modules visible | ✓ |
| 4 | Try direct URL | /assessment/baseline redirects to /dashboard | ✓ |
| 5 | Check training modules | All enabled and accessible | ✓ |

---

### Test Case 4: Baseline Cannot Be Re-Accessed
**Precondition:** User completed baseline previously

| Step | Action | Expected | Status |
|------|--------|----------|--------|
| 1 | Navigate to /assessment/baseline | 403 Forbidden or redirect | ✓ |
| 2 | Try via API | GET /api/baseline returns 403 | ✓ |
| 3 | Check UI | No baseline link in menu | ✓ |
| 4 | Check conditional rendering | Training modules shown instead | ✓ |

---

## 📊 VERIFICATION CHECKLIST

### For QA Team:

- [ ] New user account created
- [ ] Login with new account
- [ ] Verify baseline assessment is the ONLY option shown
- [ ] Verify training modules are locked/hidden
- [ ] Complete all 18 baseline questions
- [ ] Submit baseline assessment
- [ ] Verify completion message displayed
- [ ] Check database: baseline_completed = true
- [ ] Check database: baseline_score recorded
- [ ] Logout user
- [ ] Login with same user
- [ ] Verify baseline assessment is now HIDDEN
- [ ] Verify training modules are VISIBLE
- [ ] Verify training modules are ENABLED
- [ ] Try direct access to /assessment/baseline
- [ ] Verify redirect to dashboard or 403 error
- [ ] Verify user cannot re-attempt baseline

### For Developers:

- [ ] User model has baseline_completed field
- [ ] User model has baseline_score field
- [ ] User model has baseline_completed_at field
- [ ] Dashboard component checks baseline_completed status
- [ ] Baseline assessment hidden if baseline_completed = true
- [ ] Training modules hidden if baseline_completed = false
- [ ] POST /api/baseline/submit sets baseline_completed = true
- [ ] POST /api/baseline/submit returns score
- [ ] GET /api/user/baseline blocks access if completed
- [ ] /assessment/baseline redirects to dashboard if completed
- [ ] Session/JWT includes baseline_completed status
- [ ] Module unlock gates respect baseline completion status

---

## 🚀 IMPLEMENTATION PHASES

### Phase 1: Database Setup
- Add baseline_completed, baseline_score, baseline_completed_at fields to users table
- Create migration
- Deploy to staging

### Phase 2: API Implementation
- Implement baseline submission endpoint
- Add access control to baseline assessment
- Add user progress endpoint
- Test with Postman

### Phase 3: Frontend Implementation
- Update dashboard component with conditional rendering
- Hide/show baseline based on baseline_completed
- Lock/unlock training modules
- Add redirect logic for completed baseline
- Test with multiple user accounts

### Phase 4: QA & Testing
- Run full test suite
- Verify all test cases pass
- Test with multiple new users
- Test baseline completion
- Test re-login scenarios

---

## 🔍 MONITORING & VALIDATION

### Metrics to Track:
```
- New users completing baseline: X%
- Average baseline completion time: Y minutes
- Baseline score distribution: [0-20%, 20-40%, ...]
- Users proceeding to training after baseline: Z%
- Users attempting re-access to baseline: Should be 0
```

### Alerts to Set Up:
- ⚠️ User baseline_completed mismatch (UI says complete, DB says incomplete)
- ⚠️ Multiple baseline submissions for same user
- ⚠️ Baseline submission with invalid answers
- ⚠️ Database query failures on /api/baseline endpoints

---

## 📝 DOCUMENTATION UPDATES

### For Users:
- "Welcome! Please complete the baseline assessment to get started"
- "After completing the baseline, you'll unlock all training modules"
- "Your baseline score is: XX%"

### For Developers:
- Update API documentation with baseline endpoints
- Document baseline_completed field in user schema
- Document conditional rendering in component docs
- Add baseline gating tests to CI/CD

---

## ❓ FAQ

**Q: Can users re-attempt the baseline?**  
A: No. Once completed, the baseline is permanently locked and cannot be re-accessed.

**Q: What if a user never completes the baseline?**  
A: They remain in "incomplete" state and can only see the baseline assessment. Training is locked.

**Q: Where is the baseline score stored?**  
A: In the users table, baseline_score field. Also returned in user progress API.

**Q: What happens if user clears their browser cache?**  
A: The server still has baseline_completed = true, so they'll still see training modules.

**Q: Can an admin reset a user's baseline?**  
A: This should be configurable by admin (set baseline_completed = false), allowing re-attempt.

---

**Owner:** QA + Backend Team  
**Last Updated:** 2026-05-06  
**Status:** ⭐ ACTIVE REQUIREMENT
