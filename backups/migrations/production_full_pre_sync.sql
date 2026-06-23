--
-- PostgreSQL database dump
--

\restrict ErYgA4BfnELaqj7CtXi7c2ufsUAwHKWX5GKhvorcEyQUruTRdgBCTo6rWEY3o3H

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

--
-- Name: adminrole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.adminrole AS ENUM (
    'SUPER_ADMIN',
    'REGIONAL_ADMIN'
);


--
-- Name: app_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.app_role AS ENUM (
    'admin',
    'user',
    'regional_admin'
);


--
-- Name: fieldissuestatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.fieldissuestatus AS ENUM (
    'OPEN',
    'IN_PROGRESS',
    'RESOLVED',
    'CLOSED'
);


--
-- Name: user_role_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_role_enum AS ENUM (
    'learner',
    'admin',
    'coach'
);


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  INSERT INTO public.profiles (id, phone, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.phone, NEW.email),
    NEW.raw_user_meta_data->>'full_name'
  );
  RETURN NEW;
END;
$$;


--
-- Name: has_role(uuid, public.app_role); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_role(_user_id uuid, _role public.app_role) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    role public.adminrole NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: analytics_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analytics_events (
    id character varying NOT NULL,
    user_id character varying,
    event_type text,
    event_data jsonb,
    created_at timestamp with time zone,
    "timestamp" timestamp with time zone DEFAULT now()
);


--
-- Name: assessment_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_attempts (
    id character varying NOT NULL,
    assessment_id character varying NOT NULL,
    attempt_number integer NOT NULL,
    score double precision,
    passed boolean,
    created_at timestamp with time zone DEFAULT now(),
    submitted_at timestamp with time zone
);


--
-- Name: assessment_definitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_definitions (
    id character varying NOT NULL,
    type character varying NOT NULL,
    training_id character varying,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: assessment_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_responses (
    id character varying NOT NULL,
    assessment_id character varying NOT NULL,
    question_id character varying NOT NULL,
    user_answer text,
    is_correct boolean,
    points_earned double precision,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessments (
    id character varying NOT NULL,
    type character varying,
    training_id character varying,
    title character varying,
    description text,
    passing_score integer DEFAULT 80,
    max_attempts integer DEFAULT 3,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    persona_target text
);


--
-- Name: assessments_user_tracking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessments_user_tracking (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    module_id character varying NOT NULL,
    score double precision,
    status character varying,
    attempt_number integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    submitted_at timestamp with time zone
);


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificates (
    id text NOT NULL,
    user_id text,
    training_id text,
    issued_at timestamp without time zone,
    created_at timestamp without time zone,
    certificate_id character varying,
    persona character varying
);


--
-- Name: coach_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coach_assignments (
    id character varying NOT NULL,
    coach_id character varying,
    teacher_name character varying,
    school_name character varying,
    region character varying,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: coaching_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coaching_sessions (
    id character varying NOT NULL,
    coach_id character varying NOT NULL,
    coachee_id character varying NOT NULL,
    date timestamp with time zone NOT NULL,
    status character varying,
    notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


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
    updated_at timestamp with time zone DEFAULT now(),
    fico_rubric jsonb,
    hots_rubric jsonb,
    proficiency_level character varying,
    notes_for_teacher text,
    hots_notes text,
    neo_status character varying,
    neo_task_id character varying,
    neo_requested_at timestamp with time zone,
    neo_completed_at timestamp with time zone,
    neo_results jsonb,
    neo_error text,
    neo_audio_url text,
    dc_status character varying,
    dc_task_id character varying,
    dc_requested_at timestamp with time zone,
    dc_completed_at timestamp with time zone,
    dc_results jsonb,
    dc_error text,
    dc_audio_s3_key character varying
);


--
-- Name: export_scenario_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.export_scenario_options (
    id character varying NOT NULL,
    scenario_id character varying NOT NULL,
    letter character varying,
    option_text text,
    is_correct boolean,
    rationale text,
    created_at timestamp with time zone
);


--
-- Name: export_scenarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.export_scenarios (
    id character varying NOT NULL,
    training_id character varying NOT NULL,
    situation text,
    question text,
    difficulty character varying,
    created_at timestamp with time zone
);


--
-- Name: feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feedback (
    id text,
    title text,
    description text,
    persona_required text,
    order_number text,
    is_common text,
    created_at text,
    module_id text,
    main_concepts text,
    max_attempts text,
    quiz_unlock_requires_content text
);


--
-- Name: field_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.field_issues (
    id character varying NOT NULL,
    description text NOT NULL,
    status public.fieldissuestatus NOT NULL,
    reported_by character varying NOT NULL,
    assigned_to character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    resolved_at timestamp with time zone
);


--
-- Name: hots_rubric_dimensions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hots_rubric_dimensions (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    dimension text NOT NULL,
    description text,
    max_score integer DEFAULT 10,
    order_number integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: module_quiz_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.module_quiz_attempts (
    id character varying NOT NULL,
    user_id character varying,
    module_id character varying,
    attempt_number integer,
    score numeric,
    created_at timestamp with time zone,
    best_score double precision DEFAULT 0,
    passed boolean DEFAULT false,
    attempt_count integer DEFAULT 0,
    completed_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: modules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modules (
    id character varying NOT NULL,
    title character varying NOT NULL,
    description text,
    is_mandatory boolean DEFAULT false,
    order_number integer,
    competencies character varying,
    persona_required text[],
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.options (
    id character varying NOT NULL,
    question_id character varying NOT NULL,
    option_text text NOT NULL,
    is_correct boolean DEFAULT false,
    order_number integer,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id text NOT NULL,
    phone text,
    full_name text,
    persona text,
    baseline_score numeric,
    baseline_completed boolean,
    endline_score numeric,
    endline_completed boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    endline_attempt_count integer,
    baseline_attempt_count integer,
    weak_modules jsonb,
    region text,
    teacher_ids jsonb,
    school_id text,
    qualifications jsonb,
    experiences jsonb,
    sub_region text,
    user_id character varying,
    avatar_url character varying,
    bio text,
    role character varying DEFAULT 'learner'::character varying,
    is_active boolean DEFAULT true,
    email text
);


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questions (
    id character varying NOT NULL,
    assessment_id character varying NOT NULL,
    question_type character varying,
    question_text text NOT NULL,
    correct_answer character varying,
    max_score integer DEFAULT 1,
    order_number integer,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regions (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    coordinates jsonb,
    parent_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_active boolean DEFAULT true,
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: scenario_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scenario_options (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    scenario_id character varying NOT NULL,
    option_letter character(1) NOT NULL,
    option_text text NOT NULL,
    is_correct boolean DEFAULT false NOT NULL,
    rationale text DEFAULT ''::text NOT NULL,
    principle_tag text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    feedback text,
    is_optimal boolean DEFAULT false,
    order_number integer DEFAULT 0,
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT scenario_options_option_letter_check CHECK ((option_letter = ANY (ARRAY['A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar])))
);


--
-- Name: scenario_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scenario_responses (
    id character varying NOT NULL,
    user_id character varying,
    scenario_id character varying,
    response_text text,
    created_at timestamp with time zone,
    selected_option_id character varying,
    "timestamp" timestamp with time zone DEFAULT now()
);


--
-- Name: scenarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scenarios (
    id character varying DEFAULT gen_random_uuid() NOT NULL,
    unit_id character varying NOT NULL,
    order_number integer DEFAULT 1 NOT NULL,
    situation text NOT NULL,
    question text NOT NULL,
    difficulty text DEFAULT 'medium'::text NOT NULL,
    feedback_slides jsonb DEFAULT '[]'::jsonb,
    reveal_content text,
    deep_content text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    title character varying,
    description text,
    CONSTRAINT scenarios_difficulty_check CHECK ((difficulty = ANY (ARRAY['easy'::text, 'medium'::text, 'hard'::text])))
);


--
-- Name: session_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_events (
    id text,
    user_id text,
    module_id text,
    training_id text,
    context_page text,
    category text,
    rating text,
    positive_feedback text,
    improvement_feedback text,
    persona text,
    user_agent text,
    created_at text
);


--
-- Name: session_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_notes (
    id character varying NOT NULL,
    session_id character varying NOT NULL,
    content text NOT NULL,
    created_by character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: teacher_dc_scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teacher_dc_scores (
    id character varying NOT NULL,
    teacher_name character varying NOT NULL,
    school_name character varying NOT NULL,
    region character varying NOT NULL,
    grade character varying,
    subject character varying,
    total_score double precision NOT NULL,
    framework character varying,
    scored_at timestamp with time zone,
    raw_results jsonb,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: training_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_content (
    id character varying NOT NULL,
    training_id character varying NOT NULL,
    format_type character varying,
    content_url character varying,
    duration_minutes integer,
    extra_data jsonb,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: training_progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_progress (
    id text,
    user_id text,
    training_id text,
    score double precision,
    passed boolean,
    attempt_count integer,
    completed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_completed boolean DEFAULT false,
    tab_switch_count integer DEFAULT 0,
    fullscreen_violations integer DEFAULT 0,
    flagged_for_review boolean DEFAULT false,
    content_completed boolean DEFAULT false,
    content_completed_at timestamp with time zone,
    started_at timestamp with time zone,
    progress_percentage integer DEFAULT 0,
    last_accessed_at timestamp without time zone
);


--
-- Name: trainings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trainings (
    id character varying NOT NULL,
    module_id character varying,
    title character varying NOT NULL,
    description text,
    order_number integer,
    is_common boolean DEFAULT false,
    persona_required character varying,
    main_concepts text,
    max_attempts integer DEFAULT 3,
    quiz_unlock_requires_content boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: user_metrics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_metrics (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    quiz_attempts integer,
    modules_passed integer,
    total_score double precision,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: user_regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_regions (
    id character varying NOT NULL,
    user_id character varying,
    region_id character varying,
    created_at timestamp with time zone
);


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id character varying NOT NULL,
    user_id character varying NOT NULL,
    role character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_roles_id_seq OWNED BY public.user_roles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id character varying NOT NULL,
    email character varying NOT NULL,
    email_confirmed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: user_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles ALTER COLUMN id SET DEFAULT nextval('public.user_roles_id_seq'::regclass);


--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_users (id, user_id, role, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: analytics_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.analytics_events (id, user_id, event_type, event_data, created_at, "timestamp") FROM stdin;
\.


--
-- Data for Name: assessment_attempts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assessment_attempts (id, assessment_id, attempt_number, score, passed, created_at, submitted_at) FROM stdin;
\.


--
-- Data for Name: assessment_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assessment_definitions (id, type, training_id, created_at) FROM stdin;
\.


--
-- Data for Name: assessment_responses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assessment_responses (id, assessment_id, question_id, user_answer, is_correct, points_earned, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: assessments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assessments (id, type, training_id, title, description, passing_score, max_attempts, created_at, updated_at, persona_target) FROM stdin;
cf058065-da19-4620-a554-d8f1b344aaf9	module_quiz	014e2ea2-3a80-43c5-8f3c-329731000715	Unit 1.0: The Coaching Catalyst — Quiz	\N	80	3	2026-04-09 09:54:41.491628+00	2026-06-12 17:40:18.014235+00	\N
12dcd848-63d9-46e3-884d-13083bc8b238	module_quiz	bcfae3fa-29c9-4972-bb32-c7909b55227c	Unit 1.1: The Partnership Posture — Quiz	\N	80	3	2026-04-09 09:54:46.715288+00	2026-06-12 17:40:18.014235+00	\N
79ed136b-ef61-4114-b0c5-6acbb1446da8	module_quiz	9fabc12b-0f30-421d-ad41-4deb372a6314	Unit 1.2: The Shared Mirror — Quiz	\N	80	3	2026-04-09 09:54:51.732485+00	2026-06-12 17:40:18.014235+00	\N
fdb43c81-f0d0-466f-a618-218bdee2b075	module_quiz	2e867af9-1fa4-4e84-8015-c0dfbf9a4850	Unit 1.3: The Growth Engine — Quiz	\N	80	3	2026-04-09 09:54:56.720158+00	2026-06-12 17:40:18.014235+00	\N
ad87af82-7496-4b2c-bcb1-f765a7b7ef36	module_quiz	8d82e38c-73f9-4f4f-93ff-a467824ae63c	Unit 1.4: The Trust Bridge — Quiz	\N	80	3	2026-04-09 09:55:01.462505+00	2026-06-12 17:40:18.014235+00	\N
a58afc41-9f5b-4b91-b8bf-1d2e85b46918	module_quiz	1a504a0a-f44b-47d0-abc2-e44d19d6508e	Unit 1.5: The Human Filter — Quiz	\N	80	3	2026-04-09 09:55:06.274686+00	2026-06-12 17:40:18.014235+00	\N
a6b8cb55-2667-4ea1-8937-61ca6f8e3edb	module_quiz	3ee06af5-aac0-49f9-9963-df6d8096805f	Unit 1.6: Coding the Classroom — Quiz	\N	80	3	2026-04-09 09:55:11.170713+00	2026-06-12 17:40:18.014235+00	\N
cd78dae1-6ce9-4e52-a9e6-67291df3c06a	module_quiz	ad533d06-0947-4f89-854e-64eac7bd009f	Unit 2.1: Status & Psychological Safety — Quiz	\N	80	3	2026-05-05 20:14:56.447272+00	2026-06-12 17:40:18.014235+00	\N
0881865f-a678-4884-8b4e-545b07109464	module_quiz	e01320fb-012c-430b-a9bf-1e6d0bb5cf95	Unit 2.2: Evidence-Based Dialogue — Quiz	\N	80	3	2026-05-05 20:15:03.519692+00	2026-06-12 17:40:18.014235+00	\N
14899040-a9ea-4041-8cb2-7ee38b4c19f4	module_quiz	81393e37-2176-4e50-ab5e-c94237481212	Unit 2.3: Goal-Setting as Co-Creation — Quiz	\N	80	3	2026-05-05 20:15:10.185474+00	2026-06-12 17:40:18.014235+00	\N
d7e9e809-10d2-4a34-bebc-5f2e6c430c72	baseline	\N	Coach Baseline Assessment	\N	80	3	2026-05-12 16:31:26.338488+00	2026-06-12 17:40:18.014235+00	\N
5ec96580-0327-4104-a9db-3bedbc80ec7c	module_quiz	bd231775-ab2a-4bb8-91c2-f67830a2a647	Unit 3.1: The Mirror Specialist — Quiz	\N	80	3	2026-05-13 08:19:53.514935+00	2026-06-12 17:40:18.014235+00	\N
270d968d-141d-409f-8dbe-2d184c0c9f52	module_quiz	a1358ec9-368d-4aba-88b9-9840a3064cd0	Unit 3.2: The Artifact Architect — Quiz	\N	80	3	2026-05-13 08:19:58.564542+00	2026-06-12 17:40:18.014235+00	\N
962105eb-60c7-4968-a632-f02660d52fc6	module_quiz	8024ed22-05e8-467b-8d6f-3ce365a66dd1	Unit 3.3: Data Into Dialogue — Quiz	\N	80	3	2026-05-13 08:20:03.852686+00	2026-06-12 17:40:18.014235+00	\N
904752e4-b77f-4957-90ae-6a1336b84d53	module_quiz	18e5a745-f999-46ff-a29c-97d79611497d	Unit 4.1: The Digital Journal — Quiz	\N	80	3	2026-05-13 08:41:59.314413+00	2026-06-12 17:40:18.014235+00	\N
aad7f7e3-58c0-4704-ab6a-b05ed23d2ba6	module_quiz	0545c290-98f0-43a4-8651-95fe882671bb	Unit 4.2: The Adaptive Facilitator — Quiz	\N	80	3	2026-05-13 08:42:04.70847+00	2026-06-12 17:40:18.014235+00	\N
560afd3c-e56e-46ce-b79f-1438503b6518	module_quiz	f60e1788-c4ef-46d2-8a5c-fae94e3b3150	Unit 4.3: The Partnership Advocate — Quiz	\N	80	3	2026-05-13 08:42:10.420636+00	2026-06-12 17:40:18.014235+00	\N
9f6323c2-9d00-4cbb-98d8-6ac7b08f8700	module_quiz	304a5e98-5ebe-4a95-823e-5d75ce5708ef	Unit 4.4: The Consistency Guardian (WRER) — Quiz	\N	80	3	2026-05-13 08:42:15.641082+00	2026-06-12 17:40:18.014235+00	\N
cda8db78-abfa-4f37-b6f9-14ac1b887bcc	module_quiz	894cbae3-025c-45a4-ad73-265d9483aa6a	Unit 5.1: The Power of Choice Within the Impact Cycle — Quiz	\N	80	3	2026-05-13 08:42:36.362277+00	2026-06-12 17:40:18.014235+00	\N
229e046e-83b3-48e5-9037-030d2601933a	module_quiz	48b064c9-ab6c-4aab-8b81-f913d7e86173	Unit 5.2: Finding the 'Why' — Identifying Intellectual Gaps — Quiz	\N	80	3	2026-05-13 08:42:41.73356+00	2026-06-12 17:40:18.014235+00	\N
95a07a48-ec69-49a5-b060-d4bef933f2f5	module_quiz	868b0c01-8fca-4f77-865d-f414bde5c0d0	Unit 5.3: Closing the Loop — Side-by-Side Modeling — Quiz	\N	80	3	2026-05-13 08:42:47.07558+00	2026-06-12 17:40:18.014235+00	\N
8763b4df-e37f-4187-a676-a87acef38d76	module_quiz	20310b34-0585-47ba-8e54-c85baa18876e	Unit 5.4: Diagnosing the 3 Loops — Precision Coaching — Quiz	\N	80	3	2026-05-13 08:42:52.311818+00	2026-06-12 17:40:18.014235+00	\N
d5c05d52-8f4b-4e23-abc7-c2c4c82e37fd	module_quiz	578e7066-16a7-4e22-a388-3d4920c716d2	Unit 6.1: Closing the Loop — Quiz	\N	80	3	2026-05-13 08:43:12.376156+00	2026-06-12 17:40:18.014235+00	\N
48be70f3-cd8e-4d6a-8830-3523ca03f3b6	module_quiz	4bcd94c7-5d09-42d2-85b4-8d6120035522	Unit 6.2: The Protocol Guardrail — Quiz	\N	80	3	2026-05-13 08:43:17.912011+00	2026-06-12 17:40:18.014235+00	\N
9aca817e-4677-4a63-8d7b-82a92af39909	module_quiz	e28d5e1a-ebb0-44d7-9e07-8cc2d6b71430	Unit 6.3: Responsive Contextualization and Praxis — Quiz	\N	80	3	2026-05-13 08:43:23.203082+00	2026-06-12 17:40:18.014235+00	\N
51bf362f-b54f-4dd5-951c-1de885256a3f	module_quiz	d24d4240-fbc3-4cb7-996f-ced0099ad60c	Unit 6.4: Reciprocity — The Ethical Defense — Quiz	\N	80	3	2026-05-13 08:43:28.486107+00	2026-06-12 17:40:18.014235+00	\N
\.


--
-- Data for Name: assessments_user_tracking; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assessments_user_tracking (id, user_id, module_id, score, status, attempt_number, created_at, updated_at, submitted_at) FROM stdin;
\.


--
-- Data for Name: certificates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.certificates (id, user_id, training_id, issued_at, created_at, certificate_id, persona) FROM stdin;
\.


--
-- Data for Name: coach_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.coach_assignments (id, coach_id, teacher_name, school_name, region, created_at) FROM stdin;
13e1e23f-cf9f-465b-8fc3-e0fd81e48639	08a0e3b4-deff-482a-9598-1cd7425c35b2	\N	\N	islamabad	2026-05-12 16:32:25.347954+00
8aa0a738-c2e8-499c-b356-c3ceb6a84549	20151d0b-419b-4d82-bc22-dcc670527796	\N	\N	islamabad	2026-05-13 05:57:57.393213+00
91091d3b-f1d5-4df6-9080-4fe70e0b632c	1a8d51bb-1d61-4d1c-80ab-051421632184	\N	\N	islamabad	2026-05-14 09:54:51.811742+00
c1e8f876-4a5f-42ef-bbe4-7a15409f702b	531e9525-9f03-4a02-81e9-1d4ed5100e38	\N	\N	islamabad	2026-05-14 09:58:53.501387+00
14cde9eb-d42d-4038-bc69-3fa94046f88b	fa7ce468-50c0-4cbb-a987-2f37e7b5bcc2	\N	\N	islamabad	2026-05-15 12:20:00.291434+00
bd1bd382-3bc1-424c-b92c-d5cfbf98fdce	9baa44cc-addf-46c4-906e-e9f0cb724ce1	\N	\N	islamabad	2026-05-15 12:20:52.104012+00
9098c59c-1a15-4fb4-a19f-1c3265d298aa	7d5e20bc-42ce-4b4a-9906-046329153c0d	\N	\N	islamabad	2026-05-20 11:44:45.853319+00
60cd2e19-81cd-4ebf-8574-5b27522463e9	b2f358c2-5091-4f7f-a5e2-431c68768d92	\N	\N	islamabad	2026-06-02 07:40:14.380743+00
f8447f34-ffdc-4536-be44-b443d84012d2	1c903d37-7eb5-4420-8432-e59b9386a798	\N	\N	islamabad	2026-06-02 07:47:14.200515+00
85413657-c605-4435-b0f6-ce8c15da2fb0	724f69d9-713a-43f5-a021-f96ebea5ef4c	\N	\N	islamabad	2026-06-02 09:42:16.089367+00
6f220a39-67c4-4170-8be3-131a5ea426c8	0f567ea4-03f9-4bf6-89a1-97b509969137	\N	\N	islamabad	2026-06-04 07:52:47.925719+00
c0b76c92-1565-4adb-93dc-04a52396b3f0	66e67e8e-0ed9-4850-acb4-095a727a7f2e	\N	\N	islamabad	2026-06-10 07:09:56.039008+00
4d2bf470-3e4a-49c6-81d3-a2439523b320	d1ce5960-9682-4639-b987-be081423f233	\N	\N	islamabad	2026-06-11 07:32:55.040164+00
\.


--
-- Data for Name: coaching_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.coaching_sessions (id, coach_id, coachee_id, date, status, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: cot_observations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cot_observations (id, observer_id, teacher_name, school_name, subject, grade, topic, framework, date, visit_purpose, status, region, week, visit_type, planned_date, arrival_time, departure_time, total_score, submitted_at, created_at, updated_at, fico_rubric, hots_rubric, proficiency_level, notes_for_teacher, hots_notes, neo_status, neo_task_id, neo_requested_at, neo_completed_at, neo_results, neo_error, neo_audio_url, dc_status, dc_task_id, dc_requested_at, dc_completed_at, dc_results, dc_error, dc_audio_s3_key) FROM stdin;
2843e823-e4db-480f-b424-7aced9b4a240	0119885b-ce04-4a43-a565-c4722ddaca81	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-12T16:35:04.006+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-12 16:35:04.483689+00	2026-05-12 16:35:04.483689+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
79453898-d173-4e7f-90cd-5ad81bcfd67c	531e9525-9f03-4a02-81e9-1d4ed5100e38	Mehwish Rehman	IMSG(I-V)TAMMA	Eng	5	\N	FICO	2026-05-13T08:39:29.37+00:00	\N	Draft	B.K	\N	\N	\N	\N	\N	0	\N	2026-05-13 08:39:31.837436+00	2026-05-13 08:39:31.837436+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
54294b81-951f-42c6-a71a-6b0fe2c6076d	531e9525-9f03-4a02-81e9-1d4ed5100e38	Nadeema bibi	IMSG (I-VIII), BOBRI	Maths	2	\N	FICO	2026-06-16	Classroom Observation	Submitted	B.K	\N	\N	\N	\N	\N	\N	2026-06-15 11:15:06.319951+00	2026-06-15 10:23:27.164238+00	2026-06-15 11:15:06.309682+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5dc7fb05-dd6d-4030-ba65-e9fd7ee2f26a	531e9525-9f03-4a02-81e9-1d4ed5100e38	Nadeema bibi	IMSG (I-VIII), BOBRI	Maths	2	\N	FICO	2026-06-23	Coaching Follow-up	Scheduled	B.K	\N	\N	\N	\N	\N	\N	\N	2026-06-15 11:15:56.45621+00	2026-06-15 11:15:56.45621+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: export_scenario_options; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.export_scenario_options (id, scenario_id, letter, option_text, is_correct, rationale, created_at) FROM stdin;
3c7fc16c-0560-4d9f-a1e1-e1913c2a475c	796af68e-d1d1-4797-b1ee-600503dbf9ad	A	A technical correction of the teacher's mistakes.	f	\N	2026-06-09 10:02:48.160242+00
7f3daf0e-be34-4edc-ab7a-6d00ba8eeb2e	796af68e-d1d1-4797-b1ee-600503dbf9ad	B	A "Human Annotation" that highlights professional agency and growth.	f	\N	2026-06-09 10:02:48.160242+00
c1e733ec-f2fb-48bc-a6f0-44c4a3fd15b2	796af68e-d1d1-4797-b1ee-600503dbf9ad	C	A "Deficit Frame" focusing on what was missing earlier.	f	\N	2026-06-09 10:02:48.160242+00
64aa0859-4161-4a24-b504-bdd5fc741f92	796af68e-d1d1-4797-b1ee-600503dbf9ad	D	An administrative report for the principal to use in a salary review.	f	\N	2026-06-09 10:02:48.160242+00
5360f491-6e0d-40cf-9273-3854e721cff6	7139b870-538e-4d2a-b11b-74a0cc2221ac	A	To prove to the district that you have been working every week.	f	\N	2026-06-09 10:02:48.160242+00
7ea3b00e-8db6-422f-8096-f5b82ee1392b	7139b870-538e-4d2a-b11b-74a0cc2221ac	B	To keep a record of every error the teacher made so they don't repeat them.	f	\N	2026-06-09 10:02:48.160242+00
57c43db6-1c0b-45da-9372-b398640dc0ea	7139b870-538e-4d2a-b11b-74a0cc2221ac	C	To document the teacher’s success and professional journey over time rather than just counting errors.	f	\N	2026-06-09 10:02:48.160242+00
352d780c-40b9-4e11-973a-bf9c26fb7279	7139b870-538e-4d2a-b11b-74a0cc2221ac	D	To write a story that makes the school's test scores look better than they are.\r\n________________\r\n\r\n\r\nUnit 4.2: The Adaptive Facilitator	f	\N	2026-06-09 10:02:48.160242+00
b23f277c-8b2b-4fd2-a2f8-be6c709ddb04	02fe750d-566e-4899-a8db-6e53da668ce9	A	Facilitative: Asking powerful questions to help them reflect on the crisis.	f	\N	2026-06-09 10:02:48.160242+00
21683109-32af-45f2-9b58-2ff1e18fd887	02fe750d-566e-4899-a8db-6e53da668ce9	B	Directive: Providing immediate, clear instructions to ensure safety and clarity.	f	\N	2026-06-09 10:02:48.160242+00
ff87d2cb-c6ad-490d-bf66-6b75113bc45b	02fe750d-566e-4899-a8db-6e53da668ce9	C	Silent: Observing from the back to see how they handle it alone.	f	\N	2026-06-09 10:02:48.160242+00
b6380073-2c41-4304-b5bf-f293fb9d1fa6	02fe750d-566e-4899-a8db-6e53da668ce9	D	Evaluative: Taking notes on their lack of crisis management skills.	f	\N	2026-06-09 10:02:48.160242+00
be79e365-dfc7-43bc-a10f-9d6688270468	40ac57ea-373e-40f8-9de0-1ca51cf914ba	A	It allows the coach to avoid making a difficult decision.	f	\N	2026-06-09 10:02:48.160242+00
5a767bae-b5cd-46b2-b769-39fc8da9ef8c	40ac57ea-373e-40f8-9de0-1ca51cf914ba	B	It tricks the teacher into doing what the coach wanted all along.	f	\N	2026-06-09 10:02:48.160242+00
e07b4ef1-ec53-489c-b879-7bb641c0c526	40ac57ea-373e-40f8-9de0-1ca51cf914ba	C	It increases buy-in and agency by allowing the teacher to select a path that fits their current capacity.	f	\N	2026-06-09 10:02:48.160242+00
099dd958-ce1d-4a2d-b946-d08a5713ff32	40ac57ea-373e-40f8-9de0-1ca51cf914ba	D	It follows the school's policy that teachers should always be happy.\r\n________________\r\n\r\n\r\nUnit 4.3: The Partnership Advocate	f	\N	2026-06-09 10:02:48.160242+00
9b24bf37-50a4-430f-913e-25159cf2308e	a7da3358-4113-4e4b-9e67-c5663cec983b	A	Give the notes but ask the Principal to be "nice" when they talk to the teachers.	f	\N	2026-06-09 10:02:48.160242+00
73abe98f-0c00-4849-8c52-8675490c7246	a7da3358-4113-4e4b-9e67-c5663cec983b	B	Refuse to speak to the Principal at all to protect your personal integrity.	f	\N	2026-06-09 10:02:48.160242+00
c02f05e1-140b-4d9f-9493-e5b0b4a586b0	a7da3358-4113-4e4b-9e67-c5663cec983b	C	Redirect the Principal to school-wide growth patterns and trends while firmly protecting individual confidentiality.	f	\N	2026-06-09 10:02:48.160242+00
87dbb3d9-7c86-49d4-8614-d63ab42dbd7e	a7da3358-4113-4e4b-9e67-c5663cec983b	D	Hand over the notes immediately to maintain a good relationship with leadership.\r\n________________\r\n\r\n\r\nUnit 4.4: The Consistency Guardian (WRER)	f	\N	2026-06-09 10:02:48.160242+00
0cf57569-3e34-41ad-a2ab-e897e6b15a05	2f343a0a-4519-4f49-868d-e2f40847b14a	A	Hide the data so the Principal doesn't think you are being lazy.	f	\N	2026-06-09 10:02:48.160242+00
cd4e5f95-150d-465c-a307-7a05ca15ec7c	2f343a0a-4519-4f49-868d-e2f40847b14a	B	Use it to complain to the teachers about how busy you are.	f	\N	2026-06-09 10:02:48.160242+00
a011ec2d-c851-4f4c-8243-fa4baf44ca94	2f343a0a-4519-4f49-868d-e2f40847b14a	C	Use it as objective evidence to show the Principal how "displaced time" is preventing teacher growth.	f	\N	2026-06-09 10:02:48.160242+00
7b564bd9-9f71-4c47-98cb-17b8ccc7e324	2f343a0a-4519-4f49-868d-e2f40847b14a	D	Accept that inconsistency is a normal part of school life and stop tracking it.\r\n________________\r\n\r\n\r\nAnswer Key \r\nQuestion\r\n\tAnswer\r\n\t1\r\n\tB\r\n\t2\r\n\tC\r\n\t3\r\n\tB\r\n\t4\r\n\tC\r\n\t5\r\n\tC\r\n\t6\r\n\tC	f	\N	2026-06-09 10:02:48.160242+00
e171bec4-18a7-4cb5-8cf1-7c695705875e	b3eb43f0-ffd5-41f7-a2ec-3a25a4550c09	A	Remind the teacher that the Principal is expecting to see this change in their next formal evaluation.	f	\N	2026-06-09 10:02:48.160242+00
1e4642e4-2c80-4e52-b332-b78c5c0f0dea	b3eb43f0-ffd5-41f7-a2ec-3a25a4550c09	B	Mark the teacher as "Not Proficient" in your weekly report to create accountability.	f	\N	2026-06-09 10:02:48.160242+00
f78c963d-2600-4a34-8bab-a8621a8824d9	b3eb43f0-ffd5-41f7-a2ec-3a25a4550c09	C	Use a "Curious Opener" such as: "I noticed the 'No-Hands-Up' strategy wasn't used today; what barrier got in the way of trying that move?"	f	\N	2026-06-09 10:02:48.160242+00
4c493f19-9dc7-4380-ab22-a182b7844cdc	b3eb43f0-ffd5-41f7-a2ec-3a25a4550c09	D	Give the teacher a new, easier strategy since they clearly couldn't handle the first one.	f	\N	2026-06-09 10:02:48.160242+00
6372c70b-9fcc-4480-896d-c52fa0d99033	80f2b8c1-a734-40b5-bf04-893425c7843d	A	Telling the teacher they must keep using it because it is an "evidence-based" strategy.	f	\N	2026-06-09 10:02:48.160242+00
308c561c-bd98-47af-9eaf-bf87cf7f3ee7	80f2b8c1-a734-40b5-bf04-893425c7843d	B	Facilitating a "Pivot" by asking the teacher if they want to adjust the strategy (e.g., use a visual signal instead of a loud beep) or try a different one from the menu.	f	\N	2026-06-09 10:02:48.160242+00
d764b0f2-e943-4e9d-9a7f-042e4895c5e7	80f2b8c1-a734-40b5-bf04-893425c7843d	C	Agreeing that the students are the problem and moving on to a different topic.	f	\N	2026-06-09 10:02:48.160242+00
c1b9eb09-f8cd-4727-b4c6-3be8ed55d45d	80f2b8c1-a734-40b5-bf04-893425c7843d	D	Telling the teacher to ignore the students' anxiety and focus on the clock.\r\n________________\r\n\r\n\r\nUnit 6.2 & 6.4: The Partnership Advocate vs. System Pressure	f	\N	2026-06-09 10:02:48.160242+00
3001d0cf-ee65-4ad7-9652-b762defd11fd	453ea5c7-a77c-48ec-ae3e-e51a1e30dae5	A	Give the names but ask the Principal to promise not to tell the teachers where the information came from.	f	\N	2026-06-09 10:02:48.160242+00
6d7ed301-5ede-461a-9141-b7a5be7d746c	453ea5c7-a77c-48ec-ae3e-e51a1e30dae5	B	Refuse to give any information at all and walk out of the room to protect your integrity.	f	\N	2026-06-09 10:02:48.160242+00
99a2a150-5593-44c9-8827-6c83d0532adb	453ea5c7-a77c-48ec-ae3e-e51a1e30dae5	C	Validate the Principal’s goal of school improvement, but firmly hold the confidentiality boundary and offer to share "Aggregate Trends" (e.g., "70% of teachers are struggling with transitions") instead of names.	f	\N	2026-06-09 10:02:48.160242+00
d8ffd8c0-e27d-4b4a-a72d-e2b835f37345	453ea5c7-a77c-48ec-ae3e-e51a1e30dae5	D	Provide the names but only for the teachers who haven't been "nice" to you during coaching sessions.\r\n________________\r\n\r\n\r\nUnit 6.3: The Principle of Reciprocity (PP-7)	f	\N	2026-06-09 10:02:48.160242+00
6b161a53-fb1e-497f-b8d4-5ec037060548	218c830f-3c39-4a56-92c4-50af40852377	A	The coach and teacher are becoming best friends.	f	\N	2026-06-09 10:02:48.160242+00
26f6a0f4-75eb-4be2-b865-6f38b5600056	218c830f-3c39-4a56-92c4-50af40852377	B	The coach is doing the teacher a favor that the teacher must pay back later.	f	\N	2026-06-09 10:02:48.160242+00
4d64fcbd-18bf-4bb3-81aa-b2bd318c0dcf	218c830f-3c39-4a56-92c4-50af40852377	C	It recognizes that both the coach and teacher must take risks to maintain the "Sacred Space" of the coaching partnership.	f	\N	2026-06-09 10:02:48.160242+00
dd6d6b36-5854-4ad7-a34d-5982ef623c90	218c830f-3c39-4a56-92c4-50af40852377	D	It ensures that neither the coach nor the teacher gets in trouble with the District.\r\n________________\r\n\r\n\r\nUnit 6.5: Professionalism as Integrity	f	\N	2026-06-09 10:02:48.160242+00
7733116a-dcfe-4dd5-b176-467ddf4b96ed	9bdebfac-2cc8-4072-946b-e40c0e10afae	A	Following the command of the district official because they are higher in the hierarchy.	f	\N	2026-06-09 10:02:48.160242+00
72aafc48-d457-4c8a-86b9-863628ec41b4	9bdebfac-2cc8-4072-946b-e40c0e10afae	B	Guarding the integrity of the partnership by explaining that the journal is a developmental tool for the teacher, not an evaluative tool for the system.	f	\N	2026-06-09 10:02:48.160242+00
1245db2e-1e95-4be7-9727-18e596310c70	9bdebfac-2cc8-4072-946b-e40c0e10afae	C	Deleting the notes immediately so that no one can ever see them.	f	\N	2026-06-09 10:02:48.160242+00
8db7724a-e26b-405f-a238-403bdc23d5b1	9bdebfac-2cc8-4072-946b-e40c0e10afae	D	Giving the notes but editing them first to make the teacher look better.\r\n________________\r\n\r\n\r\nAnswer Key \r\nQuestion\r\n\tAnswer\r\n\t1\r\n\tC\r\n\t2\r\n\tB\r\n\t3\r\n\tC\r\n\t4\r\n\tC\r\n\t5\r\n\tB	f	\N	2026-06-09 10:02:48.160242+00
\.


--
-- Data for Name: export_scenarios; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.export_scenarios (id, training_id, situation, question, difficulty, created_at) FROM stdin;
796af68e-d1d1-4797-b1ee-600503dbf9ad	6a3d4d5c-1755-4a52-9c54-b78e24220aa6	Scenario: A coach is creating a Digital Journal entry for a teacher's growth journey. They include a photo of a student's improved essay and add the note: "Notice the shift in student engagement and clarity when you moved to the back row to support the 'Shadow' students." This note is an example of:\r\n            *	Scenario: A coach is creating a Digital Journal entry for a teacher's growth journey. They include a photo of a student's improved essay and add the note: "Notice the shift in student engagement and clarity when you moved to the back row to support the 'Shadow' students." This note is an example of:\r\n            *	medium	2026-06-09 10:02:48.160242+00
7139b870-538e-4d2a-b11b-74a0cc2221ac	6a3d4d5c-1755-4a52-9c54-b78e24220aa6	Scenario: You have been working with a teacher for three months. You decide to show them a sequence of artifacts from their Digital Journal, starting from the first "Identify" phase to the most recent "Improve" phase. Why are you acting as a "Biographer of Growth"?\r\n            *	Scenario: You have been working with a teacher for three months. You decide to show them a sequence of artifacts from their Digital Journal, starting from the first "Identify" phase to the most recent "Improve" phase. Why are you acting as a "Biographer of Growth"?\r\n            *	medium	2026-06-09 10:02:48.160242+00
02fe750d-566e-4899-a8db-6e53da668ce9	6a3d4d5c-1755-4a52-9c54-b78e24220aa6	Scenario: You are coaching a teacher who is currently facing a classroom safety crisis and feels completely overwhelmed. In this specific moment, which coaching stance is most appropriate?\r\n            *	Scenario: You are coaching a teacher who is currently facing a classroom safety crisis and feels completely overwhelmed. In this specific moment, which coaching stance is most appropriate?\r\n            *	medium	2026-06-09 10:02:48.160242+00
40ac57ea-373e-40f8-9de0-1ca51cf914ba	6a3d4d5c-1755-4a52-9c54-b78e24220aa6	Scenario: A teacher is showing resistance to changing their lesson structure. An Adaptive Facilitator offers the teacher a choice: "Would you prefer to focus on improving your 'Check for Understanding' questions or your 'Wait Time' transitions first?" Why is this effective?\r\n            *	Scenario: A teacher is showing resistance to changing their lesson structure. An Adaptive Facilitator offers the teacher a choice: "Would you prefer to focus on improving your 'Check for Understanding' questions or your 'Wait Time' transitions first?" Why is this effective?\r\n            *	medium	2026-06-09 10:02:48.160242+00
a7da3358-4113-4e4b-9e67-c5663cec983b	6a3d4d5c-1755-4a52-9c54-b78e24220aa6	Scenario: The Principal asks you for your "evaluative notes" on the "bottom 5" teachers in the building to help with a performance audit. Which response shows "Mastery" as a Partnership Advocate?\r\n            *	Scenario: The Principal asks you for your "evaluative notes" on the "bottom 5" teachers in the building to help with a performance audit. Which response shows "Mastery" as a Partnership Advocate?\r\n            *	medium	2026-06-09 10:02:48.160242+00
2f343a0a-4519-4f49-868d-e2f40847b14a	6a3d4d5c-1755-4a52-9c54-b78e24220aa6	Scenario: Your WRER (Weekly Record of Engagement & Results) data shows that you only completed 40% of your scheduled coaching visits this month because you were asked to cover classes for absent teachers. How should you use this data?\r\n            *	Scenario: Your WRER (Weekly Record of Engagement & Results) data shows that you only completed 40% of your scheduled coaching visits this month because you were asked to cover classes for absent teachers. How should you use this data?\r\n            *	medium	2026-06-09 10:02:48.160242+00
b3eb43f0-ffd5-41f7-a2ec-3a25a4550c09	f0d1c127-bb71-47e7-ac69-4f33f8112be5	Scenario: You had a great "Learn" session with a teacher about using a "No-Hands-Up" questioning strategy. However, when you return for the next observation, the teacher has gone back to only calling on the students who raise their hands.\r\nAccording to the module, this is an example of a "Leaky" coaching cycle. What is the most effective way to "Close the Loop"?\r\n*	Scenario: You had a great "Learn" session with a teacher about using a "No-Hands-Up" questioning strategy. However, when you return for the next observation, the teacher has gone back to only calling on the students who raise their hands.\r\nAccording to the module, this is an example of a "Leaky" coaching cycle. What is the most effective way to "Close the Loop"?\r\n*	medium	2026-06-09 10:02:48.160242+00
80f2b8c1-a734-40b5-bf04-893425c7843d	f0d1c127-bb71-47e7-ac69-4f33f8112be5	Scenario: During a follow-up, a teacher says, "I tried the timer, but it made the students anxious, so I stopped using it." A "Mastery" level coach should respond by:\r\n*	Scenario: During a follow-up, a teacher says, "I tried the timer, but it made the students anxious, so I stopped using it." A "Mastery" level coach should respond by:\r\n*	medium	2026-06-09 10:02:48.160242+00
453ea5c7-a77c-48ec-ae3e-e51a1e30dae5	f0d1c127-bb71-47e7-ac69-4f33f8112be5	Scenario: Your Principal calls you into their office and says, "I’m doing a performance audit. Give me the names of the three 'weakest' teachers you are coaching so I can decide whose contracts not to renew." Based on the Module 6 Mastery Rubric (Section 14), what is the "Strong Response"?\r\n*	Scenario: Your Principal calls you into their office and says, "I’m doing a performance audit. Give me the names of the three 'weakest' teachers you are coaching so I can decide whose contracts not to renew." Based on the Module 6 Mastery Rubric (Section 14), what is the "Strong Response"?\r\n*	medium	2026-06-09 10:02:48.160242+00
218c830f-3c39-4a56-92c4-50af40852377	f0d1c127-bb71-47e7-ac69-4f33f8112be5	Scenario: A teacher expresses fear about trying a new, risky student-centered activity while the coach is watching. The coach explains, "I am taking a professional risk by protecting our confidentiality from the administration so that you can feel safe taking a risk with your teaching." This is the definition of Reciprocity because:\r\n*	Scenario: A teacher expresses fear about trying a new, risky student-centered activity while the coach is watching. The coach explains, "I am taking a professional risk by protecting our confidentiality from the administration so that you can feel safe taking a risk with your teaching." This is the definition of Reciprocity because:\r\n*	medium	2026-06-09 10:02:48.160242+00
9bdebfac-2cc8-4072-946b-e40c0e10afae	f0d1c127-bb71-47e7-ac69-4f33f8112be5	Scenario: You are asked by a district official to share your "Coaching Journal" notes which contain a teacher's private reflections on their failures. How does a "Mastery" coach define Professionalism in this moment?\r\n*	Scenario: You are asked by a district official to share your "Coaching Journal" notes which contain a teacher's private reflections on their failures. How does a "Mastery" coach define Professionalism in this moment?\r\n*	medium	2026-06-09 10:02:48.160242+00
\.


--
-- Data for Name: feedback; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.feedback (id, title, description, persona_required, order_number, is_common, created_at, module_id, main_concepts, max_attempts, quiz_unlock_requires_content) FROM stdin;
014e2ea2-3a80-43c5-8f3c-329731000715	Unit 1.0: The Coaching Catalyst	Understanding coaching as a partnership-driven growth engine that honors teacher agency	null	1	true	2026-04-09 09:49:45.671727+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Coaching vs inspection, Impact Cycle, 7 Partnership Principles, confidentiality, identity shift	3	true
bcfae3fa-29c9-4972-bb32-c7909b55227c	Unit 1.1: The Partnership Posture	Shifting from a judging stance to equality-based, side-by-side partnership	null	2	true	2026-04-09 09:49:46.995059+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Judge vs Co-Pilot, 3 competency pillars, 4-step observation-to-conversation flow, partnership language toolkit	3	true
9fabc12b-0f30-421d-ad41-4deb372a6314	Unit 1.2: The Shared Mirror	Presenting classroom data as a neutral starting point for collaborative discovery	null	3	true	2026-04-09 09:49:48.259603+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Shared Mirror protocol, low-inference vs high-inference language, audit culture, 4-step process	3	true
2e867af9-1fa4-4e84-8015-c0dfbf9a4850	Unit 1.3: The Growth Engine	Operationalizing the Impact Cycle through a 4-step evidence-based partnership process	null	4	true	2026-04-09 09:49:49.495096+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	4-step coaching cycle, evidence vs interpretation, co-analysis, bite-sized action plans, loop closure	3	true
8d82e38c-73f9-4f4f-93ff-a467824ae63c	Unit 1.4: The Trust Bridge	Building ethical partnership coaching through confidentiality and trust-building practices	null	5	true	2026-04-09 09:49:50.849943+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	4-pillar ethical framework, 5 confidentiality breach types, trust-building behaviors, principal pressure handling	3	true
1a504a0a-f44b-47d0-abc2-e44d19d6508e	Unit 1.5: The Human Filter	Using AI as a partnership tool, not a replacement for human professional judgment	null	6	true	2026-04-09 09:49:52.115354+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	AI opportunity vs risk, 3-question validation framework, Pakistan-specific overrides, AI limitations	3	true
3ee06af5-aac0-49f9-9963-df6d8096805f	Unit 1.6: Coding the Classroom	Mastering the I Do/We Do/You Do/CFU schema as a partnership coaching tool	null	7	true	2026-04-09 09:49:53.359873+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Observation schema, schema + Impact Cycle, sharing schema data in partnership way, audit culture risk	3	true
ad533d06-0947-4f89-854e-64eac7bd009f	Unit 2.1: Status & Psychological Safety	Building the partnership foundation through status-safe coaching and the SCARF model	null	1	true	2026-05-05 20:14:54.638787+00	1682a68d-8350-4495-969c-acf4ac73bb99	SCARF model, status threat, 7 Partnership Principles as safety tools, evaluative vs. partnership language, confidentiality shield	3	true
e01320fb-012c-430b-a9bf-1e6d0bb5cf95	Unit 2.2: Evidence-Based Dialogue	Moving from data to teacher agency through observable evidence and curious questioning	null	2	true	2026-05-05 20:15:01.670653+00	1682a68d-8350-4495-969c-acf4ac73bb99	Observable evidence vs. interpretation, 3-step evidence-sharing protocol, Impact Cycle phases, autobiographical listening, voice ratio	3	true
81393e37-2176-4e50-ab5e-c94237481212	Unit 2.3: Goal-Setting as Co-Creation	Facilitating teacher-owned SMART goals through the 4-step co-creation questioning sequence	null	3	true	2026-05-05 20:15:08.692264+00	1682a68d-8350-4495-969c-acf4ac73bb99	4-step goal co-creation, SMART framework, teacher ownership check (1-10 scale), coach-imposed vs. teacher-owned goals, principal pressure handling	3	true
014e2ea2-3a80-43c5-8f3c-329731000715	Unit 1.0: The Coaching Catalyst	Understanding coaching as a partnership-driven growth engine that honors teacher agency	null	1	true	2026-04-09 09:49:45.671727+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Coaching vs inspection, Impact Cycle, 7 Partnership Principles, confidentiality, identity shift	3	true
bcfae3fa-29c9-4972-bb32-c7909b55227c	Unit 1.1: The Partnership Posture	Shifting from a judging stance to equality-based, side-by-side partnership	null	2	true	2026-04-09 09:49:46.995059+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Judge vs Co-Pilot, 3 competency pillars, 4-step observation-to-conversation flow, partnership language toolkit	3	true
9fabc12b-0f30-421d-ad41-4deb372a6314	Unit 1.2: The Shared Mirror	Presenting classroom data as a neutral starting point for collaborative discovery	null	3	true	2026-04-09 09:49:48.259603+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Shared Mirror protocol, low-inference vs high-inference language, audit culture, 4-step process	3	true
2e867af9-1fa4-4e84-8015-c0dfbf9a4850	Unit 1.3: The Growth Engine	Operationalizing the Impact Cycle through a 4-step evidence-based partnership process	null	4	true	2026-04-09 09:49:49.495096+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	4-step coaching cycle, evidence vs interpretation, co-analysis, bite-sized action plans, loop closure	3	true
8d82e38c-73f9-4f4f-93ff-a467824ae63c	Unit 1.4: The Trust Bridge	Building ethical partnership coaching through confidentiality and trust-building practices	null	5	true	2026-04-09 09:49:50.849943+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	4-pillar ethical framework, 5 confidentiality breach types, trust-building behaviors, principal pressure handling	3	true
1a504a0a-f44b-47d0-abc2-e44d19d6508e	Unit 1.5: The Human Filter	Using AI as a partnership tool, not a replacement for human professional judgment	null	6	true	2026-04-09 09:49:52.115354+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	AI opportunity vs risk, 3-question validation framework, Pakistan-specific overrides, AI limitations	3	true
3ee06af5-aac0-49f9-9963-df6d8096805f	Unit 1.6: Coding the Classroom	Mastering the I Do/We Do/You Do/CFU schema as a partnership coaching tool	null	7	true	2026-04-09 09:49:53.359873+00	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Observation schema, schema + Impact Cycle, sharing schema data in partnership way, audit culture risk	3	true
ad533d06-0947-4f89-854e-64eac7bd009f	Unit 2.1: Status & Psychological Safety	Building the partnership foundation through status-safe coaching and the SCARF model	null	1	true	2026-05-05 20:14:54.638787+00	1682a68d-8350-4495-969c-acf4ac73bb99	SCARF model, status threat, 7 Partnership Principles as safety tools, evaluative vs. partnership language, confidentiality shield	3	true
e01320fb-012c-430b-a9bf-1e6d0bb5cf95	Unit 2.2: Evidence-Based Dialogue	Moving from data to teacher agency through observable evidence and curious questioning	null	2	true	2026-05-05 20:15:01.670653+00	1682a68d-8350-4495-969c-acf4ac73bb99	Observable evidence vs. interpretation, 3-step evidence-sharing protocol, Impact Cycle phases, autobiographical listening, voice ratio	3	true
81393e37-2176-4e50-ab5e-c94237481212	Unit 2.3: Goal-Setting as Co-Creation	Facilitating teacher-owned SMART goals through the 4-step co-creation questioning sequence	null	3	true	2026-05-05 20:15:08.692264+00	1682a68d-8350-4495-969c-acf4ac73bb99	4-step goal co-creation, SMART framework, teacher ownership check (1-10 scale), coach-imposed vs. teacher-owned goals, principal pressure handling	3	true
\.


--
-- Data for Name: field_issues; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.field_issues (id, description, status, reported_by, assigned_to, created_at, updated_at, resolved_at) FROM stdin;
\.


--
-- Data for Name: hots_rubric_dimensions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hots_rubric_dimensions (id, dimension, description, max_score, order_number, created_at) FROM stdin;
6ac4fbb8-65a1-44eb-87bf-6259f8655c17	Critical Thinking	Teacher promotes analysis, evaluation and synthesis of ideas among students	10	1	2026-05-11 08:02:27.819734+00
21cfcad3-2caa-4221-9512-3a7d57a74640	Student Engagement	Level of student participation, curiosity and active involvement in learning	10	2	2026-05-11 08:02:27.819734+00
e4a48eb7-d285-4c56-b322-1e2b82e0d11d	Use of Resources	Effective use of teaching materials, technology and classroom tools	10	3	2026-05-11 08:02:27.819734+00
a40daa9b-d861-4a1a-9fbb-44e53557fbd9	Classroom Management	Maintaining a productive, orderly and supportive learning environment	10	4	2026-05-11 08:02:27.819734+00
dc05df9f-8b4e-4bb8-a69b-adc115205bcf	Communication Skills	Clarity of instruction, questioning techniques and effective communication	10	5	2026-05-11 08:02:27.819734+00
8f3db079-bef3-4a64-87ca-a1b00eb1e54a	Assessment & Feedback	Quality and frequency of formative assessment and feedback given to students	20	6	2026-05-11 08:02:27.819734+00
\.


--
-- Data for Name: module_quiz_attempts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.module_quiz_attempts (id, user_id, module_id, attempt_number, score, created_at, best_score, passed, attempt_count, completed_at, updated_at) FROM stdin;
1c921f6b-11c3-4872-826e-bcc5613e57ca	fdb68be8-ed12-42bb-8b27-63b108d44cc0	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	95	2026-04-30 10:55:26.025724+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
1c0f0434-4a81-41a2-ba38-5d27558d9271	eb43ebfc-3980-4fdf-81c1-ebdeb1d69b6b	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	100	2026-05-05 13:28:16.583868+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
02475942-ecdf-444b-ae18-e787e4a97cbb	13a136e1-8412-4ad9-8c33-8d94ffc08c09	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	95	2026-05-06 10:41:54.636148+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
37b45db9-c56a-4e20-80f3-98725b53d1b9	13a136e1-8412-4ad9-8c33-8d94ffc08c09	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-05-07 08:13:18.307855+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
8f362d48-dd33-4316-ab0b-f255efc5316b	1f64811c-9cbc-41ca-b262-083a0de80adf	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	81	2026-05-30 16:14:25.549666+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
ac6a2427-b604-4597-b70f-edf907f71d27	04be1530-7a2a-43e8-ab6c-2af34b305ece	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	\N	94	2026-06-02 09:43:24.141868+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
f96cd102-d219-4e69-b64d-a50fc6f0090b	1c903d37-7eb5-4420-8432-e59b9386a798	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	94	2026-06-02 10:56:26.912701+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
20dc222c-4702-4b91-8389-0893dc2d3475	01d8388c-3c39-4518-bd7a-f2c6b9153654	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	94	2026-06-03 07:11:53.740263+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
201b9d40-f9cf-4128-ae02-9994d427e273	b9417e19-0ebb-4e52-9091-aeb615c96ca8	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	81	2026-06-02 10:35:09.835574+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
a1a084c9-ca96-4cbc-a763-e6f70601a945	a6bc0bcd-46fd-4420-bcd2-94738083b143	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	100	2026-06-03 07:22:49.121908+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
d8953913-223e-4cd7-87c6-18201c30dfd6	d0c6450a-e5a4-4516-95a2-7b8caa45ddc8	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	88	2026-06-03 07:25:00.352509+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
91983d84-3ce5-44e2-9e82-a68873871a97	6e6b7747-dbe9-4453-abb6-1071b9388f24	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	63	2026-05-20 06:59:06.335604+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
5cadb768-5cd6-4d60-8822-098708564375	6e6b7747-dbe9-4453-abb6-1071b9388f24	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-05-20 07:54:54.699237+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
796f01ac-2563-4b63-a3ad-564edd9b51fe	2848c56f-9764-4245-8c5b-18347c9540da	1682a68d-8350-4495-969c-acf4ac73bb99	\N	94	2026-06-03 09:30:04.465637+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
36df6524-b4d9-47f3-bd69-2beaeda6f361	af21c833-ead9-459b-bceb-3e5214e937ca	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	88	2026-06-03 09:37:29.056003+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
a9e3281e-d52e-48f6-a61b-43fbe559f4bb	13a136e1-8412-4ad9-8c33-8d94ffc08c09	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	88	2026-06-03 09:46:45.02856+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
39666fe1-e79f-46ba-9288-b80926d02ebf	2848c56f-9764-4245-8c5b-18347c9540da	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-03 10:07:38.839595+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
280519ab-58b8-43b6-bcf9-b56df4536085	14115af8-b73f-4569-a218-5c29322d901e	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-08 09:44:12.061101+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
acc62ec4-87d3-4f21-b93f-36cec330f7a6	85d242ba-516e-430a-a3bd-e06839728f5f	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	81	2026-06-03 09:56:28.330355+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
ec93684e-3713-46e1-a577-f8512b8e1dd5	30af1bbb-e866-4780-a0e6-8bce315ba8ac	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	88	2026-06-03 10:17:43.993552+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
a9075e4e-754c-44e8-9f48-ee0b88c5baf0	30af1bbb-e866-4780-a0e6-8bce315ba8ac	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-03 11:17:33.433303+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
1cb466c2-bc3e-49f1-abe4-bafd8eb3841c	2848c56f-9764-4245-8c5b-18347c9540da	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-04 07:12:45.585271+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
58a7e080-9fb2-4773-9d26-f134de1a1ae1	1c903d37-7eb5-4420-8432-e59b9386a798	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-04 07:38:21.777569+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
4971f866-0233-4ffd-afdc-beaaa15b06c2	1c903d37-7eb5-4420-8432-e59b9386a798	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-04 08:02:32.367929+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
3d3429f2-daf6-48a5-8645-fe657badb335	1c903d37-7eb5-4420-8432-e59b9386a798	a400e0d7-bd4c-4620-98bd-47e624abcb1a	\N	100	2026-06-04 08:19:04.441897+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
f3b38579-e249-476f-b3f7-8206262164ab	1c903d37-7eb5-4420-8432-e59b9386a798	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-04 08:36:30.630417+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
0a66050c-aa2e-46db-ad17-48139f85718b	1c903d37-7eb5-4420-8432-e59b9386a798	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	\N	100	2026-06-04 10:40:06.936517+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
abcde094-bdc9-4bcf-8674-33eff6a5eeb0	2848c56f-9764-4245-8c5b-18347c9540da	a400e0d7-bd4c-4620-98bd-47e624abcb1a	\N	100	2026-06-04 11:06:23.038852+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
a1a8bf0a-6975-4171-a8ae-b3b4166a737d	fbc9cfd0-69ec-4912-8a57-d077f06ff886	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	100	2026-06-05 05:37:34.26003+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
6880a49f-be3e-45d6-ab00-f6dd6cb993d3	85d242ba-516e-430a-a3bd-e06839728f5f	1682a68d-8350-4495-969c-acf4ac73bb99	\N	88	2026-06-05 06:31:05.548252+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
3e07452f-3265-4937-8c04-bf7fd555e6d6	08a0e3b4-deff-482a-9598-1cd7425c35b2	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	100	2026-06-05 06:31:36.475905+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
65d19ad9-cd79-45ef-a563-0818f279591f	30af1bbb-e866-4780-a0e6-8bce315ba8ac	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-05 06:52:07.712022+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
7d2ff254-dd51-4476-b717-9459d7af16e4	85d242ba-516e-430a-a3bd-e06839728f5f	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	94	2026-06-05 07:01:20.706755+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
391ca63a-7923-4a7d-9f97-50c763f1fe6b	85d242ba-516e-430a-a3bd-e06839728f5f	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-05 09:05:58.246473+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
277e4921-a819-42d6-bdc4-72c745d61eee	e0e2cab8-572f-42e4-b5b8-176693832a1b	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	81	2026-06-05 10:01:30.654203+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
7de9e101-f7b4-4fa0-a2ae-09bff32d1dc9	e0e2cab8-572f-42e4-b5b8-176693832a1b	1682a68d-8350-4495-969c-acf4ac73bb99	\N	94	2026-06-05 10:31:39.390796+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
5ac043ee-bb7e-4e03-bed7-e8fe2b9df2f3	e78ada6f-85bc-4228-b03f-5e6e4b5bf760	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-05 10:36:42.141114+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
5c49df0e-521d-404e-9990-f4a85ccef038	5e56d4cf-56d4-47a9-b199-60e9b0d13da0	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	63	2026-06-05 11:20:17.939837+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
c10b521d-080a-41fb-8513-7cf3884b01d1	e0e2cab8-572f-42e4-b5b8-176693832a1b	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-05 11:27:26.591848+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
56b1d886-7d53-4b1c-8b67-015afaaaf4a4	8197d6b8-d9f7-4616-b656-abc5c88268d4	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	63	2026-06-08 03:30:40.774804+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
5f998bbd-3a3c-4940-8800-45eb6593ce6c	8197d6b8-d9f7-4616-b656-abc5c88268d4	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-08 04:25:34.663552+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
9a9678d2-7e73-4b93-80e5-c36eb858fc06	ceeb8b93-bd10-4adb-9b71-a5e416cd929b	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	94	2026-06-08 06:22:42.427524+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
ebcd3d04-20c5-4da4-a6bf-1f8eaac79677	14115af8-b73f-4569-a218-5c29322d901e	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	88	2026-06-08 06:38:45.393097+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
43d5d2ce-80d2-458d-87b3-4605d5a7e42a	14115af8-b73f-4569-a218-5c29322d901e	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-08 06:50:00.541262+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
7257a04e-d0f0-4bb5-97b3-9f0ac5ad7c3a	bfc3570d-2f3d-4746-9780-e831b28b6df1	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	81	2026-06-08 07:42:41.573033+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
f03c1f54-23cf-4265-aa18-d69c6481ae95	eb43ebfc-3980-4fdf-81c1-ebdeb1d69b6b	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	\N	94	2026-06-08 07:44:34.983116+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
7106d36c-e169-4fcf-b881-4753181df430	bfc3570d-2f3d-4746-9780-e831b28b6df1	1682a68d-8350-4495-969c-acf4ac73bb99	\N	94	2026-06-08 07:55:33.41142+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
e34899ae-2ca3-4ff6-b7a3-6ede9d489877	746a4e6a-9f50-4952-b4a1-3adde78e4ed8	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	69	2026-06-08 08:11:17.556293+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
61d588d5-1cdb-4cec-9e90-21ba4e2988cb	5060a286-9a2b-4919-9d07-0bb7451d01fc	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	94	2026-06-08 08:05:15.095711+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
5ccc820c-d30f-43af-b385-6d86d2fb4a34	32e0e04c-ef61-49c5-8259-72ab64dc056f	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	100	2026-06-08 08:19:58.937626+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
1f78efca-3080-44c6-abaa-72609e13bf80	30af1bbb-e866-4780-a0e6-8bce315ba8ac	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-08 08:26:30.160546+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
86ff7dbf-1114-442d-8812-bcbeaf8bbc78	5060a286-9a2b-4919-9d07-0bb7451d01fc	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-08 08:29:55.810906+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
2762a216-7076-4629-9d79-7ed7877732b2	13a136e1-8412-4ad9-8c33-8d94ffc08c09	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-08 08:53:08.469417+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
90901f67-bf4f-47f3-9ae0-c86bbab72095	14115af8-b73f-4569-a218-5c29322d901e	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-08 09:12:47.595306+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
ae24c650-e208-4f27-8235-b1448bc23272	5060a286-9a2b-4919-9d07-0bb7451d01fc	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-08 09:32:31.638317+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
7979b220-6fc8-4e92-afe3-059a50621613	13406b93-309e-49c7-8890-cf5033454865	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	94	2026-06-08 09:54:39.349074+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
53ff1de0-c73e-446e-becc-28b0f741fa19	14115af8-b73f-4569-a218-5c29322d901e	a400e0d7-bd4c-4620-98bd-47e624abcb1a	\N	94	2026-06-08 09:55:38.462886+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
b7838d19-6c8c-4f5a-8e54-fb5e0b020b75	30af1bbb-e866-4780-a0e6-8bce315ba8ac	a400e0d7-bd4c-4620-98bd-47e624abcb1a	\N	100	2026-06-08 10:05:30.819743+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
daa96167-d8d0-463b-967d-9180ee2f454c	14115af8-b73f-4569-a218-5c29322d901e	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	\N	100	2026-06-08 10:05:33.644827+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
3813bc6e-6a54-4842-8476-a7133c4df5d2	849d6cc7-e42e-42ec-beff-def88c23aa91	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	81	2026-06-08 10:08:02.117357+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
a292dd75-3c54-44d8-bbc2-b8ec8e0e5de9	af21c833-ead9-459b-bceb-3e5214e937ca	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-08 10:09:07.621489+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
fa97958b-9e27-4109-92d2-c3b53c95fc1b	1f64811c-9cbc-41ca-b262-083a0de80adf	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-08 10:11:04.870639+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
a1a3d534-3150-4683-94fd-f6ad5b4416d6	849d6cc7-e42e-42ec-beff-def88c23aa91	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-08 10:38:43.682518+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
a6b447c1-bf1c-4a24-9412-44dcfc32ebac	1f64811c-9cbc-41ca-b262-083a0de80adf	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-08 10:47:45.43811+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
931dd4ee-c12a-47c1-bcbb-2a7345a3f713	7112236b-c2bf-4032-8c69-9e38234f4cbf	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	94	2026-06-09 05:38:04.755982+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
6341a89c-8c00-447a-a872-1ffd1cfd85e3	01d8388c-3c39-4518-bd7a-f2c6b9153654	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-09 05:50:47.585243+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
25806bd7-74ca-4fdd-baf9-50c7dd1db61b	01d8388c-3c39-4518-bd7a-f2c6b9153654	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-09 05:53:13.067943+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
26f06c1b-5171-4517-8a42-2083b61856ee	01d8388c-3c39-4518-bd7a-f2c6b9153654	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-09 05:54:53.939716+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
ad794041-3c00-4e5f-8ed3-94f9aed4f4a8	a443269f-d33e-4bed-9e2a-72f21c8981ae	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	88	2026-06-08 11:20:48.891665+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
fcc6d21b-a405-4b9b-8827-7e459b8fe347	01d8388c-3c39-4518-bd7a-f2c6b9153654	a400e0d7-bd4c-4620-98bd-47e624abcb1a	\N	100	2026-06-09 05:57:26.792594+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
3320356d-d856-4de7-8f57-d9b8f144d2b3	01d8388c-3c39-4518-bd7a-f2c6b9153654	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	\N	100	2026-06-09 06:03:09.93902+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
0e93b868-d575-45fc-a1a2-c6f7bba909ba	7112236b-c2bf-4032-8c69-9e38234f4cbf	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-09 06:05:13.770746+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
85317845-c93c-43e4-b646-44b0f0c0c3c9	30af1bbb-e866-4780-a0e6-8bce315ba8ac	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	\N	100	2026-06-09 06:15:43.901629+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
d62abd01-be4b-429f-a631-e194f56786c9	5060a286-9a2b-4919-9d07-0bb7451d01fc	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-09 06:23:36.710589+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
f0c86c8e-45db-4e21-bd97-853188ec05d9	b1239541-be2e-4995-a6d1-4f0f928b280a	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	88	2026-06-09 06:32:32.721065+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
130cffb7-1515-417d-9a72-93228fff0a81	b1239541-be2e-4995-a6d1-4f0f928b280a	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-09 06:45:55.392549+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
68bdde66-d94a-4ed9-82dd-55575eafe7a1	b1239541-be2e-4995-a6d1-4f0f928b280a	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	94	2026-06-09 07:01:54.703947+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
e4965b14-8965-4b23-af35-558db14f27eb	5060a286-9a2b-4919-9d07-0bb7451d01fc	a400e0d7-bd4c-4620-98bd-47e624abcb1a	\N	100	2026-06-09 06:42:07.929983+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
fa31aed6-10bc-450f-816e-6c218832f444	5060a286-9a2b-4919-9d07-0bb7451d01fc	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	\N	94	2026-06-09 07:18:19.510178+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
46e8ef3b-70ef-4fda-8b70-9ceb0e0dffdd	835a5110-1ea5-4e2c-9d21-5547755d5076	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-09 07:50:59.808657+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
4e3ba19d-0da2-476b-973e-63fe246e64c9	531e9525-9f03-4a02-81e9-1d4ed5100e38	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	25	2026-04-29 07:44:17.885206+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
105c7947-2fbe-46af-90e7-1abf0b2201ac	835a5110-1ea5-4e2c-9d21-5547755d5076	930b8390-f110-4949-a5d8-e56596cd8792	\N	94	2026-06-09 10:52:43.541964+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
d1ec437c-e562-41ad-8fa4-02ce43cf70b5	b9417e19-0ebb-4e52-9091-aeb615c96ca8	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-09 11:05:08.063415+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
dd37cdf2-6811-4689-8430-5605f088374e	bb6fa6c0-9408-4496-b175-121cab8aba36	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	100	2026-06-10 05:17:39.808613+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
2026ac8d-8e33-4674-8d34-84f1bef85794	bb6fa6c0-9408-4496-b175-121cab8aba36	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-10 05:31:35.839909+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
fc8a27e3-7489-4977-8243-0af3a8854ee3	bb6fa6c0-9408-4496-b175-121cab8aba36	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-10 05:35:41.22897+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
4e656fc1-4197-42ba-985a-a82a10139de7	bb6fa6c0-9408-4496-b175-121cab8aba36	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-10 05:40:46.845751+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
0d2a8df5-1e8e-4a3d-8312-6ba5df9a3892	bb6fa6c0-9408-4496-b175-121cab8aba36	a400e0d7-bd4c-4620-98bd-47e624abcb1a	\N	94	2026-06-10 05:47:11.32076+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
391e14a4-3244-4911-a5c9-8d77cd9b4f82	c51327ba-4d36-4077-87a0-1e7d1eedf743	dabd5448-02b0-4abe-8729-47cad9fe1ce8	\N	100	2026-06-10 08:10:22.395333+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
ecd6742a-ad12-44be-964e-1abfc3032302	b9417e19-0ebb-4e52-9091-aeb615c96ca8	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	94	2026-06-10 10:15:38.10973+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
2af66aac-3b67-4e75-a713-4067e0ba1276	ceeb8b93-bd10-4adb-9b71-a5e416cd929b	a400e0d7-bd4c-4620-98bd-47e624abcb1a	\N	100	2026-06-10 11:45:32.718659+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
9020ac60-5e32-4428-ada6-cced662a99c7	13406b93-309e-49c7-8890-cf5033454865	1682a68d-8350-4495-969c-acf4ac73bb99	\N	100	2026-06-11 05:00:44.874369+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
cdb4cc7f-bd37-4e95-b300-725bdd098448	b1239541-be2e-4995-a6d1-4f0f928b280a	930b8390-f110-4949-a5d8-e56596cd8792	\N	100	2026-06-11 05:04:34.23998+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
7a8c979b-91b0-4828-a115-c34d8d8ec593	bb6fa6c0-9408-4496-b175-121cab8aba36	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	\N	94	2026-06-11 05:10:19.686962+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
38488628-9bdd-4825-84b9-eff3d4d40332	b1239541-be2e-4995-a6d1-4f0f928b280a	a400e0d7-bd4c-4620-98bd-47e624abcb1a	\N	88	2026-06-11 05:15:11.300378+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
b3c2fe40-4e5c-4cdb-85ef-f0bd0b92c5e6	b1239541-be2e-4995-a6d1-4f0f928b280a	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	\N	100	2026-06-11 05:31:00.758874+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
48a7c62f-40b4-4d57-8578-952ec397780e	af21c833-ead9-459b-bceb-3e5214e937ca	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	\N	100	2026-06-11 07:00:44.145972+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
94d8002a-0492-4217-8ecc-fe14440a91f2	a443269f-d33e-4bed-9e2a-72f21c8981ae	1682a68d-8350-4495-969c-acf4ac73bb99	\N	88	2026-06-11 07:16:03.440189+00	0	f	0	\N	2026-06-12 17:00:54.318017+00
\.


--
-- Data for Name: modules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modules (id, title, description, is_mandatory, order_number, competencies, persona_required, created_at) FROM stdin;
dabd5448-02b0-4abe-8729-47cad9fe1ce8	Module 1: Universal Core Refresher	Mandatory foundation for all coaches. Aligns with the Taleemabad Coaching OS and redefines coaching as a catalyst for teacher growth.	t	1	Strategic Vision, Developmental Stance, Evidence-Based Observation, Ethical Professionalism, Context-Aware Data Validation, Universal Instructional Language	\N	2026-04-09 09:49:45.381884+00
1682a68d-8350-4495-969c-acf4ac73bb99	Module 2: The Partnership Foundation	Building psychological safety, evidence-based dialogue, and teacher-owned goal co-creation as the foundation of partnership coaching.	f	2	Psychological Safety, Status-Safe Communication, Evidence-Based Dialogue, Goal Co-Creation, Partnership Principles Application	\N	2026-05-05 20:14:53.88116+00
6f0bd368-c57f-45e9-a6ad-f5875a71afa3	Module 3: The Mirror Specialist	Mastering objective observation, artifact collection, and data-to-dialogue conversion as the core tools of partnership coaching.	f	3	Objective Observation, Low-Inference Documentation, Artifact Architecture, Evidence-Based Dialogue, Data Protection	\N	2026-05-13 08:19:51.825688+00
930b8390-f110-4949-a5d8-e56596cd8792	Module 4: Digital & Data Intelligence	Building the digital coaching toolkit through journal annotation, adaptive facilitation, partnership advocacy, and consistency tracking.	f	4	Digital Journaling, Adaptive Facilitation, Partnership Advocacy, Consistency Tracking, Confidentiality Defence	\N	2026-05-13 08:41:57.563871+00
a400e0d7-bd4c-4620-98bd-47e624abcb1a	Module 5: The Instructional Catalyst	Integrating Choice across the Impact Cycle, diagnosing intellectual gaps, closing coaching loops with Side-by-Side modeling, and achieving Precision Coaching through 3 Loops diagnosis.	f	5	Choice Integration, Intellectual Gap Diagnosis, Side-by-Side Modeling, Precision Coaching, Loop Diagnosis, Coaching Obsolescence	\N	2026-05-13 08:42:34.727786+00
6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	Module 6: The Excellence Loop	Closing coaching loops, applying protocol guardrails, contextualizing strategies to real classroom constraints, and guarding the Sacred Space through Reciprocity and integrity-based professionalism.	f	6	Loop Closure, Protocol Fidelity, Responsive Contextualization, Praxis, Reciprocity Defense, Integrity-Based Professionalism	\N	2026-05-13 08:43:10.686489+00
\.


--
-- Data for Name: options; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.options (id, question_id, option_text, is_correct, order_number, created_at) FROM stdin;
24f52669-a116-4975-bbde-1cc8a95ea6f3	84c7800c-9714-4b7d-b629-4616124a004c	From Partner to Expert	f	\N	2026-05-13 08:19:54.226025+00
c95b3d3a-9fe2-4db9-a22f-b38e979f7e8b	84c7800c-9714-4b7d-b629-4616124a004c	From Expert with an Opinion to Mirror Specialist	t	\N	2026-05-13 08:19:54.226025+00
83e1a052-519b-44f6-8dc2-87d4d2338d13	84c7800c-9714-4b7d-b629-4616124a004c	From Coach to Principal	f	\N	2026-05-13 08:19:54.226025+00
a9643e45-9d94-4b39-b96b-46a56d98583c	84c7800c-9714-4b7d-b629-4616124a004c	From Observer to Teacher	f	\N	2026-05-13 08:19:54.226025+00
c5c53b75-def0-4f1d-a390-6d87413e85b6	224c78b9-7bb0-4697-b950-7b3ec818e5e0	Tell the teacher how they look	f	\N	2026-05-13 08:19:55.573737+00
417e9485-649d-44a5-8cca-854d65027bd2	224c78b9-7bb0-4697-b950-7b3ec818e5e0	Reflect reality so the teacher can choose to adjust themselves	t	\N	2026-05-13 08:19:55.573737+00
a144e81b-a68f-4461-b404-bf6865d624f5	224c78b9-7bb0-4697-b950-7b3ec818e5e0	Hide the teacher's mistakes	f	\N	2026-05-13 08:19:55.573737+00
d2871e46-c70d-49ba-a449-19bfccbf59ff	224c78b9-7bb0-4697-b950-7b3ec818e5e0	Praise the teacher's personality	f	\N	2026-05-13 08:19:55.573737+00
1f15ca5a-8977-4d01-81d3-69cb61925bec	988ae0b9-9125-4cd8-a50c-c9fbfc504786	They are easier to carry	f	\N	2026-05-13 08:19:59.669425+00
697f1931-427c-4cb1-9e05-ba853ef32309	988ae0b9-9125-4cd8-a50c-c9fbfc504786	They act as a 'Third Party' that both partners can look at together	t	\N	2026-05-13 08:19:59.669425+00
d38fb439-aa7c-429e-a943-00e870cac035	988ae0b9-9125-4cd8-a50c-c9fbfc504786	They prove the coach was actually in the room	f	\N	2026-05-13 08:19:59.669425+00
d6cc25a7-d774-4a06-8767-dbcafbd63c80	988ae0b9-9125-4cd8-a50c-c9fbfc504786	They are required by the government	f	\N	2026-05-13 08:19:59.669425+00
a3444d48-2487-4b3f-98f5-c61b15b14210	c929f7f7-35ad-4e8f-a2d8-7789789c9d5b	'Look at this mistake you made'	f	\N	2026-05-13 08:20:01.322578+00
ae676bcc-6406-4450-a1d3-f646232c5e48	c929f7f7-35ad-4e8f-a2d8-7789789c9d5b	'What do you notice in this photo of the back row?'	t	\N	2026-05-13 08:20:01.322578+00
92cf3566-1f5d-48ba-9ed3-79dd8aab0843	c929f7f7-35ad-4e8f-a2d8-7789789c9d5b	'I took this to show the Principal'	f	\N	2026-05-13 08:20:01.322578+00
296e0ba8-7a37-4a93-9d67-fa261bf38def	c929f7f7-35ad-4e8f-a2d8-7789789c9d5b	'This is why your lesson failed'	f	\N	2026-05-13 08:20:01.322578+00
4079a53b-2b52-48b1-a8e6-ffb9dc98fa73	13f2a09d-71e1-4edb-b538-64fc99802d46	A sharp criticism of the lesson	f	\N	2026-05-13 08:20:05.47198+00
c79da50a-1987-40cb-8e10-0ff6ceb2fe8e	13f2a09d-71e1-4edb-b538-64fc99802d46	An open-ended question about a specific piece of evidence	t	\N	2026-05-13 08:20:05.47198+00
dd385906-44b4-491a-8626-7abd06c67227	13f2a09d-71e1-4edb-b538-64fc99802d46	A timer used to end the meeting	f	\N	2026-05-13 08:20:05.47198+00
3ca59365-ef30-4cab-84b0-3fc8aee0b745	13f2a09d-71e1-4edb-b538-64fc99802d46	A compliment about the teacher's clothes	f	\N	2026-05-13 08:20:05.47198+00
25331969-b1cb-48d3-aba3-0fb231eb023e	c9cd60ea-9a25-4de2-ae9d-41d68a34d9f9	The teacher and coach talking for the same amount of time	f	\N	2026-05-13 08:20:06.816589+00
1022d6d9-77b6-4e0c-ae47-6a939a8d3cdd	c9cd60ea-9a25-4de2-ae9d-41d68a34d9f9	Both partners being open to learning and changing their minds based on data	t	\N	2026-05-13 08:20:06.816589+00
daf8f911-5146-44f0-8dc4-cae54e1e72a6	c9cd60ea-9a25-4de2-ae9d-41d68a34d9f9	The coach giving the teacher a gift	f	\N	2026-05-13 08:20:06.816589+00
defd2f68-9e80-4ab7-8ba0-c39013e2e7a2	c9cd60ea-9a25-4de2-ae9d-41d68a34d9f9	The teacher doing exactly what the coach says	f	\N	2026-05-13 08:20:06.816589+00
bf7bf003-84e8-4e01-8b22-93570d7e4862	ca4dc07a-516e-435c-86ca-a49c6d4942df	Demonstrated expertise	f	\N	2026-05-13 08:43:19.47917+00
9bb35b31-e053-44be-b388-2bdb8e82cec1	5edd2022-7ca4-4c60-8096-621b895269d0	Limits what a teacher can say	f	\N	2026-05-13 08:43:20.394822+00
c5d3090f-29da-4319-9804-a0cac31e8c4e	5edd2022-7ca4-4c60-8096-621b895269d0	Keeps the conversation partnership-aligned even under pressure	t	\N	2026-05-13 08:43:20.394822+00
94eff0ca-375e-470f-a0b0-51470ec3a750	5edd2022-7ca4-4c60-8096-621b895269d0	Slows down the coaching process	f	\N	2026-05-13 08:43:20.394822+00
200e8a2e-88ca-4ad1-8e00-bbf54f7bd2ec	5edd2022-7ca4-4c60-8096-621b895269d0	Reports errors to the Principal	f	\N	2026-05-13 08:43:20.394822+00
b0e880cd-e3af-4264-8e29-a3e123888d56	e88dccc6-dcd5-41a6-8c7f-c097c5fb1232	Reading manuals	f	\N	2026-05-13 08:43:24.351155+00
afb07bd1-a20c-4f3c-85ed-e0ccbd972b8d	e88dccc6-dcd5-41a6-8c7f-c097c5fb1232	Real-world action followed by reflection	t	\N	2026-05-13 08:43:24.351155+00
853509d0-c080-4123-b17a-76ae949a8bdb	e88dccc6-dcd5-41a6-8c7f-c097c5fb1232	Watching videos of others	f	\N	2026-05-13 08:43:24.351155+00
389e52a0-d38c-43c6-9b0d-9e5b5000ef63	e88dccc6-dcd5-41a6-8c7f-c097c5fb1232	Passing a written test	f	\N	2026-05-13 08:43:24.351155+00
8b69041e-18f6-4785-88ee-83bdab246d1a	95a06f9a-8339-4bf8-a0ab-185c375ed133	Professionalism	f	\N	2026-05-13 08:43:25.266863+00
7475c17b-2861-4a97-b421-7754649567b9	95a06f9a-8339-4bf8-a0ab-185c375ed133	A 'Leaky' coaching cycle	t	\N	2026-05-13 08:43:25.266863+00
50d38c55-39dd-4af9-92d0-0601b066e304	95a06f9a-8339-4bf8-a0ab-185c375ed133	Excellence	f	\N	2026-05-13 08:43:25.266863+00
c33e60d1-d352-4869-9a57-20b96036540e	95a06f9a-8339-4bf8-a0ab-185c375ed133	Hierarchy	f	\N	2026-05-13 08:43:25.266863+00
3678799e-eb33-47be-ac10-bff664a02822	37640a86-ad5a-4416-a28f-7d17f034841a	Written reports	f	\N	2026-05-13 08:43:26.140429+00
51bb81e5-6dcd-430a-98d1-9a0ee5ec88c6	37640a86-ad5a-4416-a28f-7d17f034841a	Observable student results	t	\N	2026-05-13 08:43:26.140429+00
940f8a9c-2e9f-46a8-9b58-c479fd62e1d7	37640a86-ad5a-4416-a28f-7d17f034841a	Longer meetings	f	\N	2026-05-13 08:43:26.140429+00
d6f6fffc-d4f7-4f18-bf04-658a3475270d	37640a86-ad5a-4416-a28f-7d17f034841a	Principal approvals	f	\N	2026-05-13 08:43:26.140429+00
c69063ce-5417-462c-b09e-08f210cf1183	5ea36ccf-5aec-45ed-aeb4-18c21739e93a	The teacher giving the coach a gift	f	\N	2026-05-13 08:43:29.243016+00
f0a79e78-8943-496a-8c0a-bf892dd2017a	5ea36ccf-5aec-45ed-aeb4-18c21739e93a	The coach protecting the teacher's growth data just as they expect the teacher to grow	t	\N	2026-05-13 08:43:29.243016+00
5104d28f-59b1-48fd-a023-89deeb2c89d9	5ea36ccf-5aec-45ed-aeb4-18c21739e93a	The coach and teacher swapping roles	f	\N	2026-05-13 08:43:29.243016+00
76e5ff6f-9b1e-4bee-9cd4-333a1833da95	5ea36ccf-5aec-45ed-aeb4-18c21739e93a	Reporting every detail to the Principal	f	\N	2026-05-13 08:43:29.243016+00
f6fb8b84-43cc-4b63-914c-3d41d241191f	3d16617f-79e2-43c4-973e-dbeafb13c012	Giving the names to avoid trouble	f	\N	2026-05-13 08:43:30.132184+00
36bdec57-45d0-4a04-ba1d-41f165318001	3d16617f-79e2-43c4-973e-dbeafb13c012	Redirecting to 'Aggregate Trends' (e.g., '70% of teachers are mastering the Planning Loop')	t	\N	2026-05-13 08:43:30.132184+00
545b4c6e-2e3a-47a2-acf3-80e5445fea07	3d16617f-79e2-43c4-973e-dbeafb13c012	Telling the Principal it is none of their business	f	\N	2026-05-13 08:43:30.132184+00
537fdb86-5900-415a-926a-a9bf6952ee62	3d16617f-79e2-43c4-973e-dbeafb13c012	Quitting the coaching job	f	\N	2026-05-13 08:43:30.132184+00
300ad6bd-c8cc-458e-963f-da0e019285e3	9c3cd2e1-8de8-48b2-80ac-cf435d96e5d9	Total compliance	f	\N	2026-05-13 08:43:31.096643+00
5e0a8904-9731-4a33-8940-4e79e840daa7	9c3cd2e1-8de8-48b2-80ac-cf435d96e5d9	Validating the Principal's goal while firmly holding the confidentiality boundary	t	\N	2026-05-13 08:43:31.096643+00
0bdee6f3-b34e-4617-b675-425719486306	9c3cd2e1-8de8-48b2-80ac-cf435d96e5d9	Blaming the teacher	f	\N	2026-05-13 08:43:31.096643+00
0cef9351-6aa1-445b-a841-6259a870aa1c	9c3cd2e1-8de8-48b2-80ac-cf435d96e5d9	Sharing the teacher's personal journal	f	\N	2026-05-13 08:43:31.096643+00
f4fcd2c0-453d-4cbf-b82c-7cc6ed00b9d4	d79a3e70-be1d-4449-93af-dbbd1f9e40e1	The teacher was very enthusiastic	f	\N	2026-05-13 08:19:54.676693+00
cc438220-84af-4310-850d-d8eb9b25a1c8	d79a3e70-be1d-4449-93af-dbbd1f9e40e1	The students were behaving poorly	f	\N	2026-05-13 08:19:54.676693+00
ca7f5449-eddf-4048-b8e1-c498129d6ca5	d79a3e70-be1d-4449-93af-dbbd1f9e40e1	The teacher walked to the back of the room three times	t	\N	2026-05-13 08:19:54.676693+00
31e88084-8300-43a1-91ba-d689627b8928	d79a3e70-be1d-4449-93af-dbbd1f9e40e1	The lesson was highly effective	f	\N	2026-05-13 08:19:54.676693+00
495d1e87-c83d-48b7-a20a-866e0705ba05	90c798fc-b2df-4cee-a759-4338fb9f66a7	Teacher Actions	f	\N	2026-05-13 08:19:56.015914+00
780c31e0-22ae-4c1e-a0a5-91dfb79b422c	90c798fc-b2df-4cee-a759-4338fb9f66a7	Student Evidence (what students say/do)	t	\N	2026-05-13 08:19:56.015914+00
ab31c332-9590-434d-b362-c6758dd744d3	90c798fc-b2df-4cee-a759-4338fb9f66a7	Coach's Opinions	f	\N	2026-05-13 08:19:56.015914+00
75814d8b-b469-4f97-8c5b-9fb14a856819	90c798fc-b2df-4cee-a759-4338fb9f66a7	The Principal's comments	f	\N	2026-05-13 08:19:56.015914+00
5f6f296d-505c-4fd5-86e5-8638459064b3	eb7de284-61bd-48f0-a82b-fc20f5217ab7	Ask the Principal for permission to visit	f	\N	2026-05-13 08:20:00.178153+00
10530a1b-9971-4af6-9792-f0f381938d17	eb7de284-61bd-48f0-a82b-fc20f5217ab7	Protect teacher agency before capturing a photo or video	t	\N	2026-05-13 08:20:00.178153+00
52a53beb-7765-459a-ba73-f213c7980d09	eb7de284-61bd-48f0-a82b-fc20f5217ab7	Get student signatures for a survey	f	\N	2026-05-13 08:20:00.178153+00
f20fdff6-8b5c-49b1-a883-4aec06f4fc54	eb7de284-61bd-48f0-a82b-fc20f5217ab7	Allow the coach to take a break	f	\N	2026-05-13 08:20:00.178153+00
07c2d9fa-57e5-459d-8d8f-e224077deaed	587f7313-f818-468d-b536-66c99c8113a1	Never lets the teacher see the photos	f	\N	2026-05-13 08:20:01.838186+00
4fbaac9f-067b-4951-9e44-b8897f6df4a6	587f7313-f818-468d-b536-66c99c8113a1	Refuses to share individual artifacts with administration to preserve trust	t	\N	2026-05-13 08:20:01.838186+00
3731a8e0-cd2d-4b33-8262-28bcf93126b3	587f7313-f818-468d-b536-66c99c8113a1	Keeps the artifacts on a public school website	f	\N	2026-05-13 08:20:01.838186+00
24e167a3-586d-48ca-a838-a2ed3e0041f5	587f7313-f818-468d-b536-66c99c8113a1	Deletes everything immediately after the lesson	f	\N	2026-05-13 08:20:01.838186+00
cf5cf267-26d7-4439-a0e0-3192b877e327	0d16d4be-c195-4a36-956e-2e6c29012e4a	Teacher Monologue	f	\N	2026-05-13 08:20:04.582347+00
9969c2a1-87a1-4999-861d-cfa8bdf49706	0d16d4be-c195-4a36-956e-2e6c29012e4a	Partnership Dialogue	t	\N	2026-05-13 08:20:04.582347+00
60746e07-5ab2-49cf-a7e4-4459ff6d1723	0d16d4be-c195-4a36-956e-2e6c29012e4a	Silent Observation	f	\N	2026-05-13 08:20:04.582347+00
1df197d2-4598-4215-bccd-222a6b5252d4	0d16d4be-c195-4a36-956e-2e6c29012e4a	Principal Interview	f	\N	2026-05-13 08:20:04.582347+00
c63e6385-9e2d-492a-9be6-be9e1523edb2	ef9e8b31-2bfb-4340-9c3c-02361a3785a3	Agree with the criticism to be honest	f	\N	2026-05-13 08:20:05.936567+00
0ec15d10-5796-45d1-acda-91b761a0f012	ef9e8b31-2bfb-4340-9c3c-02361a3785a3	Redirect to 'Curiosity' and ask what the data suggests for next steps	t	\N	2026-05-13 08:20:05.936567+00
278ac786-e7a1-48aa-bffd-64e10f08fb26	ef9e8b31-2bfb-4340-9c3c-02361a3785a3	Stop the meeting immediately	f	\N	2026-05-13 08:20:05.936567+00
fef78a34-3fc4-4d3a-9200-68cfa9eceddd	ef9e8b31-2bfb-4340-9c3c-02361a3785a3	Tell the teacher not to worry	f	\N	2026-05-13 08:20:05.936567+00
e0895945-087f-40ad-9a8a-2abae1abb9cb	f9ac7b07-4a36-47dd-991a-74e0b5fc1200	The coach needs to look busy	f	\N	2026-05-13 08:43:24.778434+00
645962ce-347d-43f0-be65-25f0c22ac18b	f9ac7b07-4a36-47dd-991a-74e0b5fc1200	It prevents teachers from talking	f	\N	2026-05-13 08:43:24.778434+00
6606b780-bc88-405b-a2d9-36700fe87808	1b20cc63-dfe2-4c69-9676-f27912f7441e	Laziness	f	\N	2026-05-13 08:43:25.699918+00
9fe8f1db-6c25-4258-82ca-ea5b35977a36	1b20cc63-dfe2-4c69-9676-f27912f7441e	Responsive Contextualization	t	\N	2026-05-13 08:43:25.699918+00
64fa27ff-2bd2-4791-87ba-0c0852a5d5cd	1b20cc63-dfe2-4c69-9676-f27912f7441e	Audit Culture	f	\N	2026-05-13 08:43:25.699918+00
c77f7c11-7ea0-4bfb-aa0f-2bbe44ed00f2	1b20cc63-dfe2-4c69-9676-f27912f7441e	Expertise	f	\N	2026-05-13 08:43:25.699918+00
92e4bea5-08b0-4ded-88da-243bc153a4a5	9a7873c8-f9e0-4222-8d4a-cb55271a5e1a	Rapid growth	f	\N	2026-05-13 08:43:29.674595+00
80f2f662-c9fd-4854-a915-2850efcee76e	9a7873c8-f9e0-4222-8d4a-cb55271a5e1a	Fear and 'Status Denial,' causing teachers to hide their struggles	t	\N	2026-05-13 08:43:29.674595+00
827d12a5-ce9a-4ec7-b6ca-0a2914864bfc	9a7873c8-f9e0-4222-8d4a-cb55271a5e1a	Better student scores	f	\N	2026-05-13 08:43:29.674595+00
d2393dbb-138c-4e0a-8d9c-2ceaabf5d22b	9a7873c8-f9e0-4222-8d4a-cb55271a5e1a	Increased funding	f	\N	2026-05-13 08:43:29.674595+00
c56ab551-63be-4a5f-9b97-a65c8908b4b4	4c8f4de0-ca83-4898-b425-d7a958bb3441	The coach has their own office	f	\N	2026-05-13 08:43:30.570041+00
70ca0bf3-1f99-4b34-b605-c097fdefd5d1	4c8f4de0-ca83-4898-b425-d7a958bb3441	Coaching remains a developmental tool, not an evaluative one	t	\N	2026-05-13 08:43:30.570041+00
ddc1fd72-5a07-44f2-aa85-76c5205543f6	4c8f4de0-ca83-4898-b425-d7a958bb3441	Only religious subjects are taught	f	\N	2026-05-13 08:43:30.570041+00
8418f0f0-1f7f-4718-9d92-5c023114c66c	4c8f4de0-ca83-4898-b425-d7a958bb3441	The classroom door is locked	f	\N	2026-05-13 08:43:30.570041+00
db66b0eb-3d8f-415f-afde-32b0ddc0a4a5	17089d38-861c-4491-bb37-be0f8330ae87	Following every command	f	\N	2026-05-13 08:43:31.547246+00
c827a9b2-b84c-465b-9cdc-a58f7aa4e2dd	17089d38-861c-4491-bb37-be0f8330ae87	Guarding the integrity of the partnership even under system pressure	t	\N	2026-05-13 08:43:31.547246+00
532d604e-b922-4524-9b35-a8608a37c61b	17089d38-861c-4491-bb37-be0f8330ae87	Finishing paperwork on time	f	\N	2026-05-13 08:43:31.547246+00
c51ea063-4ab4-4512-a5f6-c59fd9c88565	17089d38-861c-4491-bb37-be0f8330ae87	Keeping secrets from everyone	f	\N	2026-05-13 08:43:31.547246+00
708a5ca4-53e8-48a4-8eef-35d6b4677cf2	e76731c8-ced8-4b69-955d-47d759a70bae	Certainty	f	\N	2026-05-12 16:31:26.338488+00
a6599a67-2f99-48fa-aee1-ca2efff4dcea	e76731c8-ced8-4b69-955d-47d759a70bae	Status	t	\N	2026-05-12 16:31:26.338488+00
e3931bb3-3af2-4cfe-892f-424d03a7cd77	e76731c8-ced8-4b69-955d-47d759a70bae	Autonomy	f	\N	2026-05-12 16:31:26.338488+00
bd3e6940-7859-436d-a1cc-b230fefcc3fb	e76731c8-ced8-4b69-955d-47d759a70bae	Relatedness	f	\N	2026-05-12 16:31:26.338488+00
82967384-f39e-44b6-953b-e8b628314394	059df540-aa88-4077-8ec8-d4dcf0e66a5c	Failed to provide enough expert advice.	f	\N	2026-05-12 16:31:26.338488+00
b27a2276-8045-4e00-8773-9eab8a957bba	059df540-aa88-4077-8ec8-d4dcf0e66a5c	Triggered a Status Threat by using evaluative language rather than low-inference data.	t	\N	2026-05-12 16:31:26.338488+00
05b6b141-0bc7-4ea5-bd5e-02e0c7a7bfe3	059df540-aa88-4077-8ec8-d4dcf0e66a5c	Spent too much time listening.	f	\N	2026-05-12 16:31:26.338488+00
4b0c8ce8-8adb-43e0-973f-4f96e9a0ce07	059df540-aa88-4077-8ec8-d4dcf0e66a5c	Not followed the NEO-1 checklist strictly enough.	f	\N	2026-05-12 16:31:26.338488+00
435902ec-6e08-4801-9500-ffe024c679a6	407ed0cc-1f88-466f-950b-9b453b6dc437	Share the scores but ask the Principal to keep them confidential.	f	\N	2026-05-12 16:31:26.338488+00
032736db-e125-45d7-bd77-84fe57b0d1ef	407ed0cc-1f88-466f-950b-9b453b6dc437	Provide a list of only the "top-performing" teachers.	f	\N	2026-05-12 16:31:26.338488+00
d161aab7-32d1-4dbd-a62e-2c00b7087470	407ed0cc-1f88-466f-950b-9b453b6dc437	Refuse and offer a "System-Trends" report to protect individual trust.	t	\N	2026-05-12 16:31:26.338488+00
38f6693a-ebf8-451a-97d7-0777697a9b1a	7728594c-6104-4b1f-8645-59e643e638a6	Status is increased	f	\N	2026-05-13 08:19:55.118696+00
82f87f99-91bc-4452-bf80-1069d2c60cfd	7728594c-6104-4b1f-8645-59e643e638a6	Status is denied, triggering defensiveness	t	\N	2026-05-13 08:19:55.118696+00
e97b2211-98cf-4110-9778-c557ddfb22be	7728594c-6104-4b1f-8645-59e643e638a6	Status remains neutral	f	\N	2026-05-13 08:19:55.118696+00
fedccbee-6fb9-427c-9b1f-e402f0d1c879	7728594c-6104-4b1f-8645-59e643e638a6	Status is irrelevant to coaching	f	\N	2026-05-13 08:19:55.118696+00
f9401330-46c1-4f64-993c-c5db95fd442c	09c6262d-66b6-429c-b63b-fb2a82e6ee07	Provide the specific name and data	f	\N	2026-05-13 08:19:56.468641+00
178cebd7-1576-4dc9-b869-adf72ba4c63e	09c6262d-66b6-429c-b63b-fb2a82e6ee07	Redirect the Principal to school-wide patterns without naming individuals	t	\N	2026-05-13 08:19:56.468641+00
b0672e06-037f-42b3-b474-bdd5c3c45040	09c6262d-66b6-429c-b63b-fb2a82e6ee07	Ignore the Principal's request	f	\N	2026-05-13 08:19:56.468641+00
a258ec6a-ada1-4e2d-92cd-4867e76fd714	09c6262d-66b6-429c-b63b-fb2a82e6ee07	Ask the teacher to give the data themselves	f	\N	2026-05-13 08:19:56.468641+00
59190f94-9608-4a32-9bcf-33dc1517b6d6	59b3383f-e475-49fc-8044-2553942d3b01	An ancient historical object	f	\N	2026-05-13 08:19:59.241091+00
aad5fabb-9101-4f4e-bca7-1d90baabc973	59b3383f-e475-49fc-8044-2553942d3b01	A physical or digital 'slice' of classroom reality (photo, work sample)	t	\N	2026-05-13 08:19:59.241091+00
f4876605-82de-4e44-adb4-bb69b108f4a4	59b3383f-e475-49fc-8044-2553942d3b01	A certificate given to the teacher	f	\N	2026-05-13 08:19:59.241091+00
15435b34-01a8-46bb-9098-58b1814ff3a8	59b3383f-e475-49fc-8044-2553942d3b01	The coach's personal diary	f	\N	2026-05-13 08:19:59.241091+00
90ea0cb9-cbd0-40f6-a778-4bf5823549b8	9abbdf38-582d-4028-901f-30c83b2685a0	The teacher standing at the front	f	\N	2026-05-13 08:20:00.794821+00
e1168f51-661b-4423-a18c-635eddb32a57	9abbdf38-582d-4028-901f-30c83b2685a0	The students in the 'shadows' (back rows, quiet students)	t	\N	2026-05-13 08:20:00.794821+00
a436d9b4-4a17-4edf-aee9-d5853a4e0f8d	9abbdf38-582d-4028-901f-30c83b2685a0	The decorations on the classroom walls	f	\N	2026-05-13 08:20:00.794821+00
12e18229-7ab8-4d4f-b82d-85beddc013ed	9abbdf38-582d-4028-901f-30c83b2685a0	The school's front gate	f	\N	2026-05-13 08:20:00.794821+00
a65f3d8d-43c5-4864-bab1-e1ef599c551a	4f61d12e-1293-44ac-be75-12f38cee2ebd	The coach explains the data	f	\N	2026-05-13 08:20:05.02361+00
af08ac33-1c97-4c90-bf7c-bc591c0b606d	4f61d12e-1293-44ac-be75-12f38cee2ebd	The teacher interprets the artifact/data first	t	\N	2026-05-13 08:20:05.02361+00
d6fb5cf6-64ab-4551-8a6e-1d47e1a9be77	4f61d12e-1293-44ac-be75-12f38cee2ebd	The coach sets the next goal	f	\N	2026-05-13 08:20:05.02361+00
0768a9ce-5be5-4721-8889-3629f2634179	4f61d12e-1293-44ac-be75-12f38cee2ebd	The teacher signs the report	f	\N	2026-05-13 08:20:05.02361+00
64939185-8ad3-47af-92e6-6cde6ca085bd	621e25f9-05bf-4d4d-a4c8-b6c224274435	Wait for the bell to ring	f	\N	2026-05-13 08:20:06.380552+00
b4f5b727-cef3-4c9f-91eb-bfb20c0710e3	621e25f9-05bf-4d4d-a4c8-b6c224274435	Allow the teacher space to think and reflect before the coach speaks	t	\N	2026-05-13 08:20:06.380552+00
70ca575a-005b-4e8b-bf03-b3614df469e2	621e25f9-05bf-4d4d-a4c8-b6c224274435	Check the coach's phone for messages	f	\N	2026-05-13 08:20:06.380552+00
0a516106-b804-453a-b0ae-9e02baf5a0e3	621e25f9-05bf-4d4d-a4c8-b6c224274435	Make the teacher feel uncomfortable	f	\N	2026-05-13 08:20:06.380552+00
06f08af1-f2ae-47ae-85c5-f1a9e14fe907	fa78e4e4-ea60-42c0-af8f-72ee2f4fde5d	Data Entry Clerk	f	\N	2026-05-13 08:42:00.032638+00
a56360a9-29c3-4d51-8ef8-fe46566f89d5	fa78e4e4-ea60-42c0-af8f-72ee2f4fde5d	Biographer of Growth	t	\N	2026-05-13 08:42:00.032638+00
a4a0ea2c-faf9-406c-affd-57c52ff2c78c	fa78e4e4-ea60-42c0-af8f-72ee2f4fde5d	Digital Assistant	f	\N	2026-05-13 08:42:00.032638+00
1bd1a484-98b1-4da3-bb56-30ced6c02b4d	fa78e4e4-ea60-42c0-af8f-72ee2f4fde5d	Technical Inspector	f	\N	2026-05-13 08:42:00.032638+00
02ef7e18-9bd4-4333-a824-1de5975a9510	a556bf4d-5df5-4678-8bca-fa612365ef3d	'The teacher struggled with the math problem'	f	\N	2026-05-13 08:42:00.972048+00
1f97fdf4-404a-4e2a-9b54-b8bb327de12b	a556bf4d-5df5-4678-8bca-fa612365ef3d	'Notice the shift in student engagement when you moved to the back row'	t	\N	2026-05-13 08:42:00.972048+00
5789cc02-3c83-4d26-8a2c-5a8e8f0ec64e	a556bf4d-5df5-4678-8bca-fa612365ef3d	'The lesson was 10 minutes too long'	f	\N	2026-05-13 08:42:00.972048+00
c0812b52-106f-4a7b-92e3-3bba26f8d9ad	a556bf4d-5df5-4678-8bca-fa612365ef3d	'The whiteboard was not erased properly'	f	\N	2026-05-13 08:42:00.972048+00
3c2bc4c5-77e2-4bb4-9343-48d1d4c77675	8c3defc0-6b2b-402e-871c-30f79f4d78d4	By using passwords that only the principal knows	f	\N	2026-05-13 08:42:02.019447+00
cb01f81c-43e6-4191-bfa2-8a962d9f5651	8c3defc0-6b2b-402e-871c-30f79f4d78d4	By framing the folder as a 'Developmental Tool' for the teacher, not the school	t	\N	2026-05-13 08:42:02.019447+00
adc6cef1-d3bc-4b0b-b053-cc0d9113835d	8c3defc0-6b2b-402e-871c-30f79f4d78d4	By deleting photos after 24 hours	f	\N	2026-05-13 08:42:02.019447+00
3c55e2a0-30f6-4ec4-a7dc-49e098578f04	8c3defc0-6b2b-402e-871c-30f79f4d78d4	By only using student names, not teacher names	f	\N	2026-05-13 08:42:02.019447+00
0228cb85-5d0f-4b98-ba2f-9b23aebe6216	3c1c66ce-bd3f-44f7-98fc-7fd6fcff457f	The teacher is a high-performer	f	\N	2026-05-13 08:42:05.892614+00
010c51c8-d6b3-4d72-8a92-78923e99d79d	3c1c66ce-bd3f-44f7-98fc-7fd6fcff457f	A teacher is overwhelmed or facing a safety/crisis issue	t	\N	2026-05-13 08:42:05.892614+00
4e898491-42b0-4f8f-846f-d1e646bdaf83	3c1c66ce-bd3f-44f7-98fc-7fd6fcff457f	The coach wants to show off their knowledge	f	\N	2026-05-13 08:42:05.892614+00
e48d4d8d-99ef-4b7d-bfac-b5a6a996fef4	3c1c66ce-bd3f-44f7-98fc-7fd6fcff457f	The teacher asks for no help	f	\N	2026-05-13 08:42:05.892614+00
599c8563-f862-41b9-9543-76a26c194c24	c73ad48b-1251-468c-ba80-a26eebee97bd	Staying in the classroom for 4 hours	f	\N	2026-05-13 08:42:06.938179+00
e30bab60-77a0-4273-8f7d-fd8f6768a796	c73ad48b-1251-468c-ba80-a26eebee97bd	Focusing on deep, systemic changes in teacher practice and student learning	t	\N	2026-05-13 08:42:06.938179+00
bb0e4578-16eb-4523-abcc-013c93ea8748	c73ad48b-1251-468c-ba80-a26eebee97bd	Giving the teacher a lot of homework	f	\N	2026-05-13 08:42:06.938179+00
fcdecfd9-b97e-4526-96c8-61cec69149ac	c73ad48b-1251-468c-ba80-a26eebee97bd	Carrying a heavy laptop to the school	f	\N	2026-05-13 08:42:06.938179+00
e7e64bc9-2207-4efd-b722-f082dc8c16af	604c7fc5-caa6-437c-a647-3c3cd8fe61c1	Both people talk for exactly 30 minutes	f	\N	2026-05-13 08:42:07.830788+00
afcf5826-c6af-46d1-bf7e-efdef8c7c80f	604c7fc5-caa6-437c-a647-3c3cd8fe61c1	The coach is willing to be influenced by the teacher's classroom reality	t	\N	2026-05-13 08:42:07.830788+00
12576e9d-33c9-4511-b9af-379d1c373be4	604c7fc5-caa6-437c-a647-3c3cd8fe61c1	The teacher pays for the coach's tea	f	\N	2026-05-13 08:42:07.830788+00
932ae5d2-4518-4edc-aece-f05e2461682f	407ed0cc-1f88-466f-950b-9b453b6dc437	Tell the Principal you will ask the teachers for permission first.	f	\N	2026-05-12 16:31:26.338488+00
4b8b014a-5288-4f0f-a1dc-b1ece00c7c3f	3740a241-91c0-4eb9-ade1-83a8b4c67e0e	I'm here to help you improve your classroom management with some tips.	f	\N	2026-05-12 16:31:26.338488+00
c1026cfd-7cc9-4635-87a9-a389f7b7723d	3740a241-91c0-4eb9-ade1-83a8b4c67e0e	I'm here as a partner to learn alongside you; what is a specific goal you have for your students today that we can look at together?	t	\N	2026-05-12 16:31:26.338488+00
d9596a7c-fef7-4ab3-ae94-11bb73f73e47	3740a241-91c0-4eb9-ade1-83a8b4c67e0e	The District Office requires me to audit this lesson for performance tracking.	f	\N	2026-05-12 16:31:26.338488+00
d1bf79cb-1d73-4cae-8f21-fb11dae6f6d8	3740a241-91c0-4eb9-ade1-83a8b4c67e0e	I will be watching to see if you are following the standard manual correctly.	f	\N	2026-05-12 16:31:26.338488+00
ed246f1a-c2c4-42d2-bda9-b3faf96044fe	a0bfcfcb-6c6b-4ebc-b214-a4f4c4bc1d1b	Re-read the rubric to show them exactly where they failed.	f	\N	2026-05-12 16:31:26.338488+00
88049083-50d1-45ea-a84b-3b5b91c837a3	a0bfcfcb-6c6b-4ebc-b214-a4f4c4bc1d1b	Physically sit next to them and look at student work together, asking "What do you see here?"	t	\N	2026-05-12 16:31:26.338488+00
ebb377cd-b4b2-4c9c-b525-7b45bf1a9646	a0bfcfcb-6c6b-4ebc-b214-a4f4c4bc1d1b	Remind them that your role is to give expert advice they must follow.	f	\N	2026-05-12 16:31:26.338488+00
dc4f5d64-be41-43ca-8014-a7f8d944f443	a0bfcfcb-6c6b-4ebc-b214-a4f4c4bc1d1b	Suggest they observe a younger teacher who is more compliant.	f	\N	2026-05-12 16:31:26.338488+00
bc6e849c-31cb-4ab9-aa52-010d5f7f144a	055b957a-cd91-44e4-bc2a-bcb80414788c	You should use a whistle to get their attention.	f	\N	2026-05-12 16:31:26.338488+00
2b141d5a-0cef-430b-8043-ad56d720230f	055b957a-cd91-44e4-bc2a-bcb80414788c	It sounds frustrating when you've planned a lesson and the back row isn't engaging. What have you noticed about when they do pay attention?	t	\N	2026-05-12 16:31:26.338488+00
9ae0a3d9-69fa-4935-8007-973edaf3bd58	055b957a-cd91-44e4-bc2a-bcb80414788c	In my day, I handled 80 students by doing X.	f	\N	2026-05-12 16:31:26.338488+00
30a58524-ae9d-41f6-9b2f-13ff9002d6d1	055b957a-cd91-44e4-bc2a-bcb80414788c	I will mark this as a practice visit so it doesn't hurt your record.	f	\N	2026-05-12 16:31:26.338488+00
3cda6532-d0c8-45b3-9818-c1192f3b3eb4	0b6d7d3e-a411-43d3-a19d-8767d5404746	To catch the teacher ignoring students.	f	\N	2026-05-12 16:31:26.338488+00
53f98a07-2360-4514-8d00-9448866e44a5	0b6d7d3e-a411-43d3-a19d-8767d5404746	To find the truth of student learning that is often hidden by teacher activity at the "Center."	t	\N	2026-05-12 16:31:26.338488+00
c5e6990c-dfb0-4b4c-9594-c7469bd21bb2	0b6d7d3e-a411-43d3-a19d-8767d5404746	To provide evidence for a "Show Cause" notice.	f	\N	2026-05-12 16:31:26.338488+00
11eaecf4-0e36-4438-99ba-5af3653f9952	0b6d7d3e-a411-43d3-a19d-8767d5404746	To satisfy digital app requirements.	f	\N	2026-05-12 16:31:26.338488+00
a5724292-71ea-4c80-affb-c63b6e151032	e2903376-d87a-4ed5-a596-3f8ac454f595	One person being a "mean" grader.	f	\N	2026-05-12 16:31:26.338488+00
c9b8e6b7-96c1-49e9-aef1-ad6643ebc656	e2903376-d87a-4ed5-a596-3f8ac454f595	Using subjective "feelings" instead of a shared mirror of objective facts.	t	\N	2026-05-12 16:31:26.338488+00
49dab68f-8d68-4e57-85c3-175d14d59002	e2903376-d87a-4ed5-a596-3f8ac454f595	The rubric being too complex to understand.	f	\N	2026-05-12 16:31:26.338488+00
a00de7ab-3ad3-437e-90cc-8b8d8e6435ee	e2903376-d87a-4ed5-a596-3f8ac454f595	The teacher acting differently toward each of you.	f	\N	2026-05-12 16:31:26.338488+00
34945efc-00c9-4a8f-beab-c4d56ac68b9f	7a7aff9d-cea2-45e4-ad09-2a4d1259f4b4	The lighting in the room is poor.	f	\N	2026-05-12 16:31:26.338488+00
2cf63ea8-dcc3-4466-a078-1864803e1147	7a7aff9d-cea2-45e4-ad09-2a4d1259f4b4	A student is visibly distressed or the teacher is in an acute emotional crisis.	t	\N	2026-05-12 16:31:26.338488+00
c52b83c3-6886-41e2-b4b8-64557f7a706e	7a7aff9d-cea2-45e4-ad09-2a4d1259f4b4	The coach forgot their tablet.	f	\N	2026-05-12 16:31:26.338488+00
86638104-daee-4f51-affd-5ef5044935f4	7a7aff9d-cea2-45e4-ad09-2a4d1259f4b4	The teacher is using a non-standard strategy.	f	\N	2026-05-12 16:31:26.338488+00
b70dd58c-54d5-4453-a37e-458bd5599255	fac03f31-13f3-4397-9ea9-a6c7428a92d8	The teacher was too lazy to check homework.	f	\N	2026-05-12 16:31:26.338488+00
18e00faf-8c0d-4f5d-b641-26a404b822d5	fac03f31-13f3-4397-9ea9-a6c7428a92d8	At 11:15 AM, 12 of 68 students were writing in notebooks; 56 students sat with blank pages.	t	\N	2026-05-12 16:31:26.338488+00
2d445654-cc39-40ef-afa7-dbed567b1917	fac03f31-13f3-4397-9ea9-a6c7428a92d8	The teacher gave a very clear explanation of the topic.	f	\N	2026-05-12 16:31:26.338488+00
8919793a-a77b-4ddb-8bcb-7e1fef9dbcc3	fac03f31-13f3-4397-9ea9-a6c7428a92d8	The classroom was noisy because the teacher lost control.	f	\N	2026-05-12 16:31:26.338488+00
f19815a5-7e94-4bca-8411-32d6a1d92ec5	31fc6e91-b393-4610-b738-04edead3fa34	Argue until they admit they were wrong.	f	\N	2026-05-12 16:31:26.338488+00
0e01b98f-5f2c-4b5e-9726-8fc06a2d3649	31fc6e91-b393-4610-b738-04edead3fa34	Introduce the "Third Partner" by looking at 5 randomly selected student notebooks together.	t	\N	2026-05-12 16:31:26.338488+00
93ad54c8-c567-4acb-82b6-7b21baf1e542	604c7fc5-caa6-437c-a647-3c3cd8fe61c1	The coach teaches the lesson for the teacher	f	\N	2026-05-13 08:42:07.830788+00
30d146ad-aca8-4836-bb53-729d903bb6d2	14d2e925-8b54-4552-aec1-282236fa014e	The teacher is doing a great job	f	\N	2026-05-13 08:42:11.128239+00
cc5d0c57-961e-46cb-87ea-8f09cb31fbe9	14d2e925-8b54-4552-aec1-282236fa014e	Systemic pressures (like audit culture) threaten coaching integrity	t	\N	2026-05-13 08:42:11.128239+00
536e1e25-dbbf-41ba-b1f1-6b38acd3c2e9	14d2e925-8b54-4552-aec1-282236fa014e	The coach wants a promotion	f	\N	2026-05-13 08:42:11.128239+00
5a512572-b5ad-4bf3-86cd-c5eafbd01639	14d2e925-8b54-4552-aec1-282236fa014e	The school holds a sports day	f	\N	2026-05-13 08:42:11.128239+00
1679dac6-19ae-4fa8-8fe8-4b615e5142e7	78aae87f-e8b2-4c94-904a-8744ca3f0145	Provides the list to keep the principal happy	f	\N	2026-05-13 08:42:12.022296+00
bc075a28-7139-40c7-9495-a1ddc0eb2a5d	78aae87f-e8b2-4c94-904a-8744ca3f0145	Offers a 'School Growth Map' showing anonymous trends instead	t	\N	2026-05-13 08:42:12.022296+00
c250b30b-c989-4e25-b7d5-6d04980be3b3	78aae87f-e8b2-4c94-904a-8744ca3f0145	Quits the job	f	\N	2026-05-13 08:42:12.022296+00
31dda836-cded-4e72-a2ed-70e4f8ecdd05	78aae87f-e8b2-4c94-904a-8744ca3f0145	Tells the teachers to hide from the principal	f	\N	2026-05-13 08:42:12.022296+00
ac52867a-8bf8-45d8-81d0-3fa728ea772d	ae429474-d231-4685-9d4a-93404adb4188	For the principal's eyes only	f	\N	2026-05-13 08:42:13.046485+00
21784872-316b-411a-9dd8-34935ff6a72f	ae429474-d231-4685-9d4a-93404adb4188	A private developmental space for the teacher and coach	t	\N	2026-05-13 08:42:13.046485+00
fd1fc390-f685-4418-96e1-0a26964fa7e8	31fc6e91-b393-4610-b738-04edead3fa34	Agree with them to maintain the relationship and try again next week.	f	\N	2026-05-12 16:31:26.338488+00
21859898-eadf-4d91-b595-f484eec6ccf7	31fc6e91-b393-4610-b738-04edead3fa34	Inform the Principal the teacher is in denial.	f	\N	2026-05-12 16:31:26.338488+00
42f9d57a-d282-4747-ac5c-a815024a468a	e8d58213-df35-4b98-929a-9ff4dcc7ab36	Take it silently to avoid distracting the class.	f	\N	2026-05-12 16:31:26.338488+00
67c13627-c5eb-4f4f-b0bd-83969b30f78e	e8d58213-df35-4b98-929a-9ff4dcc7ab36	Use a permission script that names a specific learning curiosity (e.g., "I'm curious how they solved this").	t	\N	2026-05-12 16:31:26.338488+00
22a78ba9-2ae4-4302-8258-c55acae0c474	e8d58213-df35-4b98-929a-9ff4dcc7ab36	Only take photos of top-performing students.	f	\N	2026-05-12 16:31:26.338488+00
0cc0dfa9-0e46-480b-b88b-d7fec35ec3f7	e8d58213-df35-4b98-929a-9ff4dcc7ab36	Send the photo to the Principal immediately for validation.	f	\N	2026-05-12 16:31:26.338488+00
12f4d62b-4406-4a67-b991-4e02b53dd5e3	a08d7ee5-efe9-4ae0-96e5-7bf7ca23d165	66%	f	\N	2026-05-12 16:31:26.338488+00
b3cc0165-77ca-4a62-97f1-5e119f35a79f	a08d7ee5-efe9-4ae0-96e5-7bf7ca23d165	50% (Missing artifact and interruption count as 0% for those visits).	t	\N	2026-05-12 16:31:26.338488+00
cb4792f9-b4cf-4e0d-84cb-94c21d9e82b2	a08d7ee5-efe9-4ae0-96e5-7bf7ca23d165	75%	f	\N	2026-05-12 16:31:26.338488+00
e0ca797e-db63-4833-a13f-25a65758662b	a08d7ee5-efe9-4ae0-96e5-7bf7ca23d165	40%	f	\N	2026-05-12 16:31:26.338488+00
b52e7c67-e3df-44ce-b294-0ece0ccd6855	af56078b-c26c-4e2f-a2b8-c1dab48fbd7b	Teachers are following steps (Compliance) but without deep pedagogical dialogue (Praxis).	t	\N	2026-05-12 16:31:26.338488+00
3ed73025-4fb3-4237-86da-52a67555baa2	af56078b-c26c-4e2f-a2b8-c1dab48fbd7b	The app is not being used enough.	f	\N	2026-05-12 16:31:26.338488+00
27628f32-e881-45f2-a15a-640de2753a9c	af56078b-c26c-4e2f-a2b8-c1dab48fbd7b	Students are not participating.	f	\N	2026-05-12 16:31:26.338488+00
b2a8e442-b262-49d9-80f5-d421c5b69b88	af56078b-c26c-4e2f-a2b8-c1dab48fbd7b	The coach is not visiting enough.	f	\N	2026-05-12 16:31:26.338488+00
9c6cb5b0-93b1-421b-8fe4-3f55e860979c	f16ded0a-aa1e-4903-a7df-26362bf8be0f	Take paper notes and enter them at home.	f	\N	2026-05-12 16:31:26.338488+00
48c9c5a6-17d2-4798-9dd2-96054d0c90ab	f16ded0a-aa1e-4903-a7df-26362bf8be0f	Complete 100% of app entries (Evidence and Action Steps) inside the school building.	t	\N	2026-05-12 16:31:26.338488+00
a7282e79-7465-49bd-bb96-1ffceb28213c	f16ded0a-aa1e-4903-a7df-26362bf8be0f	Ask the teacher to enter data.	f	\N	2026-05-12 16:31:26.338488+00
cf2de97b-2740-4059-91bb-5070730747f4	f16ded0a-aa1e-4903-a7df-26362bf8be0f	Only record successful visits.	f	\N	2026-05-12 16:31:26.338488+00
56a174f3-1580-41f5-ba0f-283bbcf3e8f6	6f843250-9e8b-4119-b612-30ecf09c8e0c	I'm sorry, but I have too much work to do today.	f	\N	2026-05-12 16:31:26.338488+00
2a9d3586-4538-410e-b2fc-b3b963fe995d	6f843250-9e8b-4119-b612-30ecf09c8e0c	My WRER is currently at 50%; if I miss this block, Teacher Sara will wait another 7 days for feedback, risking student engagement.	t	\N	2026-05-12 16:31:26.338488+00
efff92fd-68fb-49ca-81cb-61fedfaee039	6f843250-9e8b-4119-b612-30ecf09c8e0c	I will do the duty if you promise to give me extra time tomorrow.	f	\N	2026-05-12 16:31:26.338488+00
e7d00ba2-4719-418e-8682-ade4df5a1c4c	6f843250-9e8b-4119-b612-30ecf09c8e0c	The District Office says I am not allowed to do protocol duty.	f	\N	2026-05-12 16:31:26.338488+00
f9882e34-615f-4b15-8870-b189c79c48e1	38e12e9c-7b25-4d92-9bda-091c62145171	Tell the teacher to follow the AI suggestion anyway.	f	\N	2026-05-12 16:31:26.338488+00
c5e5dd67-14d4-42ff-997a-ae85ee895a09	38e12e9c-7b25-4d92-9bda-091c62145171	Co-design a low-tech alternative (e.g., "Turn-and-Talk") that achieves the same intent.	t	\N	2026-05-12 16:31:26.338488+00
8af5065a-4702-4912-b791-0146c29829c7	38e12e9c-7b25-4d92-9bda-091c62145171	Mark the visit as "Not Applicable."	f	\N	2026-05-12 16:31:26.338488+00
4cdb383b-8d09-4be8-8813-f1003fdc1b22	38e12e9c-7b25-4d92-9bda-091c62145171	Report the lack of resources and skip the coaching step.	f	\N	2026-05-12 16:31:26.338488+00
bd91dbf9-0d63-4bd4-8d1e-6f5379b2193e	e6dfbfe3-d3bc-49af-886e-85720f261b83	Ignore the observation and celebrate the 100% score.	f	\N	2026-05-12 16:31:26.338488+00
ebfb25b3-cb2e-4d03-b11b-3b22a4b12a38	e6dfbfe3-d3bc-49af-886e-85720f261b83	Use the "Shared Mirror" to ask: "Data shows 100% completion, but looking at these notebooks, what do we notice about actual reasoning?"	t	\N	2026-05-12 16:31:26.338488+00
35567f5c-25e6-4d26-a7cd-a3bc96435dd3	e6dfbfe3-d3bc-49af-886e-85720f261b83	Change the dashboard score manually to 0%.	f	\N	2026-05-12 16:31:26.338488+00
2484f26b-15cb-4d54-badd-0d8a16e63488	e6dfbfe3-d3bc-49af-886e-85720f261b83	Report the teacher for "Robotic Teaching."	f	\N	2026-05-12 16:31:26.338488+00
244cee86-5b01-474a-b0d6-aab7d41292cf	99bc3665-7875-49db-a25c-c899c23faeac	Planning Loop failure	f	\N	2026-05-12 16:31:26.338488+00
5f7e7493-879e-4ac1-aebe-d053ecddc3bc	99bc3665-7875-49db-a25c-c899c23faeac	Observation Loop failure	f	\N	2026-05-12 16:31:26.338488+00
37edcba9-7ba6-4a0e-abdb-fbad7d13875c	99bc3665-7875-49db-a25c-c899c23faeac	Training Loop failure (Needs rehearsal to build muscle memory).	t	\N	2026-05-12 16:31:26.338488+00
5715cf90-92b9-4ddc-84c9-16ba8a6bce53	99bc3665-7875-49db-a25c-c899c23faeac	Mindset failure	f	\N	2026-05-12 16:31:26.338488+00
f2e8ed93-b9a7-49be-a700-b941f5f3bad3	84e0b55e-e7dc-44b8-8f22-d54cf7ac18f1	Show the teacher they are the expert.	f	\N	2026-05-12 16:31:26.338488+00
4cd14568-014d-44ad-aa0d-8412c5721712	84e0b55e-e7dc-44b8-8f22-d54cf7ac18f1	Act as a "Co-Pilot" by "sliding in" for 2 minutes to model a specific micro-skill.	t	\N	2026-05-12 16:31:26.338488+00
3015ceb1-4d8a-468e-a06a-9e494908a2c0	84e0b55e-e7dc-44b8-8f22-d54cf7ac18f1	Finish the lesson for the teacher.	f	\N	2026-05-12 16:31:26.338488+00
37dbec0d-a6d5-4169-9a54-2d5d022a39c4	84e0b55e-e7dc-44b8-8f22-d54cf7ac18f1	Evaluate students.	f	\N	2026-05-12 16:31:26.338488+00
623d97b7-8e4a-4bd6-8cae-fe830150f24c	cbe8c824-cc98-487a-824b-aa2cd2770cfd	Modify the strategy	f	\N	2026-05-12 16:31:26.338488+00
717fb542-5561-42fd-92f1-91afd6487885	cbe8c824-cc98-487a-824b-aa2cd2770cfd	Switch to a new strategy	f	\N	2026-05-12 16:31:26.338488+00
c78f800d-55f2-4016-802b-4dd989a62a16	cbe8c824-cc98-487a-824b-aa2cd2770cfd	Stay the course	f	\N	2026-05-12 16:31:26.338488+00
e75a0c74-c5c7-4d5a-8046-6493b171bfac	cbe8c824-cc98-487a-824b-aa2cd2770cfd	Report failure to administration	t	\N	2026-05-12 16:31:26.338488+00
438e306b-8bf2-45dc-88bf-3feeab12d78f	6dc6c4d4-0d24-4682-99a0-0d519e505369	The teacher doesn't know the subject matter.	f	\N	2026-05-12 16:31:26.338488+00
621a7cfa-b025-425f-9d27-a468e3dccc32	6dc6c4d4-0d24-4682-99a0-0d519e505369	The "Silence Myth": The teacher believes a quiet class copying text is a learning class.	t	\N	2026-05-12 16:31:26.338488+00
34e82182-74d3-4da8-8aef-766e3e2efff4	6dc6c4d4-0d24-4682-99a0-0d519e505369	The teacher is lazy and doesn't want to teach.	f	\N	2026-05-12 16:31:26.338488+00
6d4c5498-6bf3-4ced-bcc9-c22629b0ad92	6dc6c4d4-0d24-4682-99a0-0d519e505369	The students are too slow to do any other activity.	f	\N	2026-05-12 16:31:26.338488+00
4a530cd7-b8f4-44fe-af84-1c590b4722d8	3350a30c-9ce7-4d5b-86c1-83fa3729cb86	Tell them to be faster next time.	f	\N	2026-05-12 16:31:26.338488+00
c35d5326-ec2c-4c8d-a51c-631fa8b1aafe	3350a30c-9ce7-4d5b-86c1-83fa3729cb86	Co-design a script with specific time-stamps for each lesson segment.	t	\N	2026-05-12 16:31:26.338488+00
742bb00d-1a60-4e82-af33-638c27b89d20	3350a30c-9ce7-4d5b-86c1-83fa3729cb86	Model the entire lesson for them.	f	\N	2026-05-12 16:31:26.338488+00
59af91ae-f1a0-44cb-a10b-81ee50ca489b	3350a30c-9ce7-4d5b-86c1-83fa3729cb86	Mark them as "Not Proficient" in time management.	f	\N	2026-05-12 16:31:26.338488+00
3d3de66c-ec56-45cd-ac84-c4b967aad8f9	7609907b-2591-4c7f-abd7-0a665bac79c3	The easiest gap to fix.	f	\N	2026-05-12 16:31:26.338488+00
c2c21188-730d-4eb1-9ced-55688e865b4f	7609907b-2591-4c7f-abd7-0a665bac79c3	The "High-Leverage" change that the teacher agrees will impact students most.	t	\N	2026-05-12 16:31:26.338488+00
1149ec18-fee8-4264-9d81-3565de32905c	7609907b-2591-4c7f-abd7-0a665bac79c3	The gap the Principal is most concerned about.	f	\N	2026-05-12 16:31:26.338488+00
3cb1ba88-8be1-43b8-addb-5f00d6579fa9	7609907b-2591-4c7f-abd7-0a665bac79c3	All 8 gaps simultaneously to ensure rapid growth.	f	\N	2026-05-12 16:31:26.338488+00
1423b210-5503-4277-b386-bb04d144402d	1a765bf0-460f-46ed-96b6-1b0bcfe0999b	The teacher is unwilling to follow the manual.	f	\N	2026-05-12 16:31:26.338488+00
a9afa936-ea62-4acb-994a-06af3073569a	1a765bf0-460f-46ed-96b6-1b0bcfe0999b	A strategy is impossible due to local constraints (60 students, bolted desks).	t	\N	2026-05-12 16:31:26.338488+00
2680effd-0bea-4bc4-bd8b-8869346070e9	1a765bf0-460f-46ed-96b6-1b0bcfe0999b	The coach wants to try a new experiment.	f	\N	2026-05-12 16:31:26.338488+00
89efb9f8-723c-4718-89f8-d9de314a5dd0	1a765bf0-460f-46ed-96b6-1b0bcfe0999b	The Principal demands a change.	f	\N	2026-05-12 16:31:26.338488+00
3eeba13c-1a9a-405c-acda-aa6963764168	e0958b47-91f9-43f4-bca9-315249c4e262	WRER is 0% but growth is high.	f	\N	2026-05-12 16:31:26.338488+00
99890aa6-22d1-4f14-928e-fe7fcb7779ab	e0958b47-91f9-43f4-bca9-315249c4e262	WRER is 100% (visits happening) but Growth Rate is 0% (no behavior change).	t	\N	2026-05-12 16:31:26.338488+00
55258b42-d7d9-4e23-8fc9-45d2b90b7ee2	e0958b47-91f9-43f4-bca9-315249c4e262	Teacher refuses to sign notes.	f	\N	2026-05-12 16:31:26.338488+00
d7d0989b-b88b-48ff-b357-1916bae8af22	e0958b47-91f9-43f4-bca9-315249c4e262	Principal takes over coaching.	f	\N	2026-05-12 16:31:26.338488+00
223d0bc3-31b1-4925-914e-264cebc3b374	ae4c94f6-9d06-4cd8-8eb8-8a7f74158dcf	The report is filed.	f	\N	2026-05-12 16:31:26.338488+00
4823efdb-4f2e-42c9-8477-c5fc3af33d76	ae4c94f6-9d06-4cd8-8eb8-8a7f74158dcf	The coach gives a compliment.	f	\N	2026-05-12 16:31:26.338488+00
1c3dc243-d252-4f5b-ae86-fe245570a905	ae4c94f6-9d06-4cd8-8eb8-8a7f74158dcf	Coach and teacher verify together (Reciprocity) that the new skill is a mastered habit.	t	\N	2026-05-12 16:31:26.338488+00
d8273c02-2734-44f4-a3ba-b5900e5d0eab	ae4c94f6-9d06-4cd8-8eb8-8a7f74158dcf	Training is completed.	f	\N	2026-05-12 16:31:26.338488+00
68831bed-72e9-4625-9b81-657a90470fec	568774c7-188c-4e60-ae49-5cf5a0c89a84	Remind them this is the new "Gold Standard."	f	\N	2026-05-12 16:31:26.338488+00
c1b1aa86-db64-4401-b9eb-1f05573ebd5d	568774c7-188c-4e60-ae49-5cf5a0c89a84	Acknowledge their expertise and ask which part of the strategy will work for their community.	t	\N	2026-05-12 16:31:26.338488+00
225d7024-498c-4d3b-93e1-3cf1c4513e07	568774c7-188c-4e60-ae49-5cf5a0c89a84	Suggest they observe a younger teacher.	f	\N	2026-05-12 16:31:26.338488+00
cca7d733-2696-4a31-b6ea-a099fe733105	568774c7-188c-4e60-ae49-5cf5a0c89a84	Perform modeling without asking permission.	f	\N	2026-05-12 16:31:26.338488+00
e7da2fa4-0d89-4f98-85cb-4f5d09d1a2e5	97699844-ac3c-4944-b6c8-e55578ce1311	Blame previous student behavior.	f	\N	2026-05-12 16:31:26.338488+00
4f8eeff6-185f-424a-bfa7-fb6cbcacfb88	97699844-ac3c-4944-b6c8-e55578ce1311	Use the "Shared Mirror" to admit failure and ask: "What did you notice that I missed?"	t	\N	2026-05-12 16:31:26.338488+00
e1e6aec0-d817-418b-85f7-b563faed36d8	97699844-ac3c-4944-b6c8-e55578ce1311	Pretend it went well to maintain your "Expert" status.	f	\N	2026-05-12 16:31:26.338488+00
c07f4a11-2b77-4f2f-87c7-1ee922b0f02d	97699844-ac3c-4944-b6c8-e55578ce1311	Delete the failure recording from the app.	f	\N	2026-05-12 16:31:26.338488+00
309ebae2-2b65-401f-ae48-3c17698af25b	d6b013cd-7d24-4b41-a7ab-c4a21f5624f4	Theory is too difficult to read.	f	\N	2026-05-12 16:31:26.338488+00
553ee5d0-0c87-487d-9b9a-baa99ff3b168	d6b013cd-7d24-4b41-a7ab-c4a21f5624f4	It allows the "Human Filter" to adapt the intent of a strategy to fit local high-constraint reality.	t	\N	2026-05-12 16:31:26.338488+00
da73c877-79f3-4e33-b135-0408e410d2e8	d6b013cd-7d24-4b41-a7ab-c4a21f5624f4	It is easier for the coach to grade.	f	\N	2026-05-12 16:31:26.338488+00
3ffcf93c-d20a-4182-9c79-4471bec33d31	d6b013cd-7d24-4b41-a7ab-c4a21f5624f4	The manual is only a suggestion and not important.	f	\N	2026-05-12 16:31:26.338488+00
4bd2264b-7931-4f41-a24e-b14de314ec20	98e9e52c-9782-4c79-9a33-35e0d0337558	To correct the teacher's spelling	f	\N	2026-05-13 08:42:00.521053+00
17024326-10b8-4d35-81a4-0b98894a8750	98e9e52c-9782-4c79-9a33-35e0d0337558	To turn raw artifacts into a narrative of professional excellence	t	\N	2026-05-13 08:42:00.521053+00
67d960a3-f104-4992-91aa-c625e6d3956e	98e9e52c-9782-4c79-9a33-35e0d0337558	To provide a secret grade for the principal	f	\N	2026-05-13 08:42:00.521053+00
7a871b13-e941-4ce9-996c-4c8dad2bef9e	98e9e52c-9782-4c79-9a33-35e0d0337558	To describe what the students are wearing	f	\N	2026-05-13 08:42:00.521053+00
19d2b3ca-6d6c-45e4-9570-525b81c5e9d9	db7200e2-31c6-47ad-bd77-0fa1e6624065	Identify only	f	\N	2026-05-13 08:42:01.55752+00
5b9198f4-6873-4131-8b41-33a8c49cd81d	db7200e2-31c6-47ad-bd77-0fa1e6624065	Learn only	f	\N	2026-05-13 08:42:01.55752+00
4fb54e43-5016-4950-ab2b-2be95447f2ac	db7200e2-31c6-47ad-bd77-0fa1e6624065	The full cycle (Identify, Learn, and Improve)	t	\N	2026-05-13 08:42:01.55752+00
efec2f89-d3d4-4a76-94d0-e942096e6045	db7200e2-31c6-47ad-bd77-0fa1e6624065	Evaluation only	f	\N	2026-05-13 08:42:01.55752+00
6ba27b05-3b22-4f55-83cb-1f44dc4fbfb5	814c2e78-f61a-4680-a6a4-58f23e918c13	The very first lesson observed	f	\N	2026-05-13 08:42:02.496454+00
8b141618-392b-472d-a769-11e7088703ca	814c2e78-f61a-4680-a6a4-58f23e918c13	The 'After' photo showing the result of a specific action step	t	\N	2026-05-13 08:42:02.496454+00
1b3e0d91-d8ac-4203-a691-aff87d045bed	814c2e78-f61a-4680-a6a4-58f23e918c13	A video of the coach teaching the class	f	\N	2026-05-13 08:42:02.496454+00
9b3a46b5-4c82-4ffe-b8ac-adf09d1d0be1	814c2e78-f61a-4680-a6a4-58f23e918c13	The teacher's original lesson plan	f	\N	2026-05-13 08:42:02.496454+00
71da6472-5ace-4af2-ad1a-c919cd89139c	ff1eda98-f25d-4d12-aab8-33fa9c6f0552	The weather	f	\N	2026-05-13 08:42:05.444563+00
eda10601-9b53-48c7-95a9-4c667d6097f8	ff1eda98-f25d-4d12-aab8-33fa9c6f0552	The teacher's current needs, experience level, and context	t	\N	2026-05-13 08:42:05.444563+00
eab82ef2-61a5-4586-8ad2-f9076ee7951c	ff1eda98-f25d-4d12-aab8-33fa9c6f0552	The principal's mood	f	\N	2026-05-13 08:42:05.444563+00
a6f71340-7f4d-43aa-9696-782d5bda8f3f	ff1eda98-f25d-4d12-aab8-33fa9c6f0552	The time of day	f	\N	2026-05-13 08:42:05.444563+00
59af2e47-8087-4337-bc9b-9026b07d1b82	2341c475-b850-464b-8d38-78c0d21cfd50	Telling the teacher exactly what to do	f	\N	2026-05-13 08:42:06.362483+00
d34c8d42-035b-496c-a927-076331ba4b01	2341c475-b850-464b-8d38-78c0d21cfd50	Asking powerful questions to ignite the teacher's own reflection	t	\N	2026-05-13 08:42:06.362483+00
6538735b-bafe-4e4c-95a0-e9ab881ca5a9	2341c475-b850-464b-8d38-78c0d21cfd50	Writing the lesson plan for the teacher	f	\N	2026-05-13 08:42:06.362483+00
527d7904-1e48-4e91-9b3d-7b5aa802e878	2341c475-b850-464b-8d38-78c0d21cfd50	Observing from outside the classroom	f	\N	2026-05-13 08:42:06.362483+00
25bcc656-c961-4af3-aec0-a3d970031d7e	b16b099e-cbd6-4d18-8452-a8c0e1434ea5	Report them to the principal	f	\N	2026-05-13 08:42:07.381837+00
a650a044-ef7f-44fc-af5c-ebd5dd1d1eb6	b16b099e-cbd6-4d18-8452-a8c0e1434ea5	Empathize and offer 'Quick Win' choices to build trust	t	\N	2026-05-13 08:42:07.381837+00
582e8d67-57b2-4851-a16c-369ec3a13557	b16b099e-cbd6-4d18-8452-a8c0e1434ea5	Stop coaching them	f	\N	2026-05-13 08:42:07.381837+00
25eb8de5-2d69-4350-a78d-3d75026b97ee	b16b099e-cbd6-4d18-8452-a8c0e1434ea5	Force them to follow the rubric	f	\N	2026-05-13 08:42:07.381837+00
3fb29a46-e216-4a8b-9ef7-77a1e75ed62d	778a0c05-48b3-493c-ad10-4a3374b8c930	Complain about the school's facilities	f	\N	2026-05-13 08:42:11.580723+00
69365e49-acd9-414d-9511-bb5b1c372d8b	778a0c05-48b3-493c-ad10-4a3374b8c930	Protect coaching time and confidentiality when talking to administrators	t	\N	2026-05-13 08:42:11.580723+00
db6146b7-c324-4595-a452-0ecfdebf665c	778a0c05-48b3-493c-ad10-4a3374b8c930	Request more students for the classroom	f	\N	2026-05-13 08:42:11.580723+00
e645e2ef-e8d0-499d-8031-1c0350da5207	778a0c05-48b3-493c-ad10-4a3374b8c930	Ask the teacher for a favor	f	\N	2026-05-13 08:42:11.580723+00
4e1ac57d-43aa-40f0-8bd6-15a18d04fd42	cb20ce19-d1ba-45e4-a87c-d64bf16b43e8	Thinking about the problems but doing nothing	f	\N	2026-05-13 08:42:12.552857+00
b3b80ec5-d5bf-4fb5-b1ea-908edc0101f8	cb20ce19-d1ba-45e4-a87c-d64bf16b43e8	Taking brave, data-informed action to protect the coaching space	t	\N	2026-05-13 08:42:12.552857+00
1024d054-6db1-4a59-8af7-182558248f55	cb20ce19-d1ba-45e4-a87c-d64bf16b43e8	Writing a long email to the district	f	\N	2026-05-13 08:42:12.552857+00
4fad078c-32ec-4f64-99c5-c6f3c410dccf	cb20ce19-d1ba-45e4-a87c-d64bf16b43e8	Practicing a lesson alone	f	\N	2026-05-13 08:42:12.552857+00
236b3b5e-106f-448b-af2d-c39b9e00b659	8ee11721-406b-4d69-b8d7-1a5f879dc91b	The physical classroom door	f	\N	2026-05-13 08:42:13.491287+00
4d83a25b-a624-4985-b219-2bea28eef06d	8ee11721-406b-4d69-b8d7-1a5f879dc91b	The psychological safety required for a teacher to admit struggles and grow	t	\N	2026-05-13 08:42:13.491287+00
bb77dd90-d212-46a2-96b8-86ad455c5b4c	8ee11721-406b-4d69-b8d7-1a5f879dc91b	The principal's office	f	\N	2026-05-13 08:42:13.491287+00
86fc4bb3-ea66-4200-9515-4638e160c15b	8ee11721-406b-4d69-b8d7-1a5f879dc91b	The school's reputation only	f	\N	2026-05-13 08:42:13.491287+00
be307f31-3f3b-4c67-9c35-40ec442f43d9	d902206a-fedd-4ef3-b137-de90c274aa28	Weekly Rate of Educational Results	f	\N	2026-05-13 08:42:16.352174+00
85017323-8477-4915-84ff-292279c02413	d902206a-fedd-4ef3-b137-de90c274aa28	Weekly Record of Engagement and Results	t	\N	2026-05-13 08:42:16.352174+00
81abafe1-760c-484b-85ae-9bcc1863d3f5	d902206a-fedd-4ef3-b137-de90c274aa28	Whole Room Evidence Review	f	\N	2026-05-13 08:42:16.352174+00
6f1865b2-384e-4a91-8556-82af669bae0e	d902206a-fedd-4ef3-b137-de90c274aa28	Weekly Report to Education Registry	f	\N	2026-05-13 08:42:16.352174+00
c5311e18-def1-4690-a3bc-7819158be4e3	13198a91-a8d8-429e-b1eb-ec38551ce7e0	The coach is lazy	f	\N	2026-05-13 08:42:17.265883+00
5771fc13-f158-4527-aa9b-4bfcda9a51fa	13198a91-a8d8-429e-b1eb-ec38551ce7e0	Systemic displacement (being assigned non-coaching duties)	t	\N	2026-05-13 08:42:17.265883+00
921fc3b8-c039-47c8-96b7-98cbb1b616e1	13198a91-a8d8-429e-b1eb-ec38551ce7e0	The teachers do not like the coach	f	\N	2026-05-13 08:42:17.265883+00
ac77b1b3-c2f2-411b-8ab1-2f6a5e7304e8	13198a91-a8d8-429e-b1eb-ec38551ce7e0	The coaching app is broken	f	\N	2026-05-13 08:42:17.265883+00
feb8d224-03ba-4c2d-afaf-21de647ecc9d	aa402ace-157f-4271-ae4f-e00e6b5787a0	Closing the laptop	f	\N	2026-05-13 08:42:18.153573+00
3595d8da-758f-4667-8b45-70285fbc4d9e	aa402ace-157f-4271-ae4f-e00e6b5787a0	Creating a 'Response Plan' for the following week	t	\N	2026-05-13 08:42:18.153573+00
4e0f201b-dc36-4fd1-9121-748cc52c5501	aa402ace-157f-4271-ae4f-e00e6b5787a0	Reporting the low score to the district	f	\N	2026-05-13 08:42:18.153573+00
7b585752-ffda-4a18-922a-aaf95ad879a6	aa402ace-157f-4271-ae4f-e00e6b5787a0	Deleting the data	f	\N	2026-05-13 08:42:18.153573+00
d59e1dd9-2715-4caa-b393-db2f921ccd0e	e8ab8145-c006-482d-85b8-44f9f9d7244a	The Principal approves every coaching goal	f	\N	2026-05-13 08:42:37.06332+00
3b187c7e-5d47-40f8-8bd3-6ff2c8f9db51	e8ab8145-c006-482d-85b8-44f9f9d7244a	The teacher remains the primary decision-maker during the coaching process	t	\N	2026-05-13 08:42:37.06332+00
a195137e-3935-4df5-824a-af30f20cbc06	e8ab8145-c006-482d-85b8-44f9f9d7244a	The coach decides which strategy is 'best' for the classroom	f	\N	2026-05-13 08:42:37.06332+00
496bce8f-0b42-4225-9786-af08f5e3381d	e8ab8145-c006-482d-85b8-44f9f9d7244a	Students choose their own grades	f	\N	2026-05-13 08:42:37.06332+00
f9e515db-7a41-4197-82bf-2bd761f88b0b	b82f6164-31f1-4cff-af0a-06530aed4446	The coach's salary	f	\N	2026-05-13 08:42:37.983192+00
58f3b961-9845-489d-a7f9-b6d1e66a1f3a	b82f6164-31f1-4cff-af0a-06530aed4446	The PEERS Goal (Powerful, Easy, Emotionally Peaking, Reachable, Student-Focused)	t	\N	2026-05-13 08:42:37.983192+00
cda84269-0c87-4e0a-b700-39c99373578d	b82f6164-31f1-4cff-af0a-06530aed4446	The textbook for the next year	f	\N	2026-05-13 08:42:37.983192+00
bbb6884f-5d6b-45b5-a924-9d191dc2aab6	b82f6164-31f1-4cff-af0a-06530aed4446	The school's lunch menu	f	\N	2026-05-13 08:42:37.983192+00
597868cf-61e3-4f85-9cfa-8a1575a20e7a	9c50c020-0d6f-4793-91ed-84d1f0569225	Compliance	f	\N	2026-05-13 08:42:38.8634+00
bd02953f-62a6-4d5a-a23f-a7b50f3b472e	9c50c020-0d6f-4793-91ed-84d1f0569225	Improved Student Outcomes	t	\N	2026-05-13 08:42:38.8634+00
9c13bce2-2ab3-4ca3-af0c-16722bc1294b	9c50c020-0d6f-4793-91ed-84d1f0569225	Teacher silence	f	\N	2026-05-13 08:42:38.8634+00
6b4fd205-3071-42ff-b0fc-9650c1d77654	9c50c020-0d6f-4793-91ed-84d1f0569225	Following every coach's command	f	\N	2026-05-13 08:42:38.8634+00
af2d23bf-461a-405f-89c8-7187ed30d473	374aa3cf-943e-4a93-8ddf-4642afdebb4e	Directive commands	f	\N	2026-05-13 08:42:42.969595+00
a214981b-9dc5-4096-a80a-ae333bf2a2d2	ae429474-d231-4685-9d4a-93404adb4188	Public property of the school	f	\N	2026-05-13 08:42:13.046485+00
19721592-8c24-40ab-b158-b33e22d56cc0	ae429474-d231-4685-9d4a-93404adb4188	A grading rubric for salary	f	\N	2026-05-13 08:42:13.046485+00
88570fb0-f78b-4c77-a670-b5dcc6e94f47	a60f2ee1-7ec0-4ce8-b488-591d02d1b777	The teacher's test scores	f	\N	2026-05-13 08:42:16.806897+00
363feb78-4ba7-4aff-8055-9a90ff8f0035	a60f2ee1-7ec0-4ce8-b488-591d02d1b777	The WRER calculation (actual visits vs. scheduled visits)	t	\N	2026-05-13 08:42:16.806897+00
6deeb556-0c67-4abf-a085-2a6d217fb0ae	a60f2ee1-7ec0-4ce8-b488-591d02d1b777	The principal's satisfaction survey	f	\N	2026-05-13 08:42:16.806897+00
51f6394c-c5f4-4c97-9479-a8ab1f7ab3ec	a60f2ee1-7ec0-4ce8-b488-591d02d1b777	The coach's attendance at the office	f	\N	2026-05-13 08:42:16.806897+00
91923f99-c6ff-4df7-9f33-dad72ff88424	3c7efc28-f4b9-4128-8274-38b3c3ed6ceb	If the coach is late, the teacher can be late	f	\N	2026-05-13 08:42:17.718785+00
2c370f79-56ba-437b-bf2e-7427b7477356	3c7efc28-f4b9-4128-8274-38b3c3ed6ceb	Coaches must show up consistently if they expect teachers to be prepared	t	\N	2026-05-13 08:42:17.718785+00
50f1da0e-6e5d-49ea-af79-67cc2adf2ba2	3c7efc28-f4b9-4128-8274-38b3c3ed6ceb	The school provides a desk for the coach	f	\N	2026-05-13 08:42:17.718785+00
cb5ada0a-079d-4884-833c-be648b212d4b	3c7efc28-f4b9-4128-8274-38b3c3ed6ceb	The coach and teacher trade notes	f	\N	2026-05-13 08:42:17.718785+00
e0e1e9cd-fe5b-4aaa-97eb-c3c0dbaa5580	d0553835-b98f-477b-9ff8-c9a63394ee03	A personal failure of the coach	f	\N	2026-05-13 08:42:18.673518+00
393ad65a-0452-4400-b050-bf9d14c8e40b	d0553835-b98f-477b-9ff8-c9a63394ee03	A signal that the system needs a stronger 'Guardian'	t	\N	2026-05-13 08:42:18.673518+00
a74109d5-b884-48cf-9e73-52e05e8067b6	d0553835-b98f-477b-9ff8-c9a63394ee03	A normal part of school life that cannot be changed	f	\N	2026-05-13 08:42:18.673518+00
37920ef7-a304-4232-aac3-2b8f8886583c	d0553835-b98f-477b-9ff8-c9a63394ee03	A reason to stop coaching	f	\N	2026-05-13 08:42:18.673518+00
48e3bcbb-2def-4642-9208-e31ac75805a4	1987cc3c-4ae6-458f-83da-7bcc9d42b532	A single mandatory instruction	f	\N	2026-05-13 08:42:37.523446+00
e14d61a4-ecc5-4b99-8d5e-222d61a37d51	1987cc3c-4ae6-458f-83da-7bcc9d42b532	2–3 evidence-based strategies for the teacher to choose from	t	\N	2026-05-13 08:42:37.523446+00
417ccfbe-495e-4ee3-b5aa-a10f3217557d	1987cc3c-4ae6-458f-83da-7bcc9d42b532	A list of all teaching theories from the last decade	f	\N	2026-05-13 08:42:37.523446+00
39aae868-cdbb-4862-8830-6b258bdb4f4e	1987cc3c-4ae6-458f-83da-7bcc9d42b532	A choice of which day to be observed	f	\N	2026-05-13 08:42:37.523446+00
c673e69a-b686-4468-8e40-15b5b1dc34a0	fa63cee5-560d-4f72-ba3f-18540ed4d869	Reporting the students to the office	f	\N	2026-05-13 08:42:38.413467+00
321c2e84-17e1-4e04-ae67-52808dc9e9cc	fa63cee5-560d-4f72-ba3f-18540ed4d869	Switching to another strategy from the menu	t	\N	2026-05-13 08:42:38.413467+00
e11f8550-1aae-4d7f-a79a-b3a66ce5f646	fa63cee5-560d-4f72-ba3f-18540ed4d869	Quitting the coaching cycle	f	\N	2026-05-13 08:42:38.413467+00
953da461-a2f6-4495-98fe-efe42cc61359	fa63cee5-560d-4f72-ba3f-18540ed4d869	Giving the students a lower grade	f	\N	2026-05-13 08:42:38.413467+00
70bcaa17-f148-4d06-a982-d39e5237a633	592cb5d8-bbb3-48f4-afa3-50e0a94d187e	Speaking louder than the teacher	f	\N	2026-05-13 08:42:39.377303+00
ceff59a8-68b0-4663-96b1-34f6bfd51104	592cb5d8-bbb3-48f4-afa3-50e0a94d187e	The teacher's ideas are as valuable as the coach's	t	\N	2026-05-13 08:42:39.377303+00
6c96ea87-c027-4f5c-8ef1-00ed430da8b3	592cb5d8-bbb3-48f4-afa3-50e0a94d187e	Only the coach speaks during the 'Improve' phase	f	\N	2026-05-13 08:42:39.377303+00
3aca096c-f858-4e10-b580-1ac2c86fcf5a	592cb5d8-bbb3-48f4-afa3-50e0a94d187e	Recording the teacher's voice for an audit	f	\N	2026-05-13 08:42:39.377303+00
56daab0a-51be-4280-84d8-b0b1ecd4b159	f2a48cb5-2bc0-465a-97a8-4115f6163d82	Administrator	f	\N	2026-05-13 08:42:42.485258+00
1e094cfd-3d04-49d0-8882-ae2f835549b0	f2a48cb5-2bc0-465a-97a8-4115f6163d82	Instructional Catalyst	t	\N	2026-05-13 08:42:42.485258+00
89c03c95-427c-4a0b-82e2-9e867f3e1e00	f2a48cb5-2bc0-465a-97a8-4115f6163d82	Evaluator	f	\N	2026-05-13 08:42:42.485258+00
5a5e6356-a699-424a-bd8c-e052ab2a8488	f2a48cb5-2bc0-465a-97a8-4115f6163d82	Expert with an Opinion	f	\N	2026-05-13 08:42:42.485258+00
942aa293-bbeb-4f37-b7b3-969c65880251	709715be-bcf0-469a-a9bf-9306bf04351a	A student failing a test	f	\N	2026-05-13 08:42:43.39637+00
a710e0de-519f-41cd-a20d-0701d51114e2	709715be-bcf0-469a-a9bf-9306bf04351a	The mental model or root cause behind a teaching behavior	t	\N	2026-05-13 08:42:43.39637+00
8e14b2c3-2461-4f98-bc54-79bef422aad0	709715be-bcf0-469a-a9bf-9306bf04351a	Not having enough textbooks	f	\N	2026-05-13 08:42:43.39637+00
d86ef0f6-f3ad-4f77-aa4a-9c8f1e226209	709715be-bcf0-469a-a9bf-9306bf04351a	A teacher being late to class	f	\N	2026-05-13 08:42:43.39637+00
792d9c1e-99d5-47e7-a0e1-2762552c3da7	1cf8b77c-716f-481e-bc9a-f712f4724c46	Asks a question	f	\N	2026-05-13 08:42:44.411469+00
0780fc17-07c8-47ca-ab18-7cdb8e045bb9	1cf8b77c-716f-481e-bc9a-f712f4724c46	Delivers an evaluation as a fact	t	\N	2026-05-13 08:42:44.411469+00
039fc066-79bd-4cde-b009-b5c5065d573a	1cf8b77c-716f-481e-bc9a-f712f4724c46	Offers a choice	f	\N	2026-05-13 08:42:44.411469+00
f4dcbe15-a8a5-4b5f-a66b-efb6c86e0972	1cf8b77c-716f-481e-bc9a-f712f4724c46	Listens to the teacher	f	\N	2026-05-13 08:42:44.411469+00
22ea80de-d6ac-490c-9f7b-e96d45bc3d68	eee56778-7d8f-4895-bd77-05ae7494fe14	To quit	f	\N	2026-05-13 08:42:48.20041+00
8ecde500-2643-4efc-8149-a449ae3ba2d6	eee56778-7d8f-4895-bd77-05ae7494fe14	One of the 4 Paths (Stay the Course, Modify, Switch, Re-Identify)	t	\N	2026-05-13 08:42:48.20041+00
34e7f85b-8a94-4f5d-8177-a9c573dc81d8	eee56778-7d8f-4895-bd77-05ae7494fe14	To blame the coach	f	\N	2026-05-13 08:42:48.20041+00
6c2649c8-87ef-4a4d-a9d8-a28b1ec4fb91	eee56778-7d8f-4895-bd77-05ae7494fe14	To ignore the data	f	\N	2026-05-13 08:42:48.20041+00
7ce94ad8-fdf3-4bb5-933b-7b40ee366442	ad5e9483-1873-4a22-a1e2-3a196afa6c0b	Conclusions	f	\N	2026-05-13 08:42:49.210497+00
f3611f73-8fc9-44f4-b120-2cc37b0182e5	ad5e9483-1873-4a22-a1e2-3a196afa6c0b	Questions (e.g., 'What should we try next?')	t	\N	2026-05-13 08:42:49.210497+00
6197f24c-7336-47da-a607-d07448f56579	ad5e9483-1873-4a22-a1e2-3a196afa6c0b	Verdicts	f	\N	2026-05-13 08:42:49.210497+00
46b9577f-4c49-441e-9f8f-4be6b920c5d2	ad5e9483-1873-4a22-a1e2-3a196afa6c0b	Instructions	f	\N	2026-05-13 08:42:49.210497+00
3be63baa-c8b0-4daf-b782-215266b83952	36c682d7-159d-4584-b8b0-357688dad2bd	The teacher liked the session	f	\N	2026-05-13 08:42:50.223436+00
89e71434-3bbd-4f34-8e99-2e2d2c5d3854	36c682d7-159d-4584-b8b0-357688dad2bd	The strategy actually led to student results	t	\N	2026-05-13 08:42:50.223436+00
985ed5a9-030d-46f9-89a7-063fffea3ec1	36c682d7-159d-4584-b8b0-357688dad2bd	The coach finished their paperwork	f	\N	2026-05-13 08:42:50.223436+00
87d74fea-a93e-41e9-a825-85c0cb385fee	36c682d7-159d-4584-b8b0-357688dad2bd	The bell rang on time	f	\N	2026-05-13 08:42:50.223436+00
ccbf48f7-6584-4276-be9e-39078f61da79	374aa3cf-943e-4a93-8ddf-4642afdebb4e	Curious Openers	t	\N	2026-05-13 08:42:42.969595+00
30825045-5317-4fd6-be9e-f7792efd54f2	374aa3cf-943e-4a93-8ddf-4642afdebb4e	Evaluative adjectives (e.g., 'That was bad')	f	\N	2026-05-13 08:42:42.969595+00
7a022705-11ce-46b2-995d-d148568263f1	374aa3cf-943e-4a93-8ddf-4642afdebb4e	Strict deadlines for improvement	f	\N	2026-05-13 08:42:42.969595+00
11e3f7a7-d0ca-4ac1-b14f-e199fc72b59c	358d96ac-6ef8-43b9-9d49-f60c2f60f3f2	'You need to use more visual aids'	f	\N	2026-05-13 08:42:43.883141+00
6e80de5c-412f-4837-a522-edbca369982b	358d96ac-6ef8-43b9-9d49-f60c2f60f3f2	'Looking at these 10 students who did not finish, what do you think was the biggest barrier for them?'	t	\N	2026-05-13 08:42:43.883141+00
f95626b0-295b-496d-b8d5-b04b0330b9fa	358d96ac-6ef8-43b9-9d49-f60c2f60f3f2	'Your lesson was messy'	f	\N	2026-05-13 08:42:43.883141+00
ff48d75c-b56c-4030-a090-2e1e97303537	358d96ac-6ef8-43b9-9d49-f60c2f60f3f2	'Why did you not follow the plan I gave you?'	f	\N	2026-05-13 08:42:43.883141+00
a349672e-badd-42f8-b191-3d3f732aeadc	ba3acb16-9bf4-4619-8129-bea5c382163f	Naming a specific missing skill	f	\N	2026-05-13 08:42:44.905758+00
3970c04a-5792-416b-99a8-3dfa290a57ec	ba3acb16-9bf4-4619-8129-bea5c382163f	Restating the symptom (e.g., 'Teacher does not know how to engage students')	t	\N	2026-05-13 08:42:44.905758+00
ee86013b-18c2-46e8-a842-e5d031f8ffa3	ba3acb16-9bf4-4619-8129-bea5c382163f	Identifying a specific mental model	f	\N	2026-05-13 08:42:44.905758+00
096789ff-213f-4ff8-991f-24ec15c233dc	ba3acb16-9bf4-4619-8129-bea5c382163f	Citing student data	f	\N	2026-05-13 08:42:44.905758+00
36f25b42-3f55-4a6d-b230-dc96de9036d7	66938930-c4ce-41dc-8f45-3bb6a6bb3f23	Way for the coach to take over the class	f	\N	2026-05-13 08:42:47.770429+00
73122125-7184-4d7e-8af8-3b1e6525d212	66938930-c4ce-41dc-8f45-3bb6a6bb3f23	Bridge for the teacher to move from watching to doing with support	t	\N	2026-05-13 08:42:47.770429+00
9b83221a-1029-430a-ba63-8732c5a5312a	66938930-c4ce-41dc-8f45-3bb6a6bb3f23	Method for the coach to rest	f	\N	2026-05-13 08:42:47.770429+00
1a858b31-8c88-4f40-848f-a829766ee047	66938930-c4ce-41dc-8f45-3bb6a6bb3f23	Test for the students	f	\N	2026-05-13 08:42:47.770429+00
54e25746-ed44-47a6-8613-03bdab4a2c55	2e82d8dc-c750-4776-b7e6-2a184ec5b0de	How well they taught compared to the teacher	f	\N	2026-05-13 08:42:48.718329+00
e7d64232-19d9-40d9-9f52-b533d64676f3	2e82d8dc-c750-4776-b7e6-2a184ec5b0de	Specifically when they stepped in and what they modeled	t	\N	2026-05-13 08:42:48.718329+00
656bdb8d-e0a7-4430-8ff1-7f8df22f07eb	2e82d8dc-c750-4776-b7e6-2a184ec5b0de	What the students were wearing	f	\N	2026-05-13 08:42:48.718329+00
d8236630-6e20-41ce-8f64-d7f4c4a2c3c9	2e82d8dc-c750-4776-b7e6-2a184ec5b0de	The mistakes the teacher made	f	\N	2026-05-13 08:42:48.718329+00
aacbfa36-cb7b-4711-bf47-23d9354701ba	c9cee797-7b30-44e5-b2e9-d0508c0f28f1	The coach's recommendation	f	\N	2026-05-13 08:42:49.65688+00
3bdf16df-26f4-4367-9951-15c9d5d7c0df	c9cee797-7b30-44e5-b2e9-d0508c0f28f1	The teacher's reading of student evidence	t	\N	2026-05-13 08:42:49.65688+00
3c8e74ff-03b3-4aa4-9614-0811cea97521	c9cee797-7b30-44e5-b2e9-d0508c0f28f1	The Principal's mood	f	\N	2026-05-13 08:42:49.65688+00
e4edd57f-b1f1-4a35-86b7-c903b825d75f	c9cee797-7b30-44e5-b2e9-d0508c0f28f1	The easiest option available	f	\N	2026-05-13 08:42:49.65688+00
d2487607-4bb8-49df-ad6f-af746208f364	1c20a9c4-996a-4935-9957-ecc3b6d43ed1	Increasing Audit Pressure	f	\N	2026-05-13 08:42:52.960966+00
4d6c5519-6881-4b70-b1f7-2ab2d9dc5242	1c20a9c4-996a-4935-9957-ecc3b6d43ed1	Diagnosing the System	t	\N	2026-05-13 08:42:52.960966+00
e6601a2f-0be4-445a-a981-95cc5fbf4156	1c20a9c4-996a-4935-9957-ecc3b6d43ed1	Judging Personality	f	\N	2026-05-13 08:42:52.960966+00
4a196fd5-1bde-4875-862a-d87c271ed513	a9b7aa12-9a0b-47e8-9f58-a6a51c24acb6	The teacher's salary level	f	\N	2026-05-11 12:26:49.587848+00
01cb4dd4-9fce-4f3e-8485-731dbcc13a00	a9b7aa12-9a0b-47e8-9f58-a6a51c24acb6	The perception of being less important than the coach	t	\N	2026-05-11 12:26:49.587848+00
cd622692-3104-405b-ae0e-f191aceec609	a9b7aa12-9a0b-47e8-9f58-a6a51c24acb6	The physical location of the school	f	\N	2026-05-11 12:26:49.587848+00
934ccdda-10fc-425d-b5df-f0c63b1cf6aa	a9b7aa12-9a0b-47e8-9f58-a6a51c24acb6	The number of students in the class	f	\N	2026-05-11 12:26:49.587848+00
bef548d7-5d5e-4e86-a610-b228f0a4a11a	677353e5-3979-475e-a63e-c4ba64a2b54c	Hide teacher mistakes from the coach	f	\N	2026-05-11 12:26:50.022+00
c61435ba-0be2-4d97-b244-3ce5f12e1e50	677353e5-3979-475e-a63e-c4ba64a2b54c	Protect the safe space between coach and teacher from administrative judgment	t	\N	2026-05-11 12:26:50.022+00
490e7a5d-c761-4931-9556-7af1728a29af	677353e5-3979-475e-a63e-c4ba64a2b54c	Keep the school's address private	f	\N	2026-05-11 12:26:50.022+00
8571675e-f548-45e2-9215-e3d6e2d516f3	677353e5-3979-475e-a63e-c4ba64a2b54c	Avoid writing any reports at all	f	\N	2026-05-11 12:26:50.022+00
7c1da797-5b0a-4bb2-b085-9b3202d83297	c2d84215-2b5e-441c-b45e-28115378d18c	Both the coach and teacher have the same job title	f	\N	2026-05-11 12:26:50.455953+00
1a90e01c-739f-4ca4-b69e-e056b6686c28	c2d84215-2b5e-441c-b45e-28115378d18c	The coach and teacher have equal say in the professional growth path	t	\N	2026-05-11 12:26:50.455953+00
60db4dfb-fd9e-478b-8539-0cb4c435ab07	c2d84215-2b5e-441c-b45e-28115378d18c	The teacher does not have to listen to the coach	f	\N	2026-05-11 12:26:50.455953+00
83851120-ea27-4e46-8a1c-7d2e24477cf2	c2d84215-2b5e-441c-b45e-28115378d18c	The Principal is no longer in charge	f	\N	2026-05-11 12:26:50.455953+00
d1669c8a-c4e9-444d-a47e-2c9dc6cf939e	6b974557-df0f-447c-96b5-42ec19b4aa6a	The teacher's personality	f	\N	2026-05-11 12:26:50.883078+00
b8e84e5b-9b9d-4338-b735-698c80fd114b	6b974557-df0f-447c-96b5-42ec19b4aa6a	Objective student data (e.g., '10 students are off-task')	t	\N	2026-05-11 12:26:50.883078+00
5b8a19d2-528a-436f-ab63-6b34423e86cd	6b974557-df0f-447c-96b5-42ec19b4aa6a	The coach's own teaching history	f	\N	2026-05-11 12:26:50.883078+00
9841ed74-c3c0-4e21-8fab-049596df45a3	6b974557-df0f-447c-96b5-42ec19b4aa6a	How the teacher dresses	f	\N	2026-05-11 12:26:50.883078+00
8892fcaa-9c12-4bc8-b927-8f980a3146b6	e66dc282-77ca-4e87-9733-1e8474878536	'You must do this'	f	\N	2026-05-11 12:26:51.317765+00
ebb1e1b7-347d-46eb-a8f3-7c4f0fb91ac5	e66dc282-77ca-4e87-9733-1e8474878536	'I am telling you to change the seating'	f	\N	2026-05-11 12:26:51.317765+00
f5beec23-9b12-4008-b0f6-8fb0f99ce7a4	e66dc282-77ca-4e87-9733-1e8474878536	'Would you prefer to focus on questioning or transitions first?'	t	\N	2026-05-11 12:26:51.317765+00
1efa3689-022c-4bf5-a917-9e151c5bdf12	e66dc282-77ca-4e87-9733-1e8474878536	'The Principal wants you to do this'	f	\N	2026-05-11 12:26:51.317765+00
1f1b4075-395b-4134-a976-7d0a721929c4	4415e272-0510-4e2e-a059-22a23021a683	To make the teacher afraid so they work harder	f	\N	2026-05-11 12:26:51.747869+00
41197217-6587-422e-9ccc-75a1761b84ae	4415e272-0510-4e2e-a059-22a23021a683	To keep the teacher's brain in a 'Learning State' rather than a 'Survival State'	t	\N	2026-05-11 12:26:51.747869+00
fec20f94-f151-4624-ac73-17fb6c10e86d	4415e272-0510-4e2e-a059-22a23021a683	To finish the meeting as fast as possible	f	\N	2026-05-11 12:26:51.747869+00
01735adc-c191-4432-af0c-0490f12be610	4415e272-0510-4e2e-a059-22a23021a683	To ensure the coach looks like the expert	f	\N	2026-05-11 12:26:51.747869+00
9feddd56-a536-48c7-83f0-c5ffc36d76f3	f973b07d-e858-4743-ac29-3a62f46ccbde	Listens to the teacher's life story	f	\N	2026-05-11 12:26:54.512259+00
0771c098-1f72-47ee-ac78-ff57f47bf570	f973b07d-e858-4743-ac29-3a62f46ccbde	Relates everything the teacher says back to the coach's own experience	t	\N	2026-05-11 12:26:54.512259+00
573a8653-8a0f-4d8a-826d-bee9172837e4	f973b07d-e858-4743-ac29-3a62f46ccbde	Writes a biography of the teacher	f	\N	2026-05-11 12:26:54.512259+00
dcc4926b-c18e-473e-8b16-2402f3589ef9	f973b07d-e858-4743-ac29-3a62f46ccbde	Ignores the teacher completely	f	\N	2026-05-11 12:26:54.512259+00
bc344dd0-e90b-4634-84f4-083f43cc752b	eada3485-d835-43b9-9de1-17e40aa8ab41	0 seconds	f	\N	2026-05-11 12:26:55.039116+00
191dd799-5680-4378-b680-3c3fc36a4a9b	eada3485-d835-43b9-9de1-17e40aa8ab41	3–5 seconds after the teacher finishes speaking	t	\N	2026-05-11 12:26:55.039116+00
46f453a7-0b5d-483f-9e10-3a045f931dbb	eada3485-d835-43b9-9de1-17e40aa8ab41	1 minute of total silence	f	\N	2026-05-11 12:26:55.039116+00
36cd2c71-db60-4813-88eb-b60700e5cc37	eada3485-d835-43b9-9de1-17e40aa8ab41	Only when the coach is tired of talking	f	\N	2026-05-11 12:26:55.039116+00
b7fce670-0b99-4712-a0c5-e00f3fc71a66	9f9b5ef2-5337-4c00-a63f-305375c15f17	Giving the teacher a solution immediately	f	\N	2026-05-11 12:26:55.544459+00
6f0e24d9-6148-4504-a8c1-790df192f78f	9f9b5ef2-5337-4c00-a63f-305375c15f17	Acknowledging the teacher's feelings and the facts of their situation	t	\N	2026-05-11 12:26:55.544459+00
af75c273-737d-4437-8244-6d2c0c790fb2	9f9b5ef2-5337-4c00-a63f-305375c15f17	Telling the teacher why they are wrong	f	\N	2026-05-11 12:26:55.544459+00
4c7f397e-ae37-4bf9-9258-e92d03ac4839	9f9b5ef2-5337-4c00-a63f-305375c15f17	Complaining about the school together	f	\N	2026-05-11 12:26:55.544459+00
7cf953a3-da06-479b-8fdd-b6a001583fd8	22048d33-79d0-4667-ba37-e90d40a892f9	Talk more than the teacher	f	\N	2026-05-11 12:26:56.048594+00
42509093-cbde-4651-8a81-45451baf4ba6	22048d33-79d0-4667-ba37-e90d40a892f9	Ensure they have correctly understood the teacher's perspective	t	\N	2026-05-11 12:26:56.048594+00
ae5e2fbc-07fb-47d1-af4f-c3cc817599e4	22048d33-79d0-4667-ba37-e90d40a892f9	Repeat the textbook word-for-word	f	\N	2026-05-11 12:26:56.048594+00
d2178458-b732-4c3a-a3c4-84027526a6ae	22048d33-79d0-4667-ba37-e90d40a892f9	Show off their vocabulary	f	\N	2026-05-11 12:26:56.048594+00
43120dae-f5bd-4a41-a11b-2e4029efa996	a543f020-7894-4ffd-afb8-45139a8c9fa8	The coach speaks 80% of the time	f	\N	2026-05-11 12:26:56.482571+00
cd300946-dcac-4d15-8469-d3e9a29b9cb4	a543f020-7894-4ffd-afb8-45139a8c9fa8	The coach and teacher speak roughly equally, or the teacher speaks more	t	\N	2026-05-11 12:26:56.482571+00
fb9c5d00-5220-4968-b848-ef498caa1001	a543f020-7894-4ffd-afb8-45139a8c9fa8	No one speaks; it is all written	f	\N	2026-05-11 12:26:56.482571+00
e4aff8f7-ce66-4502-9e21-44f1e15d3d13	a543f020-7894-4ffd-afb8-45139a8c9fa8	The Principal does all the talking	f	\N	2026-05-11 12:26:56.482571+00
99d77cb9-26ba-49f0-ae2f-d314705cd910	5a30e280-7150-4695-b96f-fe8bd1ad2385	'The teacher was lazy'	f	\N	2026-05-11 12:26:56.909949+00
265ec6dc-c9c9-4456-a187-df420b9842aa	5a30e280-7150-4695-b96f-fe8bd1ad2385	'Only 5 students out of 40 completed the worksheet'	t	\N	2026-05-11 12:26:56.909949+00
5d48d70e-b378-4eb7-833e-86a1b9e617b3	5a30e280-7150-4695-b96f-fe8bd1ad2385	'The lesson was boring'	f	\N	2026-05-11 12:26:56.909949+00
892b5a43-40db-4f9c-9e4e-dd2319fcb0f9	5a30e280-7150-4695-b96f-fe8bd1ad2385	'The teacher is a natural leader'	f	\N	2026-05-11 12:26:56.909949+00
a74d4cf7-c4dd-47dd-bfbf-cd39956db9ba	57942e71-265d-435b-9643-c6844184f4d3	The Principal	f	\N	2026-05-11 12:26:59.806106+00
a0ba75a6-c232-4e32-9cda-d64edb14f2f9	57942e71-265d-435b-9643-c6844184f4d3	The Coach	f	\N	2026-05-11 12:26:59.806106+00
d6f22902-5a9b-45c3-b065-9e6487355856	57942e71-265d-435b-9643-c6844184f4d3	The Teacher (with coach guidance)	t	\N	2026-05-11 12:26:59.806106+00
b0f66a17-570e-4f4b-8cff-23bff30adfff	57942e71-265d-435b-9643-c6844184f4d3	The District Office	f	\N	2026-05-11 12:26:59.806106+00
e50eb645-426d-484d-8eef-d3ba5266d9ae	adb00418-d3df-49a3-8613-e1843e17f4d4	It is very long	f	\N	2026-05-11 12:27:00.253513+00
50df0452-477a-4e49-9f0d-d6c6298d6586	adb00418-d3df-49a3-8613-e1843e17f4d4	It can be seen and counted (e.g., student talk time)	t	\N	2026-05-11 12:27:00.253513+00
074eeb0c-85ad-49fc-b42a-5f27925217ab	adb00418-d3df-49a3-8613-e1843e17f4d4	The coach likes it	f	\N	2026-05-11 12:27:00.253513+00
e21a3494-3fcd-4976-a7a2-4691a6dc3914	adb00418-d3df-49a3-8613-e1843e17f4d4	It is written in a nice font	f	\N	2026-05-11 12:27:00.253513+00
a53643af-adfa-40c3-9546-eaac5436dc35	96669048-95e6-4a03-baa8-55754333421a	The teacher works harder	f	\N	2026-05-11 12:27:00.761461+00
4e28be17-822d-4cee-b2d5-67894e5aedab	96669048-95e6-4a03-baa8-55754333421a	The teacher complies but does not truly change their practice	t	\N	2026-05-11 12:27:00.761461+00
1d975459-b4f7-413d-b537-94d4f1b33cf5	96669048-95e6-4a03-baa8-55754333421a	The teacher gets a promotion	f	\N	2026-05-11 12:27:00.761461+00
dd2abac1-d8b0-4141-adcf-6fa723f5f388	96669048-95e6-4a03-baa8-55754333421a	The students learn faster	f	\N	2026-05-11 12:27:00.761461+00
1906c001-37fd-4140-8bfc-dd1461c67e99	ffa03d7b-b6a5-4213-9979-f0510c37b39e	Identifying teacher mistakes	f	\N	2026-05-11 12:27:01.249641+00
a1ff6c6a-4872-451a-a83e-482d97d2fb9e	ffa03d7b-b6a5-4213-9979-f0510c37b39e	Finding the 'Current Reality' of the classroom	t	\N	2026-05-11 12:27:01.249641+00
894f399f-ec1b-41b0-bc7f-2c638477217e	ffa03d7b-b6a5-4213-9979-f0510c37b39e	Identifying who is the boss	f	\N	2026-05-11 12:27:01.249641+00
3fd81c64-973b-49af-97a7-4f9af7410cca	ffa03d7b-b6a5-4213-9979-f0510c37b39e	Identifying which students are the loudest	f	\N	2026-05-11 12:27:01.249641+00
8ad27969-bc09-4da1-89e7-e85a12212e8a	8cefcecd-7483-477b-994b-a8f1f0398b85	The coach writes it and the teacher signs it	f	\N	2026-05-11 12:27:01.684959+00
a207a2b0-c6e4-44f0-b953-6c32ce7b11c5	8cefcecd-7483-477b-994b-a8f1f0398b85	The teacher and coach build the goal together through dialogue	t	\N	2026-05-11 12:27:01.684959+00
98d50813-87d8-49e9-bfdd-75917f6999d3	8cefcecd-7483-477b-994b-a8f1f0398b85	The students choose what they want to learn	f	\N	2026-05-11 12:27:01.684959+00
6b5184a4-1df6-45a0-b144-812fcffa70a3	8cefcecd-7483-477b-994b-a8f1f0398b85	There is no goal	f	\N	2026-05-11 12:27:01.684959+00
c737e203-ddae-4e67-9dac-d6df87fce394	47cef7ba-72f2-4b67-ae61-632abd55d4b1	It is easy to ignore	f	\N	2026-05-11 12:27:02.117825+00
91947202-e52f-449c-b659-1fba9f239b7d	47cef7ba-72f2-4b67-ae61-632abd55d4b1	It builds the teacher's confidence and momentum	t	\N	2026-05-11 12:27:02.117825+00
e3526428-762a-4f01-b026-042cd0f935cf	47cef7ba-72f2-4b67-ae61-632abd55d4b1	It saves the coach time	f	\N	2026-05-11 12:27:02.117825+00
837d93bc-0fc6-44b5-b254-79225662db3f	47cef7ba-72f2-4b67-ae61-632abd55d4b1	It does not require any data	f	\N	2026-05-11 12:27:02.117825+00
b8894c00-f30b-4a6d-86e1-dbc89992ba54	f39927a9-43e4-41be-94d0-d5439b701b55	Inspecting teachers and reporting to management	f	\N	2026-05-11 14:02:24.848188+00
57b2768e-cb7c-474a-9293-b912b3a1d74b	f39927a9-43e4-41be-94d0-d5439b701b55	A supportive partnership that builds teacher capacity	t	\N	2026-05-11 14:02:24.848188+00
5c1da3e9-02a8-4ee7-a9a8-8555870b097c	f39927a9-43e4-41be-94d0-d5439b701b55	Giving teachers prescriptive feedback on their weaknesses	f	\N	2026-05-11 14:02:24.848188+00
44bb90c1-40b8-429e-8a80-376d285bfdfa	f39927a9-43e4-41be-94d0-d5439b701b55	Evaluating teachers for annual performance reviews	f	\N	2026-05-11 14:02:24.848188+00
5e099074-7715-4eda-9438-9cd482f95cce	96a60384-57b1-4d34-b8a3-60d37a929e4e	The gap between school management and classroom teachers	f	\N	2026-05-11 14:02:25.272854+00
75e9e916-8a43-4ab4-989a-013d73e307a1	96a60384-57b1-4d34-b8a3-60d37a929e4e	The gap between learning theory and applying it in the classroom	t	\N	2026-05-11 14:02:25.272854+00
4010820b-2906-4129-86fa-bf731599ec40	96a60384-57b1-4d34-b8a3-60d37a929e4e	The gap between strong and weak teachers	f	\N	2026-05-11 14:02:25.272854+00
6213d46d-5ce7-4a1d-a454-9078eea9cb34	96a60384-57b1-4d34-b8a3-60d37a929e4e	The gap between coaching visits and teacher availability	f	\N	2026-05-11 14:02:25.272854+00
55550ad4-6b35-4c60-acd0-9d73a734b058	17a1dd84-c0b0-4263-9d62-f053b4ae701f	Coaching is shorter and less formal than inspection	f	\N	2026-05-11 14:02:25.775607+00
8826015c-bd64-4a6c-8a44-66e43a72be34	17a1dd84-c0b0-4263-9d62-f053b4ae701f	Coaching is a partnership of equals; inspection is top-down judgment	t	\N	2026-05-11 14:02:25.775607+00
48919814-9020-43fe-be8b-86aed6415d16	17a1dd84-c0b0-4263-9d62-f053b4ae701f	Coaching happens more frequently than inspection	f	\N	2026-05-11 14:02:25.775607+00
ada59cd1-53fd-4d3e-9bc6-d2dfc69d248b	17a1dd84-c0b0-4263-9d62-f053b4ae701f	Coaching only focuses on positive feedback	f	\N	2026-05-11 14:02:25.775607+00
2bc289df-8b57-4317-93b8-872ae695d583	1c28f009-d7dc-4a26-b83b-4ad7b6fc930a	The coach, who knows the destination	f	\N	2026-05-11 14:02:26.287404+00
fdd709da-2716-4966-9a95-6bd9aa041893	1c28f009-d7dc-4a26-b83b-4ad7b6fc930a	The coach and teacher together, as equal partners	t	\N	2026-05-11 14:02:26.287404+00
58797f03-8966-4fd8-829c-f8afe2586fde	1c28f009-d7dc-4a26-b83b-4ad7b6fc930a	The head teacher, who sets the direction	f	\N	2026-05-11 14:02:26.287404+00
d20c75ae-bf18-4434-a4ea-8a6a954fa860	1c28f009-d7dc-4a26-b83b-4ad7b6fc930a	The teacher alone, once the coach has explained the goal	f	\N	2026-05-11 14:02:26.287404+00
c55e84cb-0bfa-4a9f-a5af-fe51de06d99e	69c38655-0276-41be-bb5d-af0ef97ef5f8	Because more visits mean more accountability for the teacher	f	\N	2026-05-11 14:02:26.783502+00
643c48e3-c4c0-416f-b8fd-5b2c0fffe890	69c38655-0276-41be-bb5d-af0ef97ef5f8	Because regular cycles solidify new habits through consistent feedback loops	t	\N	2026-05-11 14:02:26.783502+00
01622778-c6c8-436d-ace6-fb81a988550d	69c38655-0276-41be-bb5d-af0ef97ef5f8	Because frequent visits allow the coach to catch more mistakes	f	\N	2026-05-11 14:02:26.783502+00
a092a948-d4f0-4de4-bf85-fc2949f40a75	69c38655-0276-41be-bb5d-af0ef97ef5f8	Because teachers prefer more visits to fewer, longer sessions	f	\N	2026-05-11 14:02:26.783502+00
a5d80fbc-ed1f-4d04-830f-1625901c2c89	7008b319-d872-4b71-90ab-0b6b06d485c4	Authoritative and directive, to ensure teachers take action	f	\N	2026-05-11 14:02:27.208274+00
3862be7f-3173-47ec-8de2-6cf6a382b1bd	7008b319-d872-4b71-90ab-0b6b06d485c4	Supportive and constructive, building confidence and capacity	t	\N	2026-05-11 14:02:27.208274+00
65d89ee6-341f-4f60-828f-7ef0b0665a23	7008b319-d872-4b71-90ab-0b6b06d485c4	Critical and challenging, to push teachers out of comfort zones	f	\N	2026-05-11 14:02:27.208274+00
317303a7-e87f-4b9d-b8fb-59d842a3d8ed	7008b319-d872-4b71-90ab-0b6b06d485c4	Neutral and distant, to maintain professional objectivity	f	\N	2026-05-11 14:02:27.208274+00
64b404b8-e919-44b1-ba80-77c58ba6a731	bff2dece-2ff4-490d-90c8-d500443d1355	Ask a curious opener to invite teacher ownership	f	\N	2026-05-11 14:02:30.111308+00
daa13a28-7f4b-4f8b-8d71-73cdf314e2ea	bff2dece-2ff4-490d-90c8-d500443d1355	Observe and collect observable behaviors	t	\N	2026-05-11 14:02:30.111308+00
abb6fa88-0679-48f2-98e9-3134770d6853	bff2dece-2ff4-490d-90c8-d500443d1355	Co-interpret evidence with the teacher	f	\N	2026-05-11 14:02:30.111308+00
8a65dc25-2be2-4f73-a172-ca1ee99880e6	bff2dece-2ff4-490d-90c8-d500443d1355	Set next steps with a follow-up date	f	\N	2026-05-11 14:02:30.111308+00
ec0200c2-671f-4aa5-b46a-ab2862a59115	e2f82106-c813-4236-853a-a2f5df8c45f5	The coach chooses the most important improvement area for the teacher	f	\N	2026-05-11 14:02:30.533763+00
4d0ac276-a5da-4d5d-800c-54955d44b064	e2f82106-c813-4236-853a-a2f5df8c45f5	Teachers have a say in their own professional goals and the actions they take	t	\N	2026-05-11 14:02:30.533763+00
a05d0827-bed8-4929-a3b4-ac940caee2f9	e2f82106-c813-4236-853a-a2f5df8c45f5	Both the coach and teacher share equal input in all decisions	f	\N	2026-05-11 14:02:30.533763+00
4ab94d99-ab65-450e-8124-571105c1b781	e2f82106-c813-4236-853a-a2f5df8c45f5	Teachers choose whether to participate in coaching or not	f	\N	2026-05-11 14:02:30.533763+00
ffca8e9d-a107-4d42-af06-63c089188464	014dc8cc-34a2-4eb7-89b8-4df1762f8f11	Coaches who are too knowledgeable about pedagogy to relate to teachers	f	\N	2026-05-11 14:02:30.989966+00
8e24c0f4-2af8-405a-bbaf-3819c0ed9d5f	014dc8cc-34a2-4eb7-89b8-4df1762f8f11	Dominating the conversation by giving answers instead of facilitating inquiry	t	\N	2026-05-11 14:02:30.989966+00
fd434eb8-901a-426a-a077-e488b49f44d4	014dc8cc-34a2-4eb7-89b8-4df1762f8f11	Setting goals that are too ambitious for the teacher's current level	f	\N	2026-05-11 14:02:30.989966+00
c892872f-ab60-4a35-95a9-c3d995d62a2b	014dc8cc-34a2-4eb7-89b8-4df1762f8f11	Using research evidence to justify coaching recommendations	f	\N	2026-05-11 14:02:30.989966+00
e8950d3f-c61d-47ed-b393-263770fc7cf2	db21c740-00c6-406c-a3c7-664cec62862d	The coach and teacher must take turns leading the coaching conversation	f	\N	2026-05-11 14:02:31.418237+00
c95b4c20-f08f-49ef-ac52-239c5df00a1d	db21c740-00c6-406c-a3c7-664cec62862d	The coach learns from the teacher just as the teacher learns from the coach	t	\N	2026-05-11 14:02:31.418237+00
879892c6-ac3e-4108-9c8f-2feedd2d1456	db21c740-00c6-406c-a3c7-664cec62862d	Both the coach and teacher must evaluate each other's performance	f	\N	2026-05-11 14:02:31.418237+00
5050e605-5c01-4957-a5e3-d6dbcb2fbef5	db21c740-00c6-406c-a3c7-664cec62862d	Teachers reciprocate by implementing every suggestion the coach offers	f	\N	2026-05-11 14:02:31.418237+00
09e6b361-fb97-48b8-a157-fa92a4a1d132	afc4fd17-1348-4375-9b1b-65fca1ae3325	The coach and teacher receive the same salary and status in the school	f	\N	2026-05-11 14:02:31.842997+00
d59b2cb5-b41f-4c70-bee5-79b6c2796110	afc4fd17-1348-4375-9b1b-65fca1ae3325	Sitting side-by-side to review data and co-create solutions together	t	\N	2026-05-11 14:02:31.842997+00
4083d8cb-9f27-4756-8cfc-f9749fb018cd	afc4fd17-1348-4375-9b1b-65fca1ae3325	Treating all teachers as equally capable regardless of their experience	f	\N	2026-05-11 14:02:31.842997+00
ddca44bb-0013-4ffb-bcd3-a6c2760c8b84	afc4fd17-1348-4375-9b1b-65fca1ae3325	The coach avoiding all evaluative language in coaching conversations	f	\N	2026-05-11 14:02:31.842997+00
834ecd21-b1b3-4dd3-a6ad-f8069c18b11c	e3bd507f-5dc3-445f-9de7-b3bc4c091363	The coach interprets the evidence and shares the meaning with the teacher	f	\N	2026-05-11 14:02:32.271181+00
c538f295-5ea7-45b0-99bf-d2889494046c	e3bd507f-5dc3-445f-9de7-b3bc4c091363	Both partners examine the observation evidence to find meaning together	t	\N	2026-05-11 14:02:32.271181+00
1545fb57-0905-4310-9be3-b5a5f3755dda	e3bd507f-5dc3-445f-9de7-b3bc4c091363	The teacher interprets alone and the coach validates their analysis	f	\N	2026-05-11 14:02:32.271181+00
7955c617-d537-46e0-92af-6eff0b28e109	e3bd507f-5dc3-445f-9de7-b3bc4c091363	The coach and teacher discuss research studies that explain the evidence	f	\N	2026-05-11 14:02:32.271181+00
deb7b9f2-474c-42cc-ac85-a9e860c6c607	26ab0a03-3b00-4c56-81f4-e0d893b78011	Evidence of teacher failure that must be addressed	f	\N	2026-05-11 14:02:35.306758+00
55ed7b28-2ddd-4d28-b0b8-19465e4daf27	26ab0a03-3b00-4c56-81f4-e0d893b78011	A neutral starting point for collaborative discovery	t	\N	2026-05-11 14:02:35.306758+00
bca0596c-753f-4f54-9206-499d0e6fbdf9	26ab0a03-3b00-4c56-81f4-e0d893b78011	Objective proof of areas where the teacher needs to improve	f	\N	2026-05-11 14:02:35.306758+00
ddcf3063-e3e1-4bda-88e3-027247bd2628	26ab0a03-3b00-4c56-81f4-e0d893b78011	A report to share with school management for accountability	f	\N	2026-05-11 14:02:35.306758+00
486c2e52-4a27-4bcc-b006-3ccbf9e6224b	319bef5d-5c86-4295-a518-af096d41bce7	'Students were not engaged with the lesson activity'	f	\N	2026-05-11 14:02:35.732357+00
601925a0-5532-41f5-83e1-ca2823d6d31f	319bef5d-5c86-4295-a518-af096d41bce7	'You asked 4 open-ended questions in the first 10 minutes'	t	\N	2026-05-11 14:02:35.732357+00
609c310c-ab77-4979-b7f2-dcddcebab028	319bef5d-5c86-4295-a518-af096d41bce7	'The teacher did not manage classroom behavior effectively'	f	\N	2026-05-11 14:02:35.732357+00
eaf9ba2f-1d30-41cc-b509-10c572aa1606	319bef5d-5c86-4295-a518-af096d41bce7	'Students seemed confused by the instructions given'	f	\N	2026-05-11 14:02:35.732357+00
8cd24fd3-bf81-4e28-9798-9da2e5d5be3d	6e09dbc4-3181-44ec-b64a-8880d72b2701	It takes too long to explain and reduces coaching efficiency	f	\N	2026-05-11 14:02:36.168034+00
b1b5755f-2037-4509-a78d-b4843f5a7102	6e09dbc4-3181-44ec-b64a-8880d72b2701	It triggers defensiveness because it is subjective, not based on facts	t	\N	2026-05-11 14:02:36.168034+00
54249a48-de93-403f-8269-f6be7ee8a97b	6e09dbc4-3181-44ec-b64a-8880d72b2701	It is too positive and does not help teachers identify real weaknesses	f	\N	2026-05-11 14:02:36.168034+00
818d2e9c-6ea9-41d8-9d49-464bce33539b	6e09dbc4-3181-44ec-b64a-8880d72b2701	It relies on the coach's expertise rather than the teacher's knowledge	f	\N	2026-05-11 14:02:36.168034+00
4f935d0b-122e-47dd-9527-660be599b451	15268675-2323-4a79-b8f8-1fbd8f27a962	A school supervisor who observes coaching sessions for quality	f	\N	2026-05-11 14:02:36.583959+00
b0f6fe2a-c39b-4798-b80c-a7f2b54b1545	15268675-2323-4a79-b8f8-1fbd8f27a962	The observation data or evidence that both coach and teacher examine together	t	\N	2026-05-11 14:02:36.583959+00
c0cf80f8-6d15-4425-8f65-53cc3b573725	15268675-2323-4a79-b8f8-1fbd8f27a962	An external coach who mediates disagreements between coach and teacher	f	\N	2026-05-11 14:02:36.583959+00
20635da6-1a1a-4176-993d-909deb479db0	15268675-2323-4a79-b8f8-1fbd8f27a962	The classroom students whose learning outcomes guide the conversation	f	\N	2026-05-11 14:02:36.583959+00
f141c301-9b0d-4fbd-9d3d-c3fdb8293554	42d8f14c-4e7a-42a9-a884-b68467468446	An action that requires significant effort and produces major change quickly	f	\N	2026-05-11 14:02:40.816276+00
30fc8500-ea5a-414d-a8ed-1982cc3cc3d7	42d8f14c-4e7a-42a9-a884-b68467468446	A small, specific change that is masterable in 1 to 2 weeks	t	\N	2026-05-11 14:02:40.816276+00
483a2c6f-d712-4edb-a9e4-9d79cb4c5898	42d8f14c-4e7a-42a9-a884-b68467468446	An action that the coach believes will have the highest impact	f	\N	2026-05-11 14:02:40.816276+00
ca7dbb47-3cde-47da-af53-13912d80a09a	42d8f14c-4e7a-42a9-a884-b68467468446	A multi-step improvement plan developed jointly by coach and teacher	f	\N	2026-05-11 14:02:40.816276+00
3a24ef26-5c1f-470f-876f-919264fcc309	4af81e44-fd75-43e4-88a8-d1651089d5e5	Proof of teacher failure that justifies coaching intervention	f	\N	2026-05-11 14:02:42.196157+00
8f1d14d2-b567-4ca0-92c2-e7927dbe16c0	4af81e44-fd75-43e4-88a8-d1651089d5e5	The foundation for co-creating the next action step	t	\N	2026-05-11 14:02:42.196157+00
e225d2b7-7235-4c84-aa8e-799fe4936572	4af81e44-fd75-43e4-88a8-d1651089d5e5	Documentation to share with school management after each cycle	f	\N	2026-05-11 14:02:42.196157+00
95159a57-3224-4747-b25e-c13071338060	4af81e44-fd75-43e4-88a8-d1651089d5e5	A benchmark to compare teachers' performance against each other	f	\N	2026-05-11 14:02:42.196157+00
6b8aba2d-bf56-4667-9a5c-73f79a3516e6	62323b38-83df-4a1f-a4d5-4c9a75920212	Signing a formal agreement at the start of the coaching relationship	f	\N	2026-05-11 14:02:46.457754+00
7862d451-354b-459a-b829-b7fc6456be39	62323b38-83df-4a1f-a4d5-4c9a75920212	Consistent, predictable actions that align with the partnership principles over time	t	\N	2026-05-11 14:02:46.457754+00
dbe0c621-a331-4308-b71a-83c56afd5e14	62323b38-83df-4a1f-a4d5-4c9a75920212	Sharing positive feedback that builds the teacher's confidence	f	\N	2026-05-11 14:02:46.457754+00
f76e49ae-da33-4b86-b4e8-399bf2162dc7	62323b38-83df-4a1f-a4d5-4c9a75920212	Explaining the coaching model in full detail at the first meeting	f	\N	2026-05-11 14:02:46.457754+00
59126f5a-0b63-4290-8176-fdcb40fe8af7	e8c495e2-a454-4a8e-ab19-f27e989bff99	Being honest with teachers even when the feedback is difficult to hear	f	\N	2026-05-11 14:02:47.782866+00
b5c7dff5-01a4-400a-a28d-758a64056189	e8c495e2-a454-4a8e-ab19-f27e989bff99	Consistently following through on partnership principles even under institutional pressure	t	\N	2026-05-11 14:02:47.782866+00
fab5fbde-dc16-4448-a45e-3ec286da65e0	e8c495e2-a454-4a8e-ab19-f27e989bff99	Maintaining accurate and complete records of all coaching interactions	f	\N	2026-05-11 14:02:47.782866+00
fda0cf25-96c6-434e-98ee-48652e922f5f	e8c495e2-a454-4a8e-ab19-f27e989bff99	Ensuring all coaching activities align with the school's strategic improvement plan	f	\N	2026-05-11 14:02:47.782866+00
29373c13-1553-43e1-a25a-30d6e6534627	7699f95f-1c14-442e-a60b-e67278ad77f8	The Observation Schema (I Do, We Do, You Do)	f	\N	2026-05-11 14:02:40.301433+00
5588627d-bc6c-4af0-898e-d6ddca0c47fe	2e9bfbf1-a6b4-4dee-9a13-8fb26a7fb875	Filtering out negative AI suggestions before sharing them with teachers	f	\N	2026-05-11 14:02:50.738663+00
878846ca-6823-4145-95d4-f048fa474897	2e9bfbf1-a6b4-4dee-9a13-8fb26a7fb875	The coach must validate and contextualise AI suggestions before using them	t	\N	2026-05-11 14:02:50.738663+00
f7f7a2fa-68d4-48a0-aef1-b4336c80340b	2e9bfbf1-a6b4-4dee-9a13-8fb26a7fb875	Using human observation data instead of AI data wherever possible	f	\N	2026-05-11 14:02:50.738663+00
14f35735-4032-43f3-955f-c8d5378c2dde	2e9bfbf1-a6b4-4dee-9a13-8fb26a7fb875	Filtering AI reports through school management before coaches access them	f	\N	2026-05-11 14:02:50.738663+00
7351cf15-a550-4c44-9ca3-8200c782c75e	1823eb89-88b5-400c-b457-b221c3f78120	Technology expertise to interpret the AI's algorithms correctly	f	\N	2026-05-11 14:02:52.050521+00
8a7c8761-c7c3-41bc-a87a-d110a9f82dd1	1823eb89-88b5-400c-b457-b221c3f78120	Context and meaning based on direct classroom observation	t	\N	2026-05-11 14:02:52.050521+00
b34060f5-b9d6-4131-b7e5-06046569cf67	1823eb89-88b5-400c-b457-b221c3f78120	Emotional support for teachers who find AI feedback threatening	f	\N	2026-05-11 14:02:52.050521+00
3fbac37b-4a5d-4fbf-b449-c779cb32e317	1823eb89-88b5-400c-b457-b221c3f78120	Independent verification that the AI's data collection was accurate	f	\N	2026-05-11 14:02:52.050521+00
968c98db-082f-400c-a1d3-5c1cc3a3ae19	85e7ad94-ee2d-4a47-8bca-2771f7b86d61	Independent Practice	f	\N	2026-05-11 14:02:55.980912+00
2684188a-97da-4069-b441-eb150c243b2c	85e7ad94-ee2d-4a47-8bca-2771f7b86d61	Guided Practice	t	\N	2026-05-11 14:02:55.980912+00
dde2c2ad-8c84-4817-918b-28dce6a6b638	85e7ad94-ee2d-4a47-8bca-2771f7b86d61	Direct Instruction	f	\N	2026-05-11 14:02:55.980912+00
b41980ce-5285-42ec-8e6d-7e8ad95a76a8	85e7ad94-ee2d-4a47-8bca-2771f7b86d61	Formative Assessment	f	\N	2026-05-11 14:02:55.980912+00
405a8d35-5008-4a91-b125-d44d439dac8f	e1b7725b-e2c5-4521-a884-72b24b50b9e8	Measuring teacher quality and performance objectively	f	\N	2026-05-11 14:02:57.403375+00
3a72cbc3-1997-4f33-8281-2085458d934e	e1b7725b-e2c5-4521-a884-72b24b50b9e8	Describing lesson structure to spark reflective dialogue	t	\N	2026-05-11 14:02:57.403375+00
9b94c080-80f9-4037-a04f-d275dc9dadff	e1b7725b-e2c5-4521-a884-72b24b50b9e8	Prescribing the correct ratio of teaching phases for each lesson	f	\N	2026-05-11 14:02:57.403375+00
2d294596-89db-478d-87d8-b8ac4fd6643f	e1b7725b-e2c5-4521-a884-72b24b50b9e8	Comparing lesson structure across teachers for management reports	f	\N	2026-05-11 14:02:57.403375+00
d0c62bf7-71be-4914-a5d1-0a29b3071df3	1c20a9c4-996a-4935-9957-ecc3b6d43ed1	Ignoring Problems	f	\N	2026-05-13 08:42:52.960966+00
cd51cf09-22b7-44e1-a09c-880cba14b72f	c4bdadbe-5274-4e68-a285-e77314c68cdd	Large pedagogical theories	f	\N	2026-05-13 08:42:53.846557+00
25c08f6b-51d5-4836-a22b-6efa44d9a861	c4bdadbe-5274-4e68-a285-e77314c68cdd	Micro-moves that make a lesson run smoothly (e.g., signals, specific questions)	t	\N	2026-05-13 08:42:53.846557+00
cafe9acb-bb3e-4987-a2bc-dbf0bb4362ca	c4bdadbe-5274-4e68-a285-e77314c68cdd	Using a new computer system	f	\N	2026-05-13 08:42:53.846557+00
ad8b70ed-2d63-47c2-896b-ef2d6b08a8c3	c4bdadbe-5274-4e68-a285-e77314c68cdd	Student name memorization	f	\N	2026-05-13 08:42:53.846557+00
d02a6de7-7250-44d2-99e9-a6bb2730d1b4	ff2600cc-ca90-4fcb-b20b-c21325242ba1	Complexity	f	\N	2026-05-13 08:42:54.734917+00
c1863eb9-b92d-4a2e-8769-c20876e36f53	ff2600cc-ca90-4fcb-b20b-c21325242ba1	Obsolescence as an external tool (becoming an internal habit for the teacher)	t	\N	2026-05-13 08:42:54.734917+00
6ed0044d-84c7-43e8-b8c2-c1609aa2c844	ff2600cc-ca90-4fcb-b20b-c21325242ba1	Use in annual performance reviews	f	\N	2026-05-13 08:42:54.734917+00
7c26c817-767e-48fe-9e7f-f56266c8725e	ff2600cc-ca90-4fcb-b20b-c21325242ba1	Expansion into 10 loops	f	\N	2026-05-13 08:42:54.734917+00
ae62b956-9d4a-44bc-b79d-348dec143ee9	3e962a17-5e70-42a9-86ad-0d23c00eedcb	It proves the coach was present for the full lesson	f	\N	2026-05-11 14:02:37.012581+00
934800ef-7b82-4da8-92dd-604e9e28f6a8	3e962a17-5e70-42a9-86ad-0d23c00eedcb	It provides an objective, verifiable timeline for teacher reflection	t	\N	2026-05-11 14:02:37.012581+00
b7eec269-3991-4eb3-b9c7-b7de6dd46e97	3e962a17-5e70-42a9-86ad-0d23c00eedcb	It demonstrates that the coach is thorough and detail-oriented	f	\N	2026-05-11 14:02:37.012581+00
3762ea93-750a-4906-99b1-8ce631404fdc	3e962a17-5e70-42a9-86ad-0d23c00eedcb	It helps calculate the percentage of time spent in each lesson phase	f	\N	2026-05-11 14:02:37.012581+00
a73936a4-4d8c-4407-b945-8be4c58bd121	8ddcf7bf-fcfc-4a7f-b109-e51ac593b11d	Completing all the paperwork for the coaching cycle	f	\N	2026-05-11 14:02:41.343674+00
ff4dad6a-7420-4e97-923e-c37e98065ae5	8ddcf7bf-fcfc-4a7f-b109-e51ac593b11d	Returning in 2 weeks to observe evidence of the agreed action step	t	\N	2026-05-11 14:02:41.343674+00
3d48f489-7b3a-4087-91b6-8520e9785fc0	8ddcf7bf-fcfc-4a7f-b109-e51ac593b11d	Ending the coaching relationship once the teacher has improved	f	\N	2026-05-11 14:02:41.343674+00
434c0628-99ac-4b7f-9571-1fc29362cf8d	8ddcf7bf-fcfc-4a7f-b109-e51ac593b11d	Writing a final report summarizing the coaching cycle outcomes	f	\N	2026-05-11 14:02:41.343674+00
f53b83c0-7487-400f-95af-4ac0e00c0120	9a93cd0b-f016-44da-abc2-14e348c96289	The coach improving their observation and feedback skills	f	\N	2026-05-11 14:02:42.635188+00
c77f71f6-bcbc-4e60-8f6d-3bb482c0173c	9a93cd0b-f016-44da-abc2-14e348c96289	Iterating and adjusting the action step based on new evidence from the classroom	t	\N	2026-05-11 14:02:42.635188+00
26309d6f-df11-4b85-80e7-ca9a6f1afaaf	9a93cd0b-f016-44da-abc2-14e348c96289	Improving the teacher's attitude and motivation toward change	f	\N	2026-05-11 14:02:42.635188+00
1ad2cfa1-1b42-43d5-b3d2-ecf3b46bed29	9a93cd0b-f016-44da-abc2-14e348c96289	Improving test scores through targeted exam preparation strategies	f	\N	2026-05-11 14:02:42.635188+00
32ab890e-0ce2-49b8-bd6f-8e6f3fab2482	ce35679e-28e1-4255-b924-82bb50a34494	Observation, Feedback, Action, Reflection	f	\N	2026-05-11 14:02:45.429452+00
5e85ef22-8029-44f6-99a4-d902932d0776	ce35679e-28e1-4255-b924-82bb50a34494	Trust, Confidentiality, Accountability, Integrity	t	\N	2026-05-11 14:02:45.429452+00
98dc5b7a-26db-4b87-aa78-d0e7209283ba	ce35679e-28e1-4255-b924-82bb50a34494	Equality, Choice, Voice, Dialogue	f	\N	2026-05-11 14:02:45.429452+00
768aeda0-a4d8-4b40-bbfd-06171a2a9b17	ce35679e-28e1-4255-b924-82bb50a34494	Planning, Observing, Analysing, Supporting	f	\N	2026-05-11 14:02:45.429452+00
172c2015-c47f-4475-9cf4-cf86e11bc3fa	9d0d86c9-2364-4a44-b93b-34dffc21b9e5	The coach being accountable to the principal for teacher improvement	f	\N	2026-05-11 14:02:46.884588+00
38d2e90f-839d-4328-a189-cdb8a7800986	9d0d86c9-2364-4a44-b93b-34dffc21b9e5	Both coach and teacher being accountable to their agreed growth goals	t	\N	2026-05-11 14:02:46.884588+00
e17a80d4-bdcf-414d-af7e-043f25ecfb83	9d0d86c9-2364-4a44-b93b-34dffc21b9e5	Teachers being accountable to complete all assigned coaching tasks	f	\N	2026-05-11 14:02:46.884588+00
d7c2acb1-ffde-415b-ba83-e919b97754c0	9d0d86c9-2364-4a44-b93b-34dffc21b9e5	The coach being accountable to report accurate data to school management	f	\N	2026-05-11 14:02:46.884588+00
3cae7859-906a-4df6-82e4-5d5498a6f6f3	c040a263-b790-45f5-aaf4-57ebd86ab6e0	Accuracy? Reliability? Evidence?	f	\N	2026-05-11 14:02:51.198448+00
0bf21232-d692-4b77-b0b7-4342d89eb781	c040a263-b790-45f5-aaf4-57ebd86ab6e0	Context? Bias? Partnership?	t	\N	2026-05-11 14:02:51.198448+00
f58011ea-6d21-456b-9b76-402854097aeb	c040a263-b790-45f5-aaf4-57ebd86ab6e0	Data? Pattern? Trend?	f	\N	2026-05-11 14:02:51.198448+00
65d74578-5adc-4bc4-9ec8-d28f8313e8ca	c040a263-b790-45f5-aaf4-57ebd86ab6e0	Observation? Analysis? Action?	f	\N	2026-05-11 14:02:51.198448+00
7f51e88f-5c60-4c8b-8541-52c120944f8a	df97db95-fc78-4296-a6b7-9209a2172bc8	Because deficit framing leads to overly positive feedback that masks real problems	f	\N	2026-05-11 14:02:52.482998+00
da2185d7-5031-4e3a-9f22-356f3dbe001d	df97db95-fc78-4296-a6b7-9209a2172bc8	Because AI often focuses only on what is wrong rather than identifying growth opportunities	t	\N	2026-05-11 14:02:52.482998+00
393cfaf6-57de-40ae-9b27-3f6704bab867	df97db95-fc78-4296-a6b7-9209a2172bc8	Because deficit framing makes the AI more likely to produce inaccurate results	f	\N	2026-05-11 14:02:52.482998+00
6d58737d-f638-4749-80c8-aa407993d022	df97db95-fc78-4296-a6b7-9209a2172bc8	Because teachers prefer positive framing and will disengage from negative AI feedback	f	\N	2026-05-11 14:02:52.482998+00
f45df2ee-7139-4a24-a828-a89fde402340	a00748ae-8d0b-41ca-ba63-a75203292b29	To give students a grade at the end of each lesson activity	f	\N	2026-05-11 14:02:56.403313+00
6600a0ac-0a60-459e-ad85-28ac4386f489	a00748ae-8d0b-41ca-ba63-a75203292b29	To gather real-time data that allows the teacher to decide whether to pivot or proceed	t	\N	2026-05-11 14:02:56.403313+00
f6e2dbdd-5183-4005-8394-653e328a7b91	a00748ae-8d0b-41ca-ba63-a75203292b29	To provide evidence for coaching reports shared with school management	f	\N	2026-05-11 14:02:56.403313+00
c64efc95-c75c-45a7-8e0c-f8bddec790a3	a00748ae-8d0b-41ca-ba63-a75203292b29	To measure how much time was spent on independent practice in the lesson	f	\N	2026-05-11 14:02:56.403313+00
fb377df4-26c5-4296-bca0-3caf2902e8d1	6989817f-47e3-4428-a187-75b604a17bbe	The teacher moves from I Do to We Do at the planned time	f	\N	2026-05-11 14:02:57.823335+00
a6a72acc-2324-4c8f-afad-e6f3276e6669	6989817f-47e3-4428-a187-75b604a17bbe	The teacher changes instruction based on student feedback from a CFU	t	\N	2026-05-11 14:02:57.823335+00
8b463529-4db5-4c61-943d-c9a698a935cc	6989817f-47e3-4428-a187-75b604a17bbe	A student asks an unexpected question that changes the lesson direction	f	\N	2026-05-11 14:02:57.823335+00
ec2f10b7-61eb-47e3-b908-794368af7a11	6989817f-47e3-4428-a187-75b604a17bbe	The coach suggests a change in lesson structure during post-observation dialogue	f	\N	2026-05-11 14:02:57.823335+00
95a8ad6a-6a01-41c1-8153-18b66b4d6254	d8a65e3d-3827-44ab-828b-e2614d94abb4	Too long	f	\N	2026-05-13 08:42:53.424335+00
4307178e-4fd9-44f7-b369-3e03c142fed2	d8a65e3d-3827-44ab-828b-e2614d94abb4	A teacher-behavior script instead of an anticipatory student-response map	t	\N	2026-05-13 08:42:53.424335+00
a4583097-dae8-4b17-8140-11fee29775cd	d8a65e3d-3827-44ab-828b-e2614d94abb4	Handwritten instead of typed	f	\N	2026-05-13 08:42:53.424335+00
139bdc89-6be8-4fc9-b27b-766927678b85	d8a65e3d-3827-44ab-828b-e2614d94abb4	Not approved by the Principal	f	\N	2026-05-13 08:42:53.424335+00
45ac2d2a-8a9a-43c8-afac-b647e4ab3c97	f5146881-3c15-40a1-a13c-de6066401540	Coaching unnecessary	f	\N	2026-05-13 08:42:54.288176+00
d46fbb30-c4ea-4985-88e7-9ed07bbea145	f5146881-3c15-40a1-a13c-de6066401540	Simultaneous delivery and monitoring structurally impossible	t	\N	2026-05-13 08:42:54.288176+00
dc114358-25f2-467f-a954-6bc7baafc7c7	f5146881-3c15-40a1-a13c-de6066401540	Teachers lazy	f	\N	2026-05-13 08:42:54.288176+00
d1e71ae0-b0b1-42a6-a712-cd99106ec2ea	f5146881-3c15-40a1-a13c-de6066401540	Data collection easy	f	\N	2026-05-13 08:42:54.288176+00
12af72d0-a58d-41f7-a0fa-c0f013f8602c	e329215c-4afd-42aa-8474-9bd593c22dd8	Name the move first	f	\N	2026-05-13 08:42:55.174642+00
08c2321b-6342-4b37-ac64-26314f7d8518	e329215c-4afd-42aa-8474-9bd593c22dd8	Diagnose the loop first, then name the move	t	\N	2026-05-13 08:42:55.174642+00
fc409683-940d-44ab-a28f-4f595b75e76a	e329215c-4afd-42aa-8474-9bd593c22dd8	Tell the Principal about the gap	f	\N	2026-05-13 08:42:55.174642+00
09bb9e4e-2546-4326-b471-4ac316725015	e329215c-4afd-42aa-8474-9bd593c22dd8	Give the teacher a generic strategy	f	\N	2026-05-13 08:42:55.174642+00
2ebbfe93-ef94-4e81-94c9-b843d54a61cc	7e6c56a9-a073-4677-9b2a-0cbf4d9b6b10	Evaluator	f	\N	2026-05-13 08:43:13.534752+00
e083c3e6-2295-4dcd-b533-7551caa5955c	7e6c56a9-a073-4677-9b2a-0cbf4d9b6b10	Co-Pilot looking for progress	t	\N	2026-05-13 08:43:13.534752+00
e49f0d0b-53a8-418a-b568-c02b0f6f4c78	7e6c56a9-a073-4677-9b2a-0cbf4d9b6b10	Subject Matter Expert	f	\N	2026-05-13 08:43:13.534752+00
6710b85a-2ac5-4d8a-ae17-f1908fd4305d	7e6c56a9-a073-4677-9b2a-0cbf4d9b6b10	Administrative Assistant	f	\N	2026-05-13 08:43:13.534752+00
9bf5c551-cbb6-467e-8a16-6f69a089778b	8175f4c5-e917-42f7-ba23-fbe1850a9c87	'You did not use the transition we planned'	f	\N	2026-05-13 08:43:14.60291+00
87638d2e-10cf-4eff-a1e1-167fc6bfdcdc	8175f4c5-e917-42f7-ba23-fbe1850a9c87	'Why is the class still noisy?'	f	\N	2026-05-13 08:43:14.60291+00
bb0969d6-f549-4195-a484-283ee586acbc	8175f4c5-e917-42f7-ba23-fbe1850a9c87	'I noticed the Think-Pair-Share did not happen — what barrier got in the way?'	t	\N	2026-05-13 08:43:14.60291+00
093b17b9-a523-4a85-8d82-fb7b7f325d66	8175f4c5-e917-42f7-ba23-fbe1850a9c87	'The Principal will be unhappy with this lesson'	f	\N	2026-05-13 08:43:14.60291+00
77a9ed48-d47a-4d4c-b337-98b8cef82d22	8d261442-91e4-40b3-88a2-51a6626a020f	Find faults	f	\N	2026-05-13 08:43:15.676892+00
96f3f4cd-c210-476b-a8a4-670b624b5942	8d261442-91e4-40b3-88a2-51a6626a020f	See if the strategy is working and help the teacher 'Pivot' if needed	t	\N	2026-05-13 08:43:15.676892+00
2a6296a4-c980-403f-8255-6a66dcc2d7bb	8d261442-91e4-40b3-88a2-51a6626a020f	Fill out the final report for the District	f	\N	2026-05-13 08:43:15.676892+00
a68fb24c-ba55-4caa-b40e-7959e1927872	8d261442-91e4-40b3-88a2-51a6626a020f	Give the students a test	f	\N	2026-05-13 08:43:15.676892+00
07b5e3d9-cf1f-4f33-bf55-f79c2715812a	d2909b7d-3324-4434-954a-bcb94c88d8f7	Arrives on time	f	\N	2026-05-13 08:43:18.589408+00
b8c581e8-ff91-4a77-89bb-dbcf85ae8dc6	d2909b7d-3324-4434-954a-bcb94c88d8f7	Does not slip back into 'Inspector Mode' or unsolicited advice	t	\N	2026-05-13 08:43:18.589408+00
4b4bb520-182b-40c3-8c29-1b3158d5bf87	d2909b7d-3324-4434-954a-bcb94c88d8f7	Follows the school's dress code	f	\N	2026-05-13 08:43:18.589408+00
9dc7d25a-b508-48ed-942b-d8c4f8a66130	d2909b7d-3324-4434-954a-bcb94c88d8f7	Grades the students accurately	f	\N	2026-05-13 08:43:18.589408+00
ca85103b-4d6c-43b7-8e66-4abd24927a34	ca4dc07a-516e-435c-86ca-a49c6d4942df	Provided helpful feedback	f	\N	2026-05-13 08:43:19.47917+00
e4a3f9ec-439d-4860-b5b0-3f3c77966fee	ca4dc07a-516e-435c-86ca-a49c6d4942df	Breached the Protocol Guardrail	t	\N	2026-05-13 08:43:19.47917+00
7639e338-7d85-455f-b995-c278e8d8e7d4	ca4dc07a-516e-435c-86ca-a49c6d4942df	Followed the Impact Cycle	f	\N	2026-05-13 08:43:19.47917+00
0fa980ca-1edc-4c58-a612-69b27bd47ca9	6b9a9abf-96bb-47ed-9690-08181ce6d463	Opposite the teacher to maintain a professional, formal distance	f	\N	2026-05-11 14:02:37.46803+00
2aa474e2-8f06-42bb-a768-0ec06da255c1	6b9a9abf-96bb-47ed-9690-08181ce6d463	Side-by-side with the teacher to examine data together as equals	t	\N	2026-05-11 14:02:37.46803+00
61bc0017-0877-4cb6-a55e-fba3faa4f445	6b9a9abf-96bb-47ed-9690-08181ce6d463	At the head of the table to establish a leadership posture	f	\N	2026-05-11 14:02:37.46803+00
8569e682-b718-4b8c-9d86-a55be6ab75fb	6b9a9abf-96bb-47ed-9690-08181ce6d463	At the back of the room during the lesson, then at the front for debrief	f	\N	2026-05-11 14:02:37.46803+00
12df4567-0e61-4aba-9e74-045aaf4e439e	7699f95f-1c14-442e-a60b-e67278ad77f8	The 7 Partnership Principles	f	\N	2026-05-11 14:02:40.301433+00
00a8f6d1-e485-47bc-a7d0-05c72aae6b7f	7699f95f-1c14-442e-a60b-e67278ad77f8	The Impact Cycle (Identify, Learn, Improve)	t	\N	2026-05-11 14:02:40.301433+00
31e107e7-890d-4cdc-b47c-35e3546dedf8	7699f95f-1c14-442e-a60b-e67278ad77f8	The PEERS Goal framework	f	\N	2026-05-11 14:02:40.301433+00
0e730ffc-4d08-464e-add4-6c048ea544eb	01c34970-d9d2-48dc-8b07-8482fbc5b9f4	The coach, based on what the evidence shows is most needed	f	\N	2026-05-11 14:02:41.763267+00
191d1eed-a225-4fa2-97f5-2bf927eec657	01c34970-d9d2-48dc-8b07-8482fbc5b9f4	The teacher, based on their own interpretation of the data	t	\N	2026-05-11 14:02:41.763267+00
40489eea-e444-499e-9a75-ad7be4f0b764	01c34970-d9d2-48dc-8b07-8482fbc5b9f4	The head teacher, based on school improvement priorities	f	\N	2026-05-11 14:02:41.763267+00
92e7324f-4618-4e31-9ef8-e520ef0cc4c3	01c34970-d9d2-48dc-8b07-8482fbc5b9f4	Both coach and teacher together, with equal input into the decision	f	\N	2026-05-11 14:02:41.763267+00
aaeadb63-24ee-45af-b9f6-62853cc23276	68f952ee-4019-488b-b868-70d1cf2a7202	The teacher becomes more open because the pressure is released	f	\N	2026-05-11 14:02:46.037017+00
65cc7798-7cbc-4404-9cdc-1b28e1325a6b	68f952ee-4019-488b-b868-70d1cf2a7202	The coaching relationship 'dies' and teachers close off from honest dialogue	t	\N	2026-05-11 14:02:46.037017+00
bb8ec081-fc9e-4518-a28d-0e29ca4e7c52	68f952ee-4019-488b-b868-70d1cf2a7202	The head teacher can use the information to support the teacher's growth	f	\N	2026-05-11 14:02:46.037017+00
697b64b6-3516-4746-9ab4-0e8a54a803a7	68f952ee-4019-488b-b868-70d1cf2a7202	The coach becomes more trusted because they were transparent	f	\N	2026-05-11 14:02:46.037017+00
45c87e93-a756-4995-a07b-d1e01e3c8a59	01d317bc-dfa8-4cc4-aedf-581cf4af3d34	Share a summary while removing the teacher's name for anonymity	f	\N	2026-05-11 14:02:47.326036+00
09de5156-ec74-4608-a959-f81a2bdab4dd	01d317bc-dfa8-4cc4-aedf-581cf4af3d34	Hold the confidentiality boundary and offer school-wide aggregate trends instead	t	\N	2026-05-11 14:02:47.326036+00
556e75f4-47c5-44c2-a6d4-c2bf63b9ff8f	01d317bc-dfa8-4cc4-aedf-581cf4af3d34	Ask the teacher for permission before sharing anything with the principal	f	\N	2026-05-11 14:02:47.326036+00
c1f289cd-d59e-4e11-bb76-4d074ca44bfe	01d317bc-dfa8-4cc4-aedf-581cf4af3d34	Share the notes only if the principal has a legitimate improvement goal	f	\N	2026-05-11 14:02:47.326036+00
b34f8f37-8606-4bac-9685-8b1c2174c99f	266b79f0-22ef-45c2-b982-752d9eb7751e	AI tools that cannot be translated into local languages like Urdu	f	\N	2026-05-11 14:02:51.625112+00
0a79350f-1088-4380-8aa1-abae8914fc3d	266b79f0-22ef-45c2-b982-752d9eb7751e	Suggestions that do not fit the local classroom context or cultural values	t	\N	2026-05-11 14:02:51.625112+00
75616e89-1367-41b5-a6b9-fbad744207b3	266b79f0-22ef-45c2-b982-752d9eb7751e	AI systems that ignore the cultural background of individual students	f	\N	2026-05-11 14:02:51.625112+00
cb63568b-ffac-4ae9-8b3c-49b88a287791	266b79f0-22ef-45c2-b982-752d9eb7751e	Coaching tools that work better in urban settings than rural ones	f	\N	2026-05-11 14:02:51.625112+00
8cda6f76-1cc6-4bc1-9320-027d09419e1b	1077c779-cd3b-44bf-8347-05899aa19db4	Share it with the teacher exactly as the AI stated and ask for an explanation	f	\N	2026-05-11 14:02:52.903542+00
f6a6f437-ce64-4099-b8c6-8a38673cdcd0	1077c779-cd3b-44bf-8347-05899aa19db4	Override the AI label and seek to understand the human context behind the data	t	\N	2026-05-11 14:02:52.903542+00
37ec5756-cc40-4e63-a165-edeb37999e3e	1077c779-cd3b-44bf-8347-05899aa19db4	Report the AI finding to the head teacher since professionalism is a serious concern	f	\N	2026-05-11 14:02:52.903542+00
e89e9f10-4ece-46ba-a645-5f865a7bb782	1077c779-cd3b-44bf-8347-05899aa19db4	Ask the teacher to respond in writing to the AI's assessment	f	\N	2026-05-11 14:02:52.903542+00
481c4be8-cb03-4887-b899-8ad8f1f370c1	4ad6cfea-a368-4a55-a023-7c32d30f1e5d	Students working independently to demonstrate mastery	f	\N	2026-05-11 14:02:55.567146+00
c286511b-baee-4f70-ae59-dd37bf66a2a4	4ad6cfea-a368-4a55-a023-7c32d30f1e5d	Teacher modeling and direct instruction for students to observe	t	\N	2026-05-11 14:02:55.567146+00
2dbce6d8-b156-4e52-bc2f-f588c2445107	4ad6cfea-a368-4a55-a023-7c32d30f1e5d	Guided practice where both teacher and students participate together	f	\N	2026-05-11 14:02:55.567146+00
88ab0025-47cd-4ff6-b8b1-e1c02c5a242a	4ad6cfea-a368-4a55-a023-7c32d30f1e5d	Check for Understanding activities to assess student learning	f	\N	2026-05-11 14:02:55.567146+00
2c32b883-bf3c-4f30-a22f-6edfee95a866	8a428520-75c0-40ae-a371-ed61a58b8a18	The teacher demonstrates the skill or concept to the class	f	\N	2026-05-11 14:02:56.893187+00
936d7a2f-efdb-4c99-949b-7d23db4a5c9e	8a428520-75c0-40ae-a371-ed61a58b8a18	Students practice independently to demonstrate mastery without teacher support	t	\N	2026-05-11 14:02:56.893187+00
9b08f9fb-4656-49e7-ad3d-b90c1f679dcb	8a428520-75c0-40ae-a371-ed61a58b8a18	Both teacher and students collaborate on a shared task	f	\N	2026-05-11 14:02:56.893187+00
08f35dbe-4fbe-408d-999f-51c5ac47c6e4	8a428520-75c0-40ae-a371-ed61a58b8a18	The teacher checks whether students understood the previous explanation	f	\N	2026-05-11 14:02:56.893187+00
b91c0c82-e15c-4f20-8a8c-0855d7ff9706	e1f5422f-abeb-4d90-9264-f94c275b3888	The coach forgets to visit	f	\N	2026-05-13 08:43:13.073036+00
1bf08ba0-48c1-46ec-a5c9-859a8e3ca73d	e1f5422f-abeb-4d90-9264-f94c275b3888	A great conversation happens but nothing changes in the classroom	t	\N	2026-05-13 08:43:13.073036+00
35c127c9-7c29-4edf-a353-b1d9569ac21b	e1f5422f-abeb-4d90-9264-f94c275b3888	The students are absent	f	\N	2026-05-13 08:43:13.073036+00
4afd2152-1e21-4817-9f27-b587b92e1efe	e1f5422f-abeb-4d90-9264-f94c275b3888	The school building is damaged	f	\N	2026-05-13 08:43:13.073036+00
cb3732b7-55d3-490b-96d9-462b6f3a48b8	cea69bd5-af6c-40bc-a8bc-bc06e960197c	Identify and Learn	f	\N	2026-05-13 08:43:13.975612+00
607091a8-8934-42d7-a430-aad8295d97b5	cea69bd5-af6c-40bc-a8bc-bc06e960197c	Learn and Improve	t	\N	2026-05-13 08:43:13.975612+00
f9e4a5f5-9672-4551-a225-75e130bf592a	cea69bd5-af6c-40bc-a8bc-bc06e960197c	Improve and Identify	f	\N	2026-05-13 08:43:13.975612+00
2647e3ca-b0c6-43cf-b7d1-3a1b2a24c014	cea69bd5-af6c-40bc-a8bc-bc06e960197c	Planning and Audit	f	\N	2026-05-13 08:43:13.975612+00
c18f7eb4-d0af-4594-864e-39c3a724a213	a135be5a-cc68-47c4-90d4-0728d2eb23d4	Broad and complex	f	\N	2026-05-13 08:43:15.210936+00
c45f561c-317e-420a-982e-3ec263fbf140	a135be5a-cc68-47c4-90d4-0728d2eb23d4	Bite-sized, observable, and teacher-chosen	t	\N	2026-05-13 08:43:15.210936+00
aaed83ab-b9bc-4426-ba0c-fa1d86397ec9	a135be5a-cc68-47c4-90d4-0728d2eb23d4	Determined solely by the coach	f	\N	2026-05-13 08:43:15.210936+00
2484644a-4628-4e3b-b108-da8c11e5f69c	a135be5a-cc68-47c4-90d4-0728d2eb23d4	Based on the annual appraisal form	f	\N	2026-05-13 08:43:15.210936+00
93b197ac-fb05-4f3a-a50a-a6dc11532c06	5ba71a7e-777e-450d-a666-833ed562ed6d	Confirming the coach's authority	f	\N	2026-05-13 08:43:19.029766+00
83e5443c-add8-4229-9534-d9750509684b	5ba71a7e-777e-450d-a666-833ed562ed6d	Using objective evidence to confirm the teacher's professional growth	t	\N	2026-05-13 08:43:19.029766+00
0218aeba-8343-44e0-958f-ad379fbe3cfa	5ba71a7e-777e-450d-a666-833ed562ed6d	Confirming the teacher's salary	f	\N	2026-05-13 08:43:19.029766+00
96abe88c-fdb6-421a-a981-3598469b86f0	5ba71a7e-777e-450d-a666-833ed562ed6d	Confirming the Principal's opinion	f	\N	2026-05-13 08:43:19.029766+00
a8cacfe9-dd81-48f6-924a-60f035433be1	284e57cf-5d2f-48b0-bfa0-ff34c3f6489c	Pass, Fail, Retry, Quit	f	\N	2026-05-13 08:43:19.934376+00
e538e756-4fa6-418c-af3e-5cff346b985f	284e57cf-5d2f-48b0-bfa0-ff34c3f6489c	Modify, Switch, Stay the Course, Re-identify	t	\N	2026-05-13 08:43:19.934376+00
cb329d75-1976-4ef2-8181-f34ee7c760af	284e57cf-5d2f-48b0-bfa0-ff34c3f6489c	Plan, Teach, Observe, Report	f	\N	2026-05-13 08:43:19.934376+00
2e4d7797-13d3-4a15-aac0-00e3996aead2	284e57cf-5d2f-48b0-bfa0-ff34c3f6489c	Lecture, Practical, Homework, Test	f	\N	2026-05-13 08:43:19.934376+00
94414b34-45b1-4cb6-b226-f87ff4322493	663af793-72ec-4cce-b70e-134dc23d9e19	The coach's opinion	f	\N	2026-05-13 08:43:20.950324+00
d0a51d04-7cea-4722-84ab-426c605c8680	663af793-72ec-4cce-b70e-134dc23d9e19	Objective student evidence (the 'Mirror')	t	\N	2026-05-13 08:43:20.950324+00
61befb34-fbc5-4d6b-8af3-53094ee9f2d4	663af793-72ec-4cce-b70e-134dc23d9e19	General impressions	f	\N	2026-05-13 08:43:20.950324+00
555386d9-3d45-428e-82fd-4368896ca19d	663af793-72ec-4cce-b70e-134dc23d9e19	Subjective judgments	f	\N	2026-05-13 08:43:20.950324+00
89b5f055-8669-4d38-b5ea-7acd95f2d56d	ea2d4750-8c08-4bd8-a449-e8db0abf58b2	Follow AI suggestions without change	f	\N	2026-05-13 08:43:23.869536+00
a397711a-5823-4d95-882e-5105fbe899d4	ea2d4750-8c08-4bd8-a449-e8db0abf58b2	Adjust strategies to fit constraints like large class sizes or limited resources	t	\N	2026-05-13 08:43:23.869536+00
52aaa44f-e21a-4d60-9d7e-1dbe04d6ee57	ea2d4750-8c08-4bd8-a449-e8db0abf58b2	Ignore the classroom environment	f	\N	2026-05-13 08:43:23.869536+00
a54029c3-61e4-4398-97c3-b2a07d206c52	ea2d4750-8c08-4bd8-a449-e8db0abf58b2	Tell the teacher to buy their own resources	f	\N	2026-05-13 08:43:23.869536+00
dcb6404a-d0ef-4ace-8276-ddaaf31c3623	f9ac7b07-4a36-47dd-991a-74e0b5fc1200	AI is always wrong	f	\N	2026-05-13 08:43:24.778434+00
e24fa0b9-1891-449a-9a3b-be0447c8b8da	f9ac7b07-4a36-47dd-991a-74e0b5fc1200	The coach must contextualize data to make it realistic for the teacher	t	\N	2026-05-13 08:43:24.778434+00
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiles (id, phone, full_name, persona, baseline_score, baseline_completed, endline_score, endline_completed, created_at, updated_at, endline_attempt_count, baseline_attempt_count, weak_modules, region, teacher_ids, school_id, qualifications, experiences, sub_region, user_id, avatar_url, bio, role, is_active, email) FROM stdin;
66e67e8e-0ed9-4850-acb4-095a727a7f2e	\N	\N	E	37	t	\N	f	\N	2026-06-16 07:23:04.483488	0	1	["Module 2", "Module 3", "Module 4", "Module 5", "Module 6"]	islamabad	[]	ICB	[]	[]	Urban-I	66e67e8e-0ed9-4850-acb4-095a727a7f2e	\N	\N	learner	t	\N
3b232875-70d9-4d70-a8a7-dc8a771ad42f	03228787876	JD Vence	B	73	t	\N	f	2026-04-15 06:42:35.504369	2026-04-15 06:54:46.609303	0	1	["Module 2", "Module 3", "Module 5"]	south	["test"]	Taleemabad by orenda	[]	[]	null	3b232875-70d9-4d70-a8a7-dc8a771ad42f	\N	\N	learner	t	\N
faea2f79-4001-499d-a315-08c0094106f5	test10@test.com	null	null	\N	f	\N	f	2026-04-16 10:22:58.138742	2026-04-16 10:23:12.999351	0	0	[]	islamabad	["Ahmed Khan", "Fatima Ahmed", "Hassan Ali"]	IMCB I-10/1	[]	[]	null	faea2f79-4001-499d-a315-08c0094106f5	\N	\N	learner	t	\N
40307a9b-d06f-471b-94f8-df432f6b763c	test5@test.com	null	A	83	t	\N	f	2026-04-15 12:26:37.177392	2026-04-15 12:30:47.631851	0	1	["Module 5"]	islamabad	["Ahmed Khan", "Fatima Ahmed", "Hassan Ali"]	IMCB I-10/1	[{"degree": "IT", "degree_type": "Bachelors", "passing_year": "2021"}]	[{"org": "Taleemabad", "current": true, "joining": "2023", "leaving": "", "designation": "Coach"}]	null	40307a9b-d06f-471b-94f8-df432f6b763c	\N	\N	learner	t	\N
7705028c-2da1-4960-b79d-e3a5d69757c7	+923375106516	Noor Faiz	D	63	t	\N	f	2026-04-22 10:06:22.655913	2026-04-23 04:53:16.073181	0	2	["Module 3", "Module 4", "Module 5", "Module 6"]	rawalpindi	["Ahmed Sher", "Imran Fida", "Sulaiman Haroon", "Aina Fareed"]	GGPS Malkot	[{"degree": "Science", "degree_type": "Bachelors", "passing_year": "2023"}]	[]	null	7705028c-2da1-4960-b79d-e3a5d69757c7	\N	\N	learner	t	\N
d867307d-8797-46a6-ab8c-a25363131a2f	+923185901481	Afifa Sultana	B	70	t	\N	f	2026-04-10 06:24:07.888223	2026-04-23 05:51:18.610649	0	1	["Module 2", "Module 4", "Module 5", "Module 6"]	islamabad	["Anum", "Hareem", "Fatima"]	Afifa Sultana	[]	[]	null	d867307d-8797-46a6-ab8c-a25363131a2f	\N	\N	learner	t	\N
9690201a-b4ca-4b02-995a-6d4b9b6eb497	03349978136	sara fatima	A	93	t	\N	f	2026-04-16 10:37:56.150194	2026-04-16 10:46:57.198047	0	1	[]	islamabad	["Areej"]	Nilore	[]	[]	null	9690201a-b4ca-4b02-995a-6d4b9b6eb497	\N	\N	learner	t	\N
24ba8b02-9b78-48c5-86ac-c1dbb8e8df9e	+923334449831	Abdul Waheed	A	97	t	\N	f	2026-04-16 10:37:20.643753	2026-04-16 10:51:12.357093	0	1	[]	islamabad	["Ali"]	IMSB Tarnol	[]	[]	null	24ba8b02-9b78-48c5-86ac-c1dbb8e8df9e	\N	\N	learner	t	\N
9baa44cc-addf-46c4-906e-e9f0cb724ce1	+923045086688	Muhammad Jalal Khan	null	\N	f	\N	f	2026-04-09 12:50:24.441996	2026-04-09 13:00:30.724178	0	0	[]	null	[]	null	[]	[]	null	9baa44cc-addf-46c4-906e-e9f0cb724ce1	\N	\N	admin	t	\N
531e9525-9f03-4a02-81e9-1d4ed5100e38	jalal.khan@taleemabad.com	Jalal Khan	A	80	t	\N	f	2026-04-08 13:09:10.355182	2026-06-15 10:21:40.288628	0	2	["Module 6"]	islamabad	["Ahmed Khan", "Fatima Ahmed", "Hassan Ali"]	IMCB I-10/1	[]	[]	B.K	531e9525-9f03-4a02-81e9-1d4ed5100e38	\N	\N	admin	t	\N
b1239541-be2e-4995-a6d1-4f0f928b280a	03268124122	Muhammad Imran	A	83	t	\N	f	2026-04-24 12:36:01.858941	2026-04-24 16:39:27.196856	0	1	["Module 3", "Module 5", "Module 6"]	islamabad	["Kamran Afzal"]	221	[{"degree": "International Relations", "degree_type": "Bachelors", "passing_year": "2021"}]	[{"org": "Cambridge School System", "current": false, "joining": "2021", "leaving": "2022", "designation": "Science Teacher"}, {"org": "Teach for Pakistan", "current": true, "joining": "2022", "leaving": "2024", "designation": "Teacher"}, {"org": "IMCB Jaba Taili", "current": false, "joining": "2024", "leaving": "Feb 2025", "designation": "EST"}]	null	b1239541-be2e-4995-a6d1-4f0f928b280a	\N	\N	learner	t	\N
bb0be704-5505-44e0-84e7-e52ad63b2b8a	03268124117	Saba Kokab	A	89	t	\N	f	2026-04-25 17:32:41.801875	2026-04-25 17:47:16.101998	0	1	["Module 5", "Module 6"]	islamabad	["Fozia bibi"]	IMS  (I-V) G8/1-3	[]	[]	null	bb0be704-5505-44e0-84e7-e52ad63b2b8a	\N	\N	learner	t	\N
a443269f-d33e-4bed-9e2a-72f21c8981ae	03268124114	Hiba anwer	A	94	t	\N	f	2026-04-25 20:03:58.563553	2026-04-25 20:16:45.492705	0	1	["Module 5", "Module 6"]	islamabad	["Asma bibi", "fozia rehman", "nadia"]	IMCG F8/1	[{"degree": "Mathematics", "degree_type": "Bachelors", "passing_year": "2018"}]	[{"org": "NIETE", "current": true, "joining": "2024-03", "leaving": "", "designation": "COACH"}]	null	a443269f-d33e-4bed-9e2a-72f21c8981ae	\N	\N	learner	t	\N
fa7ce468-50c0-4cbb-a987-2f37e7b5bcc2	1234567890	Test User	D	60	t	\N	f	2026-04-09 13:01:23.727517	2026-04-10 04:04:02.967992	0	1	["Module 2", "Module 3", "Module 4", "Module 5", "Module 6"]	null	[]	null	[]	[]	null	fa7ce468-50c0-4cbb-a987-2f37e7b5bcc2	\N	\N	learner	t	\N
5db42ffe-2880-439e-a675-458380bb26c3	03071740531	Hamza Siddique	D	61	t	\N	f	2026-04-27 09:04:09.759461	2026-04-27 09:20:39.939766	0	1	["Module 2", "Module 3", "Module 4", "Module 5", "Module 6"]	islamabad	["Muhammad Ibrahim", "Mujeeb ud Din"]	\N	[]	[]	null	5db42ffe-2880-439e-a675-458380bb26c3	\N	\N	learner	t	\N
144107da-6639-4965-966a-f15655259f64	zahoorabbas1980@gmail.com	Zahoor Abbas	null	\N	f	\N	f	2026-04-29 08:10:18.036054	2026-04-29 08:15:30.579318	0	0	[]	punjab	["Fatima"]	GPS Dhok Mohri	[]	[]	null	144107da-6639-4965-966a-f15655259f64	\N	\N	learner	t	\N
0119885b-ce04-4a43-a565-c4722ddaca81	test8@test.com	\N	E	70	t	\N	f	2026-04-16 09:49:24.021338	2026-04-30 09:47:15.331079	0	1	["Module 5", "Module 6"]	islamabad	["Ahmed Khan", "Fatima Ahmed", "Hassan Ali"]	IMCB I-10/1	[{"degree": "IT", "degree_type": "Bachelors", "passing_year": "2020"}]	[{"org": "Taleemaabd", "current": true, "joining": "2020-03", "leaving": "", "designation": "Test"}]	null	0119885b-ce04-4a43-a565-c4722ddaca81	\N	\N	learner	t	\N
13a136e1-8412-4ad9-8c33-8d94ffc08c09	zainab.zaheer@niete.edu.pk	Zainab Zaheer	E	44	t	\N	f	2026-04-29 10:48:52.144886	2026-05-04 07:49:47.544375	0	1	["Module 2", "Module 4", "Module 5", "Module 6"]	islamabad	["Saba Ayaz", "Touqir", "bismillah etc"]	IMSG I-X G10/3	[{"degree": "English", "degree_type": "Masters", "passing_year": "2020"}, {"degree": "English Literature", "degree_type": "MPhil", "passing_year": "2025"}]	[{"org": "NIETE", "current": true, "joining": "21 oct 2025", "leaving": "", "designation": "CPD Coach"}, {"org": "TeleTaleem", "current": false, "joining": "3 June 2024", "leaving": "20 Oct 2025", "designation": "English Teacher"}]	null	13a136e1-8412-4ad9-8c33-8d94ffc08c09	\N	\N	learner	t	\N
14115af8-b73f-4569-a218-5c29322d901e	eysha.qadeer@niete.edu.pk	Eysha Qadeer	E	50	t	\N	f	2026-05-06 08:22:36.355383	2026-05-06 08:31:10.859044	0	1	["Module 2", "Module 3", "Module 4", "Module 5", "Module 6"]	islamabad	["Shakeela"]	IMCB F-11/1	[{"degree": "IR", "degree_type": "Bachelors", "passing_year": "2023"}]	[]	null	14115af8-b73f-4569-a218-5c29322d901e	\N	\N	learner	t	\N
99965373-0b4e-47f1-ab34-5b0e274cb662	+923342592801	Muzzammil Patel	null	\N	f	\N	f	2026-04-24 07:32:14.637183	2026-04-24 07:32:33.936889	0	0	[]	islamabad	[]	\N	[]	[]	null	99965373-0b4e-47f1-ab34-5b0e274cb662	\N	\N	learner	t	\N
a6bc0bcd-46fd-4420-bcd2-94738083b143	03268183599	Mubasher Irfan 	A	89	t	\N	f	2026-04-24 12:33:36.252498	2026-04-26 07:25:31.532468	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	a6bc0bcd-46fd-4420-bcd2-94738083b143	\N	\N	learner	t	\N
04be1530-7a2a-43e8-ab6c-2af34b305ece	03268124156	Saaim Asif	A	83	t	\N	f	2026-04-26 04:27:48.678866	2026-04-26 05:02:41.833687	0	1	["Module 3", "Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "Biology", "degree_type": "Masters", "passing_year": "2022"}]	[]	null	04be1530-7a2a-43e8-ab6c-2af34b305ece	\N	\N	learner	t	\N
d1ce5960-9682-4639-b987-be081423f233	test3@test.com	null	null	\N	f	\N	f	2026-04-13 12:00:35.730016	2026-04-13 12:00:35.730016	0	0	[]	null	[]	null	[]	[]	null	d1ce5960-9682-4639-b987-be081423f233	\N	\N	learner	t	\N
2323dfde-9ddf-4320-bcd1-005da244b060	new@test.com	null	null	\N	f	\N	f	2026-04-16 10:02:16.655107	2026-04-16 10:02:26.876619	0	0	[]	islamabad	[]	\N	[]	[]	null	2323dfde-9ddf-4320-bcd1-005da244b060	\N	\N	learner	t	\N
849d6cc7-e42e-42ec-beff-def88c23aa91	03268124105	Saima Jabeen	A	94	t	\N	f	2026-04-24 12:12:14.270374	2026-04-24 12:29:10.919625	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	849d6cc7-e42e-42ec-beff-def88c23aa91	\N	\N	learner	t	\N
4dbf599b-c838-42c0-adb9-75d0bdd78b1d	03228586875	umar don	D	63	t	\N	f	2026-04-10 10:28:07.341153	2026-04-15 06:40:11.087846	0	1	["Module 2", "Module 5", "Module 6"]	central	[]	ICB	[]	[]	null	4dbf599b-c838-42c0-adb9-75d0bdd78b1d	\N	\N	learner	t	\N
1ec99b45-ffe2-45bd-9188-a2958f6a1bdf	0328787876	JD don	null	\N	f	\N	f	2026-04-15 08:10:56.789523	2026-04-15 08:11:32.807922	0	0	[]	south	[]	safsdfs	[]	[]	null	1ec99b45-ffe2-45bd-9188-a2958f6a1bdf	\N	\N	learner	t	\N
98b79eaf-3925-43d2-a069-067296da3d13	3268124116	Hira Abbas	A	100	t	\N	f	2026-04-26 14:37:51.737419	2026-04-26 15:03:21.469142	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	98b79eaf-3925-43d2-a069-067296da3d13	\N	\N	learner	t	\N
1f544b46-9f23-4078-825d-394b19f19f12	test4@test.com	null	null	\N	f	\N	f	2026-04-16 09:31:33.050118	2026-04-16 09:33:14.719639	0	0	[]	islamabad	[]	\N	[]	[]	null	1f544b46-9f23-4078-825d-394b19f19f12	\N	\N	learner	t	\N
ceeb8b93-bd10-4adb-9b71-a5e416cd929b	munira.shah@niete.edu.pk	Munira Shah	A	100	t	\N	f	2026-04-30 10:17:38.713077	2026-05-04 10:47:31.327708	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	ceeb8b93-bd10-4adb-9b71-a5e416cd929b	\N	\N	learner	t	\N
01d8388c-3c39-4518-bd7a-f2c6b9153654	+923215623021	Danish Iqbal	A	94	t	\N	f	2026-04-24 11:10:52.387643	2026-04-26 16:48:47.659777	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	01d8388c-3c39-4518-bd7a-f2c6b9153654	\N	\N	learner	t	\N
9278ba9d-03fd-4a9f-8d0d-3b1b6db9d9a5	test11@test.com	null	null	\N	f	\N	f	2026-04-16 10:23:35.888425	2026-04-16 10:23:43.895301	0	0	[]	islamabad	[]	\N	[]	[]	null	9278ba9d-03fd-4a9f-8d0d-3b1b6db9d9a5	\N	\N	learner	t	\N
aa134f39-2d69-4bca-a4a2-ea4b086f2204	+923165499599	Hasnat Tariq	A	97	t	\N	f	2026-04-16 10:35:35.034924	2026-04-16 10:44:02.283552	0	1	[]	islamabad	[]	\N	[]	[]	null	aa134f39-2d69-4bca-a4a2-ea4b086f2204	\N	\N	learner	t	\N
54b68113-0da9-498d-bac2-35473d6e0449	+923362227374	Anam Masood	B	70	t	\N	f	2026-04-16 10:35:46.668103	2026-04-16 10:45:39.008142	0	1	["Module 2", "Module 3"]	islamabad	[]	\N	[]	[]	null	54b68113-0da9-498d-bac2-35473d6e0449	\N	\N	learner	t	\N
13901dac-7988-4784-be84-5cfebcc1bfeb	03158404687	Tehniat	null	\N	f	\N	f	2026-04-22 09:45:41.984971	2026-04-22 09:50:12.973697	0	1	[]	rawalpindi	[]	\N	[]	[]	null	13901dac-7988-4784-be84-5cfebcc1bfeb	\N	\N	learner	t	\N
583fc16e-2efb-436b-90ff-ef94f34dd93c	03158404788	Sohaib Danish	null	\N	f	\N	f	2026-04-22 09:42:37.56942	2026-04-22 09:51:03.522376	0	1	[]	rawalpindi	[]	\N	[]	[]	null	583fc16e-2efb-436b-90ff-ef94f34dd93c	\N	\N	learner	t	\N
5b6aaf1f-213a-4681-8140-add621eb8b8c	03369333525	Hareem Fatima	A	77	t	\N	f	2026-04-22 09:42:12.410292	2026-04-22 09:58:00.948319	0	1	["Module 2", "Module 5", "Module 6"]	punjab	[]	GPS THATHA KHOKHER	[]	[]	null	5b6aaf1f-213a-4681-8140-add621eb8b8c	\N	\N	learner	t	\N
3e36fe4e-6f53-4343-80ef-c72d021e8975	3345222156	Iffa Maab	null	\N	f	\N	f	2026-04-22 09:46:01.879144	2026-04-22 10:00:34.238351	0	1	[]	rawalpindi	[]	\N	[]	[]	null	3e36fe4e-6f53-4343-80ef-c72d021e8975	\N	\N	learner	t	\N
37aeed86-d7e9-4412-9378-69039bb08566	afifsultana161@gmail.com	null	null	\N	f	\N	f	2026-04-23 06:15:10.415667	2026-04-23 06:21:58.251256	0	2	[]	islamabad	[]	\N	[]	[]	null	37aeed86-d7e9-4412-9378-69039bb08566	\N	\N	learner	t	\N
58424a37-9d59-4763-b1b4-1a31632b1a7b	test2@test.com	null	A	83	t	\N	f	2026-04-10 10:39:15.81521	2026-04-23 07:31:39.832116	0	1	["Module 4", "Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	58424a37-9d59-4763-b1b4-1a31632b1a7b	\N	\N	learner	t	\N
fdb68be8-ed12-42bb-8b27-63b108d44cc0	test6@test.com	null	E	28	t	\N	f	2026-04-16 09:40:58.058323	2026-04-30 10:26:40.041303	0	1	["Module 2", "Module 3", "Module 4", "Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	fdb68be8-ed12-42bb-8b27-63b108d44cc0	\N	\N	learner	t	\N
d0c6450a-e5a4-4516-95a2-7b8caa45ddc8	+923038826029	Toseef ur Rehman 	A	94	t	\N	f	2026-04-24 11:08:42.371444	2026-04-24 11:28:51.436889	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	d0c6450a-e5a4-4516-95a2-7b8caa45ddc8	\N	\N	learner	t	\N
32e0e04c-ef61-49c5-8259-72ab64dc056f	03268124140	Waneza Firdous	A	100	t	\N	f	2026-04-26 15:12:54.820598	2026-05-04 10:47:30.322405	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	32e0e04c-ef61-49c5-8259-72ab64dc056f	\N	\N	learner	t	\N
c51327ba-4d36-4077-87a0-1e7d1eedf743	03007522460	Aleeha Noor	A	94	t	\N	f	2026-04-24 11:39:03.971198	2026-04-24 12:01:33.167771	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	c51327ba-4d36-4077-87a0-1e7d1eedf743	\N	\N	learner	t	\N
6898d375-cdbc-4369-92a0-6ea9647f1e14	03268124113	Nouman Alam 	A	89	t	\N	f	2026-04-24 12:35:15.248351	2026-04-24 12:57:03.366276	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	6898d375-cdbc-4369-92a0-6ea9647f1e14	\N	\N	learner	t	\N
e78ada6f-85bc-4228-b03f-5e6e4b5bf760	03268124128	Mubashar Zia 	A	94	t	\N	f	2026-04-25 22:40:39.919767	2026-05-07 07:02:10.79154	0	1	["Module 5", "Module 6"]	islamabad	["Saima", "Sabah", "Fizhat", "Sania"]	Mubashar Zia 	[]	[]	null	e78ada6f-85bc-4228-b03f-5e6e4b5bf760	\N	\N	learner	t	\N
6e6b7747-dbe9-4453-abb6-1071b9388f24	irumafzal698@gmail.com	Irum Afzal	C	67	t	\N	f	2026-05-07 10:24:54.543053	2026-05-07 10:31:41.845999	0	1	["Module 2", "Module 4", "Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	6e6b7747-dbe9-4453-abb6-1071b9388f24	\N	\N	learner	t	\N
af21c833-ead9-459b-bceb-3e5214e937ca	+923268124148	M. Salman	A	94	t	\N	f	2026-04-24 13:06:51.986817	2026-04-24 13:25:10.521555	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "Molecular Virology", "degree_type": "Masters", "passing_year": "2022"}]	[{"org": "NIETE", "current": true, "joining": "2025-26", "leaving": "", "designation": "CPD Coach"}]	null	af21c833-ead9-459b-bceb-3e5214e937ca	\N	\N	learner	t	\N
bb6fa6c0-9408-4496-b175-121cab8aba36	03268124126	Ashas Khan	A	94	t	\N	f	2026-04-24 13:27:24.674629	2026-04-24 13:43:55.426747	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	bb6fa6c0-9408-4496-b175-121cab8aba36	\N	\N	learner	t	\N
6f60cb23-c16a-442f-9ed0-01cdb3448843	03077740434	Maroof Anwar	A	89	t	\N	f	2026-04-26 03:40:29.85874	2026-04-26 03:59:08.40439	0	1	["Module 5", "Module 6"]	islamabad	[]	Urban 1	[]	[]	null	6f60cb23-c16a-442f-9ed0-01cdb3448843	\N	\N	learner	t	\N
13406b93-309e-49c7-8890-cf5033454865	+923459760407	Waleed Abdullah	A	100	t	\N	f	2026-04-25 04:42:27.902319	2026-04-25 04:57:02.612267	0	1	["Module 5", "Module 6"]	islamabad	[]	735	[]	[]	null	13406b93-309e-49c7-8890-cf5033454865	\N	\N	learner	t	\N
caa29e01-ce00-41f2-94db-60cc9df57ae3	03268124119	Shazmina Sharif 	A	94	t	\N	f	2026-04-25 10:13:19.294037	2026-04-25 10:21:32.080018	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	caa29e01-ce00-41f2-94db-60cc9df57ae3	\N	\N	learner	t	\N
20151d0b-419b-4d82-bc22-dcc670527796	+923094125480	Naveera khan	null	\N	f	\N	f	2026-04-26 17:43:07.674181	2026-04-26 17:43:10.635779	0	0	[]	null	[]	null	[]	[]	null	20151d0b-419b-4d82-bc22-dcc670527796	\N	\N	learner	t	\N
30af1bbb-e866-4780-a0e6-8bce315ba8ac	03268124131	Rida Abbas 	A	100	t	\N	f	2026-04-26 11:30:50.532849	2026-04-26 11:50:15.405618	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "Computer Science", "degree_type": "Masters", "passing_year": "2020"}]	[{"org": "TeachECE (World Bank Group)", "current": false, "joining": "1 December 2022", "leaving": "3 December 2022", "designation": "Teach ECE Observer's Reliability Exam"}, {"org": "TeachECE (World Bank Group)", "current": false, "joining": "1 January 2023", "leaving": "7 January 2023", "designation": "Teach Primary observer's Reliability Exam"}]	null	30af1bbb-e866-4780-a0e6-8bce315ba8ac	\N	\N	learner	t	\N
2848c56f-9764-4245-8c5b-18347c9540da	03107399720	Meerab Din	A	94	t	\N	f	2026-04-26 11:56:28.385306	2026-04-26 12:25:51.661096	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "Microbiology", "degree_type": "Bachelors", "passing_year": "2021"}]	[{"org": "Teach For Pakistan", "current": false, "joining": "2021-6", "leaving": "2023-6", "designation": "Fellow"}, {"org": "Pak Mission Society", "current": false, "joining": "2023-10", "leaving": "2025-2", "designation": "Women Engagment Officer"}, {"org": "Idara-i-Taleem-o-Aagahi", "current": false, "joining": "2025-5", "leaving": "2025-12", "designation": "Project Associate"}, {"org": "NIETE", "current": true, "joining": "2026-2", "leaving": "", "designation": "Coach"}]	null	2848c56f-9764-4245-8c5b-18347c9540da	\N	\N	learner	t	\N
21d58325-43e3-4b26-8b17-19fa9380691d	03315881029	Khadija Akbar	A	94	t	\N	f	2026-04-25 19:35:52.86469	2026-04-25 20:07:32.118594	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	21d58325-43e3-4b26-8b17-19fa9380691d	\N	\N	learner	t	\N
5e56d4cf-56d4-47a9-b199-60e9b0d13da0	03268124162	Rabia Javed	A	83	t	\N	f	2026-04-26 14:48:57.21403	2026-04-26 15:01:36.533163	0	1	["Module 2", "Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "Education ", "degree_type": "MPhil", "passing_year": "2020"}]	[]	null	5e56d4cf-56d4-47a9-b199-60e9b0d13da0	\N	\N	learner	t	\N
bfc3570d-2f3d-4746-9780-e831b28b6df1	warda.kiani@niete.edu.pk	Warda Kiani	A	94	t	\N	f	2026-04-28 08:09:35.481893	2026-04-28 08:19:08.494401	0	1	["Module 5", "Module 6"]	islamabad	[]	IMS F-10/1	[{"degree": "Government & Public Policy", "degree_type": "Bachelors", "passing_year": "2024"}]	[]	null	bfc3570d-2f3d-4746-9780-e831b28b6df1	\N	\N	learner	t	\N
1d1b3f1d-35a0-4f1d-abab-f9ed9ee6b7b8	03268124159	Jamshaid Ahmad	A	89	t	\N	f	2026-04-27 02:37:03.566916	2026-04-27 03:19:14.841331	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	1d1b3f1d-35a0-4f1d-abab-f9ed9ee6b7b8	\N	\N	learner	t	\N
7112236b-c2bf-4032-8c69-9e38234f4cbf	fakhr.islam@niete.edu.pk	Fakhr Ul Islam	A	100	t	\N	f	2026-05-06 08:41:41.65706	2026-05-06 08:55:52.769382	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	7112236b-c2bf-4032-8c69-9e38234f4cbf	\N	\N	learner	t	\N
8197d6b8-d9f7-4616-b656-abc5c88268d4	03268124132	Javeria Nayyab	A	83	t	\N	f	2026-04-25 16:29:44.301344	2026-04-27 02:10:02.899665	0	1	["Module 4", "Module 5", "Module 6"]	islamabad	[]	NIETE-130	[{"degree": "Psychology ", "degree_type": "MPhil", "passing_year": "2023"}, {"degree": "B.Ed", "degree_type": "Bachelors", "passing_year": "2020"}, {"degree": "M.Sc Applied Psychology", "degree_type": "Bachelors", "passing_year": "2019"}, {"degree": "B.A Applied Psychology", "degree_type": "Bachelors", "passing_year": "2017"}]	[{"org": "NIETE", "current": true, "joining": "25-03-2024", "leaving": "", "designation": "CPD Coach"}, {"org": "HBL JUBILEE LIFE INSURANCE", "current": false, "joining": "2019-01", "leaving": "2019-06", "designation": "BSO"}, {"org": "PROGRESSIVE MODEL SCHOOL GUFFANWALA", "current": false, "joining": "2019-08", "leaving": "2020-09", "designation": "JUNIOR TEACHER"}]	null	8197d6b8-d9f7-4616-b656-abc5c88268d4	\N	\N	learner	t	\N
b9417e19-0ebb-4e52-9091-aeb615c96ca8	03268124101	Saman Zahoor 	D	61	t	\N	f	2026-04-27 04:14:42.566922	2026-04-27 04:25:23.616413	0	1	["Module 3", "Module 4", "Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	b9417e19-0ebb-4e52-9091-aeb615c96ca8	\N	\N	learner	t	\N
08a0e3b4-deff-482a-9598-1cd7425c35b2	+92 326 8124161	Bushra Karim	null	\N	f	\N	f	2026-04-27 05:36:25.911305	2026-04-27 05:36:27.963631	0	0	[]	null	[]	null	[]	[]	null	08a0e3b4-deff-482a-9598-1cd7425c35b2	\N	\N	learner	t	\N
1c903d37-7eb5-4420-8432-e59b9386a798	+923268124169	Abdul Malik	C	67	t	\N	f	2026-04-27 09:22:02.24608	2026-04-27 09:31:46.19965	0	4	["Module 2", "Module 3", "Module 4", "Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	1c903d37-7eb5-4420-8432-e59b9386a798	\N	\N	learner	t	\N
cbd02fa2-b563-451d-9008-5687b552eaab	03268124125	Hifza Nisar	A	100	t	\N	f	2026-04-27 00:59:52.229077	2026-04-27 09:17:14.29537	0	2	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	cbd02fa2-b563-451d-9008-5687b552eaab	\N	\N	learner	t	\N
0a859cfb-e515-4aea-8f15-cdc93780c6c1	03268124152	Aneela Khaliq 	A	94	t	\N	f	2026-04-27 08:42:14.640369	2026-04-27 11:13:24.381722	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	0a859cfb-e515-4aea-8f15-cdc93780c6c1	\N	\N	learner	t	\N
746a4e6a-9f50-4952-b4a1-3adde78e4ed8	03268124127	Hareem Abid	A	89	t	\N	f	2026-04-27 08:19:40.916425	2026-04-28 08:17:30.887919	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	746a4e6a-9f50-4952-b4a1-3adde78e4ed8	\N	\N	learner	t	\N
3263cced-27b7-4e8a-9921-c8744fcc54fd	03268124144	Sana Nawaz	A	100	t	\N	f	2026-04-27 09:39:05.469431	2026-04-27 09:59:03.174729	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "Bio Sciences", "degree_type": "Bachelors", "passing_year": "2022"}]	[{"org": "Allied School", "current": false, "joining": "2017-08", "leaving": "2018-09", "designation": "Teacher"}, {"org": "Teach For Pakistan", "current": false, "joining": "2022-07", "leaving": "2024-06", "designation": "Fellow"}, {"org": "Taleemabad", "current": true, "joining": "2024-10", "leaving": "", "designation": "CPD Coach"}]	null	3263cced-27b7-4e8a-9921-c8744fcc54fd	\N	\N	learner	t	\N
e0e2cab8-572f-42e4-b5b8-176693832a1b	shafaq.tahir@niete.edu.pk	Shafaq Tahir 	A	83	t	\N	f	2026-04-27 14:16:31.548352	2026-04-27 14:33:13.598326	0	1	["Module 4", "Module 5", "Module 6"]	islamabad	[]	\N	[]	[{"org": "Froebels International School", "current": false, "joining": "2012-10", "leaving": "2021-12", "designation": "Primary years teacher "}]	null	e0e2cab8-572f-42e4-b5b8-176693832a1b	\N	\N	learner	t	\N
232ebc3d-cc41-4eed-ad3e-3a773344bdd8	zarmeen.kausar@niete.edu.pk	Zarmeen Kausar	A	100	t	\N	f	2026-04-27 15:13:49.274869	2026-04-27 15:25:48.941736	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "Gender Studies ", "degree_type": "MPhil", "passing_year": "2025"}]	[{"org": "NIETE", "current": true, "joining": "2025-08", "leaving": "", "designation": "CPD COACH"}]	null	232ebc3d-cc41-4eed-ad3e-3a773344bdd8	\N	\N	learner	t	\N
90ef17c1-4416-48b3-812d-fdf8963f04ab	maria.karim@niete.edu.pk	Maria Karim	E	56	t	\N	f	2026-05-04 09:00:10.299945	2026-05-04 09:23:34.67239	0	1	["Module 2", "Module 3", "Module 4", "Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "Economics", "degree_type": "Bachelors", "passing_year": "2022"}]	[{"org": "Teach For Pakistan ", "current": false, "joining": "2023-07", "leaving": "2025-05", "designation": "Leadership and Teaching Fellow"}, {"org": "NIETE", "current": true, "joining": "2025-08", "leaving": "", "designation": "CPD Coach"}]	null	90ef17c1-4416-48b3-812d-fdf8963f04ab	\N	\N	learner	t	\N
eb43ebfc-3980-4fdf-81c1-ebdeb1d69b6b	hafsa.bashir@niete.edu.pk	hafsa bashir	A	94	t	\N	f	2026-05-05 12:46:57.205457	2026-05-05 12:57:36.724572	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	eb43ebfc-3980-4fdf-81c1-ebdeb1d69b6b	\N	\N	learner	t	\N
835a5110-1ea5-4e2c-9d21-5547755d5076	sehar.sajjad@niete.edu.pk	Sehar Sajjad	B	72	t	\N	f	2026-05-05 13:15:39.010364	2026-05-05 14:19:23.048218	0	1	["Module 2", "Module 4", "Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "Media Studies", "degree_type": "MPhil", "passing_year": "2022"}]	[{"org": "Taleemabad ", "current": true, "joining": "2024-03", "leaving": "", "designation": "Coach"}]	null	835a5110-1ea5-4e2c-9d21-5547755d5076	\N	\N	learner	t	\N
1f64811c-9cbc-41ca-b262-083a0de80adf	areej.noshad@niete.edu.pk	Areej Noshad	A	100	t	\N	f	2026-05-06 08:41:20.583401	2026-05-06 08:57:00.982461	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	1f64811c-9cbc-41ca-b262-083a0de80adf	\N	\N	learner	t	\N
fbc9cfd0-69ec-4912-8a57-d077f06ff886	misbah.iqbal@niete.edu.pk	Misbah Iqbal	A	100	t	\N	f	2026-05-06 09:07:35.668212	2026-05-06 09:11:50.787021	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	fbc9cfd0-69ec-4912-8a57-d077f06ff886	\N	\N	learner	t	\N
5060a286-9a2b-4919-9d07-0bb7451d01fc	javeria.khalil@niete.edu.pk	Javeria Khalil	A	83	t	\N	f	2026-05-06 09:10:35.686271	2026-05-06 09:23:41.604669	0	1	["Module 4", "Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "English Linguistics ", "degree_type": "MPhil", "passing_year": "2025"}]	[]	null	5060a286-9a2b-4919-9d07-0bb7451d01fc	\N	\N	learner	t	\N
23e92904-03ec-455f-a386-7a1c3f808387	ateeb.ali@niete.edu.pk	Ateeb Ali	A	94	t	\N	f	2026-05-06 09:58:47.706522	2026-05-06 10:07:21.551978	0	1	["Module 5", "Module 6"]	islamabad	[]	\N	[]	[]	null	23e92904-03ec-455f-a386-7a1c3f808387	\N	\N	learner	t	\N
85d242ba-516e-430a-a3bd-e06839728f5f	iqra.arshad@niete.edu.pk	Iqra Arshad	A	83	t	\N	f	2026-05-06 09:51:06.668157	2026-05-06 10:09:21.90026	0	1	["Module 3", "Module 5", "Module 6"]	islamabad	[]	\N	[{"degree": "Marketing", "degree_type": "Masters", "passing_year": "2025"}]	[]	null	85d242ba-516e-430a-a3bd-e06839728f5f	\N	\N	learner	t	\N
prod-test-cb112728-3e0c-4b95-b143-2fb28c9f0267	\N	Prod Smoke Test	\N	\N	f	\N	f	\N	2026-06-15 09:45:26.033925	0	0	[]	Punjab	["Teacher1"]	LGS	\N	\N	Lahore	prod-test-cb112728-3e0c-4b95-b143-2fb28c9f0267	\N	\N	learner	t	\N
\.


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.questions (id, assessment_id, question_type, question_text, correct_answer, max_score, order_number, created_at) FROM stdin;
677353e5-3979-475e-a63e-c4ba64a2b54c	cd78dae1-6ce9-4e52-a9e6-67291df3c06a	mcq	The 'Confidentiality Shield' is used to:	\N	1	2	2026-05-11 12:26:49.801167+00
e66dc282-77ca-4e87-9733-1e8474878536	cd78dae1-6ce9-4e52-a9e6-67291df3c06a	mcq	Which is a 'Choice-based' coaching prompt?	\N	1	5	2026-05-11 12:26:51.106664+00
cd1fc5b9-638d-4cf1-bed5-38707d197c52	cd78dae1-6ce9-4e52-a9e6-67291df3c06a	open	Why is 'Psychological Safety' the foundation of the coaching relationship? What specifically happens to teacher behavior when it is present versus absent?	Score 2: Explains that without safety teachers hide struggles and perform instead of grow; with safety they share authentic challenges, try new strategies, and own growth. Links to SCARF model. Score 1: Mentions that safety is important without distinguishing the behavioral difference. Score 0: Describes safety as comfort or friendliness without connecting to teacher professional behavior.	2	7	2026-05-11 12:26:51.965457+00
eada3485-d835-43b9-9de1-17e40aa8ab41	0881865f-a678-4884-8b4e-545b07109464	mcq	'Wait Time' in a coaching conversation should be:	\N	1	2	2026-05-11 12:26:54.816256+00
9f9b5ef2-5337-4c00-a63f-305375c15f17	0881865f-a678-4884-8b4e-545b07109464	mcq	A 'Deep Empathy' response focuses on:	\N	1	3	2026-05-11 12:26:55.335103+00
a543f020-7894-4ffd-afb8-45139a8c9fa8	0881865f-a678-4884-8b4e-545b07109464	mcq	Effective 'Voice Ratio' in a partnership conversation means:	\N	1	5	2026-05-11 12:26:56.266765+00
5a30e280-7150-4695-b96f-fe8bd1ad2385	0881865f-a678-4884-8b4e-545b07109464	mcq	Observable Evidence is:	\N	1	6	2026-05-11 12:26:56.695452+00
aed8c2b0-f871-4a56-99fd-6b5b312e0597	0881865f-a678-4884-8b4e-545b07109464	open	Describe what 'Observable Evidence' means and give one example of how you would rewrite a judgment-based statement into observable evidence for use in a coaching conversation.	Score 2: Observable evidence = what a video camera could capture (count, timestamp, specific action, direct quote); gives a specific rewrite (e.g., 'Students weren't engaged' → '57 students had blank pages at the 20-min mark'); explains that the rewrite invites teacher interpretation rather than triggering defensiveness. Score 1: Gives the definition but the rewrite still contains interpretation language. Score 0: Gives examples of evaluation statements without rewriting them, or confuses evidence with interpretation.	2	8	2026-05-11 12:26:57.398171+00
57942e71-265d-435b-9643-c6844184f4d3	14899040-a9ea-4041-8cb2-7ee38b4c19f4	mcq	In a Partnership, who chooses the coaching goal?	\N	1	1	2026-05-11 12:26:59.591068+00
8cefcecd-7483-477b-994b-a8f1f0398b85	14899040-a9ea-4041-8cb2-7ee38b4c19f4	mcq	'Co-Creation' of a goal means:	\N	1	5	2026-05-11 12:27:01.464955+00
17a1dd84-c0b0-4263-9d62-f053b4ae701f	cf058065-da19-4620-a554-d8f1b344aaf9	mcq	How is coaching fundamentally different from inspection?	\N	1	3	2026-05-11 14:02:25.557907+00
7008b319-d872-4b71-90ab-0b6b06d485c4	cf058065-da19-4620-a554-d8f1b344aaf9	mcq	Which best describes the tone of a Coaching Catalyst?	\N	1	6	2026-05-11 14:02:26.999568+00
bff2dece-2ff4-490d-90c8-d500443d1355	12dcd848-63d9-46e3-884d-13083bc8b238	mcq	What is the first step in the 4-step Observation-to-Conversation Flow?	\N	1	1	2026-05-11 14:02:29.896178+00
db21c740-00c6-406c-a3c7-664cec62862d	12dcd848-63d9-46e3-884d-13083bc8b238	mcq	What does 'Reciprocity' mean in partnership coaching?	\N	1	4	2026-05-11 14:02:31.203336+00
75f8ecbc-214a-41ec-a2e2-27ec96a9d349	12dcd848-63d9-46e3-884d-13083bc8b238	open	Describe the shift from a 'Judge' to a 'Co-Pilot' mindset in your own words. Give one concrete example of how this shift would change what you say in a post-observation conversation.	Score 2: Contrasts prescribing/judging with co-exploring, gives specific language example ('I noticed X — what was your intention?' vs 'You should have done Y'). Score 1: Describes the mindset difference without a concrete language example. Score 0: Focuses only on tone rather than the structural shift in who speaks first and who chooses.	2	7	2026-05-11 14:02:32.526375+00
3949451e-2453-4ad7-9cf5-2df600e20cf7	12dcd848-63d9-46e3-884d-13083bc8b238	open	Why is 'Voice' one of the 7 Partnership Principles, and what practical risk does a coach run if they skip it and go straight to sharing their own observations?	Score 2: Voice = teacher speaks first, explains that skipping voice removes ownership and triggers compliance mindset, links to Choice and Praxis. Score 1: Mentions teacher speaking first but does not explain the risk of skipping. Score 0: Defines voice as 'the coach's tone of voice' or does not distinguish teacher vs coach voice.	2	8	2026-05-11 14:02:32.827863+00
319bef5d-5c86-4295-a518-af096d41bce7	79ed136b-ef61-4114-b0c5-6acbb1446da8	mcq	Which of the following is a 'Low-Inference' observation statement?	\N	1	2	2026-05-11 14:02:35.516057+00
3e962a17-5e70-42a9-86ad-0d23c00eedcb	79ed136b-ef61-4114-b0c5-6acbb1446da8	mcq	How does 'time-stamping' observation data support the Shared Mirror?	\N	1	5	2026-05-11 14:02:36.799881+00
8ddcf7bf-fcfc-4a7f-b109-e51ac593b11d	fdb43c81-f0d0-466f-a618-218bdee2b075	mcq	'Closing the Loop' in the Growth Engine means:	\N	1	3	2026-05-11 14:02:41.029971+00
c2d84215-2b5e-441c-b45e-28115378d18c	cd78dae1-6ce9-4e52-a9e6-67291df3c06a	mcq	In a Partnership, 'Equality' means:	\N	1	3	2026-05-11 12:26:50.236763+00
4415e272-0510-4e2e-a059-22a23021a683	cd78dae1-6ce9-4e52-a9e6-67291df3c06a	mcq	What is the goal of 'Mitigating Threat'?	\N	1	6	2026-05-11 12:26:51.536193+00
ab9257fb-dbbf-479c-b5af-d92ff28a044f	cd78dae1-6ce9-4e52-a9e6-67291df3c06a	open	You are conducting a feedback session with Mr. Ahmed. You say: 'The Principal noticed your pacing is slow, so I am here to tell you that you must use a timer for every activity starting tomorrow.' Mr. Ahmed becomes defensive. Using the SCARF model, explain why this directive failed.	Score 2: Identifies that the directive removed Choice (autonomy), invoked principal authority (status threat from hierarchy), delivered a prescription without evidence or teacher voice — specifically naming SCARF dimensions. Score 1: Notes it was too directive or authoritative without applying the SCARF framework. Score 0: Says the teacher was being difficult or resistant without diagnosing the coaching failure.	2	8	2026-05-11 12:26:52.185891+00
f973b07d-e858-4743-ac29-3a62f46ccbde	0881865f-a678-4884-8b4e-545b07109464	mcq	'Autobiographical Listening' happens when the coach:	\N	1	1	2026-05-11 12:26:54.288368+00
22048d33-79d0-4667-ba37-e90d40a892f9	0881865f-a678-4884-8b4e-545b07109464	mcq	'Paraphrasing' helps the coach to:	\N	1	4	2026-05-11 12:26:55.761066+00
21a15afb-0d23-45b6-9c1b-118a267a1665	0881865f-a678-4884-8b4e-545b07109464	open	A coach uses Paraphrasing after a teacher describes a stressful classroom incident: 'So, if I am hearing you correctly, you felt overwhelmed because only 5 out of 40 students had the prerequisite materials ready. Is that right?' What is the primary benefit of this technique?	Score 2: Validates the teacher's voice, confirms shared understanding before moving forward, ensures coach is not misinterpreting the situation, creates space for teacher to correct if wrong — all of which preserve the partnership quality of the conversation. Score 1: Says it is useful for understanding without explaining the partnership mechanism. Score 0: Says it lets the coach repeat the facts to remember them — a coach-centered framing that misses the purpose.	2	7	2026-05-11 12:26:57.178582+00
adb00418-d3df-49a3-8613-e1843e17f4d4	14899040-a9ea-4041-8cb2-7ee38b4c19f4	mcq	A 'SMART' goal must be 'Measurable,' meaning:	\N	1	2	2026-05-11 12:27:00.037921+00
96669048-95e6-4a03-baa8-55754333421a	14899040-a9ea-4041-8cb2-7ee38b4c19f4	mcq	What happens if a coach imposes a goal on a teacher?	\N	1	3	2026-05-11 12:27:00.475386+00
47cef7ba-72f2-4b67-ae61-632abd55d4b1	14899040-a9ea-4041-8cb2-7ee38b4c19f4	mcq	A 'Small Win' goal is important because:	\N	1	6	2026-05-11 12:27:01.89533+00
a066a623-72fd-4f47-a34d-fc1a005ad1f7	14899040-a9ea-4041-8cb2-7ee38b4c19f4	open	A coach wants to ensure 'Teacher Ownership' of a new goal. Instead of telling the teacher what to do, the coach asks: 'Based on the video data we just watched, which area do you feel would have the biggest impact on student engagement if we improved it?' Why is this approach considered the Growth Engine of coaching?	Score 2: Ownership leads to intrinsic motivation and sustained change; when the teacher identifies the focus, the strategy choice, and the pivot — the teacher is coaching themselves. Coach is no longer necessary for implementation because the teacher has internalized the process. Score 1: Says ownership is good for motivation without explaining the mechanism (self-directed growth). Score 0: Says it allows the coach to avoid making difficult decisions.	2	8	2026-05-11 12:27:02.546997+00
f39927a9-43e4-41be-94d0-d5439b701b55	cf058065-da19-4620-a554-d8f1b344aaf9	mcq	What is the primary definition of coaching?	\N	1	1	2026-05-11 14:02:24.57298+00
1c28f009-d7dc-4a26-b83b-4ad7b6fc930a	cf058065-da19-4620-a554-d8f1b344aaf9	mcq	In the 'Co-Pilot' mindset, who navigates the growth journey?	\N	1	4	2026-05-11 14:02:26.070963+00
5a5d7283-fbe9-4b29-adab-c734eb22ec7d	cf058065-da19-4620-a554-d8f1b344aaf9	open	In your own words, explain why coaching is described as a 'Catalyst' for teacher growth rather than a corrective intervention. What specific behaviors make a coach a Catalyst?	Score 2: Mentions teacher agency/choice, growth focus vs correction, partnership principles (equality, voice), and contrast with inspection. Score 1: Mentions 1-2 elements (e.g. supportive, not fixing). Score 0: Describes coaching as giving feedback or telling teachers what to do.	2	7	2026-05-11 14:02:27.443238+00
8e1cd55b-d7d8-423c-bb55-89ebca62838f	cf058065-da19-4620-a554-d8f1b344aaf9	open	A new school head tells you: 'I want you to observe Mr. Kamran and give me a written report on his weaknesses.' Describe exactly what you would say and do to protect the coaching relationship while maintaining a productive relationship with the head teacher.	Score 2: Declines individual report, explains coaching vs evaluation boundary, offers school-wide aggregate instead, uses respectful tone. Score 1: Refuses but does not offer an alternative or explain the principle. Score 0: Agrees to write the report or avoids the conversation.	2	8	2026-05-11 14:02:27.706578+00
e2f82106-c813-4236-853a-a2f5df8c45f5	12dcd848-63d9-46e3-884d-13083bc8b238	mcq	The 'Choice' Partnership Principle means:	\N	1	2	2026-05-11 14:02:30.324876+00
afc4fd17-1348-4375-9b1b-65fca1ae3325	12dcd848-63d9-46e3-884d-13083bc8b238	mcq	What is the hallmark of the 'Equality' Partnership Principle in practice?	\N	1	5	2026-05-11 14:02:31.624923+00
6e09dbc4-3181-44ec-b64a-8880d72b2701	79ed136b-ef61-4114-b0c5-6acbb1446da8	mcq	Why is 'High-Inference' feedback dangerous in coaching conversations?	\N	1	3	2026-05-11 14:02:35.949905+00
6b9a9abf-96bb-47ed-9690-08181ce6d463	79ed136b-ef61-4114-b0c5-6acbb1446da8	mcq	Where should the coach sit when using the Shared Mirror protocol?	\N	1	6	2026-05-11 14:02:37.228689+00
b7b218c8-b0e6-4a89-acd9-cbe6145bba03	79ed136b-ef61-4114-b0c5-6acbb1446da8	open	Write one 'Low-Inference' and one 'High-Inference' version of the same classroom observation. Then explain why the low-inference version is more useful in a coaching conversation.	Score 2: Low-inference uses specific, time-stamped, factual language; high-inference uses labels or judgments; explains that low-inference invites curiosity while high-inference triggers defensiveness. Score 1: Gives examples but does not explain the impact difference. Score 0: Both versions contain judgment language, or the distinction is incorrect.	2	8	2026-05-11 14:02:37.899184+00
7699f95f-1c14-442e-a60b-e67278ad77f8	fdb43c81-f0d0-466f-a618-218bdee2b075	mcq	The Growth Engine coaching cycle operationalizes which framework?	\N	1	1	2026-05-11 14:02:39.991805+00
01c34970-d9d2-48dc-8b07-8482fbc5b9f4	fdb43c81-f0d0-466f-a618-218bdee2b075	mcq	Who should ideally choose the final action step in the SUPPORT phase?	\N	1	4	2026-05-11 14:02:41.548757+00
ba649694-58a1-464c-9b3e-0b284eeb7f34	fdb43c81-f0d0-466f-a618-218bdee2b075	open	A teacher says: 'You suggested the strategy and it did not work. What should I try next?' What does this situation reveal about the coaching cycle, and what is your response?	Score 2: Identifies that teacher did not own the strategy (coach suggested = coach's idea), explains that teacher choice drives ownership, returns to co-analysis before choosing next step. Score 1: Focuses on gathering more evidence but does not address the ownership issue. Score 0: Apologizes and gives another strategy, repeating the same mistake.	2	7	2026-05-11 14:02:42.856795+00
978be59b-3e4d-446c-8fce-daa9b126e7c3	fdb43c81-f0d0-466f-a618-218bdee2b075	open	Describe what the 'Identify' phase of the Growth Engine looks like in practice. What specific actions does the coach take, and what role does the teacher play?	Score 2: Co-select focus area with teacher, teacher names the challenge (not coach), observe with timestamps, set SMART goal together, teacher chooses the focus. Score 1: Describes observation and goal-setting but coach-directed rather than co-created. Score 0: Describes Identify as the coach deciding what the teacher needs to work on.	2	8	2026-05-11 14:02:43.064298+00
68f952ee-4019-488b-b868-70d1cf2a7202	ad87af82-7496-4b2c-bcb1-f765a7b7ef36	mcq	If confidentiality is broken in a coaching relationship, what typically happens?	\N	1	2	2026-05-11 14:02:45.736056+00
01d317bc-dfa8-4cc4-aedf-581cf4af3d34	ad87af82-7496-4b2c-bcb1-f765a7b7ef36	mcq	When a principal asks for individual coaching notes, the coach should:	\N	1	5	2026-05-11 14:02:47.101947+00
266b79f0-22ef-45c2-b982-752d9eb7751e	a58afc41-9f5b-4b91-b8bf-1d2e85b46918	mcq	'Cultural Blindness' in AI tools leads to:	\N	1	3	2026-05-11 14:02:51.404813+00
d79a3e70-be1d-4449-93af-dbbd1f9e40e1	5ec96580-0327-4104-a9db-3bedbc80ec7c	mcq	According to the 'Camera Test,' which of these is an objective observation?	\N	1	2	2026-05-13 08:19:54.445849+00
90c798fc-b2df-4cee-a759-4338fb9f66a7	5ec96580-0327-4104-a9db-3bedbc80ec7c	mcq	In the 'T-Chart' method, what is recorded on the right side?	\N	1	5	2026-05-13 08:19:55.798617+00
a9b7aa12-9a0b-47e8-9f58-a6a51c24acb6	cd78dae1-6ce9-4e52-a9e6-67291df3c06a	mcq	What does the 'Status' threat in the SCARF model refer to?	\N	1	1	2026-05-11 12:26:49.314914+00
6b974557-df0f-447c-96b5-42ec19b4aa6a	cd78dae1-6ce9-4e52-a9e6-67291df3c06a	mcq	A 'Status-Safe' observation focus should be on:	\N	1	4	2026-05-11 12:26:50.669208+00
ffa03d7b-b6a5-4213-9979-f0510c37b39e	14899040-a9ea-4041-8cb2-7ee38b4c19f4	mcq	The 'Identify' stage of the Impact Cycle is about:	\N	1	4	2026-05-11 12:27:00.983766+00
d1a3f0aa-2e4a-4f27-baaa-8fcc7ec8d38c	14899040-a9ea-4041-8cb2-7ee38b4c19f4	open	A teacher suggests: 'My goal is for my students to learn the material better this week.' According to the SMART framework, why is this goal insufficient, and how should it be changed?	Score 2: Goal is vague (which material?), unmeasurable (what counts as 'better'?), no timeframe (just 'this week' is not specific enough), no student evidence indicator. Rewrites using specific observable criteria — e.g., '80% of students will answer the exit ticket correctly by Friday.' Score 1: Identifies the goal is vague without addressing all 5 SMART components. Score 0: Says the goal is fine because it mentions student learning, or says it should be longer.	2	7	2026-05-11 12:27:02.33597+00
96a60384-57b1-4d34-b8a3-60d37a929e4e	cf058065-da19-4620-a554-d8f1b344aaf9	mcq	What does the 'Implementation Gap' refer to in coaching?	\N	1	2	2026-05-11 14:02:25.056377+00
69c38655-0276-41be-bb5d-af0ef97ef5f8	cf058065-da19-4620-a554-d8f1b344aaf9	mcq	Why is coaching frequency more important than coaching intensity?	\N	1	5	2026-05-11 14:02:26.575272+00
014dc8cc-34a2-4eb7-89b8-4df1762f8f11	12dcd848-63d9-46e3-884d-13083bc8b238	mcq	The 'Expert Trap' in coaching refers to:	\N	1	3	2026-05-11 14:02:30.748373+00
e3bd507f-5dc3-445f-9de7-b3bc4c091363	12dcd848-63d9-46e3-884d-13083bc8b238	mcq	What happens in 'Co-interpretation' (Step 3 of the 4-step flow)?	\N	1	6	2026-05-11 14:02:32.052872+00
26ab0a03-3b00-4c56-81f4-e0d893b78011	79ed136b-ef61-4114-b0c5-6acbb1446da8	mcq	The Shared Mirror presents classroom data as:	\N	1	1	2026-05-11 14:02:35.090252+00
15268675-2323-4a79-b8f8-1fbd8f27a962	79ed136b-ef61-4114-b0c5-6acbb1446da8	mcq	In the Shared Mirror protocol, what is the role of the 'Neutral Third Party'?	\N	1	4	2026-05-11 14:02:36.376589+00
c1546b45-bce2-4698-b822-66bcd42fa0d1	79ed136b-ef61-4114-b0c5-6acbb1446da8	open	Why is it essential for the coach to share observation data 'side-by-side' with the teacher rather than presenting it from the front of the room or across a desk? What does the physical arrangement signal?	Score 2: Side-by-side signals equality (not hierarchy), shared inquiry (not judgment), mirrors the data being 'ours' not 'yours', links to Equality Partnership Principle. Score 1: Mentions informality or comfort without connecting to the principle. Score 0: Focuses on logistics rather than the relational/symbolic meaning.	2	7	2026-05-11 14:02:37.686208+00
42d8f14c-4e7a-42a9-a884-b68467468446	fdb43c81-f0d0-466f-a618-218bdee2b075	mcq	A 'bite-sized' action step in the Growth Engine is best described as:	\N	1	2	2026-05-11 14:02:40.517289+00
4af81e44-fd75-43e4-88a8-d1651089d5e5	fdb43c81-f0d0-466f-a618-218bdee2b075	mcq	In the Growth Engine, evidence serves as:	\N	1	5	2026-05-11 14:02:41.973286+00
9a93cd0b-f016-44da-abc2-14e348c96289	fdb43c81-f0d0-466f-a618-218bdee2b075	mcq	The IMPROVE phase of the Growth Engine focuses on:	\N	1	6	2026-05-11 14:02:42.418859+00
ce35679e-28e1-4255-b924-82bb50a34494	ad87af82-7496-4b2c-bcb1-f765a7b7ef36	mcq	What are the 4 pillars of the ethical coaching framework in Unit 1.4?	\N	1	1	2026-05-11 14:02:45.210692+00
62323b38-83df-4a1f-a4d5-4c9a75920212	ad87af82-7496-4b2c-bcb1-f765a7b7ef36	mcq	'Implicit' trust in coaching is built through:	\N	1	3	2026-05-11 14:02:46.244967+00
9d0d86c9-2364-4a44-b93b-34dffc21b9e5	ad87af82-7496-4b2c-bcb1-f765a7b7ef36	mcq	What does 'Accountability' mean in partnership coaching?	\N	1	4	2026-05-11 14:02:46.675844+00
e8c495e2-a454-4a8e-ab19-f27e989bff99	ad87af82-7496-4b2c-bcb1-f765a7b7ef36	mcq	Integrity in partnership coaching means:	\N	1	6	2026-05-11 14:02:47.573233+00
eb7de284-61bd-48f0-a82b-fc20f5217ab7	270d968d-141d-409f-8dbe-2d184c0c9f52	mcq	The 'Permission Script' is used to:	\N	1	3	2026-05-13 08:19:59.894827+00
587f7313-f818-468d-b536-66c99c8113a1	270d968d-141d-409f-8dbe-2d184c0c9f52	mcq	'Artifact Protection' means the coach:	\N	1	6	2026-05-13 08:20:01.612276+00
fa78e4e4-ea60-42c0-af8f-72ee2f4fde5d	904752e4-b77f-4957-90ae-6a1336b84d53	mcq	In Unit 4.1, the coach's identity shifts from 'Data Collector' to:	\N	1	1	2026-05-13 08:41:59.760971+00
e92590ab-4cbb-4be4-bbab-1b8959c317f4	ad87af82-7496-4b2c-bcb1-f765a7b7ef36	open	Explain where the boundary of confidentiality lies when a principal has a genuine interest in improving a struggling teacher's performance. What can you share, and what must you protect?	Score 2: Can share anonymous school-level trends/themes; cannot share individual coaching notes, progress, or performance data; explains why (trust collapse); clear on the boundary even under pressure. Score 1: Knows individual data should not be shared but is vague about what CAN be shared. Score 0: Believes principal interest justifies sharing individual data, or that teacher consent makes it acceptable.	2	7	2026-05-11 14:02:48.004173+00
2e9bfbf1-a6b4-4dee-9a13-8fb26a7fb875	a58afc41-9f5b-4b91-b8bf-1d2e85b46918	mcq	The 'Human Filter' concept means:	\N	1	1	2026-05-11 14:02:50.524864+00
c040a263-b790-45f5-aaf4-57ebd86ab6e0	a58afc41-9f5b-4b91-b8bf-1d2e85b46918	mcq	What are the 3 questions in the AI Validation Framework?	\N	1	2	2026-05-11 14:02:50.989794+00
1823eb89-88b5-400c-b457-b221c3f78120	a58afc41-9f5b-4b91-b8bf-1d2e85b46918	mcq	AI provides 'Data Patterns' — what does the human coach provide?	\N	1	4	2026-05-11 14:02:51.8347+00
df97db95-fc78-4296-a6b7-9209a2172bc8	a58afc41-9f5b-4b91-b8bf-1d2e85b46918	mcq	Why should the coach check AI output for 'Deficit Framing'?	\N	1	5	2026-05-11 14:02:52.265705+00
1077c779-cd3b-44bf-8347-05899aa19db4	a58afc41-9f5b-4b91-b8bf-1d2e85b46918	mcq	If AI labels a teacher's behaviour as 'unprofessional', the coach should:	\N	1	6	2026-05-11 14:02:52.695609+00
71334c2c-8d98-498b-8470-825acac337da	a58afc41-9f5b-4b91-b8bf-1d2e85b46918	open	Give an example of when you would ask the 'Context' question from the 3-Question AI Validation Framework. What specific classroom factor might the AI have missed, and how would you add that context in your coaching conversation?	Score 2: Context question = 'Does this account for the classroom reality I observed?', example includes Pakistan-specific factor (class size, no TA, resource constraints, exam pressure), explains how to contextualize rather than discard the data. Score 1: Gives an override example without applying the Context question framing. Score 0: Describes context as explaining the AI results to the teacher without adding human knowledge.	2	7	2026-05-11 14:02:53.120109+00
4ad6cfea-a368-4a55-a023-7c32d30f1e5d	a6b8cb55-2667-4ea1-8937-61ca6f8e3edb	mcq	'I Do' in the observation schema refers to:	\N	1	1	2026-05-11 14:02:55.353355+00
85e7ad94-ee2d-4a47-8bca-2771f7b86d61	a6b8cb55-2667-4ea1-8937-61ca6f8e3edb	mcq	'We Do' in the observation schema is also known as:	\N	1	2	2026-05-11 14:02:55.775949+00
a00748ae-8d0b-41ca-ba63-a75203292b29	a6b8cb55-2667-4ea1-8937-61ca6f8e3edb	mcq	What is the primary purpose of 'CFU' (Check for Understanding)?	\N	1	3	2026-05-11 14:02:56.194268+00
8a428520-75c0-40ae-a371-ed61a58b8a18	a6b8cb55-2667-4ea1-8937-61ca6f8e3edb	mcq	'You Do' is the phase where:	\N	1	4	2026-05-11 14:02:56.617996+00
e1b7725b-e2c5-4521-a884-72b24b50b9e8	a6b8cb55-2667-4ea1-8937-61ca6f8e3edb	mcq	The observation schema is best described as a tool for:	\N	1	5	2026-05-11 14:02:57.193081+00
6989817f-47e3-4428-a187-75b604a17bbe	a6b8cb55-2667-4ea1-8937-61ca6f8e3edb	mcq	A 'Pivot' in a lesson occurs when:	\N	1	6	2026-05-11 14:02:57.609225+00
927f74da-88ac-4901-aa20-be1969834d52	a6b8cb55-2667-4ea1-8937-61ca6f8e3edb	open	Why is the 'We Do' phase described as a critical bridge in the I Do/We Do/You Do model? What is the risk of moving directly from 'I Do' to 'You Do' without a 'We Do' phase?	Score 2: We Do = guided practice with teacher support — bridges modeling and independence; risk of skipping: students attempt without sufficient scaffolding, leading to errors, confusion, or disengagement; links to schema dialogue about lesson pacing. Score 1: Describes We Do correctly but does not explain the risk of skipping it. Score 0: Confuses We Do with group work, or says skipping is fine if students are advanced.	2	7	2026-05-11 14:02:58.111911+00
8b6521ab-d7b6-4ae8-ae07-4585d10fb1e7	ad87af82-7496-4b2c-bcb1-f765a7b7ef36	open	Why does 'predictability' build trust in a coaching relationship? Give two concrete examples of predictable coaching behaviors that would strengthen teacher trust over time.	Score 2: Predictability = teacher knows what to expect (no surprises, no evaluation, consistent confidentiality), examples: always asking before telling, never sharing notes, always following through on agreed actions. Score 1: Mentions consistency without explaining why it builds trust. Score 0: Defines predictability as following a fixed coaching schedule or template.	2	8	2026-05-11 14:02:48.219904+00
e76731c8-ced8-4b69-955d-47d759a70bae	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	According to the SCARF model, a veteran teacher saying they don't need a coach is a direct threat to:	\N	1	1	2026-05-12 16:31:26.338488+00
059df540-aa88-4077-8ec8-d4dcf0e66a5c	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	When a teacher displays "Flight" behavior (minimal responses), it likely indicates the coach has:	\N	1	2	2026-05-12 16:31:26.338488+00
407ed0cc-1f88-466f-950b-9b453b6dc437	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	A Principal demands the individual engagement scores of all teachers to decide on "Show Cause" notices. According to the Universal SOP, you should:	\N	1	3	2026-05-12 16:31:26.338488+00
3740a241-91c0-4eb9-ade1-83a8b4c67e0e	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: A veteran teacher reacts with "Freeze" behavior (passive compliance). Which Opening Script best uses Equality and Voice to establish a partnership?	\N	1	4	2026-05-12 16:31:26.338488+00
a0bfcfcb-6c6b-4ebc-b214-a4f4c4bc1d1b	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: During a feedback session, a teacher is defensive. To move to a Side-by-Side mindset, you should:	\N	1	5	2026-05-12 16:31:26.338488+00
055b957a-cd91-44e4-bc2a-bcb80414788c	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: You notice a teacher is struggling with a noisy class. Instead of giving a "fix," you use Deep Empathy by saying:	\N	1	6	2026-05-12 16:31:26.338488+00
0b6d7d3e-a411-43d3-a19d-8767d5404746	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	What is the primary purpose of capturing "Data at the Edge" (e.g., back-row notebooks)?	\N	1	7	2026-05-12 16:31:26.338488+00
e2903376-d87a-4ed5-a596-3f8ac454f595	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	If a coach and teacher score the same lesson differently, this "Calibration Gap" is usually caused by:	\N	1	8	2026-05-12 16:31:26.338488+00
7a7aff9d-cea2-45e4-ad09-2a4d1259f4b4	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	The Human Filter rule states that a coach should NOT capture an artifact if:	\N	1	9	2026-05-12 16:31:26.338488+00
fac03f31-13f3-4397-9ea9-a6c7428a92d8	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: Which observation note successfully passes the "Camera Test" by removing high-inference judgment?	\N	1	10	2026-05-12 16:31:26.338488+00
31fc6e91-b393-4610-b738-04edead3fa34	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: A teacher insists a class was "perfect," but data shows 0% passed the exit ticket. To achieve Calibration, you should:	\N	1	11	2026-05-12 16:31:26.338488+00
e8d58213-df35-4b98-929a-9ff4dcc7ab36	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: When taking a digital photo of student work, the Voice principle requires you to:	\N	1	12	2026-05-12 16:31:26.338488+00
a08d7ee5-efe9-4ae0-96e5-7bf7ca23d165	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Coach Usman had 6 visits. 1 holiday, 1 absent teacher (excluded), 1 visit with no artifact, and 1 interrupted by a Principal. What is his WRER?	\N	1	13	2026-05-12 16:31:26.338488+00
851b7f87-cf20-4df7-8872-b89a4a77a4d2	a58afc41-9f5b-4b91-b8bf-1d2e85b46918	open	What does the phrase 'Human Filter' mean, and how does applying it protect the coaching partnership when AI-generated data is used in a coaching conversation?	Score 2: Human Filter = coach applies 3-question framework before sharing AI output; protects partnership by ensuring data reflects teacher's reality; prevents AI from becoming Audit Culture 2.0; teacher's agency is preserved. Score 1: Describes the concept but does not explain how it protects the coaching partnership specifically. Score 0: Defines Human Filter as removing negative AI feedback before sharing.	2	8	2026-05-11 14:02:53.329238+00
af56078b-c26c-4e2f-a2b8-c1dab48fbd7b	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	What does a "High Fidelity" but "Low Impact" score on a Regional Heatmap suggest?	\N	1	14	2026-05-12 16:31:26.338488+00
f16ded0a-aa1e-4903-a7df-26362bf8be0f	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	To avoid the "Administrative After-Burn," a coach should:	\N	1	15	2026-05-12 16:31:26.338488+00
6f843250-9e8b-4119-b612-30ecf09c8e0c	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: A Principal displaces your coaching block with "Protocol Duty." Which Advocacy Script best protects your time?	\N	1	16	2026-05-12 16:31:26.338488+00
38e12e9c-7b25-4d92-9bda-091c62145171	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: An AI dashboard suggests "Use digital tools," but there is no electricity. Following Human Override, you:	\N	1	17	2026-05-12 16:31:26.338488+00
e6dfbfe3-d3bc-49af-886e-85720f261b83	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: A dashboard shows 100% task completion, but you observe students just copying from the board. You should:	\N	1	18	2026-05-12 16:31:26.338488+00
99bc3665-7875-49db-a25c-c899c23faeac	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This is a:	\N	1	19	2026-05-12 16:31:26.338488+00
84e0b55e-e7dc-44b8-8f22-d54cf7ac18f1	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	In Side-by-Side Co-Modeling, the coach's goal is to:	\N	1	20	2026-05-12 16:31:26.338488+00
cbe8c824-cc98-487a-824b-aa2cd2770cfd	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	If a goal is not met after two visits, the Improve Phase requires one of 4 Paths. Which is NOT a path?	\N	1	21	2026-05-12 16:31:26.338488+00
6dc6c4d4-0d24-4682-99a0-0d519e505369	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap (Internal Rule) as:	\N	1	22	2026-05-12 16:31:26.338488+00
3350a30c-9ce7-4d5b-86c1-83fa3729cb86	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: A teacher spends 20 minutes on a 5-minute intro. You diagnose this as a Planning Loop failure and:	\N	1	23	2026-05-12 16:31:26.338488+00
7609907b-2591-4c7f-abd7-0a665bac79c3	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: When a teacher has 8 skill gaps, a "Catalyst" coach prioritizes:	\N	1	24	2026-05-12 16:31:26.338488+00
1a765bf0-460f-46ed-96b6-1b0bcfe0999b	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	"Responsive Contextualization" is necessary when:	\N	1	25	2026-05-12 16:31:26.338488+00
e0958b47-91f9-43f4-bca9-315249c4e262	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	The "Compliance Trap" occurs when:	\N	1	26	2026-05-12 16:31:26.338488+00
ae4c94f6-9d06-4cd8-8eb8-8a7f74158dcf	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	"Closing the Loop" is only achieved when:	\N	1	27	2026-05-12 16:31:26.338488+00
568774c7-188c-4e60-ae49-5cf5a0c89a84	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: A veteran teacher is skeptical of a new strategy. The most Reciprocal move is to:	\N	1	28	2026-05-12 16:31:26.338488+00
97699844-ac3c-4944-b6c8-e55578ce1311	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: You model a strategy and it fails (chaotic classroom). To maintain Shared Reality, you:	\N	1	29	2026-05-12 16:31:26.338488+00
d6b013cd-7d24-4b41-a7ab-c4a21f5624f4	d7e9e809-10d2-4a34-bebc-5f2e6c430c72	mcq	Case Study: Why is Praxis (action-based learning) prioritized over "Abstract Theory"?	\N	1	30	2026-05-12 16:31:26.338488+00
7728594c-6104-4b1f-8645-59e643e638a6	5ec96580-0327-4104-a9db-3bedbc80ec7c	mcq	What happens to the 'Status' of a teacher when a coach uses evaluative adjectives like 'messy' or 'weak'?	\N	1	3	2026-05-13 08:19:54.900786+00
09c6262d-66b6-429c-b63b-fb2a82e6ee07	5ec96580-0327-4104-a9db-3bedbc80ec7c	mcq	When a Principal asks for specific teacher data for an audit, the Mirror Specialist should:	\N	1	6	2026-05-13 08:19:56.24149+00
7dc80e78-da22-4327-9459-6c01b6126de9	5ec96580-0327-4104-a9db-3bedbc80ec7c	open	During a debrief, a coach tells a teacher: 'Your transition between the lecture and the activity was quite messy and weak.' According to the module, what is the likely impact of using these evaluative adjectives?	Score 2: Triggers status threat (SCARF) and stops the teacher's self-reflection by creating a hierarchy of judgment; explains mechanism (brain in defensive mode, stops listening, composes defense rather than processing). Score 1: Says it creates defensiveness without connecting to the SCARF mechanism or Equality principle. Score 0: Defends the use of evaluative language as 'honest feedback' or misattributes the teacher's reaction to personality.	2	8	2026-05-13 08:19:56.923741+00
59b3383f-e475-49fc-8044-2553942d3b01	270d968d-141d-409f-8dbe-2d184c0c9f52	mcq	What is a 'Coaching Artifact' in the context of Unit 3.2?	\N	1	1	2026-05-13 08:19:59.013734+00
9abbdf38-582d-4028-901f-30c83b2685a0	270d968d-141d-409f-8dbe-2d184c0c9f52	mcq	An 'Edge Artifact' focuses on:	\N	1	4	2026-05-13 08:20:00.497001+00
ab47ebec-afd3-4a29-b1c0-60668e4cbebb	270d968d-141d-409f-8dbe-2d184c0c9f52	open	A coach wants to capture a photo of a student's work sample. Before taking the photo, the coach asks the teacher: 'Is it okay if I capture a quick photo of this student's response to use for our discussion later?' What is the purpose of this Permission Script?	Score 2: Protects teacher agency (Choice principle), ensures teacher feels in control of what is captured, signals confidentiality (not for the principal), builds the trust that makes authentic evidence-collection possible. Score 1: Mentions following rules or getting consent without connecting to the partnership mechanism. Score 0: Says the Permission Script is to make the meeting seem more formal or official.	2	7	2026-05-13 08:20:02.057959+00
4f61d12e-1293-44ac-be75-12f38cee2ebd	962105eb-60c7-4968-a632-f02660d52fc6	mcq	In the 'Data-Dialogue Flow,' what should happen first?	\N	1	2	2026-05-13 08:20:04.808525+00
621e25f9-05bf-4d4d-a4c8-b6c224274435	962105eb-60c7-4968-a632-f02660d52fc6	mcq	The 'Wait Time' in a coaching dialogue is used to:	\N	1	5	2026-05-13 08:20:06.151339+00
98e9e52c-9782-4c79-9a33-35e0d0337558	904752e4-b77f-4957-90ae-6a1336b84d53	mcq	What is the primary purpose of 'Human Annotation' in a Digital Journal?	\N	1	2	2026-05-13 08:42:00.288056+00
db7200e2-31c6-47ad-bd77-0fa1e6624065	904752e4-b77f-4957-90ae-6a1336b84d53	mcq	The 'Digital Journal' is a tool for which phase of the Impact Cycle?	\N	1	4	2026-05-13 08:42:01.26139+00
814c2e78-f61a-4680-a6a4-58f23e918c13	904752e4-b77f-4957-90ae-6a1336b84d53	mcq	When sequencing artifacts in a Digital Journal, 'Improve' evidence shows:	\N	1	6	2026-05-13 08:42:02.24275+00
176211fe-9a1f-4a68-abbd-8f4853306d23	904752e4-b77f-4957-90ae-6a1336b84d53	open	You have been working with a teacher for three months. You decide to show them a sequence of artifacts from their Digital Journal, from the first IDENTIFY phase to the most recent IMPROVE phase. Why are you acting as a 'Biographer of Growth'?	Score 2: Biographer of Growth = documenting the teacher's professional journey over time rather than counting errors; making the arc from baseline to growth visible in one place so the teacher can see how far they have come; this is motivating and confirms coaching partnership worked. Score 1: Describes showing progress without explaining the 'biographer' identity or its motivational purpose. Score 0: Says the purpose is to prove to the district that the coach has been working consistently.	2	8	2026-05-13 08:42:03.02143+00
ff1eda98-f25d-4d12-aab8-33fa9c6f0552	aad7f7e3-58c0-4704-ab6a-b05ed23d2ba6	mcq	An 'Adaptive Facilitator' adjusts their coaching style based on:	\N	1	1	2026-05-13 08:42:05.199099+00
2341c475-b850-464b-8d38-78c0d21cfd50	aad7f7e3-58c0-4704-ab6a-b05ed23d2ba6	mcq	The 'Facilitative' stance focuses on:	\N	1	3	2026-05-13 08:42:06.134593+00
b16b099e-cbd6-4d18-8452-a8c0e1434ea5	aad7f7e3-58c0-4704-ab6a-b05ed23d2ba6	mcq	In the 'Adaptive' framework, if a teacher is resistant, a coach should first:	\N	1	5	2026-05-13 08:42:07.154866+00
14d2e925-8b54-4552-aec1-282236fa014e	560afd3c-e56e-46ce-b79f-1438503b6518	mcq	The 'Partnership Advocate' identity is needed when:	\N	1	1	2026-05-13 08:42:10.899178+00
778a0c05-48b3-493c-ad10-4a3374b8c930	560afd3c-e56e-46ce-b79f-1438503b6518	mcq	An 'Advocacy Script' is used to:	\N	1	2	2026-05-13 08:42:11.356307+00
78aae87f-e8b2-4c94-904a-8744ca3f0145	560afd3c-e56e-46ce-b79f-1438503b6518	mcq	How does an Advocate handle a request to share 'Top 5 Worst Teachers' with a principal?	\N	1	3	2026-05-13 08:42:11.806453+00
e4892f9c-b218-4f5a-8ce8-e2e91b09990e	a6b8cb55-2667-4ea1-8937-61ca6f8e3edb	open	A teacher shares their schema data with you showing 30 min I Do, 3 min We Do, 2 min You Do. How do you use this data as a partnership mirror rather than a compliance checklist?	Score 2: Share data neutrally with timestamps; ask 'What was driving this structure today?'; teacher interprets intent; co-explore whether structure matched goals; teacher chooses any adjustment; no prescription of a 'correct' ratio. Score 1: Shares data and asks a question but steers toward a prescribed restructuring. Score 0: Tells the teacher the schema is wrong and prescribes a different ratio.	2	8	2026-05-11 14:02:58.342185+00
84c7800c-9714-4b7d-b629-4616124a004c	5ec96580-0327-4104-a9db-3bedbc80ec7c	mcq	What is the primary identity shift required in Unit 3.1?	\N	1	1	2026-05-13 08:19:53.98552+00
224c78b9-7bb0-4697-b950-7b3ec818e5e0	5ec96580-0327-4104-a9db-3bedbc80ec7c	mcq	The goal of a 'Mirror Specialist' is to:	\N	1	4	2026-05-13 08:19:55.355313+00
b5c0dfed-011e-4253-b298-56fcc87a1cc0	5ec96580-0327-4104-a9db-3bedbc80ec7c	open	You are observing a classroom where Ms. Bano is moving around frequently. You want to provide objective feedback. Write a low-inference observation note about what you see, and explain why your note passes the Camera Test.	Score 2: Observation uses counts, timestamps, specific locations, and direct quotes — no adjectives or interpretive language; Camera Test explanation says 'a video camera could capture this exactly.' Score 1: Observation is mostly factual but includes one interpretation word. Score 0: Observation contains subjective adjectives ('enthusiastic,' 'confused,' 'effective') without any factual counts or timestamps.	2	7	2026-05-13 08:19:56.697836+00
988ae0b9-9125-4cd8-a50c-c9fbfc504786	270d968d-141d-409f-8dbe-2d184c0c9f52	mcq	Why are artifacts better than handwritten notes for partnership?	\N	1	2	2026-05-13 08:19:59.457733+00
c929f7f7-35ad-4e8f-a2d8-7789789c9d5b	270d968d-141d-409f-8dbe-2d184c0c9f52	mcq	How should an artifact be introduced in a conversation?	\N	1	5	2026-05-13 08:20:01.095828+00
0b8f1d65-56ee-42a5-a3ba-39b0c472f415	270d968d-141d-409f-8dbe-2d184c0c9f52	open	A teacher is defensive about classroom management. The coach places a photo showing back-row students on their phones. How does this artifact lower defensiveness compared to the coach stating what they observed verbally?	Score 2: Artifact shifts focus from teacher personality to neutral 'Third Party' object — both partners look at the same thing; status threat decreases because the 'judge' is now the photo, not the coach; Equality is restored. Score 1: Says visuals are easier to understand without explaining the status-safety mechanism. Score 0: Says the photo proves the coach was right, treating the artifact as evidence for evaluation rather than a partnership tool.	2	8	2026-05-13 08:20:02.270623+00
0d16d4be-c195-4a36-956e-2e6c29012e4a	962105eb-60c7-4968-a632-f02660d52fc6	mcq	The core goal of Unit 3.3 is to move from 'Coach Monologue' to:	\N	1	1	2026-05-13 08:20:04.309165+00
13f2a09d-71e1-4edb-b538-64fc99802d46	962105eb-60c7-4968-a632-f02660d52fc6	mcq	What is a 'Dialogue Sparker'?	\N	1	3	2026-05-13 08:20:05.253645+00
ef9e8b31-2bfb-4340-9c3c-02361a3785a3	962105eb-60c7-4968-a632-f02660d52fc6	mcq	If a teacher sees an artifact and becomes self-critical, the coach should:	\N	1	4	2026-05-13 08:20:05.707299+00
c9cd60ea-9a25-4de2-ae9d-41d68a34d9f9	962105eb-60c7-4968-a632-f02660d52fc6	mcq	What defines 'Reciprocity' in a coaching dialogue?	\N	1	6	2026-05-13 08:20:06.599614+00
4d0c002b-d6fc-4a19-ac1e-bbd13a70d7e1	962105eb-60c7-4968-a632-f02660d52fc6	open	At the start of a debrief, the coach places a T-Chart on the table. Following the 'Teacher-First' interpretation rule, what should the coach do next and why does this matter?	Score 2: Ask an open question about what the teacher notices first, then wait (5+ seconds) for teacher to speak; explain that teacher interpretation reveals their mental model, builds ownership, and makes the subsequent co-analysis genuine rather than coached compliance. Score 1: Asks a question but skips explaining why teacher-first interpretation is essential. Score 0: The coach explains the data first before asking for the teacher's view.	2	7	2026-05-13 08:20:07.04455+00
926bfabe-7f35-4fae-8e6a-8db22c49ece4	962105eb-60c7-4968-a632-f02660d52fc6	open	A coach and teacher look at a T-Chart together. The teacher says: 'I did not realize I only called on students on the left side of the room.' They then plan a new seating arrangement together. Which Partnership Principle does this process represent, and why?	Score 2: Praxis (PP-6) — the intersection of Reflection and Action; teacher reflected on evidence (saw the pattern), produced insight, which converted to a specific real-world action; explains that without Praxis, coaching is just conversation that does not change classroom reality. Score 1: Names Praxis or Reflection without explaining the mechanism (reflection → insight → action). Score 0: Names a different principle or confuses the scenario with compliance or instruction.	2	8	2026-05-13 08:20:07.256161+00
a556bf4d-5df5-4678-8bca-fa612365ef3d	904752e4-b77f-4957-90ae-6a1336b84d53	mcq	Which of the following is a 'Partnership Annotation'?	\N	1	3	2026-05-13 08:42:00.739693+00
8c3defc0-6b2b-402e-871c-30f79f4d78d4	904752e4-b77f-4957-90ae-6a1336b84d53	mcq	How does the Digital Journal protect confidentiality?	\N	1	5	2026-05-13 08:42:01.793212+00
8f2bf155-3423-4ec4-a780-b52ef481462d	904752e4-b77f-4957-90ae-6a1336b84d53	open	A coach is creating a Digital Journal entry for a teacher's growth journey. They include a photo of a student's improved essay and add the note: 'Notice the shift in student engagement and clarity when you moved to the back row to support the Shadow students.' This note is an example of a 'Human Annotation.' Explain what makes it a Human Annotation and not just a data record.	Score 2: A Human Annotation adds three elements — observation (shift in student engagement), principle reference (PRAXIS — teacher's proactive movement), and a growth framing rather than an error framing; it transforms raw evidence into a story of professional agency. Score 1: Identifies that the annotation highlights growth without explaining what makes it 'human' (the partnership principles reference and the growth narrative arc). Score 0: Says it is a Human Annotation because it is encouraging or positive — without connecting to the specific structural elements.	2	7	2026-05-13 08:42:02.777013+00
3c1c66ce-bd3f-44f7-98fc-7fd6fcff457f	aad7f7e3-58c0-4704-ab6a-b05ed23d2ba6	mcq	'Directive' coaching is most appropriate when:	\N	1	2	2026-05-13 08:42:05.67017+00
c73ad48b-1251-468c-ba80-a26eebee97bd	aad7f7e3-58c0-4704-ab6a-b05ed23d2ba6	mcq	What is the 'Coaching Heavy' approach?	\N	1	4	2026-05-13 08:42:06.590201+00
604c7fc5-caa6-437c-a647-3c3cd8fe61c1	aad7f7e3-58c0-4704-ab6a-b05ed23d2ba6	mcq	'Reciprocity' in facilitation means:	\N	1	6	2026-05-13 08:42:07.599898+00
c75dcbc8-5cab-4a5a-9539-2f479a368911	aad7f7e3-58c0-4704-ab6a-b05ed23d2ba6	open	You are coaching a teacher who is currently facing a classroom safety crisis and feels completely overwhelmed. In this specific moment, which coaching stance is most appropriate and why?	Score 2: Directive — teacher cannot access reflective capacity in a crisis; clear, specific instructions ensure safety first; partnership resumes after the crisis. Explains that Directive is not a partnership failure — it is the right tool for the right moment. Score 1: Identifies Directive as correct without explaining why facilitative would be inappropriate in a crisis moment. Score 0: Argues for Facilitative even in a safety crisis, or says the coach should only observe.	2	7	2026-05-13 08:42:08.069383+00
acee6d37-82bd-4128-b71d-b6541049d675	aad7f7e3-58c0-4704-ab6a-b05ed23d2ba6	open	A teacher is showing resistance to coaching. An Adaptive Facilitator offers: 'Would you prefer to focus on your Check for Understanding questions or your Wait Time transitions first?' Why is this effective for a resistant teacher?	Score 2: Choice restores autonomy (SCARF), which reduces the resistance that comes from feeling controlled; both options are genuine; teacher now owns the direction; Quick Win choices build trust before deeper coaching is possible. Score 1: Says choice is good for buy-in without explaining the SCARF autonomy mechanism or Quick Win strategy. Score 0: Says it lets the coach avoid a difficult decision or 'tricks' the teacher into compliance.	2	8	2026-05-13 08:42:08.385079+00
cb20ce19-d1ba-45e4-a87c-d64bf16b43e8	560afd3c-e56e-46ce-b79f-1438503b6518	mcq	'Praxis' in advocacy means:	\N	1	4	2026-05-13 08:42:12.234516+00
8ee11721-406b-4d69-b8d7-1a5f879dc91b	560afd3c-e56e-46ce-b79f-1438503b6518	mcq	A 'Guardian of the Safe Space' protects:	\N	1	6	2026-05-13 08:42:13.262589+00
d902206a-fedd-4ef3-b137-de90c274aa28	9f6323c2-9d00-4cbb-98d8-6ac7b08f8700	mcq	What does 'WRER' stand for?	\N	1	1	2026-05-13 08:42:16.113462+00
13198a91-a8d8-429e-b1eb-ec38551ce7e0	9f6323c2-9d00-4cbb-98d8-6ac7b08f8700	mcq	If a coach has a low WRER score, it usually indicates:	\N	1	3	2026-05-13 08:42:17.027172+00
aa402ace-157f-4271-ae4f-e00e6b5787a0	9f6323c2-9d00-4cbb-98d8-6ac7b08f8700	mcq	What is the final step after calculating a weekly WRER?	\N	1	5	2026-05-13 08:42:17.938681+00
b0dbd781-3ae8-4658-9b15-c1fd1190f425	9f6323c2-9d00-4cbb-98d8-6ac7b08f8700	open	Explain why coaching consistency (frequency) matters more than coaching intensity (depth of single sessions) for long-term teacher development.	Score 2: Regular 2-week cycles create feedback loops that solidify new habits; single intense sessions fade without consistent follow-up; the IMPROVE phase requires a follow-up visit to confirm strategy impact; teachers who experience consistent coaching build trust and investment that enables deeper work over time. Score 1: States that frequency matters without explaining the mechanism (habit solidification via feedback loops). Score 0: Argues that one deep session per term is sufficient, or confuses frequency with workload.	2	7	2026-05-13 08:42:18.918731+00
e8ab8145-c006-482d-85b8-44f9f9d7244a	cda8db78-abfa-4f37-b6f9-14ac1b887bcc	mcq	The 'Choice Principle' (PP-2) ensures that:	\N	1	1	2026-05-13 08:42:36.844676+00
b82f6164-31f1-4cff-af0a-06530aed4446	cda8db78-abfa-4f37-b6f9-14ac1b887bcc	mcq	What does the teacher choose during the 'IDENTIFY' phase?	\N	1	3	2026-05-13 08:42:37.763857+00
9c50c020-0d6f-4793-91ed-84d1f0569225	cda8db78-abfa-4f37-b6f9-14ac1b887bcc	mcq	According to the 'Control vs. Partnership' comparison, the end goal of Partnership is:	\N	1	5	2026-05-13 08:42:38.636521+00
966267c2-afdb-4cdc-a31c-d4fd6e37b353	cda8db78-abfa-4f37-b6f9-14ac1b887bcc	open	During the 'Learn' phase, a teacher is struggling with student transitions. Instead of telling the teacher which method to use, the coach presents a 'Micro-skills Menu' featuring three different evidence-based strategies. Why is providing this 'Menu' essential for Partnership?	Score 2: Honors the Choice Principle (PP-2) — teacher is more likely to implement a strategy they chose; a menu with only one real option is a polite mandate; strategies teachers choose are implemented more faithfully than strategies assigned. Score 1: Says choice is good for buy-in without explaining the implementation mechanism. Score 0: Says the menu is useful because it proves the coach knows multiple strategies.	2	7	2026-05-13 08:42:39.601105+00
374aa3cf-943e-4a93-8ddf-4642afdebb4e	229e046e-83b3-48e5-9037-030d2601933a	mcq	To find the 'Why' behind a classroom struggle without triggering 'Status Denial,' a coach should use:	\N	1	2	2026-05-13 08:42:42.757892+00
358d96ac-6ef8-43b9-9d49-f60c2f60f3f2	229e046e-83b3-48e5-9037-030d2601933a	mcq	Which of these is a 'Curious Opener' designed to find the root cause?	\N	1	4	2026-05-13 08:42:43.621535+00
ba3acb16-9bf4-4619-8129-bea5c382163f	229e046e-83b3-48e5-9037-030d2601933a	mcq	A 'Weak Sample Answer' for diagnosing a gap would be:	\N	1	6	2026-05-13 08:42:44.628997+00
66938930-c4ce-41dc-8f45-3bb6a6bb3f23	95a07a48-ec69-49a5-b060-d4bef933f2f5	mcq	Side-by-Side Modeling is intended to be a:	\N	1	1	2026-05-13 08:42:47.554993+00
2e82d8dc-c750-4776-b7e6-2a184ec5b0de	95a07a48-ec69-49a5-b060-d4bef933f2f5	mcq	In 'Side-by-Side' coaching, the coach should describe:	\N	1	3	2026-05-13 08:42:48.493229+00
c9cee797-7b30-44e5-b2e9-d0508c0f28f1	95a07a48-ec69-49a5-b060-d4bef933f2f5	mcq	The teacher's selection of one of the 4 Paths should be based on:	\N	1	5	2026-05-13 08:42:49.427181+00
a7d5d842-65c2-457e-a1bd-70b1932fa84c	95a07a48-ec69-49a5-b060-d4bef933f2f5	open	A teacher has 50 students in a tiny classroom with broken furniture. The coach realizes the teacher's struggle with 'Simultaneous Monitoring' is a systemic issue. In this case, what should a 'Mastery' level coach do?	Score 2: Acknowledge the structural constraint (PP-7 Reciprocity); work with teacher to find strategies that reduce monitoring load for this context; advocate for resources or environmental shifts with administration; do NOT blame teacher for inability to overcome a structural impossibility. Score 1: Acknowledges constraint without naming PP-7 or explaining the advocacy step. Score 0: Tells teacher to work harder or ignores the physical environment.	2	7	2026-05-13 08:42:50.433239+00
ae429474-d231-4685-9d4a-93404adb4188	560afd3c-e56e-46ce-b79f-1438503b6518	mcq	The 'Coaching Folder' keyword is used to emphasize that data is:	\N	1	5	2026-05-13 08:42:12.791952+00
aafbb01a-3b98-46b9-8e28-4e68bce9bae5	560afd3c-e56e-46ce-b79f-1438503b6518	open	The Principal asks you for your 'evaluative notes' on the 'bottom 5' teachers in the building to help with a performance audit. Based on the Module 4 Mastery Rubric, what is the 'Strong Response'?	Score 2: Validate the Principal's improvement goal + set the confidentiality boundary + offer the School Growth Map alternative + explain why teacher choice and confidentiality matter for coaching effectiveness. Does not just refuse — provides a path forward. Score 1: Sets the boundary without offering an alternative or explaining the partnership principle. Score 0: Provides the names or gives the notes to maintain a good relationship with leadership.	2	7	2026-05-13 08:42:13.739765+00
a60f2ee1-7ec0-4ce8-b488-591d02d1b777	9f6323c2-9d00-4cbb-98d8-6ac7b08f8700	mcq	The 'Pulse Check' of coaching consistency is:	\N	1	2	2026-05-13 08:42:16.584441+00
3c7efc28-f4b9-4128-8274-38b3c3ed6ceb	9f6323c2-9d00-4cbb-98d8-6ac7b08f8700	mcq	'Reciprocity' in Unit 4.4 means:	\N	1	4	2026-05-13 08:42:17.487219+00
d0553835-b98f-477b-9ff8-c9a63394ee03	9f6323c2-9d00-4cbb-98d8-6ac7b08f8700	mcq	Inconsistency is viewed in this module as:	\N	1	6	2026-05-13 08:42:18.448551+00
1987cc3c-4ae6-458f-83da-7bcc9d42b532	cda8db78-abfa-4f37-b6f9-14ac1b887bcc	mcq	In the 'LEARN' phase, a coach should offer a 'Micro-skills Menu' consisting of:	\N	1	2	2026-05-13 08:42:37.283184+00
fa63cee5-560d-4f72-ba3f-18540ed4d869	cda8db78-abfa-4f37-b6f9-14ac1b887bcc	mcq	When students haven't met the goal in the 'IMPROVE' phase, which of these is a valid 'Pivot' option for the teacher?	\N	1	4	2026-05-13 08:42:38.197219+00
592cb5d8-bbb3-48f4-afa3-50e0a94d187e	cda8db78-abfa-4f37-b6f9-14ac1b887bcc	mcq	'Voice' (PP-3) in this unit means:	\N	1	6	2026-05-13 08:42:39.160394+00
f2a48cb5-2bc0-465a-97a8-4115f6163d82	229e046e-83b3-48e5-9037-030d2601933a	mcq	The identity shift in this unit is moving from an 'Inspector' to an:	\N	1	1	2026-05-13 08:42:42.257389+00
709715be-bcf0-469a-a9bf-9306bf04351a	229e046e-83b3-48e5-9037-030d2601933a	mcq	An 'Intellectual Gap' refers to:	\N	1	3	2026-05-13 08:42:43.181908+00
1cf8b77c-716f-481e-bc9a-f712f4724c46	229e046e-83b3-48e5-9037-030d2601933a	mcq	In the Pakistan public school context, 'Status Denial' is often triggered when a coach:	\N	1	5	2026-05-13 08:42:44.188751+00
3ba51364-24d8-4594-b57b-891ab710f665	229e046e-83b3-48e5-9037-030d2601933a	open	You observe a lesson where the teacher has a great plan, but students are confused because the instructions were delivered too quickly and without a visual aid. You diagnose this as a 'Training Loop' gap. According to the Precision Coaching framework, what is your next move and why?	Score 2: Training Loop = missing micro-move; intervention = Rehearsal or Role-play of the specific instruction-delivery move; NOT co-planning (that addresses Planning Loop) and NOT explanation (Training needs practice, not theory). Score 1: Identifies the need for practice without connecting to the specific Loop diagnosis. Score 0: Prescribes co-planning or a new lesson design when the plan itself is not the problem.	2	7	2026-05-13 08:42:45.220753+00
eee56778-7d8f-4895-bd77-05ae7494fe14	95a07a48-ec69-49a5-b060-d4bef933f2f5	mcq	During an 'Improve' phase meeting, if engagement moved from 40% to 55% against a target of 80%, the teacher must choose:	\N	1	2	2026-05-13 08:42:47.980016+00
ad5e9483-1873-4a22-a1e2-3a196afa6c0b	95a07a48-ec69-49a5-b060-d4bef933f2f5	mcq	Co-modeling scripts and Improve meeting agendas should end with:	\N	1	4	2026-05-13 08:42:48.997143+00
36c682d7-159d-4584-b8b0-357688dad2bd	95a07a48-ec69-49a5-b060-d4bef933f2f5	mcq	'Closing the Loop' focuses on whether:	\N	1	6	2026-05-13 08:42:49.93379+00
a453c8eb-75bb-4daa-b46e-ba3a89d4a043	560afd3c-e56e-46ce-b79f-1438503b6518	open	Your WRER data shows you completed only 40% of your scheduled coaching visits this month because you were asked to cover absent teacher classes. How should you use this data?	Score 2: Use it as objective evidence in a conversation with the principal to name 'displaced time' as a systemic issue (not a personal failing); WRER converts the invisible to visible; present a Response Plan for the following week. Score 1: Identifies the data should be shared with the principal without explaining the mechanism (systemic displacement vs. personal failure framing). Score 0: Hides the data to avoid appearing lazy, or accepts the displacement as normal without documenting it.	2	8	2026-05-13 08:42:13.956102+00
ea3dd0c3-a972-476b-a020-6130f31d376b	229e046e-83b3-48e5-9037-030d2601933a	open	A teacher is frustrated because students are not participating in group work. The lesson plan shows students are put in groups but given no roles or task structure. This is a 'Planning Loop' gap. What is the most effective intervention and why?	Score 2: Co-Planning session to add specific student roles and task structure to the lesson plan; explains that this is a DESIGN gap (teacher-behavior script without student-response map), not a delivery gap; modeling or videos would address wrong loop. Score 1: Identifies co-planning without explaining why other interventions are wrong for this loop. Score 0: Recommends a lecture on collaborative learning theory or watching a video of a different teacher.	2	8	2026-05-13 08:42:45.435522+00
f75a042a-0e48-42d2-84da-41150dd243e8	9f6323c2-9d00-4cbb-98d8-6ac7b08f8700	open	A colleague coach says: 'I only completed 2 of 5 scheduled coaching visits this week — I must not be committed enough.' Using the WRER framework, how would you respond?	Score 2: Low WRER signals a systemic issue (displacement), not personal failing; coach should calculate WRER, document the specific causes, and use data to name systemic displacement to administration; the Consistency Guardian role is about advocating for coaching time, not self-blame. Score 1: Says the issue may be systemic without applying the WRER framework or Response Plan. Score 0: Agrees the coach needs to be more committed or suggests working harder without addressing the systemic cause.	2	8	2026-05-13 08:42:19.142329+00
3d840436-8d57-4f6a-bfc6-071c5bd75887	cda8db78-abfa-4f37-b6f9-14ac1b887bcc	open	A teacher's class has not met their PEERS goal during the 'Improve' phase. The coach asks: 'Do you want to stick with this strategy but practice it more, or pivot to a different strategy from our menu?' Why does this approach keep the teacher in a learning state rather than a failure state?	Score 2: Teacher reads own evidence and chooses the path (Voice + Agency); framing as 'two genuine options' preserves choice at the most vulnerable moment; teacher does not experience the unmet goal as personal failure but as data to inform a decision. Score 1: Says choice reduces shame without explaining the mechanism. Score 0: Says the question forces the teacher to admit they chose the wrong goal.	2	8	2026-05-13 08:42:39.893013+00
577c671c-89b1-4c1c-b8d4-d5f4f0223884	95a07a48-ec69-49a5-b060-d4bef933f2f5	open	After six months of coaching, a teacher starts using the '3 Loops' logic to diagnose their own lessons before the coaching visit. This represents 'Obsolescence.' What does coaching Obsolescence mean and why is it the highest measure of coaching success?	Score 2: Obsolescence = coaching framework becomes an internal habit for the teacher; teacher coaches themselves; this is the highest measure because change now outlasts the coaching relationship; the teacher no longer needs the coach to diagnose problems — they have internalized the process. Score 1: Describes the teacher being self-sufficient without explaining why this is the measure of coaching success. Score 0: Confuses Obsolescence with the coaching program ending or the teacher no longer needing to grow.	2	8	2026-05-13 08:42:50.665618+00
1c20a9c4-996a-4935-9957-ecc3b6d43ed1	8763b4df-e37f-4187-a676-a87acef38d76	mcq	The shift in this unit is from 'Blaming Effort' to:	\N	1	1	2026-05-13 08:42:52.744625+00
d8a65e3d-3827-44ab-828b-e2614d94abb4	8763b4df-e37f-4187-a676-a87acef38d76	mcq	A 'Planning Loop' gap occurs when the plan is:	\N	1	2	2026-05-13 08:42:53.20007+00
c4bdadbe-5274-4e68-a285-e77314c68cdd	8763b4df-e37f-4187-a676-a87acef38d76	mcq	The 'Training Loop' involves mastering:	\N	1	3	2026-05-13 08:42:53.635068+00
f5146881-3c15-40a1-a13c-de6066401540	8763b4df-e37f-4187-a676-a87acef38d76	mcq	According to PP-7 (Reciprocity), a coach recognizes that systemic issues like class size can make:	\N	1	4	2026-05-13 08:42:54.063776+00
ff2600cc-ca90-4fcb-b20b-c21325242ba1	8763b4df-e37f-4187-a676-a87acef38d76	mcq	The goal of the 3 Loops framework is its own:	\N	1	5	2026-05-13 08:42:54.518415+00
e329215c-4afd-42aa-8474-9bd593c22dd8	8763b4df-e37f-4187-a676-a87acef38d76	mcq	In Precision Coaching, you should always:	\N	1	6	2026-05-13 08:42:54.954192+00
f89cddbb-6069-4116-b1d8-bed69bb243c8	8763b4df-e37f-4187-a676-a87acef38d76	open	Explain the difference between a 'Planning Loop' gap and a 'Training Loop' gap, and give a specific example of each from a Pakistan classroom context.	Score 2: Planning Gap = lesson plan does not anticipate student responses (teacher-behavior script); Training Gap = teacher has good plan but lacks a specific micro-move for execution; Pakistan examples show awareness of local constraints (large classes, limited resources, Urdu-medium instruction). Score 1: Distinguishes the two loops without Pakistan-specific examples. Score 0: Confuses the two loops or describes both as teacher personality problems.	2	7	2026-05-13 08:42:55.408059+00
ec4bba73-c288-451a-80e7-4b4b937abff0	8763b4df-e37f-4187-a676-a87acef38d76	open	Why is it important to diagnose the loop BEFORE naming the coaching intervention? What happens if the coach names the wrong intervention for the wrong loop?	Score 2: Wrong intervention for wrong loop wastes time — co-planning for a Training gap does not develop the missing micro-move; role-play for a Planning gap does not fix the design; precision means matching the exact intervention to the exact root cause. Score 1: States that diagnosing first is better without explaining the consequence of misdiagnosis. Score 0: Says all interventions are equivalent or that the teacher should choose any intervention they prefer.	2	8	2026-05-13 08:42:55.639602+00
e1f5422f-abeb-4d90-9264-f94c275b3888	d5c05d52-8f4b-4e23-abc7-c2c4c82e37fd	mcq	In the Pakistan school context, a coaching cycle 'leaks' when:	\N	1	1	2026-05-13 08:43:12.830787+00
7e6c56a9-a073-4677-9b2a-0cbf4d9b6b10	d5c05d52-8f4b-4e23-abc7-c2c4c82e37fd	mcq	When 'Closing the Loop,' the coach's identity shifts from 'Inspector' to:	\N	1	2	2026-05-13 08:43:13.319387+00
cea69bd5-af6c-40bc-a8bc-bc06e960197c	d5c05d52-8f4b-4e23-abc7-c2c4c82e37fd	mcq	Closing the Loop is the bridge between which two phases of the Impact Cycle?	\N	1	3	2026-05-13 08:43:13.749315+00
8175f4c5-e917-42f7-ba23-fbe1850a9c87	d5c05d52-8f4b-4e23-abc7-c2c4c82e37fd	mcq	Which is a 'Curious Opener' designed to replace judgmental statements?	\N	1	4	2026-05-13 08:43:14.303591+00
a135be5a-cc68-47c4-90d4-0728d2eb23d4	d5c05d52-8f4b-4e23-abc7-c2c4c82e37fd	mcq	A 'Strong Action Step' in the follow-up protocol must be:	\N	1	5	2026-05-13 08:43:14.906828+00
8d261442-91e4-40b3-88a2-51a6626a020f	d5c05d52-8f4b-4e23-abc7-c2c4c82e37fd	mcq	The purpose of returning to the classroom to 'Close the Loop' is to:	\N	1	6	2026-05-13 08:43:15.436321+00
f71cedd8-fbda-4d19-85fd-a6a6218cc51a	d5c05d52-8f4b-4e23-abc7-c2c4c82e37fd	open	You had a great 'Learn' session with a teacher about using a 'No-Hands-Up' questioning strategy. When you return, the teacher has reverted to only calling on students who raise their hands. This is a 'Leaky' coaching cycle. What is the most effective way to 'Close the Loop'?	Score 2: Use a Curious Opener — 'I noticed the No-Hands-Up strategy was not used today — what barrier got in the way?' — Co-Pilot identity (looks for progress, not compliance); the barrier may be legitimate; opens productive conversation rather than punishing non-compliance. Score 1: Identifies using a curious question without explaining the Co-Pilot framing or the loop-closure mechanism. Score 0: Invokes principal authority or marks teacher as not proficient.	2	7	2026-05-13 08:43:15.932408+00
b7eedf4a-694c-4280-8bc3-9498b6b2ab3c	d5c05d52-8f4b-4e23-abc7-c2c4c82e37fd	open	During a follow-up, a teacher says: 'I tried the timer, but it made the students anxious, so I stopped using it.' A 'Mastery' level coach should respond by facilitating a 'Pivot.' What does this mean and how does it preserve teacher choice?	Score 2: The Pivot uses the 4 Paths — Modify (adjust implementation, e.g., visual signal instead of loud beep) or Switch (try another menu option); teacher has real evidence (student anxiety) that justifies re-evaluating the strategy; teacher chooses the path, not the coach; student evidence is honored, not dismissed. Score 1: Describes offering alternatives without applying the 4 Paths or explaining that the teacher must choose. Score 0: Mandates the teacher keep using the timer because it is evidence-based.	2	8	2026-05-13 08:43:16.239468+00
d2909b7d-3324-4434-954a-bcb94c88d8f7	48be70f3-cd8e-4d6a-8830-3523ca03f3b6	mcq	The 'Protocol Guardrail' is primarily used to ensure the coach:	\N	1	1	2026-05-13 08:43:18.371295+00
5ba71a7e-777e-450d-a666-833ed562ed6d	48be70f3-cd8e-4d6a-8830-3523ca03f3b6	mcq	'Status Confirmation' serves as a guardrail by:	\N	1	2	2026-05-13 08:43:18.800895+00
ca4dc07a-516e-435c-86ca-a49c6d4942df	48be70f3-cd8e-4d6a-8830-3523ca03f3b6	mcq	If a coach uses 'Evaluative Adjectives' (e.g., 'That was a bad start'), they have:	\N	1	3	2026-05-13 08:43:19.261422+00
284e57cf-5d2f-48b0-bfa0-ff34c3f6489c	48be70f3-cd8e-4d6a-8830-3523ca03f3b6	mcq	The 'Improve' phase guardrail requires the teacher to choose one of the '4 Paths.' These paths are:	\N	1	4	2026-05-13 08:43:19.694741+00
5edd2022-7ca4-4c60-8096-621b895269d0	48be70f3-cd8e-4d6a-8830-3523ca03f3b6	mcq	A protocol is considered a 'Guardrail' because it:	\N	1	5	2026-05-13 08:43:20.164433+00
663af793-72ec-4cce-b70e-134dc23d9e19	48be70f3-cd8e-4d6a-8830-3523ca03f3b6	mcq	Data shared within the Protocol Guardrail should always be:	\N	1	6	2026-05-13 08:43:20.617323+00
ea2d4750-8c08-4bd8-a449-e8db0abf58b2	9aca817e-4677-4a63-8d7b-82a92af39909	mcq	'Responsive Contextualization' requires a coach to:	\N	1	1	2026-05-13 08:43:23.642469+00
f9ac7b07-4a36-47dd-991a-74e0b5fc1200	9aca817e-4677-4a63-8d7b-82a92af39909	mcq	The 'Human Filter' is essential in this unit because:	\N	1	3	2026-05-13 08:43:24.564883+00
1b20cc63-dfe2-4c69-9676-f27912f7441e	9aca817e-4677-4a63-8d7b-82a92af39909	mcq	A coach modeling a 'Workaround' for a missing textbook is an example of:	\N	1	5	2026-05-13 08:43:25.485897+00
462d9078-2bcb-4ae8-9b76-b7db4d2ca60d	9aca817e-4677-4a63-8d7b-82a92af39909	open	A teacher expresses fear about trying a new risky activity. The coach says: 'I am taking a professional risk by protecting our confidentiality so that you can feel safe taking a risk with your teaching.' Why is this an example of Reciprocity (PP-7)?	Score 2: Reciprocity = both parties take reciprocal risks in service of the partnership; coach's risk is professional (confidentiality protection); teacher's risk is pedagogical (trying something new that might fail); the Sacred Space is maintained through mutual risk-taking, not just coach protection. Score 1: Identifies that both take risks without explaining the mechanism of mutual risk in service of growth. Score 0: Describes Reciprocity as personal friendship or transactional exchange.	2	7	2026-05-13 08:43:26.37527+00
9a7873c8-f9e0-4222-8d4a-cb55271a5e1a	51bf362f-b54f-4dd5-951c-1de885256a3f	mcq	'Audit Culture' is dangerous to coaching because it triggers:	\N	1	2	2026-05-13 08:43:29.45737+00
4c8f4de0-ca83-4898-b425-d7a958bb3441	51bf362f-b54f-4dd5-951c-1de885256a3f	mcq	The 'Sacred Space' is the professional boundary that ensures:	\N	1	4	2026-05-13 08:43:30.353845+00
17089d38-861c-4491-bb37-be0f8330ae87	51bf362f-b54f-4dd5-951c-1de885256a3f	mcq	Professionalism in Unit 6.4 is defined as:	\N	1	6	2026-05-13 08:43:31.326107+00
15250b32-b46d-459b-ae11-de8047bf05da	48be70f3-cd8e-4d6a-8830-3523ca03f3b6	open	Your Principal calls into their office and says: 'Give me the names of the three weakest teachers you are coaching so I can decide whose contracts not to renew.' Based on the Module 6 Mastery Rubric, what is the Strong Response?	Score 2: Validate the Principal's improvement goal + Redirect to aggregate trends + Hold the confidentiality boundary + Offer a monthly trend report alternative — explain why individual data would end coaching effectiveness for everyone. Score 1: Holds the boundary without offering an alternative or explaining the mechanism. Score 0: Provides the names or gives data about individuals.	2	7	2026-05-13 08:43:21.213975+00
61d353df-b1fe-4e67-8cd5-50c89712c1ae	48be70f3-cd8e-4d6a-8830-3523ca03f3b6	open	Explain the difference between 'Compliance-Based Professionalism' and 'Integrity-Based Professionalism' in Unit 6.2. Give a specific example of each.	Score 2: Compliance = following administrative commands (sharing notes, ranking teachers) even when it harms coaching; Integrity = guarding the partnership standard even under institutional pressure; example of compliance: sharing coaching notes to avoid conflict with principal; example of integrity: explaining why coaching notes cannot be shared while offering a legitimate alternative. Score 1: Distinguishes the two without specific examples. Score 0: Says integrity means keeping secrets or being uncooperative with administration.	2	8	2026-05-13 08:43:21.447376+00
e88dccc6-dcd5-41a6-8c7f-c097c5fb1232	9aca817e-4677-4a63-8d7b-82a92af39909	mcq	'Praxis' (PP-6) is the realization that learning happens through:	\N	1	2	2026-05-13 08:43:24.132601+00
95a06f9a-8339-4bf8-a0ab-185c375ed133	9aca817e-4677-4a63-8d7b-82a92af39909	mcq	Reflection without action (Praxis) results in:	\N	1	4	2026-05-13 08:43:25.008094+00
37640a86-ad5a-4416-a28f-7d17f034841a	9aca817e-4677-4a63-8d7b-82a92af39909	mcq	The goal of Praxis in Module 6 is to turn 'Coaching Conversations' into:	\N	1	6	2026-05-13 08:43:25.908248+00
5ea36ccf-5aec-45ed-aeb4-18c21739e93a	51bf362f-b54f-4dd5-951c-1de885256a3f	mcq	In the context of Unit 6.4, 'Reciprocity' means:	\N	1	1	2026-05-13 08:43:28.964691+00
3d16617f-79e2-43c4-973e-dbeafb13c012	51bf362f-b54f-4dd5-951c-1de885256a3f	mcq	When a Principal asks for names of 'failing' teachers, the Reciprocity Defense suggests:	\N	1	3	2026-05-13 08:43:29.903555+00
9c3cd2e1-8de8-48b2-80ac-cf435d96e5d9	51bf362f-b54f-4dd5-951c-1de885256a3f	mcq	A 'Strong' response to administrative pressure involves:	\N	1	5	2026-05-13 08:43:30.81731+00
3fed08b3-5ea8-480f-9eb4-12daf9d2f777	51bf362f-b54f-4dd5-951c-1de885256a3f	open	You are asked by a district official to share your Coaching Journal notes which contain a teacher's private reflections. How does a 'Mastery' coach define Professionalism in this moment?	Score 2: Integrity-Based Professionalism = guarding the partnership even under system pressure; explain that the journal is a developmental tool whose power depends on confidentiality; sharing it destroys coaching effectiveness for every teacher, not just this one; offer an aggregate alternative while holding the boundary. Score 1: Refuses to share without explaining the principle behind the refusal. Score 0: Complies because the official is higher in the hierarchy, or deletes the notes without addressing the request.	2	7	2026-05-13 08:43:31.760967+00
75e7be87-e4d4-411f-adc6-322d9d6055d1	51bf362f-b54f-4dd5-951c-1de885256a3f	open	What is the 'Sacred Space' in partnership coaching, and what happens to coaching effectiveness when it is breached?	Score 2: Sacred Space = the professional boundary ensuring coaching remains developmental (not evaluative); breach consequences: teachers perform rather than partner, hide struggles, stop being vulnerable, coaching becomes inspection; rebuilding takes months of consistent boundary-holding; every breach affects not just the individual relationship but the entire coaching climate of the school. Score 1: Defines the Sacred Space without explaining the specific consequences of a breach. Score 0: Confuses Sacred Space with a physical location or describes it as keeping secrets.	2	8	2026-05-13 08:43:31.973913+00
04ed12ca-410a-409e-8311-d86b57f405e7	9aca817e-4677-4a63-8d7b-82a92af39909	open	Describe what 'Responsive Contextualization' means and give a Pakistan-specific example of when a coach would need to apply it before sharing a strategy with a teacher.	Score 2: Responsive Contextualization = adjusting strategies to fit actual classroom constraints before presenting them; Pakistan example shows awareness of local reality (class size 60+, no electricity/devices, Urdu-medium, resource constraints); the coach applies the Human Filter (Context question) to the strategy before presenting it. Score 1: Defines contextualization without a specific Pakistan example. Score 0: Says it means using local language or building rapport.	2	8	2026-05-13 08:43:26.695611+00
\.


--
-- Data for Name: regions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.regions (id, name, code, coordinates, parent_id, created_at, is_active, updated_at) FROM stdin;
\.


--
-- Data for Name: scenario_options; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.scenario_options (id, scenario_id, option_letter, option_text, is_correct, rationale, principle_tag, created_at, feedback, is_optimal, order_number, updated_at) FROM stdin;
\.


--
-- Data for Name: scenario_responses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.scenario_responses (id, user_id, scenario_id, response_text, created_at, selected_option_id, "timestamp") FROM stdin;
\.


--
-- Data for Name: scenarios; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.scenarios (id, unit_id, order_number, situation, question, difficulty, feedback_slides, reveal_content, deep_content, is_active, created_at, updated_at, title, description) FROM stdin;
\.


--
-- Data for Name: session_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.session_events (id, user_id, module_id, training_id, context_page, category, rating, positive_feedback, improvement_feedback, persona, user_agent, created_at) FROM stdin;
b8d763ea-3778-493b-80c7-f6a3817bbe3d	531e9525-9f03-4a02-81e9-1d4ed5100e38	null	null	/dashboard	platform	3	test	test	A	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-04-28 08:02:12.626861+00
b8d763ea-3778-493b-80c7-f6a3817bbe3d	531e9525-9f03-4a02-81e9-1d4ed5100e38	null	null	/dashboard	platform	3	test	test	A	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	2026-04-28 08:02:12.626861+00
\.


--
-- Data for Name: session_notes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.session_notes (id, session_id, content, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: teacher_dc_scores; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.teacher_dc_scores (id, teacher_name, school_name, region, grade, subject, total_score, framework, scored_at, raw_results, created_at) FROM stdin;
10c814f5-b989-4064-901b-7e619a7166af	Mehwish Rehman	IMSG(I-V)TAMMA	Nilore	5	Eng	7	FICO	2026-01-21 00:00:00+00	{"subject_command": 0.0, "critical_thinking": 0.0, "effective_pedagogy": 0.0, "overall_percentage": 12.5, "inclusive_practices": 2.0, "technology_handling": 0.0, "verbal_communication": 0.0, "student_participation": 0.5, "effective_resource_use": 0.0, "technology_integration": 0.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 0.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
f561d9bd-56f9-44a8-af76-68645b92157a	Rabia Ramzan	IMS(I-V) G-6/1-2	Urban-I	5	Maths	10	FICO	2026-01-30 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 0.8, "overall_percentage": 19.166666666666668, "inclusive_practices": 1.0, "technology_handling": 0.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 0.0, "technology_integration": 0.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 0.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
52627f63-8325-467f-9b5a-042d594e10e3	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Tarnol	5	Science	13	FICO	2026-01-20 00:00:00+00	{"subject_command": 0.0, "critical_thinking": 0.0, "effective_pedagogy": 0.8, "overall_percentage": 24.615384615384617, "inclusive_practices": 0.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 2.0, "technology_integration": 4.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 0.0}	2026-05-12 16:32:28.498483+00
dc7a3442-9b97-4a00-82ac-c664122d01a8	Risfa Naveed	IMCG, F-7/4	Urban-I	5	Maths	15	FICO	2025-12-17 00:00:00+00	{"subject_command": 0.0, "critical_thinking": 0.0, "effective_pedagogy": 0.8, "overall_percentage": 28.46153846153846, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 2.0, "technology_integration": 4.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 0.0}	2026-05-12 16:32:28.498483+00
8d041630-e87e-4b89-ac8f-4351442f5498	Samia Zakir	IMCB G-13/2	Tarnol	4	Urdu	22	FICO	2026-01-21 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 1.6, "overall_percentage": 41.53846153846154, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 0.0}	2026-05-12 16:32:28.498483+00
994b405a-28f9-4117-9e0e-b877d43a6452	Saima Zubair	IMS (I-VIII) D-17	Tarnol	4	Maths	22	FICO	2026-02-03 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 1.6, "overall_percentage": 42.82051282051282, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.0, "effective_resource_use": 2.0, "technology_integration": 4.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
38aeb98c-09f6-4849-abf6-e0bd04ac48be	Sobia maqsood	IMCG,THANDA PANI (FA)	Nilore	5	Urdu	26	FICO	2026-01-26 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 1.6, "overall_percentage": 49.23076923076923, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 0.0}	2026-05-12 16:32:28.498483+00
08482a9f-54ee-435f-ad6c-df45a9d9445d	Farzana Gul Afridi	IMS(I-V) G-6/1-2	Urban-I	1	Maths	26	FICO	2026-01-30 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.6666666666666666, "effective_pedagogy": 2.4, "overall_percentage": 50.44871794871795, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 2.0, "technology_integration": 4.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
d0e16373-b433-4425-89d0-59a8a75b90a4	FOUZIA KAUSER	IMSG (I-V) Sihala Khurd	Sihala	4	Urdu	27	FICO	2026-02-12 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 1.6, "overall_percentage": 51.7948717948718, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 0.0}	2026-05-12 16:32:28.498483+00
30c92cc5-09d9-41cc-88eb-7550382643f8	Kausar Perveen	IMS(I-V) G-6/1-2	Urban-I	2	Maths	27	FICO	2026-02-06 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 1.6, "overall_percentage": 51.7948717948718, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 0.0}	2026-05-12 16:32:28.498483+00
50bb5332-9197-4145-8212-e7b23308ad92	TAJ MASIH	IMSB(I-V)SOHAN	Nilore	3	Urdu	27	FICO	2026-01-22 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.0, "effective_pedagogy": 2.4, "overall_percentage": 52.05128205128206, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 2.0, "technology_integration": 4.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
fea275a7-6dbd-4b10-bb45-f13141f2fb6c	Tanveer Abbas	IMSB (I-V) Darwala	Sihala	1	Eng	30	FICO	2026-01-21 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 1.6, "overall_percentage": 57.56410256410256, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 2.0}	2026-05-12 16:32:28.498483+00
f49ce70e-db84-4acd-99bf-e74f1469118c	Robina Tahir	IMS(I-V) No.1 G-8/1	Urban-I	2	Maths	32	FICO	2026-01-28 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 1.6, "overall_percentage": 61.08974358974359, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 1.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
eea308fb-45bd-467b-a904-c6a3a6e85f66	SAIMA NAZ	IMS (I-V) G-6/1-3	Urban-I	4	Eng	32	FICO	2026-02-10 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.6666666666666666, "effective_pedagogy": 2.4, "overall_percentage": 61.98717948717949, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
a1b23183-2d07-478a-bc09-509d5b20b3b5	HAFIZ AKHTER REHMAN	IMSB(I-V)SOHAN	Nilore	5	Urdu	32	FICO	2026-01-22 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 62.243589743589745, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
643d4335-fffb-431d-91b5-2c107921dc57	Safia Akbar	IMCB G-15	Tarnol	4	Urdu	34	FICO	2026-01-20 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.0, "effective_pedagogy": 2.4, "overall_percentage": 64.87179487179488, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 1.3333333333333333, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
d933cf76-a0d3-40c1-8169-ccd9a4e4a574	Tahira saeed	IMCB, F-8/4	Urban-I	2	Maths	35	FICO	2026-01-27 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.0, "effective_pedagogy": 2.4, "overall_percentage": 67.43589743589743, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
c0509280-05e1-4ada-94e0-13c86288bda5	Fiza Zeb	IMS(I-V) G-6/1-2	Urban-I	5	Science	36	FICO	2026-01-22 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.0, "effective_pedagogy": 2.4, "overall_percentage": 68.39743589743588, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
0af0328f-751a-4401-93b8-7fef87b9b568	UM-E-KALSOOM	IMSG(I-V) NILORE	Nilore	5	Maths	36	FICO	2025-12-19 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 2.4, "overall_percentage": 69.03846153846153, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
a721e4c7-9b1f-4011-b8d7-dd31aa0a2451	ABDUL HADI HAFEEZ AHMAD	IMSB (I-V) Karamabad	Tarnol	1	Urdu	36	FICO	2026-01-16 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 2.4, "overall_percentage": 69.35897435897435, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 1.3333333333333333, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
d1c5a6f7-ddc3-4498-a019-a76b0e15bebe	Shumaila Shafiq	IMCG, F-7/4	Urban-I	1	Maths	36	FICO	2025-12-17 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 2.4, "overall_percentage": 70.0, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
484a58bd-7d83-4e48-84bc-f7f24670f445	Humma rahim	IMCB, F-8/4	Urban-I	1	Urdu	37	FICO	2026-02-03 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.0, "effective_pedagogy": 2.4, "overall_percentage": 70.32051282051282, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
19dd5214-2cd2-420a-b7b5-61ad9acfa193	Matee Ullah Khan	IMSB (I-X) Maira Beri(F.A)	Tarnol	4	Maths	38	FICO	2026-01-28 00:00:00+00	{"subject_command": 4.0, "critical_thinking": 2.0, "effective_pedagogy": 4.0, "overall_percentage": 72.11538461538461, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
78612d4f-48d2-4646-90a3-a8774dbc626f	Tasneem Akhtar	IMSG (I-V) Sheikhpur Noon	Tarnol	3	Urdu	38	FICO	2026-01-30 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 72.82051282051282, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 2.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
c68a5055-016c-41ab-92d6-015b33afaad3	Rehana Aftab	IMS(I-V) No.2 G-9/2	Urban-II	2	Eng	38	FICO	2025-12-17 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 73.78205128205128, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
b7cdf89a-3387-4ad2-b106-0a14189111ae	Nadeema bibi	IMSG (I-VIII), BOBRI	B.K	2	Maths	38	FICO	2026-01-27 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 73.78205128205128, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 3.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
ddd01547-74d8-4ada-90d1-96709b3d165c	TANWIR AHMED KHAN	IMSB(I-V)KHANNA KAK	Nilore	1	Eng	38	FICO	2026-01-16 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 73.78205128205128, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
7a16a66f-68f8-40e4-883a-83d18134d79e	SAJIDA BANO	IMSG(I-V) JHANG SYEDAN	Nilore	4	Urdu	39	FICO	2026-01-19 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 74.74358974358975, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
2694ccca-3a7c-484e-9a89-afb851d0ed30	Fakhira bibi	IMCB G-13/2	Tarnol	5	Urdu	39	FICO	2026-01-16 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 74.74358974358975, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
5dd6795e-07d2-4d48-91bc-1e16a1b82d7f	Noureen lqbal	IMSG (I-V) Sheikhpur Noon	Tarnol	5	Maths	39	FICO	2026-01-30 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 74.74358974358975, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 2.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
55b50425-9c3f-4623-bc30-17ea46edc123	Zaitoon Noor	IMCG,THANDA PANI (FA)	Nilore	3	Eng	39	FICO	2026-01-26 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 75.38461538461537, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
85f5c6b4-54be-4933-b4e6-beacb3422996	Benazir	IMSG (I-VIII) I-9/4	Urban-II	1	Urdu	39	FICO	2026-01-20 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 75.7051282051282, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
76aea43b-f454-4016-bab1-d47b21246156	Nusrat	IMSG(I-V)TAMMA	Nilore	1	Urdu	40	FICO	2026-01-21 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 76.34615384615384, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
a5bc9482-1bdb-4094-9006-0724362088cb	Khalid Hussain Shah	IMSB(I-V)SHARIFABAD	Nilore	2	Maths	40	FICO	2026-01-16 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 76.34615384615384, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
cd5e2ce5-933c-461d-b3de-9dbdba978e24	Jamila Bibi	IMSG(I-V) ALI PUR SOUTH	Nilore	1	Urdu	40	FICO	2025-12-18 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 76.34615384615384, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
2829cda0-51cd-463a-a930-65be3a7154d6	Aiman Mujahid	IMCB,JABA TALI	Nilore	1	Urdu	40	FICO	2026-01-21 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 76.34615384615384, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
3ed41905-eba5-440e-834a-b1ef68f59a17	Bushra Bano	IMSG (I-V) Herdogher	Sihala	3	Eng	40	FICO	2026-02-12 00:00:00+00	{"subject_command": 4.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 4.0, "overall_percentage": 76.6025641025641, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 2.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
599e7d09-2bb0-4d22-9961-1769804064f4	Nadia Jabeen	IMSG (I-VIII) G-8/4	Urban-I	5	Maths	40	FICO	2026-01-21 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.6666666666666666, "effective_pedagogy": 3.2, "overall_percentage": 76.98717948717947, "inclusive_practices": 4.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
e126bd5c-0c43-40b0-9bfb-d18eb5dee335	Ghulam Murtaza (S.E.T)	IMSB(I-VIII) ALI PUR	Nilore	3	Urdu	40	FICO	2026-01-21 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 77.30769230769229, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
e53571c3-a105-4584-9b79-2986158084f4	Samina Sheikh	IMSG (I-VIII) I-9/4	Urban-II	5	Maths	41	FICO	2026-02-10 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 78.26923076923076, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
19b40cf1-5662-44ed-8e6b-eb8e98995e93	Shaheen Bibi	IMS (I-V) G-7/3-3	Urban-I	2	Urdu	41	FICO	2026-01-15 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 78.26923076923076, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
7baddac8-5131-46f6-9a75-b74e86bc008f	QARI MUHAMMAD IKRAM	IMSB(I-X) TUMAIR	Nilore	2	Urdu	41	FICO	2026-02-02 00:00:00+00	{"subject_command": 4.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 4.0, "overall_percentage": 78.52564102564101, "inclusive_practices": 4.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
3b67da4b-b2f4-420a-add4-ac4a258d3d77	M Basharat Satti	IMCB,JABA TALI	Nilore	5	Maths	41	FICO	2026-01-15 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 2.0, "effective_pedagogy": 3.2, "overall_percentage": 78.58974358974359, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
ba92f963-0136-43ba-a3fb-86334885cb38	Gulshan Habib	IMSG (I-VIII) G-7/3-2	Urban-I	1	Maths	41	FICO	2026-01-22 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 79.23076923076923, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 3.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
f617fddc-dd11-4da9-8231-691b0de96319	Nazia Nargis	IMS(I-V) PIMS G-8/3	Urban-I	2	Urdu	41	FICO	2025-12-22 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 79.23076923076923, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 3.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
20d33018-a0f3-4384-a054-634532a8b024	Bushra Islam	IMSG (I-VIII) G-8/4	Urban-I	1	Maths	41	FICO	2026-02-02 00:00:00+00	{"subject_command": 4.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 4.0, "overall_percentage": 79.48717948717949, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
1250579d-0c65-4c83-9fd9-4b705b10ef2e	Asma Abassi	IMSG (I-X) SHAHDRA KHURD	B.K	4	Maths	42	FICO	2026-01-20 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 2.0, "effective_pedagogy": 3.2, "overall_percentage": 80.1923076923077, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 2.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
d929a973-2a75-42df-9bcc-f6edf9f90c93	Kaneez Fatima	IMSG (I-VIII) F-7/4	Urban-I	5	Maths	42	FICO	2026-01-16 00:00:00+00	{"subject_command": 4.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 4.0, "overall_percentage": 80.44871794871794, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-12 16:32:28.498483+00
861bf9f3-16e7-4b24-a6d2-616093f0a991	Mehwish Rehman	IMSG(I-V)TAMMA	Nilore	5	Eng	7	FICO	2026-01-21 00:00:00+00	{"subject_command": 0.0, "critical_thinking": 0.0, "effective_pedagogy": 0.0, "overall_percentage": 12.5, "inclusive_practices": 2.0, "technology_handling": 0.0, "verbal_communication": 0.0, "student_participation": 0.5, "effective_resource_use": 0.0, "technology_integration": 0.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 0.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
53657600-2677-4b12-a96f-0fd60e8f9075	Rabia Ramzan	IMS(I-V) G-6/1-2	Urban-I	5	Maths	10	FICO	2026-01-30 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 0.8, "overall_percentage": 19.166666666666668, "inclusive_practices": 1.0, "technology_handling": 0.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 0.0, "technology_integration": 0.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 0.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
0f938c22-6b4c-4278-900b-09f42478def2	SHAHEEN AKHTAR	IMSG (I-V) Dhoke Suleman	Tarnol	5	Science	13	FICO	2026-01-20 00:00:00+00	{"subject_command": 0.0, "critical_thinking": 0.0, "effective_pedagogy": 0.8, "overall_percentage": 24.615384615384617, "inclusive_practices": 0.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 2.0, "technology_integration": 4.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 0.0}	2026-05-14 07:14:13.506506+00
21b0f990-5f6c-4e2a-8310-2030c759882e	Risfa Naveed	IMCG, F-7/4	Urban-I	5	Maths	15	FICO	2025-12-17 00:00:00+00	{"subject_command": 0.0, "critical_thinking": 0.0, "effective_pedagogy": 0.8, "overall_percentage": 28.46153846153846, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 2.0, "technology_integration": 4.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 0.0}	2026-05-14 07:14:13.506506+00
0922afe0-12ac-4d79-9bb7-4653fb372f0e	Samia Zakir	IMCB G-13/2	Tarnol	4	Urdu	22	FICO	2026-01-21 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 1.6, "overall_percentage": 41.53846153846154, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 0.0}	2026-05-14 07:14:13.506506+00
57b07d82-70cb-4306-8635-f3e635600524	Saima Zubair	IMS (I-VIII) D-17	Tarnol	4	Maths	22	FICO	2026-02-03 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 1.6, "overall_percentage": 42.82051282051282, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.0, "effective_resource_use": 2.0, "technology_integration": 4.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
903eda9f-4040-437a-a6ae-c9cd8dcf88e7	Sobia maqsood	IMCG,THANDA PANI (FA)	Nilore	5	Urdu	26	FICO	2026-01-26 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 1.6, "overall_percentage": 49.23076923076923, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 0.0}	2026-05-14 07:14:13.506506+00
7ead146b-0980-4e84-925a-63741bcedfef	Farzana Gul Afridi	IMS(I-V) G-6/1-2	Urban-I	1	Maths	26	FICO	2026-01-30 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.6666666666666666, "effective_pedagogy": 2.4, "overall_percentage": 50.44871794871795, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 2.0, "technology_integration": 4.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
f41c108c-a95f-4fc9-a740-7848161d3d90	Nadia Jabeen	IMSG (I-VIII) G-8/4	Urban-I	5	Maths	26	FICO	2026-02-13 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 1.6, "overall_percentage": 50.512820512820525, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 1.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
5b4c4995-2611-4c8f-b39a-232eb876788e	FOUZIA KAUSER	IMSG (I-V) Sihala Khurd	Sihala	4	Urdu	27	FICO	2026-02-12 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 1.6, "overall_percentage": 51.7948717948718, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 0.0}	2026-05-14 07:14:13.506506+00
676431bf-0648-4239-89e2-3e955413a824	Kausar Perveen	IMS(I-V) G-6/1-2	Urban-I	2	Maths	27	FICO	2026-02-06 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 1.6, "overall_percentage": 51.7948717948718, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 0.0}	2026-05-14 07:14:13.506506+00
f2882940-632b-4412-9789-caaa176dab43	TAJ MASIH	IMSB(I-V)SOHAN	Nilore	3	Urdu	27	FICO	2026-01-22 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.0, "effective_pedagogy": 2.4, "overall_percentage": 52.05128205128206, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 2.0, "technology_integration": 4.0, "timely_lesson_delivery": 0.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 2.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
d6b087e4-5e6f-4967-add5-8ec6d1da2d5f	Tanveer Abbas	IMSB (I-V) Darwala	Sihala	1	Eng	30	FICO	2026-01-21 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 1.6, "overall_percentage": 57.56410256410256, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 0.0, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 2.0}	2026-05-14 07:14:13.506506+00
2fc9eaa7-6c53-4633-90bc-0a321ef8d982	Fiza Zeb	IMS(I-V) G-6/1-2	Urban-I	4	Science	32	FICO	2026-02-06 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 60.641025641025635, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 1.3333333333333333, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 0.0}	2026-05-14 07:14:13.506506+00
a807da50-69e0-4e03-9418-07b8853bd474	Robina Tahir	IMS(I-V) No.1 G-8/1	Urban-I	2	Maths	32	FICO	2026-01-28 00:00:00+00	{"subject_command": 1.0, "critical_thinking": 0.0, "effective_pedagogy": 1.6, "overall_percentage": 61.08974358974359, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 1.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
28dd8e0b-9b49-4f17-be21-6847a657fd59	SAIMA NAZ	IMS (I-V) G-6/1-3	Urban-I	4	Eng	32	FICO	2026-02-10 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.6666666666666666, "effective_pedagogy": 2.4, "overall_percentage": 61.98717948717949, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
ca4df000-72dc-457e-b40c-cfba316ac1bd	HAFIZ AKHTER REHMAN	IMSB(I-V)SOHAN	Nilore	5	Urdu	32	FICO	2026-01-22 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 62.243589743589745, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
987d5ec7-6e61-4087-a36e-681ce49d5fb0	Safia Akbar	IMCB G-15	Tarnol	4	Urdu	34	FICO	2026-01-20 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.0, "effective_pedagogy": 2.4, "overall_percentage": 64.87179487179488, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 1.3333333333333333, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
ff24b1ea-0c9c-4f05-a878-99d9a4a4e75f	Tahira saeed	IMCB, F-8/4	Urban-I	2	Maths	35	FICO	2026-01-27 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.0, "effective_pedagogy": 2.4, "overall_percentage": 67.43589743589743, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
e35e03bb-cde2-4e6a-9020-78b6fafa946b	Fiza Zeb	IMS(I-V) G-6/1-2	Urban-I	5	Science	36	FICO	2026-01-22 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.0, "effective_pedagogy": 2.4, "overall_percentage": 68.39743589743588, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
f03843cd-bcde-47ac-b976-db233b051297	UM-E-KALSOOM	IMSG(I-V) NILORE	Nilore	5	Maths	36	FICO	2025-12-19 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 2.4, "overall_percentage": 69.03846153846153, "inclusive_practices": 1.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
308787a2-86a6-4710-81f7-8e6f6296ff70	ABDUL HADI HAFEEZ AHMAD	IMSB (I-V) Karamabad	Tarnol	1	Urdu	36	FICO	2026-01-16 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 2.4, "overall_percentage": 69.35897435897435, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 1.3333333333333333, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
781bba26-fd9d-41f4-b2f0-9fec6cb8e3ce	Shumaila Shafiq	IMCG, F-7/4	Urban-I	1	Maths	36	FICO	2025-12-17 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 2.4, "overall_percentage": 70.0, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
0067d162-13ff-4c72-a685-c209884ac597	Humma rahim	IMCB, F-8/4	Urban-I	1	Urdu	37	FICO	2026-02-03 00:00:00+00	{"subject_command": 2.0, "critical_thinking": 0.0, "effective_pedagogy": 2.4, "overall_percentage": 70.32051282051282, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
ee5ace6b-15e7-451b-b383-8f0d04ea57c7	Matee Ullah Khan	IMSB (I-X) Maira Beri(F.A)	Tarnol	4	Maths	38	FICO	2026-01-28 00:00:00+00	{"subject_command": 4.0, "critical_thinking": 2.0, "effective_pedagogy": 4.0, "overall_percentage": 72.11538461538461, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
b2e51693-42ef-4f61-9eb6-a6f2467f9d91	Tasneem Akhtar	IMSG (I-V) Sheikhpur Noon	Tarnol	3	Urdu	38	FICO	2026-01-30 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 72.82051282051282, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 2.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
f68ce586-c694-4fc5-b697-d799f5bb03fb	Rehana Aftab	IMS(I-V) No.2 G-9/2	Urban-II	2	Eng	38	FICO	2025-12-17 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 73.78205128205128, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
32245f4b-3983-4f99-b1d9-228d31d856f2	Nadeema bibi	IMSG (I-VIII), BOBRI	B.K	2	Maths	38	FICO	2026-01-27 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 73.78205128205128, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 3.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
bd4cda6a-0007-421e-b443-8ef239ec5444	TANWIR AHMED KHAN	IMSB(I-V)KHANNA KAK	Nilore	1	Eng	38	FICO	2026-01-16 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 73.78205128205128, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
33ef993f-e366-41d0-a0aa-4bdce2c0312a	SAJIDA BANO	IMSG(I-V) JHANG SYEDAN	Nilore	4	Urdu	39	FICO	2026-01-19 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 74.74358974358975, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
c7136740-08b4-41fb-a69c-49d857113b24	Fakhira bibi	IMCB G-13/2	Tarnol	5	Urdu	39	FICO	2026-01-16 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 74.74358974358975, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
4bed97e6-1355-4089-b022-347d0c814988	Noureen lqbal	IMSG (I-V) Sheikhpur Noon	Tarnol	5	Maths	39	FICO	2026-01-30 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 74.74358974358975, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 2.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
58fc0706-bb63-4979-bb2e-319babd143c2	Zaitoon Noor	IMCG,THANDA PANI (FA)	Nilore	3	Eng	39	FICO	2026-01-26 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 75.38461538461537, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
7093f195-e36b-4d9b-850c-e9b99fcb594b	Benazir	IMSG (I-VIII) I-9/4	Urban-II	1	Urdu	39	FICO	2026-01-20 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.0, "effective_pedagogy": 3.2, "overall_percentage": 75.7051282051282, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
f8c279f8-aa37-4999-8683-a7b6e5c38544	Nusrat	IMSG(I-V)TAMMA	Nilore	1	Urdu	40	FICO	2026-01-21 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 76.34615384615384, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
ed75c01d-402a-4aa2-9346-e9d33d46e111	Khalid Hussain Shah	IMSB(I-V)SHARIFABAD	Nilore	2	Maths	40	FICO	2026-01-16 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 76.34615384615384, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
9ebd4160-cb11-4f0d-8aba-fc5010d6963c	Jamila Bibi	IMSG(I-V) ALI PUR SOUTH	Nilore	1	Urdu	40	FICO	2025-12-18 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 76.34615384615384, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
9abd3f55-aca8-40b0-989b-93fae1117435	Aiman Mujahid	IMCB,JABA TALI	Nilore	1	Urdu	40	FICO	2026-01-21 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 76.34615384615384, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
af7fad10-faeb-48d5-9e48-aa1f37fcb605	Bushra Bano	IMSG (I-V) Herdogher	Sihala	3	Eng	40	FICO	2026-02-12 00:00:00+00	{"subject_command": 4.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 4.0, "overall_percentage": 76.6025641025641, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 2.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 2.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
6e89249b-a86d-44e6-b636-0af1332d501e	Nadia Jabeen	IMSG (I-VIII) G-8/4	Urban-I	5	Maths	40	FICO	2026-01-21 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 0.6666666666666666, "effective_pedagogy": 3.2, "overall_percentage": 76.98717948717947, "inclusive_practices": 4.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
77619bee-c688-4012-986a-3e46fb7d4e38	Ghulam Murtaza (S.E.T)	IMSB(I-VIII) ALI PUR	Nilore	3	Urdu	40	FICO	2026-01-21 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 77.30769230769229, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
fa654c8b-88b4-4292-88a4-6a13d87a1437	Samina Sheikh	IMSG (I-VIII) I-9/4	Urban-II	5	Maths	41	FICO	2026-02-10 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 78.26923076923076, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
a6247374-d571-4ac7-85d1-ba76c70262a3	Shaheen Bibi	IMS (I-V) G-7/3-3	Urban-I	2	Urdu	41	FICO	2026-01-15 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 78.26923076923076, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
21ee763f-e161-49dd-8afa-02521e5be109	QARI MUHAMMAD IKRAM	IMSB(I-X) TUMAIR	Nilore	2	Urdu	41	FICO	2026-02-02 00:00:00+00	{"subject_command": 4.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 4.0, "overall_percentage": 78.52564102564101, "inclusive_practices": 4.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 1.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 0.0, "accurate_lesson_planning": 3.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
36306bc8-1f2b-4a7e-b425-96648f573317	M Basharat Satti	IMCB,JABA TALI	Nilore	5	Maths	41	FICO	2026-01-15 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 2.0, "effective_pedagogy": 3.2, "overall_percentage": 78.58974358974359, "inclusive_practices": 3.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
771df5c3-ec17-457d-9e09-38ebd8f80cad	Gulshan Habib	IMSG (I-VIII) G-7/3-2	Urban-I	1	Maths	41	FICO	2026-01-22 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 79.23076923076923, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 3.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
dedee655-96a0-4a29-b4ad-2aa382e70bd8	Nazia Nargis	IMS(I-V) PIMS G-8/3	Urban-I	2	Urdu	41	FICO	2025-12-22 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 3.2, "overall_percentage": 79.23076923076923, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 2.6666666666666665, "student_participation": 3.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
529d216d-1c16-4b3e-9322-6fdf1079f902	Bushra Islam	IMSG (I-VIII) G-8/4	Urban-I	1	Maths	41	FICO	2026-02-02 00:00:00+00	{"subject_command": 4.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 4.0, "overall_percentage": 79.48717948717949, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 1.0, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
c034d838-44e5-42e8-81b0-11f7f190c90f	Asma Abassi	IMSG (I-X) SHAHDRA KHURD	B.K	4	Maths	42	FICO	2026-01-20 00:00:00+00	{"subject_command": 3.0, "critical_thinking": 2.0, "effective_pedagogy": 3.2, "overall_percentage": 80.1923076923077, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 2.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 3.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
17f0f60c-a998-44da-bd84-54c10a601495	Kaneez Fatima	IMSG (I-VIII) F-7/4	Urban-I	5	Maths	42	FICO	2026-01-16 00:00:00+00	{"subject_command": 4.0, "critical_thinking": 1.3333333333333333, "effective_pedagogy": 4.0, "overall_percentage": 80.44871794871794, "inclusive_practices": 2.0, "technology_handling": 4.0, "verbal_communication": 4.0, "student_participation": 0.5, "effective_resource_use": 4.0, "technology_integration": 4.0, "timely_lesson_delivery": 4.0, "activity_based_learning": 2.0, "accurate_lesson_planning": 4.0, "non_verbal_communication": 4.0}	2026-05-14 07:14:13.506506+00
\.


--
-- Data for Name: training_content; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.training_content (id, training_id, format_type, content_url, duration_minutes, extra_data, created_at) FROM stdin;
f3e25673-5222-485b-84d7-da3a1d4db0d4	48b064c9-ab6c-4aab-8b81-f913d7e86173	slides	[{"title":"Unit 5.2: Finding the 'Why' — Identifying Intellectual Gaps","content":"Moving from Fixing Symptoms to Solving Root Causes — From Inspector to Instructional Catalyst","keyPoint":"Every persistent classroom struggle has a root cause. Coaching that addresses symptoms leaves the root untouched and the problem recurring.","type":"title"},{"title":"The Identity Shift: Inspector to Instructional Catalyst","table":{"headers":["Inspector","Instructional Catalyst"],"rows":[["Sees behaviors to correct","Sees gaps to diagnose"],["'Students are off-task — you need to manage better'","'What is the thinking behind how you structured this activity?'"],["Fixes the symptom","Finds the root cause (mental model)"],["Change requires coach presence","Change outlasts the coaching relationship"],["Teacher becomes dependent","Teacher develops diagnostic capacity"]]},"keyPoint":"An Instructional Catalyst changes HOW the teacher thinks about their teaching — not just WHAT they do in the classroom."},{"title":"What Is an Intellectual Gap?","content":"An Intellectual Gap is the mental model or root cause behind a persistent teaching behavior.","table":{"headers":["Observable Symptom","Intellectual Gap (Root Cause)"],"rows":[["Students rarely respond to questions","Teacher believes silence means students are thinking (not disengaged)"],["Transitions take 8–10 minutes","Teacher has not planned transition cues — assumes students know the procedure"],["Group work is chaotic","Teacher believes assigning groups is the same as designing group roles"],["CFU questions reveal no insight","Teacher asks 'Did everyone understand?' (yes/no) rather than diagnostic questions"]]},"keyPoint":"If you address the symptom without the gap, the problem returns — because the mental model that created it is unchanged."},{"title":"The Curious Opener: Finding the Why Without Status Denial","content":"Status Denial is triggered when the coach delivers an evaluation as a fact: 'Students are disengaged because you do not use higher-order questions.'","bullets":["CURIOUS OPENER: 'Looking at these 10 students who did not finish — what do you think was the biggest barrier for them?'","CURIOUS OPENER: 'When you planned the group work activity, what role did you imagine each student playing?'","CURIOUS OPENER: 'What were you hoping to find out when you asked that comprehension question?'"],"keyPoint":"A Curious Opener is not a soft criticism — it is a diagnostic question that surfaces the teacher's mental model without triggering defensiveness."},{"title":"Diagnosing the Intellectual Gap","content":"Once you have asked a Curious Opener and the teacher has responded, listen for the mental model behind the answer:","bullets":["Teacher says: 'I ask a question and wait for hands' → Mental Model: participation = willingness to volunteer → Gap: no strategy for reaching non-volunteers","Teacher says: 'I explained it clearly — they should have understood' → Mental Model: explanation = learning → Gap: no CFU mechanism to confirm understanding","Teacher says: 'Group work means they work together' → Mental Model: proximity = collaboration → Gap: no role structure or task design for genuine interdependence"],"keyPoint":"Name the gap — not the symptom. 'I think we might be designing group work as proximity rather than interdependence. What do you think?'"},{"title":"Pakistan Context: Status Denial Triggers","content":"In Pakistan's public school system, coaches must be especially vigilant. Status Denial is often triggered when coaches:","bullets":["Deliver an evaluation as a fact: 'Your lesson was ineffective'","Reference the principal's assessment: 'The principal mentioned your pacing is slow'","Use Western assessment language that does not match local classroom realities","Compare the teacher to an idealized standard that ignores class size and resource constraints"],"keyPoint":"Finding the Why requires that the teacher feels safe enough to admit their own uncertainty. Every Curious Opener must protect that safety."}]	\N	\N	2026-05-13 08:42:40.844978+00
6caaca92-51a6-457c-a5b7-cf5918f557ff	20310b34-0585-47ba-8e54-c85baa18876e	slides	[{"title":"Unit 5.4: Diagnosing the 3 Loops — Precision Coaching","content":"Identifying the Specific Point of Intervention — From Blaming Effort to Diagnosing the System","keyPoint":"Precision Coaching means diagnosing which loop is broken before naming the move. The right intervention in the wrong loop wastes both the coach's and teacher's time.","type":"title"},{"title":"The 3 Loops Framework","table":{"headers":["Loop","Where the Gap Is","Signs of a Gap"],"rows":[["PLANNING LOOP","The plan is a teacher-behavior script, not a student-response map","Teacher has no anticipation of student confusion; lesson collapses when students respond unexpectedly"],["OBSERVATION LOOP","Teacher cannot monitor all students simultaneously (structural constraint)","Teacher delivers and monitors — but the class is too large to do both effectively"],["TRAINING LOOP","Teacher lacks a specific micro-move that would make the lesson run smoothly","Teacher has the right plan and can observe, but lacks the specific skill to execute (e.g., transition signal, specific question type)"]]}},{"title":"Loop 1: The Planning Gap — Student-Response Map","content":"A Planning Loop gap occurs when the lesson plan focuses entirely on what the TEACHER will do, with no anticipation of how STUDENTS will respond.","table":{"headers":["Teacher-Behavior Script (Gap)","Student-Response Map (Correct)"],"rows":[["'I will explain photosynthesis for 10 minutes'","'After 10-minute explanation, I expect: students who understand — hands up; students confused — blank faces. If confused: I will ask a diagnostic CFU question.'"],["'I will assign group work'","'Students will need: roles (reader, writer, reporter), task clarity, and a 5-minute warning for presentations. I will circulate in the first 2 minutes.'"]]},"keyPoint":"A plan that only describes teacher behavior cannot anticipate student confusion — because student confusion is not in the plan."},{"title":"Loop 2: The Observation Gap — Structural Constraints","content":"An Observation Loop gap occurs when the class size or physical environment makes simultaneous delivery and monitoring structurally impossible.","bullets":["75 students in a small room: delivering instruction AND monitoring all students simultaneously is physically impossible","Coaching response: acknowledge the structural constraint (PP-7 Reciprocity)","'With 75 students, simultaneous delivery and monitoring is structurally challenging. Let us think about a strategy that reduces the monitoring load — like a designated 'checkpoint row' you always check during explanations.'","Do NOT blame the teacher for not monitoring when monitoring is structurally impossible"],"keyPoint":"Reciprocity (PP-7) means the coach recognizes that systemic issues — like class size — are not teacher failures."},{"title":"Loop 3: The Training Gap — Micro-Moves","content":"A Training Loop gap occurs when the teacher has a good plan and adequate observation capacity, but lacks a specific micro-move that would make the lesson run smoothly.","bullets":["Examples of micro-moves: attention signal ('clap once if you hear me'), cold-call system, specific wait-time technique, transition cue","Coaching intervention: Rehearsal or Role-play — teacher practices the specific micro-move with the coach before implementing it with students","NOT a long lecture about classroom management theory — a 5-minute rehearsal of one specific move"],"keyPoint":"Training Loop gaps require practice, not explanation. Role-play the move before the teacher tries it in the classroom."},{"title":"Precision Diagnosis Sequence","content":"BEFORE naming the coaching intervention, always diagnose the loop:","bullets":["STEP 1: Observe the classroom for the symptom (e.g., transitions taking 8 minutes)","STEP 2: Ask a Curious Opener: 'When you planned the transition, what did you expect students to do?'","STEP 3: Listen for which loop the answer reveals: Planning Gap (no anticipation) / Observation Gap (structural constraint) / Training Gap (lacks micro-move)","STEP 4: NAME the loop — 'I think this might be a planning gap — the transition was not scripted in the lesson plan. Would you like to co-plan it together?'","STEP 5: Offer the correct intervention for that loop"],"keyPoint":"Diagnosing first prevents prescribing the wrong solution. Planning interventions for a Training gap wastes time — and vice versa."}]	\N	\N	2026-05-13 08:42:51.619263+00
e1473ba3-c566-4b9d-a170-b82397d6a279	868b0c01-8fca-4f77-865d-f414bde5c0d0	slides	[{"title":"Unit 5.3: Closing the Loop — Side-by-Side Modeling and the IMPROVE Phase","content":"Turning the 'Learn' Phase Into Lasting Student Results","keyPoint":"Side-by-Side modeling is a bridge — not a takeover. The teacher watches you model one move, then tries it immediately. The lesson belongs to the teacher.","type":"title"},{"title":"What Is Side-by-Side Modeling?","content":"Side-by-Side Modeling is a coaching technique used in the LEARN phase where the coach briefly demonstrates one specific teaching move while the teacher observes and then immediately tries it.","table":{"headers":["Class Takeover (Avoid)","Side-by-Side Modeling (Use)"],"rows":[["Coach teaches the whole lesson for the teacher","Coach models one specific move (2–5 minutes)"],["Teacher watches passively","Teacher is next to coach, observes specific move"],["Teacher feels replaced and deskilled","Teacher tries the same move immediately after"],["Coach is the expert; teacher is the recipient","Coach is the bridge; teacher is the practitioner"]]},"keyPoint":"The measure of good modeling: did the teacher try the move themselves in the same lesson?"},{"title":"The IMPROVE Phase Meeting Agenda","bullets":["STEP 1: Share evidence — 'Last visit, you set a goal of X. Here is what the data shows from this visit.'","STEP 2: Invite teacher interpretation — 'What do you notice about the progress?'","STEP 3: Present the 4 Paths — 'Given this data, here are the four options: Stay the Course, Modify, Switch, or Re-identify'","STEP 4: Teacher chooses the path — 'Which of these feels right given what you are seeing?'","STEP 5: Set next action step — teacher articulates a specific, bite-sized action before the next visit"],"keyPoint":"Every IMPROVE meeting ends with a question: 'What should we try next?' — never a conclusion."},{"title":"Evidence Thresholds: When to Pivot","content":"How much progress is enough to Stay the Course? When should you Switch?","table":{"headers":["Progress Level","Suggested Path","Coach Question"],"rows":[["Goal exceeded (e.g., target 15 hands, got 22)","Re-identify: set a new, more ambitious goal","'This goal is achieved. What is the next frontier?'"],["Strong progress (target 15 hands, got 12)","Stay the Course: strategy is working","'You are at 12 of 15. What would help close the gap?'"],["Partial progress (target 15 hands, got 8)","Modify: adjust implementation","'What would you change about how you tried this?'"],["No progress (target 15 hands, still at 3)","Switch: try another menu option","'The evidence suggests this strategy is not working here. Which other option from our menu would you like to try?'"]]}},{"title":"Co-Modeling Scripts","content":"Before modeling a teaching move, the coach uses a Co-Modeling Script to explain what they are going to do and invite observation:","bullets":["'In the next 3 minutes, I am going to try [specific move]. I want you to watch what I do with the [specific group/area]. After, tell me what you noticed.'","After modeling: 'What did you notice? What would you like to try in the next activity?'","After teacher tries: 'What did you notice about how students responded when you tried that?'"],"keyPoint":"Co-Modeling Scripts end with questions — never with verdicts about how well the coach modeled or how well the teacher tried."},{"title":"Closing the Loop: The Follow-Through Commitment","content":"Closing the Loop means the coach returns to observe whether the teacher's chosen strategy produced student results — using the same metric as the baseline.","bullets":["The loop is closed when: new evidence is collected using the same metric, teacher interprets the new data, teacher chooses the next path","The loop is NOT closed when: the coach prescribes the next action without teacher choice, the coach changes the metric between visits, the coach does not return within 2 weeks"],"keyPoint":"If the coach does not return to close the loop, the teacher learns that coaching conversations are not connected to classroom reality — and stops investing in them."}]	\N	\N	2026-05-13 08:42:46.375177+00
2ae05f6e-9b64-466e-bdec-190fc34b3916	ad533d06-0947-4f89-854e-64eac7bd009f	slides	[{"title":"Unit 2.1: Status & Psychological Safety","content":"The Partnership Foundation — Building the Status-Safe Coaching Environment","keyPoint":"When teachers feel status threat, they fight, flee, or freeze. None of these responses lead to growth.","type":"title"},{"title":"The Status Threat Problem","content":"In Pakistan's education system, teachers expect to be 'checked' by inspectors and district officers. When a coach walks in, the teacher's brain automatically scans for threat.","bullets":["Fight: Teacher argues, deflects, justifies","Flight: Teacher avoids you, gives minimal responses, says 'everything is fine'","Freeze: Teacher becomes passive, stops thinking creatively, complies without ownership"],"keyPoint":"Status threat is biological, not personal. Your goal is to eliminate it — not all discomfort."},{"title":"The SCARF Model","bullets":["Status — Perceived relative importance; coach's presence can feel like evaluation","Certainty — Predictability of what happens next; surprise visits destroy certainty","Autonomy — Sense of control over choices; imposing goals violates autonomy","Relatedness — Sense of belonging and safety with another person","Fairness — Perception of fair exchange; evaluation disguised as coaching feels unfair"],"keyPoint":"Each Partnership Principle maps to one or more SCARF dimensions."},{"title":"The 7 Partnership Principles as Safety Tools","table":{"headers":["Principle","SCARF Protection","Coaching Behavior"],"rows":[["Equality","Status + Relatedness","Sit next to teacher; acknowledge teacher expertise"],["Choice","Autonomy","Ask what the teacher wants to focus on; offer 2–3 options"],["Voice","Status + Autonomy","Ask teacher to speak first; listen without interrupting"],["Dialogue","Relatedness + Certainty","Aim for 50/50 talk time; ask before telling"],["Reflection","Certainty","Share evidence and ask 'What do you notice?' first"],["Praxis","Autonomy","Frame as 'let's try and learn' not 'you must improve'"],["Reciprocity","Relatedness","Ask what the teacher wants you to understand about their context"]]}},{"title":"Identifying Status Threats in Coaching Language","table":{"headers":["Evaluative (Threatening)","Partnership (Safe)"],"rows":[["'Your classroom management is weak'","'8 students were talking during explanation — what was driving that?'"],["'You need to check for understanding more'","'I counted 2 CFU questions in 30 minutes — what was your thinking?'"],["'Students were not engaged'","'18 students had blank worksheets at the 20-min mark — what do you notice?'"],["'I'll tell you what to fix'","'What area would you like to focus on?'"]]},"keyPoint":"Rewriting evaluative language into observable evidence + curious question is the core coaching skill."},{"title":"The Confidentiality Shield","content":"The most difficult boundary to hold — and the most essential. If you share coaching data with principals for evaluation, coaching dies immediately.","bullets":["Teacher learns data goes to principal → stops being honest","Teacher performs during observations → shows fake practice","Teacher avoids vulnerability → coaching becomes inspection","You lose all partnership trust permanently"],"keyPoint":"Coaching data is confidential. It serves growth, not evaluation. The boundary must be held even under pressure."},{"title":"Field Practice: Selecting Your Partnership Principle","bullets":["Choose ONE principle to practice in your next visit","Equality: Position yourself as a thinking partner, not an expert","Choice: Ask teacher what THEY want to focus on before suggesting anything","Voice: Ask teacher to speak first before sharing your observations","Dialogue: Aim for 50/50 talk time — count to check"],"keyPoint":"Reflection without commitment is just thinking. Make one specific, observable commitment before your next visit."}]	\N	\N	2026-05-11 12:26:47.915665+00
eabf0697-567b-4ed3-99e6-6f72ef1e07a6	ad533d06-0947-4f89-854e-64eac7bd009f	scenario	{"steps":[{"id":"s21-1","situation":"You arrive at a Grade 5 classroom. The teacher, Mr. Ahmed, tenses when he sees you. After the lesson, you start by saying: 'The principal mentioned your pacing is slow, so I am here to tell you that you must use a timer for every activity starting tomorrow.'","context":"Mr. Ahmed immediately becomes defensive and stops participating in the conversation.","question":"Based on the SCARF model, what happened here and what was the better move?","branches":[{"id":"a","text":"Mr. Ahmed is simply a difficult teacher who does not want to improve.","isCorrect":false,"rationale":"Defensiveness is not personality — it is a predictable biological response to status threat. The coach violated Choice (removed autonomy) and Status (signaled superiority via the principal reference).","principle":"Choice + Status (SCARF)"},{"id":"b","text":"The directive removed Mr. Ahmed's Choice and signaled superiority, triggering a defensive Survival State in his brain.","isCorrect":true,"rationale":"This is the precise SCARF analysis. The coach violated Choice (mandatory instruction), signaled principal authority (status hierarchy), and delivered a prescription without evidence or teacher voice — all of which trigger fight/flight/freeze.","principle":"Choice + Status (SCARF)"},{"id":"c","text":"The advice was given in a friendly tone so the issue must be something else.","isCorrect":false,"rationale":"Tone does not override structure. A directive is still a directive regardless of vocal warmth. The SCARF threat came from the content and the authority invoked, not the tone.","principle":"Voice + Equality"},{"id":"d","text":"The coach should have brought a physical timer to show Mr. Ahmed how to use it.","isCorrect":false,"rationale":"The issue is not the absence of a tool. The issue is that the coach skipped evidence, skipped teacher voice, and imposed a solution — a fundamental partnership violation.","principle":"Choice + Dialogue"}]},{"id":"s21-2","situation":"A new teacher admits during a debrief: 'I really struggled with the transition from lecture to group work — it felt like chaos.'","context":"She is being vulnerable and honest, which is exactly what psychological safety enables.","question":"What is the mastery-level response from the coach?","branches":[{"id":"a","text":"'Do not worry about it. Just try to be friendlier and more comfortable next time.'","isCorrect":false,"rationale":"This dismisses her vulnerability with vague reassurance. It does not honor her honesty or build on the psychological safety she just demonstrated.","principle":"Dialogue + Equality"},{"id":"b","text":"'I appreciate you sharing that. Let us look at the student data together so we can take risks and find a solution without judgment.'","isCorrect":true,"rationale":"This acknowledges the vulnerability (builds safety), then pivots to evidence-based co-analysis (LEARN phase), preserving the trust she extended by being honest. This is the mastery response.","principle":"Equality + Dialogue + Reflection"},{"id":"c","text":"'It is okay — the school policy says everyone struggles in the first month.'","isCorrect":false,"rationale":"Policy reference does not address her specific struggle or honor her reflection. It shuts down growth by normalizing the problem rather than exploring it.","principle":"Praxis + Dialogue"},{"id":"d","text":"'You should not feel that way. Just follow the instructions I gave you last week.'","isCorrect":false,"rationale":"This dismisses her emotional reality and reverts to a directive posture — the opposite of the partnership response this vulnerable moment called for.","principle":"Equality + Choice + Voice"}]}]}	\N	\N	2026-05-11 12:26:48.153373+00
28e4347f-a6d1-4131-82e2-299a6077ceb0	e01320fb-012c-430b-a9bf-1e6d0bb5cf95	slides	[{"title":"Unit 2.2: Evidence-Based Dialogue","content":"Moving from Data to Teacher Agency — the Most Powerful Partnership Tool","keyPoint":"Evidence without partnership = surveillance. Evidence WITH partnership = transformation.","type":"title"},{"title":"The Core Problem: Verdict vs. Dialogue","content":"You observe a lesson. You see patterns. You have insights. When you share them — the teacher becomes defensive. Why? Because you delivered a VERDICT instead of inviting DIALOGUE.","table":{"headers":["Old Way","Partnership Way"],"rows":[["Coach interprets evidence","Coach shares evidence"],["Tells teacher what it means","Teacher interprets what it means"],["Prescribes the fix","Teacher chooses action"]]},"keyPoint":"Evidence-based dialogue shifts power from coach to teacher."},{"title":"Observable Evidence vs. Coach Interpretation","bullets":["Observable Evidence: What you saw/heard with your senses. A video camera could verify it.","Example: 'At 10:15am, teacher asked a question; 3 students raised hands.'","Coach Interpretation: What you think it means — your inference or conclusion.","Example: 'Students were not engaged.' (Interpretation — you inferred disengagement from behaviors)"],"keyPoint":"When you share interpretation, you position yourself as expert evaluator. When you share evidence, you give teacher data to interpret themselves."},{"title":"The 3-Step Evidence-Sharing Protocol","bullets":["STEP 1: Share Observable Evidence — 'Here is what I noticed: At 10:15, you asked about photosynthesis and 3 students raised hands.'","STEP 2: Ask Curious Question — 'What were you thinking when you saw only 3 hands?' OR 'What do you make of that pattern?'","STEP 3: Preserve Teacher Choice — 'Based on what you are noticing, is there anything you would like to try?'"],"keyPoint":"NEVER skip Step 2. The curious question is what activates teacher Voice and Choice."},{"title":"Evidence Across the Impact Cycle","table":{"headers":["Impact Cycle Phase","Evidence Role","Coach Move"],"rows":[["IDENTIFY","Share baseline evidence — current reality without judgment","'Here is what I observed' (no interpretation)"],["LEARN","Invite teacher interpretation — teacher explains WHY","'What do you make of this?' — teacher explains context you could not see"],["IMPROVE","Track evidence over time — show impact of teacher strategy","'Last visit: 8 writing. This visit: 42 writing. What do you notice?'"]]},"keyPoint":"Evidence is the thread that runs through the entire cycle. Without it, you have opinions."},{"title":"Pakistan Classroom Example: Grade 5 Urdu, 65 Students","content":"EVIDENCE COLLECTED: 9:00–9:25am: Teacher reads aloud; 9:25–9:35am: Teacher asks questions, calls on 5 students who raise hands; 9:35–9:45am: 8 students actively writing, 57 with blank pages.","table":{"headers":["Old Way (Judgment)","Partnership Way (Evidence)"],"rows":[["'Students were not engaged — you need to check for understanding more'","'During 10 minutes of notebook time, 8 students were writing and 57 had blank pages. What was your thinking about that activity?'"],["Coach interprets, prescribes solution","Teacher may explain: 'Most students cannot read the board from their seats — classroom is too crowded'"]]},"keyPoint":"Evidence invites teacher context you could not know from observation alone."},{"title":"Protecting Evidence Confidentiality","content":"Your observation evidence is a COACHING TOOL for teacher growth — not an evaluation report for principals.","bullets":["When a principal says: 'Show me your observation notes on Teacher X'","Response: 'My notes are a coaching tool for confidential partnership. If I share them for evaluation, teachers will stop being honest and the coaching relationship ends.'","'I can share overall THEMES across all teachers without naming individuals.'","Teachers must know before any observation: 'My notes are for our conversation only — they never go to the principal.'"],"keyPoint":"Transparency with teachers about evidence confidentiality is what builds the trust that makes honest coaching possible."}]	\N	\N	2026-05-11 12:26:52.854097+00
aa833d75-d213-4f20-9f1c-67917f583b29	e01320fb-012c-430b-a9bf-1e6d0bb5cf95	scenario	{"steps":[{"id":"s22-1","situation":"While a teacher explains why her lesson struggled, the coach interrupts: 'I had the exact same problem when I taught 5th grade! What I did was change the seating chart immediately. You should do that.'","context":"The teacher stops explaining and says 'Okay' without further reflection.","question":"This is an example of which coaching pitfall, and why does it harm the partnership?","branches":[{"id":"a","text":"This is Deep Empathy — the coach is connecting by sharing a personal experience.","isCorrect":false,"rationale":"Deep Empathy means acknowledging the teacher's feelings and facts. Interrupting with a personal story and a prescription is the opposite — it removes the teacher's voice and choice.","principle":"Voice + Choice"},{"id":"b","text":"This is Autobiographical Listening — the coach relates everything back to their own experience and prescribes a solution.","isCorrect":true,"rationale":"The coach interrupted the teacher's story, redirected to their own experience, and prescribed a solution — bypassing Steps 2 and 3 of the evidence-sharing protocol entirely. The teacher's 'Okay' is compliance, not ownership.","principle":"Voice + Choice + Dialogue"},{"id":"c","text":"This is Effective Paraphrasing — the coach is summarizing the teacher's concern.","isCorrect":false,"rationale":"Paraphrasing means restating the teacher's point in your own words to confirm understanding. This was an interruption followed by a personal story and a mandate.","principle":"Voice + Dialogue"},{"id":"d","text":"This is Professional Alignment — the coach is sharing relevant experience.","isCorrect":false,"rationale":"Sharing experience is not inherently wrong, but INTERRUPTING the teacher before she finishes, then prescribing the solution, violates Voice, Choice, and Dialogue simultaneously.","principle":"Voice + Choice + Dialogue"}]},{"id":"s22-2","situation":"You observe a Grade 5 Urdu class. During the 10-minute independent writing period, 8 students are actively writing and 57 students sit with blank pages.","context":"You are about to start the post-observation conversation.","question":"Which opening best demonstrates the 3-step evidence-sharing protocol?","branches":[{"id":"a","text":"'Students were really unfocused during your explanation. Have you thought about using more engaging strategies?'","isCorrect":false,"rationale":"'Unfocused' is interpretation, not observable evidence. The question is leading — it implies a deficit and pre-selects the solution direction. Steps 1 and 2 of the protocol are both violated.","principle":"Evidence-Based + Voice"},{"id":"b","text":"'I noticed during the 10-minute notebook activity, 8 students were actively writing and 57 were sitting with blank pages. What was your thinking about that activity?'","isCorrect":true,"rationale":"This is the protocol executed correctly: observable evidence (8 writing, 57 blank pages, time-stamped activity) followed by a genuinely open curious question that invites teacher interpretation. Teacher choice is preserved.","principle":"Evidence-Based + Voice + Choice"},{"id":"c","text":"'Great lesson overall! A few small things to work on but nothing major.'","isCorrect":false,"rationale":"Vague positive framing avoids the real evidence and does not serve the teacher's growth. There is no evidence, no curious question, and no invitation for teacher voice.","principle":"Evidence-Based + Dialogue"},{"id":"d","text":"'It seemed like students needed clearer instructions. What re-teaching strategy will you use?'","isCorrect":false,"rationale":"'Needed clearer instructions' is the coach's interpretation. 'What re-teaching strategy will you use?' skips teacher interpretation entirely and imposes the coach's conclusion.","principle":"Voice + Choice"}]}]}	\N	\N	2026-05-11 12:26:53.071673+00
f231e900-e0db-4136-84ec-7ced4cf535bd	81393e37-2176-4e50-ab5e-c94237481212	slides	[{"title":"Unit 2.3: Goal-Setting as Co-Creation","content":"From Teacher Compliance to Teacher Ownership — the Entry Point to the Impact Cycle","keyPoint":"Teacher-owned goals create teacher-driven change. Coach-imposed goals create compliance.","type":"title"},{"title":"What Usually Goes Wrong","bullets":["SCENARIO 1 — Coach-Imposed Goal: Coach observes, decides 'this teacher needs to work on student talk time,' tells teacher the goal. Result: teacher passively agrees, has no ownership, coaching becomes compliance.","SCENARIO 2 — Vague Goal: Teacher says 'I want to improve my teaching.' Coach says 'Great!' Result: after 5 visits, neither can tell if progress happened.","SCENARIO 3 — Principal-Imposed Goal: Principal tells coach to make classroom management the goal. Coach delivers this demand. Result: teacher feels inspected, partnership collapses."],"keyPoint":"If coach generates the goal, the entire Impact Cycle foundation crumbles."},{"title":"The 4-Step Goal Co-Creation Sequence","bullets":["STEP 1: Invite teacher to identify focus area — 'What is one area you would like to strengthen?' Wait 10+ seconds; resist filling silence.","STEP 2: Help teacher make goal SMART — Use curious questions for each component: Specific, Measurable, Achievable, Relevant, Time-bound.","STEP 3: Connect goal to observable student evidence — 'If you reach this goal, what will be different for your STUDENTS?'","STEP 4: Confirm teacher ownership — 'On a scale of 1–10, how much does this goal matter to you?' If below 8, return to Step 1."],"keyPoint":"If teacher rates ownership below 8, it is the wrong goal. Go back."},{"title":"SMART Goal Questions by Component","table":{"headers":["Component","Curious Question"],"rows":[["Specific","'When you say [vague word], what would that look like specifically?'"],["Measurable","'How will you know if this is working? What could you count or track?'"],["Achievable","'Thinking about your 65-student class, what feels realistic to try?'"],["Relevant","'Why does this matter for your STUDENTS right now?'"],["Time-bound","'When would you like to see this shift happening?'"]]}},{"title":"Pakistan Classroom Dialogue Example","content":"Teacher: 'I want students to understand better.' → Coach: 'When you say understand better, what would that look like specifically?' → Teacher: 'I want more students to answer questions.' → Coach: 'How will you know if that is happening?' → Teacher: 'I could count raised hands.' → Coach: 'Right now, about how many raise hands?' → Teacher: '3–4 out of 68.'","bullets":["Coach: 'What feels like a realistic goal for 2 weeks?' → Teacher: 'Maybe 15 students?'","Coach: 'Why does this matter for your students?' → Teacher: 'If more students answer, more are understanding.'","Coach: 'On a scale of 1–10, how much does this matter to you?' → Teacher: 'It is a 9.'"],"keyPoint":"Notice: Coach asked questions; teacher articulated every SMART component; teacher owns the goal (rated 9/10)."},{"title":"Protecting Teacher Choice Under Principal Pressure","content":"Principal says: 'Teacher X needs to work on classroom management. Make that the coaching goal.'","bullets":["Response: 'I can facilitate Teacher X's goal-setting process by sharing observation evidence and asking curious questions.'","'If Teacher X identifies classroom management as their focus, I will support that goal.'","'For coaching to be effective, the teacher must own the goal. If I impose it, they will comply but not truly change.'","'Can I share what goal Teacher X identifies after our conversation?'"],"keyPoint":"You are not refusing the principal's concern. You are explaining WHY teacher choice matters for actual improvement."}]	\N	\N	2026-05-11 12:26:58.140964+00
59b6ca4c-775b-403a-8820-bb54348af827	81393e37-2176-4e50-ab5e-c94237481212	scenario	{"steps":[{"id":"s23-1","situation":"Coach says: 'I noticed only 5 students answered questions during the lesson. I think we should set a goal around increasing participation.' The teacher nods and says 'Okay.'","context":"The coach has just finished sharing observation data.","question":"Is this a teacher-owned or coach-imposed goal, and why does it matter?","branches":[{"id":"a","text":"Teacher-owned — the teacher agreed with the goal, which shows buy-in.","isCorrect":false,"rationale":"'Okay' is compliance, not ownership. The teacher did not identify the focus area, did not articulate the goal, and did not rate its personal relevance. Passive agreement is the hallmark of a coach-imposed goal.","principle":"Choice + Voice"},{"id":"b","text":"Coach-imposed — the coach identified the focus, diagnosed the problem, and prescribed the goal. Teacher passively agreed.","isCorrect":true,"rationale":"The coach violated all 4 goal co-creation steps: they identified the focus (not the teacher), diagnosed the issue (not the teacher), proposed the goal (not the teacher), and the teacher's 'Okay' signals compliance rather than ownership.","principle":"Choice + Voice + Equality"},{"id":"c","text":"Co-created — the coach used evidence to prompt the conversation, which is the right approach.","isCorrect":false,"rationale":"Sharing evidence is the right start. The error was what happened AFTER the evidence was shared: the coach prescribed the goal instead of asking 'What do you make of this?' and letting the teacher identify the focus.","principle":"Voice + Dialogue"},{"id":"d","text":"It does not matter who generates the goal as long as it is measurable.","isCorrect":false,"rationale":"Measurability is only one component of an effective goal. Without teacher ownership (Step 4, rated 8+/10), teachers comply but do not sustain change — the IMPROVE phase collapses.","principle":"Choice + Praxis"}]},{"id":"s23-2","situation":"Teacher says: 'I want to improve my teaching.' Coach says: 'Great! What specifically about your teaching?' Teacher says: 'I am not sure — what do you think?' Coach says: 'I think you should work on wait time after asking questions.'","context":"The teacher is genuinely unsure and has deferred to the coach.","question":"What should the coach have done instead of prescribing wait time?","branches":[{"id":"a","text":"Agreed with the teacher's confusion and chosen the wait time goal — after all, it is an evidence-based strategy.","isCorrect":false,"rationale":"Prescribing a goal when a teacher defers is the most common goal co-creation failure. The teacher's question ('What do you think?') is an invitation for the coach to take over — partnership coaching means resisting that invitation.","principle":"Choice + Voice"},{"id":"b","text":"Shared observation evidence from the most recent visit and asked: 'Looking at this data, what do you notice that matters most to you?'","isCorrect":true,"rationale":"When a teacher is stuck, evidence is the solution — not prescription. The coach shares neutral data, then re-invites teacher interpretation. This brings the teacher back to their own analysis without the coach imposing a direction.","principle":"Choice + Voice + Evidence-Based"},{"id":"c","text":"Told the teacher that 'I want to improve' is too vague and asked them to try again with a specific subject area.","isCorrect":false,"rationale":"Directing the teacher to 'try again' with more specificity is still coach-directed. The focus area should emerge from evidence, not from the coach redirecting the teacher's framing.","principle":"Equality + Dialogue"},{"id":"d","text":"Offered two options: 'Would you like to focus on questioning or transitions?' so the teacher still has some choice.","isCorrect":false,"rationale":"A false menu — presenting only the coach's pre-selected options — is not genuine teacher choice. The teacher should identify the focus area; the menu comes later in Step 2 (strategy selection), not in Step 1.","principle":"Choice + Voice"}]}]}	\N	\N	2026-05-11 12:26:58.406631+00
78844b76-d8ca-45f5-9036-ca1e20c2b86b	014e2ea2-3a80-43c5-8f3c-329731000715	slides	[{"title":"Unit 1.0: The Coaching Catalyst","content":"Building the Foundation for Partnership Coaching","keyPoint":"Coaching = CATALYZING teacher growth, not CONTROLLING behavior","type":"title"},{"title":"What is Coaching?","bullets":["Supportive Partnership: Working WITH teachers as co-pilots in their growth journey","Evidence-Based: Grounded in classroom observation data","Growth-Focused: Builds capacity and celebrates progress","Cyclical and Ongoing: Regular, sustained engagement — not a one-time visit"],"keyPoint":"Coaching is not about fixing teachers — it is about unlocking their potential."},{"title":"The Impact Cycle: 3 Phases","bullets":["IDENTIFY — Co-select observable focus, establish baseline, set SMART goal","LEARN — Gather evidence, co-analyze patterns, explore strategies together","IMPROVE — Teacher tries chosen strategy, gathers new evidence, reflects and adjusts"],"keyPoint":"Every coaching conversation should map to one of these three phases."},{"title":"Coaching vs. Inspection","table":{"headers":["Feature","Partnership Coaching","Evaluative Inspection"],"rows":[["Tone","Supportive, growth-focused","Judgmental, fault-finding"],["Purpose","Build teacher capacity","Assess/judge performance"],["Relationship","Equals working together","Hierarchical (top-down)"],["Confidentiality","Stays between coach-teacher","Reported to principal"],["Feedback","Specific, actionable, chosen by teacher","Corrective, prescribed by evaluator"],["Outcome","Teacher empowerment and skill growth","Compliance or consequences"]]},"content":"Understanding this distinction is the first step to becoming a true Coaching Catalyst."},{"title":"The 7 Partnership Principles","bullets":["1. Equality — Coach is a co-learner, not an expert authority","2. Choice — Teacher picks their own focus and strategies","3. Voice — Teacher speaks first; coach listens deeply","4. Dialogue — Conversation, not monologue","5. Reflection — Teacher reflects on their own practice","6. Praxis — Try, learn, and adjust together","7. Reciprocity — Coach learns from the teacher too"],"keyPoint":"These 7 principles are the soul of the coaching relationship."},{"title":"Why Coaching Frequency Matters","content":"Research consistently shows that coaching frequency — not intensity — drives lasting change. Regular 2-week cycles create the feedback loops that solidify new habits.","bullets":["Skill Development: Repeated practice in context","Confidence Building: Teacher sees their own progress","Reflective Practice: Systematic self-examination","Student Learning Gains: The ultimate outcome"]},{"title":"Confidentiality: The Non-Negotiable","content":"Coaching notes must NEVER be shared with principals, DEOs, or any evaluative authority. You are the guardian of a professional safe space.","bullets":["Explicit agreement at the start of every coaching relationship","Secure storage: locked cabinet or password-protected files only","Anonymous reporting: cohort-level trends only, never individual names","If confidentiality is breached, the coaching relationship collapses"],"keyPoint":"Holding this boundary — even under pressure — is what makes you a trustworthy coach."},{"title":"The Identity Shift","content":"Becoming a Coaching Catalyst requires a fundamental identity shift. You are no longer an inspector, evaluator, or expert. You are a growth partner.","bullets":["From: 'I will tell you what to improve'","To: 'We will discover together what to focus on'","From: 'I observe and report'","To: 'I observe and co-explore'"],"keyPoint":"The hardest part of this shift is resisting the urge to give answers."}]	\N	\N	2026-05-11 14:02:23.137983+00
a8aa0ca5-1765-49a9-ba0d-a20033221a7d	014e2ea2-3a80-43c5-8f3c-329731000715	scenario	{"steps":[{"id":"s10-1","situation":"You arrive at a school and the head teacher says: 'Go observe Mr. Kamran and give me a report on his weaknesses for his annual evaluation.'","context":"You are starting your first week as a coach at this school.","question":"How do you respond to maintain your coaching role?","branches":[{"id":"a","text":"Agree to observe and give the head teacher a full report — you want to make a good first impression.","isCorrect":false,"rationale":"This immediately establishes you as an evaluative inspector, destroys any chance of a coaching relationship with Mr. Kamran, and violates the confidentiality principle.","principle":"Confidentiality + Accountability"},{"id":"b","text":"Explain that your role is coaching support, not evaluation. Offer to share school-wide themes after working with teachers.","isCorrect":true,"rationale":"This correctly positions your role, holds the boundary, and offers an alternative that serves the head teacher's interest in improvement without violating confidentiality.","principle":"Confidentiality + Accountability"},{"id":"c","text":"Observe Mr. Kamran but write a softer version of the report that does not reveal too much.","isCorrect":false,"rationale":"This still breaches the coaching-evaluation boundary and deceives both the teacher and the head teacher. It compromises your integrity.","principle":"Integrity + Confidentiality"},{"id":"d","text":"Refuse to observe at all until the head teacher agrees to all partnership principles in writing.","isCorrect":false,"rationale":"While protecting the principles is right, refusing to engage is counterproductive. A constructive conversation that clarifies your role is far more effective.","principle":"Equality + Dialogue"}]},{"id":"s10-2","situation":"Ms. Ayesha (12-year experienced teacher) says: 'Just tell me what I did wrong and what to fix. I do not have time for discussions.'","context":"She has only experienced inspection-style feedback in her career.","question":"What is the most effective coaching response?","branches":[{"id":"a","text":"List the three main things she did wrong and give specific prescriptions for each.","isCorrect":false,"rationale":"This gives her what she asked for but reinforces the compliance mindset and makes her dependent on you for answers. It does not build her capacity.","principle":"Choice + Praxis"},{"id":"b","text":"Insist that partnership coaching takes time and she must engage with the full process.","isCorrect":false,"rationale":"This dismisses her legitimate concern about time and creates resistance. You lose the relationship before it starts.","principle":"Equality + Dialogue"},{"id":"c","text":"Acknowledge her time pressure, share one piece of evidence, and ask one curious question — demonstrate partnership in miniature.","isCorrect":true,"rationale":"This respects her constraint, starts demonstrating the coaching approach immediately, and creates a micro-experience of partnership that can shift her mindset over time.","principle":"Equality + Voice + Choice"},{"id":"d","text":"Skip the coaching conversation and just send her written feedback via WhatsApp.","isCorrect":false,"rationale":"Written feedback without dialogue cannot establish the coaching relationship or build her reflective capacity. It is the least impactful option.","principle":"Dialogue + Praxis"}]},{"id":"s10-3","situation":"After coaching Mr. Hassan, a colleague asks: 'How is Hassan doing? He has been struggling for years — is he improving?'","context":"Your colleague genuinely seems to want to help Mr. Hassan.","question":"What do you say?","branches":[{"id":"a","text":"Share some general observations since the colleague seems supportive and means well.","isCorrect":false,"rationale":"Casual mentions — even with good intent — are a confidentiality breach. The coaching relationship depends on absolute discretion.","principle":"Confidentiality"},{"id":"b","text":"'I appreciate your interest. I keep all coaching conversations confidential. If you want to support Hassan, I would encourage a direct conversation with him.'","isCorrect":true,"rationale":"This holds the confidentiality boundary while being respectful, and redirects in a way that could genuinely help Mr. Hassan.","principle":"Confidentiality + Integrity"},{"id":"c","text":"Say nothing at all and walk away to avoid the conversation.","isCorrect":false,"rationale":"Silence without explanation is awkward and misses an opportunity to educate your colleague about the coaching model.","principle":"Dialogue"},{"id":"d","text":"Tell the colleague you cannot share specifics but confirm that he is indeed struggling.","isCorrect":false,"rationale":"Even a vague confirmation is a confidentiality breach that can undermine trust if Mr. Hassan hears about it.","principle":"Confidentiality"}]}]}	\N	\N	2026-05-11 14:02:23.358814+00
943796c5-af8a-455e-9d89-926bb23c33af	bcfae3fa-29c9-4972-bb32-c7909b55227c	slides	[{"title":"Unit 1.1: The Partnership Posture","content":"Shifting from a judging stance to equality-based, side-by-side partnership","type":"title"},{"title":"Judge vs. Co-Pilot Mindset","table":{"headers":["Dimension","Judge Mindset","Co-Pilot Mindset"],"rows":[["Role","Expert evaluating performance","Equal partner in growth"],["Data Use","Evidence of failure","Fuel for dialogue"],["Questions","Why didn't you do X?","What were you aiming for?"],["Next Steps","Coach prescribes solution","Teacher chooses action"],["Success","Compliance with advice","Teacher owns their growth"]]},"keyPoint":"The Co-Pilot mindset means YOU navigate TOGETHER — the teacher steers."},{"title":"The 3 Competency Pillars","bullets":["Developmental Stance — Growth-focused; believe capacity is expandable","Evidence-Based Approach — Observable evidence as the fuel for dialogue","Equality Principle — Honor teacher knowledge; co-create goals as equals"],"keyPoint":"Confidentiality is embedded in all three pillars."},{"title":"The 4-Step Observation-to-Conversation Flow","bullets":["1. OBSERVE — Collect observable behaviors (IDENTIFY phase)","2. ASK — Curious opener to invite teacher ownership (LEARN phase)","3. CO-INTERPRET — Share evidence; teacher interprets it first (LEARN phase)","4. SET STEPS — Teacher chooses action + follow-up date (IMPROVE phase)"],"keyPoint":"Never skip step 2. Asking before telling is the heart of partnership."},{"title":"Partnership Language Toolkit","bullets":["Curious Opener: 'I noticed [X] — can you tell me what you were aiming for?'","Co-Interpretation: 'Here is what I observed. How does this align with your goals?'","Co-Planning: 'Would you like to try strategy A or B? Let us decide together.'"],"keyPoint":"Practice these phrases until they feel natural — tone matters as much as words."},{"title":"Pakistan Context: Applying Partnership Posture","bullets":["Urban Govt Primary, Grade 4, 78 students, no textbooks: Share what you observed about participation before asking about resources","Rural Middle School, Grade 7 Science, broken equipment, principal watching: Maintain partnership posture even under pressure","Multi-grade, 65 students, time-pressed: Bite-sized focus; teacher chooses one manageable area"]},{"title":"Structured Reflection Practice","bullets":["Step 1: Write one exact partnership phrase you will use this week","Step 2: Ask a partner to assess your TONE (not just words)","Step 3: Identify one Judge habit you want to break","Step 4: Make a public commitment to your accountability partner"],"keyPoint":"Reflection without action is just thinking. Make the commitment specific and observable."}]	\N	\N	2026-05-11 14:02:28.448699+00
e55de059-8b8b-498c-8928-e24b17ca98c8	2e867af9-1fa4-4e84-8015-c0dfbf9a4850	slides	[{"title":"Unit 1.3: The Growth Engine","content":"Operationalizing the Impact Cycle through a 4-step evidence-based partnership process","type":"title"},{"title":"The 4-Step Coaching Cycle","bullets":["1. PLAN — Co-select observable focus, set SMART goal (IDENTIFY phase)","2. OBSERVE — Collect focused, concrete evidence with timestamps (IDENTIFY phase)","3. CO-ANALYSE — Share evidence neutrally, invite teacher to interpret, co-identify growth area (LEARN phase)","4. SUPPORT — Invite teacher solutions, teacher chooses, set 2-week revisit (IMPROVE phase)"],"keyPoint":"Teacher choice is not optional — it is the engine of the whole cycle."},{"title":"Evidence vs. Interpretation","table":{"headers":["Evidence (Use This)","Interpretation (Avoid This)"],"rows":[["'10:15am — Teacher asks question; 12 students raise hands'","'Students weren't engaged with the lesson'"],["'In 20 minutes, 4 students answered all 8 questions asked'","'Only a few students understand the content'"],["'Teacher modeled 3 problems, then gave 5 independent practice problems'","'Teacher did not give enough practice time'"],["'7 worksheets were blank at end of group work'","'Students did not understand the task'"]]},"keyPoint":"Evidence is observable and specific. Interpretation is subjective and triggering."},{"title":"Step 3: Co-Analysis","bullets":["1. Share Evidence — neutral, descriptive language with timestamps","2. Ask — curious opener with minimum 5-second wait time","3. Co-Identify Growth Area — teacher names the area; coach does not impose it"],"content":"Example: 'I noticed that 4 students answered 80% of the questions. What is your reading of that pattern?'","keyPoint":"The teacher naming the growth area is 10x more powerful than the coach naming it."},{"title":"Step 4: Co-Creating the Action Plan","bullets":["Old Way: 'Here is what you need to do this week'","Partnership Way: 'What strategy would you like to try?'","Sequence: Invite → Offer options if stuck → Teacher chooses → Co-plan follow-up","Action must be: bite-sized, observable, and achievable in 2 weeks"],"keyPoint":"If the teacher did not choose the action, they will not own its implementation."},{"title":"Partnership Principles in Each Cycle Step","table":{"headers":["Cycle Step","Partnership Principles in Action"],"rows":[["PLAN","Choice + Voice — teacher defines the focus"],["OBSERVE","Reflection — data collected to enable teacher reflection"],["CO-ANALYSE","Dialogue + Equality — mutual interpretation as partners"],["SUPPORT","Praxis + Reciprocity — teacher tries, coach learns too"]]}},{"title":"Handling Resistance: 4 Real Cases","bullets":["'I am too busy. Just tell me what to fix.' → Acknowledge time pressure. Offer to focus on just one thing.","Principal demands coaching notes → Hold the boundary. Offer school-wide trends instead.","Coaching 18 teachers — how to prioritize? → Focus on highest leverage with most willingness.","Teacher chooses an ineffective strategy → Let them try it. The next cycle reveals evidence together."],"keyPoint":"Resistance is information. Approach it with curiosity, not pressure."}]	\N	\N	2026-05-11 14:02:38.665644+00
cefe8b45-af1d-4535-b6c2-1bcc37ab9d9a	8d82e38c-73f9-4f4f-93ff-a467824ae63c	slides	[{"title":"Unit 1.4: The Trust Bridge","content":"Building the Foundation of Ethical Partnership Coaching through confidentiality and trust","type":"title"},{"title":"Why Trust is the Foundation","table":{"headers":["Without Trust","With Trust"],"rows":[["Teacher hides struggles, sugar-coats reality (IDENTIFY fails)","Teacher shares authentic challenges"],["Teacher becomes defensive, blames students (LEARN fails)","Teacher reflects openly on their practice"],["Teacher complies but reverts when coach leaves (IMPROVE fails)","Teacher owns and sustains change"]]},"keyPoint":"No trust → No Impact Cycle → No student learning gains."},{"title":"The 4-Pillar Ethical Framework","bullets":["1. TRUST — Does this action build or undermine trust? Red flag: teacher feels judged, exposed, or controlled","2. CONFIDENTIALITY — Am I protecting coaching data from evaluative use? Red flag: sharing notes, staffroom talk","3. ACCOUNTABILITY — Am I clear about role boundaries? Red flag: becoming the principal's informant","4. INTEGRITY — Does this align with Partnership Principles? Red flag: imposing solutions or telling teachers what to fix"],"keyPoint":"Run every ethical decision through all 4 pillars before acting."},{"title":"5 Types of Confidentiality Breaches","bullets":["1. Undefined Boundaries — no explicit confidentiality conversation at the start","2. Unprotected Access — notebook visible, shared passwords, open files","3. Casual Mentions — staffroom conversation about a teacher's struggles","4. Principal Reporting — sharing coaching notes for evaluation","5. Comparing Teachers — naming who is strong or weak to others"],"keyPoint":"Any of these five breaches can destroy a coaching relationship permanently."},{"title":"The Confidentiality Agreement","content":"Every coaching relationship must begin with an explicit confidentiality agreement covering:","bullets":["What data will be collected and how it is stored","Who has access (answer: only the teacher and coach)","How reporting works (anonymous, cohort-level trends only)","Exceptions: legal obligations only (child safety, serious harm)"],"keyPoint":"Have this conversation in the first meeting. Do not assume confidentiality is understood."},{"title":"4 Trust-Building Behaviors","bullets":["1. Share evidence, not judgment — 'I observed X' not 'You did not do Y well'","2. Ask before telling — teacher speaks first, always","3. Honor teacher choice — even if you disagree with their strategy","4. Acknowledge what is working — start with strengths, not gaps"],"keyPoint":"Trust is built slowly through 100 small consistent actions, and destroyed quickly by one breach."},{"title":"Handling Principal Pressure","content":"A head teacher requests your coaching notes on 5 teachers for performance reviews.","bullets":["'I appreciate your interest. My role is coaching support, not evaluation.'","'I can share school-wide themes where multiple teachers are working on similar goals.'","'Sharing individual coaching notes would breach confidentiality and undermine the trust that makes coaching effective.'","Offer alternative: aggregate themes, not individual data"],"keyPoint":"You are the guardian of the professional safe space. Hold this boundary — it is not optional."}]	\N	\N	2026-05-11 14:02:43.805628+00
a9264382-7ab4-44e3-abb3-131efd8a6c9b	3ee06af5-aac0-49f9-9963-df6d8096805f	slides	[{"title":"Unit 1.6: Coding the Classroom","content":"Using the I Do/We Do/You Do/CFU Observation Schema as a Partnership Tool","type":"title"},{"title":"The Observation Schema","table":{"headers":["Phase","Description","Coach Observes"],"rows":[["I DO (Teacher Models)","Teacher demonstrates; students observe","Time, clarity, think-aloud quality"],["WE DO (Guided Practice)","Students practice WITH teacher support","Teacher circulation, feedback quality"],["YOU DO (Independent Practice)","Students apply independently","Student engagement, teacher monitoring"],["CFU (Check for Understanding)","Can happen in ANY phase","Question type, student response spread"]]},"keyPoint":"Schema describes lesson structure — it does NOT judge teaching quality."},{"title":"Schema → Impact Cycle","bullets":["IDENTIFY: Code current lesson structure (e.g., 25 min I Do, 5 min You Do = baseline pattern)","LEARN: Schema data becomes the conversation starter — teacher explains their intent","IMPROVE: Track what the teacher tries next cycle, compare schema across lessons over time"],"keyPoint":"Two lessons with identical schema codes can be completely different in quality."},{"title":"Pakistan Example: Grade 4 Maths, 68 Students","bullets":["9:00–9:20: I DO — Teacher models 12×4, thinks aloud in Urdu (20 min)","9:20–9:30: WE DO — Students in pairs: 15×3, teacher circulates (10 min)","9:30–9:40: YOU DO — 5 textbook problems independently on slates (10 min)","9:40–9:45: CFU — Students show slates for problem #3 (5 min)"],"keyPoint":"Total: 20/10/10/5 — a reasonable starting baseline for this class size."},{"title":"The Partnership Way: Sharing Schema Data","bullets":["Step 1: Share Data — 'I coded 20 min I Do, 5 min We Do, 10 min You Do, 5 min CFU'","Step 2: Invite Interpretation — 'What was your thinking about the lesson structure today?'","Step 3: Co-Explore — Teacher explains intent; together decide if adjustment is wanted"],"table":{"headers":["Old Way","Partnership Way"],"rows":[["'You talked too much'","'I coded 20 min I Do. What was driving that structure today?'"],["'Students needed more practice'","'The You Do was 5 minutes. Is that what you intended?'"]]}},{"title":"What Schema Can and Cannot Tell You","table":{"headers":["Schema CAN Show","Schema CANNOT Show"],"rows":[["Time allocation across phases","Teaching quality within a phase"],["Presence or absence of phases","Student engagement or understanding"],["Patterns across multiple lessons","Cultural responsiveness"],["Changes in structure over time","Whether structure matched student needs"]]},"keyPoint":"Use schema to open dialogue, not to render verdicts."},{"title":"Audit Culture Risk with Schema","content":"Be vigilant about how schema data gets used outside the coaching relationship.","bullets":["Risk: Principal mandates a 25/25/50 split — coaches must 'check compliance'. This is audit culture.","Risk: Schema reports demanded for teacher performance evaluations.","Prevention: Establish boundaries with principals before using schema","Boundary language: 'Schema data supports coaching conversations only — it is not a compliance measure.'"],"keyPoint":"Schema is a mirror for dialogue. The moment it becomes a compliance checklist, it loses all value."}]	\N	\N	2026-05-11 14:02:54.03698+00
0c026b84-2858-4da7-a5cd-127a5d069a8c	bcfae3fa-29c9-4972-bb32-c7909b55227c	scenario	{"steps":[{"id":"s11-1","situation":"You observe a Grade 6 lesson. The same 5 students answer every question for 45 minutes. 15 students have blank worksheets.","context":"This is your first post-observation conversation with Mr. Ali.","question":"Which opening best demonstrates the Partnership Posture?","branches":[{"id":"a","text":"'I noticed you only called on 5 students today. You need to use cold-calling to engage the rest.'","isCorrect":false,"rationale":"This is a direct prescription — the judge mindset. It tells him what is wrong and what to fix, bypassing his voice and choice entirely.","principle":"Voice + Choice"},{"id":"b","text":"'I recorded that 5 students responded to all 12 questions. What was your intention for student participation today?'","isCorrect":true,"rationale":"This shares neutral evidence and opens with a curious question that invites the teacher to reflect and interpret. This is the co-pilot posture.","principle":"Equality + Voice + Reflection"},{"id":"c","text":"'Great lesson overall! There were a few small things to work on but nothing major.'","isCorrect":false,"rationale":"Vague positivity without evidence avoids the real issue and does not serve the teacher's growth.","principle":"Evidence-Based + Equality"},{"id":"d","text":"'The students seemed disengaged. What do you think about your teaching style?'","isCorrect":false,"rationale":"'Disengaged' is an interpretation, not evidence. 'Teaching style' is too broad to support focused growth.","principle":"Evidence-Based"}]},{"id":"s11-2","situation":"The teacher responds: 'Honestly, I do not know why only those 5 students answer. I have been teaching this way for 10 years.'","context":"She does not seem defensive — she seems genuinely puzzled.","question":"What is your next move in the 4-step flow?","branches":[{"id":"a","text":"Explain that research shows cold-calling increases engagement and recommend she try it.","isCorrect":false,"rationale":"Jumping to prescription skips Step 3 (co-interpretation). She has not yet interpreted the data.","principle":"Choice + Dialogue"},{"id":"b","text":"Show her the participation data you recorded and ask: 'Looking at this, what do you notice about the pattern?'","isCorrect":true,"rationale":"This moves to Step 3 — co-interpretation. You share the evidence and invite her to make meaning from it.","principle":"Equality + Reflection + Dialogue"},{"id":"c","text":"Tell her that 10 years of this pattern is why students are struggling, and now she needs to change.","isCorrect":false,"rationale":"This is judgmental and backward-looking. It will create defensiveness and destroy the coaching relationship.","principle":"Equality + Trust"},{"id":"d","text":"Move to Step 4 and suggest she try a new participation strategy next lesson.","isCorrect":false,"rationale":"Skipping co-interpretation means the action plan will be yours, not hers.","principle":"Choice + Praxis"}]}]}	\N	\N	2026-05-11 14:02:28.666433+00
1c740c7d-1fd3-4df5-bc32-10460fb80723	9fabc12b-0f30-421d-ad41-4deb372a6314	slides	[{"title":"Unit 1.2: The Shared Mirror","content":"Presenting classroom data as a neutral starting point for collaborative discovery","type":"title"},{"title":"What is the Shared Mirror?","content":"A coaching practice where the coach presents observation data so that both coach and teacher can explore teaching and learning together — without judgment.","table":{"headers":["Approach","Description"],"rows":[["Old Way (Audit)","Coach observes → decides → prescribes → teacher complies"],["New Way (Shared Mirror)","Coach observes → shares neutral data → both interpret → teacher chooses → coach supports"]]},"keyPoint":"A mirror reflects reality without judgment. A SHARED mirror means we look at the reflection TOGETHER."},{"title":"4 Steps of the Shared Mirror","bullets":["1. Collect Observations — raw data, time-stamped, no interpretation","2. Organize Patterns — group related observations to find themes","3. Share Neutrally — facts + timestamps, zero judgment language","4. Co-Interpret & Agree — teacher selects focus and action"],"keyPoint":"Steps 3 and 4 are where the Shared Mirror actually happens."},{"title":"Do vs. Avoid","table":{"headers":["Action","Do (Shared Mirror)","Avoid (Judging Stance)"],"rows":[["Data Sharing","Time-stamped facts","Labels and judgments"],["Questioning","Curious, reflective questions","Immediate prescriptions"],["Tone","Exploratory — 'Let us look at this together'","Deficit language"],["Interpretation","Invite teacher to interpret first","Lead with coach's opinion"],["Next Steps","Teacher selects focus and strategy","Coach prescribes solution"]]}},{"title":"Low-Inference vs. High-Inference Language","bullets":["LOW-INFERENCE (Use): 'At 10:15, you asked 4 questions. 3 of the same students responded each time.'","HIGH-INFERENCE (Avoid): 'Most students were not engaged with your lesson.'","LOW-INFERENCE (Use): 'In 20 minutes of group work, I counted 7 blank worksheets.'","HIGH-INFERENCE (Avoid): 'Students did not understand the task you gave them.'"],"keyPoint":"Low-inference language invites curiosity. High-inference language triggers defensiveness."},{"title":"Shared Mirror + Impact Cycle","bullets":["IDENTIFY: Neutral data reveals the current reality of the classroom","LEARN: Co-interpretation surfaces insights and informs strategy selection","IMPROVE: Collaborative next steps are measured using the same neutral approach"],"content":"The Shared Mirror is the tool that makes the Impact Cycle feel collaborative rather than evaluative."},{"title":"Audit Culture in Pakistan: The Real Challenge","content":"Teachers in Pakistan often expect judgment. AEOs and DEOs have used observations to evaluate and punish.","bullets":["When teachers expect judgment → they hide struggles, blame students, implement superficially","When they experience shared exploration → they share authentic challenges and own their growth","Your job is to break the audit culture pattern — one conversation at a time"],"keyPoint":"The Shared Mirror is an act of resistance against audit culture."}]	\N	\N	2026-05-11 14:02:33.574907+00
0108fe87-0a38-4138-bfab-332190eecff9	18e5a745-f999-46ff-a29c-97d79611497d	scenario	{"steps":[{"id":"s41-1","situation":"A coach is creating a Digital Journal entry for a teacher's growth journey. They include a photo of a student's improved essay and add the note: 'Notice the shift in student engagement and clarity when you moved to the back row to support the Shadow students.'","context":"The coach has been working with this teacher for 3 months across 6 coaching cycles.","question":"This note is an example of which type of annotation?","branches":[{"id":"a","text":"A technical correction of the teacher's mistakes.","isCorrect":false,"rationale":"The note celebrates a specific teacher decision (moving to the back row) and its observable impact. There is no correction — only a Growth-focused observation tied to a specific action.","principle":"PRAXIS + EQUALITY"},{"id":"b","text":"A 'Human Annotation' that highlights professional agency and growth.","isCorrect":true,"rationale":"This is a Partnership Annotation with all three elements: the observation (shift in student engagement), the principle reference (implied — teacher's proactive movement = PRAXIS), and the growth connection (the 'Shadow' strategy is paying off). It belongs to the IMPROVE phase narrative.","principle":"PRAXIS + EQUALITY"},{"id":"c","text":"A 'Deficit Frame' focusing on what was missing earlier.","isCorrect":false,"rationale":"'Deficit Frame' looks backward to document failure. This annotation looks forward to celebrate growth — it is an IMPROVE phase entry, not an IDENTIFY baseline complaint.","principle":"PRAXIS + REFLECTION"},{"id":"d","text":"An administrative report for the principal to use in a salary review.","isCorrect":false,"rationale":"The Digital Journal is explicitly a confidential developmental tool between coach and teacher — not an administrative record or evaluation instrument.","principle":"Confidentiality + EQUALITY"}]},{"id":"s41-2","situation":"You have worked with a teacher for 3 months. You show them a sequence of artifacts from their Digital Journal — from the first IDENTIFY phase observation to the most recent IMPROVE phase evidence.","context":"The teacher has not seen these artifacts side by side before.","question":"Why are you acting as a 'Biographer of Growth' in this moment?","branches":[{"id":"a","text":"To prove to the district that you have been working consistently every week.","isCorrect":false,"rationale":"The Biographer of Growth identity is teacher-facing, not administratively motivated. The purpose is to make the teacher's own journey visible to themselves — not to validate the coach's work for external review.","principle":"EQUALITY + REFLECTION"},{"id":"b","text":"To keep a record of every error the teacher made so they do not repeat them.","isCorrect":false,"rationale":"This is the Deficit Frame — the opposite of the Biographer of Growth. The Journal documents the arc from baseline to growth, not an error log.","principle":"EQUALITY + REFLECTION"},{"id":"c","text":"To document the teacher's success and professional journey over time rather than just counting errors.","isCorrect":true,"rationale":"This is the Biographer of Growth function: making the full arc of change visible in one place so the teacher can see how far they have come. Research shows that seeing your own progress is a powerful motivator for continued growth.","principle":"REFLECTION + PRAXIS + EQUALITY"},{"id":"d","text":"To write a story that makes the school's test scores look better than they are.","isCorrect":false,"rationale":"The Digital Journal documents real, observable classroom change — it is not a marketing document or a fabrication.","principle":"Integrity + Equality"}]}]}	\N	\N	2026-05-13 08:41:58.800388+00
2d1d3660-ab78-4d59-abcc-403171eb0643	0545c290-98f0-43a4-8651-95fe882671bb	slides	[{"title":"Unit 4.2: The Adaptive Facilitator","content":"Reading the Room and Adjusting Your Coaching Stance — From Fixed Expert to Responsive Partner","keyPoint":"An Adaptive Facilitator does not have a fixed style. They read the teacher's current needs and adjust in real time.","type":"title"},{"title":"The Three Coaching Stances","table":{"headers":["Stance","When to Use","What It Looks Like"],"rows":[["DIRECTIVE","Teacher overwhelmed, safety crisis, complete novice","Coach provides clear, specific instructions. 'Do this now to ensure students are safe.'"],["FACILITATIVE","Teacher has capacity to reflect and choose","Coach asks powerful questions. 'What do you notice? What would you like to try?'"],["CONSULTATIVE","Teacher has expertise and wants a thought partner","Coach offers options and rationale. 'Here are two approaches — what fits your context?'"]]},"keyPoint":"Directive coaching is NOT partnership failure. It is what you do when the teacher cannot yet access reflective choice."},{"title":"Reading the Room: Signals for Stance Adjustment","bullets":["Teacher is overwhelmed or anxious → Directive: reduce cognitive load, give clear next step","Teacher is curious and engaged → Facilitative: ask questions, wait, let teacher discover","Teacher is resistant or shut down → Consultative: offer choices, reduce threat, build trust through small wins","Teacher is expert and collaborative → Consultative: share options with rationale, invite co-design","Teacher faces safety or crisis → Directive immediately: partnership can resume after the crisis"],"keyPoint":"The wrong stance at the wrong moment costs trust. Reading the room accurately is the master coaching skill."},{"title":"The 'Coaching Heavy' vs. 'Coaching Light' Spectrum","table":{"headers":["Coaching Heavy","Coaching Light"],"rows":[["Deep systemic changes in teacher practice and student learning","Surface-level behavior adjustments and quick tips"],["Full Impact Cycle engagement (IDENTIFY → LEARN → IMPROVE)","Single visit observations with no follow-up cycle"],["Teacher owns goal, strategy, and pivot","Coach prescribes action and checks compliance"],["Change outlasts the coaching relationship","Change stops when coaching stops"]]},"keyPoint":"Coaching Light creates dependent teachers. Coaching Heavy creates self-directing professionals."},{"title":"Handling Resistance: The Quick Win Strategy","content":"A resistant teacher is not failing — they are protecting themselves from a history of evaluative inspection. The Adaptive Facilitator's response:","bullets":["Do not escalate: do not increase pressure or involve the principal","Empathize first: 'I understand these conversations can feel evaluative — that is not what I am here for'","Offer a Quick Win Choice: 'Would you prefer to focus on one small thing that would make your day easier?'","Use the smallest possible intervention to build trust before attempting deeper work"],"keyPoint":"Trust is built one small consistent action at a time. Resistant teachers need Quick Wins before they can access deep coaching."},{"title":"Reciprocity in Facilitation","content":"RECIPROCITY (PP-7) means the coach is willing to be influenced by the teacher's classroom reality — not just influence the teacher.","bullets":["After every visit, ask yourself: 'What did I learn from this teacher that I did not know before?'","Document this in the Reciprocity Note in the Digital Journal","If a teacher's approach works better than the 'textbook' strategy — say so","The coach who cannot be influenced cannot be trusted as an equal"],"keyPoint":"Coaches who learn from teachers build more trust than coaches who only teach teachers."}]	\N	\N	2026-05-13 08:42:04.023757+00
cf1fbb53-65af-4ae5-83d9-7ac5e9a9c499	9fabc12b-0f30-421d-ad41-4deb372a6314	scenario	{"steps":[{"id":"s12-1","situation":"You observed a Grade 4 literacy class: 47 teacher prompts in 20 minutes, only 4 of 30 students spoken to, 7 blank worksheets at the end.","context":"You are about to start the post-observation conversation with Ms. Nadia.","question":"Which opening correctly uses the Shared Mirror?","branches":[{"id":"a","text":"'Ms. Nadia, most students were not engaged in today's lesson. We need to fix that.'","isCorrect":false,"rationale":"This is high-inference language and a prescription. It is the audit approach, not the Shared Mirror.","principle":"Evidence-Based"},{"id":"b","text":"'I recorded 47 teacher prompts in 20 minutes and noted that 4 students received all 12 direct questions. Here is the data — what do you notice?'","isCorrect":true,"rationale":"Specific, time-stamped, low-inference data shared neutrally, followed by an invitation for the teacher to interpret it first.","principle":"Shared Mirror + Equality"},{"id":"c","text":"'You did a lot of prompting today. That can sometimes reduce student independence.'","isCorrect":false,"rationale":"'A lot' is still interpretive and the second sentence moves to prescription. It is not neutral data sharing.","principle":"Evidence-Based"},{"id":"d","text":"'What did you think of the lesson today?' (start with teacher's view before sharing any data)","isCorrect":false,"rationale":"The Shared Mirror protocol calls for sharing neutral data first so the teacher can reflect on objective evidence, not just impressions.","principle":"Shared Mirror Process"}]},{"id":"s12-2","situation":"After seeing the data, Ms. Nadia says: 'Those 4 students always answer. I know the others are not engaging but I do not know why.'","context":"She is being honest and open.","question":"What is your next step in the Shared Mirror process?","branches":[{"id":"a","text":"Suggest she use popsicle sticks for random cold-calling — it is proven to work.","isCorrect":false,"rationale":"This is a premature prescription. She has just named the pattern — now is the moment for co-exploration.","principle":"Choice + Dialogue"},{"id":"b","text":"'What else do you notice in this data that might help us understand why?' (continue co-interpretation)","isCorrect":true,"rationale":"She is in the LEARN phase. Deepening co-interpretation builds her understanding of the root cause, which will make any action she chooses more grounded.","principle":"Equality + Reflection"},{"id":"c","text":"Move to action: 'Great self-awareness. Now, what would you like to try differently next lesson?'","isCorrect":false,"rationale":"Moving to action too quickly misses the depth of the LEARN phase. She has named a symptom but not yet explored the root cause.","principle":"Dialogue + Praxis"},{"id":"d","text":"Share your own interpretation: 'I think the worksheet was too hard for most students.'","isCorrect":false,"rationale":"This imposes your interpretation on her. The Shared Mirror principle requires the teacher to interpret first.","principle":"Equality + Voice"}]}]}	\N	\N	2026-05-11 14:02:33.854741+00
ee0e2bdc-0689-44bc-afc7-49f809ac8268	8d82e38c-73f9-4f4f-93ff-a467824ae63c	scenario	{"steps":[{"id":"s14-1","situation":"A head teacher says: 'I heard you were coaching Mr. Tariq. He has been resistant for years. Is he finally improving?'","context":"The head teacher seems genuinely invested in Mr. Tariq's growth.","question":"Which response best protects the coaching relationship and maintains your integrity?","branches":[{"id":"a","text":"Share that Mr. Tariq is showing some positive signs — you think the head teacher deserves to know.","isCorrect":false,"rationale":"Even positive information shared without the teacher's consent is a confidentiality breach.","principle":"Confidentiality"},{"id":"b","text":"'I keep all coaching conversations confidential. What I can say is that I am working with all teachers on growth areas relevant to student outcomes. Would a school-level summary be useful?'","isCorrect":true,"rationale":"This holds the boundary firmly, explains why, and offers an alternative that serves the head teacher's legitimate interest.","principle":"Confidentiality + Accountability + Integrity"},{"id":"c","text":"Say nothing and change the subject to avoid an uncomfortable conversation.","isCorrect":false,"rationale":"Avoidance does not establish your professional boundary. The head teacher will continue to expect this information from you.","principle":"Integrity + Dialogue"},{"id":"d","text":"Ask Mr. Tariq first if it is okay to share, and if he agrees, then tell the head teacher.","isCorrect":false,"rationale":"Asking a teacher to agree to share coaching data with the head teacher puts him in an awkward position and blurs the coaching-evaluation boundary.","principle":"Confidentiality + Trust"}]},{"id":"s14-2","situation":"You discover another coach at your school has been sharing coaching notes with the principal. Teachers are now afraid to be honest.","context":"You are a senior coach and this is affecting your coaching relationships too.","question":"What is the most ethical and effective course of action?","branches":[{"id":"a","text":"Do nothing — it is not your responsibility and you do not want to create conflict.","isCorrect":false,"rationale":"Silence makes you complicit in a practice that is destroying the coaching culture at the school.","principle":"Integrity + Accountability"},{"id":"b","text":"Talk to the other coach privately, share the 4-pillar framework, and explain how this practice is damaging trust across all coaching relationships.","isCorrect":true,"rationale":"This is the integrity move. Address it directly with the colleague, using the framework rather than personal judgment.","principle":"Integrity + Accountability + Trust"},{"id":"c","text":"Report the other coach to management immediately to protect your own coaching relationships.","isCorrect":false,"rationale":"Escalating without first attempting peer dialogue is premature and may damage the collegial relationship unnecessarily.","principle":"Dialogue + Accountability"},{"id":"d","text":"Start telling teachers privately that you do not share notes — to differentiate yourself from the other coach.","isCorrect":false,"rationale":"This creates a competitive dynamic and does not address the systemic problem.","principle":"Integrity + Accountability"}]}]}	\N	\N	2026-05-11 14:02:44.024428+00
6bd4399e-829d-4df7-9ebe-d456166ab565	1a504a0a-f44b-47d0-abc2-e44d19d6508e	slides	[{"title":"Unit 1.5: The Human Filter","content":"Using AI as a partnership tool, not a replacement for human professional judgment","type":"title"},{"title":"AI: Opportunity and Risk","table":{"headers":["AI Opportunity","AI Risk"],"rows":[["Tracks patterns over time humans miss","Misses classroom context entirely"],["Provides objective frequency data","Reinforces Western dataset bias"],["Identifies trends across many teachers","Undermines partnership if misused"],["Reduces observer memory errors","Audit Culture 2.0 — new inspector"]]},"keyPoint":"AI provides DATA PATTERNS → Human adds CONTEXT → Together = PARTNERSHIP-ALIGNED FEEDBACK"},{"title":"AI in the Impact Cycle","bullets":["IDENTIFY: AI tracks patterns + human adds 'why' context from knowing the teacher","LEARN: AI data is a conversation starter, not a conclusion","IMPROVE: AI tracks what teacher tried + human ensures teacher owns strategy selection"],"keyPoint":"AI should accelerate the Impact Cycle, not replace human judgment in it."},{"title":"The 3-Question AI Validation Framework","bullets":["1. CONTEXT — Does this account for the classroom reality I observed? (class size, resources, curriculum pressure, teacher intent)","2. BIAS — Could this reflect algorithm bias or cultural assumptions? (Western dataset, deficit framing)","3. PARTNERSHIP — Does this preserve teacher choice, voice, and agency?"],"keyPoint":"If ANY of the 3 questions raises a concern → ADD CONTEXT or OVERRIDE the AI suggestion."},{"title":"Pakistan-Specific AI Override Examples","bullets":["AI says 'use digital tools' → School has no electricity. OVERRIDE.","AI flags 40-min review as 'below pacing benchmark' → Teacher intentionally slowed for comprehension. ADD CONTEXT.","AI flags 'no differentiation' → 75 students, no teaching assistant. OVERRIDE.","AI flags 'below benchmark' for teacher with 90 students doing exceptional work. OVERRIDE."],"keyPoint":"You know the classroom. The AI does not."},{"title":"AI Limitations You Must Know","bullets":["Training Bias — AI trained on Western classroom data; penalizes Pakistan realities","Cultural Blindness — misinterprets teacher authority, collective learning, Urdu-medium instruction","Deficit Framing — AI often focuses on what is wrong rather than growth opportunities","Technical Errors — AI is not infallible; anomalous data produces anomalous suggestions"],"keyPoint":"Professional judgment always supersedes AI output. You are the Human Filter."},{"title":"When AI Becomes the New Inspector","content":"The greatest risk: AI data used for evaluation → teachers close off → trust destroyed → coaching fails.","bullets":["Prevention 1: Establish clear boundaries with principals before introducing AI tools","Prevention 2: Clarify — AI data is a coaching tool only, never an evaluation input","Prevention 3: Share AI data WITH the teacher first, not with administrators","Prevention 4: Apply the 3-Question Framework before sharing any AI output"],"keyPoint":"Your role is to be the Human Filter that prevents AI from becoming Audit Culture 2.0."}]	\N	\N	2026-05-11 14:02:49.011288+00
d24d519c-40c2-4a47-aa3a-8d2e39ace299	2e867af9-1fa4-4e84-8015-c0dfbf9a4850	scenario	{"steps":[{"id":"s13-1","situation":"A teacher tells you: 'I tried the strategy you suggested but it did not work. The students were chaotic.'","context":"You are in the IMPROVE phase of the coaching cycle.","question":"What is the most important thing to notice about this situation?","branches":[{"id":"a","text":"Apologize for suggesting the wrong strategy and give her a better one to try this week.","isCorrect":false,"rationale":"Did the teacher CHOOSE this strategy, or did you SUGGEST it? If you suggested it, the teacher did not own it, which is why it failed. This is the key lesson.","principle":"Choice + Praxis"},{"id":"b","text":"Ask: 'Tell me more about what happened. What did you observe when you tried it?' — gather evidence before interpreting.","isCorrect":true,"rationale":"Before any evaluation or next step, return to the IDENTIFY phase. Gather specific evidence about what happened. The Growth Engine starts with observation.","principle":"Evidence-Based + Dialogue"},{"id":"c","text":"Tell her that the strategy definitely works and she must have implemented it incorrectly.","isCorrect":false,"rationale":"This is dismissive, evaluative, and destroys trust. It blames the teacher without any evidence.","principle":"Equality + Trust"},{"id":"d","text":"Suggest she return to her previous approach since the new strategy did not work.","isCorrect":false,"rationale":"One failed attempt is data, not a verdict. The Growth Engine iterates — gather evidence, analyze, adjust.","principle":"Praxis + Reciprocity"}]},{"id":"s13-2","situation":"A teacher asks: 'You have 18 teachers to coach. How do you decide who gets more of your time?'","context":"This is a genuine, curious question from a reflective teacher.","question":"What is the honest and ethical answer?","branches":[{"id":"a","text":"Tell her that everyone gets equal time — it would not be fair otherwise.","isCorrect":false,"rationale":"Equal time does not mean equitable support. Teachers with different needs require different levels of engagement.","principle":"Equality (correctly understood)"},{"id":"b","text":"Tell her that you focus on teachers who have the most willing attitude and are showing growth.","isCorrect":false,"rationale":"While willingness matters, this approach abandons teachers who most need support.","principle":"Accountability"},{"id":"c","text":"Explain that you balance several factors: teachers with lowest student outcomes, highest willingness, and most growth potential — and that all teachers are in a coaching cycle.","isCorrect":true,"rationale":"This is an honest, principled answer that balances equity with impact. It respects her intelligence and models reflective, accountable coaching practice.","principle":"Accountability + Integrity"},{"id":"d","text":"Say that you cannot share that information — it would breach confidentiality between you and other teachers.","isCorrect":false,"rationale":"Explaining your prioritization framework does not breach confidentiality. This is evasive and misuses the confidentiality principle.","principle":"Integrity + Dialogue"}]}]}	\N	\N	2026-05-11 14:02:38.88811+00
0112be7f-11ae-4076-ab60-fe93bb4b77d4	3ee06af5-aac0-49f9-9963-df6d8096805f	scenario	{"steps":[{"id":"s16-1","situation":"You observe a Grade 7 Science class. Schema: 35 min I Do, 5 min We Do, 0 min You Do, 5 min CFU (45 min total).","context":"The teacher says students had an exam coming up and needed full content coverage.","question":"How do you share this schema data using the Partnership Way?","branches":[{"id":"a","text":"'Your lesson was 78% I Do — research shows students need at least 40% independent practice. You need to restructure your lessons.'","isCorrect":false,"rationale":"Prescribing a formula based on schema percentages turns schema into a compliance measure and ignores context.","principle":"Partnership + Context"},{"id":"b","text":"'I coded 35 min I Do, 5 min We Do, 0 min You Do, 5 min CFU. What was driving the lesson structure today?'","isCorrect":true,"rationale":"Share the neutral data, then invite interpretation. The teacher's context is a legitimate reason for this structure. This opens dialogue without judgment.","principle":"Shared Mirror + Voice + Equality"},{"id":"c","text":"Do not share the schema data — the teacher's explanation makes it irrelevant.","isCorrect":false,"rationale":"The data is still valuable for the coaching conversation. The teacher's intent should inform the co-interpretation, not replace the evidence.","principle":"Evidence-Based"},{"id":"d","text":"'Great lesson! The students seemed to be learning a lot during your explanation.'","isCorrect":false,"rationale":"Vague positive feedback without the schema data misses the coaching opportunity.","principle":"Evidence-Based + Partnership"}]},{"id":"s16-2","situation":"A teacher says: 'Now that I understand the schema, can you tell me the right percentage for each phase? I want to do it correctly.'","context":"He is enthusiastic and genuinely wants to improve.","question":"How do you respond?","branches":[{"id":"a","text":"Give him a 25/25/50 guideline as a starting target — it is better than having no goal.","isCorrect":false,"rationale":"A fixed formula turns schema into a compliance checklist and removes teacher judgment from the equation.","principle":"Choice + Context"},{"id":"b","text":"'The schema does not prescribe percentages — it is a tool to describe what you observe and start conversations. What does your data tell you about your students' needs right now?'","isCorrect":true,"rationale":"This correctly repositions schema as a mirror for reflection, not a formula for compliance, and turns his question into a coaching inquiry about his students.","principle":"Partnership + Voice + Reflection"},{"id":"c","text":"'I do not have an answer to that — it depends on too many factors.' (Leave it at that.)","isCorrect":false,"rationale":"While partially correct, this response is incomplete. He deserves a fuller explanation of why schema has no formula.","principle":"Dialogue + Equality"},{"id":"d","text":"Tell him that what matters most is just that all 4 phases appear in every lesson.","isCorrect":false,"rationale":"Requiring all 4 phases in every lesson is another prescription that ignores context.","principle":"Context + Choice"}]}]}	\N	\N	2026-05-11 14:02:54.24868+00
cc80f3bb-2dd7-453e-ae39-d6e976109ddf	0545c290-98f0-43a4-8651-95fe882671bb	scenario	{"steps":[{"id":"s42-1","situation":"You are coaching a teacher who is currently facing a classroom safety crisis — two students are in a physical altercation and she is completely overwhelmed and freezing at the front of the room.","context":"This is the most unusual situation you have encountered in your coaching career.","question":"In this specific moment, which coaching stance is most appropriate?","branches":[{"id":"a","text":"Facilitative: Asking powerful questions to help them reflect on the crisis.","isCorrect":false,"rationale":"A teacher in a safety crisis cannot access reflective capacity. Asking 'What do you notice?' when two students are fighting is inappropriate and potentially dangerous.","principle":"Adaptive Facilitation — Directive Moment"},{"id":"b","text":"Directive: Providing immediate, clear instructions to ensure safety and clarity.","isCorrect":true,"rationale":"Directive coaching is exactly right when the teacher is overwhelmed or facing a safety issue. 'Call for the principal now. I will speak to the class. We can debrief after.' Partnership resumes when the crisis is resolved.","principle":"Adaptive Facilitation — Directive Moment"},{"id":"c","text":"Silent: Observing from the back to see how they handle it alone.","isCorrect":false,"rationale":"A physical altercation is a safety crisis, not a growth opportunity for observation. The coaching role expands to include active support when safety is threatened.","principle":"Adaptive Facilitation + Reciprocity"},{"id":"d","text":"Evaluative: Taking notes on their lack of crisis management skills.","isCorrect":false,"rationale":"Evaluative note-taking during a crisis abandons the teacher at their most vulnerable moment. This destroys trust permanently and is the opposite of Partnership.","principle":"Equality + Trust"}]},{"id":"s42-2","situation":"A teacher is showing resistance to changing their lesson structure. The Adaptive Facilitator offers the teacher a choice: 'Would you prefer to focus on improving your Check for Understanding questions or your Wait Time transitions first?'","context":"The teacher has been resistant in the last two coaching visits.","question":"Why is offering this choice effective for a resistant teacher?","branches":[{"id":"a","text":"It allows the coach to avoid making a difficult decision.","isCorrect":false,"rationale":"Offering a choice is a strategic partnership move, not an avoidance of responsibility. The coach has already identified two valid growth areas — they are offering genuine alternatives.","principle":"Choice + Adaptive Facilitation"},{"id":"b","text":"It tricks the teacher into doing what the coach wanted all along.","isCorrect":false,"rationale":"Both options are genuine — this is not manipulation. The Choice Principle requires that both options represent real alternatives that fit the teacher's context.","principle":"Choice + Integrity"},{"id":"c","text":"It increases buy-in and agency by allowing the teacher to select a path that fits their current capacity.","isCorrect":true,"rationale":"For resistant teachers, choice is the most powerful tool available. By offering two genuine alternatives, the coach restores autonomy (SCARF), which reduces the resistance that comes from feeling controlled. The teacher now owns the direction.","principle":"Choice + SCARF + Adaptive Facilitation"},{"id":"d","text":"It follows the school's policy that teachers should always be happy.","isCorrect":false,"rationale":"Partnership coaching is not about teacher happiness — it is about building professional capacity through evidence-based partnership. Choice serves agency, not comfort.","principle":"Choice + Praxis"}]}]}	\N	\N	2026-05-13 08:42:04.261702+00
ed48f019-aa97-42cd-af6a-21806caf5280	f60e1788-c4ef-46d2-8a5c-fae94e3b3150	slides	[{"title":"Unit 4.3: The Partnership Advocate","content":"Protecting the Coaching Space Under Systemic Pressure — Becoming a Guardian of the Safe Space","keyPoint":"A Partnership Advocate does not just coach teachers. They actively protect the conditions that make coaching possible.","type":"title"},{"title":"When Advocacy Is Needed","content":"The Partnership Advocate identity activates when systemic pressures threaten coaching integrity:","bullets":["Principal requests coaching notes for performance audit","Coach is asked to rank teachers or identify 'weak' teachers","Coaching time is repeatedly taken by non-coaching duties","Administrative calendar treats coaching as inspection","Teacher is warned that coaching data will affect their evaluation"],"keyPoint":"Advocacy is not confrontation. It is the systematic protection of the conditions that allow growth."},{"title":"The Advocacy Script","content":"When the principal asks: 'Give me your evaluative notes on the bottom 5 teachers for a performance audit.'","bullets":["Validate: 'I understand your goal is school improvement — that is exactly what I am working toward.'","Boundary: 'My coaching folder is a private developmental space for the teacher and coach. If I share individual notes for evaluation, teachers will close off and coaching ends.'","Alternative: 'I can offer a School Growth Map showing anonymous trends — for example, 70% of teachers are mastering the Planning Loop.'","Offer: 'If you have performance concerns about specific teachers, you can conduct your own formal observation. I cannot provide my coaching data for that purpose.'"],"keyPoint":"The Advocacy Script: Validate + Boundary + Alternative + Offer. Never just refuse — always provide a path forward."},{"title":"The School Growth Map as an Alternative","content":"Instead of individual teacher data, offer aggregate school-level patterns:","bullets":["'Across Grade 4, average student engagement moved from 52% to 68% in one term'","'70% of teachers I am working with have strengthened Check for Understanding frequency'","'The most common growth area across all teachers this month is transition management'"],"table":{"headers":["What You CANNOT Share","What You CAN Share"],"rows":[["Individual teacher coaching notes","School-wide growth patterns by grade or area"],["Teacher performance ratings from coaching","Aggregate percentage changes in student outcomes"],["Which teachers are 'weakest' or 'strongest'","Distribution of growth areas without teacher names"]]}},{"title":"Praxis in Advocacy","content":"PRAXIS (PP-6) in advocacy means taking brave, data-informed action to protect the coaching space — not just thinking about the problems.","bullets":["Document every request that threatens confidentiality in writing","Report coaching displacement (non-coaching duties) with WRER data as evidence","Communicate the coaching model to principals at the start of each school year","Build principal relationships proactively — not only when there is a conflict"],"keyPoint":"Advocates who wait until the crisis occurs have already lost. Proactive relationship-building is the best defense."},{"title":"Guarding the Safe Space","content":"The 'Sacred Space' of coaching is the psychological safety that allows teachers to admit struggles, try new strategies, and grow authentically.","bullets":["Once breached, it takes 3–5 visits to rebuild basic trust","Teachers in schools where coaching data is shared with principals perform for coaches — they do not partner with them","Your professional identity as a coach IS the safe space — how you hold it under pressure defines you"],"keyPoint":"Guarding the safe space is not about protecting secrets. It is about protecting the conditions under which genuine professional growth is possible."}]	\N	\N	2026-05-13 08:42:09.720861+00
479a6a02-c89e-4051-a0e6-befc2072045c	304a5e98-5ebe-4a95-823e-5d75ce5708ef	slides	[{"title":"Unit 4.4: The Consistency Guardian (WRER)","content":"Tracking Coaching Frequency and Protecting Against Systemic Displacement","keyPoint":"Consistency — not intensity — is what drives lasting teacher change. The WRER is your consistency diagnostic.","type":"title"},{"title":"Why Consistency Matters More Than Intensity","content":"Research on skill development consistently shows that coaching frequency drives lasting change more than any single intensive session.","table":{"headers":["Infrequent / Intense","Frequent / Consistent"],"rows":[["One deep coaching visit per month","Regular 2-week cycles"],["Teacher forgets context, starts over","Teacher builds on momentum from previous cycle"],["Coach as occasional expert","Coach as ongoing partner"],["Change fades between visits","New habits solidify through repeated feedback loops"]]},"keyPoint":"The 2-week coaching cycle is not arbitrary — it is the minimum frequency for habit solidification."},{"title":"The WRER: Weekly Record of Engagement and Results","content":"WRER = Actual coaching visits completed ÷ Scheduled coaching visits × 100%","bullets":["Purpose: Measures coaching consistency ('Pulse Check') — not teacher performance","Target: 80%+ WRER indicates a healthy coaching program","Below 60%: Signals systemic displacement — coach is being assigned non-coaching duties","How to calculate: Each week, count scheduled visits vs. completed visits"],"keyPoint":"A low WRER is not evidence that the coach is lazy. It is evidence that the system needs a stronger Guardian."},{"title":"Systemic Displacement: The Root Cause of Low WRER","content":"Coaches in Pakistan public schools frequently face displacement — being asked to cover absent teachers, prepare reports, attend non-coaching meetings.","bullets":["Displacement is the single most common reason coaching programs fail","Teachers experience it as inconsistency or abandonment","Using WRER data: 'I completed 40% of scheduled visits because I was asked to cover 8 absent teacher periods'","The data makes the systemic cause visible without personalizing it"],"keyPoint":"WRER data is the tool for making invisible systemic displacement visible to administration."},{"title":"Creating a Response Plan from WRER Data","bullets":["STEP 1: Calculate your WRER for the week — actual/scheduled × 100","STEP 2: If below 80%, identify the cause — displacement, scheduling, absence","STEP 3: Document the cause with specifics — '3 of 4 missing visits were due to assigned class coverage'","STEP 4: Create a Response Plan for the following week — reschedule missed visits, communicate constraints","STEP 5: Share aggregate WRER data with principal proactively — not defensively"],"keyPoint":"The Response Plan converts WRER data from a complaint into a systems conversation with administration."},{"title":"Reciprocity in Consistency","content":"RECIPROCITY (PP-7) applies to consistency: coaches must show up reliably if they expect teachers to be prepared, open, and invested.","bullets":["Teachers who experience inconsistent coaching stop preparing for visits","Teachers who trust the coach will appear start investing in the coaching relationship","'If I want the teacher to commit to a 2-week action step, I must commit to returning in 2 weeks'"],"keyPoint":"Reciprocity in frequency means: coaches earn the trust of consistent teachers by being consistently present."}]	\N	\N	2026-05-13 08:42:14.922454+00
95199149-0d7d-43f1-843c-c2b3d032826a	1a504a0a-f44b-47d0-abc2-e44d19d6508e	scenario	{"steps":[{"id":"s15-1","situation":"The AI coaching app flags Ms. Sana as 'Below Benchmark' on student participation (12%). She teaches 88 students with no teaching assistant.","context":"You observe that Ms. Sana is doing exceptional work given her constraints.","question":"How do you apply the 3-Question AI Validation Framework?","branches":[{"id":"a","text":"Share the AI flag with Ms. Sana exactly as it appears and ask her to address the participation benchmark.","isCorrect":false,"rationale":"Using AI output without applying the 3-Question Framework ignores context and may reflect algorithm bias.","principle":"Context + Partnership"},{"id":"b","text":"Dismiss the AI flag entirely — you know she is doing great work and the AI is wrong.","isCorrect":false,"rationale":"Complete dismissal is also wrong. The AI data might still surface a useful conversation, even if the benchmark is not appropriate.","principle":"Evidence-Based"},{"id":"c","text":"Apply the 3 questions: CONTEXT (88 students, no TA) + BIAS (benchmark built on smaller class data) + PARTNERSHIP (frame as exploration, not failure). Override the raw flag and add full human context.","isCorrect":true,"rationale":"This is the Human Filter at work. All 3 questions reveal the AI flag needs significant contextualisation before use.","principle":"Context + Bias + Partnership"},{"id":"d","text":"Ask Ms. Sana whether she thinks the AI feedback is accurate — let her decide.","isCorrect":false,"rationale":"Sharing raw AI output and asking the teacher to evaluate its accuracy is unfair. The coach should have applied the 3-Question Framework first.","principle":"Human Filter responsibility"}]},{"id":"s15-2","situation":"The principal asks you to share the AI coaching reports for all teachers to identify 'underperforming' staff.","context":"The principal frames it as being in the interest of school improvement.","question":"What do you do?","branches":[{"id":"a","text":"Share the reports — the principal has a legitimate interest in school improvement.","isCorrect":false,"rationale":"This turns AI coaching data into an evaluation tool, which breaches confidentiality and transforms coaching into Audit Culture 2.0.","principle":"Confidentiality + Trust"},{"id":"b","text":"Decline clearly, explain that AI coaching data is a coaching tool only, and offer school-level aggregate themes instead.","isCorrect":true,"rationale":"This holds the boundary, explains the principle, and provides an alternative while protecting the coaching culture.","principle":"Confidentiality + Integrity + Accountability"},{"id":"c","text":"Share anonymised versions of the reports to protect individual teachers.","isCorrect":false,"rationale":"In a small school, anonymised data is often identifiable. This partial solution still risks breaching trust.","principle":"Confidentiality"},{"id":"d","text":"Ask each teacher for consent before sharing their AI report with the principal.","isCorrect":false,"rationale":"Asking teachers to consent to sharing coaching data with evaluative authorities puts them in an impossible position.","principle":"Trust + Confidentiality"}]}]}	\N	\N	2026-05-11 14:02:49.317498+00
baba80ff-e0e2-4d4c-b9ab-a8e317bde750	0afb8e4d-5317-49c3-a2c5-645ede3cb490	slide	https://docs.google.com/presentation/d/1calibration_process_slides/edit?usp=sharing	\N	\N	2026-05-12 16:31:25.928774+00
cc6b205c-37c7-4c4f-ba17-615290a698aa	347928c8-d15d-4989-8750-686a498a20ed	slide	https://docs.google.com/presentation/d/1codesign_action_steps_slides/edit?usp=sharing	\N	\N	2026-05-12 16:31:25.928774+00
c06b33a7-749c-41bb-b216-86e7568ddb41	c97cc119-dd7e-4316-9065-f3b8efd628d9	slide	https://docs.google.com/presentation/d/1observation_data_collection_slides/edit?usp=sharing	\N	\N	2026-05-12 16:31:25.928774+00
490e448f-78b9-4138-b143-cec2030d8009	1f567fe8-df85-4eb7-bfd9-16c530b0d077	slide	https://docs.google.com/presentation/d/1building_habits_mastery_slides/edit?usp=sharing	\N	\N	2026-05-12 16:31:25.928774+00
ea25ff45-1a94-4c1b-869e-1c3098570ab0	12634202-5673-4c03-8a6a-01538f4352c9	slide	https://docs.google.com/presentation/d/1feedback_empathy_slides/edit?usp=sharing	\N	\N	2026-05-12 16:31:25.928774+00
655e2bd5-9a0e-495f-91cf-7d0af2ea33d7	0324fae0-b47c-4c64-9e0f-6c30ad32b3ce	slide	https://docs.google.com/presentation/d/1impact_cycle_overview_slides/edit?usp=sharing	\N	\N	2026-05-12 16:31:25.928774+00
1cfea4b0-596e-400b-905e-922d654c5a5c	fe345622-fee5-43b3-b8d5-ec49020ffe6d	slide	https://docs.google.com/presentation/d/1documentation_followup_slides/edit?usp=sharing	\N	\N	2026-05-12 16:31:25.928774+00
5c59109c-8c5e-420d-8c41-f508f5ec8ae9	bd231775-ab2a-4bb8-91c2-f67830a2a647	slides	[{"title":"Unit 3.1: The Mirror Specialist","content":"Mastering Objective Observation and Data Protection — Moving from Subjective Evaluation to Low-Inference Facts","keyPoint":"A mirror reflects reality without judgment. A Mirror Specialist gives teachers data to examine without triggering defensiveness.","type":"title"},{"title":"The Identity Shift: Expert to Mirror","content":"In Pakistan's public school context, teachers are frequently 'inspected' and 'judged.' To build a true Partnership, you must shift identity.","table":{"headers":["Expert with an Opinion","Mirror Specialist"],"rows":[["Delivers verdicts: 'Your lesson was messy'","Reflects facts: '8 students were talking at 9:10'"],["Triggers defensive response","Triggers curiosity and reflection"],["Positions coach as superior judge","Positions data as the neutral third party"],["Teacher argues or complies","Teacher analyzes and chooses"]]},"keyPoint":"You are no longer an expert with an opinion. You are a Mirror — reality reflected without judgment."},{"title":"Why Opinion Destroys Partnership","bullets":["THREAT RESPONSE: 'Your lesson was messy' → brain registers status threat → cortisol spikes → fight/flight/freeze activates","EQUALITY LOST: Coach moves from co-learner to judge → Partnership Principle 1 violated → teacher is no longer a peer","DIALOGUE STOPS: Teacher in defensive mode composes a defense, not processing feedback → Reflection and Dialogue both collapse"],"keyPoint":"The solution is LOW-INFERENCE DATA — facts that teachers can examine without feeling personally attacked."},{"title":"The Camera Test","content":"THE RULE: 'If a video camera cannot capture it, it is an inference (your opinion), not a fact.'","table":{"headers":["Camera CANNOT Capture (Opinion)","Camera CAN Capture (Fact)"],"rows":[["'The teacher was angry'","'Teacher raised voice and slammed book on desk at 10:14am'"],["'Students were confused'","'6 students asked the same question: Where do we write the answer? in a 3-minute window'"],["'It was a good lesson'","'38 of 40 students completed the task correctly within 5 minutes'"],["'The teacher was not prepared'","'Teacher arrived 4 minutes after students. No materials on desks at 9:00am'"]]},"keyPoint":"Before writing any observation note: 'Could I show this to a judge as evidence without my personal testimony?'"},{"title":"Low-Inference vs. High-Inference Data","table":{"headers":["Domain","High-Inference (Avoid)","Low-Inference (Use)"],"rows":[["Classroom Management","'Poor classroom discipline'","'8 students were talking while teacher explained. 3 left seats between 9:05–9:10.'"],["Instruction Quality","'The lecture was too long'","'Teacher spoke for 22 minutes without asking a question. First student question at 22-min mark.'"],["Student Engagement","'Students seemed disinterested'","'At 15-minute mark: 12/40 students had pens down and were not writing. 5 heads on desks.'"],["Teacher Preparation","'The teacher was well-prepared'","'All materials on desks before students entered. Teacher reviewed notes for 3 minutes before start.'"]]}},{"title":"The T-Chart: Your Primary Observation Tool","content":"Divide your notebook page into two columns: LEFT = Teacher Says/Does | RIGHT = Students Say/Do. Every entry must have a timestamp, a count, and zero adjectives.","table":{"headers":["Teacher Says/Does","Students Say/Do"],"rows":[["9:00 — Writes 3 problems on board","9:00 — 40/45 students looking at board. 5 students talking."],["9:05 — Says 'Solve these now'","9:05 — 10 students ask: 'Which page?'"],["9:10 — Walks to window, looks out 4 minutes","9:10 — 20 students stop writing. 5 begin talking."],["9:14 — Returns to front, writes next problem","9:14 — 30 students resume. 8 still off task."]]},"keyPoint":"No adjectives. Only timestamps, numbers, and specific actions — everything a video camera would record."},{"title":"The Confidentiality Shield: Data Protection in Audit Culture","content":"A principal asks: 'Which two teachers in this school are underperforming? I need them for my report.'","bullets":["STEP 1 — THE BOUNDARY: 'I keep individual coaching notes confidential to ensure teachers feel safe to grow.'","STEP 2 — THE ALTERNATIVE: 'However, I can share school-wide or grade-level trends. Across Grade 4, average student engagement is currently 50%.'","STEP 3 — REDIRECT TO SCHOOL GOAL: 'I can share a monthly one-page school-wide trend report — without individual names.'"],"keyPoint":"One breach of confidentiality can permanently destroy a coaching relationship and make every teacher in the school guarded."}]	\N	\N	2026-05-13 08:19:52.814469+00
654cbb68-b1f5-41d0-85c8-09555045c554	bd231775-ab2a-4bb8-91c2-f67830a2a647	scenario	{"steps":[{"id":"s31-1","situation":"You are observing a classroom where Ms. Bano moves around frequently. After the lesson you want to provide feedback. You have two options for your opening statement.","context":"Ms. Bano is experienced but sensitive to criticism. Your opening framing will set the tone for the entire conversation.","question":"Which observation note passes the 'Camera Test'?","branches":[{"id":"a","text":"'Ms. Bano, you seemed very enthusiastic and energetic during the introduction.'","isCorrect":false,"rationale":"'Enthusiastic' and 'energetic' are emotional states that cannot be filmed. A camera records physical actions (gesturing, moving, vocal variation) but cannot capture internal emotional qualities.","principle":"Camera Test + Low-Inference Data"},{"id":"b","text":"'The students appeared confused when you explained the instructions for the group work.'","isCorrect":false,"rationale":"'Appeared confused' is inference — it is your interpretation of observable behaviors. Low-inference rewrite: '6 students raised hands during instructions. 3 students asked their neighbors what to do.'","principle":"Camera Test + Low-Inference Data"},{"id":"c","text":"'Ms. Bano walked to the back of the room three times and stood by the quietest group for 2 minutes.'","isCorrect":true,"rationale":"This passes the Camera Test perfectly: counts (3 times), specific location (back of room), specific group (quietest group), duration (2 minutes). No adjectives, no inference — only observable facts.","principle":"Camera Test + Low-Inference Data"},{"id":"d","text":"'The lesson was highly effective because the classroom environment felt very positive.'","isCorrect":false,"rationale":"'Highly effective' and 'felt very positive' are both value judgments that a camera cannot record. Neither term is observable or measurable.","principle":"Camera Test + Low-Inference Data"}]},{"id":"s31-2","situation":"During a debrief, a coach tells a teacher: 'Your transition between the lecture and the activity was quite messy and weak.'","context":"The teacher immediately becomes quiet and stops contributing to the conversation.","question":"What is the likely impact of using evaluative adjectives like 'messy' and 'weak'?","branches":[{"id":"a","text":"It motivates the teacher to work harder to impress the coach.","isCorrect":false,"rationale":"Research on feedback and SCARF consistently shows that status threat triggers defensiveness and compliance motivation — not intrinsic growth motivation. The teacher stops processing and starts defending.","principle":"Status + Equality"},{"id":"b","text":"It triggers a status threat and stops the teacher's self-reflection by creating a hierarchy of judgment.","isCorrect":true,"rationale":"This is the precise mechanism. 'Messy' and 'weak' are evaluative labels that position the coach as judge and the teacher as subject — violating Equality (PP-1). The teacher enters defensive mode and stops listening, which collapses Dialogue and Reflection simultaneously.","principle":"Status + Equality + Dialogue"},{"id":"c","text":"It provides the 'tough love' necessary for professional growth.","isCorrect":false,"rationale":"Research on partnership coaching contradicts this. Tough feedback without psychological safety produces compliance or defensiveness — neither of which leads to sustainable skill development.","principle":"Equality + Dialogue"},{"id":"d","text":"It helps the teacher understand exactly how to fix the problem.","isCorrect":false,"rationale":"Evaluative labels ('messy') tell the teacher how the coach perceives them but give no actionable data. Low-inference data ('the transition took 8 minutes and 15 students were off-task during it') gives the teacher something specific to examine and act on.","principle":"Evidence-Based + Dialogue"}]}]}	\N	\N	2026-05-13 08:19:53.054355+00
1827f194-1089-4cc6-96d8-e96130290e3b	a1358ec9-368d-4aba-88b9-9840a3064cd0	slides	[{"title":"Unit 3.2: The Artifact Architect","content":"Collecting and Using Physical Evidence as a Neutral Third Party in Partnership Conversations","keyPoint":"An artifact is a 'slice of classroom reality' that both coach and teacher can examine together — without judgment entering the picture.","type":"title"},{"title":"What Is a Coaching Artifact?","content":"A Coaching Artifact is a physical or digital 'slice' of classroom reality: a photo, student work sample, audio clip, or video excerpt.","table":{"headers":["Handwritten Notes","Coaching Artifact"],"rows":[["Coach's memory + selection bias","Objective record — camera/device captured it"],["Teacher argues: 'That is not what happened'","Hard to dispute what is in the photo"],["Coach is the 'third party' — unsafe","Artifact is the 'third party' — neutral"],["Status threat: teacher vs. coach","Status safety: both examine the same object"]]},"keyPoint":"Artifacts act as a 'Third Party' that both partners can look at together — removing the coach from the position of judge."},{"title":"The Permission Script: Protecting Teacher Agency","content":"BEFORE capturing any photo or video, always ask:","bullets":["'Is it okay if I capture a quick photo of this student's work sample to use in our conversation later?'","'I want to make sure you are comfortable with what I collect — these notes are for our coaching conversation only.'","'You can see everything I capture anytime — nothing goes to the principal.'"],"keyPoint":"The Permission Script protects teacher agency and ensures the teacher feels in control of what is being captured. It also signals that this is partnership, not surveillance."},{"title":"The Edge Artifact: Seeing the Invisible","content":"An 'Edge Artifact' focuses specifically on students in the 'shadows' — back rows, quiet students, the students the teacher cannot easily see.","bullets":["Why the Edge matters: teachers naturally focus on students who participate; 'shadow' students are educationally invisible","Artifact captures: photo of back two rows during independent work showing 12 of 15 with blank pages","In conversation: 'What do you notice in this photo of the back row?'","Result: teacher sees something they genuinely could not see from the front — no status threat, pure discovery"],"keyPoint":"The Edge Artifact makes the invisible visible — creating aha moments that prescriptive feedback never can."},{"title":"How to Introduce an Artifact","table":{"headers":["Avoid (Evaluative)","Use (Partnership)"],"rows":[["'Look at this mistake you made'","'What do you notice in this photo of the back row?'"],["'I took this to show the Principal'","'I captured this for our coaching conversation — let us look at it together'"],["'This is why your lesson failed'","'Here is what the photo shows — what do you make of this?'"],["Coach points to the artifact as evidence of failure","Both partners look at artifact together as a shared mirror"]]},"keyPoint":"Artifacts lower defensiveness because the focus shifts from the teacher's personality to the neutral object."},{"title":"Artifact Protection: The Non-Negotiable Boundary","content":"Coaching artifacts — photos, student work samples, T-charts — are a COACHING TOOL, not an evaluation report.","bullets":["Coach refuses to share individual artifacts with administration to preserve trust","Before any observation: 'Photos and notes are for our conversation only — they never go to the principal or your file.'","If principal requests: 'I can share school-level themes across all teachers — for example, average engagement in Grade 5 is 60%.'","Never share individual teacher artifacts for performance audits or evaluations"],"keyPoint":"Artifact protection is what makes teachers willing to be observed authentically rather than performing for the camera."}]	\N	\N	2026-05-13 08:19:57.815508+00
ab86965b-c034-46ed-a1da-1c754c14694b	a1358ec9-368d-4aba-88b9-9840a3064cd0	scenario	{"steps":[{"id":"s32-1","situation":"A coach wants to capture a photo of a student's work sample to use as a 'Third Party' artifact in a later conversation. Before taking the photo, the coach says: 'Is it okay if I capture a quick photo of this student's response to use for our discussion later?'","context":"The teacher is initially unsure but agrees.","question":"What is the purpose of this 'Permission Script'?","branches":[{"id":"a","text":"To follow school rules regarding the use of mobile phones in the classroom.","isCorrect":false,"rationale":"While following school rules is relevant, the primary coaching purpose of the Permission Script is about the teacher's professional agency and trust — not rule compliance.","principle":"Choice + Trust"},{"id":"b","text":"To ensure the Principal knows the coach is working hard.","isCorrect":false,"rationale":"The Permission Script is not about principal visibility. It is a teacher-facing protection that preserves the coaching confidentiality and signals partnership.","principle":"Confidentiality + Trust"},{"id":"c","text":"To protect teacher agency and ensure the teacher feels in control of what is being captured.","isCorrect":true,"rationale":"The Permission Script serves Partnership Principle 2 (Choice) — the teacher participates in deciding what evidence is collected. It also signals transparency and confidentiality, which builds the trust that makes authentic coaching possible.","principle":"Choice + Trust + Confidentiality"},{"id":"d","text":"To let the students know they are being monitored by the coach.","isCorrect":false,"rationale":"The Permission Script is directed at the teacher, not the students. Its purpose is to preserve teacher agency within the coaching relationship.","principle":"Choice + Trust"}]},{"id":"s32-2","situation":"A teacher is defensive about her classroom management. The coach places a photo on the table showing students in the very back row on their phones while the teacher is at the front.","context":"The teacher had been arguing that 'all students are engaged.'","question":"How does this artifact lower defensiveness compared to the coach stating what she observed?","branches":[{"id":"a","text":"It proves to the teacher that the coach was right all along.","isCorrect":false,"rationale":"Using an artifact to prove the coach was right is still a verdict-delivery approach. The artifact's power comes from being a neutral third party, not from winning an argument.","principle":"Equality + Dialogue"},{"id":"b","text":"It shifts the focus from the teacher's personality to the neutral 'Third Party' object, making the problem something they can solve together.","isCorrect":true,"rationale":"This is the key mechanism. When the artifact is on the table between two partners, the teacher is no longer defending against the coach — both are looking at the same object. Status threat decreases because the 'judge' is no longer the coach; it is the photo itself.","principle":"Equality + Dialogue + Status Safety"},{"id":"c","text":"It makes the meeting more interesting because there are visuals to look at.","isCorrect":false,"rationale":"Engagement is a secondary benefit. The primary mechanism is the reduction of status threat through the 'Third Party' positioning of the artifact.","principle":"Equality + Status Safety"},{"id":"d","text":"It provides evidence that the coach can send to the Principal if needed.","isCorrect":false,"rationale":"This is the exact opposite of the Artifact Protection principle. Using coaching artifacts for evaluation destroys trust permanently.","principle":"Confidentiality + Trust"}]}]}	\N	\N	2026-05-13 08:19:58.046172+00
2d29dbcc-7892-4741-b780-52e9483ab94e	8024ed22-05e8-467b-8d6f-3ce365a66dd1	slides	[{"title":"Unit 3.3: Data Into Dialogue","content":"Transforming Evidence Into Partnership Conversation — Moving from Coach Monologue to Teacher-Led Discovery","keyPoint":"Data shared as a monologue is a verdict. Data shared as an invitation is the start of partnership.","type":"title"},{"title":"The Core Goal: Coach Monologue to Partnership Dialogue","content":"OLD WAY: Coach presents data, interprets it, delivers conclusion, prescribes action. Teacher listens, agrees (or defends), tries to comply.","table":{"headers":["Coach Monologue","Partnership Dialogue"],"rows":[["Coach explains what the data means","Teacher interprets the artifact first"],["Coach prescribes next steps","Teacher chooses action based on own interpretation"],["Teacher is passive recipient","Teacher is active co-analyzer"],["Trust: teacher feels evaluated","Trust: teacher feels supported"]]},"keyPoint":"The single most important move: share the data, then wait for the teacher to interpret it first."},{"title":"The Data-Dialogue Flow","bullets":["STEP 1: Place artifact on the table between you — side by side, not across a desk","STEP 2: 'What do you notice first when you look at this?' (Teacher-First interpretation rule)","STEP 3: WAIT — give 5+ seconds for teacher to examine; resist interpreting before they speak","STEP 4: Coach offers additional observations ONLY after teacher has interpreted first","STEP 5: Co-identify next action — teacher chooses from options"],"keyPoint":"Steps 2 and 3 are where most coaches fail. Asking and then immediately answering is not teacher-first — it is coach monologue disguised as a question."},{"title":"Dialogue Sparkers: Opening Evidence Conversations","table":{"headers":["Context","Dialogue Sparker"],"rows":[["Sharing T-Chart data","'Looking at this T-Chart, what do you notice about the pattern between 9:00 and 9:20?'"],["Sharing photo of back row","'What do you notice in this photo of the back row during independent work?'"],["Sharing student work sample","'Looking at these 3 work samples from students in row 4, what do you see?'"],["Sharing participation counts","'I counted 5 students answering 11 of 12 questions. What do you make of that pattern?'"]]},"keyPoint":"A Dialogue Sparker is an open-ended question about a specific piece of evidence — it ignites teacher reflection, not coach commentary."},{"title":"When a Teacher Becomes Self-Critical","content":"Teacher sees a photo and says: 'Oh no, I look terrible in this. I had no idea how much time I wasted at the front.'","bullets":["Do NOT: 'Yes, I noticed that too — you need to change this.'","Do NOT: 'It is fine, do not be so hard on yourself.'","DO: Redirect to curiosity — 'That is a powerful observation. What does the data suggest you might try?'","The moment of self-criticism is the coaching breakthrough — the teacher is ready to change. Redirect to action."],"keyPoint":"Self-critical insight is the most powerful force in coaching. Your job is to redirect it from shame to strategy."},{"title":"Wait Time and Voice Ratio","bullets":["WAIT TIME: After asking a Dialogue Sparker, count 5 seconds silently before saying anything","Why: Teacher needs thinking space — silence is productive, not awkward","VOICE RATIO: Target 60% teacher talk, 40% coach talk in any debriefing conversation","Why: If the coach is talking more than the teacher, the coach is doing the learning, not the teacher","RECIPROCITY: Both partners open to learning and changing their minds based on data","Test: After each visit — 'What did I learn from this teacher that I did not know before?'"],"keyPoint":"If you spoke more than the teacher during the debrief, revisit the Dialogue Sparkers. Something went wrong."},{"title":"Praxis: The Intersection of Reflection and Action","content":"PRAXIS (PP-6) = Learning happens through real-world action followed by reflection. It is not enough to have insight — insight must lead to a specific, observable action.","bullets":["After teacher interprets artifact and identifies a pattern → 'What would you like to try in the next lesson?'","Teacher + Coach look at seating chart together → plan new arrangement → teacher tries it → both examine new artifact next visit","The coaching cycle is not complete until reflection converts to action and action converts to new evidence"],"keyPoint":"Praxis is the intersection of Reflection (seeing what is) and Action (trying something new). Without it, coaching is just conversation."}]	\N	\N	2026-05-13 08:20:03.177267+00
33d8d9aa-d5fe-473e-940b-87eda0e45250	8024ed22-05e8-467b-8d6f-3ce365a66dd1	scenario	{"steps":[{"id":"s33-1","situation":"At the start of a debrief, the coach places a T-Chart of student evidence on the table. The T-Chart shows that 20 of 40 students stopped writing at 9:10 — the same moment the teacher turned to write on the board.","context":"The coach is following the 'Teacher-First' interpretation rule.","question":"What should the coach do next?","branches":[{"id":"a","text":"Immediately point out the three most important patterns in the data.","isCorrect":false,"rationale":"Pointing out patterns before the teacher has a chance to speak violates Voice (PP-3). The teacher's first interpretation is the most valuable coaching data — it reveals their mental model and opens the door to genuine co-analysis.","principle":"Voice + Dialogue"},{"id":"b","text":"Ask the teacher: 'What do you notice first when you look at these student actions?' and then wait for their response.","isCorrect":true,"rationale":"This is the Teacher-First rule in action. The open question invites teacher interpretation; the wait time creates space for genuine reflection. This is the start of Partnership Dialogue, not coach monologue.","principle":"Voice + Dialogue + Reflection"},{"id":"c","text":"Explain how the data compares to the school's overall performance goals.","isCorrect":false,"rationale":"Contextualizing data relative to school goals before the teacher has interpreted it turns the conversation into a performance evaluation — violating Equality and triggering status threat.","principle":"Equality + Voice"},{"id":"d","text":"Give the teacher a written summary of the data and move to setting new goals.","isCorrect":false,"rationale":"Skipping the teacher's interpretation step and moving directly to goal-setting removes the most important phase of the LEARN cycle — teacher-led sense-making of evidence.","principle":"Voice + Dialogue + Praxis"}]},{"id":"s33-2","situation":"A coach and teacher are looking at a T-Chart artifact together. The teacher says: 'Wow — I did not realize I only called on students on the left side of the room.' The teacher and coach then work together to plan a new seating arrangement.","context":"The teacher identified the pattern themselves — the coach did not point it out.","question":"What Partnership Principle describes this process of using evidence to plan new actions?","branches":[{"id":"a","text":"Compliance and Reporting — the teacher is following the coach's direction.","isCorrect":false,"rationale":"The teacher discovered the pattern independently and chose the action — there was no compliance or direction from the coach. This is the opposite of compliance.","principle":"Choice + Voice"},{"id":"b","text":"Direct Instruction — the coach is teaching the teacher a new technique.","isCorrect":false,"rationale":"Direct Instruction would involve the coach explaining what to do. Here, the teacher identified the issue and co-planned the action — the coach facilitated, not instructed.","principle":"Equality + Choice"},{"id":"c","text":"Praxis — the intersection of Reflection and Action.","isCorrect":true,"rationale":"Praxis (PP-6) is exactly this: the teacher reflected on evidence (saw the pattern), which produced insight, which converted to a specific real-world action (new seating arrangement). This is the Growth Engine at work.","principle":"Praxis + Reflection"},{"id":"d","text":"Evaluative Feedback — the coach is using the data to grade the teacher.","isCorrect":false,"rationale":"Evaluative feedback is what the coach is NOT doing. The coach used evidence to facilitate teacher self-reflection, which is the partnership alternative to evaluation.","principle":"Equality + Dialogue"}]}]}	\N	\N	2026-05-13 08:20:03.397647+00
09ab306f-476d-4499-b50f-152dc74f4a7e	18e5a745-f999-46ff-a29c-97d79611497d	slides	[{"title":"Unit 4.1: The Digital Journal","content":"Adding the Human Heart to Data Through Annotation — From Data Collector to Biographer of Growth","keyPoint":"A photo is a snapshot. A Digital Journal is a story of professional growth across the full Impact Cycle.","type":"title"},{"title":"The Identity Shift: Data Collector to Biographer of Growth","content":"In Units 3.1–3.3 you learned to collect low-inference facts and anchor ratings to artifacts. In this unit you add the layer that transforms raw data into a coaching narrative.","table":{"headers":["Data Collector","Biographer of Growth"],"rows":[["Stores photos and T-Charts","Adds Human Annotation — insights, questions, PP references"],["Evidence is a record of what happened","Evidence becomes a story of how the teacher grew"],["Journal tracks compliance","Journal tracks professional journey"],["Used for evaluation","Used for partnership conversation"]]},"keyPoint":"The Digital Journal is not a performance record — it is a private thinking space that belongs to the coaching partnership."},{"title":"The 7 Partnership Principles in the Digital Journal","table":{"headers":["Principle","In the Journal"],"rows":[["EQUALITY","Use 'We noticed…' and 'We agreed…' — not 'Teacher failed to…'"],["CHOICE","Note when teacher chose an artifact or direction: 'Teacher chose to include the back-row notebook'"],["VOICE","Quote the teacher directly: 'Teacher said: I didn't realise they had stopped writing'"],["DIALOGUE","End annotations with an open question for the next visit"],["REFLECTION","Reference the baseline when writing progress: 'Compare to Identify entry [Date]: 40% → 78%'"],["PRAXIS","Every annotation connects reflection to a classroom action taken or planned"],["RECIPROCITY","Write a Reciprocity Note — one thing the coach learned from this teacher"]]}},{"title":"Three Types of Journal Entries Across the Impact Cycle","table":{"headers":["Phase","Purpose","Sample Language"],"rows":[["IDENTIFY (Baseline)","Establish undisputed current reality; end with teacher-chosen goal","'We noticed 18/40 students off-task in back rows. Teacher's response: I had no idea.'"],["LEARN (Pivot)","Document teacher experimenting with new strategy; normalize imperfection","'First attempt at Think-Pair-Share: 22/40 engaged. Timing needs adjustment — expected in first trial.'"],["IMPROVE (Growth)","Confirm progress using same metric as baseline; include Reciprocity Note","'Compare to Identify: 45% → 87.5% on-task. Goal exceeded. Reciprocity Note: teacher's warm-up technique is worth sharing.'"]]}},{"title":"What Is a Partnership Annotation?","content":"A Partnership Annotation transforms a photo into a coaching tool by adding three elements:","bullets":["1. THE OBSERVATION: A low-inference, specific description of what the artifact shows","2. THE PRINCIPLE REFERENCE: Which Partnership Principle is activated or protected in this moment","3. THE NEXT QUESTION: An open question for the next coaching conversation based on this artifact"],"keyPoint":"Without the annotation, the artifact is just evidence. With it, it becomes a mirror the teacher can use to guide their own growth."},{"title":"Defending Confidentiality: The Digital Journal Under Pressure","content":"A principal says: 'Show me your Digital Journal for Teacher X. I want to see how they are progressing.'","bullets":["Frame the journal as a 'Developmental Tool' for the teacher, not the school","'My coaching folder is a private developmental space for the teacher and coach. If I share it for evaluation, teachers will stop being honest.'","'I can share a school-wide growth trend report — without individual names or journals — to show overall progress.'","Never share individual journal entries for performance audit purposes"],"keyPoint":"The Digital Journal's power depends entirely on the teacher knowing it will not be used against them. One breach permanently ends trust."},{"title":"Sequencing Artifacts in the Digital Journal","content":"The Journal timeline must follow the Impact Cycle arc from first observation to lasting change.","bullets":["IDENTIFY artifacts come first — wide-shot baseline photos, T-Charts with low engagement counts","LEARN artifacts show the first attempt at a new strategy — new seating, new CFU approach","IMPROVE artifacts show the 'After' — same angle as baseline, updated T-Chart with higher counts","Final annotation: Compare to baseline and write the Reciprocity Note"],"keyPoint":"A journal that documents only one phase is incomplete. Coaching impact is only visible when the full arc is documented in one place."}]	\N	\N	2026-05-13 08:41:58.562796+00
ffd73f84-2a6a-4483-882c-45766c2cdde4	894cbae3-025c-45a4-ad73-265d9483aa6a	slides	[{"title":"Unit 5.1: The Power of Choice Within the Impact Cycle","content":"Integrating Choice at Every Phase — Moving from Managing to Partnering","keyPoint":"When a teacher chooses the goal, strategy, and pivot, that teacher is coaching themselves. Your role is to design the conditions for self-directed growth.","type":"title"},{"title":"The Fatal Flaw of the Manager Mindset","content":"Most coaches entered the role with a mental model shaped by how they were taught — expert tells learner what to do. Applied to coaching: coach identifies problem, selects strategy, models it, expects implementation.","table":{"headers":["Manager Mindset","Partner Mindset"],"rows":[["Coach chooses goal","Teacher chooses goal"],["Coach selects strategy","Teacher selects from menu"],["Coach evaluates implementation","Teacher reads own evidence"],["Motivation: please coach","Motivation: reach own goal"],["Change lasts while coach is present","Change outlasts the coaching relationship"]]},"keyPoint":"The moment the coach leaves, motivation evaporates — unless the teacher chose the plan."},{"title":"Choice at Every Phase of the Impact Cycle","table":{"headers":["Phase","Teacher's Choice","Coach's Role"],"rows":[["IDENTIFY","Teacher names the focus area and articulates the PEERS Goal","Coach shares evidence; asks 'What area do you want to strengthen?'"],["LEARN","Teacher selects from a Micro-skills Menu of 2–3 strategies","Coach offers genuine alternatives with rationale; never prescribes"],["IMPROVE","Teacher reads evidence and chooses one of 4 Paths: Stay the Course / Modify / Switch / Re-identify","Coach presents data; asks 'What does the evidence tell you?'"]]},"keyPoint":"Choice is not optional in any phase. Remove it in any one phase and the teacher loses ownership of the whole cycle."},{"title":"The PEERS Goal Framework","content":"In the IDENTIFY phase, the teacher articulates a PEERS Goal — a goal that is:","bullets":["POWERFUL: Connects to something the teacher genuinely cares about","EASY: Small enough to be achievable in 2 weeks (not overwhelming)","EMOTIONALLY PEAKING: The teacher rates ownership at 8+ on a 1–10 scale","REACHABLE: Realistic for the class size, resources, and context","STUDENT-FOCUSED: Explicitly tied to observable student behavior or outcomes"],"keyPoint":"If the teacher cannot rate the goal at 8+, it is not their goal. Return to the evidence and start the co-creation sequence again."},{"title":"The Micro-skills Menu: Choice in the LEARN Phase","content":"When a teacher is ready to try a new strategy, the coach does NOT prescribe one strategy. The coach offers a Menu of Two or Three:","bullets":["Both/all options must be genuinely distinct (not the same strategy reworded)","Each option should have a rationale: 'Some teachers in similar contexts have found X useful because...'","Coach presents: 'Here are two approaches that have worked in classrooms like yours — which one fits?'","Teacher selects — and the selection is final unless new evidence changes it"],"keyPoint":"A menu with only one real option is not a menu — it is a polite mandate."},{"title":"The 4 Paths in the IMPROVE Phase","table":{"headers":["Path","When to Choose It","Coach Move"],"rows":[["STAY THE COURSE","Evidence shows progress; strategy is working","'The data shows movement — what does your gut say?'"],["MODIFY","Strategy is partially working; one adjustment could improve it","'What would you change about how you implemented this?'"],["SWITCH","Evidence shows strategy is not working; try another menu option","'What does the evidence suggest about this approach? Would you like to try something different?'"],["RE-IDENTIFY","Goal itself needs revision (wrong goal, or goal already achieved)","'Given what we now know — is this still the right goal?'"]]},"keyPoint":"The teacher chooses the path. The coach presents the evidence. This is the complete IMPROVE phase sequence."},{"title":"Control vs. Partnership: The Ultimate Comparison","table":{"headers":["Dimension","Control Posture","Partnership Posture"],"rows":[["Goal","Compliance with coach's assessment","Teacher-owned growth and student outcomes"],["Mechanism","Coach tells, teacher does","Teacher discovers, coach facilitates"],["Motivation","External (pleasing coach)","Internal (reaching own goal)"],["Durability","Lasts while coach is present","Outlasts the coaching relationship"],["End state","Teacher needs coach forever","Teacher coaches themselves"]]},"keyPoint":"The end goal of Partnership is its own obsolescence: the teacher no longer needs you because they have internalized the process."}]	\N	\N	2026-05-13 08:42:35.650567+00
a300eeb4-3222-4469-a667-ed09beed3d8b	f60e1788-c4ef-46d2-8a5c-fae94e3b3150	scenario	{"steps":[{"id":"s43-1","situation":"The Principal asks you for your 'evaluative notes' on the 'bottom 5' teachers in the building to help with a performance audit.","context":"The Principal frames this as being for school improvement purposes.","question":"Which response shows 'Mastery' as a Partnership Advocate?","branches":[{"id":"a","text":"Give the notes but ask the Principal to be 'nice' when they talk to the teachers.","isCorrect":false,"rationale":"Sharing individual coaching notes with a principal for evaluation purposes destroys the coaching relationship with every teacher named — regardless of tone. This is a fundamental breach.","principle":"Confidentiality + Trust"},{"id":"b","text":"Refuse to speak to the Principal at all to protect your personal integrity.","isCorrect":false,"rationale":"Total non-engagement is not advocacy — it is avoidance. A Partnership Advocate holds the boundary while providing an alternative and maintaining the working relationship.","principle":"Integrity + Dialogue"},{"id":"c","text":"Redirect the Principal to school-wide growth patterns and trends while firmly protecting individual confidentiality.","isCorrect":true,"rationale":"This is the Advocacy Script: Validate the Principal's improvement goal, set the boundary on individual data, offer the School Growth Map alternative. The coach maintains the relationship while protecting the coaching partnership.","principle":"Confidentiality + Advocacy + Dialogue"},{"id":"d","text":"Hand over the notes immediately to maintain a good relationship with leadership.","isCorrect":false,"rationale":"Maintaining leadership relationships at the cost of teacher confidentiality destroys the coaching program's effectiveness for everyone. Short-term compliance creates long-term damage.","principle":"Confidentiality + Integrity"}]}]}	\N	\N	2026-05-13 08:42:09.957916+00
f955a238-e40d-4961-aaeb-29295a938a69	48b064c9-ab6c-4aab-8b81-f913d7e86173	scenario	{"steps":[{"id":"s52-1","situation":"You observe a lesson where the teacher has a good plan, but students are confused because the instructions for the group activity were delivered too quickly and without a visual aid. You diagnose this as a 'Training Loop' gap.","context":"The teacher's plan was solid — the issue was in the delivery of specific instructions.","question":"According to the Precision Coaching framework, what is your next move?","branches":[{"id":"a","text":"Co-plan a new lesson from scratch to fix the design.","isCorrect":false,"rationale":"Co-planning addresses a Planning Loop gap (where the plan itself is the problem). This is a Training Loop gap — the plan is fine. The teacher needs to practice delivering instructions clearly, not redesign the plan.","principle":"3 Loops Diagnosis"},{"id":"b","text":"Lead a 'Rehearsal' or 'Role-play' where the teacher practices delivering instructions clearly and at a slower pace.","isCorrect":true,"rationale":"Training Loop gaps require micro-move practice — not explanation or planning. A 5-minute rehearsal of the specific instruction-delivery move will be more effective than any amount of theory about classroom management.","principle":"Training Loop + Praxis"},{"id":"c","text":"Tell the teacher to read a book on classroom management.","isCorrect":false,"rationale":"Reading transfers declarative knowledge — not procedural skill. A Training Loop gap is about a missing micro-move, which requires practice to develop, not reading.","principle":"Training Loop + Praxis"},{"id":"d","text":"Report to the Principal that the teacher does not know how to talk to students.","isCorrect":false,"rationale":"This violates confidentiality, misdiagnoses a skill gap as a character problem, and turns a Training Loop gap (solvable through coaching) into an evaluative judgment.","principle":"Confidentiality + Equality"}]},{"id":"s52-2","situation":"A teacher is frustrated because students are not participating in group work. Upon looking at the lesson plan, the coach realizes there is no individual 'Task' or 'Role' assigned to each student — students are put in groups but given no structure for how to work.","context":"This is a consistent pattern across three observed lessons.","question":"This is a 'Planning Loop' gap. What is the most effective intervention?","branches":[{"id":"a","text":"Modeling a lecture for the teacher.","isCorrect":false,"rationale":"Modeling a lecture addresses a Training Loop gap in explanation delivery. This is a Planning Loop gap — the problem is in the lesson design (no roles, no task structure), not in how the teacher talks.","principle":"3 Loops Diagnosis"},{"id":"b","text":"Giving the teacher a 'Warning' for poor performance.","isCorrect":false,"rationale":"This converts a diagnosable Planning Loop gap into a punitive evaluation. The gap has a specific, fixable root cause — the teacher has not designed interdependence into the group task.","principle":"Equality + Diagnosis"},{"id":"c","text":"A 'Co-Planning' session to bridge the design gap by adding specific student roles to the lesson plan.","isCorrect":true,"rationale":"Co-Planning directly addresses the Planning Loop gap (teacher-behavior script without student-response map). Adding specific roles (reader, writer, reporter) and task structure converts the plan from proximity to genuine interdependence.","principle":"Planning Loop + Co-Planning"},{"id":"d","text":"Watching a video of a different teacher who is good at group work.","isCorrect":false,"rationale":"While video modeling can be a useful LEARN phase tool, the immediate intervention for a Planning Loop gap is co-planning the specific lesson that needs redesign — not observing an abstract example.","principle":"Planning Loop + Praxis"}]}]}	\N	\N	2026-05-13 08:42:41.128426+00
237fbc99-a609-4eed-8011-ee5c2a14f04c	20310b34-0585-47ba-8e54-c85baa18876e	scenario	{"steps":[{"id":"s54-1","situation":"After six months of coaching, you notice that the teacher has started using the '3 Loops' logic to diagnose their own lessons without you present. Before the next coaching visit, she sends you a message: 'I think I have a Training Loop gap in my transition routine — I am going to rehearse it with my team on Friday. Can we talk about what I find?'","context":"This teacher started the coaching cycle passively agreeing with coach prescriptions.","question":"This represents the goal of 'Obsolescence' in coaching. What does Obsolescence mean?","branches":[{"id":"a","text":"The coach is no longer useful and should be fired.","isCorrect":false,"rationale":"Obsolescence is the highest measure of coaching success, not a failure. The coaching framework has become the teacher's own internal habit — which is the explicit goal of Partnership Coaching.","principle":"Praxis + Reciprocity"},{"id":"b","text":"The coaching framework has become an 'internal habit' for the teacher, leading to long-term sustainable growth.","isCorrect":true,"rationale":"This is the precise definition of coaching Obsolescence. The teacher now uses the 3 Loops, diagnoses her own gaps, plans her own interventions, and seeks collaborative input rather than waiting for coach prescriptions. The Impact Cycle is now running inside the teacher's professional identity.","principle":"Praxis + Reciprocity + Choice"},{"id":"c","text":"The teacher has memorized the coach's scripts and is just repeating them.","isCorrect":false,"rationale":"The teacher is not repeating scripts — she is applying a diagnostic framework to a novel situation. Memorization is declarative; what she is demonstrating is the application of a procedural framework.","principle":"Praxis + Reflection"},{"id":"d","text":"The school has decided to stop using the coaching program.","isCorrect":false,"rationale":"Obsolescence refers to the coaching framework becoming self-sustaining within the teacher — not the termination of the program.","principle":"Praxis + Reciprocity"}]}]}	\N	\N	2026-05-13 08:42:51.835014+00
7ba26fea-f038-44ff-a57f-2b050f88695a	304a5e98-5ebe-4a95-823e-5d75ce5708ef	scenario	{"steps":[{"id":"s44-1","situation":"Your WRER data shows you completed only 40% of scheduled coaching visits this month because you were repeatedly asked to cover absent teachers' classes.","context":"Your principal has not noticed the low completion rate yet.","question":"How should you use this WRER data?","branches":[{"id":"a","text":"Hide the data so the Principal does not think you are being lazy.","isCorrect":false,"rationale":"Hiding data contradicts the evidence-based approach. WRER data is the tool for making systemic displacement visible — concealing it perpetuates the displacement.","principle":"Integrity + Evidence-Based"},{"id":"b","text":"Use it to complain to the teachers about how busy you are.","isCorrect":false,"rationale":"Sharing your workload struggles with teachers inverts the partnership — the coach is not the person who needs support in this conversation.","principle":"Equality + Professionalism"},{"id":"c","text":"Use it as objective evidence to show the Principal how 'displaced time' is preventing teacher growth.","isCorrect":true,"rationale":"This is the Consistency Guardian move: WRER data converts an invisible systemic problem (displacement) into a visible, specific, non-personal conversation with administration. 'I completed 40% of visits because I covered 8 class periods — here is the data.'","principle":"WRER + Evidence-Based + Advocacy"},{"id":"d","text":"Accept that inconsistency is a normal part of school life and stop tracking it.","isCorrect":false,"rationale":"Accepting displacement without naming it allows the systemic problem to continue. Tracking WRER is the tool that makes the problem actionable.","principle":"Consistency + Advocacy"}]}]}	\N	\N	2026-05-13 08:42:15.144742+00
014671ba-4eac-4249-80a9-3e8626261b99	894cbae3-025c-45a4-ad73-265d9483aa6a	scenario	{"steps":[{"id":"s51-1","situation":"During the 'Learn' phase, a teacher is struggling with student transitions. Instead of telling the teacher which method to use, the coach presents a 'Micro-skills Menu' featuring three different evidence-based strategies: a countdown timer, a musical cue, or a call-and-response.","context":"The teacher has been resistant to coaching in the past because previous coaches prescribed solutions without giving her any say.","question":"Why is providing this 'Menu' essential for Partnership?","branches":[{"id":"a","text":"It allows the coach to avoid being responsible if the strategy fails.","isCorrect":false,"rationale":"The Menu is not an abdication of coaching responsibility. The coach has already curated genuinely useful options. The choice step preserves teacher agency — it does not remove coach accountability.","principle":"Choice + Integrity"},{"id":"b","text":"It ensures the teacher spends more time reading than teaching.","isCorrect":false,"rationale":"The Menu is presented in a brief coaching conversation — not a reading assignment. Its purpose is to offer genuine choice, not to increase workload.","principle":"Choice + Praxis"},{"id":"c","text":"It honors the Choice Principle, ensuring the teacher remains the primary decision-maker and is more likely to implement the strategy.","isCorrect":true,"rationale":"The Menu activates Choice (PP-2): by offering genuinely distinct options, the coach ensures the teacher owns the strategy selection. Research consistently shows that strategies teachers choose are implemented more faithfully than strategies teachers are assigned.","principle":"Choice + PRAXIS + Voice"},{"id":"d","text":"It proves that the coach knows more strategies than the teacher.","isCorrect":false,"rationale":"Demonstrating superior knowledge is a Judge mindset move. The Menu's purpose is to offer genuine choice — not to display coach expertise.","principle":"Equality + Choice"}]},{"id":"s51-2","situation":"A teacher's class has not met their PEERS goal during the 'Improve' phase. The coach asks: 'Now that we see the data, do you want to stick with this strategy but practice it more, or pivot to a different strategy from our menu?'","context":"The teacher was invested in the original strategy but the data shows it is not working.","question":"This approach is designed to:","branches":[{"id":"a","text":"Force the teacher to admit they chose the wrong goal.","isCorrect":false,"rationale":"The coach is not leveraging the data for admission — they are presenting the 4 Paths (Modify vs. Switch) to keep the teacher in a learning state rather than a failure state.","principle":"Equality + Choice"},{"id":"b","text":"Foster 'Voice' and 'Agency,' keeping the teacher in a learning state rather than a failure state.","isCorrect":true,"rationale":"This is the IMPROVE phase sequence executed correctly. The teacher reads the evidence (Voice), chooses the path (Agency), and moves forward without shame. The coach's framing ('stick with or pivot') offers two genuine options — preserving choice at the most vulnerable moment.","principle":"Voice + Agency + Choice"},{"id":"c","text":"Extend the coaching cycle indefinitely so the coach stays busy.","isCorrect":false,"rationale":"The purpose of the IMPROVE phase is to reach the teacher's chosen goal — not to perpetuate the coaching relationship. Closing the loop means tracking evidence until the goal is achieved or re-identified.","principle":"Praxis + Reciprocity"},{"id":"d","text":"Let the students decide what they want to learn next.","isCorrect":false,"rationale":"The 4 Paths are teacher decisions informed by student evidence — not student decisions. The teacher remains the decision-maker in the IMPROVE phase.","principle":"Choice + Voice"}]}]}	\N	\N	2026-05-13 08:42:35.891444+00
1fa79c6d-9545-4f1c-b6dc-58655aff2848	868b0c01-8fca-4f77-865d-f414bde5c0d0	scenario	{"steps":[{"id":"s53-1","situation":"A teacher has 50 students in a tiny classroom with broken furniture. The coach realizes that the teacher's struggle with 'Simultaneous Monitoring' during instruction is actually a systemic constraint, not a skill gap.","context":"The teacher has been trying hard but physically cannot monitor all students while also delivering instruction.","question":"In this case, a 'Mastery' level coach should:","branches":[{"id":"a","text":"Blame the teacher for not being 'tough' enough with the students.","isCorrect":false,"rationale":"Toughness is irrelevant when the constraint is structural. With 50 students in a tiny room with broken furniture, simultaneous delivery and monitoring is physically impossible for anyone.","principle":"Reciprocity (PP-7) + Equality"},{"id":"b","text":"Ignore the physical environment and focus only on the teacher's personality.","isCorrect":false,"rationale":"Ignoring structural constraints violates PP-7 (Reciprocity) — the coach's job includes acknowledging what the system makes impossible, not pretending teacher effort can overcome structural barriers.","principle":"Reciprocity (PP-7)"},{"id":"c","text":"Acknowledge that the systemic environment makes certain moves 'structurally impossible' and advocate for resources or environmental shifts.","isCorrect":true,"rationale":"This is Reciprocity (PP-7) in action. The coach first acknowledges the structural constraint, then works with the teacher to find strategies that reduce the monitoring load (e.g., checkpoint row, peer monitoring). Systemic advocacy (documenting the constraint and raising it with administration) is the next step.","principle":"Reciprocity (PP-7) + Advocacy"},{"id":"d","text":"Tell the teacher to just work harder despite the classroom conditions.","isCorrect":false,"rationale":"This is the antithesis of Reciprocity. Pretending that effort can overcome structural impossibility damages trust and shows the coach has not genuinely engaged with the teacher's context.","principle":"Reciprocity (PP-7) + Equality"}]}]}	\N	\N	2026-05-13 08:42:46.637623+00
2e7582a9-d00f-45b0-b3f7-6920f6d19f4b	578e7066-16a7-4e22-a388-3d4920c716d2	slides	[{"title":"Unit 6.1: Closing the Loop","content":"Bridging the Gap Between the Learn and Improve Phases — Turning Conversation Into Classroom Reality","keyPoint":"A coaching cycle that does not close the loop is just conversation. Closing the Loop is what converts insight into student results.","type":"title"},{"title":"The 'Leaky' Coaching Cycle","content":"In the Pakistan school context, a coaching cycle 'leaks' when a great conversation happens but nothing changes in the classroom.","table":{"headers":["Leaky Cycle (Gap)","Closed Loop (Success)"],"rows":[["Coach and teacher agree on a strategy","Coach returns to observe whether strategy was used"],["Teacher passively agrees","Teacher genuinely commits to a specific, observable action"],["No follow-up observation","Follow-up observation within 2 weeks using same metric"],["Conversation ends the cycle","Evidence closes the cycle"]]},"keyPoint":"The gap between Learn (conversation) and Improve (classroom reality) is where most coaching impact is lost."},{"title":"The Coach's Identity Shift: Inspector to Co-Pilot","content":"When closing the loop, the coach's role shifts from data collector to growth co-pilot:","bullets":["NOT: 'You did not use the transition we planned — why not?'","YES: 'I noticed the Think-Pair-Share did not happen today — what barrier got in the way?'","NOT: 'Why is the class still noisy?'","YES: 'I noticed the signal was not used — what would make it easier to implement?'"],"keyPoint":"The Co-Pilot looks for progress, not compliance. The curious opener replaces the compliance check."},{"title":"The Follow-Up Protocol","bullets":["STEP 1: Return within 2 weeks of the agreed action step — no exceptions","STEP 2: Observe using the SAME metric as the baseline (if you counted raised hands, count again)","STEP 3: Share evidence first: 'Last visit, the count was X. Today, I counted Y.'","STEP 4: Invite teacher interpretation: 'What do you notice about that change?'","STEP 5: Teacher chooses next path from the 4 options (Stay the Course, Modify, Switch, Re-identify)"],"keyPoint":"Steps 2 and 3 are non-negotiable. Changing the metric between visits destroys the teacher's sense of verifiable progress."},{"title":"Strong vs. Weak Action Steps","table":{"headers":["Weak Action Step","Strong Action Step"],"rows":[["'Try to engage students more'","'In the next lesson, use Think-Pair-Share at least once after each explanation'"],["'Work on classroom management'","'Use the clap signal within 5 seconds whenever students are off-task during independent work'"],["'Be more reflective'","'After each lesson this week, write down one thing you observed about student understanding'"],["Vague, unmeasurable, coach-imposed","Bite-sized, observable, teacher-chosen"]]},"keyPoint":"A Strong Action Step is bite-sized, observable, and teacher-chosen. If any of those three are missing, renegotiate."},{"title":"Pivoting: When the Strategy Does Not Work","content":"When a teacher returns and says: 'I tried it, but it made students anxious.'","bullets":["WRONG: 'You must keep using it — it is evidence-based'","WRONG: 'The students are the problem'","RIGHT: Facilitate a Pivot — ask teacher to choose from the 4 Paths","'What would you like to adjust about the approach — the timing, the content, or the strategy itself?'","'Would you like to try a different option from the original menu?'"],"keyPoint":"One failed attempt is data, not a verdict. The Pivot is the teacher's choice, not the coach's decision."}]	\N	\N	2026-05-13 08:43:11.593649+00
078ddb9e-8d76-4b32-9f6f-0b41d9acff5c	578e7066-16a7-4e22-a388-3d4920c716d2	scenario	{"steps":[{"id":"s61-1","situation":"You had a great 'Learn' session with a teacher about using a 'No-Hands-Up' questioning strategy. However, when you return for the next observation, the teacher has reverted to only calling on students who raise their hands.","context":"The teacher had seemed genuinely committed to the strategy in your previous conversation.","question":"According to the module, this is a 'Leaky' coaching cycle. What is the most effective way to 'Close the Loop'?","branches":[{"id":"a","text":"Remind the teacher that the Principal is expecting to see this change in their next formal evaluation.","isCorrect":false,"rationale":"Invoking the principal converts coaching into compliance monitoring — exactly the status threat the coaching relationship is designed to avoid. This would destroy the trust built in the Learn phase.","principle":"Confidentiality + Status Safety"},{"id":"b","text":"Mark the teacher as 'Not Proficient' in your weekly report to create accountability.","isCorrect":false,"rationale":"Evaluative reports on individual teachers breach confidentiality and turn the coaching program into an audit tool. This is the exact opposite of the Protocol Guardrail.","principle":"Confidentiality + Protocol Guardrail"},{"id":"c","text":"Use a 'Curious Opener' such as: 'I noticed the No-Hands-Up strategy was not used today — what barrier got in the way of trying that move?'","isCorrect":true,"rationale":"This is the Co-Pilot identity in action. The Curious Opener acknowledges the gap without judgment, invites the teacher to explain the barrier (which may be legitimate), and opens a productive conversation about the next step. The loop is being closed — not punished.","principle":"Co-Pilot + Curious Opener + Dialogue"},{"id":"d","text":"Give the teacher a new, easier strategy since they clearly could not handle the first one.","isCorrect":false,"rationale":"Prescribing a new strategy without understanding WHY the first one was not used skips the Curious Opener step and violates Voice (PP-3). The barrier might be logistical, contextual, or confidence-related — and the coach cannot know without asking.","principle":"Voice + Dialogue + Choice"}]},{"id":"s61-2","situation":"During a follow-up observation, a teacher says: 'I tried the countdown timer for transitions, but it made the students anxious, so I stopped using it.'","context":"The teacher chose this strategy themselves from the Micro-skills Menu.","question":"A 'Mastery' level coach should respond by:","branches":[{"id":"a","text":"Telling the teacher they must keep using it because it is an evidence-based strategy.","isCorrect":false,"rationale":"Mandating that a teacher continue a strategy they found harmful to students violates Choice (PP-2) and ignores real student evidence. Evidence-based does not mean context-universal.","principle":"Choice + Responsive Contextualization"},{"id":"b","text":"Facilitating a 'Pivot' by asking the teacher if they want to modify the strategy (e.g., visual signal instead of a loud beep) or try a different one from the menu.","isCorrect":true,"rationale":"This is the 4 Paths Guardrail applied correctly: the teacher has evidence (students' anxiety reaction), the coach facilitates the Modify or Switch decision, and the teacher owns the pivot. The student evidence is honored.","principle":"4 Paths + Choice + Responsive Contextualization"},{"id":"c","text":"Agreeing that the students are the problem and moving on to a different topic.","isCorrect":false,"rationale":"Blaming students redirects responsibility and abandons the coaching focus. The student response is data — not a reason to abandon the goal.","principle":"Evidence-Based + Praxis"},{"id":"d","text":"Telling the teacher to ignore the students' anxiety and focus on the clock.","isCorrect":false,"rationale":"Ignoring evidence of student harm violates the student-focused goal of the Impact Cycle. If a strategy is creating anxiety, it needs to be modified or replaced — not forced.","principle":"Responsive Contextualization + Student Focus"}]}]}	\N	\N	2026-05-13 08:43:11.853904+00
8e1d2818-dee7-4660-a8e1-eec70f6250a8	4bcd94c7-5d09-42d2-85b4-8d6120035522	slides	[{"title":"Unit 6.2: The Protocol Guardrail","content":"Using Standardized SOPs to Maintain Partnership and Prevent Status Denial — System Fidelity and Protecting the Coaching Space","keyPoint":"A protocol is not a form to complete. It is a structural protection for the coaching relationship — preventing the Partnership Pathway from sliding back into Audit Culture.","type":"title"},{"title":"High-Fidelity Coaching vs. Audit Drift","table":{"headers":["High-Fidelity (Partnership SOP)","Audit Drift (Status Denial)"],"rows":[["Pre-conference before every observation","Surprise visit — coach walks in without notice"],["Teacher voice heard before coach shares data","Coach delivers verdict before teacher speaks"],["Teacher chooses next action step","Coach prescribes the action step"],["Data shared as a 'Third Party' artifact","Coach presents data as evidence of failure"],["Coaching folder is developmental tool","Coaching notes are shared with principal for evaluation"]]},"keyPoint":"Audit Drift happens one small shortcut at a time. Each shortcut moves the coaching relationship closer to inspection."},{"title":"The Pre-Conference as a Guardrail","content":"The pre-conference (meeting before the observation) is the first line of defense against Audit Drift.","bullets":["Without pre-conference: coach walks in as an inspector — teacher performs, not teaches","With pre-conference: coach and teacher agree on the focus, metric, and observation protocol — teacher teaches authentically","The 20 minutes saved by skipping the pre-conference costs 20 conversations of trust rebuilding later","Pre-conference script: 'Today I will observe [focus]. I will track [metric]. We will meet to discuss [time]. Is there anything you want me to notice?'"],"keyPoint":"The pre-conference is the step that makes everything else possible. Skipping it makes every subsequent step less effective."},{"title":"The 'Improve' Phase Guardrail: The 4 Paths","content":"The 4 Paths are not just options — they are a guardrail against the coach prescribing the next action:","bullets":["STAY THE COURSE: Strategy is working — keep it up","MODIFY: Partially working — adjust one element of implementation","SWITCH: Not working — try another option from the menu","RE-IDENTIFY: Goal itself needs revision — either achieved or wrong"],"keyPoint":"The guardrail: if the coach names the path instead of the teacher, the coach has drifted into inspection. The teacher must choose."},{"title":"Status Confirmation as a Guardrail","content":"Status Confirmation is the practice of using objective evidence to confirm the teacher's professional growth — not the coach's satisfaction.","bullets":["EVALUATIVE ADJECTIVE (breach): 'That was a bad start to the lesson'","STATUS CONFIRMATION (guardrail): 'Compare to last visit: student participation moved from 5 to 18 hands raised. The data confirms your strategy is working.'","The difference: Status Confirmation is objective (count-based) and growth-framed (teacher's growth, not coach's judgment)"],"keyPoint":"Status Confirmation protects the teacher's professional identity while providing concrete evidence of progress."},{"title":"Protecting Data Within the Protocol Guardrail","content":"All data shared within the Protocol Guardrail must be objective student evidence — not coach opinion or evaluative language.","bullets":["Evidence IN (guardrail): '18 of 40 students were writing at 9:10'","Opinion OUT (breach): 'Students were not engaged'","Guardrail test: 'Could this data statement be verified by a video camera?'","If any coaching data would threaten teacher status — reformulate before sharing"],"keyPoint":"The protocol guardrail applies to language as much as to procedure. Every evaluative adjective is a guardrail breach."}]	\N	\N	2026-05-13 08:43:17.206669+00
5f33be99-223e-4ce9-95c2-279d064d3446	4bcd94c7-5d09-42d2-85b4-8d6120035522	scenario	{"steps":[{"id":"s62-1","situation":"Your Principal calls you into their office and says: 'I am doing a performance audit. Give me the names of the three weakest teachers you are coaching so I can decide whose contracts not to renew.'","context":"The principal frames this as being for school improvement purposes.","question":"Based on the Module 6 Mastery Rubric, what is the 'Strong Response'?","branches":[{"id":"a","text":"Give the names but ask the Principal to promise not to tell the teachers where the information came from.","isCorrect":false,"rationale":"Sharing individual teacher names for contract decisions is a fundamental confidentiality breach — regardless of the promise of anonymity. Teachers in a small school will know the source, and the coaching program will end.","principle":"Confidentiality + Integrity"},{"id":"b","text":"Refuse to give any information at all and walk out of the room to protect your integrity.","isCorrect":false,"rationale":"Total non-engagement abandons the relationship with the principal and misses the opportunity to offer a legitimate alternative. The Reciprocity Defense requires staying in the conversation.","principle":"Dialogue + Advocacy"},{"id":"c","text":"Validate the Principal's goal of school improvement, but firmly hold the confidentiality boundary and offer to share 'Aggregate Trends' instead of names.","isCorrect":true,"rationale":"This is the Reciprocity Defense in full: Validate + Redirect + Boundary + Offer. The coach acknowledges the improvement goal (legitimate), protects individual confidentiality (non-negotiable), and provides aggregate trend data as a genuine alternative that serves the principal's goal.","principle":"Reciprocity Defense + Confidentiality + Advocacy"},{"id":"d","text":"Provide the names but only for the teachers who have not been nice to you during coaching sessions.","isCorrect":false,"rationale":"This uses personal grievances to justify a confidentiality breach — which compounds both ethical and professional failures. There is no scenario in which individual performance data is appropriate to share.","principle":"Confidentiality + Integrity"}]}]}	\N	\N	2026-05-13 08:43:17.460015+00
d4794e1c-74dd-43ef-87b5-e9c0cc0909cc	e28d5e1a-ebb0-44d7-9e07-8cc2d6b71430	slides	[{"title":"Unit 6.3: Responsive Contextualization and Praxis","content":"Adapting Strategies to Reality and Ensuring Action — The Human Filter Applied to Coaching","keyPoint":"A strategy that works in theory but not in this classroom, with these students, under these constraints — is not a strategy. It is a recommendation.","type":"title"},{"title":"What Is Responsive Contextualization?","content":"Responsive Contextualization is the process of adjusting coaching strategies to fit the actual constraints of the classroom before sharing them with the teacher.","table":{"headers":["Decontextualized Coaching","Responsive Contextualization"],"rows":[["Shares a strategy that requires a projector (school has no electricity)","Asks about available resources before presenting strategy options"],["Prescribes 'Think-Pair-Share' for a class of 70+ students","Adapts the strategy to the class size: 'How would this look with your 70 students?'"],["Recommends digital tools without checking access","'Given that students do not have devices, here is a low-tech version...'"],["Applies AI benchmark without checking classroom context","Applies the Human Filter before sharing AI data"]]},"keyPoint":"You know the classroom. The strategy does not. You are the bridge between evidence-based practice and this specific context."},{"title":"Praxis: Learning Happens Through Real Action","content":"PRAXIS (PP-6) is the principle that learning happens through real-world action followed by reflection — not through reading, watching, or discussing.","table":{"headers":["Without Praxis","With Praxis"],"rows":[["Coach and teacher have a great conversation","Coach and teacher agree on a specific action for the next lesson"],["Teacher nods and says 'I will try that'","Teacher articulates: 'In lesson 3 on Thursday, I will use the clap signal during transitions'"],["No evidence collected","Coach returns within 2 weeks to observe the specific action"],["Insight evaporates; practice unchanged","Reflection on evidence leads to next iteration"]]},"keyPoint":"Praxis converts Reflection into Action. Without the action step, every coaching conversation is incomplete."},{"title":"The Human Filter in Contextualization","content":"The Human Filter (from Module 1) applies to strategy recommendation just as it applies to AI data:","bullets":["CONTEXT QUESTION: 'Does this strategy account for the classroom reality I observed — class size, resources, curriculum pressure, teacher experience?'","BIAS QUESTION: 'Is this strategy drawn from research on classrooms similar to this one?'","PARTNERSHIP QUESTION: 'Does this strategy preserve teacher choice about how and when to implement it?'"],"keyPoint":"A strategy that does not pass the Human Filter should be adapted, not presented. You are the contextualization layer between research and this classroom."},{"title":"Modeling a Workaround: Responsive Contextualization in Action","content":"A teacher does not have a textbook for a vocabulary lesson. The coach models a workaround:","bullets":["'Here is what I would do with the words written on the board instead of the book pages'","Coach models the activity for 3 minutes using available materials","Coach asks: 'How would you adapt this for your class? What would you change?'","Teacher owns the adaptation — not the coach's version"],"keyPoint":"The Workaround is not a compromise — it is Responsive Contextualization. The constraint becomes a design challenge, not a failure condition."},{"title":"Reflection Without Action Is a Leaky Cycle","content":"Praxis (PP-6) means that reflection must convert to action before the coaching cycle can be considered complete.","bullets":["Coach and teacher discuss the lesson in depth","Teacher says: 'I understand now why the transitions were chaotic'","Meeting ends without a specific action step","Result: next lesson, transitions are still chaotic — insight without praxis is forgettable"],"keyPoint":"The single most important coaching move at the end of every conversation: 'What is the one specific thing you will try in the next lesson — and how will you know if it is working?'"}]	\N	\N	2026-05-13 08:43:22.446437+00
00e62e19-0329-419e-b691-2ea777953e37	e28d5e1a-ebb0-44d7-9e07-8cc2d6b71430	scenario	{"steps":[{"id":"s63-1","situation":"A teacher expresses fear about trying a new, risky student-centered activity while you are observing. You explain: 'I am taking a professional risk by protecting our confidentiality from the administration so that you can feel safe taking a risk with your teaching.'","context":"The teacher had been hesitant to try anything new because previous coaches shared their struggles with the principal.","question":"This statement is the definition of Reciprocity because:","branches":[{"id":"a","text":"The coach and teacher are becoming best friends.","isCorrect":false,"rationale":"Reciprocity in this context is a professional principle, not a social relationship. It describes mutual risk-taking in service of teacher growth and student outcomes.","principle":"Reciprocity + Professionalism"},{"id":"b","text":"The coach is doing the teacher a favor that the teacher must pay back later.","isCorrect":false,"rationale":"Reciprocity is not transactional — it does not create a debt. It is the mutual commitment to the coaching partnership that makes both parties willing to take risks in service of growth.","principle":"Reciprocity + Equality"},{"id":"c","text":"It recognizes that both the coach and teacher must take risks to maintain the Sacred Space of the coaching partnership.","isCorrect":true,"rationale":"This is the precise definition of Reciprocity in Unit 6.4. The coach's risk is professional (protecting confidentiality under administrative pressure). The teacher's risk is pedagogical (trying a new approach that might not work). Both risks are necessary for the partnership to function.","principle":"Reciprocity + Sacred Space + Partnership"},{"id":"d","text":"It ensures that neither the coach nor the teacher gets in trouble with the District.","isCorrect":false,"rationale":"Reciprocity is about enabling growth through mutual risk — not about avoiding institutional consequences. The coach may well face consequences for holding the confidentiality boundary.","principle":"Reciprocity + Integrity"}]}]}	\N	\N	2026-05-13 08:43:22.699898+00
bcb5882c-2eb5-4832-b735-3bd6e0ef4d0d	d24d4240-fbc3-4cb7-996f-ced0099ad60c	slides	[{"title":"Unit 6.4: Reciprocity — The Ethical Defense","content":"Guarding the Sacred Space Against Audit Culture — Professionalism as Integrity","keyPoint":"Reciprocity means both the coach and teacher take risks to maintain the sacred space. The coach takes the professional risk of protecting confidentiality; the teacher takes the professional risk of admitting struggle.","type":"title"},{"title":"What Is Reciprocity in Unit 6.4?","content":"In Module 6, Reciprocity (PP-7) has a specific meaning: the coach protects the teacher's growth data just as they expect the teacher to be honest and vulnerable in the partnership.","table":{"headers":["Coach's Risk","Teacher's Risk"],"rows":[["Protecting confidentiality from administrative pressure","Admitting struggles and trying strategies that might fail"],["Refusing to rank teachers or share evaluative notes","Sharing authentic challenges rather than performing for the coach"],["Advocating for teacher growth even under district pressure","Investing in coaching rather than treating it as inspection"]]},"keyPoint":"The partnership only works if BOTH parties take reciprocal risks. The coach who will not protect data cannot ask teachers to be vulnerable."},{"title":"Audit Culture as a Threat to Reciprocity","content":"Audit Culture is dangerous to coaching because it triggers Fear and Status Denial, causing teachers to hide their struggles.","bullets":["Teachers in audit culture: perform for coaches, hide weaknesses, avoid vulnerability","Result: coaching conversations are performances — not genuine growth partnerships","The Audit Culture threat is not abstract — it is active in every school in Pakistan","Your confidentiality protection is the firewall between Audit Culture and Partnership"],"keyPoint":"Every time you protect a teacher's data under administrative pressure, you are making reciprocal risk-taking possible for every teacher you coach."},{"title":"The Reciprocity Defense: Responding to Administrative Pressure","content":"When a principal asks for names of 'failing' teachers, the Reciprocity Defense strategy:","bullets":["VALIDATE: 'I understand your goal is school improvement — that is exactly what I am working toward.'","REDIRECT: 'I can share aggregate trends: 70% of teachers are mastering the Planning Loop this month.'","BOUNDARY: 'My coaching folder is a private developmental space — sharing individual data would end the coaching relationships that produce those trends.'","OFFER: 'Would a monthly one-page aggregate trend report be useful?'"],"keyPoint":"The Reciprocity Defense never just refuses. It validates, redirects, protects, and offers — in that order."},{"title":"The Sacred Space","content":"The Sacred Space is the professional boundary that ensures coaching remains a developmental tool, not an evaluative one.","bullets":["Once breached, the Sacred Space requires months of consistent behavior to rebuild","Teachers who experience Sacred Space violations perform for coaches rather than partnering with them","Guarding the Sacred Space is not just about confidentiality — it is about the entire coaching climate of the school","Your professional reputation as a Guardian of Safe Space is the foundation of your impact as a coach"],"keyPoint":"The Sacred Space is not a metaphor. It is the specific set of behaviors — confidentiality, partnership language, teacher choice — that creates the conditions for authentic professional growth."},{"title":"Professionalism as Integrity, Not Compliance","content":"In Unit 6.4, professionalism is redefined:","table":{"headers":["Compliance-Based Professionalism","Integrity-Based Professionalism"],"rows":[["Following every command from administration","Guarding the integrity of the partnership even under system pressure"],["Filing required reports on time","Refusing to file reports that compromise teacher confidentiality"],["Maintaining good relationships with principals","Maintaining good relationships while holding the coaching boundary"],["Doing what is required","Doing what is right for teacher growth and student outcomes"]]},"keyPoint":"Professionalism as Integrity means: the coaching partnership is the professional standard, not the administrative hierarchy."}]	\N	\N	2026-05-13 08:43:27.719822+00
a619382f-6be0-418b-86b0-c6121b607c4c	d24d4240-fbc3-4cb7-996f-ced0099ad60c	scenario	{"steps":[{"id":"s64-1","situation":"You are asked by a district official to share your 'Coaching Journal' notes which contain a teacher's private reflections on their failures and struggles.","context":"The official says this is for a district-wide coaching quality review.","question":"How does a 'Mastery' coach define Professionalism in this moment?","branches":[{"id":"a","text":"Following the command of the district official because they are higher in the hierarchy.","isCorrect":false,"rationale":"Compliance-based professionalism means following commands. Integrity-based professionalism means guarding the partnership even when commanded to breach it. The hierarchy does not override the ethical obligation to the teacher.","principle":"Professionalism as Integrity + Confidentiality"},{"id":"b","text":"Guarding the integrity of the partnership by explaining that the journal is a developmental tool for the teacher, not an evaluative tool for the system.","isCorrect":true,"rationale":"This is Integrity-Based Professionalism: the coaching journal is a private developmental space whose power depends on the teacher knowing it will never be used for evaluation. Sharing it destroys the coaching program, not just the individual relationship.","principle":"Professionalism as Integrity + Sacred Space + Confidentiality"},{"id":"c","text":"Deleting the notes immediately so that no one can ever see them.","isCorrect":false,"rationale":"Deleting records is not the solution — it destroys the coaching artifact that documents the teacher's growth journey. The solution is to hold the boundary while explaining why the data is confidential.","principle":"Integrity + Advocacy"},{"id":"d","text":"Giving the notes but editing them first to make the teacher look better.","isCorrect":false,"rationale":"Editing private journal entries and sharing them with evaluative authorities breaches trust on two levels: sharing what should be confidential, and falsifying the record. Both are integrity failures.","principle":"Integrity + Confidentiality"}]}]}	\N	\N	2026-05-13 08:43:28.015759+00
\.


--
-- Data for Name: training_progress; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.training_progress (id, user_id, training_id, score, passed, attempt_count, completed_at, created_at, updated_at, is_completed, tab_switch_count, fullscreen_violations, flagged_for_review, content_completed, content_completed_at, started_at, progress_percentage, last_accessed_at) FROM stdin;
4e3ba19d-0da2-476b-973e-63fe246e64c9	531e9525-9f03-4a02-81e9-1d4ed5100e38	dabd5448-02b0-4abe-8729-47cad9fe1ce8	95	t	1	2026-04-29 07:44:17.547	2026-04-29 07:44:17.885206	2026-04-29 07:44:17.885206	f	0	0	f	f	\N	\N	0	\N
1c921f6b-11c3-4872-826e-bcc5613e57ca	fdb68be8-ed12-42bb-8b27-63b108d44cc0	dabd5448-02b0-4abe-8729-47cad9fe1ce8	95	t	2	2026-04-30 10:59:11.467	2026-04-30 10:55:26.025724	2026-04-30 10:59:13.474357	f	0	0	f	f	\N	\N	0	\N
1c0f0434-4a81-41a2-ba38-5d27558d9271	eb43ebfc-3980-4fdf-81c1-ebdeb1d69b6b	dabd5448-02b0-4abe-8729-47cad9fe1ce8	100	t	1	2026-05-05 13:28:16.577	2026-05-05 13:28:16.583868	2026-05-05 13:28:16.583868	f	0	0	f	f	\N	\N	0	\N
02475942-ecdf-444b-ae18-e787e4a97cbb	13a136e1-8412-4ad9-8c33-8d94ffc08c09	dabd5448-02b0-4abe-8729-47cad9fe1ce8	95	t	1	2026-05-06 10:41:54.307	2026-05-06 10:41:54.636148	2026-05-06 10:41:54.636148	f	0	0	f	f	\N	\N	0	\N
37b45db9-c56a-4e20-80f3-98725b53d1b9	13a136e1-8412-4ad9-8c33-8d94ffc08c09	1682a68d-8350-4495-969c-acf4ac73bb99	100	t	1	2026-05-07 08:13:17.684	2026-05-07 08:13:18.307855	2026-05-07 08:13:18.307855	f	0	0	f	f	\N	\N	0	\N
4e3ba19d-0da2-476b-973e-63fe246e64c9	531e9525-9f03-4a02-81e9-1d4ed5100e38	dabd5448-02b0-4abe-8729-47cad9fe1ce8	95	t	1	2026-04-29 07:44:17.547	2026-04-29 07:44:17.885206	2026-04-29 07:44:17.885206	f	0	0	f	f	\N	\N	0	\N
1c921f6b-11c3-4872-826e-bcc5613e57ca	fdb68be8-ed12-42bb-8b27-63b108d44cc0	dabd5448-02b0-4abe-8729-47cad9fe1ce8	95	t	2	2026-04-30 10:59:11.467	2026-04-30 10:55:26.025724	2026-04-30 10:59:13.474357	f	0	0	f	f	\N	\N	0	\N
1c0f0434-4a81-41a2-ba38-5d27558d9271	eb43ebfc-3980-4fdf-81c1-ebdeb1d69b6b	dabd5448-02b0-4abe-8729-47cad9fe1ce8	100	t	1	2026-05-05 13:28:16.577	2026-05-05 13:28:16.583868	2026-05-05 13:28:16.583868	f	0	0	f	f	\N	\N	0	\N
02475942-ecdf-444b-ae18-e787e4a97cbb	13a136e1-8412-4ad9-8c33-8d94ffc08c09	dabd5448-02b0-4abe-8729-47cad9fe1ce8	95	t	1	2026-05-06 10:41:54.307	2026-05-06 10:41:54.636148	2026-05-06 10:41:54.636148	f	0	0	f	f	\N	\N	0	\N
37b45db9-c56a-4e20-80f3-98725b53d1b9	13a136e1-8412-4ad9-8c33-8d94ffc08c09	1682a68d-8350-4495-969c-acf4ac73bb99	100	t	1	2026-05-07 08:13:17.684	2026-05-07 08:13:18.307855	2026-05-07 08:13:18.307855	f	0	0	f	f	\N	\N	0	\N
c01f29ba-15c9-415f-92b7-59c83e9d0800	e78ada6f-85bc-4228-b03f-5e6e4b5bf760	304a5e98-5ebe-4a95-823e-5d75ce5708ef	\N	t	0	2026-06-16 05:37:35.223228	\N	2026-06-16 05:37:35.213496	t	0	0	f	t	\N	\N	100	\N
9901d88f-066b-4d7a-b158-6344f6a2a5f9	66e67e8e-0ed9-4850-acb4-095a727a7f2e	014e2ea2-3a80-43c5-8f3c-329731000715	\N	t	0	2026-06-16 07:26:56.954711	\N	2026-06-16 07:26:56.945565	t	0	0	f	t	\N	\N	100	\N
\.


--
-- Data for Name: trainings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.trainings (id, module_id, title, description, order_number, is_common, persona_required, main_concepts, max_attempts, quiz_unlock_requires_content, created_at) FROM stdin;
014e2ea2-3a80-43c5-8f3c-329731000715	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Unit 1.0: The Coaching Catalyst	Understanding coaching as a partnership-driven growth engine that honors teacher agency	1	t	\N	Coaching vs inspection, Impact Cycle, 7 Partnership Principles, confidentiality, identity shift	3	t	2026-04-09 09:49:45.671727+00
bcfae3fa-29c9-4972-bb32-c7909b55227c	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Unit 1.1: The Partnership Posture	Shifting from a judging stance to equality-based, side-by-side partnership	2	t	\N	Judge vs Co-Pilot, 3 competency pillars, 4-step observation-to-conversation flow, partnership language toolkit	3	t	2026-04-09 09:49:46.995059+00
9fabc12b-0f30-421d-ad41-4deb372a6314	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Unit 1.2: The Shared Mirror	Presenting classroom data as a neutral starting point for collaborative discovery	3	t	\N	Shared Mirror protocol, low-inference vs high-inference language, audit culture, 4-step process	3	t	2026-04-09 09:49:48.259603+00
2e867af9-1fa4-4e84-8015-c0dfbf9a4850	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Unit 1.3: The Growth Engine	Operationalizing the Impact Cycle through a 4-step evidence-based partnership process	4	t	\N	4-step coaching cycle, evidence vs interpretation, co-analysis, bite-sized action plans, loop closure	3	t	2026-04-09 09:49:49.495096+00
8d82e38c-73f9-4f4f-93ff-a467824ae63c	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Unit 1.4: The Trust Bridge	Building ethical partnership coaching through confidentiality and trust-building practices	5	t	\N	4-pillar ethical framework, 5 confidentiality breach types, trust-building behaviors, principal pressure handling	3	t	2026-04-09 09:49:50.849943+00
1a504a0a-f44b-47d0-abc2-e44d19d6508e	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Unit 1.5: The Human Filter	Using AI as a partnership tool, not a replacement for human professional judgment	6	t	\N	AI opportunity vs risk, 3-question validation framework, Pakistan-specific overrides, AI limitations	3	t	2026-04-09 09:49:52.115354+00
3ee06af5-aac0-49f9-9963-df6d8096805f	dabd5448-02b0-4abe-8729-47cad9fe1ce8	Unit 1.6: Coding the Classroom	Mastering the I Do/We Do/You Do/CFU schema as a partnership coaching tool	7	t	\N	Observation schema, schema + Impact Cycle, sharing schema data in partnership way, audit culture risk	3	t	2026-04-09 09:49:53.359873+00
ad533d06-0947-4f89-854e-64eac7bd009f	1682a68d-8350-4495-969c-acf4ac73bb99	Unit 2.1: Status & Psychological Safety	Building the partnership foundation through status-safe coaching and the SCARF model	1	t	\N	SCARF model, status threat, 7 Partnership Principles as safety tools, evaluative vs. partnership language, confidentiality shield	3	t	2026-05-05 20:14:54.638787+00
e01320fb-012c-430b-a9bf-1e6d0bb5cf95	1682a68d-8350-4495-969c-acf4ac73bb99	Unit 2.2: Evidence-Based Dialogue	Moving from data to teacher agency through observable evidence and curious questioning	2	t	\N	Observable evidence vs. interpretation, 3-step evidence-sharing protocol, Impact Cycle phases, autobiographical listening, voice ratio	3	t	2026-05-05 20:15:01.670653+00
81393e37-2176-4e50-ab5e-c94237481212	1682a68d-8350-4495-969c-acf4ac73bb99	Unit 2.3: Goal-Setting as Co-Creation	Facilitating teacher-owned SMART goals through the 4-step co-creation questioning sequence	3	t	\N	4-step goal co-creation, SMART framework, teacher ownership check (1-10 scale), coach-imposed vs. teacher-owned goals, principal pressure handling	3	t	2026-05-05 20:15:08.692264+00
0324fae0-b47c-4c64-9e0f-6c30ad32b3ce	\N	Unit 1.0: The Impact Cycle Overview	Understand the 4-phase coaching cycle and its role in teacher development	1	t	\N	\N	3	t	2026-05-12 16:31:25.928774+00
c97cc119-dd7e-4316-9065-f3b8efd628d9	\N	Unit 1.1: Observation & Data Collection	Learn systematic observation techniques and how to capture objective classroom data	2	t	\N	\N	3	t	2026-05-12 16:31:25.928774+00
0afb8e4d-5317-49c3-a2c5-645ede3cb490	\N	Unit 1.2: The Calibration Process	Develop shared understanding between coach and teacher through data-based dialogue	3	t	\N	\N	3	t	2026-05-12 16:31:25.928774+00
12634202-5673-4c03-8a6a-01538f4352c9	\N	Unit 1.3: Feedback with Empathy	Master the art of delivering feedback that builds trust and motivates change	4	t	\N	\N	3	t	2026-05-12 16:31:25.928774+00
347928c8-d15d-4989-8750-686a498a20ed	\N	Unit 1.4: Co-Designing Action Steps	Partner with teachers to create realistic, actionable improvement plans	5	t	\N	\N	3	t	2026-05-12 16:31:25.928774+00
fe345622-fee5-43b3-b8d5-ec49020ffe6d	\N	Unit 1.5: Documentation & Follow-up	Track progress and maintain continuity across coaching visits	6	t	\N	\N	3	t	2026-05-12 16:31:25.928774+00
1f567fe8-df85-4eb7-bfd9-16c530b0d077	\N	Unit 1.6: Building Habits & Mastery	Support teachers in making new practices automatic through deliberate practice	7	t	\N	\N	3	t	2026-05-12 16:31:25.928774+00
bd231775-ab2a-4bb8-91c2-f67830a2a647	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	Unit 3.1: The Mirror Specialist	Mastering objective observation and the Camera Test to provide low-inference data that protects teacher status	1	t	\N	Mirror Specialist identity, Camera Test, low-inference vs. high-inference data, T-Chart tool, confidentiality shield, audit culture	3	t	2026-05-13 08:19:52.339882+00
a1358ec9-368d-4aba-88b9-9840a3064cd0	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	Unit 3.2: The Artifact Architect	Collecting and using physical evidence as a neutral third party to lower defensiveness in coaching conversations	2	t	\N	Coaching artifacts, Third Party effect, Permission Script, Edge Artifact, Artifact Protection, partnership vs. audit use of evidence	3	t	2026-05-13 08:19:57.365791+00
8024ed22-05e8-467b-8d6f-3ce365a66dd1	6f0bd368-c57f-45e9-a6ad-f5875a71afa3	Unit 3.3: Data Into Dialogue	Transforming evidence into teacher-led discovery through Dialogue Sparkers and the Teacher-First interpretation rule	3	t	\N	Teacher-First interpretation, Data-Dialogue Flow, Dialogue Sparkers, Wait Time, Voice Ratio, Praxis, self-critical redirection	3	t	2026-05-13 08:20:02.720271+00
18e5a745-f999-46ff-a29c-97d79611497d	930b8390-f110-4949-a5d8-e56596cd8792	Unit 4.1: The Digital Journal	Adding human annotation to transform data into a biography of professional growth across the full Impact Cycle	1	t	\N	Biographer of Growth identity, Human Annotation, Partnership Principles in journaling, Impact Cycle sequencing, confidentiality defence	3	t	2026-05-13 08:41:58.084542+00
0545c290-98f0-43a4-8651-95fe882671bb	930b8390-f110-4949-a5d8-e56596cd8792	Unit 4.2: The Adaptive Facilitator	Reading teacher needs and adjusting coaching stance between directive, facilitative, and consultative modes	2	t	\N	Three coaching stances, reading resistance, Quick Win strategy, Coaching Heavy vs. Light, Reciprocity in facilitation	3	t	2026-05-13 08:42:03.523501+00
f60e1788-c4ef-46d2-8a5c-fae94e3b3150	930b8390-f110-4949-a5d8-e56596cd8792	Unit 4.3: The Partnership Advocate	Protecting coaching integrity against systemic pressures using the Advocacy Script and School Growth Map	3	t	\N	Advocacy Script, School Growth Map, Guardian of Safe Space, Praxis in advocacy, confidentiality boundary	3	t	2026-05-13 08:42:08.887558+00
304a5e98-5ebe-4a95-823e-5d75ce5708ef	930b8390-f110-4949-a5d8-e56596cd8792	Unit 4.4: The Consistency Guardian (WRER)	Tracking coaching frequency and using the Weekly Record of Engagement and Results to address systemic displacement	4	t	\N	WRER formula, systemic displacement, coaching consistency vs. intensity, Response Plan, Reciprocity in frequency	3	t	2026-05-13 08:42:14.434272+00
894cbae3-025c-45a4-ad73-265d9483aa6a	a400e0d7-bd4c-4620-98bd-47e624abcb1a	Unit 5.1: The Power of Choice Within the Impact Cycle	Integrating Choice at every phase of coaching from goal identification to IMPROVE phase pivots	1	t	\N	Choice Principle, PEERS Goal, Micro-skills Menu, 4 Paths (IMPROVE), Control vs. Partnership, coaching Obsolescence	3	t	2026-05-13 08:42:35.196636+00
48b064c9-ab6c-4aab-8b81-f913d7e86173	a400e0d7-bd4c-4620-98bd-47e624abcb1a	Unit 5.2: Finding the 'Why' — Identifying Intellectual Gaps	Moving from symptom-fixing to root cause diagnosis using Curious Openers and mental model identification	2	t	\N	Intellectual Gap, Instructional Catalyst identity, Curious Openers, mental model diagnosis, Status Denial triggers, Pakistan context	3	t	2026-05-13 08:42:40.391804+00
868b0c01-8fca-4f77-865d-f414bde5c0d0	a400e0d7-bd4c-4620-98bd-47e624abcb1a	Unit 5.3: Closing the Loop — Side-by-Side Modeling	Turning the Learn phase into lasting student results through side-by-side modeling and IMPROVE phase meeting protocol	3	t	\N	Side-by-Side Modeling, IMPROVE phase agenda, 4 Paths, evidence thresholds, Co-Modeling Scripts, loop closure	3	t	2026-05-13 08:42:45.8699+00
4bcd94c7-5d09-42d2-85b4-8d6120035522	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	Unit 6.2: The Protocol Guardrail	Using standardized coaching SOPs to prevent drift back into inspection mode and protect the coaching space	2	t	\N	High-Fidelity vs. Audit Drift, Pre-Conference Guardrail, 4 Paths Guardrail, Status Confirmation, data protection within protocol	3	t	2026-05-13 08:43:16.694068+00
d24d4240-fbc3-4cb7-996f-ced0099ad60c	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	Unit 6.4: Reciprocity — The Ethical Defense	Guarding the Sacred Space of coaching against audit culture through mutual risk-taking and integrity-based professionalism	4	t	\N	Reciprocity Defense, Audit Culture threat, Sacred Space, Reciprocity as mutual risk, Integrity vs. Compliance professionalism	3	t	2026-05-13 08:43:27.139138+00
20310b34-0585-47ba-8e54-c85baa18876e	a400e0d7-bd4c-4620-98bd-47e624abcb1a	Unit 5.4: Diagnosing the 3 Loops — Precision Coaching	Identifying Planning, Observation, or Training Loop gaps to prescribe the exact right coaching intervention	4	t	\N	3 Loops framework, Planning Loop, Observation Loop, Training Loop, Precision Diagnosis Sequence, coaching Obsolescence	3	t	2026-05-13 08:42:51.181599+00
578e7066-16a7-4e22-a388-3d4920c716d2	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	Unit 6.1: Closing the Loop	Bridging the Learn and Improve phases through follow-up protocols and Curious Openers that convert conversation to classroom reality	1	t	\N	Leaky coaching cycle, Follow-Up Protocol, Co-Pilot identity, Strong Action Steps, Pivot facilitation, 4 Paths	3	t	2026-05-13 08:43:11.13864+00
e28d5e1a-ebb0-44d7-9e07-8cc2d6b71430	6fb9eda1-921a-4eed-8e8f-fcb1c1a70ca3	Unit 6.3: Responsive Contextualization and Praxis	Adapting strategies to real classroom constraints and ensuring coaching conversations end in observable action	3	t	\N	Responsive Contextualization, Praxis (PP-6), Human Filter for strategies, Workaround modeling, Reflection without action = Leaky cycle	3	t	2026-05-13 08:43:21.971724+00
\.


--
-- Data for Name: user_metrics; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_metrics (id, user_id, quiz_attempts, modules_passed, total_score, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_regions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_regions (id, user_id, region_id, created_at) FROM stdin;
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_roles (id, user_id, role, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, email_confirmed_at, created_at, updated_at) FROM stdin;
prod-test-cb112728-3e0c-4b95-b143-2fb28c9f0267	prod-test-1781516722@test.com	\N	2026-06-15 09:45:25.376043+00	2026-06-15 09:45:25.376043+00
66e67e8e-0ed9-4850-acb4-095a727a7f2e	umar.kabaili@yopmail.com	\N	2026-06-16 07:14:56.258837+00	2026-06-16 07:14:56.258837+00
\.


--
-- Name: user_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_roles_id_seq', 1, false);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: analytics_events analytics_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_pkey PRIMARY KEY (id);


--
-- Name: assessment_attempts assessment_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_attempts
    ADD CONSTRAINT assessment_attempts_pkey PRIMARY KEY (id);


--
-- Name: assessment_definitions assessment_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_definitions
    ADD CONSTRAINT assessment_definitions_pkey PRIMARY KEY (id);


--
-- Name: assessment_responses assessment_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_responses
    ADD CONSTRAINT assessment_responses_pkey PRIMARY KEY (id);


--
-- Name: assessments assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- Name: assessments_user_tracking assessments_user_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments_user_tracking
    ADD CONSTRAINT assessments_user_tracking_pkey PRIMARY KEY (id);


--
-- Name: coach_assignments coach_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coach_assignments
    ADD CONSTRAINT coach_assignments_pkey PRIMARY KEY (id);


--
-- Name: coaching_sessions coaching_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coaching_sessions
    ADD CONSTRAINT coaching_sessions_pkey PRIMARY KEY (id);


--
-- Name: cot_observations cot_observations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cot_observations
    ADD CONSTRAINT cot_observations_pkey PRIMARY KEY (id);


--
-- Name: export_scenario_options export_scenario_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.export_scenario_options
    ADD CONSTRAINT export_scenario_options_pkey PRIMARY KEY (id);


--
-- Name: export_scenarios export_scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.export_scenarios
    ADD CONSTRAINT export_scenarios_pkey PRIMARY KEY (id);


--
-- Name: field_issues field_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_issues
    ADD CONSTRAINT field_issues_pkey PRIMARY KEY (id);


--
-- Name: hots_rubric_dimensions hots_rubric_dimensions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hots_rubric_dimensions
    ADD CONSTRAINT hots_rubric_dimensions_pkey PRIMARY KEY (id);


--
-- Name: module_quiz_attempts module_quiz_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.module_quiz_attempts
    ADD CONSTRAINT module_quiz_attempts_pkey PRIMARY KEY (id);


--
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_pkey PRIMARY KEY (id);


--
-- Name: options options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_unique UNIQUE (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: regions regions_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_code_key UNIQUE (code);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: scenario_options scenario_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scenario_options
    ADD CONSTRAINT scenario_options_pkey PRIMARY KEY (id);


--
-- Name: scenario_options scenario_options_scenario_id_option_letter_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scenario_options
    ADD CONSTRAINT scenario_options_scenario_id_option_letter_key UNIQUE (scenario_id, option_letter);


--
-- Name: scenario_responses scenario_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scenario_responses
    ADD CONSTRAINT scenario_responses_pkey PRIMARY KEY (id);


--
-- Name: scenarios scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scenarios
    ADD CONSTRAINT scenarios_pkey PRIMARY KEY (id);


--
-- Name: session_notes session_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_notes
    ADD CONSTRAINT session_notes_pkey PRIMARY KEY (id);


--
-- Name: teacher_dc_scores teacher_dc_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teacher_dc_scores
    ADD CONSTRAINT teacher_dc_scores_pkey PRIMARY KEY (id);


--
-- Name: training_content training_content_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_content
    ADD CONSTRAINT training_content_pkey PRIMARY KEY (id);


--
-- Name: trainings trainings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT trainings_pkey PRIMARY KEY (id);


--
-- Name: user_metrics user_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_metrics
    ADD CONSTRAINT user_metrics_pkey PRIMARY KEY (id);


--
-- Name: user_regions user_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_regions
    ADD CONSTRAINT user_regions_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_aa_assessment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aa_assessment_id ON public.assessment_attempts USING btree (assessment_id);


--
-- Name: idx_ad_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ad_type ON public.assessment_definitions USING btree (type);


--
-- Name: idx_admin_users_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_users_user_id ON public.admin_users USING btree (user_id);


--
-- Name: idx_ar_assessment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ar_assessment_id ON public.assessment_responses USING btree (assessment_id);


--
-- Name: idx_ar_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ar_question_id ON public.assessment_responses USING btree (question_id);


--
-- Name: idx_aut_module_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aut_module_id ON public.assessments_user_tracking USING btree (module_id);


--
-- Name: idx_aut_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aut_user_id ON public.assessments_user_tracking USING btree (user_id);


--
-- Name: idx_coaching_sessions_coach_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_coaching_sessions_coach_date ON public.coaching_sessions USING btree (coach_id, date);


--
-- Name: idx_coaching_sessions_coachee_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_coaching_sessions_coachee_date ON public.coaching_sessions USING btree (coachee_id, date);


--
-- Name: idx_field_issues_assigned_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_field_issues_assigned_to ON public.field_issues USING btree (assigned_to);


--
-- Name: idx_field_issues_reported_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_field_issues_reported_by ON public.field_issues USING btree (reported_by);


--
-- Name: idx_field_issues_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_field_issues_status ON public.field_issues USING btree (status);


--
-- Name: idx_scenarios_training_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_scenarios_training_id ON public.export_scenarios USING btree (training_id);


--
-- Name: idx_session_notes_session_creator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_session_notes_session_creator ON public.session_notes USING btree (session_id, created_by);


--
-- Name: idx_user_metrics_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_metrics_user_id ON public.user_metrics USING btree (user_id);


--
-- Name: ix_admin_users_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_admin_users_user_id ON public.admin_users USING btree (user_id);


--
-- Name: ix_assessment_attempts_assessment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assessment_attempts_assessment_id ON public.assessment_attempts USING btree (assessment_id);


--
-- Name: ix_assessment_responses_assessment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assessment_responses_assessment_id ON public.assessment_responses USING btree (assessment_id);


--
-- Name: ix_assessment_responses_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assessment_responses_question_id ON public.assessment_responses USING btree (question_id);


--
-- Name: ix_assessments_user_tracking_module_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assessments_user_tracking_module_id ON public.assessments_user_tracking USING btree (module_id);


--
-- Name: ix_assessments_user_tracking_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assessments_user_tracking_user_id ON public.assessments_user_tracking USING btree (user_id);


--
-- Name: ix_coaching_sessions_coach_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_coaching_sessions_coach_id ON public.coaching_sessions USING btree (coach_id);


--
-- Name: ix_coaching_sessions_coachee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_coaching_sessions_coachee_id ON public.coaching_sessions USING btree (coachee_id);


--
-- Name: ix_cot_observations_observer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_cot_observations_observer_id ON public.cot_observations USING btree (observer_id);


--
-- Name: ix_field_issues_assigned_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_field_issues_assigned_to ON public.field_issues USING btree (assigned_to);


--
-- Name: ix_field_issues_reported_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_field_issues_reported_by ON public.field_issues USING btree (reported_by);


--
-- Name: ix_field_issues_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_field_issues_status ON public.field_issues USING btree (status);


--
-- Name: ix_session_notes_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_session_notes_session_id ON public.session_notes USING btree (session_id);


--
-- Name: ix_teacher_dc_scores_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_teacher_dc_scores_region ON public.teacher_dc_scores USING btree (region);


--
-- Name: ix_user_metrics_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_user_metrics_user_id ON public.user_metrics USING btree (user_id);


--
-- Name: ix_user_roles_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_roles_user_id ON public.user_roles USING btree (user_id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: admin_users admin_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: assessment_attempts assessment_attempts_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_attempts
    ADD CONSTRAINT assessment_attempts_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments_user_tracking(id);


--
-- Name: assessment_responses assessment_responses_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_responses
    ADD CONSTRAINT assessment_responses_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments_user_tracking(id);


--
-- Name: assessments assessments_training_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_training_id_fkey FOREIGN KEY (training_id) REFERENCES public.trainings(id);


--
-- Name: assessments_user_tracking assessments_user_tracking_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments_user_tracking
    ADD CONSTRAINT assessments_user_tracking_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: export_scenario_options export_scenario_options_scenario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.export_scenario_options
    ADD CONSTRAINT export_scenario_options_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES public.export_scenarios(id);


--
-- Name: field_issues field_issues_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_issues
    ADD CONSTRAINT field_issues_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: field_issues field_issues_reported_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.field_issues
    ADD CONSTRAINT field_issues_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES public.users(id);


--
-- Name: questions questions_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id);


--
-- Name: session_notes session_notes_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_notes
    ADD CONSTRAINT session_notes_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.coaching_sessions(id);


--
-- Name: training_content training_content_training_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_content
    ADD CONSTRAINT training_content_training_id_fkey FOREIGN KEY (training_id) REFERENCES public.trainings(id);


--
-- Name: trainings trainings_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT trainings_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id);


--
-- Name: user_metrics user_metrics_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_metrics
    ADD CONSTRAINT user_metrics_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: hots_rubric_dimensions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.hots_rubric_dimensions ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict ErYgA4BfnELaqj7CtXi7c2ufsUAwHKWX5GKhvorcEyQUruTRdgBCTo6rWEY3o3H

