-- Create modules table (top-level containers)
CREATE TABLE public.modules (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title text NOT NULL,
  description text,
  desired_outcomes text,
  competencies text,
  is_mandatory boolean NOT NULL DEFAULT false,
  order_number integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Enable RLS on modules
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone authenticated can view modules"
ON public.modules FOR SELECT
USING (true);

CREATE POLICY "Admins can insert modules"
ON public.modules FOR INSERT
WITH CHECK (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can update modules"
ON public.modules FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete modules"
ON public.modules FOR DELETE
USING (has_role(auth.uid(), 'admin'::app_role));

-- Add module_id to trainings table so they become "units" under a module
ALTER TABLE public.trainings
  ADD COLUMN IF NOT EXISTS module_id uuid REFERENCES public.modules(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS main_concepts text;

-- Update trainings RLS: add update policy for admins
CREATE POLICY "Admins can update trainings"
ON public.trainings FOR UPDATE
USING (has_role(auth.uid(), 'admin'::app_role));

-- Create storage bucket for training videos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'training-videos',
  'training-videos',
  true,
  524288000, -- 500MB limit
  ARRAY['video/mp4', 'video/webm', 'video/ogg', 'video/quicktime', 'video/x-msvideo']
)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS policies
CREATE POLICY "Authenticated users can view training videos"
ON storage.objects FOR SELECT
USING (bucket_id = 'training-videos' AND auth.role() = 'authenticated');

CREATE POLICY "Admins can upload training videos"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'training-videos' AND has_role(auth.uid(), 'admin'::app_role));

CREATE POLICY "Admins can delete training videos"
ON storage.objects FOR DELETE
USING (bucket_id = 'training-videos' AND has_role(auth.uid(), 'admin'::app_role));

-- Trigger to update updated_at on modules
CREATE TRIGGER update_modules_updated_at
BEFORE UPDATE ON public.modules
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
