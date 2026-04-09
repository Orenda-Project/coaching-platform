# PROJECT_MAP.md — Coaching Platform Prototype
> Taleemabad | Built: 2026-04-08 | Engineer: Jalal Khan

See CLAUDE.md for slash commands, business rules, and architecture links.

## Full Flow
Signup → Baseline (60%) → Persona (A/B/C/D) → Module 1 (universal) → 
Module N (persona-specific, sequential unlock by order_number) → 
Endline (unlocks only when ALL modules passed, server-verified, 70%) → Certificate

## Key Thresholds
| Gate | Threshold | On Fail |
|---|---|---|
| Baseline | 60% | Retry (no persona assigned) |
| Module Quiz | 80% | Retry (max 3 attempts) |
| Endline | 70% | Retry |

## Personas
A ≥75% · B 70–74% · C 65–69% · D 60–64% · <60% = fail baseline

## Files
src/pages/Assessment.tsx       — Baseline + Endline (endline server-gated)
src/pages/TrainingModule.tsx   — Content viewer + anti-cheat quiz
src/pages/Dashboard.tsx        — Module list + locking (order_number sort)
src/pages/Certificate.tsx      — PDF certificate (upsert on conflict)
src/components/training/TrainingContentViewer.tsx — Video 90% + Slides 30s

## Migrations
supabase/migrations/20260408000001_coaching_platform_v2.sql
  - attempt_count, tab_switch_count, flagged_for_review on training_progress
  - content_completed on training_progress
  - baseline_attempt_count, endline_attempt_count on profiles
  - session_events table for analytics
  - scenario_data JSONB on training_content

## v2 Fixes vs coach-cert
- Module locking: uses order_number sort (not array index)
- Endline gate: server-verified (all modules must be passed)
- Certificate: upsert (not insert) — handles retakes
- Video: 90% watch gate + progress bar
- Anti-cheat: tab-switch detection, 3+ = flagged for admin review
- Attempt count tracked per module (max 3)
- Persona <60% = explicit fail with clear message
