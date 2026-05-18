# Training Flow Feature — Intent Definition

## Feature Overview
Manages the sequential training flow where users complete slides first, then practice scenarios, with appropriate access controls and completion tracking.

## User Story
As a learner
I want to progress through training content in a structured way (slides → practice)
So that I can build knowledge before applying it in scenarios

## Actors & Preconditions
- Learner (user enrolled in a module)
- Training has content (slides and/or scenarios)
- User is logged in and has access to the module
- User has not completed the training (first-time or retry)

## Key Behaviors
- Practice section is locked until all slides are viewed
- User auto-navigates to scenario after completing slides (if scenario exists)
- Training is complete only when BOTH slides AND scenarios are done (or slides alone if no scenario)
- User sees clear messaging for locked/unlocked sections
- Progress persists across sessions
- Users can navigate back to slides from scenario

## Known Constraints
- Slides must be completed before practice access
- Training with scenarios requires both phases to be marked complete
- Training without scenarios only requires slide completion
- Auto-navigation happens automatically after slide completion

## Out of Scope
- Video/media playback (separate feature)
- Content creation or editing
- Scenario scoring or grading
- Admin override or bypass mechanisms
