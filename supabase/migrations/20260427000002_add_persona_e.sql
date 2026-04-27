-- Add Persona E support (entry-level, <60% baseline score)
-- Update the CHECK constraint to allow 'E'
ALTER TABLE public.profiles
DROP CONSTRAINT profiles_persona_check;

ALTER TABLE public.profiles
ADD CONSTRAINT profiles_persona_check CHECK (persona IN ('A', 'B', 'C', 'D', 'E'));

-- Also update trainings table if it has persona_required constraint
ALTER TABLE public.trainings
DROP CONSTRAINT IF EXISTS trainings_persona_required_check;

ALTER TABLE public.trainings
ADD CONSTRAINT trainings_persona_required_check CHECK (persona_required IN ('A', 'B', 'C', 'D', 'E'));
