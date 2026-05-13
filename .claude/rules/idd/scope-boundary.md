# Scope Boundary Rules

## Rule 1: Hard Scope Boundary

**Statement:** Only files listed in the `=== SCOPE FILES ===` section (and their directory children) are valid sources of evidence. No other files exist for the purpose of this validation.

**Why it matters:** Validation scope is intentionally limited. A feature owns the code it ships. Evidence from files outside scope would blur ownership and produce incorrect verdicts.

**How to apply:** Before citing any file as evidence, verify it is in the loaded scope index from scope-resolver. If it is not in the index, it cannot be cited.

**Violation examples:**
- ❌ "The auth middleware (not in scope) likely handles this"
- ❌ Citing `node_modules/` or any installed library
- ✅ Only citing files that appeared in the scope-resolver declaration

---

## Rule 2: Chunk Absolute Filter

**Statement:** If any `@chunk` tag exists in the feature file, ALL scenarios without `@chunk` are removed BEFORE any analysis begins. They do not exist. They are not counted. They are not referenced.

**Why it matters:** Chunk mode is a deliberate partial-validation signal from the developer. Validating non-chunk scenarios defeats its purpose and produces misleading results.

**How to apply:** gherkin-parser performs this filter as its FIRST operation. The scenario count in every downstream skill and the final report reflects ONLY retained (chunk or all) scenarios.

**Violation examples:**
- ❌ "There are 12 scenarios total, but we are validating 3 @chunk ones"
- ✅ "3 scenarios validated" (the 9 others are invisible)

---

## Rule 3: No Transitive Analysis

**Statement:** Do not follow imports to files outside the declared scope boundary. If a scoped file imports from an out-of-scope file, note the import as an unresolvable path and stop there.

**Why it matters:** Transitive analysis expands scope arbitrarily and introduces prior-session knowledge. The scope boundary is a deliberate contract, not a starting point for exploration.

**How to apply:** When tracing a function call that resolves to an out-of-scope file, record `"unresolvable_paths": ["path/to/out-of-scope.ts → outside scope"]` and do not continue tracing through it.

**Violation examples:**
- ❌ Following `import { supabase } from 'lib/supabase'` when `lib/supabase.ts` is not in scope
- ✅ "supabase call at line 34 — lib/supabase is outside scope, cannot trace further"

---

## Rule 4: No Cross-Session Knowledge

**Statement:** Do not use knowledge from any prior validation run, prior conversation, or any source other than the files provided in the current prompt.

**Why it matters:** IDD validation must be deterministic. The same prompt must produce the same result regardless of what was validated before.

**How to apply:** Treat every `claude -p` invocation as a fresh session with no memory. The source code in the prompt is the only ground truth.

**Violation examples:**
- ❌ "In the last PR validation, login was COVERED, so the auth context is intact"
- ✅ Validate login from the source code provided, every time

---

## Rule 5: Scope Boundary Declaration

**Statement:** scope-resolver must output a scope boundary declaration BEFORE code-mapper begins any analysis. The declaration lists all loaded files and all unresolvable paths.

**Why it matters:** The declaration makes the hard boundary explicit. It prevents silent scope expansion and provides a clear audit trail for why certain evidence is absent.

**How to apply:** After indexing all scope files, output the formatted declaration block (see scope-resolver SKILL.md for exact format) before passing control to code-mapper.

**Violation examples:**
- ❌ Proceeding to code-mapper without outputting the scope declaration
- ✅ Scope declaration visible in output, then code-mapper analysis follows
