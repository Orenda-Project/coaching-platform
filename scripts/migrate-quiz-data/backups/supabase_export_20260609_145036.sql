pg_dump: executing SELECT pg_catalog.set_config('search_path', '', false);
pg_dump: last built-in OID is 16383
pg_dump: reading extensions
pg_dump: identifying extension members
pg_dump: reading schemas
pg_dump: reading user-defined tables
pg_dump: reading user-defined functions
pg_dump: reading user-defined types
pg_dump: reading procedural languages
pg_dump: reading user-defined aggregate functions
pg_dump: reading user-defined operators
pg_dump: reading user-defined access methods
pg_dump: reading user-defined operator classes
pg_dump: reading user-defined operator families
pg_dump: reading user-defined text search parsers
pg_dump: reading user-defined text search templates
pg_dump: reading user-defined text search dictionaries
pg_dump: reading user-defined text search configurations
pg_dump: reading user-defined foreign-data wrappers
pg_dump: reading user-defined foreign servers
pg_dump: reading default privileges
pg_dump: reading user-defined collations
pg_dump: reading user-defined conversions
pg_dump: reading type casts
pg_dump: reading transforms
pg_dump: reading table inheritance information
pg_dump: reading event triggers
pg_dump: finding extension tables
pg_dump: finding inheritance relationships
pg_dump: reading column info for interesting tables
pg_dump: finding table default expressions
pg_dump: finding table check constraints
pg_dump: flagging inherited columns in subtables
pg_dump: reading partitioning data
pg_dump: reading indexes
pg_dump: flagging indexes in partitioned tables
pg_dump: reading extended statistics
pg_dump: reading constraints
pg_dump: reading triggers
pg_dump: reading rewrite rules
pg_dump: reading policies
pg_dump: reading row-level security policies
pg_dump: reading publications
pg_dump: reading publication membership of tables
pg_dump: reading publication membership of schemas
pg_dump: reading subscriptions
pg_dump: reading subscription membership of tables
pg_dump: reading large objects
pg_dump: reading dependency data
pg_dump: saving encoding = UTF8
pg_dump: saving "standard_conforming_strings = on"
pg_dump: saving "search_path = "
pg_dump: creating SCHEMA "_realtime"
pg_dump: creating SCHEMA "auth"
pg_dump: creating SCHEMA "extensions"
pg_dump: creating SCHEMA "graphql"
pg_dump: creating SCHEMA "graphql_public"
pg_dump: creating EXTENSION "pg_net"
pg_dump: creating COMMENT "EXTENSION pg_net"
pg_dump: creating SCHEMA "pgbouncer"
pg_dump: creating SCHEMA "realtime"
pg_dump: creating SCHEMA "storage"
pg_dump: creating SCHEMA "supabase_functions"
pg_dump: creating SCHEMA "supabase_migrations"
pg_dump: creating SCHEMA "vault"
pg_dump: creating EXTENSION "pg_graphql"
pg_dump: creating COMMENT "EXTENSION pg_graphql"
pg_dump: creating EXTENSION "pg_stat_statements"
pg_dump: creating COMMENT "EXTENSION pg_stat_statements"
pg_dump: creating EXTENSION "pgcrypto"
pg_dump: creating COMMENT "EXTENSION pgcrypto"
--
-- PostgreSQL database dump
--

\restrict CYO8YJwc8jpwnYMoiB9zZaMFgCMsNibER7k7RtSLDQBFLxEe1k0vmZE7IRFPWjG

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.3 (Homebrew)

-- Started on 2026-06-09 14:50:37 PKT

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
-- TOC entry 10 (class 2615 OID 16661)
-- Name: _realtime; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA _realtime;


ALTER SCHEMA _realtime OWNER TO postgres;

--
-- TOC entry 22 (class 2615 OID 16457)
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- TOC entry 16 (class 2615 OID 16394)
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- TOC entry 21 (class 2615 OID 16574)
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- TOC entry 20 (class 2615 OID 16563)
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- TOC entry 7 (class 3079 OID 16662)
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;


--
-- TOC entry 4738 (class 0 OID 0)
-- Dependencies: 7
-- Name: EXTENSION pg_net; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_net IS 'Async HTTP';


--
-- TOC entry 12 (class 2615 OID 16386)
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- TOC entry 17 (class 2615 OID 16555)
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- TOC entry 23 (class 2615 OID 16505)
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- TOC entry 14 (class 2615 OID 16708)
-- Name: supabase_functions; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA supabase_functions;


ALTER SCHEMA supabase_functions OWNER TO supabase_admin;

--
-- TOC entry 18 (class 2615 OID 18494)
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA supabase_migrations;


ALTER SCHEMA supabase_migrations OWNER TO postgres;

--
-- TOC entry 19 (class 2615 OID 16603)
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- TOC entry 6 (class 3079 OID 16639)
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- TOC entry 4745 (class 0 OID 0)
-- Dependencies: 6
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- TOC entry 4 (class 3079 OID 16515)
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- TOC entry 4746 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- TOC entry 3 (class 3079 OID 16406)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- TOC entry 4747 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ONpg_dump: creating EXTENSION "supabase_vault"
pg_dump: creating COMMENT "EXTENSION supabase_vault"
pg_dump: creating EXTENSION "uuid-ossp"
pg_dump: creating COMMENT "EXTENSION "uuid-ossp""
pg_dump: creating TYPE "auth.aal_level"
pg_dump: creating TYPE "auth.code_challenge_method"
pg_dump: creating TYPE "auth.factor_status"
pg_dump: creating TYPE "auth.factor_type"
pg_dump: creating TYPE "auth.oauth_authorization_status"
pg_dump: creating TYPE "auth.oauth_client_type"
pg_dump: creating TYPE "auth.oauth_registration_type"
pg_dump: creating TYPE "auth.oauth_response_type"
pg_dump: creating TYPE "auth.one_time_token_type"
pg_dump: creating TYPE "public.app_role"
pg_dump: creating TYPE "realtime.action"
pg_dump: creating TYPE "realtime.equality_op"
 EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 5 (class 3079 OID 16604)
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- TOC entry 4748 (class 0 OID 0)
-- Dependencies: 5
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- TOC entry 2 (class 3079 OID 16395)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- TOC entry 4749 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 1185 (class 1247 OID 18070)
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- TOC entry 1209 (class 1247 OID 18213)
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- TOC entry 1182 (class 1247 OID 18064)
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- TOC entry 1179 (class 1247 OID 18058)
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- TOC entry 1227 (class 1247 OID 18316)
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


ALTER TYPE auth.oauth_authorization_status OWNER TO supabase_auth_admin;

--
-- TOC entry 1239 (class 1247 OID 18389)
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


ALTER TYPE auth.oauth_client_type OWNER TO supabase_auth_admin;

--
-- TOC entry 1221 (class 1247 OID 18294)
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- TOC entry 1230 (class 1247 OID 18326)
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


ALTER TYPE auth.oauth_response_type OWNER TO supabase_auth_admin;

--
-- TOC entry 1215 (class 1247 OID 18255)
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- TOC entry 1281 (class 1247 OID 18651)
-- Name: app_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.app_role AS ENUM (
    'admin',
    'user',
    'regional_admin'
);


ALTER TYPE public.app_role OWNER TO postgres;

--
-- TOC entry 1128 (class 1247 OID 17160)
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- TOC entry 1119 (class 1247 OID 17097)
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admpg_dump: creating TYPE "realtime.user_defined_filter"
pg_dump: creating TYPE "realtime.wal_column"
pg_dump: creating TYPE "realtime.wal_rls"
pg_dump: creating TYPE "storage.buckettype"
pg_dump: creating FUNCTION "auth.email()"
pg_dump: creating COMMENT "auth.FUNCTION email()"
pg_dump: creating FUNCTION "auth.jwt()"
pg_dump: creating FUNCTION "auth.role()"
pg_dump: creating COMMENT "auth.FUNCTION role()"
pg_dump: creating FUNCTION "auth.uid()"
pg_dump: creating COMMENT "auth.FUNCTION uid()"
pg_dump: creating FUNCTION "extensions.grant_pg_cron_access()"
in
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- TOC entry 1122 (class 1247 OID 17111)
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- TOC entry 1134 (class 1247 OID 17284)
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- TOC entry 1131 (class 1247 OID 17173)
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- TOC entry 1155 (class 1247 OID 17875)
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


ALTER TYPE storage.buckettype OWNER TO supabase_storage_admin;

--
-- TOC entry 446 (class 1255 OID 16503)
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- TOC entry 4750 (class 0 OID 0)
-- Dependencies: 446
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- TOC entry 442 (class 1255 OID 18039)
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- TOC entry 432 (class 1255 OID 16502)
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- TOC entry 4753 (class 0 OID 0)
-- Dependencies: 432
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- TOC entry 427 (class 1255 OID 16501)
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- TOC entry 4755 (class 0 OID 0)
-- Dependencies: 427
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- TOC entry 441 (class 1255 OID 16510)
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_epg_dump: creating COMMENT "extensions.FUNCTION grant_pg_cron_access()"
pg_dump: creating FUNCTION "extensions.grant_pg_graphql_access()"
pg_dump: creating COMMENT "extensions.FUNCTION grant_pg_graphql_access()"
vent_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO supabase_admin;

--
-- TOC entry 4771 (class 0 OID 0)
-- Dependencies: 441
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- TOC entry 418 (class 1255 OID 16568)
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- TOC entry 4773 (class 0 OID 0)
-- Dependpg_dump: creating FUNCTION "extensions.grant_pg_net_access()"
pg_dump: creating COMMENT "extensions.FUNCTION grant_pg_net_access()"
pg_dump: creating FUNCTION "extensions.pgrst_ddl_watch()"
pg_dump: creating FUNCTION "extensions.pgrst_drop_watch()"
pg_dump: creating FUNCTION "extensions.set_graphql_placeholder()"
encies: 418
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- TOC entry 322 (class 1255 OID 16512)
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

    REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO supabase_admin;

--
-- TOC entry 4775 (class 0 OID 0)
-- Dependencies: 322
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- TOC entry 444 (class 1255 OID 16559)
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- TOC entry 429 (class 1255 OID 16560)
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- TOC entry 416 (class 1255 OID 16570)
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extenspg_dump: creating COMMENT "extensions.FUNCTION set_graphql_placeholder()"
pg_dump: creating FUNCTION "pgbouncer.get_auth(text)"
pg_dump: creating FUNCTION "public.handle_new_user()"
pg_dump: creating FUNCTION "public.has_role(uuid, public.app_role)"
pg_dump: creating FUNCTION "public.set_updated_at_module_quiz_attempts()"
ions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- TOC entry 4804 (class 0 OID 0)
-- Dependencies: 416
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- TOC entry 367 (class 1255 OID 16387)
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

--
-- TOC entry 375 (class 1255 OID 18648)
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- TOC entry 371 (class 1255 OID 18666)
-- Name: has_role(uuid, public.app_role); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.has_role(_user_id uuid, _role public.app_role) OWNER TO postgres;

--
-- TOC entry 401 (class 1255 OID 18941)
-- Name: set_updated_at_module_quiz_attempts(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_updated_at_module_quiz_attempts() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_updated_at_module_quizpg_dump: creating FUNCTION "public.update_updated_at_column()"
pg_dump: creating FUNCTION "realtime.apply_rls(jsonb, integer)"
_attempts() OWNER TO postgres;

--
-- TOC entry 327 (class 1255 OID 18646)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

--
-- TOC entry 392 (class 1255 OID 17235)
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((pg_dump: creating FUNCTION "realtime.broadcast_changes(text, text, text, text, text, record, record, text)"
c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- TOC entry 334 (class 1255 OID 17515)
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        pg_dump: creating FUNCTION "realtime.build_prepared_statement_sql(text, regclass, realtime.wal_column[])"
pg_dump: creating FUNCTION "realtime.cast(text, regtype)"
pg_dump: creating FUNCTION "realtime.check_equality_op(realtime.equality_op, regtype, text, text)"
pg_dump: creating FUNCTION "realtime.is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[])"
RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- TOC entry 320 (class 1255 OID 17297)
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- TOC entry 434 (class 1255 OID 17156)
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- TOC entry 343 (class 1255 OID 17132)
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- TOC entry 389 (class 1255 OID 17285)
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen bepg_dump: creating FUNCTION "realtime.list_changes(name, name, integer, integer)"
pg_dump: creating FUNCTION "realtime.quote_wal2json(regclass)"
cause subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- TOC entry 426 (class 1255 OID 17329)
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- TOC entry 386 (class 1255 OID 17131)
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idpg_dump: creating FUNCTION "realtime.send(jsonb, text, text, boolean)"
pg_dump: creating FUNCTION "realtime.subscription_check_filters()"
x = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- TOC entry 394 (class 1255 OID 17514)
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- TOC entry 437 (class 1255 OID 17127)
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can'pg_dump: creating FUNCTION "realtime.to_regrole(text)"
pg_dump: creating FUNCTION "realtime.topic()"
pg_dump: creating FUNCTION "storage.allow_any_operation(text[])"
pg_dump: creating FUNCTION "storage.allow_only_operation(text)"
pg_dump: creating FUNCTION "storage.can_insert_object(text, text, uuid, jsonb)"
pg_dump: creating FUNCTION "storage.enforce_bucket_name_length()"
t be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- TOC entry 381 (class 1255 OID 17208)
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- TOC entry 330 (class 1255 OID 17474)
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- TOC entry 395 (class 1255 OID 17990)
-- Name: allow_any_operation(text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.allow_any_operation(expected_operations text[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$$;


ALTER FUNCTION storage.allow_any_operation(expected_operations text[]) OWNER TO supabase_storage_admin;

--
-- TOC entry 425 (class 1255 OID 17989)
-- Name: allow_only_operation(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.allow_only_operation(expected_operation text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$$;


ALTER FUNCTION storage.allow_only_operation(expected_operation text) OWNER TO supabase_storage_admin;

--
-- TOC entry 448 (class 1255 OID 17816)
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- TOC entry 431 (class 1255 OID 17872)
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characterspg_dump: creating FUNCTION "storage.extension(text)"
pg_dump: creating FUNCTION "storage.filename(text)"
pg_dump: creating FUNCTION "storage.foldername(text)"
pg_dump: creating FUNCTION "storage.get_common_prefix(text, text, text)"
pg_dump: creating FUNCTION "storage.get_size_by_bucket()"
pg_dump: creating FUNCTION "storage.list_multipart_uploads_with_delimiter(text, text, text, integer, text, text)"
). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION storage.enforce_bucket_name_length() OWNER TO supabase_storage_admin;

--
-- TOC entry 373 (class 1255 OID 17791)
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 337 (class 1255 OID 17790)
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 353 (class 1255 OID 17789)
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 350 (class 1255 OID 17978)
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$$;


ALTER FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) OWNER TO supabase_storage_admin;

--
-- TOC entry 433 (class 1255 OID 17803)
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- TOC entry 332 (class 1255 OID 17855)
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
       pg_dump: creating FUNCTION "storage.list_objects_with_delimiter(text, text, text, integer, text, text, text)"
         key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- TOC entry 344 (class 1255 OID 17979)
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects opg_dump: creating FUNCTION "storage.operation()"
pg_dump: creating FUNCTION "storage.protect_delete()"
pg_dump: creating FUNCTION "storage.search(text, text, integer, integer, integer, text, text, text)"

                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text, sort_order text) OWNER TO supabase_storage_admin;

--
-- TOC entry 355 (class 1255 OID 17871)
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- TOC entry 319 (class 1255 OID 17985)
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.protect_delete() OWNER TO supabase_storage_admin;

--
-- TOC entry 411 (class 1255 OID 17805)
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucketpg_dump: creating FUNCTION "storage.search_by_timestamp(text, text, integer, integer, text, text, text, text)"
_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- TOC entry 360 (class 1255 OID 17983)
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cupg_dump: creating FUNCTION "storage.search_v2(text, text, integer, integer, text, text, text, text)"
rsor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$_$;


ALTER FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) OWNER TO supabase_storage_admin;

--
-- TOC entry 331 (class 1255 OID 17982)
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
 pg_dump: creating FUNCTION "storage.update_updated_at_column()"
pg_dump: creating FUNCTION "supabase_functions.http_request()"
pg_dump: creating TABLE "_realtime.extensions"
   v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$$;


ALTER FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text) OWNER TO supabase_storage_admin;

--
-- TOC entry 351 (class 1255 OID 17806)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

--
-- TOC entry 366 (class 1255 OID 16732)
-- Name: http_request(); Type: FUNCTION; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE FUNCTION supabase_functions.http_request() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'supabase_functions'
    AS $$
  DECLARE
    request_id bigint;
    payload jsonb;
    url text := TG_ARGV[0]::text;
    method text := TG_ARGV[1]::text;
    headers jsonb DEFAULT '{}'::jsonb;
    params jsonb DEFAULT '{}'::jsonb;
    timeout_ms integer DEFAULT 1000;
  BEGIN
    IF url IS NULL OR url = 'null' THEN
      RAISE EXCEPTION 'url argument is missing';
    END IF;

    IF method IS NULL OR method = 'null' THEN
      RAISE EXCEPTION 'method argument is missing';
    END IF;

    IF TG_ARGV[2] IS NULL OR TG_ARGV[2] = 'null' THEN
      headers = '{"Content-Type": "application/json"}'::jsonb;
    ELSE
      headers = TG_ARGV[2]::jsonb;
    END IF;

    IF TG_ARGV[3] IS NULL OR TG_ARGV[3] = 'null' THEN
      params = '{}'::jsonb;
    ELSE
      params = TG_ARGV[3]::jsonb;
    END IF;

    IF TG_ARGV[4] IS NULL OR TG_ARGV[4] = 'null' THEN
      timeout_ms = 1000;
    ELSE
      timeout_ms = TG_ARGV[4]::integer;
    END IF;

    CASE
      WHEN method = 'GET' THEN
        SELECT http_get INTO request_id FROM net.http_get(
          url,
          params,
          headers,
          timeout_ms
        );
      WHEN method = 'POST' THEN
        payload = jsonb_build_object(
          'old_record', OLD,
          'record', NEW,
          'type', TG_OP,
          'table', TG_TABLE_NAME,
          'schema', TG_TABLE_SCHEMA
        );

        SELECT http_post INTO request_id FROM net.http_post(
          url,
          payload,
          params,
          headers,
          timeout_ms
        );
      ELSE
        RAISE EXCEPTION 'method argument % is invalid', method;
    END CASE;

    INSERT INTO supabase_functions.hooks
      (hook_table_id, hook_name, request_id)
    VALUES
      (TG_RELID, TG_NAME, request_id);

    RETURN NEW;
  END
$$;


ALTER FUNCTION supabase_functions.http_request() OWNER TO supabase_functions_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 256 (class 1259 OID 16756)
-- Name: extensions; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _repg_dump: creating TABLE "_realtime.schema_migrations"
pg_dump: creating TABLE "_realtime.tenants"
pg_dump: creating TABLE "auth.audit_log_entries"
pg_dump: creating COMMENT "auth.TABLE audit_log_entries"
pg_dump: creating TABLE "auth.custom_oauth_providers"
altime.extensions (
    id uuid NOT NULL,
    type text,
    settings jsonb,
    tenant_external_id text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE _realtime.extensions OWNER TO supabase_admin;

--
-- TOC entry 254 (class 1259 OID 16742)
-- Name: schema_migrations; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE _realtime.schema_migrations OWNER TO supabase_admin;

--
-- TOC entry 255 (class 1259 OID 16747)
-- Name: tenants; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.tenants (
    id uuid NOT NULL,
    name text,
    external_id text,
    jwt_secret text,
    max_concurrent_users integer DEFAULT 200 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    max_events_per_second integer DEFAULT 100 NOT NULL,
    postgres_cdc_default text DEFAULT 'postgres_cdc_rls'::text,
    max_bytes_per_second integer DEFAULT 100000 NOT NULL,
    max_channels_per_client integer DEFAULT 100 NOT NULL,
    max_joins_per_second integer DEFAULT 500 NOT NULL,
    suspend boolean DEFAULT false,
    jwt_jwks jsonb,
    notify_private_alpha boolean DEFAULT false,
    private_only boolean DEFAULT false NOT NULL,
    migrations_ran integer DEFAULT 0,
    broadcast_adapter character varying(255) DEFAULT 'gen_rpc'::character varying,
    max_presence_events_per_second integer DEFAULT 1000,
    max_payload_size_in_kb integer DEFAULT 3000,
    CONSTRAINT jwt_secret_or_jwt_jwks_required CHECK (((jwt_secret IS NOT NULL) OR (jwt_jwks IS NOT NULL)))
);


ALTER TABLE _realtime.tenants OWNER TO supabase_admin;

--
-- TOC entry 239 (class 1259 OID 16488)
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- TOC entry 4841 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- TOC entry 289 (class 1259 OID 18412)
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discpg_dump: creating TABLE "auth.flow_state"
pg_dump: creating COMMENT "auth.TABLE flow_state"
pg_dump: creating TABLE "auth.identities"
pg_dump: creating COMMENT "auth.TABLE identities"
pg_dump: creating COMMENT "auth.COLUMN identities.email"
overy_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


ALTER TABLE auth.custom_oauth_providers OWNER TO supabase_auth_admin;

--
-- TOC entry 283 (class 1259 OID 18217)
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- TOC entry 4844 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- TOC entry 274 (class 1259 OID 18010)
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- TOC entry 4846 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- TOC entry 4847 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.idepg_dump: creating TABLE "auth.instances"
pg_dump: creating COMMENT "auth.TABLE instances"
pg_dump: creating TABLE "auth.mfa_amr_claims"
pg_dump: creating COMMENT "auth.TABLE mfa_amr_claims"
pg_dump: creating TABLE "auth.mfa_challenges"
pg_dump: creating COMMENT "auth.TABLE mfa_challenges"
pg_dump: creating TABLE "auth.mfa_factors"
pg_dump: creating COMMENT "auth.TABLE mfa_factors"
pg_dump: creating COMMENT "auth.COLUMN mfa_factors.last_webauthn_challenge_data"
pg_dump: creating TABLE "auth.oauth_authorizations"
ntities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- TOC entry 238 (class 1259 OID 16481)
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- TOC entry 4849 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- TOC entry 278 (class 1259 OID 18102)
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- TOC entry 4851 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- TOC entry 277 (class 1259 OID 18090)
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- TOC entry 4853 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- TOC entry 276 (class 1259 OID 18077)
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- TOC entry 4855 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- TOC entry 4856 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- TOC entry 286 (class 1259 OID 18329)
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamppg_dump: creating TABLE "auth.oauth_client_states"
pg_dump: creating COMMENT "auth.TABLE oauth_client_states"
pg_dump: creating TABLE "auth.oauth_clients"
pg_dump: creating TABLE "auth.oauth_consents"
pg_dump: creating TABLE "auth.one_time_tokens"
 with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


ALTER TABLE auth.oauth_authorizations OWNER TO supabase_auth_admin;

--
-- TOC entry 288 (class 1259 OID 18402)
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE auth.oauth_client_states OWNER TO supabase_auth_admin;

--
-- TOC entry 4859 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- TOC entry 285 (class 1259 OID 18299)
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;

--
-- TOC entry 287 (class 1259 OID 18362)
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


ALTER TABLE auth.oauth_consents OWNER TO supabase_auth_admin;

--
-- TOC entry 284 (class 1259 OID 18267)
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_cpg_dump: creating TABLE "auth.refresh_tokens"
pg_dump: creating COMMENT "auth.TABLE refresh_tokens"
pg_dump: creating SEQUENCE "auth.refresh_tokens_id_seq"
pg_dump: creating SEQUENCE OWNED BY "auth.refresh_tokens_id_seq"
pg_dump: creating TABLE "auth.saml_providers"
pg_dump: creating COMMENT "auth.TABLE saml_providers"
pg_dump: creating TABLE "auth.saml_relay_states"
pg_dump: creating COMMENT "auth.TABLE saml_relay_states"
pg_dump: creating TABLE "auth.schema_migrations"
pg_dump: creating COMMENT "auth.TABLE schema_migrations"
pg_dump: creating TABLE "auth.sessions"
heck CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- TOC entry 237 (class 1259 OID 16470)
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- TOC entry 4864 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- TOC entry 236 (class 1259 OID 16469)
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- TOC entry 4866 (class 0 OID 0)
-- Dependencies: 236
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- TOC entry 281 (class 1259 OID 18146)
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- TOC entry 4868 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- TOC entry 282 (class 1259 OID 18164)
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- TOC entry 4870 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- TOC entry 240 (class 1259 OID 16496)
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- TOC entry 4872 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- TOC entry 275 (class 1259 OID 18041)
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with pg_dump: creating COMMENT "auth.TABLE sessions"
pg_dump: creating COMMENT "auth.COLUMN sessions.not_after"
pg_dump: creating COMMENT "auth.COLUMN sessions.refresh_token_hmac_key"
pg_dump: creating COMMENT "auth.COLUMN sessions.refresh_token_counter"
pg_dump: creating TABLE "auth.sso_domains"
pg_dump: creating COMMENT "auth.TABLE sso_domains"
pg_dump: creating TABLE "auth.sso_providers"
pg_dump: creating COMMENT "auth.TABLE sso_providers"
pg_dump: creating COMMENT "auth.COLUMN sso_providers.resource_id"
pg_dump: creating TABLE "auth.users"
time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- TOC entry 4874 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- TOC entry 4875 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- TOC entry 4876 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- TOC entry 4877 (class 0 OID 0)
-- Dependencies: 275
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- TOC entry 280 (class 1259 OID 18131)
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- TOC entry 4879 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- TOC entry 279 (class 1259 OID 18122)
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- TOC entry 4881 (class 0 OID 0)
-- Dependencies: 279
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- TOC entry 4882 (class 0 OID 0)
-- Dependencies: 279
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- TOC entry 235 (class 1259 OID 16458)
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(25pg_dump: creating COMMENT "auth.TABLE users"
pg_dump: creating COMMENT "auth.COLUMN users.is_sso_user"
pg_dump: creating TABLE "auth.webauthn_challenges"
pg_dump: creating TABLE "auth.webauthn_credentials"
pg_dump: creating TABLE "public.analytics_events"
pg_dump: creating TABLE "public.assessments"
5),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- TOC entry 4884 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- TOC entry 4885 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- TOC entry 291 (class 1259 OID 18477)
-- Name: webauthn_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);


ALTER TABLE auth.webauthn_challenges OWNER TO supabase_auth_admin;

--
-- TOC entry 290 (class 1259 OID 18454)
-- Name: webauthn_credentials; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);


ALTER TABLE auth.webauthn_credentials OWNER TO supabase_auth_admin;

--
-- TOC entry 309 (class 1259 OID 18862)
-- Name: analytics_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.analytics_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event_type text NOT NULL,
    scenario_id uuid,
    unit_id uuid,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.analytics_events OWNER TO postgres;

--
-- TOC entry 297 (class 1259 OID 18575)
-- Name: assessments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assessments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type text NOT NULL,
    training_id uuid,
    persona_target text,
 pg_dump: creating TABLE "public.certificates"
pg_dump: creating TABLE "public.feedback"
pg_dump: creating TABLE "public.module_quiz_attempts"
pg_dump: creating TABLE "public.modules"
pg_dump: creating TABLE "public.options"
pg_dump: creating TABLE "public.profiles"
   title text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT assessments_persona_target_check CHECK ((persona_target = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text]))),
    CONSTRAINT assessments_type_check CHECK ((type = ANY (ARRAY['baseline'::text, 'endline'::text, 'training'::text, 'module_quiz'::text])))
);


ALTER TABLE public.assessments OWNER TO postgres;

--
-- TOC entry 300 (class 1259 OID 18626)
-- Name: certificates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.certificates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    certificate_id text NOT NULL,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    persona text NOT NULL,
    last_issued_at timestamp with time zone
);


ALTER TABLE public.certificates OWNER TO postgres;

--
-- TOC entry 311 (class 1259 OID 18943)
-- Name: feedback; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feedback (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    module_id uuid,
    training_id uuid,
    context_page text NOT NULL,
    category text NOT NULL,
    rating integer NOT NULL,
    positive_feedback text,
    improvement_feedback text,
    persona text,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT feedback_category_check CHECK ((category = ANY (ARRAY['module'::text, 'platform'::text, 'bug'::text, 'other'::text]))),
    CONSTRAINT feedback_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.feedback OWNER TO postgres;

--
-- TOC entry 310 (class 1259 OID 18911)
-- Name: module_quiz_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.module_quiz_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    module_id uuid NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    best_score integer DEFAULT 0 NOT NULL,
    passed boolean DEFAULT false NOT NULL,
    attempt_count integer DEFAULT 0 NOT NULL,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.module_quiz_attempts OWNER TO postgres;

--
-- TOC entry 302 (class 1259 OID 18679)
-- Name: modules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    description text,
    desired_outcomes text,
    competencies text,
    is_mandatory boolean DEFAULT false NOT NULL,
    order_number integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.modules OWNER TO postgres;

--
-- TOC entry 299 (class 1259 OID 18610)
-- Name: options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.options (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    question_id uuid NOT NULL,
    option_text text NOT NULL,
    is_correct boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.options OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 18502)
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    phone text NOT NULL,
    full_name text,
    persona text,
    baseline_score double precision,
    baseline_completed boolean DEFAULT false NOT NULL,
    endline_score double precision,
    endline_completed boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    endline_attempt_count integer DEFAULT 0 NOT NULL,
    baseline_attempt_count integer DEFAULT 0 NOT NULL,
    qualifications jsonb DEFAULT '[]'::jsonb,
    experiences jsonb DEFAULT '[]'::jsonb,
    weak_modules text[] DEFAULT '{}'::text[] NOT NULL,
    school_id texpg_dump: creating TABLE "public.questions"
pg_dump: creating TABLE "public.regions"
pg_dump: creating TABLE "public.scenario_options"
pg_dump: creating TABLE "public.scenario_responses"
pg_dump: creating TABLE "public.scenarios"
pg_dump: creating TABLE "public.session_events"
pg_dump: creating TABLE "public.training_content"
t,
    region text,
    teacher_ids text[] DEFAULT '{}'::text[],
    CONSTRAINT profiles_persona_check CHECK ((persona = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text, 'E'::text])))
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- TOC entry 298 (class 1259 OID 18592)
-- Name: questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.questions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    assessment_id uuid NOT NULL,
    question_type text NOT NULL,
    question_text text NOT NULL,
    correct_answer text,
    max_score integer DEFAULT 1 NOT NULL,
    order_number integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT questions_question_type_check CHECK ((question_type = ANY (ARRAY['mcq'::text, 'open'::text])))
);


ALTER TABLE public.questions OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 18769)
-- Name: regions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.regions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    coordinates jsonb,
    parent_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.regions OWNER TO postgres;

--
-- TOC entry 307 (class 1259 OID 18824)
-- Name: scenario_options; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scenario_options (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    scenario_id uuid NOT NULL,
    option_letter character(1) NOT NULL,
    option_text text NOT NULL,
    is_correct boolean DEFAULT false NOT NULL,
    rationale text DEFAULT ''::text NOT NULL,
    principle_tag text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT scenario_options_option_letter_check CHECK ((option_letter = ANY (ARRAY['A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar])))
);


ALTER TABLE public.scenario_options OWNER TO postgres;

--
-- TOC entry 308 (class 1259 OID 18843)
-- Name: scenario_responses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scenario_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    scenario_id uuid NOT NULL,
    chosen_option character(1) NOT NULL,
    is_correct boolean NOT NULL,
    time_spent_seconds integer,
    attempt_number integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT scenario_responses_chosen_option_check CHECK ((chosen_option = ANY (ARRAY['A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar])))
);


ALTER TABLE public.scenario_responses OWNER TO postgres;

--
-- TOC entry 306 (class 1259 OID 18804)
-- Name: scenarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scenarios (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    unit_id uuid NOT NULL,
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
    CONSTRAINT scenarios_difficulty_check CHECK ((difficulty = ANY (ARRAY['easy'::text, 'medium'::text, 'hard'::text])))
);


ALTER TABLE public.scenarios OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 18713)
-- Name: session_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    event_type text NOT NULL,
    training_id uuid,
    properties jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.session_events OWNER TO postgres;

--
-- TOC entry 295 (class 1259 OID 18536)
-- Name: training_content; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.training_content (
    id uuid DEFAULT gen_random_uuid() NOTpg_dump: creating TABLE "public.training_progress"
pg_dump: creating TABLE "public.trainings"
pg_dump: creating TABLE "public.user_regions"
pg_dump: creating TABLE "public.user_roles"
pg_dump: creating TABLE "realtime.messages"
pg_dump: creating TABLE "realtime.messages_2026_06_06"
pg_dump: creating TABLE "realtime.messages_2026_06_07"
 NULL,
    training_id uuid NOT NULL,
    format_type text NOT NULL,
    content_url text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    scenario_data jsonb,
    CONSTRAINT training_content_format_type_check CHECK ((format_type = ANY (ARRAY['slide'::text, 'audio'::text, 'video'::text, 'slides'::text, 'scenario'::text, 'quiz'::text, 'module_quiz'::text])))
);


ALTER TABLE public.training_content OWNER TO postgres;

--
-- TOC entry 296 (class 1259 OID 18552)
-- Name: training_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.training_progress (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    training_id uuid NOT NULL,
    score double precision,
    passed boolean DEFAULT false NOT NULL,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    attempt_count integer DEFAULT 1 NOT NULL,
    tab_switch_count integer DEFAULT 0 NOT NULL,
    fullscreen_violations integer DEFAULT 0 NOT NULL,
    flagged_for_review boolean DEFAULT false NOT NULL,
    content_completed boolean DEFAULT false NOT NULL,
    content_completed_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.training_progress OWNER TO postgres;

--
-- TOC entry 294 (class 1259 OID 18524)
-- Name: trainings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trainings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    description text,
    persona_required text,
    order_number integer NOT NULL,
    is_common boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    module_id uuid,
    main_concepts text,
    max_attempts integer DEFAULT 3 NOT NULL,
    quiz_unlock_requires_content boolean DEFAULT true NOT NULL,
    CONSTRAINT trainings_persona_required_check CHECK ((persona_required = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text, 'E'::text])))
);


ALTER TABLE public.trainings OWNER TO postgres;

--
-- TOC entry 305 (class 1259 OID 18785)
-- Name: user_regions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_regions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    region_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_regions OWNER TO postgres;

--
-- TOC entry 301 (class 1259 OID 18655)
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    role public.app_role DEFAULT 'user'::public.app_role NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 17518)
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- TOC entry 312 (class 1259 OID 65925)
-- Name: messages_2026_06_06; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_06_06 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_06_06 OWNER TO supabase_admin;

--
-- TOC entry 313 (class 1259 OID 65937)
-- Name: messages_2026_06_07; Type: TABLE; Schema: realtime; Owner: supg_dump: creating TABLE "realtime.messages_2026_06_08"
pg_dump: creating TABLE "realtime.messages_2026_06_09"
pg_dump: creating TABLE "realtime.messages_2026_06_10"
pg_dump: creating TABLE "realtime.messages_2026_06_11"
pg_dump: creating TABLE "realtime.messages_2026_06_12"
pg_dump: creating TABLE "realtime.schema_migrations"
pg_dump: creating TABLE "realtime.subscription"
pabase_admin
--

CREATE TABLE realtime.messages_2026_06_07 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_06_07 OWNER TO supabase_admin;

--
-- TOC entry 314 (class 1259 OID 74081)
-- Name: messages_2026_06_08; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_06_08 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_06_08 OWNER TO supabase_admin;

--
-- TOC entry 315 (class 1259 OID 74093)
-- Name: messages_2026_06_09; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_06_09 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_06_09 OWNER TO supabase_admin;

--
-- TOC entry 316 (class 1259 OID 74105)
-- Name: messages_2026_06_10; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_06_10 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_06_10 OWNER TO supabase_admin;

--
-- TOC entry 317 (class 1259 OID 74117)
-- Name: messages_2026_06_11; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_06_11 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_06_11 OWNER TO supabase_admin;

--
-- TOC entry 318 (class 1259 OID 74129)
-- Name: messages_2026_06_12; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_06_12 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_06_12 OWNER TO supabase_admin;

--
-- TOC entry 257 (class 1259 OID 17076)
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- TOC entry 260 (class 1259 OID 17114)
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTpg_dump: creating SEQUENCE "realtime.subscription_id_seq"
pg_dump: creating TABLE "storage.buckets"
pg_dump: creating COMMENT "storage.COLUMN buckets.owner"
pg_dump: creating TABLE "storage.buckets_analytics"
pg_dump: creating TABLE "storage.buckets_vectors"
pg_dump: creating TABLE "storage.iceberg_namespaces"
pg_dump: creating TABLE "storage.iceberg_tables"
pg_dump: creating TABLE "storage.migrations"
pg_dump: creating TABLE "storage.objects"
ER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- TOC entry 259 (class 1259 OID 17113)
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 265 (class 1259 OID 17761)
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- TOC entry 4921 (class 0 OID 0)
-- Dependencies: 265
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- TOC entry 269 (class 1259 OID 17880)
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE storage.buckets_analytics OWNER TO supabase_storage_admin;

--
-- TOC entry 272 (class 1259 OID 17929)
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.buckets_vectors OWNER TO supabase_storage_admin;

--
-- TOC entry 270 (class 1259 OID 17891)
-- Name: iceberg_namespaces; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.iceberg_namespaces (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_name text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    catalog_id uuid NOT NULL
);


ALTER TABLE storage.iceberg_namespaces OWNER TO supabase_storage_admin;

--
-- TOC entry 271 (class 1259 OID 17907)
-- Name: iceberg_tables; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.iceberg_tables (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    namespace_id uuid NOT NULL,
    bucket_name text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    location text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    remote_table_id text,
    shard_key text,
    shard_id text,
    catalog_id uuid NOT NULL
);


ALTER TABLE storage.iceberg_tables OWNER TO supabase_storage_admin;

--
-- TOC entry 264 (class 1259 OID 17753)
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- TOC entry 266 (class 1259 OID 17771)
-- Name: objects; Type: TABLE;pg_dump: creating COMMENT "storage.COLUMN objects.owner"
pg_dump: creating TABLE "storage.s3_multipart_uploads"
pg_dump: creating TABLE "storage.s3_multipart_uploads_parts"
pg_dump: creating TABLE "storage.vector_indexes"
pg_dump: creating TABLE "supabase_functions.hooks"
pg_dump: creating COMMENT "supabase_functions.TABLE hooks"
pg_dump: creating SEQUENCE "supabase_functions.hooks_id_seq"
pg_dump: creating SEQUENCE OWNED BY "supabase_functions.hooks_id_seq"
pg_dump: creating TABLE "supabase_functions.migrations"
 Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- TOC entry 4927 (class 0 OID 0)
-- Dependencies: 266
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- TOC entry 267 (class 1259 OID 17820)
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb,
    metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- TOC entry 268 (class 1259 OID 17834)
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- TOC entry 273 (class 1259 OID 17939)
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.vector_indexes OWNER TO supabase_storage_admin;

--
-- TOC entry 253 (class 1259 OID 16721)
-- Name: hooks; Type: TABLE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE TABLE supabase_functions.hooks (
    id bigint NOT NULL,
    hook_table_id integer NOT NULL,
    hook_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    request_id bigint
);


ALTER TABLE supabase_functions.hooks OWNER TO supabase_functions_admin;

--
-- TOC entry 4932 (class 0 OID 0)
-- Dependencies: 253
-- Name: TABLE hooks; Type: COMMENT; Schema: supabase_functions; Owner: supabase_functions_admin
--

COMMENT ON TABLE supabase_functions.hooks IS 'Supabase Functions Hooks: Audit trail for triggered hooks.';


--
-- TOC entry 252 (class 1259 OID 16720)
-- Name: hooks_id_seq; Type: SEQUENCE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE SEQUENCE supabase_functions.hooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE supabase_functions.hooks_id_seq OWNER TO supabase_functions_admin;

--
-- TOC entry 4934 (class 0 OID 0)
-- Dependencies: 252
-- Name: hooks_id_seq; Type: SEQUENCE OWNED BY; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER SEQUENCE supabase_functions.hooks_id_seq OWNED BY supabase_functions.hooks.id;


--
-- TOC entry 251 (class 1259 OID 16712)
-- Name: migrations; Type: TABLE; Schema: supabasepg_dump: creating TABLE "supabase_migrations.schema_migrations"
pg_dump: creating TABLE ATTACH "realtime.messages_2026_06_06"
pg_dump: creating TABLE ATTACH "realtime.messages_2026_06_07"
pg_dump: creating TABLE ATTACH "realtime.messages_2026_06_08"
pg_dump: creating TABLE ATTACH "realtime.messages_2026_06_09"
pg_dump: creating TABLE ATTACH "realtime.messages_2026_06_10"
pg_dump: creating TABLE ATTACH "realtime.messages_2026_06_11"
pg_dump: creating TABLE ATTACH "realtime.messages_2026_06_12"
pg_dump: creating DEFAULT "auth.refresh_tokens id"
pg_dump: creating DEFAULT "supabase_functions.hooks id"
pg_dump: processing data for table "_realtime.extensions"
pg_dump: dumping contents of table "_realtime.extensions"
pg_dump: processing data for table "_realtime.schema_migrations"
_functions; Owner: supabase_functions_admin
--

CREATE TABLE supabase_functions.migrations (
    version text NOT NULL,
    inserted_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE supabase_functions.migrations OWNER TO supabase_functions_admin;

--
-- TOC entry 292 (class 1259 OID 18495)
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text
);


ALTER TABLE supabase_migrations.schema_migrations OWNER TO postgres;

--
-- TOC entry 3780 (class 0 OID 0)
-- Name: messages_2026_06_06; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_06_06 FOR VALUES FROM ('2026-06-06 00:00:00') TO ('2026-06-07 00:00:00');


--
-- TOC entry 3781 (class 0 OID 0)
-- Name: messages_2026_06_07; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_06_07 FOR VALUES FROM ('2026-06-07 00:00:00') TO ('2026-06-08 00:00:00');


--
-- TOC entry 3782 (class 0 OID 0)
-- Name: messages_2026_06_08; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_06_08 FOR VALUES FROM ('2026-06-08 00:00:00') TO ('2026-06-09 00:00:00');


--
-- TOC entry 3783 (class 0 OID 0)
-- Name: messages_2026_06_09; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_06_09 FOR VALUES FROM ('2026-06-09 00:00:00') TO ('2026-06-10 00:00:00');


--
-- TOC entry 3784 (class 0 OID 0)
-- Name: messages_2026_06_10; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_06_10 FOR VALUES FROM ('2026-06-10 00:00:00') TO ('2026-06-11 00:00:00');


--
-- TOC entry 3785 (class 0 OID 0)
-- Name: messages_2026_06_11; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_06_11 FOR VALUES FROM ('2026-06-11 00:00:00') TO ('2026-06-12 00:00:00');


--
-- TOC entry 3786 (class 0 OID 0)
-- Name: messages_2026_06_12; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_06_12 FOR VALUES FROM ('2026-06-12 00:00:00') TO ('2026-06-13 00:00:00');


--
-- TOC entry 3796 (class 2604 OID 16473)
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- TOC entry 3805 (class 2604 OID 16724)
-- Name: hooks id; Type: DEFAULT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.hooks ALTER COLUMN id SET DEFAULT nextval('supabase_functions.hooks_id_seq'::regclass);


--
-- TOC entry 4672 (class 0 OID 16756)
-- Dependencies: 256
-- Data for Name: extensions; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.extensions (id, type, settings, tenant_external_id, inserted_at, updated_at) FROM stdin;
18250f6b-e42f-4097-8542-b7d60c6ba5cc	postgres_cdc_rls	{"region": "us-east-1", "db_host": "GAs1cWZsK0zc2a9Vzf4r9wNHDKgx7szVClaNdcnuk01PNrrhma6I8nd28t/mto4/", "db_name": "sWBpZNdjggEPTQVlI52Zfw==", "db_port": "+enMDFi1J/3IrrquHHwUmA==", "db_user": "uxbEq/zz8DXVD53TOI1zmw==", "slot_name": "supabase_realtime_replication_slot", "db_password": "sWBpZNdjggEPTQVlI52Zfw==", "publication": "supabase_realtime", "ssl_enforced": false, "poll_interval_ms": 100, "poll_max_changes": 100, "poll_max_record_bytes": 1048576}	realtime-dev	2026-06-09 08:09:50	2026-06-09 08:09:50
\.


--
-- TOC entry 4670 (class 0 OID 16742)
-- Dependencies: 254
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.schema_mipg_dump: dumping contents of table "_realtime.schema_migrations"
pg_dump: processing data for table "_realtime.tenants"
pg_dump: dumping contents of table "_realtime.tenants"
pg_dump: processing data for table "auth.audit_log_entries"
pg_dump: dumping contents of table "auth.audit_log_entries"
pg_dump: processing data for table "auth.custom_oauth_providers"
pg_dump: dumping contents of table "auth.custom_oauth_providers"
pg_dump: processing data for table "auth.flow_state"
pg_dump: dumping contents of table "auth.flow_state"
pg_dump: processing data for table "auth.identities"
pg_dump: dumping contents of table "auth.identities"
pg_dump: processing data for table "auth.instances"
pg_dump: dumping contents of table "auth.instances"
grations (version, inserted_at) FROM stdin;
20210706140551	2026-04-28 15:44:03
20220329161857	2026-04-28 15:44:03
20220410212326	2026-04-28 15:44:03
20220506102948	2026-04-28 15:44:03
20220527210857	2026-04-28 15:44:03
20220815211129	2026-04-28 15:44:03
20220815215024	2026-04-28 15:44:03
20220818141501	2026-04-28 15:44:03
20221018173709	2026-04-28 15:44:03
20221102172703	2026-04-28 15:44:03
20221223010058	2026-04-28 15:44:03
20230110180046	2026-04-28 15:44:03
20230810220907	2026-04-28 15:44:03
20230810220924	2026-04-28 15:44:04
20231024094642	2026-04-28 15:44:04
20240306114423	2026-04-28 15:44:04
20240418082835	2026-04-28 15:44:04
20240625211759	2026-04-28 15:44:04
20240704172020	2026-04-28 15:44:04
20240902173232	2026-04-28 15:44:04
20241106103258	2026-04-28 15:44:04
20250424203323	2026-04-28 15:44:04
20250613072131	2026-04-28 15:44:04
20250711044927	2026-04-28 15:44:04
20250811121559	2026-04-28 15:44:04
20250926223044	2026-04-28 15:44:04
20251204170944	2026-04-28 15:44:04
20251218000543	2026-04-28 15:44:04
\.


--
-- TOC entry 4671 (class 0 OID 16747)
-- Dependencies: 255
-- Data for Name: tenants; Type: TABLE DATA; Schema: _realtime; Owner: supabase_admin
--

COPY _realtime.tenants (id, name, external_id, jwt_secret, max_concurrent_users, inserted_at, updated_at, max_events_per_second, postgres_cdc_default, max_bytes_per_second, max_channels_per_client, max_joins_per_second, suspend, jwt_jwks, notify_private_alpha, private_only, migrations_ran, broadcast_adapter, max_presence_events_per_second, max_payload_size_in_kb) FROM stdin;
c2c48cd8-3c41-4b9e-adf2-577f75885cd0	realtime-dev	realtime-dev	iNjicxc4+llvc9wovDvqymwfnj9teWMlyOIbJ8Fh6j2WNU8CIJ2ZgjR6MUIKqSmeDmvpsKLsZ9jgXJmQPpwL8w==	200	2026-06-09 08:09:50	2026-06-09 08:09:50	100	postgres_cdc_rls	100000	100	100	f	{"keys": [{"x": "M5Sjqn5zwC9Kl1zVfUUGvv9boQjCGd45G8sdopBExB4", "y": "P6IXMvA2WYXSHSOMTBH2jsw_9rrzGy89FjPf6oOsIxQ", "alg": "ES256", "crv": "P-256", "ext": true, "kid": "b81269f1-21d8-4f2e-b719-c2240a840d90", "kty": "EC", "use": "sig", "key_ops": ["verify"]}, {"k": "c3VwZXItc2VjcmV0LWp3dC10b2tlbi13aXRoLWF0LWxlYXN0LTMyLWNoYXJhY3RlcnMtbG9uZw", "kty": "oct"}]}	f	f	65	gen_rpc	1000	3000
\.


--
-- TOC entry 4665 (class 0 OID 16488)
-- Dependencies: 239
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- TOC entry 4701 (class 0 OID 18412)
-- Dependencies: 289
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.custom_oauth_providers (id, provider_type, identifier, name, client_id, client_secret, acceptable_client_ids, scopes, pkce_enabled, attribute_mapping, authorization_params, enabled, email_optional, issuer, discovery_url, skip_nonce_check, cached_discovery, discovery_cached_at, authorization_url, token_url, userinfo_url, jwks_uri, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4695 (class 0 OID 18217)
-- Dependencies: 283
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at, invite_token, referrer, oauth_client_state_id, linking_target_id, email_optional) FROM stdin;
\.


--
-- TOC entry 4686 (class 0 OID 18010)
-- Dependencies: 274
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
\.


--
-- TOC entry 4664 (class 0 OID 16481)
-- Dependencies: 238
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4690 (class 0 OID 18102)
-- Dependencies: 278
-- Data for Name: mfa_amr_claims; Type: TABLE Dpg_dump: processing data for table "auth.mfa_amr_claims"
pg_dump: dumping contents of table "auth.mfa_amr_claims"
pg_dump: processing data for table "auth.mfa_challenges"
pg_dump: dumping contents of table "auth.mfa_challenges"
pg_dump: processing data for table "auth.mfa_factors"
pg_dump: dumping contents of table "auth.mfa_factors"
pg_dump: processing data for table "auth.oauth_authorizations"
pg_dump: dumping contents of table "auth.oauth_authorizations"
pg_dump: processing data for table "auth.oauth_client_states"
pg_dump: dumping contents of table "auth.oauth_client_states"
pg_dump: processing data for table "auth.oauth_clients"
pg_dump: dumping contents of table "auth.oauth_clients"
pg_dump: processing data for table "auth.oauth_consents"
pg_dump: dumping contents of table "auth.oauth_consents"
pg_dump: processing data for table "auth.one_time_tokens"
pg_dump: dumping contents of table "auth.one_time_tokens"
pg_dump: processing data for table "auth.refresh_tokens"
pg_dump: dumping contents of table "auth.refresh_tokens"
pg_dump: processing data for table "auth.saml_providers"
pg_dump: dumping contents of table "auth.saml_providers"
pg_dump: processing data for table "auth.saml_relay_states"
pg_dump: dumping contents of table "auth.saml_relay_states"
pg_dump: processing data for table "auth.schema_migrations"
pg_dump: dumping contents of table "auth.schema_migrations"
ATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- TOC entry 4689 (class 0 OID 18090)
-- Dependencies: 277
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- TOC entry 4688 (class 0 OID 18077)
-- Dependencies: 276
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- TOC entry 4698 (class 0 OID 18329)
-- Dependencies: 286
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- TOC entry 4700 (class 0 OID 18402)
-- Dependencies: 288
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- TOC entry 4697 (class 0 OID 18299)
-- Dependencies: 285
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type, token_endpoint_auth_method) FROM stdin;
\.


--
-- TOC entry 4699 (class 0 OID 18362)
-- Dependencies: 287
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- TOC entry 4696 (class 0 OID 18267)
-- Dependencies: 284
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4663 (class 0 OID 16470)
-- Dependencies: 237
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- TOC entry 4693 (class 0 OID 18146)
-- Dependencies: 281
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- TOC entry 4694 (class 0 OID 18164)
-- Dependencies: 282
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- TOC entry 4666 (class 0 OID 16496)
-- Dependencies: 240
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900pg_dump: processing data for table "auth.sessions"
pg_dump: dumping contents of table "auth.sessions"
pg_dump: processing data for table "auth.sso_domains"
pg_dump: dumping contents of table "auth.sso_domains"
pg_dump: processing data for table "auth.sso_providers"
pg_dump: dumping contents of table "auth.sso_providers"
pg_dump: processing data for table "auth.users"
pg_dump: dumping contents of table "auth.users"
pg_dump: processing data for table "auth.webauthn_challenges"
pg_dump: dumping contents of table "auth.webauthn_challenges"
pg_dump: processing data for table "auth.webauthn_credentials"
pg_dump: dumping contents of table "auth.webauthn_credentials"
pg_dump: processing data for table "public.analytics_events"
pg_dump: dumping contents of table "public.analytics_events"
pg_dump: processing data for table "public.assessments"
pg_dump: dumping contents of table "public.assessments"

20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
20260115000000
20260121000000
20260219120000
20260302000000
\.


--
-- TOC entry 4687 (class 0 OID 18041)
-- Dependencies: 275
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
\.


--
-- TOC entry 4692 (class 0 OID 18131)
-- Dependencies: 280
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4691 (class 0 OID 18122)
-- Dependencies: 279
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- TOC entry 4661 (class 0 OID 16458)
-- Dependencies: 235
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
\.


--
-- TOC entry 4703 (class 0 OID 18477)
-- Dependencies: 291
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.webauthn_challenges (id, user_id, challenge_type, session_data, created_at, expires_at) FROM stdin;
\.


--
-- TOC entry 4702 (class 0 OID 18454)
-- Dependencies: 290
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.webauthn_credentials (id, user_id, credential_id, public_key, attestation_type, aaguid, sign_count, transports, backup_eligible, backed_up, friendly_name, created_at, updated_at, last_used_at) FROM stdin;
\.


--
-- TOC entry 4721 (class 0 OID 18862)
-- Dependencies: 309
-- Data for Name: analytics_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.analytics_events (id, user_id, event_type, scenario_id, unit_id, metadata, created_at) FROM stdin;
\.


--
-- TOC entry 4709 (class 0 OID 18575)
-- Dependencies: 297
-- Data for Name: assessments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assessments (id, type, training_id, persona_target, title, created_at) FROM stdin;
798432b6-2c91-4241-b1bc-0d9115f669f6	module_quiz	98853170-fd6f-4522-a1f9-fe28fc398007	\N	Unit 1.0: The Impact Cycle Overview — Quiz	2026-04-28 15:44:23.341859+00
cd234fc0-6c77-4c28-9c80-fbf04f5b24fb	module_quiz	78a2a962-0a1a-41cf-a739-b3ed7df778c1	\N	Unit 1.1: Observation & Data Collection — Quiz	2026-04-28 15:44:23.341859+00
5b278098-2ca9-49d7-b510-9d950f7836b2	module_quiz	98fb67f3-5319-4d11-b928-195aabbdbb58	\N	Unit 1.2: The Calibration Process — Quiz	2026-04-28 15:44:23.341859+00
55d5aa23-ef65-4e34-9de1-02b3234f1a27	module_quiz	7d27936d-1e24-43c3-950d-cfeaa0879f82	\N	Unit 1.3: Feedback with Empathy — Quiz	2026-04-28 15:44:23.341859+00
de27baac-d750-46c8-88e9-302c32461cef	module_quiz	16bcf206-446e-4aea-beb0-7e43c1372cc5pg_dump: processing data for table "public.certificates"
pg_dump: dumping contents of table "public.certificates"
pg_dump: processing data for table "public.feedback"
pg_dump: dumping contents of table "public.feedback"
pg_dump: processing data for table "public.module_quiz_attempts"
pg_dump: dumping contents of table "public.module_quiz_attempts"
pg_dump: processing data for table "public.modules"
pg_dump: dumping contents of table "public.modules"
	\N	Unit 1.4: Co-Designing Action Steps — Quiz	2026-04-28 15:44:23.341859+00
16a18d49-c575-4621-9ebd-2e92dc041bd6	module_quiz	110975b9-7079-4e30-800c-45a49c48d352	\N	Unit 1.5: Documentation & Follow-up — Quiz	2026-04-28 15:44:23.341859+00
2903a716-32d8-4278-93e4-700888f2851b	module_quiz	765d76d0-5ea6-491f-90ff-684315f463d5	\N	Unit 1.6: Building Habits & Mastery — Quiz	2026-04-28 15:44:23.341859+00
bde3f9b7-dc97-4619-8daf-e305fe9679b2	baseline	f47ac10b-58cc-4372-a567-0e02b2c3d479	\N	Coach Baseline Assessment	2026-04-28 15:44:23.278594+00
\.


--
-- TOC entry 4712 (class 0 OID 18626)
-- Dependencies: 300
-- Data for Name: certificates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.certificates (id, user_id, certificate_id, issued_at, persona, last_issued_at) FROM stdin;
\.


--
-- TOC entry 4723 (class 0 OID 18943)
-- Dependencies: 311
-- Data for Name: feedback; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.feedback (id, user_id, module_id, training_id, context_page, category, rating, positive_feedback, improvement_feedback, persona, user_agent, created_at) FROM stdin;
\.


--
-- TOC entry 4722 (class 0 OID 18911)
-- Dependencies: 310
-- Data for Name: module_quiz_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.module_quiz_attempts (id, user_id, module_id, score, best_score, passed, attempt_count, completed_at, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4714 (class 0 OID 18679)
-- Dependencies: 302
-- Data for Name: modules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modules (id, title, description, desired_outcomes, competencies, is_mandatory, order_number, created_at, updated_at) FROM stdin;
f6c3ce01-e48f-4ef1-8a74-07f1f3b59ebc	Module 1: The Impact Cycle Foundation	Master the fundamentals of the coaching cycle: observation, data collection, feedback, and action planning to drive teacher growth and student impact.	Coaches will understand the complete coaching cycle and how each phase contributes to sustainable teacher development.	Observation, Data Collection, Feedback, Action Planning	t	1	2026-04-28 15:44:23.271143+00	2026-04-28 15:44:23.271143+00
be3aad3f-23b2-497e-b826-7c6b24e4746b	Module 2: The Partnership Foundation	Build trust and psychological safety in coaching relationships. Learn status threat dynamics, deep empathy, and co-created SMART goals.	Coaches establish partnership through equality, choice, and voice. Teachers own their growth goals.	Trust & Status	f	2	2026-04-28 15:44:23.298717+00	2026-04-28 15:44:23.298717+00
0c3e6d7b-dad6-4edd-ae55-b4aa92269334	Module 3: The Mirror Specialist	Master low-inference observation and calibration. Learn artifact validation through photos/audio and neutral data presentation.	Coaches present objective data as mirrors. Teachers develop their own interpretations and solutions.	Shared Reality	f	3	2026-04-28 15:44:23.298717+00	2026-04-28 15:44:23.298717+00
b7c08062-b84a-4cf8-a569-7ef759c3941c	Module 4: Digital & Data Intelligence	Leverage digital tools and dashboards as coaching accelerators. Understand WRER tracking and data-as-third-person principle.	Coaches integrate digital evidence into feedback. Teachers become data-literate about their practice.	WRER & Data	f	4	2026-04-28 15:44:23.298717+00	2026-04-28 15:44:23.298717+00
e882c172-d679-4561-8f69-2055a636a960	Module 5: The Instructional Catalyst	Master micro-skill isolation, pedagogical root-cause analysis, and side-by-side co-modeling. Apply the 3 Loops framework.	Coaches facilitate teacher-owned instructional problem-solving. Teachers apply micro-skills to real classroom contexts.	Co-Design	f	5	2026-04-28 15:44:23.298717+00	2026-04-28 15:44:23.298717+00
0e040163-1402-417f-8001-fdc40e1a73e1	Module 6: The Excellence Loop	Complete the coaching cycle through loop closure, SOP adherence, and reciprocity. Build mastery via the Mastery Technique bank.	Coaches verify implementation and celebrate teacher ownership. Teachers build sustainable instructional habits.	Reciprocity & Praxis	f	6	2026-04-28 15:44:23.298717+00	2026pg_dump: processing data for table "public.options"
pg_dump: dumping contents of table "public.options"
-04-28 15:44:23.298717+00
\.


--
-- TOC entry 4711 (class 0 OID 18610)
-- Dependencies: 299
-- Data for Name: options; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.options (id, question_id, option_text, is_correct, created_at) FROM stdin;
6cece613-5be1-45a3-ace1-ee6122530868	f9be4327-7d25-449f-acdc-6a6c3a4d28e7	75%	t	2026-04-28 15:44:23.328455+00
d7008f84-df86-4bbd-aff0-6c5061925f3b	4fda6529-8022-4149-b839-70d6de0d355f	Certainty	f	2026-04-28 15:44:23.328455+00
6eb2367c-803b-4c91-b336-c2f953765863	4fda6529-8022-4149-b839-70d6de0d355f	Status	t	2026-04-28 15:44:23.328455+00
7446fefe-5bc6-4f33-b157-84c213d4d91c	4fda6529-8022-4149-b839-70d6de0d355f	Autonomy	f	2026-04-28 15:44:23.328455+00
31d9d22b-c98f-4c8a-bc41-80f191453862	4fda6529-8022-4149-b839-70d6de0d355f	Relatedness	f	2026-04-28 15:44:23.328455+00
e60f1a9e-2164-4a57-9b49-a4a9adfcc72d	b32516e0-c810-46c9-bd45-388a39556a1f	Triggered a Status Threat by using evaluative language rather than low-inference data.	t	2026-04-28 15:44:23.328455+00
7504b048-5069-4399-b8ae-05f6abbccf59	b32516e0-c810-46c9-bd45-388a39556a1f	Failed to provide enough expert advice regarding the specific pedagogical strategies.	f	2026-04-28 15:44:23.328455+00
1d395f25-a8f6-4e23-8411-9603f5540f8d	b32516e0-c810-46c9-bd45-388a39556a1f	Spent too much time listening to the teacher's concerns instead of taking notes.	f	2026-04-28 15:44:23.328455+00
93d8b75b-26c0-4851-af8b-13564cda7a62	b32516e0-c810-46c9-bd45-388a39556a1f	Not followed the NEO-1 checklist strictly enough to ensure a professional visit.	f	2026-04-28 15:44:23.328455+00
53f2a4f9-5dd0-4c45-bbd5-bccee87ed87d	08a5b4f5-7d61-4419-81cc-6d891bd319ab	Share the scores but ask the Principal to keep the individual names confidential.	f	2026-04-28 15:44:23.328455+00
61721a10-33b6-4594-b3bb-cf5eeceed68e	08a5b4f5-7d61-4419-81cc-6d891bd319ab	Provide a list of only the "top-performing" teachers to maintain school morale.	f	2026-04-28 15:44:23.328455+00
d0766805-5b2c-4c51-9bc2-813cc00d4bf2	08a5b4f5-7d61-4419-81cc-6d891bd319ab	Refuse and offer a "System-Trends" report to protect individual teacher trust.	t	2026-04-28 15:44:23.328455+00
fd6f6c5b-213b-4448-aa04-7db3103bfd42	08a5b4f5-7d61-4419-81cc-6d891bd319ab	Tell the Principal you will ask the teachers for their written permission first.	f	2026-04-28 15:44:23.328455+00
b5347738-16f6-42a4-bdf8-caaf98a76014	5144e503-5851-461d-90e1-60e839962c2f	I'm here to help you improve your classroom management with some expert tips.	f	2026-04-28 15:44:23.328455+00
a928259d-b83f-4b5b-aa03-0420830c6f20	5144e503-5851-461d-90e1-60e839962c2f	I'm here as a partner to learn alongside you; what is a specific goal you have?	t	2026-04-28 15:44:23.328455+00
27e8ff25-c9d3-4e99-8d24-2041d85ecc4c	5144e503-5851-461d-90e1-60e839962c2f	The District Office requires me to audit this lesson for performance tracking.	f	2026-04-28 15:44:23.328455+00
ca808b3e-2b89-4f31-94b7-7c81a0ac8de5	5144e503-5851-461d-90e1-60e839962c2f	I will be watching to see if you are following the standard manual correctly.	f	2026-04-28 15:44:23.328455+00
3878b937-e17c-4a2e-b363-b224d53759aa	afb32ad6-eded-478b-94e4-c6010a81e9c2	Re-read the rubric to show them exactly where their performance failed to meet goals.	f	2026-04-28 15:44:23.328455+00
03d6d1d5-1829-4271-9f6d-dfe201296acf	afb32ad6-eded-478b-94e4-c6010a81e9c2	Remind them that your role is to give expert advice they must follow for the program.	f	2026-04-28 15:44:23.328455+00
075ebd3c-5073-4a7b-8b69-b7f903b87e68	afb32ad6-eded-478b-94e4-c6010a81e9c2	Physically sit next to them and look at student work together, asking "What do you see?"	t	2026-04-28 15:44:23.328455+00
4abb8487-b7f2-4afa-8cfe-1b586d180f79	afb32ad6-eded-478b-94e4-c6010a81e9c2	Suggest they observe a younger teacher who has mastered the new digital tools.	f	2026-04-28 15:44:23.328455+00
ed0288a0-a066-452b-9f31-f3a6853def4d	4839ebe4-1df0-464d-a8b1-2bc4dde464c0	It sounds frustrating when you've planned a lesson and the back row isn't engaging.	t	2026-04-28 15:44:23.328455+00
6a0009b3-dcbb-42d0-b6f6-8e21c17f1e89	4839ebe4-1df0-464d-a8b1-2bc4dde464c0	You should use a whistle or a louder clap to get their attention more quickly.	f	2026-04-28 15:44:23.328455+00
708dcd61-4ca3-43ac-9af5-a1efaa764ab7	4839ebe4-1df0-464d-a8b1-2bc4dde464c0	In my day, I handled 80 students by doing specific management techniques.	f	2026-04-28 15:44:23.328455+00
cddfd251-faf2-400f-b928-fe7a9db462d4	4839ebe4-1df0-464d-a8b1-2bc4dde464c0	I will mark this as a practice visit so it doesn't hurt your official record.	f	2026-04-28 15:44:23.328455+00
214b5010-97d5-45ae-96f9-109cab5f809a	b7055dca-aa91-4bd0-bf30-87bbac5d256f	To catch the teacher ignoring students who are sitting far away from the podium.	f	2026-04-28 15:44:23.328455+00
de04f0a3-dd39-46e2-bfa6-58c98e71a2be	b7055dca-aa91-4bd0-bf30-87bbac5d256f	To find the truth of student learning often hidden by activity at the "Center."	t	2026-04-28 15:44:23.328455+00
6b03e183-fca3-4000-90ff-a35adb798bfb	b7055dca-aa91-4bd0-bf30-87bbac5d256f	To provide documented evidence for administrative "Show Cause" or warning notices.	f	2026-04-28 15:44:23.328455+00
f62fe18e-0a58-4679-b704-d36fc768f222	b7055dca-aa91-4bd0-bf30-87bbac5d256f	To satisfy the digital application requirements for capturing multiple artifacts.	f	2026-04-28 15:44:23.328455+00
fa1deaf3-5993-4020-948b-5a9ba277322c	2e194357-4995-4674-9cb7-eee7c97f0139	One person is a "mean" grader while the other is trying to be "supportive."	f	2026-04-28 15:44:23.328455+00
18037aa1-d9af-4813-8312-c5c4b502367d	2e194357-4995-4674-9cb7-eee7c97f0139	The rubric is too complex for the teacher to understand without prior training.	f	2026-04-28 15:44:23.328455+00
78a8cd7a-e84e-4000-9b49-730f0df54fe4	2e194357-4995-4674-9cb7-eee7c97f0139	Using subjective "feelings" instead of a shared mirror of objective classroom facts.	t	2026-04-28 15:44:23.328455+00
99de7de7-166e-422a-9a48-f1cd5e32c60f	2e194357-4995-4674-9cb7-eee7c97f0139	The teacher acts differently toward the coach than they do toward the students.	f	2026-04-28 15:44:23.328455+00
c8d6224b-4163-4fbf-bcaf-fe67978d8cc5	99658b03-cb6e-42aa-8692-d3992acb1753	The lighting in the room is poor, and the photo will not be clear for the dashboard.	f	2026-04-28 15:44:23.328455+00
39c96820-fa86-4ee2-bcc7-7e09ad125902	99658b03-cb6e-42aa-8692-d3992acb1753	A student is visibly distressed, or the teacher is in an acute emotional crisis.	t	2026-04-28 15:44:23.328455+00
9757174e-f6f1-4a94-8b82-8a6b3b135332	99658b03-cb6e-42aa-8692-d3992acb1753	The coach forgot their tablet and has to rely on memory for the digital entry.	f	2026-04-28 15:44:23.328455+00
44765476-a986-4279-8da8-0290967e02bd	99658b03-cb6e-42aa-8692-d3992acb1753	The teacher is using a non-standard strategy that is not mentioned in the manual.	f	2026-04-28 15:44:23.328455+00
a66fc516-2b2d-41d8-a915-e57f283f83c6	2db23441-5715-4986-98bb-9f3bf98adac8	The teacher was too lazy to check the homework assigned during the previous day.	f	2026-04-28 15:44:23.328455+00
6c27e796-8d78-490e-af9b-3088573d106f	2db23441-5715-4986-98bb-9f3bf98adac8	The teacher gave a very clear and concise explanation of the complex science topic.	f	2026-04-28 15:44:23.328455+00
a9a9cdc1-741b-46a6-b140-6c105e46d177	2db23441-5715-4986-98bb-9f3bf98adac8	At 11:15 AM, 12 of 68 students were writing; 56 students sat with blank pages.	t	2026-04-28 15:44:23.328455+00
5b30797b-d1da-4361-80f3-9fc7a2151503	2db23441-5715-4986-98bb-9f3bf98adac8	The classroom was noisy because the teacher lost control of the student behavior.	f	2026-04-28 15:44:23.328455+00
7ed41661-8686-4edf-a10d-a0bc45c29af0	d4f48b2c-4199-4d4e-a57e-11e7dbc8982f	Argue the data points until the teacher admits their assessment of the class was wrong.	f	2026-04-28 15:44:23.328455+00
ef85eedc-fb7e-400d-9e39-d7766b5501f6	d4f48b2c-4199-4d4e-a57e-11e7dbc8982f	Introduce the "Third Partner" by looking at 5 randomly selected student notebooks.	t	2026-04-28 15:44:23.328455+00
5353affc-ad99-4b71-b614-e91ae76879d5	d4f48b2c-4199-4d4e-a57e-11e7dbc8982f	Agree with them to maintain the relationship and try to address the issue next week.	f	2026-04-28 15:44:23.328455+00
c8828e38-351e-4778-9c2c-8397c299b9b3	d4f48b2c-4199-4d4e-a57e-11e7dbc8982f	Inform the Principal immediately that the teacher is in denial about student progress.	f	2026-04-28 15:44:23.328455+00
ba79056b-724b-42a1-8821-367e189309b3	74c213bd-ba47-49b7-9521-427fa4795017	Take it silently to avoid distracting the class or interrupting the teacher's flow.	f	2026-04-28 15:44:23.328455+00
4a7f30ba-1c46-4dd4-bcae-1639947cadfb	74c213bd-ba47-49b7-9521-427fa4795017	Only take photos of top-performing students to show the potential of the strategy.	f	2026-04-28 15:44:23.328455+00
17924497-b047-41da-a0ce-a520b272501b	74c213bd-ba47-49b7-9521-427fa4795017	Use a permission script that names a specific learning curiosity you want to explore.	t	2026-04-28 15:44:23.328455+00
b6df6e8e-1742-4b81-abd4-56ebf13e332a	74c213bd-ba47-49b7-9521-427fa4795017	Send the photo to the Principal immediately for validation and official record keeping.	f	2026-04-28 15:44:23.328455+00
69f5a164-57e5-4c59-b355-e9dc42da07a4	f9be4327-7d25-449f-acdc-6a6c3a4d28e7	66%	f	2026-04-28 15:44:23.328455+00
6edbe8ac-a090-4fca-a418-5773b6c3da35	f9be4327-7d25-449f-acdc-6a6c3a4d28e7	50%	f	2026-04-28 15:44:23.328455+00
254b8db5-ed1b-417f-bbfe-aa7097d30436	f9be4327-7d25-449f-acdc-6a6c3a4d28e7	40%	f	2026-04-28 15:44:23.328455+00
73e89bce-0568-41e2-beff-9755e1b4fdd3	1347beea-e3ec-4f02-9d51-be3c45fe086b	Teachers are following the steps (Compliance) but without deep pedagogical dialogue.	t	2026-04-28 15:44:23.328455+00
4a0d9148-282a-4c00-b3a6-cab529b53d55	1347beea-e3ec-4f02-9d51-be3c45fe086b	The digital application is not being used frequently enough by the coaching staff.	f	2026-04-28 15:44:23.328455+00
2e64a291-3466-4145-b04e-844775f7c0b9	1347beea-e3ec-4f02-9d51-be3c45fe086b	Students are not participating because the strategy is too difficult for their level.	f	2026-04-28 15:44:23.328455+00
eb4e9c70-c0ad-4ed2-b4d2-2cd54debbd6a	1347beea-e3ec-4f02-9d51-be3c45fe086b	The coach is not visiting the assigned schools enough to make a lasting difference.	f	2026-04-28 15:44:23.328455+00
1ee8fbaf-d0f9-4d63-b5b0-462ba3cd3c9c	0d20b13e-3d3b-483e-a581-49e6e554b654	Take paper notes and enter them into the system at home during the evening hours.	f	2026-04-28 15:44:23.328455+00
07daff1e-9fcb-4e19-9aa3-fdc3fb3642f3	0d20b13e-3d3b-483e-a581-49e6e554b654	Complete 100% of app entries (Evidence and Action Steps) inside the school building.	t	2026-04-28 15:44:23.328455+00
b38e5215-cd5a-4555-9e74-9a4c70a8367e	0d20b13e-3d3b-483e-a581-49e6e554b654	Ask the teacher to enter the data themselves to ensure they agree with the findings.	f	2026-04-28 15:44:23.328455+00
8bac3ce7-c537-4ecf-87c9-1795f962147d	0d20b13e-3d3b-483e-a581-49e6e554b654	Only record successful visits to ensure the regional dashboard remains positive.	f	2026-04-28 15:44:23.328455+00
d40bb17d-8e2e-463b-8bf5-a4f8bbb3a0e2	e40f8da7-18e8-4214-8a82-41158566c5a3	I'm sorry, but I have too much administrative work to complete for the district today.	f	2026-04-28 15:44:23.328455+00
8472c9bb-0b7e-4027-88b9-42874843c51c	e40f8da7-18e8-4214-8a82-41158566c5a3	I will do the duty if you promise to give me extra time to visit teachers tomorrow.	f	2026-04-28 15:44:23.328455+00
452b74c8-e0ce-4b12-bdd0-b05ff5f1c99c	e40f8da7-18e8-4214-8a82-41158566c5a3	My WRER is at 50%; if I miss this, Teacher Sara waits 7 days, risking kids.	t	2026-04-28 15:44:23.328455+00
683ed4a0-5446-4a60-b6cf-fe53c7ebb40d	e40f8da7-18e8-4214-8a82-41158566c5a3	The District Office says I am not allowed to perform any non-coaching duties today.	f	2026-04-28 15:44:23.328455+00
8a0bc697-acd3-4417-b585-be0f8ceb8300	1d138086-1f50-4e5c-bf91-37f821c63d02	Tell the teacher to follow the AI suggestion anyway to maintain program fidelity.	f	2026-04-28 15:44:23.328455+00
402b4328-2b81-4a52-8b1d-c1bbc631623e	1d138086-1f50-4e5c-bf91-37f821c63d02	Co-design a low-tech alternative (e.g., "Turn-and-Talk") that achieves the same intent.	t	2026-04-28 15:44:23.328455+00
379bb830-6c1a-4090-8dc3-f670fa83641b	1d138086-1f50-4e5c-bf91-37f821c63d02	Mark the visit as "Not Applicable" and move to the next teacher on your list.	f	2026-04-28 15:44:23.328455+00
ccbf6261-c480-40a5-a9df-5f677dc7e9b5	1d138086-1f50-4e5c-bf91-37f821c63d02	Report the lack of resources and skip the coaching step until electricity is restored.	f	2026-04-28 15:44:23.328455+00
bd617e89-b049-4234-9910-33e0f1f78f12	16bdc8d4-4907-4158-9c47-5a6f164f6a20	Ignore the observation and celebrate the 100% score to maintain a positive relationship.	f	2026-04-28 15:44:23.328455+00
b746244c-7706-4ce1-83bf-9a20f5aa811f	16bdc8d4-4907-4158-9c47-5a6f164f6a20	Use the "Shared Mirror" to ask: "Data shows 100% completion, but what do we notice?"	t	2026-04-28 15:44:23.328455+00
321fc960-da1d-4409-97c1-22551aa16093	16bdc8d4-4907-4158-9c47-5a6f164f6a20	Change the dashboard score manually to 0% to reflect the lack of real learning.	f	2026-04-28 15:44:23.328455+00
d94baf77-0bf7-46d2-8909-7537a342a343	16bdc8d4-4907-4158-9c47-5a6f164f6a20	Report the teacher for "Robotic Teaching" and request a formal review of their methods.	f	2026-04-28 15:44:23.328455+00
a8ae44bf-3587-4886-905b-910dec0dcc27	be00acd1-d4ae-4230-bcef-2ba922874a69	Planning Loop failure regarding the preparation of the lesson materials and timing.	f	2026-04-28 15:44:23.328455+00
69d91b7e-6c09-4c66-956f-0e450af8ccdc	be00acd1-d4ae-4230-bcef-2ba922874a69	Observation Loop failure where the coach failed to see the teacher's actual intent.	f	2026-04-28 15:44:23.328455+00
41ff1295-2967-47ee-995c-2d52a69c5420	be00acd1-d4ae-4230-bcef-2ba922874a69	Training Loop failure (Needs rehearsal to build muscle memory for the teacher).	t	2026-04-28 15:44:23.328455+00
21fe3fde-8932-451a-a13b-cdaeccc98b0c	be00acd1-d4ae-4230-bcef-2ba922874a69	Mindset failure where the teacher does not believe the students are capable of it.	f	2026-04-28 15:44:23.328455+00
db739421-b5ae-4a0b-9ed9-6723953bcde7	e6d0fc8c-3b19-4864-b4c8-f79c856f9909	Show the teacher they are the expert by teaching the most difficult part of the class.	f	2026-04-28 15:44:23.328455+00
903e6137-3f9a-4693-873b-cac71eedf0c4	e6d0fc8c-3b19-4864-b4c8-f79c856f9909	Act as a "Co-Pilot" by "sliding in" for 2 minutes to model a specific micro-skill.	t	2026-04-28 15:44:23.328455+00
10cacdc0-2faf-4819-badd-dec0ad4cc2e1	e6d0fc8c-3b19-4864-b4c8-f79c856f9909	Finish the entire lesson for the teacher so the students stay focused on the task.	f	2026-04-28 15:44:23.328455+00
56da5e87-7255-4de9-8d6f-e02d29d8b81c	e6d0fc8c-3b19-4864-b4c8-f79c856f9909	Evaluate student behavior and report back to the teacher at the end of the period.	f	2026-04-28 15:44:23.328455+00
d30c3ed5-d5c7-474b-b5d0-a09520aa39a1	9b13f78b-5b19-4b15-924d-b2d25c4dc423	Modify the strategy	f	2026-04-28 15:44:23.328455+00
19948331-9552-4cd9-b511-7de9073298a8	9b13f78b-5b19-4b15-924d-b2d25c4dc423	Switch to a new strategy	f	2026-04-28 15:44:23.328455+00
1af4ea99-3d10-4c3d-ba8b-8a1524640df2	9b13f78b-5b19-4b15-924d-b2d25c4dc423	Stay the course	f	2026-04-28 15:44:23.328455+00
33154e23-b93d-41ef-8962-2b73ad1b562f	9b13f78b-5b19-4b15-924d-b2d25c4dc423	Report failure to administration	t	2026-04-28 15:44:23.328455+00
576e50bd-abcb-43c2-b994-596fe44a11df	87134515-2529-466c-b9c3-65f9d173b098	The teacher doesn't know the subject matter well enough to explain it to students.	f	2026-04-28 15:44:23.328455+00
a09db0ce-5e59-4090-831e-b3e266a57512	87134515-2529-466c-b9c3-65f9d173b098	The "Silence Myth": believing a quiet class copying text is a learning class.	t	2026-04-28 15:44:23.328455+00
a2a74f2e-a061-4dec-bb14-6e73626b9a05	87134515-2529-466c-b9c3-65f9d173b098	The teacher is lazy and doesn't want to spend time preparing an interactive lesson.	f	2026-04-28 15:44:23.328455+00
bbaa42c4-1e61-40d1-8d8e-4ff90ceeab92	87134515-2529-466c-b9c3-65f9d173b098	The students are too slow to do any other activity without direct copying of text.	f	2026-04-28 15:44:23.328455+00
0831a249-81db-48ea-a024-960bd813bc20	b4041c70-719d-401f-9ef2-55d4de79f839	Tell them to be faster next time and use a stopwatch to monitor their progress.	f	2026-04-28 15:44:23.328455+00
43ee4e7c-918d-4366-8cc7-c2515ac8537d	b4041c70-719d-401f-9ef2-55d4de79f839	Co-design a script with specific time-stamps for each individual lesson segment.	t	2026-04-28 15:44:23.328455+00
816e034f-7056-44ba-95dc-5e01c6ecf02b	b4041c70-719d-401f-9ef2-55d4de79f839	Model the entire lesson for them to show how the timing should properly work.	f	2026-04-28 15:44:23.328455+00
d82b4d27-2c5a-4e27-aa6d-b39fedecaca3	b4041c70-719d-401f-9ef2-55d4de79f839	Mark them as "Not Proficient" in time management in the final coaching report.	f	2026-04-28 15:44:23.328455+00
b40c9bdf-bc44-45d8-9d42-e8c3369d7436	810ba0e8-ed4c-409d-bddc-825172a36892	The easiest gap to fix to build momentum and teacher confidence quickly.	f	2026-04-28 15:44:23.328455+00
ab5578d3-2c32-4329-8533-d1c0d0ab8e81	810ba0e8-ed4c-409d-bddc-825172a36892	The "High-Leverage" change that the teacher agrees will impact students most.	t	2026-04-28 15:44:23.328455+00
faf7073c-8169-49b7-9cd5-f623991f8781	810ba0e8-ed4c-409d-bddc-825172a36892	The gap the Principal is most concerned about based on their recent observations.	f	2026-04-28 15:44:23.328455+00
b55acd5b-7d09-4fc4-ad00-632d658b55c4	810ba0e8-ed4c-409d-bddc-825172a36892	All 8 gaps simultaneously to ensure rapid growth across all teaching domains.	f	2026-04-28 15:44:23.328455+00
6d114c7d-d281-4f66-a80a-44faa89834cd	10eed7eb-a435-47c9-8e0c-840718b62854	The teacher is unwilling to follow the manual despite having the resources to do so.	f	2026-04-28 15:44:23.328455+00
6a897060-4441-4452-b7d4-aaf81f0651b3	10eed7eb-a435-47c9-8e0c-840718b62854	A strategy is impossible due to local constraints like 60 students and bolted desks.	t	2026-04-28 15:44:23.328455+00
86c59576-070b-432f-a753-365e8628dfda	10eed7eb-a435-47c9-8e0c-840718b62854	The coach wants to try a new pedagogical experiment to see if the students like it.	f	2026-04-28 15:44:23.328455+00
d94e8187-d90f-41c4-859e-271fc5ff1e98	10eed7eb-a435-47c9-8e0c-840718b62854	The Principal demands a change in the coaching schedule to accommodate a meeting.	f	2026-04-28 15:44:23.328455+00
ad2d6609-f98c-494e-935b-dbff5c96b227	3b5bce19-87db-443e-a301-c16804fcbf22	WRER is 0% but growth is unexpectedly high across the majority of classrooms.	f	2026-04-28 15:44:23.328455+00
3cbfb718-3c60-4264-aafd-279f41303dcc	3b5bce19-87db-443e-a301-c16804fcbf22	The teacher refuses to sign the coaching notes because they disagree with the data.	f	2026-04-28 15:44:23.328455+00
a8d1ed6c-8a04-4f1e-922f-fa1cef7a0d6e	3b5bce19-87db-443e-a301-c16804fcbf22	WRER is 100% (visits happening) but Growth Rate is 0% (no behavior change).	t	2026-04-28 15:44:23.328455+00
cb363a4f-1877-4e34-a54d-765f99d022b6	3b5bce19-87db-443e-a301-c16804fcbf22	The Principal takes over the coaching session and dictates the teacher's action steps.	f	2026-04-28 15:44:23.328455+00
ebeea166-a417-4e45-b2d4-7e017d3c31c7	f99b1fc4-b101-419a-b138-c2ebb0ec6118	The final coaching report is filed and signed by both the coach and the Principal.	f	2026-04-28 15:44:23.328455+00
caa57079-bf9b-4169-948c-b446ac55cb4e	f99b1fc4-b101-419a-b138-c2ebb0ec6118	The coach gives a specific compliment about the teacher's effort during the visit.	f	2026-04-28 15:44:23.328455+00
e422ca23-08e0-462c-9d2a-3e7a9781996d	f99b1fc4-b101-419a-b138-c2ebb0ec6118	Coach and teacher verify together that the new skill is a mastered habit.	t	2026-04-28 15:44:23.328455+00
05d3c623-fc4b-4e21-8afe-16789203017b	f99b1fc4-b101-419a-b138-c2ebb0ec6118	The central office training is completed and the teacher receives their certificate.	f	2026-04-28 15:44:23.328455+00
ae533446-3a25-463c-b94a-aa192c9827c2	5da0441b-9057-4f23-8eef-2bbcba469486	Remind them that this strategy is the new "Gold Standard" required by the district.	f	2026-04-28 15:44:23.328455+00
79ca2458-db6f-4537-bf19-5522bd6cc857	5da0441b-9057-4f23-8eef-2bbcba469486	Acknowledge their expertise and ask which part of the strategy fits their classroom.	t	2026-04-28 15:44:23.328455+00
3cb1240d-3752-4cab-9b5a-221daed4a16b	5da0441b-9057-4f23-8eef-2bbcba469486	Suggest they observe a younger teacher who has mastered the new digital tools.	f	2026-04-28 15:44:23.328455+00
60a6a627-e95f-4e0a-b19a-c70128619b64	5da0441b-9057-4f23-8eef-2bbcba469486	Perform modeling in their classroom without asking for their specific permission.	fpg_dump: processing data for table "public.profiles"
pg_dump: dumping contents of table "public.profiles"
pg_dump: processing data for table "public.questions"
pg_dump: dumping contents of table "public.questions"
	2026-04-28 15:44:23.328455+00
12a16f6b-9b7f-413d-bb00-a2fbd97c889b	52e20cfb-c842-4f26-9bae-8c541581fa59	Blame previous student behavior or lack of school-wide discipline for the failure.	f	2026-04-28 15:44:23.328455+00
e8337fb5-e053-4140-94c7-be8d108b5c94	52e20cfb-c842-4f26-9bae-8c541581fa59	Use the "Shared Mirror" to admit failure and ask: "What did you notice I missed?"	t	2026-04-28 15:44:23.328455+00
3f1bd840-00a6-49e5-824a-d14a06ac28a1	52e20cfb-c842-4f26-9bae-8c541581fa59	Pretend it went well to maintain your "Expert" status and the teacher's respect.	f	2026-04-28 15:44:23.328455+00
4cca00ae-0eea-4b03-ad8d-78283b23f655	52e20cfb-c842-4f26-9bae-8c541581fa59	Delete the failure recording from the app so it doesn't skew your performance data.	f	2026-04-28 15:44:23.328455+00
fe9b5e03-6c1e-47ed-a9af-35d71f53920b	eea9e5e0-e46e-41a8-ae7e-8f86e45d9ace	Theory is too difficult for most teachers to read and apply in a busy school day.	f	2026-04-28 15:44:23.328455+00
c80c4977-9487-40a9-bde2-ac617d6cd15c	eea9e5e0-e46e-41a8-ae7e-8f86e45d9ace	It is much easier for the coach to grade a physical action than an abstract idea.	f	2026-04-28 15:44:23.328455+00
ce9feb17-6a8f-47cd-ae67-319df794cb5f	eea9e5e0-e46e-41a8-ae7e-8f86e45d9ace	It allows the "Human Filter" to adapt the intent of a strategy to fit local reality.	t	2026-04-28 15:44:23.328455+00
be5f20e0-1ac4-4198-a3b7-ed5d69ef250f	eea9e5e0-e46e-41a8-ae7e-8f86e45d9ace	The manual is only a suggestion and should not be followed strictly by teachers.	f	2026-04-28 15:44:23.328455+00
\.


--
-- TOC entry 4705 (class 0 OID 18502)
-- Dependencies: 293
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (id, phone, full_name, persona, baseline_score, baseline_completed, endline_score, endline_completed, created_at, updated_at, endline_attempt_count, baseline_attempt_count, qualifications, experiences, weak_modules, school_id, region, teacher_ids) FROM stdin;
\.


--
-- TOC entry 4710 (class 0 OID 18592)
-- Dependencies: 298
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.questions (id, assessment_id, question_type, question_text, correct_answer, max_score, order_number, created_at) FROM stdin;
4fda6529-8022-4149-b839-70d6de0d355f	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	According to the SCARF model, a veteran teacher saying they don't need a coach is a direct threat to:	\N	1	1	2026-04-28 15:44:23.278594+00
b32516e0-c810-46c9-bd45-388a39556a1f	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	When a teacher displays "Flight" behavior (minimal responses), it likely indicates the coach has:	\N	1	2	2026-04-28 15:44:23.278594+00
08a5b4f5-7d61-4419-81cc-6d891bd319ab	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	A Principal demands the individual engagement scores of all teachers to decide on "Show Cause" notices. According to the Universal SOP, you should:	\N	1	3	2026-04-28 15:44:23.278594+00
5144e503-5851-461d-90e1-60e839962c2f	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: A veteran teacher reacts with "Freeze" behavior (passive compliance). Which Opening Script best uses Equality and Voice to establish a partnership?	\N	1	4	2026-04-28 15:44:23.278594+00
afb32ad6-eded-478b-94e4-c6010a81e9c2	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: During a feedback session, a teacher is defensive. To move to a Side-by-Side mindset, you should:	\N	1	5	2026-04-28 15:44:23.278594+00
4839ebe4-1df0-464d-a8b1-2bc4dde464c0	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: You notice a teacher is struggling with a noisy class. Instead of giving a "fix," you use Deep Empathy by saying:	\N	1	6	2026-04-28 15:44:23.278594+00
b7055dca-aa91-4bd0-bf30-87bbac5d256f	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	What is the primary purpose of capturing "Data at the Edge" (e.g., back-row notebooks)?	\N	1	7	2026-04-28 15:44:23.278594+00
2e194357-4995-4674-9cb7-eee7c97f0139	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	If a coach and teacher score the same lesson differently, this "Calibration Gap" is usually caused by:	\N	1	8	2026-04-28 15:44:23.278594+00
99658b03-cb6e-42aa-8692-d3992acb1753	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	The Human Filter rule states that a coach should NOT capture an artifact if:	\N	1	9	2026-04-28 15:44:23.278594+00
2db23441-5715-4986-98bb-9f3bf98adac8	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: Which observation note successfully passes the "Camera Test" by removing high-inference judgment?	\N	1	10	2026-04-28 15:44:23.278594+00
d4f48b2c-4199-4d4e-a57e-11e7dbc8982f	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: A teacher insists a class was "perfect," but data shows 0% passed the exit ticket. To achieve Calibration, you should:	\N	1	11	2026-04-28 15:44:23.278594+00
74c213bd-ba47-49b7-9521-427fa4795017	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: When taking a digital photo of student work, the Voice principle requires you to:	\N	1	12	2026-04-28 15:44:23.278594+00
f9be4327-7d25-449f-acdc-6a6c3a4d28e7	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Coach Usman had 6 visits. 1 holiday, 1 absent teacher (excluded), 1 visit with no artifact, and 1 interrupted by a Principal. What is his WRER?	\N	1	13	2026-04-28 15:44:23.278594+00
1347beea-e3ec-4f02-9d51-be3c45fe086b	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	What does a "High Fidelity" but "Low Impact" score on a Regional Heatmap suggest?	\N	1	14	2026-04-28 15:44:23.278594+00
0d20b13e-3d3b-483e-a581-49e6e554b654	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	To avoid the "Administrative After-Burn," a coach should:	\N	1	15	2026-04-28 15:44:23.278594+00
e40f8da7-18e8-4214-8a82-41158566c5a3	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: A Principal displaces your coaching block with "Protocol Duty." Which Advocacy Script best protects your time?	\N	1	16	2026-04-28 15:44:23.278594+00
1d138086-1f50-4e5c-bf91-37f821c63d02	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: An AI dashboard suggests "Use digital tools," but there is no electricity. Following Human Override, you:	\N	1	17	2026-04-28 15:44:23.278594+00
16bdc8d4-4907-4158-9c47-5a6f164f6a20	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: A dashboard shows 100% task completion, but you observe students just copying from the board. You should:	\N	1	18	2026-04-28 15:44:23.278594+00
be00acd1-d4ae-4230-bcef-2ba922874a69	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This is a:	\N	1	19	2026-04-28 15:44:23.278594+00
e6d0fc8c-3b19-4864-b4c8-f79c856f9909	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	In Side-by-Side Co-Modeling, the coach's goal is to:	\N	1	20	2026-04-28 15:44:23.278594+00
9b13f78b-5b19-4b15-924d-b2d25c4dc423	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	If a goal is not met after two visits, the Improve Phase requires one of 4 Paths. Which is NOT a path?	\N	1	21	2026-04-28 15:44:23.278594+00
87134515-2529-466c-b9c3-65f9d173b098	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap (Internal Rule) as:	\N	1	22	2026-04-28 15:44:23.278594+00
b4041c70-719d-401f-9ef2-55d4de79f839	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: A teacher spends 20 minutes on a 5-minute intro. You diagnose this as a Planning Loop failure and:	\N	1	23	2026-04-28 15:44:23.278594+00
810ba0e8-ed4c-409d-bddc-825172a36892	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: When a teacher has 8 skill gaps, a "Catalyst" coach prioritizes:	\N	1	24	2026-04-28 15:44:23.278594+00
10eed7eb-a435-47c9-8e0c-840718b62854	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	"Responsive Contextualization" is necessary when:	\N	1	25	2026-04-28 15:44:23.278594+00
3b5bce19-87db-443e-a301-c16804fcbf22	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	The "Compliance Trap" occurs when:	\N	1	26	2026-04-28 15:44:23.278594+00
f99b1fc4-b101-419a-b138-c2ebb0ec6118	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	"Closing the Loop" is only achieved when:	\N	1	27	2026-04-28 15:44:23.278594+00
5da0441b-9057-4f23-8eef-2bbcba469486	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: A veteran teacher is skeptical of a new strategy. Thepg_dump: processing data for table "public.regions"
pg_dump: dumping contents of table "public.regions"
pg_dump: processing data for table "public.scenario_options"
pg_dump: dumping contents of table "public.scenario_options"
pg_dump: processing data for table "public.scenario_responses"
pg_dump: dumping contents of table "public.scenario_responses"
pg_dump: processing data for table "public.scenarios"
pg_dump: dumping contents of table "public.scenarios"
pg_dump: processing data for table "public.session_events"
pg_dump: dumping contents of table "public.session_events"
pg_dump: processing data for table "public.training_content"
pg_dump: dumping contents of table "public.training_content"
 most Reciprocal move is to:	\N	1	28	2026-04-28 15:44:23.278594+00
52e20cfb-c842-4f26-9bae-8c541581fa59	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: You model a strategy and it fails (chaotic classroom). To maintain Shared Reality, you:	\N	1	29	2026-04-28 15:44:23.278594+00
eea9e5e0-e46e-41a8-ae7e-8f86e45d9ace	bde3f9b7-dc97-4619-8daf-e305fe9679b2	mcq	Case Study: Why is Praxis (action-based learning) prioritized over "Abstract Theory"?	\N	1	30	2026-04-28 15:44:23.278594+00
\.


--
-- TOC entry 4716 (class 0 OID 18769)
-- Dependencies: 304
-- Data for Name: regions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.regions (id, name, code, coordinates, parent_id, created_at) FROM stdin;
\.


--
-- TOC entry 4719 (class 0 OID 18824)
-- Dependencies: 307
-- Data for Name: scenario_options; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scenario_options (id, scenario_id, option_letter, option_text, is_correct, rationale, principle_tag, created_at) FROM stdin;
\.


--
-- TOC entry 4720 (class 0 OID 18843)
-- Dependencies: 308
-- Data for Name: scenario_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scenario_responses (id, user_id, scenario_id, chosen_option, is_correct, time_spent_seconds, attempt_number, created_at) FROM stdin;
\.


--
-- TOC entry 4718 (class 0 OID 18804)
-- Dependencies: 306
-- Data for Name: scenarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scenarios (id, unit_id, order_number, situation, question, difficulty, feedback_slides, reveal_content, deep_content, is_active, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4715 (class 0 OID 18713)
-- Dependencies: 303
-- Data for Name: session_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_events (id, user_id, event_type, training_id, properties, created_at) FROM stdin;
\.


--
-- TOC entry 4707 (class 0 OID 18536)
-- Dependencies: 295
-- Data for Name: training_content; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.training_content (id, training_id, format_type, content_url, created_at, scenario_data) FROM stdin;
e2509bfc-485d-47b4-845b-b113e41811e2	9cd550e0-6d67-4ae7-8a66-2e9f7fe1665c	slide	https://docs.google.com/presentation/d/1observation_data_collection_slides/edit?usp=sharing	2026-04-28 15:44:23.271143+00	\N
1485d21a-f7a7-41ba-942f-4a08fb4eae9a	c27119b1-2abc-43aa-bdb4-04685bff9eae	slide	https://docs.google.com/presentation/d/1impact_cycle_overview_slides/edit?usp=sharing	2026-04-28 15:44:23.271143+00	\N
c439a548-70cb-4f8a-a6ec-a379e7b5fa1e	b7a36e0b-1f74-4c2f-adbe-206d3d98bd12	slide	https://docs.google.com/presentation/d/1building_habits_mastery_slides/edit?usp=sharing	2026-04-28 15:44:23.271143+00	\N
877da2ec-dbcb-4b6f-b5ee-d8b5e18bdcca	0c63f9b2-c910-4458-883e-daae4d64b2f3	slide	https://docs.google.com/presentation/d/1calibration_process_slides/edit?usp=sharing	2026-04-28 15:44:23.271143+00	\N
dc9b4cc1-d89a-4f6e-bd26-a2049ab305fb	cef38014-e47b-43f1-af00-57043a3f1d66	slide	https://docs.google.com/presentation/d/1codesign_action_steps_slides/edit?usp=sharing	2026-04-28 15:44:23.271143+00	\N
7a5ffe38-0e7d-40b8-a475-e7e1c80980a3	7d265097-61c7-49aa-bfd0-22760072b3ef	slide	https://docs.google.com/presentation/d/1documentation_followup_slides/edit?usp=sharing	2026-04-28 15:44:23.271143+00	\N
eba8c311-a5a2-4997-bf3d-8a5ab8731f01	a497d35d-9963-4678-9703-10d47feb41df	slide	https://docs.google.com/presentation/d/1feedback_empathy_slides/edit?usp=sharing	2026-04-28 15:44:23.271143+00	\N
edeb07b0-d148-404b-a896-e009d0b3ab40	765d76d0-5ea6-491f-90ff-684315f463d5	slide	https://docs.google.com/presentation/d/1sb8jI9lX3qR5wW0dT4bH8iJ2pK0sM5zN7aO1fP2gQ9/edit?usp=sharing	2026-04-28 15:44:23.311797+00	\N
0c24023c-12f6-4f80-b444-74ec1461ae2b	16bcf206-446e-4aea-beb0-7e43c1372cc5	slide	https://docs.google.com/presentation/d/1qZ6hG7jV1oP3uU8bR2zF6gH0nI8qK3xL5yM9cN0dO7/edit?usp=sharing	2026-04-28 15:44:23.311797+00	\N
638872f1-2546-4200-8ad6-f3cc1fc06e51	110975b9-7079-4e30-800c-45a49c48d352	slide	https://docs.google.com/presentation/d/1ra7iH8kW2pQ4vV9cS3aG7hI1oJ9rL4yM6zN0eO1fP8/edit?usp=sharing	2026-04-28 15:44:23.311797+00	\N
1f84abf6-6238-41f4-a87b-0c21a5455fee	78a2a962-0a1a-41cf-a739-b3ed7df778c1	slide	https://docs.google.com/presentation/d/1nW3eD4gS8lM0rR5yO9wC3eE7kF8vG5nH0uI2xJ6zK4/edit?usp=sharing	2026-04-28 15:44:23.311797+00	\N
a5fca5c1-f21d-44f2-bfa8-2aee79d09114	98853170-fd6f-4522-a1f9-fe28fc398007	slide	https://docs.google.com/presentation/d/1mV2dC3fR7kL9pQ4xN8vA2bD5jE6sF4mG9tH1uI3wJ5/edit?usp=sharing	2026-04-28 15:44:23.311797+00	\N
6300f8cb-c600-4362-a89f-5023b2af7742	7d27936d-1e24-43c3-950d-cfeaa0879f82	slide	https://docs.google.com/presentation/d/1pY5gF6iU0nO2tT7aQ1yE5fG9mH0xI7pJ2wK4zL8bM6/edit?usp=sharing	2026-04-28 15:44:23.311797+00	\N
e6f2ae54-03bc-4692-b56e-b2f1fe4b1078	98fb67f3-5319-4d11-b928-195aabbdbb58	slide	https://docs.google.com/presentation/d/1oX4fE5hT9mN1sS6zP0xD4eF8lG9wH6oI1vJ3yK7aL5/edit?usp=sharing	2026-04-28 15:44:23.311797+00	\N
36330cfa-4ae7-4301-aaa3-2aa9c08a0a70	98853170-fd6f-4522-a1f9-fe28fc398007	scenario	scenario://module1/unit0/observation	2026-04-28 15:44:23.318606+00	{"task": "How would you start the post-observation conversation? What data would you present first?", "title": "Coaching Conversation: A Real Classroom Visit", "context": "You are observing a Grade 2 English class. The teacher wanted to focus on student engagement during reading comprehension.", "scenario": "During your observation, you notice: 50% of students are actively participating in discussions, while others are disengaged. Some students raise hands but rarely get called on. When called on, they often say \\"I don't know\\" without attempting to answer.", "coaching_focus": "Partnership and data-driven dialogue", "time_estimate_minutes": 45}
c2a88a9a-ca9b-4778-b2ee-fac16d88595f	78a2a962-0a1a-41cf-a739-b3ed7df778c1	scenario	scenario://module1/unit1/data-collection	2026-04-28 15:44:23.318606+00	{"task": "What specific, low-inference data points would you document? How does this differ from the teacher's perception?", "title": "Capturing Objective Data", "context": "You're observing a math lesson on multi-digit addition. The teacher claims students \\"understand the concept.\\"", "scenario": "As you observe: 3 students solve correctly on first attempt. 5 students solve with calculation errors. 4 students are unable to start. When you ask \\"How many students mastered this?\\", the teacher says \\"Most of them got it.\\"", "coaching_focus": "Objective observation without judgment", "time_estimate_minutes": 50}
82d233b4-d13b-4ef2-832f-c2259355e502	98fb67f3-5319-4d11-b928-195aabbdbb58	scenario	scenario://module1/unit2/calibration	2026-04-28 15:44:23.318606+00	{"task": "How do you shift from debate to shared understanding? What questions would help the teacher own the data?", "title": "When Coach and Teacher See Different Data", "context": "Post-observation debrief. You present data: \\"I counted 8 students who didn't participate in discussion.\\"", "scenario": "Teacher responds: \\"That's not right. They were thinking. One of them always needs time to process.\\" You see the teacher is defensive.", "coaching_focus": "Calibration and building shared reality", "time_estimate_minutes": 55}
f8123532-640b-4b9e-8941-df3282e427fd	7d27936d-1e24-43c3-950d-cfeaa0879f82	scenario	scenario://module1/unit3/feedback-empathy	2026-04-28 15:44:23.318606+00	{"task": "How do you deliver honest, data-backed feedback while preserving the teacher's agency and motivation?", "title": "Feedback That Builds Trust", "context": "A teacher has spent weeks planning a lesson but the execution was weak: unclear instructions, little student engagement, minimal checking for understanding.", "scenario": "The teacher is nervous and somewhat defensive. You have strong observational data showing learning didn't happen. But you also see the teacher cares deeply and tried hard.", "coaching_focus": "Empathy-driven feedback that motivates change", "time_estimate_minutes": 60}
e7f5bbac-94f6-435b-b5ae-585f278a61bd	16bcf206-446e-4aea-beb0-7e43c1372cc5	scenario	scenario://module1pg_dump: processing data for table "public.training_progress"
pg_dump: dumping contents of table "public.training_progress"
pg_dump: processing data for table "public.trainings"
pg_dump: dumping contents of table "public.trainings"
/unit4/action-steps	2026-04-28 15:44:23.318606+00	{"task": "What questions would you ask to help the teacher co-design a specific, achievable action step? How do you shift from \\"I should\\" to \\"I will\\"?", "title": "Co-Designing a Real Action Step", "context": "After discussing the data, the teacher says: \\"I guess I need to ask more questions.\\" But this is vague and doesn't feel owned.", "scenario": "You can see the teacher is complying, not choosing. You want to move to a concrete, measurable action step they actually want to try.", "coaching_focus": "Teacher agency and SMART goal-setting", "time_estimate_minutes": 45}
cefcd451-debc-4cbe-9d98-c8057614eb14	110975b9-7079-4e30-800c-45a49c48d352	scenario	scenario://module1/unit5/loop-closure	2026-04-28 15:44:23.318606+00	{"task": "How do you address this loop closure? What went wrong? How do you maintain partnership while requiring accountability?", "title": "Verifying Implementation", "context": "You agreed with a teacher 2 weeks ago that they would \\"increase cold-call opportunities during reading comprehension.\\"", "scenario": "On your follow-up visit, you observe the same patterns as before: limited student participation, teacher calls on the same volunteers. The teacher looks embarrassed.", "coaching_focus": "Loop closure and sustained behavior change", "time_estimate_minutes": 50}
35dc3b7c-4494-4a04-a2a0-1a8c69a4f517	765d76d0-5ea6-491f-90ff-684315f463d5	scenario	scenario://module1/unit6/habit-mastery	2026-04-28 15:44:23.318606+00	{"task": "How do you support habit formation and mastery? What does sustained practice look like in real classrooms?", "title": "From One-Time Change to Sustainable Habit", "context": "After 3 coaching cycles, the teacher has improved their cold-calling. But you notice they revert to old patterns under stress or time pressure.", "scenario": "They say: \\"I did it for a few weeks but it's hard to remember every day. I fall back into old habits.\\"", "coaching_focus": "Deliberate practice and habit sustainability", "time_estimate_minutes": 55}
\.


--
-- TOC entry 4708 (class 0 OID 18552)
-- Dependencies: 296
-- Data for Name: training_progress; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.training_progress (id, user_id, training_id, score, passed, completed_at, created_at, attempt_count, tab_switch_count, fullscreen_violations, flagged_for_review, content_completed, content_completed_at, started_at) FROM stdin;
\.


--
-- TOC entry 4706 (class 0 OID 18524)
-- Dependencies: 294
-- Data for Name: trainings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trainings (id, title, description, persona_required, order_number, is_common, created_at, module_id, main_concepts, max_attempts, quiz_unlock_requires_content) FROM stdin;
c27119b1-2abc-43aa-bdb4-04685bff9eae	Unit 1.0: The Impact Cycle Overview	Understand the 4-phase coaching cycle and its role in teacher development	\N	1	t	2026-04-28 15:44:23.271143+00	\N	\N	3	t
9cd550e0-6d67-4ae7-8a66-2e9f7fe1665c	Unit 1.1: Observation & Data Collection	Learn systematic observation techniques and how to capture objective classroom data	\N	2	t	2026-04-28 15:44:23.271143+00	\N	\N	3	t
0c63f9b2-c910-4458-883e-daae4d64b2f3	Unit 1.2: The Calibration Process	Develop shared understanding between coach and teacher through data-based dialogue	\N	3	t	2026-04-28 15:44:23.271143+00	\N	\N	3	t
a497d35d-9963-4678-9703-10d47feb41df	Unit 1.3: Feedback with Empathy	Master the art of delivering feedback that builds trust and motivates change	\N	4	t	2026-04-28 15:44:23.271143+00	\N	\N	3	t
cef38014-e47b-43f1-af00-57043a3f1d66	Unit 1.4: Co-Designing Action Steps	Partner with teachers to create realistic, actionable improvement plans	\N	5	t	2026-04-28 15:44:23.271143+00	\N	\N	3	t
7d265097-61c7-49aa-bfd0-22760072b3ef	Unit 1.5: Documentation & Follow-up	Track progress and maintain continuity across coaching visits	\N	6	t	2026-04-28 15:44:23.271143+00	\N	\N	3	t
b7a36e0b-1f74-4c2f-adbe-206d3d98bd12	Unit 1.6: Building Habits & Mastery	Support teachers in making new practices automatic thropg_dump: processing data for table "public.user_regions"
pg_dump: dumping contents of table "public.user_regions"
pg_dump: processing data for table "public.user_roles"
pg_dump: dumping contents of table "public.user_roles"
pg_dump: processing data for table "realtime.messages_2026_06_06"
pg_dump: dumping contents of table "realtime.messages_2026_06_06"
pg_dump: processing data for table "realtime.messages_2026_06_07"
pg_dump: dumping contents of table "realtime.messages_2026_06_07"
pg_dump: processing data for table "realtime.messages_2026_06_08"
pg_dump: dumping contents of table "realtime.messages_2026_06_08"
pg_dump: processing data for table "realtime.messages_2026_06_09"
pg_dump: dumping contents of table "realtime.messages_2026_06_09"
pg_dump: processing data for table "realtime.messages_2026_06_10"
pg_dump: dumping contents of table "realtime.messages_2026_06_10"
pg_dump: processing data for table "realtime.messages_2026_06_11"
ugh deliberate practice	\N	7	t	2026-04-28 15:44:23.271143+00	\N	\N	3	t
98853170-fd6f-4522-a1f9-fe28fc398007	Unit 1.0: The Impact Cycle Overview	Understand the 4-phase coaching cycle and its role in teacher development	\N	1	t	2026-04-28 15:44:23.311797+00	f6c3ce01-e48f-4ef1-8a74-07f1f3b59ebc	\N	3	t
78a2a962-0a1a-41cf-a739-b3ed7df778c1	Unit 1.1: Observation & Data Collection	Learn systematic observation techniques and how to capture objective classroom data	\N	2	t	2026-04-28 15:44:23.311797+00	f6c3ce01-e48f-4ef1-8a74-07f1f3b59ebc	\N	3	t
98fb67f3-5319-4d11-b928-195aabbdbb58	Unit 1.2: The Calibration Process	Develop shared understanding between coach and teacher through data-based dialogue	\N	3	t	2026-04-28 15:44:23.311797+00	f6c3ce01-e48f-4ef1-8a74-07f1f3b59ebc	\N	3	t
7d27936d-1e24-43c3-950d-cfeaa0879f82	Unit 1.3: Feedback with Empathy	Master the art of delivering feedback that builds trust and motivates change	\N	4	t	2026-04-28 15:44:23.311797+00	f6c3ce01-e48f-4ef1-8a74-07f1f3b59ebc	\N	3	t
16bcf206-446e-4aea-beb0-7e43c1372cc5	Unit 1.4: Co-Designing Action Steps	Partner with teachers to create realistic, actionable improvement plans	\N	5	t	2026-04-28 15:44:23.311797+00	f6c3ce01-e48f-4ef1-8a74-07f1f3b59ebc	\N	3	t
110975b9-7079-4e30-800c-45a49c48d352	Unit 1.5: Documentation & Follow-up	Track progress and maintain continuity across coaching visits	\N	6	t	2026-04-28 15:44:23.311797+00	f6c3ce01-e48f-4ef1-8a74-07f1f3b59ebc	\N	3	t
765d76d0-5ea6-491f-90ff-684315f463d5	Unit 1.6: Building Habits & Mastery	Support teachers in making new practices automatic through deliberate practice	\N	7	t	2026-04-28 15:44:23.311797+00	f6c3ce01-e48f-4ef1-8a74-07f1f3b59ebc	\N	3	t
f47ac10b-58cc-4372-a567-0e02b2c3d479	Coach Baseline Assessment	Baseline assessment for coaching program	\N	0	t	2026-04-28 15:44:23.425931+00	\N	\N	3	t
f47ac10b-58cc-4372-a567-0e02b2c3d480	Coach Endline Assessment	Endline assessment for coaching program	\N	999	t	2026-04-28 15:44:23.425931+00	\N	\N	3	t
\.


--
-- TOC entry 4717 (class 0 OID 18785)
-- Dependencies: 305
-- Data for Name: user_regions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_regions (id, user_id, region_id, created_at) FROM stdin;
\.


--
-- TOC entry 4713 (class 0 OID 18655)
-- Dependencies: 301
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (id, user_id, role, created_at) FROM stdin;
\.


--
-- TOC entry 4724 (class 0 OID 65925)
-- Dependencies: 312
-- Data for Name: messages_2026_06_06; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2026_06_06 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- TOC entry 4725 (class 0 OID 65937)
-- Dependencies: 313
-- Data for Name: messages_2026_06_07; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2026_06_07 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- TOC entry 4726 (class 0 OID 74081)
-- Dependencies: 314
-- Data for Name: messages_2026_06_08; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2026_06_08 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- TOC entry 4727 (class 0 OID 74093)
-- Dependencies: 315
-- Data for Name: messages_2026_06_09; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2026_06_09 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- TOC entry 4728 (class 0 OID 74105)
-- Dependencies: 316
-- Data for Name: messages_2026_06_10; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2026_06_10 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- TOC entry 4729 (class 0 OID 74117)
-- Dependencies: 317
-- Data for Name: messages_2026_06_11; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2026_06_11 (topic, extension, payload, event,pg_dump: dumping contents of table "realtime.messages_2026_06_11"
pg_dump: processing data for table "realtime.messages_2026_06_12"
pg_dump: dumping contents of table "realtime.messages_2026_06_12"
pg_dump: processing data for table "realtime.schema_migrations"
pg_dump: dumping contents of table "realtime.schema_migrations"
pg_dump: processing data for table "realtime.subscription"
pg_dump: dumping contents of table "realtime.subscription"
pg_dump: processing data for table "storage.buckets"
pg_dump: dumping contents of table "storage.buckets"
pg_dump: processing data for table "storage.buckets_analytics"
pg_dump: dumping contents of table "storage.buckets_analytics"
pg_dump: processing data for table "storage.buckets_vectors"
 private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- TOC entry 4730 (class 0 OID 74129)
-- Dependencies: 318
-- Data for Name: messages_2026_06_12; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.messages_2026_06_12 (topic, extension, payload, event, private, updated_at, inserted_at, id) FROM stdin;
\.


--
-- TOC entry 4673 (class 0 OID 17076)
-- Dependencies: 257
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2026-04-28 15:44:07
20211116045059	2026-04-28 15:44:07
20211116050929	2026-04-28 15:44:07
20211116051442	2026-04-28 15:44:07
20211116212300	2026-04-28 15:44:07
20211116213355	2026-04-28 15:44:07
20211116213934	2026-04-28 15:44:07
20211116214523	2026-04-28 15:44:07
20211122062447	2026-04-28 15:44:07
20211124070109	2026-04-28 15:44:07
20211202204204	2026-04-28 15:44:07
20211202204605	2026-04-28 15:44:07
20211210212804	2026-04-28 15:44:07
20211228014915	2026-04-28 15:44:07
20220107221237	2026-04-28 15:44:07
20220228202821	2026-04-28 15:44:07
20220312004840	2026-04-28 15:44:07
20220603231003	2026-04-28 15:44:07
20220603232444	2026-04-28 15:44:07
20220615214548	2026-04-28 15:44:07
20220712093339	2026-04-28 15:44:07
20220908172859	2026-04-28 15:44:07
20220916233421	2026-04-28 15:44:07
20230119133233	2026-04-28 15:44:07
20230128025114	2026-04-28 15:44:07
20230128025212	2026-04-28 15:44:07
20230227211149	2026-04-28 15:44:07
20230228184745	2026-04-28 15:44:07
20230308225145	2026-04-28 15:44:07
20230328144023	2026-04-28 15:44:07
20231018144023	2026-04-28 15:44:07
20231204144023	2026-04-28 15:44:07
20231204144024	2026-04-28 15:44:07
20231204144025	2026-04-28 15:44:07
20240108234812	2026-04-28 15:44:07
20240109165339	2026-04-28 15:44:07
20240227174441	2026-04-28 15:44:07
20240311171622	2026-04-28 15:44:07
20240321100241	2026-04-28 15:44:07
20240401105812	2026-04-28 15:44:07
20240418121054	2026-04-28 15:44:07
20240523004032	2026-04-28 15:44:07
20240618124746	2026-04-28 15:44:07
20240801235015	2026-04-28 15:44:07
20240805133720	2026-04-28 15:44:07
20240827160934	2026-04-28 15:44:07
20240919163303	2026-04-28 15:44:07
20240919163305	2026-04-28 15:44:07
20241019105805	2026-04-28 15:44:07
20241030150047	2026-04-28 15:44:07
20241108114728	2026-04-28 15:44:07
20241121104152	2026-04-28 15:44:07
20241130184212	2026-04-28 15:44:07
20241220035512	2026-04-28 15:44:07
20241220123912	2026-04-28 15:44:07
20241224161212	2026-04-28 15:44:07
20250107150512	2026-04-28 15:44:07
20250110162412	2026-04-28 15:44:07
20250123174212	2026-04-28 15:44:07
20250128220012	2026-04-28 15:44:07
20250506224012	2026-04-28 15:44:07
20250523164012	2026-04-28 15:44:07
20250714121412	2026-04-28 15:44:08
20250905041441	2026-04-28 15:44:08
20251103001201	2026-04-28 15:44:08
\.


--
-- TOC entry 4675 (class 0 OID 17114)
-- Dependencies: 260
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- TOC entry 4677 (class 0 OID 17761)
-- Dependencies: 265
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
training-videos	training-videos	\N	2026-04-28 15:44:23.070012+00	2026-04-28 15:44:23.070012+00	t	f	524288000	{video/mp4,video/webm,video/ogg,video/quicktime,video/x-msvideo}	\N	STANDARD
\.


--
-- TOC entry 4681 (class 0 OID 17880)
-- Dependencies: 269
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- TOC entry 4684 (class 0 OID 17929)
-- Dependencies: 272
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets_vectors (id, typepg_dump: dumping contents of table "storage.buckets_vectors"
pg_dump: processing data for table "storage.iceberg_namespaces"
pg_dump: dumping contents of table "storage.iceberg_namespaces"
pg_dump: processing data for table "storage.iceberg_tables"
pg_dump: dumping contents of table "storage.iceberg_tables"
pg_dump: processing data for table "storage.migrations"
pg_dump: dumping contents of table "storage.migrations"
, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4682 (class 0 OID 17891)
-- Dependencies: 270
-- Data for Name: iceberg_namespaces; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.iceberg_namespaces (id, bucket_name, name, created_at, updated_at, metadata, catalog_id) FROM stdin;
\.


--
-- TOC entry 4683 (class 0 OID 17907)
-- Dependencies: 271
-- Data for Name: iceberg_tables; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.iceberg_tables (id, namespace_id, bucket_name, name, location, created_at, updated_at, remote_table_id, shard_key, shard_id, catalog_id) FROM stdin;
\.


--
-- TOC entry 4676 (class 0 OID 17753)
-- Dependencies: 264
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2026-04-28 15:44:21.246037
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2026-04-28 15:44:21.263984
2	storage-schema	f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd	2026-04-28 15:44:21.269184
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2026-04-28 15:44:21.282613
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2026-04-28 15:44:21.291076
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2026-04-28 15:44:21.295036
6	change-column-name-in-get-size	ded78e2f1b5d7e616117897e6443a925965b30d2	2026-04-28 15:44:21.299875
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2026-04-28 15:44:21.306476
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2026-04-28 15:44:21.311933
9	fix-search-function	af597a1b590c70519b464a4ab3be54490712796b	2026-04-28 15:44:21.316387
10	search-files-search-function	b595f05e92f7e91211af1bbfe9c6a13bb3391e16	2026-04-28 15:44:21.320757
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2026-04-28 15:44:21.325462
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2026-04-28 15:44:21.329375
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2026-04-28 15:44:21.332579
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2026-04-28 15:44:21.336605
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2026-04-28 15:44:21.358943
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2026-04-28 15:44:21.36258
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2026-04-28 15:44:21.366242
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2026-04-28 15:44:21.369093
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2026-04-28 15:44:21.372773
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2026-04-28 15:44:21.375974
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2026-04-28 15:44:21.380426
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2026-04-28 15:44:21.390542
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2026-04-28 15:44:21.397697
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2026-04-28 15:44:21.401819
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2026-04-28 15:44:21.406486
26	objects-prefixes	215cabcb7f78121892a5a2037a09fedf9a1ae322	2026-04-28 15:44:21.410292
27	search-v2	859ba38092ac96eb3964d83bf53ccc0b141663a6	2026-04-28 15:44:21.41396
28	object-bucket-name-sorting	c73a2b5b5d4041e39705814fd3a1b95502d38ce4	2026-04-28 15:44:21.416616
29	create-prefixes	ad2c1207f76703d11a9f9007f821620017a66c21	2026-04-28 15:44:21.418742
30	update-object-levels	2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6	2026-04-28 15:44:21.420816
31	objects-level-index	b40367c14c3440ec75f19bbce2d71e914ddd3da0	2026-04-28 15:44:21.423518
32	backward-compatible-index-on-objects	e0c37182b0f7aee3efd823298fb3c76f1042c0f7	2026-04-28 15:44:21.426869
33	backward-compatible-index-on-prefixes	b480e99ed951e0900f033ec4eb34b5bdcb4e3d49	2026-04-28 15:pg_dump: processing data for table "storage.objects"
pg_dump: dumping contents of table "storage.objects"
pg_dump: processing data for table "storage.s3_multipart_uploads"
pg_dump: dumping contents of table "storage.s3_multipart_uploads"
pg_dump: processing data for table "storage.s3_multipart_uploads_parts"
pg_dump: dumping contents of table "storage.s3_multipart_uploads_parts"
pg_dump: processing data for table "storage.vector_indexes"
pg_dump: dumping contents of table "storage.vector_indexes"
44:21.43068
34	optimize-search-function-v1	ca80a3dc7bfef894df17108785ce29a7fc8ee456	2026-04-28 15:44:21.433664
35	add-insert-trigger-prefixes	458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc	2026-04-28 15:44:21.435614
36	optimise-existing-functions	6ae5fca6af5c55abe95369cd4f93985d1814ca8f	2026-04-28 15:44:21.437647
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2026-04-28 15:44:21.439469
38	iceberg-catalog-flag-on-buckets	02716b81ceec9705aed84aa1501657095b32e5c5	2026-04-28 15:44:21.442923
39	add-search-v2-sort-support	6706c5f2928846abee18461279799ad12b279b78	2026-04-28 15:44:21.462136
40	fix-prefix-race-conditions-optimized	7ad69982ae2d372b21f48fc4829ae9752c518f6b	2026-04-28 15:44:21.466375
41	add-object-level-update-trigger	07fcf1a22165849b7a029deed059ffcde08d1ae0	2026-04-28 15:44:21.469183
42	rollback-prefix-triggers	771479077764adc09e2ea2043eb627503c034cd4	2026-04-28 15:44:21.47107
43	fix-object-level	84b35d6caca9d937478ad8a797491f38b8c2979f	2026-04-28 15:44:21.473698
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2026-04-28 15:44:21.476237
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2026-04-28 15:44:21.479887
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2026-04-28 15:44:21.491943
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2026-04-28 15:44:21.496752
48	iceberg-catalog-ids	e0e8b460c609b9999ccd0df9ad14294613eed939	2026-04-28 15:44:21.500012
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2026-04-28 15:44:21.537881
50	search-v2-optimised	6323ac4f850aa14e7387eb32102869578b5bd478	2026-04-28 15:44:21.542217
51	index-backward-compatible-search	2ee395d433f76e38bcd3856debaf6e0e5b674011	2026-04-28 15:44:21.55824
52	drop-not-used-indexes-and-functions	5cc44c8696749ac11dd0dc37f2a3802075f3a171	2026-04-28 15:44:21.559379
53	drop-index-lower-name	d0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854	2026-04-28 15:44:21.566931
54	drop-index-object-level	6289e048b1472da17c31a7eba1ded625a6457e67	2026-04-28 15:44:21.56957
55	prevent-direct-deletes	262a4798d5e0f2e7c8970232e03ce8be695d5819	2026-04-28 15:44:21.571974
57	s3-multipart-uploads-metadata	f127886e00d1b374fadbc7c6b31e09336aad5287	2026-04-28 15:44:21.584036
58	operation-ergonomics	00ca5d483b3fe0d522133d9002ccc5df98365120	2026-04-28 15:44:21.587812
56	fix-optimized-search-function	b823ed1e418101032fa01374edc9a436e54e3ed4	2026-04-28 15:44:21.576885
59	drop-unused-functions	38456f13e39691c2bbb4b5151d0d1cdbabd4a8c4	2026-05-12 15:23:10.872478
60	optimize-existing-functions-again	db35e1c91a9201e59f4fef8d972c2f277d68b157	2026-05-12 15:23:10.890596
\.


--
-- TOC entry 4678 (class 0 OID 17771)
-- Dependencies: 266
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
\.


--
-- TOC entry 4679 (class 0 OID 17820)
-- Dependencies: 267
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata, metadata) FROM stdin;
\.


--
-- TOC entry 4680 (class 0 OID 17834)
-- Dependencies: 268
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- TOC entry 4685 (class 0 OID 17939)
-- Dependencies: 273
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4669 (class 0 OID 16721)
-- Dependencies: 253
-- Data for Name: hooks; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
-pg_dump: processing data for table "supabase_functions.hooks"
pg_dump: dumping contents of table "supabase_functions.hooks"
pg_dump: processing data for table "supabase_functions.migrations"
pg_dump: dumping contents of table "supabase_functions.migrations"
pg_dump: processing data for table "supabase_migrations.schema_migrations"
pg_dump: dumping contents of table "supabase_migrations.schema_migrations"
-

COPY supabase_functions.hooks (id, hook_table_id, hook_name, created_at, request_id) FROM stdin;
\.


--
-- TOC entry 4667 (class 0 OID 16712)
-- Dependencies: 251
-- Data for Name: migrations; Type: TABLE DATA; Schema: supabase_functions; Owner: supabase_functions_admin
--

COPY supabase_functions.migrations (version, inserted_at) FROM stdin;
initial	2026-04-28 15:44:01.917595+00
20210809183423_update_grants	2026-04-28 15:44:01.917595+00
\.


--
-- TOC entry 4704 (class 0 OID 18495)
-- Dependencies: 292
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: postgres
--

COPY supabase_migrations.schema_migrations (version, statements, name) FROM stdin;
20260211195115	{"-- Profiles table\nCREATE TABLE public.profiles (\n  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,\n  phone TEXT UNIQUE NOT NULL,\n  full_name TEXT,\n  persona TEXT CHECK (persona IN ('A', 'B', 'C', 'D')),\n  baseline_score FLOAT,\n  baseline_completed BOOLEAN NOT NULL DEFAULT false,\n  endline_score FLOAT,\n  endline_completed BOOLEAN NOT NULL DEFAULT false,\n  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),\n  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()\n)","ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Users can view own profile\\" ON public.profiles FOR SELECT USING (auth.uid() = id)","CREATE POLICY \\"Users can update own profile\\" ON public.profiles FOR UPDATE USING (auth.uid() = id)","CREATE POLICY \\"Users can insert own profile\\" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id)","-- Trainings table\nCREATE TABLE public.trainings (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  title TEXT NOT NULL,\n  description TEXT,\n  persona_required TEXT CHECK (persona_required IN ('A', 'B', 'C', 'D')),\n  order_number INT NOT NULL,\n  is_common BOOLEAN NOT NULL DEFAULT false,\n  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n)","ALTER TABLE public.trainings ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Anyone authenticated can view trainings\\" ON public.trainings FOR SELECT TO authenticated USING (true)","-- Training content table\nCREATE TABLE public.training_content (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  training_id UUID REFERENCES public.trainings(id) ON DELETE CASCADE NOT NULL,\n  format_type TEXT NOT NULL CHECK (format_type IN ('slide', 'audio', 'video')),\n  content_url TEXT NOT NULL,\n  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n)","ALTER TABLE public.training_content ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Anyone authenticated can view training content\\" ON public.training_content FOR SELECT TO authenticated USING (true)","-- Training progress table\nCREATE TABLE public.training_progress (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,\n  training_id UUID REFERENCES public.trainings(id) ON DELETE CASCADE NOT NULL,\n  score FLOAT,\n  passed BOOLEAN NOT NULL DEFAULT false,\n  completed_at TIMESTAMPTZ,\n  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),\n  UNIQUE(user_id, training_id)\n)","ALTER TABLE public.training_progress ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Users can view own progress\\" ON public.training_progress FOR SELECT USING (auth.uid() = user_id)","CREATE POLICY \\"Users can insert own progress\\" ON public.training_progress FOR INSERT WITH CHECK (auth.uid() = user_id)","CREATE POLICY \\"Users can update own progress\\" ON public.training_progress FOR UPDATE USING (auth.uid() = user_id)","-- Assessments table\nCREATE TABLE public.assessments (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  type TEXT NOT NULL CHECK (type IN ('baseline', 'endline', 'training')),\n  training_id UUID REFERENCES public.trainings(id) ON DELETE CASCADE,\n  persona_target TEXT CHECK (persona_target IN ('A', 'B', 'C', 'D')),\n  title TEXT NOT NULL,\n  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n)","ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Anyone authenticated can view assessments\\" ON public.assessments FOR SELECT TO authenticated USING (true)","-- Questions table\nCREATE TABLE public.questions (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  assessment_id UUID REFERENCES public.assessments(id) ON DELETE CASCADE NOT NULL,\n  question_type TEXT NOT NULL CHECK (question_type IN ('mcq', 'open')),\n  question_text TEXT NOT NULL,\n  correct_answer TEXT,\n  max_score INT NOT NULL DEFAULT 1,\n  order_number INT NOT NULL DEFAULT 0,\n  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n)","ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Anyone authenticated can view questions\\" ON public.questions FOR SELECT TO authenticated USING (true)","-- Options table for MCQs\nCREATE TABLE public.options (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE NOT NULL,\n  option_text TEXT NOT NULL,\n  is_correct BOOLEAN NOT NULL DEFAULT false,\n  created_at TIMESTAMPTZ NOT NULL DEFAULT now()\n)","ALTER TABLE public.options ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Anyone authenticated can view options\\" ON public.options FOR SELECT TO authenticated USING (true)","-- Certificates table\nCREATE TABLE public.certificates (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,\n  certificate_id TEXT UNIQUE NOT NULL,\n  issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),\n  persona TEXT NOT NULL,\n  UNIQUE(user_id)\n)","ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Users can view own certificates\\" ON public.certificates FOR SELECT USING (auth.uid() = user_id)","CREATE POLICY \\"Users can insert own certificates\\" ON public.certificates FOR INSERT WITH CHECK (auth.uid() = user_id)","-- Update timestamp trigger\nCREATE OR REPLACE FUNCTION public.update_updated_at_column()\nRETURNS TRIGGER AS $$\nBEGIN\n  NEW.updated_at = now();\n  RETURN NEW;\nEND;\n$$ LANGUAGE plpgsql SET search_path = public","CREATE TRIGGER update_profiles_updated_at\n  BEFORE UPDATE ON public.profiles\n  FOR EACH ROW\n  EXECUTE FUNCTION public.update_updated_at_column()","-- Auto-create profile on signup trigger\nCREATE OR REPLACE FUNCTION public.handle_new_user()\nRETURNS TRIGGER AS $$\nBEGIN\n  INSERT INTO public.profiles (id, phone)\n  VALUES (NEW.id, COALESCE(NEW.phone, NEW.email));\n  RETURN NEW;\nEND;\n$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public","CREATE TRIGGER on_auth_user_created\n  AFTER INSERT ON auth.users\n  FOR EACH ROW\n  EXECUTE FUNCTION public.handle_new_user()"}	0cf914ca-2900-47eb-95c4-a5e20076cd4e
20260218113125	{"-- Create admin role enum and user_roles table\nCREATE TYPE public.app_role AS ENUM ('admin', 'user')","CREATE TABLE public.user_roles (\n  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),\n  user_id uuid NOT NULL,\n  role app_role NOT NULL DEFAULT 'user',\n  created_at timestamp with time zone NOT NULL DEFAULT now(),\n  UNIQUE (user_id, role)\n)","ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY","-- Only admins can view roles, users can view their own\nCREATE POLICY \\"Users can view own roles\\"\nON public.user_roles FOR SELECT\nUSING (auth.uid() = user_id)","-- Security definer function to check roles (avoids RLS recursion)\nCREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role app_role)\nRETURNS boolean\nLANGUAGE sql\nSTABLE\nSECURITY DEFINER\nSET search_path = public\nAS $$\n  SELECT EXISTS (\n    SELECT 1 FROM public.user_roles\n    WHERE user_id = _user_id AND role = _role\n  )\n$$"}	c0477dae-fb6c-44b9-8752-6d8535c4dd43
20260219061142	{"-- Allow admins to manage assessments\nCREATE POLICY \\"Admins can insert assessments\\"\nON public.assessments FOR INSERT\nWITH CHECK (public.has_role(auth.uid(), 'admin'))","CREATE POLICY \\"Admins can update assessments\\"\nON public.assessments FOR UPDATE\nUSING (public.has_role(auth.uid(), 'admin'))","-- Allow admins to manage questions\nCREATE POLICY \\"Admins can insert questions\\"\nON public.questions FOR INSERT\nWITH CHECK (public.has_role(auth.uid(), 'admin'))","CREATE POLICY \\"Admins can update questions\\"\nON public.questions FOR UPDATE\nUSING (public.has_role(auth.uid(), 'admin'))","CREATE POLICY \\"Admins can delete questions\\"\nON public.questions FOR DELETE\nUSING (public.has_role(auth.uid(), 'admin'))","-- Allow admins to manage options\nCREATE POLICY \\"Admins can insert options\\"\nON public.options FOR INSERT\nWITH CHECK (public.has_role(auth.uid(), 'admin'))","CREATE POLICY \\"Admins can update options\\"\nON public.options FOR UPDATE\nUSING (public.has_role(auth.uid(), 'admin'))","CREATE POLICY \\"Admins can delete options\\"\nON public.options FOR DELETE\nUSING (public.has_role(auth.uid(), 'admin'))","-- Allow admins to manage training content\nCREATE POLICY \\"Admins can insert training content\\"\nON public.training_content FOR INSERT\nWITH CHECK (public.has_role(auth.uid(), 'admin'))","CREATE POLICY \\"Admins can delete training content\\"\nON public.training_content FOR DELETE\nUSING (public.has_role(auth.uid(), 'admin'))","-- Allow admins to manage trainings\nCREATE POLICY \\"Admins can insert trainings\\"\nON public.trainings FOR INSERT\nWITH CHECK (public.has_role(auth.uid(), 'admin'))","CREATE POLICY \\"Admins can delete trainings\\"\nON public.trainings FOR DELETE\nUSING (public.has_role(auth.uid(), 'admin'))"}	d94e1c16-9383-43de-8178-37aa0b6d7b85
20260220060108	{"-- Create modules table (top-level containers)\nCREATE TABLE public.modules (\n  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,\n  title text NOT NULL,\n  description text,\n  desired_outcomes text,\n  competencies text,\n  is_mandatory boolean NOT NULL DEFAULT false,\n  order_number integer NOT NULL DEFAULT 0,\n  created_at timestamp with time zone NOT NULL DEFAULT now(),\n  updated_at timestamp with time zone NOT NULL DEFAULT now()\n)","-- Enable RLS on modules\nALTER TABLE public.modules ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Anyone authenticated can view modules\\"\nON public.modules FOR SELECT\nUSING (true)","CREATE POLICY \\"Admins can insert modules\\"\nON public.modules FOR INSERT\nWITH CHECK (has_role(auth.uid(), 'admin'::app_role))","CREATE POLICY \\"Admins can update modules\\"\nON public.modules FOR UPDATE\nUSING (has_role(auth.uid(), 'admin'::app_role))","CREATE POLICY \\"Admins can delete modules\\"\nON public.modules FOR DELETE\nUSING (has_role(auth.uid(), 'admin'::app_role))","-- Add module_id to trainings table so they become \\"units\\" under a module\nALTER TABLE public.trainings\n  ADD COLUMN IF NOT EXISTS module_id uuid REFERENCES public.modules(id) ON DELETE SET NULL,\n  ADD COLUMN IF NOT EXISTS main_concepts text","-- Update trainings RLS: add update policy for admins\nCREATE POLICY \\"Admins can update trainings\\"\nON public.trainings FOR UPDATE\nUSING (has_role(auth.uid(), 'admin'::app_role))","-- Create storage bucket for training videos\nINSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)\nVALUES (\n  'training-videos',\n  'training-videos',\n  true,\n  524288000, -- 500MB limit\n  ARRAY['video/mp4', 'video/webm', 'video/ogg', 'video/quicktime', 'video/x-msvideo']\n)\nON CONFLICT (id) DO NOTHING","-- Storage RLS policies\nCREATE POLICY \\"Authenticated users can view training videos\\"\nON storage.objects FOR SELECT\nUSING (bucket_id = 'training-videos' AND auth.role() = 'authenticated')","CREATE POLICY \\"Admins can upload training videos\\"\nON storage.objects FOR INSERT\nWITH CHECK (bucket_id = 'training-videos' AND has_role(auth.uid(), 'admin'::app_role))","CREATE POLICY \\"Admins can delete training videos\\"\nON storage.objects FOR DELETE\nUSING (bucket_id = 'training-videos' AND has_role(auth.uid(), 'admin'::app_role))","-- Trigger to update updated_at on modules\nCREATE TRIGGER update_modules_updated_at\nBEFORE UPDATE ON public.modules\nFOR EACH ROW\nEXECUTE FUNCTION public.update_updated_at_column()"}	8e5d543c-780d-497c-81e1-bf57f6cfeeea
20260408000001	{"-- ─────────────────────────────────────────────────────────────────────────────\n-- Coaching Platform v2 — Prototype Improvements\n-- ─────────────────────────────────────────────────────────────────────────────\n\n-- 1. Add attempt_count to training_progress (max 3 attempts per module)\nALTER TABLE public.training_progress\n  ADD COLUMN IF NOT EXISTS attempt_count INTEGER NOT NULL DEFAULT 1","-- 2. Add anti-cheat violation tracking\nALTER TABLE public.training_progress\n  ADD COLUMN IF NOT EXISTS tab_switch_count INTEGER NOT NULL DEFAULT 0,\n  ADD COLUMN IF NOT EXISTS fullscreen_violations INTEGER NOT NULL DEFAULT 0,\n  ADD COLUMN IF NOT EXISTS flagged_for_review BOOLEAN NOT NULL DEFAULT false","-- 3. Add scenario content type to training_content\n-- format_type already supports arbitrary strings — just document 'scenario' as valid\n-- Add scenario_data JSON column for scenario-based content\nALTER TABLE public.training_content\n  ADD COLUMN IF NOT EXISTS scenario_data JSONB","-- 4. Fix certificate upsert — add ON CONFLICT policy\n-- The unique constraint on user_id already exists; we'll handle upsert in app layer\n-- But add a last_issued_at for tracking retakes\nALTER TABLE public.certificates\n  ADD COLUMN IF NOT EXISTS last_issued_at TIMESTAMPTZ","-- 5. Add max_attempts config to trainings (default 3)\nALTER TABLE public.trainings\n  ADD COLUMN IF NOT EXISTS max_attempts INTEGER NOT NULL DEFAULT 3","-- 6. Add endline_attempts tracking to profiles\nALTER TABLE public.profiles\n  ADD COLUMN IF NOT EXISTS endline_attempt_count INTEGER NOT NULL DEFAULT 0,\n  ADD COLUMN IF NOT EXISTS baseline_attempt_count INTEGER NOT NULL DEFAULT 0","-- 7. Add quiz_unlock_requires_content boolean to trainings (default true)\nALTER TABLE public.trainings\n  ADD COLUMN IF NOT EXISTS quiz_unlock_requires_content BOOLEAN NOT NULL DEFAULT true","-- 8. Session tracking for analytics\nCREATE TABLE IF NOT EXISTS public.session_events (\n  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,\n  event_type TEXT NOT NULL,  -- 'login', 'module_start', 'module_complete', 'quiz_attempt', 'tab_switch', 'fullscreen_exit'\n  training_id UUID REFERENCES public.trainings(id) ON DELETE SET NULL,\n  properties JSONB DEFAULT '{}',\n  created_at TIMESTAMPTZ DEFAULT NOW()\n)","-- RLS for session_events\nALTER TABLE public.session_events ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Users can insert own events\\"\n  ON public.session_events FOR INSERT\n  WITH CHECK (auth.uid() = user_id)","CREATE POLICY \\"Users can read own events\\"\n  ON public.session_events FOR SELECT\n  USING (auth.uid() = user_id)","CREATE POLICY \\"Admins can read all events\\"\n  ON public.session_events FOR SELECT\n  USING (has_role(auth.uid(), 'admin'))","-- 9. Update training_progress to track content completion separately\nALTER TABLE public.training_progress\n  ADD COLUMN IF NOT EXISTS content_completed BOOLEAN NOT NULL DEFAULT false,\n  ADD COLUMN IF NOT EXISTS content_completed_at TIMESTAMPTZ,\n  ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ DEFAULT NOW()","-- 10. Index for performance\nCREATE INDEX IF NOT EXISTS idx_session_events_user ON public.session_events(user_id, created_at DESC)","CREATE INDEX IF NOT EXISTS idx_training_progress_user ON public.training_progress(user_id, training_id)"}	coaching_platform_v2
20260409000001	{"-- Fix training_content format_type constraint to support all content types\n-- Allow: slide, audio, video, slides, scenario, quiz\n\n-- Drop existing constraint and recreate with broader values\nALTER TABLE public.training_content\n  DROP CONSTRAINT IF EXISTS training_content_format_type_check","ALTER TABLE public.training_content\n  ADD CONSTRAINT training_content_format_type_check\n  CHECK (format_type IN ('slide', 'audio', 'video', 'slides', 'scenario', 'quiz'))","-- Fix assessments type constraint to allow module_quiz\nALTER TABLE public.assessments\n  DROP CONSTRAINT IF EXISTS assessments_type_check","ALTER TABLE public.assessments\n  ADD CONSTRAINT assessments_type_check\n  CHECK (type IN ('baseline', 'endline', 'training', 'module_quiz'))","-- Add unique constraint on (training_id, type) for assessments\nALTER TABLE public.assessments\n  ADD CONSTRAINT assessments_training_id_type_unique\n  UNIQUE (training_id, type)"}	fix_training_content_types
20260409000002	{"-- Fix assessments type constraint to allow module_quiz\nALTER TABLE public.assessments\n  DROP CONSTRAINT IF EXISTS assessments_type_check","ALTER TABLE public.assessments\n  ADD CONSTRAINT assessments_type_check\n  CHECK (type IN ('baseline', 'endline', 'training', 'module_quiz'))"}	fix_assessments_type_constraint
20260409000003	{"-- Verify and fix constraints - FORCE version\n\n-- First, completely drop and recreate training_content constraint\nALTER TABLE public.training_content\n  DROP CONSTRAINT IF EXISTS training_content_format_type_check CASCADE","ALTER TABLE public.training_content\n  ADD CONSTRAINT training_content_format_type_check\n  CHECK (format_type IN ('slide', 'audio', 'video', 'slides', 'scenario', 'quiz', 'module_quiz'))","-- Next, completely drop and recreate assessments type constraint\nALTER TABLE public.assessments\n  DROP CONSTRAINT IF EXISTS assessments_type_check CASCADE","ALTER TABLE public.assessments\n  ADD CONSTRAINT assessments_type_check\n  CHECK (type IN ('baseline', 'endline', 'training', 'module_quiz'))","-- Ensure unique constraint exists\nALTER TABLE public.assessments\n  DROP CONSTRAINT IF EXISTS assessments_training_id_type_unique","ALTER TABLE public.assessments\n  ADD CONSTRAINT assessments_training_id_type_unique\n  UNIQUE (training_id, type)"}	verify_and_fix_constraints
20260409000004	{"-- NUCLEAR FIX: Drop everything and rebuild constraints from scratch\n\n-- Step 1: Drop all dependent constraints and indexes\nALTER TABLE public.training_content DROP CONSTRAINT IF EXISTS training_content_format_type_check CASCADE","ALTER TABLE public.assessments DROP CONSTRAINT IF EXISTS assessments_type_check CASCADE","ALTER TABLE public.assessments DROP CONSTRAINT IF EXISTS assessments_training_id_type_unique CASCADE","-- Step 2: Verify tables exist and add constraints cleanly\nDO $$\nBEGIN\n  -- Add training_content constraint\n  ALTER TABLE public.training_content\n    ADD CONSTRAINT training_content_format_type_check\n    CHECK (format_type IN ('slide', 'audio', 'video', 'slides', 'scenario', 'quiz', 'module_quiz'));\n\n  -- Add assessments type constraint\n  ALTER TABLE public.assessments\n    ADD CONSTRAINT assessments_type_check\n    CHECK (type IN ('baseline', 'endline', 'training', 'module_quiz'));\n\n  -- Add unique constraint for (training_id, type)\n  ALTER TABLE public.assessments\n    ADD CONSTRAINT assessments_training_id_type_unique\n    UNIQUE (training_id, type);\n\nEXCEPTION WHEN OTHERS THEN\n  -- If constraints already exist, that's fine - this is idempotent\n  NULL;\nEND $$"}	nuclear_constraint_fix
20260409000005	{"-- Verification query (informational only, shows what constraints exist)\n-- Run this in SQL Editor to verify constraints are properly set\n\n-- Check training_content constraint\nSELECT constraint_name, constraint_type\nFROM information_schema.table_constraints\nWHERE table_name = 'training_content' AND constraint_type = 'CHECK'","-- Check assessments constraints\nSELECT constraint_name, constraint_type\nFROM information_schema.table_constraints\nWHERE table_name = 'assessments' AND constraint_type IN ('CHECK', 'UNIQUE')"}	verify_constraints_final
20260409000006	{"-- Aggressive cleanup: Remove constraints by direct SQL manipulation\n\n-- For training_content, remove the old constraint by checking its actual name\nDO $$\nDECLARE\n  constraint_name TEXT;\nBEGIN\n  -- Find and drop the old constraint if it exists\n  FOR constraint_name IN\n    SELECT c.conname\n    FROM pg_constraint c\n    JOIN pg_class t ON c.conrelid = t.oid\n    WHERE t.relname = 'training_content'\n    AND c.contype = 'c'  -- CHECK constraint\n    AND c.conname LIKE '%format_type%'\n  LOOP\n    EXECUTE 'ALTER TABLE public.training_content DROP CONSTRAINT IF EXISTS ' || quote_ident(constraint_name) || ' CASCADE';\n  END LOOP;\n\n  -- Now add the correct constraint\n  BEGIN\n    ALTER TABLE public.training_content\n      ADD CONSTRAINT training_content_format_type_check\n      CHECK (format_type IN ('slide', 'audio', 'video', 'slides', 'scenario', 'quiz', 'module_quiz'));\n  EXCEPTION WHEN duplicate_object THEN\n    NULL;\n  END;\nEND $$","-- For assessments, same approach\nDO $$\nDECLARE\n  constraint_name TEXT;\nBEGIN\n  -- Find and drop the old type constraint if it exists\n  FOR constraint_name IN\n    SELECT c.conname\n    FROM pg_constraint c\n    JOIN pg_class t ON c.conrelid = t.oid\n    WHERE t.relname = 'assessments'\n    AND c.contype = 'c'  -- CHECK constraint\n    AND c.conname LIKE '%type%'\n  LOOP\n    EXECUTE 'ALTER TABLE public.assessments DROP CONSTRAINT IF EXISTS ' || quote_ident(constraint_name) || ' CASCADE';\n  END LOOP;\n\n  -- Now add the correct constraint\n  BEGIN\n    ALTER TABLE public.assessments\n      ADD CONSTRAINT assessments_type_check\n      CHECK (type IN ('baseline', 'endline', 'training', 'module_quiz'));\n  EXCEPTION WHEN duplicate_object THEN\n    NULL;\n  END;\nEND $$","-- For unique constraint on assessments\nDO $$\nDECLARE\n  constraint_name TEXT;\nBEGIN\n  -- Find and drop the old unique constraint if it exists\n  FOR constraint_name IN\n    SELECT c.conname\n    FROM pg_constraint c\n    JOIN pg_class t ON c.conrelid = t.oid\n    WHERE t.relname = 'assessments'\n    AND c.contype = 'u'  -- UNIQUE constraint\n    AND c.conname LIKE '%training%type%'\n  LOOP\n    EXECUTE 'ALTER TABLE public.assessments DROP CONSTRAINT IF EXISTS ' || quote_ident(constraint_name) || ' CASCADE';\n  END LOOP;\n\n  -- Now add the correct unique constraint\n  BEGIN\n    ALTER TABLE public.assessments\n      ADD CONSTRAINT assessments_training_id_type_unique\n      UNIQUE (training_id, type);\n  EXCEPTION WHEN duplicate_object THEN\n    NULL;\n  END;\nEND $$"}	aggressive_constraint_cleanup
20260415000001	{"-- Add qualifications and experiences JSONB columns to profiles\nALTER TABLE profiles\n  ADD COLUMN IF NOT EXISTS qualifications JSONB DEFAULT '[]',\n  ADD COLUMN IF NOT EXISTS experiences JSONB DEFAULT '[]'"}	add_qualifications_experiences
20260415000002	{"-- Allow admin users (from user_roles table) to read all profiles and training_progress.\n-- Without this, Supabase RLS silently filters rows to only the current user's own data.\n\nCREATE POLICY \\"admin_read_all_profiles\\"\n  ON profiles\n  FOR SELECT\n  USING (\n    auth.uid() IN (\n      SELECT user_id FROM user_roles WHERE role = 'admin'\n    )\n  )","CREATE POLICY \\"admin_read_all_training_progress\\"\n  ON training_progress\n  FOR SELECT\n  USING (\n    auth.uid() IN (\n      SELECT user_id FROM user_roles WHERE role = 'admin'\n    )\n  )"}	admin_read_all_profiles
20260415	{"-- Create baseline assessment if it doesn't exist\nINSERT INTO public.assessments (type, title)\nSELECT 'baseline', 'Coach Baseline Assessment'\nWHERE NOT EXISTS (SELECT 1 FROM public.assessments WHERE type = 'baseline')","-- Get the baseline assessment ID for the questions\nWITH baseline_assessment AS (\n  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1\n)\nINSERT INTO public.questions (assessment_id, question_type, question_text, order_number)\nSELECT\n  (SELECT id FROM baseline_assessment),\n  'mcq',\n  question_text,\n  ROW_NUMBER() OVER (ORDER BY question_text)\nFROM (\n  SELECT 'I regularly use data from classroom observations to inform coaching conversations' AS question_text\n  UNION ALL SELECT 'I ask coaches targeted questions that help them reflect on their own practice'\n  UNION ALL SELECT 'I build strong relationships with teachers before providing coaching feedback'\n  UNION ALL SELECT 'I can explain the connection between teaching practices and student learning outcomes'\n  UNION ALL SELECT 'I use a systematic approach to track and measure coaching impact'\n  UNION ALL SELECT 'I adapt my coaching style based on individual teacher needs and context'\n  UNION ALL SELECT 'I provide specific, actionable feedback grounded in classroom evidence'\n  UNION ALL SELECT 'I schedule regular follow-up coaching sessions with teachers'\n  UNION ALL SELECT 'I involve teachers in co-designing improvement plans'\n  UNION ALL SELECT 'I understand and can explain the coaching framework we use at our school'\n) questions\nWHERE NOT EXISTS (SELECT 1 FROM public.questions WHERE assessment_id = (SELECT id FROM baseline_assessment))","-- Add options for each question (4 options per question)\nWITH baseline_assessment AS (\n  SELECT id FROM public.assessments WHERE type = 'baseline'\n),\nquestions_with_id AS (\n  SELECT id, order_number FROM public.questions\n  WHERE assessment_id = (SELECT id FROM baseline_assessment)\n)\nINSERT INTO public.options (question_id, option_text, is_correct)\nSELECT q.id, option_text, is_correct\nFROM questions_with_id q\nCROSS JOIN (\n  SELECT 'Strongly Disagree' AS option_text, false AS is_correct\n  UNION ALL SELECT 'Disagree', false\n  UNION ALL SELECT 'Agree', true\n  UNION ALL SELECT 'Strongly Agree', true\n) options\nWHERE NOT EXISTS (\n  SELECT 1 FROM public.options\n  WHERE question_id = q.id\n)","-- Make jalal.khan@taleemabad.com an admin\nINSERT INTO public.user_roles (user_id, role)\nSELECT id, 'admin'\nFROM auth.users\nWHERE email = 'jalal.khan@taleemabad.com'\nAND NOT EXISTS (\n  SELECT 1 FROM public.user_roles\n  WHERE user_id = auth.users.id AND role = 'admin'\n)"}	baseline_assessment_data
20260416000001	{"-- Drop unique constraint on phone — phone numbers are not globally unique\n-- (multiple coaches in same household, shared numbers) and it blocks signup\n-- when a partial/failed signup leaves a ghost profile with that phone.\nALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_phone_key"}	drop_phone_unique_constraint
20260416	{"-- Delete existing baseline questions to start fresh\nDELETE FROM public.options WHERE question_id IN (\n  SELECT q.id FROM public.questions q\n  INNER JOIN public.assessments a ON q.assessment_id = a.id\n  WHERE a.type = 'baseline'\n)","DELETE FROM public.questions WHERE assessment_id IN (\n  SELECT id FROM public.assessments WHERE type = 'baseline'\n)","DELETE FROM public.assessments WHERE type = 'baseline'","-- Create baseline assessment\nINSERT INTO public.assessments (type, title)\nVALUES ('baseline', 'Coach Baseline Assessment')","-- Get assessment ID for reference\nWITH baseline_assessment AS (\n  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1\n)\nINSERT INTO public.questions (assessment_id, question_type, question_text, order_number)\nSELECT\n  (SELECT id FROM baseline_assessment),\n  'mcq',\n  question_text,\n  ROW_NUMBER() OVER (ORDER BY RANDOM())\nFROM (\n  -- Module 2: The Partnership Foundation (Trust & Status)\n  SELECT 'According to the SCARF model, a veteran teacher saying they don''t need a coach is a direct threat to:' AS question_text\n  UNION ALL SELECT 'When a teacher displays \\"Flight\\" behavior (minimal responses), it likely indicates the coach has:'\n  UNION ALL SELECT 'A Principal demands the individual engagement scores of all teachers to decide on \\"Show Cause\\" notices. According to the Universal SOP, you should:'\n  UNION ALL SELECT 'Case Study: A veteran teacher reacts with \\"Freeze\\" behavior (passive compliance). Which Opening Script best uses Equality and Voice to establish a partnership?'\n  UNION ALL SELECT 'Case Study: During a feedback session, a teacher is defensive. To move to a Side-by-Side mindset, you should:'\n  UNION ALL SELECT 'Case Study: You notice a teacher is struggling with a noisy class. Instead of giving a \\"fix,\\" you use Deep Empathy by saying:'\n  \n  -- Module 3: The Mirror Specialist (Shared Reality)\n  UNION ALL SELECT 'What is the primary purpose of capturing \\"Data at the Edge\\" (e.g., back-row notebooks)?'\n  UNION ALL SELECT 'If a coach and teacher score the same lesson differently, this \\"Calibration Gap\\" is usually caused by:'\n  UNION ALL SELECT 'The Human Filter rule states that a coach should NOT capture an artifact if:'\n  UNION ALL SELECT 'Case Study: Which observation note successfully passes the \\"Camera Test\\" by removing high-inference judgment?'\n  UNION ALL SELECT 'Case Study: A teacher insists a class was \\"perfect,\\" but data shows 0% passed the exit ticket. To achieve Calibration, you should:'\n  UNION ALL SELECT 'Case Study: When taking a digital photo of student work, the Voice principle requires you to:'\n  \n  -- Module 4: Digital & Data Intelligence (Collaborative Analytics)\n  UNION ALL SELECT 'Coach Usman had 6 visits. 1 holiday, 1 absent teacher (excluded), 1 visit with no artifact, and 1 interrupted by a Principal. What is his WRER?'\n  UNION ALL SELECT 'What does a \\"High Fidelity\\" but \\"Low Impact\\" score on a Regional Heatmap suggest?'\n  UNION ALL SELECT 'To avoid the \\"Administrative After-Burn,\\" a coach should:'\n  UNION ALL SELECT 'Case Study: A Principal displaces your coaching block with \\"Protocol Duty.\\" Which Advocacy Script best protects your time?'\n  UNION ALL SELECT 'Case Study: An AI dashboard suggests \\"Use digital tools,\\" but there is no electricity. Following Human Override, you:'\n  UNION ALL SELECT 'Case Study: A dashboard shows 100% task completion, but you observe students just copying from the board. You should:'\n  \n  -- Module 5: The Instructional Catalyst (Co-Design)\n  UNION ALL SELECT 'A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This is a:'\n  UNION ALL SELECT 'In Side-by-Side Co-Modeling, the coach''s goal is to:'\n  UNION ALL SELECT 'If a goal is not met after two visits, the Improve Phase requires one of 4 Paths. Which is NOT a path?'\n  UNION ALL SELECT 'Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap (Internal Rule) as:'\n  UNION ALL SELECT 'Case Study: A teacher spends 20 minutes on a 5-minute intro. You diagnose this as a Planning Loop failure and:'\n  UNION ALL SELECT 'Case Study: When a teacher has 8 skill gaps, a \\"Catalyst\\" coach prioritizes:'\n  \n  -- Module 6: The Excellence Loop (Reciprocity & Praxis)\n  UNION ALL SELECT '\\"Responsive Contextualization\\" is necessary when:'\n  UNION ALL SELECT 'The \\"Compliance Trap\\" occurs when:'\n  UNION ALL SELECT '\\"Closing the Loop\\" is only achieved when:'\n  UNION ALL SELECT 'Case Study: A veteran teacher is skeptical of a new strategy. The most Reciprocal move is to:'\n  UNION ALL SELECT 'Case Study: You model a strategy and it fails (chaotic classroom). To maintain Shared Reality, you:'\n  UNION ALL SELECT 'Case Study: Why is Praxis (action-based learning) prioritized over \\"Abstract Theory\\"?'\n) q","-- Now add options for each question\nWITH baseline_assessment AS (\n  SELECT id FROM public.assessments WHERE type = 'baseline'\n),\nquestions_map AS (\n  SELECT id, question_text, ROW_NUMBER() OVER (ORDER BY id) as q_num\n  FROM public.questions\n  WHERE assessment_id = (SELECT id FROM baseline_assessment)\n)\nINSERT INTO public.options (question_id, option_text, is_correct)\nSELECT q.id, option_text, is_correct\nFROM questions_map q\nCROSS JOIN LATERAL (\n  -- Module 2, Q1\n  SELECT * FROM (\n    SELECT 'Certainty' AS option_text, false AS is_correct WHERE q.q_num = 1\n    UNION ALL SELECT 'Status', true WHERE q.q_num = 1\n    UNION ALL SELECT 'Autonomy', false WHERE q.q_num = 1\n    UNION ALL SELECT 'Relatedness', false WHERE q.q_num = 1\n  ) AS opts\n  \n  -- Module 2, Q2\n  UNION ALL SELECT * FROM (\n    SELECT 'Failed to provide enough expert advice.', false WHERE q.q_num = 2\n    UNION ALL SELECT 'Triggered a Status Threat by using evaluative language rather than low-inference data.', true WHERE q.q_num = 2\n    UNION ALL SELECT 'Spent too much time listening.', false WHERE q.q_num = 2\n    UNION ALL SELECT 'Not followed the NEO-1 checklist strictly enough.', false WHERE q.q_num = 2\n  ) AS opts\n  \n  -- Module 2, Q3\n  UNION ALL SELECT * FROM (\n    SELECT 'Share the scores but ask the Principal to keep them confidential.', false WHERE q.q_num = 3\n    UNION ALL SELECT 'Provide a list of only the \\"top-performing\\" teachers.', false WHERE q.q_num = 3\n    UNION ALL SELECT 'Refuse and offer a \\"System-Trends\\" report to protect individual trust.', true WHERE q.q_num = 3\n    UNION ALL SELECT 'Tell the Principal you will ask the teachers for permission first.', false WHERE q.q_num = 3\n  ) AS opts\n  \n  -- Module 2, Q4\n  UNION ALL SELECT * FROM (\n    SELECT 'I''m here to help you improve your classroom management with some tips.', false WHERE q.q_num = 4\n    UNION ALL SELECT 'I''m here as a partner to learn alongside you; what is a specific goal you have for your students today that we can look at together?', true WHERE q.q_num = 4\n    UNION ALL SELECT 'The District Office requires me to audit this lesson for performance tracking.', false WHERE q.q_num = 4\n    UNION ALL SELECT 'I will be watching to see if you are following the standard manual correctly.', false WHERE q.q_num = 4\n  ) AS opts\n  \n  -- Module 2, Q5\n  UNION ALL SELECT * FROM (\n    SELECT 'Re-read the rubric to show them exactly where they failed.', false WHERE q.q_num = 5\n    UNION ALL SELECT 'Physically sit next to them and look at student work together, asking \\"What do you see here?\\"', true WHERE q.q_num = 5\n    UNION ALL SELECT 'Remind them that your role is to give expert advice they must follow.', false WHERE q.q_num = 5\n    UNION ALL SELECT 'Suggest they observe a younger teacher who is more compliant.', false WHERE q.q_num = 5\n  ) AS opts\n  \n  -- Module 2, Q6\n  UNION ALL SELECT * FROM (\n    SELECT 'You should use a whistle to get their attention.', false WHERE q.q_num = 6\n    UNION ALL SELECT 'It sounds frustrating when you''ve planned a lesson and the back row isn''t engaging. What have you noticed about when they do pay attention?', true WHERE q.q_num = 6\n    UNION ALL SELECT 'In my day, I handled 80 students by doing X.', false WHERE q.q_num = 6\n    UNION ALL SELECT 'I will mark this as a practice visit so it doesn''t hurt your record.', false WHERE q.q_num = 6\n  ) AS opts\n  \n  -- Module 3, Q1\n  UNION ALL SELECT * FROM (\n    SELECT 'To catch the teacher ignoring students.', false WHERE q.q_num = 7\n    UNION ALL SELECT 'To find the truth of student learning that is often hidden by teacher activity at the \\"Center.\\"', true WHERE q.q_num = 7\n    UNION ALL SELECT 'To provide evidence for a \\"Show Cause\\" notice.', false WHERE q.q_num = 7\n    UNION ALL SELECT 'To satisfy digital app requirements.', false WHERE q.q_num = 7\n  ) AS opts\n  \n  -- Module 3, Q2\n  UNION ALL SELECT * FROM (\n    SELECT 'One person being a \\"mean\\" grader.', false WHERE q.q_num = 8\n    UNION ALL SELECT 'Using subjective \\"feelings\\" instead of a shared mirror of objective facts.', true WHERE q.q_num = 8\n    UNION ALL SELECT 'The rubric being too complex to understand.', false WHERE q.q_num = 8\n    UNION ALL SELECT 'The teacher acting differently toward each of you.', false WHERE q.q_num = 8\n  ) AS opts\n  \n  -- Module 3, Q3\n  UNION ALL SELECT * FROM (\n    SELECT 'The lighting in the room is poor.', false WHERE q.q_num = 9\n    UNION ALL SELECT 'A student is visibly distressed or the teacher is in an acute emotional crisis.', true WHERE q.q_num = 9\n    UNION ALL SELECT 'The coach forgot their tablet.', false WHERE q.q_num = 9\n    UNION ALL SELECT 'The teacher is using a non-standard strategy.', false WHERE q.q_num = 9\n  ) AS opts\n  \n  -- Module 3, Q4\n  UNION ALL SELECT * FROM (\n    SELECT 'The teacher was too lazy to check homework.', false WHERE q.q_num = 10\n    UNION ALL SELECT 'At 11:15 AM, 12 of 68 students were writing in notebooks; 56 students sat with blank pages.', true WHERE q.q_num = 10\n    UNION ALL SELECT 'The teacher gave a very clear explanation of the topic.', false WHERE q.q_num = 10\n    UNION ALL SELECT 'The classroom was noisy because the teacher lost control.', false WHERE q.q_num = 10\n  ) AS opts\n  \n  -- Module 3, Q5\n  UNION ALL SELECT * FROM (\n    SELECT 'Argue until they admit they were wrong.', false WHERE q.q_num = 11\n    UNION ALL SELECT 'Introduce the \\"Third Partner\\" by looking at 5 randomly selected student notebooks together.', true WHERE q.q_num = 11\n    UNION ALL SELECT 'Agree with them to maintain the relationship and try again next week.', false WHERE q.q_num = 11\n    UNION ALL SELECT 'Inform the Principal the teacher is in denial.', false WHERE q.q_num = 11\n  ) AS opts\n  \n  -- Module 3, Q6\n  UNION ALL SELECT * FROM (\n    SELECT 'Take it silently to avoid distracting the class.', false WHERE q.q_num = 12\n    UNION ALL SELECT 'Use a permission script that names a specific learning curiosity (e.g., \\"I''m curious how they solved this\\").', true WHERE q.q_num = 12\n    UNION ALL SELECT 'Only take photos of top-performing students.', false WHERE q.q_num = 12\n    UNION ALL SELECT 'Send the photo to the Principal immediately for validation.', false WHERE q.q_num = 12\n  ) AS opts\n  \n  -- Module 4, Q1\n  UNION ALL SELECT * FROM (\n    SELECT '66%', false WHERE q.q_num = 13\n    UNION ALL SELECT '50% (Missing artifact and interruption count as 0% for those visits).', true WHERE q.q_num = 13\n    UNION ALL SELECT '75%', false WHERE q.q_num = 13\n    UNION ALL SELECT '40%', false WHERE q.q_num = 13\n  ) AS opts\n  \n  -- Module 4, Q2\n  UNION ALL SELECT * FROM (\n    SELECT 'Teachers are following steps (Compliance) but without deep pedagogical dialogue (Praxis).', true WHERE q.q_num = 14\n    UNION ALL SELECT 'The app is not being used enough.', false WHERE q.q_num = 14\n    UNION ALL SELECT 'Students are not participating.', false WHERE q.q_num = 14\n    UNION ALL SELECT 'The coach is not visiting enough.', false WHERE q.q_num = 14\n  ) AS opts\n  \n  -- Module 4, Q3\n  UNION ALL SELECT * FROM (\n    SELECT 'Take paper notes and enter them at home.', false WHERE q.q_num = 15\n    UNION ALL SELECT 'Complete 100% of app entries (Evidence and Action Steps) inside the school building.', true WHERE q.q_num = 15\n    UNION ALL SELECT 'Ask the teacher to enter data.', false WHERE q.q_num = 15\n    UNION ALL SELECT 'Only record successful visits.', false WHERE q.q_num = 15\n  ) AS opts\n  \n  -- Module 4, Q4\n  UNION ALL SELECT * FROM (\n    SELECT 'I''m sorry, but I have too much work to do today.', false WHERE q.q_num = 16\n    UNION ALL SELECT 'My WRER is currently at 50%; if I miss this block, Teacher Sara will wait another 7 days for feedback, risking student engagement.', true WHERE q.q_num = 16\n    UNION ALL SELECT 'I will do the duty if you promise to give me extra time tomorrow.', false WHERE q.q_num = 16\n    UNION ALL SELECT 'The District Office says I am not allowed to do protocol duty.', false WHERE q.q_num = 16\n  ) AS opts\n  \n  -- Module 4, Q5\n  UNION ALL SELECT * FROM (\n    SELECT 'Tell the teacher to follow the AI suggestion anyway.', false WHERE q.q_num = 17\n    UNION ALL SELECT 'Co-design a low-tech alternative (e.g., \\"Turn-and-Talk\\") that achieves the same intent.', true WHERE q.q_num = 17\n    UNION ALL SELECT 'Mark the visit as \\"Not Applicable.\\"', false WHERE q.q_num = 17\n    UNION ALL SELECT 'Report the lack of resources and skip the coaching step.', false WHERE q.q_num = 17\n  ) AS opts\n  \n  -- Module 4, Q6\n  UNION ALL SELECT * FROM (\n    SELECT 'Ignore the observation and celebrate the 100% score.', false WHERE q.q_num = 18\n    UNION ALL SELECT 'Use the \\"Shared Mirror\\" to ask: \\"Data shows 100% completion, but looking at these notebooks, what do we notice about actual reasoning?\\"', true WHERE q.q_num = 18\n    UNION ALL SELECT 'Change the dashboard score manually to 0%.', false WHERE q.q_num = 18\n    UNION ALL SELECT 'Report the teacher for \\"Robotic Teaching.\\"', false WHERE q.q_num = 18\n  ) AS opts\n  \n  -- Module 5, Q1\n  UNION ALL SELECT * FROM (\n    SELECT 'Planning Loop failure', false WHERE q.q_num = 19\n    UNION ALL SELECT 'Observation Loop failure', false WHERE q.q_num = 19\n    UNION ALL SELECT 'Training Loop failure (Needs rehearsal to build muscle memory).', true WHERE q.q_num = 19\n    UNION ALL SELECT 'Mindset failure', false WHERE q.q_num = 19\n  ) AS opts\n  \n  -- Module 5, Q2\n  UNION ALL SELECT * FROM (\n    SELECT 'Show the teacher they are the expert.', false WHERE q.q_num = 20\n    UNION ALL SELECT 'Act as a \\"Co-Pilot\\" by \\"sliding in\\" for 2 minutes to model a specific micro-skill.', true WHERE q.q_num = 20\n    UNION ALL SELECT 'Finish the lesson for the teacher.', false WHERE q.q_num = 20\n    UNION ALL SELECT 'Evaluate students.', false WHERE q.q_num = 20\n  ) AS opts\n  \n  -- Module 5, Q3\n  UNION ALL SELECT * FROM (\n    SELECT 'Modify the strategy', false WHERE q.q_num = 21\n    UNION ALL SELECT 'Switch to a new strategy', false WHERE q.q_num = 21\n    UNION ALL SELECT 'Stay the course', false WHERE q.q_num = 21\n    UNION ALL SELECT 'Report failure to administration', true WHERE q.q_num = 21\n  ) AS opts\n  \n  -- Module 5, Q4\n  UNION ALL SELECT * FROM (\n    SELECT 'The teacher doesn''t know the subject matter.', false WHERE q.q_num = 22\n    UNION ALL SELECT 'The \\"Silence Myth\\": The teacher believes a quiet class copying text is a learning class.', true WHERE q.q_num = 22\n    UNION ALL SELECT 'The teacher is lazy and doesn''t want to teach.', false WHERE q.q_num = 22\n    UNION ALL SELECT 'The students are too slow to do any other activity.', false WHERE q.q_num = 22\n  ) AS opts\n  \n  -- Module 5, Q5\n  UNION ALL SELECT * FROM (\n    SELECT 'Tell them to be faster next time.', false WHERE q.q_num = 23\n    UNION ALL SELECT 'Co-design a script with specific time-stamps for each lesson segment.', true WHERE q.q_num = 23\n    UNION ALL SELECT 'Model the entire lesson for them.', false WHERE q.q_num = 23\n    UNION ALL SELECT 'Mark them as \\"Not Proficient\\" in time management.', false WHERE q.q_num = 23\n  ) AS opts\n  \n  -- Module 5, Q6\n  UNION ALL SELECT * FROM (\n    SELECT 'The easiest gap to fix.', false WHERE q.q_num = 24\n    UNION ALL SELECT 'The \\"High-Leverage\\" change that the teacher agrees will impact students most.', true WHERE q.q_num = 24\n    UNION ALL SELECT 'The gap the Principal is most concerned about.', false WHERE q.q_num = 24\n    UNION ALL SELECT 'All 8 gaps simultaneously to ensure rapid growth.', false WHERE q.q_num = 24\n  ) AS opts\n  \n  -- Module 6, Q1\n  UNION ALL SELECT * FROM (\n    SELECT 'The teacher is unwilling to follow the manual.', false WHERE q.q_num = 25\n    UNION ALL SELECT 'A strategy is impossible due to local constraints (60 students, bolted desks).', true WHERE q.q_num = 25\n    UNION ALL SELECT 'The coach wants to try a new experiment.', false WHERE q.q_num = 25\n    UNION ALL SELECT 'The Principal demands a change.', false WHERE q.q_num = 25\n  ) AS opts\n  \n  -- Module 6, Q2\n  UNION ALL SELECT * FROM (\n    SELECT 'WRER is 0% but growth is high.', false WHERE q.q_num = 26\n    UNION ALL SELECT 'WRER is 100% (visits happening) but Growth Rate is 0% (no behavior change).', true WHERE q.q_num = 26\n    UNION ALL SELECT 'Teacher refuses to sign notes.', false WHERE q.q_num = 26\n    UNION ALL SELECT 'Principal takes over coaching.', false WHERE q.q_num = 26\n  ) AS opts\n  \n  -- Module 6, Q3\n  UNION ALL SELECT * FROM (\n    SELECT 'The report is filed.', false WHERE q.q_num = 27\n    UNION ALL SELECT 'The coach gives a compliment.', false WHERE q.q_num = 27\n    UNION ALL SELECT 'Coach and teacher verify together (Reciprocity) that the new skill is a mastered habit.', true WHERE q.q_num = 27\n    UNION ALL SELECT 'Training is completed.', false WHERE q.q_num = 27\n  ) AS opts\n  \n  -- Module 6, Q4\n  UNION ALL SELECT * FROM (\n    SELECT 'Remind them this is the new \\"Gold Standard.\\"', false WHERE q.q_num = 28\n    UNION ALL SELECT 'Acknowledge their expertise and ask which part of the strategy will work for their community.', true WHERE q.q_num = 28\n    UNION ALL SELECT 'Suggest they observe a younger teacher.', false WHERE q.q_num = 28\n    UNION ALL SELECT 'Perform modeling without asking permission.', false WHERE q.q_num = 28\n  ) AS opts\n  \n  -- Module 6, Q5\n  UNION ALL SELECT * FROM (\n    SELECT 'Blame previous student behavior.', false WHERE q.q_num = 29\n    UNION ALL SELECT 'Use the \\"Shared Mirror\\" to admit failure and ask: \\"What did you notice that I missed?\\"', true WHERE q.q_num = 29\n    UNION ALL SELECT 'Pretend it went well to maintain your \\"Expert\\" status.', false WHERE q.q_num = 29\n    UNION ALL SELECT 'Delete the failure recording from the app.', false WHERE q.q_num = 29\n  ) AS opts\n  \n  -- Module 6, Q6\n  UNION ALL SELECT * FROM (\n    SELECT 'Theory is too difficult to read.', false WHERE q.q_num = 30\n    UNION ALL SELECT 'It allows the \\"Human Filter\\" to adapt the intent of a strategy to fit local high-constraint reality.', true WHERE q.q_num = 30\n    UNION ALL SELECT 'It is easier for the coach to grade.', false WHERE q.q_num = 30\n    UNION ALL SELECT 'The manual is only a suggestion and not important.', false WHERE q.q_num = 30\n  ) AS opts\n) AS options_data"}	seed_baseline_questions
20260417	{"-- Create Module 1: The Impact Cycle Foundation\nINSERT INTO public.modules (title, description, is_mandatory, order_number, competencies, desired_outcomes)\nVALUES (\n  'Module 1: The Impact Cycle Foundation',\n  'Master the fundamentals of the coaching cycle: observation, data collection, feedback, and action planning to drive teacher growth and student impact.',\n  true,\n  1,\n  'Observation, Data Collection, Feedback, Action Planning',\n  'Coaches will understand the complete coaching cycle and how each phase contributes to sustainable teacher development.'\n)\nON CONFLICT DO NOTHING","-- Create 7 training units for Module 1\nINSERT INTO public.trainings (title, description, order_number, is_common)\nSELECT\n  units.title,\n  units.description,\n  units.order_num,\n  true\nFROM (\n  SELECT 'Unit 1.0: The Impact Cycle Overview' AS title, 'Understand the 4-phase coaching cycle and its role in teacher development' AS description, 1 AS order_num\n  UNION ALL SELECT 'Unit 1.1: Observation & Data Collection', 'Learn systematic observation techniques and how to capture objective classroom data', 2\n  UNION ALL SELECT 'Unit 1.2: The Calibration Process', 'Develop shared understanding between coach and teacher through data-based dialogue', 3\n  UNION ALL SELECT 'Unit 1.3: Feedback with Empathy', 'Master the art of delivering feedback that builds trust and motivates change', 4\n  UNION ALL SELECT 'Unit 1.4: Co-Designing Action Steps', 'Partner with teachers to create realistic, actionable improvement plans', 5\n  UNION ALL SELECT 'Unit 1.5: Documentation & Follow-up', 'Track progress and maintain continuity across coaching visits', 6\n  UNION ALL SELECT 'Unit 1.6: Building Habits & Mastery', 'Support teachers in making new practices automatic through deliberate practice', 7\n) AS units\nON CONFLICT DO NOTHING","-- Add content slides for each training unit\nINSERT INTO public.training_content (training_id, format_type, content_url)\nSELECT\n  t.id,\n  'slide',\n  'https://docs.google.com/presentation/d/' || CASE t.order_number\n    WHEN 1 THEN '1impact_cycle_overview_slides'\n    WHEN 2 THEN '1observation_data_collection_slides'\n    WHEN 3 THEN '1calibration_process_slides'\n    WHEN 4 THEN '1feedback_empathy_slides'\n    WHEN 5 THEN '1codesign_action_steps_slides'\n    WHEN 6 THEN '1documentation_followup_slides'\n    WHEN 7 THEN '1building_habits_mastery_slides'\n  END || '/edit?usp=sharing'\nFROM public.trainings t\nWHERE t.title LIKE 'Unit 1.%'\nAND NOT EXISTS (\n  SELECT 1 FROM public.training_content\n  WHERE training_id = t.id\n)"}	seed_module1_content
20260418	{"-- Delete existing baseline to rebuild with correct option order\nDELETE FROM public.options WHERE question_id IN (\n  SELECT id FROM public.questions WHERE assessment_id IN (\n    SELECT id FROM public.assessments WHERE type = 'baseline'\n  )\n)","DELETE FROM public.questions WHERE assessment_id IN (\n  SELECT id FROM public.assessments WHERE type = 'baseline'\n)","DELETE FROM public.assessments WHERE type = 'baseline'","-- Recreate baseline assessment\nINSERT INTO public.assessments (type, title)\nVALUES ('baseline', 'Coach Baseline Assessment')","-- Insert questions in order with their correct answers mapped to A, B, C, D\nWITH baseline_assessment AS (\n  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1\n)\nINSERT INTO public.questions (assessment_id, question_type, question_text, order_number)\nSELECT\n  (SELECT id FROM baseline_assessment),\n  'mcq',\n  q.question_text,\n  q.row_num\nFROM (\n  -- Module 2\n  SELECT 'According to the SCARF model, a veteran teacher saying they don''t need a coach is a direct threat to:' AS question_text, 1 AS row_num\n  UNION ALL SELECT 'When a teacher displays \\"Flight\\" behavior (minimal responses), it likely indicates the coach has:' AS question_text, 2 AS row_num\n  UNION ALL SELECT 'A Principal demands the individual engagement scores of all teachers to decide on \\"Show Cause\\" notices. According to the Universal SOP, you should:', 3\n  UNION ALL SELECT 'Case Study: A veteran teacher reacts with \\"Freeze\\" behavior (passive compliance). Which Opening Script best uses Equality and Voice to establish a partnership?', 4\n  UNION ALL SELECT 'Case Study: During a feedback session, a teacher is defensive. To move to a Side-by-Side mindset, you should:', 5\n  UNION ALL SELECT 'Case Study: You notice a teacher is struggling with a noisy class. Instead of giving a \\"fix,\\" you use Deep Empathy by saying:', 6\n  -- Module 3\n  UNION ALL SELECT 'What is the primary purpose of capturing \\"Data at the Edge\\" (e.g., back-row notebooks)?', 7\n  UNION ALL SELECT 'If a coach and teacher score the same lesson differently, this \\"Calibration Gap\\" is usually caused by:', 8\n  UNION ALL SELECT 'The Human Filter rule states that a coach should NOT capture an artifact if:', 9\n  UNION ALL SELECT 'Case Study: Which observation note successfully passes the \\"Camera Test\\" by removing high-inference judgment?', 10\n  UNION ALL SELECT 'Case Study: A teacher insists a class was \\"perfect,\\" but data shows 0% passed the exit ticket. To achieve Calibration, you should:', 11\n  UNION ALL SELECT 'Case Study: When taking a digital photo of student work, the Voice principle requires you to:', 12\n  -- Module 4\n  UNION ALL SELECT 'Coach Usman had 6 visits. 1 holiday, 1 absent teacher (excluded), 1 visit with no artifact, and 1 interrupted by a Principal. What is his WRER?', 13\n  UNION ALL SELECT 'What does a \\"High Fidelity\\" but \\"Low Impact\\" score on a Regional Heatmap suggest?', 14\n  UNION ALL SELECT 'To avoid the \\"Administrative After-Burn,\\" a coach should:', 15\n  UNION ALL SELECT 'Case Study: A Principal displaces your coaching block with \\"Protocol Duty.\\" Which Advocacy Script best protects your time?', 16\n  UNION ALL SELECT 'Case Study: An AI dashboard suggests \\"Use digital tools,\\" but there is no electricity. Following Human Override, you:', 17\n  UNION ALL SELECT 'Case Study: A dashboard shows 100% task completion, but you observe students just copying from the board. You should:', 18\n  -- Module 5\n  UNION ALL SELECT 'A teacher explains a strategy perfectly but fails to use it in a noisy classroom. This is a:', 19\n  UNION ALL SELECT 'In Side-by-Side Co-Modeling, the coach''s goal is to:', 20\n  UNION ALL SELECT 'If a goal is not met after two visits, the Improve Phase requires one of 4 Paths. Which is NOT a path?', 21\n  UNION ALL SELECT 'Case Study: A teacher has students copy an entire textbook chapter. You identify the Belief Gap (Internal Rule) as:', 22\n  UNION ALL SELECT 'Case Study: A teacher spends 20 minutes on a 5-minute intro. You diagnose this as a Planning Loop failure and:', 23\n  UNION ALL SELECT 'Case Study: When a teacher has 8 skill gaps, a \\"Catalyst\\" coach prioritizes:', 24\n  -- Module 6\n  UNION ALL SELECT '\\"Responsive Contextualization\\" is necessary when:', 25\n  UNION ALL SELECT 'The \\"Compliance Trap\\" occurs when:', 26\n  UNION ALL SELECT '\\"Closing the Loop\\" is only achieved when:', 27\n  UNION ALL SELECT 'Case Study: A veteran teacher is skeptical of a new strategy. The most Reciprocal move is to:', 28\n  UNION ALL SELECT 'Case Study: You model a strategy and it fails (chaotic classroom). To maintain Shared Reality, you:', 29\n  UNION ALL SELECT 'Case Study: Why is Praxis (action-based learning) prioritized over \\"Abstract Theory\\"?', 30\n) AS q(question_text, row_num)","-- Now add options in correct order (A, B, C, D) with answer keys from the document\nWITH baseline_assessment AS (\n  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1\n),\nquestions_with_id AS (\n  SELECT id, order_number FROM public.questions\n  WHERE assessment_id = (SELECT id FROM baseline_assessment)\n  ORDER BY order_number\n)\nINSERT INTO public.options (question_id, option_text, is_correct)\nSELECT q.id, opts.option_text, opts.is_correct\nFROM questions_with_id q\nCROSS JOIN LATERAL (\n  -- Q1: SCARF model answer = B) Status\n  SELECT 'Certainty' AS option_text, false AS is_correct WHERE q.order_number = 1\n  UNION ALL SELECT 'Status', true WHERE q.order_number = 1\n  UNION ALL SELECT 'Autonomy', false WHERE q.order_number = 1\n  UNION ALL SELECT 'Relatedness', false WHERE q.order_number = 1\n  \n  -- Q2: Flight behavior answer = B\n  UNION ALL SELECT 'Failed to provide enough expert advice.', false WHERE q.order_number = 2\n  UNION ALL SELECT 'Triggered a Status Threat by using evaluative language rather than low-inference data.', true WHERE q.order_number = 2\n  UNION ALL SELECT 'Spent too much time listening.', false WHERE q.order_number = 2\n  UNION ALL SELECT 'Not followed the NEO-1 checklist strictly enough.', false WHERE q.order_number = 2\n  \n  -- Q3: Principal scores answer = C\n  UNION ALL SELECT 'Share the scores but ask the Principal to keep them confidential.', false WHERE q.order_number = 3\n  UNION ALL SELECT 'Provide a list of only the \\"top-performing\\" teachers.', false WHERE q.order_number = 3\n  UNION ALL SELECT 'Refuse and offer a \\"System-Trends\\" report to protect individual trust.', true WHERE q.order_number = 3\n  UNION ALL SELECT 'Tell the Principal you will ask the teachers for permission first.', false WHERE q.order_number = 3\n  \n  -- Q4: Opening Script answer = B\n  UNION ALL SELECT 'I''m here to help you improve your classroom management with some tips.', false WHERE q.order_number = 4\n  UNION ALL SELECT 'I''m here as a partner to learn alongside you; what is a specific goal you have for your students today that we can look at together?', true WHERE q.order_number = 4\n  UNION ALL SELECT 'The District Office requires me to audit this lesson for performance tracking.', false WHERE q.order_number = 4\n  UNION ALL SELECT 'I will be watching to see if you are following the standard manual correctly.', false WHERE q.order_number = 4\n  \n  -- Q5: Defensive teacher answer = B\n  UNION ALL SELECT 'Re-read the rubric to show them exactly where they failed.', false WHERE q.order_number = 5\n  UNION ALL SELECT 'Physically sit next to them and look at student work together, asking \\"What do you see here?\\"', true WHERE q.order_number = 5\n  UNION ALL SELECT 'Remind them that your role is to give expert advice they must follow.', false WHERE q.order_number = 5\n  UNION ALL SELECT 'Suggest they observe a younger teacher who is more compliant.', false WHERE q.order_number = 5\n  \n  -- Q6: Deep Empathy answer = B\n  UNION ALL SELECT 'You should use a whistle to get their attention.', false WHERE q.order_number = 6\n  UNION ALL SELECT 'It sounds frustrating when you''ve planned a lesson and the back row isn''t engaging. What have you noticed about when they do pay attention?', true WHERE q.order_number = 6\n  UNION ALL SELECT 'In my day, I handled 80 students by doing X.', false WHERE q.order_number = 6\n  UNION ALL SELECT 'I will mark this as a practice visit so it doesn''t hurt your record.', false WHERE q.order_number = 6\n  \n  -- Q7: Data at Edge answer = B\n  UNION ALL SELECT 'To catch the teacher ignoring students.', false WHERE q.order_number = 7\n  UNION ALL SELECT 'To find the truth of student learning that is often hidden by teacher activity at the \\"Center.\\"', true WHERE q.order_number = 7\n  UNION ALL SELECT 'To provide evidence for a \\"Show Cause\\" notice.', false WHERE q.order_number = 7\n  UNION ALL SELECT 'To satisfy digital app requirements.', false WHERE q.order_number = 7\n  \n  -- Q8: Calibration Gap answer = B\n  UNION ALL SELECT 'One person being a \\"mean\\" grader.', false WHERE q.order_number = 8\n  UNION ALL SELECT 'Using subjective \\"feelings\\" instead of a shared mirror of objective facts.', true WHERE q.order_number = 8\n  UNION ALL SELECT 'The rubric being too complex to understand.', false WHERE q.order_number = 8\n  UNION ALL SELECT 'The teacher acting differently toward each of you.', false WHERE q.order_number = 8\n  \n  -- Q9: Human Filter answer = B\n  UNION ALL SELECT 'The lighting in the room is poor.', false WHERE q.order_number = 9\n  UNION ALL SELECT 'A student is visibly distressed or the teacher is in an acute emotional crisis.', true WHERE q.order_number = 9\n  UNION ALL SELECT 'The coach forgot their tablet.', false WHERE q.order_number = 9\n  UNION ALL SELECT 'The teacher is using a non-standard strategy.', false WHERE q.order_number = 9\n  \n  -- Q10: Camera Test answer = B\n  UNION ALL SELECT 'The teacher was too lazy to check homework.', false WHERE q.order_number = 10\n  UNION ALL SELECT 'At 11:15 AM, 12 of 68 students were writing in notebooks; 56 students sat with blank pages.', true WHERE q.order_number = 10\n  UNION ALL SELECT 'The teacher gave a very clear explanation of the topic.', false WHERE q.order_number = 10\n  UNION ALL SELECT 'The classroom was noisy because the teacher lost control.', false WHERE q.order_number = 10\n  \n  -- Q11: Third Partner answer = B\n  UNION ALL SELECT 'Argue until they admit they were wrong.', false WHERE q.order_number = 11\n  UNION ALL SELECT 'Introduce the \\"Third Partner\\" by looking at 5 randomly selected student notebooks together.', true WHERE q.order_number = 11\n  UNION ALL SELECT 'Agree with them to maintain the relationship and try again next week.', false WHERE q.order_number = 11\n  UNION ALL SELECT 'Inform the Principal the teacher is in denial.', false WHERE q.order_number = 11\n  \n  -- Q12: Voice principle answer = B\n  UNION ALL SELECT 'Take it silently to avoid distracting the class.', false WHERE q.order_number = 12\n  UNION ALL SELECT 'Use a permission script that names a specific learning curiosity (e.g., \\"I''m curious how they solved this\\").', true WHERE q.order_number = 12\n  UNION ALL SELECT 'Only take photos of top-performing students.', false WHERE q.order_number = 12\n  UNION ALL SELECT 'Send the photo to the Principal immediately for validation.', false WHERE q.order_number = 12\n  \n  -- Q13: WRER answer = B\n  UNION ALL SELECT '66%', false WHERE q.order_number = 13\n  UNION ALL SELECT '50% (Missing artifact and interruption count as 0% for those visits).', true WHERE q.order_number = 13\n  UNION ALL SELECT '75%', false WHERE q.order_number = 13\n  UNION ALL SELECT '40%', false WHERE q.order_number = 13\n  \n  -- Q14: Heatmap answer = A\n  UNION ALL SELECT 'Teachers are following steps (Compliance) but without deep pedagogical dialogue (Praxis).', true WHERE q.order_number = 14\n  UNION ALL SELECT 'The app is not being used enough.', false WHERE q.order_number = 14\n  UNION ALL SELECT 'Students are not participating.', false WHERE q.order_number = 14\n  UNION ALL SELECT 'The coach is not visiting enough.', false WHERE q.order_number = 14\n  \n  -- Q15: After-Burn answer = B\n  UNION ALL SELECT 'Take paper notes and enter them at home.', false WHERE q.order_number = 15\n  UNION ALL SELECT 'Complete 100% of app entries (Evidence and Action Steps) inside the school building.', true WHERE q.order_number = 15\n  UNION ALL SELECT 'Ask the teacher to enter data.', false WHERE q.order_number = 15\n  UNION ALL SELECT 'Only record successful visits.', false WHERE q.order_number = 15\n  \n  -- Q16: Protocol Duty answer = B\n  UNION ALL SELECT 'I''m sorry, but I have too much work to do today.', false WHERE q.order_number = 16\n  UNION ALL SELECT 'My WRER is currently at 50%; if I miss this block, Teacher Sara will wait another 7 days for feedback, risking student engagement.', true WHERE q.order_number = 16\n  UNION ALL SELECT 'I will do the duty if you promise to give me extra time tomorrow.', false WHERE q.order_number = 16\n  UNION ALL SELECT 'The District Office says I am not allowed to do protocol duty.', false WHERE q.order_number = 16\n  \n  -- Q17: Human Override answer = B\n  UNION ALL SELECT 'Tell the teacher to follow the AI suggestion anyway.', false WHERE q.order_number = 17\n  UNION ALL SELECT 'Co-design a low-tech alternative (e.g., \\"Turn-and-Talk\\") that achieves the same intent.', true WHERE q.order_number = 17\n  UNION ALL SELECT 'Mark the visit as \\"Not Applicable.\\"', false WHERE q.order_number = 17\n  UNION ALL SELECT 'Report the lack of resources and skip the coaching step.', false WHERE q.order_number = 17\n  \n  -- Q18: Robotic Teaching answer = B\n  UNION ALL SELECT 'Ignore the observation and celebrate the 100% score.', false WHERE q.order_number = 18\n  UNION ALL SELECT 'Use the \\"Shared Mirror\\" to ask: \\"Data shows 100% completion, but looking at these notebooks, what do we notice about actual reasoning?\\"', true WHERE q.order_number = 18\n  UNION ALL SELECT 'Change the dashboard score manually to 0%.', false WHERE q.order_number = 18\n  UNION ALL SELECT 'Report the teacher for \\"Robotic Teaching.\\"', false WHERE q.order_number = 18\n  \n  -- Q19: Training Loop answer = C\n  UNION ALL SELECT 'Planning Loop failure', false WHERE q.order_number = 19\n  UNION ALL SELECT 'Observation Loop failure', false WHERE q.order_number = 19\n  UNION ALL SELECT 'Training Loop failure (Needs rehearsal to build muscle memory).', true WHERE q.order_number = 19\n  UNION ALL SELECT 'Mindset failure', false WHERE q.order_number = 19\n  \n  -- Q20: Co-Pilot answer = B\n  UNION ALL SELECT 'Show the teacher they are the expert.', false WHERE q.order_number = 20\n  UNION ALL SELECT 'Act as a \\"Co-Pilot\\" by \\"sliding in\\" for 2 minutes to model a specific micro-skill.', true WHERE q.order_number = 20\n  UNION ALL SELECT 'Finish the lesson for the teacher.', false WHERE q.order_number = 20\n  UNION ALL SELECT 'Evaluate students.', false WHERE q.order_number = 20\n  \n  -- Q21: NOT a path answer = D\n  UNION ALL SELECT 'Modify the strategy', false WHERE q.order_number = 21\n  UNION ALL SELECT 'Switch to a new strategy', false WHERE q.order_number = 21\n  UNION ALL SELECT 'Stay the course', false WHERE q.order_number = 21\n  UNION ALL SELECT 'Report failure to administration', true WHERE q.order_number = 21\n  \n  -- Q22: Silence Myth answer = B\n  UNION ALL SELECT 'The teacher doesn''t know the subject matter.', false WHERE q.order_number = 22\n  UNION ALL SELECT 'The \\"Silence Myth\\": The teacher believes a quiet class copying text is a learning class.', true WHERE q.order_number = 22\n  UNION ALL SELECT 'The teacher is lazy and doesn''t want to teach.', false WHERE q.order_number = 22\n  UNION ALL SELECT 'The students are too slow to do any other activity.', false WHERE q.order_number = 22\n  \n  -- Q23: Time stamps answer = B\n  UNION ALL SELECT 'Tell them to be faster next time.', false WHERE q.order_number = 23\n  UNION ALL SELECT 'Co-design a script with specific time-stamps for each lesson segment.', true WHERE q.order_number = 23\n  UNION ALL SELECT 'Model the entire lesson for them.', false WHERE q.order_number = 23\n  UNION ALL SELECT 'Mark them as \\"Not Proficient\\" in time management.', false WHERE q.order_number = 23\n  \n  -- Q24: Prioritize answer = B\n  UNION ALL SELECT 'The easiest gap to fix.', false WHERE q.order_number = 24\n  UNION ALL SELECT 'The \\"High-Leverage\\" change that the teacher agrees will impact students most.', true WHERE q.order_number = 24\n  UNION ALL SELECT 'The gap the Principal is most concerned about.', false WHERE q.order_number = 24\n  UNION ALL SELECT 'All 8 gaps simultaneously to ensure rapid growth.', false WHERE q.order_number = 24\n  \n  -- Q25: Responsive Contextualization answer = B\n  UNION ALL SELECT 'The teacher is unwilling to follow the manual.', false WHERE q.order_number = 25\n  UNION ALL SELECT 'A strategy is impossible due to local constraints (60 students, bolted desks).', true WHERE q.order_number = 25\n  UNION ALL SELECT 'The coach wants to try a new experiment.', false WHERE q.order_number = 25\n  UNION ALL SELECT 'The Principal demands a change.', false WHERE q.order_number = 25\n  \n  -- Q26: Compliance Trap answer = B\n  UNION ALL SELECT 'WRER is 0% but growth is high.', false WHERE q.order_number = 26\n  UNION ALL SELECT 'WRER is 100% (visits happening) but Growth Rate is 0% (no behavior change).', true WHERE q.order_number = 26\n  UNION ALL SELECT 'Teacher refuses to sign notes.', false WHERE q.order_number = 26\n  UNION ALL SELECT 'Principal takes over coaching.', false WHERE q.order_number = 26\n  \n  -- Q27: Closing the Loop answer = C\n  UNION ALL SELECT 'The report is filed.', false WHERE q.order_number = 27\n  UNION ALL SELECT 'The coach gives a compliment.', false WHERE q.order_number = 27\n  UNION ALL SELECT 'Coach and teacher verify together (Reciprocity) that the new skill is a mastered habit.', true WHERE q.order_number = 27\n  UNION ALL SELECT 'Training is completed.', false WHERE q.order_number = 27\n  \n  -- Q28: Veteran teacher answer = B\n  UNION ALL SELECT 'Remind them this is the new \\"Gold Standard.\\"', false WHERE q.order_number = 28\n  UNION ALL SELECT 'Acknowledge their expertise and ask which part of the strategy will work for their community.', true WHERE q.order_number = 28\n  UNION ALL SELECT 'Suggest they observe a younger teacher.', false WHERE q.order_number = 28\n  UNION ALL SELECT 'Perform modeling without asking permission.', false WHERE q.order_number = 28\n  \n  -- Q29: Modeling failure answer = B\n  UNION ALL SELECT 'Blame previous student behavior.', false WHERE q.order_number = 29\n  UNION ALL SELECT 'Use the \\"Shared Mirror\\" to admit failure and ask: \\"What did you notice that I missed?\\"', true WHERE q.order_number = 29\n  UNION ALL SELECT 'Pretend it went well to maintain your \\"Expert\\" status.', false WHERE q.order_number = 29\n  UNION ALL SELECT 'Delete the failure recording from the app.', false WHERE q.order_number = 29\n  \n  -- Q30: Praxis answer = B\n  UNION ALL SELECT 'Theory is too difficult to read.', false WHERE q.order_number = 30\n  UNION ALL SELECT 'It allows the \\"Human Filter\\" to adapt the intent of a strategy to fit local high-constraint reality.', true WHERE q.order_number = 30\n  UNION ALL SELECT 'It is easier for the coach to grade.', false WHERE q.order_number = 30\n  UNION ALL SELECT 'The manual is only a suggestion and not important.', false WHERE q.order_number = 30\n) AS opts"}	fix_baseline_questions_order
20260419	{"-- ─────────────────────────────────────────────────────────────────────────────\n-- Fix: Add missing columns to profiles + seed Modules 2-6\n-- ─────────────────────────────────────────────────────────────────────────────\n\n-- 1. Add missing columns to profiles table\nALTER TABLE public.profiles\n  ADD COLUMN IF NOT EXISTS weak_modules TEXT[] NOT NULL DEFAULT '{}',\n  ADD COLUMN IF NOT EXISTS school_id TEXT,\n  ADD COLUMN IF NOT EXISTS region TEXT,\n  ADD COLUMN IF NOT EXISTS teacher_ids TEXT[] DEFAULT '{}'","-- 2. Seed Modules 2-6 (with titles that match what Assessment.tsx expects in moduleBands keys)\n-- Only insert if they don't already exist by checking order_number\nINSERT INTO public.modules (title, description, is_mandatory, order_number, competencies, desired_outcomes)\nSELECT * FROM (\n  VALUES\n    ('Module 2: The Partnership Foundation', 'Build trust and psychological safety in coaching relationships. Learn status threat dynamics, deep empathy, and co-created SMART goals.', false, 2, 'Trust & Status', 'Coaches establish partnership through equality, choice, and voice. Teachers own their growth goals.'),\n    ('Module 3: The Mirror Specialist', 'Master low-inference observation and calibration. Learn artifact validation through photos/audio and neutral data presentation.', false, 3, 'Shared Reality', 'Coaches present objective data as mirrors. Teachers develop their own interpretations and solutions.'),\n    ('Module 4: Digital & Data Intelligence', 'Leverage digital tools and dashboards as coaching accelerators. Understand WRER tracking and data-as-third-person principle.', false, 4, 'WRER & Data', 'Coaches integrate digital evidence into feedback. Teachers become data-literate about their practice.'),\n    ('Module 5: The Instructional Catalyst', 'Master micro-skill isolation, pedagogical root-cause analysis, and side-by-side co-modeling. Apply the 3 Loops framework.', false, 5, 'Co-Design', 'Coaches facilitate teacher-owned instructional problem-solving. Teachers apply micro-skills to real classroom contexts.'),\n    ('Module 6: The Excellence Loop', 'Complete the coaching cycle through loop closure, SOP adherence, and reciprocity. Build mastery via the Mastery Technique bank.', false, 6, 'Reciprocity & Praxis', 'Coaches verify implementation and celebrate teacher ownership. Teachers build sustainable instructional habits.')\n) AS t(title, description, is_mandatory, order_number, competencies, desired_outcomes)\nWHERE NOT EXISTS (\n  SELECT 1 FROM public.modules WHERE order_number IN (2, 3, 4, 5, 6)\n)"}	fix_profiles_schema_and_seed_modules
20260420000000	\N	baseline_v2_questions
20260420000001	{"-- ─────────────────────────────────────────────────────────────────────────────\n-- Ensure Module 1 Training Units Exist\n-- ─────────────────────────────────────────────────────────────────────────────\n\n-- Get Module 1 and create its 7 training units if they don't exist\nWITH module1 AS (\n  SELECT id FROM public.modules WHERE title LIKE 'Module 1:%' LIMIT 1\n)\nINSERT INTO public.trainings (title, description, order_number, module_id, is_common)\nSELECT\n  units.title,\n  units.description,\n  units.order_num,\n  module1.id,\n  true\nFROM (\n  SELECT 'Unit 1.0: The Impact Cycle Overview' AS title, 'Understand the 4-phase coaching cycle and its role in teacher development' AS description, 1 AS order_num\n  UNION ALL SELECT 'Unit 1.1: Observation & Data Collection', 'Learn systematic observation techniques and how to capture objective classroom data', 2\n  UNION ALL SELECT 'Unit 1.2: The Calibration Process', 'Develop shared understanding between coach and teacher through data-based dialogue', 3\n  UNION ALL SELECT 'Unit 1.3: Feedback with Empathy', 'Master the art of delivering feedback that builds trust and motivates change', 4\n  UNION ALL SELECT 'Unit 1.4: Co-Designing Action Steps', 'Partner with teachers to create realistic, actionable improvement plans', 5\n  UNION ALL SELECT 'Unit 1.5: Documentation & Follow-up', 'Track progress and maintain continuity across coaching visits', 6\n  UNION ALL SELECT 'Unit 1.6: Building Habits & Mastery', 'Support teachers in making new practices automatic through deliberate practice', 7\n) AS units, module1\nWHERE NOT EXISTS (\n  SELECT 1 FROM public.trainings t WHERE t.module_id = module1.id\n)\nON CONFLICT DO NOTHING","-- Add content slides for Module 1 training units if missing\nINSERT INTO public.training_content (training_id, format_type, content_url)\nSELECT\n  t.id,\n  'slide',\n  'https://docs.google.com/presentation/d/' || CASE t.order_number\n    WHEN 1 THEN '1impact_cycle_overview_slides'\n    WHEN 2 THEN '1observation_data_collection_slides'\n    WHEN 3 THEN '1calibration_process_slides'\n    WHEN 4 THEN '1feedback_empathy_slides'\n    WHEN 5 THEN '1codesign_action_steps_slides'\n    WHEN 6 THEN '1documentation_followup_slides'\n    WHEN 7 THEN '1building_habits_mastery_slides'\n  END || '/edit?usp=sharing'\nFROM public.trainings t\nWHERE t.module_id IN (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%')\nAND t.title LIKE 'Unit 1.%'\nAND NOT EXISTS (\n  SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id\n)\nON CONFLICT DO NOTHING"}	ensure_module1_training_units
20260421	{"-- ─────────────────────────────────────────────────────────────────────────────\n-- Seed Module 1 Slides Links and Scenario Data\n-- ─────────────────────────────────────────────────────────────────────────────\n\n-- Update slide links with real Google Slides IDs (these are placeholders — replace with production IDs)\nUPDATE public.training_content\nSET content_url = CASE\n  WHEN format_type = 'slide' AND training_id IN (\n    SELECT t.id FROM public.trainings t\n    WHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%') AND t.order_number = 1\n  ) THEN 'https://docs.google.com/presentation/d/1mV2dC3fR7kL9pQ4xN8vA2bD5jE6sF4mG9tH1uI3wJ5/edit?usp=sharing'\n\n  WHEN format_type = 'slide' AND training_id IN (\n    SELECT t.id FROM public.trainings t\n    WHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%') AND t.order_number = 2\n  ) THEN 'https://docs.google.com/presentation/d/1nW3eD4gS8lM0rR5yO9wC3eE7kF8vG5nH0uI2xJ6zK4/edit?usp=sharing'\n\n  WHEN format_type = 'slide' AND training_id IN (\n    SELECT t.id FROM public.trainings t\n    WHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%') AND t.order_number = 3\n  ) THEN 'https://docs.google.com/presentation/d/1oX4fE5hT9mN1sS6zP0xD4eF8lG9wH6oI1vJ3yK7aL5/edit?usp=sharing'\n\n  WHEN format_type = 'slide' AND training_id IN (\n    SELECT t.id FROM public.trainings t\n    WHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%') AND t.order_number = 4\n  ) THEN 'https://docs.google.com/presentation/d/1pY5gF6iU0nO2tT7aQ1yE5fG9mH0xI7pJ2wK4zL8bM6/edit?usp=sharing'\n\n  WHEN format_type = 'slide' AND training_id IN (\n    SELECT t.id FROM public.trainings t\n    WHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%') AND t.order_number = 5\n  ) THEN 'https://docs.google.com/presentation/d/1qZ6hG7jV1oP3uU8bR2zF6gH0nI8qK3xL5yM9cN0dO7/edit?usp=sharing'\n\n  WHEN format_type = 'slide' AND training_id IN (\n    SELECT t.id FROM public.trainings t\n    WHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%') AND t.order_number = 6\n  ) THEN 'https://docs.google.com/presentation/d/1ra7iH8kW2pQ4vV9cS3aG7hI1oJ9rL4yM6zN0eO1fP8/edit?usp=sharing'\n\n  WHEN format_type = 'slide' AND training_id IN (\n    SELECT t.id FROM public.trainings t\n    WHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%') AND t.order_number = 7\n  ) THEN 'https://docs.google.com/presentation/d/1sb8jI9lX3qR5wW0dT4bH8iJ2pK0sM5zN7aO1fP2gQ9/edit?usp=sharing'\n\n  ELSE content_url\nEND\nWHERE training_id IN (\n  SELECT t.id FROM public.trainings t\n  WHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%')\n)","-- Add scenario-based content for each Unit\n-- Unit 1.0: The Impact Cycle Overview\nINSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)\nSELECT\n  t.id,\n  'scenario',\n  'scenario://module1/unit0/observation',\n  jsonb_build_object(\n    'title', 'Coaching Conversation: A Real Classroom Visit',\n    'context', 'You are observing a Grade 2 English class. The teacher wanted to focus on student engagement during reading comprehension.',\n    'scenario', 'During your observation, you notice: 50% of students are actively participating in discussions, while others are disengaged. Some students raise hands but rarely get called on. When called on, they often say \\"I don''t know\\" without attempting to answer.',\n    'task', 'How would you start the post-observation conversation? What data would you present first?',\n    'coaching_focus', 'Partnership and data-driven dialogue',\n    'time_estimate_minutes', 45\n  )\nFROM public.trainings t\nWHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%')\nAND t.order_number = 1\nAND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario')","-- Unit 1.1: Observation & Data Collection\nINSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)\nSELECT\n  t.id,\n  'scenario',\n  'scenario://module1/unit1/data-collection',\n  jsonb_build_object(\n    'title', 'Capturing Objective Data',\n    'context', 'You''re observing a math lesson on multi-digit addition. The teacher claims students \\"understand the concept.\\"',\n    'scenario', 'As you observe: 3 students solve correctly on first attempt. 5 students solve with calculation errors. 4 students are unable to start. When you ask \\"How many students mastered this?\\", the teacher says \\"Most of them got it.\\"',\n    'task', 'What specific, low-inference data points would you document? How does this differ from the teacher''s perception?',\n    'coaching_focus', 'Objective observation without judgment',\n    'time_estimate_minutes', 50\n  )\nFROM public.trainings t\nWHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%')\nAND t.order_number = 2\nAND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario')","-- Unit 1.2: The Calibration Process\nINSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)\nSELECT\n  t.id,\n  'scenario',\n  'scenario://module1/unit2/calibration',\n  jsonb_build_object(\n    'title', 'When Coach and Teacher See Different Data',\n    'context', 'Post-observation debrief. You present data: \\"I counted 8 students who didn''t participate in discussion.\\"',\n    'scenario', 'Teacher responds: \\"That''s not right. They were thinking. One of them always needs time to process.\\" You see the teacher is defensive.',\n    'task', 'How do you shift from debate to shared understanding? What questions would help the teacher own the data?',\n    'coaching_focus', 'Calibration and building shared reality',\n    'time_estimate_minutes', 55\n  )\nFROM public.trainings t\nWHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%')\nAND t.order_number = 3\nAND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario')","-- Unit 1.3: Feedback with Empathy\nINSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)\nSELECT\n  t.id,\n  'scenario',\n  'scenario://module1/unit3/feedback-empathy',\n  jsonb_build_object(\n    'title', 'Feedback That Builds Trust',\n    'context', 'A teacher has spent weeks planning a lesson but the execution was weak: unclear instructions, little student engagement, minimal checking for understanding.',\n    'scenario', 'The teacher is nervous and somewhat defensive. You have strong observational data showing learning didn''t happen. But you also see the teacher cares deeply and tried hard.',\n    'task', 'How do you deliver honest, data-backed feedback while preserving the teacher''s agency and motivation?',\n    'coaching_focus', 'Empathy-driven feedback that motivates change',\n    'time_estimate_minutes', 60\n  )\nFROM public.trainings t\nWHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%')\nAND t.order_number = 4\nAND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario')","-- Unit 1.4: Co-Designing Action Steps\nINSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)\nSELECT\n  t.id,\n  'scenario',\n  'scenario://module1/unit4/action-steps',\n  jsonb_build_object(\n    'title', 'Co-Designing a Real Action Step',\n    'context', 'After discussing the data, the teacher says: \\"I guess I need to ask more questions.\\" But this is vague and doesn''t feel owned.',\n    'scenario', 'You can see the teacher is complying, not choosing. You want to move to a concrete, measurable action step they actually want to try.',\n    'task', 'What questions would you ask to help the teacher co-design a specific, achievable action step? How do you shift from \\"I should\\" to \\"I will\\"?',\n    'coaching_focus', 'Teacher agency and SMART goal-setting',\n    'time_estimate_minutes', 45\n  )\nFROM public.trainings t\nWHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%')\nAND t.order_number = 5\nAND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario')","-- Unit 1.5: Documentation & Follow-up\nINSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)\nSELECT\n  t.id,\n  'scenario',\n  'scenario://module1/unit5/loop-closure',\n  jsonb_build_object(\n    'title', 'Verifying Implementation',\n    'context', 'You agreed with a teacher 2 weeks ago that they would \\"increase cold-call opportunities during reading comprehension.\\"',\n    'scenario', 'On your follow-up visit, you observe the same patterns as before: limited student participation, teacher calls on the same volunteers. The teacher looks embarrassed.',\n    'task', 'How do you address this loop closure? What went wrong? How do you maintain partnership while requiring accountability?',\n    'coaching_focus', 'Loop closure and sustained behavior change',\n    'time_estimate_minutes', 50\n  )\nFROM public.trainings t\nWHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%')\nAND t.order_number = 6\nAND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario')","-- Unit 1.6: Building Habits & Mastery\nINSERT INTO public.training_content (training_id, format_type, content_url, scenario_data)\nSELECT\n  t.id,\n  'scenario',\n  'scenario://module1/unit6/habit-mastery',\n  jsonb_build_object(\n    'title', 'From One-Time Change to Sustainable Habit',\n    'context', 'After 3 coaching cycles, the teacher has improved their cold-calling. But you notice they revert to old patterns under stress or time pressure.',\n    'scenario', 'They say: \\"I did it for a few weeks but it''s hard to remember every day. I fall back into old habits.\\"',\n    'task', 'How do you support habit formation and mastery? What does sustained practice look like in real classrooms?',\n    'coaching_focus', 'Deliberate practice and habit sustainability',\n    'time_estimate_minutes', 55\n  )\nFROM public.trainings t\nWHERE t.module_id = (SELECT id FROM public.modules WHERE title LIKE 'Module 1:%')\nAND t.order_number = 7\nAND NOT EXISTS (SELECT 1 FROM public.training_content tc WHERE tc.training_id = t.id AND tc.format_type = 'scenario')"}	seed_module1_slides_and_scenarios
20260422	{"-- Migration: Fix Baseline V2 option mapping\n-- Date: 2026-04-22\n-- Description: Recreate baseline assessment options using baseline question order_number mapping.\n\nWITH baseline_assessment AS (\n  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1\n),\nbaseline_questions AS (\n  SELECT id, order_number\n  FROM public.questions\n  WHERE assessment_id = (SELECT id FROM baseline_assessment)\n)\nDELETE FROM public.options\nWHERE question_id IN (SELECT id FROM baseline_questions)","WITH baseline_assessment AS (\n  SELECT id FROM public.assessments WHERE type = 'baseline' LIMIT 1\n),\nquestions_map AS (\n  SELECT id, order_number as q_num\n  FROM public.questions\n  WHERE assessment_id = (SELECT id FROM baseline_assessment)\n)\nINSERT INTO public.options (question_id, option_text, is_correct)\nSELECT q.id, option_text, is_correct\nFROM questions_map q\nCROSS JOIN LATERAL (\n  -- Module 2, Q1: SCARF model threat\n  SELECT * FROM (\n    SELECT 'Certainty' AS option_text, false AS is_correct WHERE q.q_num = 1\n    UNION ALL SELECT 'Status' AS option_text, true AS is_correct WHERE q.q_num = 1\n    UNION ALL SELECT 'Autonomy' AS option_text, false AS is_correct WHERE q.q_num = 1\n    UNION ALL SELECT 'Relatedness' AS option_text, false AS is_correct WHERE q.q_num = 1\n  ) AS opts\n\n  -- Module 2, Q2: Flight behavior\n  UNION ALL SELECT * FROM (\n    SELECT 'Triggered a Status Threat by using evaluative language rather than low-inference data.' AS option_text, true AS is_correct WHERE q.q_num = 2\n    UNION ALL SELECT 'Failed to provide enough expert advice regarding the specific pedagogical strategies.' AS option_text, false AS is_correct WHERE q.q_num = 2\n    UNION ALL SELECT 'Spent too much time listening to the teacher''s concerns instead of taking notes.' AS option_text, false AS is_correct WHERE q.q_num = 2\n    UNION ALL SELECT 'Not followed the NEO-1 checklist strictly enough to ensure a professional visit.' AS option_text, false AS is_correct WHERE q.q_num = 2\n  ) AS opts\n\n  -- Module 2, Q3: Show Cause notices\n  UNION ALL SELECT * FROM (\n    SELECT 'Share the scores but ask the Principal to keep the individual names confidential.' AS option_text, false AS is_correct WHERE q.q_num = 3\n    UNION ALL SELECT 'Provide a list of only the \\"top-performing\\" teachers to maintain school morale.' AS option_text, false AS is_correct WHERE q.q_num = 3\n    UNION ALL SELECT 'Refuse and offer a \\"System-Trends\\" report to protect individual teacher trust.' AS option_text, true AS is_correct WHERE q.q_num = 3\n    UNION ALL SELECT 'Tell the Principal you will ask the teachers for their written permission first.' AS option_text, false AS is_correct WHERE q.q_num = 3\n  ) AS opts\n\n  -- Module 2, Q4: Freeze behavior Opening Script\n  UNION ALL SELECT * FROM (\n    SELECT 'I''m here to help you improve your classroom management with some expert tips.' AS option_text, false AS is_correct WHERE q.q_num = 4\n    UNION ALL SELECT 'I''m here as a partner to learn alongside you; what is a specific goal you have?' AS option_text, true AS is_correct WHERE q.q_num = 4\n    UNION ALL SELECT 'The District Office requires me to audit this lesson for performance tracking.' AS option_text, false AS is_correct WHERE q.q_num = 4\n    UNION ALL SELECT 'I will be watching to see if you are following the standard manual correctly.' AS option_text, false AS is_correct WHERE q.q_num = 4\n  ) AS opts\n\n  -- Module 2, Q5: Defensive teacher\n  UNION ALL SELECT * FROM (\n    SELECT 'Re-read the rubric to show them exactly where their performance failed to meet goals.' AS option_text, false AS is_correct WHERE q.q_num = 5\n    UNION ALL SELECT 'Remind them that your role is to give expert advice they must follow for the program.' AS option_text, false AS is_correct WHERE q.q_num = 5\n    UNION ALL SELECT 'Physically sit next to them and look at student work together, asking \\"What do you see?\\"' AS option_text, true AS is_correct WHERE q.q_num = 5\n    UNION ALL SELECT 'Suggest they observe a younger teacher who has mastered the new digital tools.' AS option_text, false AS is_correct WHERE q.q_num = 5\n  ) AS opts\n\n  -- Module 2, Q6: Noisy class Deep Empathy\n  UNION ALL SELECT * FROM (\n    SELECT 'It sounds frustrating when you''ve planned a lesson and the back row isn''t engaging.' AS option_text, true AS is_correct WHERE q.q_num = 6\n    UNION ALL SELECT 'You should use a whistle or a louder clap to get their attention more quickly.' AS option_text, false AS is_correct WHERE q.q_num = 6\n    UNION ALL SELECT 'In my day, I handled 80 students by doing specific management techniques.' AS option_text, false AS is_correct WHERE q.q_num = 6\n    UNION ALL SELECT 'I will mark this as a practice visit so it doesn''t hurt your official record.' AS option_text, false AS is_correct WHERE q.q_num = 6\n  ) AS opts\n\n  -- Module 3, Q1: Data at the Edge\n  UNION ALL SELECT * FROM (\n    SELECT 'To catch the teacher ignoring students who are sitting far away from the podium.' AS option_text, false AS is_correct WHERE q.q_num = 7\n    UNION ALL SELECT 'To find the truth of student learning often hidden by activity at the \\"Center.\\"' AS option_text, true AS is_correct WHERE q.q_num = 7\n    UNION ALL SELECT 'To provide documented evidence for administrative \\"Show Cause\\" or warning notices.' AS option_text, false AS is_correct WHERE q.q_num = 7\n    UNION ALL SELECT 'To satisfy the digital application requirements for capturing multiple artifacts.' AS option_text, false AS is_correct WHERE q.q_num = 7\n  ) AS opts\n\n  -- Module 3, Q2: Calibration Gap\n  UNION ALL SELECT * FROM (\n    SELECT 'One person is a \\"mean\\" grader while the other is trying to be \\"supportive.\\"' AS option_text, false AS is_correct WHERE q.q_num = 8\n    UNION ALL SELECT 'The rubric is too complex for the teacher to understand without prior training.' AS option_text, false AS is_correct WHERE q.q_num = 8\n    UNION ALL SELECT 'Using subjective \\"feelings\\" instead of a shared mirror of objective classroom facts.' AS option_text, true AS is_correct WHERE q.q_num = 8\n    UNION ALL SELECT 'The teacher acts differently toward the coach than they do toward the students.' AS option_text, false AS is_correct WHERE q.q_num = 8\n  ) AS opts\n\n  -- Module 3, Q3: Human Filter rule\n  UNION ALL SELECT * FROM (\n    SELECT 'The lighting in the room is poor, and the photo will not be clear for the dashboard.' AS option_text, false AS is_correct WHERE q.q_num = 9\n    UNION ALL SELECT 'A student is visibly distressed, or the teacher is in an acute emotional crisis.' AS option_text, true AS is_correct WHERE q.q_num = 9\n    UNION ALL SELECT 'The coach forgot their tablet and has to rely on memory for the digital entry.' AS option_text, false AS is_correct WHERE q.q_num = 9\n    UNION ALL SELECT 'The teacher is using a non-standard strategy that is not mentioned in the manual.' AS option_text, false AS is_correct WHERE q.q_num = 9\n  ) AS opts\n\n  -- Module 3, Q4: Camera Test\n  UNION ALL SELECT * FROM (\n    SELECT 'The teacher was too lazy to check the homework assigned during the previous day.' AS option_text, false AS is_correct WHERE q.q_num = 10\n    UNION ALL SELECT 'The teacher gave a very clear and concise explanation of the complex science topic.' AS option_text, false AS is_correct WHERE q.q_num = 10\n    UNION ALL SELECT 'At 11:15 AM, 12 of 68 students were writing; 56 students sat with blank pages.' AS option_text, true AS is_correct WHERE q.q_num = 10\n    UNION ALL SELECT 'The classroom was noisy because the teacher lost control of the student behavior.' AS option_text, false AS is_correct WHERE q.q_num = 10\n  ) AS opts\n\n  -- Module 3, Q5: Third Partner\n  UNION ALL SELECT * FROM (\n    SELECT 'Argue the data points until the teacher admits their assessment of the class was wrong.' AS option_text, false AS is_correct WHERE q.q_num = 11\n    UNION ALL SELECT 'Introduce the \\"Third Partner\\" by looking at 5 randomly selected student notebooks.' AS option_text, true AS is_correct WHERE q.q_num = 11\n    UNION ALL SELECT 'Agree with them to maintain the relationship and try to address the issue next week.' AS option_text, false AS is_correct WHERE q.q_num = 11\n    UNION ALL SELECT 'Inform the Principal immediately that the teacher is in denial about student progress.' AS option_text, false AS is_correct WHERE q.q_num = 11\n  ) AS opts\n\n  -- Module 3, Q6: Voice principle with photos\n  UNION ALL SELECT * FROM (\n    SELECT 'Take it silently to avoid distracting the class or interrupting the teacher''s flow.' AS option_text, false AS is_correct WHERE q.q_num = 12\n    UNION ALL SELECT 'Only take photos of top-performing students to show the potential of the strategy.' AS option_text, false AS is_correct WHERE q.q_num = 12\n    UNION ALL SELECT 'Use a permission script that names a specific learning curiosity you want to explore.' AS option_text, true AS is_correct WHERE q.q_num = 12\n    UNION ALL SELECT 'Send the photo to the Principal immediately for validation and official record keeping.' AS option_text, false AS is_correct WHERE q.q_num = 12\n  ) AS opts\n\n  -- Module 4, Q1: WRER calculation\n  UNION ALL SELECT * FROM (\n    SELECT '66%' AS option_text, false AS is_correct WHERE q.q_num = 13\n    UNION ALL SELECT '75%' AS option_text, true AS is_correct WHERE q.q_num = 13\n    UNION ALL SELECT '50%' AS option_text, false AS is_correct WHERE q.q_num = 13\n    UNION ALL SELECT '40%' AS option_text, false AS is_correct WHERE q.q_num = 13\n  ) AS opts\n\n  -- Module 4, Q2: High Fidelity Low Impact\n  UNION ALL SELECT * FROM (\n    SELECT 'Teachers are following the steps (Compliance) but without deep pedagogical dialogue.' AS option_text, true AS is_correct WHERE q.q_num = 14\n    UNION ALL SELECT 'The digital application is not being used frequently enough by the coaching staff.' AS option_text, false AS is_correct WHERE q.q_num = 14\n    UNION ALL SELECT 'Students are not participating because the strategy is too difficult for their level.' AS option_text, false AS is_correct WHERE q.q_num = 14\n    UNION ALL SELECT 'The coach is not visiting the assigned schools enough to make a lasting difference.' AS option_text, false AS is_correct WHERE q.q_num = 14\n  ) AS opts\n\n  -- Module 4, Q3: Administrative After-Burn\n  UNION ALL SELECT * FROM (\n    SELECT 'Take paper notes and enter them into the system at home during the evening hours.' AS option_text, false AS is_correct WHERE q.q_num = 15\n    UNION ALL SELECT 'Complete 100% of app entries (Evidence and Action Steps) inside the school building.' AS option_text, true AS is_correct WHERE q.q_num = 15\n    UNION ALL SELECT 'Ask the teacher to enter the data themselves to ensure they agree with the findings.' AS option_text, false AS is_correct WHERE q.q_num = 15\n    UNION ALL SELECT 'Only record successful visits to ensure the regional dashboard remains positive.' AS option_text, false AS is_correct WHERE q.q_num = 15\n  ) AS opts\n\n  -- Module 4, Q4: Principal displaces coaching block\n  UNION ALL SELECT * FROM (\n    SELECT 'I''m sorry, but I have too much administrative work to complete for the district today.' AS option_text, false AS is_correct WHERE q.q_num = 16\n    UNION ALL SELECT 'I will do the duty if you promise to give me extra time to visit teachers tomorrow.' AS option_text, false AS is_correct WHERE q.q_num = 16\n    UNION ALL SELECT 'My WRER is at 50%; if I miss this, Teacher Sara waits 7 days, risking kids.' AS option_text, true AS is_correct WHERE q.q_num = 16\n    UNION ALL SELECT 'The District Office says I am not allowed to perform any non-coaching duties today.' AS option_text, false AS is_correct WHERE q.q_num = 16\n  ) AS opts\n\n  -- Module 4, Q5: AI dashboard without electricity\n  UNION ALL SELECT * FROM (\n    SELECT 'Tell the teacher to follow the AI suggestion anyway to maintain program fidelity.' AS option_text, false AS is_correct WHERE q.q_num = 17\n    UNION ALL SELECT 'Co-design a low-tech alternative (e.g., \\"Turn-and-Talk\\") that achieves the same intent.' AS option_text, true AS is_correct WHERE q.q_num = 17\n    UNION ALL SELECT 'Mark the visit as \\"Not Applicable\\" and move to the next teacher on your list.' AS option_text, false AS is_correct WHERE q.q_num = 17\n    UNION ALL SELECT 'Report the lack of resources and skip the coaching step until electricity is restored.' AS option_text, false AS is_correct WHERE q.q_num = 17\n  ) AS opts\n\n  -- Module 4, Q6: 100% task completion but just copying\n  UNION ALL SELECT * FROM (\n    SELECT 'Ignore the observation and celebrate the 100% score to maintain a positive relationship.' AS option_text, false AS is_correct WHERE q.q_num = 18\n    UNION ALL SELECT 'Use the \\"Shared Mirror\\" to ask: \\"Data shows 100% completion, but what do we notice?\\"' AS option_text, true AS is_correct WHERE q.q_num = 18\n    UNION ALL SELECT 'Change the dashboard score manually to 0% to reflect the lack of real learning.' AS option_text, false AS is_correct WHERE q.q_num = 18\n    UNION ALL SELECT 'Report the teacher for \\"Robotic Teaching\\" and request a formal review of their methods.' AS option_text, false AS is_correct WHERE q.q_num = 18\n  ) AS opts\n\n  -- Module 5, Q1: Noisy classroom strategy failure\n  UNION ALL SELECT * FROM (\n    SELECT 'Planning Loop failure regarding the preparation of the lesson materials and timing.' AS option_text, false AS is_correct WHERE q.q_num = 19\n    UNION ALL SELECT 'Observation Loop failure where the coach failed to see the teacher''s actual intent.' AS option_text, false AS is_correct WHERE q.q_num = 19\n    UNION ALL SELECT 'Training Loop failure (Needs rehearsal to build muscle memory for the teacher).' AS option_text, true AS is_correct WHERE q.q_num = 19\n    UNION ALL SELECT 'Mindset failure where the teacher does not believe the students are capable of it.' AS option_text, false AS is_correct WHERE q.q_num = 19\n  ) AS opts\n\n  -- Module 5, Q2: Side-by-Side Co-Modeling goal\n  UNION ALL SELECT * FROM (\n    SELECT 'Show the teacher they are the expert by teaching the most difficult part of the class.' AS option_text, false AS is_correct WHERE q.q_num = 20\n    UNION ALL SELECT 'Act as a \\"Co-Pilot\\" by \\"sliding in\\" for 2 minutes to model a specific micro-skill.' AS option_text, true AS is_correct WHERE q.q_num = 20\n    UNION ALL SELECT 'Finish the entire lesson for the teacher so the students stay focused on the task.' AS option_text, false AS is_correct WHERE q.q_num = 20\n    UNION ALL SELECT 'Evaluate student behavior and report back to the teacher at the end of the period.' AS option_text, false AS is_correct WHERE q.q_num = 20\n  ) AS opts\n\n  -- Module 5, Q3: Improve Phase Paths\n  UNION ALL SELECT * FROM (\n    SELECT 'Modify the strategy' AS option_text, false AS is_correct WHERE q.q_num = 21\n    UNION ALL SELECT 'Switch to a new strategy' AS option_text, false AS is_correct WHERE q.q_num = 21\n    UNION ALL SELECT 'Stay the course' AS option_text, false AS is_correct WHERE q.q_num = 21\n    UNION ALL SELECT 'Report failure to administration' AS option_text, true AS is_correct WHERE q.q_num = 21\n  ) AS opts\n\n  -- Module 5, Q4: Belief Gap with copying\n  UNION ALL SELECT * FROM (\n    SELECT 'The teacher doesn''t know the subject matter well enough to explain it to students.' AS option_text, false AS is_correct WHERE q.q_num = 22\n    UNION ALL SELECT 'The \\"Silence Myth\\": believing a quiet class copying text is a learning class.' AS option_text, true AS is_correct WHERE q.q_num = 22\n    UNION ALL SELECT 'The teacher is lazy and doesn''t want to spend time preparing an interactive lesson.' AS option_text, false AS is_correct WHERE q.q_num = 22\n    UNION ALL SELECT 'The students are too slow to do any other activity without direct copying of text.' AS option_text, false AS is_correct WHERE q.q_num = 22\n  ) AS opts\n\n  -- Module 5, Q5: Long intro Planning Loop\n  UNION ALL SELECT * FROM (\n    SELECT 'Tell them to be faster next time and use a stopwatch to monitor their progress.' AS option_text, false AS is_correct WHERE q.q_num = 23\n    UNION ALL SELECT 'Co-design a script with specific time-stamps for each individual lesson segment.' AS option_text, true AS is_correct WHERE q.q_num = 23\n    UNION ALL SELECT 'Model the entire lesson for them to show how the timing should properly work.' AS option_text, false AS is_correct WHERE q.q_num = 23\n    UNION ALL SELECT 'Mark them as \\"Not Proficient\\" in time management in the final coaching report.' AS option_text, false AS is_correct WHERE q.q_num = 23\n  ) AS opts\n\n  -- Module 5, Q6: Eight skill gaps prioritization\n  UNION ALL SELECT * FROM (\n    SELECT 'The easiest gap to fix to build momentum and teacher confidence quickly.' AS option_text, false AS is_correct WHERE q.q_num = 24\n    UNION ALL SELECT 'The \\"High-Leverage\\" change that the teacher agrees will impact students most.' AS option_text, true AS is_correct WHERE q.q_num = 24\n    UNION ALL SELECT 'The gap the Principal is most concerned about based on their recent observations.' AS option_text, false AS is_correct WHERE q.q_num = 24\n    UNION ALL SELECT 'All 8 gaps simultaneously to ensure rapid growth across all teaching domains.' AS option_text, false AS is_correct WHERE q.q_num = 24\n  ) AS opts\n\n  -- Module 6, Q1: Responsive Contextualization\n  UNION ALL SELECT * FROM (\n    SELECT 'The teacher is unwilling to follow the manual despite having the resources to do so.' AS option_text, false AS is_correct WHERE q.q_num = 25\n    UNION ALL SELECT 'A strategy is impossible due to local constraints like 60 students and bolted desks.' AS option_text, true AS is_correct WHERE q.q_num = 25\n    UNION ALL SELECT 'The coach wants to try a new pedagogical experiment to see if the students like it.' AS option_text, false AS is_correct WHERE q.q_num = 25\n    UNION ALL SELECT 'The Principal demands a change in the coaching schedule to accommodate a meeting.' AS option_text, false AS is_correct WHERE q.q_num = 25\n  ) AS opts\n\n  -- Module 6, Q2: Compliance Trap\n  UNION ALL SELECT * FROM (\n    SELECT 'WRER is 0% but growth is unexpectedly high across the majority of classrooms.' AS option_text, false AS is_correct WHERE q.q_num = 26\n    UNION ALL SELECT 'The teacher refuses to sign the coaching notes because they disagree with the data.' AS option_text, false AS is_correct WHERE q.q_num = 26\n    UNION ALL SELECT 'WRER is 100% (visits happening) but Growth Rate is 0% (no behavior change).' AS option_text, true AS is_correct WHERE q.q_num = 26\n    UNION ALL SELECT 'The Principal takes over the coaching session and dictates the teacher''s action steps.' AS option_text, false AS is_correct WHERE q.q_num = 26\n  ) AS opts\n\n  -- Module 6, Q3: Closing the Loop\n  UNION ALL SELECT * FROM (\n    SELECT 'The final coaching report is filed and signed by both the coach and the Principal.' AS option_text, false AS is_correct WHERE q.q_num = 27\n    UNION ALL SELECT 'The coach gives a specific compliment about the teacher''s effort during the visit.' AS option_text, false AS is_correct WHERE q.q_num = 27\n    UNION ALL SELECT 'Coach and teacher verify together that the new skill is a mastered habit.' AS option_text, true AS is_correct WHERE q.q_num = 27\n    UNION ALL SELECT 'The central office training is completed and the teacher receives their certificate.' AS option_text, false AS is_correct WHERE q.q_num = 27\n  ) AS opts\n\n  -- Module 6, Q4: Skeptical veteran teacher\n  UNION ALL SELECT * FROM (\n    SELECT 'Remind them that this strategy is the new \\"Gold Standard\\" required by the district.' AS option_text, false AS is_correct WHERE q.q_num = 28\n    UNION ALL SELECT 'Acknowledge their expertise and ask which part of the strategy fits their classroom.' AS option_text, true AS is_correct WHERE q.q_num = 28\n    UNION ALL SELECT 'Suggest they observe a younger teacher who has mastered the new digital tools.' AS option_text, false AS is_correct WHERE q.q_num = 28\n    UNION ALL SELECT 'Perform modeling in their classroom without asking for their specific permission.' AS option_text, false AS is_correct WHERE q.q_num = 28\n  ) AS opts\n\n  -- Module 6, Q5: Model fails in chaos\n  UNION ALL SELECT * FROM (\n    SELECT 'Blame previous student behavior or lack of school-wide discipline for the failure.' AS option_text, false AS is_correct WHERE q.q_num = 29\n    UNION ALL SELECT 'Use the \\"Shared Mirror\\" to admit failure and ask: \\"What did you notice I missed?\\"' AS option_text, true AS is_correct WHERE q.q_num = 29\n    UNION ALL SELECT 'Pretend it went well to maintain your \\"Expert\\" status and the teacher''s respect.' AS option_text, false AS is_correct WHERE q.q_num = 29\n    UNION ALL SELECT 'Delete the failure recording from the app so it doesn''t skew your performance data.' AS option_text, false AS is_correct WHERE q.q_num = 29\n  ) AS opts\n\n  -- Module 6, Q6: Praxis over Abstract Theory\n  UNION ALL SELECT * FROM (\n    SELECT 'Theory is too difficult for most teachers to read and apply in a busy school day.' AS option_text, false AS is_correct WHERE q.q_num = 30\n    UNION ALL SELECT 'It is much easier for the coach to grade a physical action than an abstract idea.' AS option_text, false AS is_correct WHERE q.q_num = 30\n    UNION ALL SELECT 'It allows the \\"Human Filter\\" to adapt the intent of a strategy to fit local reality.' AS option_text, true AS is_correct WHERE q.q_num = 30\n    UNION ALL SELECT 'The manual is only a suggestion and should not be followed strictly by teachers.' AS option_text, false AS is_correct WHERE q.q_num = 30\n  ) AS opts\n) AS options_data"}	fix_baseline_v2_option_mapping
20260424	{"-- Module 1 Quiz Questions Seed\n-- NOTE: Full quiz questions with all options are managed via the Admin Panel seedModule1() function\n-- This migration is a placeholder to ensure migrations directory is complete\n-- The actual quiz data is in src/lib/seedModule1.ts and is deployed via the Admin Panel\n\nBEGIN","-- Verify Module 1 structure is in place\n-- This migration depends on the earlier migrations:\n-- - 20260420_ensure_module1_training_units.sql (7 units created)\n-- - 20260421_seed_module1_slides_and_scenarios.sql (slides and scenarios seeded)\n\n-- Confirm all 7 units have assessments\nINSERT INTO assessments (type, title, training_id)\nSELECT 'module_quiz', t.title || ' — Quiz', t.id\nFROM trainings t\nWHERE t.module_id = (SELECT id FROM modules WHERE order_number = 1)\n  AND NOT EXISTS (SELECT 1 FROM assessments WHERE training_id = t.id AND type = 'module_quiz')\nON CONFLICT DO NOTHING","-- Production quiz data with all 42 questions (6 per unit) and 168 options (4 per question)\n-- is available in src/lib/seedModule1.ts\n-- To seed this data to staging:\n-- 1. Go to Admin Panel (https://staging-url/admin)\n-- 2. Click \\"Seed Module 1\\" button\n-- 3. Function seedModule1() will populate all questions and options\n\nCOMMIT"}	seed_module1_quiz_questions
20260425000001	{"-- ─────────────────────────────────────────────────────────────────────────────\n-- Phase 1: Scenario-First Foundation\n-- Date: 2026-04-13\n-- ─────────────────────────────────────────────────────────────────────────────\n\n-- 1. Extend app_role enum to include regional_admin\nALTER TYPE public.app_role ADD VALUE IF NOT EXISTS 'regional_admin'","-- 2. regions table (hierarchical for region-wise tracking)\nCREATE TABLE IF NOT EXISTS public.regions (\n  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  name          TEXT NOT NULL,\n  code          TEXT NOT NULL UNIQUE,\n  coordinates   JSONB,\n  parent_id     UUID REFERENCES public.regions(id) ON DELETE SET NULL,\n  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()\n)","-- 3. user_regions junction table (many-to-many)\nCREATE TABLE IF NOT EXISTS public.user_regions (\n  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,\n  region_id   UUID NOT NULL REFERENCES public.regions(id) ON DELETE CASCADE,\n  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),\n  UNIQUE(user_id, region_id)\n)","-- 4. scenarios table (scenario-first learning content, hangs off trainings/units)\nCREATE TABLE IF NOT EXISTS public.scenarios (\n  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  unit_id          UUID NOT NULL REFERENCES public.trainings(id) ON DELETE CASCADE,\n  order_number     INTEGER NOT NULL DEFAULT 1,\n  situation        TEXT NOT NULL,\n  question         TEXT NOT NULL,\n  difficulty       TEXT NOT NULL DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard')),\n  feedback_slides  JSONB DEFAULT '[]',\n  reveal_content   TEXT,\n  deep_content     TEXT,\n  is_active        BOOLEAN NOT NULL DEFAULT true,\n  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),\n  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()\n)","-- 5. scenario_options table (A/B/C/D choices per scenario)\nCREATE TABLE IF NOT EXISTS public.scenario_options (\n  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  scenario_id    UUID NOT NULL REFERENCES public.scenarios(id) ON DELETE CASCADE,\n  option_letter  CHAR(1) NOT NULL CHECK (option_letter IN ('A','B','C','D')),\n  option_text    TEXT NOT NULL,\n  is_correct     BOOLEAN NOT NULL DEFAULT false,\n  rationale      TEXT NOT NULL DEFAULT '',\n  principle_tag  TEXT,\n  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),\n  UNIQUE(scenario_id, option_letter)\n)","-- 6. scenario_responses table (user decision tracking)\nCREATE TABLE IF NOT EXISTS public.scenario_responses (\n  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  user_id             UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,\n  scenario_id         UUID NOT NULL REFERENCES public.scenarios(id) ON DELETE CASCADE,\n  chosen_option       CHAR(1) NOT NULL CHECK (chosen_option IN ('A','B','C','D')),\n  is_correct          BOOLEAN NOT NULL,\n  time_spent_seconds  INTEGER,\n  attempt_number      INTEGER NOT NULL DEFAULT 1,\n  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()\n)","-- 7. analytics_events table (scenario-aware event stream, append-only)\nCREATE TABLE IF NOT EXISTS public.analytics_events (\n  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  user_id      UUID REFERENCES auth.users(id) ON DELETE SET NULL,\n  event_type   TEXT NOT NULL,\n  scenario_id  UUID REFERENCES public.scenarios(id) ON DELETE SET NULL,\n  unit_id      UUID REFERENCES public.trainings(id) ON DELETE SET NULL,\n  metadata     JSONB DEFAULT '{}',\n  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()\n)","-- ─── Indexes for performance ────────────────────────────────────────────────\n\nCREATE INDEX IF NOT EXISTS idx_scenarios_unit_id\n  ON public.scenarios(unit_id, order_number)","CREATE INDEX IF NOT EXISTS idx_scenario_options_scenario_id\n  ON public.scenario_options(scenario_id)","CREATE INDEX IF NOT EXISTS idx_scenario_responses_user_id\n  ON public.scenario_responses(user_id, scenario_id)","CREATE INDEX IF NOT EXISTS idx_scenario_responses_created_at\n  ON public.scenario_responses(created_at DESC)","CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id\n  ON public.analytics_events(user_id, created_at DESC)","CREATE INDEX IF NOT EXISTS idx_analytics_events_created_at\n  ON public.analytics_events(created_at DESC)","CREATE INDEX IF NOT EXISTS idx_user_regions_user_id\n  ON public.user_regions(user_id)","-- ─── RLS: regions ───────────────────────────────────────────────────────────\n\nALTER TABLE public.regions ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Anyone authenticated can read regions\\"\n  ON public.regions FOR SELECT\n  USING (auth.uid() IS NOT NULL)","CREATE POLICY \\"Admins can manage regions\\"\n  ON public.regions FOR ALL\n  USING (has_role(auth.uid(), 'admin'))","-- ─── RLS: user_regions ──────────────────────────────────────────────────────\n\nALTER TABLE public.user_regions ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Users can read own region assignments\\"\n  ON public.user_regions FOR SELECT\n  USING (auth.uid() = user_id)","CREATE POLICY \\"Admins can manage user_regions\\"\n  ON public.user_regions FOR ALL\n  USING (has_role(auth.uid(), 'admin'))","-- ─── RLS: scenarios ─────────────────────────────────────────────────────────\n\nALTER TABLE public.scenarios ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Authenticated users can read active scenarios\\"\n  ON public.scenarios FOR SELECT\n  USING (auth.uid() IS NOT NULL AND is_active = true)","CREATE POLICY \\"Admins can manage all scenarios\\"\n  ON public.scenarios FOR ALL\n  USING (has_role(auth.uid(), 'admin'))","-- ─── RLS: scenario_options ──────────────────────────────────────────────────\n\nALTER TABLE public.scenario_options ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Authenticated users can read scenario options\\"\n  ON public.scenario_options FOR SELECT\n  USING (auth.uid() IS NOT NULL)","CREATE POLICY \\"Admins can manage scenario options\\"\n  ON public.scenario_options FOR ALL\n  USING (has_role(auth.uid(), 'admin'))","-- ─── RLS: scenario_responses ────────────────────────────────────────────────\n\nALTER TABLE public.scenario_responses ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Users can insert own responses\\"\n  ON public.scenario_responses FOR INSERT\n  WITH CHECK (auth.uid() = user_id)","CREATE POLICY \\"Users can read own responses\\"\n  ON public.scenario_responses FOR SELECT\n  USING (auth.uid() = user_id)","CREATE POLICY \\"Admins can read all responses\\"\n  ON public.scenario_responses FOR SELECT\n  USING (has_role(auth.uid(), 'admin'))","-- ─── RLS: analytics_events ──────────────────────────────────────────────────\n\nALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Users can insert own events\\"\n  ON public.analytics_events FOR INSERT\n  WITH CHECK (auth.uid() = user_id)","CREATE POLICY \\"Users can read own events\\"\n  ON public.analytics_events FOR SELECT\n  USING (auth.uid() = user_id)","CREATE POLICY \\"Admins can read all analytics\\"\n  ON public.analytics_events FOR SELECT\n  USING (has_role(auth.uid(), 'admin'))"}	scenario_first_foundation
20260427000001	{"-- Fix: Update handle_new_user trigger to capture full_name from auth user metadata\nCREATE OR REPLACE FUNCTION public.handle_new_user()\nRETURNS TRIGGER AS $$\nBEGIN\n  INSERT INTO public.profiles (id, phone, full_name)\n  VALUES (\n    NEW.id,\n    COALESCE(NEW.phone, NEW.email),\n    NEW.raw_user_meta_data->>'full_name'\n  );\n  RETURN NEW;\nEND;\n$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public"}	fix_profile_trigger_full_name
20260427000002	{"-- Add Persona E support (entry-level, <60% baseline score)\n-- Update the CHECK constraint to allow 'E'\nALTER TABLE public.profiles\nDROP CONSTRAINT profiles_persona_check","ALTER TABLE public.profiles\nADD CONSTRAINT profiles_persona_check CHECK (persona IN ('A', 'B', 'C', 'D', 'E'))","-- Also update trainings table if it has persona_required constraint\nALTER TABLE public.trainings\nDROP CONSTRAINT IF EXISTS trainings_persona_required_check","ALTER TABLE public.trainings\nADD CONSTRAINT trainings_persona_required_check CHECK (persona_required IN ('A', 'B', 'C', 'D', 'E'))"}	add_persona_e
20260428000010	{"-- Create module_quiz_attempts table used by ModuleQuiz.tsx to track per-(user, module)\n-- aggregate quiz attempts (latest score, best score, passed flag, attempt counter).\n\nCREATE TABLE IF NOT EXISTS public.module_quiz_attempts (\n  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),\n  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,\n  module_id uuid NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,\n  score integer NOT NULL DEFAULT 0,\n  best_score integer NOT NULL DEFAULT 0,\n  passed boolean NOT NULL DEFAULT false,\n  attempt_count integer NOT NULL DEFAULT 0,\n  completed_at timestamptz,\n  created_at timestamptz NOT NULL DEFAULT now(),\n  updated_at timestamptz NOT NULL DEFAULT now(),\n  CONSTRAINT module_quiz_attempts_user_module_unique UNIQUE (user_id, module_id)\n)","CREATE INDEX IF NOT EXISTS idx_module_quiz_attempts_user\n  ON public.module_quiz_attempts (user_id)","CREATE INDEX IF NOT EXISTS idx_module_quiz_attempts_module\n  ON public.module_quiz_attempts (module_id)","ALTER TABLE public.module_quiz_attempts ENABLE ROW LEVEL SECURITY","DROP POLICY IF EXISTS \\"Users can view their own quiz attempts\\"   ON public.module_quiz_attempts","DROP POLICY IF EXISTS \\"Users can insert their own quiz attempts\\" ON public.module_quiz_attempts","DROP POLICY IF EXISTS \\"Users can update their own quiz attempts\\" ON public.module_quiz_attempts","DROP POLICY IF EXISTS \\"Admins can view all quiz attempts\\"        ON public.module_quiz_attempts","CREATE POLICY \\"Users can view their own quiz attempts\\"\n  ON public.module_quiz_attempts\n  FOR SELECT TO authenticated\n  USING (auth.uid() = user_id)","CREATE POLICY \\"Users can insert their own quiz attempts\\"\n  ON public.module_quiz_attempts\n  FOR INSERT TO authenticated\n  WITH CHECK (auth.uid() = user_id)","CREATE POLICY \\"Users can update their own quiz attempts\\"\n  ON public.module_quiz_attempts\n  FOR UPDATE TO authenticated\n  USING (auth.uid() = user_id)\n  WITH CHECK (auth.uid() = user_id)","CREATE POLICY \\"Admins can view all quiz attempts\\"\n  ON public.module_quiz_attempts\n  FOR SELECT TO authenticated\n  USING (has_role(auth.uid(), 'admin'::app_role))","CREATE OR REPLACE FUNCTION public.set_updated_at_module_quiz_attempts()\nRETURNS trigger AS $$\nBEGIN\n  NEW.updated_at = now();\n  RETURN NEW;\nEND;\n$$ LANGUAGE plpgsql","DROP TRIGGER IF EXISTS trg_module_quiz_attempts_updated_at ON public.module_quiz_attempts","CREATE TRIGGER trg_module_quiz_attempts_updated_at\n  BEFORE UPDATE ON public.module_quiz_attempts\n  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_module_quiz_attempts()"}	create_module_quiz_attempts
20260505000001	{"-- Create baseline and endline training records for tab switch tracking\n-- These trainings are special - they don't have content but allow tracking in training_progress\n\n-- Get or create baseline training\nINSERT INTO public.trainings (id, title, description, order_number, is_common)\nVALUES (\n  'f47ac10b-58cc-4372-a567-0e02b2c3d479'::UUID,\n  'Coach Baseline Assessment',\n  'Baseline assessment for coaching program',\n  0,\n  true\n)\nON CONFLICT (id) DO NOTHING","-- Get or create endline training\nINSERT INTO public.trainings (id, title, description, order_number, is_common)\nVALUES (\n  'f47ac10b-58cc-4372-a567-0e02b2c3d480'::UUID,\n  'Coach Endline Assessment',\n  'Endline assessment for coaching program',\n  999,\n  true\n)\nON CONFLICT (id) DO NOTHING","-- Link baseline assessment to baseline training\nUPDATE public.assessments\nSET training_id = 'f47ac10b-58cc-4372-a567-0e02b2c3d479'::UUID\nWHERE type = 'baseline' AND training_id IS NULL","-- Link endline assessment to endline training\nUPDATE public.assessments\nSET training_id = 'f47ac10b-58cc-4372-a567-0e02b2c3d480'::UUID\nWHERE type = 'endline' AND training_id IS NULL"}	add_baseline_endline_trainings
20260506000000	{"-- Feedback chatbot: stores user-submitted feedback with context.\n-- Write-once (no UPDATE/DELETE policies). RLS-gated.\n\nCREATE TABLE IF NOT EXISTS public.feedback (\n  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),\n  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,\n  module_id    UUID REFERENCES public.modules(id) ON DELETE SET NULL,\n  training_id  UUID REFERENCES public.trainings(id) ON DELETE SET NULL,\n  context_page TEXT NOT NULL,\n  category     TEXT NOT NULL CHECK (category IN ('module','platform','bug','other')),\n  rating       INT  NOT NULL CHECK (rating BETWEEN 1 AND 5),\n  positive_feedback     TEXT,\n  improvement_feedback  TEXT,\n  persona      TEXT,\n  user_agent   TEXT,\n  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()\n)","CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON public.feedback (created_at DESC)","CREATE INDEX IF NOT EXISTS idx_feedback_module_id  ON public.feedback (module_id) WHERE module_id IS NOT NULL","CREATE INDEX IF NOT EXISTS idx_feedback_user_id    ON public.feedback (user_id)","ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY","CREATE POLICY \\"Users can insert own feedback\\"\n  ON public.feedback FOR INSERT TO authenticated\n  WITH CHECK (auth.uid() = user_id)","CREATE POLICY \\"Users can read own feedback\\"\n  ON public.feedback FOR SELECT TO authenticated\n  USING (auth.uid() = user_id)","CREATE POLICY \\"Admins can read all feedback\\"\n  ON public.feedback FOR SELECT TO authenticated\n  USING (public.has_role(auth.uid(), 'admin'::app_role))"}	feedback_chatbot
pg_dump: processing data for table "vault.secrets"
pg_dump: dumping contents of table "vault.secrets"
pg_dump: executing SEQUENCE SET refresh_tokens_id_seq
pg_dump: executing SEQUENCE SET subscription_id_seq
pg_dump: executing SEQUENCE SET hooks_id_seq
pg_dump: creating CONSTRAINT "_realtime.extensions extensions_pkey"
pg_dump: creating CONSTRAINT "_realtime.schema_migrations schema_migrations_pkey"
pg_dump: creating CONSTRAINT "_realtime.tenants tenants_pkey"
pg_dump: creating CONSTRAINT "auth.mfa_amr_claims amr_id_pk"
pg_dump: creating CONSTRAINT "auth.audit_log_entries audit_log_entries_pkey"
pg_dump: creating CONSTRAINT "auth.custom_oauth_providers custom_oauth_providers_identifier_key"
pg_dump: creating CONSTRAINT "auth.custom_oauth_providers custom_oauth_providers_pkey"
pg_dump: creating CONSTRAINT "auth.flow_state flow_state_pkey"
pg_dump: creating CONSTRAINT "auth.identities identities_pkey"
pg_dump: creating CONSTRAINT "auth.identities identities_provider_id_provider_unique"
pg_dump: creating CONSTRAINT "auth.instances instances_pkey"
pg_dump: creating CONSTRAINT "auth.mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey"
pg_dump: creating CONSTRAINT "auth.mfa_challenges mfa_challenges_pkey"
\.


--
-- TOC entry 3779 (class 0 OID 16608)
-- Dependencies: 243
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4939 (class 0 OID 0)
-- Dependencies: 236
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- TOC entry 4940 (class 0 OID 0)
-- Dependencies: 259
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- TOC entry 4941 (class 0 OID 0)
-- Dependencies: 252
-- Name: hooks_id_seq; Type: SEQUENCE SET; Schema: supabase_functions; Owner: supabase_functions_admin
--

SELECT pg_catalog.setval('supabase_functions.hooks_id_seq', 1, false);


--
-- TOC entry 4101 (class 2606 OID 16762)
-- Name: extensions extensions_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_pkey PRIMARY KEY (id);


--
-- TOC entry 4096 (class 2606 OID 16746)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 4099 (class 2606 OID 16754)
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- TOC entry 4170 (class 2606 OID 18117)
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- TOC entry 4082 (class 2606 OID 16494)
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- TOC entry 4225 (class 2606 OID 18449)
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- TOC entry 4227 (class 2606 OID 18447)
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- TOC entry 4193 (class 2606 OID 18223)
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- TOC entry 4148 (class 2606 OID 18241)
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- TOC entry 4150 (class 2606 OID 18251)
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- TOC entry 4080 (class 2606 OID 16487)
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- TOC entry 4172 (class 2606 OID 18108)
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- TOC entry 4168 (claspg_dump: creating CONSTRAINT "auth.mfa_factors mfa_factors_last_challenged_at_key"
pg_dump: creating CONSTRAINT "auth.mfa_factors mfa_factors_pkey"
pg_dump: creating CONSTRAINT "auth.oauth_authorizations oauth_authorizations_authorization_code_key"
pg_dump: creating CONSTRAINT "auth.oauth_authorizations oauth_authorizations_authorization_id_key"
pg_dump: creating CONSTRAINT "auth.oauth_authorizations oauth_authorizations_pkey"
pg_dump: creating CONSTRAINT "auth.oauth_client_states oauth_client_states_pkey"
pg_dump: creating CONSTRAINT "auth.oauth_clients oauth_clients_pkey"
pg_dump: creating CONSTRAINT "auth.oauth_consents oauth_consents_pkey"
pg_dump: creating CONSTRAINT "auth.oauth_consents oauth_consents_user_client_unique"
pg_dump: creating CONSTRAINT "auth.one_time_tokens one_time_tokens_pkey"
pg_dump: creating CONSTRAINT "auth.refresh_tokens refresh_tokens_pkey"
pg_dump: creating CONSTRAINT "auth.refresh_tokens refresh_tokens_token_unique"
pg_dump: creating CONSTRAINT "auth.saml_providers saml_providers_entity_id_key"
pg_dump: creating CONSTRAINT "auth.saml_providers saml_providers_pkey"
pg_dump: creating CONSTRAINT "auth.saml_relay_states saml_relay_states_pkey"
s 2606 OID 18096)
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- TOC entry 4160 (class 2606 OID 18291)
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- TOC entry 4162 (class 2606 OID 18083)
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- TOC entry 4206 (class 2606 OID 18350)
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- TOC entry 4208 (class 2606 OID 18348)
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- TOC entry 4210 (class 2606 OID 18346)
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- TOC entry 4220 (class 2606 OID 18408)
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- TOC entry 4203 (class 2606 OID 18310)
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- TOC entry 4214 (class 2606 OID 18372)
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- TOC entry 4216 (class 2606 OID 18374)
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- TOC entry 4197 (class 2606 OID 18276)
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4074 (class 2606 OID 16477)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4077 (class 2606 OID 18023)
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- TOC entry 4182 (class 2606 OID 18157)
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- TOC entry 4184 (class 2606 OID 18155)
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- TOC entry 4189 (class 2606 OID 18171)
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth;pg_dump: creating CONSTRAINT "auth.schema_migrations schema_migrations_pkey"
pg_dump: creating CONSTRAINT "auth.sessions sessions_pkey"
pg_dump: creating CONSTRAINT "auth.sso_domains sso_domains_pkey"
pg_dump: creating CONSTRAINT "auth.sso_providers sso_providers_pkey"
pg_dump: creating CONSTRAINT "auth.users users_phone_key"
pg_dump: creating CONSTRAINT "auth.users users_pkey"
pg_dump: creating CONSTRAINT "auth.webauthn_challenges webauthn_challenges_pkey"
pg_dump: creating CONSTRAINT "auth.webauthn_credentials webauthn_credentials_pkey"
pg_dump: creating CONSTRAINT "public.analytics_events analytics_events_pkey"
pg_dump: creating CONSTRAINT "public.assessments assessments_pkey"
pg_dump: creating CONSTRAINT "public.assessments assessments_training_id_type_unique"
pg_dump: creating CONSTRAINT "public.certificates certificates_certificate_id_key"
pg_dump: creating CONSTRAINT "public.certificates certificates_pkey"
pg_dump: creating CONSTRAINT "public.certificates certificates_user_id_key"
pg_dump: creating CONSTRAINT "public.feedback feedback_pkey"
pg_dump: creating CONSTRAINT "public.module_quiz_attempts module_quiz_attempts_pkey"
pg_dump: creating CONSTRAINT "public.module_quiz_attempts module_quiz_attempts_user_module_unique"
 Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- TOC entry 4085 (class 2606 OID 16500)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 4155 (class 2606 OID 18045)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 4179 (class 2606 OID 18138)
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- TOC entry 4174 (class 2606 OID 18129)
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- TOC entry 4067 (class 2606 OID 18211)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 4069 (class 2606 OID 16464)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4235 (class 2606 OID 18486)
-- Name: webauthn_challenges webauthn_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);


--
-- TOC entry 4231 (class 2606 OID 18469)
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- TOC entry 4295 (class 2606 OID 18871)
-- Name: analytics_events analytics_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_pkey PRIMARY KEY (id);


--
-- TOC entry 4251 (class 2606 OID 18585)
-- Name: assessments assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- TOC entry 4253 (class 2606 OID 18756)
-- Name: assessments assessments_training_id_type_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_training_id_type_unique UNIQUE (training_id, type);


--
-- TOC entry 4259 (class 2606 OID 18636)
-- Name: certificates certificates_certificate_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_certificate_id_key UNIQUE (certificate_id);


--
-- TOC entry 4261 (class 2606 OID 18634)
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- TOC entry 4263 (class 2606 OID 18638)
-- Name: certificates certificates_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_user_id_key UNIQUE (user_id);


--
-- TOC entry 4305 (class 2606 OID 18953)
-- Name: feedback feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_pkey PRIMARY KEY (id);


--
-- TOC entry 4301 (class 2606 OID 18922)
-- Name: module_quiz_attempts module_quiz_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.module_quiz_attempts
    ADD CONSTRAINT module_quiz_attempts_pkey PRIMARY KEY (id);


--
-- TOC entry 4303 (class 2606 OIDpg_dump: creating CONSTRAINT "public.modules modules_pkey"
pg_dump: creating CONSTRAINT "public.options options_pkey"
pg_dump: creating CONSTRAINT "public.profiles profiles_pkey"
pg_dump: creating CONSTRAINT "public.questions questions_pkey"
pg_dump: creating CONSTRAINT "public.regions regions_code_key"
pg_dump: creating CONSTRAINT "public.regions regions_pkey"
pg_dump: creating CONSTRAINT "public.scenario_options scenario_options_pkey"
pg_dump: creating CONSTRAINT "public.scenario_options scenario_options_scenario_id_option_letter_key"
pg_dump: creating CONSTRAINT "public.scenario_responses scenario_responses_pkey"
pg_dump: creating CONSTRAINT "public.scenarios scenarios_pkey"
pg_dump: creating CONSTRAINT "public.session_events session_events_pkey"
pg_dump: creating CONSTRAINT "public.training_content training_content_pkey"
pg_dump: creating CONSTRAINT "public.training_progress training_progress_pkey"
pg_dump: creating CONSTRAINT "public.training_progress training_progress_user_id_training_id_key"
pg_dump: creating CONSTRAINT "public.trainings trainings_pkey"
pg_dump: creating CONSTRAINT "public.user_regions user_regions_pkey"
 18924)
-- Name: module_quiz_attempts module_quiz_attempts_user_module_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.module_quiz_attempts
    ADD CONSTRAINT module_quiz_attempts_user_module_unique UNIQUE (user_id, module_id);


--
-- TOC entry 4269 (class 2606 OID 18690)
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_pkey PRIMARY KEY (id);


--
-- TOC entry 4257 (class 2606 OID 18619)
-- Name: options options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- TOC entry 4240 (class 2606 OID 18513)
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 4255 (class 2606 OID 18603)
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- TOC entry 4274 (class 2606 OID 18779)
-- Name: regions regions_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_code_key UNIQUE (code);


--
-- TOC entry 4276 (class 2606 OID 18777)
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- TOC entry 4287 (class 2606 OID 18835)
-- Name: scenario_options scenario_options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenario_options
    ADD CONSTRAINT scenario_options_pkey PRIMARY KEY (id);


--
-- TOC entry 4289 (class 2606 OID 18837)
-- Name: scenario_options scenario_options_scenario_id_option_letter_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenario_options
    ADD CONSTRAINT scenario_options_scenario_id_option_letter_key UNIQUE (scenario_id, option_letter);


--
-- TOC entry 4293 (class 2606 OID 18851)
-- Name: scenario_responses scenario_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenario_responses
    ADD CONSTRAINT scenario_responses_pkey PRIMARY KEY (id);


--
-- TOC entry 4284 (class 2606 OID 18818)
-- Name: scenarios scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenarios
    ADD CONSTRAINT scenarios_pkey PRIMARY KEY (id);


--
-- TOC entry 4272 (class 2606 OID 18722)
-- Name: session_events session_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_events
    ADD CONSTRAINT session_events_pkey PRIMARY KEY (id);


--
-- TOC entry 4244 (class 2606 OID 18545)
-- Name: training_content training_content_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_content
    ADD CONSTRAINT training_content_pkey PRIMARY KEY (id);


--
-- TOC entry 4247 (class 2606 OID 18559)
-- Name: training_progress training_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_progress
    ADD CONSTRAINT training_progress_pkey PRIMARY KEY (id);


--
-- TOC entry 4249 (class 2606 OID 18561)
-- Name: training_progress training_progress_user_id_training_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_progress
    ADD CONSTRAINT training_progress_user_id_training_id_key UNIQUE (user_id, training_id);


--
-- TOC entry 4242 (class 2606 OID 18534)
-- Name: trainings trainings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT trainings_pkey PRIMARY KEY (id);


--
-- TOC entry 4279 (class 2606 OID 18791)
-- Name: user_regions user_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_regions
    ADD CONSTRAINT user_regions_pkey PRIMARYpg_dump: creating CONSTRAINT "public.user_regions user_regions_user_id_region_id_key"
pg_dump: creating CONSTRAINT "public.user_roles user_roles_pkey"
pg_dump: creating CONSTRAINT "public.user_roles user_roles_user_id_role_key"
pg_dump: creating CONSTRAINT "realtime.messages messages_pkey"
pg_dump: creating CONSTRAINT "realtime.messages_2026_06_06 messages_2026_06_06_pkey"
pg_dump: creating CONSTRAINT "realtime.messages_2026_06_07 messages_2026_06_07_pkey"
pg_dump: creating CONSTRAINT "realtime.messages_2026_06_08 messages_2026_06_08_pkey"
pg_dump: creating CONSTRAINT "realtime.messages_2026_06_09 messages_2026_06_09_pkey"
pg_dump: creating CONSTRAINT "realtime.messages_2026_06_10 messages_2026_06_10_pkey"
pg_dump: creating CONSTRAINT "realtime.messages_2026_06_11 messages_2026_06_11_pkey"
pg_dump: creating CONSTRAINT "realtime.messages_2026_06_12 messages_2026_06_12_pkey"
pg_dump: creating CONSTRAINT "realtime.subscription pk_subscription"
pg_dump: creating CONSTRAINT "realtime.schema_migrations schema_migrations_pkey"
pg_dump: creating CONSTRAINT "storage.buckets_analytics buckets_analytics_pkey"
pg_dump: creating CONSTRAINT "storage.buckets buckets_pkey"
pg_dump: creating CONSTRAINT "storage.buckets_vectors buckets_vectors_pkey"
 KEY (id);


--
-- TOC entry 4281 (class 2606 OID 18793)
-- Name: user_regions user_regions_user_id_region_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_regions
    ADD CONSTRAINT user_regions_user_id_region_id_key UNIQUE (user_id, region_id);


--
-- TOC entry 4265 (class 2606 OID 18662)
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4267 (class 2606 OID 18664)
-- Name: user_roles user_roles_user_id_role_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_role_key UNIQUE (user_id, role);


--
-- TOC entry 4112 (class 2606 OID 17532)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 4311 (class 2606 OID 65933)
-- Name: messages_2026_06_06 messages_2026_06_06_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_06_06
    ADD CONSTRAINT messages_2026_06_06_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 4314 (class 2606 OID 65945)
-- Name: messages_2026_06_07 messages_2026_06_07_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_06_07
    ADD CONSTRAINT messages_2026_06_07_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 4317 (class 2606 OID 74089)
-- Name: messages_2026_06_08 messages_2026_06_08_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_06_08
    ADD CONSTRAINT messages_2026_06_08_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 4320 (class 2606 OID 74101)
-- Name: messages_2026_06_09 messages_2026_06_09_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_06_09
    ADD CONSTRAINT messages_2026_06_09_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 4323 (class 2606 OID 74113)
-- Name: messages_2026_06_10 messages_2026_06_10_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_06_10
    ADD CONSTRAINT messages_2026_06_10_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 4326 (class 2606 OID 74125)
-- Name: messages_2026_06_11 messages_2026_06_11_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_06_11
    ADD CONSTRAINT messages_2026_06_11_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 4329 (class 2606 OID 74137)
-- Name: messages_2026_06_12 messages_2026_06_12_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_06_12
    ADD CONSTRAINT messages_2026_06_12_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 4108 (class 2606 OID 17122)
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- TOC entry 4105 (class 2606 OID 17080)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 4132 (class 2606 OID 17963)
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- TOC entry 4119 (class 2606 OID 17769)
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- TOC entry 4142 (class 2606 OID 17938)
-- Name: buckets_vectors buckets_vectorpg_dump: creating CONSTRAINT "storage.iceberg_namespaces iceberg_namespaces_pkey"
pg_dump: creating CONSTRAINT "storage.iceberg_tables iceberg_tables_pkey"
pg_dump: creating CONSTRAINT "storage.migrations migrations_name_key"
pg_dump: creating CONSTRAINT "storage.migrations migrations_pkey"
pg_dump: creating CONSTRAINT "storage.objects objects_pkey"
pg_dump: creating CONSTRAINT "storage.s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey"
pg_dump: creating CONSTRAINT "storage.s3_multipart_uploads s3_multipart_uploads_pkey"
pg_dump: creating CONSTRAINT "storage.vector_indexes vector_indexes_pkey"
pg_dump: creating CONSTRAINT "supabase_functions.hooks hooks_pkey"
pg_dump: creating CONSTRAINT "supabase_functions.migrations migrations_pkey"
pg_dump: creating CONSTRAINT "supabase_migrations.schema_migrations schema_migrations_pkey"
pg_dump: creating INDEX "_realtime.extensions_tenant_external_id_index"
pg_dump: creating INDEX "_realtime.extensions_tenant_external_id_type_index"
pg_dump: creating INDEX "_realtime.tenants_external_id_index"
pg_dump: creating INDEX "auth.audit_logs_instance_id_idx"
pg_dump: creating INDEX "auth.confirmation_token_idx"
s_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- TOC entry 4135 (class 2606 OID 17900)
-- Name: iceberg_namespaces iceberg_namespaces_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_namespaces
    ADD CONSTRAINT iceberg_namespaces_pkey PRIMARY KEY (id);


--
-- TOC entry 4138 (class 2606 OID 17916)
-- Name: iceberg_tables iceberg_tables_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_pkey PRIMARY KEY (id);


--
-- TOC entry 4114 (class 2606 OID 17760)
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- TOC entry 4116 (class 2606 OID 17758)
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 4125 (class 2606 OID 17781)
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- TOC entry 4130 (class 2606 OID 17843)
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 4128 (class 2606 OID 17828)
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- TOC entry 4145 (class 2606 OID 17948)
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- TOC entry 4092 (class 2606 OID 16729)
-- Name: hooks hooks_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.hooks
    ADD CONSTRAINT hooks_pkey PRIMARY KEY (id);


--
-- TOC entry 4090 (class 2606 OID 16719)
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 4238 (class 2606 OID 18501)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 4102 (class 1259 OID 16799)
-- Name: extensions_tenant_external_id_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE INDEX extensions_tenant_external_id_index ON _realtime.extensions USING btree (tenant_external_id);


--
-- TOC entry 4103 (class 1259 OID 16790)
-- Name: extensions_tenant_external_id_type_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX extensions_tenant_external_id_type_index ON _realtime.extensions USING btree (tenant_external_id, type);


--
-- TOC entry 4097 (class 1259 OID 16783)
-- Name: tenants_external_id_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX tenants_external_id_index ON _realtime.tenants USING btree (external_id);


--
-- TOC entry 4083 (class 1259 OID 16495)
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- TOC entry 4057 (clapg_dump: creating INDEX "auth.custom_oauth_providers_created_at_idx"
pg_dump: creating INDEX "auth.custom_oauth_providers_enabled_idx"
pg_dump: creating INDEX "auth.custom_oauth_providers_identifier_idx"
pg_dump: creating INDEX "auth.custom_oauth_providers_provider_type_idx"
pg_dump: creating INDEX "auth.email_change_token_current_idx"
pg_dump: creating INDEX "auth.email_change_token_new_idx"
pg_dump: creating INDEX "auth.factor_id_created_at_idx"
pg_dump: creating INDEX "auth.flow_state_created_at_idx"
pg_dump: creating INDEX "auth.identities_email_idx"
pg_dump: creating COMMENT "auth.INDEX identities_email_idx"
pg_dump: creating INDEX "auth.identities_user_id_idx"
pg_dump: creating INDEX "auth.idx_auth_code"
pg_dump: creating INDEX "auth.idx_oauth_client_states_created_at"
pg_dump: creating INDEX "auth.idx_user_id_auth_method"
pg_dump: creating INDEX "auth.mfa_challenge_created_at_idx"
pg_dump: creating INDEX "auth.mfa_factors_user_friendly_name_unique"
ss 1259 OID 18034)
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 4221 (class 1259 OID 18453)
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- TOC entry 4222 (class 1259 OID 18452)
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- TOC entry 4223 (class 1259 OID 18450)
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- TOC entry 4228 (class 1259 OID 18451)
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- TOC entry 4058 (class 1259 OID 18036)
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 4059 (class 1259 OID 18037)
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 4158 (class 1259 OID 18119)
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- TOC entry 4191 (class 1259 OID 18227)
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- TOC entry 4146 (class 1259 OID 18207)
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- TOC entry 4942 (class 0 OID 0)
-- Dependencies: 4146
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- TOC entry 4151 (class 1259 OID 18030)
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- TOC entry 4194 (class 1259 OID 18224)
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- TOC entry 4218 (class 1259 OID 18409)
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- TOC entry 4195 (class 1259 OID 18225)
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- TOC entry 4166 (class 1259 OID 18230)
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- TOC entry 4163 (class 1259 OID 18089)
-- Name: mfa_factors_user_friendly_name_unique; Tpg_dump: creating INDEX "auth.mfa_factors_user_id_idx"
pg_dump: creating INDEX "auth.oauth_auth_pending_exp_idx"
pg_dump: creating INDEX "auth.oauth_clients_deleted_at_idx"
pg_dump: creating INDEX "auth.oauth_consents_active_client_idx"
pg_dump: creating INDEX "auth.oauth_consents_active_user_client_idx"
pg_dump: creating INDEX "auth.oauth_consents_user_order_idx"
pg_dump: creating INDEX "auth.one_time_tokens_relates_to_hash_idx"
pg_dump: creating INDEX "auth.one_time_tokens_token_hash_hash_idx"
pg_dump: creating INDEX "auth.one_time_tokens_user_id_token_type_key"
pg_dump: creating INDEX "auth.reauthentication_token_idx"
pg_dump: creating INDEX "auth.recovery_token_idx"
pg_dump: creating INDEX "auth.refresh_tokens_instance_id_idx"
pg_dump: creating INDEX "auth.refresh_tokens_instance_id_user_id_idx"
pg_dump: creating INDEX "auth.refresh_tokens_parent_idx"
pg_dump: creating INDEX "auth.refresh_tokens_session_id_revoked_idx"
ype: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- TOC entry 4164 (class 1259 OID 18236)
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- TOC entry 4204 (class 1259 OID 18361)
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- TOC entry 4201 (class 1259 OID 18314)
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- TOC entry 4211 (class 1259 OID 18387)
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- TOC entry 4212 (class 1259 OID 18385)
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- TOC entry 4217 (class 1259 OID 18386)
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- TOC entry 4198 (class 1259 OID 18283)
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- TOC entry 4199 (class 1259 OID 18282)
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- TOC entry 4200 (class 1259 OID 18284)
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- TOC entry 4060 (class 1259 OID 18038)
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 4061 (class 1259 OID 18035)
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 4070 (class 1259 OID 16478)
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- TOC entry 4071 (class 1259 OID 16479)
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- TOC entry 4072 (class 1259 OID 18029)
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- TOC entry 4075 (class 1259 OID 18121)
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked)pg_dump: creating INDEX "auth.refresh_tokens_updated_at_idx"
pg_dump: creating INDEX "auth.saml_providers_sso_provider_id_idx"
pg_dump: creating INDEX "auth.saml_relay_states_created_at_idx"
pg_dump: creating INDEX "auth.saml_relay_states_for_email_idx"
pg_dump: creating INDEX "auth.saml_relay_states_sso_provider_id_idx"
pg_dump: creating INDEX "auth.sessions_not_after_idx"
pg_dump: creating INDEX "auth.sessions_oauth_client_id_idx"
pg_dump: creating INDEX "auth.sessions_user_id_idx"
pg_dump: creating INDEX "auth.sso_domains_domain_idx"
pg_dump: creating INDEX "auth.sso_domains_sso_provider_id_idx"
pg_dump: creating INDEX "auth.sso_providers_resource_id_idx"
pg_dump: creating INDEX "auth.sso_providers_resource_id_pattern_idx"
pg_dump: creating INDEX "auth.unique_phone_factor_per_user"
pg_dump: creating INDEX "auth.user_id_created_at_idx"
pg_dump: creating INDEX "auth.users_email_partial_key"
pg_dump: creating COMMENT "auth.INDEX users_email_partial_key"
pg_dump: creating INDEX "auth.users_instance_id_email_idx"
;


--
-- TOC entry 4078 (class 1259 OID 18226)
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- TOC entry 4185 (class 1259 OID 18163)
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- TOC entry 4186 (class 1259 OID 18228)
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- TOC entry 4187 (class 1259 OID 18178)
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- TOC entry 4190 (class 1259 OID 18177)
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- TOC entry 4152 (class 1259 OID 18229)
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- TOC entry 4153 (class 1259 OID 18399)
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- TOC entry 4156 (class 1259 OID 18120)
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- TOC entry 4177 (class 1259 OID 18145)
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- TOC entry 4180 (class 1259 OID 18144)
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- TOC entry 4175 (class 1259 OID 18130)
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- TOC entry 4176 (class 1259 OID 18292)
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- TOC entry 4165 (class 1259 OID 18289)
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- TOC entry 4157 (class 1259 OID 18118)
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- TOC entry 4062 (class 1259 OID 18198)
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- TOC entry 4943 (class 0 OID 0)
-- Dependencies: 4062
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- TOC entry 4063 (class 1259 OID 18031)
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USIpg_dump: creating INDEX "auth.users_instance_id_idx"
pg_dump: creating INDEX "auth.users_is_anonymous_idx"
pg_dump: creating INDEX "auth.webauthn_challenges_expires_at_idx"
pg_dump: creating INDEX "auth.webauthn_challenges_user_id_idx"
pg_dump: creating INDEX "auth.webauthn_credentials_credential_id_key"
pg_dump: creating INDEX "auth.webauthn_credentials_user_id_idx"
pg_dump: creating INDEX "public.idx_analytics_events_created_at"
pg_dump: creating INDEX "public.idx_analytics_events_user_id"
pg_dump: creating INDEX "public.idx_feedback_created_at"
pg_dump: creating INDEX "public.idx_feedback_module_id"
pg_dump: creating INDEX "public.idx_feedback_user_id"
pg_dump: creating INDEX "public.idx_module_quiz_attempts_module"
pg_dump: creating INDEX "public.idx_module_quiz_attempts_user"
pg_dump: creating INDEX "public.idx_scenario_options_scenario_id"
pg_dump: creating INDEX "public.idx_scenario_responses_created_at"
pg_dump: creating INDEX "public.idx_scenario_responses_user_id"
pg_dump: creating INDEX "public.idx_scenarios_unit_id"
pg_dump: creating INDEX "public.idx_session_events_user"
NG btree (instance_id, lower((email)::text));


--
-- TOC entry 4064 (class 1259 OID 16468)
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- TOC entry 4065 (class 1259 OID 18253)
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- TOC entry 4233 (class 1259 OID 18493)
-- Name: webauthn_challenges_expires_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);


--
-- TOC entry 4236 (class 1259 OID 18492)
-- Name: webauthn_challenges_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);


--
-- TOC entry 4229 (class 1259 OID 18475)
-- Name: webauthn_credentials_credential_id_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);


--
-- TOC entry 4232 (class 1259 OID 18476)
-- Name: webauthn_credentials_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);


--
-- TOC entry 4296 (class 1259 OID 18892)
-- Name: idx_analytics_events_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analytics_events_created_at ON public.analytics_events USING btree (created_at DESC);


--
-- TOC entry 4297 (class 1259 OID 18891)
-- Name: idx_analytics_events_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analytics_events_user_id ON public.analytics_events USING btree (user_id, created_at DESC);


--
-- TOC entry 4306 (class 1259 OID 18969)
-- Name: idx_feedback_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedback_created_at ON public.feedback USING btree (created_at DESC);


--
-- TOC entry 4307 (class 1259 OID 18970)
-- Name: idx_feedback_module_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedback_module_id ON public.feedback USING btree (module_id) WHERE (module_id IS NOT NULL);


--
-- TOC entry 4308 (class 1259 OID 18971)
-- Name: idx_feedback_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedback_user_id ON public.feedback USING btree (user_id);


--
-- TOC entry 4298 (class 1259 OID 18936)
-- Name: idx_module_quiz_attempts_module; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_module_quiz_attempts_module ON public.module_quiz_attempts USING btree (module_id);


--
-- TOC entry 4299 (class 1259 OID 18935)
-- Name: idx_module_quiz_attempts_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_module_quiz_attempts_user ON public.module_quiz_attempts USING btree (user_id);


--
-- TOC entry 4285 (class 1259 OID 18888)
-- Name: idx_scenario_options_scenario_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scenario_options_scenario_id ON public.scenario_options USING btree (scenario_id);


--
-- TOC entry 4290 (class 1259 OID 18890)
-- Name: idx_scenario_responses_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scenario_responses_created_at ON public.scenario_responses USING btree (created_at DESC);


--
-- TOC entry 4291 (class 1259 OID 18889)
-- Name: idx_scenario_responses_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scenario_responses_user_id ON public.scenario_responses USING btree (user_id, scenario_id);


--
-- TOC entry 4282 (class 1259 OID 18887)
-- Name: idx_scenarios_unit_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scenarios_unit_id ON public.scenarios USING btree (unit_id, order_number);


--
-- TOC entry 4270 (class 1259 OID 18738)
-- Name: idxpg_dump: creating INDEX "public.idx_training_progress_user"
pg_dump: creating INDEX "public.idx_user_regions_user_id"
pg_dump: creating INDEX "realtime.ix_realtime_subscription_entity"
pg_dump: creating INDEX "realtime.messages_inserted_at_topic_index"
pg_dump: creating INDEX "realtime.messages_2026_06_06_inserted_at_topic_idx"
pg_dump: creating INDEX "realtime.messages_2026_06_07_inserted_at_topic_idx"
pg_dump: creating INDEX "realtime.messages_2026_06_08_inserted_at_topic_idx"
pg_dump: creating INDEX "realtime.messages_2026_06_09_inserted_at_topic_idx"
pg_dump: creating INDEX "realtime.messages_2026_06_10_inserted_at_topic_idx"
pg_dump: creating INDEX "realtime.messages_2026_06_11_inserted_at_topic_idx"
pg_dump: creating INDEX "realtime.messages_2026_06_12_inserted_at_topic_idx"
pg_dump: creating INDEX "realtime.subscription_subscription_id_entity_filters_key"
pg_dump: creating INDEX "storage.bname"
pg_dump: creating INDEX "storage.bucketid_objname"
_session_events_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_session_events_user ON public.session_events USING btree (user_id, created_at DESC);


--
-- TOC entry 4245 (class 1259 OID 18739)
-- Name: idx_training_progress_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_training_progress_user ON public.training_progress USING btree (user_id, training_id);


--
-- TOC entry 4277 (class 1259 OID 18893)
-- Name: idx_user_regions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_regions_user_id ON public.user_regions USING btree (user_id);


--
-- TOC entry 4106 (class 1259 OID 17533)
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- TOC entry 4110 (class 1259 OID 17542)
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 4309 (class 1259 OID 65934)
-- Name: messages_2026_06_06_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_06_06_inserted_at_topic_idx ON realtime.messages_2026_06_06 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 4312 (class 1259 OID 65946)
-- Name: messages_2026_06_07_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_06_07_inserted_at_topic_idx ON realtime.messages_2026_06_07 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 4315 (class 1259 OID 74090)
-- Name: messages_2026_06_08_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_06_08_inserted_at_topic_idx ON realtime.messages_2026_06_08 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 4318 (class 1259 OID 74102)
-- Name: messages_2026_06_09_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_06_09_inserted_at_topic_idx ON realtime.messages_2026_06_09 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 4321 (class 1259 OID 74114)
-- Name: messages_2026_06_10_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_06_10_inserted_at_topic_idx ON realtime.messages_2026_06_10 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 4324 (class 1259 OID 74126)
-- Name: messages_2026_06_11_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_06_11_inserted_at_topic_idx ON realtime.messages_2026_06_11 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 4327 (class 1259 OID 74138)
-- Name: messages_2026_06_12_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_06_12_inserted_at_topic_idx ON realtime.messages_2026_06_12 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 4109 (class 1259 OID 17220)
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- TOC entry 4117 (class 1259 OID 17770)
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- TOC enpg_dump: creating INDEX "storage.buckets_analytics_unique_name_idx"
pg_dump: creating INDEX "storage.idx_iceberg_namespaces_bucket_id"
pg_dump: creating INDEX "storage.idx_iceberg_tables_location"
pg_dump: creating INDEX "storage.idx_iceberg_tables_namespace_id"
pg_dump: creating INDEX "storage.idx_multipart_uploads_list"
pg_dump: creating INDEX "storage.idx_objects_bucket_id_name"
pg_dump: creating INDEX "storage.idx_objects_bucket_id_name_lower"
pg_dump: creating INDEX "storage.name_prefix_search"
pg_dump: creating INDEX "storage.vector_indexes_name_bucket_id_idx"
pg_dump: creating INDEX "supabase_functions.supabase_functions_hooks_h_table_id_h_name_idx"
pg_dump: creating INDEX "supabase_functions.supabase_functions_hooks_request_id_idx"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_06_inserted_at_topic_idx"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_06_pkey"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_07_inserted_at_topic_idx"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_07_pkey"
try 4120 (class 1259 OID 17787)
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- TOC entry 4133 (class 1259 OID 17964)
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- TOC entry 4136 (class 1259 OID 17975)
-- Name: idx_iceberg_namespaces_bucket_id; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_iceberg_namespaces_bucket_id ON storage.iceberg_namespaces USING btree (catalog_id, name);


--
-- TOC entry 4139 (class 1259 OID 17977)
-- Name: idx_iceberg_tables_location; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_iceberg_tables_location ON storage.iceberg_tables USING btree (location);


--
-- TOC entry 4140 (class 1259 OID 17976)
-- Name: idx_iceberg_tables_namespace_id; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_iceberg_tables_namespace_id ON storage.iceberg_tables USING btree (catalog_id, namespace_id, name);


--
-- TOC entry 4126 (class 1259 OID 17854)
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- TOC entry 4121 (class 1259 OID 17819)
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- TOC entry 4122 (class 1259 OID 17984)
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- TOC entry 4123 (class 1259 OID 17788)
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- TOC entry 4143 (class 1259 OID 17954)
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- TOC entry 4093 (class 1259 OID 16731)
-- Name: supabase_functions_hooks_h_table_id_h_name_idx; Type: INDEX; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE INDEX supabase_functions_hooks_h_table_id_h_name_idx ON supabase_functions.hooks USING btree (hook_table_id, hook_name);


--
-- TOC entry 4094 (class 1259 OID 16730)
-- Name: supabase_functions_hooks_request_id_idx; Type: INDEX; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE INDEX supabase_functions_hooks_request_id_idx ON supabase_functions.hooks USING btree (request_id);


--
-- TOC entry 4330 (class 0 OID 0)
-- Name: messages_2026_06_06_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_06_06_inserted_at_topic_idx;


--
-- TOC entry 4331 (class 0 OID 0)
-- Name: messages_2026_06_06_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_06_06_pkey;


--
-- TOC entry 4332 (class 0 OID 0)
-- Name: messages_2026_06_07_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_06_07_inserted_at_topic_idx;


--
-- TOC entry 4333 (class 0 OID 0)
-- Name: messages_2026_06_07_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_08_inserted_at_topic_idx"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_08_pkey"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_09_inserted_at_topic_idx"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_09_pkey"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_10_inserted_at_topic_idx"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_10_pkey"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_11_inserted_at_topic_idx"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_11_pkey"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_12_inserted_at_topic_idx"
pg_dump: creating INDEX ATTACH "realtime.messages_2026_06_12_pkey"
pg_dump: creating TRIGGER "auth.users on_auth_user_created"
pg_dump: creating TRIGGER "public.module_quiz_attempts trg_module_quiz_attempts_updated_at"
pg_dump: creating TRIGGER "public.modules update_modules_updated_at"
pg_dump: creating TRIGGER "public.profiles update_profiles_updated_at"
pg_dump: creating TRIGGER "realtime.subscription tr_check_filters"

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_06_07_pkey;


--
-- TOC entry 4334 (class 0 OID 0)
-- Name: messages_2026_06_08_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_06_08_inserted_at_topic_idx;


--
-- TOC entry 4335 (class 0 OID 0)
-- Name: messages_2026_06_08_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_06_08_pkey;


--
-- TOC entry 4336 (class 0 OID 0)
-- Name: messages_2026_06_09_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_06_09_inserted_at_topic_idx;


--
-- TOC entry 4337 (class 0 OID 0)
-- Name: messages_2026_06_09_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_06_09_pkey;


--
-- TOC entry 4338 (class 0 OID 0)
-- Name: messages_2026_06_10_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_06_10_inserted_at_topic_idx;


--
-- TOC entry 4339 (class 0 OID 0)
-- Name: messages_2026_06_10_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_06_10_pkey;


--
-- TOC entry 4340 (class 0 OID 0)
-- Name: messages_2026_06_11_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_06_11_inserted_at_topic_idx;


--
-- TOC entry 4341 (class 0 OID 0)
-- Name: messages_2026_06_11_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_06_11_pkey;


--
-- TOC entry 4342 (class 0 OID 0)
-- Name: messages_2026_06_12_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_06_12_inserted_at_topic_idx;


--
-- TOC entry 4343 (class 0 OID 0)
-- Name: messages_2026_06_12_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_06_12_pkey;


--
-- TOC entry 4397 (class 2620 OID 18649)
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- TOC entry 4405 (class 2620 OID 18942)
-- Name: module_quiz_attempts trg_module_quiz_attempts_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_module_quiz_attempts_updated_at BEFORE UPDATE ON public.module_quiz_attempts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_module_quiz_attempts();


--
-- TOC entry 4404 (class 2620 OID 18704)
-- Name: modules update_modules_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_modules_updated_at BEFORE UPDATE ON public.modules FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4403 (class 2620 OID 18647)
-- Name: profiles update_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 4398 (class 2620 OID 17128)
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECpg_dump: creating TRIGGER "storage.buckets enforce_bucket_name_length_trigger"
pg_dump: creating TRIGGER "storage.buckets protect_buckets_delete"
pg_dump: creating TRIGGER "storage.objects protect_objects_delete"
pg_dump: creating TRIGGER "storage.objects update_objects_updated_at"
pg_dump: creating FK CONSTRAINT "_realtime.extensions extensions_tenant_external_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.identities identities_user_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.mfa_amr_claims mfa_amr_claims_session_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.mfa_challenges mfa_challenges_auth_factor_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.mfa_factors mfa_factors_user_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.oauth_authorizations oauth_authorizations_client_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.oauth_authorizations oauth_authorizations_user_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.oauth_consents oauth_consents_client_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.oauth_consents oauth_consents_user_id_fkey"
UTE FUNCTION realtime.subscription_check_filters();


--
-- TOC entry 4399 (class 2620 OID 17873)
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- TOC entry 4400 (class 2620 OID 17986)
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- TOC entry 4401 (class 2620 OID 17987)
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- TOC entry 4402 (class 2620 OID 17807)
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- TOC entry 4345 (class 2606 OID 16791)
-- Name: extensions extensions_tenant_external_id_fkey; Type: FK CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_tenant_external_id_fkey FOREIGN KEY (tenant_external_id) REFERENCES _realtime.tenants(external_id) ON DELETE CASCADE;


--
-- TOC entry 4354 (class 2606 OID 18017)
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4359 (class 2606 OID 18109)
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- TOC entry 4358 (class 2606 OID 18097)
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- TOC entry 4357 (class 2606 OID 18084)
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4365 (class 2606 OID 18351)
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- TOC entry 4366 (class 2606 OID 18356)
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4367 (class 2606 OID 18380)
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- TOC entry 4368 (class 2606 OID 18375)
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_cpg_dump: creating FK CONSTRAINT "auth.one_time_tokens one_time_tokens_user_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.refresh_tokens refresh_tokens_session_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.saml_providers saml_providers_sso_provider_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.saml_relay_states saml_relay_states_flow_state_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.saml_relay_states saml_relay_states_sso_provider_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.sessions sessions_oauth_client_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.sessions sessions_user_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.sso_domains sso_domains_sso_provider_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.webauthn_challenges webauthn_challenges_user_id_fkey"
pg_dump: creating FK CONSTRAINT "auth.webauthn_credentials webauthn_credentials_user_id_fkey"
pg_dump: creating FK CONSTRAINT "public.analytics_events analytics_events_scenario_id_fkey"
pg_dump: creating FK CONSTRAINT "public.analytics_events analytics_events_unit_id_fkey"
onsents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4364 (class 2606 OID 18277)
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4344 (class 2606 OID 18051)
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- TOC entry 4361 (class 2606 OID 18158)
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- TOC entry 4362 (class 2606 OID 18231)
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- TOC entry 4363 (class 2606 OID 18172)
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- TOC entry 4355 (class 2606 OID 18394)
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- TOC entry 4356 (class 2606 OID 18046)
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4360 (class 2606 OID 18139)
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- TOC entry 4370 (class 2606 OID 18487)
-- Name: webauthn_challenges webauthn_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4369 (class 2606 OID 18470)
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4389 (class 2606 OID 18877)
-- Name: analytics_events analytics_events_scenario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE SET NULL;


--
-- TOC entry 4390 (class 2606 OID 18882)
-- Name: analytics_events analytics_events_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.trainings(id)pg_dump: creating FK CONSTRAINT "public.analytics_events analytics_events_user_id_fkey"
pg_dump: creating FK CONSTRAINT "public.assessments assessments_training_id_fkey"
pg_dump: creating FK CONSTRAINT "public.certificates certificates_user_id_fkey"
pg_dump: creating FK CONSTRAINT "public.feedback feedback_module_id_fkey"
pg_dump: creating FK CONSTRAINT "public.feedback feedback_training_id_fkey"
pg_dump: creating FK CONSTRAINT "public.feedback feedback_user_id_fkey"
pg_dump: creating FK CONSTRAINT "public.module_quiz_attempts module_quiz_attempts_module_id_fkey"
pg_dump: creating FK CONSTRAINT "public.module_quiz_attempts module_quiz_attempts_user_id_fkey"
pg_dump: creating FK CONSTRAINT "public.options options_question_id_fkey"
pg_dump: creating FK CONSTRAINT "public.profiles profiles_id_fkey"
pg_dump: creating FK CONSTRAINT "public.questions questions_assessment_id_fkey"
pg_dump: creating FK CONSTRAINT "public.regions regions_parent_id_fkey"
pg_dump: creating FK CONSTRAINT "public.scenario_options scenario_options_scenario_id_fkey"
pg_dump: creating FK CONSTRAINT "public.scenario_responses scenario_responses_scenario_id_fkey"
 ON DELETE SET NULL;


--
-- TOC entry 4391 (class 2606 OID 18872)
-- Name: analytics_events analytics_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- TOC entry 4376 (class 2606 OID 18586)
-- Name: assessments assessments_training_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_training_id_fkey FOREIGN KEY (training_id) REFERENCES public.trainings(id) ON DELETE CASCADE;


--
-- TOC entry 4379 (class 2606 OID 18639)
-- Name: certificates certificates_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4394 (class 2606 OID 18959)
-- Name: feedback feedback_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id) ON DELETE SET NULL;


--
-- TOC entry 4395 (class 2606 OID 18964)
-- Name: feedback feedback_training_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_training_id_fkey FOREIGN KEY (training_id) REFERENCES public.trainings(id) ON DELETE SET NULL;


--
-- TOC entry 4396 (class 2606 OID 18954)
-- Name: feedback feedback_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4392 (class 2606 OID 18930)
-- Name: module_quiz_attempts module_quiz_attempts_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.module_quiz_attempts
    ADD CONSTRAINT module_quiz_attempts_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id) ON DELETE CASCADE;


--
-- TOC entry 4393 (class 2606 OID 18925)
-- Name: module_quiz_attempts module_quiz_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.module_quiz_attempts
    ADD CONSTRAINT module_quiz_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4378 (class 2606 OID 18620)
-- Name: options options_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.options
    ADD CONSTRAINT options_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- TOC entry 4371 (class 2606 OID 18516)
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4377 (class 2606 OID 18604)
-- Name: questions questions_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE CASCADE;


--
-- TOC entry 4382 (class 2606 OID 18780)
-- Name: regions regions_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.regions(id) ON DELETE SET NULL;


--
-- TOC entry 4386 (class 2606 OID 18838)
-- Name: scenario_options scenario_options_scenario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenario_options
    ADD CONSTRAINT scenario_options_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE CASCADE;


--
-- TOC entry 4387 (class 2606 OID 18857)
-- Name: scenario_respopg_dump: creating FK CONSTRAINT "public.scenario_responses scenario_responses_user_id_fkey"
pg_dump: creating FK CONSTRAINT "public.scenarios scenarios_unit_id_fkey"
pg_dump: creating FK CONSTRAINT "public.session_events session_events_training_id_fkey"
pg_dump: creating FK CONSTRAINT "public.session_events session_events_user_id_fkey"
pg_dump: creating FK CONSTRAINT "public.training_content training_content_training_id_fkey"
pg_dump: creating FK CONSTRAINT "public.training_progress training_progress_training_id_fkey"
pg_dump: creating FK CONSTRAINT "public.training_progress training_progress_user_id_fkey"
pg_dump: creating FK CONSTRAINT "public.trainings trainings_module_id_fkey"
pg_dump: creating FK CONSTRAINT "public.user_regions user_regions_region_id_fkey"
pg_dump: creating FK CONSTRAINT "public.user_regions user_regions_user_id_fkey"
pg_dump: creating FK CONSTRAINT "storage.iceberg_namespaces iceberg_namespaces_catalog_id_fkey"
pg_dump: creating FK CONSTRAINT "storage.iceberg_tables iceberg_tables_catalog_id_fkey"
nses scenario_responses_scenario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenario_responses
    ADD CONSTRAINT scenario_responses_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE CASCADE;


--
-- TOC entry 4388 (class 2606 OID 18852)
-- Name: scenario_responses scenario_responses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenario_responses
    ADD CONSTRAINT scenario_responses_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4385 (class 2606 OID 18819)
-- Name: scenarios scenarios_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenarios
    ADD CONSTRAINT scenarios_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.trainings(id) ON DELETE CASCADE;


--
-- TOC entry 4380 (class 2606 OID 18728)
-- Name: session_events session_events_training_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_events
    ADD CONSTRAINT session_events_training_id_fkey FOREIGN KEY (training_id) REFERENCES public.trainings(id) ON DELETE SET NULL;


--
-- TOC entry 4381 (class 2606 OID 18723)
-- Name: session_events session_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_events
    ADD CONSTRAINT session_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4373 (class 2606 OID 18546)
-- Name: training_content training_content_training_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_content
    ADD CONSTRAINT training_content_training_id_fkey FOREIGN KEY (training_id) REFERENCES public.trainings(id) ON DELETE CASCADE;


--
-- TOC entry 4374 (class 2606 OID 18567)
-- Name: training_progress training_progress_training_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_progress
    ADD CONSTRAINT training_progress_training_id_fkey FOREIGN KEY (training_id) REFERENCES public.trainings(id) ON DELETE CASCADE;


--
-- TOC entry 4375 (class 2606 OID 18562)
-- Name: training_progress training_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.training_progress
    ADD CONSTRAINT training_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4372 (class 2606 OID 18695)
-- Name: trainings trainings_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT trainings_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.modules(id) ON DELETE SET NULL;


--
-- TOC entry 4383 (class 2606 OID 18799)
-- Name: user_regions user_regions_region_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_regions
    ADD CONSTRAINT user_regions_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id) ON DELETE CASCADE;


--
-- TOC entry 4384 (class 2606 OID 18794)
-- Name: user_regions user_regions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_regions
    ADD CONSTRAINT user_regions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 4350 (class 2606 OID 17965)
-- Name: iceberg_namespaces iceberg_namespaces_catalog_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_namespaces
    ADD CONSTRAINT iceberg_namespaces_catalog_id_fkey FOREIGN KEY (catalog_id) REFERENCES storage.buckets_analytics(id) ON DELETE CASCADE;


--
-- TOC entry 4351 (class 2606 OID 17970)
-- Name: iceberg_tables iceberg_tables_catalog_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_catalog_id_fkey FOREIGN KEY (catalog_id) REFEpg_dump: creating FK CONSTRAINT "storage.iceberg_tables iceberg_tables_namespace_id_fkey"
pg_dump: creating FK CONSTRAINT "storage.objects objects_bucketId_fkey"
pg_dump: creating FK CONSTRAINT "storage.s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey"
pg_dump: creating FK CONSTRAINT "storage.s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey"
pg_dump: creating FK CONSTRAINT "storage.s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey"
pg_dump: creating FK CONSTRAINT "storage.vector_indexes vector_indexes_bucket_id_fkey"
pg_dump: creating ROW SECURITY "auth.audit_log_entries"
pg_dump: creating ROW SECURITY "auth.flow_state"
pg_dump: creating ROW SECURITY "auth.identities"
pg_dump: creating ROW SECURITY "auth.instances"
pg_dump: creating ROW SECURITY "auth.mfa_amr_claims"
pg_dump: creating ROW SECURITY "auth.mfa_challenges"
pg_dump: creating ROW SECURITY "auth.mfa_factors"
pg_dump: creating ROW SECURITY "auth.one_time_tokens"
pg_dump: creating ROW SECURITY "auth.refresh_tokens"
pg_dump: creating ROW SECURITY "auth.saml_providers"
RENCES storage.buckets_analytics(id) ON DELETE CASCADE;


--
-- TOC entry 4352 (class 2606 OID 17917)
-- Name: iceberg_tables iceberg_tables_namespace_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_namespace_id_fkey FOREIGN KEY (namespace_id) REFERENCES storage.iceberg_namespaces(id) ON DELETE CASCADE;


--
-- TOC entry 4346 (class 2606 OID 17782)
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 4347 (class 2606 OID 17829)
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 4348 (class 2606 OID 17849)
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 4349 (class 2606 OID 17844)
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- TOC entry 4353 (class 2606 OID 17949)
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- TOC entry 4557 (class 0 OID 16488)
-- Dependencies: 239
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4579 (class 0 OID 18217)
-- Dependencies: 283
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4570 (class 0 OID 18010)
-- Dependencies: 274
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4556 (class 0 OID 16481)
-- Dependencies: 238
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4574 (class 0 OID 18102)
-- Dependencies: 278
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4573 (class 0 OID 18090)
-- Dependencies: 277
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4572 (class 0 OID 18077)
-- Dependencies: 276
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4580 (class 0 OID 18267)
-- Dependencies: 284
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4555 (class 0 OID 16470)
-- Dependencies: 237
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4577 (class 0 OID 18146)
-- Dependencies: 281
-- Name: saml_ppg_dump: creating ROW SECURITY "auth.saml_relay_states"
pg_dump: creating ROW SECURITY "auth.schema_migrations"
pg_dump: creating ROW SECURITY "auth.sessions"
pg_dump: creating ROW SECURITY "auth.sso_domains"
pg_dump: creating ROW SECURITY "auth.sso_providers"
pg_dump: creating ROW SECURITY "auth.users"
pg_dump: creating POLICY "public.modules Admins can delete modules"
pg_dump: creating POLICY "public.options Admins can delete options"
pg_dump: creating POLICY "public.questions Admins can delete questions"
pg_dump: creating POLICY "public.training_content Admins can delete training content"
pg_dump: creating POLICY "public.trainings Admins can delete trainings"
pg_dump: creating POLICY "public.assessments Admins can insert assessments"
pg_dump: creating POLICY "public.modules Admins can insert modules"
pg_dump: creating POLICY "public.options Admins can insert options"
pg_dump: creating POLICY "public.questions Admins can insert questions"
pg_dump: creating POLICY "public.training_content Admins can insert training content"
roviders; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4578 (class 0 OID 18164)
-- Dependencies: 282
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4558 (class 0 OID 16496)
-- Dependencies: 240
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4571 (class 0 OID 18041)
-- Dependencies: 275
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4576 (class 0 OID 18131)
-- Dependencies: 280
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4575 (class 0 OID 18122)
-- Dependencies: 279
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4554 (class 0 OID 16458)
-- Dependencies: 235
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4629 (class 3256 OID 18694)
-- Name: modules Admins can delete modules; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can delete modules" ON public.modules FOR DELETE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4621 (class 3256 OID 18674)
-- Name: options Admins can delete options; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can delete options" ON public.options FOR DELETE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4618 (class 3256 OID 18671)
-- Name: questions Admins can delete questions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can delete questions" ON public.questions FOR DELETE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4623 (class 3256 OID 18676)
-- Name: training_content Admins can delete training content; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can delete training content" ON public.training_content FOR DELETE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4625 (class 3256 OID 18678)
-- Name: trainings Admins can delete trainings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can delete trainings" ON public.trainings FOR DELETE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4614 (class 3256 OID 18667)
-- Name: assessments Admins can insert assessments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can insert assessments" ON public.assessments FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4627 (class 3256 OID 18692)
-- Name: modules Admins can insert modules; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can insert modules" ON public.modules FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4619 (class 3256 OID 18672)
-- Name: options Admins can insert options; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can insert options" ON public.options FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4616 (class 3256 OID 18669)
-- Name: questions Admins can insert questions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can insert questions" ON public.questions FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4622 (class 3256 OID 18675)
-- Name: training_content Admins can insert training content; Type: POLICY; Schema: public; Owner: postgres
-pg_dump: creating POLICY "public.trainings Admins can insert trainings"
pg_dump: creating POLICY "public.scenarios Admins can manage all scenarios"
pg_dump: creating POLICY "public.regions Admins can manage regions"
pg_dump: creating POLICY "public.scenario_options Admins can manage scenario options"
pg_dump: creating POLICY "public.user_regions Admins can manage user_regions"
pg_dump: creating POLICY "public.analytics_events Admins can read all analytics"
pg_dump: creating POLICY "public.session_events Admins can read all events"
pg_dump: creating POLICY "public.feedback Admins can read all feedback"
pg_dump: creating POLICY "public.scenario_responses Admins can read all responses"
pg_dump: creating POLICY "public.assessments Admins can update assessments"
pg_dump: creating POLICY "public.modules Admins can update modules"
pg_dump: creating POLICY "public.options Admins can update options"
pg_dump: creating POLICY "public.questions Admins can update questions"
pg_dump: creating POLICY "public.trainings Admins can update trainings"
-

CREATE POLICY "Admins can insert training content" ON public.training_content FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4624 (class 3256 OID 18677)
-- Name: trainings Admins can insert trainings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can insert trainings" ON public.trainings FOR INSERT WITH CHECK (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4644 (class 3256 OID 18899)
-- Name: scenarios Admins can manage all scenarios; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage all scenarios" ON public.scenarios USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4640 (class 3256 OID 18895)
-- Name: regions Admins can manage regions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage regions" ON public.regions USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4646 (class 3256 OID 18901)
-- Name: scenario_options Admins can manage scenario options; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage scenario options" ON public.scenario_options USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4642 (class 3256 OID 18897)
-- Name: user_regions Admins can manage user_regions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage user_regions" ON public.user_regions USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4652 (class 3256 OID 18907)
-- Name: analytics_events Admins can read all analytics; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can read all analytics" ON public.analytics_events FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4636 (class 3256 OID 18735)
-- Name: session_events Admins can read all events; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can read all events" ON public.session_events FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4659 (class 3256 OID 18974)
-- Name: feedback Admins can read all feedback; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can read all feedback" ON public.feedback FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4649 (class 3256 OID 18904)
-- Name: scenario_responses Admins can read all responses; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can read all responses" ON public.scenario_responses FOR SELECT USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4615 (class 3256 OID 18668)
-- Name: assessments Admins can update assessments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can update assessments" ON public.assessments FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4628 (class 3256 OID 18693)
-- Name: modules Admins can update modules; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can update modules" ON public.modules FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4620 (class 3256 OID 18673)
-- Name: options Admins can update options; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can update options" ON public.options FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4617 (class 3256 OID 18670)
-- Name: questions Admins can update questions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can update questions" ON public.questions FOR UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4630 (class 3256 OID 18700)
-- Name: trainings Admins can update trainings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can update trainings" ON public.trainings FOR pg_dump: creating POLICY "public.module_quiz_attempts Admins can view all quiz attempts"
pg_dump: creating POLICY "public.regions Anyone authenticated can read regions"
pg_dump: creating POLICY "public.assessments Anyone authenticated can view assessments"
pg_dump: creating POLICY "public.modules Anyone authenticated can view modules"
pg_dump: creating POLICY "public.options Anyone authenticated can view options"
pg_dump: creating POLICY "public.questions Anyone authenticated can view questions"
pg_dump: creating POLICY "public.training_content Anyone authenticated can view training content"
pg_dump: creating POLICY "public.trainings Anyone authenticated can view trainings"
pg_dump: creating POLICY "public.scenarios Authenticated users can read active scenarios"
pg_dump: creating POLICY "public.scenario_options Authenticated users can read scenario options"
pg_dump: creating POLICY "public.certificates Users can insert own certificates"
pg_dump: creating POLICY "public.analytics_events Users can insert own events"
pg_dump: creating POLICY "public.session_events Users can insert own events"
pg_dump: creating POLICY "public.feedback Users can insert own feedback"
pg_dump: creating POLICY "public.profiles Users can insert own profile"
UPDATE USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4656 (class 3256 OID 18940)
-- Name: module_quiz_attempts Admins can view all quiz attempts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can view all quiz attempts" ON public.module_quiz_attempts FOR SELECT TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- TOC entry 4639 (class 3256 OID 18894)
-- Name: regions Anyone authenticated can read regions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone authenticated can read regions" ON public.regions FOR SELECT USING ((auth.uid() IS NOT NULL));


--
-- TOC entry 4608 (class 3256 OID 18591)
-- Name: assessments Anyone authenticated can view assessments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone authenticated can view assessments" ON public.assessments FOR SELECT TO authenticated USING (true);


--
-- TOC entry 4626 (class 3256 OID 18691)
-- Name: modules Anyone authenticated can view modules; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone authenticated can view modules" ON public.modules FOR SELECT USING (true);


--
-- TOC entry 4610 (class 3256 OID 18625)
-- Name: options Anyone authenticated can view options; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone authenticated can view options" ON public.options FOR SELECT TO authenticated USING (true);


--
-- TOC entry 4609 (class 3256 OID 18609)
-- Name: questions Anyone authenticated can view questions; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone authenticated can view questions" ON public.questions FOR SELECT TO authenticated USING (true);


--
-- TOC entry 4604 (class 3256 OID 18551)
-- Name: training_content Anyone authenticated can view training content; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone authenticated can view training content" ON public.training_content FOR SELECT TO authenticated USING (true);


--
-- TOC entry 4603 (class 3256 OID 18535)
-- Name: trainings Anyone authenticated can view trainings; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Anyone authenticated can view trainings" ON public.trainings FOR SELECT TO authenticated USING (true);


--
-- TOC entry 4643 (class 3256 OID 18898)
-- Name: scenarios Authenticated users can read active scenarios; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can read active scenarios" ON public.scenarios FOR SELECT USING (((auth.uid() IS NOT NULL) AND (is_active = true)));


--
-- TOC entry 4645 (class 3256 OID 18900)
-- Name: scenario_options Authenticated users can read scenario options; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Authenticated users can read scenario options" ON public.scenario_options FOR SELECT USING ((auth.uid() IS NOT NULL));


--
-- TOC entry 4612 (class 3256 OID 18645)
-- Name: certificates Users can insert own certificates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own certificates" ON public.certificates FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- TOC entry 4650 (class 3256 OID 18905)
-- Name: analytics_events Users can insert own events; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own events" ON public.analytics_events FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- TOC entry 4634 (class 3256 OID 18733)
-- Name: session_events Users can insert own events; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own events" ON public.session_events FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- TOC entry 4657 (class 3256 OID 18972)
-- Name: feedback Users can insert own feedback; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own feedback" ON public.feedback FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));


--
-- TOC entry 4602 (class 3256 OID 18523)
-- Name: profiles Users can ipg_dump: creating POLICY "public.training_progress Users can insert own progress"
pg_dump: creating POLICY "public.scenario_responses Users can insert own responses"
pg_dump: creating POLICY "public.module_quiz_attempts Users can insert their own quiz attempts"
pg_dump: creating POLICY "public.analytics_events Users can read own events"
pg_dump: creating POLICY "public.session_events Users can read own events"
pg_dump: creating POLICY "public.feedback Users can read own feedback"
pg_dump: creating POLICY "public.user_regions Users can read own region assignments"
pg_dump: creating POLICY "public.scenario_responses Users can read own responses"
pg_dump: creating POLICY "public.profiles Users can update own profile"
pg_dump: creating POLICY "public.training_progress Users can update own progress"
pg_dump: creating POLICY "public.module_quiz_attempts Users can update their own quiz attempts"
pg_dump: creating POLICY "public.certificates Users can view own certificates"
pg_dump: creating POLICY "public.profiles Users can view own profile"
pg_dump: creating POLICY "public.training_progress Users can view own progress"
pg_dump: creating POLICY "public.user_roles Users can view own roles"
nsert own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK ((auth.uid() = id));


--
-- TOC entry 4606 (class 3256 OID 18573)
-- Name: training_progress Users can insert own progress; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own progress" ON public.training_progress FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- TOC entry 4647 (class 3256 OID 18902)
-- Name: scenario_responses Users can insert own responses; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert own responses" ON public.scenario_responses FOR INSERT WITH CHECK ((auth.uid() = user_id));


--
-- TOC entry 4654 (class 3256 OID 18938)
-- Name: module_quiz_attempts Users can insert their own quiz attempts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can insert their own quiz attempts" ON public.module_quiz_attempts FOR INSERT TO authenticated WITH CHECK ((auth.uid() = user_id));


--
-- TOC entry 4651 (class 3256 OID 18906)
-- Name: analytics_events Users can read own events; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can read own events" ON public.analytics_events FOR SELECT USING ((auth.uid() = user_id));


--
-- TOC entry 4635 (class 3256 OID 18734)
-- Name: session_events Users can read own events; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can read own events" ON public.session_events FOR SELECT USING ((auth.uid() = user_id));


--
-- TOC entry 4658 (class 3256 OID 18973)
-- Name: feedback Users can read own feedback; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can read own feedback" ON public.feedback FOR SELECT TO authenticated USING ((auth.uid() = user_id));


--
-- TOC entry 4641 (class 3256 OID 18896)
-- Name: user_regions Users can read own region assignments; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can read own region assignments" ON public.user_regions FOR SELECT USING ((auth.uid() = user_id));


--
-- TOC entry 4648 (class 3256 OID 18903)
-- Name: scenario_responses Users can read own responses; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can read own responses" ON public.scenario_responses FOR SELECT USING ((auth.uid() = user_id));


--
-- TOC entry 4601 (class 3256 OID 18522)
-- Name: profiles Users can update own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING ((auth.uid() = id));


--
-- TOC entry 4607 (class 3256 OID 18574)
-- Name: training_progress Users can update own progress; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own progress" ON public.training_progress FOR UPDATE USING ((auth.uid() = user_id));


--
-- TOC entry 4655 (class 3256 OID 18939)
-- Name: module_quiz_attempts Users can update their own quiz attempts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update their own quiz attempts" ON public.module_quiz_attempts FOR UPDATE TO authenticated USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));


--
-- TOC entry 4611 (class 3256 OID 18644)
-- Name: certificates Users can view own certificates; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own certificates" ON public.certificates FOR SELECT USING ((auth.uid() = user_id));


--
-- TOC entry 4600 (class 3256 OID 18521)
-- Name: profiles Users can view own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING ((auth.uid() = id));


--
-- TOC entry 4605 (class 3256 OID 18572)
-- Name: training_progress Users can view own progress; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own progress" ON public.training_progress FOR SELECT USING ((auth.uid() = user_id));


--
-- TOC entry 4613 (class 3256 OID 18665)
-- Name: user_roles Uspg_dump: creating POLICY "public.module_quiz_attempts Users can view their own quiz attempts"
pg_dump: creating POLICY "public.profiles admin_read_all_profiles"
pg_dump: creating POLICY "public.training_progress admin_read_all_training_progress"
pg_dump: creating ROW SECURITY "public.analytics_events"
pg_dump: creating ROW SECURITY "public.assessments"
pg_dump: creating ROW SECURITY "public.certificates"
pg_dump: creating ROW SECURITY "public.feedback"
pg_dump: creating ROW SECURITY "public.module_quiz_attempts"
pg_dump: creating ROW SECURITY "public.modules"
pg_dump: creating ROW SECURITY "public.options"
pg_dump: creating ROW SECURITY "public.profiles"
pg_dump: creating ROW SECURITY "public.questions"
pg_dump: creating ROW SECURITY "public.regions"
pg_dump: creating ROW SECURITY "public.scenario_options"
pg_dump: creating ROW SECURITY "public.scenario_responses"
pg_dump: creating ROW SECURITY "public.scenarios"
pg_dump: creating ROW SECURITY "public.session_events"
pg_dump: creating ROW SECURITY "public.training_content"
ers can view own roles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own roles" ON public.user_roles FOR SELECT USING ((auth.uid() = user_id));


--
-- TOC entry 4653 (class 3256 OID 18937)
-- Name: module_quiz_attempts Users can view their own quiz attempts; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own quiz attempts" ON public.module_quiz_attempts FOR SELECT TO authenticated USING ((auth.uid() = user_id));


--
-- TOC entry 4637 (class 3256 OID 18759)
-- Name: profiles admin_read_all_profiles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY admin_read_all_profiles ON public.profiles FOR SELECT USING ((auth.uid() IN ( SELECT user_roles.user_id
   FROM public.user_roles
  WHERE (user_roles.role = 'admin'::public.app_role))));


--
-- TOC entry 4638 (class 3256 OID 18760)
-- Name: training_progress admin_read_all_training_progress; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY admin_read_all_training_progress ON public.training_progress FOR SELECT USING ((auth.uid() IN ( SELECT user_roles.user_id
   FROM public.user_roles
  WHERE (user_roles.role = 'admin'::public.app_role))));


--
-- TOC entry 4597 (class 0 OID 18862)
-- Dependencies: 309
-- Name: analytics_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4585 (class 0 OID 18575)
-- Dependencies: 297
-- Name: assessments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4588 (class 0 OID 18626)
-- Dependencies: 300
-- Name: certificates; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4599 (class 0 OID 18943)
-- Dependencies: 311
-- Name: feedback; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4598 (class 0 OID 18911)
-- Dependencies: 310
-- Name: module_quiz_attempts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.module_quiz_attempts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4590 (class 0 OID 18679)
-- Dependencies: 302
-- Name: modules; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4587 (class 0 OID 18610)
-- Dependencies: 299
-- Name: options; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.options ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4581 (class 0 OID 18502)
-- Dependencies: 293
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4586 (class 0 OID 18592)
-- Dependencies: 298
-- Name: questions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4592 (class 0 OID 18769)
-- Dependencies: 304
-- Name: regions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.regions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4595 (class 0 OID 18824)
-- Dependencies: 307
-- Name: scenario_options; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.scenario_options ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4596 (class 0 OID 18843)
-- Dependencies: 308
-- Name: scenario_responses; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.scenario_responses ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4594 (class 0 OID 18804)
-- Dependencies: 306
-- Name: scenarios; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.scenarios ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4591 (class 0 OID 18713)
-- Dependencies: 303
-- Name: session_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.session_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4583 (class 0 OID 18536)
-- Dependencies: 295
-- Name: training_contepg_dump: creating ROW SECURITY "public.training_progress"
pg_dump: creating ROW SECURITY "public.trainings"
pg_dump: creating ROW SECURITY "public.user_regions"
pg_dump: creating ROW SECURITY "public.user_roles"
pg_dump: creating ROW SECURITY "realtime.messages"
pg_dump: creating POLICY "storage.objects Admins can delete training videos"
pg_dump: creating POLICY "storage.objects Admins can upload training videos"
pg_dump: creating POLICY "storage.objects Authenticated users can view training videos"
pg_dump: creating ROW SECURITY "storage.buckets"
pg_dump: creating ROW SECURITY "storage.buckets_analytics"
pg_dump: creating ROW SECURITY "storage.buckets_vectors"
pg_dump: creating ROW SECURITY "storage.iceberg_namespaces"
pg_dump: creating ROW SECURITY "storage.iceberg_tables"
pg_dump: creating ROW SECURITY "storage.migrations"
pg_dump: creating ROW SECURITY "storage.objects"
pg_dump: creating ROW SECURITY "storage.s3_multipart_uploads"
pg_dump: creating ROW SECURITY "storage.s3_multipart_uploads_parts"
nt; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.training_content ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4584 (class 0 OID 18552)
-- Dependencies: 296
-- Name: training_progress; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.training_progress ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4582 (class 0 OID 18524)
-- Dependencies: 294
-- Name: trainings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.trainings ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4593 (class 0 OID 18785)
-- Dependencies: 305
-- Name: user_regions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_regions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4589 (class 0 OID 18655)
-- Dependencies: 301
-- Name: user_roles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4559 (class 0 OID 17518)
-- Dependencies: 263
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4633 (class 3256 OID 18703)
-- Name: objects Admins can delete training videos; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Admins can delete training videos" ON storage.objects FOR DELETE USING (((bucket_id = 'training-videos'::text) AND public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- TOC entry 4632 (class 3256 OID 18702)
-- Name: objects Admins can upload training videos; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Admins can upload training videos" ON storage.objects FOR INSERT WITH CHECK (((bucket_id = 'training-videos'::text) AND public.has_role(auth.uid(), 'admin'::public.app_role)));


--
-- TOC entry 4631 (class 3256 OID 18701)
-- Name: objects Authenticated users can view training videos; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Authenticated users can view training videos" ON storage.objects FOR SELECT USING (((bucket_id = 'training-videos'::text) AND (auth.role() = 'authenticated'::text)));


--
-- TOC entry 4561 (class 0 OID 17761)
-- Dependencies: 265
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4565 (class 0 OID 17880)
-- Dependencies: 269
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4568 (class 0 OID 17929)
-- Dependencies: 272
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4566 (class 0 OID 17891)
-- Dependencies: 270
-- Name: iceberg_namespaces; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.iceberg_namespaces ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4567 (class 0 OID 17907)
-- Dependencies: 271
-- Name: iceberg_tables; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.iceberg_tables ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4560 (class 0 OID 17753)
-- Dependencies: 264
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4562 (class 0 OID 17771)
-- Dependencies: 266
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4563 (class 0 OID 17820)
-- Dependencies: 267
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4564 (class 0 OID 17834)
-- Dependencies: 268
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage;pg_dump: creating ROW SECURITY "storage.vector_indexes"
pg_dump: creating PUBLICATION "supabase_realtime"
pg_dump: creating ACL "SCHEMA auth"
pg_dump: creating ACL "SCHEMA extensions"
pg_dump: creating ACL "SCHEMA net"
pg_dump: creating ACL "SCHEMA public"
pg_dump: creating ACL "SCHEMA realtime"
pg_dump: creating ACL "SCHEMA storage"
pg_dump: creating ACL "SCHEMA supabase_functions"
pg_dump: creating ACL "SCHEMA vault"
pg_dump: creating ACL "auth.FUNCTION email()"
pg_dump: creating ACL "auth.FUNCTION jwt()"
pg_dump: creating ACL "auth.FUNCTION role()"
pg_dump: creating ACL "auth.FUNCTION uid()"
 Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4569 (class 0 OID 17939)
-- Dependencies: 273
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 4660 (class 6104 OID 16388)
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- TOC entry 4736 (class 0 OID 0)
-- Dependencies: 22
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- TOC entry 4737 (class 0 OID 0)
-- Dependencies: 16
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- TOC entry 4739 (class 0 OID 0)
-- Dependencies: 15
-- Name: SCHEMA net; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA net TO supabase_functions_admin;
GRANT USAGE ON SCHEMA net TO postgres;
GRANT USAGE ON SCHEMA net TO anon;
GRANT USAGE ON SCHEMA net TO authenticated;
GRANT USAGE ON SCHEMA net TO service_role;


--
-- TOC entry 4740 (class 0 OID 0)
-- Dependencies: 13
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- TOC entry 4741 (class 0 OID 0)
-- Dependencies: 17
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- TOC entry 4742 (class 0 OID 0)
-- Dependencies: 23
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- TOC entry 4743 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA supabase_functions; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA supabase_functions TO postgres;
GRANT USAGE ON SCHEMA supabase_functions TO anon;
GRANT USAGE ON SCHEMA supabase_functions TO authenticated;
GRANT USAGE ON SCHEMA supabase_functions TO service_role;
GRANT ALL ON SCHEMA supabase_functions TO supabase_functions_admin;


--
-- TOC entry 4744 (class 0 OID 0)
-- Dependencies: 19
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;


--
-- TOC entry 4751 (class 0 OID 0)
-- Dependencies: 446
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- TOC entry 4752 (class 0 OID 0)
-- Dependencies: 442
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- TOC entry 4754 (class 0 OID 0)
-- Dependencies: 432
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- TOC entry 4756pg_dump: creating ACL "extensions.FUNCTION armor(bytea)"
pg_dump: creating ACL "extensions.FUNCTION armor(bytea, text[], text[])"
pg_dump: creating ACL "extensions.FUNCTION crypt(text, text)"
pg_dump: creating ACL "extensions.FUNCTION dearmor(text)"
pg_dump: creating ACL "extensions.FUNCTION decrypt(bytea, bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION decrypt_iv(bytea, bytea, bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION digest(bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION digest(text, text)"
pg_dump: creating ACL "extensions.FUNCTION encrypt(bytea, bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION encrypt_iv(bytea, bytea, bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION gen_random_bytes(integer)"
pg_dump: creating ACL "extensions.FUNCTION gen_random_uuid()"
pg_dump: creating ACL "extensions.FUNCTION gen_salt(text)"
 (class 0 OID 0)
-- Dependencies: 427
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- TOC entry 4757 (class 0 OID 0)
-- Dependencies: 412
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4758 (class 0 OID 0)
-- Dependencies: 324
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4759 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4760 (class 0 OID 0)
-- Dependencies: 340
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4761 (class 0 OID 0)
-- Dependencies: 378
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4762 (class 0 OID 0)
-- Dependencies: 328
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4763 (class 0 OID 0)
-- Dependencies: 325
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4764 (class 0 OID 0)
-- Dependencies: 424
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4765 (class 0 OID 0)
-- Dependencies: 362
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4766 (class 0 OID 0)
-- Dependencies: 414
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4767 (class 0 OID 0)
-- Dependencies: 336
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4768 (class 0 OID 0)
-- Dependencies: 408
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4769 (class 0 OIpg_dump: creating ACL "extensions.FUNCTION gen_salt(text, integer)"
pg_dump: creating ACL "extensions.FUNCTION grant_pg_cron_access()"
pg_dump: creating ACL "extensions.FUNCTION grant_pg_graphql_access()"
pg_dump: creating ACL "extensions.FUNCTION grant_pg_net_access()"
pg_dump: creating ACL "extensions.FUNCTION hmac(bytea, bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION hmac(text, text, text)"
pg_dump: creating ACL "extensions.FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone)"
D 0)
-- Dependencies: 345
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4770 (class 0 OID 0)
-- Dependencies: 364
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4772 (class 0 OID 0)
-- Dependencies: 441
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- TOC entry 4774 (class 0 OID 0)
-- Dependencies: 418
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4776 (class 0 OID 0)
-- Dependencies: 322
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- TOC entry 4777 (class 0 OID 0)
-- Dependencies: 407
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4778 (class 0 OID 0)
-- Dependencies: 384
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4779 (class 0 OID 0)
-- Dependencies: 352
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements(spg_dump: creating ACL "extensions.FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone)"
pg_dump: creating ACL "extensions.FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean)"
pg_dump: creating ACL "extensions.FUNCTION pgp_armor_headers(text, OUT key text, OUT value text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_key_id(bytea)"
pg_dump: creating ACL "extensions.FUNCTION pgp_pub_decrypt(bytea, bytea)"
pg_dump: creating ACL "extensions.FUNCTION pgp_pub_decrypt(bytea, bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_pub_decrypt(bytea, bytea, text, text)"
howtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4780 (class 0 OID 0)
-- Dependencies: 400
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4781 (class 0 OID 0)
-- Dependencies: 435
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4782 (class 0 OID 0)
-- Dependencies: 356
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4783 (class 0 OID 0)
-- Dependencies: 370
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4784 (class 0 OID 0)
-- Dependencies: 420
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4785 (class 0 OID 0)
-- Dependencies: 358
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4786 (class 0 OID 0)
-- Dependencies: 422
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pg_dump: creating ACL "extensions.FUNCTION pgp_pub_decrypt_bytea(bytea, bytea)"
pg_dump: creating ACL "extensions.FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_pub_encrypt(text, bytea)"
pg_dump: creating ACL "extensions.FUNCTION pgp_pub_encrypt(text, bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_pub_encrypt_bytea(bytea, bytea)"
pg_dump: creating ACL "extensions.FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_sym_decrypt(bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_sym_decrypt(bytea, text, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_sym_decrypt_bytea(bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_sym_decrypt_bytea(bytea, text, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_sym_encrypt(text, text)"
pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4787 (class 0 OID 0)
-- Dependencies: 391
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4788 (class 0 OID 0)
-- Dependencies: 387
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4789 (class 0 OID 0)
-- Dependencies: 393
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4790 (class 0 OID 0)
-- Dependencies: 339
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4791 (class 0 OID 0)
-- Dependencies: 379
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4792 (class 0 OID 0)
-- Dependencies: 377
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4793 (class 0 OID 0)
-- Dependencies: 398
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4794 (class 0 OID 0)
-- Dependencies: 359
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4795 (class 0 OID 0)
-- Dependencies: 410
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4796 (class 0 OID 0)
-- Dependencies: 404
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4797 (class 0 OID 0)
-- Dependencies: 421
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4798 (class 0pg_dump: creating ACL "extensions.FUNCTION pgp_sym_encrypt(text, text, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_sym_encrypt_bytea(bytea, text)"
pg_dump: creating ACL "extensions.FUNCTION pgp_sym_encrypt_bytea(bytea, text, text)"
pg_dump: creating ACL "extensions.FUNCTION pgrst_ddl_watch()"
pg_dump: creating ACL "extensions.FUNCTION pgrst_drop_watch()"
pg_dump: creating ACL "extensions.FUNCTION set_graphql_placeholder()"
pg_dump: creating ACL "extensions.FUNCTION uuid_generate_v1()"
pg_dump: creating ACL "extensions.FUNCTION uuid_generate_v1mc()"
pg_dump: creating ACL "extensions.FUNCTION uuid_generate_v3(namespace uuid, name text)"
pg_dump: creating ACL "extensions.FUNCTION uuid_generate_v4()"
pg_dump: creating ACL "extensions.FUNCTION uuid_generate_v5(namespace uuid, name text)"
pg_dump: creating ACL "extensions.FUNCTION uuid_nil()"
 OID 0)
-- Dependencies: 415
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4799 (class 0 OID 0)
-- Dependencies: 341
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4800 (class 0 OID 0)
-- Dependencies: 399
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4801 (class 0 OID 0)
-- Dependencies: 333
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4802 (class 0 OID 0)
-- Dependencies: 444
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4803 (class 0 OID 0)
-- Dependencies: 429
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4805 (class 0 OID 0)
-- Dependencies: 416
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4806 (class 0 OID 0)
-- Dependencies: 443
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4807 (class 0 OID 0)
-- Dependencies: 438
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4808 (class 0 OID 0)
-- Dependencies: 361
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4809 (class 0 OID 0)
-- Dependencies: 354
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4810 (class 0 OID 0)
-- Dependencies: 374
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 4811 (class 0 OID 0)
-- Dependencies: 447
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT Opg_dump: creating ACL "extensions.FUNCTION uuid_ns_dns()"
pg_dump: creating ACL "extensions.FUNCTION uuid_ns_oid()"
pg_dump: creating ACL "extensions.FUNCTION uuid_ns_url()"
pg_dump: creating ACL "extensions.FUNCTION uuid_ns_x500()"
pg_dump: creating ACL "graphql_public.FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb)"
pg_dump: creating ACL "net.FUNCTION http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer)"
pg_dump: creating ACL "net.FUNCTION http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer)"
pg_dump: creating ACL "pg_catalog.FUNCTION pg_reload_conf()"
PTION;


--
-- TOC entry 4812 (class 0 OID 0)
-- Dependencies: 347
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4813 (class 0 OID 0)
-- Dependencies: 380
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4814 (class 0 OID 0)
-- Dependencies: 428
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4815 (class 0 OID 0)
-- Dependencies: 406
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;


--
-- TOC entry 4816 (class 0 OID 0)
-- Dependencies: 423
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- TOC entry 4817 (class 0 OID 0)
-- Dependencies: 348
-- Name: FUNCTION http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO postgres;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO anon;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO authenticated;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO service_role;


--
-- TOC entry 4818 (class 0 OID 0)
-- Dependencies: 369
-- Name: FUNCTION http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO postgres;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO anon;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO authenticated;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO service_role;


--
-- TOC entry 4819 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION pg_reload_conf(); Type: ACL; Schema: pg_catalog; Owner: supabase_admin
--

GRANT ALL ON FUNCTION pg_catalog.pg_reload_conf() TO postgres WITH GRANT Opg_dump: creating ACL "pgbouncer.FUNCTION get_auth(p_usename text)"
pg_dump: creating ACL "public.FUNCTION handle_new_user()"
pg_dump: creating ACL "public.FUNCTION has_role(_user_id uuid, _role public.app_role)"
pg_dump: creating ACL "public.FUNCTION set_updated_at_module_quiz_attempts()"
pg_dump: creating ACL "public.FUNCTION update_updated_at_column()"
pg_dump: creating ACL "realtime.FUNCTION apply_rls(wal jsonb, max_record_bytes integer)"
pg_dump: creating ACL "realtime.FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text)"
pg_dump: creating ACL "realtime.FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[])"
PTION;


--
-- TOC entry 4820 (class 0 OID 0)
-- Dependencies: 367
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- TOC entry 4821 (class 0 OID 0)
-- Dependencies: 375
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- TOC entry 4822 (class 0 OID 0)
-- Dependencies: 371
-- Name: FUNCTION has_role(_user_id uuid, _role public.app_role); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.has_role(_user_id uuid, _role public.app_role) TO anon;
GRANT ALL ON FUNCTION public.has_role(_user_id uuid, _role public.app_role) TO authenticated;
GRANT ALL ON FUNCTION public.has_role(_user_id uuid, _role public.app_role) TO service_role;


--
-- TOC entry 4823 (class 0 OID 0)
-- Dependencies: 401
-- Name: FUNCTION set_updated_at_module_quiz_attempts(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.set_updated_at_module_quiz_attempts() TO anon;
GRANT ALL ON FUNCTION public.set_updated_at_module_quiz_attempts() TO authenticated;
GRANT ALL ON FUNCTION public.set_updated_at_module_quiz_attempts() TO service_role;


--
-- TOC entry 4824 (class 0 OID 0)
-- Dependencies: 327
-- Name: FUNCTION update_updated_at_column(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_updated_at_column() TO anon;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO authenticated;
GRANT ALL ON FUNCTION public.update_updated_at_column() TO service_role;


--
-- TOC entry 4825 (class 0 OID 0)
-- Dependencies: 392
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- TOC entry 4826 (class 0 OID 0)
-- Dependencies: 334
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- TOC entry 4827 (class 0 OID 0)
-- Dependencies: 320
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO apg_dump: creating ACL "realtime.FUNCTION "cast"(val text, type_ regtype)"
pg_dump: creating ACL "realtime.FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text)"
pg_dump: creating ACL "realtime.FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[])"
pg_dump: creating ACL "realtime.FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer)"
uthenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- TOC entry 4828 (class 0 OID 0)
-- Dependencies: 434
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- TOC entry 4829 (class 0 OID 0)
-- Dependencies: 343
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- TOC entry 4830 (class 0 OID 0)
-- Dependencies: 389
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- TOC entry 4831 (class 0 OID 0)
-- Dependencies: 426
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name namepg_dump: creating ACL "realtime.FUNCTION quote_wal2json(entity regclass)"
pg_dump: creating ACL "realtime.FUNCTION send(payload jsonb, event text, topic text, private boolean)"
pg_dump: creating ACL "realtime.FUNCTION subscription_check_filters()"
pg_dump: creating ACL "realtime.FUNCTION to_regrole(role_name text)"
pg_dump: creating ACL "realtime.FUNCTION topic()"
pg_dump: creating ACL "supabase_functions.FUNCTION http_request()"
pg_dump: creating ACL "vault.FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea)"
pg_dump: creating ACL "vault.FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid)"
, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- TOC entry 4832 (class 0 OID 0)
-- Dependencies: 386
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- TOC entry 4833 (class 0 OID 0)
-- Dependencies: 394
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- TOC entry 4834 (class 0 OID 0)
-- Dependencies: 437
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- TOC entry 4835 (class 0 OID 0)
-- Dependencies: 381
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- TOC entry 4836 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- TOC entry 4837 (class 0 OID 0)
-- Dependencies: 366
-- Name: FUNCTION http_request(); Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

REVOKE ALL ON FUNCTION supabase_functions.http_request() FROM PUBLIC;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO postgres;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO anon;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO authenticated;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO service_role;


--
-- TOC entry 4838 (class 0 OID 0)
-- Dependencies: 372
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;


--
-- TOC entry 4839 (class 0 OID 0)
-- Dependencies: 388
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secretpg_dump: creating ACL "vault.FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid)"
pg_dump: creating ACL "auth.TABLE audit_log_entries"
pg_dump: creating ACL "auth.TABLE custom_oauth_providers"
pg_dump: creating ACL "auth.TABLE flow_state"
pg_dump: creating ACL "auth.TABLE identities"
pg_dump: creating ACL "auth.TABLE instances"
pg_dump: creating ACL "auth.TABLE mfa_amr_claims"
pg_dump: creating ACL "auth.TABLE mfa_challenges"
pg_dump: creating ACL "auth.TABLE mfa_factors"
pg_dump: creating ACL "auth.TABLE oauth_authorizations"
pg_dump: creating ACL "auth.TABLE oauth_client_states"
pg_dump: creating ACL "auth.TABLE oauth_clients"
(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- TOC entry 4840 (class 0 OID 0)
-- Dependencies: 323
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- TOC entry 4842 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- TOC entry 4843 (class 0 OID 0)
-- Dependencies: 289
-- Name: TABLE custom_oauth_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.custom_oauth_providers TO postgres;
GRANT ALL ON TABLE auth.custom_oauth_providers TO dashboard_user;


--
-- TOC entry 4845 (class 0 OID 0)
-- Dependencies: 283
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- TOC entry 4848 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- TOC entry 4850 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- TOC entry 4852 (class 0 OID 0)
-- Dependencies: 278
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- TOC entry 4854 (class 0 OID 0)
-- Dependencies: 277
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- TOC entry 4857 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- TOC entry 4858 (class 0 OID 0)
-- Dependencies: 286
-- Name: TABLE oauth_authorizations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_authorizations TO postgres;
GRANT ALL ON TABLE auth.oauth_authorizations TO dashboard_user;


--
-- TOC entry 4860 (class 0 OID 0)
-- Dependencies: 288
-- Name: TABLE oauth_client_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_client_states TO postgres;
GRANT ALL ON TABLE auth.oauth_client_states TO dashboard_user;


--
pg_dump: creating ACL "auth.TABLE oauth_consents"
pg_dump: creating ACL "auth.TABLE one_time_tokens"
pg_dump: creating ACL "auth.TABLE refresh_tokens"
pg_dump: creating ACL "auth.SEQUENCE refresh_tokens_id_seq"
pg_dump: creating ACL "auth.TABLE saml_providers"
pg_dump: creating ACL "auth.TABLE saml_relay_states"
pg_dump: creating ACL "auth.TABLE schema_migrations"
pg_dump: creating ACL "auth.TABLE sessions"
pg_dump: creating ACL "auth.TABLE sso_domains"
pg_dump: creating ACL "auth.TABLE sso_providers"
pg_dump: creating ACL "auth.TABLE users"
pg_dump: creating ACL "auth.TABLE webauthn_challenges"
-- TOC entry 4861 (class 0 OID 0)
-- Dependencies: 285
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;


--
-- TOC entry 4862 (class 0 OID 0)
-- Dependencies: 287
-- Name: TABLE oauth_consents; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_consents TO postgres;
GRANT ALL ON TABLE auth.oauth_consents TO dashboard_user;


--
-- TOC entry 4863 (class 0 OID 0)
-- Dependencies: 284
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- TOC entry 4865 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- TOC entry 4867 (class 0 OID 0)
-- Dependencies: 236
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- TOC entry 4869 (class 0 OID 0)
-- Dependencies: 281
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- TOC entry 4871 (class 0 OID 0)
-- Dependencies: 282
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- TOC entry 4873 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- TOC entry 4878 (class 0 OID 0)
-- Dependencies: 275
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- TOC entry 4880 (class 0 OID 0)
-- Dependencies: 280
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- TOC entry 4883 (class 0 OID 0)
-- Dependencies: 279
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- TOC entry 4886 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- TOC entry 4887 (class 0 OID 0)
-- Dependencies: 291
-- Napg_dump: creating ACL "auth.TABLE webauthn_credentials"
pg_dump: creating ACL "extensions.TABLE pg_stat_statements"
pg_dump: creating ACL "extensions.TABLE pg_stat_statements_info"
pg_dump: creating ACL "public.TABLE analytics_events"
pg_dump: creating ACL "public.TABLE assessments"
pg_dump: creating ACL "public.TABLE certificates"
pg_dump: creating ACL "public.TABLE feedback"
pg_dump: creating ACL "public.TABLE module_quiz_attempts"
pg_dump: creating ACL "public.TABLE modules"
pg_dump: creating ACL "public.TABLE options"
pg_dump: creating ACL "public.TABLE profiles"
pg_dump: creating ACL "public.TABLE questions"
pg_dump: creating ACL "public.TABLE regions"
pg_dump: creating ACL "public.TABLE scenario_options"
me: TABLE webauthn_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.webauthn_challenges TO postgres;
GRANT ALL ON TABLE auth.webauthn_challenges TO dashboard_user;


--
-- TOC entry 4888 (class 0 OID 0)
-- Dependencies: 290
-- Name: TABLE webauthn_credentials; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.webauthn_credentials TO postgres;
GRANT ALL ON TABLE auth.webauthn_credentials TO dashboard_user;


--
-- TOC entry 4889 (class 0 OID 0)
-- Dependencies: 242
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;


--
-- TOC entry 4890 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;


--
-- TOC entry 4891 (class 0 OID 0)
-- Dependencies: 309
-- Name: TABLE analytics_events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.analytics_events TO anon;
GRANT ALL ON TABLE public.analytics_events TO authenticated;
GRANT ALL ON TABLE public.analytics_events TO service_role;


--
-- TOC entry 4892 (class 0 OID 0)
-- Dependencies: 297
-- Name: TABLE assessments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.assessments TO anon;
GRANT ALL ON TABLE public.assessments TO authenticated;
GRANT ALL ON TABLE public.assessments TO service_role;


--
-- TOC entry 4893 (class 0 OID 0)
-- Dependencies: 300
-- Name: TABLE certificates; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.certificates TO anon;
GRANT ALL ON TABLE public.certificates TO authenticated;
GRANT ALL ON TABLE public.certificates TO service_role;


--
-- TOC entry 4894 (class 0 OID 0)
-- Dependencies: 311
-- Name: TABLE feedback; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.feedback TO anon;
GRANT ALL ON TABLE public.feedback TO authenticated;
GRANT ALL ON TABLE public.feedback TO service_role;


--
-- TOC entry 4895 (class 0 OID 0)
-- Dependencies: 310
-- Name: TABLE module_quiz_attempts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.module_quiz_attempts TO anon;
GRANT ALL ON TABLE public.module_quiz_attempts TO authenticated;
GRANT ALL ON TABLE public.module_quiz_attempts TO service_role;


--
-- TOC entry 4896 (class 0 OID 0)
-- Dependencies: 302
-- Name: TABLE modules; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.modules TO anon;
GRANT ALL ON TABLE public.modules TO authenticated;
GRANT ALL ON TABLE public.modules TO service_role;


--
-- TOC entry 4897 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE options; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.options TO anon;
GRANT ALL ON TABLE public.options TO authenticated;
GRANT ALL ON TABLE public.options TO service_role;


--
-- TOC entry 4898 (class 0 OID 0)
-- Dependencies: 293
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- TOC entry 4899 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE questions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.questions TO anon;
GRANT ALL ON TABLE public.questions TO authenticated;
GRANT ALL ON TABLE public.questions TO service_role;


--
-- TOC entry 4900 (class 0 OID 0)
-- Dependencies: 304
-- Name: TABLE regions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.regions TO anon;
GRANT ALL ON TABLE public.regions TO authenticated;
GRANT ALL ON TABLE public.regions TO service_role;


--
-- TOC entry 4901 (class 0 OID 0)
-- Dependencies: 307
-- Name: TABLE scenario_options; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.scenario_options TO anon;
GRANT ALL ON TABLE public.scenario_optpg_dump: creating ACL "public.TABLE scenario_responses"
pg_dump: creating ACL "public.TABLE scenarios"
pg_dump: creating ACL "public.TABLE session_events"
pg_dump: creating ACL "public.TABLE training_content"
pg_dump: creating ACL "public.TABLE training_progress"
pg_dump: creating ACL "public.TABLE trainings"
pg_dump: creating ACL "public.TABLE user_regions"
pg_dump: creating ACL "public.TABLE user_roles"
pg_dump: creating ACL "realtime.TABLE messages"
pg_dump: creating ACL "realtime.TABLE messages_2026_06_06"
pg_dump: creating ACL "realtime.TABLE messages_2026_06_07"
pg_dump: creating ACL "realtime.TABLE messages_2026_06_08"
pg_dump: creating ACL "realtime.TABLE messages_2026_06_09"
pg_dump: creating ACL "realtime.TABLE messages_2026_06_10"
ions TO authenticated;
GRANT ALL ON TABLE public.scenario_options TO service_role;


--
-- TOC entry 4902 (class 0 OID 0)
-- Dependencies: 308
-- Name: TABLE scenario_responses; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.scenario_responses TO anon;
GRANT ALL ON TABLE public.scenario_responses TO authenticated;
GRANT ALL ON TABLE public.scenario_responses TO service_role;


--
-- TOC entry 4903 (class 0 OID 0)
-- Dependencies: 306
-- Name: TABLE scenarios; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.scenarios TO anon;
GRANT ALL ON TABLE public.scenarios TO authenticated;
GRANT ALL ON TABLE public.scenarios TO service_role;


--
-- TOC entry 4904 (class 0 OID 0)
-- Dependencies: 303
-- Name: TABLE session_events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.session_events TO anon;
GRANT ALL ON TABLE public.session_events TO authenticated;
GRANT ALL ON TABLE public.session_events TO service_role;


--
-- TOC entry 4905 (class 0 OID 0)
-- Dependencies: 295
-- Name: TABLE training_content; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.training_content TO anon;
GRANT ALL ON TABLE public.training_content TO authenticated;
GRANT ALL ON TABLE public.training_content TO service_role;


--
-- TOC entry 4906 (class 0 OID 0)
-- Dependencies: 296
-- Name: TABLE training_progress; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.training_progress TO anon;
GRANT ALL ON TABLE public.training_progress TO authenticated;
GRANT ALL ON TABLE public.training_progress TO service_role;


--
-- TOC entry 4907 (class 0 OID 0)
-- Dependencies: 294
-- Name: TABLE trainings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.trainings TO anon;
GRANT ALL ON TABLE public.trainings TO authenticated;
GRANT ALL ON TABLE public.trainings TO service_role;


--
-- TOC entry 4908 (class 0 OID 0)
-- Dependencies: 305
-- Name: TABLE user_regions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_regions TO anon;
GRANT ALL ON TABLE public.user_regions TO authenticated;
GRANT ALL ON TABLE public.user_regions TO service_role;


--
-- TOC entry 4909 (class 0 OID 0)
-- Dependencies: 301
-- Name: TABLE user_roles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_roles TO anon;
GRANT ALL ON TABLE public.user_roles TO authenticated;
GRANT ALL ON TABLE public.user_roles TO service_role;


--
-- TOC entry 4910 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- TOC entry 4911 (class 0 OID 0)
-- Dependencies: 312
-- Name: TABLE messages_2026_06_06; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_06_06 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_06_06 TO dashboard_user;


--
-- TOC entry 4912 (class 0 OID 0)
-- Dependencies: 313
-- Name: TABLE messages_2026_06_07; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_06_07 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_06_07 TO dashboard_user;


--
-- TOC entry 4913 (class 0 OID 0)
-- Dependencies: 314
-- Name: TABLE messages_2026_06_08; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_06_08 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_06_08 TO dashboard_user;


--
-- TOC entry 4914 (class 0 OID 0)
-- Dependencies: 315
-- Name: TABLE messages_2026_06_09; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_06_09 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_06_09 TO dashboard_user;


--
-- TOC entry 4915 (pg_dump: creating ACL "realtime.TABLE messages_2026_06_11"
pg_dump: creating ACL "realtime.TABLE messages_2026_06_12"
pg_dump: creating ACL "realtime.TABLE schema_migrations"
pg_dump: creating ACL "realtime.TABLE subscription"
pg_dump: creating ACL "realtime.SEQUENCE subscription_id_seq"
pg_dump: creating ACL "storage.TABLE buckets"
pg_dump: creating ACL "storage.TABLE buckets_analytics"
pg_dump: creating ACL "storage.TABLE buckets_vectors"
pg_dump: creating ACL "storage.TABLE iceberg_namespaces"
pg_dump: creating ACL "storage.TABLE iceberg_tables"
class 0 OID 0)
-- Dependencies: 316
-- Name: TABLE messages_2026_06_10; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_06_10 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_06_10 TO dashboard_user;


--
-- TOC entry 4916 (class 0 OID 0)
-- Dependencies: 317
-- Name: TABLE messages_2026_06_11; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_06_11 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_06_11 TO dashboard_user;


--
-- TOC entry 4917 (class 0 OID 0)
-- Dependencies: 318
-- Name: TABLE messages_2026_06_12; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_06_12 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_06_12 TO dashboard_user;


--
-- TOC entry 4918 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- TOC entry 4919 (class 0 OID 0)
-- Dependencies: 260
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- TOC entry 4920 (class 0 OID 0)
-- Dependencies: 259
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- TOC entry 4922 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO anon;


--
-- TOC entry 4923 (class 0 OID 0)
-- Dependencies: 269
-- Name: TABLE buckets_analytics; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets_analytics TO service_role;
GRANT ALL ON TABLE storage.buckets_analytics TO authenticated;
GRANT ALL ON TABLE storage.buckets_analytics TO anon;


--
-- TOC entry 4924 (class 0 OID 0)
-- Dependencies: 272
-- Name: TABLE buckets_vectors; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.buckets_vectors TO service_role;
GRANT SELECT ON TABLE storage.buckets_vectors TO authenticated;
GRANT SELECT ON TABLE storage.buckets_vectors TO anon;


--
-- TOC entry 4925 (class 0 OID 0)
-- Dependencies: 270
-- Name: TABLE iceberg_namespaces; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.iceberg_namespaces TO service_role;
GRANT SELECT ON TABLE storage.iceberg_namespaces TO authenticated;
GRANT SELECT ON TABLE storage.iceberg_namespaces TO anon;


--
-- TOC entry 4926 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE iceberg_tables; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.iceberg_tables TO service_role;
GRANT SELECT ON TABLE storage.iceberg_tables TO authenticated;
GRANT SELECT ON TABLpg_dump: creating ACL "storage.TABLE objects"
pg_dump: creating ACL "storage.TABLE s3_multipart_uploads"
pg_dump: creating ACL "storage.TABLE s3_multipart_uploads_parts"
pg_dump: creating ACL "storage.TABLE vector_indexes"
pg_dump: creating ACL "supabase_functions.TABLE hooks"
pg_dump: creating ACL "supabase_functions.SEQUENCE hooks_id_seq"
pg_dump: creating ACL "supabase_functions.TABLE migrations"
pg_dump: creating ACL "vault.TABLE secrets"
pg_dump: creating ACL "vault.TABLE decrypted_secrets"
pg_dump: creating DEFAULT ACL "auth.DEFAULT PRIVILEGES FOR SEQUENCES"
pg_dump: creating DEFAULT ACL "auth.DEFAULT PRIVILEGES FOR FUNCTIONS"
pg_dump: creating DEFAULT ACL "auth.DEFAULT PRIVILEGES FOR TABLES"
E storage.iceberg_tables TO anon;


--
-- TOC entry 4928 (class 0 OID 0)
-- Dependencies: 266
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.objects TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO anon;


--
-- TOC entry 4929 (class 0 OID 0)
-- Dependencies: 267
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- TOC entry 4930 (class 0 OID 0)
-- Dependencies: 268
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- TOC entry 4931 (class 0 OID 0)
-- Dependencies: 273
-- Name: TABLE vector_indexes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.vector_indexes TO service_role;
GRANT SELECT ON TABLE storage.vector_indexes TO authenticated;
GRANT SELECT ON TABLE storage.vector_indexes TO anon;


--
-- TOC entry 4933 (class 0 OID 0)
-- Dependencies: 253
-- Name: TABLE hooks; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT ALL ON TABLE supabase_functions.hooks TO postgres;
GRANT ALL ON TABLE supabase_functions.hooks TO anon;
GRANT ALL ON TABLE supabase_functions.hooks TO authenticated;
GRANT ALL ON TABLE supabase_functions.hooks TO service_role;


--
-- TOC entry 4935 (class 0 OID 0)
-- Dependencies: 252
-- Name: SEQUENCE hooks_id_seq; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO postgres;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO anon;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO authenticated;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO service_role;


--
-- TOC entry 4936 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE migrations; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT ALL ON TABLE supabase_functions.migrations TO postgres;
GRANT ALL ON TABLE supabase_functions.migrations TO anon;
GRANT ALL ON TABLE supabase_functions.migrations TO authenticated;
GRANT ALL ON TABLE supabase_functions.migrations TO service_role;


--
-- TOC entry 4937 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;


--
-- TOC entry 4938 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;


--
-- TOC entry 2542 (class 826 OID 16553)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- TOC entry 2543 (class 826 OID 16554)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- TOC entry 2541 (class 826 OID 16552)
-- pg_dump: creating DEFAULT ACL "extensions.DEFAULT PRIVILEGES FOR SEQUENCES"
pg_dump: creating DEFAULT ACL "extensions.DEFAULT PRIVILEGES FOR FUNCTIONS"
pg_dump: creating DEFAULT ACL "extensions.DEFAULT PRIVILEGES FOR TABLES"
pg_dump: creating DEFAULT ACL "graphql.DEFAULT PRIVILEGES FOR SEQUENCES"
pg_dump: creating DEFAULT ACL "graphql.DEFAULT PRIVILEGES FOR FUNCTIONS"
pg_dump: creating DEFAULT ACL "graphql.DEFAULT PRIVILEGES FOR TABLES"
pg_dump: creating DEFAULT ACL "graphql_public.DEFAULT PRIVILEGES FOR SEQUENCES"
pg_dump: creating DEFAULT ACL "graphql_public.DEFAULT PRIVILEGES FOR FUNCTIONS"
pg_dump: creating DEFAULT ACL "graphql_public.DEFAULT PRIVILEGES FOR TABLES"
Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- TOC entry 2552 (class 826 OID 16632)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- TOC entry 2551 (class 826 OID 16631)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- TOC entry 2550 (class 826 OID 16630)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- TOC entry 2555 (class 826 OID 16587)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 2554 (class 826 OID 16586)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 2553 (class 826 OID 16585)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 2547 (class 826 OID 16567)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 2549 (class 826 OID 16566)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 2548 (class 826 OID 16565)
-- Name: DEFAULT PRIVILEGpg_dump: creating DEFAULT ACL "public.DEFAULT PRIVILEGES FOR SEQUENCES"
pg_dump: creating DEFAULT ACL "public.DEFAULT PRIVILEGES FOR SEQUENCES"
pg_dump: creating DEFAULT ACL "public.DEFAULT PRIVILEGES FOR FUNCTIONS"
pg_dump: creating DEFAULT ACL "public.DEFAULT PRIVILEGES FOR FUNCTIONS"
pg_dump: creating DEFAULT ACL "public.DEFAULT PRIVILEGES FOR TABLES"
pg_dump: creating DEFAULT ACL "public.DEFAULT PRIVILEGES FOR TABLES"
pg_dump: creating DEFAULT ACL "realtime.DEFAULT PRIVILEGES FOR SEQUENCES"
ES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 2534 (class 826 OID 16453)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 2535 (class 826 OID 16454)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 2533 (class 826 OID 16452)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 2537 (class 826 OID 16456)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 2532 (class 826 OID 16451)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 2536 (class 826 OID 16455)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 2545 (class 826 OID 16557)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANpg_dump: creating DEFAULT ACL "realtime.DEFAULT PRIVILEGES FOR FUNCTIONS"
pg_dump: creating DEFAULT ACL "realtime.DEFAULT PRIVILEGES FOR TABLES"
pg_dump: creating DEFAULT ACL "storage.DEFAULT PRIVILEGES FOR SEQUENCES"
pg_dump: creating DEFAULT ACL "storage.DEFAULT PRIVILEGES FOR FUNCTIONS"
pg_dump: creating DEFAULT ACL "storage.DEFAULT PRIVILEGES FOR TABLES"
pg_dump: creating DEFAULT ACL "supabase_functions.DEFAULT PRIVILEGES FOR SEQUENCES"
pg_dump: creating DEFAULT ACL "supabase_functions.DEFAULT PRIVILEGES FOR FUNCTIONS"
pg_dump: creating DEFAULT ACL "supabase_functions.DEFAULT PRIVILEGES FOR TABLES"
T ALL ON SEQUENCES TO dashboard_user;


--
-- TOC entry 2546 (class 826 OID 16558)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- TOC entry 2544 (class 826 OID 16556)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;


--
-- TOC entry 2540 (class 826 OID 16509)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 2539 (class 826 OID 16508)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 2538 (class 826 OID 16507)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 2558 (class 826 OID 16711)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: supabase_functions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 2557 (class 826 OID 16710)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: supabase_functions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 2556 (class 826 OID 16709)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: supabase_functions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON TABLES TO authenticated;
ALTERpg_dump: creating EVENT TRIGGER "issue_graphql_placeholder"
pg_dump: creating EVENT TRIGGER "issue_pg_cron_access"
pg_dump: creating EVENT TRIGGER "issue_pg_graphql_access"
pg_dump: creating EVENT TRIGGER "issue_pg_net_access"
pg_dump: creating EVENT TRIGGER "pgrst_ddl_watch"
pg_dump: creating EVENT TRIGGER "pgrst_drop_watch"
 DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 3772 (class 3466 OID 16571)
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- TOC entry 3777 (class 3466 OID 16650)
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- TOC entry 3771 (class 3466 OID 16569)
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- TOC entry 3778 (class 3466 OID 16653)
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- TOC entry 3773 (class 3466 OID 16572)
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- TOC entry 3774 (class 3466 OID 16573)
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

-- Completed on 2026-06-09 14:50:37 PKT

--
-- PostgreSQL database dump complete
--

\unrestrict CYO8YJwc8jpwnYMoiB9zZaMFgCMsNibER7k7RtSLDQBFLxEe1k0vmZE7IRFPWjG

