# Learning Flow: Scenario-First Learning Model (Phase 1)

## Overview

The Scenario-First learning model inverts the traditional content-first approach by prioritizing decision-making and real-world application:

**Traditional Slides-First:** Users watch slides → take quiz (60-70% skip content, 70% fail quiz)

**Scenario-First (Phase 1):** Users decide → see feedback → optional deep learning → next scenario (100% engage)

---

## Why Scenario-First?

Research shows coaching skill development requires:
1. **Decision-making practice** — Real scenarios where coaches decide independently
2. **Immediate feedback** — Why their decision was right or wrong
3. **Optional deepening** — Context and principles for those who want to learn more

The Scenario-First model aligns with adult learning theory (reflective practice, self-directed learning).

---

## The 5-Phase Flow

```
┌─────────────┐
│   Loading   │ ← Fetch scenarios for unit
└─────────────┘
      ↓
┌─────────────────────────────────────────┐
│ Phase 1: SCENARIO                       │
│ ─────────────────────────────────────── │
│ • Display situation & question          │
│ • Show 4 MCQ options (A-D)              │
│ • User selects and submits decision     │
└─────────────────────────────────────────┘
      ↓ (Analytics: decision_submitted)
┌─────────────────────────────────────────┐
│ Phase 2: FEEDBACK                       │
│ ─────────────────────────────────────── │
│ • Green badge: ✓ Correct                │
│ • Red badge: ✗ Incorrect                │
│ • Show chosen option vs correct answer  │
│ • Display rationale                     │
│ • Show principle tag (e.g., Trust)      │
│ • Continue button                       │
└─────────────────────────────────────────┘
      ↓ (Analytics: feedback_viewed)
┌─────────────────────────────────────────┐
│ Phase 3: REVEAL (if feedback_slides)    │
│ ─────────────────────────────────────── │
│ • 2-3 slide carousel                    │
│ • Each slide: title + body + optional   │
│ • Previous/Next navigation              │
│ • Progress indicator (Slide 1 / 3)      │
│ • Done button                           │
└─────────────────────────────────────────┘
      ↓
┌─────────────────────────────────────────┐
│ Phase 4: DEPTH (if deep_content)        │
│ ─────────────────────────────────────── │
│ • Collapsed "Read more" expandable      │
│ • On first expand: analytics event      │
│ • Full context and principles           │
│ • Continue button                       │
└─────────────────────────────────────────┘
      ↓ (Analytics: read_more_clicked)
┌─────────────────────────────────────────┐
│ Phase 5: SUMMARY or NEXT SCENARIO       │
│ ─────────────────────────────────────── │
│ If more scenarios:                      │
│ • Load next scenario → Phase 1           │
│                                          │
│ If last scenario:                        │
│ • Show results: X/Y correct             │
│ • Time spent breakdown                  │
│ • Back to Dashboard button              │
└─────────────────────────────────────────┘
```

---

## Smart Phase Progression

The system intelligently skips empty phases:

- If `feedback_slides.length === 0` → Skip REVEAL phase, go to DEPTH
- If `deep_content === null` → Skip DEPTH phase, go to SUMMARY/next
- If both empty → Go directly to SUMMARY

**Example:** Scenario with only situation + question + options (no reveal/depth):
```
Scenario → Feedback → Summary
```

**Example:** Full-featured scenario:
```
Scenario → Feedback → Reveal (3 slides) → Depth → Summary
```

---

## Components

### ScenarioCard
Displays the decision-making prompt.

```
┌────────────────────────────────────┐
│ Situation:                          │
│ A teacher comes to you mentioning  │
│ they struggle with engagement...    │
│                                    │
│ Question: What's your first step? │
│                                    │
│ ○ A. Observe their teaching       │
│ ○ B. Ask what they've tried       │
│ ○ C. Suggest strategies           │
│ ○ D. Review student data          │
└────────────────────────────────────┘
```

**Props:**
- `situation` — Context paragraph
- `question` — Decision prompt
- `options[]` — A/B/C/D choices
- `selectedLetter` — Current selection
- `onSelect` — Handler for option click
- `locked` — Disable options (after submission)

---

### FeedbackCard
Shows decision outcome and reasoning.

```
┌──────────────────────────────────┐
│ ✓ Correct!                       │
│                                 │
│ You selected: B. Ask what       │
│ Correct answer: B. Ask what     │
│                                 │
│ Rationale:                      │
│ Understanding their context &   │
│ previous attempts builds trust. │
│                                 │
│ Principle: Partnership Building │
│                                 │
│ [Continue →]                    │
└──────────────────────────────────┘
```

**Props:**
- `isCorrect` — Boolean for styling
- `chosenOptionText` — What user picked
- `correctOptionText` — Right answer
- `rationale` — Why it's correct/incorrect
- `principleTag` — Coaching principle (e.g., "Trust")
- `onContinue` — Next phase button

---

### RevealSlides
Feedback carousel with progression.

```
┌──────────────────────────────────┐
│ Why This Matters (Slide 1/3)    │
│                                 │
│ Partnership isn't nice-to-have. │
│ It's foundational to all        │
│ effective coaching. When you... │
│                                 │
│ [← Prev] [Progress] [Next →]   │
└──────────────────────────────────┘
```

**Props:**
- `slides[]` — Array of {title, body, image_url?}
- `onDone` — Completion handler

**Behavior:**
- Auto-calls `onDone()` if `slides.length === 0`
- Smooth transitions between slides
- Disabled/enabled navigation based on position

---

### ExpandableDepth
Collapsible advanced content.

```
┌──────────────────────────────────┐
│ ▼ Read more about partnership... │
│                                 │
│ [Hidden until expanded]         │
└──────────────────────────────────┘

↓ On click:

┌──────────────────────────────────┐
│ ▲ Read more about partnership... │
│                                 │
│ Partnership isn't just a        │
│ technique. It's a philosophy    │
│ rooted in...                    │
│                                 │
│ [Continue →]                    │
└──────────────────────────────────┘
```

**Props:**
- `content` — Deep explanation text
- `scenarioId` — For analytics tracking
- `unitId` — For analytics tracking

**Behavior:**
- Collapsed by default (`max-h-0`)
- On first expand: fires `read_more_clicked` analytics
- Smooth max-height transition

---

## Analytics & Tracking

Each phase fires analytics events:

| Phase | Event | Metadata |
|-------|-------|----------|
| Scenario shown | `scenario_viewed` | scenario_id, unit_id |
| Decision submitted | `decision_submitted` | scenario_id, unit_id, chosen_option |
| Feedback shown | `feedback_viewed` | scenario_id, unit_id |
| Deep content expanded | `read_more_clicked` | scenario_id, unit_id |

Events saved to `analytics_events` table for reporting and insights.

---

## Data & Storage

### Database Tables

**scenarios** — Stored per unit with progression order

```
id, unit_id, order_number, situation, question,
difficulty, feedback_slides (JSONB),
reveal_content, deep_content, is_active
```

**scenario_options** — A/B/C/D choices per scenario

```
id, scenario_id, option_letter (A|B|C|D),
option_text, is_correct, rationale, principle_tag
```

**scenario_responses** — User decision tracking

```
id, user_id, scenario_id, chosen_option (A|B|C|D),
is_correct, time_spent_seconds, attempt_number
```

---

## Time Tracking

For each scenario, the component tracks:
- When scenario phase becomes active (useRef)
- When user submits decision
- Calculates `time_spent_seconds` and saves to `scenario_responses`

Used for analytics: engagement time, pacing insights, reflection patterns.

---

## Admin Content Creation

Admins create scenario content via `/admin/units/:unitId/scenarios`:

1. **Create Scenario**
   - Situation text
   - Question text
   - Difficulty (easy/medium/hard)
   - Feedback slides (JSON array of {title, body})
   - Reveal content (short rationale)
   - Deep content (full explanation)
   - Active toggle

2. **Edit Options** at `/admin/scenarios/:scenarioId/options`
   - 4 rows for A/B/C/D
   - Option text, rationale, principle tag
   - Mark one as correct (only one allowed)

---

## Best Practices for Scenario Creation

**Good Scenario:**
- **Situation:** Realistic, specific context (2-3 sentences)
- **Question:** Clear, decision-focused prompt
- **Options:** Plausible alternatives, not obviously wrong
- **Rationale:** Explains why choice is right, connects to coaching principles
- **Reveal slide:** 1-3 slides with key insights
- **Deep content:** Full context for learners wanting deeper understanding

**Avoid:**
- Overly obvious correct answer (teaches nothing)
- Unclear situation (confuses learners)
- Rationale that's lecture-like (should be reflective)
- Too many reveal slides (diminishes impact)

---

## Performance Considerations

- Scenarios loaded with options (merged client-side)
- Images in reveal slides optimized (lazy load or CDN)
- Analytics fire-and-forget (non-blocking)
- localStorage auto-saves progress every 5 seconds (future: add retry logic)

---

## Future Enhancements

- **Branching scenarios:** Different paths based on user choice
- **Peer comparison:** "X% of coaches chose this option"
- **Scenario versioning:** Admin can update scenarios without losing historical responses
- **Time-based hints:** Suggestions after 30 seconds of inactivity
- **Scenario libraries:** Pre-built scenarios by topic/competency

---

**Last Updated:** 2026-04-14
