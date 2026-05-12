---
name: parsing-gherkin-scenarios
description: Use when validating BDD feature files - extract scenarios, detect chunk filtering mode, classify positive vs negative scenarios
---

# Parsing Gherkin Scenarios

## Overview

Parse `.feature` files and structure scenarios for validation. Detect `@chunk` mode (run subset) vs full (all scenarios). Classify each scenario by type (`@positive`, `@negative`, or untagged) and extract step details (Given/When/Then).

## When to Use

- First step in IDD validation pipeline
- Loading a `.feature` file for analysis
- Need to identify which scenarios to validate (chunk vs full mode)

## Core Process

### Step 1: Chunk Mode Detection (FIRST operation)

| Finding | Behavior |
|---------|----------|
| Any `@chunk` tag found | Mode = "chunk" → retain ONLY @chunk scenarios |
| No `@chunk` tags | Mode = "full" → retain all scenarios |

Log result: "Mode: [chunk|full] | X scenarios retained"

### Step 2: Extract Each Scenario

For every retained scenario, extract:

```json
{
  "name": "exact scenario name from file",
  "type": "positive | negative | untagged",
  "tags": ["@chunk", "@positive", "@negative"],
  "steps": {
    "given": ["step text"],
    "when": ["step text"],
    "then": ["step text"]
  },
  "is_chunk": true,
  "raw_text": "full scenario block verbatim"
}
```

### Step 3: Validate Tags

Every scenario must have `@positive` OR `@negative` tag:

- Both present → type = "positive" or "negative"
- Neither present → type = "untagged"
- Mark untagged scenarios for validator (will fail validation)

## Hard Constraints

- `@chunk` filtering is the FIRST operation — before parsing, before any analysis
- If mode = chunk: non-`@chunk` scenarios are INVISIBLE. Do not count, reference, or analyze them.
- Scenario count in output must reflect only retained scenarios

## Output

Structured scenario list ready for scope-resolver and code-mapper.
