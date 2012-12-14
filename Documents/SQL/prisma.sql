--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.5
-- Dumped by pg_dump version 9.1.5
-- Started on 2012-12-14 14:21:41 BRST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 201 (class 3079 OID 11646)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2151 (class 0 OID 0)
-- Dependencies: 201
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 216 (class 1255 OID 54553)
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
-- TOC entry 213 (class 1255 OID 54554)
-- Dependencies: 6 639
-- Name: AlunoDisciplinaApto(character varying, character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoDisciplinaApto"("pAluno" character varying, "pDisciplina" character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM "AlunoDisciplinaAptoCache" WHERE "Aluno" = "pAluno" AND "Disciplina" = "pDisciplina") THEN
		IF "DisciplinaTemPreRequisito"("pDisciplina") = FALSE THEN
			INSERT INTO "AlunoDisciplinaAptoCache"("Aluno", "Disciplina", "Apto") VALUES ("pAluno", "pDisciplina", 2);
		ELSIF "AlunoDisciplinaSituacao"("pAluno", "pDisciplina") = 'NC' THEN 
				INSERT INTO "AlunoDisciplinaAptoCache"("Aluno", "Disciplina", "Apto") VALUES ("pAluno", "pDisciplina",
				(
					SELECT MAX(aprga."Apto")
					FROM "PreRequisitoGrupo" prg
						INNER JOIN "AlunoPreRequisitoGrupoDisciplinaApto" aprga
							ON prg."PK_PreRequisitoGrupo" = aprga."FK_PreRequisitoGrupo"
					WHERE prg."FK_Disciplina" = "pDisciplina" AND aprga."FK_Aluno" = "pAluno"
				));
		ELSE
			INSERT INTO "AlunoDisciplinaAptoCache"("Aluno", "Disciplina", "Apto") VALUES ("pAluno", "pDisciplina", 2);
		END IF;		
	END IF;

	RETURN (SELECT "Apto" FROM "AlunoDisciplinaAptoCache" WHERE "Aluno" = "pAluno" AND "Disciplina" = "pDisciplina");
END;
$$;


ALTER FUNCTION public."AlunoDisciplinaApto"("pAluno" character varying, "pDisciplina" character varying) OWNER TO prisma;

--
-- TOC entry 214 (class 1255 OID 54555)
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
-- TOC entry 215 (class 1255 OID 54556)
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
			oa."FK_Aluno" = ad."FK_Aluno" AND
			o."PK_Codigo" = od."FK_Optativa" AND
			ad."FK_Disciplina" = od."FK_Disciplina" AND
			ad."FK_Status" = 'CP'
	)
$_$;


ALTER FUNCTION public."AlunoOptativaCursada"(character varying, character varying) OWNER TO prisma;

--
-- TOC entry 217 (class 1255 OID 54557)
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
-- TOC entry 218 (class 1255 OID 54558)
-- Dependencies: 6
-- Name: LimpaBanco(); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "LimpaBanco"() RETURNS void
    LANGUAGE sql
    AS $$
	SELECT setval('seq_log', 1);
	SELECT setval('seq_prerequisito', 1);
	SELECT setval('seq_professor', 1);
	SELECT setval('seq_sugestao', 1);
	SELECT setval('seq_turma', 1);
	SELECT setval('seq_unidade', 1);
	
	TRUNCATE "Usuario" CASCADE;
	TRUNCATE "Professor" CASCADE;
	TRUNCATE "Disciplina" CASCADE;
	TRUNCATE "Optativa" CASCADE;
	TRUNCATE "Curso" CASCADE;
	TRUNCATE "AlunoDisciplinaAptoCache" CASCADE;
	TRUNCATE "Log" CASCADE;
	TRUNCATE "Comentario" CASCADE;
	TRUNCATE "Unidade" CASCADE;
$$;


ALTER FUNCTION public."LimpaBanco"() OWNER TO prisma;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 161 (class 1259 OID 54559)
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
-- TOC entry 162 (class 1259 OID 54562)
-- Dependencies: 2025 2026 6
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
-- TOC entry 163 (class 1259 OID 54567)
-- Dependencies: 6
-- Name: AlunoDisciplinaAptoCache; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "AlunoDisciplinaAptoCache" (
    "Aluno" character varying(20) NOT NULL,
    "Disciplina" character varying(7) NOT NULL,
    "Apto" integer NOT NULL
);


ALTER TABLE public."AlunoDisciplinaAptoCache" OWNER TO prisma;

--
-- TOC entry 164 (class 1259 OID 54570)
-- Dependencies: 6
-- Name: AlunoDisciplinaStatus; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "AlunoDisciplinaStatus" (
    "PK_Status" character varying(2) NOT NULL,
    "Nome" character varying(20) NOT NULL
);


ALTER TABLE public."AlunoDisciplinaStatus" OWNER TO prisma;

--
-- TOC entry 165 (class 1259 OID 54573)
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
-- TOC entry 166 (class 1259 OID 54576)
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
-- TOC entry 2152 (class 0 OID 0)
-- Dependencies: 166
-- Name: seq_turma; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_turma', 1, true);


--
-- TOC entry 167 (class 1259 OID 54578)
-- Dependencies: 2027 2028 2029 2030 2031 6
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
    "FK_Professor" bigint NOT NULL,
    "Deletada" boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Turma" OWNER TO prisma;

--
-- TOC entry 168 (class 1259 OID 54585)
-- Dependencies: 2004 6
-- Name: AlunoDisciplinaTurmaSelecionada; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "AlunoDisciplinaTurmaSelecionada" AS
    SELECT t."FK_Disciplina" AS "CodigoDisciplina", ats."FK_Turma", ats."FK_Aluno" AS "MatriculaAluno", ats."Opcao", ats."NoLinha" FROM ("AlunoTurmaSelecionada" ats JOIN "Turma" t ON (((t."PK_Turma" = ats."FK_Turma") AND (t."Deletada" = false))));


ALTER TABLE public."AlunoDisciplinaTurmaSelecionada" OWNER TO prisma;

--
-- TOC entry 169 (class 1259 OID 54589)
-- Dependencies: 6
-- Name: PreRequisitoGrupoDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "PreRequisitoGrupoDisciplina" (
    "FK_PreRequisitoGrupo" bigint NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."PreRequisitoGrupoDisciplina" OWNER TO prisma;

--
-- TOC entry 170 (class 1259 OID 54592)
-- Dependencies: 2005 6
-- Name: AlunoPreRequisitoGrupoDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "AlunoPreRequisitoGrupoDisciplina" AS
    SELECT t."FK_Matricula" AS "FK_Aluno", t."FK_PreRequisitoGrupo", t."FK_Disciplina", COALESCE(ad."FK_Status", 'NC'::character varying) AS "Situacao" FROM ((SELECT a."FK_Matricula", prgd."FK_PreRequisitoGrupo", prgd."FK_Disciplina" FROM "PreRequisitoGrupoDisciplina" prgd, "Aluno" a) t LEFT JOIN "AlunoDisciplina" ad ON ((((ad."FK_Aluno")::text = (t."FK_Matricula")::text) AND ((ad."FK_Disciplina")::text = (t."FK_Disciplina")::text))));


ALTER TABLE public."AlunoPreRequisitoGrupoDisciplina" OWNER TO prisma;

--
-- TOC entry 171 (class 1259 OID 54596)
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
-- TOC entry 2153 (class 0 OID 0)
-- Dependencies: 171
-- Name: seq_prerequisito; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_prerequisito', 1, true);


--
-- TOC entry 172 (class 1259 OID 54598)
-- Dependencies: 2032 2033 6
-- Name: PreRequisitoGrupo; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "PreRequisitoGrupo" (
    "PK_PreRequisitoGrupo" bigint DEFAULT nextval('seq_prerequisito'::regclass) NOT NULL,
    "CreditosMinimos" integer DEFAULT 0 NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."PreRequisitoGrupo" OWNER TO prisma;

--
-- TOC entry 173 (class 1259 OID 54603)
-- Dependencies: 2006 6
-- Name: AlunoPreRequisitoGrupoDisciplinaApto; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "AlunoPreRequisitoGrupoDisciplinaApto" AS
    SELECT a."FK_Matricula" AS "FK_Aluno", prg."PK_PreRequisitoGrupo" AS "FK_PreRequisitoGrupo", CASE WHEN ("AlunoCreditosCursados"(a."FK_Matricula") < prg."CreditosMinimos") THEN 0 WHEN (EXISTS (SELECT 1 FROM "AlunoPreRequisitoGrupoDisciplina" aprgd1 WHERE ((((aprgd1."FK_Aluno")::text = (a."FK_Matricula")::text) AND (aprgd1."FK_PreRequisitoGrupo" = prg."PK_PreRequisitoGrupo")) AND ((aprgd1."Situacao")::text = 'NC'::text)))) THEN 0 WHEN (EXISTS (SELECT 1 FROM "AlunoPreRequisitoGrupoDisciplina" aprgd1 WHERE ((((aprgd1."FK_Aluno")::text = (a."FK_Matricula")::text) AND (aprgd1."FK_PreRequisitoGrupo" = prg."PK_PreRequisitoGrupo")) AND ((aprgd1."Situacao")::text = 'EA'::text)))) THEN 1 ELSE 2 END AS "Apto" FROM "Aluno" a, "PreRequisitoGrupo" prg;


ALTER TABLE public."AlunoPreRequisitoGrupoDisciplinaApto" OWNER TO prisma;

--
-- TOC entry 174 (class 1259 OID 54607)
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
-- TOC entry 2154 (class 0 OID 0)
-- Dependencies: 174
-- Name: seq_sugestao; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_sugestao', 1, true);


--
-- TOC entry 175 (class 1259 OID 54609)
-- Dependencies: 2034 2035 6
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
-- TOC entry 176 (class 1259 OID 54617)
-- Dependencies: 6
-- Name: Curso; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Curso" (
    "PK_Curso" character varying(3) NOT NULL,
    "Nome" character varying(50) NOT NULL
);


ALTER TABLE public."Curso" OWNER TO prisma;

--
-- TOC entry 177 (class 1259 OID 54620)
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
-- TOC entry 178 (class 1259 OID 54623)
-- Dependencies: 6
-- Name: Optativa; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Optativa" (
    "PK_Codigo" character varying(7) NOT NULL,
    "Nome" character varying(100) NOT NULL
);


ALTER TABLE public."Optativa" OWNER TO prisma;

--
-- TOC entry 179 (class 1259 OID 54626)
-- Dependencies: 2036 6
-- Name: OptativaAluno; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "OptativaAluno" (
    "FK_Optativa" character varying(7) NOT NULL,
    "FK_Aluno" character varying(20) NOT NULL,
    "PeriodoSugerido" integer DEFAULT 1 NOT NULL
);


ALTER TABLE public."OptativaAluno" OWNER TO prisma;

--
-- TOC entry 180 (class 1259 OID 54630)
-- Dependencies: 2007 6
-- Name: FaltaCursarOptativa; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "FaltaCursarOptativa" AS
    SELECT oa."FK_Aluno" AS "Aluno", o."PK_Codigo" AS "CodigoOptativa", o."Nome" AS "NomeOptativa", oa."PeriodoSugerido" FROM ("Optativa" o JOIN "OptativaAluno" oa ON (((o."PK_Codigo")::text = (oa."FK_Optativa")::text))) WHERE (NOT "AlunoOptativaCursada"(oa."FK_Aluno", o."PK_Codigo"));


ALTER TABLE public."FaltaCursarOptativa" OWNER TO prisma;

--
-- TOC entry 181 (class 1259 OID 54634)
-- Dependencies: 6
-- Name: OptativaDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "OptativaDisciplina" (
    "FK_Optativa" character varying(7) NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."OptativaDisciplina" OWNER TO prisma;

--
-- TOC entry 182 (class 1259 OID 54637)
-- Dependencies: 2008 6
-- Name: FaltaCursarOptativaDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "FaltaCursarOptativaDisciplina" AS
    SELECT fco."Aluno", fco."CodigoOptativa", od."FK_Disciplina" AS "CodigoDisciplina", COALESCE(ad."FK_Status", 'NC'::character varying) AS "Situacao", "AlunoDisciplinaApto"(fco."Aluno", od."FK_Disciplina") AS "Apto" FROM (("FaltaCursarOptativa" fco JOIN "OptativaDisciplina" od ON (((od."FK_Optativa")::text = (fco."CodigoOptativa")::text))) LEFT JOIN "AlunoDisciplina" ad ON ((((ad."FK_Disciplina")::text = (od."FK_Disciplina")::text) AND ((fco."Aluno")::text = (ad."FK_Aluno")::text))));


ALTER TABLE public."FaltaCursarOptativaDisciplina" OWNER TO prisma;

--
-- TOC entry 183 (class 1259 OID 54641)
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
-- TOC entry 2155 (class 0 OID 0)
-- Dependencies: 183
-- Name: seq_log; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_log', 1, true);


--
-- TOC entry 184 (class 1259 OID 54643)
-- Dependencies: 2037 2038 2039 6
-- Name: Log; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Log" (
    "PK_Log" bigint DEFAULT nextval('seq_log'::regclass) NOT NULL,
    "DataHora" timestamp with time zone DEFAULT now() NOT NULL,
    "IP" character varying(40),
    "URI" character varying(500),
    "HashSessao" character varying(40),
    "Erro" boolean DEFAULT false NOT NULL,
    "Notas" text,
    "FK_Usuario" character varying(20) NOT NULL,
    "Browser" character varying(300)
);


ALTER TABLE public."Log" OWNER TO prisma;

--
-- TOC entry 185 (class 1259 OID 54652)
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
-- TOC entry 2156 (class 0 OID 0)
-- Dependencies: 185
-- Name: seq_professor; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_professor', 1, true);


--
-- TOC entry 186 (class 1259 OID 54654)
-- Dependencies: 2040 6
-- Name: Professor; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Professor" (
    "PK_Professor" bigint DEFAULT nextval('seq_professor'::regclass) NOT NULL,
    "Nome" character varying(100) NOT NULL
);


ALTER TABLE public."Professor" OWNER TO prisma;

--
-- TOC entry 187 (class 1259 OID 54658)
-- Dependencies: 2041 6
-- Name: TurmaHorario; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TurmaHorario" (
    "FK_Turma" bigint NOT NULL,
    "DiaSemana" integer NOT NULL,
    "HoraInicial" integer NOT NULL,
    "HoraFinal" integer NOT NULL,
    "FK_Unidade" bigint DEFAULT 1 NOT NULL
);


ALTER TABLE public."TurmaHorario" OWNER TO prisma;

--
-- TOC entry 188 (class 1259 OID 54661)
-- Dependencies: 2009 6
-- Name: MicroHorario; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "MicroHorario" AS
    SELECT d."PK_Codigo" AS "CodigoDisciplina", d."Nome" AS "NomeDisciplina", d."Creditos", t."PK_Turma", t."Codigo" AS "CodigoTurma", t."PeriodoAno", t."Vagas", t."Destino", t."HorasDistancia", t."SHF", p."Nome" AS "NomeProfessor", th."DiaSemana", th."HoraInicial", th."HoraFinal" FROM ((("Disciplina" d JOIN "Turma" t ON (((t."FK_Disciplina")::text = (d."PK_Codigo")::text))) JOIN "Professor" p ON ((t."FK_Professor" = p."PK_Professor"))) JOIN "TurmaHorario" th ON (((th."FK_Turma" = t."PK_Turma") AND (t."Deletada" = false)))) ORDER BY d."PK_Codigo", d."Nome", d."Creditos", t."PK_Turma", t."Codigo", t."PeriodoAno", t."Vagas", t."Destino", t."HorasDistancia", t."SHF", p."Nome", th."DiaSemana", th."HoraInicial", th."HoraFinal";


ALTER TABLE public."MicroHorario" OWNER TO prisma;

--
-- TOC entry 189 (class 1259 OID 54666)
-- Dependencies: 2010 6
-- Name: MicroHorarioDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "MicroHorarioDisciplina" AS
    SELECT t."Aluno", t."CodigoDisciplina", t."NomeDisciplina", t."Creditos", COALESCE(ad."FK_Status", 'NC'::character varying) AS "Situacao", "AlunoDisciplinaApto"(t."Aluno", t."CodigoDisciplina") AS "Apto" FROM ((SELECT a."FK_Matricula" AS "Aluno", d."PK_Codigo" AS "CodigoDisciplina", d."Nome" AS "NomeDisciplina", d."Creditos" FROM "Disciplina" d, "Aluno" a) t LEFT JOIN "AlunoDisciplina" ad ON ((((ad."FK_Aluno")::text = (t."Aluno")::text) AND ((ad."FK_Disciplina")::text = (t."CodigoDisciplina")::text))));


ALTER TABLE public."MicroHorarioDisciplina" OWNER TO prisma;

--
-- TOC entry 196 (class 1259 OID 55341)
-- Dependencies: 2020 6
-- Name: PopulaAlunoDisciplinaAptoCacheFaltaCursarDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "PopulaAlunoDisciplinaAptoCacheFaltaCursarDisciplina" AS
    SELECT "AlunoDisciplinaApto"("AlunoDisciplina"."FK_Aluno", "AlunoDisciplina"."FK_Disciplina") AS "AlunoDisciplinaApto" FROM "AlunoDisciplina" WHERE (("AlunoDisciplina"."FK_Status")::text <> 'CP'::text);


ALTER TABLE public."PopulaAlunoDisciplinaAptoCacheFaltaCursarDisciplina" OWNER TO prisma;

--
-- TOC entry 195 (class 1259 OID 55337)
-- Dependencies: 2019 6
-- Name: PopulaAlunoDisciplinaAptoCacheFaltaCursarOptativa; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "PopulaAlunoDisciplinaAptoCacheFaltaCursarOptativa" AS
    SELECT "AlunoDisciplinaApto"(oa."FK_Aluno", od."FK_Disciplina") AS "AlunoDisciplinaApto" FROM ("OptativaAluno" oa JOIN "OptativaDisciplina" od ON (((oa."FK_Optativa")::text = (od."FK_Optativa")::text))) WHERE ("AlunoOptativaCursada"(oa."FK_Aluno", od."FK_Disciplina") = false);


ALTER TABLE public."PopulaAlunoDisciplinaAptoCacheFaltaCursarOptativa" OWNER TO prisma;

--
-- TOC entry 190 (class 1259 OID 54671)
-- Dependencies: 6
-- Name: TipoDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TipoDisciplina" (
    "PK_Codigo" character varying(2) NOT NULL,
    "Nome" character varying(50)
);


ALTER TABLE public."TipoDisciplina" OWNER TO prisma;

--
-- TOC entry 191 (class 1259 OID 54674)
-- Dependencies: 6
-- Name: TipoUsuario; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TipoUsuario" (
    "PK_TipoUsuario" integer NOT NULL,
    "Nome" character varying(20) NOT NULL
);


ALTER TABLE public."TipoUsuario" OWNER TO prisma;

--
-- TOC entry 198 (class 1259 OID 55889)
-- Dependencies: 6
-- Name: seq_unidade; Type: SEQUENCE; Schema: public; Owner: prisma
--

CREATE SEQUENCE seq_unidade
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_unidade OWNER TO prisma;

--
-- TOC entry 2157 (class 0 OID 0)
-- Dependencies: 198
-- Name: seq_unidade; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_unidade', 1, true);


--
-- TOC entry 199 (class 1259 OID 55891)
-- Dependencies: 2044 6
-- Name: Unidade; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Unidade" (
    "PK_Unidade" bigint DEFAULT nextval('seq_unidade'::regclass) NOT NULL,
    "Nome" character varying(50) NOT NULL
);


ALTER TABLE public."Unidade" OWNER TO prisma;

--
-- TOC entry 200 (class 1259 OID 55914)
-- Dependencies: 2022 6
-- Name: TurmaHorarioUnidade; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "TurmaHorarioUnidade" AS
    SELECT th."FK_Turma", th."DiaSemana", th."HoraInicial", th."HoraFinal", u."Nome" AS "Unidade" FROM ("TurmaHorario" th JOIN "Unidade" u ON ((u."PK_Unidade" = th."FK_Unidade")));


ALTER TABLE public."TurmaHorarioUnidade" OWNER TO prisma;

--
-- TOC entry 192 (class 1259 OID 54677)
-- Dependencies: 2011 6
-- Name: TurmaProfessor; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "TurmaProfessor" AS
    SELECT t."PK_Turma", t."Codigo" AS "CodigoTurma", t."FK_Disciplina" AS "CodigoDisciplina", t."PeriodoAno", t."Vagas", t."Destino", t."HorasDistancia", t."SHF", p."Nome" AS "NomeProfessor" FROM ("Turma" t JOIN "Professor" p ON ((t."FK_Professor" = p."PK_Professor"))) WHERE (t."Deletada" = false);


ALTER TABLE public."TurmaProfessor" OWNER TO prisma;

--
-- TOC entry 193 (class 1259 OID 54681)
-- Dependencies: 2042 6
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
-- TOC entry 197 (class 1259 OID 55880)
-- Dependencies: 2021 6
-- Name: UsuarioAluno; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "UsuarioAluno" AS
    SELECT u."PK_Login" AS "Matricula", u."Nome" AS "NomeAluno", c."Nome" AS "Curso", u."UltimoAcesso", a."CoeficienteRendimento" AS "CR" FROM (("Usuario" u JOIN "Aluno" a ON (((u."PK_Login")::text = (a."FK_Matricula")::text))) JOIN "Curso" c ON (((c."PK_Curso")::text = (a."FK_Curso")::text))) WHERE (u."FK_TipoUsuario" = 3);


ALTER TABLE public."UsuarioAluno" OWNER TO prisma;

--
-- TOC entry 194 (class 1259 OID 54685)
-- Dependencies: 2043 6
-- Name: VariavelAmbiente; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "VariavelAmbiente" (
    "PK_Variavel" character varying(30) NOT NULL,
    "Habilitada" boolean DEFAULT true NOT NULL,
    "Descricao" text
);


ALTER TABLE public."VariavelAmbiente" OWNER TO prisma;

--
-- TOC entry 2124 (class 0 OID 54559)
-- Dependencies: 161 2146
-- Data for Name: Aluno; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Aluno" ("FK_Matricula", "CoeficienteRendimento", "FK_Curso") FROM stdin;
\.


--
-- TOC entry 2125 (class 0 OID 54562)
-- Dependencies: 162 2146
-- Data for Name: AlunoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoDisciplina" ("FK_Aluno", "FK_Disciplina", "FK_Status", "Tentativas", "Periodo", "FK_TipoDisciplina") FROM stdin;
\.


--
-- TOC entry 2126 (class 0 OID 54567)
-- Dependencies: 163 2146
-- Data for Name: AlunoDisciplinaAptoCache; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoDisciplinaAptoCache" ("Aluno", "Disciplina", "Apto") FROM stdin;
\.


--
-- TOC entry 2127 (class 0 OID 54570)
-- Dependencies: 164 2146
-- Data for Name: AlunoDisciplinaStatus; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoDisciplinaStatus" ("PK_Status", "Nome") FROM stdin;
CP	Cumpriu
EA	Em andamento
NC	Não cumpriu
\.


--
-- TOC entry 2128 (class 0 OID 54573)
-- Dependencies: 165 2146
-- Data for Name: AlunoTurmaSelecionada; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoTurmaSelecionada" ("FK_Aluno", "FK_Turma", "Opcao", "NoLinha") FROM stdin;
\.


--
-- TOC entry 2132 (class 0 OID 54609)
-- Dependencies: 175 2146
-- Data for Name: Comentario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Comentario" ("PK_Sugestao", "FK_Usuario", "Comentario", "DataHora") FROM stdin;
\.


--
-- TOC entry 2133 (class 0 OID 54617)
-- Dependencies: 176 2146
-- Data for Name: Curso; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Curso" ("PK_Curso", "Nome") FROM stdin;
\.


--
-- TOC entry 2134 (class 0 OID 54620)
-- Dependencies: 177 2146
-- Data for Name: Disciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Disciplina" ("PK_Codigo", "Nome", "Creditos") FROM stdin;
\.


--
-- TOC entry 2138 (class 0 OID 54643)
-- Dependencies: 184 2146
-- Data for Name: Log; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Log" ("PK_Log", "DataHora", "IP", "URI", "HashSessao", "Erro", "Notas", "FK_Usuario", "Browser") FROM stdin;
\.


--
-- TOC entry 2135 (class 0 OID 54623)
-- Dependencies: 178 2146
-- Data for Name: Optativa; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Optativa" ("PK_Codigo", "Nome") FROM stdin;
\.


--
-- TOC entry 2136 (class 0 OID 54626)
-- Dependencies: 179 2146
-- Data for Name: OptativaAluno; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "OptativaAluno" ("FK_Optativa", "FK_Aluno", "PeriodoSugerido") FROM stdin;
\.


--
-- TOC entry 2137 (class 0 OID 54634)
-- Dependencies: 181 2146
-- Data for Name: OptativaDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "OptativaDisciplina" ("FK_Optativa", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2131 (class 0 OID 54598)
-- Dependencies: 172 2146
-- Data for Name: PreRequisitoGrupo; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "PreRequisitoGrupo" ("PK_PreRequisitoGrupo", "CreditosMinimos", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2130 (class 0 OID 54589)
-- Dependencies: 169 2146
-- Data for Name: PreRequisitoGrupoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "PreRequisitoGrupoDisciplina" ("FK_PreRequisitoGrupo", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2139 (class 0 OID 54654)
-- Dependencies: 186 2146
-- Data for Name: Professor; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Professor" ("PK_Professor", "Nome") FROM stdin;
\.


--
-- TOC entry 2141 (class 0 OID 54671)
-- Dependencies: 190 2146
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
-- TOC entry 2142 (class 0 OID 54674)
-- Dependencies: 191 2146
-- Data for Name: TipoUsuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "TipoUsuario" ("PK_TipoUsuario", "Nome") FROM stdin;
1	Administrador
2	Coordenador
3	Aluno
\.


--
-- TOC entry 2129 (class 0 OID 54578)
-- Dependencies: 167 2146
-- Data for Name: Turma; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Turma" ("PK_Turma", "FK_Disciplina", "Codigo", "PeriodoAno", "Vagas", "Destino", "HorasDistancia", "SHF", "FK_Professor", "Deletada") FROM stdin;
\.


--
-- TOC entry 2140 (class 0 OID 54658)
-- Dependencies: 187 2146
-- Data for Name: TurmaHorario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "TurmaHorario" ("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal", "FK_Unidade") FROM stdin;
\.


--
-- TOC entry 2145 (class 0 OID 55891)
-- Dependencies: 199 2146
-- Data for Name: Unidade; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Unidade" ("PK_Unidade", "Nome") FROM stdin;
\.


--
-- TOC entry 2143 (class 0 OID 54681)
-- Dependencies: 193 2146
-- Data for Name: Usuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Usuario" ("PK_Login", "Senha", "Nome", "HashSessao", "TermoAceito", "FK_TipoUsuario", "UltimoAcesso") FROM stdin;
admin	164b0b9234f65b9fc6f01d72fda859241e0935cc	Administrador	\N	f	1	\N
\.


--
-- TOC entry 2144 (class 0 OID 54685)
-- Dependencies: 194 2146
-- Data for Name: VariavelAmbiente; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "VariavelAmbiente" ("PK_Variavel", "Habilitada", "Descricao") FROM stdin;
manutencao	f	Desculpe. O sistema encontra-se em manutenção. Por favor, tente mais tarde. Obrigado.
\.


--
-- TOC entry 2046 (class 2606 OID 54693)
-- Dependencies: 161 161 2147
-- Name: PK_Aluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "PK_Aluno" PRIMARY KEY ("FK_Matricula");


--
-- TOC entry 2048 (class 2606 OID 54695)
-- Dependencies: 162 162 162 2147
-- Name: PK_AlunoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "PK_AlunoDisciplina" PRIMARY KEY ("FK_Aluno", "FK_Disciplina");


--
-- TOC entry 2050 (class 2606 OID 54697)
-- Dependencies: 163 163 163 2147
-- Name: PK_AlunoDisciplinaAptoCache; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaAptoCache"
    ADD CONSTRAINT "PK_AlunoDisciplinaAptoCache" PRIMARY KEY ("Aluno", "Disciplina");


--
-- TOC entry 2052 (class 2606 OID 54699)
-- Dependencies: 164 164 2147
-- Name: PK_AlunoDisciplinaStatus; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "PK_AlunoDisciplinaStatus" PRIMARY KEY ("PK_Status");


--
-- TOC entry 2056 (class 2606 OID 54701)
-- Dependencies: 165 165 165 2147
-- Name: PK_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "PK_AlunoTurmaSelecionada" PRIMARY KEY ("FK_Aluno", "FK_Turma");


--
-- TOC entry 2069 (class 2606 OID 54703)
-- Dependencies: 176 176 2147
-- Name: PK_Curso; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Curso"
    ADD CONSTRAINT "PK_Curso" PRIMARY KEY ("PK_Curso");


--
-- TOC entry 2071 (class 2606 OID 54705)
-- Dependencies: 177 177 2147
-- Name: PK_Disciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Disciplina"
    ADD CONSTRAINT "PK_Disciplina" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2079 (class 2606 OID 54707)
-- Dependencies: 184 184 2147
-- Name: PK_Log; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "PK_Log" PRIMARY KEY ("PK_Log");


--
-- TOC entry 2073 (class 2606 OID 54709)
-- Dependencies: 178 178 2147
-- Name: PK_Optativa; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Optativa"
    ADD CONSTRAINT "PK_Optativa" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2075 (class 2606 OID 54711)
-- Dependencies: 179 179 179 2147
-- Name: PK_OptativaAluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "PK_OptativaAluno" PRIMARY KEY ("FK_Optativa", "FK_Aluno");


--
-- TOC entry 2077 (class 2606 OID 54713)
-- Dependencies: 181 181 181 2147
-- Name: PK_OptativaDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "PK_OptativaDisciplina" PRIMARY KEY ("FK_Optativa", "FK_Disciplina");


--
-- TOC entry 2065 (class 2606 OID 54715)
-- Dependencies: 172 172 2147
-- Name: PK_PreRequisitoGrupo; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "PK_PreRequisitoGrupo" PRIMARY KEY ("PK_PreRequisitoGrupo");


--
-- TOC entry 2063 (class 2606 OID 54717)
-- Dependencies: 169 169 169 2147
-- Name: PK_PreRequisitoGrupoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "PK_PreRequisitoGrupoDisciplina" PRIMARY KEY ("FK_PreRequisitoGrupo", "FK_Disciplina");


--
-- TOC entry 2081 (class 2606 OID 54719)
-- Dependencies: 186 186 2147
-- Name: PK_Professor; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Professor"
    ADD CONSTRAINT "PK_Professor" PRIMARY KEY ("PK_Professor");


--
-- TOC entry 2067 (class 2606 OID 54721)
-- Dependencies: 175 175 2147
-- Name: PK_Sugestao; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "PK_Sugestao" PRIMARY KEY ("PK_Sugestao");


--
-- TOC entry 2086 (class 2606 OID 54723)
-- Dependencies: 190 190 2147
-- Name: PK_TipoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoDisciplina"
    ADD CONSTRAINT "PK_TipoDisciplina" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2088 (class 2606 OID 54725)
-- Dependencies: 191 191 2147
-- Name: PK_TipoUsuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "PK_TipoUsuario" PRIMARY KEY ("PK_TipoUsuario");


--
-- TOC entry 2060 (class 2606 OID 54727)
-- Dependencies: 167 167 2147
-- Name: PK_Turma; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma" PRIMARY KEY ("PK_Turma");


--
-- TOC entry 2084 (class 2606 OID 54729)
-- Dependencies: 187 187 187 187 187 2147
-- Name: PK_TurmaHorario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "PK_TurmaHorario" PRIMARY KEY ("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal");


--
-- TOC entry 2097 (class 2606 OID 55896)
-- Dependencies: 199 199 2147
-- Name: PK_Unidade; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Unidade"
    ADD CONSTRAINT "PK_Unidade" PRIMARY KEY ("PK_Unidade");


--
-- TOC entry 2092 (class 2606 OID 54731)
-- Dependencies: 193 193 2147
-- Name: PK_Usuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "PK_Usuario" PRIMARY KEY ("PK_Login");


--
-- TOC entry 2095 (class 2606 OID 54733)
-- Dependencies: 194 194 2147
-- Name: PK_VariavelAmbiente; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "VariavelAmbiente"
    ADD CONSTRAINT "PK_VariavelAmbiente" PRIMARY KEY ("PK_Variavel");


--
-- TOC entry 2054 (class 2606 OID 54735)
-- Dependencies: 164 164 2147
-- Name: Unique_AlunoDisciplinaStatus_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "Unique_AlunoDisciplinaStatus_Nome" UNIQUE ("Nome");


--
-- TOC entry 2058 (class 2606 OID 54737)
-- Dependencies: 165 165 165 165 165 2147
-- Name: Unique_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "Unique_AlunoTurmaSelecionada" UNIQUE ("FK_Aluno", "FK_Turma", "Opcao", "NoLinha");


--
-- TOC entry 2090 (class 2606 OID 54739)
-- Dependencies: 191 191 2147
-- Name: Unique_TipoUsuario_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "Unique_TipoUsuario_Nome" UNIQUE ("Nome");


--
-- TOC entry 2099 (class 2606 OID 55898)
-- Dependencies: 199 199 2147
-- Name: Unique_Unidade_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Unidade"
    ADD CONSTRAINT "Unique_Unidade_Nome" UNIQUE ("Nome");


--
-- TOC entry 2082 (class 1259 OID 54740)
-- Dependencies: 186 2147
-- Name: Professor_Nome_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Professor_Nome_Index" ON "Professor" USING btree ("Nome");


--
-- TOC entry 2061 (class 1259 OID 54741)
-- Dependencies: 167 167 167 2147
-- Name: Turma_Disciplina_Codigo_Periodo_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Turma_Disciplina_Codigo_Periodo_Index" ON "Turma" USING btree ("FK_Disciplina", "Codigo", "PeriodoAno");


--
-- TOC entry 2093 (class 1259 OID 54742)
-- Dependencies: 193 2147
-- Name: Usuario_HashSession_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Usuario_HashSession_Index" ON "Usuario" USING btree ("HashSessao");


--
-- TOC entry 2012 (class 2618 OID 54743)
-- Dependencies: 165 165 165 165 165 165 165 165 2147
-- Name: AlunoTurmaSelecionadaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "AlunoTurmaSelecionadaDuplicada" AS ON INSERT TO "AlunoTurmaSelecionada" WHERE (EXISTS (SELECT 1 FROM "AlunoTurmaSelecionada" ats WHERE (((ats."FK_Aluno")::text = (new."FK_Aluno")::text) AND (ats."FK_Turma" = new."FK_Turma")))) DO INSTEAD UPDATE "AlunoTurmaSelecionada" ats SET "Opcao" = new."Opcao", "NoLinha" = new."NoLinha" WHERE (((ats."FK_Aluno")::text = (new."FK_Aluno")::text) AND (ats."FK_Turma" = new."FK_Turma"));


--
-- TOC entry 2013 (class 2618 OID 54745)
-- Dependencies: 176 176 176 176 176 2147
-- Name: CursoDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "CursoDuplicado" AS ON INSERT TO "Curso" WHERE (EXISTS (SELECT 1 FROM "Curso" d WHERE ((d."PK_Curso")::text = (new."PK_Curso")::text))) DO INSTEAD UPDATE "Curso" d SET "Nome" = new."Nome" WHERE ((d."PK_Curso")::text = (new."PK_Curso")::text);


--
-- TOC entry 2024 (class 2618 OID 55937)
-- Dependencies: 167 167 187 167 2147
-- Name: DeletarTurma; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "DeletarTurma" AS ON DELETE TO "Turma" DO INSTEAD (UPDATE "Turma" SET "Deletada" = true WHERE ("Turma"."PK_Turma" = old."PK_Turma"); DELETE FROM "TurmaHorario" WHERE ("TurmaHorario"."FK_Turma" = old."PK_Turma"); );


--
-- TOC entry 2014 (class 2618 OID 54747)
-- Dependencies: 177 177 177 177 177 177 2147
-- Name: DisciplinaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "DisciplinaDuplicada" AS ON INSERT TO "Disciplina" WHERE (EXISTS (SELECT 1 FROM "Disciplina" d WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text))) DO INSTEAD UPDATE "Disciplina" d SET "Nome" = new."Nome", "Creditos" = new."Creditos" WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text);


--
-- TOC entry 2015 (class 2618 OID 54749)
-- Dependencies: 178 178 178 178 178 2147
-- Name: OptativaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "OptativaDuplicada" AS ON INSERT TO "Optativa" WHERE (EXISTS (SELECT 1 FROM "Optativa" d WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text))) DO INSTEAD UPDATE "Optativa" d SET "Nome" = new."Nome" WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text);


--
-- TOC entry 2016 (class 2618 OID 54751)
-- Dependencies: 186 186 186 186 2147
-- Name: ProfessorDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "ProfessorDuplicado" AS ON INSERT TO "Professor" WHERE (EXISTS (SELECT 1 FROM "Professor" d WHERE ((d."Nome")::text = (new."Nome")::text))) DO INSTEAD NOTHING;


--
-- TOC entry 2017 (class 2618 OID 54752)
-- Dependencies: 167 167 167 167 167 167 167 167 167 167 167 167 167 2147
-- Name: TurmaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaDuplicada" AS ON INSERT TO "Turma" WHERE (EXISTS (SELECT 1 FROM "Turma" t WHERE ((((t."FK_Disciplina")::text = (new."FK_Disciplina")::text) AND ((t."Codigo")::text = (new."Codigo")::text)) AND (t."PeriodoAno" = new."PeriodoAno")))) DO INSTEAD UPDATE "Turma" t SET "Vagas" = new."Vagas", "Destino" = new."Destino", "HorasDistancia" = new."HorasDistancia", "SHF" = new."SHF", "FK_Professor" = new."FK_Professor", "Deletada" = false WHERE ((((t."FK_Disciplina")::text = (new."FK_Disciplina")::text) AND ((t."Codigo")::text = (new."Codigo")::text)) AND (t."PeriodoAno" = new."PeriodoAno"));


--
-- TOC entry 2018 (class 2618 OID 54754)
-- Dependencies: 187 187 187 187 187 187 187 2147
-- Name: TurmaHorarioDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaHorarioDuplicado" AS ON INSERT TO "TurmaHorario" WHERE (EXISTS (SELECT 1 FROM "TurmaHorario" th WHERE ((((th."FK_Turma" = new."FK_Turma") AND (th."DiaSemana" = new."DiaSemana")) AND (th."HoraInicial" = new."HoraInicial")) AND (th."HoraFinal" = new."HoraFinal")))) DO INSTEAD NOTHING;


--
-- TOC entry 2023 (class 2618 OID 55918)
-- Dependencies: 199 199 199 199 2147
-- Name: UnidadeDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "UnidadeDuplicada" AS ON INSERT TO "Unidade" WHERE (EXISTS (SELECT 1 FROM "Unidade" u WHERE ((u."Nome")::text = (new."Nome")::text))) DO INSTEAD NOTHING;


--
-- TOC entry 2106 (class 2606 OID 55858)
-- Dependencies: 2045 163 161 2147
-- Name: FK_AlunoDisciplinaAptoCache_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplinaAptoCache"
    ADD CONSTRAINT "FK_AlunoDisciplinaAptoCache_Aluno" FOREIGN KEY ("Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2107 (class 2606 OID 55863)
-- Dependencies: 163 2070 177 2147
-- Name: FK_AlunoDisciplinaAptoCache_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplinaAptoCache"
    ADD CONSTRAINT "FK_AlunoDisciplinaAptoCache_Disciplina" FOREIGN KEY ("Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2102 (class 2606 OID 54755)
-- Dependencies: 2045 161 162 2147
-- Name: FK_AlunoDisciplina_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2103 (class 2606 OID 54760)
-- Dependencies: 162 2051 164 2147
-- Name: FK_AlunoDisciplina_AlunoDisciplinaStatus; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_AlunoDisciplinaStatus" FOREIGN KEY ("FK_Status") REFERENCES "AlunoDisciplinaStatus"("PK_Status") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2104 (class 2606 OID 54765)
-- Dependencies: 162 2070 177 2147
-- Name: FK_AlunoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2105 (class 2606 OID 54770)
-- Dependencies: 2085 162 190 2147
-- Name: FK_AlunoDisciplina_TipoDisciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_TipoDisciplina" FOREIGN KEY ("FK_TipoDisciplina") REFERENCES "TipoDisciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2108 (class 2606 OID 54775)
-- Dependencies: 161 2045 165 2147
-- Name: FK_AlunoTurmaSelecionada_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2109 (class 2606 OID 54780)
-- Dependencies: 165 167 2059 2147
-- Name: FK_AlunoTurmaSelecionada_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2100 (class 2606 OID 54785)
-- Dependencies: 2068 161 176 2147
-- Name: FK_Aluno_Curso; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Curso" FOREIGN KEY ("FK_Curso") REFERENCES "Curso"("PK_Curso") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2101 (class 2606 OID 54790)
-- Dependencies: 193 161 2091 2147
-- Name: FK_Aluno_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Usuario" FOREIGN KEY ("FK_Matricula") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2120 (class 2606 OID 55884)
-- Dependencies: 2091 184 193 2147
-- Name: FK_Log_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "FK_Log_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2116 (class 2606 OID 54800)
-- Dependencies: 161 179 2045 2147
-- Name: FK_OptativaAluno_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2117 (class 2606 OID 54805)
-- Dependencies: 178 2072 179 2147
-- Name: FK_OptativaAluno_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2118 (class 2606 OID 54810)
-- Dependencies: 177 2070 181 2147
-- Name: FK_OptativaDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2119 (class 2606 OID 54815)
-- Dependencies: 178 2072 181 2147
-- Name: FK_OptativaDisciplina_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2112 (class 2606 OID 54820)
-- Dependencies: 169 2070 177 2147
-- Name: FK_PreRequisitoGrupoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2113 (class 2606 OID 54825)
-- Dependencies: 169 2064 172 2147
-- Name: FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo" FOREIGN KEY ("FK_PreRequisitoGrupo") REFERENCES "PreRequisitoGrupo"("PK_PreRequisitoGrupo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2114 (class 2606 OID 54830)
-- Dependencies: 172 177 2070 2147
-- Name: FK_PreRequisitoGrupo_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "FK_PreRequisitoGrupo_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2115 (class 2606 OID 54835)
-- Dependencies: 193 2091 175 2147
-- Name: FK_Sugestao_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "FK_Sugestao_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2121 (class 2606 OID 55904)
-- Dependencies: 187 167 2059 2147
-- Name: FK_TurmaHorario_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "FK_TurmaHorario_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2122 (class 2606 OID 55909)
-- Dependencies: 187 199 2096 2147
-- Name: FK_TurmaHorario_Unidade; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "FK_TurmaHorario_Unidade" FOREIGN KEY ("FK_Unidade") REFERENCES "Unidade"("PK_Unidade") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2110 (class 2606 OID 55925)
-- Dependencies: 2080 167 186 2147
-- Name: FK_Turma_Professor; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "FK_Turma_Professor" FOREIGN KEY ("FK_Professor") REFERENCES "Professor"("PK_Professor") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2123 (class 2606 OID 54850)
-- Dependencies: 193 191 2087 2147
-- Name: FK_Usuario_TipoUsuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "FK_Usuario_TipoUsuario" FOREIGN KEY ("FK_TipoUsuario") REFERENCES "TipoUsuario"("PK_TipoUsuario") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2111 (class 2606 OID 55930)
-- Dependencies: 177 167 2070 2147
-- Name: PK_Turma_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2012-12-14 14:21:41 BRST

--
-- PostgreSQL database dump complete
--

