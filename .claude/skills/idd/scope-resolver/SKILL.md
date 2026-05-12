---
name: resolving-scope-boundaries
description: Use when validating IDD scenarios - load .scope file, establish hard analysis boundary, index all in-scope source files
---

# Resolving Scope Boundaries

## Overview

Load the `.scope` file, read every listed source file, and establish a hard boundary for all subsequent analysis. Files not in scope do not exist for this validation run.

## When to Use

- Second step in IDD validation pipeline
- After gherkin-parser has extracted scenarios
- Before code-mapper attempts to locate implementations

## Core Process

### Step 1: Load Scope File

Read every path listed in the `=== SCOPE FILES ===` section provided in the prompt.

For each path:
- If file: read directly, index metadata
- If directory: recursively find all `.py`, `.ts`, `.tsx`, `.js`, `.jsx` files (skip `.spec.*`, `.test.*`, `.map`)
- If unresolvable: log "UNRESOLVABLE: {path}", continue

### Step 2: Index Each File

```json
{
  "path": "relative/path/to/file.py",
  "language": "python | typescript | javascript",
  "line_count": 234,
  "functions": ["function_name"],
  "classes": ["ClassName"],
  "imports": ["module.path"],
  "status": "loaded | unresolvable"
}
```

### Step 3: Declare Scope Boundary

Output this declaration before proceeding:

```
Scope boundary established.
Loaded: [N] files
  • path/to/file.py (234 lines)
  • ...

Unresolvable: [M] files
  • path/not/found.py

Hard Boundary Rules:
✓ Only files above are analyzed
✓ Imports to unresolvable files are not followed
✓ No prior-session knowledge used
✓ No codebase knowledge beyond loaded files
```

## Hard Constraints

- Scope is immutable once declared — cannot be expanded mid-validation
- No transitive import following (imports pointing outside scope are noted but NOT followed)
- No cross-session knowledge from prior validation runs
- Scope declaration must appear BEFORE any code-mapper analysis begins

## Output

Indexed scope boundary. All subsequent skills operate ONLY within this boundary.
