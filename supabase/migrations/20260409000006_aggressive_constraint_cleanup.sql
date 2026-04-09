-- Aggressive cleanup: Remove constraints by direct SQL manipulation

-- For training_content, remove the old constraint by checking its actual name
DO $$
DECLARE
  constraint_name TEXT;
BEGIN
  -- Find and drop the old constraint if it exists
  FOR constraint_name IN
    SELECT c.conname
    FROM pg_constraint c
    JOIN pg_class t ON c.conrelid = t.oid
    WHERE t.relname = 'training_content'
    AND c.contype = 'c'  -- CHECK constraint
    AND c.conname LIKE '%format_type%'
  LOOP
    EXECUTE 'ALTER TABLE public.training_content DROP CONSTRAINT IF EXISTS ' || quote_ident(constraint_name) || ' CASCADE';
  END LOOP;

  -- Now add the correct constraint
  BEGIN
    ALTER TABLE public.training_content
      ADD CONSTRAINT training_content_format_type_check
      CHECK (format_type IN ('slide', 'audio', 'video', 'slides', 'scenario', 'quiz', 'module_quiz'));
  EXCEPTION WHEN duplicate_object THEN
    NULL;
  END;
END $$;

-- For assessments, same approach
DO $$
DECLARE
  constraint_name TEXT;
BEGIN
  -- Find and drop the old type constraint if it exists
  FOR constraint_name IN
    SELECT c.conname
    FROM pg_constraint c
    JOIN pg_class t ON c.conrelid = t.oid
    WHERE t.relname = 'assessments'
    AND c.contype = 'c'  -- CHECK constraint
    AND c.conname LIKE '%type%'
  LOOP
    EXECUTE 'ALTER TABLE public.assessments DROP CONSTRAINT IF EXISTS ' || quote_ident(constraint_name) || ' CASCADE';
  END LOOP;

  -- Now add the correct constraint
  BEGIN
    ALTER TABLE public.assessments
      ADD CONSTRAINT assessments_type_check
      CHECK (type IN ('baseline', 'endline', 'training', 'module_quiz'));
  EXCEPTION WHEN duplicate_object THEN
    NULL;
  END;
END $$;

-- For unique constraint on assessments
DO $$
DECLARE
  constraint_name TEXT;
BEGIN
  -- Find and drop the old unique constraint if it exists
  FOR constraint_name IN
    SELECT c.conname
    FROM pg_constraint c
    JOIN pg_class t ON c.conrelid = t.oid
    WHERE t.relname = 'assessments'
    AND c.contype = 'u'  -- UNIQUE constraint
    AND c.conname LIKE '%training%type%'
  LOOP
    EXECUTE 'ALTER TABLE public.assessments DROP CONSTRAINT IF EXISTS ' || quote_ident(constraint_name) || ' CASCADE';
  END LOOP;

  -- Now add the correct unique constraint
  BEGIN
    ALTER TABLE public.assessments
      ADD CONSTRAINT assessments_training_id_type_unique
      UNIQUE (training_id, type);
  EXCEPTION WHEN duplicate_object THEN
    NULL;
  END;
END $$;
