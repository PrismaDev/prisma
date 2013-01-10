--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.5
-- Dumped by pg_dump version 9.1.5
-- Started on 2012-12-25 22:07:37 BRST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 212 (class 3079 OID 11646)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2207 (class 0 OID 0)
-- Dependencies: 212
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 228 (class 1255 OID 64977)
-- Dependencies: 6
-- Name: AlunoCreditos(character varying, character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoCreditos"(character varying, character varying) RETURNS integer
    LANGUAGE sql
    AS $_$
	SELECT COALESCE(SUM(d."Creditos"),0)::integer
	FROM "AlunoDisciplina" ad
		INNER JOIN "Disciplina" d
			ON(ad."FK_Disciplina" = d."PK_Codigo")
	WHERE ad."FK_Aluno" =  $1 AND "FK_Status" = $2
$_$;


ALTER FUNCTION public."AlunoCreditos"(character varying, character varying) OWNER TO prisma;

--
-- TOC entry 224 (class 1255 OID 64978)
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
-- TOC entry 225 (class 1255 OID 64979)
-- Dependencies: 684 6
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
-- TOC entry 226 (class 1255 OID 64980)
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
-- TOC entry 227 (class 1255 OID 64981)
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
-- TOC entry 229 (class 1255 OID 64982)
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
-- TOC entry 230 (class 1255 OID 64983)
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
-- TOC entry 161 (class 1259 OID 64984)
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
-- TOC entry 162 (class 1259 OID 64987)
-- Dependencies: 2081 2082 6
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
-- TOC entry 163 (class 1259 OID 64992)
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
-- TOC entry 164 (class 1259 OID 64995)
-- Dependencies: 6
-- Name: AlunoDisciplinaStatus; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "AlunoDisciplinaStatus" (
    "PK_Status" character varying(2) NOT NULL,
    "Nome" character varying(20) NOT NULL
);


ALTER TABLE public."AlunoDisciplinaStatus" OWNER TO prisma;

--
-- TOC entry 165 (class 1259 OID 64998)
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
-- TOC entry 166 (class 1259 OID 65001)
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
-- TOC entry 2208 (class 0 OID 0)
-- Dependencies: 166
-- Name: seq_turma; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_turma', 1, true);


--
-- TOC entry 167 (class 1259 OID 65003)
-- Dependencies: 2083 2084 2085 2086 2087 6
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
-- TOC entry 168 (class 1259 OID 65011)
-- Dependencies: 2049 6
-- Name: AlunoDisciplinaTurmaSelecionada; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "AlunoDisciplinaTurmaSelecionada" AS
    SELECT t."FK_Disciplina" AS "CodigoDisciplina", ats."FK_Turma", ats."FK_Aluno" AS "MatriculaAluno", ats."Opcao", ats."NoLinha" FROM ("AlunoTurmaSelecionada" ats JOIN "Turma" t ON (((t."PK_Turma" = ats."FK_Turma") AND (t."Deletada" = false))));


ALTER TABLE public."AlunoDisciplinaTurmaSelecionada" OWNER TO prisma;

--
-- TOC entry 169 (class 1259 OID 65015)
-- Dependencies: 6
-- Name: PreRequisitoGrupoDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "PreRequisitoGrupoDisciplina" (
    "FK_PreRequisitoGrupo" bigint NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."PreRequisitoGrupoDisciplina" OWNER TO prisma;

--
-- TOC entry 170 (class 1259 OID 65018)
-- Dependencies: 2050 6
-- Name: AlunoPreRequisitoGrupoDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "AlunoPreRequisitoGrupoDisciplina" AS
    SELECT t."FK_Matricula" AS "FK_Aluno", t."FK_PreRequisitoGrupo", t."FK_Disciplina", COALESCE(ad."FK_Status", 'NC'::character varying) AS "Situacao" FROM ((SELECT a."FK_Matricula", prgd."FK_PreRequisitoGrupo", prgd."FK_Disciplina" FROM "PreRequisitoGrupoDisciplina" prgd, "Aluno" a) t LEFT JOIN "AlunoDisciplina" ad ON ((((ad."FK_Aluno")::text = (t."FK_Matricula")::text) AND ((ad."FK_Disciplina")::text = (t."FK_Disciplina")::text))));


ALTER TABLE public."AlunoPreRequisitoGrupoDisciplina" OWNER TO prisma;

--
-- TOC entry 171 (class 1259 OID 65022)
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
-- TOC entry 2209 (class 0 OID 0)
-- Dependencies: 171
-- Name: seq_prerequisito; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_prerequisito', 1, true);


--
-- TOC entry 172 (class 1259 OID 65024)
-- Dependencies: 2088 2089 6
-- Name: PreRequisitoGrupo; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "PreRequisitoGrupo" (
    "PK_PreRequisitoGrupo" bigint DEFAULT nextval('seq_prerequisito'::regclass) NOT NULL,
    "CreditosMinimos" integer DEFAULT 0 NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."PreRequisitoGrupo" OWNER TO prisma;

--
-- TOC entry 173 (class 1259 OID 65029)
-- Dependencies: 2051 6
-- Name: AlunoPreRequisitoGrupoDisciplinaApto; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "AlunoPreRequisitoGrupoDisciplinaApto" AS
    SELECT a."FK_Matricula" AS "FK_Aluno", prg."PK_PreRequisitoGrupo" AS "FK_PreRequisitoGrupo", CASE WHEN (("AlunoCreditos"(a."FK_Matricula", 'CP'::character varying) + "AlunoCreditos"(a."FK_Matricula", 'EA'::character varying)) < prg."CreditosMinimos") THEN 0 WHEN (EXISTS (SELECT 1 FROM "AlunoPreRequisitoGrupoDisciplina" aprgd1 WHERE ((((aprgd1."FK_Aluno")::text = (a."FK_Matricula")::text) AND (aprgd1."FK_PreRequisitoGrupo" = prg."PK_PreRequisitoGrupo")) AND ((aprgd1."Situacao")::text = 'NC'::text)))) THEN 0 WHEN ("AlunoCreditos"(a."FK_Matricula", 'CP'::character varying) < prg."CreditosMinimos") THEN 1 WHEN (EXISTS (SELECT 1 FROM "AlunoPreRequisitoGrupoDisciplina" aprgd1 WHERE ((((aprgd1."FK_Aluno")::text = (a."FK_Matricula")::text) AND (aprgd1."FK_PreRequisitoGrupo" = prg."PK_PreRequisitoGrupo")) AND ((aprgd1."Situacao")::text = 'EA'::text)))) THEN 1 ELSE 2 END AS "Apto" FROM "Aluno" a, "PreRequisitoGrupo" prg;


ALTER TABLE public."AlunoPreRequisitoGrupoDisciplinaApto" OWNER TO prisma;

--
-- TOC entry 174 (class 1259 OID 65034)
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
-- TOC entry 2210 (class 0 OID 0)
-- Dependencies: 174
-- Name: seq_sugestao; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_sugestao', 1, true);


--
-- TOC entry 175 (class 1259 OID 65036)
-- Dependencies: 2090 2091 6
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
-- TOC entry 176 (class 1259 OID 65044)
-- Dependencies: 6
-- Name: Curso; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Curso" (
    "PK_Curso" character varying(3) NOT NULL,
    "Nome" character varying(50) NOT NULL
);


ALTER TABLE public."Curso" OWNER TO prisma;

--
-- TOC entry 177 (class 1259 OID 65047)
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
-- TOC entry 178 (class 1259 OID 65050)
-- Dependencies: 6
-- Name: Optativa; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Optativa" (
    "PK_Codigo" character varying(7) NOT NULL,
    "Nome" character varying(100) NOT NULL
);


ALTER TABLE public."Optativa" OWNER TO prisma;

--
-- TOC entry 179 (class 1259 OID 65053)
-- Dependencies: 2092 6
-- Name: OptativaAluno; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "OptativaAluno" (
    "FK_Optativa" character varying(7) NOT NULL,
    "FK_Aluno" character varying(20) NOT NULL,
    "PeriodoSugerido" integer DEFAULT 1 NOT NULL
);


ALTER TABLE public."OptativaAluno" OWNER TO prisma;

--
-- TOC entry 180 (class 1259 OID 65057)
-- Dependencies: 2052 6
-- Name: FaltaCursarOptativa; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "FaltaCursarOptativa" AS
    SELECT oa."FK_Aluno" AS "Aluno", o."PK_Codigo" AS "CodigoOptativa", o."Nome" AS "NomeOptativa", oa."PeriodoSugerido" FROM ("Optativa" o JOIN "OptativaAluno" oa ON (((o."PK_Codigo")::text = (oa."FK_Optativa")::text))) WHERE (NOT "AlunoOptativaCursada"(oa."FK_Aluno", o."PK_Codigo"));


ALTER TABLE public."FaltaCursarOptativa" OWNER TO prisma;

--
-- TOC entry 181 (class 1259 OID 65061)
-- Dependencies: 6
-- Name: OptativaDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "OptativaDisciplina" (
    "FK_Optativa" character varying(7) NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."OptativaDisciplina" OWNER TO prisma;

--
-- TOC entry 182 (class 1259 OID 65064)
-- Dependencies: 2053 6
-- Name: FaltaCursarOptativaDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "FaltaCursarOptativaDisciplina" AS
    SELECT fco."Aluno", fco."CodigoOptativa", od."FK_Disciplina" AS "CodigoDisciplina", COALESCE(ad."FK_Status", 'NC'::character varying) AS "Situacao", "AlunoDisciplinaApto"(fco."Aluno", od."FK_Disciplina") AS "Apto" FROM (("FaltaCursarOptativa" fco JOIN "OptativaDisciplina" od ON (((od."FK_Optativa")::text = (fco."CodigoOptativa")::text))) LEFT JOIN "AlunoDisciplina" ad ON ((((ad."FK_Disciplina")::text = (od."FK_Disciplina")::text) AND ((fco."Aluno")::text = (ad."FK_Aluno")::text))));


ALTER TABLE public."FaltaCursarOptativaDisciplina" OWNER TO prisma;

--
-- TOC entry 183 (class 1259 OID 65068)
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
-- TOC entry 2211 (class 0 OID 0)
-- Dependencies: 183
-- Name: seq_log; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_log', 1, true);


--
-- TOC entry 184 (class 1259 OID 65070)
-- Dependencies: 2093 2094 2095 6
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
-- TOC entry 185 (class 1259 OID 65079)
-- Dependencies: 2054 6
-- Name: LogAcessoSegundo; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogAcessoSegundo" AS
    SELECT date_part('year'::text, "Log"."DataHora") AS "Ano", date_part('month'::text, "Log"."DataHora") AS "Mes", date_part('day'::text, "Log"."DataHora") AS "Dia", date_part('hour'::text, "Log"."DataHora") AS "Hora", date_part('minute'::text, "Log"."DataHora") AS "Minuto", (date_part('second'::text, "Log"."DataHora"))::integer AS "Segundo", count(*) AS "Quantidade" FROM "Log" WHERE ("Log"."Erro" = false) GROUP BY date_part('year'::text, "Log"."DataHora"), date_part('month'::text, "Log"."DataHora"), date_part('day'::text, "Log"."DataHora"), date_part('hour'::text, "Log"."DataHora"), date_part('minute'::text, "Log"."DataHora"), (date_part('second'::text, "Log"."DataHora"))::integer ORDER BY date_part('year'::text, "Log"."DataHora") DESC, date_part('month'::text, "Log"."DataHora") DESC, date_part('day'::text, "Log"."DataHora") DESC, date_part('hour'::text, "Log"."DataHora") DESC, date_part('minute'::text, "Log"."DataHora") DESC, (date_part('second'::text, "Log"."DataHora"))::integer DESC;


ALTER TABLE public."LogAcessoSegundo" OWNER TO prisma;

--
-- TOC entry 186 (class 1259 OID 65083)
-- Dependencies: 2055 6
-- Name: LogAlunoAno; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogAlunoAno" AS
    SELECT ('20'::text || "substring"(("Log"."FK_Usuario")::text, 1, 3)) AS "AnoEntrada", count(DISTINCT "Log"."FK_Usuario") AS count FROM ("Log" JOIN "Aluno" ON ((("Log"."FK_Usuario")::text = ("Aluno"."FK_Matricula")::text))) GROUP BY ('20'::text || "substring"(("Log"."FK_Usuario")::text, 1, 3)) ORDER BY count(DISTINCT "Log"."FK_Usuario") DESC, ('20'::text || "substring"(("Log"."FK_Usuario")::text, 1, 3));


ALTER TABLE public."LogAlunoAno" OWNER TO prisma;

--
-- TOC entry 187 (class 1259 OID 65087)
-- Dependencies: 2056 6
-- Name: LogAlunoCurso; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogAlunoCurso" AS
    SELECT t1."Codigo" AS "CodigoCurso", t1."Nome" AS "NomeCurso", COALESCE(t2.count, (0)::bigint) AS "Atual", t1.count AS "Total", round((((COALESCE(t2.count, (0)::bigint))::numeric / (t1.count)::numeric) * (100)::numeric), 2) AS "Porcentagem" FROM ((SELECT c."PK_Curso" AS "Codigo", c."Nome", count(DISTINCT a."FK_Matricula") AS count FROM ("Aluno" a JOIN "Curso" c ON (((c."PK_Curso")::text = (a."FK_Curso")::text))) GROUP BY c."PK_Curso", c."Nome") t1 LEFT JOIN (SELECT c."PK_Curso" AS "Codigo", c."Nome", count(DISTINCT l."FK_Usuario") AS count FROM (("Log" l JOIN "Aluno" a ON (((a."FK_Matricula")::text = (l."FK_Usuario")::text))) JOIN "Curso" c ON (((a."FK_Curso")::text = (c."PK_Curso")::text))) GROUP BY c."PK_Curso", c."Nome") t2 ON (((t1."Codigo")::text = (t2."Codigo")::text))) ORDER BY t1."Nome";


ALTER TABLE public."LogAlunoCurso" OWNER TO prisma;

--
-- TOC entry 188 (class 1259 OID 65092)
-- Dependencies: 2057 6
-- Name: LogAlunoSelecionada; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogAlunoSelecionada" AS
    SELECT count(t."FK_Aluno") AS "QuantidadeAluno", round(avg(t.count), 3) AS "MediaSelecionada" FROM (SELECT "AlunoTurmaSelecionada"."FK_Aluno", count(*) AS count FROM "AlunoTurmaSelecionada" GROUP BY "AlunoTurmaSelecionada"."FK_Aluno" ORDER BY "AlunoTurmaSelecionada"."FK_Aluno") t;


ALTER TABLE public."LogAlunoSelecionada" OWNER TO prisma;

--
-- TOC entry 189 (class 1259 OID 65096)
-- Dependencies: 2058 6
-- Name: LogErro; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogErro" AS
    SELECT "Log"."PK_Log", "Log"."DataHora", "Log"."IP", "Log"."URI", "Log"."HashSessao", "Log"."Erro", "Log"."Notas", "Log"."FK_Usuario", "Log"."Browser" FROM "Log" WHERE ("Log"."Erro" = true);


ALTER TABLE public."LogErro" OWNER TO prisma;

--
-- TOC entry 190 (class 1259 OID 65100)
-- Dependencies: 2059 6
-- Name: LogHistogramaBrowserUsuario; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogHistogramaBrowserUsuario" AS
    SELECT "Log"."Browser", count(DISTINCT "Log"."FK_Usuario") AS count FROM "Log" GROUP BY "Log"."Browser" ORDER BY count(DISTINCT "Log"."FK_Usuario") DESC, "Log"."Browser";


ALTER TABLE public."LogHistogramaBrowserUsuario" OWNER TO prisma;

--
-- TOC entry 191 (class 1259 OID 65104)
-- Dependencies: 2060 6
-- Name: LogOcupacaoTurma; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogOcupacaoTurma" AS
    SELECT t."FK_Disciplina" AS "CodigoDisciplina", t."Codigo" AS "CodigoTurma", t."PeriodoAno", ats."Opcao", count(DISTINCT ats."FK_Aluno") AS "QuantidadeAluno", t."Vagas", trunc((((count(DISTINCT ats."FK_Aluno"))::numeric / (t."Vagas")::numeric) * (100)::numeric), 2) AS "Porcentagem" FROM ("AlunoTurmaSelecionada" ats JOIN "Turma" t ON ((t."PK_Turma" = ats."FK_Turma"))) GROUP BY ats."FK_Turma", t."FK_Disciplina", t."Codigo", t."PeriodoAno", ats."Opcao", t."Vagas" ORDER BY ats."FK_Turma", t."FK_Disciplina", t."Codigo", t."PeriodoAno", ats."Opcao", count(DISTINCT ats."FK_Aluno"), t."Vagas", trunc((((count(DISTINCT ats."FK_Aluno"))::numeric / (t."Vagas")::numeric) * (100)::numeric), 2);


ALTER TABLE public."LogOcupacaoTurma" OWNER TO prisma;

--
-- TOC entry 192 (class 1259 OID 65109)
-- Dependencies: 2061 6
-- Name: LogQuantidadeUsuario; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogQuantidadeUsuario" AS
    SELECT count(DISTINCT "Log"."FK_Usuario") AS count FROM "Log";


ALTER TABLE public."LogQuantidadeUsuario" OWNER TO prisma;

--
-- TOC entry 193 (class 1259 OID 65113)
-- Dependencies: 2062 6
-- Name: LogUsuarioAcesso; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogUsuarioAcesso" AS
    SELECT t."Acessos", count(*) AS "QuantidadeUsuario" FROM (SELECT "Log"."FK_Usuario", count(DISTINCT "Log"."HashSessao") AS "Acessos" FROM "Log" GROUP BY "Log"."FK_Usuario") t GROUP BY t."Acessos" ORDER BY t."Acessos" DESC;


ALTER TABLE public."LogUsuarioAcesso" OWNER TO prisma;

--
-- TOC entry 194 (class 1259 OID 65117)
-- Dependencies: 2063 6
-- Name: LogUsuarioDia; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogUsuarioDia" AS
    SELECT ("Log"."DataHora")::date AS "Data", count(DISTINCT "Log"."FK_Usuario") AS count FROM "Log" GROUP BY ("Log"."DataHora")::date ORDER BY ("Log"."DataHora")::date DESC;


ALTER TABLE public."LogUsuarioDia" OWNER TO prisma;

--
-- TOC entry 195 (class 1259 OID 65121)
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
-- TOC entry 2212 (class 0 OID 0)
-- Dependencies: 195
-- Name: seq_professor; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_professor', 1, true);


--
-- TOC entry 196 (class 1259 OID 65123)
-- Dependencies: 2096 6
-- Name: Professor; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Professor" (
    "PK_Professor" bigint DEFAULT nextval('seq_professor'::regclass) NOT NULL,
    "Nome" character varying(100) NOT NULL
);


ALTER TABLE public."Professor" OWNER TO prisma;

--
-- TOC entry 197 (class 1259 OID 65127)
-- Dependencies: 2097 6
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
-- TOC entry 198 (class 1259 OID 65131)
-- Dependencies: 2064 6
-- Name: MicroHorario; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "MicroHorario" AS
    SELECT d."PK_Codigo" AS "CodigoDisciplina", d."Nome" AS "NomeDisciplina", d."Creditos", t."PK_Turma", t."Codigo" AS "CodigoTurma", t."PeriodoAno", t."Vagas", t."Destino", t."HorasDistancia", t."SHF", p."Nome" AS "NomeProfessor", th."DiaSemana", th."HoraInicial", th."HoraFinal" FROM ((("Disciplina" d JOIN "Turma" t ON (((t."FK_Disciplina")::text = (d."PK_Codigo")::text))) JOIN "Professor" p ON ((t."FK_Professor" = p."PK_Professor"))) JOIN "TurmaHorario" th ON (((th."FK_Turma" = t."PK_Turma") AND (t."Deletada" = false))));


ALTER TABLE public."MicroHorario" OWNER TO prisma;

--
-- TOC entry 199 (class 1259 OID 65136)
-- Dependencies: 2065 6
-- Name: MicroHorarioDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "MicroHorarioDisciplina" AS
    SELECT t."Aluno", t."CodigoDisciplina", t."NomeDisciplina", t."Creditos", COALESCE(ad."FK_Status", 'NC'::character varying) AS "Situacao", "AlunoDisciplinaApto"(t."Aluno", t."CodigoDisciplina") AS "Apto" FROM ((SELECT a."FK_Matricula" AS "Aluno", d."PK_Codigo" AS "CodigoDisciplina", d."Nome" AS "NomeDisciplina", d."Creditos" FROM "Disciplina" d, "Aluno" a) t LEFT JOIN "AlunoDisciplina" ad ON ((((ad."FK_Aluno")::text = (t."Aluno")::text) AND ((ad."FK_Disciplina")::text = (t."CodigoDisciplina")::text))));


ALTER TABLE public."MicroHorarioDisciplina" OWNER TO prisma;

--
-- TOC entry 200 (class 1259 OID 65141)
-- Dependencies: 2066 6
-- Name: PopulaAlunoDisciplinaAptoCacheFaltaCursarDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "PopulaAlunoDisciplinaAptoCacheFaltaCursarDisciplina" AS
    SELECT "AlunoDisciplinaApto"("AlunoDisciplina"."FK_Aluno", "AlunoDisciplina"."FK_Disciplina") AS "AlunoDisciplinaApto" FROM "AlunoDisciplina" WHERE (("AlunoDisciplina"."FK_Status")::text <> 'CP'::text);


ALTER TABLE public."PopulaAlunoDisciplinaAptoCacheFaltaCursarDisciplina" OWNER TO prisma;

--
-- TOC entry 201 (class 1259 OID 65145)
-- Dependencies: 2067 6
-- Name: PopulaAlunoDisciplinaAptoCacheFaltaCursarOptativa; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "PopulaAlunoDisciplinaAptoCacheFaltaCursarOptativa" AS
    SELECT "AlunoDisciplinaApto"(oa."FK_Aluno", od."FK_Disciplina") AS "AlunoDisciplinaApto" FROM ("OptativaAluno" oa JOIN "OptativaDisciplina" od ON (((oa."FK_Optativa")::text = (od."FK_Optativa")::text))) WHERE ("AlunoOptativaCursada"(oa."FK_Aluno", od."FK_Disciplina") = false);


ALTER TABLE public."PopulaAlunoDisciplinaAptoCacheFaltaCursarOptativa" OWNER TO prisma;

--
-- TOC entry 202 (class 1259 OID 65149)
-- Dependencies: 2068 6
-- Name: PopulaAlunoDisciplinaAptoCacheTurmaSelecionada; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "PopulaAlunoDisciplinaAptoCacheTurmaSelecionada" AS
    SELECT "AlunoDisciplinaApto"(ats."FK_Aluno", t."FK_Disciplina") AS "AlunoDisciplinaApto" FROM ("AlunoTurmaSelecionada" ats JOIN "Turma" t ON ((t."PK_Turma" = ats."FK_Turma")));


ALTER TABLE public."PopulaAlunoDisciplinaAptoCacheTurmaSelecionada" OWNER TO prisma;

--
-- TOC entry 203 (class 1259 OID 65153)
-- Dependencies: 6
-- Name: TipoDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TipoDisciplina" (
    "PK_Codigo" character varying(2) NOT NULL,
    "Nome" character varying(50)
);


ALTER TABLE public."TipoDisciplina" OWNER TO prisma;

--
-- TOC entry 204 (class 1259 OID 65156)
-- Dependencies: 6
-- Name: TipoUsuario; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TipoUsuario" (
    "PK_TipoUsuario" integer NOT NULL,
    "Nome" character varying(20) NOT NULL
);


ALTER TABLE public."TipoUsuario" OWNER TO prisma;

--
-- TOC entry 205 (class 1259 OID 65159)
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
-- TOC entry 2213 (class 0 OID 0)
-- Dependencies: 205
-- Name: seq_unidade; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_unidade', 1, true);


--
-- TOC entry 206 (class 1259 OID 65161)
-- Dependencies: 2098 6
-- Name: Unidade; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Unidade" (
    "PK_Unidade" bigint DEFAULT nextval('seq_unidade'::regclass) NOT NULL,
    "Nome" character varying(50) NOT NULL
);


ALTER TABLE public."Unidade" OWNER TO prisma;

--
-- TOC entry 207 (class 1259 OID 65165)
-- Dependencies: 2069 6
-- Name: TurmaHorarioUnidade; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "TurmaHorarioUnidade" AS
    SELECT th."FK_Turma", th."DiaSemana", th."HoraInicial", th."HoraFinal", u."Nome" AS "Unidade" FROM ("TurmaHorario" th JOIN "Unidade" u ON ((u."PK_Unidade" = th."FK_Unidade")));


ALTER TABLE public."TurmaHorarioUnidade" OWNER TO prisma;

--
-- TOC entry 208 (class 1259 OID 65169)
-- Dependencies: 2070 6
-- Name: TurmaProfessor; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "TurmaProfessor" AS
    SELECT t."PK_Turma", t."Codigo" AS "CodigoTurma", t."FK_Disciplina" AS "CodigoDisciplina", t."PeriodoAno", t."Vagas", t."Destino", t."HorasDistancia", t."SHF", p."Nome" AS "NomeProfessor" FROM ("Turma" t JOIN "Professor" p ON ((t."FK_Professor" = p."PK_Professor"))) WHERE (t."Deletada" = false);


ALTER TABLE public."TurmaProfessor" OWNER TO prisma;

--
-- TOC entry 209 (class 1259 OID 65173)
-- Dependencies: 2099 6
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
-- TOC entry 210 (class 1259 OID 65177)
-- Dependencies: 2071 6
-- Name: UsuarioAluno; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "UsuarioAluno" AS
    SELECT u."PK_Login" AS "Matricula", u."Nome" AS "NomeAluno", c."Nome" AS "Curso", u."UltimoAcesso", a."CoeficienteRendimento" AS "CR" FROM (("Usuario" u JOIN "Aluno" a ON (((u."PK_Login")::text = (a."FK_Matricula")::text))) JOIN "Curso" c ON (((c."PK_Curso")::text = (a."FK_Curso")::text))) WHERE (u."FK_TipoUsuario" = 3);


ALTER TABLE public."UsuarioAluno" OWNER TO prisma;

--
-- TOC entry 211 (class 1259 OID 65181)
-- Dependencies: 2100 6
-- Name: VariavelAmbiente; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "VariavelAmbiente" (
    "PK_Variavel" character varying(30) NOT NULL,
    "Habilitada" boolean DEFAULT true NOT NULL,
    "Descricao" text
);


ALTER TABLE public."VariavelAmbiente" OWNER TO prisma;

--
-- TOC entry 2180 (class 0 OID 64984)
-- Dependencies: 161 2202
-- Data for Name: Aluno; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Aluno" ("FK_Matricula", "CoeficienteRendimento", "FK_Curso") FROM stdin;
\.


--
-- TOC entry 2181 (class 0 OID 64987)
-- Dependencies: 162 2202
-- Data for Name: AlunoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoDisciplina" ("FK_Aluno", "FK_Disciplina", "FK_Status", "Tentativas", "Periodo", "FK_TipoDisciplina") FROM stdin;
\.


--
-- TOC entry 2182 (class 0 OID 64992)
-- Dependencies: 163 2202
-- Data for Name: AlunoDisciplinaAptoCache; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoDisciplinaAptoCache" ("Aluno", "Disciplina", "Apto") FROM stdin;
\.


--
-- TOC entry 2183 (class 0 OID 64995)
-- Dependencies: 164 2202
-- Data for Name: AlunoDisciplinaStatus; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoDisciplinaStatus" ("PK_Status", "Nome") FROM stdin;
CP	Cumpriu
EA	Em andamento
NC	Não cumpriu
\.


--
-- TOC entry 2184 (class 0 OID 64998)
-- Dependencies: 165 2202
-- Data for Name: AlunoTurmaSelecionada; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoTurmaSelecionada" ("FK_Aluno", "FK_Turma", "Opcao", "NoLinha") FROM stdin;
\.


--
-- TOC entry 2188 (class 0 OID 65036)
-- Dependencies: 175 2202
-- Data for Name: Comentario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Comentario" ("PK_Sugestao", "FK_Usuario", "Comentario", "DataHora") FROM stdin;
\.


--
-- TOC entry 2189 (class 0 OID 65044)
-- Dependencies: 176 2202
-- Data for Name: Curso; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Curso" ("PK_Curso", "Nome") FROM stdin;
\.


--
-- TOC entry 2190 (class 0 OID 65047)
-- Dependencies: 177 2202
-- Data for Name: Disciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Disciplina" ("PK_Codigo", "Nome", "Creditos") FROM stdin;
\.


--
-- TOC entry 2194 (class 0 OID 65070)
-- Dependencies: 184 2202
-- Data for Name: Log; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Log" ("PK_Log", "DataHora", "IP", "URI", "HashSessao", "Erro", "Notas", "FK_Usuario", "Browser") FROM stdin;
\.


--
-- TOC entry 2191 (class 0 OID 65050)
-- Dependencies: 178 2202
-- Data for Name: Optativa; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Optativa" ("PK_Codigo", "Nome") FROM stdin;
\.


--
-- TOC entry 2192 (class 0 OID 65053)
-- Dependencies: 179 2202
-- Data for Name: OptativaAluno; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "OptativaAluno" ("FK_Optativa", "FK_Aluno", "PeriodoSugerido") FROM stdin;
\.


--
-- TOC entry 2193 (class 0 OID 65061)
-- Dependencies: 181 2202
-- Data for Name: OptativaDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "OptativaDisciplina" ("FK_Optativa", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2187 (class 0 OID 65024)
-- Dependencies: 172 2202
-- Data for Name: PreRequisitoGrupo; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "PreRequisitoGrupo" ("PK_PreRequisitoGrupo", "CreditosMinimos", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2186 (class 0 OID 65015)
-- Dependencies: 169 2202
-- Data for Name: PreRequisitoGrupoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "PreRequisitoGrupoDisciplina" ("FK_PreRequisitoGrupo", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2195 (class 0 OID 65123)
-- Dependencies: 196 2202
-- Data for Name: Professor; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Professor" ("PK_Professor", "Nome") FROM stdin;
\.


--
-- TOC entry 2197 (class 0 OID 65153)
-- Dependencies: 203 2202
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
-- TOC entry 2198 (class 0 OID 65156)
-- Dependencies: 204 2202
-- Data for Name: TipoUsuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "TipoUsuario" ("PK_TipoUsuario", "Nome") FROM stdin;
1	Administrador
2	Coordenador
3	Aluno
\.


--
-- TOC entry 2185 (class 0 OID 65003)
-- Dependencies: 167 2202
-- Data for Name: Turma; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Turma" ("PK_Turma", "FK_Disciplina", "Codigo", "PeriodoAno", "Vagas", "Destino", "HorasDistancia", "SHF", "FK_Professor", "Deletada") FROM stdin;
\.


--
-- TOC entry 2196 (class 0 OID 65127)
-- Dependencies: 197 2202
-- Data for Name: TurmaHorario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "TurmaHorario" ("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal", "FK_Unidade") FROM stdin;
\.


--
-- TOC entry 2199 (class 0 OID 65161)
-- Dependencies: 206 2202
-- Data for Name: Unidade; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Unidade" ("PK_Unidade", "Nome") FROM stdin;
\.


--
-- TOC entry 2200 (class 0 OID 65173)
-- Dependencies: 209 2202
-- Data for Name: Usuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Usuario" ("PK_Login", "Senha", "Nome", "HashSessao", "TermoAceito", "FK_TipoUsuario", "UltimoAcesso") FROM stdin;
\.


--
-- TOC entry 2201 (class 0 OID 65181)
-- Dependencies: 211 2202
-- Data for Name: VariavelAmbiente; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "VariavelAmbiente" ("PK_Variavel", "Habilitada", "Descricao") FROM stdin;
manutencao	f	Desculpe. O sistema encontra-se em manutenção. Por favor, tente mais tarde. Obrigado.
\.


--
-- TOC entry 2102 (class 2606 OID 65189)
-- Dependencies: 161 161 2203
-- Name: PK_Aluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "PK_Aluno" PRIMARY KEY ("FK_Matricula");


--
-- TOC entry 2104 (class 2606 OID 65191)
-- Dependencies: 162 162 162 2203
-- Name: PK_AlunoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "PK_AlunoDisciplina" PRIMARY KEY ("FK_Aluno", "FK_Disciplina");


--
-- TOC entry 2106 (class 2606 OID 65193)
-- Dependencies: 163 163 163 2203
-- Name: PK_AlunoDisciplinaAptoCache; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaAptoCache"
    ADD CONSTRAINT "PK_AlunoDisciplinaAptoCache" PRIMARY KEY ("Aluno", "Disciplina");


--
-- TOC entry 2108 (class 2606 OID 65198)
-- Dependencies: 164 164 2203
-- Name: PK_AlunoDisciplinaStatus; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "PK_AlunoDisciplinaStatus" PRIMARY KEY ("PK_Status");


--
-- TOC entry 2112 (class 2606 OID 65200)
-- Dependencies: 165 165 165 2203
-- Name: PK_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "PK_AlunoTurmaSelecionada" PRIMARY KEY ("FK_Aluno", "FK_Turma");


--
-- TOC entry 2125 (class 2606 OID 65202)
-- Dependencies: 176 176 2203
-- Name: PK_Curso; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Curso"
    ADD CONSTRAINT "PK_Curso" PRIMARY KEY ("PK_Curso");


--
-- TOC entry 2127 (class 2606 OID 65204)
-- Dependencies: 177 177 2203
-- Name: PK_Disciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Disciplina"
    ADD CONSTRAINT "PK_Disciplina" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2135 (class 2606 OID 65206)
-- Dependencies: 184 184 2203
-- Name: PK_Log; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "PK_Log" PRIMARY KEY ("PK_Log");


--
-- TOC entry 2129 (class 2606 OID 65209)
-- Dependencies: 178 178 2203
-- Name: PK_Optativa; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Optativa"
    ADD CONSTRAINT "PK_Optativa" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2131 (class 2606 OID 65211)
-- Dependencies: 179 179 179 2203
-- Name: PK_OptativaAluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "PK_OptativaAluno" PRIMARY KEY ("FK_Optativa", "FK_Aluno");


--
-- TOC entry 2133 (class 2606 OID 65215)
-- Dependencies: 181 181 181 2203
-- Name: PK_OptativaDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "PK_OptativaDisciplina" PRIMARY KEY ("FK_Optativa", "FK_Disciplina");


--
-- TOC entry 2121 (class 2606 OID 65217)
-- Dependencies: 172 172 2203
-- Name: PK_PreRequisitoGrupo; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "PK_PreRequisitoGrupo" PRIMARY KEY ("PK_PreRequisitoGrupo");


--
-- TOC entry 2119 (class 2606 OID 65219)
-- Dependencies: 169 169 169 2203
-- Name: PK_PreRequisitoGrupoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "PK_PreRequisitoGrupoDisciplina" PRIMARY KEY ("FK_PreRequisitoGrupo", "FK_Disciplina");


--
-- TOC entry 2137 (class 2606 OID 65221)
-- Dependencies: 196 196 2203
-- Name: PK_Professor; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Professor"
    ADD CONSTRAINT "PK_Professor" PRIMARY KEY ("PK_Professor");


--
-- TOC entry 2123 (class 2606 OID 65223)
-- Dependencies: 175 175 2203
-- Name: PK_Sugestao; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "PK_Sugestao" PRIMARY KEY ("PK_Sugestao");


--
-- TOC entry 2142 (class 2606 OID 65225)
-- Dependencies: 203 203 2203
-- Name: PK_TipoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoDisciplina"
    ADD CONSTRAINT "PK_TipoDisciplina" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2144 (class 2606 OID 65227)
-- Dependencies: 204 204 2203
-- Name: PK_TipoUsuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "PK_TipoUsuario" PRIMARY KEY ("PK_TipoUsuario");


--
-- TOC entry 2116 (class 2606 OID 65229)
-- Dependencies: 167 167 2203
-- Name: PK_Turma; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma" PRIMARY KEY ("PK_Turma");


--
-- TOC entry 2140 (class 2606 OID 65231)
-- Dependencies: 197 197 197 197 197 2203
-- Name: PK_TurmaHorario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "PK_TurmaHorario" PRIMARY KEY ("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal");


--
-- TOC entry 2148 (class 2606 OID 65233)
-- Dependencies: 206 206 2203
-- Name: PK_Unidade; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Unidade"
    ADD CONSTRAINT "PK_Unidade" PRIMARY KEY ("PK_Unidade");


--
-- TOC entry 2152 (class 2606 OID 65235)
-- Dependencies: 209 209 2203
-- Name: PK_Usuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "PK_Usuario" PRIMARY KEY ("PK_Login");


--
-- TOC entry 2155 (class 2606 OID 65237)
-- Dependencies: 211 211 2203
-- Name: PK_VariavelAmbiente; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "VariavelAmbiente"
    ADD CONSTRAINT "PK_VariavelAmbiente" PRIMARY KEY ("PK_Variavel");


--
-- TOC entry 2110 (class 2606 OID 65239)
-- Dependencies: 164 164 2203
-- Name: Unique_AlunoDisciplinaStatus_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "Unique_AlunoDisciplinaStatus_Nome" UNIQUE ("Nome");


--
-- TOC entry 2114 (class 2606 OID 65241)
-- Dependencies: 165 165 165 165 165 2203
-- Name: Unique_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "Unique_AlunoTurmaSelecionada" UNIQUE ("FK_Aluno", "FK_Turma", "Opcao", "NoLinha");


--
-- TOC entry 2146 (class 2606 OID 65243)
-- Dependencies: 204 204 2203
-- Name: Unique_TipoUsuario_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "Unique_TipoUsuario_Nome" UNIQUE ("Nome");


--
-- TOC entry 2150 (class 2606 OID 65245)
-- Dependencies: 206 206 2203
-- Name: Unique_Unidade_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Unidade"
    ADD CONSTRAINT "Unique_Unidade_Nome" UNIQUE ("Nome");


--
-- TOC entry 2138 (class 1259 OID 65246)
-- Dependencies: 196 2203
-- Name: Professor_Nome_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Professor_Nome_Index" ON "Professor" USING btree ("Nome");


--
-- TOC entry 2117 (class 1259 OID 65247)
-- Dependencies: 167 167 167 2203
-- Name: Turma_Disciplina_Codigo_Periodo_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Turma_Disciplina_Codigo_Periodo_Index" ON "Turma" USING btree ("FK_Disciplina", "Codigo", "PeriodoAno");


--
-- TOC entry 2153 (class 1259 OID 65248)
-- Dependencies: 209 2203
-- Name: Usuario_HashSession_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Usuario_HashSession_Index" ON "Usuario" USING btree ("HashSessao");


--
-- TOC entry 2072 (class 2618 OID 65249)
-- Dependencies: 165 165 165 165 165 165 165 165 2203
-- Name: AlunoTurmaSelecionadaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "AlunoTurmaSelecionadaDuplicada" AS ON INSERT TO "AlunoTurmaSelecionada" WHERE (EXISTS (SELECT 1 FROM "AlunoTurmaSelecionada" ats WHERE (((ats."FK_Aluno")::text = (new."FK_Aluno")::text) AND (ats."FK_Turma" = new."FK_Turma")))) DO INSTEAD UPDATE "AlunoTurmaSelecionada" ats SET "Opcao" = new."Opcao", "NoLinha" = new."NoLinha" WHERE (((ats."FK_Aluno")::text = (new."FK_Aluno")::text) AND (ats."FK_Turma" = new."FK_Turma"));


--
-- TOC entry 2073 (class 2618 OID 65251)
-- Dependencies: 176 176 176 176 176 2203
-- Name: CursoDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "CursoDuplicado" AS ON INSERT TO "Curso" WHERE (EXISTS (SELECT 1 FROM "Curso" d WHERE ((d."PK_Curso")::text = (new."PK_Curso")::text))) DO INSTEAD UPDATE "Curso" d SET "Nome" = new."Nome" WHERE ((d."PK_Curso")::text = (new."PK_Curso")::text);


--
-- TOC entry 2074 (class 2618 OID 65253)
-- Dependencies: 167 197 167 167 2203
-- Name: DeletarTurma; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "DeletarTurma" AS ON DELETE TO "Turma" DO INSTEAD (UPDATE "Turma" SET "Deletada" = true WHERE ("Turma"."PK_Turma" = old."PK_Turma"); DELETE FROM "TurmaHorario" WHERE ("TurmaHorario"."FK_Turma" = old."PK_Turma"); );


--
-- TOC entry 2075 (class 2618 OID 65254)
-- Dependencies: 177 177 177 177 177 177 2203
-- Name: DisciplinaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "DisciplinaDuplicada" AS ON INSERT TO "Disciplina" WHERE (EXISTS (SELECT 1 FROM "Disciplina" d WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text))) DO INSTEAD UPDATE "Disciplina" d SET "Nome" = new."Nome", "Creditos" = new."Creditos" WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text);


--
-- TOC entry 2076 (class 2618 OID 65256)
-- Dependencies: 178 178 178 178 178 2203
-- Name: OptativaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "OptativaDuplicada" AS ON INSERT TO "Optativa" WHERE (EXISTS (SELECT 1 FROM "Optativa" d WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text))) DO INSTEAD UPDATE "Optativa" d SET "Nome" = new."Nome" WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text);


--
-- TOC entry 2077 (class 2618 OID 65258)
-- Dependencies: 196 196 196 196 2203
-- Name: ProfessorDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "ProfessorDuplicado" AS ON INSERT TO "Professor" WHERE (EXISTS (SELECT 1 FROM "Professor" d WHERE ((d."Nome")::text = (new."Nome")::text))) DO INSTEAD NOTHING;


--
-- TOC entry 2078 (class 2618 OID 65259)
-- Dependencies: 167 167 167 167 167 167 167 167 167 167 167 167 167 2203
-- Name: TurmaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaDuplicada" AS ON INSERT TO "Turma" WHERE (EXISTS (SELECT 1 FROM "Turma" t WHERE ((((t."FK_Disciplina")::text = (new."FK_Disciplina")::text) AND ((t."Codigo")::text = (new."Codigo")::text)) AND (t."PeriodoAno" = new."PeriodoAno")))) DO INSTEAD UPDATE "Turma" t SET "Vagas" = new."Vagas", "Destino" = new."Destino", "HorasDistancia" = new."HorasDistancia", "SHF" = new."SHF", "FK_Professor" = new."FK_Professor", "Deletada" = false WHERE ((((t."FK_Disciplina")::text = (new."FK_Disciplina")::text) AND ((t."Codigo")::text = (new."Codigo")::text)) AND (t."PeriodoAno" = new."PeriodoAno"));


--
-- TOC entry 2079 (class 2618 OID 65261)
-- Dependencies: 197 197 197 197 197 197 197 2203
-- Name: TurmaHorarioDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaHorarioDuplicado" AS ON INSERT TO "TurmaHorario" WHERE (EXISTS (SELECT 1 FROM "TurmaHorario" th WHERE ((((th."FK_Turma" = new."FK_Turma") AND (th."DiaSemana" = new."DiaSemana")) AND (th."HoraInicial" = new."HoraInicial")) AND (th."HoraFinal" = new."HoraFinal")))) DO INSTEAD NOTHING;


--
-- TOC entry 2080 (class 2618 OID 65262)
-- Dependencies: 206 206 206 206 2203
-- Name: UnidadeDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "UnidadeDuplicada" AS ON INSERT TO "Unidade" WHERE (EXISTS (SELECT 1 FROM "Unidade" u WHERE ((u."Nome")::text = (new."Nome")::text))) DO INSTEAD NOTHING;


--
-- TOC entry 2162 (class 2606 OID 65263)
-- Dependencies: 161 2101 163 2203
-- Name: FK_AlunoDisciplinaAptoCache_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplinaAptoCache"
    ADD CONSTRAINT "FK_AlunoDisciplinaAptoCache_Aluno" FOREIGN KEY ("Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2163 (class 2606 OID 65268)
-- Dependencies: 163 2126 177 2203
-- Name: FK_AlunoDisciplinaAptoCache_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplinaAptoCache"
    ADD CONSTRAINT "FK_AlunoDisciplinaAptoCache_Disciplina" FOREIGN KEY ("Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2158 (class 2606 OID 65273)
-- Dependencies: 161 162 2101 2203
-- Name: FK_AlunoDisciplina_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2159 (class 2606 OID 65278)
-- Dependencies: 164 162 2107 2203
-- Name: FK_AlunoDisciplina_AlunoDisciplinaStatus; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_AlunoDisciplinaStatus" FOREIGN KEY ("FK_Status") REFERENCES "AlunoDisciplinaStatus"("PK_Status") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2160 (class 2606 OID 65283)
-- Dependencies: 162 177 2126 2203
-- Name: FK_AlunoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2161 (class 2606 OID 65288)
-- Dependencies: 2141 162 203 2203
-- Name: FK_AlunoDisciplina_TipoDisciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_TipoDisciplina" FOREIGN KEY ("FK_TipoDisciplina") REFERENCES "TipoDisciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2164 (class 2606 OID 65293)
-- Dependencies: 161 165 2101 2203
-- Name: FK_AlunoTurmaSelecionada_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2165 (class 2606 OID 65298)
-- Dependencies: 2115 167 165 2203
-- Name: FK_AlunoTurmaSelecionada_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2156 (class 2606 OID 65303)
-- Dependencies: 176 2124 161 2203
-- Name: FK_Aluno_Curso; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Curso" FOREIGN KEY ("FK_Curso") REFERENCES "Curso"("PK_Curso") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2157 (class 2606 OID 65308)
-- Dependencies: 161 209 2151 2203
-- Name: FK_Aluno_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Usuario" FOREIGN KEY ("FK_Matricula") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2176 (class 2606 OID 65313)
-- Dependencies: 184 209 2151 2203
-- Name: FK_Log_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "FK_Log_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2172 (class 2606 OID 65318)
-- Dependencies: 179 2101 161 2203
-- Name: FK_OptativaAluno_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2173 (class 2606 OID 65323)
-- Dependencies: 179 2128 178 2203
-- Name: FK_OptativaAluno_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2174 (class 2606 OID 65328)
-- Dependencies: 177 181 2126 2203
-- Name: FK_OptativaDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2175 (class 2606 OID 65333)
-- Dependencies: 2128 181 178 2203
-- Name: FK_OptativaDisciplina_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2168 (class 2606 OID 65338)
-- Dependencies: 2126 169 177 2203
-- Name: FK_PreRequisitoGrupoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2169 (class 2606 OID 65343)
-- Dependencies: 172 169 2120 2203
-- Name: FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo" FOREIGN KEY ("FK_PreRequisitoGrupo") REFERENCES "PreRequisitoGrupo"("PK_PreRequisitoGrupo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2170 (class 2606 OID 65348)
-- Dependencies: 172 2126 177 2203
-- Name: FK_PreRequisitoGrupo_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "FK_PreRequisitoGrupo_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2171 (class 2606 OID 65353)
-- Dependencies: 209 2151 175 2203
-- Name: FK_Sugestao_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "FK_Sugestao_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2177 (class 2606 OID 65358)
-- Dependencies: 197 2115 167 2203
-- Name: FK_TurmaHorario_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "FK_TurmaHorario_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2178 (class 2606 OID 65363)
-- Dependencies: 197 206 2147 2203
-- Name: FK_TurmaHorario_Unidade; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "FK_TurmaHorario_Unidade" FOREIGN KEY ("FK_Unidade") REFERENCES "Unidade"("PK_Unidade") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2166 (class 2606 OID 65368)
-- Dependencies: 167 196 2136 2203
-- Name: FK_Turma_Professor; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "FK_Turma_Professor" FOREIGN KEY ("FK_Professor") REFERENCES "Professor"("PK_Professor") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2179 (class 2606 OID 65373)
-- Dependencies: 209 2143 204 2203
-- Name: FK_Usuario_TipoUsuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "FK_Usuario_TipoUsuario" FOREIGN KEY ("FK_TipoUsuario") REFERENCES "TipoUsuario"("PK_TipoUsuario") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2167 (class 2606 OID 65378)
-- Dependencies: 167 2126 177 2203
-- Name: PK_Turma_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2012-12-25 22:07:38 BRST

--
-- PostgreSQL database dump complete
--

