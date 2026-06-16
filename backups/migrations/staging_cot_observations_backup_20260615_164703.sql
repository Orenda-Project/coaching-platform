--
-- PostgreSQL database dump
--

\restrict 1ZRXDfBT1pydaizN7oyNCQOBhoNTjIv1rjqBNwQRHVLtaKWaKIdjhT8KtfPh5dx

-- Dumped from database version 18.4 (Debian 18.4-1.pgdg13+1)
-- Dumped by pg_dump version 18.3 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cot_observations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cot_observations (
    id character varying NOT NULL,
    observer_id character varying NOT NULL,
    teacher_name character varying NOT NULL,
    school_name character varying NOT NULL,
    subject character varying,
    grade character varying,
    topic character varying,
    framework character varying,
    date character varying,
    visit_purpose character varying,
    status character varying DEFAULT 'Scheduled'::character varying,
    region character varying,
    week character varying,
    visit_type character varying,
    planned_date character varying,
    arrival_time character varying,
    departure_time character varying,
    total_score double precision,
    submitted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Data for Name: cot_observations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cot_observations (id, observer_id, teacher_name, school_name, subject, grade, topic, framework, date, visit_purpose, status, region, week, visit_type, planned_date, arrival_time, departure_time, total_score, submitted_at, created_at, updated_at) FROM stdin;
6e9aba93-8556-497c-9d0d-97891869d567	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-07T06:55:41.473+00:00	\N	Draft		\N	\N	\N	\N	\N	0	\N	2026-05-07 06:55:42.959363+00	2026-05-07 06:59:30.894+00
4b5172e9-46ac-4280-a505-fd77475947ad	28faa70d-2ff3-4d94-945e-0173cf435908	Haya Abid	IMCG F6/2	English	Class 3	\N	FICO	2026-05-05T10:17:00+00:00	\N	Draft	islamabad	\N	\N	\N	\N	\N	0	\N	2026-05-05 10:17:05.524634+00	2026-05-06 09:58:15.972+00
9fc7c125-5a71-4e74-9d9d-da252863b5dd	f1c8caeb-5f54-429d-96a1-edce436e46f7	Aneesa test	ICB	English	Class 1	Alpha	FICO	2026-05-07T06:42:00+00:00	\N	Draft	islamabad	\N	\N	\N	\N	\N	0	\N	2026-05-07 06:42:29.809474+00	2026-05-07 06:46:03.966+00
8964858f-427d-444f-a97e-f4a679db5f76	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-07T09:41:11.071+00:00	\N	Submitted		\N	\N	\N	\N	\N	0	2026-05-07 09:45:30.51+00	2026-05-07 09:41:12.699152+00	2026-05-07 09:45:30.51+00
bf32df02-8881-40eb-92a4-afc94b2ad120	e49e8f22-226d-4d14-ab71-8884c46b5b68	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-07T09:50:15.404+00:00	\N	Draft		\N	\N	\N	\N	\N	0	\N	2026-05-07 09:50:16.368184+00	2026-05-07 09:50:16.368184+00
35d026d4-1901-4e97-8ace-6c2c088fb3bd	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-07T06:49:57.761+00:00	\N	Submitted		\N	\N	\N	\N	\N	0	2026-05-07 06:54:18.295+00	2026-05-07 06:49:59.222321+00	2026-05-07 06:54:18.295+00
09a88971-98fe-49ae-8d7f-0ac06627d00f	e49e8f22-226d-4d14-ab71-8884c46b5b68	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-07T09:50:40.053+00:00	\N	Draft		\N	\N	\N	\N	\N	0	\N	2026-05-07 09:50:40.728209+00	2026-05-07 09:50:40.728209+00
1fa00ed3-f0dc-42f7-bb75-31264f131cd7	853e2257-c846-4993-a772-57bde062792c	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-07T10:14:33.684+00:00	\N	Draft		\N	\N	\N	\N	\N	0	\N	2026-05-07 10:14:33.812235+00	2026-05-07 10:14:33.812235+00
eff7b2cf-7e80-4d65-8c0c-fa3963f35f5f	e49e8f22-226d-4d14-ab71-8884c46b5b68	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-08T05:56:19.976+00:00	\N	Draft		\N	\N	\N	\N	\N	0	\N	2026-05-08 05:56:20.500074+00	2026-05-08 05:56:20.500074+00
5da9e536-a3b6-40bd-bf4c-837075e08b46	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-11T09:18:12.347+00:00	\N	Draft	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-11 09:18:12.375067+00	2026-05-11 09:23:06.793+00
ac4373fb-5c4c-4fa7-ad4b-53b8800a9bb8	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	classroom observation	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-12 11:12:45.096331+00	2026-05-12 11:14:32.46+00
886ee95b-0630-46c3-ace1-431ea48a4719	28faa70d-2ff3-4d94-945e-0173cf435908	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T07:42:47.664+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-12 07:42:48.380821+00	2026-05-12 07:42:48.380821+00
02e68b12-72bd-44df-81b3-a3032d799c68	e49e8f22-226d-4d14-ab71-8884c46b5b68	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T10:29:07.334+00:00	\N	Submitted	Nilore	\N	\N	\N	\N	\N	0	2026-05-12 10:45:51.82+00	2026-05-12 10:29:08.037167+00	2026-05-12 10:45:51.821+00
f88666f0-10c9-47f9-a3a8-04b1969fcec6	de00223b-2413-4519-920c-d793b5a17a6a	Rabia Ramzan	IMS(I-V) G-6/1-2	Maths	5	\N	FICO	2026-05-11T07:20:12.831+00:00	\N	Draft		\N	\N	\N	\N	\N	0	\N	2026-05-11 07:20:12.770531+00	2026-05-11 07:54:23.013+00
b102a415-5256-4714-9a10-c2194cd33668	28faa70d-2ff3-4d94-945e-0173cf435908	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T07:44:00.919+00:00	\N	Submitted	B.K	\N	\N	\N	\N	\N	0	2026-05-12 07:55:58.655+00	2026-05-12 07:44:01.366017+00	2026-05-12 07:55:58.655+00
27d51bfa-9d36-44d0-8207-333c61d45890	28faa70d-2ff3-4d94-945e-0173cf435908	Rabia Ramzan	IMS(I-V) G-6/1-2	Maths	5	\N	FICO	2026-05-12T08:00:02.832+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-12 08:00:03.196266+00	2026-05-12 08:00:03.196266+00
3d1a6264-ccfd-4298-9069-d3759e0d221b	28faa70d-2ff3-4d94-945e-0173cf435908	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T08:02:00.67+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-12 08:02:00.990765+00	2026-05-12 08:02:00.990765+00
b79b0219-2e55-4fd9-b0d3-b2cea50e0922	28faa70d-2ff3-4d94-945e-0173cf435908	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T08:06:09.426+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-12 08:06:10.517797+00	2026-05-12 08:06:10.517797+00
4b02888a-ab3c-4b5c-90da-839b4ce13239	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T07:24:04.498+00:00	\N	Submitted	Nilore	\N	\N	\N	\N	\N	0	2026-05-12 09:41:05.105+00	2026-05-12 07:24:04.444357+00	2026-05-12 09:41:05.105+00
35ed97c7-fdb9-4a80-9763-f9e6eda58d2c	e49e8f22-226d-4d14-ab71-8884c46b5b68	Kausar Perveen	IMS(I-V) G-6/1-2	Maths	2	\N	FICO	2026-05-12T11:09:12.9+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-12 11:09:13.081431+00	2026-05-12 11:09:13.081431+00
776c0f64-104d-487e-9fcb-0bf64e22ed63	e49e8f22-226d-4d14-ab71-8884c46b5b68	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T11:11:42.535+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-12 11:11:42.712351+00	2026-05-12 11:11:42.712351+00
4cb46b82-62e6-4ce7-8f3a-20880e06303c	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	classroom observation	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-12 11:25:08.134241+00	2026-05-12 11:26:43.006+00
0591661c-2ce1-4336-ad2f-87eed42bc820	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	classtoom observation	Submitted	Sihala	\N	\N	\N	\N	\N	0	2026-05-12 11:12:19.21+00	2026-05-12 11:08:53.817771+00	2026-05-12 11:12:19.21+00
495bfa1f-58bd-499d-a7fe-c8dd784305ae	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	classroom observation	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-12 15:18:18.912605+00	2026-05-12 15:19:51.735+00
350f05e9-8a00-401f-9fbe-7492a2f752a5	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	classroom observation	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-12 15:09:26.307893+00	2026-05-12 15:10:56.856+00
c20241ee-9cd5-4816-b651-e2a89b41e70d	0bed584c-d5bb-49a3-a415-b354ad5808ee	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T16:18:09.417+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-12 16:18:09.92273+00	2026-05-12 16:18:09.92273+00
9b86fe8f-9e9c-4bf3-a9e4-d0e6975efb60	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-14T00:00:00+00:00	classroom observation	Scheduled	Sihala	\N	\N	\N	\N	\N	0	\N	2026-05-13 06:09:26.003381+00	2026-05-13 06:21:54.808+00
2352aac6-4844-4be9-9a09-7b0fc15ffba8	0bed584c-d5bb-49a3-a415-b354ad5808ee	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T16:33:20.256+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-12 16:33:20.727458+00	2026-05-12 16:37:14.544+00
c5e0ee71-c354-4fa0-89f9-a2b94304f2df	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	classroom observations	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-13 06:24:35.472569+00	2026-05-13 06:26:39.133+00
1ca10259-de2c-4c63-812e-570131a124b3	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	classroom observation	Scheduled	Tarnol	\N	\N	\N	\N	\N	0	\N	2026-05-13 06:29:32.001296+00	2026-05-13 06:45:16.387+00
c84b25f7-fd11-42ff-917b-26bcb02e5bd2	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-07T08:08:31.667+00:00	\N	Submitted		\N	\N	\N	\N	\N	0	2026-05-19 08:23:03.586+00	2026-05-07 08:08:32.986808+00	2026-05-19 08:23:03.586+00
96bde300-5748-4e84-8b54-fd6919fa7a6a	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	CLASSROOM OBSERVATION	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-13 06:57:34.824879+00	2026-05-13 06:59:00.166+00
1aaf5d48-24ca-4bc4-91d6-8932cdad102c	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-18T00:00:00+00:00	neo debrief	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-18 07:45:25.916052+00	2026-05-18 07:45:25.916052+00
4aa08c32-75fe-45e0-81dc-95d9ece5973c	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-18T00:00:00+00:00	classroom observation	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-18 07:47:25.649715+00	2026-05-18 07:47:25.649715+00
6b509cf6-2b68-4541-832d-a9e2b12e04f2	0bed584c-d5bb-49a3-a415-b354ad5808ee	Rabia Ramzan	IMS(I-V) G-6/1-2	Maths	5	\N	FICO	2026-05-13T07:34:24.196+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-13 07:34:24.982341+00	2026-05-13 07:34:24.982341+00
e0f76a6e-c1d8-43b2-83e4-88e92b3a9e1b	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	CLASSROOM OBSERVATION	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-13 07:28:51.205348+00	2026-05-13 07:42:22.784+00
bd53337a-fb18-44b0-991d-46e71e92b6a8	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	neo debrief	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-13 07:58:43.875367+00	2026-05-13 08:00:48.843+00
9a639f93-78c6-4f7a-94ab-c55e515e5602	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-19T00:00:00+00:00	neo debrief	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-19 08:21:32.277084+00	2026-05-19 08:21:32.277084+00
f1ab47d3-6bc3-4026-b418-ad8c7ce4e32d	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	classroom observation	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-13 08:02:59.871625+00	2026-05-13 08:13:25.726+00
d960c69d-710e-4b35-8caf-066f242af207	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	neo debrief	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-13 10:02:31.96955+00	2026-05-13 10:02:31.96955+00
df1b15da-4b8d-422d-88b1-f56d1a943dc1	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	neo	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-13 10:05:56.719015+00	2026-05-13 10:05:56.719015+00
79803077-821f-4a31-9d41-34aa46970448	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	neo	Draft	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-13 10:06:54.154145+00	2026-05-13 10:18:15.112+00
80724b2c-f962-4c45-b7b8-6db341a410cc	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-15T00:00:00+00:00	neo debrief	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-15 05:30:14.656031+00	2026-05-15 05:30:14.656031+00
88655a4e-ac41-469d-89ec-ef8a72043fe9	f9853e95-565d-420f-8d01-856dc73ba2c6	Safia Akbar	IMCB G-15	Urdu	4	\N	FICO	2026-05-19T00:00:00+00:00	neo dbrief	Scheduled	Tarnol	\N	\N	\N	\N	\N	0	\N	2026-05-19 17:21:44.229823+00	2026-05-19 17:21:44.229823+00
c7b25a09-74ee-4ff7-ba76-074236aeb44b	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-15T00:00:00+00:00	neo debrief	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-15 05:43:01.141515+00	2026-05-15 05:49:56.244+00
c01b999e-97de-45df-8d7e-ded96915893c	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-15T00:00:00+00:00	neo debrief	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-15 06:37:44.054251+00	2026-05-15 06:37:44.054251+00
f76765f3-6e36-4df9-94b6-629fabd828e1	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-18T00:00:00+00:00	neo debrief	Scheduled	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-18 06:02:05.905153+00	2026-05-18 06:02:05.905153+00
f3d27827-7ea6-4119-8731-d9dfad41d808	f1c8caeb-5f54-429d-96a1-edce436e46f7	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	test	FICO	2026-05-18T00:00:00+00:00	observatio	Scheduled	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-18 06:37:05.382304+00	2026-05-18 06:37:05.382304+00
02b382e8-987e-4d8b-82a9-1df243e1b4ad	f9853e95-565d-420f-8d01-856dc73ba2c6	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-18T00:00:00+00:00	neo debrief	Submitted	Nilore	\N	\N	\N	\N	\N	0	2026-05-18 07:42:17.184+00	2026-05-18 07:33:33.662418+00	2026-05-18 07:42:17.184+00
9db8c644-d2d6-4efb-93da-99462c5b8b39	f9853e95-565d-420f-8d01-856dc73ba2c6	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Science	5	\N	FICO	2026-05-20T00:00:00+00:00	neo debrief	Scheduled	Tarnol	\N	\N	\N	\N	\N	0	\N	2026-05-20 06:52:36.306601+00	2026-05-20 06:52:36.306601+00
4d0c629f-93b4-41ad-b228-0dfe2add157e	f9853e95-565d-420f-8d01-856dc73ba2c6	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Science	5	\N	FICO	2026-05-20T00:00:00+00:00	neo debrief	Scheduled	Tarnol	\N	\N	\N	\N	\N	0	\N	2026-05-20 07:41:42.601499+00	2026-05-20 07:41:42.601499+00
6f6a925f-7a6a-4ae8-83fc-4f321c61f348	f9853e95-565d-420f-8d01-856dc73ba2c6	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Science	5	\N	FICO	2026-05-20T00:00:00+00:00	neo observation	Scheduled	Tarnol	\N	\N	\N	\N	\N	0	\N	2026-05-20 07:48:19.74921+00	2026-05-20 07:48:19.74921+00
8535fe16-ceea-4680-951a-fc56241f40e8	f9853e95-565d-420f-8d01-856dc73ba2c6	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Science	5	\N	FICO	2026-05-20T00:00:00+00:00	neo observation	Scheduled	Tarnol	\N	\N	\N	\N	\N	0	\N	2026-05-20 08:02:28.651484+00	2026-05-20 08:02:28.651484+00
72a3c56c-d62e-4678-bac4-2afaadab55fd	f9853e95-565d-420f-8d01-856dc73ba2c6	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Science	5	\N	FICO	2026-05-20T00:00:00+00:00	neo debrief	Scheduled	Tarnol	\N	\N	\N	\N	\N	0	\N	2026-05-20 09:37:55.122534+00	2026-05-20 09:37:55.122534+00
a85cc88d-60d3-4038-8ec5-c18e738be0d0	f9853e95-565d-420f-8d01-856dc73ba2c6	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Science	5	\N	FICO	2026-05-20T00:00:00+00:00	nnn	Scheduled	Tarnol	\N	\N	\N	\N	\N	0	\N	2026-05-20 10:30:05.979964+00	2026-05-20 10:30:05.979964+00
3d14b4f6-fe59-4be4-b0e3-b6bb57c209c1	de00223b-2413-4519-920c-d793b5a17a6a	Amina Khan	Government School Nilore	Mathematics	5	\N	FICO	2026-06-03T00:00:00+00:00	FICO observation	Submitted	islamabad	\N	FICO	2026-06-02	09:00:00	14:00:00	0	\N	2026-06-02 07:57:17.835928+00	2026-06-02 08:02:37.532+00
92a3179c-2a88-4216-97fa-1e6a3e08a950	de00223b-2413-4519-920c-d793b5a17a6a	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T00:00:00+00:00	neo	Draft	Nilore	\N	\N	\N	\N	\N	0	\N	2026-05-13 10:18:30.36038+00	2026-06-03 09:38:44.481+00
78817bd5-bfd1-435c-ab9b-2b76068cda09	de00223b-2413-4519-920c-d793b5a17a6a	Amina Khan	Government School Nilore	Mathematics	5	\N	FICO	2026-06-03T00:00:00+00:00	FICO observation	Draft	islamabad	\N	FICO	2026-06-03	09:00:00	14:00:00	0	\N	2026-06-03 08:05:08.357195+00	2026-06-03 09:38:55.007+00
f7028754-adbc-414e-b2fb-046a0fe06b11	f9853e95-565d-420f-8d01-856dc73ba2c6	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Science	5	\N	FICO	2026-06-03T00:00:00+00:00	FICO observation	Scheduled	islamabad	week 1	FICO	2026-06-03	09:00:00	14:00:00	0	\N	2026-06-03 10:07:03.101952+00	2026-06-03 10:09:52.923+00
30efa91b-6a18-46f8-b517-e77caaff628d	f9853e95-565d-420f-8d01-856dc73ba2c6	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Science	5	\N	FICO	2026-06-04T00:00:00+00:00	FICO observation	Submitted	islamabad	\N	FICO	2026-06-03	09:00:00	14:00:00	0	\N	2026-06-03 10:32:31.47875+00	2026-06-03 10:32:40.334+00
c0410bbd-8c0c-47c3-8c58-034e5d55a964	f1c8caeb-5f54-429d-96a1-edce436e46f7	Rehana Aftab	IMS(I-V) No.2 G-9/2	Eng	2	\N	FICO	2026-06-04T00:00:00+00:00	General Visit observation	Submitted	islamabad	2	General Visit	2026-06-04	10:00:00	12:00:00	0	\N	2026-06-04 07:55:03.574389+00	2026-06-04 07:55:38.26+00
fdaade8d-db79-4712-9a40-d0ae3a41fe5a	f1c8caeb-5f54-429d-96a1-edce436e46f7	Ali Raza	Government School Urban-II	Mathematics	5	\N	FICO	2026-06-05T00:00:00+00:00	M&H observation	Scheduled	islamabad	4	M&H	2026-06-04	09:00:00	12:00:00	0	\N	2026-06-04 07:56:55.53477+00	2026-06-04 07:56:55.53477+00
ae173f89-6e53-47ea-b57a-ae8150d6fad1	f9853e95-565d-420f-8d01-856dc73ba2c6	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Science	5	\N	FICO	2026-06-05T00:00:00+00:00	FICO observation	Scheduled	islamabad	\N	FICO	2026-06-05	09:00:00	14:00:00	0	\N	2026-06-05 05:53:02.333748+00	2026-06-05 05:53:02.333748+00
c3402c8b-bd10-4c0c-a84f-cd81deb4d340	f1c8caeb-5f54-429d-96a1-edce436e46f7	Rehana Aftab	IMS(I-V) No.2 G-9/2	Eng	2	\N	FICO	2026-06-04T00:00:00+00:00	FICO observation	Draft	islamabad	\N	FICO	2026-06-04	09:00:00	14:00:00	0	\N	2026-06-03 07:36:30.89679+00	2026-06-04 07:57:33.891+00
7b287c03-9163-4d15-812a-7b3681b3c9d6	28faa70d-2ff3-4d94-945e-0173cf435908	Nadeema bibi	IMSG (I-VIII), BOBRI	Maths	2	\N	FICO	2026-06-17	Classroom Observation	Scheduled	B.K	\N	\N	\N	\N	\N	\N	\N	2026-06-12 18:17:18.450705+00	2026-06-12 18:17:18.450705+00
722eb7fb-f092-4590-b7e5-658b03b33c9c	28faa70d-2ff3-4d94-945e-0173cf435908	Nadia Ahmed	Government School B.K	Science	2	\N	FICO	2026-06-25	Classroom Observation	Scheduled	B.K	\N	\N	\N	\N	\N	\N	\N	2026-06-12 18:38:18.773457+00	2026-06-12 18:38:18.773457+00
1518e9c8-609a-43d2-827a-4e5ceb0bc824	f9853e95-565d-420f-8d01-856dc73ba2c6	Saima Zubair	IMS (I-VIII) D-17	Maths	4	\N	FICO	2026-06-15	Classroom Observation	Scheduled	Tarnol	\N	\N	\N	\N	\N	\N	\N	2026-06-15 08:12:10.700636+00	2026-06-15 08:12:10.700636+00
9b65752e-1125-4b18-9a5e-9e901e7347c7	f9853e95-565d-420f-8d01-856dc73ba2c6	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Science	5	\N	FICO	2026-06-05T00:00:00+00:00	FICO observation	Submitted	islamabad	\N	FICO	2026-06-05	09:00:00	14:00:00	0	2026-06-15 08:12:48.947079+00	2026-06-05 08:04:16.442617+00	2026-06-15 08:12:48.944023+00
\.


--
-- Name: cot_observations cot_observations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cot_observations
    ADD CONSTRAINT cot_observations_pkey PRIMARY KEY (id);


--
-- Name: ix_cot_observations_observer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cot_observations_observer_id ON public.cot_observations USING btree (observer_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 1ZRXDfBT1pydaizN7oyNCQOBhoNTjIv1rjqBNwQRHVLtaKWaKIdjhT8KtfPh5dx

