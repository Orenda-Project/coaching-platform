
CREATE TABLE IF NOT EXISTS rawalpindi_teacher_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_name TEXT NOT NULL,
  school_name TEXT NOT NULL,
  emis TEXT,
  cluster_name TEXT NOT NULL,
  aeo_name TEXT,
  cc_mobile TEXT,
  grade TEXT,
  subject TEXT,
  classroom_management FLOAT NOT NULL DEFAULT 0,
  lesson_planning FLOAT NOT NULL DEFAULT 0,
  instructional_strategies FLOAT NOT NULL DEFAULT 0,
  student_engagement FLOAT NOT NULL DEFAULT 0,
  assessment_feedback FLOAT NOT NULL DEFAULT 0,
  multigrade_setup FLOAT NOT NULL DEFAULT 0,
  total_score FLOAT NOT NULL DEFAULT 0,
  max_total_score FLOAT NOT NULL DEFAULT 51,
  overall_percentage FLOAT NOT NULL DEFAULT 0,
  last_observation_date DATE,
  observation_count INTEGER NOT NULL DEFAULT 0,
  synced_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (teacher_name, school_name, cluster_name)
);

ALTER TABLE rawalpindi_teacher_scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated_read_rawalpindi_teachers"
  ON rawalpindi_teacher_scores
  FOR SELECT
  TO authenticated
  USING (true);

CREATE INDEX IF NOT EXISTS idx_rawalpindi_teacher_scores_cluster
  ON rawalpindi_teacher_scores (cluster_name);

-- Also add rawalpindi_cluster to profiles if missing
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS rawalpindi_cluster TEXT;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES MIANA MOHRA', 'GES MIANA MOHRA', '37330377', 'Chountra', 'TAUQEER AKBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS GHILWAL', 'GPS GHILWAL', '37330339', 'Chountra', 'TAUQEER AKBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS PAPIAN', 'GPS PAPIAN', '37330383', 'Chountra', 'TAUQEER AKBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS KOLIAN GOHRU', 'GPS KOLIAN GOHRU', '37330371', 'Chountra', 'TAUQEER AKBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES RAIKA MIRA', 'GES RAIKA MIRA', '37330385', 'Chountra', 'TAUQEER AKBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES THALLA KHURD', 'GES THALLA KHURD', '37330392', 'Chountra', 'TAUQEER AKBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES HOON', 'GES HOON', '37330145', 'Chountra', 'TAUQEER AKBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS ADHAWAL', 'GPS ADHAWAL', '37330393', 'Chountra', 'TAUQEER AKBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES CHAK BELI KHAN', 'GES CHAK BELI KHAN', '37330396', 'Chountra', 'TAUQEER AKBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES BAGH SANGRA', 'GES BAGH SANGRA', '37330288', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES JAWA', 'GES JAWA', '37330130', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES KURI KHUDA BAKSH', 'GES KURI KHUDA BAKSH', '37330131', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHOK HIMMAT', 'GPS DHOK HIMMAT', '37330298', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS GANDIAN', 'GPS GANDIAN', '37330715', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS JHARAKI', 'GPS JHARAKI', '37330273', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MALANA', 'GPS MALANA', '37330302', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MIAN AHMEDA', 'GPS MIAN AHMEDA', '37330280', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS SHEIKH ZADA', 'GPS SHEIKH ZADA', '37330266', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS TAKHTI', 'GPS TAKHTI', '37330267', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS UNPUR', 'GPS UNPUR', '37330303', 'Jhatta Hathial', 'ABDUL MATEEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHOK RAJA HASSO KHAN', 'GPS DHOK RAJA HASSO KHAN', '37330332', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHOK KHASALA', 'GPS DHOK KHASALA', '37330321', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MAIRA KHURD', 'GPS MAIRA KHURD', '37330253', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS CHACH RAWAN', 'GPS CHACH RAWAN', '37330716', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS SAROBA', 'GPS SAROBA', '37330334', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS SHARIFABAD', 'GPS SHARIFABAD', '37330336', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS CHAK DENAL', 'GPS CHAK DENAL', '37330312', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DAHRI', 'GPS DAHRI', '37330401', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES RAJAR', 'GES RAJAR', '37330140', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES MUJAHID', 'GES MUJAHID', '37330138', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES SANGRAL', 'GES SANGRAL', '37330142', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES DHULIAL', 'GES DHULIAL', '37330259', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES KOLIAN HAMEED', 'GES KOLIAN HAMEED', '37330352', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES GHEELA KALAN', 'GES GHEELA KALAN', '37330361', 'Chakri', 'ATIF MINHAS', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS HAYAL', 'GPS HAYAL', '37330250', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MISRIOT', 'GPS MISRIOT', '37330254', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS CENTRAL JAIL', 'GPS CENTRAL JAIL', '37330305', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHALLA', 'GPS DHALLA', '37330307', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS BODIAL', 'GPS BODIAL', '37330309', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DEGAL', 'GPS DEGAL', '37330315', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHAMIAL', 'GPS DHAMIAL', '37330317', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS SHAHPUR SYEDAN', 'GPS SHAHPUR SYEDAN', '37330335', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS KALRI', 'GPS KALRI', '37330349', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES KHASALA KALLAN', 'GES KHASALA KALLAN', '37330350', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS KHATANA', 'GPS KHATANA', '37330687', 'Adiala', 'ASIF JABBAR', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS BAKRA MANDI', 'GPS BAKRA MANDI', '37330200', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHOK GUJRAN', 'GPS DHOK GUJRAN', '37330204', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHOK MISTRIAN', 'GPS DHOK MISTRIAN', '37330206', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHOK SYEDAN', 'GPS DHOK SYEDAN', '37330208', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GBPS DHOKE ZIARAT', 'GBPS DHOKE ZIARAT', '37330209', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS TULSA', 'GPS TULSA', '37330226', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES LAKHAN', 'GES LAKHAN', '37330241', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS LIAQAT MODEL', 'GPS LIAQAT MODEL', '37330242', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MOHRI GHAZAN', 'GPS MOHRI GHAZAN', '37330249', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES BAJNIAL', 'GES BAJNIAL', '37330257', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS CHAKRA', 'GPS CHAKRA', '37330258', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHOK CHATTA', 'GPS DHOK CHATTA', '37330318', 'RWP Cantt', 'AMIR AQEEL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES MUSLIM GULSHANABAD', 'GES MUSLIM GULSHANABAD', '37330118', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS SHIMLA ISLAMIA', 'GPS SHIMLA ISLAMIA', '37330121', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS AMAR PURA', 'GPS AMAR PURA', '37330199', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS TAJ UL ISLAM', 'GPS TAJ UL ISLAM', '37330223', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MC DHOK PARACHA', 'GPS MC DHOK PARACHA', '37330229', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MC FEROZABAD', 'GPS MC FEROZABAD', '37330230', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MC MUSLIM TOWN', 'GPS MC MUSLIM TOWN', '37330234', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS IQBAL RAHIM TOWN', 'GPS IQBAL RAHIM TOWN', '37330236', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS KHAN ASGHAR MALL', 'GPS KHAN ASGHAR MALL', '37330240', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MANZOOR MUSLIM', 'GPS MANZOOR MUSLIM', '37330244', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MILLAT ISLAMIA', 'GPS MILLAT ISLAMIA', '37330245', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS JHANGIRABAD', 'GPS JHANGIRABAD', '37330251', 'Shakrial', 'WAHEED AHMAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS CHAKLALA', 'GPS CHAKLALA', '37330203', 'Chaklala', 'SHERAZ HUSSAIN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHOK ROSHAN DIN', 'GPS DHOK ROSHAN DIN', '37330207', 'Chaklala', 'SHERAZ HUSSAIN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS QUMI PAY JHANDA CHICHI', 'GPS QUMI PAY JHANDA CHICHI', '37330219', 'Chaklala', 'SHERAZ HUSSAIN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS TANVEER UL ISLAM', 'GPS TANVEER UL ISLAM', '37330225', 'Chaklala', 'SHERAZ HUSSAIN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MC QASIMABAD', 'GPS MC QASIMABAD', '37330233', 'Chaklala', 'SHERAZ HUSSAIN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS JHANDA CHICHI', 'GPS JHANDA CHICHI', '37330238', 'Chaklala', 'SHERAZ HUSSAIN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHOK MUNSHI', 'GPS DHOK MUNSHI', '37330322', 'Chaklala', 'SHERAZ HUSSAIN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS REHMATABAD', 'GPS REHMATABAD', '37330333', 'Chaklala', 'SHERAZ HUSSAIN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MORGAH', 'GPS MORGAH', '37330359', 'Chaklala', 'SHERAZ HUSSAIN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS KOT JABBI', 'GPS KOT JABBI', '37330688', 'Chaklala', 'SHERAZ HUSSAIN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES BANGESH COLONY', 'GES BANGESH COLONY', '37330201', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS DHOK HASSU', 'GPS DHOK HASSU', '37330205', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS NEW PUBLIC RAWALPINDI', 'GPS NEW PUBLIC RAWALPINDI', '37330216', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS POSTAL COLONY', 'GPS POSTAL COLONY', '37330218', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS RATTA AMRAL', 'GPS RATTA AMRAL', '37330221', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS STANDARD MUSLIM KKS', 'GPS STANDARD MUSLIM KKS', '37330222', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS WESTRAGE-I', 'GPS WESTRAGE-I', '37330227', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MC ARJAN NAGAR RAWALPINDI', 'GPS MC ARJAN NAGAR RAWALPINDI', '37330228', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS MC MOHALLAH WORKSHOP RWP', 'GPS MC MOHALLAH WORKSHOP RWP', '37330231', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS HAMIDIA KHAYABAN-E-SIR SYED', 'GPS HAMIDIA KHAYABAN-E-SIR SYED', '37330235', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS ISLAMIA RATTA AMRAL', 'GPS ISLAMIA RATTA AMRAL', '37330237', 'Pirwadai', 'WASEEM ASHRAF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES DODHAR NAJJAR', 'GES DODHAR NAJJAR', '37330125', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES MUJAHID GANGAL', 'GES MUJAHID GANGAL', '37330128', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES MAL JANJAL', 'GES MAL JANJAL', '37330132', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS GOHRA RAMIAL', 'GPS GOHRA RAMIAL', '37330271', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS KHAI AWAN', 'GPS KHAI AWAN', '37330275', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS GHROLI', 'GPS GHROLI', '37330283', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS GOHRA GUJRAN', 'GPS GOHRA GUJRAN', '37330284', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS KALRI BASSALI', 'GPS KALRI BASSALI', '37330285', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS BAGGA SHEIKHAN', 'GPS BAGGA SHEIKHAN', '37330289', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS BANGIAL SAWAN', 'GPS BANGIAL SAWAN', '37330292', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS BASSALI', 'GPS BASSALI', '37330293', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GPS CHAK KHAS', 'GPS CHAK KHAS', '37330294', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GES CHANNI ALAM SHER', 'GES CHANNI ALAM SHER', '37330295', 'Bassali', 'ASIF SHAHZAD', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS KHABA BARALA', 'GMPS KHABA BARALA', '37330370', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS LASMALAI', 'GMPS LASMALAI', '37330374', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS SALMOON', 'GMPS SALMOON', '37330389', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS TALLA BAJAR', 'GGPS TALLA BAJAR', '37330390', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS CHAK SIGHOO', 'GMPS CHAK SIGHOO', '37330397', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS GAGAN', 'GMPS GAGAN', '37330409', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS GANGAL', 'GMPS GANGAL', '37330410', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES BODIAL', 'GGES BODIAL', '37330621', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS CHOKAR', 'GMPS CHOKAR', '37330633', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES DK MUREED', 'GGES DK MUREED', '37330637', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS DHOKE ADRANA', 'GMPS DHOKE ADRANA', '37330638', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS HOON', 'GGPS HOON', '37330649', 'Chauntra', 'ABDULLAH RAHIM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS PIND RANJHA', 'GMPS PIND RANJHA', '37330255', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS PIND MALHU', 'GMPS PIND MALHU', '37330331', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS GURBAL', 'GMPS GURBAL', '37330342', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS JATTAL', 'GMPS JATTAL', '37330345', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS JHANDU SYEDAN', 'GMPS JHANDU SYEDAN', '37330346', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS LAKHOO', 'GGPS LAKHOO', '37330576', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES MOHRI KHATTRAN', 'GGES MOHRI KHATTRAN', '37330585', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS CHAKARA', 'GGPS CHAKARA', '37330598', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS DHOK CHEHR', 'GMPS DHOK CHEHR', '37330606', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS DHUMMA', 'GMPS DHUMMA', '37330608', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS BERKET', 'GGPS BERKET', '37330618', 'Saddar Berooni', 'ATIQA TARIQ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS AKHTER ISLAMIA', 'GGPS AKHTER ISLAMIA', '37330150', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES NEW GIRLS', 'GGES NEW GIRLS', '37330157', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES MURREE ROAD', 'GGES MURREE ROAD', '37330161', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS CARRIAGE FACTORY', 'GGPS CARRIAGE FACTORY', '37330433', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS MANGTAL 1', 'GGPS MANGTAL 1', '37330440', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS MC BANGESH COLONY', 'GGPS MC BANGESH COLONY', '37330451', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DK HASSU', 'GGPS DK HASSU', '37330452', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DK HUKAM DAD', 'GGPS DK HUKAM DAD', '37330453', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS PIRWADHAI', 'GGPS PIRWADHAI', '37330454', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES DHOKE PARACHA', 'GGES DHOKE PARACHA', '37330455', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS NEW PHAGWARI', 'GGPS NEW PHAGWARI', '37330457', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS WARD 28', 'GGPS WARD 28', '37330458', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS CHITTIAN HATTIAN', 'GGPS CHITTIAN HATTIAN', '37330459', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS REHMANIA', 'GGPS REHMANIA', '37330473', 'Pirwadhai', 'Waqas Rao', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES KARAHI', 'GGES KARAHI', '37330195', 'Raika Maira', 'Malik Nadeem Sultan', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS JARA', 'GMPS JARA', '37330366', 'Raika Maira', 'Malik Nadeem Sultan', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS MORJHANG', 'GMPS MORJHANG', '37330381', 'Raika Maira', 'Malik Nadeem Sultan', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS BANIAN', 'GMPS BANIAN', '37330623', 'Raika Maira', 'Malik Nadeem Sultan', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGCMS DHOKE GUJRI', 'GGCMS DHOKE GUJRI', '37330627', 'Raika Maira', 'Malik Nadeem Sultan', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS RAIKA MAIRA', 'GGPS RAIKA MAIRA', '37330654', 'Raika Maira', 'Malik Nadeem Sultan', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES KURAR', 'GGES KURAR', '37330664', 'Raika Maira', 'Malik Nadeem Sultan', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES MISRIAL', 'GGES MISRIAL', '37330669', 'Raika Maira', 'Malik Nadeem Sultan', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS GAHI SYEDAN', 'GMPS GAHI SYEDAN', '37330325', 'Chakri W-EE', 'MARYAM NAEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS GANG', 'GMPS GANG', '37330327', 'Chakri W-EE', 'MARYAM NAEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS GHELLA KHURD', 'GMPS GHELLA KHURD', '37330362', 'Chakri W-EE', 'MARYAM NAEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS HARNIALI SYEDAN', 'GMPS HARNIALI SYEDAN', '37330364', 'Chakri W-EE', 'MARYAM NAEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS MOHRA CHAKRI', 'GMPS MOHRA CHAKRI', '37330380', 'Chakri W-EE', 'MARYAM NAEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS DANDI GUJRAN', 'GMPS DANDI GUJRAN', '37330400', 'Chakri W-EE', 'MARYAM NAEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES DHERI', 'GGES DHERI', '37330634', 'Chakri W-EE', 'MARYAM NAEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES GHELA KALAN', 'GGES GHELA KALAN', '37330643', 'Chakri W-EE', 'MARYAM NAEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS TATRAL', 'GGPS TATRAL', '37330657', 'Chakri W-EE', 'MARYAM NAEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS JASWAL', 'GMPS JASWAL', '37330661', 'Chakri W-EE', 'MARYAM NAEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS CHOORA', 'GMPS CHOORA', '37330314', 'Kolian Hameed', 'MEMOONA SAEED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS KHILRI', 'GGPS KHILRI', '37330569', 'Kolian Hameed', 'MEMOONA SAEED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS MALUKAL', 'GMPS MALUKAL', '37330580', 'Kolian Hameed', 'MEMOONA SAEED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS CHAKRAN', 'GMPS CHAKRAN', '37330599', 'Kolian Hameed', 'MEMOONA SAEED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES GANGAWALA', 'GGES GANGAWALA', '37330610', 'Kolian Hameed', 'MEMOONA SAEED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS BILAWAL', 'GMPS BILAWAL', '37330620', 'Kolian Hameed', 'MEMOONA SAEED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES DHADHAMBER', 'GGES DHADHAMBER', '37330630', 'Kolian Hameed', 'MEMOONA SAEED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES ANWAR UL ISLAM', 'GGES ANWAR UL ISLAM', '37330151', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES SHOKAT SADDAR', 'GGES SHOKAT SADDAR', '37330165', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DHOK RAHEEM BAKSH', 'GGPS DHOK RAHEEM BAKSH', '37330443', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS MC CHAMAN ZAR', 'GGPS MC CHAMAN ZAR', '37330446', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS MC ARIA MUHALLA', 'GGPS MC ARIA MUHALLA', '37330450', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES NASEERABAD', 'GGES NASEERABAD', '37330461', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS JHAWRA', 'GGPS JHAWRA', '37330488', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS JORIAN', 'GGPS JORIAN', '37330565', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS LAKHAN', 'GGPS LAKHAN', '37330575', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS LIAQAT COLONY', 'GGPS LIAQAT COLONY', '37330578', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS MOHRA TULLA', 'GGPS MOHRA TULLA', '37330584', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS BANDA NAGGIAL', 'GGPS BANDA NAGGIAL', '37330709', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DHOK ZIARAT', 'GGPS DHOK ZIARAT', '37330710', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES BRITISH HOMES', 'GGES BRITISH HOMES', '37330717', 'Cantt', 'NIGHAT NOREEN', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES ARAZI SOHAL', 'GGES ARAZI SOHAL', '37330172', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES DADHOCHA', 'GGES DADHOCHA', '37330175', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES DHAKALA', 'GGES DHAKALA', '37330176', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS MOHRA BHATAN', 'GMPS MOHRA BHATAN', '37330281', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS BARWALA', 'GMPS BARWALA', '37330300', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS SAGRI', 'GMPS SAGRI', '37330504', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES JUMMAT MUGHAL', 'GGES JUMMAT MUGHAL', '37330512', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS LOHDRA', 'GMPS LOHDRA', '37330519', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS CHATRO', 'GGPS CHATRO', '37330530', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS GURAH RAMIAL', 'GGPS GURAH RAMIAL', '37330531', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DADHAR NAJJAR', 'GGPS DADHAR NAJJAR', '37330532', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS DAWRI', 'GMPS DAWRI', '37330534', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS ABAN CHAK', 'GMPS ABAN CHAK', '37330547', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGCMS MOHRI KHAMBAL', 'GGCMS MOHRI KHAMBAL', '37330556', 'Lodhran', 'RABBIA RAUF', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES MUJAHID GANGAL W', 'GGES MUJAHID GANGAL W', '37330179', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS SAFAIR', 'GMPS SAFAIR', '37330263', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS SAMLAL', 'GMPS SAMLAL', '37330264', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS WARIAMA', 'GMPS WARIAMA', '37330269', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS SARHANDI', 'GGPS SARHANDI', '37330497', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS SARHADNY', 'GGPS SARHADNY', '37330505', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS TIMBER RATIAL', 'GGPS TIMBER RATIAL', '37330509', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS MARI BANGIAL', 'GGPS MARI BANGIAL', '37330522', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES MAIRA MOHRA', 'GGES MAIRA MOHRA', '37330524', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS MOHRA SAWAIN', 'GGPS MOHRA SAWAIN', '37330527', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DROGHA HASSAN ALI', 'GGPS DROGHA HASSAN ALI', '37330544', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS JABBAR DERVAISH', 'GGPS JABBAR DERVAISH', '37330546', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES BANDA', 'GGES BANDA', '37330551', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES JHARAKI W', 'GGES JHARAKI W', '37330555', 'Bassali W-EE', 'SADIA AZIZ', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS PIAL', 'GMPS PIAL', '37330262', 'Bagga Sheikhan', 'SAFIA AFTAB', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS SUMBAL', 'GGPS SUMBAL', '37330507', 'Bagga Sheikhan', 'SAFIA AFTAB', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS KALIAM MUGHAL', 'GGPS KALIAM MUGHAL', '37330513', 'Bagga Sheikhan', 'SAFIA AFTAB', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS MAIRA BHARTHA', 'GGPS MAIRA BHARTHA', '37330521', 'Bagga Sheikhan', 'SAFIA AFTAB', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS CHANNI ALAM SHER W', 'GGPS CHANNI ALAM SHER W', '37330529', 'Bagga Sheikhan', 'SAFIA AFTAB', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS GOHARA BHARATHA', 'GGPS GOHARA BHARATHA', '37330542', 'Bagga Sheikhan', 'SAFIA AFTAB', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS BAGGA SHEIKHAN NO1', 'GGPS BAGGA SHEIKHAN NO1', '37330548', 'Bagga Sheikhan', 'SAFIA AFTAB', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS BAGGA SANGRAL', 'GGPS BAGGA SANGRAL', '37330549', 'Bagga Sheikhan', 'SAFIA AFTAB', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES HARRAKA', 'GGES HARRAKA', '37330553', 'Bagga Sheikhan', 'SAFIA AFTAB', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS NO2 BAGGA SHEIKHAN', 'GGPS NO2 BAGGA SHEIKHAN', '37330704', 'Bagga Sheikhan', 'SAFIA AFTAB', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS BAGRA SYEDAN', 'GMPS BAGRA SYEDAN', '37330256', 'Sihal', 'SANIA NASEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES MUJAHID SIHAL', 'GGES MUJAHID SIHAL', '37330587', 'Sihal', 'SANIA NASEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS DK CHAACH', 'GMPS DK CHAACH', '37330605', 'Sihal', 'SANIA NASEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DK MALKAN', 'GGPS DK MALKAN', '37330607', 'Sihal', 'SANIA NASEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES PIND HABTAL', 'GGES PIND HABTAL', '37330612', 'Sihal', 'SANIA NASEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS JADA', 'GMPS JADA', '37330613', 'Sihal', 'SANIA NASEEM', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES JABBAR MIANA', 'GGES JABBAR MIANA', '37330129', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS KALI PARI', 'GMPS KALI PARI', '37330369', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS UNPUR W', 'GGPS UNPUR W', '37330511', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS KHARAKAN', 'GGPS KHARAKAN', '37330515', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS KHINGER KALAN', 'GGPS KHINGER KALAN', '37330516', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS LILA KAMAL PUR', 'GGPS LILA KAMAL PUR', '37330518', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES DK BUDHAL', 'GGES DK BUDHAL', '37330537', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DHUDIAN', 'GGPS DHUDIAN', '37330538', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS FEROZY', 'GGPS FEROZY', '37330539', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS GANGAL JH', 'GMPS GANGAL JH', '37330540', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES HOSHIAL', 'GGES HOSHIAL', '37330554', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES MOHRA JH', 'GGES MOHRA JH', '37330629', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES NIKRALI', 'GGES NIKRALI', '37330706', 'Jhatta Hathial W', 'SEHRISH KANWAL', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS HAKIMAL', 'GMPS HAKIMAL', '37330363', 'Chak Beli Khan', 'SHAKOOR AHMED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS JHANGI DAIM', 'GMPS JHANGI DAIM', '37330368', 'Chak Beli Khan', 'SHAKOOR AHMED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS PINDORI', 'GMPS PINDORI', '37330384', 'Chak Beli Khan', 'SHAKOOR AHMED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS RUPPER KHURD', 'GMPS RUPPER KHURD', '37330388', 'Chak Beli Khan', 'SHAKOOR AHMED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS BAINS', 'GMPS BAINS', '37330411', 'Chak Beli Khan', 'SHAKOOR AHMED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DK ALI BHADUR', 'GGPS DK ALI BHADUR', '37330639', 'Chak Beli Khan', 'SHAKOOR AHMED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGMPS DK BHATIAN', 'GGMPS DK BHATIAN', '37330640', 'Chak Beli Khan', 'SHAKOOR AHMED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGMPS THALLA KALAN', 'GGMPS THALLA KALAN', '37330658', 'Chak Beli Khan', 'SHAKOOR AHMED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES THALLA KHURD W', 'GGES THALLA KHURD W', '37330659', 'Chak Beli Khan', 'SHAKOOR AHMED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS MEHMOODA', 'GMPS MEHMOODA', '37330667', 'Chak Beli Khan', 'SHAKOOR AHMED', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DK KAMMA KHAN', 'GGPS DK KAMMA KHAN', '37330701', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS KHINGER', 'GMPS KHINGER', '37330351', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES DK KALA KHAM', 'GGES DK KALA KHAM', '37330559', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES KOTHA KALLAN', 'GGES KOTHA KALLAN', '37330561', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS KALAS', 'GGPS KALAS', '37330566', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS KHASALA KHURD', 'GGPS KHASALA KHURD', '37330568', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS KOHALA KALLAN', 'GGPS KOHALA KALLAN', '37330571', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS KOHALA SYEDAN', 'GGPS KOHALA SYEDAN', '37330572', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GMPS LADIAN', 'GMPS LADIAN', '37330574', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS MAIRA KHURD ADD', 'GGPS MAIRA KHURD ADD', '37330583', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS MORGAH ADD', 'GGPS MORGAH ADD', '37330586', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGES JAIL COLONY', 'GGES JAIL COLONY', '37330614', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;

INSERT INTO rawalpindi_teacher_scores (teacher_name, school_name, emis, cluster_name, aeo_name, total_score, max_total_score, overall_percentage, observation_count)
VALUES ('GGPS DHOKE BABA', 'GGPS DHOKE BABA', '37330708', 'Addyala', 'TASNEEM SHEHZADI', 0, 51, 0, 0)
ON CONFLICT (teacher_name, school_name, cluster_name) DO NOTHING;
