--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

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
-- Name: average_to_answer_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.average_to_answer_rules (
    id integer NOT NULL,
    metric_name character varying(100) NOT NULL,
    question_code character varying(50) NOT NULL,
    lower_bound numeric NOT NULL,
    upper_bound numeric NOT NULL,
    resulting_answer_value text NOT NULL
);


ALTER TABLE public.average_to_answer_rules OWNER TO postgres;

--
-- Name: average_to_answer_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.average_to_answer_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.average_to_answer_rules_id_seq OWNER TO postgres;

--
-- Name: average_to_answer_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.average_to_answer_rules_id_seq OWNED BY public.average_to_answer_rules.id;


--
-- Name: benchmark_scoring_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.benchmark_scoring_rules (
    id integer NOT NULL,
    metric_name character varying(100) NOT NULL,
    description text,
    upper_bound numeric,
    score integer NOT NULL,
    is_inverted boolean DEFAULT false,
    comparison_type character varying(50)
);


ALTER TABLE public.benchmark_scoring_rules OWNER TO postgres;

--
-- Name: benchmark_scoring_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.benchmark_scoring_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.benchmark_scoring_rules_id_seq OWNER TO postgres;

--
-- Name: benchmark_scoring_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.benchmark_scoring_rules_id_seq OWNED BY public.benchmark_scoring_rules.id;


--
-- Name: company_size_esg_issues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.company_size_esg_issues (
    id integer NOT NULL,
    company_size text NOT NULL,
    key_issue text,
    opportunity text,
    threat text,
    linked_metric text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.company_size_esg_issues OWNER TO postgres;

--
-- Name: company_size_esg_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.company_size_esg_issues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.company_size_esg_issues_id_seq OWNER TO postgres;

--
-- Name: company_size_esg_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.company_size_esg_issues_id_seq OWNED BY public.company_size_esg_issues.id;


--
-- Name: diagnoses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnoses (
    id integer NOT NULL,
    user_id integer NOT NULL,
    company_name character varying(255),
    representative_name character varying(255),
    industry_codes text[],
    establishment_year integer,
    employee_count integer,
    products_services text,
    recent_sales bigint,
    recent_operating_profit bigint,
    export_percentage character varying(50),
    is_listed boolean,
    company_size character varying(50),
    main_business_region character varying(100),
    status character varying(50) DEFAULT 'in_progress'::character varying,
    total_score numeric(5,2),
    e_score numeric(5,2),
    s_score numeric(5,2),
    g_score numeric(5,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    diagnosis_type character varying(50) DEFAULT 'simple'::character varying NOT NULL
);


ALTER TABLE public.diagnoses OWNER TO postgres;

--
-- Name: diagnoses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.diagnoses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diagnoses_id_seq OWNER TO postgres;

--
-- Name: diagnoses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnoses_id_seq OWNED BY public.diagnoses.id;


--
-- Name: diagnosis_answers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnosis_answers (
    id integer NOT NULL,
    diagnosis_id integer NOT NULL,
    question_code character varying(20) NOT NULL,
    answer_value text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    score numeric
);


ALTER TABLE public.diagnosis_answers OWNER TO postgres;

--
-- Name: diagnosis_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.diagnosis_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diagnosis_answers_id_seq OWNER TO postgres;

--
-- Name: diagnosis_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnosis_answers_id_seq OWNED BY public.diagnosis_answers.id;


--
-- Name: esg_programs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.esg_programs (
    id integer NOT NULL,
    program_code character varying(50) NOT NULL,
    esg_category character(1) NOT NULL,
    title character varying(255) NOT NULL,
    content jsonb,
    updated_at timestamp with time zone,
    economic_effects jsonb,
    related_links jsonb,
    program_overview text,
    risk_text text,
    risk_description text,
    opportunity_effects jsonb,
    status text DEFAULT 'draft'::text NOT NULL,
    service_regions text[]
);


ALTER TABLE public.esg_programs OWNER TO postgres;

--
-- Name: esg_programs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.esg_programs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.esg_programs_id_seq OWNER TO postgres;

--
-- Name: esg_programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.esg_programs_id_seq OWNED BY public.esg_programs.id;


--
-- Name: industries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.industries (
    id integer NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(255) NOT NULL,
    category_l character varying(100),
    category_m character varying(100),
    category_s character varying(100),
    esg_issues text[],
    esg_opportunities text[],
    esg_risks text[]
);


ALTER TABLE public.industries OWNER TO postgres;

--
-- Name: industries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.industries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.industries_id_seq OWNER TO postgres;

--
-- Name: industries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.industries_id_seq OWNED BY public.industries.id;


--
-- Name: industry_averages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.industry_averages (
    id integer NOT NULL,
    industry_code character varying(10) NOT NULL,
    industry_name character varying(255) NOT NULL,
    ghg_emissions_avg numeric,
    energy_usage_avg numeric,
    waste_generation_avg numeric,
    non_regular_ratio_avg numeric,
    disability_employment_ratio_avg numeric,
    female_employee_ratio_avg numeric,
    years_of_service_avg numeric,
    donation_ratio_avg numeric,
    quality_mgmt_ratio_avg numeric,
    outside_director_ratio_avg numeric,
    board_meetings_avg numeric,
    executive_compensation_ratio_avg numeric,
    cumulative_voting_ratio_avg numeric,
    dividend_policy_ratio_avg numeric,
    legal_violation_ratio_avg numeric
);


ALTER TABLE public.industry_averages OWNER TO postgres;

--
-- Name: industry_averages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.industry_averages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.industry_averages_id_seq OWNER TO postgres;

--
-- Name: industry_averages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.industry_averages_id_seq OWNED BY public.industry_averages.id;


--
-- Name: industry_benchmark_scores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.industry_benchmark_scores (
    id integer NOT NULL,
    industry_code character varying(10) NOT NULL,
    question_code character varying(50) NOT NULL,
    average_score numeric(5,2) DEFAULT 50.00,
    notes text,
    last_calculated_at timestamp with time zone
);


ALTER TABLE public.industry_benchmark_scores OWNER TO postgres;

--
-- Name: industry_benchmark_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.industry_benchmark_scores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.industry_benchmark_scores_id_seq OWNER TO postgres;

--
-- Name: industry_benchmark_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.industry_benchmark_scores_id_seq OWNED BY public.industry_benchmark_scores.id;


--
-- Name: industry_esg_issues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.industry_esg_issues (
    id integer NOT NULL,
    industry_code character varying(10) NOT NULL,
    key_issue text,
    opportunity text,
    threat text,
    linked_metric text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.industry_esg_issues OWNER TO postgres;

--
-- Name: industry_esg_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.industry_esg_issues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.industry_esg_issues_id_seq OWNER TO postgres;

--
-- Name: industry_esg_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.industry_esg_issues_id_seq OWNED BY public.industry_esg_issues.id;


--
-- Name: inquiries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inquiries (
    id integer NOT NULL,
    user_id integer,
    company_name character varying(255),
    manager_name character varying(100),
    phone character varying(50),
    email character varying(255) NOT NULL,
    inquiry_type character varying(100) NOT NULL,
    content text NOT NULL,
    status character varying(50) DEFAULT 'new'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.inquiries OWNER TO postgres;

--
-- Name: inquiries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inquiries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inquiries_id_seq OWNER TO postgres;

--
-- Name: inquiries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inquiries_id_seq OWNED BY public.inquiries.id;


--
-- Name: news_posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.news_posts (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    author_id integer,
    category character varying(100),
    status character varying(20) DEFAULT 'published'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    content jsonb,
    is_pinned boolean DEFAULT false
);


ALTER TABLE public.news_posts OWNER TO postgres;

--
-- Name: news_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.news_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.news_posts_id_seq OWNER TO postgres;

--
-- Name: news_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.news_posts_id_seq OWNED BY public.news_posts.id;


--
-- Name: partners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.partners (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    logo_url character varying(255) NOT NULL,
    link_url character varying(255),
    display_order integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.partners OWNER TO postgres;

--
-- Name: partners_display_order_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.partners_display_order_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.partners_display_order_seq OWNER TO postgres;

--
-- Name: partners_display_order_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.partners_display_order_seq OWNED BY public.partners.display_order;


--
-- Name: partners_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.partners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.partners_id_seq OWNER TO postgres;

--
-- Name: partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.partners_id_seq OWNED BY public.partners.id;


--
-- Name: regional_esg_issues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.regional_esg_issues (
    id integer NOT NULL,
    region character varying(100) NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    esg_category character varying(1),
    display_order integer NOT NULL
);


ALTER TABLE public.regional_esg_issues OWNER TO postgres;

--
-- Name: regional_esg_issues_display_order_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.regional_esg_issues_display_order_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.regional_esg_issues_display_order_seq OWNER TO postgres;

--
-- Name: regional_esg_issues_display_order_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.regional_esg_issues_display_order_seq OWNED BY public.regional_esg_issues.display_order;


--
-- Name: regional_esg_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.regional_esg_issues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.regional_esg_issues_id_seq OWNER TO postgres;

--
-- Name: regional_esg_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.regional_esg_issues_id_seq OWNED BY public.regional_esg_issues.id;


--
-- Name: related_sites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.related_sites (
    id integer NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    display_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.related_sites OWNER TO postgres;

--
-- Name: related_sites_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.related_sites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.related_sites_id_seq OWNER TO postgres;

--
-- Name: related_sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.related_sites_id_seq OWNED BY public.related_sites.id;


--
-- Name: scoring_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scoring_rules (
    id integer NOT NULL,
    question_code character varying(20) NOT NULL,
    answer_condition text,
    score text NOT NULL,
    esg_category character(1) NOT NULL,
    notes text
);


ALTER TABLE public.scoring_rules OWNER TO postgres;

--
-- Name: scoring_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.scoring_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scoring_rules_id_seq OWNER TO postgres;

--
-- Name: scoring_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.scoring_rules_id_seq OWNED BY public.scoring_rules.id;


--
-- Name: simulator_parameters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.simulator_parameters (
    id integer NOT NULL,
    category character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    formula text,
    parameter_value numeric,
    unit character varying(50),
    is_editable boolean DEFAULT true,
    display_order integer NOT NULL
);


ALTER TABLE public.simulator_parameters OWNER TO postgres;

--
-- Name: simulator_parameters_display_order_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.simulator_parameters_display_order_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.simulator_parameters_display_order_seq OWNER TO postgres;

--
-- Name: simulator_parameters_display_order_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.simulator_parameters_display_order_seq OWNED BY public.simulator_parameters.display_order;


--
-- Name: simulator_parameters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.simulator_parameters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.simulator_parameters_id_seq OWNER TO postgres;

--
-- Name: simulator_parameters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.simulator_parameters_id_seq OWNED BY public.simulator_parameters.id;


--
-- Name: site_content; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.site_content (
    id integer NOT NULL,
    content_key character varying(100) NOT NULL,
    content_value jsonb,
    updated_at timestamp with time zone DEFAULT now(),
    terms_of_service text,
    privacy_policy text,
    content jsonb,
    marketing_consent_text text
);


ALTER TABLE public.site_content OWNER TO postgres;

--
-- Name: site_content_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.site_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.site_content_id_seq OWNER TO postgres;

--
-- Name: site_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.site_content_id_seq OWNED BY public.site_content.id;


--
-- Name: strategy_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.strategy_rules (
    id integer NOT NULL,
    description text,
    conditions jsonb NOT NULL,
    recommended_program_code character varying(50),
    priority integer DEFAULT 0
);


ALTER TABLE public.strategy_rules OWNER TO postgres;

--
-- Name: strategy_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.strategy_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.strategy_rules_id_seq OWNER TO postgres;

--
-- Name: strategy_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.strategy_rules_id_seq OWNED BY public.strategy_rules.id;


--
-- Name: survey_questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.survey_questions (
    id integer NOT NULL,
    question_code character varying(20) NOT NULL,
    esg_category character(1) NOT NULL,
    question_text text NOT NULL,
    question_type character varying(50) NOT NULL,
    options jsonb,
    explanation text,
    display_order integer,
    next_question_default character varying(20),
    next_question_if_yes character varying(20),
    next_question_if_no character varying(20),
    criteria_text text,
    benchmark_metric character varying(100),
    diagnosis_type character varying(50) DEFAULT 'simple'::character varying NOT NULL,
    scoring_method character varying(50) DEFAULT 'direct_score'::character varying
);


ALTER TABLE public.survey_questions OWNER TO postgres;

--
-- Name: survey_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.survey_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.survey_questions_id_seq OWNER TO postgres;

--
-- Name: survey_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.survey_questions_id_seq OWNED BY public.survey_questions.id;


--
-- Name: user_applications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_applications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    program_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    status text DEFAULT '신청'::text NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.user_applications OWNER TO postgres;

--
-- Name: user_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_applications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_applications_id_seq OWNER TO postgres;

--
-- Name: user_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_applications_id_seq OWNED BY public.user_applications.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    company_name character varying(255),
    industry_codes text[],
    representative character varying(100),
    address text,
    business_location text,
    manager_name character varying(100),
    manager_phone character varying(50),
    interests text[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    reset_token text,
    reset_token_expires timestamp with time zone,
    is_verified boolean DEFAULT false,
    verification_token text,
    verification_token_expires timestamp with time zone,
    role character varying(20) DEFAULT 'user'::character varying NOT NULL,
    profile_image_url text,
    agreed_to_terms_at timestamp with time zone,
    agreed_to_privacy_at timestamp with time zone,
    agreed_to_marketing boolean DEFAULT false,
    withdrawn_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: average_to_answer_rules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.average_to_answer_rules ALTER COLUMN id SET DEFAULT nextval('public.average_to_answer_rules_id_seq'::regclass);


--
-- Name: benchmark_scoring_rules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benchmark_scoring_rules ALTER COLUMN id SET DEFAULT nextval('public.benchmark_scoring_rules_id_seq'::regclass);


--
-- Name: company_size_esg_issues id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_size_esg_issues ALTER COLUMN id SET DEFAULT nextval('public.company_size_esg_issues_id_seq'::regclass);


--
-- Name: diagnoses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnoses ALTER COLUMN id SET DEFAULT nextval('public.diagnoses_id_seq'::regclass);


--
-- Name: diagnosis_answers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnosis_answers ALTER COLUMN id SET DEFAULT nextval('public.diagnosis_answers_id_seq'::regclass);


--
-- Name: esg_programs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.esg_programs ALTER COLUMN id SET DEFAULT nextval('public.esg_programs_id_seq'::regclass);


--
-- Name: industries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industries ALTER COLUMN id SET DEFAULT nextval('public.industries_id_seq'::regclass);


--
-- Name: industry_averages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_averages ALTER COLUMN id SET DEFAULT nextval('public.industry_averages_id_seq'::regclass);


--
-- Name: industry_benchmark_scores id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_benchmark_scores ALTER COLUMN id SET DEFAULT nextval('public.industry_benchmark_scores_id_seq'::regclass);


--
-- Name: industry_esg_issues id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_esg_issues ALTER COLUMN id SET DEFAULT nextval('public.industry_esg_issues_id_seq'::regclass);


--
-- Name: inquiries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inquiries ALTER COLUMN id SET DEFAULT nextval('public.inquiries_id_seq'::regclass);


--
-- Name: news_posts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.news_posts ALTER COLUMN id SET DEFAULT nextval('public.news_posts_id_seq'::regclass);


--
-- Name: partners id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partners ALTER COLUMN id SET DEFAULT nextval('public.partners_id_seq'::regclass);


--
-- Name: partners display_order; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partners ALTER COLUMN display_order SET DEFAULT nextval('public.partners_display_order_seq'::regclass);


--
-- Name: regional_esg_issues id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regional_esg_issues ALTER COLUMN id SET DEFAULT nextval('public.regional_esg_issues_id_seq'::regclass);


--
-- Name: regional_esg_issues display_order; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regional_esg_issues ALTER COLUMN display_order SET DEFAULT nextval('public.regional_esg_issues_display_order_seq'::regclass);


--
-- Name: related_sites id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.related_sites ALTER COLUMN id SET DEFAULT nextval('public.related_sites_id_seq'::regclass);


--
-- Name: scoring_rules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scoring_rules ALTER COLUMN id SET DEFAULT nextval('public.scoring_rules_id_seq'::regclass);


--
-- Name: simulator_parameters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.simulator_parameters ALTER COLUMN id SET DEFAULT nextval('public.simulator_parameters_id_seq'::regclass);


--
-- Name: simulator_parameters display_order; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.simulator_parameters ALTER COLUMN display_order SET DEFAULT nextval('public.simulator_parameters_display_order_seq'::regclass);


--
-- Name: site_content id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_content ALTER COLUMN id SET DEFAULT nextval('public.site_content_id_seq'::regclass);


--
-- Name: strategy_rules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.strategy_rules ALTER COLUMN id SET DEFAULT nextval('public.strategy_rules_id_seq'::regclass);


--
-- Name: survey_questions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.survey_questions ALTER COLUMN id SET DEFAULT nextval('public.survey_questions_id_seq'::regclass);


--
-- Name: user_applications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_applications ALTER COLUMN id SET DEFAULT nextval('public.user_applications_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: average_to_answer_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.average_to_answer_rules (id, metric_name, question_code, lower_bound, upper_bound, resulting_answer_value) FROM stdin;
1	non_regular_ratio_avg	S-Q5_1	0	20	1
2	non_regular_ratio_avg	S-Q5_1	21	40	2
3	non_regular_ratio_avg	S-Q5_1	41	60	3
4	non_regular_ratio_avg	S-Q5_1	61	80	4
5	non_regular_ratio_avg	S-Q5_1	81	100	5
11	female_employee_ratio_avg	S-Q7_1	0	10	1
12	female_employee_ratio_avg	S-Q7_1	11	15	2
13	female_employee_ratio_avg	S-Q7_1	16	20	3
14	female_employee_ratio_avg	S-Q7_1	21	25	4
15	female_employee_ratio_avg	S-Q7_1	26	100	5
16	years_of_service_avg	S-Q8_1	0	2	1
17	years_of_service_avg	S-Q8_1	3	5	2
18	years_of_service_avg	S-Q8_1	6	8	3
19	years_of_service_avg	S-Q8_1	9	11	4
20	years_of_service_avg	S-Q8_1	12	100	5
21	outside_director_ratio_avg	S-Q11_1	0	3	1
22	outside_director_ratio_avg	S-Q11_1	3	60	2
23	outside_director_ratio_avg	S-Q11_1	61	70	3
24	outside_director_ratio_avg	S-Q11_1	71	80	4
25	outside_director_ratio_avg	S-Q11_1	81	999999	5
26	board_meetings_avg	S-Q12_1	0	1	1
27	board_meetings_avg	S-Q12_1	2	3	2
28	board_meetings_avg	S-Q12_1	4	6	3
30	board_meetings_avg	S-Q12_1	12	99999999	5
29	board_meetings_avg	S-Q12_1	7	9	4
6	disability_employment_ratio_avg	S-Q6_1	0	1.8	1
7	disability_employment_ratio_avg	S-Q6_1	1.9	2.4	2
8	disability_employment_ratio_avg	S-Q6_1	2.5	3.1	3
9	disability_employment_ratio_avg	S-Q6_1	3.1	3.8	4
10	disability_employment_ratio_avg	S-Q6_1	3.8	100	5
\.


--
-- Data for Name: benchmark_scoring_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.benchmark_scoring_rules (id, metric_name, description, upper_bound, score, is_inverted, comparison_type) FROM stdin;
6	energy_usage_avg		0.4	100	t	percentage
7	energy_usage_avg	30%	0.7	75	t	percentage
8	energy_usage_avg	업계평균과 같을 때 	1	50	t	percentage
9	energy_usage_avg		1.4	25	t	percentage
10	energy_usage_avg		1.7	0	t	percentage
5	ghg_emissions_avg		1.7	0	t	percentage
4	ghg_emissions_avg		1.4	25	t	percentage
2	ghg_emissions_avg		0.7	75	t	percentage
3	ghg_emissions_avg	업계평균과 같을 때 	1	50	t	percentage
1	ghg_emissions_avg		0.4	100	t	percentage
11	waste_generation_avg		0.4	100	t	percentage
12	waste_generation_avg		0.7	75	t	percentage
13	waste_generation_avg	업계평균과 같을 때 	1	50	t	percentage
14	waste_generation_avg		1.4	25	t	percentage
15	waste_generation_avg		1.7	0	t	percentage
\.


--
-- Data for Name: company_size_esg_issues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.company_size_esg_issues (id, company_size, key_issue, opportunity, threat, linked_metric, created_at, updated_at) FROM stdin;
1	대기업	공급망 ESG 실사 의무화, 복잡한 공시 규제.	글로벌 경쟁력 강화, 대규모 투자 유치	규제 미준수 시 과징금, 브랜드 평판 리스크	supply_chain_management	2025-06-29 02:37:13.537871+09	2025-06-29 03:18:12.311174+09
2	중견기업	수출 및 납품을 위한 ESG 평가 압력	대기업 공급망 편입 기회, 신사업 진출	고객사 요구 미충족 시 계약 해지 리스크	customer_esg_audit	2025-06-29 02:37:13.537871+09	2025-06-29 03:18:12.311174+09
3	중소기업	인력 및 예산 부족, ESG 정보 접근성 저하	정부 지원 사업 가점, 우수 인재 확보	자금 조달의 어려움, 인력 유출 심화	sme_esg_support	2025-06-29 02:37:13.537871+09	2025-06-29 03:18:12.311174+09
4	소기업/소상공인	에너지 비용 상승, 폐기물 처리 부담	지역사회 상생을 통한 고객 충성도 확보	기후변화로 인한 원자재 가격 변동 리스크	local_community_relations	2025-06-29 02:37:13.537871+09	2025-06-29 03:18:12.311174+09
\.


--
-- Data for Name: diagnoses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnoses (id, user_id, company_name, representative_name, industry_codes, establishment_year, employee_count, products_services, recent_sales, recent_operating_profit, export_percentage, is_listed, company_size, main_business_region, status, total_score, e_score, s_score, g_score, created_at, updated_at, diagnosis_type) FROM stdin;
110	8	Master	홍길동	{B08,C10,B06}	2020	60	1234	500000000000	100000000000	30-50	f	medium	domestic_metro,asia	completed	14.58	18.75	16.67	8.33	2025-06-29 23:25:41.045308+09	2025-06-29 23:27:41.222547+09	simple
100	9	(주)이에스지표준원	권영석	{E38,J62,M70}	2024	50	123	123400000000	12300000000	10-30	f	small_medium	domestic_metro	completed	29.17	50.00	38.33	-0.83	2025-06-27 02:31:47.262504+09	2025-06-27 02:32:24.713698+09	simple
111	8	Master	홍길동	{B08,C10,B06}	2020	50	12345	123400000000	12300000000	0-10	f	small_medium	domestic_metro,asia,americas,europe	completed	42.50	50.00	50.00	27.50	2025-06-30 10:33:41.873328+09	2025-06-30 10:35:11.197566+09	simple
103	8	Master	홍길동	{B08,C10,C28}	2020	1234	1234	123400000000	12300000000	50+	f	small_medium	domestic_metro	completed	43.61	50.00	49.17	31.67	2025-06-27 11:20:15.843025+09	2025-06-27 11:20:58.168126+09	simple
112	8	Master	권영석	{B08,C10}	2020	12312	12312	1231400000000	123400000000	0-10	f	medium	domestic_metro,asia	completed	24.72	37.50	41.67	-5.00	2025-07-01 23:33:04.629051+09	2025-07-01 23:33:33.558011+09	simple
106	8	Master	홍길동	{B08,C10,B07}	2020	1234	123	1234500000000	123400000000	30-50	f	large	domestic_metro,asia	completed	100.00	100.00	100.00	100.00	2025-06-29 02:46:01.656215+09	2025-06-29 02:46:52.335341+09	simple
107	8	Master	홍길동	{B08,C10,B07}	2020	300	300	300000000000	150000000000	10-30	f	medium	domestic_metro,asia	completed	30.83	25.00	53.33	14.17	2025-06-29 02:47:59.561539+09	2025-06-29 02:48:42.285838+09	simple
113	8	Master	권영석	{B08,C10}	2020	123	123	21300000000	12300000000	30-50	f	small_medium	domestic_metro	completed	16.67	25.00	16.67	8.33	2025-07-02 01:02:04.964922+09	2025-07-02 01:02:18.994635+09	simple
\.


--
-- Data for Name: diagnosis_answers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnosis_answers (id, diagnosis_id, question_code, answer_value, created_at, score) FROM stdin;
2696	110	S-Q1	Yes	2025-06-29 23:27:41.222547+09	0
2697	110	S-Q2	No	2025-06-29 23:27:41.222547+09	0
2698	110	S-Q1_1	3	2025-06-29 23:27:41.222547+09	75
2699	110	S-Q3	No	2025-06-29 23:27:41.222547+09	0
2700	110	S-Q4	No	2025-06-29 23:27:41.222547+09	0
2701	110	S-Q5	No	2025-06-29 23:27:41.222547+09	100
2702	110	S-Q6	No	2025-06-29 23:27:41.222547+09	0
2703	110	S-Q7	No	2025-06-29 23:27:41.222547+09	0
2704	110	S-Q8	No	2025-06-29 23:27:41.222547+09	0
2705	110	S-Q9	No	2025-06-29 23:27:41.222547+09	0
2706	110	S-Q10	No	2025-06-29 23:27:41.222547+09	0
2707	110	S-Q11	No	2025-06-29 23:27:41.222547+09	0
2708	110	S-Q12	No	2025-06-29 23:27:41.222547+09	-50
2569	106	S-Q1	Yes	2025-06-29 02:46:52.335341+09	0
2402	100	S-Q1	No	2025-06-27 02:32:24.713698+09	0
2403	100	S-Q2	Yes	2025-06-27 02:32:24.713698+09	0
2404	100	S-Q2_1	1	2025-06-27 02:32:24.713698+09	100
2405	100	S-Q3	Yes	2025-06-27 02:32:24.713698+09	0
2406	100	S-Q3_1	3489000	2025-06-27 02:32:24.713698+09	50
2407	100	S-Q4	Yes	2025-06-27 02:32:24.713698+09	0
2408	100	S-Q4_1	3000	2025-06-27 02:32:24.713698+09	50
2409	100	S-Q5	Yes	2025-06-27 02:32:24.713698+09	0
2410	100	S-Q5_1	2	2025-06-27 02:32:24.713698+09	75
2411	100	S-Q6	No	2025-06-27 02:32:24.713698+09	0
2412	100	S-Q7	Yes	2025-06-27 02:32:24.713698+09	0
2413	100	S-Q7_1	2	2025-06-27 02:32:24.713698+09	40
2414	100	S-Q8	Yes	2025-06-27 02:32:24.713698+09	0
2415	100	S-Q8_1	2	2025-06-27 02:32:24.713698+09	40
2416	100	S-Q9	Yes	2025-06-27 02:32:24.713698+09	0
2417	100	S-Q9_1	1	2025-06-27 02:32:24.713698+09	25
2418	100	S-Q9_2	1	2025-06-27 02:32:24.713698+09	0
2419	100	S-Q10	Yes	2025-06-27 02:32:24.713698+09	0
2570	106	S-Q1_1	4	2025-06-29 02:46:52.335341+09	100
2571	106	S-Q2	Yes	2025-06-29 02:46:52.335341+09	0
2572	106	S-Q2_1	50	2025-06-29 02:46:52.335341+09	100
2573	106	S-Q3	Yes	2025-06-29 02:46:52.335341+09	0
2574	106	S-Q3_1	100000	2025-06-29 02:46:52.335341+09	100
2575	106	S-Q4	Yes	2025-06-29 02:46:52.335341+09	0
2576	106	S-Q4_1	200	2025-06-29 02:46:52.335341+09	100
2577	106	S-Q5	No	2025-06-29 02:46:52.335341+09	100
2578	106	S-Q6	Yes	2025-06-29 02:46:52.335341+09	0
2579	106	S-Q6_1	5	2025-06-29 02:46:52.335341+09	100
2580	106	S-Q6_2	0	2025-06-29 02:46:52.335341+09	0
2581	106	S-Q7	Yes	2025-06-29 02:46:52.335341+09	0
2582	106	S-Q7_1	5	2025-06-29 02:46:52.335341+09	100
2583	106	S-Q8	Yes	2025-06-29 02:46:52.335341+09	0
2584	106	S-Q8_1	5	2025-06-29 02:46:52.335341+09	100
2585	106	S-Q9	Yes	2025-06-29 02:46:52.335341+09	0
2586	106	S-Q9_1	4	2025-06-29 02:46:52.335341+09	100
2587	106	S-Q9_2	1	2025-06-29 02:46:52.335341+09	0
2588	106	S-Q10	Yes	2025-06-29 02:46:52.335341+09	0
2589	106	S-Q10_1	4	2025-06-29 02:46:52.335341+09	100
2590	106	S-Q11	Yes	2025-06-29 02:46:52.335341+09	0
2591	106	S-Q11_1	5	2025-06-29 02:46:52.335341+09	100
2420	100	S-Q10_1	2	2025-06-27 02:32:24.713698+09	50
2421	100	S-Q11	No	2025-06-27 02:32:24.713698+09	0
2422	100	S-Q12	Yes	2025-06-27 02:32:24.713698+09	0
2423	100	S-Q12_1	2	2025-06-27 02:32:24.713698+09	25
2424	100	S-Q13	No	2025-06-27 02:32:24.713698+09	0
2425	100	S-Q14	No	2025-06-27 02:32:24.713698+09	0
2426	100	S-Q15	No	2025-06-27 02:32:24.713698+09	0
2427	100	S-Q16	Yes	2025-06-27 02:32:24.713698+09	0
2428	100	S-Q16_1	2	2025-06-27 02:32:24.713698+09	-30
2592	106	S-Q12	Yes	2025-06-29 02:46:52.335341+09	0
2593	106	S-Q12_1	5	2025-06-29 02:46:52.335341+09	100
2594	106	S-Q13	Yes	2025-06-29 02:46:52.335341+09	0
2595	106	S-Q13_1	1	2025-06-29 02:46:52.335341+09	100
2596	106	S-Q14	Yes	2025-06-29 02:46:52.335341+09	0
2597	106	S-Q14_1	4	2025-06-29 02:46:52.335341+09	100
2598	106	S-Q15	Yes	2025-06-29 02:46:52.335341+09	0
2599	106	S-Q15_1	4	2025-06-29 02:46:52.335341+09	100
2600	106	S-Q16	No	2025-06-29 02:46:52.335341+09	100
2709	110	S-Q13	No	2025-06-29 23:27:41.222547+09	0
2710	110	S-Q14	No	2025-06-29 23:27:41.222547+09	0
2711	110	S-Q15	No	2025-06-29 23:27:41.222547+09	0
2712	110	S-Q16	No	2025-06-29 23:27:41.222547+09	100
2747	112	S-Q1	Yes	2025-07-01 23:33:33.558011+09	0
2748	112	S-Q1_1	2	2025-07-01 23:33:33.558011+09	50
2749	112	S-Q2	Yes	2025-07-01 23:33:33.558011+09	0
2750	112	S-Q2_1	300	2025-07-01 23:33:33.558011+09	50
2751	112	S-Q3	No	2025-07-01 23:33:33.558011+09	0
2752	112	S-Q4	Yes	2025-07-01 23:33:33.558011+09	0
2753	112	S-Q4_1	2222	2025-07-01 23:33:33.558011+09	50
2754	112	S-Q5	Yes	2025-07-01 23:33:33.558011+09	0
2755	112	S-Q5_1	2	2025-07-01 23:33:33.558011+09	75
2756	112	S-Q6	Yes	2025-07-01 23:33:33.558011+09	0
2757	112	S-Q6_1	2	2025-07-01 23:33:33.558011+09	25
2758	112	S-Q6_2	1	2025-07-01 23:33:33.558011+09	0
2759	112	S-Q7	Yes	2025-07-01 23:33:33.558011+09	0
2760	112	S-Q7_1	3	2025-07-01 23:33:33.558011+09	60
2761	112	S-Q8	Yes	2025-07-01 23:33:33.558011+09	0
2762	112	S-Q8_1	2	2025-07-01 23:33:33.558011+09	40
2763	112	S-Q9	Yes	2025-07-01 23:33:33.558011+09	0
2764	112	S-Q9_1	2	2025-07-01 23:33:33.558011+09	50
2765	112	S-Q9_2	1	2025-07-01 23:33:33.558011+09	0
2766	112	S-Q10	No	2025-07-01 23:33:33.558011+09	0
2767	112	S-Q11	No	2025-07-01 23:33:33.558011+09	0
2768	112	S-Q12	Yes	2025-07-01 23:33:33.558011+09	0
2769	112	S-Q12_1	1	2025-07-01 23:33:33.558011+09	0
2713	111	S-Q1	Yes	2025-06-30 10:35:11.197566+09	0
2472	103	S-Q1	Yes	2025-06-27 11:20:58.168126+09	0
2473	103	S-Q1_1	2	2025-06-27 11:20:58.168126+09	50
2474	103	S-Q2	Yes	2025-06-27 11:20:58.168126+09	0
2475	103	S-Q2_1	300	2025-06-27 11:20:58.168126+09	50
2476	103	S-Q3	Yes	2025-06-27 11:20:58.168126+09	0
2477	103	S-Q3_1	2089000	2025-06-27 11:20:58.168126+09	75
2478	103	S-Q4	Yes	2025-06-27 11:20:58.168126+09	0
2479	103	S-Q4_1	3000	2025-06-27 11:20:58.168126+09	25
2480	103	S-Q5	Yes	2025-06-27 11:20:58.168126+09	0
2481	103	S-Q5_1	1	2025-06-27 11:20:58.168126+09	100
2482	103	S-Q6	No	2025-06-27 11:20:58.168126+09	0
2483	103	S-Q7	Yes	2025-06-27 11:20:58.168126+09	0
2484	103	S-Q7_1	3	2025-06-27 11:20:58.168126+09	60
2485	103	S-Q8	Yes	2025-06-27 11:20:58.168126+09	0
2486	103	S-Q8_1	3	2025-06-27 11:20:58.168126+09	60
2487	103	S-Q9	Yes	2025-06-27 11:20:58.168126+09	0
2488	103	S-Q9_1	1	2025-06-27 11:20:58.168126+09	25
2489	103	S-Q9_2	1	2025-06-27 11:20:58.168126+09	0
2490	103	S-Q10	Yes	2025-06-27 11:20:58.168126+09	0
2491	103	S-Q10_1	2	2025-06-27 11:20:58.168126+09	50
2492	103	S-Q11	Yes	2025-06-27 11:20:58.168126+09	0
2493	103	S-Q11_1	2	2025-06-27 11:20:58.168126+09	40
2494	103	S-Q12	Yes	2025-06-27 11:20:58.168126+09	0
2495	103	S-Q12_1	2	2025-06-27 11:20:58.168126+09	25
2496	103	S-Q13	Yes	2025-06-27 11:20:58.168126+09	0
2497	103	S-Q13_1	2	2025-06-27 11:20:58.168126+09	80
2498	103	S-Q14	Yes	2025-06-27 11:20:58.168126+09	0
2499	103	S-Q14_1	2	2025-06-27 11:20:58.168126+09	50
2500	103	S-Q15	Yes	2025-06-27 11:20:58.168126+09	0
2501	103	S-Q15_1	1	2025-06-27 11:20:58.168126+09	25
2502	103	S-Q16	Yes	2025-06-27 11:20:58.168126+09	0
2503	103	S-Q16_1	2	2025-06-27 11:20:58.168126+09	-30
2714	111	S-Q1_1	2	2025-06-30 10:35:11.197566+09	50
2715	111	S-Q2	Yes	2025-06-30 10:35:11.197566+09	0
2716	111	S-Q2_1	300	2025-06-30 10:35:11.197566+09	50
2717	111	S-Q3	Yes	2025-06-30 10:35:11.197566+09	0
2718	111	S-Q3_1	3489000	2025-06-30 10:35:11.197566+09	50
2719	111	S-Q4	Yes	2025-06-30 10:35:11.197566+09	0
2720	111	S-Q4_1	2250	2025-06-30 10:35:11.197566+09	50
2721	111	S-Q5	Yes	2025-06-30 10:35:11.197566+09	0
2722	111	S-Q5_1	2	2025-06-30 10:35:11.197566+09	75
2723	111	S-Q6	Yes	2025-06-30 10:35:11.197566+09	0
2724	111	S-Q6_1	2	2025-06-30 10:35:11.197566+09	25
2725	111	S-Q6_2	1	2025-06-30 10:35:11.197566+09	0
2726	111	S-Q7	Yes	2025-06-30 10:35:11.197566+09	0
2727	111	S-Q7_1	2	2025-06-30 10:35:11.197566+09	40
2728	111	S-Q8	Yes	2025-06-30 10:35:11.197566+09	0
2729	111	S-Q8_1	3	2025-06-30 10:35:11.197566+09	60
2730	111	S-Q9	Yes	2025-06-30 10:35:11.197566+09	0
2731	111	S-Q9_1	2	2025-06-30 10:35:11.197566+09	50
2732	111	S-Q9_2	1	2025-06-30 10:35:11.197566+09	0
2733	111	S-Q10	Yes	2025-06-30 10:35:11.197566+09	0
2734	111	S-Q10_1	2	2025-06-30 10:35:11.197566+09	50
2735	111	S-Q11	Yes	2025-06-30 10:35:11.197566+09	0
2736	111	S-Q11_1	1	2025-06-30 10:35:11.197566+09	20
2737	111	S-Q12	Yes	2025-06-30 10:35:11.197566+09	0
2738	111	S-Q12_1	2	2025-06-30 10:35:11.197566+09	25
2739	111	S-Q13	Yes	2025-06-30 10:35:11.197566+09	0
2740	111	S-Q13_1	1	2025-06-30 10:35:11.197566+09	100
2601	107	S-Q1	Yes	2025-06-29 02:48:42.285838+09	0
2602	107	S-Q1_1	2	2025-06-29 02:48:42.285838+09	50
2603	107	S-Q2	Yes	2025-06-29 02:48:42.285838+09	0
2604	107	S-Q2_1	300	2025-06-29 02:48:42.285838+09	50
2605	107	S-Q3	No	2025-06-29 02:48:42.285838+09	0
2606	107	S-Q4	No	2025-06-29 02:48:42.285838+09	0
2607	107	S-Q5	Yes	2025-06-29 02:48:42.285838+09	0
2608	107	S-Q5_1	2	2025-06-29 02:48:42.285838+09	75
2609	107	S-Q6	No	2025-06-29 02:48:42.285838+09	0
2610	107	S-Q7	Yes	2025-06-29 02:48:42.285838+09	0
2611	107	S-Q7_1	3	2025-06-29 02:48:42.285838+09	60
2612	107	S-Q8	Yes	2025-06-29 02:48:42.285838+09	0
2613	107	S-Q8_1	3	2025-06-29 02:48:42.285838+09	60
2614	107	S-Q9	Yes	2025-06-29 02:48:42.285838+09	0
2615	107	S-Q9_1	2	2025-06-29 02:48:42.285838+09	50
2616	107	S-Q9_2	2	2025-06-29 02:48:42.285838+09	0
2617	107	S-Q10	Yes	2025-06-29 02:48:42.285838+09	0
2618	107	S-Q10_1	3	2025-06-29 02:48:42.285838+09	75
2619	107	S-Q11	Yes	2025-06-29 02:48:42.285838+09	0
2620	107	S-Q11_1	1	2025-06-29 02:48:42.285838+09	20
2621	107	S-Q12	Yes	2025-06-29 02:48:42.285838+09	0
2622	107	S-Q12_1	4	2025-06-29 02:48:42.285838+09	75
2623	107	S-Q13	No	2025-06-29 02:48:42.285838+09	0
2624	107	S-Q14	No	2025-06-29 02:48:42.285838+09	0
2625	107	S-Q15	No	2025-06-29 02:48:42.285838+09	0
2626	107	S-Q16	Yes	2025-06-29 02:48:42.285838+09	0
2627	107	S-Q16_1	3	2025-06-29 02:48:42.285838+09	-10
2741	111	S-Q14	Yes	2025-06-30 10:35:11.197566+09	0
2742	111	S-Q14_1	1	2025-06-30 10:35:11.197566+09	25
2743	111	S-Q15	Yes	2025-06-30 10:35:11.197566+09	0
2744	111	S-Q15_1	1	2025-06-30 10:35:11.197566+09	25
2745	111	S-Q16	Yes	2025-06-30 10:35:11.197566+09	0
2746	111	S-Q16_1	2	2025-06-30 10:35:11.197566+09	-30
2770	112	S-Q13	No	2025-07-01 23:33:33.558011+09	0
2771	112	S-Q14	No	2025-07-01 23:33:33.558011+09	0
2772	112	S-Q15	No	2025-07-01 23:33:33.558011+09	0
2773	112	S-Q16	Yes	2025-07-01 23:33:33.558011+09	0
2774	112	S-Q16_1	2	2025-07-01 23:33:33.558011+09	-30
2775	113	S-Q1	Yes	2025-07-02 01:02:18.994635+09	0
2776	113	S-Q1_1	2	2025-07-02 01:02:18.994635+09	50
2777	113	S-Q2	Yes	2025-07-02 01:02:18.994635+09	0
2778	113	S-Q2_1	300	2025-07-02 01:02:18.994635+09	50
2779	113	S-Q3	No	2025-07-02 01:02:18.994635+09	0
2780	113	S-Q4	No	2025-07-02 01:02:18.994635+09	0
2781	113	S-Q5	No	2025-07-02 01:02:18.994635+09	100
2782	113	S-Q6	No	2025-07-02 01:02:18.994635+09	0
2783	113	S-Q7	No	2025-07-02 01:02:18.994635+09	0
2784	113	S-Q8	No	2025-07-02 01:02:18.994635+09	0
2785	113	S-Q9	No	2025-07-02 01:02:18.994635+09	0
2786	113	S-Q10	No	2025-07-02 01:02:18.994635+09	0
2787	113	S-Q11	No	2025-07-02 01:02:18.994635+09	0
2788	113	S-Q12	No	2025-07-02 01:02:18.994635+09	-50
2789	113	S-Q13	No	2025-07-02 01:02:18.994635+09	0
2790	113	S-Q14	No	2025-07-02 01:02:18.994635+09	0
2791	113	S-Q15	No	2025-07-02 01:02:18.994635+09	0
2792	113	S-Q16	No	2025-07-02 01:02:18.994635+09	100
\.


--
-- Data for Name: esg_programs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.esg_programs (id, program_code, esg_category, title, content, updated_at, economic_effects, related_links, program_overview, risk_text, risk_description, opportunity_effects, status, service_regions) FROM stdin;
33	G-PROG-01	G	지속가능 재무	[{"images": ["program-1751343051059-vlad-hilitanu-pt7QzB4ZLWw-unsplash.jpg"], "subheading": "지속가능 재무 소제목", "description": "지속가능 재무 상세내용 테스트 \\n\\n27일 오후 6시30분쯤 서울 노원구 상계동 일대에 멧돼지가 나타났다는 신고가 119에 접수됐다.\\n\\n소방당국에 따르면 수락산에서 내려온 것으로 추정되는 멧돼지 1마리가 상계주공 1, 2단지 사이에서 발견됐다.\\n\\n이후 멧돼지는 현재 상계주공2단지 인근에서 대치했다가 오후 8시쯤 사살됐다.\\n\\n소방 관계자는 “경찰 입회하에 엽사가 멧돼지를 사살했다”며 “엽사에게 인계해 상황이 종료됐다”고 설명했다.", "image_layout": "row", "description_size": "16"}]	\N	[]	[{"homepage_url": "https://naver.worksmobile.com/", "organization_name": "연계단체 테스트"}]	지속가능 재무 개요	지속가능 재무 방치시 리스크 요약	지속가능 재무 방치시 리스크 세부설명	[{"type": "text", "value": "지속가능 재무 개선시 기대효과 요약 텍스트"}]	published	{""}
68	테스트 250701	E	테스트 250701	[{"images": ["program-1751343075941-marek-piwnicki-vzGQlsZ-ZhY-unsplash.jpg", "program-1751343076065-scott-taylor-02a4DSekRVg-unsplash.jpg"], "subheading": "테스트 250701 소제목", "description": "테스트 250701 상세내용", "image_layout": "row", "description_size": "16"}]	\N	[]	[{"homepage_url": "https://naver.worksmobile.com/", "organization_name": "연계단체 테스트"}]	테스트 250701 프로그램 개요	테스트 250701 방치 리스크 요약	테스트 250701 방치 리스크 세부설명	[{"type": "text", "value": "테스트 250701 개선시 기대효과 요약 텍스트"}]	published	{전국}
67	테스트 250630	E	테스트 250630	[{"images": ["program-1751343063293-zetong-li-AEYbdyOH2cU-unsplash.jpg"], "subheading": "테스트 250630 소제목", "description": "테스트 250630 소제목 내용", "image_layout": "row", "description_size": "16"}]	\N	[{"type": "per_ton_effect", "value": 100000, "description": "탄ㅅ"}]	[{"homepage_url": "https://naver.worksmobile.com/", "organization_name": "연계단체 테스트 "}]	테스트 250630 개요	테스트 250630 방치 리스크 요약	테스트 250630 세부설명	[{"rule": {"type": "calculation", "params": {"avgDataKey": "ghg_emissions_avg", "correctionFactor": 1}}, "type": "calculation", "description": "테스트 250630 계산식 세부설명"}]	published	{전국}
32	s-PROG-01	S	장애인 프로그램	[{"images": ["program-1751343041010-scott-taylor-02a4DSekRVg-unsplash.jpg"], "subheading": "장애인 프로그램 소제목", "description": "장애인 프로그램 상세내용 \\n27일 오후 6시30분쯤 서울 노원구 상계동 일대에 멧돼지가 나타났다는 신고가 119에 접수됐다.\\n\\n소방당국에 따르면 수락산에서 내려온 것으로 추정되는 멧돼지 1마리가 상계주공 1, 2단지 사이에서 발견됐다.\\n\\n이후 멧돼지는 현재 상계주공2단지 인근에서 대치했다가 오후 8시쯤 사살됐다.\\n\\n소방 관계자는 “경찰 입회하에 엽사가 멧돼지를 사살했다”며 “엽사에게 인계해 상황이 종료됐다”고 설명했다.", "image_layout": "row", "description_size": "16"}]	\N	[{"type": "unit_effect", "value": 500000, "description": ""}]	[{"homepage_url": "https://naver.worksmobile.com/", "organization_name": "연계단체 테스트 "}]	장애인 프로그램 개요 장애인 관련 비용 20% 감소	장애인 프로그램 리스크 테스트 인당 200만원 과태료 발생	방치 시 리스크 설명 테스트	[{"type": "text", "value": "개선시 기대효과 요약 텍스트 테스트 인당 50만원 지원금 "}, {"rule": {"type": "calculation", "params": {"avgDataKey": "disability_employment_ratio_avg", "correctionFactor": 100}}, "type": "calculation", "description": "개선시 기대효과 설명 테스트"}]	published	{서울}
1	E-PROG-01	E	에너지 효율 개선 컨설팅	[{"images": ["program-1751343029335-marek-piwnicki-vzGQlsZ-ZhY-unsplash.jpg"], "subheading": "123", "description": "27일 오후 6시30분쯤 서울 노원구 상계동 일대에 멧돼지가 나타났다는 신고가 119에 접수됐다.\\n\\n소방당국에 따르면 수락산에서 내려온 것으로 추정되는 멧돼지 1마리가 상계주공 1, 2단지 사이에서 발견됐다.\\n\\n이후 멧돼지는 현재 상계주공2단지 인근에서 대치했다가 오후 8시쯤 사살됐다.\\n\\n소방 관계자는 “경찰 입회하에 엽사가 멧돼지를 사살했다”며 “엽사에게 인계해 상황이 종료됐다”고 설명했다.", "image_layout": "row", "description_size": "16"}]	2025-06-27 13:29:57.048895+09	[{"type": "unit_effect", "value": 1000, "description": "12345"}, {"type": "per_ton_effect", "value": 1000, "description": "12345"}]	[{"homepage_url": "https://naver.worksmobile.com/", "organization_name": "연계단체 테스트 "}]	여기에 요약내용 들어감	톤당 100만원 비용 발생		[{"type": "text", "value": "에너지 효율 개선 20%"}, {"rule": {"type": "calculation", "params": {"avgDataKey": "ghg_emissions_avg", "correctionFactor": 1}}, "type": "calculation", "description": "설명부분"}]	published	{전국}
\.


--
-- Data for Name: industries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.industries (id, code, name, category_l, category_m, category_s, esg_issues, esg_opportunities, esg_risks) FROM stdin;
3	A01	농업	\N	\N	\N	\N	\N	\N
4	A02	임업	\N	\N	\N	\N	\N	\N
5	A03	어업	\N	\N	\N	\N	\N	\N
6	B05	석탄,원유 및 천연가스 광업	\N	\N	\N	\N	\N	\N
7	B06	금속광업	\N	\N	\N	\N	\N	\N
8	B07	비금속광물 광업: 연료용 제외	\N	\N	\N	\N	\N	\N
9	B08	광업 지원 서비스업	\N	\N	\N	\N	\N	\N
10	C10	식료품 제조업	\N	\N	\N	\N	\N	\N
11	C11	음료 제조업	\N	\N	\N	\N	\N	\N
12	C12	주류 제조업	\N	\N	\N	\N	\N	\N
13	C13	섬유제품 제조업	\N	\N	\N	\N	\N	\N
14	C14	의복 제조업	\N	\N	\N	\N	\N	\N
15	C15	피혁 제조업	\N	\N	\N	\N	\N	\N
16	C16	목재 제품 제조업	\N	\N	\N	\N	\N	\N
17	C17	펄프, 종이 제조업	\N	\N	\N	\N	\N	\N
18	C18	인쇄 및 기록매체 복제업	\N	\N	\N	\N	\N	\N
19	C19	코크스, 연탄 및 석유정제품 제조업	\N	\N	\N	\N	\N	\N
20	C20	화학물질 제조업	\N	\N	\N	\N	\N	\N
21	C21	의약품 제조업	\N	\N	\N	\N	\N	\N
22	C22	고무 및 플라스틱 제품 제조업	\N	\N	\N	\N	\N	\N
23	C23	비금속 광물제품 제조업	\N	\N	\N	\N	\N	\N
24	C24	1차 금속 제조업	\N	\N	\N	\N	\N	\N
25	C25	금속가공제품 제조업	\N	\N	\N	\N	\N	\N
26	C26	전자부품 제조업	\N	\N	\N	\N	\N	\N
27	C27	컴퓨터 및 주변장치 제조업	\N	\N	\N	\N	\N	\N
28	C28	전기장비 제조업	\N	\N	\N	\N	\N	\N
30	C30	기타 운송장비 제조업	\N	\N	\N	\N	\N	\N
31	C31	가구 제조업	\N	\N	\N	\N	\N	\N
32	C32	완구 및 스포츠용품 제조업	\N	\N	\N	\N	\N	\N
33	C33	기타 제품 제조업	\N	\N	\N	\N	\N	\N
34	C34	의료용 기기 제조업	\N	\N	\N	\N	\N	\N
35	D35	전기, 가스, 증기 및 공기조절 공급업	\N	\N	\N	\N	\N	\N
36	E36	수도업	\N	\N	\N	\N	\N	\N
37	E37	하수, 폐수 및 분뇨 처리업	\N	\N	\N	\N	\N	\N
38	E38	폐기물 처리업	\N	\N	\N	\N	\N	\N
39	E39	환경 정화 및 복원업	\N	\N	\N	\N	\N	\N
40	F41	건물 건설업	\N	\N	\N	\N	\N	\N
41	F42	토목 건설업	\N	\N	\N	\N	\N	\N
42	F43	전문직별 공사업	\N	\N	\N	\N	\N	\N
43	G45	자동차 판매업	\N	\N	\N	\N	\N	\N
44	G46	도매업	\N	\N	\N	\N	\N	\N
45	G47	소매업	\N	\N	\N	\N	\N	\N
46	H49	육상 운송업	\N	\N	\N	\N	\N	\N
47	H50	수상 운송업	\N	\N	\N	\N	\N	\N
48	H51	항공 운송업	\N	\N	\N	\N	\N	\N
49	H52	창고 및 운송지원 서비스업	\N	\N	\N	\N	\N	\N
50	I55	숙박업	\N	\N	\N	\N	\N	\N
51	I56	음식점업	\N	\N	\N	\N	\N	\N
52	J58	출판업	\N	\N	\N	\N	\N	\N
53	J59	영상,오디오,기록물 제작 및 배급업	\N	\N	\N	\N	\N	\N
54	J60	방송 및 영상·오디오물 제공 서비스업	\N	\N	\N	\N	\N	\N
55	J61	우편 및 통신업	\N	\N	\N	\N	\N	\N
57	J63	정보서비스업	\N	\N	\N	\N	\N	\N
58	K64	은행업	\N	\N	\N	\N	\N	\N
59	K65	보험업	\N	\N	\N	\N	\N	\N
60	K66	금융 및 보험관련 서비스업	\N	\N	\N	\N	\N	\N
61	L68	부동산업	\N	\N	\N	\N	\N	\N
62	M69	법무 및 회계 서비스업	\N	\N	\N	\N	\N	\N
63	M70	경영컨설팅업	\N	\N	\N	\N	\N	\N
64	M71	전문서비스업	\N	\N	\N	\N	\N	\N
65	M72	건축 기술, 엔지니어링 및 기타 과학기술 서비스업	\N	\N	\N	\N	\N	\N
66	M73	기타 전문, 과학 및 기술 서비스업	\N	\N	\N	\N	\N	\N
67	N74	사업시설 관리 및 조경 서비스업	\N	\N	\N	\N	\N	\N
68	N75	사업 지원 서비스업	\N	\N	\N	\N	\N	\N
69	N76	임대업 : 부동산 제외	\N	\N	\N	\N	\N	\N
70	N78	고용 서비스업	\N	\N	\N	\N	\N	\N
71	O84	공공행정 및 국방	\N	\N	\N	\N	\N	\N
72	P85	교육 서비스업	\N	\N	\N	\N	\N	\N
73	Q86	보건업	\N	\N	\N	\N	\N	\N
74	Q87	사회복지 서비스업	\N	\N	\N	\N	\N	\N
75	R90	예술 창작 및 공연업	\N	\N	\N	\N	\N	\N
76	R91	스포츠 및 오락관련 서비스업	\N	\N	\N	\N	\N	\N
77	S94	협회 및 단체	\N	\N	\N	\N	\N	\N
78	S95	개인 및 소비용품 수리업	\N	\N	\N	\N	\N	\N
79	S96	기타 개인 서비스업	\N	\N	\N	\N	\N	\N
80	T97	가구 내 고용활동	\N	\N	\N	\N	\N	\N
81	T98	달리 구분되지 않은 자가 소비를 위한 가구 재화 및 서비스 생산활동	\N	\N	\N	\N	\N	\N
82	U99	국제 및 외국기관	\N	\N	\N	\N	\N	\N
29	C29	자동차 및 트레일러 제조업	\N	\N	\N	{"높은 에너지 소비로 인한 탄소 배출","사업장 폐기물 처리 부담","공급망 내 인권 및 안전 문제"}	{"에너지 효율 개선을 통한 비용 절감","친환경 자동차 부품 개발","공급망 ESG 관리 강화로 고객사 신뢰 확보"}	{"탄소 배출 규제 강화","원자재 가격 변동성","협력업체 안전사고 발생 리스크"}
56	J62	소프트웨어 개발 및 공급업	\N	\N	\N	{"데이터센터의 높은 전력 소비","개인정보보호 및 데이터 보안","장시간 근무 및 개발자 인권 문제"}	{"클라우드 기반 서비스로 에너지 효율화","데이터 보안 기술 강화로 신뢰성 확보","유연 근무제 및 개발자 복지 향상"}	{"개인정보 유출 사고","서비스 장애로 인한 사회적 영향","핵심 개발자 이탈 리스크"}
\.


--
-- Data for Name: industry_averages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.industry_averages (id, industry_code, industry_name, ghg_emissions_avg, energy_usage_avg, waste_generation_avg, non_regular_ratio_avg, disability_employment_ratio_avg, female_employee_ratio_avg, years_of_service_avg, donation_ratio_avg, quality_mgmt_ratio_avg, outside_director_ratio_avg, board_meetings_avg, executive_compensation_ratio_avg, cumulative_voting_ratio_avg, dividend_policy_ratio_avg, legal_violation_ratio_avg) FROM stdin;
18	C20	화학물질 및 화학제품 제조업; 의약품 제외	17500.0	69780000.0	2500.0	30.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.03	\N	\N	\N
19	C21	의료용 물질 및 의약품 제조업	1000.0	4652000.0	300.0	25.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.54	\N	\N	\N
20	C22	고무 및 플라스틱제품 제조업	550.0	14537500.0	300.0	20.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
21	C23	비금속 광물제품 제조업	5000.0	34890000.0	1750.0	20.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.07	\N	\N	\N
22	C24	1차 금속 제조업	25000.0	168635000.0	5500.0	25.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.07	\N	\N	\N
23	C25	금속 가공제품 제조업; 기계 및 가구 제외	1000.0	17445000.0	300.0	35.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.07	\N	\N	\N
24	C26	전자제품 제조업	400.0	8722500.0	175.0	30.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
25	C27	컴퓨터 및 주변장치 제조업	100.0	1744500.0	60.0	20.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
26	C28	전기장비 제조업	400.0	8722500.0	175.0	30.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
27	C29	자동차 및 트레일러 제조업	2000.0	1744500.0	1250.0	25.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
28	C30	기타 운송장비 제조업	1500.0	8722500.0	1250.0	30.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.07	\N	\N	\N
29	C31	가구 제조업	100.0	1744500.0	60.0	40.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.14	\N	\N	\N
30	C32	완구 및 스포츠용품 제조업	150.0	2326000.0	60.0	35.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
31	C33	기타 제품 제조업	65.0	872250.0	30.0	35.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
32	C34	의료용 기기 제조업	65.0	872250.0	30.0	35.0	1.64	26.6	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
33	D35	전기, 가스, 증기 및 공기조절 공급업	225000.0	348900000.0	22500.0	15.0	3.19	13.1	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
34	E36	수도업; 하수, 폐기물 처리, 원료 재생업 제외	1250.0	8722500.0	600.0	15.0	2.5	22.0	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
35	E37	하수, 폐기물 처리, 원료 재생업	1000.0	1744500.0	1750.0	25.0	2.5	22.0	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
36	E38	폐기물 처리업	1250.0	3489000.0	3000.0	37.5	2.5	13.5	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
37	E39	환경 정화 및 복원업	125.0	232600.0	175.0	37.5	2.5	13.5	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
38	F41	건물 건설업	125.0	3489000.0	125.0	50.0	1.09	51.3	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
39	F42	토목 건설업	200.0	4652000.0	300.0	50.0	1.09	51.3	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
40	F43	전문직별 공사업	65.0	1744500.0	60.0	50.0	1.09	51.3	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
41	G45	자동차 및 부품 판매업	45.0	1744500.0	30.0	35.0	1.14	18.4	6.6	\N	\N	41.2	9.8	1.0	\N	\N	\N
42	G46	도매 및 상품 중개업	65.0	4652000.0	30.0	35.0	1.14	18.4	6.6	\N	\N	41.2	9.8	1.0	\N	\N	\N
43	G47	소매업; 자동차 제외	25.0	14537500.0	12.5	50.0	1.14	18.4	6.6	\N	\N	41.2	9.8	1.0	\N	\N	\N
44	H49	육상 운송 및 파이프라인 운송업	1250.0	58150000.0	175.0	42.5	1.29	18.4	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
45	H50	수상 운송업	3000.0	8722500.0	300.0	37.5	1.29	62.4	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
46	H51	항공 운송업	12500.0	17445000.0	300.0	25.0	1.29	62.4	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
47	H52	창고 및 운송관련 서비스업	300.0	8722500.0	60.0	37.5	1.29	34.6	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
48	I55	숙박업	75.0	5233500.0	30.0	57.5	1.25	34.6	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
49	I56	음식점 및 주점업	25.0	14537500.0	30.0	67.5	1.25	34.6	6.6	\N	\N	41.2	9.8	0.18	\N	\N	\N
50	J58	출판업	20.0	407050.0	17.5	35.0	2.37	34.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
51	J59	영상ㆍ오디오 기록물 제작 및 배급업	4.0	302380.0	12.5	50.0	2.37	34.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
52	J60	방송 및 영상오디오물 제공 서비스업	20.0	232600.0	12.5	37.5	2.37	34.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
53	J61	우편 및 통신업	40.0	523350.0	12.5	25.0	2.37	49.0	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
54	J63	정보서비스업	4.0	232600.0	6.0	27.5	2.37	49.0	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
55	K64	은행업	20.0	523350.0	6.0	20.0	2.39	47.5	6.6	\N	\N	41.2	9.8	0.57	\N	\N	\N
56	K65	보험업	10.0	174450.0	3.0	25.0	2.39	42.0	6.6	\N	\N	41.2	9.8	0.57	\N	\N	\N
57	K66	금융 및 보험 관련 서비스업	6.0	116300.0	3.0	25.0	2.39	42.0	6.6	\N	\N	41.2	9.8	0.57	\N	\N	\N
58	L68	부동산업	6.0	174450.0	3.0	42.5	1.83	42.0	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
4	B05	석탄 광업	12500	69780000	30000	20	0.81	9.9	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
5	B06	원유 및 천연가스 채굴업	60000	116300000	60000	20	0.81	9.9	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
6	B07	금속 광업	1250	14537500	5500	30	0.81	9.9	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
3	A03	어업	35	232600	90	60	0.73	49.2	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
7	B08	비금속광물 광업; 연료용 제외	300	3489000	2250	30	0.81	9.9	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
8	C10	식료품 제조업	1000	4070500	600	37.5	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
9	C11	음료 제조업	550	3489000	300	37.5	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
10	C12	담배 제조업	200	232600	125	37.5	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
11	C13	섬유제품 제조업; 의복 제외	350	1453750	300	40	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
13	C15	가죽, 가방 및 신발 제조업	100	407050	60	45	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
14	C16	목재 및 나무제품 제조업; 가구 제외	200	1744500	175	40	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
15	C17	펄프, 종이 및 종이제품 제조업	6000	14537500	1750	35	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
16	C18	인쇄 및 기록매체 복제업	75	872250	60	40	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
17	C19	코크스, 연탄 및 석유정제품 제조업	80000	116300000	5500	25	1.64	26.6	6.6	\N	\N	41.2	9.8	0.03	\N	\N	\N
2	A02	임업	12.5	116300	30	50	0.73	49.2	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
59	M69	법무 및 회계 서비스업	3.5	116300.0	2.0	22.5	2.01	49.8	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
60	M70	연구개발업	3.5	116300.0	6.0	22.5	2.01	49.8	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
61	M71	전문서비스업	5.0	116300.0	3.0	32.5	2.01	38.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
62	M72	건축,기술,엔지니어링 및 기타 과학기술 서비스업	10.0	29075.0	2.0	32.5	2.01	38.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
63	M73	기타 전문, 과학 및 기술 서비스업	3.5	87225.0	2.0	32.5	2.01	38.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
64	N74	사업시설 관리 및 조경 서비스업	3.5	87225.0	2.0	32.5	2.33	62.9	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
65	N75	사업 지원 서비스업	10.0	174450.0	3.0	32.5	2.33	79.5	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
66	N76	임대업:부동산 제외	3.5	87225.0	2.0	32.5	2.33	79.5	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
67	N78	고용 서비스업	5.0	174450.0	3.0	32.5	2.33	79.5	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
68	O84	공공행정 및 국방	10.0	87225.0	6.0	30.0	3.32	79.5	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
69	P85	교육 서비스업	6.5	75595.0	6.0	35.0	1.76	51.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
70	Q86	보건업	20.0	145375.0	12.5	42.5	2.34	51.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
71	Q87	사회복지 서비스업	5.0	40705.0	3.0	50.0	2.34	51.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
72	R90	예술 창작 및 공연업	6.0	69780.0	3.0	55.0	1.88	51.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
73	R91	스포츠 및 오락관련 서비스업	6.5	75595.0	3.0	45.0	1.88	51.6	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
74	S94	협회 및 단체	3.0	23260.0	2.0	55.0	2.31	54.5	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
75	S95	개인 및 소비용품 수리업	2.0	23260.0	2.0	55.0	2.31	54.5	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
76	S96	기타 개인 서비스업	2.0	23260.0	2.0	55.0	2.31	54.5	6.6	\N	\N	41.2	9.8	0.44	\N	\N	\N
77	U99	국제 및 외국기관	5	40705	3	45	2.31	54.5	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
1	A01	농업	20	11630	40	60	0.73	49.2	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
12	C14	의복, 의복 액세서리 및 모피제품 제조업	100	872250	60	45	1.64	26.6	6.6	\N	\N	41.2	9.8	0.12	\N	\N	\N
\.


--
-- Data for Name: industry_benchmark_scores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.industry_benchmark_scores (id, industry_code, question_code, average_score, notes, last_calculated_at) FROM stdin;
84	A03	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
90	A03	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
95	A03	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
101	A03	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
94	A03	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
96	A03	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
97	A03	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
98	A03	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
77	A03	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
102	A03	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
99	A03	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
118	B05	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
124	B05	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
129	B05	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
135	B05	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
128	B05	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
130	B05	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
131	B05	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
132	B05	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
111	B05	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
136	B05	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
133	B05	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
151	B06	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
152	B06	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
158	B06	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
163	B06	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
169	B06	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
161	B06	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
162	B06	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
164	B06	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
165	B06	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
166	B06	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
143	B06	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
140	B06	S-Q5_1	100.00	\N	2025-06-25 16:13:29.27617+09
145	B06	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
148	B06	S-Q7_1	20.00	\N	2025-06-25 16:13:29.27617+09
170	B06	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
167	B06	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
144	B06	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
171	B07	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
173	B07	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
185	B07	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
186	B07	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
192	B07	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
197	B07	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
203	B07	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
195	B07	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
196	B07	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
198	B07	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
199	B07	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
200	B07	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
177	B07	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
174	B07	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
179	B07	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
182	B07	S-Q7_1	20.00	\N	2025-06-25 16:13:29.27617+09
204	B07	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
201	B07	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
178	B07	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1062	D35	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1121	E36	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1113	E36	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1114	E36	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1116	E36	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1117	E36	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1118	E36	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1095	E36	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1092	E36	S-Q5_1	100.00	\N	2025-06-25 16:13:29.27617+09
1097	E36	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1100	E36	S-Q7_1	80.00	\N	2025-06-25 16:13:29.27617+09
1122	E36	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1119	E36	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1096	E36	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1123	E37	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1125	E37	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
205	B08	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
207	B08	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
219	B08	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
220	B08	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
226	B08	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
231	B08	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
237	B08	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
229	B08	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
230	B08	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
232	B08	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
233	B08	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
234	B08	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
211	B08	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
208	B08	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
213	B08	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
216	B08	S-Q7_1	20.00	\N	2025-06-25 16:13:29.27617+09
238	B08	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
235	B08	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
212	B08	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
239	C10	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
241	C10	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
253	C10	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
254	C10	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
260	C10	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
265	C10	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
271	C10	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
263	C10	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
264	C10	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
266	C10	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
267	C10	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
268	C10	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
245	C10	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
242	C10	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
247	C10	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
250	C10	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
272	C10	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
269	C10	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
246	C10	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
273	C11	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
275	C11	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
287	C11	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
288	C11	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
294	C11	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
299	C11	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
305	C11	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
297	C11	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
298	C11	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
300	C11	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
301	C11	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
302	C11	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
279	C11	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
276	C11	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
281	C11	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1089	E36	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1137	E37	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1138	E37	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1144	E37	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1149	E37	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1155	E37	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1147	E37	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1148	E37	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1150	E37	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1151	E37	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1152	E37	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1129	E37	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1126	E37	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1131	E37	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1134	E37	S-Q7_1	80.00	\N	2025-06-25 16:13:29.27617+09
1156	E37	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1153	E37	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1130	E37	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1157	E38	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1159	E38	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1171	E38	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1172	E38	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1178	E38	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1183	E38	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1189	E38	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1181	E38	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
284	C11	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
306	C11	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
303	C11	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
280	C11	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
307	C12	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
309	C12	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
321	C12	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
322	C12	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
328	C12	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
333	C12	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
339	C12	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
331	C12	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
332	C12	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
334	C12	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
335	C12	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
336	C12	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
313	C12	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
310	C12	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
315	C12	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
318	C12	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
340	C12	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
337	C12	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
314	C12	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
341	C13	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
343	C13	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
355	C13	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
356	C13	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
362	C13	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
367	C13	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
373	C13	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
365	C13	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
366	C13	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
368	C13	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
369	C13	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
370	C13	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
347	C13	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
344	C13	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
349	C13	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
352	C13	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
374	C13	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
371	C13	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
348	C13	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
375	C14	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
377	C14	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
389	C14	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
390	C14	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
396	C14	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
401	C14	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
407	C14	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
399	C14	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
400	C14	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
402	C14	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
403	C14	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1091	E36	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1182	E38	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1184	E38	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1185	E38	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1186	E38	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1163	E38	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1160	E38	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1165	E38	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1168	E38	S-Q7_1	40.00	\N	2025-06-25 16:13:29.27617+09
1190	E38	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1187	E38	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1164	E38	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1191	E39	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1193	E39	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1205	E39	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1206	E39	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1212	E39	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1217	E39	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1223	E39	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1215	E39	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1216	E39	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1218	E39	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1219	E39	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1220	E39	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1197	E39	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1194	E39	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
404	C14	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
381	C14	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
378	C14	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
383	C14	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
386	C14	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
408	C14	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
405	C14	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
382	C14	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
409	C15	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
411	C15	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
423	C15	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
424	C15	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
430	C15	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
435	C15	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
441	C15	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
433	C15	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
434	C15	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
436	C15	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
437	C15	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
438	C15	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
415	C15	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
412	C15	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
417	C15	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
420	C15	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
442	C15	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
439	C15	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
416	C15	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
443	C16	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
445	C16	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
457	C16	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
458	C16	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
464	C16	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
469	C16	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
475	C16	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
467	C16	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
468	C16	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
470	C16	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
471	C16	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
472	C16	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
449	C16	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
446	C16	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
451	C16	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
454	C16	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
476	C16	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
473	C16	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
450	C16	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
477	C17	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
479	C17	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
491	C17	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
492	C17	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
498	C17	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
503	C17	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1199	E39	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1202	E39	S-Q7_1	40.00	\N	2025-06-25 16:13:29.27617+09
1224	E39	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1221	E39	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1198	E39	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1225	F41	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1227	F41	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1239	F41	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1240	F41	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1246	F41	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1251	F41	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1257	F41	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1249	F41	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1250	F41	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1252	F41	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1253	F41	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1254	F41	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1231	F41	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1228	F41	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
1233	F41	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1236	F41	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1258	F41	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1255	F41	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1232	F41	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1259	F42	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1261	F42	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1273	F42	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1274	F42	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1280	F42	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
509	C17	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
501	C17	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
502	C17	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
504	C17	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
505	C17	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
506	C17	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
483	C17	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
480	C17	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
485	C17	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
488	C17	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
510	C17	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
507	C17	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
484	C17	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
511	C18	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
513	C18	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
525	C18	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
526	C18	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
532	C18	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
537	C18	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
543	C18	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
535	C18	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
536	C18	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
538	C18	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
539	C18	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
540	C18	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
517	C18	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
514	C18	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
519	C18	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
522	C18	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
544	C18	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
541	C18	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
518	C18	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
545	C19	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
547	C19	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
559	C19	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
560	C19	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
566	C19	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
571	C19	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
577	C19	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
569	C19	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
570	C19	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
572	C19	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
573	C19	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
574	C19	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
551	C19	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
548	C19	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
553	C19	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
556	C19	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
578	C19	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
575	C19	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
552	C19	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
579	C20	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
581	C20	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
593	C20	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1103	E36	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1285	F42	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1291	F42	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1283	F42	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1284	F42	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1286	F42	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1287	F42	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1288	F42	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1265	F42	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1262	F42	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
1267	F42	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1270	F42	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1292	F42	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1289	F42	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1266	F42	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1293	F43	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1295	F43	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1307	F43	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1308	F43	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1314	F43	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1319	F43	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1325	F43	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1317	F43	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1318	F43	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
594	C20	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
602	C20	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
600	C20	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
601	C20	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
605	C20	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
611	C20	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
603	C20	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
604	C20	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
606	C20	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
607	C20	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
608	C20	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
585	C20	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
582	C20	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
583	C20	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
584	C20	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
587	C20	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
588	C20	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
589	C20	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
590	C20	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
591	C20	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
596	C20	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
597	C20	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
598	C20	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
599	C20	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
612	C20	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
609	C20	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
610	C20	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
586	C20	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
613	C21	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
615	C21	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
627	C21	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
628	C21	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
634	C21	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
639	C21	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
645	C21	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
637	C21	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
638	C21	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
640	C21	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
641	C21	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
642	C21	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
619	C21	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
616	C21	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
621	C21	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
624	C21	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
646	C21	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
643	C21	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
620	C21	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
647	C22	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
649	C22	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
661	C22	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
662	C22	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
668	C22	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
673	C22	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
679	C22	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1320	F43	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1321	F43	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1322	F43	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1299	F43	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1296	F43	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
1301	F43	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1304	F43	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1326	F43	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1323	F43	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1300	F43	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1327	G45	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1329	G45	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1341	G45	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1342	G45	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1348	G45	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1353	G45	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1359	G45	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1351	G45	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1352	G45	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1354	G45	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1355	G45	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1356	G45	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1333	G45	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1330	G45	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1335	G45	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1338	G45	S-Q7_1	60.00	\N	2025-06-25 16:13:29.27617+09
671	C22	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
672	C22	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
674	C22	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
675	C22	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
676	C22	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
653	C22	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
650	C22	S-Q5_1	100.00	\N	2025-06-25 16:13:29.27617+09
655	C22	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
658	C22	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
680	C22	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
677	C22	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
654	C22	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
681	C23	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
683	C23	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
695	C23	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
696	C23	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
702	C23	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
707	C23	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
713	C23	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
705	C23	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
706	C23	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
708	C23	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
709	C23	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
710	C23	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
687	C23	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
684	C23	S-Q5_1	100.00	\N	2025-06-25 16:13:29.27617+09
689	C23	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
692	C23	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
714	C23	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
711	C23	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
688	C23	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
715	C24	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
717	C24	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
729	C24	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
730	C24	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
736	C24	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
741	C24	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
747	C24	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
739	C24	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
740	C24	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
742	C24	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
743	C24	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
744	C24	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
721	C24	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
718	C24	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
723	C24	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
726	C24	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
748	C24	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
745	C24	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
722	C24	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
749	C25	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
751	C25	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
763	C25	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
764	C25	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1104	E36	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1360	G45	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1357	G45	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1334	G45	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1361	G46	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1363	G46	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1375	G46	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1376	G46	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1382	G46	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1387	G46	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1393	G46	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1385	G46	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1386	G46	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1388	G46	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1389	G46	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1390	G46	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1367	G46	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1364	G46	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1369	G46	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1372	G46	S-Q7_1	60.00	\N	2025-06-25 16:13:29.27617+09
1394	G46	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1391	G46	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1368	G46	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1395	G47	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
770	C25	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
775	C25	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
781	C25	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
773	C25	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
774	C25	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
776	C25	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
777	C25	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
778	C25	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
755	C25	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
752	C25	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
757	C25	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
760	C25	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
782	C25	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
779	C25	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
756	C25	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
783	C26	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
785	C26	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
797	C26	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
798	C26	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
804	C26	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
809	C26	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
815	C26	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
807	C26	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
808	C26	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
810	C26	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
811	C26	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
812	C26	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
789	C26	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
786	C26	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
791	C26	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
794	C26	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
816	C26	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
813	C26	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
790	C26	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
817	C27	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
819	C27	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
831	C27	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
832	C27	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
838	C27	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
843	C27	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
849	C27	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
841	C27	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
842	C27	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
844	C27	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
845	C27	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
846	C27	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
823	C27	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
820	C27	S-Q5_1	100.00	\N	2025-06-25 16:13:29.27617+09
825	C27	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
828	C27	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
850	C27	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
847	C27	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
824	C27	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
851	C28	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1110	E36	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1397	G47	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1409	G47	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1410	G47	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1416	G47	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1421	G47	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1427	G47	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1419	G47	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1420	G47	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1422	G47	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1423	G47	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1424	G47	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1401	G47	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1398	G47	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
1403	G47	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1406	G47	S-Q7_1	60.00	\N	2025-06-25 16:13:29.27617+09
1428	G47	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1425	G47	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1402	G47	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1429	H49	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1431	H49	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1443	H49	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1444	H49	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1450	H49	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
853	C28	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
865	C28	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
866	C28	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
872	C28	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
877	C28	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
883	C28	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
875	C28	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
876	C28	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
878	C28	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
879	C28	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
880	C28	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
857	C28	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
854	C28	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
859	C28	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
862	C28	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
884	C28	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
881	C28	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
858	C28	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
885	C30	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
887	C30	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
899	C30	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
900	C30	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
906	C30	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
911	C30	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
917	C30	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
909	C30	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
910	C30	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
912	C30	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
913	C30	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
914	C30	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
891	C30	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
888	C30	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
893	C30	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
896	C30	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
918	C30	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
915	C30	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
892	C30	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
919	C31	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
921	C31	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
933	C31	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
934	C31	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
940	C31	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
945	C31	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
951	C31	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
943	C31	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
944	C31	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
946	C31	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
947	C31	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
948	C31	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
925	C31	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
922	C31	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
927	C31	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1455	H49	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1461	H49	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1453	H49	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1454	H49	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1456	H49	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1457	H49	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1458	H49	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1435	H49	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1432	H49	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
1437	H49	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1440	H49	S-Q7_1	60.00	\N	2025-06-25 16:13:29.27617+09
1462	H49	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1459	H49	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1436	H49	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1463	H50	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1465	H50	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1477	H50	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1478	H50	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1484	H50	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1489	H50	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1495	H50	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1487	H50	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1488	H50	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1490	H50	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1491	H50	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1492	H50	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1469	H50	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1466	H50	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1471	H50	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
930	C31	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
952	C31	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
949	C31	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
926	C31	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
953	C32	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
955	C32	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
967	C32	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
968	C32	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
974	C32	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
979	C32	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
985	C32	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
977	C32	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
978	C32	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
980	C32	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
981	C32	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
982	C32	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
959	C32	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
956	C32	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
961	C32	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
964	C32	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
986	C32	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
983	C32	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
960	C32	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
987	C33	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
989	C33	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1001	C33	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1002	C33	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1008	C33	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1013	C33	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1019	C33	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1011	C33	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1012	C33	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1014	C33	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1015	C33	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1016	C33	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
993	C33	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
990	C33	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
995	C33	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
998	C33	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1020	C33	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1017	C33	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
994	C33	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1021	C34	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1023	C34	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1035	C34	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1036	C34	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1042	C34	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1047	C34	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1053	C34	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1045	C34	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1046	C34	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1048	C34	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1049	C34	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1115	E36	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1474	H50	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1496	H50	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1493	H50	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1470	H50	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1497	H51	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1499	H51	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1511	H51	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1512	H51	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1518	H51	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1523	H51	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1529	H51	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1521	H51	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1522	H51	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1524	H51	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1525	H51	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1526	H51	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1503	H51	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1500	H51	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1505	H51	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1508	H51	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1530	H51	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1527	H51	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1504	H51	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1531	H52	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1533	H52	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
42	A02	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
69	A03	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
71	A03	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
83	A03	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
93	A03	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
75	A03	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
72	A03	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
80	A03	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
76	A03	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
103	B05	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
105	B05	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
117	B05	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
127	B05	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
109	B05	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
106	B05	S-Q5_1	100.00	\N	2025-06-25 16:13:29.27617+09
114	B05	S-Q7_1	20.00	\N	2025-06-25 16:13:29.27617+09
110	B05	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
137	B06	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
139	B06	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1545	H52	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1546	H52	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1552	H52	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1557	H52	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1563	H52	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1555	H52	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1556	H52	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1558	H52	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1559	H52	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1560	H52	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1537	H52	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1534	H52	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1539	H52	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1542	H52	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1564	H52	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1561	H52	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1538	H52	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1565	I55	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1567	I55	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1579	I55	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1580	I55	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1586	I55	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1591	I55	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1597	I55	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1589	I55	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1590	I55	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1592	I55	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1593	I55	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1594	I55	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1571	I55	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1568	I55	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
1573	I55	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1576	I55	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1598	I55	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1595	I55	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1572	I55	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1599	I56	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1601	I56	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1613	I56	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1614	I56	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1620	I56	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1625	I56	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1631	I56	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1623	I56	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1624	I56	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1626	I56	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1627	I56	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1628	I56	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1605	I56	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1602	I56	S-Q5_1	25.00	\N	2025-06-25 16:13:29.27617+09
1607	I56	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1610	I56	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1632	I56	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1629	I56	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1606	I56	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1633	J58	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1635	J58	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1647	J58	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1648	J58	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1654	J58	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1659	J58	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1665	J58	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1657	J58	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1658	J58	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1660	J58	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1661	J58	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1662	J58	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1639	J58	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1636	J58	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1641	J58	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1644	J58	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1666	J58	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1663	J58	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1640	J58	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1667	J59	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1669	J59	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1681	J59	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1682	J59	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1688	J59	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1693	J59	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1699	J59	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1691	J59	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1692	J59	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1694	J59	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1695	J59	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1696	J59	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1673	J59	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1670	J59	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
1675	J59	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1678	J59	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1700	J59	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1697	J59	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1674	J59	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1701	J60	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1703	J60	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1715	J60	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1716	J60	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1722	J60	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1727	J60	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1733	J60	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1725	J60	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1726	J60	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1728	J60	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1729	J60	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1730	J60	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1707	J60	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1704	J60	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1709	J60	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1712	J60	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1734	J60	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1731	J60	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1708	J60	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1735	J61	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1737	J61	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1749	J61	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1750	J61	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1756	J61	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1761	J61	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1767	J61	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1759	J61	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1760	J61	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1762	J61	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1763	J61	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1764	J61	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1741	J61	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1738	J61	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1743	J61	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1746	J61	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1768	J61	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1765	J61	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1742	J61	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1769	J63	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1771	J63	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1783	J63	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1784	J63	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1790	J63	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1795	J63	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1801	J63	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1793	J63	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1794	J63	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1796	J63	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1797	J63	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1798	J63	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1775	J63	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1772	J63	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1777	J63	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1780	J63	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1802	J63	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1799	J63	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1776	J63	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1803	K64	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1805	K64	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1817	K64	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1818	K64	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1824	K64	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1829	K64	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1835	K64	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1827	K64	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1828	K64	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1830	K64	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1831	K64	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1832	K64	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1809	K64	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1806	K64	S-Q5_1	100.00	\N	2025-06-25 16:13:29.27617+09
1811	K64	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1814	K64	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1836	K64	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1833	K64	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1810	K64	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1837	K65	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1839	K65	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1851	K65	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1852	K65	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1858	K65	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1863	K65	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1869	K65	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1861	K65	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1862	K65	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1864	K65	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1865	K65	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1866	K65	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1843	K65	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1840	K65	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1845	K65	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1848	K65	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1870	K65	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1867	K65	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1844	K65	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1871	K66	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1873	K66	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1885	K66	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1886	K66	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1892	K66	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1897	K66	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1903	K66	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1895	K66	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1896	K66	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1898	K66	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1899	K66	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1900	K66	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1877	K66	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1874	K66	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1879	K66	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1882	K66	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1904	K66	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1901	K66	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1878	K66	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1905	L68	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1907	L68	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1919	L68	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1920	L68	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1926	L68	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1931	L68	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1937	L68	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1929	L68	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1930	L68	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1932	L68	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1933	L68	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1934	L68	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1911	L68	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1908	L68	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
1913	L68	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1916	L68	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1938	L68	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1935	L68	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1912	L68	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1939	M69	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1941	M69	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1953	M69	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1954	M69	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1960	M69	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1965	M69	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1971	M69	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1963	M69	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1964	M69	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1966	M69	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1967	M69	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1968	M69	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1945	M69	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1942	M69	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1947	M69	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1950	M69	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1972	M69	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1969	M69	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1946	M69	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1973	M70	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1975	M70	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1987	M70	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1988	M70	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1994	M70	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1999	M70	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2005	M70	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1997	M70	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1998	M70	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2000	M70	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2001	M70	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2002	M70	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1979	M70	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1976	M70	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1981	M70	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1984	M70	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2006	M70	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2003	M70	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1980	M70	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2007	M71	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2009	M71	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2021	M71	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2022	M71	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2028	M71	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2033	M71	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2039	M71	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2031	M71	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2032	M71	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2034	M71	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2035	M71	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2036	M71	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2013	M71	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2010	M71	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
2015	M71	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2018	M71	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2040	M71	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2037	M71	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2014	M71	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2041	M72	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2043	M72	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2055	M72	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2056	M72	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2062	M72	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2067	M72	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2073	M72	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2065	M72	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2066	M72	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2068	M72	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2069	M72	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2070	M72	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2047	M72	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2049	M72	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2052	M72	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2074	M72	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2071	M72	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2048	M72	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2075	M73	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2077	M73	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2089	M73	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2090	M73	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2096	M73	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2101	M73	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2107	M73	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2099	M73	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2100	M73	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2102	M73	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2103	M73	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2104	M73	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2081	M73	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2078	M73	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
2083	M73	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2086	M73	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2108	M73	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2105	M73	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2082	M73	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2109	N74	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2111	N74	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2123	N74	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2124	N74	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2130	N74	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2135	N74	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2141	N74	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2133	N74	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2134	N74	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2136	N74	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2137	N74	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2138	N74	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2115	N74	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2112	N74	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
2117	N74	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2120	N74	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2142	N74	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2139	N74	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2116	N74	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2143	N75	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2145	N75	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2157	N75	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2158	N75	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2164	N75	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2169	N75	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2175	N75	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2167	N75	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2168	N75	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2170	N75	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2171	N75	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2172	N75	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2149	N75	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2146	N75	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
2151	N75	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2154	N75	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2176	N75	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2173	N75	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2150	N75	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2177	N76	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2179	N76	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2191	N76	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2192	N76	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2198	N76	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2203	N76	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2209	N76	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2235	N78	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2236	N78	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2238	N78	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2239	N78	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2240	N78	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2217	N78	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2214	N78	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
2219	N78	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2222	N78	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2244	N78	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2241	N78	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2218	N78	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2245	O84	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2247	O84	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2259	O84	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2260	O84	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2266	O84	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2271	O84	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2277	O84	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2269	O84	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2270	O84	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2272	O84	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2273	O84	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2274	O84	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2251	O84	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2248	O84	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
2253	O84	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2256	O84	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2278	O84	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2275	O84	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2252	O84	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2279	P85	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2281	P85	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2293	P85	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2294	P85	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2300	P85	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2305	P85	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2311	P85	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2303	P85	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2304	P85	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2306	P85	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2307	P85	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2308	P85	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2285	P85	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2282	P85	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
2287	P85	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2290	P85	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2312	P85	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2309	P85	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2286	P85	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2313	Q86	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2315	Q86	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2327	Q86	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2328	Q86	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2334	Q86	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2339	Q86	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2345	Q86	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2337	Q86	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2338	Q86	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2340	Q86	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2341	Q86	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2342	Q86	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2319	Q86	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2316	Q86	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2321	Q86	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2324	Q86	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2346	Q86	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2343	Q86	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2320	Q86	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2347	Q87	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2349	Q87	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2361	Q87	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2362	Q87	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2368	Q87	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2373	Q87	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2379	Q87	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2371	Q87	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2372	Q87	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2374	Q87	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2375	Q87	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2376	Q87	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2353	Q87	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2350	Q87	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2355	Q87	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2358	Q87	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2380	Q87	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2377	Q87	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2354	Q87	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2381	R90	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2383	R90	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2395	R90	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2396	R90	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2402	R90	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2407	R90	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2413	R90	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2405	R90	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2406	R90	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2408	R90	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2409	R90	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2410	R90	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2387	R90	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2384	R90	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2389	R90	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2392	R90	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2414	R90	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2411	R90	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2388	R90	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2415	R91	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2417	R91	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2429	R91	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2430	R91	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2436	R91	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2441	R91	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2447	R91	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2439	R91	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2440	R91	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2442	R91	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2443	R91	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2444	R91	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2421	R91	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2418	R91	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2423	R91	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2426	R91	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2448	R91	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2445	R91	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2422	R91	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2449	S94	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2451	S94	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2463	S94	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2464	S94	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2470	S94	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2475	S94	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2481	S94	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2473	S94	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2474	S94	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2476	S94	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2477	S94	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2478	S94	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2455	S94	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2452	S94	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2460	S94	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2482	S94	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2479	S94	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1050	C34	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1027	C34	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1024	C34	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
1029	C34	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1032	C34	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
1054	C34	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1051	C34	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
1028	C34	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1055	D35	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
1057	D35	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
1069	D35	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
1070	D35	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
1076	D35	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
1081	D35	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
1087	D35	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
1079	D35	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
1080	D35	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
1082	D35	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
1083	D35	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
1084	D35	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
1061	D35	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
1058	D35	S-Q5_1	100.00	\N	2025-06-25 16:13:29.27617+09
1063	D35	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1066	D35	S-Q7_1	40.00	\N	2025-06-25 16:13:29.27617+09
1088	D35	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
1085	D35	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2456	S94	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2483	S95	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2485	S95	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2497	S95	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2498	S95	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2504	S95	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2509	S95	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2515	S95	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2507	S95	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2508	S95	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2510	S95	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2511	S95	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2512	S95	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2489	S95	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2486	S95	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2491	S95	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2494	S95	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2516	S95	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2513	S95	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2490	S95	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2517	S96	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2519	S96	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2531	S96	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2532	S96	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2538	S96	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2543	S96	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2549	S96	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2541	S96	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2542	S96	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2544	S96	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2545	S96	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2546	S96	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2523	S96	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2520	S96	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2525	S96	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2528	S96	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2550	S96	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2547	S96	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2524	S96	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2551	T97	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2553	T97	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2565	T97	S-Q8_1	50.00	\N	2025-06-25 16:13:29.27617+09
2566	T97	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2572	T97	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2577	T97	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2583	T97	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2575	T97	S-Q11_1	50.00	\N	2025-06-25 16:13:29.27617+09
2576	T97	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2578	T97	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2579	T97	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2580	T97	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2557	T97	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2554	T97	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2559	T97	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2562	T97	S-Q7_1	50.00	\N	2025-06-25 16:13:29.27617+09
2584	T97	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2581	T97	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2558	T97	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2585	T98	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2587	T98	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2599	T98	S-Q8_1	50.00	\N	2025-06-25 16:13:29.27617+09
2600	T98	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2606	T98	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2611	T98	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2617	T98	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2609	T98	S-Q11_1	50.00	\N	2025-06-25 16:13:29.27617+09
2610	T98	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2612	T98	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2613	T98	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2614	T98	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2591	T98	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2588	T98	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2593	T98	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2596	T98	S-Q7_1	50.00	\N	2025-06-25 16:13:29.27617+09
2618	T98	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2615	T98	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2643	U99	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2644	U99	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2646	U99	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2694	J62	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
1	A01	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2	A01	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
3	A01	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
14	A01	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
15	A01	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
16	A01	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
17	A01	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
24	A01	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
22	A01	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
23	A01	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
27	A01	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
33	A01	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
25	A01	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
26	A01	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
28	A01	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
29	A01	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
30	A01	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
7	A01	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
4	A01	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
5	A01	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
6	A01	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
9	A01	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
10	A01	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
11	A01	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
12	A01	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
13	A01	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
18	A01	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
19	A01	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
20	A01	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
21	A01	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
34	A01	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
31	A01	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
32	A01	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
8	A01	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
35	A02	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
36	A02	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
37	A02	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
48	A02	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
49	A02	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
50	A02	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
51	A02	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
58	A02	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
56	A02	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
57	A02	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
61	A02	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
67	A02	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
59	A02	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
60	A02	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
62	A02	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
63	A02	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
64	A02	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
41	A02	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
38	A02	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
39	A02	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
40	A02	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
43	A02	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
44	A02	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
45	A02	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
46	A02	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
47	A02	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
52	A02	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
53	A02	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
54	A02	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
55	A02	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
68	A02	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
65	A02	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
66	A02	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2044	M72	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
70	A03	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
82	A03	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
85	A03	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
92	A03	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
91	A03	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
73	A03	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
74	A03	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
78	A03	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
79	A03	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
81	A03	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
86	A03	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
87	A03	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
88	A03	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
89	A03	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
100	A03	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
104	B05	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
116	B05	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
119	B05	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
126	B05	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
125	B05	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
107	B05	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
108	B05	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
112	B05	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
113	B05	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
115	B05	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
120	B05	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
121	B05	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
122	B05	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
123	B05	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
134	B05	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
138	B06	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
150	B06	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
153	B06	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
160	B06	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
159	B06	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
141	B06	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
142	B06	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
146	B06	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
147	B06	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
149	B06	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
154	B06	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
155	B06	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
156	B06	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
157	B06	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
168	B06	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
172	B07	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
184	B07	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
187	B07	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
194	B07	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
193	B07	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
175	B07	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
176	B07	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
180	B07	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
181	B07	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
183	B07	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
188	B07	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
189	B07	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
190	B07	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
191	B07	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
202	B07	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
206	B08	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
218	B08	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
221	B08	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
228	B08	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
227	B08	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
209	B08	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
210	B08	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
214	B08	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
215	B08	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
217	B08	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
222	B08	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
223	B08	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
224	B08	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
225	B08	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
236	B08	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
240	C10	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
252	C10	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
255	C10	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
262	C10	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
261	C10	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
243	C10	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
244	C10	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
248	C10	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
249	C10	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
251	C10	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
256	C10	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
257	C10	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
258	C10	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
259	C10	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
270	C10	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
274	C11	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
286	C11	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
289	C11	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
296	C11	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
295	C11	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
277	C11	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
278	C11	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
282	C11	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
283	C11	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
285	C11	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
290	C11	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
291	C11	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
292	C11	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
293	C11	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
304	C11	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
308	C12	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
320	C12	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
323	C12	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
330	C12	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
329	C12	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
311	C12	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
312	C12	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
316	C12	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
317	C12	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
319	C12	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
324	C12	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
325	C12	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
326	C12	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
327	C12	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
338	C12	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
342	C13	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
354	C13	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
357	C13	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
364	C13	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
363	C13	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
345	C13	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
346	C13	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
350	C13	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
351	C13	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
353	C13	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
358	C13	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
359	C13	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
360	C13	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
361	C13	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
372	C13	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
376	C14	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
388	C14	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
391	C14	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
398	C14	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
397	C14	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
379	C14	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
380	C14	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
384	C14	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
385	C14	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
387	C14	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
392	C14	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
393	C14	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
394	C14	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
395	C14	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
406	C14	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
410	C15	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
422	C15	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
425	C15	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
432	C15	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
431	C15	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
413	C15	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
414	C15	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
418	C15	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
419	C15	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
421	C15	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
426	C15	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
427	C15	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
428	C15	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
429	C15	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
440	C15	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
444	C16	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
456	C16	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
459	C16	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
466	C16	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
465	C16	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
447	C16	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
448	C16	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
452	C16	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
453	C16	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
455	C16	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
460	C16	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
461	C16	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
462	C16	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
463	C16	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
474	C16	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
478	C17	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
490	C17	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
493	C17	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
500	C17	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
499	C17	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
481	C17	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
482	C17	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
486	C17	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
487	C17	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
489	C17	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
494	C17	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
495	C17	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
496	C17	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
497	C17	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
508	C17	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
512	C18	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
524	C18	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
527	C18	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
534	C18	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
533	C18	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
515	C18	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
516	C18	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
520	C18	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
521	C18	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
523	C18	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
528	C18	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
529	C18	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
530	C18	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
531	C18	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
542	C18	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
546	C19	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
558	C19	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
561	C19	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
568	C19	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
567	C19	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
549	C19	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
550	C19	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
554	C19	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
555	C19	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
557	C19	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
562	C19	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
563	C19	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
564	C19	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
565	C19	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
576	C19	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
580	C20	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
592	C20	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
595	C20	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2201	N76	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2202	N76	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2204	N76	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2205	N76	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2206	N76	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2183	N76	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2180	N76	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
2185	N76	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2188	N76	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2210	N76	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2207	N76	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2184	N76	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2211	N78	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2213	N78	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2225	N78	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2226	N78	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2232	N78	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2237	N78	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2243	N78	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
614	C21	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
626	C21	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
629	C21	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
636	C21	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
635	C21	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
617	C21	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
618	C21	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
622	C21	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
623	C21	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
625	C21	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
630	C21	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
631	C21	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
632	C21	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
633	C21	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
644	C21	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
648	C22	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
660	C22	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
663	C22	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
670	C22	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
669	C22	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
651	C22	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
652	C22	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
656	C22	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
657	C22	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
659	C22	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
664	C22	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
665	C22	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
666	C22	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
667	C22	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
678	C22	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
682	C23	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
694	C23	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
697	C23	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
704	C23	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
703	C23	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
685	C23	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
686	C23	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
690	C23	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
691	C23	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
693	C23	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
698	C23	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
699	C23	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
700	C23	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
701	C23	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
712	C23	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
716	C24	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
728	C24	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
731	C24	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
738	C24	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
737	C24	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
719	C24	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
720	C24	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
724	C24	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
725	C24	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
727	C24	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
732	C24	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
733	C24	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
734	C24	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
735	C24	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
746	C24	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
750	C25	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
762	C25	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
765	C25	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
772	C25	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
771	C25	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
753	C25	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
754	C25	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
758	C25	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
759	C25	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
761	C25	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
766	C25	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
767	C25	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
768	C25	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
769	C25	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
780	C25	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
784	C26	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
796	C26	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
799	C26	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
806	C26	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
805	C26	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
787	C26	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
788	C26	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
792	C26	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
793	C26	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
795	C26	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
800	C26	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
801	C26	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
802	C26	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
803	C26	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
814	C26	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
818	C27	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
830	C27	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
833	C27	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
840	C27	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
839	C27	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
821	C27	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
822	C27	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
826	C27	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
827	C27	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
829	C27	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
834	C27	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
835	C27	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
836	C27	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
837	C27	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
848	C27	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
852	C28	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
864	C28	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
867	C28	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
874	C28	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
873	C28	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
855	C28	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
856	C28	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
860	C28	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
861	C28	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
863	C28	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
868	C28	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
869	C28	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
870	C28	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
871	C28	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
882	C28	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
886	C30	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
898	C30	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
901	C30	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
908	C30	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
907	C30	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
889	C30	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
890	C30	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
894	C30	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
895	C30	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
897	C30	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
902	C30	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
903	C30	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
904	C30	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
905	C30	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
916	C30	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
920	C31	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
932	C31	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
935	C31	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
942	C31	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
941	C31	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
923	C31	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
924	C31	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
928	C31	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
929	C31	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
931	C31	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
936	C31	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
937	C31	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
938	C31	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
939	C31	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
950	C31	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
954	C32	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
966	C32	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
969	C32	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
976	C32	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
975	C32	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
957	C32	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
958	C32	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
962	C32	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
963	C32	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
965	C32	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
970	C32	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
971	C32	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
972	C32	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
973	C32	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
984	C32	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
988	C33	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1000	C33	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1003	C33	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1010	C33	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1009	C33	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
991	C33	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
992	C33	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
996	C33	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
997	C33	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
999	C33	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1004	C33	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1005	C33	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1006	C33	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1007	C33	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1018	C33	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1022	C34	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1034	C34	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1037	C34	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1044	C34	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1043	C34	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1025	C34	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1026	C34	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1030	C34	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1031	C34	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1033	C34	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1038	C34	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1039	C34	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1040	C34	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1041	C34	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1052	C34	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1056	D35	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1068	D35	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1071	D35	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1078	D35	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1077	D35	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1059	D35	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1060	D35	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1064	D35	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1065	D35	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1067	D35	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1072	D35	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1073	D35	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1074	D35	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1075	D35	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1086	D35	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1090	E36	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1102	E36	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1105	E36	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1112	E36	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1111	E36	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1093	E36	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1094	E36	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1098	E36	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1099	E36	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1101	E36	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1106	E36	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1107	E36	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1108	E36	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1109	E36	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1120	E36	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1124	E37	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1136	E37	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1139	E37	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1146	E37	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1145	E37	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1127	E37	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1128	E37	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1132	E37	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1133	E37	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1135	E37	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1140	E37	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1141	E37	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1142	E37	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1143	E37	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1154	E37	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1158	E38	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1170	E38	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1173	E38	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1180	E38	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1179	E38	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1161	E38	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1162	E38	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1166	E38	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1167	E38	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1169	E38	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1174	E38	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1175	E38	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1176	E38	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1177	E38	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1188	E38	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1192	E39	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1204	E39	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1207	E39	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1214	E39	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1213	E39	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1195	E39	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1196	E39	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1200	E39	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1201	E39	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1203	E39	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1208	E39	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1209	E39	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1210	E39	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1211	E39	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1222	E39	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1226	F41	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1238	F41	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1241	F41	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1248	F41	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1247	F41	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1229	F41	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1230	F41	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1234	F41	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1235	F41	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1237	F41	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1242	F41	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1243	F41	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1244	F41	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1245	F41	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1256	F41	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1260	F42	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1272	F42	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1275	F42	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1282	F42	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1281	F42	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1263	F42	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1264	F42	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1268	F42	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1269	F42	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1271	F42	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1276	F42	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1277	F42	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1278	F42	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1279	F42	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1290	F42	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1294	F43	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1306	F43	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1309	F43	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1316	F43	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1315	F43	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1297	F43	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1298	F43	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1302	F43	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1303	F43	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1305	F43	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1310	F43	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1311	F43	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1312	F43	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1313	F43	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1324	F43	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1328	G45	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1340	G45	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1343	G45	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1350	G45	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1349	G45	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1331	G45	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1332	G45	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1336	G45	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1337	G45	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1339	G45	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1344	G45	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1345	G45	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1346	G45	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1347	G45	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1358	G45	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1362	G46	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1374	G46	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1377	G46	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1384	G46	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1383	G46	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1365	G46	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1366	G46	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1370	G46	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1371	G46	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1373	G46	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1378	G46	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1379	G46	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1380	G46	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1381	G46	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1392	G46	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1396	G47	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1408	G47	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1411	G47	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1418	G47	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1417	G47	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1399	G47	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1400	G47	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1404	G47	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1405	G47	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1407	G47	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1412	G47	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1413	G47	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1414	G47	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1415	G47	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1426	G47	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1430	H49	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1442	H49	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1445	H49	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1452	H49	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1451	H49	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1433	H49	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1434	H49	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1438	H49	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1439	H49	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1441	H49	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1446	H49	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1447	H49	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1448	H49	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1449	H49	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1460	H49	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1464	H50	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1476	H50	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1479	H50	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1486	H50	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1485	H50	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1467	H50	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1468	H50	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1472	H50	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1473	H50	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1475	H50	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1480	H50	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1481	H50	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1482	H50	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1483	H50	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1494	H50	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1498	H51	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1510	H51	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1513	H51	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1520	H51	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1519	H51	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1501	H51	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1502	H51	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1506	H51	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1507	H51	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1509	H51	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1514	H51	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1515	H51	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1516	H51	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1517	H51	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1528	H51	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1532	H52	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1544	H52	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1547	H52	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1554	H52	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1553	H52	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1535	H52	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1536	H52	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1540	H52	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1541	H52	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1543	H52	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1548	H52	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1549	H52	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1550	H52	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1551	H52	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1562	H52	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1566	I55	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1578	I55	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1581	I55	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1588	I55	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1587	I55	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1569	I55	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1570	I55	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1574	I55	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1575	I55	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1577	I55	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1582	I55	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1583	I55	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1584	I55	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1585	I55	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1596	I55	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1600	I56	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1612	I56	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1615	I56	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1622	I56	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1621	I56	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1603	I56	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1604	I56	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1608	I56	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1609	I56	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1611	I56	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1616	I56	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1617	I56	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1618	I56	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1619	I56	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1630	I56	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1634	J58	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1646	J58	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1649	J58	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1656	J58	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1655	J58	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1637	J58	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1638	J58	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1642	J58	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1643	J58	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1645	J58	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1650	J58	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1651	J58	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1652	J58	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1653	J58	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1664	J58	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1668	J59	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1680	J59	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1683	J59	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1690	J59	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1689	J59	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1671	J59	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1672	J59	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1676	J59	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1677	J59	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1679	J59	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1684	J59	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1685	J59	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1686	J59	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1687	J59	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1698	J59	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2457	S94	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
1702	J60	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1714	J60	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1717	J60	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1724	J60	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1723	J60	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1705	J60	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1706	J60	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1710	J60	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1711	J60	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1713	J60	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1718	J60	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1719	J60	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1720	J60	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1721	J60	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1732	J60	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1736	J61	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1748	J61	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1751	J61	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1758	J61	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1757	J61	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1739	J61	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1740	J61	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1744	J61	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1745	J61	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1747	J61	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1752	J61	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1753	J61	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1754	J61	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1755	J61	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1766	J61	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1770	J63	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1782	J63	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1785	J63	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1792	J63	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1791	J63	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1773	J63	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1774	J63	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1778	J63	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1779	J63	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1781	J63	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1786	J63	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1787	J63	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1788	J63	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1789	J63	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1800	J63	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1804	K64	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1816	K64	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1819	K64	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1826	K64	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1825	K64	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1807	K64	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1808	K64	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1812	K64	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1813	K64	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1815	K64	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1820	K64	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1821	K64	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1822	K64	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1823	K64	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1834	K64	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1838	K65	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1850	K65	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1853	K65	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1860	K65	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1859	K65	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1841	K65	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1842	K65	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1846	K65	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1847	K65	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1849	K65	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1854	K65	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1855	K65	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1856	K65	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1857	K65	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1868	K65	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1872	K66	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1884	K66	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1887	K66	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1894	K66	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1893	K66	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1875	K66	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1876	K66	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1880	K66	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1881	K66	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1883	K66	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1888	K66	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1889	K66	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1890	K66	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1891	K66	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1902	K66	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1906	L68	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1918	L68	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1921	L68	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1928	L68	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1927	L68	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1909	L68	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1910	L68	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1914	L68	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1915	L68	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1917	L68	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1922	L68	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1923	L68	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1924	L68	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1925	L68	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1936	L68	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1940	M69	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1952	M69	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1955	M69	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1962	M69	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1961	M69	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1943	M69	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1944	M69	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1948	M69	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1949	M69	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1951	M69	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1956	M69	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1957	M69	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1958	M69	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1959	M69	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
1970	M69	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
1974	M70	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
1986	M70	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
1989	M70	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
1996	M70	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
1995	M70	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
1977	M70	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
1978	M70	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
1982	M70	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
1983	M70	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
1985	M70	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
1990	M70	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
1991	M70	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
1992	M70	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
1993	M70	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2004	M70	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2008	M71	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2020	M71	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2023	M71	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2030	M71	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2029	M71	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2011	M71	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2012	M71	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2016	M71	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2017	M71	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2019	M71	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2024	M71	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2025	M71	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2026	M71	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2027	M71	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2038	M71	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2042	M72	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2054	M72	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2057	M72	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2064	M72	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2063	M72	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2045	M72	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2046	M72	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2050	M72	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2051	M72	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2053	M72	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2058	M72	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2059	M72	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2060	M72	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2061	M72	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2072	M72	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2076	M73	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2088	M73	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2091	M73	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2098	M73	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2097	M73	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2079	M73	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2080	M73	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2084	M73	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2085	M73	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2087	M73	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2092	M73	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2093	M73	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2094	M73	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2095	M73	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2106	M73	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2110	N74	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2122	N74	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2125	N74	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2132	N74	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2131	N74	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2113	N74	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2114	N74	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2118	N74	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2119	N74	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2121	N74	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2126	N74	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2127	N74	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2128	N74	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2129	N74	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2140	N74	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2144	N75	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2156	N75	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2159	N75	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2166	N75	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2165	N75	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2147	N75	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2148	N75	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2152	N75	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2153	N75	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2155	N75	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2160	N75	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2161	N75	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2162	N75	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2163	N75	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2174	N75	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2178	N76	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2190	N76	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2193	N76	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2200	N76	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2199	N76	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2181	N76	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2182	N76	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2186	N76	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2187	N76	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2189	N76	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2194	N76	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2195	N76	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2196	N76	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2197	N76	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2208	N76	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2212	N78	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2224	N78	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2227	N78	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2234	N78	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2233	N78	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2215	N78	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2216	N78	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2220	N78	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2221	N78	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2223	N78	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2228	N78	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2229	N78	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2230	N78	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2231	N78	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2242	N78	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2592	T98	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2619	U99	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2621	U99	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2633	U99	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2634	U99	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2640	U99	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2645	U99	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2651	U99	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2246	O84	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2258	O84	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2261	O84	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2268	O84	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2267	O84	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2249	O84	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2250	O84	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2254	O84	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2255	O84	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2257	O84	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2262	O84	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2263	O84	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2264	O84	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2265	O84	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2276	O84	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2280	P85	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2292	P85	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2295	P85	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2302	P85	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2301	P85	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2283	P85	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2284	P85	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2288	P85	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2289	P85	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2291	P85	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2296	P85	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2297	P85	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2298	P85	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2299	P85	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2310	P85	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2314	Q86	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2326	Q86	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2329	Q86	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2336	Q86	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2335	Q86	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2317	Q86	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2318	Q86	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2322	Q86	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2323	Q86	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2325	Q86	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2330	Q86	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2331	Q86	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2332	Q86	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2333	Q86	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2344	Q86	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2348	Q87	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2360	Q87	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2363	Q87	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2370	Q87	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2369	Q87	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2351	Q87	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2352	Q87	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2356	Q87	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2357	Q87	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2359	Q87	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2364	Q87	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2365	Q87	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2366	Q87	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2367	Q87	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2378	Q87	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2382	R90	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2394	R90	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2397	R90	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2404	R90	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2403	R90	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2385	R90	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2386	R90	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2390	R90	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2391	R90	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2393	R90	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2398	R90	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2399	R90	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2400	R90	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2401	R90	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2412	R90	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2416	R91	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2428	R91	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2431	R91	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2438	R91	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2437	R91	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2419	R91	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2420	R91	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2424	R91	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2425	R91	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2427	R91	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2432	R91	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2433	R91	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2434	R91	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2435	R91	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2446	R91	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2450	S94	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2462	S94	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2465	S94	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2472	S94	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2471	S94	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2453	S94	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2454	S94	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2458	S94	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2459	S94	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2461	S94	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2466	S94	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2467	S94	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2468	S94	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2469	S94	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2480	S94	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2484	S95	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2496	S95	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2499	S95	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2506	S95	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2505	S95	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2487	S95	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2488	S95	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2492	S95	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2493	S95	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2495	S95	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2500	S95	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2501	S95	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2502	S95	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2503	S95	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2514	S95	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2647	U99	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2648	U99	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2625	U99	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2622	U99	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2627	U99	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2630	U99	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2652	U99	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2649	U99	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2717	J62	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2718	J62	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2518	S96	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2530	S96	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2533	S96	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2540	S96	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2539	S96	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2521	S96	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2522	S96	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2526	S96	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2527	S96	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2529	S96	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2534	S96	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2535	S96	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2536	S96	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2537	S96	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2548	S96	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2552	T97	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2564	T97	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2567	T97	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2574	T97	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2573	T97	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2555	T97	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2556	T97	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2560	T97	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2561	T97	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2563	T97	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2568	T97	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2569	T97	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2570	T97	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2571	T97	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2582	T97	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2586	T98	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2598	T98	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2601	T98	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2608	T98	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2607	T98	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2589	T98	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2590	T98	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2594	T98	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2595	T98	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2597	T98	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2602	T98	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2603	T98	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2604	T98	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2605	T98	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2616	T98	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2620	U99	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2632	U99	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2635	U99	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2642	U99	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2641	U99	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2623	U99	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2624	U99	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2628	U99	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2629	U99	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2631	U99	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2636	U99	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2637	U99	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2638	U99	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2639	U99	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2650	U99	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2626	U99	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2653	C29	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2654	C29	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2655	C29	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2666	C29	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2667	C29	S-Q8_1	60.00	\N	2025-06-25 16:13:29.27617+09
2668	C29	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2669	C29	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2676	C29	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2674	C29	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2675	C29	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2665	C29	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2670	C29	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2671	C29	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2672	C29	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2673	C29	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2686	C29	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
2683	C29	S-Q16_1	50.00	\N	2025-06-25 16:13:29.27617+09
2684	C29	S-Q1	0.00	\N	2025-06-25 16:13:29.27617+09
2660	C29	S-Q4_1	50.00	\N	2025-06-25 16:13:29.27617+09
2687	J62	S-Q2_1	50.00	\N	2025-06-25 16:13:29.27617+09
2688	J62	S-Q3	0.00	\N	2025-06-25 16:13:29.27617+09
2689	J62	S-Q3_1	50.00	\N	2025-06-25 16:13:29.27617+09
2700	J62	S-Q8	0.00	\N	2025-06-25 16:13:29.27617+09
2701	J62	S-Q8_1	50.00	\N	2025-06-25 16:13:29.27617+09
2702	J62	S-Q9_1	50.00	\N	2025-06-25 16:13:29.27617+09
2703	J62	S-Q9_2	50.00	\N	2025-06-25 16:13:29.27617+09
2710	J62	S-Q2	0.00	\N	2025-06-25 16:13:29.27617+09
2708	J62	S-Q12	0.00	\N	2025-06-25 16:13:29.27617+09
2709	J62	S-Q13	0.00	\N	2025-06-25 16:13:29.27617+09
2713	J62	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2719	J62	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2711	J62	S-Q11_1	50.00	\N	2025-06-25 16:13:29.27617+09
2712	J62	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2714	J62	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2715	J62	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2716	J62	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2693	J62	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2690	J62	S-Q5_1	50.00	\N	2025-06-25 16:13:29.27617+09
2691	J62	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2692	J62	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2695	J62	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2679	C29	S-Q16	0.00	\N	2025-06-25 16:13:29.27617+09
2685	C29	S-Q1_1	50.00	\N	2025-06-25 16:13:29.27617+09
2677	C29	S-Q11_1	40.00	\N	2025-06-25 16:13:29.27617+09
2678	C29	S-Q10_1	50.00	\N	2025-06-25 16:13:29.27617+09
2680	C29	S-Q13_1	50.00	\N	2025-06-25 16:13:29.27617+09
2681	C29	S-Q14_1	50.00	\N	2025-06-25 16:13:29.27617+09
2682	C29	S-Q15_1	50.00	\N	2025-06-25 16:13:29.27617+09
2659	C29	S-Q6_1	50.00	\N	2025-06-25 16:13:29.27617+09
2656	C29	S-Q5_1	75.00	\N	2025-06-25 16:13:29.27617+09
2657	C29	S-Q6	0.00	\N	2025-06-25 16:13:29.27617+09
2658	C29	S-Q4	0.00	\N	2025-06-25 16:13:29.27617+09
2661	C29	S-Q5	0.00	\N	2025-06-25 16:13:29.27617+09
2662	C29	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2663	C29	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2664	C29	S-Q7_1	100.00	\N	2025-06-25 16:13:29.27617+09
2696	J62	S-Q6_2	50.00	\N	2025-06-25 16:13:29.27617+09
2697	J62	S-Q7	0.00	\N	2025-06-25 16:13:29.27617+09
2698	J62	S-Q7_1	50.00	\N	2025-06-25 16:13:29.27617+09
2699	J62	S-Q9	0.00	\N	2025-06-25 16:13:29.27617+09
2704	J62	S-Q10	0.00	\N	2025-06-25 16:13:29.27617+09
2705	J62	S-Q11	0.00	\N	2025-06-25 16:13:29.27617+09
2706	J62	S-Q15	0.00	\N	2025-06-25 16:13:29.27617+09
2707	J62	S-Q14	0.00	\N	2025-06-25 16:13:29.27617+09
2720	J62	S-Q12_1	50.00	\N	2025-06-25 16:13:29.27617+09
\.


--
-- Data for Name: industry_esg_issues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.industry_esg_issues (id, industry_code, key_issue, opportunity, threat, linked_metric, notes, created_at, updated_at) FROM stdin;
14	B05	광산안전, 탄소배출, 폐기물관리	 탈석탄 전환기 전략 수립	탄광 사고	E1-1, S1-3, G2-1		2025-06-25 01:04:38.003987+09	2025-06-25 01:09:06.887769+09
15	B06	토양오염, 물 사용, 지역사회 영향	친환경 채굴 기술 도입	지역 반발 	E2-1, S2-2, G1-1		2025-06-25 01:04:40.216372+09	2025-06-25 01:09:06.887769+09
16	B07	탄소배출, 유출사고, 생태계 영향	재생에너지로 사업 전환 기회	해양 유출 사고 	E1-2, S1-2, G3-1		2025-06-25 01:04:42.73539+09	2025-06-25 01:09:06.887769+09
17	B08	토양오염, 물 사용, 지역사회 영향	친환경 채굴 기술 도입	지역 반발 	E2-1, S2-2, G1-1		2025-06-25 01:04:45.671163+09	2025-06-25 01:09:06.887769+09
18	C10	식품안전, 포장폐기물, 공급망 인권	친환경 포장 시장 확대	식품 리콜 	E1-2, S2-2, G1-1		2025-06-25 01:04:48.0372+09	2025-06-25 01:09:06.887769+09
19	C11	물 사용량, 플라스틱 사용, 건강 이슈	무설탕 제품 수요 증가	당류 규제 리스크 	E2-1, S1-2, G2-1		2025-06-25 01:04:50.097453+09	2025-06-25 01:09:06.887769+09
20	C12	건강영향, 사회적 책임, 원재료 추적성	책임 브랜드 구축	음주운전 사고 연계 리스크 	S1-2, S2-1, G2-2		2025-06-25 01:05:00.667954+09	2025-06-25 01:09:06.887769+09
21	C13	공급망 노동, 화학물질 사용, 폐기물	친환경 소재 수요 증가	아동노동 리스크 	S2-2, E2-2, G1-1		2025-06-25 01:05:04.049608+09	2025-06-25 01:09:06.887769+09
22	C14	수질오염, 염색공정 에너지, 공급망 책임	저수세 염색기술 확산	염색폐수 규제 	E1-1, E2-1, G3-1		2025-06-25 01:05:06.860078+09	2025-06-25 01:09:06.887769+09
23	C15	동물복지, 화학물질, 인권	대체가죽 시장 확대	피혁공정 인권 논란 	S1-3, E2-1, G1-2		2025-06-25 01:05:08.809779+09	2025-06-25 01:09:06.887769+09
25	C16	벌목 영향, 탄소 저장, 공급망 인증	FSC 인증 수요 증가	불법 벌목 리스크 	E1-1, S2-2, G2-1		2025-06-25 01:05:12.198608+09	2025-06-25 01:09:06.887769+09
26	C17	산림관리, 에너지 사용, 수질오염	재생용지 시장 확대	종이소비 감소 	E1-2, E2-2, S1-1		2025-06-25 01:05:14.354633+09	2025-06-25 01:09:06.887769+09
11	A01	토양관리, 수자원 사용, 기후변화 대응	스마트 농업 기술 도입 기회	가뭄으로 인한 작황 감소 	E1-1, E2-1, S1-1		2025-06-25 00:58:56.934001+09	2025-06-25 01:09:06.887769+09
12	A02	산림보호, 생물다양성, 탄소흡수	탄소배출권 확보 기회	벌목 규제 리스크 	E1-2, S2-2, G3-1		2025-06-25 01:04:31.422666+09	2025-06-25 01:09:06.887769+09
13	A03	남획, 해양생태계 보호, 수질오염	친환경 양식 기술 투자 기회	수산자원 고갈 	E1-1, S1-2, G2-1		2025-06-25 01:04:34.93034+09	2025-06-25 01:09:06.887769+09
27	C18	화학물질 사용, 에너지 사용, 폐기물	디지털 인쇄 수요 증가	VOC 배출 규제 	E1-1, E2-1, G3-1		2025-06-25 01:05:16.364055+09	2025-06-25 01:09:06.887769+09
28	C19	온실가스, 수질오염, 폭발위험	CCUS 기술 시장 진입	화학사고 리스크 	E1-1, G3-2, S1-3		2025-06-25 01:05:18.263699+09	2025-06-25 01:09:06.887769+09
29	C20	유해물질, GHG, 공급망 안전	친환경 화학제품 수요	화학물질규제 	E1-1, S1-3, G1-1		2025-06-25 01:05:20.368462+09	2025-06-25 01:09:06.887769+09
30	C21	임상시험 윤리, 제품접근성, R&D 지속성	바이오헬스 글로벌 확장	신약 리스크 	S2-1, G1-2, G3-1		2025-06-25 01:05:22.241114+09	2025-06-25 01:09:06.887769+09
31	C22	폐기물관리, 유해화학물질, 재활용률	바이오플라스틱 시장 확대	플라스틱 규제 	E2-1, G3-1, S1-2		2025-06-25 01:05:25.878923+09	2025-06-25 01:09:06.887769+09
32	C23	온실가스 배출, 자원소모, 지역사회 영향	친환경 건축자재 수요	시멘트 탄소규제 	E1-1, G2-2, S1-3		2025-06-25 01:05:29.730402+09	2025-06-25 01:09:06.887769+09
33	C24	에너지효율, 제품안전, 공급망 기준	스마트기계 수요 증가	산업사고 리스크 	E1-2, G2-1, S2-2		2025-06-25 01:05:32.500325+09	2025-06-25 01:09:06.887769+09
34	C25	에너지효율, 제품안전, 공급망 기준	스마트기계 수요 증가		E1-2, G2-1, S2-2		2025-06-25 01:05:35.228022+09	2025-06-25 01:09:06.887769+09
35	C26	에너지소비, 희귀금속, 전자폐기물	순환전자소재 확장	폐전자 제품 증가 	E1-2, E2-2, G3-1		2025-06-25 01:05:37.851574+09	2025-06-25 01:09:06.887769+09
36	C27	탄소발자국, 제품수명주기, 공급망 윤리	친환경 설계 경쟁력 확보	배터리 문제 	E1-2, G1-1, S2-1		2025-06-25 01:05:40.28252+09	2025-06-25 01:09:06.887769+09
37	C28	에너지효율, 안전성, 공급망 투명성	고효율 제품 마케팅	기기 고장 리스크 	E1-1, S2-2, G2-1		2025-06-25 01:05:43.051624+09	2025-06-25 01:09:06.887769+09
38	C29	배출가스, 제품안전, 전기차 전환	 EV 시장 선도	배출 규제 강화	E1-1, S1-3, G3-2		2025-06-25 01:05:45.99645+09	2025-06-25 01:09:06.887769+09
39	C30	무기 윤리, 공급망 안정성, 안전규제	무기 추적 기술 수요	수출 규제 리스크 	G2-2, S1-2, E2-1		2025-06-25 01:05:49.701173+09	2025-06-25 01:09:06.887769+09
40	C31	산림자원, 화학물질, 제품안전	인증 가구 수요 증가	불법 벌목 비판 	E1-1, S1-1, G3-1		2025-06-25 01:05:52.785193+09	2025-06-25 01:09:06.887769+09
41	C32	소재 안정성, 아동안전, 공급망 점검	안전 인증 장난감 수요 증가	제품 리콜 	S1-2, G2-2, E2-2		2025-06-25 01:05:56.076952+09	2025-06-25 01:09:06.887769+09
42	C33	에너지관리, 생산폐기물, 근로자 안전	에너지절감 기술 투자 유치	산업재해  	E1-1, S2-1, G3-1		2025-06-25 01:05:59.56487+09	2025-06-25 01:09:06.887769+09
43	C34	제품품질, 환자안전, 데이터보안	스마트의료기기 시장 확대	기기 고장  	S2-1, G1-1, E1-2		2025-06-25 01:06:03.683645+09	2025-06-25 01:09:06.887769+09
44	D35	탄소배출, 에너지믹스, 송배전 안정성	재생에너지 투자 수익 확대	탄소세 증가  	E1-1, G1-1, G3-2		2025-06-25 01:06:06.392261+09	2025-06-25 01:09:06.887769+09
45	E36	수자원 보호, 공급 안정성, 수질 기준	스마트 물관리 기술 확대	가뭄 리스크  	E2-1, S1-1, G2-1		2025-06-25 01:06:09.016329+09	2025-06-25 01:09:06.887769+09
46	E37	폐기물 처리, 순환경제, 환경오염	재활용 시장 성장	폐기물 과징금  	E2-2, G1-2, S2-2		2025-06-25 01:06:11.783443+09	2025-06-25 01:09:06.887769+09
47	E38	유해폐기물 관리, 온실가스 감축, 토양오염	에너지화 기술 도입 기회	유해폐기물 규제  	E1-1, E2-2, G3-1		2025-06-25 01:06:15.081608+09	2025-06-25 01:09:06.887769+09
48	E39	폐기물 처리, 순환경제, 환경오염	재활용 시장 성장	폐기물 과징금 	E2-2, G1-2, S2-2		2025-06-25 01:06:18.7877+09	2025-06-25 01:09:06.887769+09
49	F41	공사 안전, 자재환경성, 부패방지	그린빌딩 시장 확대	현장 사고 	S2-1, G2-1, G3-2		2025-06-25 01:06:23.092149+09	2025-06-25 01:09:06.887769+09
50	F42	탄소배출, 환경영향평가, 지역사회 소통	친환경 인프라 수주 기회	대형공사 민원	E1-2, S1-3, G1-1		2025-06-25 01:06:26.256416+09	2025-06-25 01:09:06.887769+09
51	F43	건축폐기물, 자재 공급망, 에너지 효율	저에너지 설계 수요 증가	건축폐기물 규제  	E2-1, S1-2, G2-2		2025-06-25 01:06:29.140126+09	2025-06-25 01:09:06.887769+09
52	G45	제품정보 공개, 차량재활용, 고객보호	EV 중심 유통 확대	불완전 판매 리스크  	S1-2, G3-2, E2-1		2025-06-25 01:06:31.536372+09	2025-06-25 01:09:06.887769+09
53	G46	공급망 관리, 윤리적 조달, 물류탄소배출	 친환경 유통망 차별화	납품 리스크 	E1-1, S2-1, G2-1		2025-06-25 01:06:33.841404+09	2025-06-25 01:09:06.887769+09
54	G47	소비자 안전, 폐기물, 저소득 접근성	사회가치 기반 마케팅 확대	유통환경 규제  	S1-2, E2-2, G1-1		2025-06-25 01:06:37.383969+09	2025-06-25 01:09:06.887769+09
55	H49	탄소배출, 교통안전, 운송효율성	전기운송수단 전환	노후차량 규제  	E1-1, S1-2, G2-1		2025-06-25 01:06:40.069444+09	2025-06-25 01:09:06.887769+09
57	H50	선박오염, 기상리스크, 해양안전	친환경 선박 투자 유치	해양연료규제  	E1-2, G2-2, S1-3		2025-06-25 01:06:44.749933+09	2025-06-25 01:09:06.887769+09
58	H51	항공기 배출, 안전관리, 항로 최적화	SAF 기술혁신 경쟁력	국제 배출 규제  	E1-1, S1-1, G3-2		2025-06-25 01:06:48.519145+09	2025-06-25 01:09:06.887769+09
59	H52	온실가스, 물류효율화, 노동조건	스마트 물류 솔루션 확대	이산화탄소 규제  	E1-2, S2-1, G2-1		2025-06-25 01:06:51.265801+09	2025-06-25 01:09:06.887769+09
60	I55	식품안전, 폐기물 관리, 근로자 처우	친환경 식자재 마케팅 기회	식중독 사고  	E2-2, S1-2, G1-1		2025-06-25 01:07:04.670062+09	2025-06-25 01:09:06.887769+09
61	I56	에너지소비, 물사용, 고객건강	그린숙박 인증 확대	비효율 운영 리스크  	E1-2, S2-1, G3-2		2025-06-25 01:07:07.275568+09	2025-06-25 01:09:06.887769+09
62	J58	콘텐츠 책임성, 데이터프라이버시, 지적재산권보호	사회적가치 창출	디지털전환으로 친환경콘텐츠	E6-1, S7-1, S8-2		2025-06-25 01:07:11.289894+09	2025-06-25 01:09:06.887769+09
63	J59	콘텐츠 책임성, 데이터프라이버시, 지적재산권보호	사회적가치 창출	디지털전환으로 친환경콘텐츠	E6-1, S7-1, S8-2		2025-06-25 01:07:14.91259+09	2025-06-25 01:09:06.887769+09
64	J60	콘텐츠 책임성, 데이터프라이버시, 지적재산권보호	사회적가치 창출	디지털전환으로 친환경콘텐츠	E6-1, S7-1, S8-2		2025-06-25 01:07:17.656732+09	2025-06-25 01:09:06.887769+09
65	J61	망중립성, 개인정보 보호, 전력소비	클린 통신 브랜드 구축	정보유출  	S1-1, E1-2, G2-2		2025-06-25 01:07:20.497495+09	2025-06-25 01:09:06.887769+09
67	J62	데이터보안, 알고리즘 편향, 에너지사용	 지속가능 IT서비스 시장 선점	개인정보 유출 	S1-1, G2-1, E1-2		2025-06-25 01:07:27.364028+09	2025-06-25 01:09:06.887769+09
68	J63	데이터보안, 알고리즘 편향, 에너지사용	 지속가능 IT서비스 시장 선점	개인정보 유출 	S1-1, G2-1, E1-2		2025-06-25 01:07:29.935888+09	2025-06-25 01:09:06.887769+09
69	K64	책임대출, 기후리스크 반영, 고객정보보호	ESG 금융 상품 확대 기회	부실대출 리스크  	S1-3, G1-1, E2-1		2025-06-25 01:07:33.256177+09	2025-06-25 01:09:06.887769+09
70	K65	재난리스크, 보험상품투명성, 사이버보안	 ESG 기반 보험 설계 확대	기후 재난 비용 	S2-1, G2-1, G3-1		2025-06-25 01:07:36.411909+09	2025-06-25 01:09:06.887769+09
71	K66	지속가능 투자 및 ESG 펀드, 금융 포용성, 윤리경영 및 내부통제	금융 취약계층 대상 디지털 접근성 강화 	그린워싱 및 ESG 오인 투자	E3-1. S7-1, S소비자		2025-06-25 01:07:38.770564+09	2025-06-25 01:09:06.887769+09
72	L68	건물에너지효율, 기후리스크, 임대 투명성	그린부동산 프리미엄 확대	노후건물 규제  	E1-1, S1-3, G2-1		2025-06-25 01:07:44.5035+09	2025-06-25 01:09:06.887769+09
74	M69	윤리경영, 고객정보보호, ESG 자문역할	ESG 전문컨설팅 시장 성장	부정 자문 리스크  	G1-1, S1-2, G3-1		2025-06-25 01:07:49.760764+09	2025-06-25 01:09:06.887769+09
75	M70	고객 ESG 역량 지원, 투명성, 성과측정	지속가능 경영 프레임워크 수요 증가	성과 왜곡  	G2-1, S2-2, G3-2		2025-06-25 01:07:53.792473+09	2025-06-25 01:09:06.887769+09
76	M71	다양성과 포용성, 전문직 윤리 및 독립성	지속가능경영 전문 서비스 제공	이해충돌 	S3-1, S3-3, G1-1		2025-06-25 01:08:00.153831+09	2025-06-25 01:09:06.887769+09
79	M72	다양성과 포용성, 전문직 윤리 및 독립성	지속가능경영 전문 서비스 제공	이해충돌 	S3-1, S3-3, G1-1		2025-06-25 01:08:05.748255+09	2025-06-25 01:09:06.887769+09
80	M73	다양성과 포용성, 전문직 윤리 및 독립성	지속가능경영 전문 서비스 제공	이해충돌 	S3-1, S3-3, G1-1		2025-06-25 01:08:13.301778+09	2025-06-25 01:09:06.887769+09
81	N74	다양성과 포용성, 전문직 윤리 및 독립성	지속가능경영 전문 서비스 제공	이해충돌 	S3-1, S3-3, G1-1		2025-06-25 01:08:17.513125+09	2025-06-25 01:09:06.887769+09
82	N75	다양성과 포용성, 전문직 윤리 및 독립성	지속가능경영 전문 서비스 제공	이해충돌 	S3-1, S3-3, G1-1		2025-06-25 01:08:20.327705+09	2025-06-25 01:09:06.887769+09
83	N76	온실가스배출, 접근성(배리어프리), 이해상충방지	그린빌딩/에너지절감형리모델링	기후위험 	E3-1, E4-1, S7-1, 		2025-06-25 01:08:24.51174+09	2025-06-25 01:09:06.887769+09
84	N78	공정채용, 노동환경, 차별금지	ESG 채용관리 솔루션 확대	불공정 채용 이슈 	S1-2, S2-1, G1-1		2025-06-25 01:08:28.370892+09	2025-06-25 01:09:06.887769+09
85	O84	정책투명성, 공공조달 ESG기준, 디지털접근성	ESG기반 행정 혁신	정보불신 	G1-1, G3-2, S1-3		2025-06-25 01:08:31.906521+09	2025-06-25 01:09:06.887769+09
86	P85	접근성, 교육격차, 디지털포용	ESG 교육 서비스 수요 증가	정보 격차 	S1-1, G3-2, S2-2		2025-06-25 01:08:35.606709+09	2025-06-25 01:09:06.887769+09
87	Q86	환자안전, 정보보호, 의료 접근성	스마트의료 솔루션 확대	의료사고 	S2-1, G1-1, G2-2		2025-06-25 01:08:39.738775+09	2025-06-25 01:09:06.887769+09
88	Q87	취약계층접근성, 종사자 및 이용자 인권	지역기반 서비스 확대로 신뢰도 향상	인권침해 돌봄사고 	S3-1, S3-3, S4-1		2025-06-25 01:08:42.8166+09	2025-06-25 01:09:06.887769+09
89	R90	표현의 자유, 다양성, 저작권	문화다양성 콘텐츠 기회	표절 리스크  	S1-3, G1-1, G3-1		2025-06-25 01:08:45.680758+09	2025-06-25 01:09:06.887769+09
90	R91	폐기물처리, 고객안전, 콘텐츠 다양성	지속가능한 이벤트 도입	콘텐츠 논란/ 안전사고 	S7-1, S소비자		2025-06-25 01:08:48.475823+09	2025-06-25 01:09:06.887769+09
91	S94	제품안전, 고객보호, 근로자복지	친환경 제품 신뢰도 상승	소비자 항의 	S1-2, E2-2, G2-2		2025-06-25 01:08:51.369996+09	2025-06-25 01:09:06.887769+09
92	S95	지역사회 기반 일자리창출, 소비자 신뢰성	순환경제모델의 핵심사업군	품질불완전성 	E6-1, E6-2, S7-1		2025-06-25 01:08:55.000633+09	2025-06-25 01:09:06.887769+09
93	S96	지역사회 기반 일자리창출, 소비자 신뢰성	순환경제모델의 핵심사업군	품질불완전성 	E6-1, E6-2, S7-1		2025-06-25 01:08:57.771246+09	2025-06-25 01:09:06.887769+09
94	T97	근로조건, 성별격차, 복지안전망	공공지원 연계 확대	돌봄노동 착취 이슈 	S1-3, S2-1, G1-2		2025-06-25 01:09:00.322169+09	2025-06-25 01:09:06.887769+09
95	T98	해당없음	-	해당없음	해당없음		2025-06-25 01:09:02.779774+09	2025-06-25 01:09:06.887769+09
96	U99	국제거버넌스, 정책일관성, 인권보호	국제기구 협력 기회	글로벌 규제 미준수 	G1-1, G2-1, S1-1		2025-06-25 01:09:05.294026+09	2025-06-25 01:09:06.887769+09
\.


--
-- Data for Name: inquiries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inquiries (id, user_id, company_name, manager_name, phone, email, inquiry_type, content, status, created_at) FROM stdin;
11	\N	회사명	123	123	123456@123.om	이용문의	1234	new	2025-06-27 02:36:00.086729+09
10	8	Master	홍길동	01012345678	kyss1229@daum.net	이용문의	12345	in_progress	2025-06-27 02:30:45.942998+09
12	8	Master	홍길동	01012345678	kyss1229@daum.net	프로그램문의	문의문의	new	2025-06-27 13:13:52.080419+09
13	8	Master	홍길동	010-1234-5678	kyss1229@daum.net	이용문의	123	new	2025-06-29 22:55:17.413955+09
14	8	Master	123	123124124	kyss1229@daum.net	기타문의	123124124	resolved	2025-06-29 23:14:04.840963+09
15	8	Master	홍길동	01012345678	kyss1229@daum.net	이용문의	250701 0240	new	2025-07-01 02:40:17.454287+09
16	8	Master	홍길동	01012345678	kyss1229@daum.net	서비스 이용 문의	이용문의	new	2025-07-01 21:51:57.471962+09
17	8	Master	권영석	01012345678	kyss1229@daum.net	서비스 이용 문의	123124	new	2025-07-02 01:40:20.987891+09
\.


--
-- Data for Name: news_posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.news_posts (id, title, author_id, category, status, created_at, updated_at, content, is_pinned) FROM stdin;
30	테스트2	8	locallink	published	2025-07-01 10:32:32.683211+09	2025-07-01 10:32:32.683211+09	[{"images": ["/uploads/news/news-8-1751333552262-vlad-hilitanu-pt7QzB4ZLWw-unsplash.jpg"], "layout": "text-left", "subheading": "", "description": "123", "image_width": 800, "subheading_size": 28, "description_size": 16}]	f
23	테스트 동향	8	trends	published	2025-07-01 00:34:11.029874+09	2025-07-01 00:57:02.247986+09	[{"images": ["/uploads/news/news-8-1751297650463-zetong-li-AEYbdyOH2cU-unsplash.jpg"], "layout": "text-right", "subheading": "123", "description": "123124124124", "image_width": 400, "subheading_size": 28, "description_size": 16}]	f
31	테스트3	8	locallink	published	2025-07-01 10:32:57.328308+09	2025-07-01 10:32:57.328308+09	[{"images": ["/uploads/news/news-8-1751333576771-zetong-li-AEYbdyOH2cU-unsplash.jpg"], "layout": "text-left", "subheading": "", "description": "xptmxm3", "image_width": 10000, "subheading_size": 28, "description_size": 16}]	f
28	로컬링크 테스트 기간	8	locallink	\N	2025-07-01 09:42:56.601442+09	2025-07-01 17:14:45.110702+09	[{"images": ["/uploads/news/news-8-1751330576284-marek-piwnicki-vzGQlsZ-ZhY-unsplash.jpg"], "layout": "img-top-text-center", "subheading": "", "description": "로컬링크AI 테스트 기간입니다 ", "image_width": 300, "subheading_size": 28, "description_size": 16}]	t
29	테스트1	8	locallink	published	2025-07-01 10:32:15.432895+09	2025-07-01 10:32:15.432895+09	[{"images": ["/uploads/news/news-8-1751333534571-scott-taylor-02a4DSekRVg-unsplash.jpg"], "layout": "text-left", "subheading": "", "description": "테스트1", "image_width": 600, "subheading_size": 28, "description_size": 16}]	f
\.


--
-- Data for Name: partners; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.partners (id, name, logo_url, link_url, display_order, created_at) FROM stdin;
4	123	partner-1750878402434-485712911.jpg	213	4	2025-06-26 04:06:42.476612+09
5	1234	partner-1750878922157-484205111.jpg	1234	5	2025-06-26 04:15:22.224358+09
6	1234	partner-1750878928427-58897519.jpg	1234	6	2025-06-26 04:15:28.466633+09
7	1234	partner-1750878933313-765391673.jpg	1234	7	2025-06-26 04:15:33.353517+09
8	123	partner-1750882475787-927753340.jpg	23	8	2025-06-26 05:14:35.797159+09
9	123	partner-1750882481357-188614989.jpg	23	9	2025-06-26 05:14:41.398754+09
10	123	partner-1750882487208-836933141.jpg	23	10	2025-06-26 05:14:47.24126+09
11	123	partner-1751356552522-316366639.jpg	123	11	2025-07-01 16:55:52.592506+09
12	123123	partner-1751356562041-615837181.jpg	123123	12	2025-07-01 16:56:02.050794+09
\.


--
-- Data for Name: regional_esg_issues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.regional_esg_issues (id, region, content, created_at, updated_at, esg_category, display_order) FROM stdin;
54	대전	자원순환 시스템으로 인한 과학도시 위상 재고 필요	2025-06-25 10:45:53.292923+09	\N	E	49
55	대전	과학기술 인력 유출으로 인한 수도권으로 인재 이동 	2025-06-25 10:46:00.994279+09	\N	S	50
56	대전	교통 인프라 확충으로 인한 도시철도 2호선 등으로 인한 문제	2025-06-25 10:46:19.21268+09	\N	S	51
57	대전	지역 대학과의 상생으로 인한 산학연 협력 중요 	2025-06-25 10:46:25.77367+09	\N	S	52
2	서울	수도권 인구 밀집으로 대기질 관리 필요	2025-06-25 01:39:10.313788+09	2025-06-25 02:36:39.586236+09	E	1
58	대전	R&D 예산 투명성으로 인한 정부 출연 연구기관 거버넌스 중요성	2025-06-25 10:46:43.79111+09	\N	G	53
6	서울	노후 건물 비효율로 에너지 다소비 문제 해결 필요	2025-06-25 01:52:02.316433+09	2025-06-25 02:37:00.091202+09	E	2
59	대전	스타트업 지원 정책으로 인한 혁신 생태계 거버넌스 구축 필요	2025-06-25 10:46:52.859711+09	\N	G	54
12	서울	높은 부동산 가격으로 주거불안정 문제	2025-06-25 02:47:19.354125+09	\N	S	7
13	서울	소득 격차 심화로 사회적 불평등 심화 문제	2025-06-25 02:56:19.539791+09	2025-06-25 02:56:31.927173+09	S	8
14	서울	대규모 예산 집행으로 투명한 도시 행정 이슈	2025-06-25 02:56:55.899236+09	\N	G	9
9	서울	출퇴근 인구 집중으로 교통 혼잡 심화 문제 해결 필요	2025-06-25 02:08:14.148242+09	2025-06-25 02:37:19.60369+09	S	6
11	서울	1인 가구 증가로 폐기물 처리 필요	2025-06-25 02:36:11.102556+09	\N	E	4
60	대전	시정 정보 공개으로 인한 시민의 알 권리 보장 	2025-06-25 10:47:01.589136+09	\N	G	55
61	울산	주력 산업 탄소배출으로 인한 석유화학,조선,자동차 분야 환경문제  	2025-06-25 10:58:54.359263+09	\N	E	56
62	울산	산업단지 안전사고으로 인한 화학물질 누출 위험 	2025-06-25 10:59:01.573697+09	\N	E	57
15	서울	다양한 이해관계로 시민참여 거버넌스 필요	2025-06-25 02:57:16.238812+09	\N	G	10
16	서울	공공사업 투명성 요구로 부패방지 시스템 필요	2025-06-25 02:57:30.15473+09	2025-06-25 03:23:50.31815+09	G	11
17	부산	항만 대기오염으로 인한 대형 선박 밀집 	2025-06-25 03:29:52.683414+09	2025-06-25 03:29:58.806223+09	E	12
18	부산	해양 플라스틱으로 인한 국내 최대 항구도시 	2025-06-25 03:30:32.693702+09	\N	E	13
19	부산	기후변화 대응으로 인한 해수면 상승 위험 	2025-06-25 03:30:39.148677+09	\N	E	14
20	부산	초고령 사회 진입으로 인한 전국 최고 고령화율 	2025-06-25 10:34:05.833269+09	\N	S	15
21	부산	청년 인구 유출으로 인한 양질의 일자리 부족 	2025-06-25 10:34:17.428664+09	\N	S	16
22	부산	관광-주민 상생으로 인한 오버투어리즘 문제 	2025-06-25 10:34:25.631464+09	\N	S	17
23	부산	항만 재개발 투명성으로 인한 대규모 공공 프로젝트 	2025-06-25 10:34:33.038289+09	\N	G	18
24	부산	국제 행사 유치으로 인한 엑스포 등 거버넌스 	2025-06-25 10:34:39.158724+09	\N	G	19
25	부산	도시 안전 및 재난관리으로 인한 태풍 등 자연재해 	2025-06-25 10:34:45.216325+09	\N	G	20
26	대구	폭염 및 대기질으로 인한 분지 지형 특성 	2025-06-25 10:34:56.425713+09	\N	E	21
27	대구	낙동강 수질 관리로 인한 주요 식수원 오염 	2025-06-25 10:35:06.650334+09	\N	E	22
28	대구	노후 산단 환경오염으로 인한 염색 등 전통 산업 	2025-06-25 10:35:13.913495+09	\N	E	23
29	대구	전통 주력산업 쇠퇴으로 인한 섬유 등 구조조정 	2025-06-25 10:35:32.497883+09	\N	S	24
30	대구	청년 일자리 부족으로 인한 지역 인재 유출 심화 	2025-06-25 10:35:38.269853+09	\N	S	25
31	대구	대중교통 시스템 개선으로 인한 도시 확장 및 인구 	2025-06-25 10:35:44.272217+09	\N	S	26
32	대구	개발 사업 투명성으로 인한 신공항 등 대형 사업 	2025-06-25 10:35:54.379984+09	\N	G	27
33	대구	시민 참여 활성화으로 인한 보수적 정치 지형 	2025-06-25 10:36:00.680538+09	\N	G	28
34	대구	효율적 예산 집행으로 인한 시 재정 건전성 확보 	2025-06-25 10:36:06.718494+09	\N	G	29
35	인천	공항/항만 대기오염으로 인한 국제 허브 기능 	2025-06-25 10:39:31.664179+09	\N	E	30
36	인천	수도권 매립지 관리으로 인한 환경 및 주민 갈등 	2025-06-25 10:39:37.04691+09	\N	E	31
37	인천	해양 생태계 보호으로 인한 갯벌 및 도서 지역 	2025-06-25 10:39:42.609385+09	\N	E	32
38	인천	공항 소음 피해으로 인한 주민 건강권 문제 	2025-06-25 10:39:50.953834+09	\N	S	33
39	인천	다문화 포용 정책으로 인한 외국인 주민 비율 높음 	2025-06-25 10:39:56.85344+09	\N	S	34
40	인천	원도심-신도심 격차으로 인한 송도,청라 등 개발 	2025-06-25 10:40:25.742282+09	\N	S	35
41	인천	경제자유구역 거버넌스으로 인한 외국 자본 투자 유치 	2025-06-25 10:40:33.265278+09	\N	G	36
42	인천	항만 물류 운영 효율으로 인한 수도권 관문 역할 	2025-06-25 10:40:39.312622+09	\N	G	37
43	인천	시민 안전망 구축으로 인한 각종 사건사고 대응 	2025-06-25 10:40:45.484423+09	\N	G	38
44	광주	도심 하천 수질으로 인한 광주천 등 생태 복원 	2025-06-25 10:42:17.42922+09	\N	E	39
45	광주	자동차 배출가스으로 인한 완성차 공장 위치 	2025-06-25 10:42:22.19211+09	\N	E	40
46	광주	에너지 자립 도시으로 인한 AI 연계 에너지 전환 	2025-06-25 10:42:27.269119+09	\N	E	41
47	광주	미래차 산업 일자리으로 인한 기존 산업 전환 	2025-06-25 10:42:33.722576+09	\N	S	42
49	광주	문화예술 생태계으로 인한 아시아문화중심도시 	2025-06-25 10:42:47.973271+09	\N	S	44
50	광주	AI 산업단지 투명성으로 인한 미래 전략 사업 육성 	2025-06-25 10:42:55.09969+09	\N	G	45
51	광주	청렴도 제고로 인한 부패 방지 노력 필요 	2025-06-25 10:44:01.568528+09	\N	G	46
52	대전	연구단지 안전 관리으로 인한 대덕연구개발특구 	2025-06-25 10:45:31.274461+09	\N	E	47
53	대전	갑천 등 하천 생태계으로 인한 도시 개발과 보존 	2025-06-25 10:45:38.826906+09	\N	E	48
63	울산	태화강 생태 복원으로 인한 산업화 후 환경 개선 	2025-06-25 10:59:06.963794+09	\N	E	58
64	울산	산업재해 예방이 필요한 중공업 중심 산업 	2025-06-25 10:59:21.680566+09	\N	S	59
65	울산	주력산업 고용 안정 문제와 조선업 등 경기 변동 	2025-06-25 10:59:38.28007+09	\N	S	60
66	울산	외국인 노동자 지원으로 인한 조선소 인력 수급 	2025-06-25 10:59:44.432444+09	\N	S	61
67	울산	대기업-협력사 관계와 공정거래 문화 정착 	2025-06-25 10:59:58.832926+09	\N	G	62
68	울산	노사 관계 안정과 강성 노조 활동 이력	2025-06-25 11:00:21.160792+09	\N	G	63
69	울산	안전 경영 체계 확립과 기업 최고경영진 책임 강화	2025-06-25 11:00:40.172756+09	\N	G	64
70	세종	친환경 도시 설계로 인한 계획도시 특성 반영	2025-06-25 11:07:31.610134+09	\N	E	65
71	세종	중앙공원 등 녹지 보존으로 인한 도시의 허파 역할 강화	2025-06-25 11:07:37.463549+09	\N	E	66
72	세종	스마트시티 에너지 전환으로 인한 미래형 도시 모델 	2025-06-25 11:07:42.928354+09	\N	E	67
73	세종	정주여건 개선이 필요한 문화/상업시설 부족 	2025-06-25 11:08:08.359763+09	\N	S	68
74	세종	지역 내 교육 인프라와 젊은 인구 비중 높음 	2025-06-25 11:08:16.285769+09	\N	S	69
75	세종	대중교통 시스템 구축으로 인한 자족기능 강화 필요 	2025-06-25 11:08:22.625832+09	\N	S	70
76	세종	행정수도 이전 논의로 인한 국가적 거버넌스 이슈 	2025-06-25 11:08:48.397116+09	\N	G	71
77	세종	주민 자치 모델로 인한 높은 시민의식 대응 	2025-06-25 11:08:54.655303+09	\N	G	72
78	세종	도시계획 투명성으로 인한 부동산 투기 방지강화	2025-06-25 11:09:01.843943+09	\N	G	73
79	경기	반도체 공장 용수으로 인한 첨단 산업단지 위치로 인한 환경문제	2025-06-25 15:30:40.730448+09	\N	E	74
80	경기	수도권 미세먼지와 서울 인접 및 교통량으로 인한 탄소발생	2025-06-25 15:30:58.494258+09	\N	E	75
81	경기	급격한 인구 유입으로 신도시 녹지 확보가 필요  	2025-06-25 15:31:16.511643+09	\N	E	76
82	경기	서울 통근 인구로 인한 광역 교통망 확충	2025-06-25 15:32:00.513135+09	\N	S	77
83	경기	경기 남부/북부 격차 로 인한 지역간 발전 불균형	2025-06-25 15:32:06.980864+09	\N	S	78
84	경기	IT 기업 다수 위치 로 인한 플랫폼 노동자 권익	2025-06-25 15:32:14.133508+09	\N	S	79
85	경기	대규모 택지 개발 과 개발사업 인허가 비리 문제 	2025-06-25 15:32:57.476298+09	\N	G	80
86	경기	서울시와 협력한 광역버스 등 준공영제	2025-06-25 15:33:03.993288+09	\N	G	81
87	경기	전력 수급 및 민원과 데이터센터 갈등 조정	2025-06-25 15:33:12.083018+09	\N	G	82
88	강원	높은 산림 비중으로 산불 예방 및 대응	2025-06-25 15:35:13.399931+09	\N	E	83
89	강원	과거 석탄 산업 유산 으로 인한 폐광 지역 환경 복원	2025-06-25 15:35:21.382403+09	\N	E	84
90	강원	관광과 환경보호로 인한 설악산 등 국립공원 보존	2025-06-25 15:35:28.34607+09	\N	E	85
91	강원	남북 분단 현실과 접경지역 군사 규제와 제한	2025-06-25 15:35:35.620636+09	\N	S	86
92	강원	지역 경제 활성화를 위한 동계올림픽 유산 활용 	2025-06-25 15:35:42.920594+09	\N	S	87
93	강원	넓은 면적,낮은 인구와 의료 인프라 부족 문제	2025-06-25 15:35:50.20816+09	\N	S	88
94	강원	중앙정부와 협력과 특별자치도 권한 이양	2025-06-25 15:35:56.94741+09	\N	G	89
95	강원	리조트 등 난개발 방지를 위한 관광개발 투명성	2025-06-25 15:36:03.866055+09	\N	G	90
96	강원	풍력 등 주민 수용성과 재생에너지 발전 갈등	2025-06-25 15:36:10.111971+09	\N	G	91
97	충북	중부권 핵심 상수원인 대청호 수질 관리	2025-06-25 15:43:47.792909+09	\N	E	92
98	충북	오창 등 산업단지의 2차전지 공장 환경적 안전문제 	2025-06-25 15:43:53.941335+09	\N	E	93
99	충북	제천으로 인한 단양 지역의 시멘트 공장 환경오염 	2025-06-25 15:44:00.377572+09	\N	E	94
100	충북	오송역 등 KTX 분기점의 중부권 교통 허브 관리 문제  	2025-06-25 15:44:08.037921+09	\N	S	95
101	충북	특화 산업 생태계 기반의 바이오 인력 양성 필요 	2025-06-25 15:44:15.394896+09	\N	S	96
102	충북	고령화 및 인구 감소와 농촌 지역 소멸 위기  	2025-06-25 15:44:22.05168+09	\N	S	97
103	충북	전략 산업 육성 정책으로 인한 바이오 산업 투자 유치  	2025-06-25 15:44:31.482848+09	\N	G	98
104	충북	행정수도 관문 공항인 청주공항 활성화  	2025-06-25 15:44:38.911534+09	\N	G	99
105	충북	광역 경제권 구축을 위한 충북-대전 상생 협력	2025-06-25 15:44:44.986824+09	\N	G	100
106	충남	국내 최대 화력발전인 석탄화력발전소 단계적 폐쇄와 재생에너지 전환 	2025-06-25 15:47:26.080852+09	\N	E	101
107	충남	대산 석유화학단지의 서해안 유류오염 	2025-06-25 15:47:31.786395+09	\N	E	102
108	충남	대규모 축산업 지역의 가축분뇨 악취  	2025-06-25 15:47:38.851212+09	\N	E	103
109	충남	대기업 중심 산업구조로 삼성/현대차 의존 경제 	2025-06-25 15:47:49.535925+09	\N	S	104
110	충남	외국인 계절근로자로 인한 농촌 인력난 	2025-06-25 15:47:55.348873+09	\N	S	105
111	충남	도청 이전 신도시인 내포신도시 정주여건	2025-06-25 15:48:01.940858+09	\N	S	106
112	충남	탈석탄 정의로운 전환을 위한 에너지 전환 거버넌스 확대	2025-06-25 15:48:08.986514+09	\N	G	107
113	충남	공급망 내 중소기업과 대기업-지역 상생	2025-06-25 15:48:16.034426+09	\N	G	108
114	충남	미래 성장동력 확보를 위한 환황해 경제권 구축  	2025-06-25 15:48:23.524057+09	\N	G	109
\.


--
-- Data for Name: related_sites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.related_sites (id, name, url, display_order, created_at) FROM stdin;
11	테스트1	https://www.naver.com/	0	2025-07-01 23:53:10.403169+09
12	테스트2	https://www.daum.net/	0	2025-07-01 23:53:10.403169+09
\.


--
-- Data for Name: scoring_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scoring_rules (id, question_code, answer_condition, score, esg_category, notes) FROM stdin;
150	Q1	1	0	E	\N
151	Q1	2	0	E	\N
63	S-Q1_1	2	50.00	E	\N
64	S-Q1_1	3	75.00	E	\N
65	S-Q1_1	4	100.00	E	\N
66	S-Q5	No	100.00	S	\N
67	S-Q5_1	1	100.00	S	\N
68	S-Q5_1	2	75.00	S	\N
69	S-Q5_1	3	50.00	S	\N
70	S-Q5_1	4	25.00	S	\N
71	S-Q5_1	5	0.00	S	\N
72	S-Q6_1	1	0.00	S	\N
73	S-Q6_1	2	25.00	S	\N
74	S-Q6_1	3	50.00	S	\N
75	S-Q6_1	4	75.00	S	\N
76	S-Q6_1	5	100.00	S	\N
77	S-Q7_1	1	20.00	S	\N
78	S-Q7_1	2	40.00	S	\N
79	S-Q7_1	3	60.00	S	\N
80	S-Q7_1	4	80.00	S	\N
81	S-Q7_1	5	100.00	S	\N
82	S-Q8_1	1	20.00	S	\N
83	S-Q8_1	2	40.00	S	\N
84	S-Q8_1	3	60.00	S	\N
85	S-Q8_1	4	80.00	S	\N
86	S-Q8_1	5	100.00	S	\N
87	S-Q9_1	1	25.00	S	\N
88	S-Q9_1	2	50.00	S	\N
89	S-Q9_1	3	75.00	S	\N
90	S-Q9_1	4	100.00	S	\N
91	S-Q10_1	1	25.00	S	\N
92	S-Q10_1	2	50.00	S	\N
93	S-Q10_1	3	75.00	S	\N
94	S-Q10_1	4	100.00	S	\N
95	S-Q11_1	1	20.00	G	\N
96	S-Q11_1	2	40.00	G	\N
97	S-Q11_1	3	60.00	G	\N
98	S-Q11_1	4	80.00	G	\N
99	S-Q11_1	5	100.00	G	\N
100	S-Q12	No	-50.00	G	\N
101	S-Q12_1	1	0.00	G	\N
102	S-Q12_1	2	25.00	G	\N
103	S-Q12_1	3	50.00	G	\N
104	S-Q12_1	4	75.00	G	\N
105	S-Q12_1	5	100.00	G	\N
106	S-Q13_1	1	100.00	G	\N
107	S-Q13_1	2	80.00	G	\N
108	S-Q13_1	3	60.00	G	\N
109	S-Q13_1	4	40.00	G	\N
110	S-Q13_1	5	20.00	G	\N
111	S-Q14_1	1	25.00	G	\N
62	S-Q1_1	1	25.00	E	\N
112	S-Q14_1	2	50.00	G	\N
113	S-Q14_1	3	75.00	G	\N
114	S-Q14_1	4	100.00	G	\N
115	S-Q15_1	1	25.00	G	\N
116	S-Q15_1	2	50.00	G	\N
117	S-Q15_1	3	75.00	G	\N
118	S-Q15_1	4	100.00	G	\N
119	S-Q16	No	100.00	G	\N
120	S-Q16_1	1	-50.00	G	\N
121	S-Q16_1	2	-30.00	G	\N
122	S-Q16_1	3	-10.00	G	\N
135	S-Q2_1	*	BENCHMARK_GHG	E	\N
136	S-Q3_1	*	BENCHMARK_ENERGY	E	\N
137	S-Q4_1	*	BENCHMARK_WASTE	E	\N
\.


--
-- Data for Name: simulator_parameters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.simulator_parameters (id, category, name, description, formula, parameter_value, unit, is_editable, display_order) FROM stdin;
1	기부금 설정예시	참고기부금(세율하향용)	다음 법인세율 구간까지 남은 금액	IF(영업이익 > 200, 영업이익 - 200, ...)	\N	억원	f	1
2	기부금 설정예시	참고기부금(MAX손금산입)	세금혜택을 최대로 받을 수 있는 기부금	영업이익 * (손금산입인정비율/100)	\N	억원	f	2
3	기부금 설정예시	추천기부금(국제기준)	매출액 대비 국제 권장 수준의 기부금	매출액 * (국제기준비율/100)	\N	억원	f	3
4	기부금 설정예시	최소기부금(가이드라인)	주요국 가이드라인에 따른 최소 기부금	MAX(최소금액, 영업이익 * 비율)	\N	억원	f	4
8	비용절감효과	ESG활동 기대효과(추정치)	지역협력활동으로 인한 유무형 가치	(매출액*비율) * (목표예산/추천기부금)	\N	원	f	8
9	비용절감효과	ESG활동 마케팅 효과	기부금으로 인한 홍보비 절감 추정	목표예산 * 비율	\N	원	f	9
10	비용절감효과	기업신뢰도 향상	신뢰도 향상으로 인한 매출 증대 효과 추정	(매출액/영업이익)*(목표예산/추천기부금)*비율	\N	원	f	10
14	자동계산 결과	적용세율	기부 후 예상되는 법인세율	IF(과세표준<=2, 9.9, ...)	\N	%	f	14
15	자동계산 결과	손금산입 인정 기부금	세법상 비용으로 인정되는 기부금	MIN(목표예산, 영업이익 * 비율)	\N	억원	f	15
16	자동계산 결과	기부 후 과세표준	기부 후 세금계산의 기준이 되는 금액	영업이익 - 손금산입인정기부금	\N	억원	f	16
17	자동계산 결과	법인세 절감액	기부로 인해 절감되는 법인세	기부전법인세 - 기부후법인세	\N	원	f	17
19	플랜에 따른 기대효과	프로그램 기대효과	선택한 프로그램 수행 시 기대효과	목표예산*단위기대효과 + 온실가스감축량*톤당기대효과	\N	원	f	19
20	플랜에 따른 기대효과	단위 기대효과	프로그램별 1원당 기대효과	admin_programs에서 관리	\N	\N	f	20
21	플랜에 따른 기대효과	톤당 기대효과	프로그램별 온실가스 1톤당 기대효과	admin_programs에서 관리	\N	\N	f	21
7	기부금 설정예시	가이드라인 비율	최소기부금 계산에 사용	\N	0.12	%	t	7
11	비용절감효과	ESG활동 가산 비율	기대효과 계산에 사용	\N	0.5	%	t	11
13	비용절감효과	신뢰도 향상 계수	신뢰도 향상 계산에 사용	\N	0.5	%	t	13
12	비용절감효과	마케팅 효과 비율	마케팅 효과 계산에 사용	\N	10	%	t	12
5	기부금 설정예시	국제기준 기부 비율	추천기부금 계산에 사용	\N	10	%	t	5
18	자동계산 결과	손금산입 인정 한도	손금산입 인정 기부금 계산에 사용	\N	50	%	t	18
6	기부금 설정예시	가이드라인 최소 금액	최소기부금 계산에 사용	\N	0.5	억원	t	6
\.


--
-- Data for Name: site_content; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.site_content (id, content_key, content_value, updated_at, terms_of_service, privacy_policy, content, marketing_consent_text) FROM stdin;
1	main_page_sections	[{"title": "ESG 경영, Locallink에서 <br> 한 눈에 확인하세요", "images": [{"file": "/uploads/pages/page-1751381566357-marek-piwnicki-vzGQlsZ-ZhY-unsplash.jpg"}], "layout": "text-right", "description": "LocalLink는 기업이 쉽고 빠르게 ESG를 진단하고, 지역 공급망과 협력하여 기업에 꼭 맞는 지속가능 전략을 설계할 수 있도록 돕는 AI 기반 플랫폼입니다.\\n\\n간단한 설문만으로 환경(E), 사회(S), 지배구조(G) 각 영역의 현황을 파악하고, 관련 법규, 업종 기준, 업계 평균과 비교하여 실행 가능한 ESG 방향을 제시합니다.\\n\\n복잡하고 멀게만 느껴졌던 ESG, 이제 LocalLink와 함께라면 우리 기업의 언어로, 우리 속도로 시작할 수 있습니다. 한 번의 진단이, 지속가능한 성장의 출발점이 됩니다.", "image_width": 500}, {"title": " 주요 기능", "images": [{"file": "/uploads/pages/page-1751381590402-scott-taylor-02a4DSekRVg-unsplash.jpg"}], "layout": "text-left", "description": "●간편한 온라인 ESG 자가진단\\n●업종별 맞춤형 ESG 실천 가이드\\n●지역 공급망과의 협업을 통한 ESG 실행\\n●예산의 효율적 사용으로 ESG실행 제안\\n●AI기반 ESG 성과 관리 및 보고서 생성\\n●지속적인 ESG 개선을 위한 피드백 시스템\\n", "image_width": 400}]	2025-07-01 23:53:10.403169+09	서비스 이용 약관 \r\n제1장 총칙\r\n제1조(목적)\r\n이 이용약관(이하 “본 약관”)은 주식회사 이에스지표준원(이하 “공급사업자” 또는 “당사”) 가 제공하는 솔루션 “LocalLink” 및 부가서비스(이하 “본 서비스”)의 이용과 관련하여, 귀하(“최종이용자”)의 접근 및 이용에 필요한 기본적 사항을 규정한다.\r\n\r\n제2조(정의)\r\n본 약관에서 사용하는 용어의 정의는 아래와 같다.\r\n① “본 서비스”라 함은 공급사업자가 제공하는 ESG 데이터 관리 및 ESG프로그램 연결 플랫폼 “LocalLink”를 말한다.\r\n② “공급사업자”라 함은 본 서비스를 제공하는 사업자로서, 본 약관에서는 주식회사 이에스지표준원을 지칭한다.\r\n③ “이용사업자”라 함은 본 약관 상의 이용신청 절차에 따라 공급사업자와 유료서비스 이용계약을 체결하고 본 서비스를 이용하는 개인, 개인사업자, 혹 법인사업자를 말한다.\r\n④ “유료 서비스”라 함은 공급사업자가 제공하는 서비스 중 이용사업자의 규모 및 필요한 기능에 따라 요금을 지불한 경우 이용할 수 있는 서비스를 의미한다.\r\n⑤ “서비스 이용계약”이라 함은 유료 서비스 이용을 위하여 공급사업자와 이용사업자 간 상호 동의하여 체결하는 개별 계약을 말한다.\r\n⑥ “최종이용자”라 함은 회원가입을 완료한 개인, 개인사업자 혹은 법인사업자가 본 서비스 내에 회원가입을 완료하고 본 서비스를 이용하는 회사를 말한다.\r\n⑦ “이용사업자 데이터”라 함은 이용사업자 및 최종이용자가 공급사업자의 정보통신자원에 제출, 기록, 업로드 등의 형식으로 저장하는 정보로서 이용사업자가 소유 또는 관리하는 정보를 말한다.\r\n⑧ “최종이용자 정보”라 함은 이름, 이메일 주소, 전화번호, 소속 회사 등의 개인정보 등 본 서비스를 이용하는 특정 최종이용자를 식별할 수 있는 정보를 말한다.\r\n⑨ “개별약관”이라 함은 본 서비스에 관하여 본 약관과는 별도로 ‘약관’, 가이드라인’, ‘정책’, ‘방침’ 등의 명칭으로 공급사업자가 배포 또는 게시한 문서를 말한다.\r\n\r\n제3조(약관의 명시)\r\n① 공급사업자는 이용사업자가 본 약관, 개별약관의 내용과 공급사업자의 상호, 회사소재지, 대표자의 성명, 사업자등록번호, 연락처 등을 쉽게 알 수 있도록 공급사업자가 운영하는 웹사이트 내의 적절한 장소에 게시한다.\r\n② 공급사업자는 이용사업자가 공급사업자와 이 약관의 내용에 관하여 질의 및 응답을 할 수 있도록 적절한 절차를 마련하여야 한다.\r\n\r\n제4조(약관의 동의)\r\n① 이용사업자는 본 약관의 규정에 따라 본 서비스를 이용해야 한다. 이용사업자는 본 약관과 개별약관에 대해 유효한 동의를 했을 경우에 한하여 본 서비스를 이용할 수 있다.\r\n② 이용사업자는 회원 가입 후, 서비스 내 신규 회사를 개설하는 시점에 본 약관에 동의해야만 회사를 개설하여 운영할 수 있다. 이용사업자가 본 약관의 내용을 확인하고 회사를 개설한 뒤 본 서비스를 실제로 이용하거나 최종이용자가 실제로 이용하도록 하는 경우에도 본 약관에 동의하는 것으로 간주된다.\r\n③ 공급사업자는 본 약관 이외에 별도의 이용약관 및 정책을 둘 수 있으며, 해당 내용이 본 약관과 상충할 경우에는 개별약관이 우선 적용되며, 다만 개별약관이 규율하지 않는 부분에 대해서는 본 약관이 적용된다.\r\n\r\n제 5조(약관의 변경)\r\n① 공급사업자는 「약관의 규제에 관한 법률」, 「정보통신망 이용촉진 및 정보보호 등에 관한 법률」 등 관련 법령을 위배하지 않는 범위에서 본 약관을 개정할 수 있다.\r\n② 공급사업자가 본 약관을 개정할 경우에는 적용일자 및 개정사유를 명시하여 현행약관과 함께 제1항의 방식에 따라 그 개정약관의 적용일자 7일 전부터 적용일자 전일까지 공지한다. 다만, 이용사업자에게 불리한 약관의 개정의 경우에는 적용일자 30일 전에 공지하며, 이와 별도로 개정약관의 내용을 이용사업자가 등록한 이메일 또는 서비스 내 기능을 통해 개별적으로 통지한다.\r\n③ 이용사업자가 전항에 따라 개정약관을 공지 또는 통지한 후에 이용사업자가 30일 기간 내에 명시적으로 거부의 의사표시를 하지 않은 경우 약관의 개정사항에 대해 동의한 것으로 간주하며, 변경된 약관에 대한 정보를 알지 못하여 발생하는 이용사업자의 피해에 대해 공급사업자는 책임을 지지 않는다.\r\n\r\n제6조(약관의 해석)\r\n본 약관에서 정하지 아니한 사항과 본 약관의 해석에 관하여는 「개인정보 보호법」, 「신용정보의 이용 및 보호에 관한 법률」, 「약관의 규제에 관한 법률」, 「정보통신망 이용촉진 및 정보보호 등에 관한 법률과 관계 법령 또는 상관습에 따른다.\r\n\r\n제2장 이용계약의 체결 및 약관 동의\r\n제7조(이용신청 및 방법)\r\n① 이용사업자는 공급사업자가 정한 이용신청 양식에 따라 본 서비스 제공에 필요한 필수 정보를 기입한 후 본 약관의 내용에 대하여 동의한다는 의사표시를 하여 본 서비스의 이용을 신청한다. 공급사업자는 이용신청에 필요한 개인정보의 항목과 그 처리목적을 이용사업자가 확인할 수 있도록 개인정보 처리방침에 안내한다.\r\n② 이용사업자는 제1항의 신청을 할 때에 본인의 실명(법인사업자의 경우 실제 상호, 이하 같다) 및 실제 정보를 기재하여야 한다. 이용사업자가 타인 또는 타사의 명의를 도용하거나 거짓 정보를 기재한 경우에는 본 약관에서 정한 권리를 주장할 수 없고, 공급사업자는 이를 이유로 본 서비스 이용계약을 해제하거나 해지할 수 있다.\r\n③ 14세 미만의 아동은 본 서비스를 이용할 수 없으며 14세 미만의 아동이 아닌 미성년자가 이용할 경우에는 법정대리인의 동의를 얻어야 하고, 구체적인 동의절차는 이용사업자가 제공하는 방법에 따르며 이에 따라 발생하는 문제에 대하여 공급사업자는 책임지지 않는다.\r\n④ 유료 서비스를 이용하고자 하는 이용사업자는 개별계약을 체결함으로써 유료 서비스의 이용을 신청할 수 있다.\r\n\r\n제8조(이용신청의 승낙과 거절)\r\n① 서비스 이용계약은 이용사업자가 공급사업자에게 이용신청을 하고, 공급사업자의 승낙의 통지가 이용사업자에게 도달한 때에 성립한다. 다만, 이용사업자가 본 서비스 이용을 위하여 공급사업자와 본 약관과 별도의 개별계약을 체결한 경우, 계약의 성립시기는 별도의 서면 계약서가 양측에 의해 날인되어 양측 모두 원본 혹은 사본을 교부받은 때로 한다.\r\n② 공급사업자는 원칙적으로 이용사업자의 이용신청을 승낙한다. 단, 다음 각 호의 어느 하나에 해당하는 이용신청에 대해서는 승낙하지 않을 수 있다.\r\n1. 제7조(이용신청 및 방법) 제2항에 위반하여 이용을 신청한 경우\r\n2. 이용사업자가 이용요금을 납부하지 않은 경우\r\n3. 이용사업자가 공급사업자와 체결한 계약의 중대한 내용을 위반한 사실이 있는 경우\r\n4. 14세 미만의 아동으로 확인된 경우\r\n5. 14세미만의 아동이 아닌 미성년자가 법정대리인의 동의를 받지 않았거나 동의를 받은 사실을 확인할 수 없는 경우\r\n6. 타인의 신용카드, 유·무선 전화, 은행 계좌 등을 무단으로 이용하거나 도용하여 서비스 이용요금을 결제하는 경우\r\n7. 「정보통신망 이용촉진 및 정보보호 등에 관한 법률」, 「저작권법」, 「개인정보 보호법」 및 그 밖의 관계 법령에서 금지하는 위법행위를 할 목적으로 이용신청을 하는 경우\r\n8. 이용사업자가 이 계약에 의하여 이전에 이용사업자의 자격을 상실한 사실이 있는 경우\r\n9. 그 밖에 제1호에서 제7호까지에 준하는 사유로서 승낙하는 것이 상당히 부적절하다고 판단되는 경우\r\n③ 공급사업자는 다음 각 호의 어느 하나에 해당하는 경우에는 그 사유가 해소될 때까지 승낙을 유보할 수 있다.\r\n1. 공급사업자의 설비에 여유가 없거나 기술적 장애가 있는 경우\r\n2. 서비스 장애 또는 서비스 이용요금 결제수단에 장애가 있는 경우\r\n3. 그 밖에 제1호 또는 제2호에 준하는 사유로서 이용신청의 승낙이 곤란한 경우\r\n④ 이용사업자는 이용신청 시 기재한 필수정보가 변경되었을 경우 이메일, 고객센터 등을 통하여 그 내용을 공급사업자에게 지체 없이 알려야 하며, 그 필수정보가 개인 정보에 해당하는 경우 본 서비스 내 계정 설정 페이지를 통하여 직접 수정하여야 한다.\r\n\r\n제3장 계약 당사자의 의무\r\n제9조(공급사업자의 의무)\r\n① 공급사업자는 안정적인 서비스 제공을 위하여 정기적인 운영 점검을 실시할 수 있고, 이를 사전에 이용사업자에게 통지하여야 한다.\r\n② 공급사업자는 장애로 인하여 정상적인 서비스가 어려운 경우에 이를 신속하게 수리 및 복구하고, 신속한 처리가 곤란한 경우에는 그 사유와 일정을 이용사업자에게 통지하여야 한다.\r\n③ 공급사업자는 적절한 수준의 보안을 제공하여야 하며, 개인정보의 유출 또는 제3자로부터의 권리 침해를 방지할 의무가 있다.\r\n\r\n제10조(이용사업자의 의무)\r\n① 이용사업자는 서비스를 이용하는 과정에서 본 약관 및 개별약관, 저작권법 등 관련 법령을 위반하거나 선량한 풍속, 기타 사회질서에 반하는 행위를 하여서는 아니 된다.\r\n② 유료 서비스를 사용하는 이용사업자는 이용계약에서 정한 날까지 요금을 납부하여야 하고, 연락처, 결제 방법 등 거래에 필요한 정보가 변경된 때에는 그 사실을 공급사업자에게 지체 없이 알려야 한다.\r\n③ 이용사업자는 아이디와 비밀번호 등 서비스 접속정보에 대한 관리책임이 있으며, 이용사업자 혹은 최종이용자의 주의의무 위반으로 인한 최종이용자 정보의 도용에 대해서는 공급사업자가 책임을 지지 않는다.\r\n④ 이용사업자는 이 계약의 규정, 이용안내 및 서비스와 관련하여 공급사업자로부터 통지받은 제반사항을 확인하고, 합의된 사항을 준수하여야 한다.\r\n\r\n제10조의2(최종이용자의 권리 및 의무)\r\n①최종이용자는 계정을 생성할 때 정확하고 완전한 최신정보를 제공해야 하며, 계정의 정보를 항상 최신으로 유지하여야 한다.\r\n② 최종이용자는 본인 스스로 이용사업자가 이용을 허가한 최종이용자임을 보증하여야 한다.\r\n③ 최종이용자는 다음 사항과 관련하여 이용사업자가 전적으로 책임을 부담한다는 점에 동의한다.\r\n1. 이용사업자 데이터 처리에 영향을 줄 수 있는 이용사업자의 모든 정책 및 관행, 그리고 설정에 대해 최종이용자에게 통보하는 일\r\n2. 이용사업자의 서비스 운영에 필요한 최종이용자의 권리, 허가 또는 동의를 얻는 일\r\n3. 이용사업자 계약에 따라 이용사업자 데이터를 전송 및 처리하는 것이 안전하다는 것을 최종이용자에게 증명하고, 이용사업자 데이터를 기반으로 발생한 최종이용자간 분쟁을 해결하는 일\r\n\r\n제4장 서비스의 이용\r\n제11조(서비스의 제공 및 변경)\r\n① 공급사업자는 이용사업자에게 이용계약에 따른 서비스를 제공하여야 한다.\r\n② 공급사업자는 서비스의 내용 또는 그 이행수준 변경 시 이용사업자에게 불리하고 또한 그 내용이 중요한 경우에는 이용사업자의 동의를 얻어야 한다.\r\n③ 공급사업자는 서비스의 원활한 사용을 위해 이용사업자에게 제품, 신규 기능, 활용 방법 등에 대한 정보성 안내를 이메일 등으로 제공할 수 있다.\r\n④ 공급사업자와 이용사업자는 서로 간의 문의나 요청에 대응하기 위해 이를 처리하는 담당부서 및 담당자의 이름과 연락처를 정하여 알려주어야 한다.\r\n주식회사 이에스지표준원 담당자: 강정화, contect@esgstandard.or.kr\r\n\r\n제11조의 2(최종이용자의 서비스 이용)\r\n최종이용자는 이용사업자가 공급사업자와 체결한 서비스 이용계약이 만료, 해지되거나 이용사업자 또는 공급사업자가 본 서비스에 대한 최종이용자의 접근권한을 종료시킬 때까지 서비스를 이용할 수 있다. 다만, 최종이용자는 본 서비스 이용을 종료하기를 원할 경우 언제든지 탈퇴할 수 있다.\r\n\r\n제12조(서비스 이용 요금)\r\n① 이용사업자는 유료 서비스 이용신청시 이용료를 지급하여야 하고, 서비스 이용요금에 관련한 세금에 대한 책임을 부담한다.\r\n② 공급사업자는 본 서비스 제공을 위하여 이용사업자와 별도의 개별계약을 체결할 수 있고, 별도의 개별계약이 다르게 명시하지 않는 한, 이용계약의 종료일에 상관없이 공급사업자의 가격정책 변동에 따라 요금이 인상될 시 즉시 다음 청구 기간에 반영한다.\r\n\r\n제13조(이용요금의 청구와 지급)\r\n① 공급사업자는 과금 시점을 기준으로 이용기간 동안 발생할 예정인 이용요금을 청구하고 지급청구서 또는 전자세금계산서를 발송하여야 한다.\r\n② 이용사업자는 지급청구서 혹은 전자세금계산서의 내용에 이의가 없으면 기재된 지급기일까지 청구된 요금을 지급하여야 한다. \r\n③ 이용사업자는 청구된 이용요금에 이의가 있으면 청구서가 도달한 날로부터 4일 이내에 이의를 신청할 수 있고, 공급사업자는 이의신청을 접수한 날로부터 7일 이내에 그 처리결과를 이용사업자에게 통지하여야 한다.\r\n④ 이용사업자는 지급과 관련하여 이용사업자가 입력한 정보가 정확한지 여부를 확인해야 하며, 입력 정보와 관련하여 발생한 책임과 불이익은 이용사업자가 전적으로 부담한다.\r\n⑤ 공급사업자의 고의 및 중대한 과실이 있거나 공급사업자가 인정한 사유에 의한 경우를 제외하고 이용요금 미납으로 인해 발생하는 모든 문제에 대한 책임은 이용사업자에게 있다.\r\n\r\n제13조의 2(결제수단)\r\n① 유료 서비스에서 사용할 수 있는 이용요금 결제수단은 다음 각 호와 같다.\r\n1. 계좌이체\r\n② 이용사업자는 타인의 결제수단을 임의로 사용할 수 없다. 타인의 결제수단을 임의 사용함으로써 발생하는 공급사업자, 결제수단의 적법한 소유자, 기타 해당 결제와 관련된 제3자의 손실이나 손해에 대한 책임은 전부 이용사업자에게 있다.\r\n③ 유료서비스 이용을 위한 결제를 위하여 이용사업자가 입력한 정보가 부정확하여 발생한 문제에 대한 책임과 불이익은 이용사업자가 전적으로 부담하여야 한다.\r\n④ 이용사업자는 유료서비스 이용요금 결제 시 정당하고, 적법한 사용권한을 가지고 있는 결제수단을 사용하여야 하며, 공급사업자는 그 여부를 확인할 수 있으며, 이용사업자가 사용한 결제수단의 적법성 등에 대한 확인이 완료될 때까지 거래 진행을 중지하거나 해당 거래를 취소할 수 있다.\r\n\r\n제14조(이용요금의 정산 및 반환)\r\n① 공급사업자는 이용사업자가 이용요금을 과·오납한 때에는 이를 반환하여 정산하여야 하고, 이용사업자가 이용요금을 체납한 때에는 납입기일 다음날부터 완납시까지 지체일당 체납금액의 (1,000)분의 (3)을 곱하여 가산금을 징수할 수 있다.\r\n② 이용사업자가 공급사업자의 귀책사유로 인한 서비스의 중대한 장애로 인하여 서비스를 사용할 수 없는 경우 이미 요금이 납부된 경우 공급사업자에게 장애 발생시점부터 장애해결 후 정상 이용이 가능해진 시점까지 이용요금의 반환을 청구할 수 있다.\r\n\r\n제15조(서비스 이용의 제한 및 정지)\r\n① 공급사업자는 다음 각 호의 어느 하나에 해당하는 경우에 서비스 이용을 제한 혹은 정지할 수 있으며, 그 사유가 해소되면 지체 없이 서비스 제공을 재개하여야 한다.\r\n1. 이용사업자가 정당한 사유 없이 이용요금을 연체하여 체납금 및 가산금의 이행을 최고 받은 후 14일 이내에 이를 납입하지 않는 경우\r\n2. 이용사업자 혹은 최종이용자가 제3자에게 서비스를 임의로 제공하는 경우\r\n3. 이용사업자 혹은 최종이용자가 시스템 운영이나 네트워크 보안 등에 심각한 장애 혹은 전자적 침해행위로 데이터의 손상, 서버정지 등을 초래하거나 그 밖에 이 계약의 규정에 위반하거나 할 우려가 있는 행위를 한 경우\r\n4. 기타 관련 법령에 위반하거나 공급사업자의 업무를 방해하는 행위를 하는 경우\r\n② 공급사업자는 제1항 1호에 따른 서비스를 정지하기 전 (14)일까지 그 사실을 이용사업자에게 통지하고 이의신청의 기회를 주어야 한다. 다만, 이용사업자의 책임 있는 사유로 통지를 할 수 없는 때에는 그러하지 아니하다.\r\n③ 공급사업자는 제1항 2, 3, 4호에 따른 서비스 이용 제한 혹은 정지는 사전 통지 없이 진행할 수 있으며, 공급사업자는 진행 후 그 사실을 이용사업자에게 지체 없이 통지하여야 한다.\r\n④ 공급사업자가 제1항 각 호에 따라 서비스를 정지한 경우에는 특별한 사유가 없으면 이용사업자가 그 기간 동안의 이용요금을 납부하여야 한다.\r\n\r\n제16조(서비스의 일시 중지)\r\n이용사업자는 서비스의 일시 중지를 요구할 수 없다.\r\n\r\n제17조(서비스 제공의 중단)\r\n① 공급사업자는 다음 각 호의 어느 하나에 해당하는 경우에 서비스 제공을 중단할 수 있으며, 그 사유가 해소되면 지체 없이 서비스 제공을 재개하여야 한다.\r\n1. 서비스 개선을 위한 시스템 개선, 설비의 증설·보수·점검, 시설의 관리 및 운용 등의 사유로 부득이하게 서비스를 제공할 수 없는 경우\r\n2. 해킹 등 전자적 침해사고나 통신사고 등 예상하지 못한 서비스의 불안전성에 대응하기 위하여 필요한 경우\r\n3. 천재지변, 정전, 서비스 설비의 장애 등으로 인하여 정상적인 서비스 제공이 불가능한 경우\r\n② 공급사업자는 제1항에 따라 서비스를 중단할 수 있으나, 중단 후에는 지체 없이 그 사실을 이용사업자에게 통지하여야 한다.\r\n③ 제2항에 따른 통지에는 중단기간이 포함되어야 하고, 공급사업자가 그 기간을 초과한 경우에는 이용요금에서 초과기간에 대한 금액을 공제한다.\r\n④ 이용사업자가 제1항 각호에 정한 사유의 발생에 대하여 책임이 없는 경우에는 중단기간 동안의 이용요금에 대한 납부의무를 면한다.\r\n\r\n제5장 서비스의 이용기간 및 종료\r\n제18조(이용사업자의 해제 및 해지)\r\n① 이용사업자는 다음 각 호의 어느 하나에 해당하는 사유가 있는 경우에는 해당 서비스를 처음 제공받은 날부터 3월 이내 또는 그 사실을 알았거나 알 수 있었던 날부터 30일 이내에 이 계약을 해제할 수 있다.\r\n1. 이 계약에서 약정한 서비스가 제공되지 않는 경우\r\n2. 제공되는 서비스가 표시 · 광고 등과 상이하거나 현저한 차이가 있는 경우\r\n3. 그 밖에 서비스의 결함으로 정상적인 이용이 불가능하거나 현저히 곤란한 경우\r\n② 이용사업자는 다음 각 호의 어느 하나에 해당하는 경우에 계약을 해지할 수 있다.\r\n1. 공급사업자가 서비스 제공 중에 파산 등의 사유로 계약상의 의무를 이행할 수 없거나 그 의무의 이행이 현저히 곤란하게 된 경우\r\n2. 공급사업자가 약정한 서비스계약의 내용에 따른 서비스제공을 다하지 않는 경우\r\n③ 제1항과 제2항에 따라 계약을 해지하고자 하는 때에는 공급사업자에게 해지 예정일 (30)일 전까지 그 사유를 통지하고 이의 신청의 기회를 주어야 한다. 다만 공급사업자의 책임 있는 사유로 통지를 할 수 없는 때에는 사전통지와 이의신청의 기회제공을 면한다.\r\n④ 이용사업자가 본 조에 따라 유료 서비스 이용계약을 해제 또는 해지하는 경우 공급사업자는 이용사업자에게 해지예정일로부터 남은 기간 동안의 이용요금을 일할계산하여 환불한다.\r\n\r\n제19조(공급사업자의 해제 및 해지)\r\n① 공급사업자는 다음 각 호의 어느 하나에 해당하는 경우에 계약을 해제할 수 있다.\r\n1. 공급사업자가 서비스를 개시하여도 이용사업자가 계약의 목적을 달성할 수 없는 경우\r\n2. 계약체결 후 서비스가 제공되기 전에 이용사업자가 파산 등의 사유로 계약상의 의무를 이행할 수 없거나 그 의무의 이행이 현저히 곤란하게 된 경우\r\n② 공급사업자는 다음 각 호의 어느 하나에 해당하는 경우에 계약을 해지할 수 있다.\r\n1. 이용사업자가 제10조(이용사업자의 의무)에서 정한 이용사업자의 의무를 위반한 경우 혹은 다음 각 목의 어느 하나에 해당하는 경우 가. 이용사업자가 서비스 이용을 정지당한 후 월 이용요금을 기준으로 (3)회 이상 이용요금의 지급을 연체한 경우 나. 이용사업자가 공급사업자의 동의 없이 계약상의 권리 및 의무를 제3자에게 처분한 경우\r\n2. 제14조(서비스 이용의 제한 및 정지)에 따라 서비스의 이용이 제한된 이용사업자가 상당한 기간 동안 해당 사유를 해소하지 않는 경우\r\n3. 사업의 종료에 따라 서비스를 종료하는 경우\r\n③ 공급사업자가 제2항에 따라 계약을 해지하고자 하는 때에는 이용사업자에게 (30)일 전까지 그 사유를 통지하고 이의신청의 기회를 주어야 한다. 다만, 이용사업자의 책임 있는 사유로 통지를 할 수 없는 때에는 사전통지와 이의신청의 기회제공을 면한다.\r\n④ 공급사업자는 이용사업자가 고의 또는 중대한 과실로 공급사업자에게 손해를 입힌 경우에는 사전 통지 없이 계약을 해지할 수 있으며, 공급사업자는 해지 후 그 사실을 이용사업자에게 지체 없이 통지하여야 한다.\r\n⑤ 제2항 제3호 및 제4항에 따른 계약 해지는 이용사업자에 대한 손해배상의 청구에 영향을 미치지 아니한다.\r\n⑥ 공급사업자가 계약을 해지하는 경우에는 이용사업자에게 서면, 전자우편 또는 이에 준하는 방법으로 다음 각 호의 사항을 통지하여야 한다.\r\n1. 해지사유\r\n2. 해지일\r\n3. 환급비용\r\n\r\n제6장 이용사업자 데이터의 보호\r\n제20조(이용자 정보의 보호와 관리)\r\n공급사업자는 관련 법령이 정하는 바에 따라 이용사업자 데이터를 보호한다. 최종이용자 정보의 보호 및 이용에 대해서는 관련 법령 및 별도로 고지하는 개인정보 처리방침을 따른다.\r\n\r\n제7장 공급사업자의 면책 등\r\n제21조(공급사업자의 면책)\r\n① 공급사업자는 본 서비스를 “있는 그대로 (As Is)” 제공하며 이용사업자가 서비스를 이용하여 기대하는 이익을 얻지 못하거나 상실한 것에 대하여 책임을 지지 않는다.\r\n② 공급사업자는 공급사업자의 고의 및 중대한 과실이 없는 한 다음 각 호에서 정의한 손해에 대하여 어떠한 책임도 부담하지 않는다.\r\n1. 무료체험서비스, 테스트, 시범 운영 서비스 등 공급사업자에게 비용을 지불하지 않은 서비스의 이용으로 인한 손해\r\n2. 최종이용자 간, 이용사업자와 최종이용자 간, 최종이용자와 제3자 간, 이용사업자와 제3자 간에 발생한 분쟁으로 인한 손해\r\n3. 천재지변 또는 이에 준하는 불가항력의 상태에서 발생한 손해\r\n4. 공급사업자의 통제범위를 벗어난 외부 네트워크 및 장비 등으로 인하여 발생한 손해\r\n5. 공급사업자가 제 17 조 제 1 항의 사유로 서비스를 제한·중단하여 발생한 손해\r\n6. 이용사업자 및 최종사용자의 귀책사유로 인하여 발생한 손해\r\n7. 제 3자가 서비스의 접속 및 전송을 방해하거나 서비스를 중단시켜 발생한 손해\r\n8. 제 3자가 악성 프로그램을 전송 또는 유포함으로써 발생하는 손해\r\n9. 제 3자에 의한 이용사업자 및 최종이용자의 계정 또는 공급사업자 서버에 대한 승인되지 않은 접속 및 이용을 원인으로 발생한 손해\r\n10. 전송된 데이터의 생략, 누락, 파괴 등으로 발생한 손해\r\n11. 공급사업자의 고의 또는 과실이 없는 사유로 인해 발생한 손해\r\n③ 관련 법령에 의하여 허용되는 최대한의 범위 내에서, 공급사업자, 공급사업자 및 그 제휴사의 임원, 이사, 파트너, 직원, 대리인 및 고문 (통칭하여 “공급사업자 측”)은 비록 그러한 손실 또는 손해의 가능성에 앞서 조언을 하였더라도 본 서비스의 이용과 관련한 상실이익, 상실수입, 상실예금 기타 간접적, 징벌적, 예외적 손해에 대하여 어떠한 방식으로도 책임을 부담하지 않는다.\r\n\r\n제22조(최고관리자 및 최종이용자의 이용약관)\r\n본 서비스 내에서 활동하는 모든 최종이용자 및 이용사업자를 대표하는 최고관리자(접근 권한)는 본 이용약관을 준수한다.\r\n\r\n제23조(이용사업자에 대한 통지)\r\n① 공급사업자는 다음 각 호의 어느 하나에 해당하는 사유가 발생한 경우에는 이용사업자가 미리 지정한 전화 또는 휴대전화로 통화하거나, 문자메시지 또는 우편(전자우편 포함)의 발신, 서비스 접속화면 게시 등의 방법으로 이용사업자에게 알려야 한다.\r\n1. 침해사고\r\n2. 최종이용자 정보의 유출\r\n3. 서비스의 중단\r\n4. 서비스의 종료\r\n5. 그밖에 이용사업자의 서비스 이용에 중대한 영향을 미치는 사항\r\n② 공급사업자는 제1항 각 호 중 어느 하나에 해당하는 사유가 발생한 경우에는 그 사실을 지체 없이 이용사업자에게 알려야 한다. 다만, 다음 각 호의 경우는 예외로 한다.\r\n1. (14)일 전에 사전 예고를 하고 서비스를 중단한 경우\r\n2. 30일 전에 서비스를 변경하거나 종료하도록 한 경우\r\n3. 30일 전에 사업을 폐지하거나 종료하도록 한 경우\r\n③ 공급사업자는 제1항 제1호에서 제3호까지의 사유가 발생한 경우에 지체 없이 다음 각 호의 사항을 해당 이용사업자에게 알려야 한다. 다만, 제2호의 발생 원인을 바로 알기 어려운 경우에는 나머지 사항을 먼저 알리고, 발생 원인이 확인되면 이를 지체 없이 해당 이용사업자에게 알려야 한다.\r\n1. 발생내용\r\n2. 발생원인\r\n3. 공급사업자의 피해 확산 방지 조치 현황\r\n4. 이용사업자의 피해예방 또는 확산방지방법\r\n5. 담당부서 및 연락처\r\n\r\n제24조(양도 등의 제한)\r\n공급사업자와 이용사업자, 최종이용자는 이 계약에 따른 권리와 의무의 전부 또는 일부를 상대방의 사전 동의 없이 제3자에게 양도 또는 담보로 제공할 수 없다. 이용사업자가 최고관리자 권한을 다른 사내 담당자에게 양도하는 것은 계약의 권리와 의무 양도와 관계없다.\r\n\r\n제25조(관할법원)\r\n공급사업자와 이용사업자 간 및 공급사업자와 최종이용자 간에 발생한 분쟁으로 소송이 제기되는 경우에는 서울중앙지방법원을 관할법원으로 한다.\r\n\r\n제26조(준거법)\r\n이 계약의 성립, 효력, 해석 및 이행과 관련하여서는 대한민국법을 적용한다.\r\n\r\n	LOCALLINK 개인정보처리방침\r\n주식회사 이에스지표준원(이하 "회사"라 함)은 이용자의 개인정보를 소중히 여기며, 『개인정보 보호법』 및 『정보통신망 이용촉진 및 정보보호 등에 관한 법률』 등 개인정보처리자가 준수하여야 하는 대한민국의 관계 법령 및 규정, 가이드라인에 따라 개인정보를 처리·관리합니다.\r\n본 방침은 회사가 제공하는 LOCALLINK(이하 "서비스")에서 수집하는 개인정보의 항목, 이용목적, 보유기간, 제3자 제공 등 주요 내용 안내하며, 수집·처리하는 구체적인 방침을 제공합니다.\r\n\r\n1. 개인정보의 처리 목적\r\n회사는 다음의 목적을 위해 개인정보를 처리합니다. 처리하는 개인정보는 목적 이외의 용도로는 사용되지 않으며, 목적이 변경될 경우에는 사전 동의를 구하겠습니다.\r\n•\t서비스 제공 및 관리: 회원가입, 서비스 제공, 계약 이행, 고객 상담 등\r\n•\t마케팅 및 광고: 이벤트 안내, 고객 대상 맞춤형 서비스 제공 등\r\n•\t법적 의무 준수: 관련 법령에 따른 법적 의무 이행\r\n\r\n2. 처리하는 개인정보 항목\r\n회사는 다음의 개인정보 항목을 수집·이용합니다.\r\n•\t필수항목: 이름, 생년월일, 성별, 연락처(휴대폰번호, 이메일), IP 주소, 서비스 이용 기록\r\n•\t선택항목: 주소, 결제 정보(신용카드 정보 등), 서비스 이용을 위한 인증 정보\r\n\r\n3. 개인정보의 보유 및 이용 기간\r\n회사는 법령에 따른 개인정보 보유·이용 기간 또는 이용자가 개인정보의 수집·이용에 대한 동의일로부터 일정 기간 동안 개인정보를 처리·보유합니다. \r\n•\t예: 회원 가입 이후 탈퇴 시까지, 법령에 따라 보존해야 하는 기간(최대 5년) 동안\r\n\r\n4. 개인정보의 파기 절차 및 방법\r\n개인정보는 처리 목적에 따라 보유 기간이 끝난 후 지체없이 파기합니다. \r\n•\t파기 방법: 전자적 파일 형식인 경우 복구가 불가능한 방법으로 삭제, 종이 문서의 경우 분쇄 또는 소각\r\n\r\n5. 개인정보의 제3자 제공\r\n회사는 이용자의 별도 동의 없이는 개인정보를 제3자에게 제공하지 않으며, 제공 시에는 제공 목적, 항목, 받는 자 등을 명확히 고지하고 동의를 받습니다. 다만, 법률에 특별한 규정이 있는 경우 예외로 합니다.\r\n\r\n6. 이용자 권리와 행사 방법\r\n이용자는 언제든지 개인정보 열람, 정정, 삭제, 이용 정지 요구 등을 할 수 있으며, 회사는 이에 지체없이 조치하겠습니다.\r\n•\t행사 방법: 이메일, 고객센터 전화 등을 통해 요청 가능\r\n\r\n7. 개인정보의 안전성 확보 조치\r\n회사는 개인정보의 안전한 처리를 위해 다음과 같은 기술적·관리적 조치를 취하고 있습니다.\r\n•\t접근 권한 제한, 암호화, 주기적인 직원 교육 등\r\n\r\n8. 개인정보 보호책임자 및 문의처\r\n개인정보 관련 문의, 불만 처리, 피해 구제 등을 위해 개인정보 보호책임자를 지정하고 있습니다.\r\n•\t이름: \r\n•\t연락처: [전화번호], [이메일 주소]\r\n\r\n9. 기타\r\n이 방침은 시행일(2025년 *월 *일)로부터 적용되며, 법률 또는 정책 변경에 따라 필요 시 수정·공개할 예정입니다.\r\n\r\n	{"brn": "사업자등록번호: 314-86-68179", "address": "서울특별시 서대문구 통일로484 서대문구창업보육센터 208호", "contact": "문의: locallinkai@esgstandard.or.kr", "copyright": "2025 LocalLink. All Rights Reserved.", "company_info": "상호:이에스지표준원 | 대표:권영석"}	마케팅 활용 및 수신 동의\r\n주식회사 이에스지표준원은 “개인정보 보호법”에 따라 동의를 얻어 아래와 같이 LocalLink 서비스의 홍보 및 마케팅을 위한 개인정보를 수집, 이용 합니다.\r\n1.수집목적      \r\n○ 이용자에 대한 편의 제공, 본 서비스에 대한 상품·서비스 안내 및 이용권유, 사은·판촉행사 등의 마케팅 활동, 시장조사 및 상품·서비스 개발연구 등을 목적으로 수집·이용\r\n○ LocalLink 에서 운영하는 서비스의 원할한 이용 목적으로 수집·이용\r\n○ 성명, 휴대전화번호, 이메일, 업체명\r\n2.보유기간\r\n○ 동의일로부터 회원 탈퇴 혹은 마케팅 동의 해제 시까지 보유·이용\r\n귀하는 개인정보 수집, 이용에 동의하지 않을 권리가 있으며, 동의를 거부할 경우에는 거부한 내용 관련 서비스를 받을 수 없습니다.\r\n주식회사 이에스지표준원에서 제공하는 마케팅 정보를 원하지 않을 경우 ‘설정 > 수정’에서 철회를 요청할 수 있습니다. 또한 향후 마케팅 활용에 새롭게 동의하고자 하는 경우에는 ‘설정 > 수정’에서 동의하실 수 있습니다.\r\n\r\n
\.


--
-- Data for Name: strategy_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.strategy_rules (id, description, conditions, recommended_program_code, priority) FROM stdin;
3	e 점수가 80점 미만	{"rules": [{"item": "E", "type": "category_score", "value": 60, "operator": "<"}], "operator": "AND"}	E-PROG-01	1
5	장애인 점수가 100점 미만일때	{"rules": [{"item": "S-Q6", "type": "question_score", "value": 100, "operator": "<"}, {"item": "S-Q6_1", "type": "question_score", "value": 100, "operator": "<"}, {"item": "S-Q6_2", "type": "question_score", "value": 100, "operator": "<"}], "operator": "OR"}	s-PROG-01	1
9	지속가능재무(개별문항)	{"rules": [{"item": "S-Q16_1", "type": "question_score", "value": 100, "operator": "<"}, {"item": "S-Q16", "type": "question_score", "value": 100, "operator": "<"}, {"item": "S-Q15_1", "type": "question_score", "value": 100, "operator": "<"}], "operator": "OR"}	G-PROG-01	0
10	폐기물 처리 현황이 50점 미만	{"rules": [{"item": "S-Q2", "type": "question_score", "value": 50, "operator": "<"}, {"item": "S-Q2", "type": "question_score", "value": 50, "operator": "<"}], "operator": "OR"}	테스트 250630	1
\.


--
-- Data for Name: survey_questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.survey_questions (id, question_code, esg_category, question_text, question_type, options, explanation, display_order, next_question_default, next_question_if_yes, next_question_if_no, criteria_text, benchmark_metric, diagnosis_type, scoring_method) FROM stdin;
54	Q1	E	테스트	YN	[{"text": "1", "value": "1"}, {"text": "2", "value": "2"}]	테스트	1	END_SURVEY	\N	\N	\N	ghg_emissions_avg	advanced	direct_score
4	S-Q2_1	E	온실가스 배출량을 산정한 적이 있다면, 연간 배출량은 얼마나 됩니까?	INPUT	[]	단위는 tCO₂eq입니다. 연간 총 배출량을 입력해주세요. 동종 업계 평균치를 참고자료로 활용할 수 있으며, 정확한 산정이 어려울 경우 전문가의 도움을 받는 것이 좋습니다.	4	S-Q3	\N	\N	\N	ghg_emissions_avg	simple	benchmark_comparison
5	S-Q3	E	(환경-기후변화-에너지사용량)귀사는 에너지 사용량을 모니터링하고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	에너지 사용량 모니터링은 에너지 효율 개선, 비용 절감 및 온실가스 배출량 감축의 기초가 됩니다.	5	\N	S-Q3_1	S-Q4	\N	energy_usage_avg	simple	direct_score
6	S-Q3_1	E	에너지 사용량을 모니터링하고 있다면, 연간 총 에너지 사용량은 얼마입니까?	INPUT	[]	연간 총 에너지 사용량을 MWh로 입력해주세요.	6	S-Q4	\N	\N	\N	energy_usage_avg	simple	benchmark_comparison
16	S-Q8	S	(사회-노동-근속년수)귀사는 전체 직원의 평균 근속년수를 파악하고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	평균 근속년수는 고용의 질과 안정성, 직원 만족도를 간접적으로 나타내는 지표입니다.	16	\N	S-Q8_1	S-Q9	\N	years_of_service_avg	simple	direct_score
17	S-Q8_1	S	전체 직원의 평균 근속년수를 파악하고 있다면, 평균 근속년수는 몇 년입니까?	SELECT_ONE	[{"text": "1번: 2년 미만", "value": "1"}, {"text": "2번: 3~5년", "value": "2"}, {"text": "3번: 5~7년", "value": "3"}, {"text": "4번: 7~10년", "value": "4"}, {"text": "5번: 10년 이상", "value": "5"}]	최근 3년간 퇴사자를 포함한 전체 직원의 평균적인 회사 근무 기간을 선택해주세요.	17	S-Q9	\N	\N	평균 근속년수가 길수록 높은 점수를 획득합니다.	years_of_service_avg	simple	direct_score
19	S-Q9_1	S	귀사는 조직의 사회공헌 관련 계획 또는 실행계획을 수립하고 있습니까?	SELECT_ONE	[{"text": "1번: 선언적 목표 설정", "value": "1"}, {"text": "2번: 계획 및 예산 명시", "value": "2"}, {"text": "3번: 대표프로그램 제시 및 성과관리지표(KPI) 설정", "value": "3"}, {"text": "4번: 중장기 실행계획 마련", "value": "4"}]	사회공헌 활동에 대한 기업의 의지와 실행 수준을 가장 잘 나타내는 항목을 선택해주세요.	19	S-Q9_2	\N	\N	사회공헌 계획 수준이 높을수록 높은 점수를 획득합니다.	donation_ratio_avg	simple	direct_score
20	S-Q9_2	S	최근 1년 이내 기부를 한 적이 있다면, 연간 총 기부금액은 얼마입니까? (₩ 단위: 억원, 5000만원=0.5억원)	INPUT	[]	현금 기부, 현물 기부(시가 평가액), 임직원 봉사활동(인건비 환산액) 등을 포함한 연간 총 기부금액을 억원 단위로 입력합니다.	20	S-Q10	\N	\N	\N	donation_ratio_avg	simple	direct_score
3	S-Q2	E	(환경-기후변화-온실가스배출량)귀사는 최근 1년 내 온실가스 배출량을 산정한 적이 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	이 질문은 귀사의 온실가스 배출량 관리 현황을 파악하기 위한 것입니다. '예'를 선택하시면 배출량에 대한 추가 질문이 나타납니다. 온실가스 관리의 첫 단계는 배출량 산정입니다.	3	\N	S-Q2_1	S-Q3	\N	ghg_emissions_avg	simple	direct_score
25	S-Q12	G	(지배구조-이사회-운영)귀사는 이사회가 정기적으로 운영되고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	정기적인 이사회 운영은 효과적인 의사결정과 경영 감독 기능을 보장합니다.	25	\N	S-Q12_1	S-Q13	\N	\N	simple	direct_score
27	S-Q13	G	(지배구조-경영진-성과평가)귀사는 임원 보수를 매출액과 비교하여 관리하고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	임원 보수 정책의 합리성과 투명성은 책임 경영과 주주 이익 보호에 중요합니다.	27	\N	S-Q13_1	S-Q14	\N	executive_compensation_ratio_avg	simple	direct_score
33	S-Q16	G	(지배구조-윤리경영-규제위반)최근 5년 내 환경, 공정거래, 고용 관련 법규 위반 또는 임직원 처벌 사례가 있었습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	환경, 공정거래, 고용 등 주요 법규 준수는 기업의 기본적인 사회적 책임입니다.	33	\N	S-Q16_1	END_SURVEY	위반 없을 시 100점, 처벌 수위에 따라 감점됩니다.	legal_violation_ratio_avg	simple	direct_score
2	S-Q1_1	E	환경경영 관련 계획을 갖고 있다면, 환경경영 실천 수준은 어느 정도입니까?	SELECT_ONE	[{"text": "1번: 선언적 목표 설정", "value": "1"}, {"text": "2번: 내부 계획 존재", "value": "2"}, {"text": "3번: 예산책정 및 사용(환경단체기부, 인증 등)", "value": "3"}, {"text": "4번: 정기평가 및 이행", "value": "4"}]	단순한 목표 선언을 넘어, 구체적인 내부 계획, 예산 편성 및 집행, 그리고 정기적인 성과 평가 및 피드백 반영까지 실천 수준을 선택해주세요.	2	S-Q2	\N	\N	실천 수준이 높을수록 높은 점수를 획득합니다.	\N	simple	direct_score
24	S-Q11_1	G	사외이사를 선임하고 있다면, 사외이사 수는 전체 이사 수 대비 몇%입니까?	SELECT_ONE	[{"text": "1번: 3인 미만", "value": "1"}, {"text": "2번: 3인 이상이면서 총원의 60%미만", "value": "2"}, {"text": "3번: 3인 이상이면서 총원의 60~70%", "value": "3"}, {"text": "4번: 3인 이상이면서 총원의 70~80%", "value": "4"}, {"text": "5번: 3인 이상이면서 총원의 80% 이상", "value": "5"}]	전체 이사(등기이사 기준) 중 사외이사가 차지하는 비율을 선택해주세요. 상법상 요건 외에 자발적 확대 노력을 평가합니다.	24	S-Q12	\N	\N	사외이사 비율이 높을수록 높은 점수를 획득합니다.	outside_director_ratio_avg	simple	direct_score
22	S-Q10_1	S	품질경영 논의를 하고 있다면, 귀사의 품질경영 수준은 어느 정도라고 보십니까?	SELECT_ONE	[{"text": "1번: 선언적 목표 설정", "value": "1"}, {"text": "2번: 내부 계획수립 및 관리", "value": "2"}, {"text": "3번: 예산책정 및 사용(소비자 피드백 활동, 인증 등)", "value": "3"}, {"text": "4번: 정기평가 및 이행", "value": "4"}]	제품 및 서비스 품질 향상을 위한 목표 설정, 계획 수립, 실행, 평가 및 개선 활동의 전반적인 수준을 선택해주세요.	22	S-Q11	\N	\N	품질경영 수준이 높을수록 높은 점수를 획득합니다.	quality_mgmt_ratio_avg	simple	direct_score
28	S-Q13_1	G	임원 보수를 매출과 비교해 관리하고 있다면, 임원보수는 매출액 대비 몇 %입니까?	SELECT_ONE	[{"text": "1번: 0.1%미만", "value": "1"}, {"text": "2번: 0.1~0.5%", "value": "2"}, {"text": "3번: 0.5%~1.5%", "value": "3"}, {"text": "4번: 1.6%~2%", "value": "4"}, {"text": "5번: 2%이상", "value": "5"}]	등기 임원의 연간 총 보수액(급여, 상여, 스톡옵션 행사 이익 등 포함)이 회사 전체 매출액에서 차지하는 비율을 선택해주세요.	28	S-Q14	\N	\N	매출액 대비 임원 보수 비율이 낮을수록 높은 점수를 획득합니다.	executive_compensation_ratio_avg	simple	direct_score
30	S-Q14_1	G	집중투표 제도를 논의하고 있다면, 제도 운영 수준은 어느 정도입니까?	SELECT_ONE	[{"text": "1번: 선언적 목표 설정", "value": "1"}, {"text": "2번: 내부 계획수립", "value": "2"}, {"text": "3번: 일부 적용", "value": "3"}, {"text": "4번: 모든 의결에 적용", "value": "4"}]	정관에 집중투표제 도입(또는 배제 여부 명시) 및 실제 운영 수준을 선택해주세요.	30	S-Q15	\N	\N	제도 운영 수준이 높을수록 높은 점수를 획득합니다.	cumulative_voting_ratio_avg	simple	direct_score
32	S-Q15_1	G	주주환원 정책을 논의하고 있다면, 주주환원 계획 수준은 어느 정도입니까?	SELECT_ONE	[{"text": "1번: 선언적 목표 설정", "value": "1"}, {"text": "2번: 내부 계획 수립", "value": "2"}, {"text": "3번: 정책 수립 후 일부 반영", "value": "3"}, {"text": "4번: 주기적 배당 또는 자사주 매입 있음", "value": "4"}]	배당, 자사주 매입/소각 등 주주환원 정책의 수립 및 이행 수준을 선택해주세요.	32	S-Q16	\N	\N	주주환원 계획 수준이 높을수록 높은 점수를 획득합니다.	dividend_policy_ratio_avg	simple	direct_score
12	S-Q6_1	S	귀사는 장애인 의무고용률을 몇% 달성했습니까?	SELECT_ONE	[{"text": "1번: 1.8%미만", "value": "1"}, {"text": "2번: 1.8%이상 2.5%미만", "value": "2"}, {"text": "3번: 2.5%이상 3.1%미만", "value": "3"}, {"text": "4번: 3.1%이상 3.8%미만", "value": "4"}, {"text": "5번: 3.8% 이상", "value": "5"}]	장애인고용촉진 및 직업재활법에 따른 상시근로자 수 대비 장애인 의무고용률 달성 수준을 선택해주세요.	12	S-Q6_2	\N	\N	의무고용률 달성 수준이 높을수록 높은 점수를 획득합니다.	disability_employment_ratio_avg	simple	benchmark_comparison
10	S-Q5_1	S	비정규직 직원을 고용하고 있다면, 전체 직원 중 비정규직 비율은 몇 %입니까?	SELECT_ONE	[{"text": "1번: 20% 미만", "value": "1"}, {"text": "2번: 20~40%", "value": "2"}, {"text": "3번: 40~60%", "value": "3"}, {"text": "4번: 60~80%", "value": "4"}, {"text": "5번: 80% 초과", "value": "5"}]	전체 임직원 수 대비 직접 고용한 비정규직(기간제, 단시간 근로자 등)의 비율을 선택해주세요. 파견, 용역 근로자는 제외합니다.	10	S-Q6	\N	\N	비정규직 비율이 낮을수록 높은 점수를 획득합니다.	non_regular_ratio_avg	simple	direct_score
11	S-Q6	S	(사회-노동-장애인)귀사는 장애인을 고용하고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	장애인 고용은 사회적 약자 포용 및 다양성 존중 측면에서 중요한 ESG 요소입니다.	11	\N	S-Q6_1	S-Q7	\N	disability_employment_ratio_avg	simple	direct_score
7	S-Q4	E	(환경-자원순환-폐기물발생량) 귀사는 폐기물 발생량을 모니터링하고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	폐기물 발생량은 귀사와 지역사회의 자원순환정도를 평가하는 지표입니다.	7	\N	S-Q4_1	S-Q5	\N	waste_generation_avg	simple	direct_score
9	S-Q5	S	(사회-노동-비정규직)귀사는 비정규직 직원을 고용하고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	비정규직 고용 현황은 기업의 고용 안정성 및 질과 관련된 사회적 책임을 평가하는 지표입니다.	9	\N	S-Q5_1	S-Q6	\N	non_regular_ratio_avg	simple	direct_score
13	S-Q6_2	S	귀사가 장애인고용부담금(과태료)을 납부하는 경우, 연간 과태료는 얼마입니까? \n(₩, 숫자, 단위 억원, 500만원=0.05)	INPUT	[]	의무고용률 미달 시 납부하는 연간 장애인고용부담금 총액을 억원 단위로 입력합니다. (예: 500만원은 0.05로 입력)	13	S-Q7	\N	\N	\N	disability_employment_ratio_avg	simple	direct_score
14	S-Q7	S	(사회-노동-여성)귀사의 전체 직원 중 여성 직원을 고용하고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	여성 직원 고용 현황은 양성평등 및 직장 내 다양성 확보 노력을 보여주는 지표입니다.	14	\N	S-Q7_1	S-Q8	\N	female_employee_ratio_avg	simple	direct_score
15	S-Q7_1	S	여성직원을 고용하고 있다면, 전체 직원 대비 비율은 몇 %입니까?	SELECT_ONE	[{"text": "1번: 10%미만", "value": "1"}, {"text": "2번: 11~15%", "value": "2"}, {"text": "3번: 15~20%", "value": "3"}, {"text": "4번: 21~25%", "value": "4"}, {"text": "5번: 25% 이상", "value": "5"}]	전체 임직원 수 대비 여성 직원의 비율을 선택해주세요.	15	S-Q8	\N	\N	여성 직원 비율이 높을수록 높은 점수를 획득합니다.	female_employee_ratio_avg	simple	direct_score
18	S-Q9	S	(사회-지역사회-상생협력)귀사는 최근 1년 내 지역사회에 기부를 한 적이 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	지역사회 기부는 기업의 사회적 책임 이행(CSR) 및 ESG측면에서 지역의 사회적 공급망 구축에 기여합니다.	18	\N	S-Q9_1	S-Q10	\N	donation_ratio_avg	simple	direct_score
21	S-Q10	S	(사회-품질경영-소비자,공급망)귀사는 품질경영 관련 논의를 진행한 적이 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	품질경영은 고객 만족도 제고 및 기업 경쟁력 강화의 핵심 요소입니다.	21	\N	S-Q10_1	S-Q11	\N	quality_mgmt_ratio_avg	simple	direct_score
23	S-Q11	G	(지배구조-이사회-사외이사)귀사 이사회에 사외이사를 선임하고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	사외이사 제도는 이사회의 독립성과 경영 투명성을 높이는 데 기여합니다.	23	\N	S-Q11_1	S-Q12	\N	\N	simple	direct_score
31	S-Q15	G	(지배구조-주주권리-배당정책)귀사는 주주환원(배당 등)을 고려한 재무정책을 논의하고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	주주환원은 기업 이익의 공유를 통해 주주 가치를 제고하는 중요한 활동입니다.	31	\N	S-Q15_1	S-Q16	\N	dividend_policy_ratio_avg	simple	direct_score
29	S-Q14	G	(지배구조-주주권리-집중투표제)귀사는 주주권리 보호를 위한 집중투표 제도에 대해 논의한 적이 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	집중투표제는 소수 주주의 권익을 보호하고 이사회의 다양성을 증진하는 제도로 논의될 수 있습니다.	29	\N	S-Q14_1	S-Q15	\N	cumulative_voting_ratio_avg	simple	direct_score
26	S-Q12_1	G	정기적으로 이사회가 운영된다면, 연간 이사회 개최 횟수는 몇 회입니까?	SELECT_ONE	[{"text": "1번: 연간(1회)", "value": "1"}, {"text": "2번: 반기+비정기(2~3회)", "value": "2"}, {"text": "3번: 분기+비정기(4~6회)", "value": "3"}, {"text": "4번: 격월+비정기(6~8회)", "value": "4"}, {"text": "5번: 월(12회 이상)", "value": "5"}]	정기 이사회 및 임시 이사회를 포함하여 연간 총 몇 회의 이사회가 개최되는지 선택해주세요.	26	S-Q13	\N	\N	개최 횟수가 많을수록 높은 점수를 획득합니다. (개최 안 할 시 감점)	board_meetings_avg	simple	direct_score
34	S-Q16_1	G	법규위반 사례가 있다면,사안의 건수 또는 내용은 무엇입니까?	SELECT_ONE	[{"text": "1번: 처벌수위가 형벌·벌금·과료 등인 사법상 처분인 경우", "value": "1"}, {"text": "2번: 처벌수위가 과태료·과징금·이행강제금 등인 행정상 금전적 처분인 경우", "value": "2"}, {"text": "3번: 처벌수위가 시정명령·시정권고·경고 등인 행정상 비금전적 처분인 경우", "value": "3"}]	최근 5년 내 발생한 위반 사례 중 가장 처벌 수위가 높거나 사회적 영향이 컸던 대표적인 사안을 기준으로 선택해주세요.	34	END_SURVEY	\N	\N	처벌 수위가 높을수록 감점 폭이 커집니다.	legal_violation_ratio_avg	simple	direct_score
1	S-Q1	E	(환경-환경경영-전략수립)귀사는 환경경영 관련 정책 또는 실행계획을 수립하고 있습니까?	YN	[{"text": "예", "value": "Yes"}, {"text": "아니오", "value": "No"}]	환경경영 정책 및 실행 계획은 기업의 환경적 책임을 체계적으로 이행하고 지속적인 개선을 도모하기 위한 중요한 기반입니다.	1	\N	S-Q1_1	S-Q2	\N	\N	simple	direct_score
8	S-Q4_1	E	폐기물 발생량을 모니터링하고 있다면, 연간 총 폐기물 발생량은 얼마입니까?	INPUT	[]	폐기물 발생량은 업계평균을 참고해서 입력해주세요	8	S-Q5	\N	\N	\N	waste_generation_avg	simple	benchmark_comparison
\.


--
-- Data for Name: user_applications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_applications (id, user_id, program_id, created_at, status, updated_at) FROM stdin;
28	8	33	2025-07-02 00:10:25.438954+09	접수	2025-07-02 01:03:07.474574+09
25	8	32	2025-06-30 10:37:29.678576+09	접수	2025-07-02 01:03:09.902367+09
24	8	1	2025-06-30 10:37:25.997845+09	접수	2025-07-02 01:03:11.613901+09
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password, company_name, industry_codes, representative, address, business_location, manager_name, manager_phone, interests, created_at, updated_at, reset_token, reset_token_expires, is_verified, verification_token, verification_token_expires, role, profile_image_url, agreed_to_terms_at, agreed_to_privacy_at, agreed_to_marketing, withdrawn_at) FROM stdin;
10	softkwon@naver.com	$2b$10$3B/1M0n/yijQQkNbab6N6Oeu5ewKA3yb9JBVl3KJs2rMPGE/hQ.hu	abcd	{J59,J60,J61}	abcd	경기 성남시 분당구 판교로 30 123 ()	경기	1234	01012345678	{E_interest_1,E_interest_2,S_interest_4,S_interest_5,G_interest_3,G_interest_4}	2025-06-24 13:55:16.209296+09	2025-07-02 01:20:34.270479+09	cd883e925da755bf1d5624d6192a507207e82467e79a1f2bfad45b33e453eac3	2025-07-02 01:47:37.726+09	t	\N	\N	user	\N	\N	\N	t	\N
8	kyss1229@daum.net	$2b$10$CAl8j/9XsBGeBMHC2MF6vuJ2JlB396Gm9oT4NUId8UdKVQpJmi5cC	Master	{B08,C10}	권영석	서울 서대문구 통일로 484 (03628) 208	서울	권영석	01012345678	{E_interest_1,E_interest_2,E_interest_3,E_interest_4,S_interest_4,S_interest_5,G_interest_2}	2025-06-18 03:00:38.018101+09	2025-07-02 00:00:40.694654+09	8642ff0d0ce13b317a100a2a5c6f1e96d8ff97c28d66a8383bb48867a4421952	2025-07-02 01:48:49.214+09	t	\N	\N	super_admin	/uploads/profiles/profile-8-1751174958103.jpeg	\N	\N	t	\N
9	softkwon@esgstandard.or.kr	$2b$10$bpbAOF1FRVz8WR2SaWhyhetsghFgXK9cAdRl7pO32CUuFBn9Ge9ei	(주)이에스지표준원	{E38,J62,M70}	권영석	서울 서대문구 통일로 484 (03628) 208호	서울	권영석	01012345678	{E_interest_1,E_interest_2,E_interest_4,E_interest_5,S_interest_1,S_interest_2,S_interest_3,S_interest_4,S_interest_5,G_interest_1,G_interest_2,G_interest_3,G_interest_4,G_interest_5}	2025-06-19 23:34:08.546918+09	2025-06-24 15:11:12.77773+09	\N	\N	t	\N	\N	user	\N	\N	\N	f	\N
\.


--
-- Name: average_to_answer_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.average_to_answer_rules_id_seq', 31, true);


--
-- Name: benchmark_scoring_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.benchmark_scoring_rules_id_seq', 16, true);


--
-- Name: company_size_esg_issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.company_size_esg_issues_id_seq', 4, true);


--
-- Name: diagnoses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnoses_id_seq', 113, true);


--
-- Name: diagnosis_answers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnosis_answers_id_seq', 2792, true);


--
-- Name: esg_programs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.esg_programs_id_seq', 68, true);


--
-- Name: industries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.industries_id_seq', 82, true);


--
-- Name: industry_averages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.industry_averages_id_seq', 77, true);


--
-- Name: industry_benchmark_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.industry_benchmark_scores_id_seq', 40536, true);


--
-- Name: industry_esg_issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.industry_esg_issues_id_seq', 96, true);


--
-- Name: inquiries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inquiries_id_seq', 17, true);


--
-- Name: news_posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.news_posts_id_seq', 31, true);


--
-- Name: partners_display_order_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.partners_display_order_seq', 12, true);


--
-- Name: partners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.partners_id_seq', 12, true);


--
-- Name: regional_esg_issues_display_order_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.regional_esg_issues_display_order_seq', 109, true);


--
-- Name: regional_esg_issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.regional_esg_issues_id_seq', 114, true);


--
-- Name: related_sites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.related_sites_id_seq', 12, true);


--
-- Name: scoring_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.scoring_rules_id_seq', 151, true);


--
-- Name: simulator_parameters_display_order_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.simulator_parameters_display_order_seq', 21, true);


--
-- Name: simulator_parameters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.simulator_parameters_id_seq', 21, true);


--
-- Name: site_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.site_content_id_seq', 2, true);


--
-- Name: strategy_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.strategy_rules_id_seq', 10, true);


--
-- Name: survey_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.survey_questions_id_seq', 54, true);


--
-- Name: user_applications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_applications_id_seq', 28, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 12, true);


--
-- Name: average_to_answer_rules average_to_answer_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.average_to_answer_rules
    ADD CONSTRAINT average_to_answer_rules_pkey PRIMARY KEY (id);


--
-- Name: benchmark_scoring_rules benchmark_scoring_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.benchmark_scoring_rules
    ADD CONSTRAINT benchmark_scoring_rules_pkey PRIMARY KEY (id);


--
-- Name: company_size_esg_issues company_size_esg_issues_company_size_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_size_esg_issues
    ADD CONSTRAINT company_size_esg_issues_company_size_key UNIQUE (company_size);


--
-- Name: company_size_esg_issues company_size_esg_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.company_size_esg_issues
    ADD CONSTRAINT company_size_esg_issues_pkey PRIMARY KEY (id);


--
-- Name: diagnoses diagnoses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnoses
    ADD CONSTRAINT diagnoses_pkey PRIMARY KEY (id);


--
-- Name: diagnosis_answers diagnosis_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnosis_answers
    ADD CONSTRAINT diagnosis_answers_pkey PRIMARY KEY (id);


--
-- Name: esg_programs esg_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.esg_programs
    ADD CONSTRAINT esg_programs_pkey PRIMARY KEY (id);


--
-- Name: esg_programs esg_programs_program_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.esg_programs
    ADD CONSTRAINT esg_programs_program_code_key UNIQUE (program_code);


--
-- Name: industries industries_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industries
    ADD CONSTRAINT industries_code_key UNIQUE (code);


--
-- Name: industries industries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industries
    ADD CONSTRAINT industries_pkey PRIMARY KEY (id);


--
-- Name: industry_averages industry_averages_industry_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_averages
    ADD CONSTRAINT industry_averages_industry_code_key UNIQUE (industry_code);


--
-- Name: industry_averages industry_averages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_averages
    ADD CONSTRAINT industry_averages_pkey PRIMARY KEY (id);


--
-- Name: industry_benchmark_scores industry_benchmark_scores_industry_code_question_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_benchmark_scores
    ADD CONSTRAINT industry_benchmark_scores_industry_code_question_code_key UNIQUE (industry_code, question_code);


--
-- Name: industry_benchmark_scores industry_benchmark_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_benchmark_scores
    ADD CONSTRAINT industry_benchmark_scores_pkey PRIMARY KEY (id);


--
-- Name: industry_esg_issues industry_esg_issues_industry_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_esg_issues
    ADD CONSTRAINT industry_esg_issues_industry_code_key UNIQUE (industry_code);


--
-- Name: industry_esg_issues industry_esg_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_esg_issues
    ADD CONSTRAINT industry_esg_issues_pkey PRIMARY KEY (id);


--
-- Name: inquiries inquiries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inquiries
    ADD CONSTRAINT inquiries_pkey PRIMARY KEY (id);


--
-- Name: news_posts news_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.news_posts
    ADD CONSTRAINT news_posts_pkey PRIMARY KEY (id);


--
-- Name: partners partners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.partners
    ADD CONSTRAINT partners_pkey PRIMARY KEY (id);


--
-- Name: regional_esg_issues regional_esg_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regional_esg_issues
    ADD CONSTRAINT regional_esg_issues_pkey PRIMARY KEY (id);


--
-- Name: related_sites related_sites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.related_sites
    ADD CONSTRAINT related_sites_pkey PRIMARY KEY (id);


--
-- Name: scoring_rules scoring_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scoring_rules
    ADD CONSTRAINT scoring_rules_pkey PRIMARY KEY (id);


--
-- Name: simulator_parameters simulator_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.simulator_parameters
    ADD CONSTRAINT simulator_parameters_pkey PRIMARY KEY (id);


--
-- Name: site_content site_content_content_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_content
    ADD CONSTRAINT site_content_content_key_key UNIQUE (content_key);


--
-- Name: site_content site_content_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_content
    ADD CONSTRAINT site_content_pkey PRIMARY KEY (id);


--
-- Name: strategy_rules strategy_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.strategy_rules
    ADD CONSTRAINT strategy_rules_pkey PRIMARY KEY (id);


--
-- Name: survey_questions survey_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.survey_questions
    ADD CONSTRAINT survey_questions_pkey PRIMARY KEY (id);


--
-- Name: survey_questions survey_questions_question_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.survey_questions
    ADD CONSTRAINT survey_questions_question_code_key UNIQUE (question_code);


--
-- Name: user_applications user_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_applications
    ADD CONSTRAINT user_applications_pkey PRIMARY KEY (id);


--
-- Name: user_applications user_applications_user_id_program_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_applications
    ADD CONSTRAINT user_applications_user_id_program_id_key UNIQUE (user_id, program_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_diagnoses_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_diagnoses_user_id ON public.diagnoses USING btree (user_id);


--
-- Name: idx_diagnosis_answers_diagnosis_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_diagnosis_answers_diagnosis_id ON public.diagnosis_answers USING btree (diagnosis_id);


--
-- Name: diagnoses diagnoses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnoses
    ADD CONSTRAINT diagnoses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: diagnosis_answers diagnosis_answers_diagnosis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnosis_answers
    ADD CONSTRAINT diagnosis_answers_diagnosis_id_fkey FOREIGN KEY (diagnosis_id) REFERENCES public.diagnoses(id) ON DELETE CASCADE;


--
-- Name: industry_benchmark_scores industry_benchmark_scores_industry_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_benchmark_scores
    ADD CONSTRAINT industry_benchmark_scores_industry_code_fkey FOREIGN KEY (industry_code) REFERENCES public.industries(code);


--
-- Name: industry_esg_issues industry_esg_issues_industry_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.industry_esg_issues
    ADD CONSTRAINT industry_esg_issues_industry_code_fkey FOREIGN KEY (industry_code) REFERENCES public.industries(code);


--
-- Name: inquiries inquiries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inquiries
    ADD CONSTRAINT inquiries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: news_posts news_posts_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.news_posts
    ADD CONSTRAINT news_posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: strategy_rules strategy_rules_recommended_program_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.strategy_rules
    ADD CONSTRAINT strategy_rules_recommended_program_code_fkey FOREIGN KEY (recommended_program_code) REFERENCES public.esg_programs(program_code);


--
-- Name: user_applications user_applications_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_applications
    ADD CONSTRAINT user_applications_program_id_fkey FOREIGN KEY (program_id) REFERENCES public.esg_programs(id) ON DELETE CASCADE;


--
-- Name: user_applications user_applications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_applications
    ADD CONSTRAINT user_applications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

