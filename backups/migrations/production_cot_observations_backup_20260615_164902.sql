--
-- PostgreSQL database dump
--

\restrict HOztRWahV83DLAWzaLfdjRKX5f743PKuNg74GUZPBnhWA4WDyHJt1BXh17mVcKg

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
2843e823-e4db-480f-b424-7aced9b4a240	0119885b-ce04-4a43-a565-c4722ddaca81	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T16:35:04.006+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-12 16:35:04.483689+00	2026-05-12 16:35:04.483689+00
79453898-d173-4e7f-90cd-5ad81bcfd67c	531e9525-9f03-4a02-81e9-1d4ed5100e38	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T08:39:29.37+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-13 08:39:31.837436+00	2026-05-13 08:39:31.837436+00
54294b81-951f-42c6-a71a-6b0fe2c6076d	531e9525-9f03-4a02-81e9-1d4ed5100e38	Nadeema bibi	IMSG (I-VIII), BOBRI	Maths	2	\N	FICO	2026-06-16	Classroom Observation	Submitted	B.K	\N	\N	\N	\N	\N	\N	2026-06-15 11:15:06.319951+00	2026-06-15 10:23:27.164238+00	2026-06-15 11:15:06.309682+00
5dc7fb05-dd6d-4030-ba65-e9fd7ee2f26a	531e9525-9f03-4a02-81e9-1d4ed5100e38	Nadeema bibi	IMSG (I-VIII), BOBRI	Maths	2	\N	FICO	2026-06-23	Coaching Follow-up	Scheduled	B.K	\N	\N	\N	\N	\N	\N	\N	2026-06-15 11:15:56.45621+00	2026-06-15 11:15:56.45621+00
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

\unrestrict HOztRWahV83DLAWzaLfdjRKX5f743PKuNg74GUZPBnhWA4WDyHJt1BXh17mVcKg

