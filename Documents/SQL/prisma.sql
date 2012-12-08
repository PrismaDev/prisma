--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.5
-- Dumped by pg_dump version 9.1.5
-- Started on 2012-12-08 14:45:01 BRST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 193 (class 3079 OID 11646)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2102 (class 0 OID 0)
-- Dependencies: 193
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 209 (class 1255 OID 44488)
-- Dependencies: 6
-- Name: AlunoCreditosCursados(character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoCreditosCursados"(character varying) RETURNS integer
    LANGUAGE sql
    AS $_$
	SELECT COALESCE(SUM(d."Creditos"),0)::integer
	FROM "AlunoDisciplina" ad
		INNER JOIN "Disciplina" d
			ON(ad."FK_Disciplina" = d."PK_Codigo")
	WHERE ad."FK_Aluno" =  $1 AND "FK_Status" = 'CP'
$_$;


ALTER FUNCTION public."AlunoCreditosCursados"(character varying) OWNER TO prisma;

--
-- TOC entry 207 (class 1255 OID 36374)
-- Dependencies: 6
-- Name: AlunoDisciplinaApto(character varying, character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoDisciplinaApto"(character varying, character varying) RETURNS integer
    LANGUAGE sql
    AS $_$
	SELECT 	CASE
			WHEN "DisciplinaTemPreRequisito"($2) = FALSE THEN 2
			ELSE
			(
				SELECT MAX(aprga."Apto")
				FROM "PreRequisitoGrupo" prg
					INNER JOIN "AlunoPreRequisitoGrupoDisciplinaApto" aprga
						ON prg."PK_PreRequisitoGrupo" = aprga."FK_PreRequisitoGrupo"
				WHERE prg."FK_Disciplina" = $2 AND aprga."FK_Aluno" = $1
			)
		END
$_$;


ALTER FUNCTION public."AlunoDisciplinaApto"(character varying, character varying) OWNER TO prisma;

--
-- TOC entry 211 (class 1255 OID 36372)
-- Dependencies: 6
-- Name: AlunoDisciplinaApto_Old(character varying, character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoDisciplinaApto_Old"(character varying, character varying) RETURNS boolean
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
				ON ad."FK_Aluno" = a."FK_Matricula" AND prgd."FK_Disciplina" = ad."FK_Disciplina" AND ad."FK_Status" <> 'NC'
				WHERE 	prgd."FK_PreRequisitoGrupo" = prg."PK_PreRequisitoGrupo" AND
					ad."FK_Disciplina" IS NULL
			) = 0
	)
$_$;


ALTER FUNCTION public."AlunoDisciplinaApto_Old"(character varying, character varying) OWNER TO prisma;

--
-- TOC entry 206 (class 1255 OID 36334)
-- Dependencies: 6
-- Name: AlunoDisciplinaSituacao(character varying, character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoDisciplinaSituacao"(character varying, character varying) RETURNS character varying
    LANGUAGE sql
    AS $_$
	SELECT COALESCE
	(
		(SELECT "FK_Status" FROM "AlunoDisciplina" WHERE "FK_Aluno" = $1 AND "FK_Disciplina" = $2),
		'NC'
	)
$_$;


ALTER FUNCTION public."AlunoDisciplinaSituacao"(character varying, character varying) OWNER TO prisma;

--
-- TOC entry 212 (class 1255 OID 36120)
-- Dependencies: 6
-- Name: AlunoOptativaCursada(character varying, character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoOptativaCursada"(character varying, character varying) RETURNS boolean
    LANGUAGE sql
    AS $$
	SELECT EXISTS
	(
		SELECT 1 FROM "OptativaAluno" oa, "Optativa" o, "OptativaDisciplina" od, "AlunoDisciplina" ad
		WHERE 	oa."FK_Aluno" = '0911409' AND
			o."PK_Codigo" = 'FIL0300' AND
			oa."FK_Optativa" = o."PK_Codigo" AND
			oa."FK_Aluno" = ad."FK_Aluno" AND
			o."PK_Codigo" = od."FK_Optativa" AND
			ad."FK_Disciplina" = od."FK_Disciplina" AND
			ad."FK_Status" = 'CP'
	)
$$;


ALTER FUNCTION public."AlunoOptativaCursada"(character varying, character varying) OWNER TO prisma;

--
-- TOC entry 208 (class 1255 OID 44461)
-- Dependencies: 6
-- Name: DisciplinaDaTurma(bigint); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "DisciplinaDaTurma"(bigint) RETURNS character varying
    LANGUAGE sql
    AS $_$
	SELECT "FK_Disciplina"
	FROM "Turma"
	WHERE "PK_Turma" = $1
$_$;


ALTER FUNCTION public."DisciplinaDaTurma"(bigint) OWNER TO prisma;

--
-- TOC entry 205 (class 1255 OID 36121)
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
-- TOC entry 210 (class 1255 OID 36124)
-- Dependencies: 6
-- Name: LimpaBanco(); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "LimpaBanco"() RETURNS void
    LANGUAGE sql
    AS $$
	DELETE FROM "Usuario";
	DELETE FROM "Professor";
	DELETE FROM "Disciplina";
	DELETE FROM "Optativa";
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
    "FK_Matricula" character varying(20) NOT NULL,
    "CoeficienteRendimento" real,
    "FK_Curso" character varying(3) NOT NULL
);


ALTER TABLE public."Aluno" OWNER TO prisma;

--
-- TOC entry 172 (class 1259 OID 35901)
-- Dependencies: 1998 1999 6
-- Name: AlunoDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "AlunoDisciplina" (
    "FK_Aluno" character varying(20) NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL,
    "FK_Status" character varying(2),
    "Tentativas" integer DEFAULT 0,
    "Periodo" integer DEFAULT 1 NOT NULL,
    "FK_TipoDisciplina" character varying(2) NOT NULL
);


ALTER TABLE public."AlunoDisciplina" OWNER TO prisma;

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
-- TOC entry 186 (class 1259 OID 36350)
-- Dependencies: 1982 6
-- Name: AlunoPreRequisitoGrupoDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "AlunoPreRequisitoGrupoDisciplina" AS
    SELECT a."FK_Matricula" AS "FK_Aluno", prgd."FK_PreRequisitoGrupo", prgd."FK_Disciplina", "AlunoDisciplinaSituacao"(a."FK_Matricula", prgd."FK_Disciplina") AS "Situacao" FROM "PreRequisitoGrupoDisciplina" prgd, "Aluno" a;


ALTER TABLE public."AlunoPreRequisitoGrupoDisciplina" OWNER TO prisma;

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
-- TOC entry 2103 (class 0 OID 0)
-- Dependencies: 181
-- Name: seq_prerequisito; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_prerequisito', 5647, true);


--
-- TOC entry 182 (class 1259 OID 36075)
-- Dependencies: 2005 2006 6
-- Name: PreRequisitoGrupo; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "PreRequisitoGrupo" (
    "PK_PreRequisitoGrupo" bigint DEFAULT nextval('seq_prerequisito'::regclass) NOT NULL,
    "CreditosMinimos" integer DEFAULT 0 NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."PreRequisitoGrupo" OWNER TO prisma;

--
-- TOC entry 188 (class 1259 OID 36418)
-- Dependencies: 1984 6
-- Name: AlunoPreRequisitoGrupoDisciplinaApto; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "AlunoPreRequisitoGrupoDisciplinaApto" AS
    SELECT a."FK_Matricula" AS "FK_Aluno", prg."PK_PreRequisitoGrupo" AS "FK_PreRequisitoGrupo", CASE WHEN ("AlunoCreditosCursados"(a."FK_Matricula") < prg."CreditosMinimos") THEN 0 WHEN (EXISTS (SELECT 1 FROM "AlunoPreRequisitoGrupoDisciplina" aprgd1 WHERE ((((aprgd1."FK_Aluno")::text = (a."FK_Matricula")::text) AND (aprgd1."FK_PreRequisitoGrupo" = prg."PK_PreRequisitoGrupo")) AND ((aprgd1."Situacao")::text = 'NC'::text)))) THEN 0 WHEN (EXISTS (SELECT 1 FROM "AlunoPreRequisitoGrupoDisciplina" aprgd1 WHERE ((((aprgd1."FK_Aluno")::text = (a."FK_Matricula")::text) AND (aprgd1."FK_PreRequisitoGrupo" = prg."PK_PreRequisitoGrupo")) AND ((aprgd1."Situacao")::text = 'EA'::text)))) THEN 1 ELSE 2 END AS "Apto" FROM "Aluno" a, "PreRequisitoGrupo" prg;


ALTER TABLE public."AlunoPreRequisitoGrupoDisciplinaApto" OWNER TO prisma;

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
-- TOC entry 2104 (class 0 OID 0)
-- Dependencies: 169
-- Name: seq_sugestao; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_sugestao', 1, false);


--
-- TOC entry 164 (class 1259 OID 35718)
-- Dependencies: 1991 1992 6
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
-- TOC entry 184 (class 1259 OID 36142)
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
    "Creditos" integer NOT NULL
);


ALTER TABLE public."Disciplina" OWNER TO prisma;

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
-- Dependencies: 2004 6
-- Name: OptativaAluno; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "OptativaAluno" (
    "FK_Optativa" character varying(7) NOT NULL,
    "FK_Aluno" character varying(20) NOT NULL,
    "PeriodoSugerido" integer DEFAULT 1 NOT NULL
);


ALTER TABLE public."OptativaAluno" OWNER TO prisma;

--
-- TOC entry 185 (class 1259 OID 36301)
-- Dependencies: 1980 6
-- Name: FaltaCursarOptativa; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "FaltaCursarOptativa" AS
    SELECT oa."FK_Aluno" AS "Aluno", o."PK_Codigo" AS "CodigoOptativa", o."Nome" AS "NomeOptativa", oa."PeriodoSugerido" FROM ("Optativa" o JOIN "OptativaAluno" oa ON (((o."PK_Codigo")::text = (oa."FK_Optativa")::text))) WHERE (NOT "AlunoOptativaCursada"(oa."FK_Aluno", o."PK_Codigo"));


ALTER TABLE public."FaltaCursarOptativa" OWNER TO prisma;

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
-- TOC entry 187 (class 1259 OID 36375)
-- Dependencies: 1983 6
-- Name: FaltaCursarOptativaDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "FaltaCursarOptativaDisciplina" AS
    SELECT ad."FK_Aluno" AS "Aluno", od."FK_Optativa" AS "CodigoOptativa", od."FK_Disciplina" AS "CodigoDisciplina", ad."FK_Status" AS "Situacao", "AlunoDisciplinaApto"(ad."FK_Aluno", od."FK_Disciplina") AS "Apto" FROM ("OptativaDisciplina" od JOIN "AlunoDisciplina" ad ON ((((ad."FK_Disciplina")::text = (od."FK_Disciplina")::text) AND ((ad."FK_Status")::text <> 'CP'::text))));


ALTER TABLE public."FaltaCursarOptativaDisciplina" OWNER TO prisma;

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
-- TOC entry 2105 (class 0 OID 0)
-- Dependencies: 166
-- Name: seq_log; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_log', 1, true);


--
-- TOC entry 165 (class 1259 OID 35758)
-- Dependencies: 1993 1994 1995 6
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
-- TOC entry 2106 (class 0 OID 0)
-- Dependencies: 168
-- Name: seq_professor; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_professor', 2345, true);


--
-- TOC entry 167 (class 1259 OID 35818)
-- Dependencies: 1996 6
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
-- TOC entry 2107 (class 0 OID 0)
-- Dependencies: 175
-- Name: seq_turma; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_turma', 3095, true);


--
-- TOC entry 176 (class 1259 OID 35986)
-- Dependencies: 2000 2001 2002 2003 6
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
-- TOC entry 191 (class 1259 OID 44455)
-- Dependencies: 1987 6
-- Name: MicroHorario; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "MicroHorario" AS
    SELECT d."PK_Codigo" AS "CodigoDisciplina", d."Nome" AS "NomeDisciplina", d."Creditos", t."PK_Turma", t."Codigo" AS "CodigoTurma", t."PeriodoAno", t."Vagas", t."Destino", t."HorasDistancia", t."SHF", p."Nome" AS "NomeProfessor", th."DiaSemana", th."HoraInicial", th."HoraFinal" FROM ((("Disciplina" d JOIN "Turma" t ON (((t."FK_Disciplina")::text = (d."PK_Codigo")::text))) JOIN "Professor" p ON ((t."FK_Professor" = p."PK_Professor"))) JOIN "TurmaHorario" th ON ((th."FK_Turma" = t."PK_Turma")));


ALTER TABLE public."MicroHorario" OWNER TO prisma;

--
-- TOC entry 189 (class 1259 OID 36432)
-- Dependencies: 1985 6
-- Name: MicroHorarioDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "MicroHorarioDisciplina" AS
    SELECT a."FK_Matricula" AS "Aluno", d."PK_Codigo" AS "CodigoDisciplina", d."Nome" AS "NomeDisciplina", d."Creditos", "AlunoDisciplinaSituacao"(a."FK_Matricula", d."PK_Codigo") AS "Situacao", "AlunoDisciplinaApto"(a."FK_Matricula", d."PK_Codigo") AS "Apto" FROM "Disciplina" d, "Aluno" a;


ALTER TABLE public."MicroHorarioDisciplina" OWNER TO prisma;

--
-- TOC entry 192 (class 1259 OID 44535)
-- Dependencies: 6
-- Name: TipoDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TipoDisciplina" (
    "PK_Codigo" character varying(2) NOT NULL,
    "Nome" character varying(50)
);


ALTER TABLE public."TipoDisciplina" OWNER TO prisma;

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
-- TOC entry 190 (class 1259 OID 36440)
-- Dependencies: 1986 6
-- Name: TurmaProfessor; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "TurmaProfessor" AS
    SELECT t."PK_Turma", t."Codigo" AS "CodigoTurma", t."FK_Disciplina" AS "CodigoDisciplina", t."PeriodoAno", t."Vagas", t."Destino", t."HorasDistancia", t."SHF", p."Nome" AS "NomeProfessor" FROM ("Turma" t JOIN "Professor" p ON ((t."FK_Professor" = p."PK_Professor")));


ALTER TABLE public."TurmaProfessor" OWNER TO prisma;

--
-- TOC entry 161 (class 1259 OID 35689)
-- Dependencies: 1990 6
-- Name: Usuario; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Usuario" (
    "PK_Login" character varying(20) NOT NULL,
    "Senha" character varying(40),
    "Nome" character varying(100),
    "HashSessao" character varying(40),
    "TermoAceito" boolean DEFAULT false NOT NULL,
    "FK_TipoUsuario" integer NOT NULL,
    "UltimoAcesso" timestamp with time zone
);


ALTER TABLE public."Usuario" OWNER TO prisma;

--
-- TOC entry 170 (class 1259 OID 35879)
-- Dependencies: 1997 6
-- Name: VariavelAmbiente; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "VariavelAmbiente" (
    "PK_Variavel" character varying(30) NOT NULL,
    "Habilitada" boolean DEFAULT true NOT NULL,
    "Descricao" text
);


ALTER TABLE public."VariavelAmbiente" OWNER TO prisma;

--
-- TOC entry 2078 (class 0 OID 35695)
-- Dependencies: 162 2097
-- Data for Name: Aluno; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Aluno" ("FK_Matricula", "CoeficienteRendimento", "FK_Curso") FROM stdin;
\.


--
-- TOC entry 2085 (class 0 OID 35901)
-- Dependencies: 172 2097
-- Data for Name: AlunoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoDisciplina" ("FK_Aluno", "FK_Disciplina", "FK_Status", "Tentativas", "Periodo", "FK_TipoDisciplina") FROM stdin;
\.


--
-- TOC entry 2086 (class 0 OID 35917)
-- Dependencies: 173 2097
-- Data for Name: AlunoDisciplinaStatus; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoDisciplinaStatus" ("PK_Status", "Nome") FROM stdin;
CP	Cumpriu
EA	Em andamento
NC	Não cumpriu
\.


--
-- TOC entry 2089 (class 0 OID 36001)
-- Dependencies: 177 2097
-- Data for Name: AlunoTurmaSelecionada; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoTurmaSelecionada" ("FK_Aluno", "FK_Turma", "Opcao", "NoLinha") FROM stdin;
\.


--
-- TOC entry 2080 (class 0 OID 35718)
-- Dependencies: 164 2097
-- Data for Name: Comentario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Comentario" ("PK_Sugestao", "FK_Usuario", "Comentario", "DataHora") FROM stdin;
\.


--
-- TOC entry 2095 (class 0 OID 36142)
-- Dependencies: 184 2097
-- Data for Name: Curso; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Curso" ("PK_Curso", "Nome") FROM stdin;
\.


--
-- TOC entry 2084 (class 0 OID 35893)
-- Dependencies: 171 2097
-- Data for Name: Disciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Disciplina" ("PK_Codigo", "Nome", "Creditos") FROM stdin;
\.


--
-- TOC entry 2081 (class 0 OID 35758)
-- Dependencies: 165 2097
-- Data for Name: Log; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Log" ("PK_Log", "DataHora", "IP", "URI", "HashSessao", "Erro", "Notas", "FK_Usuario") FROM stdin;
\.


--
-- TOC entry 2087 (class 0 OID 35939)
-- Dependencies: 174 2097
-- Data for Name: Optativa; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Optativa" ("PK_Codigo", "Nome") FROM stdin;
\.


--
-- TOC entry 2091 (class 0 OID 36043)
-- Dependencies: 179 2097
-- Data for Name: OptativaAluno; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "OptativaAluno" ("FK_Optativa", "FK_Aluno", "PeriodoSugerido") FROM stdin;
\.


--
-- TOC entry 2092 (class 0 OID 36058)
-- Dependencies: 180 2097
-- Data for Name: OptativaDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "OptativaDisciplina" ("FK_Optativa", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2093 (class 0 OID 36075)
-- Dependencies: 182 2097
-- Data for Name: PreRequisitoGrupo; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "PreRequisitoGrupo" ("PK_PreRequisitoGrupo", "CreditosMinimos", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2094 (class 0 OID 36082)
-- Dependencies: 183 2097
-- Data for Name: PreRequisitoGrupoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "PreRequisitoGrupoDisciplina" ("FK_PreRequisitoGrupo", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2082 (class 0 OID 35818)
-- Dependencies: 167 2097
-- Data for Name: Professor; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Professor" ("PK_Professor", "Nome") FROM stdin;
\.


--
-- TOC entry 2096 (class 0 OID 44535)
-- Dependencies: 192 2097
-- Data for Name: TipoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "TipoDisciplina" ("PK_Codigo", "Nome") FROM stdin;
AC	Atividade Complementar
ED	Eletiva do departamento
EF	Eletiva fora do departamento
EL	Eletiva livre
EO	Eletiva de orientação
NC	Não classificada
OB	Obrigatória básica
OC	Obrigatória do curso
OE	Obrigatória da ênfase
OG	Obrigatória geral
OH	Obrigatória da habilitação
OP	Obrigatória pedagógica
OR	Obrigatória religiosa
PB	Optativa básica
PC	Optativa do curso
PE	Optativa da ênfase
PG	Optativa geral
PH	Optativa da habilitação
PR	Optativa religiosa
\.


--
-- TOC entry 2079 (class 0 OID 35708)
-- Dependencies: 163 2097
-- Data for Name: TipoUsuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "TipoUsuario" ("PK_TipoUsuario", "Nome") FROM stdin;
1	Administrador
2	Coordenador
3	Aluno
\.


--
-- TOC entry 2088 (class 0 OID 35986)
-- Dependencies: 176 2097
-- Data for Name: Turma; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Turma" ("PK_Turma", "FK_Disciplina", "Codigo", "PeriodoAno", "Vagas", "Destino", "HorasDistancia", "SHF", "FK_Professor") FROM stdin;
\.


--
-- TOC entry 2090 (class 0 OID 36018)
-- Dependencies: 178 2097
-- Data for Name: TurmaHorario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "TurmaHorario" ("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal") FROM stdin;
\.


--
-- TOC entry 2077 (class 0 OID 35689)
-- Dependencies: 161 2097
-- Data for Name: Usuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Usuario" ("PK_Login", "Senha", "Nome", "HashSessao", "TermoAceito", "FK_TipoUsuario", "UltimoAcesso") FROM stdin;
\.


--
-- TOC entry 2083 (class 0 OID 35879)
-- Dependencies: 170 2097
-- Data for Name: VariavelAmbiente; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "VariavelAmbiente" ("PK_Variavel", "Habilitada", "Descricao") FROM stdin;
manutencao	f	Desculpe. O sistema encontra-se em manutenção. Por favor, tente mais tarde. Obrigado.
\.


--
-- TOC entry 2011 (class 2606 OID 36393)
-- Dependencies: 162 162 2098
-- Name: PK_Aluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "PK_Aluno" PRIMARY KEY ("FK_Matricula");


--
-- TOC entry 2028 (class 2606 OID 35906)
-- Dependencies: 172 172 172 2098
-- Name: PK_AlunoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "PK_AlunoDisciplina" PRIMARY KEY ("FK_Aluno", "FK_Disciplina");


--
-- TOC entry 2030 (class 2606 OID 35921)
-- Dependencies: 173 173 2098
-- Name: PK_AlunoDisciplinaStatus; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "PK_AlunoDisciplinaStatus" PRIMARY KEY ("PK_Status");


--
-- TOC entry 2039 (class 2606 OID 36005)
-- Dependencies: 177 177 177 2098
-- Name: PK_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "PK_AlunoTurmaSelecionada" PRIMARY KEY ("FK_Aluno", "FK_Turma");


--
-- TOC entry 2053 (class 2606 OID 36146)
-- Dependencies: 184 184 2098
-- Name: PK_Curso; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Curso"
    ADD CONSTRAINT "PK_Curso" PRIMARY KEY ("PK_Curso");


--
-- TOC entry 2026 (class 2606 OID 35900)
-- Dependencies: 171 171 2098
-- Name: PK_Disciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Disciplina"
    ADD CONSTRAINT "PK_Disciplina" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2019 (class 2606 OID 35767)
-- Dependencies: 165 165 2098
-- Name: PK_Log; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "PK_Log" PRIMARY KEY ("PK_Log");


--
-- TOC entry 2034 (class 2606 OID 35943)
-- Dependencies: 174 174 2098
-- Name: PK_Optativa; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Optativa"
    ADD CONSTRAINT "PK_Optativa" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2045 (class 2606 OID 36047)
-- Dependencies: 179 179 179 2098
-- Name: PK_OptativaAluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "PK_OptativaAluno" PRIMARY KEY ("FK_Optativa", "FK_Aluno");


--
-- TOC entry 2047 (class 2606 OID 36062)
-- Dependencies: 180 180 180 2098
-- Name: PK_OptativaDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "PK_OptativaDisciplina" PRIMARY KEY ("FK_Optativa", "FK_Disciplina");


--
-- TOC entry 2049 (class 2606 OID 36081)
-- Dependencies: 182 182 2098
-- Name: PK_PreRequisitoGrupo; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "PK_PreRequisitoGrupo" PRIMARY KEY ("PK_PreRequisitoGrupo");


--
-- TOC entry 2051 (class 2606 OID 36086)
-- Dependencies: 183 183 183 2098
-- Name: PK_PreRequisitoGrupoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "PK_PreRequisitoGrupoDisciplina" PRIMARY KEY ("FK_PreRequisitoGrupo", "FK_Disciplina");


--
-- TOC entry 2021 (class 2606 OID 35822)
-- Dependencies: 167 167 2098
-- Name: PK_Professor; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Professor"
    ADD CONSTRAINT "PK_Professor" PRIMARY KEY ("PK_Professor");


--
-- TOC entry 2017 (class 2606 OID 35725)
-- Dependencies: 164 164 2098
-- Name: PK_Sugestao; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "PK_Sugestao" PRIMARY KEY ("PK_Sugestao");


--
-- TOC entry 2055 (class 2606 OID 44539)
-- Dependencies: 192 192 2098
-- Name: PK_TipoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoDisciplina"
    ADD CONSTRAINT "PK_TipoDisciplina" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2013 (class 2606 OID 35712)
-- Dependencies: 163 163 2098
-- Name: PK_TipoUsuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "PK_TipoUsuario" PRIMARY KEY ("PK_TipoUsuario");


--
-- TOC entry 2036 (class 2606 OID 35994)
-- Dependencies: 176 176 2098
-- Name: PK_Turma; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma" PRIMARY KEY ("PK_Turma");


--
-- TOC entry 2043 (class 2606 OID 36032)
-- Dependencies: 178 178 178 178 178 2098
-- Name: PK_TurmaHorario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "PK_TurmaHorario" PRIMARY KEY ("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal");


--
-- TOC entry 2008 (class 2606 OID 35727)
-- Dependencies: 161 161 2098
-- Name: PK_Usuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "PK_Usuario" PRIMARY KEY ("PK_Login");


--
-- TOC entry 2024 (class 2606 OID 35887)
-- Dependencies: 170 170 2098
-- Name: PK_VariavelAmbiente; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "VariavelAmbiente"
    ADD CONSTRAINT "PK_VariavelAmbiente" PRIMARY KEY ("PK_Variavel");


--
-- TOC entry 2032 (class 2606 OID 35923)
-- Dependencies: 173 173 2098
-- Name: Unique_AlunoDisciplinaStatus_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "Unique_AlunoDisciplinaStatus_Nome" UNIQUE ("Nome");


--
-- TOC entry 2041 (class 2606 OID 36007)
-- Dependencies: 177 177 177 177 177 2098
-- Name: Unique_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "Unique_AlunoTurmaSelecionada" UNIQUE ("FK_Aluno", "FK_Turma", "Opcao", "NoLinha");


--
-- TOC entry 2015 (class 2606 OID 35807)
-- Dependencies: 163 163 2098
-- Name: Unique_TipoUsuario_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "Unique_TipoUsuario_Nome" UNIQUE ("Nome");


--
-- TOC entry 2022 (class 1259 OID 36200)
-- Dependencies: 167 2098
-- Name: Professor_Nome_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Professor_Nome_Index" ON "Professor" USING btree ("Nome");


--
-- TOC entry 2037 (class 1259 OID 36205)
-- Dependencies: 176 176 176 2098
-- Name: Turma_Disciplina_Codigo_Periodo_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Turma_Disciplina_Codigo_Periodo_Index" ON "Turma" USING btree ("FK_Disciplina", "Codigo", "PeriodoAno");


--
-- TOC entry 2009 (class 1259 OID 36176)
-- Dependencies: 161 2098
-- Name: Usuario_HashSession_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Usuario_HashSession_Index" ON "Usuario" USING btree ("HashSessao");


--
-- TOC entry 1981 (class 2618 OID 36347)
-- Dependencies: 177 177 177 177 177 177 177 177 2098
-- Name: AlunoTurmaSelecionadaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "AlunoTurmaSelecionadaDuplicada" AS ON INSERT TO "AlunoTurmaSelecionada" WHERE (EXISTS (SELECT 1 FROM "AlunoTurmaSelecionada" ats WHERE (((ats."FK_Aluno")::text = (new."FK_Aluno")::text) AND (ats."FK_Turma" = new."FK_Turma")))) DO INSTEAD UPDATE "AlunoTurmaSelecionada" ats SET "Opcao" = new."Opcao", "NoLinha" = new."NoLinha" WHERE (((ats."FK_Aluno")::text = (new."FK_Aluno")::text) AND (ats."FK_Turma" = new."FK_Turma"));


--
-- TOC entry 1988 (class 2618 OID 44494)
-- Dependencies: 184 184 184 184 184 2098
-- Name: CursoDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "CursoDuplicado" AS ON INSERT TO "Curso" WHERE (EXISTS (SELECT 1 FROM "Curso" d WHERE ((d."PK_Curso")::text = (new."PK_Curso")::text))) DO INSTEAD UPDATE "Curso" d SET "Nome" = new."Nome" WHERE ((d."PK_Curso")::text = (new."PK_Curso")::text);


--
-- TOC entry 1976 (class 2618 OID 36173)
-- Dependencies: 171 171 171 171 171 171 2098
-- Name: DisciplinaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "DisciplinaDuplicada" AS ON INSERT TO "Disciplina" WHERE (EXISTS (SELECT 1 FROM "Disciplina" d WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text))) DO INSTEAD UPDATE "Disciplina" d SET "Nome" = new."Nome", "Creditos" = new."Creditos" WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text);


--
-- TOC entry 1989 (class 2618 OID 44531)
-- Dependencies: 174 174 174 174 174 2098
-- Name: OptativaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "OptativaDuplicada" AS ON INSERT TO "Optativa" WHERE (EXISTS (SELECT 1 FROM "Optativa" d WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text))) DO INSTEAD UPDATE "Optativa" d SET "Nome" = new."Nome" WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text);


--
-- TOC entry 1977 (class 2618 OID 36179)
-- Dependencies: 167 167 167 167 2098
-- Name: ProfessorDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "ProfessorDuplicado" AS ON INSERT TO "Professor" WHERE (EXISTS (SELECT 1 FROM "Professor" d WHERE ((d."Nome")::text = (new."Nome")::text))) DO INSTEAD NOTHING;


--
-- TOC entry 1978 (class 2618 OID 36221)
-- Dependencies: 176 176 176 176 176 176 176 176 176 176 176 176 176 2098
-- Name: TurmaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaDuplicada" AS ON INSERT TO "Turma" WHERE (EXISTS (SELECT 1 FROM "Turma" t WHERE ((((t."FK_Disciplina")::text = (new."FK_Disciplina")::text) AND ((t."Codigo")::text = (new."Codigo")::text)) AND (t."PeriodoAno" = new."PeriodoAno")))) DO INSTEAD UPDATE "Turma" t SET "Vagas" = new."Vagas", "Destino" = new."Destino", "HorasDistancia" = new."HorasDistancia", "SHF" = new."SHF", "FK_Professor" = new."FK_Professor" WHERE ((((t."FK_Disciplina")::text = (new."FK_Disciplina")::text) AND ((t."Codigo")::text = (new."Codigo")::text)) AND (t."PeriodoAno" = new."PeriodoAno"));


--
-- TOC entry 1979 (class 2618 OID 36235)
-- Dependencies: 178 178 178 178 178 178 178 2098
-- Name: TurmaHorarioDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaHorarioDuplicado" AS ON INSERT TO "TurmaHorario" WHERE (EXISTS (SELECT 1 FROM "TurmaHorario" th WHERE ((((th."FK_Turma" = new."FK_Turma") AND (th."DiaSemana" = new."DiaSemana")) AND (th."HoraInicial" = new."HoraInicial")) AND (th."HoraFinal" = new."HoraFinal")))) DO INSTEAD NOTHING;


--
-- TOC entry 2061 (class 2606 OID 44719)
-- Dependencies: 172 2010 162 2098
-- Name: FK_AlunoDisciplina_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2063 (class 2606 OID 44729)
-- Dependencies: 172 173 2029 2098
-- Name: FK_AlunoDisciplina_AlunoDisciplinaStatus; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_AlunoDisciplinaStatus" FOREIGN KEY ("FK_Status") REFERENCES "AlunoDisciplinaStatus"("PK_Status") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2062 (class 2606 OID 44724)
-- Dependencies: 2025 172 171 2098
-- Name: FK_AlunoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2064 (class 2606 OID 44734)
-- Dependencies: 192 172 2054 2098
-- Name: FK_AlunoDisciplina_TipoDisciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_TipoDisciplina" FOREIGN KEY ("FK_TipoDisciplina") REFERENCES "TipoDisciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2068 (class 2606 OID 36399)
-- Dependencies: 2010 177 162 2098
-- Name: FK_AlunoTurmaSelecionada_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2067 (class 2606 OID 36013)
-- Dependencies: 2035 176 177 2098
-- Name: FK_AlunoTurmaSelecionada_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2057 (class 2606 OID 44500)
-- Dependencies: 162 2052 184 2098
-- Name: FK_Aluno_Curso; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Curso" FOREIGN KEY ("FK_Curso") REFERENCES "Curso"("PK_Curso") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2058 (class 2606 OID 44505)
-- Dependencies: 162 2007 161 2098
-- Name: FK_Aluno_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Usuario" FOREIGN KEY ("FK_Matricula") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2060 (class 2606 OID 36132)
-- Dependencies: 165 2007 161 2098
-- Name: FK_Log_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "FK_Log_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2070 (class 2606 OID 44684)
-- Dependencies: 162 2010 179 2098
-- Name: FK_OptativaAluno_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2071 (class 2606 OID 44689)
-- Dependencies: 179 174 2033 2098
-- Name: FK_OptativaAluno_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2073 (class 2606 OID 36068)
-- Dependencies: 2025 180 171 2098
-- Name: FK_OptativaDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2072 (class 2606 OID 36063)
-- Dependencies: 174 180 2033 2098
-- Name: FK_OptativaDisciplina_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2076 (class 2606 OID 36092)
-- Dependencies: 183 2025 171 2098
-- Name: FK_PreRequisitoGrupoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2075 (class 2606 OID 36087)
-- Dependencies: 2048 183 182 2098
-- Name: FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo" FOREIGN KEY ("FK_PreRequisitoGrupo") REFERENCES "PreRequisitoGrupo"("PK_PreRequisitoGrupo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2074 (class 2606 OID 36097)
-- Dependencies: 182 2025 171 2098
-- Name: FK_PreRequisitoGrupo_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "FK_PreRequisitoGrupo_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2059 (class 2606 OID 35888)
-- Dependencies: 2007 164 161 2098
-- Name: FK_Sugestao_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "FK_Sugestao_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2069 (class 2606 OID 36168)
-- Dependencies: 178 2035 176 2098
-- Name: FK_TurmaHorario_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "FK_TurmaHorario_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2065 (class 2606 OID 36211)
-- Dependencies: 2020 167 176 2098
-- Name: FK_Turma_Professor; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "FK_Turma_Professor" FOREIGN KEY ("FK_Professor") REFERENCES "Professor"("PK_Professor") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2056 (class 2606 OID 44513)
-- Dependencies: 163 161 2012 2098
-- Name: FK_Usuario_TipoUsuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "FK_Usuario_TipoUsuario" FOREIGN KEY ("FK_TipoUsuario") REFERENCES "TipoUsuario"("PK_TipoUsuario") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2066 (class 2606 OID 36216)
-- Dependencies: 171 176 2025 2098
-- Name: PK_Turma_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2012-12-08 14:45:01 BRST

--
-- PostgreSQL database dump complete
--

