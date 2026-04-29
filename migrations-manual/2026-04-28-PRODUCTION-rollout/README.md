# Module 1 Quiz Rebuild — Production Migration Suite

**Status:** Ready for Production  
**Target:** Supabase `agziuwqpkfmxtospfxns` (production)  
**Date:** 2026-04-28  
**Branch:** `feature/module1-quiz-rebuild-and-attempts-table`

---

## 📋 What This Migration Does

Replaces all 37 existing Module 1 quiz questions with:
- **42 new MCQs** (6 per unit × 7 units, order 1–42)
- **7 scenario-based questions** (1 per unit, order 17–23)
- **`module_quiz_attempts` table** for tracking per-user quiz performance

Frontend automatically displays 20 questions per quiz: 16 random MCQs (unit-balanced) + 4 random scenarios.

---

## 📁 Files in This Directory

| File | Purpose | Phase |
|------|---------|-------|
| `00-preflight.sql` | Snapshot current production state before changes | 1 |
| `01-forward.sql` | Apply question rebuild + create tracking table | 2 |
| `02-rollback.sql` | Restore original questions if migration fails | 3 |
| `03-cleanup-backups.sql` | Drop backup tables after 3+ days validation | 5 |
| `RUNBOOK.md` | Step-by-step production deployment guide | — |

---

## ✅ What's Been Tested

- ✅ Staging migration (full cycle: forward → verification → rollback → cleanup)
- ✅ Frontend ModuleQuiz.tsx updated to fetch/shuffle/score scenarios (feature branch)
- ✅ `module_quiz_attempts` table created with RLS policies and trigger
- ✅ All 49 questions with options inserted and verified
- ✅ Question shuffling algorithm validates option positions are randomized
- ✅ Backup tables created and verified restorable

---

## 🚀 To Deploy to Production

1. **Read the RUNBOOK**  
   See `RUNBOOK.md` for complete 5-phase deployment guide with safety checks.

2. **Quick summary:**
   - Phase 1: Run `00-preflight.sql` (snapshot current state)
   - Phase 2: Run `01-forward.sql` (apply migration)
   - Phase 2: Run verification queries (confirm counts)
   - Phase 4: Monitor for 1–2 days (no errors in app)
   - Phase 5: Run `03-cleanup-backups.sql` (drop backups)

3. **Off-peak only**  
   Coordinate with team to run during low-traffic window (10pm–6am preferred).

4. **Rollback ready**  
   If Phase 2 fails, Phase 3 (`02-rollback.sql`) restores original questions instantly.

---

## 🔍 Key Safety Features

✅ **Backup tables** — All original questions/options snapshotted before deletion  
✅ **Idempotent** — Safe to re-run if network fails mid-migration  
✅ **Atomic transactions** — BEGIN…COMMIT ensures all-or-nothing consistency  
✅ **Verification blocks** — Counts verified inside transaction; exception on mismatch  
✅ **RLS policies** — New table has fine-grained row-level security  
✅ **PostgREST cache refresh** — `NOTIFY pgrst` ensures schema reload  
✅ **Rollback procedure** — 02-rollback.sql tested on staging  

---

## ⚠️ Current Production State

- **Active users:** Yes (coaches and students actively taking Module 1 quiz)
- **Real data:** Yes (module_quiz_attempts will start recording on first attempt after migration)
- **Downtime:** No (quiz remains available during migration; questions swap atomically)
- **Data loss risk:** None (all original questions backed up; rollback available for 3+ days)

---

## 📞 Questions Before Deployment?

1. Verify all 5 files present in this directory ✓
2. Confirm target project: `agziuwqpkfmxtospfxns` ✓
3. Review RUNBOOK.md troubleshooting section
4. Confirm off-peak deployment window with team
5. Set Slack reminder for 1–2 day monitoring period

---

## 🎯 Post-Deployment Tasks

After Phase 5 (cleanup):

1. Commit any local changes from app testing to feature branch
2. Create PR from `feature/module1-quiz-rebuild-and-attempts-table` → `main`
3. Code review before merging
4. Monitor app in production for 1 week for any issues
5. Document lessons learned in `docs/memory/patterns.md` if new patterns discovered

---

**Prepared by:** Claude Haiku 4.5  
**Last updated:** 2026-04-29 11:30 UTC
