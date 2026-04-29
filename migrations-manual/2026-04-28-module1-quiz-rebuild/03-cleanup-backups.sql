-- =============================================================================
-- Module 1 Quiz Rebuild — Cleanup Backup Tables
-- Date: 2026-04-28
--
-- Run this ONLY after you have validated the migration in production for
-- a few days and are confident no rollback will be needed.
--
-- Drops the backup tables created by 01-forward.sql.
-- =============================================================================

BEGIN;

DROP TABLE IF EXISTS public.backup_module1_questions_20260428;
DROP TABLE IF EXISTS public.backup_module1_options_20260428;

COMMIT;

SELECT 'Backup tables dropped.' AS status;
