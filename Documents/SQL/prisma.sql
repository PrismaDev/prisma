--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.5
-- Dumped by pg_dump version 9.3.5
-- Started on 2014-11-10 08:55:12 BRST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 219 (class 3079 OID 11789)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2322 (class 0 OID 0)
-- Dependencies: 219
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 232 (class 1255 OID 16386)
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
-- TOC entry 233 (class 1255 OID 16387)
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
-- TOC entry 234 (class 1255 OID 16388)
-- Name: AlunoDisciplinaApto(character varying, character varying); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoDisciplinaApto"("pAluno" character varying, "pDisciplina" character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	prg "PreRequisitoGrupo"%rowtype;
	prg_status text;	
	cr_cp integer;
	cr_cp_ea integer;
	res integer;
BEGIN
	IF "DisciplinaTemPreRequisito"("pDisciplina") = FALSE OR "AlunoDisciplinaSituacao"("pAluno", "pDisciplina") <> 'NC' THEN
		return 2;
	END IF;
	
	cr_cp := "AlunoCreditos"("pAluno", 'CP');
	cr_cp_ea := cr_cp + "AlunoCreditos"("pAluno", 'EA');
	res := 0;
	
	FOR prg IN (SELECT * FROM "PreRequisitoGrupo" WHERE "FK_Disciplina" = "pDisciplina") LOOP

		IF cr_cp_ea < prg."CreditosMinimos" THEN
			CONTINUE; -- res := MAX(res, 0);
		END IF;
	
		prg_status := (	
			SELECT MAX(COALESCE(ad."FK_Status", 'NC'))
			FROM "PreRequisitoGrupoDisciplina" prgd
				LEFT JOIN "AlunoDisciplina" ad
					ON prgd."FK_Disciplina" = ad."FK_Disciplina" AND ad."FK_Aluno" = "pAluno"
			WHERE prgd."FK_PreRequisitoGrupo" = prg."PK_PreRequisitoGrupo"
		);

		IF prg_status = 'NC' THEN
			CONTINUE; -- res := MAX(res, 0);
		ELSIF cr_cp < prg."CreditosMinimos" OR prg_status = 'EA' THEN
			res := 1; -- res := MAX(res, 1);
		ELSE
			RETURN 2; -- res := MAX(res, 2);
		END IF;
	END LOOP;

	RETURN res;
END;
$$;


ALTER FUNCTION public."AlunoDisciplinaApto"("pAluno" character varying, "pDisciplina" character varying) OWNER TO prisma;

--
-- TOC entry 235 (class 1255 OID 16389)
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
-- TOC entry 236 (class 1255 OID 16390)
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
-- TOC entry 239 (class 1255 OID 16788)
-- Name: AlunoTurmaRank(character varying, bigint); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "AlunoTurmaRank"(character varying, bigint) RETURNS bigint
    LANGUAGE sql
    AS $_$
	SELECT count(*)
	FROM (SELECT DISTINCT "FK_Aluno" FROM "AlunoTurmaSelecionada" WHERE $2 = "FK_Turma") T
	WHERE 	(SELECT "Rank" FROM "Aluno" WHERE "FK_Matricula" = $1) < 
		(SELECT "Rank" FROM "Aluno" WHERE "FK_Matricula" = T."FK_Aluno")
$_$;


ALTER FUNCTION public."AlunoTurmaRank"(character varying, bigint) OWNER TO prisma;

--
-- TOC entry 237 (class 1255 OID 16391)
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
-- TOC entry 238 (class 1255 OID 16392)
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
	TRUNCATE "Log" CASCADE;
	TRUNCATE "Comentario" CASCADE;
	TRUNCATE "Unidade" CASCADE;
$$;


ALTER FUNCTION public."LimpaBanco"() OWNER TO prisma;

--
-- TOC entry 240 (class 1255 OID 16789)
-- Name: TurmaVagasTotal(bigint); Type: FUNCTION; Schema: public; Owner: prisma
--

CREATE FUNCTION "TurmaVagasTotal"(bigint) RETURNS bigint
    LANGUAGE sql
    AS $_$
	SELECT sum(TD."Vagas") AS sum 
		FROM "TurmaDestino" TD 
		WHERE TD."FK_Turma" = $1
$_$;


ALTER FUNCTION public."TurmaVagasTotal"(bigint) OWNER TO prisma;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 170 (class 1259 OID 16393)
-- Name: Aluno; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Aluno" (
    "FK_Matricula" character varying(20) NOT NULL,
    "CoeficienteRendimento" real,
    "FK_Curso" character varying(3) NOT NULL,
    "Rank" real
);


ALTER TABLE public."Aluno" OWNER TO prisma;

--
-- TOC entry 171 (class 1259 OID 16396)
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
-- TOC entry 172 (class 1259 OID 16401)
-- Name: AlunoDisciplinaStatus; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "AlunoDisciplinaStatus" (
    "PK_Status" character varying(2) NOT NULL,
    "Nome" character varying(20) NOT NULL
);


ALTER TABLE public."AlunoDisciplinaStatus" OWNER TO prisma;

--
-- TOC entry 173 (class 1259 OID 16404)
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
-- TOC entry 174 (class 1259 OID 16407)
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
-- TOC entry 175 (class 1259 OID 16409)
-- Name: Turma; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Turma" (
    "PK_Turma" bigint DEFAULT nextval('seq_turma'::regclass) NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL,
    "Codigo" character varying(10) NOT NULL,
    "PeriodoAno" integer NOT NULL,
    "HorasDistancia" integer DEFAULT 0 NOT NULL,
    "SHF" integer DEFAULT 0 NOT NULL,
    "FK_Professor" bigint NOT NULL,
    "Deletada" boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Turma" OWNER TO prisma;

--
-- TOC entry 176 (class 1259 OID 16416)
-- Name: AlunoDisciplinaTurmaSelecionada; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "AlunoDisciplinaTurmaSelecionada" AS
 SELECT t."FK_Disciplina" AS "CodigoDisciplina",
    ats."FK_Turma",
    ats."FK_Aluno" AS "MatriculaAluno",
    ats."Opcao",
    ats."NoLinha",
    "TurmaVagasTotal"(ats."FK_Turma") AS "Vagas",
    "AlunoTurmaRank"(ats."FK_Aluno", ats."FK_Turma") AS "QtdNaFrente"
   FROM ("AlunoTurmaSelecionada" ats
     JOIN "Turma" t ON (((t."PK_Turma" = ats."FK_Turma") AND (t."Deletada" = false))));


ALTER TABLE public."AlunoDisciplinaTurmaSelecionada" OWNER TO prisma;

--
-- TOC entry 177 (class 1259 OID 16420)
-- Name: AvisoDesabilitado; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "AvisoDesabilitado" (
    "CodAviso" character varying(50) NOT NULL,
    "FK_Aluno" character varying(20) NOT NULL
);


ALTER TABLE public."AvisoDesabilitado" OWNER TO prisma;

--
-- TOC entry 178 (class 1259 OID 16423)
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
-- TOC entry 179 (class 1259 OID 16425)
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
-- TOC entry 180 (class 1259 OID 16433)
-- Name: Curso; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Curso" (
    "PK_Curso" character varying(3) NOT NULL,
    "Nome" character varying(50) NOT NULL
);


ALTER TABLE public."Curso" OWNER TO prisma;

--
-- TOC entry 181 (class 1259 OID 16436)
-- Name: Disciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Disciplina" (
    "PK_Codigo" character varying(7) NOT NULL,
    "Nome" character varying(100) NOT NULL,
    "Creditos" integer NOT NULL
);


ALTER TABLE public."Disciplina" OWNER TO prisma;

--
-- TOC entry 182 (class 1259 OID 16439)
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
-- TOC entry 183 (class 1259 OID 16443)
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
-- TOC entry 184 (class 1259 OID 16445)
-- Name: Unidade; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Unidade" (
    "PK_Unidade" bigint DEFAULT nextval('seq_unidade'::regclass) NOT NULL,
    "Nome" character varying(50) NOT NULL
);


ALTER TABLE public."Unidade" OWNER TO prisma;

--
-- TOC entry 185 (class 1259 OID 16449)
-- Name: EstatisticaDemandaHorario; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "EstatisticaDemandaHorario" AS
 SELECT ats."Opcao",
    ( SELECT "Unidade"."Nome"
           FROM "Unidade"
          WHERE ("Unidade"."PK_Unidade" = th."FK_Unidade")) AS "Unidade",
    th."DiaSemana",
    th."HoraInicial",
    th."HoraFinal",
    count(*) AS "Demanda"
   FROM ("AlunoTurmaSelecionada" ats
     JOIN "TurmaHorario" th ON ((th."FK_Turma" = ats."FK_Turma")))
  GROUP BY ats."Opcao", th."DiaSemana", th."HoraInicial", th."HoraFinal", th."FK_Unidade";


ALTER TABLE public."EstatisticaDemandaHorario" OWNER TO prisma;

--
-- TOC entry 218 (class 1259 OID 16790)
-- Name: EstatisticaDemandaTurma; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "EstatisticaDemandaTurma" AS
 SELECT "Turma"."FK_Disciplina",
    "Turma"."Codigo",
    "TurmaVagasTotal"("Turma"."PK_Turma") AS "Vagas",
    ( SELECT count(DISTINCT "AlunoTurmaSelecionada"."FK_Aluno") AS count
           FROM "AlunoTurmaSelecionada"
          WHERE ("AlunoTurmaSelecionada"."FK_Turma" = "Turma"."PK_Turma")) AS "Demanda"
   FROM "Turma"
  WHERE ("Turma"."Deletada" = false);


ALTER TABLE public."EstatisticaDemandaTurma" OWNER TO prisma;

--
-- TOC entry 187 (class 1259 OID 16461)
-- Name: Optativa; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Optativa" (
    "PK_Codigo" character varying(7) NOT NULL,
    "Nome" character varying(100) NOT NULL
);


ALTER TABLE public."Optativa" OWNER TO prisma;

--
-- TOC entry 188 (class 1259 OID 16464)
-- Name: OptativaAluno; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "OptativaAluno" (
    "FK_Optativa" character varying(7) NOT NULL,
    "FK_Aluno" character varying(20) NOT NULL,
    "PeriodoSugerido" integer DEFAULT 1 NOT NULL
);


ALTER TABLE public."OptativaAluno" OWNER TO prisma;

--
-- TOC entry 189 (class 1259 OID 16468)
-- Name: FaltaCursarOptativa; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "FaltaCursarOptativa" AS
 SELECT oa."FK_Aluno" AS "Aluno",
    o."PK_Codigo" AS "CodigoOptativa",
    o."Nome" AS "NomeOptativa",
    oa."PeriodoSugerido"
   FROM ("Optativa" o
     JOIN "OptativaAluno" oa ON (((o."PK_Codigo")::text = (oa."FK_Optativa")::text)))
  WHERE (NOT "AlunoOptativaCursada"(oa."FK_Aluno", o."PK_Codigo"));


ALTER TABLE public."FaltaCursarOptativa" OWNER TO prisma;

--
-- TOC entry 190 (class 1259 OID 16472)
-- Name: OptativaDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "OptativaDisciplina" (
    "FK_Optativa" character varying(7) NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."OptativaDisciplina" OWNER TO prisma;

--
-- TOC entry 191 (class 1259 OID 16475)
-- Name: FaltaCursarOptativaDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "FaltaCursarOptativaDisciplina" AS
 SELECT fco."Aluno",
    fco."CodigoOptativa",
    od."FK_Disciplina" AS "CodigoDisciplina",
    COALESCE(ad."FK_Status", 'NC'::character varying) AS "Situacao",
    "AlunoDisciplinaApto"(fco."Aluno", od."FK_Disciplina") AS "Apto"
   FROM (("FaltaCursarOptativa" fco
     JOIN "OptativaDisciplina" od ON (((od."FK_Optativa")::text = (fco."CodigoOptativa")::text)))
     LEFT JOIN "AlunoDisciplina" ad ON ((((ad."FK_Disciplina")::text = (od."FK_Disciplina")::text) AND ((fco."Aluno")::text = (ad."FK_Aluno")::text))));


ALTER TABLE public."FaltaCursarOptativaDisciplina" OWNER TO prisma;

--
-- TOC entry 192 (class 1259 OID 16479)
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
-- TOC entry 193 (class 1259 OID 16481)
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
-- TOC entry 194 (class 1259 OID 16490)
-- Name: LogAcessoSegundo; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogAcessoSegundo" AS
 SELECT date_part('year'::text, "Log"."DataHora") AS "Ano",
    date_part('month'::text, "Log"."DataHora") AS "Mes",
    date_part('day'::text, "Log"."DataHora") AS "Dia",
    date_part('hour'::text, "Log"."DataHora") AS "Hora",
    date_part('minute'::text, "Log"."DataHora") AS "Minuto",
    (date_part('second'::text, "Log"."DataHora"))::integer AS "Segundo",
    count(*) AS "Quantidade"
   FROM "Log"
  WHERE ("Log"."Erro" = false)
  GROUP BY date_part('year'::text, "Log"."DataHora"), date_part('month'::text, "Log"."DataHora"), date_part('day'::text, "Log"."DataHora"), date_part('hour'::text, "Log"."DataHora"), date_part('minute'::text, "Log"."DataHora"), (date_part('second'::text, "Log"."DataHora"))::integer
  ORDER BY date_part('year'::text, "Log"."DataHora") DESC, date_part('month'::text, "Log"."DataHora") DESC, date_part('day'::text, "Log"."DataHora") DESC, date_part('hour'::text, "Log"."DataHora") DESC, date_part('minute'::text, "Log"."DataHora") DESC, (date_part('second'::text, "Log"."DataHora"))::integer DESC;


ALTER TABLE public."LogAcessoSegundo" OWNER TO prisma;

--
-- TOC entry 195 (class 1259 OID 16494)
-- Name: LogAlertasDesabilitados; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogAlertasDesabilitados" AS
 SELECT t."AlertasDesabilitados",
    count(*) AS "QuantidadeAlunos"
   FROM ( SELECT "AvisoDesabilitado"."FK_Aluno",
            count(*) AS "AlertasDesabilitados"
           FROM "AvisoDesabilitado"
          GROUP BY "AvisoDesabilitado"."FK_Aluno") t
  GROUP BY t."AlertasDesabilitados"
  ORDER BY t."AlertasDesabilitados" DESC;


ALTER TABLE public."LogAlertasDesabilitados" OWNER TO prisma;

--
-- TOC entry 196 (class 1259 OID 16498)
-- Name: LogAlunoAno; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogAlunoAno" AS
 SELECT ('20'::text || "substring"(("Log"."FK_Usuario")::text, 1, 3)) AS "AnoEntrada",
    count(DISTINCT "Log"."FK_Usuario") AS count
   FROM ("Log"
     JOIN "Aluno" ON ((("Log"."FK_Usuario")::text = ("Aluno"."FK_Matricula")::text)))
  GROUP BY ('20'::text || "substring"(("Log"."FK_Usuario")::text, 1, 3))
  ORDER BY count(DISTINCT "Log"."FK_Usuario") DESC, ('20'::text || "substring"(("Log"."FK_Usuario")::text, 1, 3));


ALTER TABLE public."LogAlunoAno" OWNER TO prisma;

--
-- TOC entry 197 (class 1259 OID 16502)
-- Name: LogAlunoCurso; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogAlunoCurso" AS
 SELECT t1."Codigo" AS "CodigoCurso",
    t1."Nome" AS "NomeCurso",
    COALESCE(t2.count, (0)::bigint) AS "Atual",
    t1.count AS "Total",
    round((((COALESCE(t2.count, (0)::bigint))::numeric / (t1.count)::numeric) * (100)::numeric), 2) AS "Porcentagem"
   FROM (( SELECT c."PK_Curso" AS "Codigo",
            c."Nome",
            count(DISTINCT a."FK_Matricula") AS count
           FROM ("Aluno" a
             JOIN "Curso" c ON (((c."PK_Curso")::text = (a."FK_Curso")::text)))
          GROUP BY c."PK_Curso", c."Nome") t1
     LEFT JOIN ( SELECT c."PK_Curso" AS "Codigo",
            c."Nome",
            count(DISTINCT l."FK_Usuario") AS count
           FROM (("Log" l
             JOIN "Aluno" a ON (((a."FK_Matricula")::text = (l."FK_Usuario")::text)))
             JOIN "Curso" c ON (((a."FK_Curso")::text = (c."PK_Curso")::text)))
          GROUP BY c."PK_Curso", c."Nome") t2 ON (((t1."Codigo")::text = (t2."Codigo")::text)))
  ORDER BY t1."Nome";


ALTER TABLE public."LogAlunoCurso" OWNER TO prisma;

--
-- TOC entry 198 (class 1259 OID 16507)
-- Name: LogAlunoSelecionada; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogAlunoSelecionada" AS
 SELECT count(t."FK_Aluno") AS "QuantidadeAluno",
    round(avg(t.count), 3) AS "MediaSelecionada"
   FROM ( SELECT "AlunoTurmaSelecionada"."FK_Aluno",
            count(*) AS count
           FROM "AlunoTurmaSelecionada"
          GROUP BY "AlunoTurmaSelecionada"."FK_Aluno"
          ORDER BY "AlunoTurmaSelecionada"."FK_Aluno") t;


ALTER TABLE public."LogAlunoSelecionada" OWNER TO prisma;

--
-- TOC entry 199 (class 1259 OID 16511)
-- Name: LogErro; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogErro" AS
 SELECT "Log"."PK_Log",
    "Log"."DataHora",
    "Log"."IP",
    "Log"."URI",
    "Log"."HashSessao",
    "Log"."Erro",
    "Log"."Notas",
    "Log"."FK_Usuario",
    "Log"."Browser"
   FROM "Log"
  WHERE ("Log"."Erro" = true);


ALTER TABLE public."LogErro" OWNER TO prisma;

--
-- TOC entry 200 (class 1259 OID 16515)
-- Name: LogHistogramaBrowserUsuario; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogHistogramaBrowserUsuario" AS
 SELECT "Log"."Browser",
    count(DISTINCT "Log"."FK_Usuario") AS count
   FROM "Log"
  GROUP BY "Log"."Browser"
  ORDER BY count(DISTINCT "Log"."FK_Usuario") DESC, "Log"."Browser";


ALTER TABLE public."LogHistogramaBrowserUsuario" OWNER TO prisma;

--
-- TOC entry 186 (class 1259 OID 16453)
-- Name: TurmaDestino; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TurmaDestino" (
    "FK_Turma" bigint NOT NULL,
    "Destino" character varying(3) NOT NULL,
    "Vagas" integer DEFAULT 0 NOT NULL
);


ALTER TABLE public."TurmaDestino" OWNER TO prisma;

--
-- TOC entry 201 (class 1259 OID 16519)
-- Name: LogOcupacaoTurma; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogOcupacaoTurma" AS
 SELECT t."FK_Disciplina" AS "CodigoDisciplina",
    t."Codigo" AS "CodigoTurma",
    t."PeriodoAno",
    ats."Opcao",
    count(DISTINCT ats."FK_Aluno") AS "QuantidadeAluno",
    td."Destino",
    td."Vagas",
    trunc((((count(DISTINCT ats."FK_Aluno"))::numeric / (td."Vagas")::numeric) * (100)::numeric), 2) AS "Porcentagem"
   FROM (("AlunoTurmaSelecionada" ats
     JOIN "Turma" t ON ((t."PK_Turma" = ats."FK_Turma")))
     JOIN "TurmaDestino" td ON ((t."PK_Turma" = td."FK_Turma")))
  GROUP BY ats."FK_Turma", t."FK_Disciplina", t."Codigo", t."PeriodoAno", ats."Opcao", td."Destino", td."Vagas"
  ORDER BY ats."FK_Turma", t."FK_Disciplina", t."Codigo", t."PeriodoAno", ats."Opcao", count(DISTINCT ats."FK_Aluno"), td."Destino", td."Vagas", trunc((((count(DISTINCT ats."FK_Aluno"))::numeric / (td."Vagas")::numeric) * (100)::numeric), 2);


ALTER TABLE public."LogOcupacaoTurma" OWNER TO prisma;

--
-- TOC entry 202 (class 1259 OID 16524)
-- Name: LogQuantidadeUsuario; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogQuantidadeUsuario" AS
 SELECT count(DISTINCT "Log"."FK_Usuario") AS count
   FROM "Log";


ALTER TABLE public."LogQuantidadeUsuario" OWNER TO prisma;

--
-- TOC entry 203 (class 1259 OID 16528)
-- Name: LogUsuarioAcesso; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogUsuarioAcesso" AS
 SELECT t."Acessos",
    count(*) AS "QuantidadeUsuario"
   FROM ( SELECT "Log"."FK_Usuario",
            count(DISTINCT "Log"."HashSessao") AS "Acessos"
           FROM "Log"
          GROUP BY "Log"."FK_Usuario") t
  GROUP BY t."Acessos"
  ORDER BY t."Acessos" DESC;


ALTER TABLE public."LogUsuarioAcesso" OWNER TO prisma;

--
-- TOC entry 204 (class 1259 OID 16532)
-- Name: LogUsuarioDia; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "LogUsuarioDia" AS
 SELECT ("Log"."DataHora")::date AS "Data",
    count(DISTINCT "Log"."FK_Usuario") AS count
   FROM "Log"
  GROUP BY ("Log"."DataHora")::date
  ORDER BY ("Log"."DataHora")::date DESC;


ALTER TABLE public."LogUsuarioDia" OWNER TO prisma;

--
-- TOC entry 205 (class 1259 OID 16536)
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
-- TOC entry 206 (class 1259 OID 16538)
-- Name: Professor; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Professor" (
    "PK_Professor" bigint DEFAULT nextval('seq_professor'::regclass) NOT NULL,
    "Nome" character varying(100) NOT NULL
);


ALTER TABLE public."Professor" OWNER TO prisma;

--
-- TOC entry 207 (class 1259 OID 16542)
-- Name: MicroHorario; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "MicroHorario" AS
 SELECT d."PK_Codigo" AS "CodigoDisciplina",
    d."Nome" AS "NomeDisciplina",
    d."Creditos",
    t."PK_Turma",
    t."Codigo" AS "CodigoTurma",
    t."PeriodoAno",
    td."Vagas",
    td."Destino",
    t."HorasDistancia",
    t."SHF",
    p."Nome" AS "NomeProfessor",
    th."DiaSemana",
    th."HoraInicial",
    th."HoraFinal"
   FROM (((("Disciplina" d
     JOIN "Turma" t ON ((((t."FK_Disciplina")::text = (d."PK_Codigo")::text) AND (t."Deletada" = false))))
     JOIN "Professor" p ON ((t."FK_Professor" = p."PK_Professor")))
     JOIN "TurmaHorario" th ON ((th."FK_Turma" = t."PK_Turma")))
     JOIN "TurmaDestino" td ON ((td."FK_Turma" = t."PK_Turma")));


ALTER TABLE public."MicroHorario" OWNER TO prisma;

--
-- TOC entry 208 (class 1259 OID 16547)
-- Name: MicroHorarioDisciplina; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "MicroHorarioDisciplina" AS
 SELECT t."Aluno",
    t."CodigoDisciplina",
    t."NomeDisciplina",
    t."Creditos",
    COALESCE(ad."FK_Status", 'NC'::character varying) AS "Situacao",
    "AlunoDisciplinaApto"(t."Aluno", t."CodigoDisciplina") AS "Apto"
   FROM (( SELECT a."FK_Matricula" AS "Aluno",
            d."PK_Codigo" AS "CodigoDisciplina",
            d."Nome" AS "NomeDisciplina",
            d."Creditos"
           FROM "Disciplina" d,
            "Aluno" a) t
     LEFT JOIN "AlunoDisciplina" ad ON ((((ad."FK_Aluno")::text = (t."Aluno")::text) AND ((ad."FK_Disciplina")::text = (t."CodigoDisciplina")::text))));


ALTER TABLE public."MicroHorarioDisciplina" OWNER TO prisma;

--
-- TOC entry 209 (class 1259 OID 16552)
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
-- TOC entry 210 (class 1259 OID 16554)
-- Name: PreRequisitoGrupo; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "PreRequisitoGrupo" (
    "PK_PreRequisitoGrupo" bigint DEFAULT nextval('seq_prerequisito'::regclass) NOT NULL,
    "CreditosMinimos" integer DEFAULT 0 NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."PreRequisitoGrupo" OWNER TO prisma;

--
-- TOC entry 211 (class 1259 OID 16559)
-- Name: PreRequisitoGrupoDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "PreRequisitoGrupoDisciplina" (
    "FK_PreRequisitoGrupo" bigint NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL
);


ALTER TABLE public."PreRequisitoGrupoDisciplina" OWNER TO prisma;

--
-- TOC entry 212 (class 1259 OID 16562)
-- Name: TipoDisciplina; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TipoDisciplina" (
    "PK_Codigo" character varying(2) NOT NULL,
    "Nome" character varying(50)
);


ALTER TABLE public."TipoDisciplina" OWNER TO prisma;

--
-- TOC entry 213 (class 1259 OID 16565)
-- Name: TipoUsuario; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "TipoUsuario" (
    "PK_TipoUsuario" integer NOT NULL,
    "Nome" character varying(20) NOT NULL
);


ALTER TABLE public."TipoUsuario" OWNER TO prisma;

--
-- TOC entry 214 (class 1259 OID 16568)
-- Name: TurmaHorarioUnidade; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "TurmaHorarioUnidade" AS
 SELECT th."FK_Turma",
    th."DiaSemana",
    th."HoraInicial",
    th."HoraFinal",
    u."Nome" AS "Unidade"
   FROM ("TurmaHorario" th
     JOIN "Unidade" u ON ((u."PK_Unidade" = th."FK_Unidade")));


ALTER TABLE public."TurmaHorarioUnidade" OWNER TO prisma;

--
-- TOC entry 215 (class 1259 OID 16572)
-- Name: TurmaProfessor; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "TurmaProfessor" AS
 SELECT t."PK_Turma",
    t."Codigo" AS "CodigoTurma",
    t."FK_Disciplina" AS "CodigoDisciplina",
    t."PeriodoAno",
    t."HorasDistancia",
    t."SHF",
    p."Nome" AS "NomeProfessor"
   FROM ("Turma" t
     JOIN "Professor" p ON ((t."FK_Professor" = p."PK_Professor")))
  WHERE (t."Deletada" = false);


ALTER TABLE public."TurmaProfessor" OWNER TO prisma;

--
-- TOC entry 216 (class 1259 OID 16576)
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
-- TOC entry 217 (class 1259 OID 16580)
-- Name: UsuarioAluno; Type: VIEW; Schema: public; Owner: prisma
--

CREATE VIEW "UsuarioAluno" AS
 SELECT u."PK_Login" AS "Matricula",
    u."Nome" AS "NomeAluno",
    c."Nome" AS "Curso",
    u."UltimoAcesso",
    a."CoeficienteRendimento" AS "CR"
   FROM (("Usuario" u
     JOIN "Aluno" a ON (((u."PK_Login")::text = (a."FK_Matricula")::text)))
     JOIN "Curso" c ON (((c."PK_Curso")::text = (a."FK_Curso")::text)))
  WHERE (u."FK_TipoUsuario" = 3);


ALTER TABLE public."UsuarioAluno" OWNER TO prisma;

--
-- TOC entry 2287 (class 0 OID 16393)
-- Dependencies: 170
-- Data for Name: Aluno; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Aluno" ("FK_Matricula", "CoeficienteRendimento", "FK_Curso", "Rank") FROM stdin;
\.


--
-- TOC entry 2288 (class 0 OID 16396)
-- Dependencies: 171
-- Data for Name: AlunoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoDisciplina" ("FK_Aluno", "FK_Disciplina", "FK_Status", "Tentativas", "Periodo", "FK_TipoDisciplina") FROM stdin;
\.


--
-- TOC entry 2289 (class 0 OID 16401)
-- Dependencies: 172
-- Data for Name: AlunoDisciplinaStatus; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoDisciplinaStatus" ("PK_Status", "Nome") FROM stdin;
CP	Cumpriu
EA	Em andamento
NC	Não cumpriu
\.


--
-- TOC entry 2290 (class 0 OID 16404)
-- Dependencies: 173
-- Data for Name: AlunoTurmaSelecionada; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AlunoTurmaSelecionada" ("FK_Aluno", "FK_Turma", "Opcao", "NoLinha") FROM stdin;
\.


--
-- TOC entry 2293 (class 0 OID 16420)
-- Dependencies: 177
-- Data for Name: AvisoDesabilitado; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "AvisoDesabilitado" ("CodAviso", "FK_Aluno") FROM stdin;
\.


--
-- TOC entry 2295 (class 0 OID 16425)
-- Dependencies: 179
-- Data for Name: Comentario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Comentario" ("PK_Sugestao", "FK_Usuario", "Comentario", "DataHora") FROM stdin;
\.


--
-- TOC entry 2296 (class 0 OID 16433)
-- Dependencies: 180
-- Data for Name: Curso; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Curso" ("PK_Curso", "Nome") FROM stdin;
\.


--
-- TOC entry 2297 (class 0 OID 16436)
-- Dependencies: 181
-- Data for Name: Disciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Disciplina" ("PK_Codigo", "Nome", "Creditos") FROM stdin;
\.


--
-- TOC entry 2306 (class 0 OID 16481)
-- Dependencies: 193
-- Data for Name: Log; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Log" ("PK_Log", "DataHora", "IP", "URI", "HashSessao", "Erro", "Notas", "FK_Usuario", "Browser") FROM stdin;
\.


--
-- TOC entry 2302 (class 0 OID 16461)
-- Dependencies: 187
-- Data for Name: Optativa; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Optativa" ("PK_Codigo", "Nome") FROM stdin;
\.


--
-- TOC entry 2303 (class 0 OID 16464)
-- Dependencies: 188
-- Data for Name: OptativaAluno; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "OptativaAluno" ("FK_Optativa", "FK_Aluno", "PeriodoSugerido") FROM stdin;
\.


--
-- TOC entry 2304 (class 0 OID 16472)
-- Dependencies: 190
-- Data for Name: OptativaDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "OptativaDisciplina" ("FK_Optativa", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2310 (class 0 OID 16554)
-- Dependencies: 210
-- Data for Name: PreRequisitoGrupo; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "PreRequisitoGrupo" ("PK_PreRequisitoGrupo", "CreditosMinimos", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2311 (class 0 OID 16559)
-- Dependencies: 211
-- Data for Name: PreRequisitoGrupoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "PreRequisitoGrupoDisciplina" ("FK_PreRequisitoGrupo", "FK_Disciplina") FROM stdin;
\.


--
-- TOC entry 2308 (class 0 OID 16538)
-- Dependencies: 206
-- Data for Name: Professor; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Professor" ("PK_Professor", "Nome") FROM stdin;
\.


--
-- TOC entry 2312 (class 0 OID 16562)
-- Dependencies: 212
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
-- TOC entry 2313 (class 0 OID 16565)
-- Dependencies: 213
-- Data for Name: TipoUsuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "TipoUsuario" ("PK_TipoUsuario", "Nome") FROM stdin;
1	Administrador
2	Coordenador
3	Aluno
\.


--
-- TOC entry 2292 (class 0 OID 16409)
-- Dependencies: 175
-- Data for Name: Turma; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Turma" ("PK_Turma", "FK_Disciplina", "Codigo", "PeriodoAno", "HorasDistancia", "SHF", "FK_Professor", "Deletada") FROM stdin;
\.


--
-- TOC entry 2301 (class 0 OID 16453)
-- Dependencies: 186
-- Data for Name: TurmaDestino; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "TurmaDestino" ("FK_Turma", "Destino", "Vagas") FROM stdin;
\.


--
-- TOC entry 2298 (class 0 OID 16439)
-- Dependencies: 182
-- Data for Name: TurmaHorario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "TurmaHorario" ("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal", "FK_Unidade") FROM stdin;
\.


--
-- TOC entry 2300 (class 0 OID 16445)
-- Dependencies: 184
-- Data for Name: Unidade; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Unidade" ("PK_Unidade", "Nome") FROM stdin;
\.


--
-- TOC entry 2314 (class 0 OID 16576)
-- Dependencies: 216
-- Data for Name: Usuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

COPY "Usuario" ("PK_Login", "Senha", "Nome", "HashSessao", "TermoAceito", "FK_TipoUsuario", "UltimoAcesso") FROM stdin;
\.


--
-- TOC entry 2323 (class 0 OID 0)
-- Dependencies: 192
-- Name: seq_log; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_log', 1, true);


--
-- TOC entry 2324 (class 0 OID 0)
-- Dependencies: 209
-- Name: seq_prerequisito; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_prerequisito', 1, true);


--
-- TOC entry 2325 (class 0 OID 0)
-- Dependencies: 205
-- Name: seq_professor; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_professor', 1, true);


--
-- TOC entry 2326 (class 0 OID 0)
-- Dependencies: 178
-- Name: seq_sugestao; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_sugestao', 1, true);


--
-- TOC entry 2327 (class 0 OID 0)
-- Dependencies: 174
-- Name: seq_turma; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_turma', 1, true);


--
-- TOC entry 2328 (class 0 OID 0)
-- Dependencies: 183
-- Name: seq_unidade; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_unidade', 1, true);


--
-- TOC entry 2070 (class 2606 OID 16585)
-- Name: PK_Aluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "PK_Aluno" PRIMARY KEY ("FK_Matricula");


--
-- TOC entry 2072 (class 2606 OID 16587)
-- Name: PK_AlunoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "PK_AlunoDisciplina" PRIMARY KEY ("FK_Aluno", "FK_Disciplina");


--
-- TOC entry 2074 (class 2606 OID 16591)
-- Name: PK_AlunoDisciplinaStatus; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "PK_AlunoDisciplinaStatus" PRIMARY KEY ("PK_Status");


--
-- TOC entry 2078 (class 2606 OID 16593)
-- Name: PK_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "PK_AlunoTurmaSelecionada" PRIMARY KEY ("FK_Aluno", "FK_Turma");


--
-- TOC entry 2085 (class 2606 OID 16595)
-- Name: PK_AvisoDesabilitado; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AvisoDesabilitado"
    ADD CONSTRAINT "PK_AvisoDesabilitado" PRIMARY KEY ("CodAviso", "FK_Aluno");


--
-- TOC entry 2089 (class 2606 OID 16597)
-- Name: PK_Curso; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Curso"
    ADD CONSTRAINT "PK_Curso" PRIMARY KEY ("PK_Curso");


--
-- TOC entry 2091 (class 2606 OID 16599)
-- Name: PK_Disciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Disciplina"
    ADD CONSTRAINT "PK_Disciplina" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2107 (class 2606 OID 16601)
-- Name: PK_Log; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "PK_Log" PRIMARY KEY ("PK_Log");


--
-- TOC entry 2101 (class 2606 OID 16603)
-- Name: PK_Optativa; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Optativa"
    ADD CONSTRAINT "PK_Optativa" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2103 (class 2606 OID 16605)
-- Name: PK_OptativaAluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "PK_OptativaAluno" PRIMARY KEY ("FK_Optativa", "FK_Aluno");


--
-- TOC entry 2105 (class 2606 OID 16607)
-- Name: PK_OptativaDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "PK_OptativaDisciplina" PRIMARY KEY ("FK_Optativa", "FK_Disciplina");


--
-- TOC entry 2112 (class 2606 OID 16609)
-- Name: PK_PreRequisitoGrupo; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "PK_PreRequisitoGrupo" PRIMARY KEY ("PK_PreRequisitoGrupo");


--
-- TOC entry 2114 (class 2606 OID 16611)
-- Name: PK_PreRequisitoGrupoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "PK_PreRequisitoGrupoDisciplina" PRIMARY KEY ("FK_PreRequisitoGrupo", "FK_Disciplina");


--
-- TOC entry 2109 (class 2606 OID 16613)
-- Name: PK_Professor; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Professor"
    ADD CONSTRAINT "PK_Professor" PRIMARY KEY ("PK_Professor");


--
-- TOC entry 2087 (class 2606 OID 16615)
-- Name: PK_Sugestao; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "PK_Sugestao" PRIMARY KEY ("PK_Sugestao");


--
-- TOC entry 2116 (class 2606 OID 16617)
-- Name: PK_TipoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoDisciplina"
    ADD CONSTRAINT "PK_TipoDisciplina" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2118 (class 2606 OID 16619)
-- Name: PK_TipoUsuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "PK_TipoUsuario" PRIMARY KEY ("PK_TipoUsuario");


--
-- TOC entry 2082 (class 2606 OID 16621)
-- Name: PK_Turma; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma" PRIMARY KEY ("PK_Turma");


--
-- TOC entry 2099 (class 2606 OID 16623)
-- Name: PK_TurmaDestino; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TurmaDestino"
    ADD CONSTRAINT "PK_TurmaDestino" PRIMARY KEY ("FK_Turma", "Destino", "Vagas");


--
-- TOC entry 2093 (class 2606 OID 16625)
-- Name: PK_TurmaHorario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "PK_TurmaHorario" PRIMARY KEY ("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal");


--
-- TOC entry 2095 (class 2606 OID 16627)
-- Name: PK_Unidade; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Unidade"
    ADD CONSTRAINT "PK_Unidade" PRIMARY KEY ("PK_Unidade");


--
-- TOC entry 2122 (class 2606 OID 16629)
-- Name: PK_Usuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "PK_Usuario" PRIMARY KEY ("PK_Login");


--
-- TOC entry 2076 (class 2606 OID 16631)
-- Name: Unique_AlunoDisciplinaStatus_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "Unique_AlunoDisciplinaStatus_Nome" UNIQUE ("Nome");


--
-- TOC entry 2080 (class 2606 OID 16633)
-- Name: Unique_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "Unique_AlunoTurmaSelecionada" UNIQUE ("FK_Aluno", "FK_Turma", "Opcao", "NoLinha");


--
-- TOC entry 2120 (class 2606 OID 16635)
-- Name: Unique_TipoUsuario_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "Unique_TipoUsuario_Nome" UNIQUE ("Nome");


--
-- TOC entry 2097 (class 2606 OID 16637)
-- Name: Unique_Unidade_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Unidade"
    ADD CONSTRAINT "Unique_Unidade_Nome" UNIQUE ("Nome");


--
-- TOC entry 2110 (class 1259 OID 16638)
-- Name: Professor_Nome_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Professor_Nome_Index" ON "Professor" USING btree ("Nome");


--
-- TOC entry 2083 (class 1259 OID 16639)
-- Name: Turma_Disciplina_Codigo_Periodo_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Turma_Disciplina_Codigo_Periodo_Index" ON "Turma" USING btree ("FK_Disciplina", "Codigo", "PeriodoAno");


--
-- TOC entry 2123 (class 1259 OID 16640)
-- Name: Usuario_HashSession_Index; Type: INDEX; Schema: public; Owner: prisma; Tablespace: 
--

CREATE INDEX "Usuario_HashSession_Index" ON "Usuario" USING btree ("HashSessao");


--
-- TOC entry 2275 (class 2618 OID 16641)
-- Name: AdicionarAvisoDesabilitado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "AdicionarAvisoDesabilitado" AS
    ON INSERT TO "AvisoDesabilitado"
   WHERE (EXISTS ( SELECT 1
           FROM "AvisoDesabilitado" ad
          WHERE (((ad."CodAviso")::text = (new."CodAviso")::text) AND ((ad."FK_Aluno")::text = (new."FK_Aluno")::text)))) DO INSTEAD NOTHING;


--
-- TOC entry 2276 (class 2618 OID 16642)
-- Name: AlunoTurmaSelecionadaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "AlunoTurmaSelecionadaDuplicada" AS
    ON INSERT TO "AlunoTurmaSelecionada"
   WHERE (EXISTS ( SELECT 1
           FROM "AlunoTurmaSelecionada" ats_1
          WHERE (((ats_1."FK_Aluno")::text = (new."FK_Aluno")::text) AND (ats_1."FK_Turma" = new."FK_Turma")))) DO INSTEAD  UPDATE "AlunoTurmaSelecionada" ats SET "Opcao" = new."Opcao", "NoLinha" = new."NoLinha"
  WHERE (((ats."FK_Aluno")::text = (new."FK_Aluno")::text) AND (ats."FK_Turma" = new."FK_Turma"));


--
-- TOC entry 2277 (class 2618 OID 16644)
-- Name: CursoDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "CursoDuplicado" AS
    ON INSERT TO "Curso"
   WHERE (EXISTS ( SELECT 1
           FROM "Curso" d_1
          WHERE ((d_1."PK_Curso")::text = (new."PK_Curso")::text))) DO INSTEAD  UPDATE "Curso" d SET "Nome" = new."Nome"
  WHERE ((d."PK_Curso")::text = (new."PK_Curso")::text);


--
-- TOC entry 2278 (class 2618 OID 16646)
-- Name: DeletarAvisoDesabilitado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "DeletarAvisoDesabilitado" AS
    ON DELETE TO "AvisoDesabilitado"
   WHERE (NOT (EXISTS ( SELECT 1
           FROM "AvisoDesabilitado" ad
          WHERE (((ad."CodAviso")::text = (old."CodAviso")::text) AND ((ad."FK_Aluno")::text = (old."FK_Aluno")::text))))) DO INSTEAD NOTHING;


--
-- TOC entry 2279 (class 2618 OID 16647)
-- Name: DisciplinaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "DisciplinaDuplicada" AS
    ON INSERT TO "Disciplina"
   WHERE (EXISTS ( SELECT 1
           FROM "Disciplina" d_1
          WHERE ((d_1."PK_Codigo")::text = (new."PK_Codigo")::text))) DO INSTEAD  UPDATE "Disciplina" d SET "Nome" = new."Nome", "Creditos" = new."Creditos"
  WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text);


--
-- TOC entry 2280 (class 2618 OID 16649)
-- Name: OptativaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "OptativaDuplicada" AS
    ON INSERT TO "Optativa"
   WHERE (EXISTS ( SELECT 1
           FROM "Optativa" d_1
          WHERE ((d_1."PK_Codigo")::text = (new."PK_Codigo")::text))) DO INSTEAD  UPDATE "Optativa" d SET "Nome" = new."Nome"
  WHERE ((d."PK_Codigo")::text = (new."PK_Codigo")::text);


--
-- TOC entry 2281 (class 2618 OID 16651)
-- Name: ProfessorDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "ProfessorDuplicado" AS
    ON INSERT TO "Professor"
   WHERE (EXISTS ( SELECT 1
           FROM "Professor" d
          WHERE ((d."Nome")::text = (new."Nome")::text))) DO INSTEAD NOTHING;


--
-- TOC entry 2282 (class 2618 OID 16652)
-- Name: TurmaDestinoDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaDestinoDuplicado" AS
    ON INSERT TO "TurmaDestino"
   WHERE (EXISTS ( SELECT 1
           FROM "TurmaDestino" "TurmaDestino_1"
          WHERE (("TurmaDestino_1"."FK_Turma" = new."FK_Turma") AND (("TurmaDestino_1"."Destino")::text = (new."Destino")::text)))) DO INSTEAD  UPDATE "TurmaDestino" SET "Vagas" = new."Vagas"
  WHERE (("TurmaDestino"."FK_Turma" = new."FK_Turma") AND (("TurmaDestino"."Destino")::text = (new."Destino")::text));


--
-- TOC entry 2283 (class 2618 OID 16654)
-- Name: TurmaDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaDuplicada" AS
    ON INSERT TO "Turma"
   WHERE (EXISTS ( SELECT 1
           FROM "Turma" t_1
          WHERE ((((t_1."FK_Disciplina")::text = (new."FK_Disciplina")::text) AND ((t_1."Codigo")::text = (new."Codigo")::text)) AND (t_1."PeriodoAno" = new."PeriodoAno")))) DO INSTEAD  UPDATE "Turma" t SET "HorasDistancia" = new."HorasDistancia", "SHF" = new."SHF", "FK_Professor" = new."FK_Professor", "Deletada" = false
  WHERE ((((t."FK_Disciplina")::text = (new."FK_Disciplina")::text) AND ((t."Codigo")::text = (new."Codigo")::text)) AND (t."PeriodoAno" = new."PeriodoAno"));


--
-- TOC entry 2284 (class 2618 OID 16656)
-- Name: TurmaHorarioDuplicado; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "TurmaHorarioDuplicado" AS
    ON INSERT TO "TurmaHorario"
   WHERE (EXISTS ( SELECT 1
           FROM "TurmaHorario" th
          WHERE ((((th."FK_Turma" = new."FK_Turma") AND (th."DiaSemana" = new."DiaSemana")) AND (th."HoraInicial" = new."HoraInicial")) AND (th."HoraFinal" = new."HoraFinal")))) DO INSTEAD NOTHING;


--
-- TOC entry 2285 (class 2618 OID 16657)
-- Name: UnidadeDuplicada; Type: RULE; Schema: public; Owner: prisma
--

CREATE RULE "UnidadeDuplicada" AS
    ON INSERT TO "Unidade"
   WHERE (EXISTS ( SELECT 1
           FROM "Unidade" u
          WHERE ((u."Nome")::text = (new."Nome")::text))) DO INSTEAD NOTHING;


--
-- TOC entry 2126 (class 2606 OID 16658)
-- Name: FK_AlunoDisciplina_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2127 (class 2606 OID 16663)
-- Name: FK_AlunoDisciplina_AlunoDisciplinaStatus; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_AlunoDisciplinaStatus" FOREIGN KEY ("FK_Status") REFERENCES "AlunoDisciplinaStatus"("PK_Status") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2128 (class 2606 OID 16668)
-- Name: FK_AlunoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2129 (class 2606 OID 16673)
-- Name: FK_AlunoDisciplina_TipoDisciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_TipoDisciplina" FOREIGN KEY ("FK_TipoDisciplina") REFERENCES "TipoDisciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2130 (class 2606 OID 16678)
-- Name: FK_AlunoTurmaSelecionada_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2131 (class 2606 OID 16683)
-- Name: FK_AlunoTurmaSelecionada_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2124 (class 2606 OID 16688)
-- Name: FK_Aluno_Curso; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Curso" FOREIGN KEY ("FK_Curso") REFERENCES "Curso"("PK_Curso") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2125 (class 2606 OID 16693)
-- Name: FK_Aluno_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Usuario" FOREIGN KEY ("FK_Matricula") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2134 (class 2606 OID 16698)
-- Name: FK_AvisoDesabilitado_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AvisoDesabilitado"
    ADD CONSTRAINT "FK_AvisoDesabilitado_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2143 (class 2606 OID 16703)
-- Name: FK_Log_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "FK_Log_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2139 (class 2606 OID 16708)
-- Name: FK_OptativaAluno_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2140 (class 2606 OID 16713)
-- Name: FK_OptativaAluno_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2141 (class 2606 OID 16718)
-- Name: FK_OptativaDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2142 (class 2606 OID 16723)
-- Name: FK_OptativaDisciplina_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2145 (class 2606 OID 16728)
-- Name: FK_PreRequisitoGrupoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2146 (class 2606 OID 16733)
-- Name: FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo" FOREIGN KEY ("FK_PreRequisitoGrupo") REFERENCES "PreRequisitoGrupo"("PK_PreRequisitoGrupo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2144 (class 2606 OID 16738)
-- Name: FK_PreRequisitoGrupo_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "FK_PreRequisitoGrupo_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2135 (class 2606 OID 16743)
-- Name: FK_Sugestao_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "FK_Sugestao_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2138 (class 2606 OID 16748)
-- Name: FK_TurmaDestino_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "TurmaDestino"
    ADD CONSTRAINT "FK_TurmaDestino_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2136 (class 2606 OID 16753)
-- Name: FK_TurmaHorario_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "FK_TurmaHorario_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2137 (class 2606 OID 16758)
-- Name: FK_TurmaHorario_Unidade; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "FK_TurmaHorario_Unidade" FOREIGN KEY ("FK_Unidade") REFERENCES "Unidade"("PK_Unidade") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2132 (class 2606 OID 16763)
-- Name: FK_Turma_Professor; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "FK_Turma_Professor" FOREIGN KEY ("FK_Professor") REFERENCES "Professor"("PK_Professor") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2147 (class 2606 OID 16768)
-- Name: FK_Usuario_TipoUsuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "FK_Usuario_TipoUsuario" FOREIGN KEY ("FK_TipoUsuario") REFERENCES "TipoUsuario"("PK_TipoUsuario") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2133 (class 2606 OID 16773)
-- Name: PK_Turma_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2321 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2014-11-10 08:55:13 BRST

--
-- PostgreSQL database dump complete
--

