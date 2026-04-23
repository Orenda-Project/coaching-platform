# QA Risk Patterns

Last updated: 2026-04-23

## High-Risk Scenarios (always test these)
- **Fresh user signup → baseline redirect** — has broken before (baseline_completed not written)
- **Persona assignment at boundary scores** — exactly 60%, 70%, 75% (off-by-one errors)
- **Content gate: video at 89% completion** — below 90% gate, quiz should NOT unlock yet
- **Quiz retry: passed=true preservation** — retaking quiz must keep best score, passed flag unchanged
- **Endline gate enforcement** — attempting endline before all modules passed must fail
- **Certificate duplicate on retry** — retaking endline must NOT create duplicate certificate row
- **Anti-cheat: tab switch mid-quiz** — tab switch during quiz must be flagged correctly
- **Admin route access control** — non-admin user must be blocked from admin routes

## Medium-Risk (test when relevant)
- Mobile responsiveness on quiz screen (touch, keyboard, viewport)
- Refresh mid-quiz (progress saved? quiz state preserved?)
- Empty question bank (graceful error, not crash)
- Network failure during quiz submit (toast shown, retry available)
- Module unlock cascade (passing Module N unlocks Module N+1 correctly)

## Edge Cases Rarely Tested
- User with no modules assigned (dashboard shows "no modules")
- Persona score exactly at threshold (75.0 = A, 74.9 = B)
- Content in multiple formats (video, slides, scenario) all gate correctly
- Endline retake after passing (certificate reissue without duplicate)
