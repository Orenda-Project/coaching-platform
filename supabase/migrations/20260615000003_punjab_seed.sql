-- Punjab teacher scores seed — sourced from Moawin observation data sheet (2026-06-15)
-- 73 unique teachers across 16 clusters; latest non-zero onspot observation per teacher

INSERT INTO punjab_teacher_scores
  (teacher_name, school_name, emis, cluster_name, cc_name, cc_mobile, grade, subject,
   classroom_management, lesson_planning, instructional_strategies, student_engagement,
   assessment_feedback, multigrade_setup, total_score, max_total_score, overall_percentage,
   last_observation_date, observation_count)
VALUES
  -- Cluster Aorangabad (cc: Zahoor Abbas)
  ('Hajra bibi','GPS CHHAJI MAR','37140104','Cluster Aorangabad','Zahoor Abbas','03025199095','Grade 3','Math',9,7,6,7,7,0,36,51,70.6,'2026-04-29',1),
  ('Shakila Naz','GPS CHHAJI MAR','37140104','Cluster Aorangabad','Zahoor Abbas','03025199095','Grade 2','English',5,5,6,4,5,0,25,51,49.0,'2026-04-29',1),
  ('Noor ul Ain','GPS DHOK MOHRI','37140108','Cluster Aorangabad','Zahoor Abbas','03025199095','Grade 1','Urdu',5,5,8,5,5,0,28,51,54.9,'2026-04-29',1),

  -- Cluster Chab (cc: Suhail Abbas)
  ('Rizwana Yasmeen','GGPS SUKWAN','37140300','Cluster Chab','Suhail Abbas','03485705755','Grade 1','English',3,3,4,3,3,0,16,51,31.4,'2026-05-21',1),
  ('Hira Shabir','GGPS SUKWAN','37140300','Cluster Chab','Suhail Abbas','03485705755','Grade 5','Science',3,3,4,3,3,0,16,51,31.4,'2026-05-21',1),
  ('Marina Fatima','GPS CHHAB','37140156','Cluster Chab','Suhail Abbas','03485705755','Grade 3','Urdu',5,5,5,3,3,0,21,51,41.2,'2026-05-12',4),
  ('Sabira Tufail','GPS DHOK MANJOKHA','37140064','Cluster Chab','Suhail Abbas','03485705755','Grade 3','English',3,3,4,3,3,0,16,51,31.4,'2026-05-06',2),

  -- Cluster Dakhnair (cc: Mehtab)
  ('Nighat Yasmin','GGPS DHOK BAZ GUL','37140284','Cluster Dakhnair','Mehtab','03363193635','Grade 3','English',3,3,4,3,3,0,16,51,31.4,'2026-05-22',1),
  ('Uzma Ameer','GGPS JABBI','37140295','Cluster Dakhnair','Mehtab','03363193635','Grade 4','English',3,3,4,3,3,0,16,51,31.4,'2026-05-22',1),
  ('Samreen Bibi','GGPS JABBI','37140295','Cluster Dakhnair','Mehtab','03363193635','Grade 2','Math',3,3,4,3,3,0,16,51,31.4,'2026-05-22',2),
  ('Iram Fatima','GGPS RATTI KIRI','37140293','Cluster Dakhnair','Mehtab','03363193635','Grade 5','Math',3,3,4,3,3,0,16,51,31.4,'2026-05-22',4),
  ('Shazia Parveen','GPS AMRATI','37140068','Cluster Dakhnair','Mehtab','03363193635','Grade 4','Math',3,3,4,3,3,0,16,51,31.4,'2026-05-17',5),
  ('Salma Mamtaz','GPS DHOK BAZGUL','37140168','Cluster Dakhnair','Mehtab','03363193635','Grade 2','English',3,3,4,3,3,0,16,51,31.4,'2026-05-22',1),
  ('Saira Amjad','GPS DHOK HINDU','37140172','Cluster Dakhnair','Mehtab','03363193635','Grade 2','Math',3,3,4,3,3,0,16,51,31.4,'2026-05-22',2),
  ('Rukhsana Hameed','GPS DUPPER','37140171','Cluster Dakhnair','Mehtab','03363193635','Prep','English',3,3,4,3,3,0,16,51,31.4,'2026-05-04',4),
  ('Alishba Eiman','GPS JABBI (JHAMAT)','37140167','Cluster Dakhnair','Mehtab','03363193635','Grade 3','English',3,3,4,3,3,0,16,51,31.4,'2026-05-22',1),
  ('Shabana Tariq','GPS JABBI (JHAMAT)','37140167','Cluster Dakhnair','Mehtab','03363193635','Grade 2','English',3,3,4,3,3,0,16,51,31.4,'2026-05-22',1),
  ('Sadat hussain','GPS MALLANGI','37140159','Cluster Dakhnair','Mehtab','03363193635','Grade 3','English',3,3,4,3,3,0,16,51,31.4,'2026-05-04',1),
  ('Amber jabeen','GPS RATTI KIRRI','37140170','Cluster Dakhnair','Mehtab','03363193635','Grade 4','Math',3,3,4,3,3,0,16,51,31.4,'2026-05-22',3),
  ('Aqsa Rehman','GPS RATTI KIRRI','37140170','Cluster Dakhnair','Mehtab','03363193635','Grade 3','Math',3,3,4,3,3,0,16,51,31.4,'2026-05-22',2),

  -- Cluster Injra (cc: Babar)
  ('Sehrish Ibrahim','GGPS Jaba','37140260','Cluster Injra','Babar','03116911573','Grade 5','English',7,6,8,7,5,0,33,51,64.7,'2026-05-05',2),
  ('Neha Jalil','GGPS NAKKA KHURD','37140292','Cluster Injra','Babar','03116911573','Grade 3','Math',7,7,10,8,7,0,39,51,76.5,'2026-05-18',1),
  ('Rozina Anwar','GPS CHHOI (MAKHAD)','37140176','Cluster Injra','Babar','03116911573','Grade 2','Math',7,5,9,5,5,0,31,51,60.8,'2026-05-18',1),
  ('Sumayyah Shabbir','GPS DHOK HABIB','37140356','Cluster Injra','Babar','03116911573','Grade 4','Math',4,5,8,5,5,0,27,51,52.9,'2026-05-19',1),
  ('Nadia Shehnaz','GPS DHOK NILHAD (JAND)','37140177','Cluster Injra','Babar','03116911573','Grade 3','Math',7,5,9,7,5,0,33,51,64.7,'2026-05-18',1),
  ('ulfat Noreen','GPS KOTE WALI','37140149','Cluster Injra','Babar','03116911573','Grade 5','Urdu',5,6,8,4,6,0,29,51,56.9,'2026-05-19',1),
  ('Laila Arif','GPS NAKKA KHURD','37140175','Cluster Injra','Babar','03116911573','Grade 5','Math',6,5,8,7,6,0,32,51,62.7,'2026-05-20',2),

  -- Cluster Jand (cc: Tauqeer)
  ('Asifa noureen','GGPS DHOK QAZI (LANGER)','37140250','Cluster Jand','Tauqeer','03459654290','Grade 4','Urdu',5,7,6,4,4,0,26,51,51.0,'2026-05-11',1),
  ('Madiha Akram','GGPS DINGI NARI','37140249','Cluster Jand','Tauqeer','03459654290','Grade 3','English',6,6,8,5,6,0,31,51,60.8,'2026-05-21',1),
  ('Rimsha mehreen','GGPS LANGAR','37140241','Cluster Jand','Tauqeer','03459654290','Grade 4','English',7,7,8,6,6,0,34,51,66.7,'2026-05-18',1),
  ('Nazia Batool','GPS DHOK CHUDRIAN','37140141','Cluster Jand','Tauqeer','03459654290','Grade 3','English',7,6,7,5,5,0,30,51,58.8,'2026-05-21',1),
  ('Naseem Akhtar','GPS GHANDIAN','37140380','Cluster Jand','Tauqeer','03459654290','Grade 4','English',5,7,10,5,5,0,32,51,62.7,'2026-05-14',1),
  ('Sumaira bibi','GPS JAND NO.3','37140046','Cluster Jand','Tauqeer','03459654290','Grade 4','English',5,5,7,5,5,0,27,51,52.9,'2026-05-05',2),

  -- Cluster Mithial (cc: Ammar)
  ('Aneeqa hayat','GGPS DHOK KUND','37140188','Cluster Mithial','Ammar','03184096302','Grade 2','Math',5,4,6,6,4,0,25,51,49.0,'2026-05-21',1),
  ('Tamseel Zahra','GGPS DHOK KUND','37140188','Cluster Mithial','Ammar','03184096302','Grade 4','English',7,7,8,7,9,0,38,51,74.5,'2026-04-29',2),
  ('Gulista Zahra','GGPS KAHAL','37140220','Cluster Mithial','Ammar','03184096302','Grade 1','English',5,4,7,4,4,0,24,51,47.1,'2026-05-21',1),
  ('Fatima-tur-Rida','GGPS KALARIAN','37140208','Cluster Mithial','Ammar','03184096302','Grade 1','Math',6,6,8,6,8,0,34,51,66.7,'2026-05-14',1),
  ('JANAT KHAN','GGPS KALARIAN','37140208','Cluster Mithial','Ammar','03184096302','Grade 4','Urdu',0,0,0,0,0,0,0,51,0.0,'2026-05-14',1),
  ('Azra jabeen','GGPS MARMAKI','37140257','Cluster Mithial','Ammar','03184096302','Grade 4','Urdu',5,4,5,4,4,0,22,51,43.1,'2026-05-19',1),
  ('Fouzia Gul','GGPS MIRWAL','37140218','Cluster Mithial','Ammar','03184096302','Grade 2','Urdu',5,3,5,4,5,0,22,51,43.1,'2026-05-19',1),
  ('Ambreen Akhter','GGPS MIRWAL','37140218','Cluster Mithial','Ammar','03184096302','Prep','English',4,5,6,4,4,0,23,51,45.1,'2026-05-19',1),
  ('NIMRA SULTANA','GPS JANDIAL','37140120','Cluster Mithial','Ammar','03184096302','Grade 5','English',5,4,7,5,4,0,25,51,49.0,'2026-05-19',1),
  ('Ammara Nosheen','GPS JANDIAL','37140120','Cluster Mithial','Ammar','03184096302','Grade 4','English',5,5,6,5,3,0,24,51,47.1,'2026-05-19',1),

  -- Cluster Nara (cc: Zeeshan)
  ('Sehrish Shaukat','GGPS KUNDRALA','37140231','Cluster Nara','Zeeshan','03023503164','Grade 4','Urdu',6,6,9,6,6,0,33,51,64.7,'2026-05-13',1),

  -- Cluster Salmanabad (cc: Shabbir Ahmad)
  ('Muqaddas noor','GGPS ALAMSHERI','37140183','Cluster Salmanabad','Shabbir Ahmad','03418825428','Grade 5','English',8,7,10,8,8,0,41,51,80.4,'2026-05-13',1),
  ('aqsa bibi','GGPS DHOK WARA','37140191','Cluster Salmanabad','Shabbir Ahmad','03418825428','Grade 5','English',8,7,10,7,8,0,40,51,78.4,'2026-05-11',1),
  ('Maria Afzal','GPS BASAL','37140112','Cluster Salmanabad','Shabbir Ahmad','03418825428','Grade 3','English',6,7,9,7,7,0,36,51,70.6,'2026-05-05',2),
  ('Malaika Javed','GPS DHOK WARA','37140114','Cluster Salmanabad','Shabbir Ahmad','03418825428','Grade 5','English',5,4,7,4,5,0,25,51,49.0,'2026-05-13',1),

  -- Cluster Tarap (cc: Wajahat)
  ('Nafeesa Almas','GGPS INJRA AFGHANA','37140303','Cluster Tarap','Wajahat','03360333105','Grade 1','Math',5,4,5,4,5,0,23,51,45.1,'2026-05-18',1),
  ('Amna Ibrar','GPS DHOK GHAGGI','37140371','Cluster Tarap','Wajahat','03360333105','Grade 2','Math',4,4,6,4,3,0,21,51,41.2,'2026-05-13',1),
  ('Asia Faerheen','GPS DHOK LOON TARAP','37140147','Cluster Tarap','Wajahat','03360333105','Grade 3','English',3,3,7,4,4,0,21,51,41.2,'2026-05-13',1),
  ('Maria Kanwal','GPS MANJA GHUNDI','37140150','Cluster Tarap','Wajahat','03360333105','Grade 5','Math',5,5,7,4,5,0,26,51,51.0,'2026-05-05',2),

  -- Cluster Thatta (cc: Shuail Ameer)
  ('Shagufta bibi','GGPS GANDAKAS','37140226','Cluster Thatta','Shuail Ameer','03288664941','Grade 5','English',5,6,7,5,5,0,28,51,54.9,'2026-05-21',1),
  ('Qurat Ul Ain','GPS DHOK MAIDA','37140133','Cluster Thatta','Shuail Ameer','03288664941','Grade 5','English',9,9,12,9,9,0,48,51,94.1,'2026-05-05',3),
  ('Maryam Bibi','GPS MINHALI','37140139','Cluster Thatta','Shuail Ameer','03288664941','Grade 4','English',5,6,8,5,5,0,29,51,56.9,'2026-05-21',1),
  ('Saba Gull','GPS MOHRI (THATTA)','37140140','Cluster Thatta','Shuail Ameer','03288664941','Grade 5','Urdu',6,6,8,5,5,0,30,51,58.8,'2026-05-21',1),

  -- Cluster Ziyarat (cc: Ali Hamza)
  ('Nadia bibi','GPS HAJI MUNDIAL','37140383','Cluster Ziyarat','Ali Hamza','03415619448','Grade 5','Math',6,7,11,7,6,0,37,51,72.5,'2026-04-30',1),
  ('Samina Akhter','GPS TARAP GULIYAL','37140400','Cluster Ziyarat','Ali Hamza','03415619448','Grade 5','English',6,6,8,6,8,0,34,51,66.7,'2026-04-30',1),
  ('Waheeda Bibi','GPS TARAP GULIYAL','37140400','Cluster Ziyarat','Ali Hamza','03415619448','Prep','English',9,7,12,9,9,0,46,51,90.2,'2026-04-30',1),

  -- Dhurnal (cc: Muhammad Zeeshan)
  ('Sana Waqar','GGPS DHOK KHANA','37420308','Dhurnal','Muhammad Zeeshan','03025494348','Grade 5','Islamiat',0,0,0,0,0,0,0,51,0.0,'2026-05-18',2),
  ('Sadaf Sultan','GGPS HAJIAL','37420307','Dhurnal','Muhammad Zeeshan','03025494348','Grade 2','Math',9,7,11,9,7,0,43,51,84.3,'2026-05-20',2),

  -- Kot Gulla (cc: Muhammad Ijaz)
  ('Uma Kalsoom','GGCMPS LAITI','37420492','Kot Gulla','Muhammad Ijaz','03022483339','Grade 5','Urdu',6,7,9,7,6,0,35,51,68.6,'2026-05-19',1),
  ('Saira Yasmeen','GGPS LARIAN','37420509','Kot Gulla','Muhammad Ijaz','03022483339','Grade 3','Urdu',5,7,8,7,7,0,34,51,66.7,'2026-05-17',1),
  ('Zahida parveen','GPS DHOK CHATHA','37420114','Kot Gulla','Muhammad Ijaz','03022483339','Grade 3','Urdu',7,6,9,7,6,0,35,51,68.6,'2026-05-20',1),
  ('Abida Perveen','GPS DHOK CHATHA','37420114','Kot Gulla','Muhammad Ijaz','03022483339','Grade 5','Urdu',7,7,9,8,6,0,37,51,72.5,'2026-05-20',1),
  ('Rubina Khanam','GPS DHOK SHARFA','37420434','Kot Gulla','Muhammad Ijaz','03022483339','Grade 4','Urdu',0,0,0,0,0,0,0,51,0.0,'2026-05-19',1),

  -- Lawa (cc: Gulraiz Jalil)
  ('Rubina Nadeem Malik','GGPS DHOK HAKMAL','37420352','Lawa','Gulraiz Jalil','03007294604','Prep','Urdu',8,8,11,7,8,0,42,51,82.4,'2026-05-20',1),
  ('Iqra Rameen','GGPS NOOR JAMAL','37420338','Lawa','Gulraiz Jalil','03007294604','Grade 1','Urdu',6,7,10,7,6,0,36,51,70.6,'2026-05-20',1),
  ('Insbat Asif','GPS SHAH GUL HUSSAN','37420182','Lawa','Gulraiz Jalil','03007294604','Grade 2','Math',9,9,11,8,8,0,45,51,88.2,'2026-05-20',1),

  -- Pichnand (cc: Tahira Yasmeen)
  ('Shabila Mushtaq','GGPS DHADHUMAR COLONY','37420347','Pichnand','Tahira Yasmeen','03318044776','Grade 3','English',6,6,8,6,6,0,32,51,62.7,'2026-05-20',1),
  ('Moneeba Iftikhar','GGPS DHOK SHERBAZ','37420346','Pichnand','Tahira Yasmeen','03318044776','Grade 4','English',7,6,9,7,7,0,36,51,70.6,'2026-05-21',1),
  ('Irza Faisal','GGPS DHOK SOKI','37420343','Pichnand','Tahira Yasmeen','03318044776','Grade 5','Math',6,6,8,6,6,0,32,51,62.7,'2026-05-21',1),

  -- attock (cc: Mubashir Ali)
  ('sehir nawaz','GBPS DHOK FATEH','37110093','attock','Mubashir Ali','03111545249','Grade 3','English',5,7,10,5,5,0,32,51,62.7,'2026-05-18',1)

ON CONFLICT (teacher_name, school_name, cluster_name) DO UPDATE SET
  emis = EXCLUDED.emis,
  cc_name = EXCLUDED.cc_name,
  cc_mobile = EXCLUDED.cc_mobile,
  grade = EXCLUDED.grade,
  subject = EXCLUDED.subject,
  classroom_management = EXCLUDED.classroom_management,
  lesson_planning = EXCLUDED.lesson_planning,
  instructional_strategies = EXCLUDED.instructional_strategies,
  student_engagement = EXCLUDED.student_engagement,
  assessment_feedback = EXCLUDED.assessment_feedback,
  multigrade_setup = EXCLUDED.multigrade_setup,
  total_score = EXCLUDED.total_score,
  max_total_score = EXCLUDED.max_total_score,
  overall_percentage = EXCLUDED.overall_percentage,
  last_observation_date = EXCLUDED.last_observation_date,
  observation_count = EXCLUDED.observation_count,
  synced_at = NOW();
