-- Migration: Add ICT sub-regions with coach-school mappings
-- Purpose: Populate teacher_dc_scores with ICT region data for Smart Scheduler

-- Insert test user profiles for coaches if they don't exist
INSERT INTO public.profiles (id, full_name, phone, region, sub_region)
SELECT
  gen_random_uuid(),
  coach_name,
  '+92300000000',
  'ICT',
  region
FROM (
  SELECT DISTINCT coach_name, 'Urban-1' as region FROM (
    VALUES ('Bushra'), ('Hiba'), ('Hifza'), ('Maroof'), ('Khadija Akbar'), ('Mubashar'), ('Saba'), ('Saima Jabeen'), ('Shazmina'), ('Irum'), ('Aleeha')
  ) AS coaches(coach_name)
  UNION ALL
  SELECT DISTINCT coach_name, 'Urban-2' as region FROM (
    VALUES ('Misbah'), ('Esha Qadeer'), ('Zainab'), ('Waneza'), ('Munira'), ('Hareem'), ('Rabia Javed'), ('Warda'), ('Shafaq Tahir'), ('Mehwish'), ('Aneela')
  ) AS coaches(coach_name)
  UNION ALL
  SELECT DISTINCT coach_name, 'Sihala' as region FROM (
    VALUES ('Ateeb'), ('Hamza'), ('Hira'), ('Meerab'), ('Mehwish'), ('Rida Abbas'), ('Saaim'), ('Moiz')
  ) AS coaches(coach_name)
  UNION ALL
  SELECT DISTINCT coach_name, 'Barakhau' as region FROM (
    VALUES ('Abdul Malik'), ('Ashas Khan'), ('Jamshaid'), ('Javeria Nayab'), ('Javeria Khalil'), ('Hafsa'), ('Nidda Asif'), ('Noman Alam'), ('Zarmeen Kausar'), ('Zarmeen')
  ) AS coaches(coach_name)
  UNION ALL
  SELECT DISTINCT coach_name, 'Tarnol' as region FROM (
    VALUES ('Saman Zahoor')
  ) AS coaches(coach_name)
  UNION ALL
  SELECT DISTINCT coach_name, 'Nilore' as region FROM (
    VALUES ('Areej'), ('Fakhr'), ('Waleed'), ('Maria'), ('Toseef'), ('Mubasher'), ('Sehar')
  ) AS coaches(coach_name)
) as all_coaches
ON CONFLICT (id) DO NOTHING;

-- Update existing teacher_dc_scores records to assign regions based on school names
-- Urban-1 schools
UPDATE public.teacher_dc_scores
SET region = 'Urban-1'
WHERE school_name IN (
  'IMS(I-V) No.2 G-8/4', 'IMS(I-V) PIMS G-8/3', 'IMS(I-V) No.1 G-8/4', 'ICG, F-6/2', 'IMS(I-V) F-6/1',
  'IMS(I-V) G-6/4', 'IMCG, F-8/1', 'IMS(I-V) G-7/4', 'IMS (I-V) G-7/3-3', 'IMSG (I-VIII) F/7-4',
  'IMCB, F-7/3', 'IMCG, ST. 25, F-6/2', 'IMS(I-V) No.1 G-8/2', 'IMS(I-V) No.2 G-8/2', 'IMSG(I-VIII) G-6/2',
  'IMSG (VI-X) G-6/2', 'IMSG (VI-X) F-7/2', 'IMCG (VI-XII), G-6/1-4', 'ICB G-6/3 (Morning) Middle and High',
  'ICB G-6/3 (Evening) Middle And High', 'IMS (I-V) G-6/1-1', 'IMS(I-V) G-7/1', 'IMS(I-V) No.2 E-8',
  'IMSG(I-X) E-9', 'IMSB (I-X) P.M. Colony G-5', 'IMS(I-V) No.1 E-8', 'ICB G-6/3', 'ICB G-6/3 Evening',
  'IMSG (I-VIII) G-7/3-2', 'IMS(I-V) G-7/3-1', 'IMS (I-V) F7/2', 'IMS(I-V) No.2 G-8/1', 'IMS(I-V) No.3 G-8/1',
  'IMSG (I-VIII) F-7/1', 'IMS(I-V) G-6/2', 'IMS(I-V) F-6/3', 'IMS (I-V) F-8/2', 'IMSG, F-7/4',
  'IMS(I-V) No.2 G-7/2', 'IMSG (I-VIII) G-8/4', 'IMS(I-V) G-6/1-2', 'IMS(I-V) E-7/4', 'IMS(I-V) No.1 G-8/1',
  'IMS F8/4', 'IMS (I-V) G-6/1-3', 'IMSG G-5 PM Colony', 'IMSG (I-X) P.E. CLY G-5', 'IMS(I-V) No.1 G-7/2',
  'IMS (I-V) F6/4', 'IMS(I-V) G-6/2 Café Iram', 'IMS (I-VIII) G-7/3-4', 'IMS(I-V) G-6/1-4', 'IMS(I-V) F-8/3',
  'IMS (I-V), F-7/2-4'
);

-- Urban-2 schools
UPDATE public.teacher_dc_scores
SET region = 'Urban-2'
WHERE school_name IN (
  'IMS, No.1, I-9/1', 'IMS(I-V) I-10/2', 'IMS (I-V) No.3, G-9/2', 'IMCB, I-8/3', 'IMCG(VI-XII), I-9/1',
  'IMSB (VI-X) No.1, I-9/4', 'IMS (I-V) G-11/1', 'IMS (I-V) G-11/2', 'IMS (I-V) No.3, St#68, G-9/3', 'IMCB F-11/1',
  'IMSB (VI-X) G-11/2', 'IMSB (VI-X), G-11/2', 'IMS(I-V), I-8/1', 'IMSG (I-X), G-10/3', 'IMCB, I-10/1',
  'IMCB, I-10/1 M & H', 'IMSG (I-VIII), I-10/4', 'IMSG (VI-X), I-10/4', 'IMCB(VI-XII), G-9/4', 'IMS (I-V) No.2, I-10/1',
  'IMS (I-V) No.2, G-9/4', 'IMS (I-V) G-10/1', 'IMS (I-V) No.4, G-9/2', 'IMSG (I-X) G-9/1', 'IMCB G-10/4',
  'IMS (I-V) No.1, G-9/4', 'IMSB (VI-X), G-9/1', 'IMS (I-V) No.1 G-9/2', 'IMS(I-V) No.1 G-9/3', 'IMCG, F-10/2',
  'IMCG(I-XII),F-11/3', 'IMS (I-V) G-9/1', 'IMS (I-V) G-10/4', 'IMSG (I-X), G-11/2', 'IMSG (I-VIII) I-9/4',
  'IMCB, G-11/1', 'IMS (I-V) No.2, G-9/2', 'IMS (I-V) No.2, I-9/4', 'IMSG (VI-X), G-9/4', 'IMS (I-V), F-10/2',
  'IMS (I-V), F-10/4', 'IMS (I-V), F-10/1', 'IMS (I-V), G-10/3', 'IMCB, F-10/3', 'IMSG (VI-X), F-11/1',
  'IMCG G-10/2', 'IMCG, I-10/4 St #23', 'IMSG (I-VIII) I-8/1', 'IMSG (VI-X), I-8/1', 'IMS(I-V) No.2 I-9/1-Co-Edu',
  'IMS (I-V) No.2, St#7, G-9/3', 'IMS (I-V) No.1, I-9/4', 'IMS (I-V) No.1, G-10/2', 'IMS(I-V) No.2 G-10/2-Co-Edu',
  'IMSG(VI-X), G-10/1', 'IMSG (VI-X), I-9/4', 'IMCG I-8/4', 'IMS (I-V) No.1, I-10/1', 'IMS(I-V), AIOU Colony',
  'IMSB (I-VIII), I-8/1, beyond primary', 'IMSB (VI-X) No.2, I-9/4', 'IMSB (VI-X), I-8/4'
);

-- Sihala schools
UPDATE public.teacher_dc_scores
SET region = 'Sihala'
WHERE school_name IN (
  'IMSB (I-X) Gagri', 'IMCG (I-X) PindMalkan', 'IMSG (I-V) GANGOTA SYEDAN', 'IMSG (I-V) Mughal', 'IMSG (I-VIII) Miana Thub',
  'IMSB (I-V)Chak Kamdar', 'IMSG (I-VIII)Peija', 'IMSB (I-V) Sigga', 'IMSB (VI-X) Sihala', 'IMCB Pakistan Town',
  'IMCG, Korang Town', 'IMSG (I-V) PWD Col', 'IMS (I-V) Soan Garden, Lohi Bheer', 'IMSG (I-X) Dhoke Gangal', 'IMSB (I-VIII), Koral',
  'IMSB (I-V) Lohi Bher', 'IMSG (I-V) Sihala', 'IMSG (I-V) CBR Colony', 'IMCG(VI-XII) Humak', 'IMSG (I-VIII) Rajwal',
  'IMSG (I-V) Rawat', 'IMSG (I-V) Sheikhpur', 'IMSG (I-V) Hoon Dhamial', 'IMSB (I-V) Bhangril', 'IMSG (I-X) Humak',
  'IMSG Mohra Nagial', 'IMSG (I-VIII) PTC Sihala', 'IMSB (I-V) Mohri Rawat', 'IMCG(VI-XII). Rawat', 'IMCB Mohra Nagial',
  'IMSG (I-V) (M.T) Humak', 'IMSB (I-V) Sihala', 'IMSB (I-VIII) Herdogher', 'IMSG (I-VIII) Mohri Rawat', 'IMSG (I-VIII) Bhangril',
  'IMSB (I-X) Banni Saran', 'IMSB (I-V) Rajwal', 'IMSB (I-V) Chak', 'IMSG (I-V) Gohra Mast', 'IMSG (I-V) Ladhiot',
  'IMSG (I-V) Sihala Khurd', 'IMSG (I-VIII) Bhimber Trar', 'IMSG (I-V) Mohri Mughal', 'IMSG (I-X) Nara Syedan', 'IMSB (I-X) Dhaliala',
  'IMSG (I-V) Herdogher', 'IMCG(VI-XII) Herdogher', 'IMSG (I-V) Pindory Syedan', 'IMSG (I-X) Gagri', 'IMSG (I-X) Upran Gohra',
  'IMSB (I-V) Bhimber Trar', 'IMSG (I-VIII) Jandala', 'IMSG (I-X) Dhaliala', 'IMSB (I-VIII) Nara Syedan', 'IMSB (I-V) Mughal',
  'IMSG (IV-X) Sihala', 'IMCB (I-XII) F-8/4', 'IMSB (VI-X) G-10/3', 'IMSB (I-V) Kortana', 'IMSG (I-X) R/Col. Rawat',
  'IMSB (I-V) Mohra Kalu', 'IMSB (I-V) D/Mai Nawab', 'IMS (I-V) Gohra Shahan', 'IMSG (I-V) Sihala Mirzian', 'IMSB (I-VIII) Ara Burji',
  'IMSB (I-V) Humak', 'IMCB(VI-XII) Humak', 'IMCB(I-XII), F-8/3', 'IMCB(VI-XII) Mughal', 'IMCB(VI-XII) Rawat',
  'IMCG(VI-XII) Humak', 'IMSG (I-V) Humak', 'IMSG (I-VIII) Niazian', 'IMSB (I-VIII)S/Mirzian', 'IMCG Lohi Bher',
  'IMSB (I-V) Boora Bangial', 'IMSG (I-V)Boora Bangial'
);

-- Barakhau schools
UPDATE public.teacher_dc_scores
SET region = 'Barakhau'
WHERE school_name IN (
  'IMCB (VI-XII) CHAK SHAHZAD', 'IMSB (I-X) BHARA KAU', 'IMSB (I-VIII), MOHRA NOOR NIH', 'IMSG (I-X) TALHAR', 'IMCB (VI-XII) G-7/2',
  'IMSB (VI-X), NOOR PUR SHAHAN', 'IMSB (I-V) MAIRA BEGWAL (evening)', 'IMSB (I-V), BHUDDO', 'IMSB (I-V), NOOR PUR SHAHAN (evening)', 'IMSB (I-V), RUMLI',
  'IMSB (VI-X) RAWAL DAM', 'IMSB (I-X) SAID PUR (Evening)', 'IMSB (I-V), MALOT', 'IMSB (I-V) RAWAL DAM', 'IMSB (I-VIII) CHATTA BAKHTAWAR',
  'IMSG (I-X) MALOT', 'IMSG (I-X) MOHRA NOOR', 'IMSG (I-V), BHARA KAU, NAI ABADI', 'IMSG (I-V) MAIRA MALPUR', 'IMSB (VI-XII) G-6/4',
  'IMSB (I-VIII), MALWAR', 'IMSB (I-X) Phulgran (F.A)', 'IMSB (I-V), DHOKE SYEDAN', 'IMSG (I-V) MAL', 'IMSB (I_V) Kuree',
  'IMSB ( I-V) PALALI', 'IMSB (I-V), KOT HATHIAL, QAZIABAD (evening)', 'IMSB (I-V), KUREE', 'IMSG (I_VIII) BAIN-NALA', 'IMSB (I-V), SIHALI',
  'IMSG (I-X) KURRI', 'IMSG (I-X) PHULGRAN', 'IMSG (I-V) MOHRIAN', 'IMSG (I-V) PIND BEGWAL DANA', 'IMSG (I-V), SHAH PUR',
  'IMSG (I-VIII), BHARA KAU (Eve)', 'IMSB (I-V), DHOKE JERRANI', 'IMSG (I-V), SUBBAN', 'IMSG (I-V), ATHAL', 'IMSB (I-V), ATHAL',
  'IMSG (I-X) GOKINA', 'IMCG (VI-XII) PIND BEGWAL', 'IMCG (I-V) PIND BEGWAL', 'IMSG (I-VIII), SHAHDRA KALAN', 'IMSG (I-VIII), BOBRI',
  'IMSB (I-V), DOHALA SYEDAN', 'IMSG (I-VIII) MANDALA', 'IMSG (I-V), MALPUR (F.A)', 'IMCB Maira Begwal', 'IMCG (I-XII), University Colony (U.C)',
  'IMSG (I-X), SAID PUR', 'IMSB (I-V), PIND BEGWAL', 'IMSB (I-VIII), SATRA MEEL', 'IMSG (I-X) NOORPUR SHAHAN', 'IMCG (I-XII), MARGALLA TOWN',
  'IMSG (I-X), NHC', 'IMCG (I-XII) RAWAL TOWN ISLAMABAD', 'IMSG (I-VIII), KOT HATHIAL', 'IMSG (I-V), (NHC) CHAK SHEHZAD', 'IMSG (I-V) , SHAHZAD TOWN',
  'IMSB (I-X), Talhar', 'IMSB (I-VIII) Jandala', 'IMSB (I-VIII), KOT HATHIAL (NAI ABADI)', 'IMSG (I-X) LAKHWAL', 'IMSB (I-V) Mangial',
  'IMSB (I-VIII), MALPUR', 'IMCB (VI-XII) G-7/2', 'IMSB (I-X) CHATTAR', 'IMSB (I-V) KALRAN', 'IMSG (I-V), DHOKE JERRANI',
  'IMSG (I-V) KOT HATHIAL (NAI ABADI)', 'IMCG (I-XII) MAIRA BEGWAL', 'IMSG (I-VIII), SANJALIAN', 'IMSB (I-V), GOKINA', 'IMSB (I-VIII) BOBRI',
  'IMCG (VI-XII), KOT HATHIYAL', 'IMSB (I-X) SHAHDARA', 'IMSG (I-X) Shahdra Khurd'
);

-- Tarnol schools
UPDATE public.teacher_dc_scores
SET region = 'Tarnol'
WHERE school_name IN (
  'IMCG G-14/4', 'IMCB G-13/2', 'IMCB G-15/1', 'IMSG (I-V) Dhoke Suleman', 'IMSG (I-X) Jhangi Syedan (F.A.)', 'IMCG I-10/1'
);

-- Nilore schools
UPDATE public.teacher_dc_scores
SET region = 'Nilore'
WHERE school_name IN (
  'IMSG Tarlai No.1', 'IMSG (I-V) ALIPUR FARASH', 'IMSG (I-X) JABATAILI', 'IMSG(I-X) NEW SHAKRIAL', 'IMSG(I-V)SHAKRIAL',
  'IMSG(I-V) KHANNA NAI ABADI', 'IMSG(I-V) NO.2 TARLAI', 'IMCG TARLAI', 'IMSG(I-V) ALI PUR (MV)', 'IMSG (I-V) ALIPUR SOUTH',
  'IMSG(I-V)TAMMA', 'IMSG(I-V) PUNJGRAN (760)', 'IMSG(I-V) FRASH TOWN', 'IMCG KIRPA', 'IMSB(I-V) SIRRI',
  'IMSB(I-V) TUMAIR', 'IMSB(I-V) CHIRAH', 'IMSB(I-VIII) DELLA', 'IMSB(I-VIII) PEHOUNT', 'IMSB(I-VIII) KIJNAH',
  'IMSB(I-V)MOHARA SOLINA', 'IMSB(I-V)MOHARA', 'IMSB(I-V)KHADRAPPAR', 'IMSB(I-X) JAGIOT', 'IMCB,JABA TALI',
  'IMSB(I-V)SOHAN', 'IMSB(I-V) JHANG SYDEN', 'IMSB(I-V)TARLAI', 'IMSB(I-V)KHANNA KAK', 'IMSG(I-V) SIMLY DAM',
  'IMSB(I-V)BIATH', 'IMSG (I-VIII) KALIA (FA)', 'IMCG, PEHOUNT', 'IMSB(I-V) NILORE', 'IMCG THANDAPANI',
  'IMSG(I-V) SEVERA', 'IMSG(I-V) DHOK FATHALL', 'IMSG(I-V) JHANG SYEDAN', 'IMSG(I-V) NILORE', 'IMSG(I-VIII) SOHAN',
  'IMSB(I-X)KIRPA', 'IMSB(I-V)PINDMISTRIAN', 'IMSB(I-X) THANDA PANI', 'IMSB(I-VIII) ALI PUR', 'IMSB(I-X) KHANNA DAK',
  'IMSB(I-X) KHANNA NAI ABADI', 'IMSB(I-V)SHARIFABAD', 'IMSB(I-V) BANGIAL', 'IMSB(I-V)ARA', 'IMSG(I-V)HERNO',
  'IMSG(I-V) CHIRAH', 'IMSG (I-VIII) KIJNAH', 'IMCG JAGIOT', 'IMSG(I-V)TUMIAR', 'IMSG(I-V) KALIA NEW',
  'IMSG (I-V) CHAPPAR Ghasota (F.A)', 'IMSG(I-V) CHAKHTAN'
);

-- Verify the updates
SELECT COUNT(*) as total_updated, region FROM public.teacher_dc_scores
WHERE region IN ('Urban-1', 'Urban-2', 'Sihala', 'Barakhau', 'Tarnol', 'Nilore')
GROUP BY region;
