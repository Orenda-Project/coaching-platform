
-- Allow admins to manage assessments
CREATE POLICY "Admins can insert assessments"
ON public.assessments FOR INSERT
WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update assessments"
ON public.assessments FOR UPDATE
USING (public.has_role(auth.uid(), 'admin'));

-- Allow admins to manage questions
CREATE POLICY "Admins can insert questions"
ON public.questions FOR INSERT
WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update questions"
ON public.questions FOR UPDATE
USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete questions"
ON public.questions FOR DELETE
USING (public.has_role(auth.uid(), 'admin'));

-- Allow admins to manage options
CREATE POLICY "Admins can insert options"
ON public.options FOR INSERT
WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can update options"
ON public.options FOR UPDATE
USING (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete options"
ON public.options FOR DELETE
USING (public.has_role(auth.uid(), 'admin'));

-- Allow admins to manage training content
CREATE POLICY "Admins can insert training content"
ON public.training_content FOR INSERT
WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete training content"
ON public.training_content FOR DELETE
USING (public.has_role(auth.uid(), 'admin'));

-- Allow admins to manage trainings
CREATE POLICY "Admins can insert trainings"
ON public.trainings FOR INSERT
WITH CHECK (public.has_role(auth.uid(), 'admin'));

CREATE POLICY "Admins can delete trainings"
ON public.trainings FOR DELETE
USING (public.has_role(auth.uid(), 'admin'));
