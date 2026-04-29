-- =============================================================================
-- PRODUCTION CLEANUP — Drop Backup Tables
-- Date: 2026-04-28
--
-- RUN THIS ONLY after you have validated the forward migration (01-forward.sql)
-- in production for a few days and are confident no rollback will be needed.
--
-- This script drops the backup tables created by 01-forward.sql.
-- =============================================================================

BEGIN;

DROP TABLE IF EXISTS public.backup_module1_questions_20260428;
DROP TABLE IF EXISTS public.backup_module1_options_20260428;

COMMIT;

SELECT 'Backup tables dropped. Migration is finalized.' AS status;
