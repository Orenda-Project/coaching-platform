# Behavior Analysis Rules

## Rule: Always Dry-Run Non-Covered Scenarios

**Statement:** For every scenario that is NOT ✅ COVERED, perform a dry-run trace through the actual code to determine what ACTUALLY happens — not what should happen.

**Why:** "Missing" does not mean "nothing." A missing implementation still has actual behavior (404, null return, crash, silent failure). The actual behavior is what the user experiences and what matters for impact assessment.

**How to apply:** Before writing the `actual_behavior` field, trace:
1. Does the entry point exist?
2. If yes, what does it do when called with the scenario's inputs?
3. Where exactly does behavior diverge from the Gherkin expectation?
4. What is the last successful operation, and what breaks after it?

---

## Worked Examples

### MISSING scenario dry-run

```
Scenario: User receives confirmation email after signup

Dry-run trace:
  • Entry point: POST /api/signup → src/pages/Signup.tsx handleSubmit()
  • Line 45: supabase.auth.signUp() called ✓
  • Line 48: user redirected to /dashboard ✓
  • Email sending: no email service call found anywhere in scope
  • Result: user is signed up and redirected, but no confirmation email is sent

actual_behavior: "Signup completes and user is redirected, but no confirmation email is triggered — the email step is entirely absent from the implementation"
impact: "Users never receive a confirmation email"
```

### PARTIAL scenario dry-run

```
Scenario: User sees validation error when submitting empty form

Dry-run trace:
  • Entry point: LoginForm handleSubmit() → src/pages/Login.tsx line 23
  • Line 25: if (!email || !password) check present ✓ (Given: empty form)
  • Line 26: setError('Please fill all fields') called ✓ (When: submit clicked)
  • Error state set correctly ✓
  • Then: error message displayed — JSX at line 67: {error && <p>{error}</p>} ✓
  • But: button does not return to enabled state after error — loading state not reset
  • Line 31: setLoading(true) but no setLoading(false) in the validation branch

actual_behavior: "Validation error message displays correctly, but submit button remains disabled after error, requiring page refresh to retry"
impact: "User sees the error but cannot resubmit without refreshing the page"
```

### VIOLATION scenario dry-run

```
Scenario: Expired OTP is rejected

Dry-run trace:
  • Entry point: verifyOtp() → src/hooks/useAuth.tsx line 78
  • Line 82: const isValid = otp.expiry > Date.now()
  • Condition uses strict greater-than (>), not greater-than-or-equal (>=)
  • OTP at exact expiry millisecond: expiry === Date.now() → isValid = false... wait
  • Re-check: expiry > Date.now() is FALSE when equal — OTP IS rejected at exact expiry
  • HOWEVER: line 89: if (attempts < 3) { allowRetry() } — no expiry re-check on retry
  • A request that arrives 1ms before expiry, fails, then retries after expiry: retry is allowed
  • The retry path at line 89 does not re-validate expiry

actual_behavior: "Initial OTP submission correctly rejects expired tokens, but the retry flow (line 89) does not re-check expiry — an OTP expired between first attempt and retry is accepted on retry"
impact: "Expired OTPs can be used by retrying after expiry"
```

---

## Red-Flag Phrases (Never Write These)

These indicate you are rationalizing instead of tracing:

| Red flag | Why it's wrong |
|---------|----------------|
| "likely handles this" | Guessing — trace the actual code |
| "should be implemented" | Describes intent, not behavior |
| "implied by the framework" | Framework behavior ≠ scope evidence |
| "common pattern suggests" | Prior knowledge, not scope evidence |
| "probably works because" | Probability is not evidence |
| "architecture implies" | Architecture ≠ implementation |
