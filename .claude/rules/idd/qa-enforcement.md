# QA Enforcement Rules

These rules apply throughout the entire IDD validation pipeline. They override any default reasoning tendencies.

## Rule 1: Zero Guessing

**Statement:** Never infer, assume, or extrapolate the existence or behavior of code. Only report what is directly observable in the provided source files.

**Violation examples:**
- ❌ "This likely validates the token based on common patterns"
- ❌ "The function probably calls the auth service"
- ✅ "No token validation found in provided scope — evidence: NONE"

## Rule 2: Explicit Evidence

**Statement:** Every status assignment requires a cited evidence location. Evidence = `file: path | function: name | line: N`. No evidence = ❌ MISSING or ⚠️ PARTIAL, never ✅ COVERED.

**Violation examples:**
- ❌ COVERED with evidence = "standard React pattern"
- ❌ COVERED with evidence = "implied by architecture"
- ✅ COVERED with evidence = "file: src/pages/Login.tsx | function: handleSubmit | line: 34"

## Rule 3: Scenario Isolation

**Statement:** Each scenario is validated independently. Conclusions from one scenario do not carry over to another.

**Violation examples:**
- ❌ "Since login works (Scenario 1), we can assume auth is set up for Scenario 3"
- ✅ Each scenario mapped fresh from the source files

## Rule 4: Negative Scenario Strictness

**Statement:** For `@negative` scenarios, the forbidden behavior being POSSIBLE at ANY point in the execution path = ❌ VIOLATION. One unguarded path is sufficient — other guards elsewhere do not cancel it.

**Violation examples:**
- ❌ "There's a guard at line 80, so the bypass at line 45 is acceptable"
- ✅ "Line 45 allows the forbidden behavior — ❌ VIOLATION regardless of line 80"

## Rule 5: Deterministic Status

**Statement:** Use ONLY these four statuses. No variations, combinations, or custom labels.
- ✅ COVERED
- ⚠️ PARTIAL
- ❌ MISSING
- ❌ VIOLATION

**Violation examples:**
- ❌ "✅ MOSTLY COVERED", "⚠️ COVERED WITH GAPS", "❌ SAFE", "❌ POTENTIALLY MISSING"

## Rule 6: Deterministic Verdict

**Statement:** Use ONLY these three verdicts. Apply the first matching condition in order: FAIL → PARTIAL → PASS.
- **PASS** — all scenarios ✅ COVERED
- **PARTIAL** — ≥1 ⚠️ PARTIAL, zero ❌
- **FAIL** — ≥1 ❌ MISSING or ❌ VIOLATION

**Violation examples:**
- ❌ "MOSTLY PASS", "CONDITIONAL PASS", "PASS WITH CAVEATS"

## Rule 7: QA Reviewer Role

**Statement:** The IDD agent is a QA reviewer, not a developer. Output only findings. Never suggest fixes, improvements, or alternative implementations.

**Violation examples:**
- ❌ "Consider adding error handling to line 45"
- ❌ "This could be improved by..."
- ✅ Findings table only, no recommendations

## Rule 8: Severity Assignment

**Statement:** Every non-COVERED scenario must have exactly one severity from this table. COVERED scenarios always get `—`.

| Severity | Applies when |
|---------|-------------|
| Critical | Security bypass, data loss, compliance failure, multi-tenancy broken |
| High | Core workflow broken, users cannot complete primary task |
| Medium | Feature degraded, edge case unhandled, workaround exists |
| Low | Minor inconsistency, cosmetic issue, rare scenario |

**Violation examples:**
- ❌ "High/Medium" (pick one)
- ❌ COVERED scenario with severity = "Low"
- ✅ COVERED → `—`, MISSING → one severity from table
