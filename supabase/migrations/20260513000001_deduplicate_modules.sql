-- Remove duplicate Module 1 entries, keeping only one

WITH module1_duplicates AS (
  SELECT id, title, order_number,
    ROW_NUMBER() OVER (PARTITION BY order_number ORDER BY created_at ASC) as rn
  FROM public.modules
  WHERE title LIKE 'Module 1:%'
    AND order_number = 1
)
DELETE FROM public.modules
WHERE id IN (
  SELECT id FROM module1_duplicates WHERE rn > 1
);
