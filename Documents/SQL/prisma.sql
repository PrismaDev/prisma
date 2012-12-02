--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.5
-- Dumped by pg_dump version 9.1.5
-- Started on 2012-12-01 21:44:40 BRST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 187 (class 3079 OID 11646)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2065 (class 0 OID 0)
-- Dependencies: 187
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 202 (class 1255 OID 36122)
-- Dependencies: 6
-- Name: AlunoDisciplinaApto(character varying, character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoDisciplinaApto"(character varying, character varying) RETURNS boolean
    LANGUAGE sql
    AS $_$
	SELECT NOT "DisciplinaTemPreRequisito"($2) OR EXISTS
	(
		SELECT 1
		FROM "PreRequisitoGrupo" prg, "Aluno" a
		WHERE 	prg."FK_Disciplina" = $2 AND
			a."FK_Matricula" = $1 AND
			a."CoeficienteRendimento" >= prg."CreditosMinimos" AND
			(
				SELECT COUNT(*)
				FROM "PreRequisitoGrupoDisciplina" prgd 
				LEFT JOIN "AlunoDisciplina" ad
				ON ad."FK_Aluno" = a."FK_Matricula" AND prgd."FK_Disciplina" = ad."FK_Disciplina" AND ad."FK_Status" = 'CP'
				WHERE 	prgd."FK_PreRequisitoGrupo" = prg."PK_PreRequisitoGrupo" AND
					ad."FK_Disciplina" IS NULL
			) = 0
	)
$_$;


ALTER FUNCTION public."AlunoDisciplinaApto"(character varying, character varying) OWNER TO prisma;

--
-- TOC entry 199 (class 1255 OID 36120)
-- Dependencies: 6
-- Name: AlunoOptativaCursada(character varying, character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoOptativaCursada"(character varying, character varying) RETURNS boolean
    LANGUAGE sql
    AS $_$
	SELECT EXISTS
	(
		SELECT 1 FROM "OptativaAluno" oa, "Optativa" o, "OptativaDisciplina" od, "AlunoDisciplina" ad
		WHERE 	oa."FK_Aluno" = $1 AND
			o."PK_Codigo" = $2 AND
			oa."FK_Optativa" = o."PK_Codigo" AND
			o."PK_Codigo" = od."FK_Optativa" AND
			ad."FK_Disciplina" = od."FK_Disciplina" AND
			ad."FK_Status" = 'CP'
	)
$_$;


ALTER FUNCTION public."AlunoOptativaCursada"(character varying, character varying) OWNER TO prisma;

--
-- TOC entry 200 (class 1255 OID 36121)
-- Dependencies: 6
-- Name: DisciplinaTemPreRequisito(character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "DisciplinaTemPreRequisito"(character varying) RETURNS boolean
    LANGUAGE sql
    AS $_$
	SELECT EXISTS
	(
		SELECT 1 FROM "PreRequisitoGrupo" prg WHERE prg."FK_Disciplina" = $1
	)
$_$;


ALTER FUNCTION public."DisciplinaTemPreRequisito"(character varying) OWNER TO prisma;

--
-- TOC entry 201 (class 1255 OID 36124)
-- Dependencies: 6
-- Name: LimpaBanco(); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "LimpaBanco"() RETURNS void
    LANGUAGE sql
    AS $$
	DELETE FROM "Usuario";
	DELETE FROM "Professor";
	DELETE FROM "Disciplina";
	DELETE FROM "Curso";
$$;


ALTER FUNCTION public."LimpaBanco"() OWNER TO prisma;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 162 (class 1259 OID 35695)
-- Dependencies: 6
-- Name: Aluno; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Aluno" (
    "FK_Matricula" character varying(10) NOT NULL,
    "CoeficienteRendimento" integer,
    "FK_Curso" character varying(3) NOT NULL
);


ALTER TABLE public."Aluno" OWNER TO prisma;

--
-- TOC entry 172 (class 1259 OID 35901)
-- Dependencies: 1963 6
-- Name: AlunoDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "AlunoDisciplina" (
    "FK_Aluno" character varying(20) NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL,
    "FK_Status" character varying(2),
    "Tentativas" integer DEFAULT 0
);


ALTER TABLE public."AlunoDisciplina" OWNER TO prisma;

--
-- TOC entry 184 (class 1259 OID 36115)
-- Dependencies: 1949 6
-- Name: AlunoDisciplinaApto; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "AlunoDisciplinaApto" AS
    SELECT ad."FK_Aluno" AS "Aluno", ad."FK_Disciplina" AS "Disciplina", "AlunoDisciplinaApto"(ad."FK_Aluno", ad."FK_Disciplina") AS "Apto" FROM "AlunoDisciplina" ad;


ALTER TABLE public."AlunoDisciplinaApto" OWNER TO prisma;

--
-- TOC entry 173 (class 1259 OID 35917)
-- Dependencies: 6
-- Name: AlunoDisciplinaStatus; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "AlunoDisciplinaStatus" (
    "PK_Status" character varying(2) NOT NULL,
    "Nome" character varying(20) NOT NULL
);


ALTER TABLE public."AlunoDisciplinaStatus" OWNER TO prisma;

--
-- TOC entry 177 (class 1259 OID 36001)
-- Dependencies: 6
-- Name: AlunoTurmaSelecionada; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "AlunoTurmaSelecionada" (
    "FK_Aluno" character varying(20) NOT NULL,
    "FK_Turma" bigint NOT NULL,
    "Opcao" integer NOT NULL,
    "NoLinha" integer NOT NULL
);


ALTER TABLE public."AlunoTurmaSelecionada" OWNER TO prisma;

--
-- TOC entry 169 (class 1259 OID 35870)
-- Dependencies: 6
-- Name: seq_sugestao; Type: SEQUENCE; Schema: public; Owner: prisma
--

CREATE SEQUENCE seq_sugestao
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_sugestao OWNER TO prisma;

--
-- TOC entry 2066 (class 0 OID 0)
-- Dependencies: 169
-- Name: seq_sugestao; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_sugestao', 1, false);


--
-- TOC entry 164 (class 1259 OID 35718)
-- Dependencies: 1956 1957 6
-- Name: Comentario; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Comentario" (
    "PK_Sugestao" bigint DEFAULT nextval('seq_sugestao'::regclass) NOT NULL,
    "FK_Usuario" character varying(20) NOT NULL,
    "Comentario" text NOT NULL,
    "DataHora" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public."Comentario" OWNER TO prisma;

--
-- TOC entry 185 (class 1259 OID 36142)
-- Dependencies: 6
-- Name: Curso; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Curso" (
    "PK_Curso" character varying(3) NOT NULL,
    "Nome" character varying(50) NOT NULL
);


ALTER TABLE public."Curso" OWNER TO prisma;

--
-- TOC entry 171 (class 1259 OID 35893)
-- Dependencies: 6
-- Name: Disciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Disciplina" (
    "PK_Codigo" character varying(7) NOT NULL,
    "Nome" character varying(100) NOT NULL,
    "Creditos" integer
);


ALTER TABLE public."Disciplina" OWNER TO prisma;

--
-- TOC entry 166 (class 1259 OID 35775)
-- Dependencies: 6
-- Name: seq_log; Type: SEQUENCE; Schema: public; Owner: prisma
--

CREATE SEQUENCE seq_log
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_log OWNER TO prisma;

--
-- TOC entry 2067 (class 0 OID 0)
-- Dependencies: 166
-- Name: seq_log; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_log', 1, true);


--
-- TOC entry 165 (class 1259 OID 35758)
-- Dependencies: 1958 1959 1960 6
-- Name: Log; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Log" (
    "PK_Log" bigint DEFAULT nextval('seq_log'::regclass) NOT NULL,
    "DataHora" timestamp with time zone DEFAULT now() NOT NULL,
    "IP" character varying(40),
    "URI" character varying(100),
    "HashSessao" character varying(40),
    "Erro" boolean DEFAULT false NOT NULL,
    "Notas" text,
    "FK_Usuario" character varying(20) NOT NULL
);


ALTER TABLE public."Log" OWNER TO prisma;

--
-- TOC entry 168 (class 1259 OID 35868)
-- Dependencies: 6
-- Name: seq_professor; Type: SEQUENCE; Schema: public; Owner: prisma
--

CREATE SEQUENCE seq_professor
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_professor OWNER TO prisma;

--
-- TOC entry 2068 (class 0 OID 0)
-- Dependencies: 168
-- Name: seq_professor; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_professor', 1195, true);


--
-- TOC entry 167 (class 1259 OID 35818)
-- Dependencies: 1961 6
-- Name: Professor; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Professor" (
    "PK_Professor" bigint DEFAULT nextval('seq_professor'::regclass) NOT NULL,
    "Nome" character varying(100) NOT NULL
);


ALTER TABLE public."Professor" OWNER TO prisma;

--
-- TOC entry 175 (class 1259 OID 35984)
-- Dependencies: 6
-- Name: seq_turma; Type: SEQUENCE; Schema: public; Owner: prisma
--

CREATE SEQUENCE seq_turma
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_turma OWNER TO prisma;

--
-- TOC entry 2069 (class 0 OID 0)
-- Dependencies: 175
-- Name: seq_turma; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_turma', 1, true);


--
-- TOC entry 176 (class 1259 OID 35986)
-- Dependencies: 1964 1965 1966 1967 6
-- Name: Turma; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Turma" (
    "PK_Turma" bigint DEFAULT nextval('seq_turma'::regclass) NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL,
    "Codigo" character varying(10) NOT NULL,
    "PeriodoAno" integer NOT NULL,
    "Vagas" integer DEFAULT 0 NOT NULL,
    "Destino" character varying(3),
    "HorasDistancia" integer DEFAULT 0 NOT NULL,
    "SHF" integer DEFAULT 0 NOT NULL,
    "FK_Professor" bigint NOT NULL
);


ALTER TABLE public."Turma" OWNER TO prisma;

--
-- TOC entry 178 (class 1259 OID 36018)
-- Dependencies: 6
-- Name: TurmaHorario; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TurmaHorario" (
    "FK_Turma" bigint NOT NULL,
    "DiaSemana" integer NOT NULL,
    "HoraInicial" integer NOT NULL,
    "HoraFinal" integer NOT NULL
);


ALTER TABLE public."TurmaHorario" OWNER TO prisma;

--
-- TOC entry 186 (class 1259 OID 36223)
-- Dependencies: 1953 6
-- Name: MicroHorario; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "MicroHorario" AS
    SELECT d."PK_Codigo" AS "Disciplina", d."Nome" AS "Nome da Disciplina", p."Nome" AS "Professor", d."Creditos", t."Codigo" AS "Turma", t."Destino", t."Vagas", th."DiaSemana", th."HoraInicial", th."HoraFinal", t."HorasDistancia" AS "Horas a Distancia", t."SHF" FROM "Disciplina" d, "Turma" t, "Professor" p, "TurmaHorario" th WHERE ((((t."FK_Disciplina")::text = (d."PK_Codigo")::text) AND (p."PK_Professor" = t."FK_Professor")) AND (th."FK_Turma" = t."PK_Turma"));


ALTER TABLE public."MicroHorario" OWNER TO prisma;

--
-- TOC entry 174 (class 1259 OID 35939)
-- Dependencies: 6
-- Name: Optativa; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Optativa" (
    "PK_Codigo" character varying(7) NOT NULL,
    "Nome" character varying(100) NOT NULL
);


ALTER TABLE public."Optativa" OWNER TO prisma;

--
-- TOC entry 179 (class 1259 OID 36043)
-- Dependencies: 6
-- Name: OptativaAluno; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "OptativaAluno" (
    "FK_Optativa" character varying(7) NOT NULL,
    "FK_Aluno" character varying(20) NOT NULL
);


ALTER TABLE public."OptativaAluno" OWNER TO prisma;

--
-- TOC entry 180 (class 1259 OID 36058)
-- Dependencies: 6
-- Name: OptativaDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "OptativaDisciplina" (
    "FK_Optativa" character varying(7) NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."OptativaDisciplina" OWNER TO prisma;

--
-- TOC entry 181 (class 1259 OID 36073)
-- Dependencies: 6
-- Name: seq_prerequisito; Type: SEQUENCE; Schema: public; Owner: prisma
--

CREATE SEQUENCE seq_prerequisito
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_prerequisito OWNER TO prisma;

--
-- TOC entry 2070 (class 0 OID 0)
-- Dependencies: 181
-- Name: seq_prerequisito; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_prerequisito', 1, false);


--
-- TOC entry 182 (class 1259 OID 36075)
-- Dependencies: 1968 1969 6
-- Name: PreRequisitoGrupo; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "PreRequisitoGrupo" (
    "PK_PreRequisitoGrupo" bigint DEFAULT nextval('seq_prerequisito'::regclass) NOT NULL,
    "CreditosMinimos" integer DEFAULT 0 NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."PreRequisitoGrupo" OWNER TO prisma;

--
-- TOC entry 183 (class 1259 OID 36082)
-- Dependencies: 6
-- Name: PreRequisitoGrupoDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "PreRequisitoGrupoDisciplina" (
    "FK_PreRequisitoGrupo" bigint NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."PreRequisitoGrupoDisciplina" OWNER TO prisma;

--
-- TOC entry 163 (class 1259 OID 35708)
-- Dependencies: 6
-- Name: TipoUsuario; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TipoUsuario" (
    "PK_TipoUsuario" integer NOT NULL,
    "Nome" character varying(20) NOT NULL
);


ALTER TABLE public."TipoUsuario" OWNER TO prisma;

--
-- TOC entry 161 (class 1259 OID 35689)
-- Dependencies: 1955 6
-- Name: Usuario; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Usuario" (
    "PK_Login" character varying(20) NOT NULL,
    "Senha" character varying(40) NOT NULL,
    "Nome" character varying(100),
    "HashSessao" character varying(40),
    "TermoAceito" boolean DEFAULT false NOT NULL,
    "FK_TipoUsuario" integer NOT NULL
);


ALTER TABLE public."Usuario" OWNER TO prisma;

--
-- TOC entry 170 (class 1259 OID 35879)
-- Dependencies: 1962 6
-- Name: VariavelAmbiente; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "VariavelAmbiente" (
    "PK_Variavel" character varying(30) NOT NULL,
    "Habilitada" boolean DEFAULT true NOT NULL,
    "Descricao" text
);


ALTER TABLE public."VariavelAmbiente" OWNER TO prisma;

--
-- TOC entry 2042 (class 0 OID 35695)
-- Dependencies: 162 2060
-- Data for Name: Aluno; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2049 (class 0 OID 35901)
-- Dependencies: 172 2060
-- Data for Name: AlunoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2050 (class 0 OID 35917)
-- Dependencies: 173 2060
-- Data for Name: AlunoDisciplinaStatus; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "AlunoDisciplinaStatus" VALUES ('CP', 'Cumpriu');
INSERT INTO "AlunoDisciplinaStatus" VALUES ('NC', 'Não cumpriu');
INSERT INTO "AlunoDisciplinaStatus" VALUES ('EA', 'Em andamento');


--
-- TOC entry 2053 (class 0 OID 36001)
-- Dependencies: 177 2060
-- Data for Name: AlunoTurmaSelecionada; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2044 (class 0 OID 35718)
-- Dependencies: 164 2060
-- Data for Name: Comentario; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2059 (class 0 OID 36142)
-- Dependencies: 185 2060
-- Data for Name: Curso; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "Curso" VALUES ('ADM', 'ADMINISTRACAO');
INSERT INTO "Curso" VALUES ('ARQ', 'ARQUITETURA E URBANISMO');
INSERT INTO "Curso" VALUES ('ACN', 'ARTES CENICAS');
INSERT INTO "Curso" VALUES ('CCP', 'CIENCIA DA COMPUTACAO');
INSERT INTO "Curso" VALUES ('BIO', 'CIENCIAS BIOLOGICAS');
INSERT INTO "Curso" VALUES ('CEC', 'CIENCIAS ECONOMICAS');
INSERT INTO "Curso" VALUES ('CSC', 'CIENCIAS SOCIAIS');
INSERT INTO "Curso" VALUES ('CPF', 'COMPLEMENTACAO PEDAGOGICA - FRANCES');
INSERT INTO "Curso" VALUES ('CPI', 'COMPLEMENTACAO PEDAGOGICA - INGLES');
INSERT INTO "Curso" VALUES ('CCM', 'COMUNICACAO SOCIAL');
INSERT INTO "Curso" VALUES ('HED', 'CURSO DE HISTORIA A DISTANCIA');
INSERT INTO "Curso" VALUES ('CDI', 'DESENHO INDUSTRIAL');
INSERT INTO "Curso" VALUES ('CDD', 'DIREITO DIURNO');
INSERT INTO "Curso" VALUES ('CDN', 'DIREITO NOTURNO');
INSERT INTO "Curso" VALUES ('ADI', 'DOMINIO ADICIONAL');
INSERT INTO "Curso" VALUES ('CEM', 'EMPREENDEDORISMO');
INSERT INTO "Curso" VALUES ('CEG', 'ENGENHARIA');
INSERT INTO "Curso" VALUES ('CFL', 'FILOSOFIA');
INSERT INTO "Curso" VALUES ('CFE', 'FILOSOFIA (FACULDADE ECLESIASTICA)');
INSERT INTO "Curso" VALUES ('CFS', 'FISICA');
INSERT INTO "Curso" VALUES ('CGG', 'GEOGRAFIA');
INSERT INTO "Curso" VALUES ('CHS', 'HISTORIA');
INSERT INTO "Curso" VALUES ('CIF', 'INFORMATICA');
INSERT INTO "Curso" VALUES ('CIC', 'INTERPRETACAO DE CONFERENCIAS');
INSERT INTO "Curso" VALUES ('CLT', 'LETRAS');
INSERT INTO "Curso" VALUES ('CMM', 'MATEMATICA');
INSERT INTO "Curso" VALUES ('CPD', 'PEDAGOGIA');
INSERT INTO "Curso" VALUES ('CPS', 'PSICOLOGIA');
INSERT INTO "Curso" VALUES ('CQM', 'QUIMICA');
INSERT INTO "Curso" VALUES ('CQI', 'QUIMICA INDUSTRIAL');
INSERT INTO "Curso" VALUES ('RIT', 'RELACOES INTERNACIONAIS');
INSERT INTO "Curso" VALUES ('CSS', 'SERVICO SOCIAL');
INSERT INTO "Curso" VALUES ('CSI', 'SISTEMAS DE INFORMACAO');
INSERT INTO "Curso" VALUES ('CSO', 'SOCIOLOGIA E POLITICA');
INSERT INTO "Curso" VALUES ('TPD', 'TECNOLOGO EM PROCESSAMENTO DE DADOS');
INSERT INTO "Curso" VALUES ('CTL', 'TEOLOGIA');


--
-- TOC entry 2048 (class 0 OID 35893)
-- Dependencies: 171 2060
-- Data for Name: Disciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2045 (class 0 OID 35758)
-- Dependencies: 165 2060
-- Data for Name: Log; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2051 (class 0 OID 35939)
-- Dependencies: 174 2060
-- Data for Name: Optativa; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2055 (class 0 OID 36043)
-- Dependencies: 179 2060
-- Data for Name: OptativaAluno; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2056 (class 0 OID 36058)
-- Dependencies: 180 2060
-- Data for Name: OptativaDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2057 (class 0 OID 36075)
-- Dependencies: 182 2060
-- Data for Name: PreRequisitoGrupo; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2058 (class 0 OID 36082)
-- Dependencies: 183 2060
-- Data for Name: PreRequisitoGrupoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2046 (class 0 OID 35818)
-- Dependencies: 167 2060
-- Data for Name: Professor; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "Professor" VALUES (2, 'ADRIANA FERREIRA BONFATTI');
INSERT INTO "Professor" VALUES (3, 'ALESSANDRA VANNUCCI');
INSERT INTO "Professor" VALUES (4, 'VITOR MANUEL CARNEIRO LEMOS');
INSERT INTO "Professor" VALUES (5, 'CELIO ROBERTO LIMA RENTROIA');
INSERT INTO "Professor" VALUES (6, 'RICARDO NOLLA RUIZ');
INSERT INTO "Professor" VALUES (7, 'ANDREA CHERMAN');
INSERT INTO "Professor" VALUES (8, 'CLAUDIA DUARTE SOARES');
INSERT INTO "Professor" VALUES (9, 'PATRICIA ITALA FERREIRA');
INSERT INTO "Professor" VALUES (10, 'JOAO RENATO DE SOUZA COELHO BENAZZI');
INSERT INTO "Professor" VALUES (11, 'LYGIA ALESSANDRA MAGALHAES MAGACHO');
INSERT INTO "Professor" VALUES (12, 'MILA DESOUZART DE AQUINO VIANA');
INSERT INTO "Professor" VALUES (13, 'MARCIO PEZZELLA FERREIRA');
INSERT INTO "Professor" VALUES (14, 'ANDRE LUIZ ROIZMAN');
INSERT INTO "Professor" VALUES (15, 'FRANCIS BERENGER MACHADO');
INSERT INTO "Professor" VALUES (16, 'FLAVIA DE SOUZA COSTA N CAVAZOTTE');
INSERT INTO "Professor" VALUES (17, 'ISAO NISHIOKA');
INSERT INTO "Professor" VALUES (18, 'JORGE MANOEL TEIXEIRA CARNEIRO');
INSERT INTO "Professor" VALUES (19, 'MARCOS LOPEZ REGO');
INSERT INTO "Professor" VALUES (20, 'PAULO CESAR TEIXEIRA');
INSERT INTO "Professor" VALUES (21, 'SANDRA REGINA DA ROCHA PINTO');
INSERT INTO "Professor" VALUES (22, 'COORDENADOR DE CURSO');
INSERT INTO "Professor" VALUES (23, 'ALESSANDRA BAIOCCHI ANTUNES CORREA');
INSERT INTO "Professor" VALUES (24, 'ANDRE LACOMBE PENNA DA ROCHA');
INSERT INTO "Professor" VALUES (25, 'DANIEL KAMLOT');
INSERT INTO "Professor" VALUES (26, 'DANILO ROGERIO ARRUDA');
INSERT INTO "Professor" VALUES (27, 'LUIZ PAULO MOREIRA LIMA');
INSERT INTO "Professor" VALUES (28, 'MARCELA COHEN MARTELOTTE');
INSERT INTO "Professor" VALUES (29, 'MARCUS WILCOX HEMAIS');
INSERT INTO "Professor" VALUES (30, 'PAULA CRISTINA DA CUNHA GOMES');
INSERT INTO "Professor" VALUES (31, 'PAULO CESAR DE MENDONCA MOTTA');
INSERT INTO "Professor" VALUES (32, 'RENATA CELI MOREIRA DA SILVA');
INSERT INTO "Professor" VALUES (33, 'ANDRE CABUS KLOTZLE');
INSERT INTO "Professor" VALUES (34, 'ANTONIO CARLOS FIGUEIREDO PINTO');
INSERT INTO "Professor" VALUES (35, 'GUSTAVO SILVA ARAUJO');
INSERT INTO "Professor" VALUES (36, 'JOSE CORREIA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (37, 'LEONARDO LIMA GOMES');
INSERT INTO "Professor" VALUES (38, 'LIANA RIBEIRO DOS SANTOS');
INSERT INTO "Professor" VALUES (39, 'LUIZ EDUARDO TEIXEIRA BRANDAO');
INSERT INTO "Professor" VALUES (40, 'MARCELO CABUS KLOTZLE');
INSERT INTO "Professor" VALUES (41, 'ALESSANDRA DE SA MELLO DA COSTA');
INSERT INTO "Professor" VALUES (42, 'ANA HELOISA DA COSTA LEMOS');
INSERT INTO "Professor" VALUES (43, 'ANDREA GOMES BITTENCOURT');
INSERT INTO "Professor" VALUES (44, 'EDMUNDO EUTROPIO COELHO DE SOUZA');
INSERT INTO "Professor" VALUES (45, 'FERNANDO CARLOS RODRIGUES CORTEZI');
INSERT INTO "Professor" VALUES (46, 'ANNA MARIA SOTERO DA SILVA NETO');
INSERT INTO "Professor" VALUES (47, 'EVANDRO DA SILVEIRA GOULART');
INSERT INTO "Professor" VALUES (48, 'ROBERTO VELASCO KOPP JUNIOR');
INSERT INTO "Professor" VALUES (49, 'SHEILA DE BARCELLOS MAIA JORDAO');
INSERT INTO "Professor" VALUES (50, 'ROBERTO GIL UCHOA B DE CARVALHO');
INSERT INTO "Professor" VALUES (51, 'VERANISE JACUBOWSKI CORREIA DUBEUX');
INSERT INTO "Professor" VALUES (52, 'SANDER FURTADO DE MENDONCA');
INSERT INTO "Professor" VALUES (53, 'LEA MARA BENATTI ASSAID');
INSERT INTO "Professor" VALUES (54, 'ULISSES FELIPE CAMARDELLA');
INSERT INTO "Professor" VALUES (55, 'MARCELA MELO AMORIM');
INSERT INTO "Professor" VALUES (56, 'MARIO DOMINGUES DE PAULA SIMOES');
INSERT INTO "Professor" VALUES (57, 'RAPHAEL BRAGA DA SILVA');
INSERT INTO "Professor" VALUES (58, 'ANDRE LUIZ CARVALHAL DA SILVA');
INSERT INTO "Professor" VALUES (59, 'LUIS ALEXANDRE GRUBITS DE P PESSOA');
INSERT INTO "Professor" VALUES (60, 'JOSE ROBERTO POTSCH DE C E SILVA');
INSERT INTO "Professor" VALUES (61, 'JORGE BRANTES FERREIRA');
INSERT INTO "Professor" VALUES (62, 'GLACIR DE OLIVEIRA G ZAPATA');
INSERT INTO "Professor" VALUES (63, 'MARCELO GHIARONI DE A E SILVA');
INSERT INTO "Professor" VALUES (64, 'PATRICIA AMELIA TOMEI');
INSERT INTO "Professor" VALUES (65, 'MARIA CRISTINA ASSUMPCAO CARNEIRO');
INSERT INTO "Professor" VALUES (66, 'MARCELO FERNANDEZ PINEIRO');
INSERT INTO "Professor" VALUES (67, 'JORGE LUIZ CORDEIRO PAULO');
INSERT INTO "Professor" VALUES (68, 'MARCO AURELIO DE SA RIBEIRO');
INSERT INTO "Professor" VALUES (69, 'LUIS FELIPE SAO THIAGO DE CARVALHO');
INSERT INTO "Professor" VALUES (70, 'RUBEN JOSE BAUER NAVEIRA');
INSERT INTO "Professor" VALUES (71, 'PAULO MASSILLON DE FREITAS MARTINS');
INSERT INTO "Professor" VALUES (72, 'RENATA GEORGIA MOTTA KURTZ');
INSERT INTO "Professor" VALUES (73, 'GLADYS RAIMUNDA TRINDADE DE ARAUJO');
INSERT INTO "Professor" VALUES (74, 'JOAO PAULO VIEIRA TINOCO');
INSERT INTO "Professor" VALUES (75, 'DOURIVAL DE SOUZA CARVALHO JUNIOR');
INSERT INTO "Professor" VALUES (76, 'JORGE ALBERTO ZIETLOW DURO');
INSERT INTO "Professor" VALUES (77, 'MARCOS COHEN');
INSERT INTO "Professor" VALUES (78, 'RENATA MACHADO RIBEIRO NUNES');
INSERT INTO "Professor" VALUES (79, 'CIRO VALERIO TORRES DA SILVA');
INSERT INTO "Professor" VALUES (80, 'MARIA ANGELA CAMPELO DE MELO');
INSERT INTO "Professor" VALUES (81, 'TERESIA DIANA L VAN A DE M SOARES');
INSERT INTO "Professor" VALUES (82, 'ROGER JAMES VOLKEMA');
INSERT INTO "Professor" VALUES (83, 'JOSE TAVARES ARARUNA JUNIOR');
INSERT INTO "Professor" VALUES (84, 'ALDER CATUNDA TIMBO MUNIZ');
INSERT INTO "Professor" VALUES (85, 'ALFREDO LUIZ PORTO DE BRITTO');
INSERT INTO "Professor" VALUES (86, 'ANTONIO JOSE DE SENA BATISTA');
INSERT INTO "Professor" VALUES (87, 'ANA PAULA POLIZZO');
INSERT INTO "Professor" VALUES (88, 'AUGUSTO IVAN DE FREITAS PINHEIRO');
INSERT INTO "Professor" VALUES (89, 'MAIRA MACHADO MARTINS');
INSERT INTO "Professor" VALUES (90, 'HENRIQUE GASPAR BARANDIER');
INSERT INTO "Professor" VALUES (91, 'ANA LUIZA DE SOUZA NOBRE');
INSERT INTO "Professor" VALUES (92, 'JOAO MASAO KAMITA');
INSERT INTO "Professor" VALUES (93, 'WALTER DOS SANTOS TEIXEIRA FILHO');
INSERT INTO "Professor" VALUES (94, 'FERNANDO BETIM PAES LEME');
INSERT INTO "Professor" VALUES (95, 'FERNANDO MAURICIO ESPOSITO GALARCE');
INSERT INTO "Professor" VALUES (96, 'LEILA BEATRIZ DA SILVA SILVEIRA');
INSERT INTO "Professor" VALUES (97, 'RAUL ANDREW SIMOES CORREA SMITH');
INSERT INTO "Professor" VALUES (98, 'HERMANO BRAGA V DE FREITAS FILHO');
INSERT INTO "Professor" VALUES (99, 'MOEMA FALCI LOURES');
INSERT INTO "Professor" VALUES (100, 'ISRAEL FONSECA NUNES JUNIOR');
INSERT INTO "Professor" VALUES (101, 'MARCOS OSMAR FAVERO');
INSERT INTO "Professor" VALUES (102, 'CARLOS EDUARDO S DE VASCONCELLOS');
INSERT INTO "Professor" VALUES (103, 'PEDRO HENRIQUE EVORA ESTEVES AMARAL');
INSERT INTO "Professor" VALUES (104, 'NANDA ESKES');
INSERT INTO "Professor" VALUES (105, 'CLAUDIA MARIA PIMENTEL N DE MIRANDA');
INSERT INTO "Professor" VALUES (106, 'ANNIE GOLDBERG EPPINGHAUS');
INSERT INTO "Professor" VALUES (107, 'PEDRO LOBAO PEGURIER');
INSERT INTO "Professor" VALUES (108, 'VERA MAGIANO HAZAN');
INSERT INTO "Professor" VALUES (109, 'JOAO CARLOS LAUFER CALAFATE');
INSERT INTO "Professor" VALUES (110, 'ERNANI DE SOUZA FREIRE FILHO');
INSERT INTO "Professor" VALUES (111, 'CARLA JUACABA DE ALMEIDA');
INSERT INTO "Professor" VALUES (112, 'MARIA FERNANDA RODRIGUES C LEMOS');
INSERT INTO "Professor" VALUES (113, 'RODRIGO RINALDI DE MATTOS');
INSERT INTO "Professor" VALUES (114, 'LUIS CARLOS SOARES M DOMINGUES');
INSERT INTO "Professor" VALUES (115, 'RICARDO ESTEVES');
INSERT INTO "Professor" VALUES (116, 'LUCIANO ROSA ALONSO ALVARES');
INSERT INTO "Professor" VALUES (117, 'GABRIEL NOGUEIRA DUARTE');
INSERT INTO "Professor" VALUES (118, 'HORISTA A CONTRATAR');
INSERT INTO "Professor" VALUES (119, 'MARCELO ROBERTO V D DE M BEZERRA');
INSERT INTO "Professor" VALUES (120, 'MANUEL FIASCHI');
INSERT INTO "Professor" VALUES (121, 'PEDRO RIVERA MONTEIRO');
INSERT INTO "Professor" VALUES (122, 'CLAUDIA DE FREITAS ESCARLATE');
INSERT INTO "Professor" VALUES (123, 'PIERRE ANDRE ALEXANDRE H P MARTIN');
INSERT INTO "Professor" VALUES (124, 'JOAQUIM MARCAL FERREIRA DE ANDRADE');
INSERT INTO "Professor" VALUES (125, 'DELY SOARES BENTES');
INSERT INTO "Professor" VALUES (126, 'HILTON ESTEVES DE BERREDO');
INSERT INTO "Professor" VALUES (127, 'SILVIO DE MOURA DIAS');
INSERT INTO "Professor" VALUES (128, 'ADRIANO ANDRADE C DE MENDONCA');
INSERT INTO "Professor" VALUES (129, 'NATHALIA MUSSI WEIDLICH');
INSERT INTO "Professor" VALUES (130, 'DENISE CHINI SOLOT');
INSERT INTO "Professor" VALUES (131, 'EDUARDO ROCHA DE OLIVEIRA FILHO');
INSERT INTO "Professor" VALUES (132, 'LUIS CANDIDO GOMES DE CAMPOS');
INSERT INTO "Professor" VALUES (133, 'FERNANDO FERNANDES DE MELLO');
INSERT INTO "Professor" VALUES (134, 'LUCIA GOMES RIBEIRO');
INSERT INTO "Professor" VALUES (135, 'ALESSANDRA CARUSI MACHADO BEZERRA');
INSERT INTO "Professor" VALUES (136, 'RAUL BUENO ANDRADE SILVA');
INSERT INTO "Professor" VALUES (137, 'THIAGO LEITAO DE SOUZA');
INSERT INTO "Professor" VALUES (138, 'VERONICA GOMES NATIVIDADE');
INSERT INTO "Professor" VALUES (139, 'SUZANA VALLADARES FONSECA');
INSERT INTO "Professor" VALUES (140, 'AUGUSTO SEIBEL MACHADO');
INSERT INTO "Professor" VALUES (141, 'CARLOS ANDRE LAMEIRAO CORTES');
INSERT INTO "Professor" VALUES (142, 'MARCO ANTONIO MAGALHAES LIMA');
INSERT INTO "Professor" VALUES (143, 'SELMA DE SA RORIZ REIS');
INSERT INTO "Professor" VALUES (144, 'ROBERTO HENRIQUE G EPPINGHAUS');
INSERT INTO "Professor" VALUES (145, 'SHEILA DAIN');
INSERT INTO "Professor" VALUES (146, 'CRISTINA ADAM SALGADO GUIMARAES');
INSERT INTO "Professor" VALUES (147, 'EDUARDO BERLINER');
INSERT INTO "Professor" VALUES (148, 'SILVANA APARECIDA FERREIRA MARQUES');
INSERT INTO "Professor" VALUES (149, 'CARLOS EURICO POGGI DE ARAGAO JR');
INSERT INTO "Professor" VALUES (150, 'AMADOR DE CARVALHO PEREZ');
INSERT INTO "Professor" VALUES (151, 'RENATA VILANOVA LIMA');
INSERT INTO "Professor" VALUES (152, 'LUIZA MARIA INTERLENGHI');
INSERT INTO "Professor" VALUES (153, 'ALBERTO CIPINIUK');
INSERT INTO "Professor" VALUES (154, 'CRISTINA DA COSTA VIANA');
INSERT INTO "Professor" VALUES (155, 'THEREZA DE MIRANDA CARVALHO');
INSERT INTO "Professor" VALUES (156, 'MARIO GORDILHO FRAGA');
INSERT INTO "Professor" VALUES (157, 'PIEDADE EPSTEIN GRINBERG');
INSERT INTO "Professor" VALUES (158, 'AMALIA GIACOMINI');
INSERT INTO "Professor" VALUES (159, 'CECILIA MARTINS DE MELLO');
INSERT INTO "Professor" VALUES (160, 'RICARDO ARTUR PEREIRA CARVALHO');
INSERT INTO "Professor" VALUES (161, 'BARBARA JANE NECYK');
INSERT INTO "Professor" VALUES (162, 'ALFREDO LAUFER');
INSERT INTO "Professor" VALUES (163, 'ANA MARIA BRANCO NOGUEIRA DA SILVA');
INSERT INTO "Professor" VALUES (164, 'LUIS VICENTE BARROS CARDOSO DE MELO');
INSERT INTO "Professor" VALUES (165, 'IZABEL MARIA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (166, 'JAKELINE PRATA DE ASSIS PIRES');
INSERT INTO "Professor" VALUES (167, 'ALEXANDRE GABRIEL CHRISTO');
INSERT INTO "Professor" VALUES (168, 'ALEXANDRO SOLORZANO');
INSERT INTO "Professor" VALUES (169, 'JOSAFA CARLOS DE SIQUEIRA');
INSERT INTO "Professor" VALUES (170, 'HENRIQUE BASTOS RAJAO REIS');
INSERT INTO "Professor" VALUES (171, 'VITOR HUGO DOS SANTOS GOMES MAIA');
INSERT INTO "Professor" VALUES (172, 'MARIA FRANCO TRINDADE MEDEIROS');
INSERT INTO "Professor" VALUES (173, 'ROMULO BARROSO BAPTISTA');
INSERT INTO "Professor" VALUES (174, 'MICHELE DAL TOE CASAGRANDE');
INSERT INTO "Professor" VALUES (175, 'ELISA DOMINGUEZ SOTELINO');
INSERT INTO "Professor" VALUES (176, 'MARTA DE SOUZA LIMA VELASCO');
INSERT INTO "Professor" VALUES (177, 'GLAUCO JOSE DE OLIVEIRA RODRIGUES');
INSERT INTO "Professor" VALUES (178, 'ICLEA REYS DE ORTIZ');
INSERT INTO "Professor" VALUES (179, 'JUSTINO ARTUR FERRAZ VIEIRA');
INSERT INTO "Professor" VALUES (180, 'JORGE LUCAS FERREIRA');
INSERT INTO "Professor" VALUES (181, 'JAQUELINE PASSAMANI Z GUIMARAES');
INSERT INTO "Professor" VALUES (182, 'ANTONIO ROBERTO M B DE OLIVEIRA');
INSERT INTO "Professor" VALUES (183, 'BEN HUR DE ALBUQUERQUE E SILVA');
INSERT INTO "Professor" VALUES (184, 'DANIEL MESQUITA PEREIRA');
INSERT INTO "Professor" VALUES (185, 'GABRIEL CHAVARRY NEIVA');
INSERT INTO "Professor" VALUES (186, 'LUISA CHAVES DE MELO');
INSERT INTO "Professor" VALUES (187, 'CRISTINA MARIA MARTINS DE MATOS');
INSERT INTO "Professor" VALUES (188, 'MARILIA SOARES MARTINS');
INSERT INTO "Professor" VALUES (189, 'ANTONIO JORGE ALABY PINHEIRO');
INSERT INTO "Professor" VALUES (190, 'MARCIO NUNES DA SILVA');
INSERT INTO "Professor" VALUES (191, 'ROSANGELA NUNES DE ARAUJO');
INSERT INTO "Professor" VALUES (192, 'MARILENE PEREIRA LOPES');
INSERT INTO "Professor" VALUES (193, 'CASSIA MARIA CHAFFIN GUEDES PEREIRA');
INSERT INTO "Professor" VALUES (194, 'LEISE TAVEIRA DOS SANTOS');
INSERT INTO "Professor" VALUES (195, 'MARIZA TAVARES FIGUEIRA');
INSERT INTO "Professor" VALUES (196, 'PAULO CESAR DE ARAUJO');
INSERT INTO "Professor" VALUES (197, 'MIGUEL MEDEIROS FERREIRA GOMES');
INSERT INTO "Professor" VALUES (198, 'LIVIA FRANCA SALLES');
INSERT INTO "Professor" VALUES (199, 'ARTURO PISCIOTTI NETTO');
INSERT INTO "Professor" VALUES (200, 'ISRAEL TABAK');
INSERT INTO "Professor" VALUES (201, 'MADALENA RAMIREZ SAPUCAIA');
INSERT INTO "Professor" VALUES (202, 'LUIZ FRANCISCO FERREIRA LEO');
INSERT INTO "Professor" VALUES (203, 'DENISE COSTA LOPES');
INSERT INTO "Professor" VALUES (204, 'LEONEL AZEVEDO DE AGUIAR');
INSERT INTO "Professor" VALUES (205, 'ISABEL PARANHOS MONTEIRO');
INSERT INTO "Professor" VALUES (206, 'KATIA ANCORA DA LUZ');
INSERT INTO "Professor" VALUES (207, 'ARTHUR HENRIQUE MOTTA DAPIEVE');
INSERT INTO "Professor" VALUES (208, 'FERNANDO CAIUBY ARIANI FILHO');
INSERT INTO "Professor" VALUES (209, 'FERNANDO DE ALMEIDA SA');
INSERT INTO "Professor" VALUES (210, 'SILVIO TENDLER');
INSERT INTO "Professor" VALUES (211, 'SANDRA KORMAN DIB');
INSERT INTO "Professor" VALUES (212, 'CRESO DA CRUZ SOARES JUNIOR');
INSERT INTO "Professor" VALUES (213, 'ERNESTO CARNEIRO RODRIGUES');
INSERT INTO "Professor" VALUES (214, 'VERA ANGELA NOVELLO');
INSERT INTO "Professor" VALUES (215, 'LENIVALDO GOMES DE ALMEIDA');
INSERT INTO "Professor" VALUES (216, 'MARIA INES GURJAO');
INSERT INTO "Professor" VALUES (217, 'ROBERTO DE MAGALHAES VEIGA');
INSERT INTO "Professor" VALUES (218, 'AMERICA ADRIANA BENEDIKT');
INSERT INTO "Professor" VALUES (219, 'GUSTAVO CHATAIGNIER G DA COSTA');
INSERT INTO "Professor" VALUES (220, 'LILIANE RUTH HEYNEMANN');
INSERT INTO "Professor" VALUES (221, 'CARLA VIEIRA DE SIQUEIRA');
INSERT INTO "Professor" VALUES (222, 'GIOVANNA FERREIRA DEALTRY');
INSERT INTO "Professor" VALUES (223, 'SERGIO LUIZ RIBEIRO MOTA');
INSERT INTO "Professor" VALUES (224, 'VERA LUCIA FOLLAIN DE FIGUEIREDO');
INSERT INTO "Professor" VALUES (225, 'LEONARDO SCHLESINGER CAVALCANTI');
INSERT INTO "Professor" VALUES (226, 'CLARISSE FUKELMAN');
INSERT INTO "Professor" VALUES (227, 'ADRIANA ANDRADE BRAGA');
INSERT INTO "Professor" VALUES (228, 'ARTHUR CEZAR DE A ITUASSU FILHO');
INSERT INTO "Professor" VALUES (229, 'JOSE EUDES ARAUJO ALENCAR');
INSERT INTO "Professor" VALUES (230, 'ALUIZIO ALVES FILHO');
INSERT INTO "Professor" VALUES (231, 'ADAIR LEONARDO ROCHA');
INSERT INTO "Professor" VALUES (232, 'SERGIO LUIZ BONATO');
INSERT INTO "Professor" VALUES (233, 'ALESSANDRA SILVEIRA DA CRUZ');
INSERT INTO "Professor" VALUES (234, 'HERMES FREDERICO PINHO DE ARAUJO');
INSERT INTO "Professor" VALUES (235, 'CLAUDIA LILIA RABELO VERSIANI');
INSERT INTO "Professor" VALUES (236, 'CLAUDIO ROQUETTE BOJUNGA');
INSERT INTO "Professor" VALUES (237, 'FELIPE GOMBERG');
INSERT INTO "Professor" VALUES (238, 'JULIA FATIMA DE JESUS CRUZ');
INSERT INTO "Professor" VALUES (239, 'ANTONIO BERNARDO MARIANI GUERREIRO');
INSERT INTO "Professor" VALUES (240, 'JOAO LUIZ RENHA');
INSERT INTO "Professor" VALUES (241, 'LUIZ FERNANDO FAVILLA CARRILHO');
INSERT INTO "Professor" VALUES (242, 'PAULO CARVALHO DE AZEREDO FILHO');
INSERT INTO "Professor" VALUES (243, 'CLAUDIA DE ALCANTARA CHAVES');
INSERT INTO "Professor" VALUES (244, 'ANGELA MARIA DE REGO MONTEIRO');
INSERT INTO "Professor" VALUES (245, 'EDUARDO JOSE LOBAO PEGURIER');
INSERT INTO "Professor" VALUES (246, 'ROSAMARY ESQUENAZI');
INSERT INTO "Professor" VALUES (247, 'MARIA ISABEL MONTEIRO F BARRETO');
INSERT INTO "Professor" VALUES (248, 'MARIANA DE MORAES PALMEIRA');
INSERT INTO "Professor" VALUES (249, 'JOSE MARIANI DE SA CARVALHO');
INSERT INTO "Professor" VALUES (250, 'NEY COSTA SANTOS FILHO');
INSERT INTO "Professor" VALUES (251, 'RENATO SCHVARTZ');
INSERT INTO "Professor" VALUES (252, 'AFFONSO FERNANDES DE ARAUJO');
INSERT INTO "Professor" VALUES (253, 'DIOGO MADUELL VIEIRA');
INSERT INTO "Professor" VALUES (254, 'JOSE ANTONIO DE OLIVEIRA');
INSERT INTO "Professor" VALUES (255, 'LUIZ CARLOS CARDOSO');
INSERT INTO "Professor" VALUES (256, 'MARIANA LUZ EIRAS');
INSERT INTO "Professor" VALUES (257, 'ERNANI ALMEIDA FERRAZ');
INSERT INTO "Professor" VALUES (258, 'PATRICIA MAURICIO CARVALHO');
INSERT INTO "Professor" VALUES (259, 'RAFAEL DE CASTRO RUSAK');
INSERT INTO "Professor" VALUES (260, 'ALEXANDRE AUGUSTO FREIRE CARAUTA');
INSERT INTO "Professor" VALUES (261, 'LUCIANA AZEVEDO PEREIRA');
INSERT INTO "Professor" VALUES (262, 'WILSON LUIS BRANCO MARTINS');
INSERT INTO "Professor" VALUES (263, 'ERMELINDA RITA DE SAO THIAGO GENTIL');
INSERT INTO "Professor" VALUES (264, 'MARCELO KISCHINHEVSKY');
INSERT INTO "Professor" VALUES (265, 'MAURO JOSE DE SOUZA SILVEIRA');
INSERT INTO "Professor" VALUES (266, 'BRUNA SANT ANA AUCAR');
INSERT INTO "Professor" VALUES (267, 'CARMEM LUCIA BARRETO PETIT');
INSERT INTO "Professor" VALUES (268, 'BRUNO CHALOUB DIEGUEZ');
INSERT INTO "Professor" VALUES (269, 'LETICIA HEES ALVES');
INSERT INTO "Professor" VALUES (270, 'CARLOS NOBRE CRUZ');
INSERT INTO "Professor" VALUES (271, 'ADRIANA MEDEIROS FERREIRA DA SILVA');
INSERT INTO "Professor" VALUES (272, 'WEILER ALVES FINAMORE FILHO');
INSERT INTO "Professor" VALUES (273, 'PAULO RUBENS DA FONSECA');
INSERT INTO "Professor" VALUES (274, 'FRANCISCO OTAVIO ARCHILA DA COSTA');
INSERT INTO "Professor" VALUES (275, 'MARIA SUELY MONTEIRO CALDAS');
INSERT INTO "Professor" VALUES (276, 'LUCIANA ROCHA DE MAGALHAES BARROS');
INSERT INTO "Professor" VALUES (277, 'FLAVIA DE OLIVEIRA RUA A CIUCCI');
INSERT INTO "Professor" VALUES (278, 'RENATA MARIA CANTANHEDE AMARANTE');
INSERT INTO "Professor" VALUES (279, 'CELIO GOMES CAMPOS');
INSERT INTO "Professor" VALUES (280, 'JULIO DE ALMEIDA LUBIANCO');
INSERT INTO "Professor" VALUES (281, 'BERNARDO PORTUGAL SILVA RAPOSO');
INSERT INTO "Professor" VALUES (282, 'MARCIA ANTABI');
INSERT INTO "Professor" VALUES (283, 'CARLOS ROBERTO CERQUEIRA ALVES');
INSERT INTO "Professor" VALUES (284, 'ITALA MADUELL VIEIRA');
INSERT INTO "Professor" VALUES (285, 'CARLA RODRIGUES');
INSERT INTO "Professor" VALUES (286, 'LILIAN SABACK DE SA MORAES');
INSERT INTO "Professor" VALUES (287, 'SIDNEY NOLASCO DE REZENDE');
INSERT INTO "Professor" VALUES (288, 'LENIRA PEREIRA PINTO ALCURE');
INSERT INTO "Professor" VALUES (289, 'ROBERTO GOMES MADER GONCALVES');
INSERT INTO "Professor" VALUES (290, 'ANTONIO CARLOS GOMES DE MATTOS');
INSERT INTO "Professor" VALUES (291, 'HERNANI HEFFNER');
INSERT INTO "Professor" VALUES (292, 'LUCAS BENDER CARPENA DE M P GARCIA');
INSERT INTO "Professor" VALUES (293, 'MELANIE DIMANTAS');
INSERT INTO "Professor" VALUES (294, 'WALTER LIMA JUNIOR');
INSERT INTO "Professor" VALUES (295, 'MARCELO ROBERTO VELLOZO A AZEVEDO');
INSERT INTO "Professor" VALUES (296, 'CLELIA ELISA CABRAL BESSA');
INSERT INTO "Professor" VALUES (297, 'BERNARDO AUGUSTO DE REGO MONTEIRO');
INSERT INTO "Professor" VALUES (298, 'LIGIA AMORIM RIZZO');
INSERT INTO "Professor" VALUES (299, 'CLAUDIA BRUTT GUIMARAES');
INSERT INTO "Professor" VALUES (300, 'ALUIZIO ANTONIO PIRES');
INSERT INTO "Professor" VALUES (301, 'CLAUDIA DA SILVA PEREIRA');
INSERT INTO "Professor" VALUES (302, 'CANDIDA MARIA MONTEIRO R DA COSTA');
INSERT INTO "Professor" VALUES (303, 'ESTANISLAU BEZERRA FELIX');
INSERT INTO "Professor" VALUES (304, 'DANIEL ALVES DA COSTA VARGENS');
INSERT INTO "Professor" VALUES (305, 'BARBARA CASTELLO B R DE ASSUMPCAO');
INSERT INTO "Professor" VALUES (306, 'MARCOS LUIS BARBATO');
INSERT INTO "Professor" VALUES (307, 'MARIA CRISTINA BRAVO DE MORAES');
INSERT INTO "Professor" VALUES (308, 'MARCIA GUARISCHI CORTES');
INSERT INTO "Professor" VALUES (309, 'CARLOS ANTONIO DA COSTA FERNANDES');
INSERT INTO "Professor" VALUES (310, 'ANDREA FRANCA MARTINS');
INSERT INTO "Professor" VALUES (311, 'ANGELUCCIA BERNARDES HABERT');
INSERT INTO "Professor" VALUES (312, 'AUGUSTO LUIZ DUARTE LOPES SAMPAIO');
INSERT INTO "Professor" VALUES (313, 'CESAR ROMERO JACOB');
INSERT INTO "Professor" VALUES (314, 'EVERARDO PEREIRA GUIMARAES ROCHA');
INSERT INTO "Professor" VALUES (315, 'JOSE CARLOS SOUZA RODRIGUES');
INSERT INTO "Professor" VALUES (316, 'MIGUEL SERPA PEREIRA');
INSERT INTO "Professor" VALUES (317, 'RENATO CORDEIRO GOMES');
INSERT INTO "Professor" VALUES (318, 'IONE BORGES FERREIRA VICENTE');
INSERT INTO "Professor" VALUES (319, 'ALEXANDRE SOUZA CHAVES');
INSERT INTO "Professor" VALUES (320, 'MARIVANI DE OLIVEIRA DE A PEREIRA');
INSERT INTO "Professor" VALUES (321, 'ROBERTO TEIXEIRA CORREA');
INSERT INTO "Professor" VALUES (322, 'SOLANGE MARTINS JORDAO');
INSERT INTO "Professor" VALUES (323, 'ROSEMARY FERNANDES DA COSTA');
INSERT INTO "Professor" VALUES (324, 'MONICA BAPTISTA CAMPOS');
INSERT INTO "Professor" VALUES (325, 'PAULO ALVES ROMAO');
INSERT INTO "Professor" VALUES (326, 'GERALDO MARQUES RAIMUNDO');
INSERT INTO "Professor" VALUES (327, 'JOAO GERALDO MACHADO BELLOCCHIO');
INSERT INTO "Professor" VALUES (328, 'THEOPHILO ANTONIO DA ROCHA MATTOS');
INSERT INTO "Professor" VALUES (329, 'MARCOS VINICIO MIRANDA VIEIRA');
INSERT INTO "Professor" VALUES (330, 'MARCO ANTONIO GUSMAO BONELLI');
INSERT INTO "Professor" VALUES (331, 'CLAUDIO JACINTO DA SILVA');
INSERT INTO "Professor" VALUES (332, 'MARCOS ANTONIO DE SANTANA');
INSERT INTO "Professor" VALUES (333, 'ANDRE SAMPAIO DE OLIVEIRA');
INSERT INTO "Professor" VALUES (334, 'CELSO PINTO CARIAS');
INSERT INTO "Professor" VALUES (335, 'GERALDO LUIZ CAMPOS C DE OLIVEIRA');
INSERT INTO "Professor" VALUES (336, 'VERA MARIA LANZELLOTTI BALDEZ BOING');
INSERT INTO "Professor" VALUES (337, 'EVA APARECIDA REZENDE DE MORAES');
INSERT INTO "Professor" VALUES (338, 'GLORIA MARIA TELES');
INSERT INTO "Professor" VALUES (339, 'MANUEL DE OLIVEIRA MANANGAO');
INSERT INTO "Professor" VALUES (340, 'GLORIA FATIMA COSTA DO NASCIMENTO');
INSERT INTO "Professor" VALUES (341, 'MARIA CARMEN CASTANHEIRA AVELAR');
INSERT INTO "Professor" VALUES (342, 'CASSIA QUELHO TAVARES');
INSERT INTO "Professor" VALUES (343, 'BARBARA PATARO BUCKER');
INSERT INTO "Professor" VALUES (344, 'MARIA ADELAIDE FERREIRA GOMES');
INSERT INTO "Professor" VALUES (345, 'MARCYLENE DE OLIVEIRA CAPPER');
INSERT INTO "Professor" VALUES (346, 'FERNANDO GALVAO DE ANDREA FERREIRA');
INSERT INTO "Professor" VALUES (347, 'CANDIDO FELICIANO DA PONTE NETO');
INSERT INTO "Professor" VALUES (348, 'JOAO ANTONIO SILVEIRA LINS SUCUPIRA');
INSERT INTO "Professor" VALUES (349, 'JOSE ROBERTO RODRIGUES DEVELLARD');
INSERT INTO "Professor" VALUES (350, 'MAURICIO REIS VIANA FILHO');
INSERT INTO "Professor" VALUES (351, 'RENATA MATTOS EYER DE ARAUJO');
INSERT INTO "Professor" VALUES (352, 'LUIZA NOVAES');
INSERT INTO "Professor" VALUES (353, 'LUCIANA BARBOSA DE SOUSA');
INSERT INTO "Professor" VALUES (354, 'MARIO AUGUSTO PINTO DE SOUZA SEIXAS');
INSERT INTO "Professor" VALUES (355, 'LUCIANA GRETHER DE MELLO CARVALHO');
INSERT INTO "Professor" VALUES (356, 'NATHALIA CHEHAB DE SA CAVALCANTE');
INSERT INTO "Professor" VALUES (357, 'CELSO BRAGA WILMER');
INSERT INTO "Professor" VALUES (358, 'FLAVIA NIZIA DA FONSECA RIBEIRO');
INSERT INTO "Professor" VALUES (359, 'JOY HELENA WORMS TILL');
INSERT INTO "Professor" VALUES (360, 'ROMULO MIYAZAWA MATTEONI');
INSERT INTO "Professor" VALUES (361, 'FERNANDO FELICIO DOS S DE CARVALHO');
INSERT INTO "Professor" VALUES (362, 'DEBORAH CHAGAS CHRISTO');
INSERT INTO "Professor" VALUES (363, 'IRINA ARAGAO DOS SANTOS');
INSERT INTO "Professor" VALUES (364, 'MARCO ANTONIO MAIA FONSECA');
INSERT INTO "Professor" VALUES (365, 'SIMONE CARVALHO DE FORMIGA XAVIER');
INSERT INTO "Professor" VALUES (366, 'JOAO DE SA BONELLI');
INSERT INTO "Professor" VALUES (367, 'VERA MARIA MARSICANO DAMAZIO');
INSERT INTO "Professor" VALUES (368, 'MARIA CLAUDIA BOLSHAW GOMES');
INSERT INTO "Professor" VALUES (369, 'CLAUDIA HABIB KAYAT');
INSERT INTO "Professor" VALUES (370, 'GUILHERME AZEVEDO TOLEDO');
INSERT INTO "Professor" VALUES (371, 'JOANA PESSOA');
INSERT INTO "Professor" VALUES (372, 'ELIANE GARCIA PEREIRA');
INSERT INTO "Professor" VALUES (373, 'GILBERTO MENDES CORREIA JUNIOR');
INSERT INTO "Professor" VALUES (374, 'MONICA SABOIA SADDI');
INSERT INTO "Professor" VALUES (375, 'ROBERTA PORTAS GONCALVES RODRIGUES');
INSERT INTO "Professor" VALUES (376, 'MARCELO FERNANDES PEREIRA');
INSERT INTO "Professor" VALUES (377, 'CLAUDIO GOMES WERNECK DE FREITAS');
INSERT INTO "Professor" VALUES (378, 'HENRIQUE MATTAR MONNERAT');
INSERT INTO "Professor" VALUES (379, 'TATIANA MESSER RYBALOWSKI');
INSERT INTO "Professor" VALUES (380, 'DANIEL MALAGUTI CAMPOS');
INSERT INTO "Professor" VALUES (381, 'GUILHERME DE ALMEIDA XAVIER');
INSERT INTO "Professor" VALUES (382, 'MONICA MARANHA PAES DE CARVALHO');
INSERT INTO "Professor" VALUES (383, 'JOAO DE SOUZA LEITE');
INSERT INTO "Professor" VALUES (384, 'ELIZABETH BASTOS GRANDMASSON CHAVES');
INSERT INTO "Professor" VALUES (385, 'EVELYN GRUMACH');
INSERT INTO "Professor" VALUES (386, 'MARIA DAS GRACAS DE ALMEIDA CHAGAS');
INSERT INTO "Professor" VALUES (387, 'ANA LUIZA MORALES DE AGUIAR');
INSERT INTO "Professor" VALUES (388, 'LUIZA FERRO COSTA MARCIER');
INSERT INTO "Professor" VALUES (389, 'FELIPE RANGEL CARNEIRO');
INSERT INTO "Professor" VALUES (390, 'CELSO MEIRELLES DE OLIVEIRA SANTOS');
INSERT INTO "Professor" VALUES (391, 'JOAQUIM DE SALLES REDIG DE CAMPOS');
INSERT INTO "Professor" VALUES (392, 'CRISTINE NOGUEIRA NUNES');
INSERT INTO "Professor" VALUES (393, 'SILVIA HELENA SOARES DA COSTA');
INSERT INTO "Professor" VALUES (394, 'ALEXANDRE CANTINI REZENDE');
INSERT INTO "Professor" VALUES (395, 'EMILIO RANGEL CARNEIRO');
INSERT INTO "Professor" VALUES (396, 'VERA MARIA CAVALCANTI BERNARDES');
INSERT INTO "Professor" VALUES (397, 'JOSE AUGUSTO BRANDAO ESTELLITA LINS');
INSERT INTO "Professor" VALUES (398, 'ZOY ANASTASSAKIS');
INSERT INTO "Professor" VALUES (399, 'WASHINGTON DIAS LESSA');
INSERT INTO "Professor" VALUES (400, 'LEONARDO CARDARELLI LEITE');
INSERT INTO "Professor" VALUES (401, 'LUIZ EDUARDO DUTRA COELHO DA ROCHA');
INSERT INTO "Professor" VALUES (402, 'MIGUEL SANTOS DE CARVALHO');
INSERT INTO "Professor" VALUES (403, 'HELENA CAVALCANTI DE ALBUQUERQUE');
INSERT INTO "Professor" VALUES (404, 'MONICA FROTA LEAO FEITOSA');
INSERT INTO "Professor" VALUES (405, 'FRANCISCO OLIVEIRA DE QUEIROZ');
INSERT INTO "Professor" VALUES (406, 'GUILHERME LORENZONI DE ALMEIDA');
INSERT INTO "Professor" VALUES (407, 'RICARDO DA CUNHA FONTES');
INSERT INTO "Professor" VALUES (408, 'CARLOS EDUARDO FELIX DA COSTA');
INSERT INTO "Professor" VALUES (409, 'JOSE ROBERTO SANSEVERINO');
INSERT INTO "Professor" VALUES (410, 'CLAUDIA RENATA MONT A B RODRIGUES');
INSERT INTO "Professor" VALUES (411, 'JULIETA COSTA SOBRAL');
INSERT INTO "Professor" VALUES (412, 'LUIZ ANTONIO LUZIO COELHO');
INSERT INTO "Professor" VALUES (413, 'EDNA LUCIA OLIVEIRA DA CUNHA LIMA');
INSERT INTO "Professor" VALUES (414, 'FABIO PINTO LOPES DE LIMA');
INSERT INTO "Professor" VALUES (415, 'VERA LUCIA MOREIRA DOS S NOJIMA');
INSERT INTO "Professor" VALUES (416, 'EDUARDO PUCU DE ARAUJO');
INSERT INTO "Professor" VALUES (417, 'REJANE SPITZ');
INSERT INTO "Professor" VALUES (418, 'WERTHER TEIXEIRA DE AZEVEDO NETO');
INSERT INTO "Professor" VALUES (419, 'MARCOS AMARANTE DE A MAGALHAES');
INSERT INTO "Professor" VALUES (420, 'GABRIEL DO AMARAL BATISTA');
INSERT INTO "Professor" VALUES (421, 'ALINE MOREIRA MONCORES');
INSERT INTO "Professor" VALUES (422, 'ADRIANA SAMPAIO LEITE');
INSERT INTO "Professor" VALUES (423, 'CLAUDIA MARIA MONTEIRO VIANNA');
INSERT INTO "Professor" VALUES (424, 'ELAINE RADICETTI');
INSERT INTO "Professor" VALUES (425, 'WALVYKER ALVES DE SOUZA');
INSERT INTO "Professor" VALUES (426, 'CLAUDIA CRISTINA DE MELLO ROLLIM');
INSERT INTO "Professor" VALUES (427, 'DANIELA CORREA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (428, 'CELSO RAYOL JUNIOR');
INSERT INTO "Professor" VALUES (429, 'FREDERICO SALAMONI GELLI');
INSERT INTO "Professor" VALUES (430, 'MARCELO MASSAHARU HATAKEYAMA');
INSERT INTO "Professor" VALUES (431, 'CLAUDIO FREITAS DE MAGALHAES');
INSERT INTO "Professor" VALUES (432, 'GABRIELLA FERREIRA CHAVES VACCARI');
INSERT INTO "Professor" VALUES (433, 'LEONIDAS AUGUSTO CORREIA DE MORAES');
INSERT INTO "Professor" VALUES (434, 'JORGE LANGONE');
INSERT INTO "Professor" VALUES (435, 'ALFREDO JEFFERSON DE OLIVEIRA');
INSERT INTO "Professor" VALUES (436, 'JORGE ROBERTO LOPES DOS SANTOS');
INSERT INTO "Professor" VALUES (437, 'TATIANA TABAK');
INSERT INTO "Professor" VALUES (438, 'JOSE LUIZ MENDES RIPPER');
INSERT INTO "Professor" VALUES (439, 'GUILHERME NUNES DA COSTA');
INSERT INTO "Professor" VALUES (440, 'MERIDA ALBERTA HERASME MEDINA');
INSERT INTO "Professor" VALUES (441, 'TANIA PETERSEN CORREA');
INSERT INTO "Professor" VALUES (442, 'YANN ALBERT GRANDJEAN');
INSERT INTO "Professor" VALUES (443, 'MARIE GEORGIANA JOSEPHINE V VIDAL');
INSERT INTO "Professor" VALUES (444, 'JOSE MARCIO ANTONIO G DE CAMARGO');
INSERT INTO "Professor" VALUES (445, 'MARIANA DE MORAES B P ALBUQUERQUE');
INSERT INTO "Professor" VALUES (446, 'MIGUEL NATHAN FOGUEL');
INSERT INTO "Professor" VALUES (447, 'LUISA SHU KURIZKY');
INSERT INTO "Professor" VALUES (448, 'WALTER NOVAES FILHO');
INSERT INTO "Professor" VALUES (449, 'MARCELO NUNO CARNEIRO DE SOUSA');
INSERT INTO "Professor" VALUES (450, 'MARIA DE NAZARETH MACIEL');
INSERT INTO "Professor" VALUES (451, 'PAULO MANSUR LEVY');
INSERT INTO "Professor" VALUES (452, 'ELIANE GOTTLIEB');
INSERT INTO "Professor" VALUES (453, 'MARIA ELENA GAVA REDDO ALVES');
INSERT INTO "Professor" VALUES (454, 'MARCOS ANTONIO COUTINHO DA SILVEIRA');
INSERT INTO "Professor" VALUES (455, 'SHEILA NAJBERG');
INSERT INTO "Professor" VALUES (456, 'ANTONIO MARCOS HOELZ PINTO AMBROZIO');
INSERT INTO "Professor" VALUES (457, 'JULIANO JUNQUEIRA ASSUNCAO');
INSERT INTO "Professor" VALUES (458, 'ROGERIO LADEIRA FURQUIM WERNECK');
INSERT INTO "Professor" VALUES (459, 'EDUARDO ZILBERMAN');
INSERT INTO "Professor" VALUES (460, 'JOAO BARBOSA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (461, 'PEDRO HENRIQUE DE CASTRO ROSADO');
INSERT INTO "Professor" VALUES (462, 'CARLOS VIANA DE CARVALHO');
INSERT INTO "Professor" VALUES (463, 'MARCIA GUERRA PEREIRA');
INSERT INTO "Professor" VALUES (464, 'RAFAEL PINHO SENRA DE MORAIS');
INSERT INTO "Professor" VALUES (465, 'JOAO MANOEL PINHO DE MELLO');
INSERT INTO "Professor" VALUES (466, 'MONICA BAUMGARTEN DE BOLLE');
INSERT INTO "Professor" VALUES (467, 'DANIELA ALONSO FONTES');
INSERT INTO "Professor" VALUES (468, 'HAMILTON MASSATAKA KAI');
INSERT INTO "Professor" VALUES (469, 'MARCELO DE PAIVA ABREU');
INSERT INTO "Professor" VALUES (470, 'FELIPE TAMEGA FERNANDES');
INSERT INTO "Professor" VALUES (471, 'LUIZ ROBERTO AZEVEDO CUNHA');
INSERT INTO "Professor" VALUES (472, 'JOSE ANTONIO ORTEGA');
INSERT INTO "Professor" VALUES (473, 'LUIZ PAULO VELLOZO LUCAS');
INSERT INTO "Professor" VALUES (474, 'JOAO HALLAK NETO');
INSERT INTO "Professor" VALUES (475, 'ROBERTO GERALDO S SANTOS FILHO');
INSERT INTO "Professor" VALUES (476, 'RUI RONALD CALDAS MARINHO');
INSERT INTO "Professor" VALUES (477, 'LEONARDO BANDEIRA REZENDE');
INSERT INTO "Professor" VALUES (478, 'GUSTAVO MAURICIO GONZAGA');
INSERT INTO "Professor" VALUES (479, 'TEMPO CONTINUO A DEFINIR');
INSERT INTO "Professor" VALUES (480, 'MAURICIO CORTEZ REIS');
INSERT INTO "Professor" VALUES (481, 'MARCO ANTONIO F DE H CAVALCANTI');
INSERT INTO "Professor" VALUES (482, 'JUAREZ DA SILVEIRA FIGUEIREDO');
INSERT INTO "Professor" VALUES (483, 'MARCELO CUNHA MEDEIROS');
INSERT INTO "Professor" VALUES (484, 'FABRICIO MELLO RODRIGUES DA SILVA');
INSERT INTO "Professor" VALUES (485, 'RODRIGO REIS SOARES');
INSERT INTO "Professor" VALUES (486, 'MARIA LUIZA GOMES TEIXEIRA');
INSERT INTO "Professor" VALUES (487, 'ANA WALESKA POLLO CAMPOS MENDONCA');
INSERT INTO "Professor" VALUES (488, 'PATRICIA COELHO DA COSTA');
INSERT INTO "Professor" VALUES (489, 'ISABEL ALICE OSWALD MONTEIRO LELIS');
INSERT INTO "Professor" VALUES (490, 'ROSALIA MARIA DUARTE');
INSERT INTO "Professor" VALUES (491, 'DANIELA FRIDA DRELICH VALENTIM');
INSERT INTO "Professor" VALUES (492, 'ZENA WINONA EISENBERG');
INSERT INTO "Professor" VALUES (493, 'FATIMA CRISTINA DE MENDONCA ALVES');
INSERT INTO "Professor" VALUES (494, 'RALPH INGS BANNELL');
INSERT INTO "Professor" VALUES (495, 'CYNTHIA PAES DE CARVALHO');
INSERT INTO "Professor" VALUES (496, 'MARIA CRISTINA M P DE CARVALHO');
INSERT INTO "Professor" VALUES (497, 'ADELIA MARIA NEHME SIMAO E KOFF');
INSERT INTO "Professor" VALUES (498, 'MARCELO GUSTAVO ANDRADE DE SOUZA');
INSERT INTO "Professor" VALUES (499, 'ALICIA MARIA CATALANO DE BONAMINO');
INSERT INTO "Professor" VALUES (500, 'MARIA RITA PASSERI SALOMAO');
INSERT INTO "Professor" VALUES (501, 'MARIA FERNANDA REZENDE NUNES');
INSERT INTO "Professor" VALUES (502, 'MARIA INES GALVAO FLORES M DE SOUZA');
INSERT INTO "Professor" VALUES (503, 'ANA MARIA BELTRAN PAVANI');
INSERT INTO "Professor" VALUES (504, 'SERGIO RICARDO YATES DOS SANTOS');
INSERT INTO "Professor" VALUES (505, 'CAROLINA GUIMARAES DE SOUZA DIAS');
INSERT INTO "Professor" VALUES (506, 'LEONARDO COSTA RANGEL');
INSERT INTO "Professor" VALUES (507, 'ADERSON CAMPOS PASSOS');
INSERT INTO "Professor" VALUES (508, 'RUTH ESPINOLA SORIANO DE MELLO');
INSERT INTO "Professor" VALUES (509, 'MARCO AURELIO FAGUNDES ALBERNAZ');
INSERT INTO "Professor" VALUES (510, 'CARLA FRANCISCA BOTTINO ANTONACCIO');
INSERT INTO "Professor" VALUES (511, 'JULIA BLOOMFIELD GAMA ZARDO');
INSERT INTO "Professor" VALUES (512, 'MARIA FATIMA LUDOVICO DE ALMEIDA');
INSERT INTO "Professor" VALUES (513, 'LUIS FERNANDO OLIVEIRA DO VABO JR');
INSERT INTO "Professor" VALUES (514, 'ADRIAN GIASSONE');
INSERT INTO "Professor" VALUES (515, 'DANIELA SILVEIRA SOLURI');
INSERT INTO "Professor" VALUES (516, 'JORGE DIAS LAGE');
INSERT INTO "Professor" VALUES (517, 'JOEL VIEIRA BAPTISTA JUNIOR');
INSERT INTO "Professor" VALUES (518, 'HUGO FUKS');
INSERT INTO "Professor" VALUES (519, 'RICARDO YOGUI');
INSERT INTO "Professor" VALUES (520, 'ANDRE RIBEIRO DE OLIVEIRA');
INSERT INTO "Professor" VALUES (521, 'ANA ROSA FONSECA DE AGUIAR MARTINS');
INSERT INTO "Professor" VALUES (522, 'JOAO QUEIROZ KRAUSE');
INSERT INTO "Professor" VALUES (523, 'RONALDO RODRIGUES BASTOS');
INSERT INTO "Professor" VALUES (524, 'JOSE PAULO SILVA DE PAULA');
INSERT INTO "Professor" VALUES (525, 'NEY AUGUSTO DUMONT');
INSERT INTO "Professor" VALUES (526, 'DJENANE CORDEIRO PAMPLONA');
INSERT INTO "Professor" VALUES (527, 'LUIS FERNANDO FIGUEIRA DA SILVA');
INSERT INTO "Professor" VALUES (528, 'WASHINGTON BRAGA FILHO');
INSERT INTO "Professor" VALUES (529, 'SIDNEI PACIORNIK');
INSERT INTO "Professor" VALUES (530, 'BOJAN MARINKOVIC');
INSERT INTO "Professor" VALUES (531, 'JOSE ROBERTO MORAES D ALMEIDA');
INSERT INTO "Professor" VALUES (532, 'IVANI DE SOUZA BOTT');
INSERT INTO "Professor" VALUES (533, 'RAUL ALMEIDA NUNES');
INSERT INTO "Professor" VALUES (534, 'MARCOS VENICIUS SOARES PEREIRA');
INSERT INTO "Professor" VALUES (535, 'DAVID MARTINS VIEIRA');
INSERT INTO "Professor" VALUES (536, 'MARIA MAGDALENA LYRA DA SILVA');
INSERT INTO "Professor" VALUES (537, 'FABIO RODRIGO SIQUEIRA BATISTA');
INSERT INTO "Professor" VALUES (538, 'PEDRICTO ROCHA FILHO');
INSERT INTO "Professor" VALUES (539, 'ANA CRISTINA MALHEIROS G CARVALHO');
INSERT INTO "Professor" VALUES (540, 'CARLOS ROBERTO HALL BARBOSA');
INSERT INTO "Professor" VALUES (541, 'ROBERTO RIBEIRO DE AVILLEZ');
INSERT INTO "Professor" VALUES (542, 'REINALDO CASTRO SOUZA');
INSERT INTO "Professor" VALUES (543, 'MARLEY MARIA BERNARDES R VELLASCO');
INSERT INTO "Professor" VALUES (544, 'ROBERTO JOSE DE CARVALHO');
INSERT INTO "Professor" VALUES (545, 'LUIS FERNANDO ALZUGUIR AZEVEDO');
INSERT INTO "Professor" VALUES (546, 'MONICA FEIJO NACCACHE');
INSERT INTO "Professor" VALUES (547, 'MARCELO DE ANDRADE DREUX');
INSERT INTO "Professor" VALUES (548, 'THEREZINHA SOUZA DA COSTA');
INSERT INTO "Professor" VALUES (549, 'EDUARDO DE ALBUQUERQUE BROCCHI');
INSERT INTO "Professor" VALUES (550, 'ARTHUR MARTINS BARBOSA BRAGA');
INSERT INTO "Professor" VALUES (551, 'FLAVIA CESAR TEIXEIRA MENDES');
INSERT INTO "Professor" VALUES (552, 'MARIA CECILIA DE CARVALHO CHAVES');
INSERT INTO "Professor" VALUES (553, 'PAULO SOARES ALVES CUNHA');
INSERT INTO "Professor" VALUES (554, 'ROBERTO PEIXOTO NOGUEIRA');
INSERT INTO "Professor" VALUES (555, 'LINCOLN WOLF DE ALMEIDA NEVES');
INSERT INTO "Professor" VALUES (556, 'FERNANDO HENRIQUE DA SILVEIRA NETO');
INSERT INTO "Professor" VALUES (557, 'JOSE EUGENIO LEAL');
INSERT INTO "Professor" VALUES (558, 'JOSE PAULO TEIXEIRA');
INSERT INTO "Professor" VALUES (559, 'NELIO DOMINGUES PIZZOLATO');
INSERT INTO "Professor" VALUES (560, 'CARLOS PATRICIO MERCADO SAMANEZ');
INSERT INTO "Professor" VALUES (561, 'MARIA ISABEL PAIS DA SILVA');
INSERT INTO "Professor" VALUES (562, 'PAULO BATISTA GONCALVES');
INSERT INTO "Professor" VALUES (563, 'MELISSA LEMOS CAVALIERE');
INSERT INTO "Professor" VALUES (564, 'MARCO AURELIO CAVALCANTI PACHECO');
INSERT INTO "Professor" VALUES (565, 'CELSO ROMANEL');
INSERT INTO "Professor" VALUES (566, 'DEBORA LOPES PILOTTO DOMINGUES');
INSERT INTO "Professor" VALUES (567, 'LUIZ FERNANDO CAMPOS RAMOS MARTHA');
INSERT INTO "Professor" VALUES (568, 'DEANE DE MESQUITA ROEHL');
INSERT INTO "Professor" VALUES (569, 'RAUL ROSAS E SILVA');
INSERT INTO "Professor" VALUES (570, 'TACIO MAURO PEREIRA DE CAMPOS');
INSERT INTO "Professor" VALUES (571, 'KHOSROW GHAVAMI');
INSERT INTO "Professor" VALUES (572, 'GIUSEPPE BARBOSA GUIMARAES');
INSERT INTO "Professor" VALUES (573, 'SEBASTIAO ARTHUR LOPES DE ANDRADE');
INSERT INTO "Professor" VALUES (574, 'CARLOS EDEN SARDENBERG MESQUITA');
INSERT INTO "Professor" VALUES (575, 'ERNANI DE SOUZA COSTA');
INSERT INTO "Professor" VALUES (576, 'ROBSON LUIZ GAIOFATTO');
INSERT INTO "Professor" VALUES (577, 'VICENTE GARAMBONE FILHO');
INSERT INTO "Professor" VALUES (578, 'EURIPEDES DO AMARAL VARGAS JR');
INSERT INTO "Professor" VALUES (579, 'MAURICIO LEONARDO TOREM');
INSERT INTO "Professor" VALUES (580, 'FRANCISCO JOSE MOURA');
INSERT INTO "Professor" VALUES (581, 'JOSE CARLOS D ABREU');
INSERT INTO "Professor" VALUES (582, 'LUIZ ALBERTO CESAR TEIXEIRA');
INSERT INTO "Professor" VALUES (583, 'EDUARDO JOSE SIQUEIRA P DE SOUZA');
INSERT INTO "Professor" VALUES (584, 'MARLENE SABINO PONTES');
INSERT INTO "Professor" VALUES (585, 'GUILHERME PENELLO TEMPORAO');
INSERT INTO "Professor" VALUES (586, 'PATRICIA LUSTOZA DE SOUZA');
INSERT INTO "Professor" VALUES (587, 'MARIA CRISTINA RIBEIRO CARVALHO');
INSERT INTO "Professor" VALUES (588, 'EMANOEL PAIVA OLIVEIRA COSTA');
INSERT INTO "Professor" VALUES (589, 'FLAVIO JOSE VIEIRA HASSELMANN');
INSERT INTO "Professor" VALUES (590, 'CRISTIANO AUGUSTO COELHO FERNANDES');
INSERT INTO "Professor" VALUES (591, 'JOSE MAURO PEDRO FORTES');
INSERT INTO "Professor" VALUES (592, 'ABRAHAM ALCAIM');
INSERT INTO "Professor" VALUES (593, 'MOISES HENRIQUE SZWARCMAN');
INSERT INTO "Professor" VALUES (594, 'MAURO SCHWANKE DA SILVA');
INSERT INTO "Professor" VALUES (595, 'DELBERIS ARAUJO LIMA');
INSERT INTO "Professor" VALUES (596, 'RAUL QUEIROZ FEITOSA');
INSERT INTO "Professor" VALUES (597, 'LUIS FERNANDO CORREA MONTEIRO');
INSERT INTO "Professor" VALUES (598, 'ALVARO DE LIMA VEIGA FILHO');
INSERT INTO "Professor" VALUES (599, 'ALEXANDRE STREET DE AGUIAR');
INSERT INTO "Professor" VALUES (600, 'JEAN PIERRE VON DER WEID');
INSERT INTO "Professor" VALUES (601, 'MARCO ANTONIO GRIVET MATTOSO MAIA');
INSERT INTO "Professor" VALUES (602, 'EUGENIO KAHN EPPRECHT');
INSERT INTO "Professor" VALUES (603, 'ROBERTO CINTRA MARTINS');
INSERT INTO "Professor" VALUES (604, 'SILVIO HAMACHER');
INSERT INTO "Professor" VALUES (605, 'LEONARDO JUNQUEIRA LUSTOSA');
INSERT INTO "Professor" VALUES (606, 'MARIO ANTONIO PINHEIRO BITENCOURT');
INSERT INTO "Professor" VALUES (607, 'PAULO ROBERTO TAVARES DALCOL');
INSERT INTO "Professor" VALUES (608, 'ROGERIO ODIVAN BRITO SERRAO');
INSERT INTO "Professor" VALUES (609, 'VENETIA MARIA CORREA SANTOS');
INSERT INTO "Professor" VALUES (610, 'MARCIUS HOLLANDA PEREIRA DA ROCHA');
INSERT INTO "Professor" VALUES (611, 'RENATO DE VIVEIROS LIMA');
INSERT INTO "Professor" VALUES (612, 'GUSTAVO MIRANDA ARAUJO');
INSERT INTO "Professor" VALUES (613, 'GUSTAVO COSTA GOMES MOREIRA');
INSERT INTO "Professor" VALUES (614, 'THAIS HELENA DE LIMA NUNES');
INSERT INTO "Professor" VALUES (615, 'FERNANDA MARIA PEREIRA RAUPP');
INSERT INTO "Professor" VALUES (616, 'LUIZ HENRIQUE ABREU DAL BELLO');
INSERT INTO "Professor" VALUES (617, 'KATIA MARIA CARLOS ROCHA');
INSERT INTO "Professor" VALUES (618, 'FERNANDO ANTONIO LUCENA AIUBE');
INSERT INTO "Professor" VALUES (619, 'ROGERIO DE GUSMAO PINTO LOPES');
INSERT INTO "Professor" VALUES (620, 'HERMES GOMES DA SILVA FILHO');
INSERT INTO "Professor" VALUES (621, 'CARLOS VALOIS MACIEL BRAGA');
INSERT INTO "Professor" VALUES (622, 'CARLOS ALBERTO DE ALMEIDA');
INSERT INTO "Professor" VALUES (623, 'HANS INGO WEBER');
INSERT INTO "Professor" VALUES (624, 'SERGIO LEAL BRAGA');
INSERT INTO "Professor" VALUES (625, 'GREGORIO SALCEDO MUNOZ');
INSERT INTO "Professor" VALUES (626, 'MARCO ANTONIO MEGGIOLARO');
INSERT INTO "Professor" VALUES (627, 'RUBENS SAMPAIO FILHO');
INSERT INTO "Professor" VALUES (628, 'RONALDO DOMINGUES VIEIRA');
INSERT INTO "Professor" VALUES (629, 'ALCIR DE FARO ORLANDO');
INSERT INTO "Professor" VALUES (630, 'MARCIO DA SILVEIRA CARVALHO');
INSERT INTO "Professor" VALUES (631, 'JAIME TUPIASSU PINHO DE CASTRO');
INSERT INTO "Professor" VALUES (632, 'MARCOS SEBASTIAO DE PAULA GOMES');
INSERT INTO "Professor" VALUES (633, 'MAURO SPERANZA NETO');
INSERT INTO "Professor" VALUES (634, 'JOSE LUIZ DE FRANCA FREIRE');
INSERT INTO "Professor" VALUES (635, 'JOSE ALBERTO DOS REIS PARISE');
INSERT INTO "Professor" VALUES (636, 'JORGE LUIZ FONTANELLA');
INSERT INTO "Professor" VALUES (637, 'IVAN FABIO MOTA DE MENEZES');
INSERT INTO "Professor" VALUES (638, 'RICARDO TEIXEIRA DA COSTA NETO');
INSERT INTO "Professor" VALUES (639, 'CECILIA VILANI');
INSERT INTO "Professor" VALUES (640, 'WILSON BUCKER AGUIAR JUNIOR');
INSERT INTO "Professor" VALUES (641, 'EDMAR DAS MERCES PENHA');
INSERT INTO "Professor" VALUES (642, 'ANDRE LUIS ALBERTON');
INSERT INTO "Professor" VALUES (643, 'ROBERTO BENTES DE CARVALHO');
INSERT INTO "Professor" VALUES (644, 'ROBERTO WERNECK DO CARMO');
INSERT INTO "Professor" VALUES (645, 'JOSE MARCUS DE OLIVEIRA GODOY');
INSERT INTO "Professor" VALUES (646, 'DENISE MARIA MANO PESSOA');
INSERT INTO "Professor" VALUES (647, 'NEISE RIBEIRO VIEIRA');
INSERT INTO "Professor" VALUES (648, 'RENATO DA SILVA CARREIRA');
INSERT INTO "Professor" VALUES (649, 'LUIZ FELIPE GUANAES REGO');
INSERT INTO "Professor" VALUES (650, 'ROGERIO SCHIFFER DE SOUZA');
INSERT INTO "Professor" VALUES (651, 'LUIS GLAUBER RODRIGUES');
INSERT INTO "Professor" VALUES (652, 'EMANUEL FONSECA DA COSTA');
INSERT INTO "Professor" VALUES (653, 'WELLINGTON CAMPOS');
INSERT INTO "Professor" VALUES (654, 'PAULO DORE FERNANDES');
INSERT INTO "Professor" VALUES (655, 'ABELARDO BORGES BARRETO JUNIOR');
INSERT INTO "Professor" VALUES (656, 'JOAO MANOEL DE ALBUQUERQUE LINS');
INSERT INTO "Professor" VALUES (657, 'ROGERIO SOARES DA COSTA');
INSERT INTO "Professor" VALUES (658, 'VERA MARIA PEREIRA DE M HENRIQUES');
INSERT INTO "Professor" VALUES (659, 'CAIO SALLES MARCONDES DE MOURA');
INSERT INTO "Professor" VALUES (660, 'CURSO A DISTANCIA');
INSERT INTO "Professor" VALUES (661, 'LUISA SEVERO BUARQUE DE HOLANDA');
INSERT INTO "Professor" VALUES (662, 'REMO MANNARINO FILHO');
INSERT INTO "Professor" VALUES (663, 'GABRIEL JUCA DE HOLLANDA');
INSERT INTO "Professor" VALUES (664, 'MARIA INES SENRA ANACHORETA');
INSERT INTO "Professor" VALUES (665, 'VINICIUS DE CARVALHO MONTEIRO');
INSERT INTO "Professor" VALUES (666, 'MARCELA FIGUEIREDO C DE OLIVEIRA');
INSERT INTO "Professor" VALUES (667, 'LUIZ CARLOS PINHEIRO DIAS PEREIRA');
INSERT INTO "Professor" VALUES (668, 'KATIA RODRIGUES MURICY');
INSERT INTO "Professor" VALUES (669, 'IRLEY FERNANDES FRANCO');
INSERT INTO "Professor" VALUES (670, 'MAURA IGLESIAS');
INSERT INTO "Professor" VALUES (671, 'EDUARDO JARDIM DE MORAES');
INSERT INTO "Professor" VALUES (672, 'LUIZ CAMILLO D P O DE ALMEIDA');
INSERT INTO "Professor" VALUES (673, 'LUDOVIC SOUTIF');
INSERT INTO "Professor" VALUES (674, 'ELSA HELENA BUADAS WIBMER');
INSERT INTO "Professor" VALUES (675, 'DEBORAH DANOWSKI');
INSERT INTO "Professor" VALUES (676, 'EDGARD JOSE JORGE FILHO');
INSERT INTO "Professor" VALUES (677, 'FERNANDO FRANCA COCCHIARALE');
INSERT INTO "Professor" VALUES (678, 'MARCOS WILLIAM BERNARDO');
INSERT INTO "Professor" VALUES (679, 'LIGIA TERESA SARAMAGO PADUA');
INSERT INTO "Professor" VALUES (680, 'MARCELO DA SILVA NORBERTO');
INSERT INTO "Professor" VALUES (681, 'EDGAR DE BRITO LYRA NETTO');
INSERT INTO "Professor" VALUES (682, 'RENATO BARBOSA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (683, 'ENIO FROTA DA SILVEIRA');
INSERT INTO "Professor" VALUES (684, 'HORTENCIO ALVES BORGES');
INSERT INTO "Professor" VALUES (685, 'ALEXANDRE BALIU BRAUTIGAM');
INSERT INTO "Professor" VALUES (686, 'HIROSHI NUNOKAWA');
INSERT INTO "Professor" VALUES (687, 'ENRIQUE VICTORIANO ANDA');
INSERT INTO "Professor" VALUES (688, 'RAPHAEL DIAS MARTINS DE PAOLA');
INSERT INTO "Professor" VALUES (689, 'ROSANE RIERA FREIRE');
INSERT INTO "Professor" VALUES (690, 'MARIA OSWALD MACHADO DE MATOS');
INSERT INTO "Professor" VALUES (691, 'DANIEL ACOSTA AVALOS');
INSERT INTO "Professor" VALUES (692, 'DANIEL SOARES VELASCO');
INSERT INTO "Professor" VALUES (693, 'CARLA GOBEL BURLAMAQUI DE MELLO');
INSERT INTO "Professor" VALUES (694, 'ANTONIO CARLOS OLIVEIRA BRUNO');
INSERT INTO "Professor" VALUES (695, 'WALDEMAR MONTEIRO DA SILVA JUNIOR');
INSERT INTO "Professor" VALUES (696, 'VERA LUCIA VIEIRA BALTAR');
INSERT INTO "Professor" VALUES (697, 'RODRIGO PRIOLI MENEZES');
INSERT INTO "Professor" VALUES (698, 'FABIO ALEX PEREIRA DOS SANTOS');
INSERT INTO "Professor" VALUES (699, 'WELLES ANTONIO MARTINEZ MORGADO');
INSERT INTO "Professor" VALUES (700, 'SONIA RENAUX WANDERLEY LOURO');
INSERT INTO "Professor" VALUES (701, 'MARCO CREMONA');
INSERT INTO "Professor" VALUES (702, 'NEY ROBERTO DHEIN');
INSERT INTO "Professor" VALUES (703, 'GLAUCIO LIMA SIQUEIRA');
INSERT INTO "Professor" VALUES (704, 'TOMMASO DEL ROSSO');
INSERT INTO "Professor" VALUES (705, 'CELIA BEATRIZ ANTENEODO DE PORTO');
INSERT INTO "Professor" VALUES (706, 'LUIZ ALENCAR REIS DA SILVA MELLO');
INSERT INTO "Professor" VALUES (707, 'ISABEL CRISTINA DOS SANTOS CARVALHO');
INSERT INTO "Professor" VALUES (708, 'MARCELO EDUARDO HUGUENIN M DA COSTA');
INSERT INTO "Professor" VALUES (709, 'GERALDO MONTEIRO SIGAUD');
INSERT INTO "Professor" VALUES (710, 'ELISABETH COSTA MONTEIRO');
INSERT INTO "Professor" VALUES (711, 'FERNANDO LAZARO FREIRE JUNIOR');
INSERT INTO "Professor" VALUES (712, 'STEFAN ZOHREN');
INSERT INTO "Professor" VALUES (713, 'ACHILLES D AVILA CHIROL');
INSERT INTO "Professor" VALUES (714, 'CLEBER MARQUES DE CASTRO');
INSERT INTO "Professor" VALUES (715, 'ANDREA PAULA DE SOUZA');
INSERT INTO "Professor" VALUES (716, 'MARCELO MOTTA DE FREITAS');
INSERT INTO "Professor" VALUES (717, 'LUCIANO XIMENES ARAGAO');
INSERT INTO "Professor" VALUES (718, 'LEONARDO DOS PASSOS MIRANDA NAME');
INSERT INTO "Professor" VALUES (719, 'ROGERIO RIBEIRO DE OLIVEIRA');
INSERT INTO "Professor" VALUES (720, 'JOAO RUA');
INSERT INTO "Professor" VALUES (721, 'REGINA CELIA DE MATTOS');
INSERT INTO "Professor" VALUES (722, 'ALVARO HENRIQUE DE SOUZA FERREIRA');
INSERT INTO "Professor" VALUES (723, 'REJANE CRISTINA DE ARAUJO RODRIGUES');
INSERT INTO "Professor" VALUES (724, 'JOAO LUIZ DE FIGUEIREDO SILVA');
INSERT INTO "Professor" VALUES (725, 'AUGUSTO CESAR PINHEIRO DA SILVA');
INSERT INTO "Professor" VALUES (726, 'EDUARDO PIMENTEL MENEZES');
INSERT INTO "Professor" VALUES (727, 'RITA DE CASSIA MARTINS MONTEZUMA');
INSERT INTO "Professor" VALUES (728, 'OSWALDO MUNTEAL FILHO');
INSERT INTO "Professor" VALUES (729, 'UMBERTO GUATIMOSIM ALVIM');
INSERT INTO "Professor" VALUES (730, 'SILVIA PATUZZI');
INSERT INTO "Professor" VALUES (731, 'MARCELO GANTUS JASMIN');
INSERT INTO "Professor" VALUES (732, 'ISABELA FERNANDES SOARES LEITE');
INSERT INTO "Professor" VALUES (733, 'GISELLE MARQUES CAMARA');
INSERT INTO "Professor" VALUES (734, 'MARCOS GUEDES VENEU');
INSERT INTO "Professor" VALUES (735, 'REGIANE AUGUSTO DE MATTOS');
INSERT INTO "Professor" VALUES (736, 'MURILO SEBE BON MEIHY');
INSERT INTO "Professor" VALUES (737, 'RENATO PETROCCHI');
INSERT INTO "Professor" VALUES (738, 'SYDENHAM LOURENCO NETO');
INSERT INTO "Professor" VALUES (739, 'MAURICIO BARRETO ALVAREZ PARADA');
INSERT INTO "Professor" VALUES (740, 'ILMAR ROHLOFF DE MATTOS');
INSERT INTO "Professor" VALUES (741, 'LEONARDO AFFONSO DE MIRANDA PEREIRA');
INSERT INTO "Professor" VALUES (742, 'LUIS REZNIK');
INSERT INTO "Professor" VALUES (743, 'MARCO ANTONIO VILLELA PAMPLONA');
INSERT INTO "Professor" VALUES (744, 'MARIA ELISA NORONHA DE SA MADER');
INSERT INTO "Professor" VALUES (745, 'HELOISA MEIRELES GESTEIRA');
INSERT INTO "Professor" VALUES (746, 'MARIA DA GRACA SALGADO');
INSERT INTO "Professor" VALUES (747, 'LUCIANA LOMBARDO COSTA PEREIRA');
INSERT INTO "Professor" VALUES (748, 'DANIEL PINHA SILVA');
INSERT INTO "Professor" VALUES (749, 'ROMULO COSTA MATTOS');
INSERT INTO "Professor" VALUES (750, 'MARIA GABRIELA CARNEIRO DE CARVALHO');
INSERT INTO "Professor" VALUES (751, 'HENRIQUE ESTRADA RODRIGUES');
INSERT INTO "Professor" VALUES (752, 'IVANA STOLZE LIMA');
INSERT INTO "Professor" VALUES (753, 'EUNICIA BARROS BARCELOS FERNANDES');
INSERT INTO "Professor" VALUES (754, 'FLAVIA MARIA SCHLEE EYLER');
INSERT INTO "Professor" VALUES (755, 'RICARDO AUGUSTO BENZAQUEN DE ARAUJO');
INSERT INTO "Professor" VALUES (756, 'MARIA TEREZA CHAVES DE MELLO');
INSERT INTO "Professor" VALUES (757, 'LUCIANA BORGERTH VIAL CORREA');
INSERT INTO "Professor" VALUES (758, 'JUCARA DA SILVA BARBOSA DE MELLO');
INSERT INTO "Professor" VALUES (759, 'LUIZ FELIPE RORIS R S DO CARMO');
INSERT INTO "Professor" VALUES (760, 'ANTONIO FERNANDO DE CASTRO VIEIRA');
INSERT INTO "Professor" VALUES (761, 'IVAN MATHIAS FILHO');
INSERT INTO "Professor" VALUES (762, 'JOSE CARLOS RAMALHO MOREIRA');
INSERT INTO "Professor" VALUES (763, 'CLAUDIA FERLIN');
INSERT INTO "Professor" VALUES (764, 'SERGIO COLCHER');
INSERT INTO "Professor" VALUES (765, 'PAULA YPIRANGA DOS GUARANYS');
INSERT INTO "Professor" VALUES (766, 'LUIZ FERNANDO BESSA SEIBEL');
INSERT INTO "Professor" VALUES (767, 'CAROLINA DE LIMA AGUILAR');
INSERT INTO "Professor" VALUES (768, 'HELIO CORTES VIEIRA LOPES');
INSERT INTO "Professor" VALUES (769, 'ROBERTO IERUSALIMSCHY');
INSERT INTO "Professor" VALUES (770, 'BRUNO FEIJO');
INSERT INTO "Professor" VALUES (771, 'ROGERIO FERREIRA RODRIGUES');
INSERT INTO "Professor" VALUES (772, 'JOISA DE SOUZA OLIVEIRA');
INSERT INTO "Professor" VALUES (773, 'ALBERTO BARBOSA RAPOSO');
INSERT INTO "Professor" VALUES (774, 'BRUNO LOPES VIEIRA');
INSERT INTO "Professor" VALUES (775, 'MARCO ANTONIO CASANOVA');
INSERT INTO "Professor" VALUES (776, 'LUCIANO PEREIRA SOARES');
INSERT INTO "Professor" VALUES (777, 'ANA CAROLINA LETICHEVSKY');
INSERT INTO "Professor" VALUES (778, 'EDWARD HERMANN HAEUSLER');
INSERT INTO "Professor" VALUES (779, 'NOEMI DE LA ROCQUE RODRIGUEZ');
INSERT INTO "Professor" VALUES (780, 'ANA LUCIA DE MOURA');
INSERT INTO "Professor" VALUES (781, 'ALEXANDRE MALHEIROS MESLIN');
INSERT INTO "Professor" VALUES (782, 'ALESSANDRO FABRICIO GARCIA');
INSERT INTO "Professor" VALUES (783, 'FLAVIO HELENO BEVILACQUA E SILVA');
INSERT INTO "Professor" VALUES (784, 'MARCOS VIANNA VILLAS');
INSERT INTO "Professor" VALUES (785, 'ROGERIO LUIS DE CARVALHO COSTA');
INSERT INTO "Professor" VALUES (786, 'JOSE CARLOS MILLAN');
INSERT INTO "Professor" VALUES (787, 'JULIO CESAR SAMPAIO DO PRADO LEITE');
INSERT INTO "Professor" VALUES (788, 'SERGIO LIFSCHITZ');
INSERT INTO "Professor" VALUES (789, 'SIMONE DINIZ JUNQUEIRA BARBOSA');
INSERT INTO "Professor" VALUES (790, 'EDMUNDO BASTOS TORREAO');
INSERT INTO "Professor" VALUES (791, 'MARCANTONIO GIUSEPPE MARIA C FABRA');
INSERT INTO "Professor" VALUES (792, 'RAUL PIERRE RENTERIA');
INSERT INTO "Professor" VALUES (793, 'ARNDT VON STAA');
INSERT INTO "Professor" VALUES (794, 'GUSTAVO ROBICHEZ DE CARVALHO');
INSERT INTO "Professor" VALUES (795, 'ANDERSON OLIVEIRA DA SILVA');
INSERT INTO "Professor" VALUES (796, 'ALEXANDRE RADEMAKER');
INSERT INTO "Professor" VALUES (797, 'EDUARDO SANY LABER');
INSERT INTO "Professor" VALUES (798, 'LUIZ FERNANDO GOMES SOARES');
INSERT INTO "Professor" VALUES (799, 'RUY LUIZ MILIDIU');
INSERT INTO "Professor" VALUES (800, 'MARCELO GATTASS');
INSERT INTO "Professor" VALUES (801, 'EDIRLEI EVERSON SOARES DE LIMA');
INSERT INTO "Professor" VALUES (802, 'MARKUS ENDLER');
INSERT INTO "Professor" VALUES (803, 'MYRIAM SERTA COSTA');
INSERT INTO "Professor" VALUES (804, 'CLAUDIO VICTOR NASAJON SASSON');
INSERT INTO "Professor" VALUES (805, 'HELENE KLEINBERGER SALIM');
INSERT INTO "Professor" VALUES (806, 'MAIRA SIMAN GOMES');
INSERT INTO "Professor" VALUES (807, 'CARLOS FREDERICO PEREIRA DA S GAMA');
INSERT INTO "Professor" VALUES (808, 'MARTA REGINA FERNANDEZ Y G MORENO');
INSERT INTO "Professor" VALUES (809, 'CAROLINA MOULIN AGUIAR');
INSERT INTO "Professor" VALUES (810, 'MARCIO ANTONIO SCALERCIO');
INSERT INTO "Professor" VALUES (811, 'LUCIANA BADIN PEREIRA LIMA');
INSERT INTO "Professor" VALUES (812, 'ALEXANDRA DE MELLO E SILVA');
INSERT INTO "Professor" VALUES (813, 'DIEGO SANTOS VIEIRA DE JESUS');
INSERT INTO "Professor" VALUES (814, 'PHILIPPE OLIVIER BONDITTI');
INSERT INTO "Professor" VALUES (815, 'MONICA HERZ');
INSERT INTO "Professor" VALUES (816, 'CLAUDIO ANDRES TELLEZ ZEPEDA');
INSERT INTO "Professor" VALUES (817, 'FERNANDO NEVES DA COSTA MAIA');
INSERT INTO "Professor" VALUES (818, 'FABIANO PELLIN MIELNICZUK');
INSERT INTO "Professor" VALUES (819, 'LAYLA IBRAHIM ABDALLAH DAWOOD');
INSERT INTO "Professor" VALUES (820, 'PEDRO CLAUDIO CUNGA BRANDO B CUNHA');
INSERT INTO "Professor" VALUES (821, 'KAI MICHAEL KENKEL');
INSERT INTO "Professor" VALUES (822, 'CARLOS FREDERICO DE SOUZA COELHO');
INSERT INTO "Professor" VALUES (823, 'ALEXANDRE DOS SANTOS SILVA');
INSERT INTO "Professor" VALUES (824, 'ARTHUR BERNARDES DO AMARAL');
INSERT INTO "Professor" VALUES (825, 'LEANE CORNET NAIDIN');
INSERT INTO "Professor" VALUES (826, 'MARIA ELENA RODRIGUEZ ORTIZ');
INSERT INTO "Professor" VALUES (827, 'MIGUEL BORBA DE SA');
INSERT INTO "Professor" VALUES (828, 'ADRIANA ERTHAL ABDENUR');
INSERT INTO "Professor" VALUES (829, 'PAULO LUIZ MOREAUX LAVIGNE ESTEVES');
INSERT INTO "Professor" VALUES (830, 'GISELE GUIMARAES CITTADINO');
INSERT INTO "Professor" VALUES (831, 'PAULO ROBERTO SOARES MENDONCA');
INSERT INTO "Professor" VALUES (832, 'JULIA ALEXIM NUNES DA SILVA');
INSERT INTO "Professor" VALUES (833, 'CARLOS GUILHERME FRANCOVICH LUGONES');
INSERT INTO "Professor" VALUES (834, 'LEILA MENEZES DUARTE');
INSERT INTO "Professor" VALUES (835, 'CARLOS GUSTAVO VIANNA DIREITO');
INSERT INTO "Professor" VALUES (836, 'FRANCIS WALESKA ESTEVES DA SILVA');
INSERT INTO "Professor" VALUES (837, 'ANDREA PINHEIRO SANTOS');
INSERT INTO "Professor" VALUES (838, 'IRMA ALMEIDA KLAUTAU LOPES');
INSERT INTO "Professor" VALUES (839, 'INES ALEGRIA ROCUMBACK');
INSERT INTO "Professor" VALUES (840, 'JOB ELOISIO VIEIRA GOMES');
INSERT INTO "Professor" VALUES (841, 'ANA PAULA SANTORO P DE C ALMEIDA');
INSERT INTO "Professor" VALUES (842, 'THEOPHILO ANTONIO MIGUEL FILHO');
INSERT INTO "Professor" VALUES (843, 'FELIPE GIRDWOOD ACIOLI');
INSERT INTO "Professor" VALUES (844, 'GUSTAVO JUNQUEIRA CARNEIRO LEAO');
INSERT INTO "Professor" VALUES (845, 'CARLOS ALBERTO PLASTINO');
INSERT INTO "Professor" VALUES (846, 'ADRIANA RIBEIRO RICE GEISLER');
INSERT INTO "Professor" VALUES (847, 'MARCELLO RAPOSO CIOTOLA');
INSERT INTO "Professor" VALUES (848, 'THULA RAFAELA DE OLIVEIRA PIRES');
INSERT INTO "Professor" VALUES (849, 'TELMA DA GRACA DE LIMA LAGE');
INSERT INTO "Professor" VALUES (850, 'EDUARDO PEREZ OBERG');
INSERT INTO "Professor" VALUES (851, 'ADRIANA VIDAL DE OLIVEIRA');
INSERT INTO "Professor" VALUES (852, 'RACHEL BARROS NIGRO');
INSERT INTO "Professor" VALUES (853, 'NOEL STRUCHINER');
INSERT INTO "Professor" VALUES (854, 'MAURICIO DE ALBUQUERQUE ROCHA');
INSERT INTO "Professor" VALUES (855, 'MARIA LUCIA DE PAULA OLIVEIRA');
INSERT INTO "Professor" VALUES (856, 'ANTONIO CARLOS DE SOUZA C MAIA');
INSERT INTO "Professor" VALUES (857, 'MARIANA TROTTA DALLALANA QUINTANS');
INSERT INTO "Professor" VALUES (858, 'ELIANE BOTELHO JUNQUEIRA');
INSERT INTO "Professor" VALUES (859, 'PEDRO HERMILIO VILLAS BOAS C BRANCO');
INSERT INTO "Professor" VALUES (860, 'ANA LUCIA DE LYRA TAVARES');
INSERT INTO "Professor" VALUES (861, 'JOSE GUILHERME BERMAN CORREA PINTO');
INSERT INTO "Professor" VALUES (862, 'FERNANDO CAVALCANTI WALCACER');
INSERT INTO "Professor" VALUES (863, 'VIRGINIA TOTTI GUIMARAES');
INSERT INTO "Professor" VALUES (864, 'VICTORIA AMALIA DE B C G DE SULOCKI');
INSERT INTO "Professor" VALUES (865, 'ROGERIO RABE');
INSERT INTO "Professor" VALUES (866, 'OTAVIO AUGUSTO DE CASTRO BRAVO');
INSERT INTO "Professor" VALUES (867, 'CLAUDIO LUIS BRAGA DELL ORTO');
INSERT INTO "Professor" VALUES (868, 'IVAN FIRMINO SANTIAGO DA SILVA');
INSERT INTO "Professor" VALUES (869, 'LUIZ FERNANDO VOSS CHAGAS LESSA');
INSERT INTO "Professor" VALUES (870, 'DANIELLE DE ANDRADE MOREIRA');
INSERT INTO "Professor" VALUES (871, 'FLAVIA DA COSTA LIMMER');
INSERT INTO "Professor" VALUES (872, 'ANDRE PERECMANIS');
INSERT INTO "Professor" VALUES (873, 'CARLOS CESAR GOMES');
INSERT INTO "Professor" VALUES (874, 'ELIZABETH TOSTES DE BARROS');
INSERT INTO "Professor" VALUES (875, 'CARLOS RAYMUNDO CARDOSO');
INSERT INTO "Professor" VALUES (876, 'BRENO MELARAGNO COSTA');
INSERT INTO "Professor" VALUES (877, 'JOAO RICARDO WANDERLEY DORNELLES');
INSERT INTO "Professor" VALUES (878, 'LUIZ CLAUDIO SALLES CRISTOFARO');
INSERT INTO "Professor" VALUES (879, 'PEDRO PAULO CRISTOFARO');
INSERT INTO "Professor" VALUES (880, 'JULIAN FONSECA PENA CHEDIAK');
INSERT INTO "Professor" VALUES (881, 'MANOEL VARGAS FRANCO NETTO');
INSERT INTO "Professor" VALUES (882, 'NORMA JONSSEN PARENTE');
INSERT INTO "Professor" VALUES (883, 'TERESA CRISTINA GONCALVES PANTOJA');
INSERT INTO "Professor" VALUES (884, 'BRUNO VAZ DE CARVALHO');
INSERT INTO "Professor" VALUES (885, 'LUIZ EMYGDIO FRANCO DA ROSA JUNIOR');
INSERT INTO "Professor" VALUES (886, 'MANOEL MARQUES DA COSTA BRAGA NETO');
INSERT INTO "Professor" VALUES (887, 'GUILHERME VAZ PORTO BRECHBUHLER');
INSERT INTO "Professor" VALUES (888, 'ANDRE CHATEAUBRIAND P D MARTINS');
INSERT INTO "Professor" VALUES (889, 'PAULO EDUARDO RAMOS DE ARAUJO PENNA');
INSERT INTO "Professor" VALUES (890, 'FRANCISCO ANTUNES MACIEL MUSSNICH');
INSERT INTO "Professor" VALUES (891, 'HELVECIO DE CARVALHO COUTO');
INSERT INTO "Professor" VALUES (892, 'CARLOS HENRIQUE TRANJAN BECHARA');
INSERT INTO "Professor" VALUES (893, 'BRUNO GARCIA REDONDO');
INSERT INTO "Professor" VALUES (894, 'FRANCISCO DE GUIMARAENS');
INSERT INTO "Professor" VALUES (895, 'JOSE RIBAS VIEIRA');
INSERT INTO "Professor" VALUES (896, 'THIAGO RAGONHA VARELA');
INSERT INTO "Professor" VALUES (897, 'REGINA COELI LISBOA SOARES');
INSERT INTO "Professor" VALUES (898, 'LETICIA DE CAMPOS VELHO MARTEL');
INSERT INTO "Professor" VALUES (899, 'JOAO BATISTA BERTHIER LEITE SOARES');
INSERT INTO "Professor" VALUES (900, 'FABIO CARVALHO LEITE');
INSERT INTO "Professor" VALUES (901, 'AUGUSTO HENRIQUE P DE S W MARTINS');
INSERT INTO "Professor" VALUES (902, 'CELSO DE ALBUQUERQUE SILVA');
INSERT INTO "Professor" VALUES (903, 'MANOEL MESSIAS PEIXINHO');
INSERT INTO "Professor" VALUES (904, 'MARIANNA MONTEBELLO WILLEMAN');
INSERT INTO "Professor" VALUES (905, 'MARCIA NINA BERNARDES');
INSERT INTO "Professor" VALUES (906, 'LETICIA DA COSTA PAES');
INSERT INTO "Professor" VALUES (907, 'ALESSANDRO LUCCIOLA MOLON');
INSERT INTO "Professor" VALUES (908, 'ROSANGELA LUNARDELLI CAVALLAZZI');
INSERT INTO "Professor" VALUES (909, 'PEDRO PAULO SALLES CRISTOFARO');
INSERT INTO "Professor" VALUES (910, 'ADOLFO BORGES FILHO');
INSERT INTO "Professor" VALUES (911, 'MIA ALESSANDRA DE SOUZA REIS');
INSERT INTO "Professor" VALUES (912, 'LUCIANO VIANNA ARAUJO');
INSERT INTO "Professor" VALUES (913, 'FIRLY NASCIMENTO FILHO');
INSERT INTO "Professor" VALUES (914, 'LEONARDO DUNCAN MOREIRA LIMA');
INSERT INTO "Professor" VALUES (915, 'MARCIO VIEIRA SOUTO COSTA FERREIRA');
INSERT INTO "Professor" VALUES (916, 'MELVIN BADRA BENNESBY');
INSERT INTO "Professor" VALUES (917, 'RONALDO EDUARDO CRAMER VEIGA');
INSERT INTO "Professor" VALUES (918, 'DARCIO AUGUSTO CHAVES FARIA');
INSERT INTO "Professor" VALUES (919, 'PAULO MARCELO DE MIRANDA SERRANO');
INSERT INTO "Professor" VALUES (920, 'ROGERIO JOSE BENTO S DO NASCIMENTO');
INSERT INTO "Professor" VALUES (921, 'LEONARDO DE SOUZA CHAVES');
INSERT INTO "Professor" VALUES (922, 'PAULO FREITAS RIBEIRO');
INSERT INTO "Professor" VALUES (923, 'SALVADOR BEMERGUY');
INSERT INTO "Professor" VALUES (924, 'ISABELLA FRANCO GUERRA');
INSERT INTO "Professor" VALUES (925, 'LAURO DA GAMA E SOUZA JUNIOR');
INSERT INTO "Professor" VALUES (926, 'GUSTAVO SENECHAL DE GOFFREDO');
INSERT INTO "Professor" VALUES (927, 'CAROLINA DE CAMPOS MELO');
INSERT INTO "Professor" VALUES (928, 'DANIELA TREJOS VARGAS');
INSERT INTO "Professor" VALUES (929, 'NADIA DE ARAUJO');
INSERT INTO "Professor" VALUES (930, 'IRINEU ZIBORDI');
INSERT INTO "Professor" VALUES (931, 'JOSE NASCIMENTO ARAUJO NETTO');
INSERT INTO "Professor" VALUES (932, 'JULIANA BRACKS DUARTE');
INSERT INTO "Professor" VALUES (933, 'RICARDO BRAJTERMAN');
INSERT INTO "Professor" VALUES (934, 'MARIA CELINA BODIN DE MORAES');
INSERT INTO "Professor" VALUES (935, 'CAITLIN SAMPAIO MULHOLLAND');
INSERT INTO "Professor" VALUES (936, 'THAMIS AVILA DALSENTER');
INSERT INTO "Professor" VALUES (937, 'MARCELO FERNANDEZ TRINDADE');
INSERT INTO "Professor" VALUES (938, 'PEDRO MARCOS NUNES BARBOSA');
INSERT INTO "Professor" VALUES (939, 'VLADIMIR MUCURY CARDOSO');
INSERT INTO "Professor" VALUES (940, 'CARLOS NELSON DE PAULA KONDER');
INSERT INTO "Professor" VALUES (941, 'FLAVIO MULLER DOS REIS DE S PUPO');
INSERT INTO "Professor" VALUES (942, 'CARLOS SANTOS DE OLIVEIRA');
INSERT INTO "Professor" VALUES (943, 'JOSE ROBERTO DE CASTRO NEVES');
INSERT INTO "Professor" VALUES (944, 'MARCELO JUNQUEIRA CALIXTO');
INSERT INTO "Professor" VALUES (945, 'HELOISA CARPENA VIEIRA DE MELLO');
INSERT INTO "Professor" VALUES (946, 'GUILHERME VALDETARO MATHIAS');
INSERT INTO "Professor" VALUES (947, 'DANIELE MEDINA MAIA');
INSERT INTO "Professor" VALUES (948, 'MARCELO ROBERTO DE CARVALHO FERRO');
INSERT INTO "Professor" VALUES (949, 'FLAVIA DE ALMEIDA V DE CASTRO');
INSERT INTO "Professor" VALUES (950, 'RENATO LIMA CHARNAUX SERTA');
INSERT INTO "Professor" VALUES (951, 'ROBERTA MAURO MEDINA MAIA');
INSERT INTO "Professor" VALUES (952, 'KATIA REGINA DA COSTA SILVA CIOTOLA');
INSERT INTO "Professor" VALUES (953, 'ROGERIO REIS DE MELLO');
INSERT INTO "Professor" VALUES (954, 'MARIO ROBERTO CARVALHO DE FARIA');
INSERT INTO "Professor" VALUES (955, 'ANA LUIZA MAIA NEVARES');
INSERT INTO "Professor" VALUES (956, 'ALVARO PIQUET CARNEIRO P DOS SANTOS');
INSERT INTO "Professor" VALUES (957, 'BRUNO MACHADO EIRAS');
INSERT INTO "Professor" VALUES (958, 'DENISE MULLER DOS REIS PUPO');
INSERT INTO "Professor" VALUES (959, 'ADRIANO BARCELOS ROMEIRO');
INSERT INTO "Professor" VALUES (960, 'GILBERTO MARTINS DE ALMEIDA');
INSERT INTO "Professor" VALUES (961, 'DANTE BRAZ LIMONGI');
INSERT INTO "Professor" VALUES (962, 'JOAO MESTIERI');
INSERT INTO "Professor" VALUES (963, 'SERGIO BERMUDES');
INSERT INTO "Professor" VALUES (964, 'AGNES CHRISTIAN CHAVES FARIA');
INSERT INTO "Professor" VALUES (965, 'FERNANDA LEITE MENDES E SANTO');
INSERT INTO "Professor" VALUES (966, 'ALEXANDRE SERVINO ASSED');
INSERT INTO "Professor" VALUES (967, 'HELENA FERES HAWAD');
INSERT INTO "Professor" VALUES (968, 'CLARISSA ROLLIN PINHEIRO BASTOS');
INSERT INTO "Professor" VALUES (969, 'ADRIANA GRAY DA SILVA REIS');
INSERT INTO "Professor" VALUES (970, 'MARIA DE FATIMA DUARTE H DOS SANTOS');
INSERT INTO "Professor" VALUES (971, 'SANDRA PEREIRA BERNARDO');
INSERT INTO "Professor" VALUES (972, 'MARGARETH AMOROSO DE MESQUITA');
INSERT INTO "Professor" VALUES (973, 'MARIA CRISTINA G DE G MONTEIRO');
INSERT INTO "Professor" VALUES (974, 'LEONARDO BERENGER ALVES CARNEIRO');
INSERT INTO "Professor" VALUES (975, 'CELIA EYER DE ARAUJO');
INSERT INTO "Professor" VALUES (976, 'ANGELA FILOMENA PERRICONE PASTURA');
INSERT INTO "Professor" VALUES (977, 'DENISE LEZAN DE ALMEIDA');
INSERT INTO "Professor" VALUES (978, 'RICARDO BORGES ALENCAR');
INSERT INTO "Professor" VALUES (979, 'SHEILA MEJLACHOWICZ');
INSERT INTO "Professor" VALUES (980, 'MARIA CECILIA GONSALVES CARVALHO');
INSERT INTO "Professor" VALUES (981, 'FLAVIA DI LUCCIO');
INSERT INTO "Professor" VALUES (982, 'ADRIANA LEITE DO PRADO REBELLO');
INSERT INTO "Professor" VALUES (983, 'ADRIANA F DE S DE ALBUQUERQUE');
INSERT INTO "Professor" VALUES (984, 'MARCO ALEXANDRE DE OLIVEIRA');
INSERT INTO "Professor" VALUES (985, 'REGINA LUCIA MONTEDONIO BORGES');
INSERT INTO "Professor" VALUES (986, 'EDNA CAMPOS PACHECO FERNANDES');
INSERT INTO "Professor" VALUES (987, 'MARCIA OLIVE NOVELLINO');
INSERT INTO "Professor" VALUES (988, 'ALICIA OLGA GRIFO DE RAMAL');
INSERT INTO "Professor" VALUES (989, 'VANISE DE SOUZA QUITETE');
INSERT INTO "Professor" VALUES (990, 'LEILA MATHIAS COSTA');
INSERT INTO "Professor" VALUES (991, 'TALITA DE ASSIS BARRETO');
INSERT INTO "Professor" VALUES (992, 'EUGENIA MARIA PIRES KOELER');
INSERT INTO "Professor" VALUES (993, 'PAULO RICARDO PEREZ CUADRAT');
INSERT INTO "Professor" VALUES (994, 'ANTONIO CARLOS MATTOSO SALGADO');
INSERT INTO "Professor" VALUES (995, 'BEATRIZ CASTRO BARRETO');
INSERT INTO "Professor" VALUES (996, 'INES KAYON DE MILLER');
INSERT INTO "Professor" VALUES (997, 'ADRIANA NOGUEIRA ACCIOLY NOBREGA');
INSERT INTO "Professor" VALUES (998, 'LUIZ CARLOS BARROS DE FREITAS');
INSERT INTO "Professor" VALUES (999, 'CLAUDIA FERNANDA CHIGRES');
INSERT INTO "Professor" VALUES (1000, 'LEANDRO SANTOS ABRANTES');
INSERT INTO "Professor" VALUES (1001, 'MARIA CLAUDIA DE FREITAS');
INSERT INTO "Professor" VALUES (1002, 'CILENE APARECIDA NUNES RODRIGUES');
INSERT INTO "Professor" VALUES (1003, 'HELENA FRANCO MARTINS');
INSERT INTO "Professor" VALUES (1004, 'ERICA DOS SANTOS RODRIGUES');
INSERT INTO "Professor" VALUES (1005, 'MARIA DAS GRACAS DIAS PEREIRA');
INSERT INTO "Professor" VALUES (1006, 'LETICIA MARIA SICURO CORREA');
INSERT INTO "Professor" VALUES (1007, 'LILIANA CABRAL BASTOS');
INSERT INTO "Professor" VALUES (1008, 'HEIDRUN FRIEDEL K O DE OLIVEIRA');
INSERT INTO "Professor" VALUES (1009, 'ELIANA LUCIA MADUREIRA YUNES GARCIA');
INSERT INTO "Professor" VALUES (1010, 'FREDERICO OLIVEIRA COELHO');
INSERT INTO "Professor" VALUES (1011, 'MARIANA CUSTODIO DO NASCIMENTO LAGO');
INSERT INTO "Professor" VALUES (1012, 'JULIO CESAR VALLADAO DINIZ');
INSERT INTO "Professor" VALUES (1013, 'DANIELA GIANNA CLAUDIA B VERSIANI');
INSERT INTO "Professor" VALUES (1014, 'ROSANA KOHL BINES');
INSERT INTO "Professor" VALUES (1015, 'MARILIA ROTHIER CARDOSO');
INSERT INTO "Professor" VALUES (1016, 'ALEXANDRE MONTAURY B COUTINHO');
INSERT INTO "Professor" VALUES (1017, 'SILVIA BEATRIZ ALEXANDRA B COSTA');
INSERT INTO "Professor" VALUES (1018, 'MIRIAM SUTTER MEDEIROS');
INSERT INTO "Professor" VALUES (1019, 'IZABEL MARGATO');
INSERT INTO "Professor" VALUES (1020, 'MARCIA LOBIANCO VICENTE AMORIM');
INSERT INTO "Professor" VALUES (1021, 'JANETE DOS SANTOS BESSA NEVES');
INSERT INTO "Professor" VALUES (1022, 'MARIA LILIA SIMOES DE OLIVEIRA');
INSERT INTO "Professor" VALUES (1023, 'TANIA CONCEICAO PEREIRA');
INSERT INTO "Professor" VALUES (1024, 'PAULO FERNANDO HENRIQUES BRITTO');
INSERT INTO "Professor" VALUES (1025, 'DANIEL ARGOLO ESTILL');
INSERT INTO "Professor" VALUES (1026, 'MARCIA DO AMARAL PEIXOTO MARTINS');
INSERT INTO "Professor" VALUES (1027, 'MARIA PAULA FROTA');
INSERT INTO "Professor" VALUES (1028, 'MARIA DO CARMO LEITE DE OLIVEIRA');
INSERT INTO "Professor" VALUES (1029, 'LUCIA MARIA DA CRUZ FIDALGO');
INSERT INTO "Professor" VALUES (1030, 'STELLA TERESA APONTE CAYMMI');
INSERT INTO "Professor" VALUES (1031, 'KARL ERIK SCHOLLHAMMER');
INSERT INTO "Professor" VALUES (1032, 'LUIS EDUARDO FERREIRA B MOREIRA');
INSERT INTO "Professor" VALUES (1033, 'CARLOS TOMEI');
INSERT INTO "Professor" VALUES (1034, 'RICARDO GALDO CAMELIER');
INSERT INTO "Professor" VALUES (1035, 'SERGIO NOBREGA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (1036, 'FRANCISCO RONDINELLI JUNIOR');
INSERT INTO "Professor" VALUES (1037, 'ELIANA GIAMBIAGI');
INSERT INTO "Professor" VALUES (1038, 'YURI KI');
INSERT INTO "Professor" VALUES (1039, 'MONICA MOREIRA BARROS');
INSERT INTO "Professor" VALUES (1040, 'RAFAEL OSWALDO RUGGIERO RODRIGUEZ');
INSERT INTO "Professor" VALUES (1041, 'MIGUEL ADRIANO KOILLER SCHNOOR');
INSERT INTO "Professor" VALUES (1042, 'VERA SYME JACOB BENZECRY');
INSERT INTO "Professor" VALUES (1043, 'RENATA MARTINS DA ROSA');
INSERT INTO "Professor" VALUES (1044, 'RACHEL BERGMAN FONTE');
INSERT INTO "Professor" VALUES (1045, 'SILVANA MARINI RODRIGUES LOPES');
INSERT INTO "Professor" VALUES (1046, 'LUCIANA ARRUDA DE OLIVEIRA FREIRE');
INSERT INTO "Professor" VALUES (1047, 'SERGIO BERNARDO VOLCHAN');
INSERT INTO "Professor" VALUES (1048, 'CARLOS FREDERICO BORGES PALMEIRA');
INSERT INTO "Professor" VALUES (1049, 'ALEX LUCIO RIBEIRO CASTRO');
INSERT INTO "Professor" VALUES (1050, 'MARCOS CRAIZER');
INSERT INTO "Professor" VALUES (1051, 'CRISTIANE PINHO GUEDES');
INSERT INTO "Professor" VALUES (1052, 'DEBORA FREIRE MONDAINI');
INSERT INTO "Professor" VALUES (1053, 'AMERICO BARBOSA DA CUNHA JUNIOR');
INSERT INTO "Professor" VALUES (1054, 'LUANA SA DE AZEVEDO');
INSERT INTO "Professor" VALUES (1055, 'RICARDO DE SA EARP');
INSERT INTO "Professor" VALUES (1056, 'CHRISTINE SERTA COSTA');
INSERT INTO "Professor" VALUES (1057, 'JAIRO DA SILVA BOCHI');
INSERT INTO "Professor" VALUES (1058, 'ANA CRISTINA BERNARDO DE OLIVEIRA');
INSERT INTO "Professor" VALUES (1059, 'PEDRO PAIVA ZUHLKE D OLIVEIRA');
INSERT INTO "Professor" VALUES (1060, 'NICOLAU CORCAO SALDANHA');
INSERT INTO "Professor" VALUES (1061, 'THOMAS MAURICE LEWINER');
INSERT INTO "Professor" VALUES (1062, 'LUCA SCALA');
INSERT INTO "Professor" VALUES (1063, 'BOYAN SLAVCHEV SIRAKOV');
INSERT INTO "Professor" VALUES (1064, 'DANIELA ROMAO BARBUTO DIAS');
INSERT INTO "Professor" VALUES (1065, 'MONAH WINOGRAD');
INSERT INTO "Professor" VALUES (1066, 'ANA MARIA DE TOLEDO PIZA RUDGE');
INSERT INTO "Professor" VALUES (1067, 'NORMA MOREIRA SALGADO FRANCO');
INSERT INTO "Professor" VALUES (1068, 'REGINA LUCIA LIMA PONTES');
INSERT INTO "Professor" VALUES (1069, 'REGINA LUCIA LEMOS LEITE SARDINHA');
INSERT INTO "Professor" VALUES (1070, 'TATIANA BARBOSA CARVALHO');
INSERT INTO "Professor" VALUES (1071, 'DENISE BERRUEZO PORTINARI');
INSERT INTO "Professor" VALUES (1072, 'ANTONIO CARLOS DE OLIVEIRA');
INSERT INTO "Professor" VALUES (1073, 'AUTERIVES MACIEL JUNIOR');
INSERT INTO "Professor" VALUES (1074, 'ANDREA SEIXAS MAGALHAES');
INSERT INTO "Professor" VALUES (1075, 'ANA MARIA NICOLACI DA COSTA');
INSERT INTO "Professor" VALUES (1076, 'CARLOS AUGUSTO DE O PEIXOTO JR');
INSERT INTO "Professor" VALUES (1077, 'CAROLINA LAMPREIA');
INSERT INTO "Professor" VALUES (1078, 'CLAUDIA AMORIM GARCIA');
INSERT INTO "Professor" VALUES (1079, 'ELIANA DE ANDRADE FREIRE');
INSERT INTO "Professor" VALUES (1080, 'ESTHER MARIA MAGALHAES ARANTES');
INSERT INTO "Professor" VALUES (1081, 'FLAVIA SOLLERO DE CAMPOS');
INSERT INTO "Professor" VALUES (1082, 'JESUS LANDEIRA FERNANDEZ');
INSERT INTO "Professor" VALUES (1083, 'JUNIA DE VILHENA');
INSERT INTO "Professor" VALUES (1084, 'LIDIA LEVY DE ALVARENGA');
INSERT INTO "Professor" VALUES (1085, 'MARCUS ANDRE VIEIRA');
INSERT INTO "Professor" VALUES (1086, 'MARIA INES GARCIA DE F BITTENCOURT');
INSERT INTO "Professor" VALUES (1087, 'SOLANGE JOBIM E SOUZA');
INSERT INTO "Professor" VALUES (1088, 'SILVIA MARIA ABU JAMRA ZORNIG');
INSERT INTO "Professor" VALUES (1089, 'TEREZINHA FERES CARNEIRO');
INSERT INTO "Professor" VALUES (1090, 'TEREZA CRISTINA SALDANHA ERTHAL');
INSERT INTO "Professor" VALUES (1091, 'MARIA ELIZABETH RIBEIRO DOS SANTOS');
INSERT INTO "Professor" VALUES (1092, 'ALVARO DE PINHEIRO GOUVEA');
INSERT INTO "Professor" VALUES (1093, 'CARMEN LUIZA HOZANNA FERREIRA');
INSERT INTO "Professor" VALUES (1094, 'GUILHERME GUTMAN CORREA DE ARAUJO');
INSERT INTO "Professor" VALUES (1095, 'HELENICE CHARCHAT FICHMAN');
INSERT INTO "Professor" VALUES (1096, 'MARIA HELENA RODRIGUES NAVAS ZAMORA');
INSERT INTO "Professor" VALUES (1097, 'ANA MARIA STINGEL');
INSERT INTO "Professor" VALUES (1098, 'SARA ANGELA KISLANOV');
INSERT INTO "Professor" VALUES (1099, 'FERNANDO RIBEIRO TENORIO');
INSERT INTO "Professor" VALUES (1100, 'EVA GERTRUDES JONATHAN');
INSERT INTO "Professor" VALUES (1101, 'RAPHAEL SACCHI ZAREMBA');
INSERT INTO "Professor" VALUES (1102, 'REGINA MARIA MURAT VASCONCELOS');
INSERT INTO "Professor" VALUES (1103, 'SANDRA SALOMAO CARVALHO');
INSERT INTO "Professor" VALUES (1104, 'CARLOS EDUARDO DUARTE A DE BRITO');
INSERT INTO "Professor" VALUES (1105, 'MARACY DOMINGUES ALVES');
INSERT INTO "Professor" VALUES (1106, 'CELIA FERREIRA NOVAES');
INSERT INTO "Professor" VALUES (1107, 'LUIZA DE SOUZA E SILVA MARTINS');
INSERT INTO "Professor" VALUES (1108, 'REGINA SCHOEMER JARDIM');
INSERT INTO "Professor" VALUES (1109, 'MARIANGELA DA SILVA MONTEIRO');
INSERT INTO "Professor" VALUES (1110, 'HELENE DE OLIVEIRA SHINOHARA');
INSERT INTO "Professor" VALUES (1111, 'ADRIANA HADDAD NUDI');
INSERT INTO "Professor" VALUES (1112, 'FATIMA VENTURA PEREIRA MEIRELLES');
INSERT INTO "Professor" VALUES (1113, 'NICOLAS ADRIAN REY');
INSERT INTO "Professor" VALUES (1114, 'JIANG KAI');
INSERT INTO "Professor" VALUES (1115, 'WHEI OH LIN');
INSERT INTO "Professor" VALUES (1116, 'NADIA SUZANA HENRIQUES SCHNEIDER');
INSERT INTO "Professor" VALUES (1117, 'ISABEL MARIA NETO DA SILVA MOREIRA');
INSERT INTO "Professor" VALUES (1118, 'FLAVIA DE ALMEIDA VIEIRA');
INSERT INTO "Professor" VALUES (1119, 'OMAR PANDOLI');
INSERT INTO "Professor" VALUES (1120, 'RICARDO QUEIROZ AUCELIO');
INSERT INTO "Professor" VALUES (1121, 'PERCIO AUGUSTO MARDINI FARIAS');
INSERT INTO "Professor" VALUES (1122, 'ADRIANA GIODA');
INSERT INTO "Professor" VALUES (1123, 'TATIANA DILLENBURG SAINT PIERRE');
INSERT INTO "Professor" VALUES (1124, 'CAMILLA DJENNE BUARQUE MULLER');
INSERT INTO "Professor" VALUES (1125, 'ANDRE SILVA PIMENTEL');
INSERT INTO "Professor" VALUES (1126, 'JHONNY OSWALDO HUERTAS FLORES');
INSERT INTO "Professor" VALUES (1127, 'ANGELA DE LUCA REBELLO WAGENER');
INSERT INTO "Professor" VALUES (1128, 'SUELI BULHOES DA SILVA');
INSERT INTO "Professor" VALUES (1129, 'MARIA LUIZA CAMPOS DA SILVA VALENTE');
INSERT INTO "Professor" VALUES (1130, 'ELIZA REGINA AMBROSIO');
INSERT INTO "Professor" VALUES (1131, 'MARIA HELENA DE SOUZA TAVARES');
INSERT INTO "Professor" VALUES (1132, 'MARCIO EDUARDO BROTTO');
INSERT INTO "Professor" VALUES (1133, 'VALERIA PEREIRA BASTOS');
INSERT INTO "Professor" VALUES (1134, 'MARIA ELIZABETH FREIRE SALVADOR');
INSERT INTO "Professor" VALUES (1135, 'LUCIENE ALCINDA DE MEDEIROS');
INSERT INTO "Professor" VALUES (1136, 'JUSSARA FRANCISCA DE ASSIS');
INSERT INTO "Professor" VALUES (1137, 'LUIZA HELENA NUNES ERMEL');
INSERT INTO "Professor" VALUES (1138, 'ANDREIA CLAPP SALVADOR');
INSERT INTO "Professor" VALUES (1139, 'MARCELO LUCIANO VIEIRA');
INSERT INTO "Professor" VALUES (1140, 'INEZ TEREZINHA STAMPA');
INSERT INTO "Professor" VALUES (1141, 'RAFAEL SOARES GONCALVES');
INSERT INTO "Professor" VALUES (1142, 'CARLA FERREIRA SOARES');
INSERT INTO "Professor" VALUES (1143, 'JOSE MAURO DE FREITAS JUNIOR');
INSERT INTO "Professor" VALUES (1144, 'FERNANDO CARDOSO LIMA NETO');
INSERT INTO "Professor" VALUES (1145, 'LUIZ FERNANDO ALMEIDA PEREIRA');
INSERT INTO "Professor" VALUES (1146, 'SAMARA LIMA TAVARES MANCEBO');
INSERT INTO "Professor" VALUES (1147, 'PAULO RENATO FLORES DURAN');
INSERT INTO "Professor" VALUES (1148, 'ROSI MARQUES MACHADO');
INSERT INTO "Professor" VALUES (1149, 'MARCELO TADEU BAUMANN BURGOS');
INSERT INTO "Professor" VALUES (1150, 'MARIA ALICE REZENDE DE CARVALHO');
INSERT INTO "Professor" VALUES (1151, 'ANGELA MARIA DE RANDOLPHO PAIVA');
INSERT INTO "Professor" VALUES (1152, 'SOLANGE MARIA LUCAN DE OLIVEIRA');
INSERT INTO "Professor" VALUES (1153, 'ALESSANDRA MAIA TERRA DE FARIA');
INSERT INTO "Professor" VALUES (1154, 'EDUARDO VASCONCELOS RAPOSO');
INSERT INTO "Professor" VALUES (1155, 'MARIA CELINA SOARES D ARAUJO');
INSERT INTO "Professor" VALUES (1156, 'BRUNO DE MOURA BORGES');
INSERT INTO "Professor" VALUES (1157, 'ANA PAULA CONDE GOMES');
INSERT INTO "Professor" VALUES (1158, 'ANA FERNANDA BATISTA COELHO ALVES');
INSERT INTO "Professor" VALUES (1159, 'JOAO ROBERTO LOPES PINTO');
INSERT INTO "Professor" VALUES (1160, 'CARLOS EDUARDO REBELLO DE MENDONCA');
INSERT INTO "Professor" VALUES (1161, 'ANTONIO CARLOS ALKMIM DOS REIS');
INSERT INTO "Professor" VALUES (1162, 'RICARDO EMMANUEL ISMAEL DE CARVALHO');
INSERT INTO "Professor" VALUES (1163, 'LUIZA FERREIRA DE SOUZA LEITE');
INSERT INTO "Professor" VALUES (1164, 'MARCELLO SORRENTINO');
INSERT INTO "Professor" VALUES (1165, 'BERNARDO VELLOSO FERNANDEZ CONDE');
INSERT INTO "Professor" VALUES (1166, 'TATIANA BRAGA BACAL');
INSERT INTO "Professor" VALUES (1167, 'SONIA DUARTE TRAVASSOS');
INSERT INTO "Professor" VALUES (1168, 'PATRICIA BAPTISTA CORALIS');
INSERT INTO "Professor" VALUES (1169, 'VALTER SINDER');
INSERT INTO "Professor" VALUES (1170, 'PAULO JORGE DA SILVA RIBEIRO');
INSERT INTO "Professor" VALUES (1171, 'SONIA MARIA GIACOMINI');
INSERT INTO "Professor" VALUES (1172, 'PAULO CESAR GREENHALGH DE C LIMA');
INSERT INTO "Professor" VALUES (1173, 'LUIZ JORGE WERNECK VIANNA');
INSERT INTO "Professor" VALUES (1174, 'SIMONE DUBEUX BERARDO C DA CUNHA');
INSERT INTO "Professor" VALUES (1175, 'PAULO CEZAR COSTA');
INSERT INTO "Professor" VALUES (1176, 'MARIA CLARA LUCCHETTI BINGEMER');
INSERT INTO "Professor" VALUES (1177, 'LUIZ FERNANDO RIBEIRO SANTANA');
INSERT INTO "Professor" VALUES (1178, 'ANA MARIA DE AZEREDO LOPES TEPEDINO');
INSERT INTO "Professor" VALUES (1179, 'ABIMAR OLIVEIRA DE MORAES');
INSERT INTO "Professor" VALUES (1180, 'ISIDORO MAZZAROLO');
INSERT INTO "Professor" VALUES (1181, 'JOEL PORTELLA AMADO');
INSERT INTO "Professor" VALUES (1182, 'LEONARDO AGOSTINI FERNANDES');
INSERT INTO "Professor" VALUES (1183, 'LUCIA PEDROSA DE PADUA');
INSERT INTO "Professor" VALUES (1184, 'LUIS CORREA LIMA');
INSERT INTO "Professor" VALUES (1185, 'MARIA DE LOURDES CORREA LIMA');
INSERT INTO "Professor" VALUES (1186, 'TEREZA MARIA POMPEIA CAVALCANTI');
INSERT INTO "Professor" VALUES (1187, 'MARIO DE FRANCA MIRANDA');
INSERT INTO "Professor" VALUES (1188, 'ANTONIO JOSE AFONSO DA COSTA');
INSERT INTO "Professor" VALUES (1189, 'ALFREDO SAMPAIO COSTA');
INSERT INTO "Professor" VALUES (1190, 'JOSE OTACIO OLIVEIRA GUEDES');
INSERT INTO "Professor" VALUES (1191, 'PAULO FERNANDO CARNEIRO DE ANDRADE');
INSERT INTO "Professor" VALUES (1192, 'ALFONSO GARCIA RUBIO');
INSERT INTO "Professor" VALUES (1193, 'JESUS HORTAL SANCHEZ');
INSERT INTO "Professor" VALUES (1194, 'MARIO LUIZ MENEZES GONCALVES');
INSERT INTO "Professor" VALUES (1195, 'MARIA TERESA DE FREITAS CARDOSO');


--
-- TOC entry 2043 (class 0 OID 35708)
-- Dependencies: 163 2060
-- Data for Name: TipoUsuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "TipoUsuario" VALUES (1, 'Administrador');
INSERT INTO "TipoUsuario" VALUES (2, 'Coordenador');
INSERT INTO "TipoUsuario" VALUES (3, 'Aluno');


--
-- TOC entry 2052 (class 0 OID 35986)
-- Dependencies: 176 2060
-- Data for Name: Turma; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2054 (class 0 OID 36018)
-- Dependencies: 178 2060
-- Data for Name: TurmaHorario; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2041 (class 0 OID 35689)
-- Dependencies: 161 2060
-- Data for Name: Usuario; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2047 (class 0 OID 35879)
-- Dependencies: 170 2060
-- Data for Name: VariavelAmbiente; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "VariavelAmbiente" VALUES ('manutencao', false, 'Desculpe. O sistema encontra-se em manutenção. Por favor, tente mais tarde. Obrigado.');


--
-- TOC entry 1974 (class 2606 OID 35861)
-- Dependencies: 162 162 2061
-- Name: PK_Aluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "PK_Aluno" PRIMARY KEY ("FK_Matricula");


--
-- TOC entry 1991 (class 2606 OID 35906)
-- Dependencies: 172 172 172 2061
-- Name: PK_AlunoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "PK_AlunoDisciplina" PRIMARY KEY ("FK_Aluno", "FK_Disciplina");


--
-- TOC entry 1993 (class 2606 OID 35921)
-- Dependencies: 173 173 2061
-- Name: PK_AlunoDisciplinaStatus; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "PK_AlunoDisciplinaStatus" PRIMARY KEY ("PK_Status");


--
-- TOC entry 2004 (class 2606 OID 36005)
-- Dependencies: 177 177 177 2061
-- Name: PK_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "PK_AlunoTurmaSelecionada" PRIMARY KEY ("FK_Aluno", "FK_Turma");


--
-- TOC entry 2018 (class 2606 OID 36146)
-- Dependencies: 185 185 2061
-- Name: PK_Curso; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Curso"
    ADD CONSTRAINT "PK_Curso" PRIMARY KEY ("PK_Curso");


--
-- TOC entry 1989 (class 2606 OID 35900)
-- Dependencies: 171 171 2061
-- Name: PK_Disciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Disciplina"
    ADD CONSTRAINT "PK_Disciplina" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 1982 (class 2606 OID 35767)
-- Dependencies: 165 165 2061
-- Name: PK_Log; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "PK_Log" PRIMARY KEY ("PK_Log");


--
-- TOC entry 1997 (class 2606 OID 35943)
-- Dependencies: 174 174 2061
-- Name: PK_Optativa; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Optativa"
    ADD CONSTRAINT "PK_Optativa" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2010 (class 2606 OID 36047)
-- Dependencies: 179 179 179 2061
-- Name: PK_OptativaAluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "PK_OptativaAluno" PRIMARY KEY ("FK_Optativa", "FK_Aluno");


--
-- TOC entry 2012 (class 2606 OID 36062)
-- Dependencies: 180 180 180 2061
-- Name: PK_OptativaDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "PK_OptativaDisciplina" PRIMARY KEY ("FK_Optativa", "FK_Disciplina");


--
-- TOC entry 2014 (class 2606 OID 36081)
-- Dependencies: 182 182 2061
-- Name: PK_PreRequisitoGrupo; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "PK_PreRequisitoGrupo" PRIMARY KEY ("PK_PreRequisitoGrupo");


--
-- TOC entry 2016 (class 2606 OID 36086)
-- Dependencies: 183 183 183 2061
-- Name: PK_PreRequisitoGrupoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "PK_PreRequisitoGrupoDisciplina" PRIMARY KEY ("FK_PreRequisitoGrupo", "FK_Disciplina");


--
-- TOC entry 1984 (class 2606 OID 35822)
-- Dependencies: 167 167 2061
-- Name: PK_Professor; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Professor"
    ADD CONSTRAINT "PK_Professor" PRIMARY KEY ("PK_Professor");


--
-- TOC entry 1980 (class 2606 OID 35725)
-- Dependencies: 164 164 2061
-- Name: PK_Sugestao; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "PK_Sugestao" PRIMARY KEY ("PK_Sugestao");


--
-- TOC entry 1976 (class 2606 OID 35712)
-- Dependencies: 163 163 2061
-- Name: PK_TipoUsuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "PK_TipoUsuario" PRIMARY KEY ("PK_TipoUsuario");


--
-- TOC entry 2001 (class 2606 OID 35994)
-- Dependencies: 176 176 2061
-- Name: PK_Turma; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma" PRIMARY KEY ("PK_Turma");


--
-- TOC entry 2008 (class 2606 OID 36032)
-- Dependencies: 178 178 178 178 178 2061
-- Name: PK_TurmaHorario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "PK_TurmaHorario" PRIMARY KEY ("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal");


--
-- TOC entry 1971 (class 2606 OID 35727)
-- Dependencies: 161 161 2061
-- Name: PK_Usuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "PK_Usuario" PRIMARY KEY ("PK_Login");


--
-- TOC entry 1987 (class 2606 OID 35887)
-- Dependencies: 170 170 2061
-- Name: PK_VariavelAmbiente; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "VariavelAmbiente"
    ADD CONSTRAINT "PK_VariavelAmbiente" PRIMARY KEY ("PK_Variavel");


--
-- TOC entry 1995 (class 2606 OID 35923)
-- Dependencies: 173 173 2061
-- Name: Unique_AlunoDisciplinaStatus_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "Unique_AlunoDisciplinaStatus_Nome" UNIQUE ("Nome");


--
-- TOC entry 2006 (class 2606 OID 36007)
-- Dependencies: 177 177 177 177 177 2061
-- Name: Unique_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "Unique_AlunoTurmaSelecionada" UNIQUE ("FK_Aluno", "FK_Turma", "Opcao", "NoLinha");


--
-- TOC entry 2020 (class 2606 OID 36148)
-- Dependencies: 185 185 2061
-- Name: Unique_Curso_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Curso"
    ADD CONSTRAINT "Unique_Curso_Nome" UNIQUE ("Nome");


--
-- TOC entry 1999 (class 2606 OID 35945)
-- Dependencies: 174 174 2061
-- Name: Unique_Optativa_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Optativa"
    ADD CONSTRAINT "Unique_Optativa_Nome" UNIQUE ("Nome");


--
-- TOC entry 1978 (class 2606 OID 35807)
-- Dependencies: 163 163 2061
-- Name: Unique_TipoUsuario_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "Unique_TipoUsuario_Nome" UNIQUE ("Nome");


--
-- TOC entry 1985 (class 1259 OID 36200)
-- Dependencies: 167 2061
-- Name: Professor_Nome_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Professor_Nome_Index" ON "Professor" USING btree ("Nome");


--
-- TOC entry 2002 (class 1259 OID 36205)
-- Dependencies: 176 176 176 2061
-- Name: Turma_Disciplina_Codigo_Periodo_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Turma_Disciplina_Codigo_Periodo_Index" ON "Turma" USING btree ("FK_Disciplina", "Codigo", "PeriodoAno");


--
-- TOC entry 1972 (class 1259 OID 36176)
-- Dependencies: 161 2061
-- Name: Usuario_HashSession_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Usuario_HashSession_Index" ON "Usuario" USING btree ("HashSessao");


--
-- TOC entry 1950 (class 2618 OID 36173)
-- Dependencies: 171 171 171 171 171 171 2061
-- Name: DisciplinaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "DisciplinaDuplicada" AS ON INSERT TO "Disciplina" WHERE (EXISTS (SELECT 1 FROM "Disciplina" d WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text))) DO INSTEAD UPDATE "Disciplina" d SET "Nome" = new."Nome", "Creditos" = new."Creditos" WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text);


--
-- TOC entry 1951 (class 2618 OID 36179)
-- Dependencies: 167 167 167 167 2061
-- Name: ProfessorDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "ProfessorDuplicado" AS ON INSERT TO "Professor" WHERE (EXISTS (SELECT 1 FROM "Professor" d WHERE ((d."Nome")::text = (new."Nome")::text))) DO INSTEAD NOTHING;


--
-- TOC entry 1952 (class 2618 OID 36221)
-- Dependencies: 176 176 176 176 176 176 176 176 176 176 176 176 176 2061
-- Name: TurmaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaDuplicada" AS ON INSERT TO "Turma" WHERE (EXISTS (SELECT 1 FROM "Turma" t WHERE ((((t."FK_Disciplina")::text = (new."FK_Disciplina")::text) AND ((t."Codigo")::text = (new."Codigo")::text)) AND (t."PeriodoAno" = new."PeriodoAno")))) DO INSTEAD UPDATE "Turma" t SET "Vagas" = new."Vagas", "Destino" = new."Destino", "HorasDistancia" = new."HorasDistancia", "SHF" = new."SHF", "FK_Professor" = new."FK_Professor" WHERE ((((t."FK_Disciplina")::text = (new."FK_Disciplina")::text) AND ((t."Codigo")::text = (new."Codigo")::text)) AND (t."PeriodoAno" = new."PeriodoAno"));


--
-- TOC entry 1954 (class 2618 OID 36235)
-- Dependencies: 178 178 178 178 178 178 178 2061
-- Name: TurmaHorarioDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaHorarioDuplicado" AS ON INSERT TO "TurmaHorario" WHERE (EXISTS (SELECT 1 FROM "TurmaHorario" th WHERE ((((th."FK_Turma" = new."FK_Turma") AND (th."DiaSemana" = new."DiaSemana")) AND (th."HoraInicial" = new."HoraInicial")) AND (th."HoraFinal" = new."HoraFinal")))) DO INSTEAD NOTHING;


--
-- TOC entry 2026 (class 2606 OID 35924)
-- Dependencies: 162 172 1973 2061
-- Name: FK_AlunoDisciplina_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2028 (class 2606 OID 35934)
-- Dependencies: 1992 173 172 2061
-- Name: FK_AlunoDisciplina_AlunoDisciplinaStatus; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_AlunoDisciplinaStatus" FOREIGN KEY ("FK_Status") REFERENCES "AlunoDisciplinaStatus"("PK_Status") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2027 (class 2606 OID 35929)
-- Dependencies: 1988 171 172 2061
-- Name: FK_AlunoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2031 (class 2606 OID 36008)
-- Dependencies: 1973 162 177 2061
-- Name: FK_AlunoTurmaSelecionada_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2032 (class 2606 OID 36013)
-- Dependencies: 2000 176 177 2061
-- Name: FK_AlunoTurmaSelecionada_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2023 (class 2606 OID 36154)
-- Dependencies: 2017 185 162 2061
-- Name: FK_Aluno_Curso; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Curso" FOREIGN KEY ("FK_Curso") REFERENCES "Curso"("PK_Curso") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2022 (class 2606 OID 36149)
-- Dependencies: 161 1970 162 2061
-- Name: FK_Aluno_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Usuario" FOREIGN KEY ("FK_Matricula") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2025 (class 2606 OID 36132)
-- Dependencies: 161 1970 165 2061
-- Name: FK_Log_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "FK_Log_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2035 (class 2606 OID 36053)
-- Dependencies: 179 162 1973 2061
-- Name: FK_OptativaAluno_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2034 (class 2606 OID 36048)
-- Dependencies: 174 1996 179 2061
-- Name: FK_OptativaAluno_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2037 (class 2606 OID 36068)
-- Dependencies: 180 1988 171 2061
-- Name: FK_OptativaDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2036 (class 2606 OID 36063)
-- Dependencies: 1996 180 174 2061
-- Name: FK_OptativaDisciplina_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2040 (class 2606 OID 36092)
-- Dependencies: 1988 183 171 2061
-- Name: FK_PreRequisitoGrupoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2039 (class 2606 OID 36087)
-- Dependencies: 182 183 2013 2061
-- Name: FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo" FOREIGN KEY ("FK_PreRequisitoGrupo") REFERENCES "PreRequisitoGrupo"("PK_PreRequisitoGrupo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2038 (class 2606 OID 36097)
-- Dependencies: 182 171 1988 2061
-- Name: FK_PreRequisitoGrupo_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "FK_PreRequisitoGrupo_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2024 (class 2606 OID 35888)
-- Dependencies: 164 1970 161 2061
-- Name: FK_Sugestao_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "FK_Sugestao_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2033 (class 2606 OID 36168)
-- Dependencies: 176 178 2000 2061
-- Name: FK_TurmaHorario_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "FK_TurmaHorario_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2029 (class 2606 OID 36211)
-- Dependencies: 1983 167 176 2061
-- Name: FK_Turma_Professor; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "FK_Turma_Professor" FOREIGN KEY ("FK_Professor") REFERENCES "Professor"("PK_Professor") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2021 (class 2606 OID 35971)
-- Dependencies: 163 161 1975 2061
-- Name: FK_Usuario_TipoUsuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "FK_Usuario_TipoUsuario" FOREIGN KEY ("FK_TipoUsuario") REFERENCES "TipoUsuario"("PK_TipoUsuario") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2030 (class 2606 OID 36216)
-- Dependencies: 176 1988 171 2061
-- Name: PK_Turma_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2012-12-01 21:44:40 BRST

--
-- PostgreSQL database dump complete
--

