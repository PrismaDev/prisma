--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.5
-- Dumped by pg_dump version 9.1.5
-- Started on 2012-11-30 12:56:34 BRST

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
-- TOC entry 2060 (class 0 OID 0)
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
-- Dependencies: 1959 6
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
-- TOC entry 185 (class 1259 OID 36115)
-- Dependencies: 1950 6
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
-- TOC entry 2061 (class 0 OID 0)
-- Dependencies: 169
-- Name: seq_sugestao; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_sugestao', 1, false);


--
-- TOC entry 164 (class 1259 OID 35718)
-- Dependencies: 1952 1953 6
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
-- TOC entry 186 (class 1259 OID 36142)
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
    "Creditos" integer,
    "Ementa" text
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
-- TOC entry 2062 (class 0 OID 0)
-- Dependencies: 166
-- Name: seq_log; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_log', 1, true);


--
-- TOC entry 165 (class 1259 OID 35758)
-- Dependencies: 1954 1955 1956 6
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
-- TOC entry 2063 (class 0 OID 0)
-- Dependencies: 168
-- Name: seq_professor; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_professor', 1275, true);


--
-- TOC entry 167 (class 1259 OID 35818)
-- Dependencies: 1957 6
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
-- TOC entry 2064 (class 0 OID 0)
-- Dependencies: 175
-- Name: seq_turma; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_turma', 1, false);


--
-- TOC entry 176 (class 1259 OID 35986)
-- Dependencies: 1960 1961 1962 1963 6
-- Name: Turma; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Turma" (
    "PK_Turma" bigint DEFAULT nextval('seq_turma'::regclass) NOT NULL,
    "FK_Disciplina" character varying(7) NOT NULL,
    "Codigo" character varying(3) NOT NULL,
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
-- TOC entry 184 (class 1259 OID 36106)
-- Dependencies: 1949 6
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
-- TOC entry 2065 (class 0 OID 0)
-- Dependencies: 181
-- Name: seq_prerequisito; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_prerequisito', 1, false);


--
-- TOC entry 182 (class 1259 OID 36075)
-- Dependencies: 1964 1965 6
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
-- Dependencies: 1951 6
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
-- Dependencies: 1958 6
-- Name: VariavelAmbiente; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "VariavelAmbiente" (
    "PK_Variavel" character varying(30) NOT NULL,
    "Habilitada" boolean DEFAULT true NOT NULL,
    "Descricao" text
);


ALTER TABLE public."VariavelAmbiente" OWNER TO prisma;

--
-- TOC entry 2037 (class 0 OID 35695)
-- Dependencies: 162 2055
-- Data for Name: Aluno; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2044 (class 0 OID 35901)
-- Dependencies: 172 2055
-- Data for Name: AlunoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2045 (class 0 OID 35917)
-- Dependencies: 173 2055
-- Data for Name: AlunoDisciplinaStatus; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "AlunoDisciplinaStatus" VALUES ('CP', 'Cumpriu');
INSERT INTO "AlunoDisciplinaStatus" VALUES ('NC', 'Não cumpriu');
INSERT INTO "AlunoDisciplinaStatus" VALUES ('EA', 'Em andamento');


--
-- TOC entry 2048 (class 0 OID 36001)
-- Dependencies: 177 2055
-- Data for Name: AlunoTurmaSelecionada; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2039 (class 0 OID 35718)
-- Dependencies: 164 2055
-- Data for Name: Comentario; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2054 (class 0 OID 36142)
-- Dependencies: 186 2055
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
-- TOC entry 2043 (class 0 OID 35893)
-- Dependencies: 171 2055
-- Data for Name: Disciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "Disciplina" VALUES ('ACN1000', 'PROJETO - TEXTO', 8, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1001', 'PROJETO - CORPO', 8, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1002', 'PROJETO - SOM', 8, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1003', 'PROJETO - INTERPRETACAO', 8, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1004', 'PROJETO - CENA', 8, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1005', 'PROJETO FINAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1006', 'ESTAGIO SUPERVISIONADO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1022', 'TEATRO E MUSICA NA CULTURA BRASIEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1023', 'O LEITOR, O ESPECTADOR E A OBRA DE ARTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1024', 'A VOZ EM CENA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1025', 'TOPICOS ESPECIAIS EM ARTES CENICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ACN1027', 'TOPICOS ESPECIAIS EM ARTES CENICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ACP0900', 'ATIVIDADES COMPLEMENTARES', 10, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1005', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1006', 'INTR A ANALISE ADMINISTRATIVA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1010', 'ANALISE EMPRESARIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1019', 'INTRODUCAO A FINANCAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1170', 'DISCIPLINA INTEGRADORA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1171', 'DISCIPLINA INTEGRADORA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1172', 'DISCIPLINA INTEGRADORA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1173', 'DISCIPLINA INTEGRADORA IV(TRABALHO FINAL DO CURSO)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1251', 'CONTABILIDADE ADMINISTRATIVA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1256', 'PESQUISA OPERACIONAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1257', 'PESQUISA OPERACIONAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1259', 'TECNICAS DE INFORMATICA PARA ADMINISTRADORES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1271', 'CONTABILIDADE GERENCIAL E DE CUSTOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1272', 'MAT FINANCEIRA E AVAL DE VALOR', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1273', 'MATEMATICA FINANCEIRA E VALOR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1276', 'ESTATISTICA APLICADA A ADMINISTRACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1277', 'ESTATISTICA APLICADA A ADMINISTRACAO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1279', 'PESQUISA OPERACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1351', 'ADMINISTRACAO FINANCEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1353', 'ORCAMENTO DE EMPRESAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1354', 'PLANEJAMENTO FINANCEIRO E ANALISE DO CAPITAL DE GI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1355', 'ORCAMENTO DE EMPRESAS E CONTROLADORIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1362', 'MERCADO DE CAP E INVESTIMENTOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1363', 'INST FINANCEIRAS NO BRASIL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1382', 'FINANCAS INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1383', 'DERIVATIVOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1387', 'TOPICOS ESPECIAIS EM FINANCAS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1388', 'TOPICOS ESPECIAIS EM FINANCAS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1390', 'JOGOS DE NEGOCIOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1451', 'PRINCIPIOS DE MARKETING', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1452', 'ADMINISTRACAO DE VENDAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1453', 'COMPORTAMENTO DO CONSUMIDOR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1454', 'PESQUISA EM MARKETING', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1455', 'PESQUISA EM MARKETING', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1458', 'GERENCIA DE MARKETING', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1460', 'MARKETING DE SERVICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1480', 'MARKETING NA INTERNET', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1481', 'COMUNICACAO INTEGRADA DE MARKETING', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1482', 'MARKETING DE VAREJO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1484', 'ESTRATEGIA DE DISTRIBUICAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1485', 'MARKETING INTERNACIONAL E GLOBALIZACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1486', 'ESTRATEGIAS COLABORATIVAS DE MARKETING', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1487', 'TOPICOS ESPECIAIS EM MARKETING I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1488', 'TOPICOS ESPECIAIS EM MARKETING II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1497', 'MARKETING SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1570', 'LOGISTICA EMPRESARIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1585', 'TECNICAS DE PROGRAMACAO PARA ADMINISTRADORES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1650', 'COMPORTAMENTO ORGANIZACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1651', 'ADMINISTRACAO RECURSOS HUMANOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1653', 'GESTAO DE PESSOAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1668', 'AVALIACAO POTENCIAL, DESENVOLVIMENTO/GESTAO DE COM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1683', 'GESTAO DO ESPORTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1687', 'ADMINISTRACAO INTERNACIONALE ESTRATEGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1694', 'RECRUTAMENTO E SELECAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1695', 'FUNDAMENTOS DA LIDERANCA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1696', 'GESTAO DO CONHECIMENTO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1770', 'ANALISE MULTIVARIADA DE DADOS APLICADA A ADMINISTR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1774', 'ARQUITETURA DA INFORMACAO E PROCESSAMENTO DE NEGOC', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1881', 'ESTUDO DO ENTRETENIMENTO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1951', 'INTRODUCAO A ADMINISTRACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1952', 'TEORIA GERAL DE ADMINISTRACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1956', 'GERENCIAMENTO DE PROJETOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1957', 'ESTRUTURA E PROCESSOS ORGANIZACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1973', 'ESTAGIO SUPERVISIONADO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1974', 'ESTAGIO SUPERVISIONADO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1976', 'PLANEJAMENTO ESTRATEGICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1977', 'METODOLOGIA DE PESQUISA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1978', 'PLANEJAMENTO ESTRATEGICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1979', 'RESPONSABILIDADE SOCIAL E GOVERNANCA CORPORATIVA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1980', 'TOPICOS ESPECIAIS EM ADMINISTRACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1981', 'TOP ESP EM ADMINISTRACAO II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1990', 'CULT,PODER E MUDANCA NAS ORGAN', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1991', 'GESTAO DE PEQUENAS EMPRESAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1994', 'CRIATIVIDADE E INOVACAO NAS ORGANIZACOES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM1998', 'NEGOCIACAO GERENCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2301', 'ORGANIZACOES CONTEMPORANEAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2302', 'CONTABILIDADE FINANCEIRA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2303', 'PRINCIPIOS DE MARKETING (PM)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2304', 'CONTABILIDADE GERENCIAL/FORMACAO DE PRECO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2305', 'GESTAO DE PESSOAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2306', 'GESTAO ECONOMICA DE EMPRESAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2307', 'GESTAO DE MARKETING', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2308', 'FINANCAS CORPORATIVAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2309', 'GESTAO DE OPERACOES', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2310', 'EMPRESA NA ECONOMIA GLOBAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2311', 'ESTRATEGIAS DE EMPRESAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2320', 'METODOLOGIA DE PRESQUISA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2321', 'INFERENCIA ESTATISTICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2323', 'TOPICOS AVANCADOS EM INFERENCIA ESTATISTICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2324', 'SEMINARIO DE DISSERTACAO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2325', 'SEMINARIO DE DISSERTACAO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2341', ' ADMINISTRACAO DE CARTEIRAS ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2345', 'DERIVATIVOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2346', 'ESTRATEGIA FINANCEIRA DE LONGO PRAZO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2347', 'FINANCAS INTERNACIONAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2353', 'TOPICOS ESPECIAIS EM FINANCAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2360', ' MARKETING DE SERVICOS ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2362', 'PESQUISA DE MARKETING', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2364', 'COMPORTAMENTO DO CONSUMIDOR', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2365', 'MARKETING DE RELACIONAMENTO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2370', 'TOPICOS ESPECIAIS EM MARKETING', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2371', 'TOPICOS ESPECIAIS EM MARKETING', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2380', 'APRENDIZADO CONTINUO NAS ORGANIZACOES', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2382', 'ESTRUTURAS E PROCESSOS ORGANIZACIONAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2386', 'VISOES DA ORGANIZACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2388', ' TOP ESP ORGANIZACAO PLANEJAMEN ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2556', 'TEORIA GERAL DA ADMINISTRACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2566', 'TEORIA DAS ORGANIZACOES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2567', 'ESTRATEGIAS DE EMPRESAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2568', 'COMPORTAMENTO ORGANIZACIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2569', 'CONHECIMENTO E APRENDIZADO NAS ORGANIZACOES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2571', 'TOP ESP DE ORGANIZ E PLANEJ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2574', 'TOP ESP DE ORGANIZ E PLANEJ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2575', ' TOP ESP DE ORGANIZ E PLANEJ ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2654', 'PRINCIPIOS DE FINANCAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2656', 'INTRODUCAO A CONTABILIDADE', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2661', 'AVALIACAO E FINANC DE PROJETOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2663', ' CONTABIL PARA DECISOES GERENC ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2668', 'DERIVATIVOS FINANCEIROS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2670', 'TOPICOS ESPECIAIS DE FINANCAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2671', 'TOPICOS ESPECIAIS DE FINANCAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2672', 'TOPICOS ESPECIAIS DE FINANCAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2673', ' TOPICOS ESPECIAIS DE FINANCAS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2674', 'TOPICOS ESPECIAIS DE FINANCAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2678', ' TOPICOS ESPECIAIS DE FINANCAS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2679', 'TOPICOS ESPECIAIS DE FINANCAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2754', 'GESTAO DE MARKETING', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2761', 'POLITICA DE DISTRIBUICAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2763', ' ESTRATEGIA DE MARKETING ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2764', 'MARKETING DE SERVICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2765', 'COMPORTAMENTO DO CONSUMIDOR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2766', 'PESQUISA DE MARKETING', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2770', 'TOPICOS ESPECIAIS DE MARKETING', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2771', ' TOPICOS ESPECIAIS DE MARKETING ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2772', 'TOPICOS ESPECIAIS DE MARKETING', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2828', 'SEMINARIO DE TESE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2830', 'SEMINARIO DE DESENVOLVIMENTO DE ARTIGOS CIENTIFICO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2831', 'METODOS QUANTITATIVOS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2832', 'METODOS QUANTITATIVOS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2833', 'METODOLOGIA EM FINANCAS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2834', 'METODOLOGIA EM FINANCAS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2836', 'METODOLOGIA DE PESQUISA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2837', 'METODOS QUALITATIVOS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2838', 'METODOS QUALITATIVOS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2839', 'METODOS DE SURVEY', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2840', 'TOPICOS AVANCADOS EM FINANCAS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2841', 'TOPICOS AVANCADOS EM FINANCAS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2842', 'TOPICOS AVANCADOS EM MARKETING I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2843', 'TOPICOS AVANCADOS EM MARKETING II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2844', 'TOPICOS AVANCADOS EM ORGANIZACOES I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2845', 'TOPICOS AVANCADOS EM ORGANIZACOES II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2846', 'TOPICOS AVANCADOS EM ESTRATEGIA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2847', 'TOPICOS AVANCADOS EM ESTRATEGIA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2951', 'FUNDAMENTOS DA ADMINISTRACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2953', 'MODELAGEM QUANTITATIVA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2955', 'ANALISE MULTIVARIADA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2957', 'FUNDAMENTOS DE ESTATISTICA', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ADM2958', 'METODOLOGIA DE PESQUISA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ADM3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ADM3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ADM3010', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ADM3100', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ADM3200', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ADM3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ADM3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ADM9976', 'INTRODUCTION TO STRATEGY IN A GLOBALIZED WORLD', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ADM9980', 'INTERNATIONAL NEGOTIATION', 4, NULL);
INSERT INTO "Disciplina" VALUES ('AMB1001', 'PROJETO FINAL DE CURSO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1000', 'INTRODUCAO A PROFISSAO DE ARQUITETO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1001', 'TEORIA E HISTORIA DA ARQUITETURA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1002', 'TEORIA E HISTORIA DA ARQUITETURA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1003', 'URBANISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1004', 'PLANEJAMENTO URBANO E REGIONAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1005', 'TEORIA E HISTORIA DA ARQUITETURA III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1006', 'CONFORTO AMBIENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1101', 'INTRODUCAO AO PROJETO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1102', 'PROJETO DO ESPACO RESIDENCIAL I', 12, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1103', 'PROJETO DO ESPACO DO TRABALHO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1104', 'PROJETO DO ESPACO COLETIVO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1105', 'PROJETO DE REVITALIZACAO E REUTILIZACAO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1106', 'PROJETO URBANO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1107', 'PROJETO DE ARQUITETURA UTOPICA', 6, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1108', 'PROJETO DO ESPACO RESIDENCIAL II', 12, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1109', 'PROPOSTA DE PROJETO FINAL', 6, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1110', 'PROJETO FINAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1111', 'PROJETO DE PAISAGISMO', 6, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1201', 'PROGRAMA CONTINUADO DE ESTAGIO I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1202', 'PROGRAMA CONTINUADO DE ESTAGIO II', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1302', 'PROJETO DE INTERIORES I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1316', ' PROJ ESPECIAIS ARQUITETURA I ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1319', 'TOPICOS ESPECIAIS EM ARQUITETURA IV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1322', 'TOPICOS ESPECIAIS EM ARQUITETURA VII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1323', 'TOPICOS ESPECIAIS EM ARQUITETURA VIII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1324', ' TOP ESP EM ARQUITETURA IX ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1325', ' TOP ESP EM ARQUITETURA X ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1328', 'TOPICOS ESPECIAIS EM ARQUITETURA XIII', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1329', 'TOPICOS ESPECIAIS EM ARQUITETURA XIV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1331', 'TOPICOS ESPECIAIS EM ARQUITETURA XVI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1342', 'TOPICOS ESPECIAIS EM ARQUITETURA XXVII', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1343', 'TOPICOS ESPECIAIS EM ARQUITETURA XXVIII', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1345', 'TOPICOS ESPECIAIS EM ARQUITETURA XXX', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1347', 'TOPICOS ESPECIAIS EM ARQUITETURA XXXII', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1349', 'TOPICOS ESPECIAIS EM ARQUITETURA XXXIV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1350', 'TOPICOS ESPECIAIS EM ARQUITETURA XXXV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1352', 'TOPICOS ESPECIAIS EM ARQUITETURA XXXVII', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1353', 'TOPICOS ESPECIAIS EM ARQUITETURA XXXVIII', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1354', ' TOP ESP EM ARQUITETURA XXXIX ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1355', ' TOP ESP EM ARQUITETURA XL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1356', ' TOP ESP EM ARQUITETURA XLI ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ARQ1357', 'TOPICOS ESPECIAIS EM ARQUITETURA XLII', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART0100', 'OPTATIVAS DE DESENHO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ART1019', 'INTR AO DESENHO DE OBSERVACAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ART1020', 'DESENHO DE OBSERVACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1021', 'DES DE OBSERVACAO II(PLAST II)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1022', 'FUND DA GEOMETRIA(MATEMATICA)', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ART1024', 'DESENHO GEOMETRICO II', 6, NULL);
INSERT INTO "Disciplina" VALUES ('ART1026', 'DESENHO TECNICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1027', 'GEOMETRIA DESCRITIVA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART1028', 'DESENHO DE ARQUITETURA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART1029', 'DESENHO DE ARQUITETURA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART1030', 'DESENHO DE ARQUITETURA III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART1031', 'PROJETO BASICO I-ESTAGIO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ART1032', 'PROJETO BASICO II-ESTAGIO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ART1036', 'PLANEJ, PROJ E DESEN-CV IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1038', 'PLANEJ, PROJ E DESEN-CV V', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1039', 'PLANEJ, PROJ E DESEN-PP V', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1040', 'PLANEJ, PROJ E DESEN-CV(CONCL)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1041', 'PLANEJ, PROJ E DESEN-PP(CONCL)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1050', 'DESENHO DE OBSERVACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART1051', 'PLASTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART1052', 'A IMAGEM FOTOGRAFICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ART1053', 'DESENHO DE MODELO VIVO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ART1054', 'DESENHO DE CONCEPCAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ART1055', 'HISTORIA DA ARTE I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ART1056', 'HISTORIA DA ARTE II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ART1110', 'INTR AO LAB DE REPR GRAFICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ART1114', 'LAB DE REPR GRAFICA-TEC DE IL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1115', 'LAB DE REPR GRAFICA-GRAVURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1116', 'LINGUAGEM DA ILUSTRACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART1120', 'INTR AO LAB DE REPR EM VOLUME', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ART1210', 'FUND DA LINGUAGEM VISUAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1211', 'FUND DA LINGUAGEM VISUAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1310', 'INTR AO LAB DE REPR OT-ELETR', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ART1312', 'LAB DE REPR OT-ELETR-AUD VIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1320', 'INTR A COMPUTACAO GRAFICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ART1411', 'HISTORIA DO DESENHO INDUSTRIAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ART1420', 'CULTURA MODERNA E CONTEMPORANEA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1551', 'PLANEJAMENTO DE EMPREENDIMENTOS CULTURAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1610', 'A QUESTAO METODOLOGICA(SEMIN)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1612', 'SEMIOTICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1819', 'ERGONOMIA NA ARQUITETURA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ART1821', 'ANALISE GRAFICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1824', 'ERGONOMIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1839', 'TOPICOS ESPECIAIS EM ARTES X', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1841', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ART1844', 'TOPICOS ESPECIAIS EM DESIGN V', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1849', 'TOPICOS ESPECIAIS EM DESIGN X', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1854', 'TOPICOS ESPECIAIS EM DESIGN XII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ART1857', 'TOPICOS ESPECIAIS EM DESIGN XV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1858', 'TOPICOS ESPECIAIS EM DESIGN XVI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART1900', 'ESTAGIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ART2003', 'PROCEDIMENTOS DE PESQUISA EM DESIGN', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2004', 'ESTUDO E PESQUISA DE MESTRADO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2005', 'DESENVOLVIMENTO DA TESE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2006', 'ESTUDO E PESQUISA DE MESTRADO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2007', 'ESTUDO E PESQUISA DE DOUTORADO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2009', 'ESTUDO E PESQUISA DE DOUTORADO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2010', 'HISTORIA DO DESIGN', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2011', 'EPISTEMOLOGIA DO DESIGN', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2012', 'DESENVOLVIMENTO DA DISSERTACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2110', 'ARTE, CULTURA E SOCIEDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2115', 'OBJETO E MEIO AMBIENTE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2116', ' INTERATIVIDADE:DESIGN/CONCEITO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2201', 'TOPICOS ESPECIAIS EM DESIGN I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2202', 'TOPICOS ESPECIAIS EM DESIGN II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2203', 'TOPICOS ESPECIAIS EM DESIGN III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2204', ' TOP ESPECIAIS EM DESIGN IV ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2205', ' TOP ESPECIAIS EM DESIGN V ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2220', 'ERGONOMIA: METODOS/TECN DE PESQUISA E DA ACAO ERGO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2221', ' ERGO/USAB PROD E PROC PRODUCAO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2222', 'ERGONOMIA/USABILIDADE DA INTERACAO HOMEM/COMPUTADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2232', 'QUESTOES DA SUBJETIVIDADE NO DESIGN', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2237', ' LINGUAGEM DA MIDIA VISUAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2253', 'DESIGN E INTERDISCIPLINARIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2271', 'PRODUCAO INTERDISCIPLINAR DE TEXTO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2276', 'TEORIAS CONTEMPORANEAS SOBRE  A ARQUITETURA E A CI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2278', ' COM, INTER E AUTORIA EM DESIGN ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2280', ' DISCURSOS NA CIENCIA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART2282', 'SISTEMAS INTERSEMIOTICOS DO DESING', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ART3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ART3007', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ART3009', 'PROCEDIMENTOS METODOLOGICOS DE PESQUISA EM DESIGN/', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ART3203', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ATU0201', 'OPT DE ANALISE DE RISCO A', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ATU0202', 'OPT DE ANALISE DE RISCO B', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ATU0221', 'OPT DE ANALISE DE RISCO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO0100', 'OPT CIENCIAS BIOLOGICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1001', 'BIOLOGIA GERAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1002', 'ESTATISTICA APLICADA A BIOLOGIA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1003', 'ESTATISTICA APLICADA A BIOLOGIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1004', 'ESTATISTICA APLIC A ECOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1005', 'DESENHO AMOSTRAL EM ESTUDOS ECOLOGICOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1006', 'BIOMAS BRASILEIROS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1007', 'BIOETICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1008', 'BIOLOGIA APLICADA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1009', 'GENETICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1010', 'METODOS ESTUDO EM ECOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1011', 'ETNOBIOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1111', 'BIOLOGIA VEGETAL I', 6, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1112', 'BIOLOGIA VEGETAL II', 6, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1113', 'BIOLOGIA VEGETAL III', 6, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1114', 'MICROBIOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1115', 'GEOPROCESSAMENTO APLI BIOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1116', 'ESTAGIO SUPERVISIONADO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1117', 'CONSERVACAO E SUSTENTABILIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1118', 'MODELAGEM AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1119', 'SEMINARIOS TEMATICOS I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1120', 'SEMINARIOS TEMATICOS II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1121', 'BIOLOGIA ANIMAL I', 6, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1122', 'BIOLOGIA ANIMAL II', 6, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1123', 'BIOLOGIA ANIMAL III', 6, NULL);
INSERT INTO "Disciplina" VALUES ('BIO1130', 'PROJETO AMBIENTAL', 6, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2103', ' TOPICOS ESPECIAIS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2104', ' TOPICOS ESPECIAIS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2105', ' TOPICOS ESPECIAIS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2106', 'TOPICOS ESPECIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2107', 'TOPICOS ESPECIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2108', 'TOPICOS ESPECIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2109', 'TOPICOS ESPECIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2110', 'TEORIA SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2111', 'TEORIAS DO BRASIL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2112', 'TEORIAS DO BRASIL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2116', 'SEMINARIOS ESPECIAIS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2117', ' SEMINARIOS ESPECIAIS II ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2118', 'SEMINARIOS ESPECIAIS III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2122', 'SEMINARIOS ESPECIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2125', 'SEMINARIOS ESPECIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2128', 'CULTURA, ANTROPOLOGIA DO GENERO E DA SEXUALIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2145', 'ASSIMETRIAS POLITICAS E INCREMENTOS DEMOCRATICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2147', 'TEORIA SOCIAL CLASSICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS2150', 'METODOLOGIA DE PESQUISA QUALITATIVA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIS3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIS3001', 'SEMINARIO DE TESE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CIS3002', 'ESTUDO DIRIGIDO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CIS3003', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIS3004', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIS3201', 'ESTAGIO DE DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('CIS3202', 'ESTAGIO DE DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1004', 'PROJETO FINAL DE ENGENHARIA CIVIL', 1, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1101', 'RESISTENCIA DOS MATERIAIS I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1105', 'MECANICA GERAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1107', 'INTRODUCAO MECANICA SOLIDOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1111', 'SISTEMAS ESTRUTURAIS NA ARQUITETURA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1112', 'SISTEMAS ESTRUTURAIS NA ARQUITETURA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1113', 'SISTEMAS ESTRUTURAIS NA ARQUITETURA III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1126', 'ANALISE DE ESTRUTURAS I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1127', 'ANALISE DE ESTRUTURAS II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1131', 'ESTRUT DE CONCRETO ARMADO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1141', 'ESTRUTURAS DE ACO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1300', 'TOPOGRAFIA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1301', 'TOPOGRAFIA NA ARQUITETURA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1305', 'CONSTRUCAO CIVIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1324', 'INSTALACOES PREDIAIS E URBANAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1342', 'PLANEJAMENTO CONTROLE DE OBRAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1412', 'HIDROLOGIA I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1414', 'HIDROLOGIA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1417', 'HIDRAULICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1500', 'GEOLOGIA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1501', 'MECANICA DOS SOLOS I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1502', 'MECANICA DOS SOLOS II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1514', 'MECANICA SOLOS P/ ENG AMB', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1581', 'GEOTECNIA NA ARQUITETURA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1601', 'MATERIAIS DE CONSTRUCAO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1713', 'TRATAMENTO DE ESGOTOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1715', 'MEIO AMBIENTE E DESENVOLVIMENTO SUSTENTAVEL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CIV1742', 'FUNDAMENTOS DA PERFILAGEM', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2102', 'CALCULO MATRICIAL DE ESTRUTURAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2103', 'TEORIA DA ELASTICIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2104', 'TEORIA DA PLASTICIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2106', 'INSTABILIDADE DAS ESTRUTURAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2108', 'DINAMICA DAS ESTRUTURAS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2109', 'ANALISE EXPERIMENTAL DE ESTRUT', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2118', 'METODO DOS ELEMENTOS FINITOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2123', 'MOD CONSTIT P/ESTRUT CONCRETO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2125', 'COMPORTAMENTO E PROJETO DE ESTRUTURAS DE ACO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2126', 'COMPORTAMENTO E PROJETO DE ESTRUTURAS DE CONCRETO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2127', 'COMPORTAMENTO E PROJETO DE ESTRUTURAS DE CONCRETO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2129', 'PROGRAMACAO MATEMATICA APLICADAA ENGENHARIA CIVIL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2132', 'ESTRUTURAS DE MATERIAIS COMPOSITOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2133', 'ANALISE E CONTROLE DE RISCO EM SISTEMAS ESTRUTURAI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2134', 'PATOLOGIA DAS ESTRUTURAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2141', 'SEMINARIO EM ENGENHARIA ESTRUTURAL I', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2142', 'SEMINARIO EM ENGENHARIA ESTRUTURAL II', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2151', 'METODO HIBRIDO DOS ELEMENTOS DE CONTORNO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2195', 'TOPICOS ESP DE ENG ESTRUTURAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2196', ' TOPICOS ESP DE ENG ESTRUTURAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2199', 'TOPICOS ESP DE ENG ESTRUTURAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2516', 'GEOLOGIA DA ENGENHARIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2517', 'FUNDACOES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2518', 'BARRAG DE TERRA E ENROCAMENTO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2519', 'EMPUXOS TERRA E ESTAB TALUDES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2520', 'MECANICA DAS ROCHAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2530', 'MECANICA DOS SOLOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2531', 'GEOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2532', 'METODOS NUMERICOS EM ENGENHARIA CIVIL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2534', 'MECANICA DAS ROCHAS APLICADA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2535', 'DINAMICA DOS SOLOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2537', 'ENSAIOS DE LABORATORIO EM GEOTECNIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2538', 'INVESTIGACOES GEOTECNICAS DE CAMPO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2540', 'MODELOS CONSTITUTIVOS PARA MATERIAIS GEOTECNICOS I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2541', 'SEMINARIO GEOTECNICO I', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2542', 'SEMINARIO GEOTECNICO II', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2543', 'GEOTECNIA AMBIENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2544', 'MECANICA DOS SOLOS AVANCADA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2545', 'GEOMECANICA DO PETROLEO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2546', 'HIDROLOGIA DE AGUAS SUBTERRANEAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2547', 'MODELOS CONSTITUTIVOS PARA MATERIAIS GEOTECNICOS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2552', 'MET NUMER EM PROBL DE FLUXO E TRANSP EM MEIOS PORO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2553', 'GEOTECNIA EXPERIMENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2581', ' TOP ESP EM GEOTECNIA ', 1, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2598', 'TOPICOS ESPECIAIS DE GEOTECNIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2599', 'TOPICOS ESPECIAIS DE GEOTECNIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV2802', 'SISTEMAS GRAFICOS PARA ENG', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIV3001', 'TESE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIV3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIV3007', 'EXAME DE PROPOSTA DE TESE', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIV3011', 'ESTUDO ORIENTADO EM ENGENHARIA CIVIL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('CIV3201', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('CIV3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CIV3211', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('COM0203', 'OPT COM SOCIAL-CINEMA', 12, NULL);
INSERT INTO "Disciplina" VALUES ('COM0301', 'OPTATIVAS DE COM SOCIAL - BJN', 12, NULL);
INSERT INTO "Disciplina" VALUES ('COM0302', 'OPTATIVAS DE COM SOCIAL - BPR', 8, NULL);
INSERT INTO "Disciplina" VALUES ('COM1001', 'CULTURA BRASILEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1002', 'SEMINARIOS ESP EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1006', 'SEMINARIOS ESP EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1007', 'SEM ESP EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1008', 'SEM ESP EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1009', 'SEM ESP EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1010', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1011', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1012', 'SEM ESP EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1013', 'SEM ESP EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1014', 'SEM ESP EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1015', 'SEM ESP EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1016', ' SEM ESPECIAIS EM COMUNICACAO ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1017', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1018', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1019', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1031', 'SEM ESP EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1032', ' SEM ESP EM COMUNICACAO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1033', 'SEM ESP EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1034', 'SEM ESP EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1036', 'SEM ESP EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1038', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1039', ' SEM ESP EM COMUNICACAO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1040', ' SEM ESP EM COMUNICACAO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1041', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1042', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1043', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1044', ' SEM ESP EM COMUNICACAO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1045', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1046', ' SEM ESP EM COMUNICACAO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1047', ' SEM ESP EM COMUNICACAO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1048', ' SEM ESP EM COMUNICACAO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1049', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1050', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1051', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1053', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1054', 'SEMINARIOS ESPECIAIS EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1100', 'COMUNICACAO E TEATRO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1106', 'TEORIA DA COMUNICACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1107', 'TEORIA DA COMUNICACAO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1130', 'ESTETICA DA COM DE MASSA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1151', 'HISTORIA DA IMPRENSA NO BRASIL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1162', 'COM E LITERATURA BRASILEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1163', 'TEORIA DA IMAGEM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1166', 'HIST DA PUBLICIDADE NO BRASIL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1170', 'MET DA PESQUISA EM COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1180', 'MIDIAS GLOBAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1190', 'MIDIAS LOCAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1246', 'TECNICAS DE COMUNICACAO ORAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1250', 'TECNICAS DE COMUNICACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1251', 'TECNICAS DE COMUNICACAO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1260', 'INTRODUCAO AO JORNALISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1261', 'INTRODUCAO A PUBLICIDADE E PROPAGANDA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1262', 'INTRODUCAO AO CINEMA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1263', 'COMUNICACAO GRAFICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1264', 'COMUNICACAO AUDIOVISUAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1265', 'COMUNICACAO IMPRESSA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1266', 'COMUNICACAO EM RADIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1267', 'COMUNICACAO EM TELEVISAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1370', 'TECNICAS DE REPORTAGEM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1371', 'PLANEJAMENTO GRAFICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1372', 'FOTOJORNALISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1373', 'REDACAO EM JORNALISMO IMPRESSO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1374', 'RADIOJORNALISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1375', 'TELEJORNALISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1380', 'EDICAO EM JORNALISMO IMPRESSO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1381', 'EDICAO EM RADIOJORNALISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1382', 'EDICAO EM TELEJORNALISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1390', 'LABORATORIO DE JORNALISMO IMPRESSO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1391', 'LABORATORIO DE RADIOJORNALISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1392', 'LABORATORIO DE TELEJORNALISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1557', 'CINE-DOCUMENTARIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1570', 'CINEMA MUNDIAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1571', 'CINEMA MUNDIAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1572', 'CINEMA BRASILEIRO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1573', 'TEORIA E CRITICA CINEMATOGRAFICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1580', 'ARGUMENTO E ROTEIRO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1581', 'DIRECAO CINEMATOGRAFICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1582', 'DIRECAO DE FOTOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1583', 'EDICAO EM CINEMA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1590', 'PRODUCAO CINEMATOGRAFICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1591', 'PRODUCAO CINEMATOGRAFICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1592', 'PROJETO DE FILME I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1593', 'PROJETO DE FILME II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1670', 'MARKETING I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1671', 'MARKETING II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1672', 'ATENDIMENTO PUBLICITARIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1673', 'PESQUISA DE MERCADO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1674', 'PLANEJAMENTO PUBLICITARIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1675', 'MIDIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1680', 'REDACAO PUBLICITARIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1681', 'DIRECAO DE ARTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1682', 'LABORATORIO DE PUBLICIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1683', 'FOTOGRAFIA PARA PUBLICIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1684', 'PRODUCAO PUBLICITARIA EM RADIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1685', 'FILME PUBLICITARIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1720', 'COMUNICACAO, CULTURA E CONSUMO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1721', 'SEMIOLOGIA E COMUNICACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('COM1902', 'PROJETO EXPERIMENTAL EM JORNALISMO', 8, NULL);
INSERT INTO "Disciplina" VALUES ('COM1903', 'PROJETO EXPERIMENTAL EM PUBLICIDADE E PROPAGANDA', 8, NULL);
INSERT INTO "Disciplina" VALUES ('COM1904', 'PROJETO EXPERIMENTAL EM JORNALISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1905', 'PROJETO EXPERIMENTAL EM CINEMA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM1906', 'PROJETO EXPERIMENTAL EM PUBLICIDADE E PROPAGANDA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('COM2010', 'TEORIAS DA CULTURA DE MASSA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2110', 'COMUNICACAO E PRATICAS DE CONSUMO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2111', 'COMUNICACAO E REPRESENTACOES DA CIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2112', ' COM DE MASSA E CULTURA IMAGEM ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2116', 'LEITURA DE REPRESENTACOES MIDIATICAS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2211', 'SEMINARIOS AVANCADOS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2212', 'SEMINARIOS AVANCADOS III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2213', 'SEMINARIOS AVANCADOS IV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2310', ' PESQUISA SUPERVISIONADA I ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2311', 'PESQUISA SUPERVISIONADA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2410', ' TEORIAS DA COMUNICACAO II ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM2515', ' COMUNICACAO/PRATICAS CONSUMO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('COM3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('COM3200', 'ESTAGIO DE DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('CRE0700', 'OPTATIVAS DE CRISTIANISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1100', 'O HUMANO E O FENOMENO RELIGIOSO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1112', 'O CRIST E AS GRANDES RELIGIOES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1113', 'CRISTIANISMO E ATEISMO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1115', 'CRISTIANISMO E JUDAISMO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1116', 'BIBLIA E CRISTIANISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1117', 'CRIST E DIAL COM O MUNDO MODER', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1118', 'CRISTIANISMO E PROBL SOCIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1127', 'O CRISTIANISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1134', 'HISTORIA E REVELACAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1136', 'SOCIOLOGIA DA RELIGIAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1141', 'ETICA CRISTA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1146', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1158', 'ETICA PROFISSIONAL - PARA ARQUITETURA E DESENHO IN', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1161', 'ETICA PROFISSIONAL(PARA PSIC)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1162', 'ETICA PROFISSIONAL(PARA SER)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1163', 'ETICA PROFISSIONAL(P/COM SOC)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1164', 'ETICA PROFISSIONAL(PARA DIR)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1167', 'ETICA PROFISSIONAL(P/ECO-ADM)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1168', 'ETICA PROFISSIONAL (PARA DI-PD-FL-GE-HS-LT-RI-SO)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1171', 'ETICA PROFISSIONAL - ENG', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1172', 'ETICA PROFISSIONAL - CCP, CSI, MAT, QUI E FIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1173', 'ETICA PROFISSIONAL - IRI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CRE1174', 'ETICA PROFISSIONAL P/BIOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('CTC0403', 'OPT DE ELETROMAGNETISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('CTC0404', 'OPT DE FISICA MODERNA', 6, NULL);
INSERT INTO "Disciplina" VALUES ('CTC1002', 'INTROD A ENGENHARIA I/CB/CTC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('CTC1004', 'CIENCIA E TECNOL CONTEMPORANEA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG0020', 'DISCIPLINAS DE PROJETO AVANCAD', 30, NULL);
INSERT INTO "Disciplina" VALUES ('DSG0100', 'OPT HIST DA ARTE E DO DESIGN', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG0131', 'OPT REPRES EM COMUNICACAO VISU', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG0151', '0PT DE REPRES EM DESIGN DE MOD', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG0161', '0PT DE REPRES EM DEISGN DE PRO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG0200', 'OPT DE QUESTOES EM DESIGN', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG0300', '0PT DE COMUNICACAO VISUAL', 6, NULL);
INSERT INTO "Disciplina" VALUES ('DSG0400', '0PT DE DESIGN DE MIDIA DIGITAL', 9, NULL);
INSERT INTO "Disciplina" VALUES ('DSG0501', '0PT DE DESIGN DE MODA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG0600', '0PT DE DESIGN DE PRODUTO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1001', 'PROJ BASICO-CONTEXTO/CONCEITO', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1002', 'PROJETO BASICO - PLANEJAMENTO', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1003', 'PROJETO BASICO - DESENVOLVIMENTO', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1004', 'PROJETO AVANCADO - ESTRATEGIA E GESTAO', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1005', 'PROJETO AVANCADO - PRODUCAO E DISTRIBUICAO', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1006', 'PROJETO AVANCADO - USO E IMPACTOS SOCIO-AMBIENTAIS', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1030', 'ANTEPROJETO DE COMUNICACAO VISUAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1031', 'PROJETO DE COMUNICACAO VISUAL', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1032', 'PROJETO FINAL DE COMUNICACAO VISUAL', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1041', 'PROJETO EM DESIGN DE MIDIA DIGITAL', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1042', 'PROJETO FINAL EM DESIGN DE MIDIA DIGITAL', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1051', 'PROJETO DE DESIGN DE MODA', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1052', 'PROJETO FINAL DE DESIGN DE MODA', 8, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1061', 'PROJETO DE DESIGN DE PRODUTO', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1062', 'PROJETO FINAL DE DESIGN DE PRODUTO', 10, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1101', 'HISTORIA DO DESIGN I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1102', 'HISTORIA DO DESIGN II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1103', 'TEORIA DO DESIGN', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1104', 'HISTORIA DOS ESTILOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1105', 'NOVAS TECNOLOGIAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1111', 'FUNDAMENTOS DA GEOMETRIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1112', 'GEOMETRIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1131', 'INTRODUCAO A GRAFICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1132', 'HISTORIA DO DESIGN BRASILEIRO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1141', 'FUNDAMENTOS DA MIDIA DIGITAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1142', 'CRIACAO E TRATAMENTO DE IMAGEM', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1143', 'EDICAO E POS-PRODUCAO DE IMAGENS EM MOVIMENTO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1144', 'MODELAGEM VIRTUAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1145', 'MODELAGEM VIRTUAL II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1151', 'DESIGN DE PADRONAGEM', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1161', 'ESTAGIO SUPERVISIONADO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1301', 'QUESTOES EM DESIGN COM VISUAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1302', 'TENDENCIAS EM COMUNICACAO VISUAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1303', 'COR NA COMUNICACAO VISUAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1304', 'ERGONOMIA INFORMACIONAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1305', 'BIONICA PARA COMUNICACAO VISUAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1311', 'GRAFICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1312', 'SISTEMAS DE PRODUCAO GRAFICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1321', 'LINGUAGEM E COMUNICACAO VISUAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1322', 'IMAGEM E REPRESENTACAO EM COMUNICACAO VISUAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1323', 'TEORIAS E ENFOQUES CRITICOS DA COMUNICACAO NO DESI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1331', 'TIPOGRAFIA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1332', 'TIPOGRAFIA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1334', 'DESIGN E COMUNICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1335', 'LINGUAGEM E COMUNICACAO VISUAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1336', 'ENCADERNACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1337', 'BRANDING - CONSTRUCAO DA MARCA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1401', 'QUESTOES DESIGN MIDIA DIGITAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1402', 'APLICACOES NO DESIGN DE MIDIA DIGITAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1403', 'ERGONOMIA E INTERACAO HUMANO-COMPUTADOR', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1411', 'DESIGN E EXPANSAO DOS SENTIDOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1412', 'INTERFACES FISICAS E LOGICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1413', 'DESIGN DE OBJETOS INTELIGENTES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1415', 'SONORIZACAO E AUDIO DIGITAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1417', 'QUESTOES DE MOBILIDADE E UBIQUIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1421', 'PRINCIPIOS DE ANIMACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1422', 'COMPUTACAO PARA ANIMACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1423', 'HISTORIA DA ANIMACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1424', 'ANIMACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1431', 'PRINCIPIOS DE JOGOS ELETRONICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1432', 'COMPUTACAO GRAFICA E TECNOLOGIA PARA JOGOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1433', 'DESIGN DE JOGOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1441', 'HIPERMIDIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1501', 'QUESTOES EM DESIGN-MODA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1502', 'TENDENCIAS EM DESIGN DE MODA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1503', 'COR NO DESIGN DE MODA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1504', 'ERGONOMIA E VESTUARIO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1511', 'MODELAGEM I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1512', 'MODELAGEM II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1513', 'DESENHO TECNICO DE VESTUARIO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1514', 'COMPOSICAO E ESTRUTURA DO VESTUARIO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1515', 'TECNICAS DE COSTURA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1516', 'DESENHO DE MODA AUXILIADO POR COMPUTADOR - CAD', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1517', 'DESIGN DE ESTAMPARIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1518', 'TECNOLOGIA TEXTIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1519', 'ALFAIATARIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1531', 'HISTORIA DA INDUMENTARIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1532', 'HISTORIA DA MODA CONTEMPORANEA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1533', 'HISTORIA DA MODA CONTEMPORANEA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1534', 'ANTROPOLOGIA DA MODA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1535', 'DESENHO DE MODA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1536', 'ILUSTRACAO DE MODA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1537', 'FIGURINO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1538', 'HISTORIA DA MODA BRASILEIRA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1551', 'DESIGN DE ADORNOS PESSOAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1553', ' HISTORIA DO ADORNO PESSOAL II ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1554', ' DESENHO DE ADORNO PESSOAL ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1559', 'PESQUISA EM ADORNOS PESSOAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1601', 'QUESTOES DESIGN PROJ PRODUTO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1602', 'TENDENCIAS EM DESIGN DE PRODUTO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1603', 'COR EM DESIGN DE PRODUTO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1604', 'ERGONOMIA DO PRODUTO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1605', 'BIONICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1611', 'REPRESENTACAO EM VOLUME I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1612', 'REPRESENTACAO EM VOLUME II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1613', 'REPRESENTACAO EM VOLUME III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1621', 'DESENHO TECNICO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1622', 'MATERIAIS E PROCESSOS DE PRODUCAO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1623', 'MATERIAIS E PROCESSOS DE PRODUCAO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1631', 'ESTRUTURAS E MECANISMOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1632', 'SEMANTICA DO PRODUTO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1633', 'TEORIA DO OBJETO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1634', 'ECODESIGN', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1635', 'ILUSTRACAO DE PRODUTOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1636', 'PROXEMIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1637', 'LABORATORIO DA FORMA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1638', 'LABORATORIO DA FORMA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1700', 'TOPICOS ESPECIAIS EM DESIGN I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1701', ' TOPICOS ESPECIAIS EM DESIGN II ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1702', 'TOPICOS ESPECIAIS EM DESIGN III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1703', 'TOPICOS ESPECIAIS DESIGN IV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1704', 'TOPICOS ESPECIAIS DESIGN V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1710', 'TOPICOS ESPECIAIS EM DESIGN XI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1750', 'TOPICOS ESPECIAIS EM DESIGN LI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1751', 'TOPICOS ESPECIAIS EM DESIGN LII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1752', ' TOPICOS ESP EM DESIGN LIII ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1753', ' TOPICOS ESP EM DESIGN LIV ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1782', 'TOPICOS ESPECIAIS EM DESIGN LXXXIII', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1783', 'TOPICOS ESPECIAIS EM DESIGN LXXXIV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1784', 'TOPICOS ESPECIAIS EM DESIGN LXXXV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1785', 'TOPICOS ESPECIAIS EM DESIGN LXXXVI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1787', 'TOPICOS ESPECIAIS EM DESIGN LXXXVIII', 4, NULL);
INSERT INTO "Disciplina" VALUES ('DSG1788', ' TOPICOS ESP EM DESIGN LXXXIX ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO0101', 'OPT ECONOMIA-DESEN INDUSTRIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO0110', 'OPT DE ECONOMIA (P/DIREITO)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO0200', 'OPTATIVAS DEPT ECONOMIA', 14, NULL);
INSERT INTO "Disciplina" VALUES ('ECO0201', 'OPTATIVAS ECONOMIA-NUC BAS CCS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1101', 'INTRODUCAO A ECONOMIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1102', 'INTRODUCAO A ECONOMIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1103', 'ECONOMIA(PARA ARQUITETURA, DESENHO INDUSTRIAL, ENG', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1106', 'INTROD A TEORIA DO DESENV ECON', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1107', 'EVOLUCAO DO PENSAMENTO ECON', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1109', 'INTR A ECONOMIA I (PARA ECO)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1110', 'INTRODUCAO A ECONOMIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1113', 'TEORIA MICROECONOMICA I N', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1115', 'ECONOMIA POLITICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1119', 'INTRODUCAO AS FINANCAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1121', 'ECONOMIA FINANCEIRA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1122', 'ECONOMIA FINANCEIRA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1130', 'ANALISE DE INVESTIMENTOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1201', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1202', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1203', 'DESENVOLVIMENTO SOC ECONOMICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1208', 'ECONOMIA INTERNACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1211', 'CONTAB E ANALISE DE BALANCOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1212', 'CONTABILIDADE SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1213', 'TEORIA MICROECONOMICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1214', 'TEORIA MICROECONOMICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1215', 'TEORIA MICROECONOMICA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1216', 'TEORIA MACROECONOMICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1217', 'TEORIA MACROECONOMICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1218', 'ECONOMIA DO SETOR PUBLICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1219', 'ECONOMIA MONETARIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1220', 'FORMACAO ECONOMICA DO BRASIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1221', 'POLITICA E PLANEJAMENTO ECON', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1222', 'ECONOMIA POLITICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1301', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1304', 'MATEMATICA APLICADA A ECONOMIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1307', 'MATEMATICA FINANCEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1308', 'ECONOMIA INTERNACIONAL N', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1310', 'TEORIA ECONOMICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1316', 'TEORIA MACROECONOMICA I N', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1322', 'CONTABILIDADE SOCIAL N', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1403', 'DESENVOL SOCIOECONOMICO N', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1404', 'ECO BRASILEIRA CONTEMPORANEA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1406', 'ECONOMIA BRAS CONTEMPORANEA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1407', 'HIST DO PENSAMENTO ECONOMICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1410', 'ECONOMIA BRASILEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1411', 'ECONOMIA BRASILEIRA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1506', 'ECON BRAS CONTEMPORANEA II N', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1508', 'HISTORIA DO PENS ECONOMICO N', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1651', 'SEMINARIO EM TEORIA ECONOMICA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1652', 'SEMINARIO EM TEORIA ECONOMICA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1653', 'SEMINARIO EM TEORIA ECONOMICA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1657', 'SEMINARIO EM TEORIA ECONOMICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1660', 'SEMIN EM POLITICA ECONOMICA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1663', 'SEMIN EM POLITICA ECONOMICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1664', 'SEMIN EM POLITICA ECONOMICA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1666', 'SEMIN EM POLITICA ECONOMICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1667', 'SEMIN EM POLITICA ECONOMICA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1670', 'SEMIN EM ECONOMIA APLICADA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1674', 'SEMIN EM ECONOMIA APLICADA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1675', 'SEMIN EM ECONOMIA APLICADA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1676', 'SEMIN EM ECONOMIA APLICADA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1677', 'SEMIN EM ECONOMIA APLICADA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1704', 'ECONOMETRIA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1705', 'ECONOMETRIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1721', 'INTR A ESTATISTICA ECONOMICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1722', 'ESTAT ECO E INTR A ECONOMETRIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1800', 'TEC DE PESQUISA EM ECONOMIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1801', 'TEN DE PESQUISA EM ECONOMIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1804', 'ECONOMETRIA I N', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1810', 'MONOGRAFIA', 8, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1811', 'MONOGRAFIA I', 8, NULL);
INSERT INTO "Disciplina" VALUES ('ECO1812', 'MONOGRAFIA II', 8, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2007', 'MACROECONOMIA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2008', 'MACROECONOMIA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2009', 'MACROECONOMIA III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2010', ' MACROECONOMIA IV ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2020', 'MICROECONOMIA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2021', 'MICROECONOMIA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2138', 'ECONOMIA DO SETOR PUBLICO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2139', 'ECONOMIA DO SETOR PUBLICO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2142', 'HISTORIA ECONOMICA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2150', 'ECONOMIA DO TRABALHO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2151', 'ECONOMIA DO TRABALHO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2154', 'TOPICOS AVANCADOS EM ECONOMIA DO TRABALHO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2155', 'FINANCAS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2157', 'FINANCAS CORPORATIVAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2201', 'DESENVOLVIMENTO ECONOMICO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2202', 'DESENVOLVIMENTO ECONOMICO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2501', ' TEORIA ECONOMICA I ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2601', 'ORGANIZACAO INDUSTRIAL I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2602', 'ORGANIZACAO INDUSTRIAL II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2701', 'ESTATISTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2705', 'ECONOMETRIA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2706', 'ECONOMETRIA III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2707', 'ECONOMETRIA III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2708', 'ECONOMETRIA IV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2713', 'MATEMATICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2801', 'SEMINARIO DE PESQUISA E POLITICA ECONOMICA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2810', 'SEMINARIO DE DISSERTACAO DE MESTRADO I', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2811', 'SEMINARIO DE DISSERTACAO DE MESTRADO II', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2820', 'SEMINARIO DE TESE DE DOUTORADO I', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2821', 'SEMINARIO DE TESE DE DOUTORADO II', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2822', 'SEMINARIO DE TESE DE DOUTORADO III', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2823', 'SEMINARIO DE TESE DE DOUTORADO IV', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2824', 'SEMINARIO DE TESE DE DOUTORADO V', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO2825', 'SEMINARIO DE TESE DE DOUTORADO VI', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO3200', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ECO3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('EDH1324', 'HISTORIA CONTEMPORANEA IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDH1414', 'HISTORIA DO BRASIL IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDH1415', 'HISTORIA DO BRASIL V', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDH1423', 'HISTORIA DO BRASIL VIII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('EDH1523', 'HISTORIA DA AMERICA VI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('EDH1818', 'SEMINARIOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDH1821', 'SEMINARIOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU0107', 'OPTATIVAS DE PEDAGOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU0300', 'OPT EDUCACAO P/CIENC SOCIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU0700', 'OPTATIVAS DE EDUCACAO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1350', 'PRATICA DE ENSINO EM PORTUGUES I', 5, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1354', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1362', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1381', 'ESTAGIO SUPERVISIONADO DE ENSINO: PORTUGUES I', 5, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1382', 'ESTAGIO SUPERVISIONADO DE ENSINO: PORTUGUES II', 5, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1383', 'ESTAGIO SUPERVISIONADO DE ENSINO: PORTUGUES I (P/L', 5, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1384', 'ESTAGIO SUPERVISIONADO DE ENSINO:PORTUGUES II (P/L', 5, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1385', 'ESTAGIO SUPERVISIONADO DE ENSINO: INGLES I', 5, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1386', 'ESTAGIO SUPERVISIONADO DE ENSINO: INGLES II', 5, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1391', 'ESTAGIO SUPERVISIONADO DE ENSINO: PORTUGUES I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1392', 'EST SUP ENS: PORTUGUES II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1393', 'EST SUP ENS: PORTUGUES III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1396', 'EST SUP DE ENSINO: INGLES I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1397', 'ESTAGIO SUPERVISIONADO DE ENSINO: INGLES II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1398', 'EST SUP DE ENSINO: INGLES III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1445', 'EDUCACAO E SOCIEDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1446', 'HISTORIA E POLITICA DA EDUCACAO BASICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1447', 'O PROCESSO DE CONSTRUCAO DO CONHECIMENTO NA ESCOLA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1448', 'A ESCOLA, O PROFESSOR E A PRATICA DOCENTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1509', 'SOCIOLOGIA DA EDUCACAO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1600', 'DIDATICA GERAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1601', 'PLANEJ ORG TRABALHO ESCOLAR I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1605', 'ESTRUTURA DE 1. GRAU', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1705', 'TENDENC EDU CRIAN 0 A 6 ANOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1733', 'TOPICOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1734', ' TOPICOS ESPECIAIS ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1741', 'CRIANCA E CULTURA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1760', 'ANTROPOLOGIA E EDUCACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1761', 'ESTATISTICA APLICADA A EDUCACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1762', 'FILOSOFIA DA EDUCACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1763', 'FILOSOFIA DA EDUCACAO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1764', 'HISTORIA DAS IDEIAS E PRATICAS PEDAGOGICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1765', 'HIST EDUCACAO NO BRASIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1766', 'POLITICA EDUCACIONAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1767', 'POLITICA EDUCACIONAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1768', 'PSICOLOGIA EDUCACIONAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1769', 'PSICOLOGIA EDUCACIONAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1770', 'SOCIOLOGIA DA EDUCACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1771', 'SOCIOLOGIA DA EDUCACAO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1772', 'AS CRIANCAS/COTID EDU INFANTIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1773', 'AVALIACAO EDUCACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1774', 'CRIANCA E CULTURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1775', 'DIDATICA GERAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1776', 'EDUCACAO EM DIREITOS HUMANOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1777', 'DIVERS E INCLUSAO EDUCACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1778', 'EDUCACAO BRASILEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1779', 'GESTAO DE GRUPOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1780', 'MIDIA, TECNOLOGIAS E EDUCACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1781', 'ORGANIZACAO ESCOLAR I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1782', 'ORGANIZACAO ESCOLAR II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1783', 'METOD ENSINO CIENCIAS NATURAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1784', 'METODOLOGIA DO ENSICO DAS CIENCIAS SOCIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1785', 'METODOLOGIA DO ENSINO DA LINGUA PORTUGUESA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1786', 'METODOLOGIA DO ENSINO DA MATEMATICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1787', 'PROCESSO DE ALFABETIZACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1788', 'ESTAGIO SUPERVISIONADO: GESTAO DA ESCOLA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1789', 'ESTAGIO SUPERVISIONADO DE EDUCACAO INFANTIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1790', 'PRATICA DE ENSINO EM MATERIAS PEDAGOGICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1791', 'PRATICA DE ENSINO EM ESCOLA FUNDAMENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1792', 'PESQUISA EDUCACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1793', 'EDUCACAO AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1794', 'EDUCACAO DE JOVENS E ADULTOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1795', ' EDUCACAO E TRABALHO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU1796', 'CULTURA DIGITAL E EDUCACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2014', 'ESTUDO INDIVIDUAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2116', 'PESQUISA EDUCACIONAL I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2117', 'PESQUISA EDUCACIONAL II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0903', 'OPT ENG PROCESSOS QUIMICOS', 6, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2123', 'TRABALHO SUPERVISIONADO DE PESQUISA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2130', ' TOP ESP DE PESQ EDUCACIONAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2137', 'TOPICOS ESPECIAIS DE PESQUISA EDUCACIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2183', 'TOPICOS ESPECIAIS DE PESQUISA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2186', ' TOP ESP DE PESQUISA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2189', 'TOPICOS ESPECIAIS DE PESQUISA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2190', 'TOPICOS ESPECIAIS DE PESQUISA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2191', 'TOPICOS ESPECIAIS DE PESQUISA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2260', 'TOPICOS ESPECIAIS EM FUNDAMENTOS EM EDUCACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2262', 'TOPICOS ESPECIAIS DE FUNDAMENTOS DA EDUCACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2270', 'EDUCACAO BRASILEIRA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2274', 'HIST DA EDUCACAO BRASILEIRA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2275', 'FILOSOFIA DA EDUCACAO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2276', 'FILOSOFIA DA EDUCACAO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2277', 'SOCIOLOGIA DA EDUCACAO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2281', 'POLITICA EDUCACAO BRASILEIRA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2282', 'PSICOLOGIA DA EDUCACAO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2287', 'QUESTOES ATUAIS DA EDUCACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2301', 'METODOLOGIA DIDATICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2321', 'TOPICOS ESPECIAIS DE PRATICA PEDAGOGICA E FORMACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2340', 'TOPICOS ESPECIAIS DE DEMOCRATIZACAO DA EDUCACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2351', 'TOPICOS ESPECIAIS DE CULTURA,PENSAMENTO E LINGUAGE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU2352', ' TOP ESP DE CULTURA,PENS E LING ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('EDU3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('EDU3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('EDU3004', 'EXAME DE QUALIFICACAO I', 0, NULL);
INSERT INTO "Disciplina" VALUES ('EDU3005', 'EXAME DE QUALIFICACAO II', 0, NULL);
INSERT INTO "Disciplina" VALUES ('EDU3201', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('EDU3202', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('EDU3203', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELD0900', 'ELETIVAS DO DEPARTAMENTO', 20, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1005', 'PROJETO DE GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1009', 'PROJETO DE GRADUACAO EM CONTROLE E AUTOMACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1015', 'PROJETO FINAL I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1023', 'ESTUDO ORIENTADO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1028', 'MODELAGEM SISTEMAS DINAMICOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1030', 'SINAIS E SISTEMAS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1035', 'SISTEMAS DIGITAIS P/ AUTOMACAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1107', 'ELETROTECNICA GERAL-ENG CIV', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1111', 'CIRCUITOS ELETRICOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1115', 'MATERIAIS ELETRICOS II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1130', 'ELETR GERAL(P/MEC-MET-QUI)', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1201', 'ELETROMAGNETISMO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1203', 'ELETROMAGNETISMO II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1328', 'ELETRONICA ANALOGICA I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1500', 'INTROD SISTEMAS ENERGIA ELETR', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1526', 'PRODUC E TRANSM ENERGIA ELETR', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1600', 'INTRODUCAO AS TELECOMUNICACOES', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1601', 'PRINCIPIOS DE COMUNICACOES', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1609', 'SISTEMAS DE RADIO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1720', 'TECNICAS DIGITAIS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1724', 'SISTEMAS DIGITAIS II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1803', 'PESQUISA OPERACIONAL I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1829', 'PROBABILIDADE E ESTATISTICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1830', 'MODELOS PROB EM ENG ELETRICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1831', 'PROCESSOS ESTOCASTICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ELE1832', 'INFERENCIA ESTATISTICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2005', 'TOP ESPECIAIS DE ENG ELETRICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2006', 'TOP ESPECIAIS DE ENG ELETRICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2007', 'TOP ESPECIAIS DE ENG ELETRICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2030', 'ESTUDO ORIENTADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2031', 'ESTUDO ORIENTADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2032', 'ESTUDO ORIENTADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2033', 'ESTUDO ORIENTADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2034', 'ESTUDO ORIENTADO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2035', 'ESTUDO ORIENTADO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2038', 'ESTUDO ORIENTADO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2039', 'ESTUDO ORIENTADO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2050', 'INTRODUCAO A NANOTECNOLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2051', 'NANODISPOSITIVOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2222', 'RADIOMETEOROLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2223', 'PROPAGACAO TROPOSFERICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2224', 'CANAL DE RADIOPROPAGACAO MOVEL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2228', 'ANTENAS DE ABERTURA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2231', 'METOD ASSINT TEOR ELETROMAGNET', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2240', 'METOD NUMER TEOR ELETROMAGNET', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2250', 'TOP ESP DE ELETROMAGNETISMO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2251', 'TOP ESP DE ELETROMAGNETISMO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2342', 'VISAO COMPUTACIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2394', 'REDES NEURAIS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2395', 'COMPUTACAO EVOLUCIONARIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2399', 'LOGICA FUZZY', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2504', 'ANALISE DE REDES ELETRICAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2505', 'ESTABILIDADE DE TENSAO EM REDES ELETRICAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2528', 'OPER E CONTR DE SIST POTENCIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2550', 'TOP ESPECIAIS DE POTENCIA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2552', 'TOPICOS ESP DE POTENCIA III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2600', 'TEORIA ESTATIST COMUNICACOES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2601', 'DETECCAO E ESTIMACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2603', 'PROCESSAMENTO DIGITAL DE VOZ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2604', 'PROCESSAMENTO DE IMAGENS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2605', 'SIST TELECOMUNIC VIA SATELITE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2606', 'REDES DE COMUNICACOES  MOVEIS E PESSOAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2607', 'TRANSMISSAO DIGITAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2612', 'TOP ESP TELECOMUNICACOES III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2613', 'TOPICOS ESPECIAIS EM TELECOMUNICACOES IV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2614', 'PLANEJAM DE SISTEMAS DE COMUNIC CELULARES E DE RAD', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2620', 'MATERIAIS E ESTRUTURAS PARA OPTOELETRONICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2622', 'SISTEMAS DE COMUNICACOES OPTICAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2624', 'ELETRONICA QUANTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2701', 'ESTRUT ALGEB/TOPOL TEOR SIST', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2702', 'ANALISE FUNC APLIC A TEOR SIST', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2707', 'PROCESSOS ESTOCASTICOS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2709', 'REDES NEURAIS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2711', 'METOD ESTATIST MULTIVARIAVEIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2712', 'TEORIA INFERENCIA ESTATISTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2713', 'METODOS BAYESIANOS DE PREVISAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2714', 'ANALISE DE SERIES FINANCEIRAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2720', 'ANALISE DE SERIES TEMPORAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2721', 'MODELOS ESTRUTURAIS PARA SERIES TEMPORAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2742', 'PROGRAMACAO LINEAR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2744', 'PROGRAMACAO INTEIRA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2757', ' TOP ESPECIAIS DE SISTEMAS I ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2758', 'TOP ESPECIAIS DE SISTEMAS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2759', 'TOP ESPECIAIS DE SISTEMAS III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2760', 'TOPICOS ESPECIAIS EM INTELIGENCIA COMPUTACIONAL I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2761', 'TOPICOS ESPECIAIS EM INTELIGENCIA COMPUTACIONAL II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2768', 'TOPICOS ESPECIAIS EM VISAO COMPUTACIONAL I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE2769', ' TOP ESP VIS COMPUTACIONAL II ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3007', 'EXAME DE PROPOSTA DE TESE', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3200', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3201', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3204', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3205', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3206', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3211', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3221', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3224', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3225', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3226', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3227', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3228', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELE3229', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('ELL0900', 'ELET LIVRES-DENTRO/FORA DEPT', 18, NULL);
INSERT INTO "Disciplina" VALUES ('ELO0900', 'ELETIVAS DE ORIENTACAO', 22, NULL);
INSERT INTO "Disciplina" VALUES ('ELU0900', 'ELETIVAS-FORA DO DEPARTAMENTO', 8, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1000', 'PROJETO FINAL DE EMPREENDEDORISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1005', 'SEMINARIO DE FINANCAS PARA EMPREENDEDORES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1006', 'LABORATORIO DE IDEIAS E OPORTUNIDADES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1008', ' SIMULA DECISAO PLAN/ORC/IMPLEM ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1009', 'FINANCA PARA EMPREENDEDORES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1010', 'EMPREENDEDORISMO SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1011', 'PLANEJ EMPREENDIMENTOS SOCIAIS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1012', 'QUALIDADE NA GESTAO DE NEGOCIOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1014', ' EMPRESAS FAMILIARES ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1032', 'CRIACAO DE PROJETOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1101', 'TOPICOS ESPECIAIS EM EMPREENDEDORISMO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1102', 'TOPICOS ESPECIAIS EM EMPREENDEDORISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1103', 'EMPREENDEDORISMO E DESENVOLVIMENTO LOCAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1104', 'TOPICOS ESPECIAIS EM EMPREENDEDORISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1106', 'TOP ESP EM EMPREENDEDORISMO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1107', 'TOP ESP EM EMPREENDEDORISMO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('EMP1200', 'EMPREENDEDORISMO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0100', 'OPTATIVAS DE ENFASE - EEL - 2', 28, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0110', 'OPTATIVAS DE ENFASE - EEL - 3', 20, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0301', 'OPT DE SISTEMAS DIGITAIS', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0302', 'OPT DE SISTEMAS MECATRONICOS', 20, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0303', 'OPT ENFASES EM ENG ELETRICA', 18, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0305', 'OPT DE ENGENHARIA DE PETROLEO', 8, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0306', 'OPT DE PROBABILIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0307', 'OPT DE ESTATISTICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0308', 'OPT DE PESQUISA OPERACIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0309', 'OPT DE PROCESSOS ESTOCASTICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0310', 'OPT DE MARKETING', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0311', 'OPT DE ENG DE PRODUCAO', 23, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0314', 'OPT DE NANOTECNOLOGIA', 27, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0316', 'OPT FENOMENOS TRANSPORTE', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0317', 'OPT DE ENGENHARIA AMBIENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0318', 'OPT DE ELETRICIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0401', 'OPT PROJ GRAD ENGENHARIA AMBIE', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0403', 'OPT PROJ GRA ENG COMPUTACAO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0404', 'OPT PROJ GRA ENG COMPUTACAO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0405', 'OPT PROJ GRAD ENG CONTR AUTOMA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0406', 'OPT DE PROJ GRADUACAO EM ENG E', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0408', 'OPT PROJ GRAD ENGENHARIA MECAN', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0410', 'OPT PROJ GRADUACAO ENG DE PROD', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0411', 'OPT PROJ GRAD ENGENHARIA QUIMI', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0442', 'OPT DE QUIMICA GERAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0447', 'OPT DE FENOMENOS DE TRANSPORTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0449', 'OPTATIVAS DE ECONOMIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0451', 'OPT DE ELETROTECNICA GERAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0452', 'OPT DE ESTATISTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0454', 'OPT DE ENGENHARIA AMBIENTAL', 7, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0455', 'OPT DE GEOPROCESSAMENTO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0457', 'OPT DE TRANSF DE MASSA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0464', 'OPT FUNDAMENTOS GEOTECNIA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0471', 'OPT FONTES/CONTROLES POL INDUS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0472', 'OPT TRATAMENTO EFLUENTES INDUS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0482', 'OPT SIST GESTAO/QUALID AMBIENT', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0502', 'OPT DE GEOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0511', 'OPT FUNDAMENTOS GEOTECNIA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0515', 'OPT MECANICA DOS SOLOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0516', 'OPT PROJ GRAD ENGENHARIA CIVIL', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0551', 'OPT ENGENHARIA DE COMPUTACAO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0603', 'OPT INSTRUMENTACAO ELETRONICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0604', 'OPT SISTEMAS DIGITAIS', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0607', 'OPT INTEGRACAO DA MANUFATURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0610', 'OPT CONTROLE E AUTOMACAO', 28, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0654', 'OPT DE CIRCUITOS ELETRICOS E E', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0655', 'OPTATIVAS DE MATERIAIS ELETRIC', 6, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0662', 'OPTATIVAS DE TECNICAS DIGITAIS', 7, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0663', 'OPT CONVERSAO ELETROMECANICA E', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0664', 'OPT ONTROLE E SERVOMECANISMOS', 7, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0665', 'OPT CONTROLE DE SISTEMAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0674', 'OPT MICROCONTROLADORES/SIST EM', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0701', 'OPT INTROD ENG DE MATERIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0703', 'OPT DE INTR PROCES MATERIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0765', 'OPT DE TECNOLOGIA MECANICA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0802', 'OPT MECANICA DOS FLUIDOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0830', 'OPT ENGENHARIA DE PETROLEO', 15, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0832', 'OPT INSTRUMENTACAO ELETRONICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0851', 'OPT DE PROBABILIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0852', 'OPT DE ESTATISTICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0853', 'OPT DE PESQUISA OPERACIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0854', 'OPT DE PROCESSOS ESTOCASTICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0855', 'OPT DE MARKETING', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0856', 'OPT DE ENGENHARIA DE PRODUCAO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0857', 'OPT PLANEJAMENTO/CONTROLE PROD', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0858', 'OPT ADMINISTRACAO P/ENG DE PRO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0859', 'OPT CALC VAR VARIAVEIS II P/EN', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0901', 'OPT TERMODINAMICA P/ ENG QUIMI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0904', 'OPT TRANSFERENCIA DE CALOR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG0905', 'OPT TRANSFERENCIA DE MASSA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1000', 'INTRODUCAO A ENGENHARIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1003', 'DESENHO TECNICO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1004', 'DESENHO TECNICO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1007', 'INTRODUACAO A MECANICA DOS SOLIDOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1011', 'FENOMENOS DE TRANSPORTE I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1012', 'FENOMENOS DE TRANSPORTE II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1015', 'CIENCIA E TECNOLOGIA DOS MATERIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1016', 'MATERIAIS DE ENGENHARIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1018', 'ELETROTECNICA GERAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1019', 'LABORATORIO DE ELETROTECNICA GERAL', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1021', 'ADMINISTRACAO PARA ENGENHEIROS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1023', 'INTRODUCAO A ECONOMIA PARA ENGENHEIROS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1025', 'INTRODUCAO A ENGENHARIA AMBIENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1027', 'INSTRUMENTACAO ELETRONICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1028', 'TERMODINAMICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1029', 'PROBABILIDADE E ESTATISTICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1030', 'TRANSFERENCIA DE MASSA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1031', 'MECANICA DOS FLUIDOS', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1032', 'TRANSMISSAO DE CALOR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1101', 'ESTUDO ORIENTADO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1102', 'ESTUDO ORIENTADO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1103', 'ESTUDO ORIENTADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1104', 'ESTUDO ORIENTADO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1110', 'TOPICOS ESPECIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1115', 'TOPICOS ESPECIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1121', 'TOPICOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1122', 'TOPICOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1123', 'TOPICOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1124', 'TOPICOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1130', 'PROJETO DE GRADUACAO EM ENGENHARIA AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1131', 'PROJETO DE GRADUACAO EM ENGENHARIA CIVIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1132', 'PROJ GRAD EM ENG COMPUTACAO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1133', 'PROJ GRAD EM ENG COMPUTACAO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1134', 'PROJ GRAD ENG CONTR AUTOMACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1135', 'PROJETO DE GRADUACAO EM ENGENHARIA ELETRICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1137', 'PROJETO DE GRADUACAO EM ENGENHARIA DE MATERIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1138', 'PROJETO DE GRADUACAO EM ENGENHARIA MECANICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1139', 'PROJETO DE GRADUACAO EM ENGENHARIA DE PETROLEO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1140', 'PROJETO DE GRADUACAO EM ENGENHARIA DE PRODUCAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1141', 'PROJETO DE GRADUACAO EM ENGENHARIA QUIMICA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1142', 'PROJETO DE GRADUACAO EM ENGENHARIA QUIMICA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1143', 'PROJETO DE GRADUACAO EM ENGENHARIA DE PETROLEO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1144', 'PROJ GRAD ENG NANOTECNOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1150', 'ESTAGIO SUPERVISIONADO EM ENGENHARIA AMBIENTAL', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1151', 'ESTAGIO SUPERVISIONADO EM ENGENHARIA CIVIL', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1153', 'EST SUPERV EM ENG COMPUTACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1154', 'EST SUP ENG CONTR E AUTOMACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1155', 'ESTAGIO SUPERVISIONADO EM ENGENHARIA ELETRICA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1157', 'ESTAGIO SUPERVISIONADO EM ENGENHARIA DE MATERIAIS', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1158', 'ESTAGIO SUPERVISIONADO EM ENGENHARIA MECANICA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1159', 'ESTAGIO SUPERVISIONADO EM ENGENHARIA DE PETROLEO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1160', 'ESTAGIO SUPERVISIONADO EM ENGENHARIA DE PRODUCAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1161', 'ESTAGIO SUPERVISIONADO EM ENGENHARIA QUIMICA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1162', 'EST SUPERV ENG NANOTECNOLOGIA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1170', 'ESTAGIO EM TEMPO INTEGRAL', 16, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1200', 'MECANICA GERAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1201', 'GEOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1202', 'LABORATORIO DE GEOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1203', 'ANALISE DE ESTRUTURAS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1204', 'ANALISE DE ESTRUTURAS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1205', 'RESISTENCIA DOS MATERIAIS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1206', 'RESISTENCIA DOS MATERIAIS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1207', 'HIDRAULICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1208', 'TOPOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1209', 'FUNDAMENTOS DE GEOTECNIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1210', 'LABORATORIO DE GEOTECNIA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1211', 'MECANICA DOS SOLOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1212', 'LABORATORIO DE MECANICA DOS SOLOS', 1, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1213', 'MATERIAIS DE CONSTRUCAO I', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1215', 'ESTRUTURAS DE MADEIRA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1216', 'HIDROLOGIA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1218', 'ESTRUTURAS DE CONCRETO ARMADO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1219', 'ESTRUTURAS DE CONCRETO ARMADO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1220', 'ESTRUTURAS DE ACO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1222', 'ESTRADAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1223', 'CONSTRUCAO CIVIL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1224', 'CONSTRUCAO CIVIL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1225', 'INSTALACOES PREDIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1226', 'PLANEJAMENTO E CONTROLE DE OBRAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1227', 'GEOTECNIA APLICADA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1228', 'ENGENHARIA DE FUNDACOES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1229', 'ARQUITETURA E URBANISMO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1230', 'SANEAMENTO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1231', 'METOD DO PROJETO EM ENG CIVIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1244', 'PONTES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1245', 'ESTRUTURAS FLUVIAIS E MARITIMAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1264', 'INTRODUCAO A MECANICA DAS ROCHAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1266', 'GEOTECNIA AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1301', 'INTRODUCAO CARACTERIZACAO,PROCESSEMENTO/OBTENCAO M', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1303', 'DIAGRAMAS DE FASES E SUAS APLICACOES', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1311', 'RECURSOS NAT E PROCES MINERAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1312', 'CINETICA DAS REACOES E PROCESSOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1313', 'EXTRACAO E SINTESE DE MATERIAIS A', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1314', 'ELETROQUIMICA E APLICACOES NA ENGENHARIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1315', 'EXTRACAO E SINTESE DE MATERIAIS B', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1316', 'NAO FERROSOS E DERIVADOS METALICOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1317', 'SIDERURGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1319', 'PROCESSOS E PROJETOS MINERO-METALURGICOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1330', 'MONITORAMENTO AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1331', 'ESTRUTURA DOS MATERIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1332', 'TRANSFORMACOES DE FASES DOS MATERIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1333', 'COMPORTAMENTO MECANICO DOS MATERIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1334', 'CARACTERIZACAO MICROESTRUTURAL DOS MATERIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1336', 'FERRO E SUAS LIGAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1337', 'MATERIAIS CERAMICOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1338', 'MATERIAIS POLIMERICOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1339', 'MATERIAIS COMPOSITOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1340', 'PROCESSOS DE FABRICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1341', 'JUNCAO DE MATERIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1342', 'ESPECIFICACAO E SELECAO DE MATERIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1351', 'FONTES/CONTR POLUIC INDUSTRIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1352', 'TRATAMENTO DE EFLUENTES INDUSTRIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1353', 'RECICLAGEM DE RESIDUOS INDUSTRIAIS E SUCATAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1354', 'FONTES DE ENERGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1400', 'SINAIS E SISTEMAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1401', 'INTRODUCAO A SISTEMAS DE ENERGIA ELETRICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1402', 'INTRODUCACAO AS TELECOMUNICACOES', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1403', 'CIRCUITOS ELETRICOS E ELETRONICOS', 6, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1404', 'LABORATORIO DE CIRCUITOS ELETRICOS E ELETRONICOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1405', 'MATERIAIS ELETRICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1406', 'LABORATORIO DE MATERIAIS ELETRICOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1407', 'ELETROMAGNETISMO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1408', 'ELETROMAGNETISMO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1409', 'INTRODUCAO A ANALISE ESTATISTICA DE DADOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1410', 'MODELOS PROBABILISTICOS EM ENGENHARIA ELETRICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1411', 'PRINCIPIOS DE COMUNICACOES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1412', 'INSTALACOES ELETRICAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1413', 'TECNICAS DIGITAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1414', 'LABORATORIO DE TECNICAS DIGITAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1415', 'CONVERSAO ELETROMECANICA DE ENERGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1416', 'LABORATORIO DE CONVERSAO ELETROMECANICA DE ENERGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1417', 'CONTROLE E SERVOMECANISMOS', 6, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1418', 'LABORATORIO DE CONTROLES E SERVOMECANISMOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1425', 'GERACAO DE ENERGIA ELETRICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1426', 'TRANSMISSAO DE ENERGIA ELETRICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1428', 'ANALISE DE SISTEMAS DE ENERGIA ELETRICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1429', 'ANALISE DE SISTEMAS DE ENERGIA ELETRICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1430', 'ANAL SIST ENERGIA ELETRICA III', 99, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1432', 'SUBESTACOES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1433', 'PROTECAO DE SISTEMAS ELETRICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1436', 'EFICIENCIA ENERGETICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1443', 'PROCESSAMENTO DIGITAL DE SINAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1444', 'ELETRONICA ANALOGICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1445', 'LABORATORIO DE ELETRONICA ANALOGICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1446', 'PROJETOS EM ELETRONICA ANALOGICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1448', 'COMPUTACAO DIGITAL', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1450', 'MICROCONTROLADORES E SISTEMAS EMBARCADOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1451', 'ARQUITETURA DE COMPUTADORES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1452', 'ELETRONICA DE POTENCIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1456', 'INTELIGENCIA COMPUTACIONAL APLICADA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1458', 'PROJETO AUTOMACAO INDUSTRIAL', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1459', 'SISTEMAS DIGITAIS PARA AUTOMACAO', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1460', 'CONTROLE INTELIGENTE DE SISTEMAS ROBOTICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1465', 'PROCESSOS ESTOCASTICOS MARKOVIANOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1466', 'TEORIA DA INFERENCIA ESTATISTICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1467', 'OTIMIZACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1468', 'PROGRAMACOA LIENAR INTEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1469', 'ANALISE DE SERIES TEMPORAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1470', 'MODELOS DE REGRESSAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1471', 'CONTROLE DISCRETO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1475', 'ANTENAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1476', 'RADIO PROPAGACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1477', 'DISPOSITIVOS DE MICROONDAS I', 6, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1478', 'PRINCIPIOS DE COMUNICACOES OTICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1479', 'REDES DE COMUNICACOES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1481', 'SISTEMAS RADIO FIXOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1482', 'SISTEMAS MOVEIS DE RAPIDO ACESSO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1483', 'SISTEMAS DE TRANSMISSAO DIGITAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1487', 'PROCESSAMENTO DE VOZ E IMAGEM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1490', 'REGULACAO E GESTAO DE TELECOMUNICACOES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1500', 'TEORIA DA PROBABILIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1501', 'INFERENCIA ESTATISTICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1502', 'PESQUISA OPERACIONAL I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1503', 'PESQUISA OPERACIONAL II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1504', 'ENGENHARIA DE METODOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1505', 'INTRODUCAO A TEORIA ECONOMICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1506', 'PLANEJAMENTO E CONTROLE DE PRODUCAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1507', 'TRANSPORTE E LOGISTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1508', 'ARRANJO FISICO INDUSTRIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1509', 'PROJETO DO PRODUTO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1510', 'ERGONOMIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1511', 'TECNOLOGIA INDUSTRIAL BASICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1512', 'ECONOMIA DA ENGENHARIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1513', 'CONTABILIDADE GERENCIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1514', 'ESTRATEGIA DA PRODUCAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1515', 'ANALISE DE DECISOES E RISCO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1516', 'CONTROLE DE QUALIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1517', 'MARKETING', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1518', 'SISTEMAS DE INFORMACAO GERENCIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1519', 'ORGANIZACAO DE EMPRESAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1520', 'HIGIENE E SEGURANCA DO TRABALHO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1521', 'GERENCIA DA PRODUCAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1522', 'GERENCIA DE PROJETOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1523', 'GERENCIA DA QUALIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1525', 'GERENCIA FINANCEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1526', 'ENGENHARIA FINANCEIRA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1527', 'ENGENHARIA FINANCEIRA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1528', 'LOGISTICA GERAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1529', 'DISTRIBUICAO FISICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1530', 'COMERCIO INTERNACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1531', 'ESTRATEGIAS E GESTAO DE COMPRAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1533', 'ANALISE FINANCEIRA EM ENGENHARIA DE PETROLEO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1700', 'ESTATICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1701', 'TERMODINAMICA PARA ENGENHARIA MECANICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1702', 'DESENHO MECANICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1703', 'MECANICA DOS SOLIDOS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1704', 'MECANICA DOS SOLIDOS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1705', 'DINAMICA DE CORPOS RIGIDOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1707', 'MECANICA DOS FLUIDOS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1708', 'METROLOGIA DIMENSIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1709', 'COMPORTAMENTO MECANICO DOS MATERIAIS', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1710', 'VIBRACOES MECANICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1712', 'TECNOLOGIA MECANICA', 6, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1713', 'METODOS EXPERIMENTAIS EM ENGENHARIA MECANICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1714', 'METODOS NUMERICOS EM ENGENHARIA MECANICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1715', 'ELEMENTOS DE MAQUINAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1716', 'MAQUINAS TERMICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1717', 'PROCESSOS DE FABRICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1718', 'MODELAGEM SISTEMAS DINAMICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1719', 'CONTROLE DE SISTEMAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1720', 'PROJETO DE SISTEMAS MECANICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1721', 'PROJETO DE SISTEMAS TERMICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1722', 'CONTROLE DA POLUICAO ATMOSFERICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1727', 'BIOLOGIA P/ENG AMBIENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1780', 'INTEGRADORA BASICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1781', 'INTEGRADORA BASICA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1782', 'SISTEMAS DE ATUACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1783', 'INTEGRACAO DA MANUFATURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1784', 'AUTOMACAO DA MANUFATURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1786', 'OTIMIZACAO DE PROJETOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1791', 'INTRODUCAO AOS SISTEMAS AUTOMOTIVOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1793', 'FUNDAMENTOS DE PROJETOS DE VEICULOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1800', 'INTRODUCAO AOS PROCESSOS QUIMICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1801', 'METODOS NUM P/ ENG QUIMICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1802', 'INTRODUCAO A ENGENHARIA QUIMICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1803', 'TERMODINAMICA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1805', 'ENGENHARIA BIOQUIMICA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1806', 'ENGENHARIA BIOQUIMICA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1807', 'ENGENHARIA DE PROCESSOS QUIMICOS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1808', 'ENGENHARIA DE PROCESSOS QUIMICOS II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1809', 'CALCULO DE REATORES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1810', 'CALCULO DE REATORES II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1813', 'OPERACOES UNITARIAS A', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1814', 'OPERACOES UNITARIAS B', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1815', 'OPERACOES UNITARIAS C', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1816', 'PROJETO DE PROCESSOS QUIMICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1817', 'ANALISE E CONTROLE DE PROCESSOS QUIMICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1818', 'SIMULACAO E OTIMIZACAO DE PROCESSOS QUIMICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1819', 'LABORATORIO DE ENGENHARIA QUIMICA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1820', 'LAB DE ENGENHARIA QUIMICA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1821', 'TECNOLOGIA DE PROCESSOS QUIMICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1900', 'AVALIACAO E CONTABILIZACAO DE IMPACTOS AMBIENTAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1901', 'RECUP DE AREAS DEGRADADAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1902', 'ESTAGIO DE CAMPO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1903', 'COLETA E DISP DE RESID SOLIDOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1904', 'SAUDE AMBIENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1905', 'SISTEMAS DE GESTAO E DE QUALIDADE AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1906', 'ANALISE DE RISCO AMBIENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1907', 'QUIMICA ANALIT P/ENG AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1908', 'QUIMICA ORGANICA PARA ENGENHARIA AMBIENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1909', 'LABORATORIO DE QUIMICA ORGANICA PARA ENGENHARIA AM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1910', 'GEOPROCESSAMENTO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1913', 'MEIO AMBIENTE E DESENVOLVIMENTO SUSTENTAVEL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1920', 'SISTEMAS MARITIMOS DE PRODUCAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1921', 'GEOLOGIA DO PETROLEO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1922', 'QUIMICA DO PETROLEO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1923', 'ENGENHARIA DE RESERVATORIOS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1924', 'PETROFISICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1925', 'FUNDAMENGOS DA PERFILAGEM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1926', 'ENGENHARIA DE RESERVATORIOS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1927', 'METODOS GEOFISICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1928', 'ENGENHARIA DE PRODUCAO DE PETROLEO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1929', 'ENGENHARIA DE POCOS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1930', 'ENGENHARIA DE POCOS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1931', 'MECANICA DAS ROCHAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1932', 'AVALIACAO DE FORMACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1933', 'ANALISE DE RISCO AMBIENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1934', 'ENG DE PRODUCAO DE PETROLEO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1960', 'INTRODUCAO A NANOTECNOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1961', 'CARACTERIZACAO NANOMATERIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1962', 'LAB CARACT DE NANOMATERIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1963', 'SINTESE DE NANOMATERIAIS', 5, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1972', 'IMPAC SOCIAIS NONOTECNOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('ENG1973', 'IMPAC AMBIENT NANOTECNOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIL0100', 'OPTATIVAS DEPT DE FILOSOFIA', 20, NULL);
INSERT INTO "Disciplina" VALUES ('FIL0102', 'OPT FILOSOFIA-NUCLEO BAS CTCH', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL0150', 'OPTATIVAS LICENCIATURA EM FILO', 24, NULL);
INSERT INTO "Disciplina" VALUES ('FIL0201', 'OPT FILOSOFIA-NUCLEO BAS CCS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL0202', 'OPTATIVAS FILOSOFIA-SER SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL0204', 'OPT FIL PARA CIEN SOC', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL0300', 'OPTATIVAS FILOSOFIA-CB/CTC', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1000', 'INTRODUCAO A FILOSOFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1002', 'FILOSOFIA DA CIENCIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1006', 'HISTORIA DO PENSAMENTO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1100', 'MET DE PESQ BIBL EM FILOSOFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1150', 'MONOGRAFIA', 10, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1211', 'CORR DO PENS CONTEMPORANEO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1212', 'CORR DO PENS CONTEMPORANEO III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1220', 'HISTORIA DA FILOSOFIA ANTIGA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1221', 'HISTORIA DA FILOSOFIA ANTIGA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1222', 'HISTORIA FILOSOFIA MEDIEVAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1223', 'HISTORIA DA FILOSOFIA MODERNA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1224', 'HISTORIA DA FILOSOFIA MODERNA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1225', 'HISTORIA DA FILOSOFIA CONTEMPORANEA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1251', ' SEMINARIO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1254', ' SEMINARIO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1255', 'SEMINARIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1260', 'TOPICOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1261', 'TOPICOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1262', 'TOPICOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1302', 'TEORIA DO CONHECIMENTO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1303', 'TEORIA DO CONHECIMENTO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1304', 'LOGICA I (INTR FIL A LOGICA)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1310', 'LOGICA II(INTR A LOG MODERNA)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1319', ' FILOSOFIA DA LOGICA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1334', 'QUESTOES EPISTEMOLOGICAS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1400', 'FILOSOFIA GERAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1401', 'FILOSOFIA GERAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1500', 'FILOSOFIA DA NATUREZA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1600', 'ANTROPOLOGIA FILOSOFICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1601', 'ANTROPOLOGIA FILOSOFICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1700', 'ETICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1701', 'ETICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1801', 'FILOSOFIA DA HISTORIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1802', 'FILOSOFIA DA LINGUAGEM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1803', 'FILOSOFIA DA ARTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1804', 'FILOSOFIA DA RELIGIAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1814', 'FILOSOFIA POLITICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1815', 'ESTETICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1816', 'ESTETICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1820', 'DIDATICA ESPECIAL DE FILOSOFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1821', 'APOIO DOCENTE EM FILOSOFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1822', 'ESTAGIO SUPERVISIONADO I - FILOSOFIA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1823', 'ESTAGIO SUPERVISIONADO II - FILOSOFIA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1830', 'DIDATICA ESP DE FILOSOFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1831', 'APOIO DOCENTE EM FILOSOFIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1832', 'ESTAG SUPERV I - FILOSOFIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIL1833', 'ESTAG SUPERV II - FILOSOFIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2158', 'SEMINARIO DE MESTRADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2160', 'SEMINARIO DE DOUTORADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2164', ' ESTUDO INDIVIDUAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2165', 'ESTUDO INDIVIDUAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2166', 'ESTUDO INDIVIDUAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2280', 'TOP ESP DE HIST DA FILOSOFIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2282', 'TOP ESP DE HIST DA FILOSOFIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2283', 'TOP ESP DE HIST DA FILOSOFIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2284', 'TOP ESP DE HIST DA FILOSOFIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2285', 'TOP ESP DE FIL CONTEMPORANEA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2286', 'TOP ESP DE FIL CONTEMPORANEA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2287', ' TOP ESP DE FIL CONTEMPORANEA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2288', 'TOP ESP DE FIL CONTEMPORANEA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2289', 'TOP ESP DE FIL CONTEMPORANEA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2314', 'TOPICOS DE LOGICA MATEMATICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2318', 'TOPICOS DE LOGICA MATEMATICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2347', ' TOP DE FIL DA LINGUAGEM ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2348', 'TOP DE FIL DA LINGUAGEM', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2349', 'TOP DE FIL DA LINGUAGEM', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2350', 'TOP DE TEORIA DO CONHECIMENTO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2563', ' CIENCIA E SOCIEDADE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2650', 'QUESTOES DE FILOSOFIA MODERNA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2651', 'QUESTOES DE FILOSOFIA MODERNA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2652', ' QUESTOES DE FILOSOFIA MODERNA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2670', 'TOPICOS DE FILOSOFIA ANTIGA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2671', 'TOPICOS DE FILOSOFIA ANTIGA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2681', 'TOP DE FIL SOCIAL E POLITICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2682', 'TOP DE FIL SOCIAL E POLITICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2684', ' TOP DE FIL SOCIAL E POLITICA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2701', 'PENS ETICO MODERNO E CONTEMP', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2781', ' TOPICOS DE ETICA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2882', ' TOP DE FILOSOFIA DA CULTURA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2883', 'TOP DE FILOSOFIA DA CULTURA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL2884', 'TOP DE FILOSOFIA DA CULTURA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIL3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('FIL3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('FIL3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('FIL3200', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('FIL3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('FIL3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('FIS0200', 'OPT FISICA-DESEN INDUSTRIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS0303', 'OPT MEC GERAL II/MEC ANALITICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1002', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1003', 'MECANICA NEWTONIANA A', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1004', 'MECANICA NEWTONIANA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1005', 'FLUIDOS E TERMODINAMICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1006', 'ELETROMAGNETISMO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1007', 'FISICA MODERNA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1011', 'FISICA NA ARQUITETURA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1012', 'ASPECTOS FISICOS NO CONFORTO AMBIENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1021', 'MECANICA NEWTONIANA A', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1022', 'LAB MEC NEWTONIANA A', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1025', 'MECANICA NEWTONIANA A', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1026', 'MECANICA NEWTONIANA B', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1027', 'LABORATORIO DE MECANICA NEWTONIANA B', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1031', 'MECANICA NEWTONIANA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1032', 'LAB MEC NEWTONIANA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1033', 'MECANICA NEWTONIANA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1034', 'LABORATORIO DE MECANICA NEWTONIANA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1041', 'FLUIDOS E TERMODINAMICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1042', 'LABORATORIO DE FLUIDOS E TERMODINAMICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1051', 'ELETROMAGNETISMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1052', 'LABORATORIO DE ELETROMAGNETISMO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1053', 'ESTUDOS ORIENTADOS DE ELETROMAGNETISMO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1061', 'FISICA MODERNA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1062', 'LABORATORIO DE FISICA MODERNA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1100', 'INTRODUCAO A FISICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1101', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1104', 'FISICA IV', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1105', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1108', 'FISICA D', 99, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1130', 'FISICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1201', 'MECANICA GERAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1211', 'MECANICA ANALITICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1212', 'TEORIA DA RELATIV RESTRITA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1221', 'MECANICA QUANTICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1222', 'MECANICA QUANTICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1301', 'ELETROMAGNETISMO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1302', 'ELETROMAGNETISMO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1330', 'BIOFISICA PARA BIOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1400', 'ESTRUTURA DA MATERIA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1402', 'ESTRUTURA DA MATERIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1405', 'ESTRUTURA DA MATERIA III', 6, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1406', 'ESTRUTURA DA MATERIA IV', 6, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1407', ' FISICA CONTEMPORANEA I ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1451', 'LAB DE FISICA MODERNA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1452', 'LAB DE FISICA MODERNA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1462', ' TOP DE FISICA CONTEMPORANEA ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1463', ' TOP DE FISICA CONTEMPORANEA ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1505', 'MET MAT DA FIS E DA ENG I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1506', 'MET MAT DA FIS E DA ENG II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1602', 'FISICA ESTATISTICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS1810', 'A FISICA NA MUSICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2007', 'FISICA QUANTICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2102', ' TOPICOS AVANC FISICA TEORICA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2106', ' TOPICOS AVANC FISICA TEORICA ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2107', 'TOPICOS AVANCADOS DE FISICA TEORICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2112', 'TOPICOS AVANCADOS DE FISICA TEORICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2113', 'TOPICOS AVANCADOS DE FISICA TEORICA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2203', 'MECANICA QUANTICA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2303', 'ELETROMAGNETISMO III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2533', 'TOPICOS AVANCADOS DE BIOFISICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2555', 'OTICA AVANCADA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2572', ' TOP AVANC FISICA APLICADA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2601', 'MECANICA ESTATISTICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2901', 'SEMINARIOS I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2902', 'SEMINARIOS II', 1, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2903', 'SEMINARIOS III', 1, NULL);
INSERT INTO "Disciplina" VALUES ('FIS2904', 'SEMINARIOS IV', 1, NULL);
INSERT INTO "Disciplina" VALUES ('FIS3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('FIS3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('FIS3005', 'EXAME DE QUALIFICACAO - PROVA ORAL', 0, NULL);
INSERT INTO "Disciplina" VALUES ('FIS3201', ' ESTAGIO DOCENCIA NA GRADUACAO ', 1, NULL);
INSERT INTO "Disciplina" VALUES ('FIS3202', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS3212', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('FIS3221', ' ESTAGIO DOCENCIA NA GRADUACAO ', 1, NULL);
INSERT INTO "Disciplina" VALUES ('FLE1102', 'METAFISICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO0203', 'OPT GEOGRAFIA-NUCLEO BAS CCS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO0230', 'OPT DE GEOGRAFIA P/ADM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO0300', 'OPT DE GEO P/CIENCIAS SOCIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1100', 'CLIMATOLOGIA PARA ENGENHARIA AMBIENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1114', 'GEOGRAFIA FISICA GERAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1115', 'FUNDAMENTOS DE GEOLOGIA PARA A GEOGRAFIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1116', 'CLIMATOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1117', 'GEOMORFOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1118', 'HIDROLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1119', 'PEDOLOGIA E MANEJO DOS SOLOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1120', 'GEOMORFOLOGIA COSTEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1121', 'DINAM PAISAGEM GEOMORFOLOGICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1201', 'GEOGRAFIA HUMANA-ESPACO E SOCIEDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1204', 'GEOGRAFIA HUMANA - ESPACO URBANO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1211', 'GEOGRAFIA HUMANA GERAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1212', 'GEOHISTORIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1213', 'ESPACO AGRARIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1214', 'GEOGRAFIA DA POPULACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1215', 'ESPACO INDUSTRIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1216', 'GEOGRAFIA POLITICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1217', 'ESPACO URBANO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1310', 'ESPACO AGRARIO BRASILEIRO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1311', 'GEOGRAFIA POPULACAO DO BRASIL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1312', 'ESPACO URBANO BRASILEIRO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1409', 'GEOGRAFIA DO MUNDO CONTEMPORANEO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1410', 'GEOGRAFIA DO MUNDO CONTEMPORANEO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1411', 'GEOGRAFIA DO RIO DE JANEIRO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1430', 'BIOGEOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1510', 'TRABALHO FINAL DE CURSO(MONOG)', 8, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1511', 'PENSAMENTO GEOGRAFICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1512', 'METODOLOGIA DA GEOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1513', 'PLANEJ E GESTAO DO TERRITORIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1514', 'PRAT PESQ I-MET QUANTITATIVOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1515', 'PRAT PESQ II - AVAL AMBIENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1516', 'PRATICA DE PESQUISA III - AVALIACAO AMBIENTAL (PRO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1517', 'PRATICA DE PESQUISA IV - ESTAGIO DE CAMPO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1524', 'TRABALHO FINAL DE LICENCIATURA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1525', 'TRABALHO FINAL DE LICENCIATURA II', 7, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1526', 'TRABALHO FINAL DE BACHARELADO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1527', 'TRABALHO FINAL DE BACHARELADO II', 7, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1528', 'ESTAGIO SPERVISIONADO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1529', 'ESTAGIO SUPERVISIONADO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1530', 'ESTAGIO SUPERVISIONADO III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1531', 'ESTAGIO SUPERVISIONADO IV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1600', 'ECOLOGIA PARA ENG AMBIENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1603', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1631', 'INTRODUCAO A BIOGEOGRAFIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1632', 'ECOLOGIA GERAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1633', 'BIOGEOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1634', 'ECOLOGIA FLORESTAS TROPICAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1635', 'ETICA AMBIENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1636', 'RECURSOS NATURAIS E MEIO AMBIENTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1731', 'CARTOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1732', 'GEOPROCESSAMENTO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1801', 'ENSINO DE GEOGRAFIA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1802', 'ENSINO DE GEOGRAFIA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1803', 'ENSINO DE GEOGRAFIA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1804', 'ENSINO DE GEOGRAFIA IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1902', 'SEMINARIOS ESPECIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1903', ' SEMINARIOS ESPECIAIS ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1911', 'SEMINARIOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO1917', ' SEMINARIOS ESPECIAIS ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2001', 'PAISAGEM, ESPACO E SUSTENTABILIDADES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2002', 'TEORIA E EPISTEMOLOGIA DA GEOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2102', 'HISTORIA AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2104', ' ECOLOGIA DA PAISAGEM ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2106', 'EVOLUCAO DA PAISAGEM GEOMORFOLOGICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2205', 'REPRESENTACOES DO ESPACO URBANO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2206', 'DESENVOLVIMENTO E TRANSFORMACOES TERRITORIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2208', ' PLANEJAMENTO/GEST TERRITORIO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2210', 'TOPICOS ESPECIAIS EM GEOGRAFIA E MEIO AMBIENTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2302', 'SISTEMA INFORMACOES GEOGRAFICAS APLICADO ANALISE A', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2303', 'METODOS QUANTITATIVOS APLICADOS A ANALISE AMBIENTA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2401', 'ESTUDO DIRIGIDO DE LINHA DE PESQUISA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO2402', 'SEMINARIO DE DISSERTACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('GEO3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('GEO3200', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('HIS0201', 'OPT HISTORIA-NUCLEO BAS CCS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS0204', 'OPT HISTORIA-NUC BAS-GEOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS0215', 'OPT HIS PARA CIEN SOC', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS0216', 'OPT HIS ECO POL SOC BRASIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS0226', 'OPTATIVAS DE MEDIEVAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS0230', 'OPT HISTORIA DA AMERICA', 10, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1001', 'INTR AS CIENCIAS SOCIAIS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1101', 'INTRODUCAO A HISTORIA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1102', 'INTRODUCAO A HISTORIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1103', 'TEORIA DA HISTORIA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1104', 'TEORIA DA HISTORIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1211', 'HISTORIA ANTIGA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1212', 'HISTORIA ANTIGA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1213', 'HISTORIA ANTIGA III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1221', 'HISTORIA MEDIEVAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1224', 'HISTORIA MEDIEVAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1308', 'HIST DO MUNDO CONTEMPORANEO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1311', 'HISTORIA MODERNA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1312', 'HISTORIA MODERNA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1313', 'HISTORIA MODERNA III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1321', 'HISTORIA CONTEMPORANEA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1322', 'HISTORIA CONTEMPORANEA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1323', 'HISTORIA CONTEMPORANEA III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1324', 'HISTORIA CONTEMPORANEA IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1325', 'HISTORIA DA AFRICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1326', 'HISTORIA DA AFRICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1411', 'HISTORIA DO BRASIL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1412', 'HISTORIA DO BRASIL II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1413', 'HISTORIA DO BRASIL III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1414', 'HISTORIA DO BRASIL IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1415', 'HISTORIA DO BRASIL V', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1421', 'HISTORIA DO BRASIL VI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1422', 'HISTORIA DO BRASIL VII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1423', 'HISTORIA DO BRASIL VIII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1430', 'HISTORIA DA ARQUITETURA NO BRASIL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1511', 'HISTORIA DA AMERICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1512', 'HISTORIA DA AMERICA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1513', 'HISTORIA DA AMERICA III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1514', 'HISTORIA DA AMERICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1515', 'HISTORIA DA AMERICA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1516', 'HISTORIA DA AMERICA IV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1521', 'HISTORIA DA AMERICA IV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1522', 'HISTORIA DA AMERICA V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1523', 'HISTORIA DA AMERICA VI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1603', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1604', 'HIS ECON,POLIT E SOC DO BRAS A', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1605', 'HIS ECON,POLIT E SOC DO BRAS B', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1607', 'HIS ECON,POLIT E SOC GERAL B', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1608', 'HISTORIA ECONOMICA GERAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1609', 'HISTORIA ECONOMICA GERAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1705', 'HISTORIA DA HISTORIOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1706', 'SEM ESPEC EM HISTORIA SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1709', 'MONOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1822', 'SEMINARIOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1824', ' SEMINARIOS ESPECIAIS ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1825', ' SEMINARIOS ESPECIAIS ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1826', 'SEMINARIOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1827', 'SEMINARIOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1829', ' SEMINARIOS ESPECIAIS ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1839', 'SEMINARIOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1850', 'HISTORIA DAS CIDADES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1873', 'SEMINARIOS ESPECIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1874', 'SEMINARIOS ESPECIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1875', 'SEMINARIOS ESPECIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1877', 'SEMINARIOS ESPECIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1902', 'TUTORIA I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1903', 'TUTORIA II', 1, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1904', 'TUTORIA III', 1, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1905', 'TUTORIA IV', 1, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1906', 'TUTORIA V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1907', 'LABORATORIO DE ENSINO-APRENDIZAGEM DE HISTORIA (LE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1908', 'ESTAGIO SUPERVISIONADO I', 5, NULL);
INSERT INTO "Disciplina" VALUES ('HIS1909', 'ESTAGIO SUPERVISIONADO II', 5, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2001', 'HIST E HISTORIOG DA CULTURA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2002', 'HIST E HISTORIOG DA CULTURA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2007', ' HISTORIA E TEORIA LITERARIA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2018', 'HISTORIA DA ARTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2024', 'SEMINARIOS ESPECIAIS EM TEORIA E HISTORIOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2025', 'SEMINARIOS ESPECIAIS EM TEORIA E HISTORIOG', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2026', ' SEMIN ESP TEORIA E HISTORIOG ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2027', 'SEMINARIOS ESPECIAIS EM TEORIA E HISTORIOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2028', 'SEMINARIOS ESPECIAIS EM TEORIA E HISTORIOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2029', 'SEMINARIOS ESPECIAIS EM HISTORIA CULTURAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2030', 'SEMINARIOS ESPECIAIS EM HISTORIA CULTURAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2031', 'SEMINARIOS ESPECIAIS EM HISTORIA CULTURAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2032', 'SEMINARIOS ESPECIAIS EM HISTORIA CULTURAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2033', ' SEMIN ESP HISTORIA CULTURAL ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2034', ' SEMIN ESP HISTORIA CULTURAL ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2036', 'SEMINARIOS ESPECIAIS EM HISTORIA DA ARTE E ARQUITE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2037', ' SEMIN ESP HIS ARTE/ARQUITETURA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2038', 'SEMINARIOS ESPECIAIS EM HISTORIA DA ARTE E ARQUITE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2040', 'SEMINARIOS ESPECIAIS EM HISTORIA DA ARTE E ARQUITE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2043', 'HISTORIA E HISTORIOGRAFIA DA CULTURA V', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2045', 'HISTORIA E TEMPO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2047', 'HISTORIA E IDEIAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2048', ' HISTORIA E ESTETICA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2051', 'SEMINARIO DE DISSERTACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2052', 'SEMINARIO DE DISSERTACAO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2053', 'EXAME DE QUALIFICACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2054', 'SEMINARIO DE TESE I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2055', 'SEMINARIO DE TESE II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2056', 'SEMINARIO DE TESE III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS2057', 'SEMINARIO DE TESE IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('HIS3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('HIS3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('HIS3200', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('HIS3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('HIS3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('HIS9827', 'BRAZILIAN HISTORY', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IND1004', 'PROJETO DE FORMATURA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('IND1021', 'TOPICOS ESPECIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND1031', 'TOPICOS ESPECIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND1032', 'TOPICOS ESPECIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND1033', ' TOPICOS ESPECIAIS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND1034', 'TOPICOS ESPECIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND1113', 'ESTATISTICA PARA ENG DE PROD', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IND1114', 'TEORIA DA PROBABILIDADE', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IND1115', 'INFERENCIA ESTATISTICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IND1200', 'INTRODUCAO A TEORIA ECONOMICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IND1201', 'ECONOMIA DA ENGENHARIA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IND1417', 'ESTRATEGIA E ANALISE PRODUCAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IND1604', 'ENGENHARIA FINANCEIRA I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IND2000', 'ESTUDO INDIVIDUAL I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('IND2001', 'ESTUDO INDIVIDUAL II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND2002', 'ESTUDO INDIVIDUAL III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2003', 'SEMINARIO DE ENG INDUSTRIAL', 1, NULL);
INSERT INTO "Disciplina" VALUES ('IND2006', 'ESTUDO INDIVIDUAL IV', 1, NULL);
INSERT INTO "Disciplina" VALUES ('IND2007', 'ESTUDO INDIVIDUAL V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND2008', 'ESTUDO INDIVIDUAL VI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2021', 'EXAME DE PROPOSTA DE DISSERTACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IND2050', ' TOP ESP DE ENG INDUSTRIAL ', 1, NULL);
INSERT INTO "Disciplina" VALUES ('IND2070', 'TOP ESP DE ENG INDUSTRIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2071', 'TOP ESP DE ENG INDUSTRIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2072', 'TOP ESP DE ENG INDUSTRIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2077', 'TOP ESP DE ENG INDUSTRIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2078', 'TOP ESP DE ENG INDUSTRIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2115', 'FLUXOS EM REDES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2121', 'TEORIA DA PROBABILIDADE E ELEMENTOS DE ESTATISTICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IND2123', 'TECNICAS DE OTIMIZACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IND2125', 'METODOS ECONOMETRICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IND2201', 'INTRO AS FINANCAS CORPORATIVAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2221', 'INTRODUCAO A DERIVATIVOS FINANCEIROS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2222', 'TEORIA DE FINANCAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2227', 'ANALISE DE PROJETOS INDUSTRIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2272', 'ANALISE DE INVESTIMENTOS COM OPCOES REAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2300', 'MICROECONOMIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2301', 'ORGANIZACAO INDUSTRIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2401', 'INTRO AOS SISTEMAS DE PRODUCAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2428', 'SISTEMAS DE PRODUCAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IND2431', 'METODOS ESTATISTICOS PARA A QUALIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2442', 'INTRODUCAO A SISTEMAS DE LOGISTICA E DE TRANSPORTE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2443', 'PRATICA DE MODELAGEM MATEMATICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2445', 'SISTEMAS DE DISTRIBUICAO FISICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND2450', 'GESTAO DA CADEIA DE SUPRIMENTO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND2460', 'TEORIA DA LOCALIZACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2501', 'MET PROBABILISTICOS : PROBABILIDADE E MODELOS DE P', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2503', 'LOGISTICA EMPRESARIAL E SISTEMAS PRODUTIVOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND2504', 'METODOS QUANTITATIVOS : PROGRAMACAO MATEMATICA E H', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2505', 'SISTEMAS DE INFORMACAO PARA LOGISTICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND2510', 'LOGISTICA INTEGRADA E TECNOLOGIA DA INFORMACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND2511', 'JOGO LOGISTICO OU ESTUDOS DE CASOS EM LOGISTICA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('IND2512', 'TOPICO ESPECIAL : LOGISTICA DO PETROLEO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND2513', 'TOPICOS ESPECIAIS EM LOGISTICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND2599', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IND3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IND3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IND3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IND3007', 'EXAME DE PROPOSTA DE TESE', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IND3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IND3211', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('IND3212', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND3213', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IND3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IND3221', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('IND3222', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IND3223', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF0303', 'OPT DE INTELIGENCIA ARTIFICIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF0310', 'OPT ENGENHARIA DE SOFTWARE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF0350', 'OPT DE INGLES TECNICO - INF', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF0354', 'OPTATIVAS DE LINHA A', 8, NULL);
INSERT INTO "Disciplina" VALUES ('INF0355', 'OPTATIVAS DE LINHA B', 8, NULL);
INSERT INTO "Disciplina" VALUES ('INF0358', 'OPTATIVAS DE PROJETO FINAL I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF0359', 'OPT ORGANIZACAO DE COMPUTADORE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF0360', 'OPT PRINCIPIOS DE MODELAGEM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF0361', 'OPT CALCULO I P/ CSI', 5, NULL);
INSERT INTO "Disciplina" VALUES ('INF0362', 'OPT PROJETO DE SISTEMAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF0363', 'OPT DE DIREITO P/ CSI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF0364', 'OPT MODELAGEM DE DADOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF0365', 'OPT INTRODUCAO A MATEMATICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1001', 'INTR CIENCIA DA COMPUTACAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1002', 'CALCULO NUMERICO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1004', 'PROGRAMACAO PARA INFORMATICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1005', 'PROGRAMACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1006', 'PROGRAMACAO PARA INFORMATICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1007', 'PROGRAMACAO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1008', 'INTRODUCAO A ARQUITETURA DE COMPUTADORES', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF1009', 'LOGICA PARA COMPUTACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1010', 'ESTRUTURAS DE DADOS AVANCADAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1011', 'SEMANTICA DE LINGUAGENS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1012', 'MODELAGEM DE DADOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF1013', 'MODELAGEM DE SOFTWARE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1014', 'SEMINARIO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF1015', 'COMPUTABILIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1016', 'ESPECIFICACAO E ANALISE FORMAL DE SISTEMAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1018', 'SOFTWARE BASICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1019', 'SISTEMAS DE COMPUTACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1020', 'PRINCIPIOS DE SISTEMAS DE INFORMACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1021', 'PRINCIPIOS DE GOVERNANCA EM TECNOLOGIA DA INFORMAC', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1023', 'GERENCIAMENTO DE SERVICOS EM TI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1030', 'CONCEITOS DE INFORMATICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF1044', 'ANAL E PROJ DE SISTEMAS III', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1089', 'LING E TECN DE PROGRAMACAO IV', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1093', 'T A PROG-LING ORIENTADAS OBJET', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1161', 'TOP AVAN PROGRAMACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1174', 'T A PROG-LING PROG P| AMB WIN', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1218', 'ESTRUTURA DE DADOS I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1301', 'PROGRAMACAO MODULAR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1302', 'LINGUAGENS E MAQUINAS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1308', 'ESTRUTURAS DISCRETAS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1315', 'ORGANIZACAO DE COMPUTADORES', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1316', 'SISTEMAS OPERACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1317', 'REDES DE COMPUTADORES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1318', 'TECNICAS DE PROGRAMACAO II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1337', 'LINGUAGEM DE PROGRAMACAO ORIENTADOS A OBJETOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1339', 'COMPUTACAO GRAFICA TRIDIMENSIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1340', 'BANCO DE DADOS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1341', 'BANCO DE DADOS III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1343', 'CONSTRUCAO DE SISTEMAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1346', 'PROJETO DE INTERACAO HUMANO-COMPUTADOR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1355', 'PROBABILIDADE E ESTATISTICA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('INF1359', 'PROJETO FINAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1370', 'FERRAMENTAS DO UNIX', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1371', 'PROGRAMACAO EM UNIX', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1372', 'PROJETO FINAL I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1374', 'BANCO DE DADOS IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1377', 'ENGENHARIA DE REQUISITOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1379', 'PRINCIPIOS DE MODELAGEM', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1381', 'TECNICAS DE PROGRAMACAO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1383', 'BANCOS DE DADOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1389', 'ESTRUTURAS DE DADOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1390', 'PROJETO FINAL I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1401', 'PRINCIPIOS DE MODELAGEM', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1402', 'MODELAGEM DE DADOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1403', 'INTRODUCAO A INTERACAO HUMANO-COMPUTADOR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1404', 'MODELAGEM DE SISTEMAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1405', 'CONSTRUCAO DE SISTEMAS', 5, NULL);
INSERT INTO "Disciplina" VALUES ('INF1406', 'PROGRAMACAO DISTRIBUIDA E CONCORRENTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1407', 'PROGRAMACAO PARA A WEB', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1408', 'ANALISE DE PROCESSOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1410', 'GERENCIA DE PROJETOS EM INFORMATICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1411', 'PROJETO FINAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1412', 'PROJETO FINAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1413', 'TESTE DE SOFTWARE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1414', 'QUALIDADE DE SOFTWARE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1416', 'SEGURANCA DA INFORMACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1503', 'PROCES DE DADOS(PARA ECONOMIA)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1608', 'ANALISE NUMERICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1612', 'SOFTWARE BASICO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1620', 'ESTRUTURAS DE DADOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1624', 'PROJ DE SISTEMAS DE SOFTWARE I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1626', 'LINGUAGENS FORMAIS E AUTOMATOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1627', 'SISTEMAS DE COMPUTACAO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1628', 'PROGRAMACAO PONTO GRANDE', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1629', 'PRINCIPIOS DE ENGENHARIA DE SOFTWARE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1631', 'ESTRUTURAS DISCRETAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1636', 'PROGRAMACAO ORIENTADA A OBJETOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1640', 'REDES DE COMUNICACAO DE DADOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1715', 'COMPILADORES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1721', 'ANALISE DE ALGORITMOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1731', 'BANCO DE DADOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1761', 'COMPUTACAO GRAFICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1771', 'INTELIGENCIA ARTIFICIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1801', 'TOPICOS EM ENG COMPUTACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1803', 'TOPICOS EM ENG COMPUTACAO III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1804', 'TOPICOS EM ENGENHARIA DE COMPUTACAO IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1810', 'TOPICOS EM ENGENHARIA DE COMPUTACAO X', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1811', 'SEMINARIO I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF1812', 'SEMINARIO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF1813', 'SEMINARIO III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF1814', 'SEMINARIO IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1821', 'PROJETO ORIENTADO I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF1822', 'PROJETO ORIENTADO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF1823', 'PROJETO ORIENTADO III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF1824', 'PROJETO ORIENTADO IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1902', 'PLANEJAMENTO DE NEGOCIOS PARA EMPREENDEDORES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1903', 'METODOLOGIA DE GESTAO DE PROJETOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF1905', 'GESTAO PLANO NEGOCIOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1915', 'PROJETO FINAL I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('INF1920', 'ESTAGIO SUPERVISIONADO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF1950', 'PROJETO FINAL I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF1951', 'PROJETO FINAL II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2002', 'TRABALHO INDIVIDUAL EM ENGENHARIA DE SOFTWARE I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2003', 'TRAVALHO INDIVIDUAL EM ENGENHARIA DE SOFTWARE II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2004', 'TRABALHO INDIVIDUAL EM ENGENHARIA DE SOFTWARE III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2005', 'TOPICOS DE ENGENHARIA DE SOFTWARE I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2006', 'TOPICOS DE ENGENHARIA DE SOFTWARE II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2007', 'TOPICOS EM ENGENHARIA DE SOFTWARE III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2030', 'TOPICOS DE BANCO DE DADOS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2033', ' TOP TEORIA DA COMPUTACAO I ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2036', 'TRABALHO INDIVIDUAL EM TEORIA DA COMPUTACAO I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2037', 'TRABALHO INDIVIDUAL EM TEORIA DA COMPUTACAO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2038', 'TRABALHO INDIVIDUAL EM TEORIA DA COMPUTACAO III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2061', 'SEMINARIO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2062', 'TOPICOS DE COMPUTACAO GRAFICA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2063', 'TOPICOS DE COMPUTACAO GRAFICA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2064', 'TOPICOS DE COMPUTACAO GRAFICA III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2065', 'TRABALHO INDIVIDUAL EM COMPUTACAO GRAFICA I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2066', 'TRABALHO INDIVIDUAL EM COMPUTACAO GRAFICA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2067', 'TRABALHO INDIVIDUAL EM COMPUTACAO GRAFICA III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2079', 'PESQUISA DE TESE I EM BANCO DE DADOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2080', 'PESQUISA DE TESE II EM BANCO DE DADOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2081', 'PESQUISA DE TESE III EM BANCO DE DADOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2082', 'PESQUISA DE TESE IV EM BANCO DE DADOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2083', 'TRABALHO INDIVIDUAL EM BANCO DE DADOS I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2084', 'TRABALHO INDIVIDUAL EM BANCO DE DADOS II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2085', 'TRABALHO INDIVIDUAL EM BANCO DE DADOS III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2102', 'PROJETO FINAL DE PROGRAMACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2106', 'SISTEMAS DE COMPONENTES DE SOFTWARE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2125', 'PROJETO SISTEMAS DE SOFTWARE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2127', 'LINGUAGENS FORMAIS E AUTOMATOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2131', ' ENGENHARIA DE REQUISITOS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2134', 'TESTE E MEDICAO DE SOFTWARE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2135', 'PROCESSOS E AMBIENTES DE DESENVOLVIMENTO DE SOFTWA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2182', 'TRABALHO INDIVIDUAL EM LINGUAGENS E PROGRAMACAO IV', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2183', 'TRABALHO INDIVIDUAL EM LINGUAGENS E PROGRAMACAO V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2184', 'TRABALHO INDIVIDUAL EM LINGUAGENS E PROGRAMACAO VI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2190', 'TRABALHO INDIVIDUAL EM ENGENHARIA DE SOFTWARE IV', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2191', 'TRABALHO INDIVIDUAL EM ENGENHARIA DE SOFTWARE V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2192', 'TRABALHO INDIVIDUAL EM ENGENHARIA DE SOFTWARE VI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2193', 'PESQUISA DE TESE I EM ENGENHARIA DE SOFTWARE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2194', 'PESQUISA DE TESE II EM ENGENHARIA DE SOFTWARE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2195', 'PESQUISA DE TESE III EM ENGENHARIA DE SOFTWARE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2196', 'PESQUISA DE TESE IV EM ENGENHARIA DE SOFTWARE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2217', 'LOGICA E ESPECIFICACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2218', 'COMPUTABILIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2292', 'TRABALHO INDIVIDUAL EM TEORIA DA COMPUTACAO IV', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2293', 'TRABALHO INDIVIDUAL EM TEORIA DA COMPUTACAO V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2294', 'TRABALHO INDIVIDUAL EM TEORIA DA COMPUTACAO VI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2295', 'PESQUISA DE TESE I EM TEORIA DA COMPUTACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2296', 'PESQUISA DE TESE II EM TEORIA DA COMPUTACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2297', 'PESQUISA DE TESE III EM TEORIA DA COMPUTACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2298', 'PESQUISA DE TESE IV EM TEORIA DA COMPUTACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2328', 'TOPICOS EM TECNOLOGIAS DE BANCO DE DADOS P/ WEB SE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2390', ' TOPICOS DE BANCO DE DADOS IV ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2391', 'TOPICOS DE BANCO DE DADOS V', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2392', 'TRABALHO INDIVIDUAL EM BANCO DE DADOS IV', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2393', 'TRABALHO INDIVIDUAL EM BANCO DE DADOS V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2394', 'TRABALHO INDIVIDUAL EM BANCO DE DADOS VI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2541', 'INTRODUCAO A COMPUTACAO MOVEL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2542', 'ALGORITMOS DISTRIBUIDOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2556', 'SEMINARIOS EM SISTEMAS DISTRIBUIDOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2586', 'PESQUISA DE TESE I EM REDES DE COMPUTADORES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2587', 'PESQUISA DE TESE II EM REDES DE COMPUTADORES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2588', 'PESQUISA DE TESE III EM REDES DE COMPUTADORES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2589', 'PESQUISA DE TESE IV EM REDES DE COMPUTADORES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2592', 'TOPICOS DE REDES DE COMPUTADORES E SISTEMAS DISTRI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2595', 'TRAB IND EM REDES DE COMPUTADORES E SIST DISTRIBUI', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2596', 'TRAB IND EM REDES DE COMPUTADORES E SIST DISTRIBUI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2597', 'TRAB IND EM REDES DE COMPUTADORES E SIST DISTRIBUI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2598', 'TRAB IND EM REDES DE COMPUTADORES E SIST DISTRIBUI', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2599', 'TRAB IND EM REDES DE COMPUTADORES E SIST DISTRIBUI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2604', ' GEOMETRIA COMPUTACIONAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2607', 'ANIMACAO POR COMPUTADOR E JOGOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2608', 'FUNDAMENTOS DA COMPUTACAO GRAFICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2609', 'GAME AI: IA EM JOGOS 3D', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2610', 'RENDERING EM TEMPO REAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2686', 'PESQUISA DE TESE I EM COMPUTACAO GRAFICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2687', 'PESQUISA DE TESE II EM COMPUTACAO GRAFICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2688', 'PESQUISA DE TESE III EM COMPUTACAO GRAFICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2689', 'PESQUISA DE TESE IV EM COMPUTACAO GRAFICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2692', 'TRABALHO INDIVIDUAL EM COMPUTACAO GRAFICA IV', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2693', 'TRABALHO INDIVIDUAL EM COMPUTACAO GRAFICA V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2694', 'TRABALHO INDIVIDUAL EM COMPUTACAO GRAFICA VI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2705', ' LINGUISTICA COMP INTERATIVA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2706', 'INTRODUCAO A INTERACAO HUMANO-COMPUTADOR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2707', 'ENGENHARIA SEMIOTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2708', 'INTERFACES INTELIGENTES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2786', 'PESQUISA DE TESE I EM INTERACAO HUMANO-COMPUTADOR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2787', 'PESQUISA DE TESE II EM INTERACAO HUMANO-COMPUTADOR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2788', 'PESQUISA DE TESE III EM INTERACAO HUMANO-COMPUTADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2789', 'PESQUISA DE TESE IV EM INTERACAO HUMANO-COMPUTADOR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2792', 'TOPICOS EM INTERACAO HUMANO-COMPUTADOR III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2793', ' TOP INTER HUM-COMPUTADOR IV ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2794', 'TOPICOS EM INTERACAO HUMANO-COMPUTADOR V', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2795', 'TRABALHO INDIVIDUAL EM INTERACAO HUMANO-COMPUTADOR', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2796', 'TRABALHO INDIVIDUAL EM INTERACAO HUMANO-COMPUTADOR', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2797', 'TRABALHO INDIVIDUAL EM INTERACAO HUMANO-COMPUTADOR', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2798', 'TRABALHO INDIVIDUAL EM INTERACAO HUMANO-COMPUTADOR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2799', 'TRABALHO INDIVIDUAL EM INTERACAO HUMANO-COMPUTADOR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2801', 'FUNDAMENTOS DE SISTEMAS MULTIMIDIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2802', 'AUTORIA DE APLICACOES HIPERMIDIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2806', 'PESQUISA DE TESE I EM LINGUAGENS DE PROGRAMACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2807', 'PESQUISA DE TESE II EM LINGUAGENS DE PROGRAMACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2808', 'PESQUISA DE TESE III EM LINGUAGENS DE PROGRAMACAO.', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2809', 'PESQUISA DE TESE IV EM LINGUAGENS DE PROGRAMACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2811', 'TOPICOS EM LINGUAGENS E PROGRAMACAO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2813', 'TRABALHO INDIVIDUAL EM LINGUAGENS E PROGRAMACAO I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2814', 'TRABALHO INDIVIDUAL EM LINGUAGENS E PROGRAMACAO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2815', 'TRABALHO INDIVIDUAL EM LINGUAGENS E PROGRAMACAO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2886', 'PESQUISA DE TESE I EM HIPERTEXTO E MULTIMIDIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2887', 'PESQUISA DE TESE II EM HIPERTEXTO E MULTIMIDIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2888', 'PESQUISA DE TESE III EM HIPERTEXTO E MULTIMIDIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2889', 'PESQUISA DE TESE IV EM HIPERTEXTO E MULTIMIDIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2891', 'TOPICOS DE HIPERTEXTO E MULTIMIDIA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2893', 'TOPICOS DE HIPERTEXTO E MULTIMIDIA IV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2894', 'TOPICOS DE HIPERTEXTO E MULTIMIDIA V', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2895', 'TRABALHO INDIVIDUAL EM HIPERTEXTO E MULTIMIDIA I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2896', 'TRABALHO INDIVIDUAL EM HIPERTEXTO E MULTIMIDIA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2897', 'TRABALHO INDIVIDUAL EM HIPERTEXTO E MULTIMIDIA III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2898', 'TRABALHO INDIVIDUAL EM HIPERTEXTO E MULTIMIDIA IV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2899', 'TRABALHO INDIVIDUAL EM HIPERTEXTO E MULTIMIDIA V', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2912', 'OTIMIZACAO COMBINATORIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2915', 'TOPICOS DE ALGORITMOS, PARALELISMO E OTIMIZACAO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2916', 'TOPICOS DE ALGORITMOS, PARALELISMO E OTIMIZACAO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2920', 'TOPICOS DE ENGENHARIA DE SOFTWARE IV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2921', 'TOPICOS DE ENGENHARIA DE SOFTWARE V', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2922', ' TOP ENGENHARIA DE SOFTWARE VI ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2926', 'PROJETO E ANALISE DE ALGORITMOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('INF2979', 'TOPICOS DE OTIMIZACAO E RACIOCINIO AUTOMATICO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2981', 'TOPICOS DE OTIMIZACAO E RACIOCINIO AUTOMATICO IV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2983', 'TRABALHO INDIVIDUAL EM OTIMIZACAO E RACIOCINIO AUT', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2984', 'TRABALHO INDIVIDUAL EM OTIMIZACAO E RACIOCINIO AUT', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF2985', 'TRABALHO INDIVIDUAL EM OTIMIZACAO/RACIOCINIO AUTOM', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2986', 'PESQUISA DE TESE I EM OTIMIZACAO E RACIOCINIO AUTO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2987', 'PESQUISA DE TESE II EM OTIMIZACAO E RACIOCINIO AUT', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2988', 'PESQUISA DE TESE III EM OTIMIZACAO E RACIOCINIO AU', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2989', 'PESQUISA DE TESE IV EM OTIMIZACAO E RACIOCINIO AUT', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2991', 'TOPICOS DE ALGORITMOS, PARALELISMO E OTIMIZACAO V', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2992', 'TRAB INDIVIDUAL EM ALGORITMOS, PARALELISMO E OTIMI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF2993', 'TRAB INDIVIDUAL EM ALGORITMOS, PARALELISMO E OTIMI', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF2994', 'TRAB INDIVIDUAL EM ALGORITMOS, PARALELISMO E OTIMI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('INF3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('INF3002', 'REQUISITO BASICO DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('INF3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('INF3006', 'EXAME PROPOSTA DE DISSERTACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('INF3007', 'EXAME DE PROPOSTA DE TESE', 0, NULL);
INSERT INTO "Disciplina" VALUES ('INF3200', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('INF3201', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF3202', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF3203', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('INF3211', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF3212', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF3213', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('INF3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('INF3221', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('INF3222', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('INF3223', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI0301', 'OPT DE ESTUDOS DE AREA', 12, NULL);
INSERT INTO "Disciplina" VALUES ('IRI0302', 'OPT TEMAS EM REL INTERNACIONAI', 16, NULL);
INSERT INTO "Disciplina" VALUES ('IRI0303', 'OPT ESTUDOS AVANCADOS EM RELAC', 16, NULL);
INSERT INTO "Disciplina" VALUES ('IRI0304', 'OPT PRATICA PROFOSSIONAL 1 (OP', 8, NULL);
INSERT INTO "Disciplina" VALUES ('IRI0305', 'OPT PRATICA PROFOSSIONAL 2 (OP', 8, NULL);
INSERT INTO "Disciplina" VALUES ('IRI0306', 'OPT PRATICA PROFISSIONAL 3 (OP', 8, NULL);
INSERT INTO "Disciplina" VALUES ('IRI0311', 'OPT TEORIA RELACOES INTERNACIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI0313', 'OPT TEMAS DE RELACOES INTERNAC', 14, NULL);
INSERT INTO "Disciplina" VALUES ('IRI0314', 'OPT ESTUDOS DE AREA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI0315', 'OPT POLITICA EXTERNA DO BRASIL', 8, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1201', 'INTROD POLITICA INTERNACIONAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1501', 'FORMACAO DO SISTEMA INTERNACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1502', 'O SISTEMA INTERNACIONAL DO SECULO XX', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1503', 'TEORIA REL INTERNACIONAIS I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1504', 'TEORIA REL INTERNACIONAIS II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1505', 'TEORIA REL INTERNACIONAIS III', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1506', 'TEORIA REL INTERNACIONAIS IV', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1507', 'INTRODUCAO A POLITICA INTERNACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1509', 'ORGANIZACOES INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1510', 'PROBLEMAS DA GUERRA E DA PAZ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1511', 'A POLITICA E A ECONOMIA NAS RELACOES INTERNACIONAI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1512', 'A POLITICA E A ECONOMIA NAS RELACOES INTERNACIONAI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1513', 'ANALISE DE POLITICA EXTERNA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1514', ' PROCESSOS INTEGRACAO REGIONAL ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1515', 'SEGURANCA E RELACOES INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1450', 'DIREITO ELEITORAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1521', 'TEORIAS CLASSICAS DAS RELACOES INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1522', 'TEORIAS CONTEMPORANEAS DAS RELACOES INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1523', 'FUNDAMENTOS TEORICOS DAS RELACOES INTERNACIONAIS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1524', 'TEORIAS CONTEMPORANEAS DAS RELACOES INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1525', 'FUNDAMENTOS TEORICOS DAS RELACOES INTERNACIONAIS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1526', 'TECNICAS DE PESQUISA EM RELACOES INTERNACIONAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1527', 'METODOLOGIA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1528', 'METODOLOGIA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1601', 'GLOBALIZACAO, POLITICA E CULTURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1603', 'POL EXTERNA BRASILEIRA II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1608', 'POLITICA EXTERNA BRASILEIRA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1609', 'POLITICA EXTERNA BRASILEIRA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1630', 'MET TECN PESQ REL INTERNAC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1631', 'OS CONFLITOS INTERNACIONAIS CONTEMPORANEOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1632', 'COOPERACAO TECNICA INTERNACIONAL E DESENVOLVIMENTO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1633', 'REGIMES DE COMERCIO INTERNACIONAL E POLITICAS COME', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1636', 'INTERVENCOES HUMANITARIAS EM AREAS DE CONFLITO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1646', 'COOPERACAO INTERNACIONAL NAO-GOVERNAMENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1648', 'POLITICAS PUBLICAS E PROJETOS DE COOPERACAO INTERN', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1653', 'POLITICA COMERCIAL COMPARADA E NEGOCIACOES INTERNA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1654', 'COMERCIO INTERNACIONAL: FATORES DE COMPETITIVIDADE', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1655', 'INTERNACIONALIZACAO DA PRODUCAO E EMPRESAS TRANSNA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1658', 'TOPICOS ESPECIAIS EM COMERCIO INTERNACIONAL I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1703', 'GUERRA FRIA E ORDEM INTERCIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1712', 'GLOBALIZACAO FINANCEIRA E RELACOES INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1713', 'POLITICA EXTERNA DAS GRANDES POTENCIAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1726', ' INST/INTEGR SOC-POL/ECO AFRICA ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1727', 'INTRODUCAO A AJUDA HUMANITARIA INTERNACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1730', 'TERRORISMOS INTERNACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1731', ' QUEST ENERG/REL INTERNACIONAIS ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1732', 'IDENTIDADE E CULTURA NAS RELACOES INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1734', 'ATORES NAO-ESTATAIS NA POLITICA INTERNACIONAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1735', 'GENERO E RELACOES INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1737', 'CONFLITOS INTERNACIONAIS: ISRAEL X PALESTINA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1739', ' CONFLITOS INTER: GOLFO PERSICO ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1740', 'CONFLITOS INTERNACIONAIS: REGIAO DOS GRANDES LAGOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1745', 'INTRODUCAO AO ESTUDO DO DESENVOLVIMENTO INTERNACIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1746', 'INTRODUCAO AO COMERCIO INTERNACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1748', 'DIREITOS HUMANOS E POLITICA INTERNACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1749', 'MEIO AMBIENTE E RELACOES INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1750', 'O REGIME INTERNACIONAL DE REFUGIADOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1760', 'TOPICOS ESPECIAIS EM TEMAS DE RELACOES INTERNACION', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1778', ' TOP ESP REL INTERNACIONAIS IX ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1802', 'CONFLITO E POLITICA NO ORIENTE MEDIO E NA AFRICA D', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1804', 'REL INT RUSSIA/EUROPA DO LESTE DEPOIS DA GUERRA FR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1806', 'DEMOCRACIA, DESENVOLVIMENTO E SEGURANCA NA A LATIN', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1820', 'ESTADO, POLITICA E DESENVOLVIMENTO NA AFRICA SUBSA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1822', 'ESTADO, POLITICA E DESENVOLVIMENTO AMERICA CENTRAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1823', 'ESTADO, POLITICA E DESENVOLVIMENTO NA AMERICA LATI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1824', 'ESTADO, POLITICA E DESENVOLVIMENTO NA AMERICA DO N', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1828', ' QUES POL INT SUL/SUD ASIATICO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1829', 'QUESTOES DA POLITICA INTERNACIONAL DA EUROPA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1830', 'QUESTOES DA POLITICA INTERNACIONAL DA RUSSIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1831', 'QUESTOES DA POLITICA INTERNACIONAL DA CHINA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1832', 'QUESTOES DA POLITICA INTERNACIONAL NA AFRICA SUBSA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1834', 'DEMOCRACIA, DESENVOLVIMENTO E SEGURANCA NA AMERICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1836', 'QUESTOES DE POLITICA INTERNACIONAL DO ORIENTE MEDI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1837', 'TOPICOS ESPECIAIS EM ESTUDOS DE AREA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1838', 'TOPICOS ESPECIAIS EM ESTUDOS DE AREA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1844', 'TOPICOS ESPECIAIS EM ESTUDOS DE AREA VIII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1901', 'MONOGRAFIA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1902', 'MONOGRAFIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1921', 'SEMINARIO DE RELACOES INTERNACIONAIS I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1922', 'SEMINARIO DE RELACOES INTERNACIONAIS II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1923', 'SEMINARIO DE RELACOES INTERNACIONAIS III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1924', 'SEMINARIO DE RELACOES INTERNACIONAIS IV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1925', 'SEMINARIO DE RELACOES INTERNACIONAIS V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1926', 'SEMINARIO DE RELACOES INTERNACIONAIS VI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1927', 'SEMINARIO DE RELACOES INTERNACIONAIS VII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1928', 'SEM DE REL INTERNACIONAIS VIII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1952', 'GOVERNANCA GLOBAL E GOVERNAMENTALIDADE', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1957', 'ESTUDOS DO SESENVOLVIMENTO INTERNACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1958', 'ECONOMIA POLITICA DA GLOBALIZACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1959', 'O PROB JUST TEO REL INTERNAC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1960', 'AS NACOES UNIDAS E AJUDA HUMANITARIA INTERNACIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1961', 'ESTUDOS SOBRE OPERACOES DE PAZ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1963', 'TRANSFORMACOES DA PRATICA HUMANITARIA INTERNACIONA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1964', 'O BRASIL NOS FOROS MULTILATERAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1969', 'POLITICA ECONOMICA EXTERNA NORTE-AMERICANA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1979', 'PRIVATIZACAO DA SEGURANCA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1983', 'GENOCIDIO E POLITICA INTERNACIONAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1984', 'ESTUDOS AVANCADOS EM DIREITOS HUMANOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1985', 'TOP ESP ESTUDOS AVANCADOS I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('IRI1987', 'TOPICOS ESPECIAIS EM ESTUDOS AVANCADOS III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2400', 'HISTORIA DO SISTEMA INTERNACIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2401', 'TEORIA DAS RELACOES INTERNACIONAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2402', 'DESIGUALDADE NA POLITICA MUNDIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2403', 'METODOLOGIA DAS RELACOES INTERNACIONAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2404', 'GLOBALIZACAO DA POLITICA MUNDIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2405', 'AGENTES E ESTRUTURAS DO SISTEMA INTERNACIONAL MODE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2406', 'SEGURANCA E INSEGURANCA INTERNACIONAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2407', 'PERIFERIA E DESENVOLVIMENTO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2408', 'IMPERIO, HIERARQUIA, HEGEMONIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2409', 'ECONOMIA POLITICA INTERNACIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2411', ' COSMOPOLITICA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2417', 'COLONIALIDADE E POS-COLONIALISMO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2418', ' TOP ESP GLOB,GOV/DESENV I ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2422', ' ESTADO,SOBERANIA E MODERNIDADE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2423', 'GOVERNAMENTALIDADE, NORMALIZACAO E MULTILATERALISM', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2424', 'INSTITUICOES INTERNACIONAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2425', ' AGENT,ESTRUT/ACAO HUMNITARIAS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2426', 'ANALISE DE POLITICA EXTERNA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2427', 'POLITICA EXTERNA BRASILEIRA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2430', ' DEM,JUS/EXCL SIST INTENACIONAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2431', 'TOP ESP EM ARQUITETURA DO SISTEMA INTERNACIONAL I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2439', 'REGIMES GLOBAIS DE SEGURANCA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2441', 'INTERVENCOES HUMANITARIAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2442', 'OPERACOES DE MANUTENCAO DA PAZ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI2446', 'TOPICOS ESPECIAIS EM CONFLITO, VIOLENCIA E PACIFIC', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IRI3002', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IRI3005', 'EXAME DE QUALIFICACAO', 5, NULL);
INSERT INTO "Disciplina" VALUES ('IRI3100', 'TEORIA DAS RELACOES INTERNACIONAIS PARA DOUTORADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI3101', 'DESENHO DE PESQUISA EM RELACOES INTERNACIONAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI3102', 'SEMINARIO DE TESE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('IRI3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IRI3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IRI3230', 'ESTAGIO E DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('IRI9602', 'BRAZILIAN FOREING POLICY I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('IUE1003', ' INTEGR UNIVERSIDADE ESCOLA III ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0101', 'OPT INTRODUCAO AO DIREITO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0104', 'OPT DE MEDICINA LEGAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0109', 'OPT DE METODOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0110', 'OPT DE PRATICA FORENCE', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0120', 'OPT DE DIREITO COMERCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0130', 'OPT DE DIREITO PENAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0131', 'OPT DE DIREITO TRIBUTARIO', 8, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0140', 'OPT DE DIREITO CONSTITUCIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0150', 'OPT DIREITO PROCESSUAL CIVIL', 12, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0152', 'OPT DIREITO PROCESSUAL PENAL', 8, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0153', 'OPT DIREITO PROCES DO TRABALHO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0154', 'OPT DE DIREITO ADMINISTRATIVO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0160', 'OPT DE DIREITO INTERNACIONAL', 6, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0180', 'OPT DE DIREITO CIVIL', 12, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0190', 'OPT DE ESTAGIO SUPERVISIONADO', 20, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0200', 'OPT DEPARTAMENTO DE DIREITO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0400', 'DISCIPLINAS DAS ENFASES', 48, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0410', 'OPTATIVAS ESTADO E SOCIEDADE', 8, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0420', 'OPTATIVAS DE CONTENCIOSO', 8, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0430', 'OPTATIVAS DE EMPRESARIAL', 8, NULL);
INSERT INTO "Disciplina" VALUES ('JUR0440', 'OPTATIVAS DE PENAL', 8, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1001', 'INTR A CIENCIA DO DIREITO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1002', 'INTR A CIENCIA DO DIREITO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1003', 'HISTORIA DO DIREITO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1004', 'DIREITO ROMANO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1005', 'FILOSOFIA DO DIREITO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1007', 'SOCIOLOGIA JURIDICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1008', 'INSTITUICOES DO DIREITO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1016', 'LEGISLACAO SOCIAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1018', 'INST DO DIREITO(PARA ADM)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1022', 'NOCOES DE DIREITO PARA EMPREENDEDORES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1023', 'DIREITO E LEGISLACAO SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1024', 'DIREITO NAS RELACOES INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1028', 'DIREITO COMERCIAL E TRIBUTARIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1029', 'DIREITO, PSICOLOGIA E SUBJETIVIDADE', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1031', 'INTRODUCAO AO DIREITO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1032', 'INTRODUCAO AO DIREITO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1033', 'TEORIA DO DIREITO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1035', 'FILOSOFIA DO DIREITO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1036', 'METODOLOGIA DA PESQUISA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1037', 'SOCIOLOGIA DO DIREITO E DA ADMINISTRACAO DA JUSTIC', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1040', 'DIREITO COMPARADO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1050', 'LOGICA E ARGUMENTACAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1051', 'ANTROPOLOGIA DO DIREITO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1101', 'DIREITO PENAL I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1103', 'DIREITO PENAL III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1104', 'MEDICINA LEGAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1111', 'DIREITO AMBIENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1112', 'DIREITO DA CRIANCA E DO ADOLESCENTE', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1114', 'DIREITO PENAL IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1131', 'DIREITO PENAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1132', 'DIREITO PENAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1140', 'DIREITO AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1141', 'DIREITO PENAL ECONOMICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1142', 'MEDICINA LEGAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1143', 'DIR PENAL III-DIREITO PENAL DO HOMEM,DA VIDA E DA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1144', 'DIREITO PENAL IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1145', 'CRIMINOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1146', 'DIREITO DA EXECUCAO PENAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1152', 'DIREITO PENAL COMPLEMENTAR', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1201', 'DIREITO COMERCIAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1202', 'DIREITO COMERCIAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1203', 'DIREITO COMERCIAL III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1204', 'DIREITO COMERCIAL IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1210', 'MERCADO DE CAPITAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1231', 'TEORIA DA EMPRESA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1232', 'DIREITO SOCIETARIO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1233', 'TITULOS DE CREDITO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1234', 'FALENCIA E RECUPERACAO DE EMPRESAS I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1240', 'NEGOCIAC,MEDIACAO/ARBITRAGEM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1241', 'CONTRATOS EMPRESARIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1242', 'DIREITO SOCIETARIO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1301', 'DIR FINANCEIRO E TRIBUTARIO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1302', 'DIR FINANCEIRO E TRIBUTARIO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1306', 'LEGISLACAO TRIBUTARIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1330', 'LEGISLACAO AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1331', 'DIREITO TRIBUTARIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1340', 'PROCESSO TRIBUTARIO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1341', 'TRIBUTOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1400', 'DIREITO CONSTITUCIONAL I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1402', 'DIREITO CONSTITUCIONAL II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1404', 'DIREITO ADMINISTRATIVO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1412', 'DIREITO ADMINISTRATIVO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1423', 'DIREITO CONSTITUCIONAL III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1430', 'TEORIA DO ESTADO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1431', 'DIREITO CONSTITUCIONAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1432', 'DIREITO CONSTITUCIONAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1433', 'DIREITO CONSTITUCIONAL III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1434', 'DIREITO ADMINISTRATIVO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1440', 'JURISDICAO CONSTITUCIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1441', 'DIREITOS HUMANOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1442', 'PROCESSO ADMINISTRATIVO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1443', 'PROCESSO/TECNICA LEGISTATIVOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1444', 'DIREITO URBANISTICO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1445', 'PAPEL DO ESTADO NO DOMINIO ECONOMICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1501', 'DIREITO JUDICIARIO CIVIL I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1520', 'DIREITO PROCESSUAL CIVIL I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1521', 'DIREITO PROCESSUAL CIVIL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1522', 'DIREITO PROCESSUAL CIVIL III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1523', 'DIREITO PROCESSUAL CIVIL IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1526', 'DIREITO PROCESSUAL PENAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1527', 'DIREITO PROCESSUAL PENAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1530', 'TEORIA GERAL DO PROCESSO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1531', 'DIREITO PROCESSUAL CIVIL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1532', 'DIREITO PROCESSUAL CIVIL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1533', 'DIREITO PROCESSUAL CIVIL III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1534', 'DIREITO PROCESSUAL DO TRABALHO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1535', 'DIREITO PROCESSUAL DO TRABALHO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1536', 'DIREITO PROCESSUAL PENAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1540', 'ACOES COLETIVAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1541', 'PROCEDIMENTOS ESPECIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1542', 'DIREITO PROCESSUAL PENAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1601', 'DIR INTERNACIONAL PUBLICO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1602', 'DIR INTERNACIONAL PUBLICO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1603', 'DIREITO INTERNACIONAL PRIVADO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1631', 'DIREITO INTERNACIONAL PUBLICO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1632', 'DIREITO INTERNACIONAL PUBLICO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1633', 'DIREITO INTERNACIONAL PRIVADO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1640', 'DIR DAS ORGAN INTERNACIONAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1641', 'DIREITO INTERNACIONAL PENAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1701', 'DIREITO DO TRABALHO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1702', 'DIREITO DO TRABALHO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1714', 'DIREITO PROCESSUAL DO TRABALHO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1731', 'DIREITO DO TRABALHO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1732', 'DIREITO DO TRABALHO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1740', 'O TRABALHO NA EMPRESA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1801', 'DIREITO CIVIL I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1802', 'DIREITO CIVIL II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1803', 'DIREITO CIVIL III', 99, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1804', 'DIREITO CIVIL IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1805', 'DIREITO CIVIL V', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1806', 'DIREITO CIVIL VI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1807', 'DIREITO CIVIL VII', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1809', 'DIREITO DO AUTOR', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1818', 'DIREITO CIVIL VIII', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1830', 'TEORIA DO DIREITO PRIVADO', 6, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1831', 'TEORIA DAS OBRIGACOES E DOS CONTRATOS I', 6, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1832', 'TEORIA DAS OBRIGACOES E DOS CONTRATOS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1833', 'RESPONSABILIDADE CIVIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1834', 'DIREITO DO CONSUMIDOR', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1835', 'DIREITO DAS COISAS E DAS ACOES POSSESSORIAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1836', 'DIREITO DE FAMILIA E PROCEDIMENTOS CORRELATOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1837', 'DIREITO DAS SUCESSOES E PROCEDIMENTOS CORRELATOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1840', 'PROPRIEDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1901', 'ESTAGIO SUPERVISIONADO I', 5, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1902', 'ESTAGIO SUPERVISIONADO II', 5, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1903', 'ESTAGIO SUPERVISIONADO III', 5, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1904', 'ESTAGIO SUPERVISIONADO IV', 5, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1910', 'PRAT FORENSE E ORG JUDICIARIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1915', 'MONOGRAFIA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1916', 'MONOGRAFIA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1918', 'METODOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1919', 'MONOGRAFIA', 6, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1922', 'TOPICOS ESPECIAIS EM DIREITO III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1923', 'TOPICOS ESPECIAIS EM DIREITO IV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1925', 'TOPICOS ESPECIAIS EM DIREITO VI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1926', 'TOPICOS ESPECIAIS EM DIREITO VII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1932', ' TOP ESP EM DIREITO XIII ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1934', 'TOPICOS ESPECIAIS EM DIREITO XV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1938', 'TOPICOS ESPECIAIS EM DIREITO XIX', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1939', ' TOP ESP EM DIREITO XX ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1940', 'TOPICOS ESPECIAIS EM DIREITO XXI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1941', 'TOPICOS ESPECIAIS EM DIREITO XXII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1942', 'TOPICOS ESPECIAIS EM DIREITO XXIII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1943', 'TOPICOS ESPECIAIS EM DIREITO XXIV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1947', 'TOPICOS ESPECIAIS EM DIREITO XXVIII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1949', ' TOP ESP EM DIREITO XXX ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1953', 'TOPICOS ESPECIAIS EM DIREITO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1954', 'TOPICOS ESPECIAIS EM DIREITO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1956', ' TOP ESPECIAIS DIREITO XXXVII ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1957', 'TOPICOS ESPECIAIS EM DIREITO XXXVIII', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1958', ' TOP ESPECIAIS DIREITO XXXIX ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1959', 'TOPICOS ESPECIAIS EM DIREITO XL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1961', 'ESTAGIO SUPERVISIONADO I', 6, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1962', 'ESTAGIO SUPERVISIONADO II', 6, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1963', 'ESTAGIO SUPERVISIONADO III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR1964', 'ESTAGIO SUPERVISIONADO IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2500', 'ESPISTEMOLOGIA DO DIREITO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2502', 'TEORIA DA CONSTITUICAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2503', 'TEORIA GERAL DO DIREITO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2507', 'SEMINAR METODOL E DISSERTACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2510', 'DIREITOS E GARANTIAS INDIVIDUAIS E COLETIVAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2512', 'TEORIA POLITICA MODERNA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2529', ' TOP ESP DIREITO CONSTITUCIONAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2530', 'TOPICOS ESPECIAIS EM DIREITO CONSTITUCIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2531', 'TOPICOS ESPECIAIS EM DIREITO CONSTITUCIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2532', 'TOPICOS ESPECIAIS EM DIREITOS HUMANOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2533', 'TOPICOS ESPECIAIS EM DIREITOS HUMANOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2534', 'TOPICOS ESPECIAIS EM DIREITOS HUMANOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2535', 'TOPICOS ESPECIAIS EM DIREITOS HUMANOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2536', 'TOPICOS ESPECIAIS EM DIREITOS HUMANOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2544', ' TOP ESP FILOSOFIA POLITICA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2545', 'TEORIA CONSTITUCIONAL CONTEMPORANEA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2546', 'ETICA,DIREITOS HUMANOS E PRINCIPIOS CONSTITUCIONAI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2547', 'TEORIA DA DEMOCRACIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2548', 'SEMINARIO DE PESQUISA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2555', 'SOCIOLOGIA JURIDICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2560', 'TOPICOS ESPECIAIS EM DIREITO CONSTITUCIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2561', 'TOPICOS ESPECIAIS EM DIREITO CONSTITUCIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2562', 'TOPICOS ESPECIAIS EM DIREITO CONSTITUCIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2564', 'TOPICOS ESPECIAIS EM DIREITO CONSTITUCIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2568', 'TOPICOS ESPECIAIS EM DIREITOS HUMANOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2569', ' TOP ESP DIREITOS HUMANOS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2570', ' TOP ESP DIREITOS HUMANOS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2574', 'TOPICOS ESPECIAIS EM TEORIA POLITICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2575', 'TOPICOS ESPECIAIS EM TEORIA POLITICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2576', 'TOPICOS ESPECIAIS EM TEORIA POLITICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR2578', 'TOPICOS ESPECIAIS EM FILOSOFIA POLITICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('JUR3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('JUR3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('JUR3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('JUR3200', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('JUR3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('JUR3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET0010', 'OPT LING ESTRANGEIRA-FILOSOFIA', 16, NULL);
INSERT INTO "Disciplina" VALUES ('LET0160', 'OPT EM LITERATURA/CULTURA PORT', 12, NULL);
INSERT INTO "Disciplina" VALUES ('LET0161', 'OPT EM LINGUA INGLESA ORAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET0162', 'OPT EM LETRAS CLASSICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET0163', 'OPT EM ESTUDOS DE LITERATURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET0166', 'OPTATIVA EM LITERATURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET0167', 'OPTATIVA EM PROD TEXT POETICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET0168', 'OPTATIVA EM PROD TEXT DRAMATIC', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET0169', 'OPTATIVA EM PROD TEXTUAL (P/FO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET0173', 'OPTATIVA EM PRODUCAO DE TEXTO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET0174', 'OPTATIVA EM TRADUCAO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('LET0191', 'OPTATIVAS DE LETRAS PARA CDI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET0300', 'OPTATIVAS DE LETRAS P/ CIENCIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET0310', 'OPT DE LETRAS P/ CCP', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1008', 'GRAMATICA DO PORTUGUES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1011', 'PORTUGUES TECNICO I - PARA INFORMATICA E TPD', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1040', 'COMUNICACAO E EXPRESSAO HUMANAS - O DISCURSO EMPRE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1059', 'PORTUGUES TECNICO II - INF', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1090', 'COM EXPRESSAO I (PARA COM SOC)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1091', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1092', 'COM E EXPRESSAO III(P/COM SOC)', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1113', 'INGLES INSTRUMENTAL: LEITURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1117', 'GRAMATICA DE LINGUA INGLESA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1139', 'LINGUA INGLESA : CURSOS MONOGRAFICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1208', 'FRANCES 1', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1209', 'FRANCES 2', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1228', 'FRANCES : LINGUA, CULTURA E CIVILIZACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1230', 'FRANCES 3', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1280', 'PORTUGUES PARA ESTRANGEIROS I', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1281', 'PORTUGUES PARA ESTRANGEIROS II', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1282', 'PORTUGUES PARA ESTRANGEIROS III', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1285', 'PORTUGUES PARA ESTRANGEIROS IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1286', 'PORTUGUES PARA ESTRANGEIROS V', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1287', 'PORTUGUES INSTRUMENTAL PARA ESTRANGEIROS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1290', 'INGLES 4', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1291', 'INGLES 5', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1292', 'INGLES 6', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1294', 'INGLES 1', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1295', 'INGLES 2', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1296', 'INGLES 3', 6, NULL);
INSERT INTO "Disciplina" VALUES ('LET1301', 'ESPANHOL 1', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1302', 'ESPANHOL 2', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1311', 'ESPANHOL COMERCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1330', 'TEX CIENT P/BIO:LEIT PRODUCAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('LET1353', 'ESPANHOL(NIVEL AVANCADO)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1404', 'PRODUCAO DO TEXTO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1405', 'PRODUCAO DO TEXTO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1407', 'INTRODUCAO A LINGUISTICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1408', 'PORTUGUES PADRAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1409', 'FONOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1410', 'ESTRUTURAS LEXICAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1411', 'SINTAXE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1412', 'LINGUA E COGNICAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1413', 'DISCURSO, SOCIEDADE E INTERACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1414', 'TEORIAS DO SIGNIFICADO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1416', 'TOPICOS EM LINGUISTICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1420', 'FORMACAO DO LEITOR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1422', 'TEORIA DA LITERATURA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1423', 'TEORIA DA LITERATURA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1424', 'LITERATURA E CULTURA BRASILEIRAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1425', 'LITERATURA BRASILEIRA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1426', 'LITERATURA BRASILEIRA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1427', 'LITERATURA BRASILEIRA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1428', 'O CANONE OCIDENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1429', 'LITERATURA E INTERFACES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1430', 'TOPICOS EM LITERATURA BRASILEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1433', 'TOPICOS EM TEORIA DA LITERATURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1440', 'LITERATURA PORTUGUESA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1441', 'LITERATURA PORTUGUESA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1442', 'LITERATURA PORTUGUESA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1443', 'CULTURA E LITERATURAS PORTUGUESAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1444', 'TOPICOS EM LITERATURA PORTUGUESA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1447', 'LITERATURAS AFRICANAS EM LINGUA PORTUGUESA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1450', 'LINGUA INGLESA: TEXTO E LEITURA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1451', 'LINGUA INGLESA: TEXTO E LEITURA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1452', 'LINGUA INGLESA: ASPECTOS MORFOSSINTATICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1454', 'LINGUA INGLESA: DISCURSO ORAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1455', 'LINGUA INGLESA: OFICINA ORAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1456', 'LI: OFIC PROD ESCRIT/GRAMATICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1457', 'LINGUA INGLESA: DISCURSO ESCRITO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1458', 'LINGUA INGLESA: DISCURSO ESCRITO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1459', 'LINGUA INGLESA: ANALISE TEXTUAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1460', 'LING INGL:OFICINA LITERARIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1461', 'LINGUA INGLESA: CULTURA BRITANICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1462', 'LING INGL:CULTURA AMERICANA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1463', 'LITERATURA BRITANICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1464', 'LITERATURA AMERICANA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1465', 'LINGUA INGLESA: FONOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1467', 'TOPICOS EM LINGUA INGLESA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1470', 'LINGUA LATINA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1472', 'CULTURA GRECO-LATINA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1474', 'IMAGENS, MITOS E LITERATURA MODERNA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1475', 'OFICINA DE TEATRO ANTIGO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1476', 'GREGO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1479', 'TOPICOS EM LETRAS CLASSICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1480', 'LGTCA APLICADA:LINGUA MATERNA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1481', 'AQUISICAO E PROCESSAMENTO DA LINGUAGEM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1482', 'OFICINA I: INTERACAO E ENSINO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1486', 'OFICINA III - PESQUISA: ENSINO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1487', 'OFICINA IV - PESQUISA: LINGUA PORTUGUESA/LINGUISTI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1488', 'OFICINA V - PESQUISA: LITERATURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1489', 'LINGUISTICA APLICADA: LINGUA ESTRANGEIRA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1493', 'OFICINA II:CRIACAO MAT ENSINO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1501', 'ALEMAO 1', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1502', 'ALEMAO 2', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1521', 'ALEMAO 3', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1522', 'ALEMAO 4', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1525', 'ALEMAO V', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1545', 'OFICINA DE PRODUCAO DE TEXTO NARRATIVO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1546', 'OFICINA DE PRODUCAO DE TEXTO POETICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1547', 'OFICINA DE PRODUCAO DE TEXTO DRAMATICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1548', 'OFICINA DE PRODUCAO DE TEXTO TECNICO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1550', 'OF PROD TEXT ACAD/ENSAISTICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1551', 'PROJETO DE AUTORIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1554', 'OFICINA DE PRODUCAO TEXTUAL AVANCADA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1570', 'INTRODUCAO A TRADUCAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1571', 'TRADUCAO TECNICO-CIENTIFICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1572', 'TRADUCAO DE FICCAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1573', 'TEORIAS DE TRADUCAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1576', 'TRADUCAO PARA LEGENDAGEM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1581', 'ESTAGIO SUPERVISIONADO DE TRADUCAO I', 5, NULL);
INSERT INTO "Disciplina" VALUES ('LET1582', 'ESTAGIO SUPERVISIONADO DE TRADUCAO II', 5, NULL);
INSERT INTO "Disciplina" VALUES ('LET1606', 'MITOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1612', 'MITOLOGIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1613', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1614', 'LATIM II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1616', 'LATIM IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1710', ' EST SUPERV ENSINO:PORTUGUES I ', 5, NULL);
INSERT INTO "Disciplina" VALUES ('LET1712', ' EST SUP ENS BILINGUE I ', 5, NULL);
INSERT INTO "Disciplina" VALUES ('LET1714', ' EST SUP ENS: BILINGUE III ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('LET1716', ' EST SUPERV ENSINO: INGLES II ', 5, NULL);
INSERT INTO "Disciplina" VALUES ('LET1717', ' EST SUPERV ENSINO:INGLES III ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('LET1797', 'TECNICAS DE COMUNICACAO PARA EMPREENDEDORES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1800', ' ELABORACAO DE TEXTO ESCRITO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1801', 'LINGUA BRASILEIRA DE SINAIS I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('LET1803', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1804', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1805', ' PRODUCAO DE TEXTO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1806', 'FONOLOGIA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1807', 'ESTRUTURAS LEXICAIS PORTUGUES', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1808', 'SINTAXE', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1830', ' LINGUAGEM E SENTIDO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1831', ' AQUISICAO PROC DA LINGUAGEM ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1832', ' LINGUAGEM E SOCIEDADE ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1836', ' TOP EST DA LINGUAGEM I ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1840', ' ESTUDOS DE LITERATURA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1841', ' PRATICAS DE LEITURA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1842', ' LITERATURA E CULTURA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1843', ' CANONES EM LINGUA PORTUGUESA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1847', ' LITERATURA E NACIONALIDADE ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1848', ' TEORIAS DE LITERATURA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1855', ' LITERATURA E OUTRAS ARTES ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1856', ' LITERATURA E MODERNIDADE ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1866', ' LITERATURA E CONTEMPORANEIDADE ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1868', ' TOP EM LITERATURA PORTUGUESA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1870', 'LINGUA CHINESA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1871', 'LINGUA CHINESA II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1872', 'LINGUA CHINESA III', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1877', ' TOP EM ESTUDOS LITERATURA I ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1880', 'INTRODUCAO A CULTURA CHINESA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1881', ' LINGUA LATINA I ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1883', ' CULTURA GRECO-LATINA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1884', ' IMAGENS,MITOS LITERAT MODERNA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1886', ' GREGO II ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1889', ' MITOLOGIA II ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1893', ' OFIC TEATRO ANTIGO: O TRAGICO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1895', ' REALISMOS NA LITERATURA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1896', ' O FATO E A FICCAO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1900', 'LING INGL:TEXTO E CONTEXTO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1901', ' LING INGL:TEXTO E CONTEXTO II ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1903', ' LING INGLESA:DISCURSO ESCRITO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1908', ' LING INGL:OFICINA PRODUC ORAL ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1910', 'ANAL E PROD DO TEXTO ACAD', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1912', 'LINGUIS APLIC LING ESTRANGEIRA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1914', ' LIT/CULT BRIT:OBRAS FUNDADORAS ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1916', ' LIT/CULT NOR-AMER:MOD/CONTEMP ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1918', ' LINGUA INGLESA: GRAMATICA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1919', ' LINGUA INGLESA: CONVERSAO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1920', 'COMPREENSAO E PRODUCAO DO TEXTO TECNICO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('LET1921', 'INTRODUCAO A TRADUCAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1922', 'TRADUCAO TECNICO-CIENTIFICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1924', 'TRADUCAO DE FICCAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1926', 'TECNOLOGIAS DA TRADUCAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1927', 'TRADUCAO AUDIOVISUAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1931', 'TRADUCAO JURAMENTADA-JURIDICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1932', 'VERSAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1933', ' TOPICOS EM TRADUCAO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1938', 'ESTAG SUPERV DE TRADUCAO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1939', 'ESTAG SUPERV DE TRADUCAO II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('LET1940', 'OFICINA DE LEITURA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('LET1941', ' OF 1-INT ENS SAL AULA LING MAT ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1944', ' OFIC 4-PES/ENS:LING ORAL ESCR ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1950', 'DISCURSO ARGUMENTATIVO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('LET1960', ' OFICINA DE TEXTO NARRATIVO I ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1979', ' OFICINA TEXTO INFANTO-JUVENIL ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1984', ' OFICINA DE BIOGRAFIA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET1988', ' PROJETO DE AUTORIA I ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('LET1995', 'INTRODUCAO AO LATIM FORENSE', 2, NULL);
INSERT INTO "Disciplina" VALUES ('LET1999', 'INICIACAO A PESQUISA (PARA ALUNOS DE CONVENIO)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('LET2215', 'EVOLUCAO DO PENSAMENTO LINGUISTICO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2216', 'LINGUISTICA CONTEMPORANEA - PRINCIPAIS CORRENTES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2229', 'TEORIA SINTATICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2242', ' TOP LINGUA DISCURSO SOCIEDADE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2243', 'TOPICOS EM LINGUISTICA/AREAS AFINS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2297', 'PESQUISA SUPERVISIONADA PARA O MESTRADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2298', 'PESQUISA SUPERVISIONADA PARA O DOUTORADO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2299', 'PESQUISA SUPERVISIONADA PARA O DOUTORADO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2303', 'ESTUDO ORIENTADO : PROJETO DE DISSERTACAO DE MESTR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2304', 'ESTUDO ORIENTADO : PROJETO DE TESE DE DOUTORADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2370', 'TOPICOS EM ESTUDOS DA LINGUAGEM I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('LET2371', ' TOP ESTUDOS DA LINGUAGEM II ', 1, NULL);
INSERT INTO "Disciplina" VALUES ('LET2372', 'TOPICOS EM ESTUDOS DA LINGUAGEM III', 1, NULL);
INSERT INTO "Disciplina" VALUES ('LET2376', ' GENEROS DISCURSIVOS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2400', 'CONSTRUCOES LEXICAIS DO PORTUGUES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2401', 'INTRODUCAO PORTUGUES COMO SEGUNDA LINGUA PARA ESTR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2403', 'INTRODUCAO A PSICOLINGUISTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2404', 'AQUISICAO DA LINGUAGEM', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2407', 'CULTURA/SUJEITO CONST SENTIDO:TRADUCAO COMO CAMPO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2408', ' INTROD A LINGUISTICA APLICADA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2410', 'INTRODUCAO A SOCIOLINGUISTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2412', 'TEORIAS DO SIGNIFICADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2413', 'AQUISICAO DA SEGUNDA LINGUA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2414', ' FUND LINGUISTICA COMPUTACIONAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2415', ' A PRODUCAO DA LINGUAGEM ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2417', 'AQUISICAO LINGUAGEM/PROBLEMAS DO DESENVOLVIMENTO L', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2418', 'TEORIAS DE INTERPRETACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2419', ' TEORIAS DA TRADUCAO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2420', 'PRAGMATICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2421', 'LINGUISTICA SISTEMICO-FUNCIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2422', 'LINGUAGEM E INTERACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2423', 'TRABALHO DE FACE E DA GESTAO DE RELACOES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2424', ' DISCURSO E IDENTIDADE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2428', ' ASP CULT PORT SEGUNDA LINGUA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2436', 'LINGUAGEM, SENTIDO E PSICANALISE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2440', 'DISCURSO EM CONTEXTOS PEDAGOGICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2442', 'QUESTOES TEORICO-METODOLOGICAS PESQUISA ESTUDOS LI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2447', 'TOPICOS EM ESTUDOS DO SENTIDO E DA TRADUCAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2448', 'PESQUISA SUPERVISIONADA PARA O MESTRADO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('LET2449', 'PESQUISA SUPERVISIONADA PARA O DOUTORADO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('LET2450', 'SEMINARIO DE PESQUISA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2500', 'TEORIAS DA LITERATURA E DA CULTURA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2501', 'SEMINARIO DE FORMULACAO PROJETO E DESENVOLVIMENTO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2502', 'SEMINARIO DE DISSERTACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2503', ' PROJETO INDIVIDUAL ESTUDOS I ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2504', ' SEMINARIOS AVANCADOS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2505', 'SEMINARIO DE FORMULACAO PROJETO/DESENVOLVIMENTO PE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2506', ' SEMINARIO DE TESE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2509', ' IMAG/EXPER DA LITERATURA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2511', 'DIMENSOES CONTEMPORANEAS DO ESTETICO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2512', 'HISTORIAS DE LITERATURA: TEORIA E EXPERIMENTOS ATU', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2513', ' MODERNIDADES E MODERNISMOS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2514', 'A ESCRITA DE HISTORIA E MEMORIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2517', 'ESTETICA, ETICA E POLITICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2522', 'TOPICOS AVANCADOS EM TEORIAS E CRITICAS CONTEMPORA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2523', 'TOPICOS AVANCADOS EM TEORIAS E CRITICAS CONTEMPORA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2524', 'TOPICOS AVANCADOS EM TEORIAS E CRITICAS CONTEMPORA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2525', ' NOVOS SUPORTES DA ESCRITA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2526', 'A "ESCRITA DE SI" NA COMUNICACAO LITERARIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2527', ' OS LIMITES DO LITERARIO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2528', 'ESCRITA ARTISTICA E PRODUCAO DE PENSAMENTO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2529', ' ESCRITA/CULTURA CONTEMPORANEA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2530', 'TEORIAS E PRATICAS ARTISTICAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2532', 'ESTUDOS DE POESIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2533', ' ESTUDOS DA NARRATIVA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2534', 'TOPICOS EM TEORIAS DO TEXTO E DA ESCRITA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2536', 'TOPICOS EM CRITICA E INTERPRETACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2537', 'TEXTO, CONTEXTO E INTERTEXTO NA LITERATURA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2538', ' LIT/POL: PERF INT DO ESCRITOR ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2539', 'REALISMO, REALISMOS: MATRIZES E TRANSFORMACOES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2540', 'VANGUARDAS POETICAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2543', 'REPRESENTACOES DA AFRICANIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2545', 'LITERATURA E EXPERIENCIA URBANA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2547', ' LITERATURA CONTEMPORANEA I ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2550', 'CONTEMPORANIEDADE E CRITICA CULTURAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2551', 'TOPICOS EM LITERATURA PORTUGUESA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET2552', 'TOPICOS EM LITERATURA BRASILEIRA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('LET3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3010', 'DISSERTACAO DE MESTRADO (ESTUDOS DA LINGUAGEM)', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3011', 'DISSERTACAO MESTRADO(LITERATURA,CULTURA E CONTEMPO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3015', 'EXAME DE QUALIFICACAO - DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3020', 'TESE DE DOUTORADO (ESTUDOS DA LINGUAGEM)', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3021', 'TESE DE DOUTORADO (LITERATURA, CULTURA E CONTEMPOR', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3030', ' PESQ ORIENTADA-MESTRADO I ', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3031', ' PESQ ORIENTADA-MESTRADO II ', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3032', ' PESQ ORIENTADA-DOUTORADO I ', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3101', 'EXAME DE PROFICIENCIA EM LINGUA ESTRANGEIRA-INGLES', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3102', 'EXAME DE PROFICIENCIA EM LINGUA ESTRANGEIRA-FRANCE', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3106', 'EXAME DE PROFICIENCIA EM LINGUA ESTRANGEIRA:INGLES', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3200', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3201', ' ESTAGIO DOC ORIENTADO I - M ', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3202', ' ESTAGIO DOC ORIENTADO I - D ', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('LET9419', 'SPECIAL TOPICS IN PORTUGUESE LANGUAGE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1003', 'INTRODUCAO AO CALCULO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1004', 'CALCULO DE UMA VARIAVEL A', 5, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1005', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1006', 'ESTUDO ORIENTADO EM INTRODUCAO AO CALCULO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1010', 'SEMINARIO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1020', 'SEMINARIO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1040', 'INICIACAO A PESQUISA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1041', 'INICIACAO A PESQUISA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1045', 'PROJETO FINAL DE GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1050', 'TOPICOS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1051', 'TOPICOS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1052', ' TOPICOS III ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1053', ' TOPICOS IV ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1071', 'MATEMATICA DO ESPACO E DAS FORMAS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1072', 'CALCULO NA ARQUITETURA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1082', 'LOGICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1106', 'CALCULO II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1107', 'CALCULO III', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1108', 'CALCULO IV', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1112', 'MATEMATICA II(PARA ECONOMIA)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1116', 'CALCULO ESPECIAL II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1117', 'CALCULO ESPECIAL III', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1118', 'CALCULO ESPECIAL IV', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1127', 'MATEMATICA APLICADA PARA ADMINISTRACAO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1128', 'MATEMATICA APLICADA PARA ADMINISTRACAO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1129', 'MATEMATICA APLICADA PARA MATEMATICA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1134', 'MATEMATICA PARA COMPUTACAO III', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1135', 'CALCULO PARA INFORMATICA I', 5, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1136', 'CALCULO PARA INFORMATICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1151', 'CALCULO DE UMA VARIAVEL', 5, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1152', 'CALC DIF DE VARIAS VARIAVEIS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1153', 'CALC INTEG DE VARIAS VARIAVEIS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1154', 'EQUACOES DIFERENCIAIS E DE DIFERENCAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1157', 'CALCULO A UMA VARIAVEL A', 6, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1158', 'CALCULO A UMA VARIAVEL B', 6, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1161', 'CALCULO DE UMA VARIAVEL', 6, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1162', 'CALCULO A VARIAS VARIAVEIS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1163', 'CALCULO A VARIAS VARIAVEIS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1171', 'CALC DE UMA VARIAVEL - ESP', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1172', 'CALC DIF VARIAS VARIAVEIS-ESP', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1173', 'CALC INTEG VARIAS VARIAV-ESP', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1174', 'EQUAC DIF E DE DIFERENCAS-ESP', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1181', 'CALCULO UMA VARIAVEL-ESPECIAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1182', 'CALCULO A VARIAS VARIAVEIS I ESPECIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1183', 'CAL A VARIAS VARIAVEIS II ESP', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1200', 'ALGEBRA LINEAR I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1202', 'ALGEBRA LINEAR II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1210', 'ALGEBRA LINEAR PARA INFORMATICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1215', 'ALGEBRA LINEAR(PARA ECO)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1220', 'ALGEBRA I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1223', 'ESPACOS VETORIAIS E TRANSFORMACOES LINEARES', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1224', 'ESTRUTURAS ALGEBRICAS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1225', 'ESTRUTURAS ALGEBRICAS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1231', 'ALGEBRA LINEAR NUMERICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1303', 'ELEMENTOS MATEMATICOS DE COMPUTACAO GRAFICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1310', 'MATEMATICA DISCRETA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1406', 'METODOS NUMERICOS EM EQUACOES DIFERENCIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1410', 'INTRODUCAO A PROBABILIDADE', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1411', 'INTRODUCAO AS EQUACOES DIFERENCIAIS PARCIAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1413', 'INTRODUCAO A PROBABILIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1510', 'INTRODUCAO AS FUNCOES DE VARIAVEL COMPLEXA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1604', 'INTRODUCAO A ANALISE', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1605', 'INTRODUCAO A ANALISE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1606', 'ANALISE REAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1610', 'ANALISE I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1612', 'ANALISE NO RN', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1702', 'INTRODUCAO A TOPOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1811', 'GEOMETRIA DIFERENCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT1901', 'EQUACOES DIFERENCIAIS ORDINARIAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2001', 'ESTUDO ORIENTADO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2002', 'ESTUDO ORIENTADO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2003', 'ESTUDO ORIENTADO III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2004', 'ESTUDO ORIENTADO IV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2012', 'SEMINARIO DE MESTRADO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2013', 'SEMINARIO DE MESTRADO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2021', 'SEMINARIO DE DOUTORADO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2022', 'SEMINARIO DE DOUTORADO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2023', 'SEMINARIO DE DOUTORADO III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2024', 'SEMINARIO DE DOUTORADO IV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2082', 'TOPICOS DE LOGICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2102', 'CALCULO AVANCADO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2200', 'ALGEBRA LINEAR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2220', 'ESTRUTURAS ALGEBRICAS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2221', 'ESTRUTURAS ALGEBRICAS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2229', 'ALGEBRA LINEAR COMPUTACIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2302', 'TEORIA MATEMATICA DE PROBABILIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2410', 'TOP DE MATEMAT APLICADA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2411', 'TOP DE MATEMAT APLICADA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2412', 'TOP DE MATEMAT APLICADA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2413', 'TOP DE MATEMAT APLICADA IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2421', 'TOP DE FISICA MATEMATICA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2422', 'TOP DE FISICA MATEMATICA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2423', 'TOP DE FISICA MATEMATICA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2424', 'TOP DE FISICA MATEMATICA IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2442', 'MODELAGEM GEOMETRICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2447', 'COMPUTACAO CIENTIFICA E EQUACOES DIFERENCIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2449', 'MATEMATICA PARA INDUSTRIA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2450', 'MATEMATICA PARA INDUSTRIA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2502', 'VARIAVEL COMPLEXA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2610', 'TOPICOS DE ANALISE I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2611', 'TOPICOS DE ANALISE II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2612', 'TOPICOS DE ANALISE III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2613', 'TOPICOS DE ANALISE IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2620', 'ANALISE REAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2621', ' MEDIDA E INTEGRACAO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2622', 'ANALISE FUNCIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2624', 'ANALISE NO ESPACO RN', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2712', ' TOPOLOGIA ALGEBRICA I ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2714', 'INTRODUCAO A TOPOLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2810', 'TOPICOS DE GEOMETRIA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2812', 'GEOMETRIA DIFERENCIAL EM R3', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2821', 'VARIEDADES DIFERENCIAVEIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2826', 'GEOMETRIA RIEMANNIANA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2827', ' SUPERFICIES DE RIEMANN ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2905', 'EQUACOES DIFERENCIAIS ORDINARIAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT2907', 'EQUACOES DIFERENCIAIS PARCIAIS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MAT3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MAT3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MAT3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MAT3202', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT3204', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MAT3205', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MAT3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MAT3212', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MAT3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MAT3222', ' ESTAGIO DOCENCIA NA GRADUACAO ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1005', 'PROJETO DE GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1140', 'ESTATICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1166', 'MODELAGEM SISTEMAS DINAMICOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1200', 'MECANICA DOS SOLIDOS I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1202', 'MECANICA DOS SOLIDOS II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1210', 'COMPORT MECANICO DOS MATERIAIS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1214', 'ELEMENTOS DE MAQUINAS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1301', 'TERMODINAMICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1315', 'FENOMENOS DE TRANSPORTE', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1320', 'MECANICA DOS FLUIDOS I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1325', 'TRANSMISSAO DE CALOR I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1340', 'TRANSMISSAO DE CALOR', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1400', 'DESENHO TECNICO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1401', 'DESENHO MECANICO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1701', 'METODOS NUMERICOS EM ENG MEC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1801', 'INTROD A ECO DO PETROLEO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC1825', 'PERFURACAO E COMPLETACAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2001', 'SEMINARIO DE DOUTORADO I', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2002', 'SEMINARIO DE DOUTORADO II', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2009', 'TOP ESP DE ENGENHARIA MECANICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2010', ' TOP ESP DE ENGENHARIA MECANICA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2011', ' TOP ESP DE ENGENHARIA MECANICA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2018', 'TOPICOS ESPECIAIS EM ENGENHARIA MECANICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2021', 'TOPICOS ESPECIAIS EM ENGENHARIA MECANICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2031', 'SEMINARIO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2110', 'METOD MATEMAT EM ENG MECANICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2111', 'METODOS MATEMATICOS EM ENGENHARIA MECANICA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2120', 'ELEM FINITOS NA ENG MECANICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2222', ' ANALISE DE VIBRACOES ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2231', 'MECANICA DA FRATURA E FADIGA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2233', 'COMPORTAMENTO MECANICO DOS MATERIAIS AVANCADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2240', 'TEORIA DA ELASTICIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2245', 'ANALISE EXPERIMENT DE TENSOES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2303', 'TERMODINAMICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2310', 'METOD EXPERIMENT TERMOCIENCIAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2335', 'DINAMICA FLUIDOS COMPUTACIONAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2338', 'MECANICA DE FLUIDOS NAO NEWTONIANOS AVANCADOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2343', 'ENERGIA SOLAR', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2344', 'MECANICA DOS FLUIDOS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2345', 'MECANICA DOS FLUIDOS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2346', 'ESCOAMENTO MULTIFASICO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2347', 'TRANSFERENCIA DE CALOR I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2348', 'TRANSFERENCIA DE CALOR II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2349', 'CONTROLE DE POLUICAO ATMOSFERICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2350', 'ELEMENTOS FINITOS EM FLUIDOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2351', 'FUNDAMENTOS DA POLUICAO ATMOSFERICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2352', 'MECANICA DE FLUIDOS NAO NEWTONIANOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2353', 'SIMULACAO DE SISTEMAS DE REFRIGERACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2355', ' TURBULENCIA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2357', 'MOTORES DE COMBUSTAO INTERNA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2362', ' MODELAGEM DE SOLIDOS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2364', 'DINAMICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2367', 'INTEGRIDADE ESTRUTURAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2373', 'ESCOAMENTO EM DUTOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2374', 'PROJETO MECANICO DE DUTOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2376', 'FLUIDOS NAO NEWTONIANOS NA INDUSTRIA DO PETROLEO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2377', 'ESCOAMENTO EM MEIOS POROSOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2380', 'COMPLETACAO DE POCOS DE PETROLEO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2381', 'PERFURACAO DE POCOS DE PETROLEO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2384', 'ENGENHARIA DE RESERVATORIOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2385', 'ENGENHARIA DE PRODUCAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2386', 'SISTEMAS DE ENERGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2387', 'SISTEMAS DE PRODUCAO OFFSHORE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2388', 'FUNDAMENTOS DA COMBUSTAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2401', 'INTRODUCAO A ROBOTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2402', 'CONTROLE DE SISTEMAS ROBOTICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2501', ' ESTUDO ORIENTADO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2502', ' ESTUDO ORIENTADO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC2961', 'SENSORES A FIBRA OTICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MEC3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MEC3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MEC3003', 'PROPOSTA DE DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MEC3005', 'EXAME DE QUALIFICACAO I', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MEC3201', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('MEC3211', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('MEC3221', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('MED1330', 'SAUDE E MEIO AMBIENTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('MET1801', 'INTRODUCAO A ENG DE MATERIAIS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MET1802', 'TERMODINAMICA DOS MATERIAIS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MET1811', 'CINETICA DAS REACOES E PROCESS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MET1813', 'TECNOLOGIA MINERAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MET1818', 'TRANSFERENCIA DE CALOR', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MET1831', 'CIENCIA E ENGENHARIA MATERIAIS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MET1848', 'MECANICA DOS CORPOS SOLIDOS', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MET1851', 'FONTES CONT POL INDUSTRIAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('MET2800', 'SEMINARIO DE PESQUISA', 1, NULL);
INSERT INTO "Disciplina" VALUES ('MET2803', 'ESTUDO ORIENTADO EM ENGENHARIA DE MATERIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2804', 'FUNDAMENTOS DE TERMODINAMICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2805', 'FUNDAMENTOS DA ENGENHARIA DE MATERIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2806', 'FUNDAMENTOS DE ENGENHARIA DE MICROESTRUTURAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2807', 'FUNDAMENTOS MATEMATICOS PARA ENGENHARIA DE MATERIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2808', 'TERMODINAMICA DOS MATERIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2809', 'DIAGRAMAS DE FASES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2810', 'FENOMENOS DE TRANSPORTE EM ENGENHARIA DE MATERIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2813', 'PROCESSAMENTO DIGITAL DE IMAGENS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2814', 'MICROSCOPIA QUANTITATIVA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2831', 'TEORIA DE DEFEITOS EM SOLIDOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2833', 'TRANSFORMACAO DE FASE NO ESTADO SOLIDO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2835', 'FRATURA DE MATERIAIS ESTRUTURAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2837', 'INTEGRIDADE ESTRUTURAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2838', 'MATERIAIS CERAMICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2839', 'MATERIAIS POLIMETRICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2840', ' MATERIAIS COMPOSITOS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2841', 'SOLDAGEM E JUNCAO DE MATERIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2856', 'TOPICOS ESPECIAIS EM CIENCIA DOS MATERIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2857', ' TOP ESP EM CIENCIA MATERIAIS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2858', 'TOPICOS ESPECIAIS EM CIENCIA DOS MATERIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2859', 'TOPICOS ESPECIAIS EM CIENCIA DOS MATERIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2860', 'FLUIDODINAMICA APLICADA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2861', 'TRATAMENTO DE MINERIOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2862', 'CINETICA E ENGENHARIA DE REATORES', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2863', 'HIDROMETALURGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2865', 'PIROMETALURGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2868', 'OPERACOES UNITARIAS DA TECNOLOGIA AMBIENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2869', 'TRATAMENTO DE EFLUENTES INDUSTRIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2890', 'TOPICOS ESPECIAIS EM METALURGIA EXTRATIVA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2891', 'TOPICOS ESPECIAIS EM METALURGIA EXTRATIVA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2892', 'TOPICOS ESPECIAIS EM METALURGIA EXTRATIVA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2897', 'TOPICOS ESPECIAIS EM ENGENHARIA AMBIENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2898', ' TOP ESP EM ENG AMBIENTAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET2899', 'TOPICOS ESPECIAIS EM ENGENHARIA AMBIENTAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MET3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MET3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MET3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MET3007', 'PROPOSTA DE TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MET3201', 'ESTAGIO DOCENCIA NA GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('MET3202', 'ESTAGIO DOCENCIA NA GRADUACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('MET3203', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2000', 'SEMINARIO EM METROLOGIA', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2001', 'FUNDAMENTOS DA METROLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2002', 'FUNDAMENTOS DA TECNOLOGIA INDUSTRIAL BASICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2003', 'ESTATISTICA PARA METROLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2004', ' METODOLOGIA DA PESQUISA ', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2005', 'COMUNICACAO CIENTIFICA', 0, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2101', 'INCERTEZA DE MEDICAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2102', 'TOPICOS AVANCADOS EM INCERTEZA DE MEDICAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2103', 'SENSORES E INSTRUMENTACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2104', 'PROCESSAMENTO E ANALISE DE SINAIS DE DIGITAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2105', 'GESTAO ESTRATEGICA DA INOVACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2106', 'METROLOGIA PARA O DESENVOLVIMENTO SUSTENTAVEL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2108', 'INTRODUCAO AS REDES INTELIGENTES DE ENERGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2202', 'METROLOGIA PARA O SETOR DA SAUDE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2203', 'METROLOGIA DO CORACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2205', ' MEDICAO BIOELETROMAGNETICA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2206', ' BIOMETROLOGIA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2305', 'MEDICAO DE TEMPERATURA, PRESSAO E VAZAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2401', ' EFICIENCIA ENERGETICA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2604', ' AVAL/INDICAD SUSTENTABILIDADE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2701', ' TOP AVANC INCERTEZA DE MEDICAO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2801', ' ESTUDO ORIENTADO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2952', 'TOPICOS ESPECIAIS EM METROLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2957', 'TOPICOS ESPECIAIS EM METROLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2958', 'TOPICOS ESPECIAIS EM METROLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI2959', 'TOPICOS ESPECIAIS EM METROLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('MQI3000', 'DISSERTACAO DE MESTRADO EM METROLOGIA', 0, NULL);
INSERT INTO "Disciplina" VALUES ('NBH0121', 'OPT SOCIOL/HIS-NUCL BAS CTCH', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PMA2013', ' GEOMETRIA I ', 8, NULL);
INSERT INTO "Disciplina" VALUES ('PMA2014', ' ARITMETICA I ', 8, NULL);
INSERT INTO "Disciplina" VALUES ('PSI0108', 'OPT PROC PSICOLOGICOS BASICOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI0109', 'OPT PSICOLOGIA DESENVOLVIMENTO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI0110', 'OPT PSICOLOGIA SOCIAL', 8, NULL);
INSERT INTO "Disciplina" VALUES ('PSI0112', 'OPT PSICOPATOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI0113', 'OPT PSICODIAGNOSTICO', 8, NULL);
INSERT INTO "Disciplina" VALUES ('PSI0204', 'OPT PSI SOCIAL (P/SERVICO SOC)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1010', 'COTIDIANO DIGITAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1011', 'MIDIAS INTERATIVAS E SUBJETIVIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1016', 'METAPSICOLOGIA FREUDIANA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1017', 'PSICANALISE INGLESA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1018', 'PSICANALISE FRANCESA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1020', 'FUNDAMENTOS EM NEUROCIENCIAS', 8, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1023', 'TOPICOS EM NEUROCIENCIAS III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1024', 'AVALIACAO PSICOLOGICA', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1031', 'TOPICOS EM PSICOPATOLOGIA IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1033', 'PSI APLICADA A ADMINISTRACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1043', 'PSICOLOGIA HOSPITALAR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1130', 'PSICOLOGIA E PERCEPCAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1210', 'PSICOLOGIA DA PERSONALIDADE I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1223', 'PSIC DO DESENVOLVIMENTO I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1250', 'PSICOLOGIA SOCIAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1451', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1600', 'METODO CIENTIFICO EM PSI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1601', 'PESQUISA III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1602', 'PESQUISA IV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1604', 'FUNDAMENTOS METODOLOGICOS DE ELABORACAO DE MONOGRA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1800', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1801', 'ENF PSICAN SUBJ-FREUD', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1806', 'TOPICOS EM GENEALOGIA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1810', 'TOPICOS EM GENEALOGIA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1811', ' TOPICOS EM GENEALOGIA III ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1812', 'GENEAL PROBLEMAT PSICOLOGICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1813', 'HISTORIA DA PSICOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1814', 'TOP EM GENEALOGIA IV', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1815', 'PSICOLOGIA ANALITICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1817', 'HISTORIA DA PSICOLOGIA', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1820', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1824', 'NEUROPSICOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1828', 'BIO-NEURO-PSICOLOGIA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1830', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1831', 'METODOS QUANTITATIVOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1832', 'TOPICOS EM METODO CIENTIFICO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1833', 'ESTATISTICA APLICADA A PSICOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1835', 'PESQUISA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1836', 'PESQUISA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1839', 'METODOS QUALITATIVOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1840', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1842', 'CRIATIVIDADE', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1847', 'TOPICOS EM PROCESSOS PSICOLOGICOS BASICOS III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1848', 'PROCESSOS PSICOLOGICOS BASICOS', 8, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1849', 'CIENCIA COGNITIVA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1850', 'PSICOLOGIA E DESENVOLVIMENTO', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1851', 'MODOS DE SUBJETIVACAO NA INFANCIA E NA ADOLESCENCI', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1852', 'INFANCIA, ADOLESCENCIA E SOCIEDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1855', 'TOPICOS EM PSICOLOGIA E DESENVOLVIMENTO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1857', 'TOP PSI E DESENVOLVIMENTO II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1858', 'TOPICOS EM PSICOLOGIA E DESENVOLVIMENTO III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1860', 'PSICOPATOLOGIA', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1861', 'TOPICOS EM PSICOPATOLOGIA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1862', 'ABORDAGEM PSICOLOGICA DOS QUADROS CLINICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1864', 'TOPICOS EM PSICOPATOLOGIA II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1867', 'PSICOFARMACOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1868', 'TOXICOMANIAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1869', 'ABORDAGEM PSIQUIATRICA DOS QUADROS CLINICOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1870', 'PSICOLOGIA SOCIAL', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1871', 'DINAMICA DE GRUPO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1875', ' TOPICOS EM PSI SOCIAL I ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1876', 'DINAMICA DE GRUPO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1877', 'TOPICOS EM PSICOLOGIA SOCIAL III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1878', 'TOPICOS EM PSICOLOGIA SOCIAL IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1879', 'TOPICOS EM PSICOLOGIA SOCIAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1880', 'PSICOLOGIA E ESPORTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1881', 'PROCESSOS GRUPAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1898', 'LINGUAGEM E SUBJETIVIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1899', 'LINGUAGEM E COGNICAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1900', 'PSICOLOGIA E INSTITUICOES', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1901', 'PSICOLOGIA E JUSTICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1902', 'PSICOLOGIA E COMUNIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1903', 'PSICOLOGIA E SAUDE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1904', 'INSTITUICOES E PRATICAS SOCIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1905', 'TOPICOS EM PSICOLOGIA E INSTITUICOES I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1907', ' TOP EM PSI E INSTITUICOES II ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1908', 'TOPICOS EM PSICOLOGIA E INSTITUICOES III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1909', 'TOPICOS EM PSICOLOGIA E INSTITUICOES IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1910', 'TEORIA PSICANALITICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1913', 'TOPICOS EM TEORIA PSICANALITICA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1914', 'TOPICOS EM TEORIA PSICANALITICA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1916', 'TOPICOS EM TEORIA PSICANALITICA IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1917', 'TOPICOS EM TEORIA PSICANALITICA V', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1920', 'PSICODIAGNOSTICO', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1923', 'TESTES DE INTELIGENCIA, APTIDAO E INTERESSE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1924', 'LAUDO DE AVALIACAO PSICOLOGICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1925', ' TOP EM PSICODIAGNOSTICO I ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1927', 'TOPICOS EM PSICODIAGNOSTICO III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1928', 'TOPICOS EM PSICODIAGNOSTICO IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1929', 'TOPICOS EM PSICODIAGNOSTICO V', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1930', 'PSICOTERAPIAS', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1932', 'PSICOTERAPIA FENOMENOLOGICA-EXISTENCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1933', 'PSICOTERAPIA COGNITIVO COMPORTAMENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1935', 'PSICOTERAPIAS CORPORAIS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1936', 'PSICOTERAPIA BREVE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1937', 'PSICOTERAPIA FAMILIA CASAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1941', 'PSICOTERAPIA DE GRUPO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1942', 'TOPICOS EM PSICOTERAPIAS I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1943', 'TOPICOS EM PSICOTERAPIAS II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1944', 'TOPICOS EM PSICOTERAPIAS III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1946', 'GESTALT-TERAPIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1947', 'ASSEDIO MORAL E SAUDE DO TRABALHADOR', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1950', 'PSICOLOGIA, TRABALHO E ORGANIZACOES', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1952', 'ORIENTACAO PROFISSIONAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1953', 'TREINAMENTO E DESENVOLVIMENTO DE RECURSOS HUMANOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1957', 'TOPICOS EM PSICOLOGIA, TRABALHO E ORGANIZACOES III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1958', 'ATITUDE E COMPORTAMENTO EMPREENDEDOR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1960', 'PSICOLOGIA E EDUCACAO', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1968', 'PSICOLOGIA E EDUCACAO INCLUSIVA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1970', 'MONOGRAFIA I', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1971', 'MONOGRAFIA II', 6, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1972', 'MONITORIA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1973', 'MONITORIA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1974', 'MONITORIA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1975', 'MONITORIA IV', 2, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1980', 'ESTAGIO A', 12, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1981', 'ESTAGIO BASICO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1982', 'ESTAGIO BASICO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1983', 'ESTAGIO BASICO III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1984', 'ESTAGIO BASICO IV', 4, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1985', 'ESTAGIO V', 10, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1986', 'ESTAGIO VI', 10, NULL);
INSERT INTO "Disciplina" VALUES ('PSI1990', 'ESTAGIO B', 12, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2001', 'TEMAS EM PSICANALISE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2002', ' TEMAS EM PSICANALISE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2004', 'TEMAS EM PSICANALISE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2006', 'TEMAS EM LINGUAGEM E SUBJETIVIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2008', ' TEMAS LINGUAGEM SUBJETIVIDADE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2009', 'TEMAS EM LINGUAGEM E SUBJETIVIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2010', ' TEMAS LINGUAGEM SUBJETIVIDADE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2018', 'TEMAS EM FAMILIA E CASAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2019', 'TEMAS EM FAMILIA E CASAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2020', 'TEMAS EM FAMILIA E CASAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2022', 'TEMAS EM PSICANALISE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2023', 'TEMAS EM PSICANALISE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2024', 'TEMAS EM PSICANALISE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2025', ' TEMAS EM PSICANALISE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2026', 'TEMAS EM LINGUAGEM E SUBJETIVIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2027', ' TEMAS LINGUAGEM SUBJETIVIDADE ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2028', 'TEMAS EM LINGUAGEM E SUBJETIVIDADE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2057', ' TEMAS EM FAMILIA E CASAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2060', 'TEMAS EM FAMILIA E CASAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2073', 'TEMAS EM CLINICA E NEUROCIENCIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2074', 'TEMAS EM CLINICA E NEUROCIENCIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2075', ' TEMAS CLINICA E NEUROCIENCIA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2076', ' TEMAS CLINICA E NEUROCIENCIA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2079', 'TEMAS EM CLINICA E NEUROCIENCIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2080', 'TEMAS EM CLINICA E NEUROCIENCIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2105', 'ANALISE DE DISCURSO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2120', 'ESTUDO INDIVIDUAL PARA MESTRADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2121', 'ESTUDO INDIVIDUAL PARA DOUTORADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2601', 'METODOS DE PESQUISA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2602', 'SEMINARIO DE DISSERTACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2603', 'ESTUDO E PESQUISA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2604', 'ESTUDO E PESQUISA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2701', 'SEMINARIO DE DOUTORADO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI2702', 'SEMINARIO DE DOUTORADO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3002', 'EXAME PROJETO DE DISSERTACAO', 99, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3203', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3213', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3223', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3224', 'ESTAGIO DE DOCENCIA NA GRADUACAO IV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3225', 'ESTAGIO DE DOCENCIA NA GRADUACAO V', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3226', 'ESTAGIO DE DOCENCIA NA GRADUACAO VI', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3227', 'ESTAGIO DE DOCENCIA NA GRADUACAO VII', 3, NULL);
INSERT INTO "Disciplina" VALUES ('PSI3228', 'ESTAGIO DE DOCENCIA NA GRADUACAO VIII', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI0200', 'OPTATIVAS DE QUIMICA', 12, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1103', 'QUIMICA GERAL PARA BIOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1111', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1243', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1330', 'BIOQUIMICA PARA BIOLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1701', 'LAB DE QUIMICA GERAL', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1703', 'QUIMICA INORGANICA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1705', 'QUIMICA INORGANICA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1706', 'LAB DE QUIMICA INORGANICA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1709', 'LABORATORIO DE QUIMICA GERAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1712', 'LABORATORIO DE QUIMICA INORGANICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1720', 'QUIMICA GERAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1721', 'QUIMICA ANALITICA A', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1722', 'LABORATORIO DE QUIMICA ANALITICA A', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1723', 'QUIMICA ANALITICA B', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1724', 'LABORATORIO DE QUIMICA ANALITICA B', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1725', 'QUIMICA ANALITICA QUALITATIVA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1727', 'QUIMICA ANALITICA QUANTITAT I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1735', 'QUIMICA ANALITICA C', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1736', 'LAB DE QUIMICA ANALITICA C', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1737', 'QUIMIOMETRIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1738', 'OPERACOES UNITARIAS P/ QUIMICA', 5, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1742', 'LAB DE FISICO-QUIMICA B', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1745', 'QUIMICA INORGANICA III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1750', 'QUIMICA ORGANICA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1751', 'QUIMICA ORGANICA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1753', 'QUIMICA ORGANICA III', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1754', 'LAB SINTESE E ANAL ORGAN II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1755', 'LABORATORIO DE QUIMICA ORGANICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1768', 'BIOQUIMICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1769', 'LABORATORIO DE BIOQUIMICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1786', 'FISICO-QUIMICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1787', 'LABORATORIO DE FISICO-QUIMICA A', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1788', 'FISICO-QUIMICA A', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1789', 'FISICO-QUIMICA B', 6, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1797', 'QUIMICA AMBIENTAL I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1798', 'QUIMICA PARA ENGENHARIA AMBIENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1800', 'INTROD ENGENHARIA QUIMICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1801', 'METOD NUMER PARA ENG QUIMICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1802', 'TERMODINAMICA PARA ENG QUIMICA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1803', 'MEC DOS FLUIDOS PARA ENG QUI', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1804', 'MICROBIOLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1805', 'CINETICA E CALCULO DE REATORES', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1810', 'MATERIAIS DA INDUSTRIA QUIMICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1811', 'OPERACOES UNITARIAS I', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1812', 'OPERACOES UNITARIAS II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1817', 'TRANSFERENCIA DE CALOR', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1818', 'TRANSFERENCIA DE MASSA', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1819', 'PROCESSOS QUI INORGANICOS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1820', 'PROCESSOS QUI ORGANICOS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1821', 'PROCESSOS BIOQUIMICOS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1822', 'OPERACOES UNITARIAS A', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1823', 'OPERACOES UNITARIAS B', 99, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1826', 'PROJETO DE GRADUACAO', 1, NULL);
INSERT INTO "Disciplina" VALUES ('QUI1845', 'TRABALHO ORIENTADO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2051', 'PESQ DE TESE DE DOUTORADO I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2052', 'PESQ DE TESE DE DOUTORADO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2224', 'QUIMICA ANALITICA AVANCADA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2412', 'QUIMICA INORGANICA AVANCADA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2432', 'CATALISE HETEROGENEA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2433', 'FISICO-QUIMICA AVANCADA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2523', 'LABORATORIO DE QUIMICA AVANCADA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2527', ' METODOS ESPECTROMETRICOS II ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2529', ' RADIOQUIMICA APLICADA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2530', ' QUIMICA AMBIENTAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2531', ' QUIMICA ATMOSFERICA ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2614', 'TOP ESP DE QUIMICA INORGANICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2621', 'METODOS ESPECTROSCOPICOS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2622', 'METODOS ESPECTROSCOPICOS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2632', 'TOP ESP DE FISICO-QUIMICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2635', 'TOP ESP DE FISICO-QUIMICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2643', ' TOP ESP DE QUIMICA ORGANICA ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2644', 'TOP ESP DE QUIMICA ORGANICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2647', 'QUIMICA ORGANICA AVANCADA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2685', 'QUIMICA OCEANOGRAFICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2690', 'BIOINORGANICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2721', 'LAB METOD ESPECTROSCOPICOS I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2722', 'LAB METOD ESPECTROSCOPICOS II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2741', ' LAB MET ESPECTROMETRICOS II ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2880', 'SEMINARIO I', 1, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2881', 'SEMINARIO II', 1, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2882', ' SEMINARIO III ', 0, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2950', 'METROLOGIA EM QUIMICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2990', 'ESTAGIO SUPERVISIONADO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI2991', 'ESTAGIO SUPERVISIONADO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('QUI3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('QUI3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('QUI3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('QUI3203', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI3213', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('QUI3223', 'ESTAGIO DOCENCIA NA GRADUACAO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER1153', 'HISTORIA DO SERVICO SOCIAL I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1154', 'HISTORIA DO SERVICO SOCIAL II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1158', 'INTRODUCAO TEORICO-METODOLOGICA DO SERVICO SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1159', 'TEORIA DO SERVICO SOCIAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1164', 'PESQUISA EM SERVICO SOCIAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1176', 'METODOLOGIA DO SER SOCIAL I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1177', 'TEORIA DO SERVICO SOCIAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1178', 'METODOLOGIA DO SERVICO SOCIAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1179', 'TEORIA DO SERVICO SOCIAL III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1184', 'ADMINISTRACAO EM SER SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1185', 'POLITICA SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1186', 'PLANEJAMENTO SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1188', 'DESENVOLVIMENTO DE COMUNIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1205', 'METODOLOGIA DO SER SOCIAL III', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1206', 'SER SOCIAL-SEMINARIO SINTESE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1207', 'PESQUISA EM SERVICO SOCIAL II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SER1208', 'ANALISE DO PROCESSO METOD I', 6, NULL);
INSERT INTO "Disciplina" VALUES ('SER1209', 'ANALISE DO PROCESSO METODOLOGICO II', 6, NULL);
INSERT INTO "Disciplina" VALUES ('SER1210', 'ANALISE DO PROCESSO METOD III', 6, NULL);
INSERT INTO "Disciplina" VALUES ('SER1211', 'ANALISE DO PROCESSO METODOLOGIA IV', 6, NULL);
INSERT INTO "Disciplina" VALUES ('SER1212', 'ESTAGIO SUPERVISIONADO I', 6, NULL);
INSERT INTO "Disciplina" VALUES ('SER1213', 'ESTAGIO SUPERVISIONADO II', 6, NULL);
INSERT INTO "Disciplina" VALUES ('SER1214', 'ORIENT TRAB CONCLUSAO CURSO I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1215', 'ORIENTACAO DO TRABALHO DE CONCLUSAO DE CURSO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1220', 'INTRODUCAO AO SERVICO SOCIAL I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1221', 'INTRODUCAO AO SERVICO SOCIAL II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1222', 'SEMINARIO DE CONTEUDO VARIAVEL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1223', 'SEMINARIO DE CONTEUDO VARIAVEL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1224', 'SEMINARIO CONTEUDO VARIAVEL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1225', 'SEMINARIO CONTEUDO VARIAVEL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1226', 'SEMINARIO DE CONTEUDO VARIAVEL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER1227', 'SEMINARIO DE CONTEUDO VARIAVEL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SER2008', 'SERVICO SOCIAL E QUESTAO SOCIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2127', 'ATIVIDADES PROGRAMADAS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2128', 'ATIVIDADES PROGRAMADAS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2601', 'QUESTAO SOCIAL, SERVICO SOCIAL E DIREITOS SOCIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2602', 'ESTADO, SOCIEDADE E ACAO DO SERVICO SOCIAL NA ESFE', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2604', 'VIOLENCIA, CIDADANIA E SERVICO SOCIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2622', 'ESTUDOS AVANCADOS EM PESQUISA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2626', 'METODOLOGIA DA PESQUISA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2627', 'TOPICOS ESPECIAIS DE TEORIA SOCIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2632', 'POLITICAS ASSISTENCIAIS: HISTORIA E CONTEXTO ATUAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2635', 'FORMAS DE REISTENCIA SOCIAL E POLITICAS PUBLICAS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2636', 'SUJEITOS COLETIVOS, CIDADANIA E PROC DEMOCRATICOS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2691', 'SEMINARIO DE DOUTORADO II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER2692', 'SEMINARIO DE PROJETO DE TESE', 0, NULL);
INSERT INTO "Disciplina" VALUES ('SER2694', 'POLITICA SOCIAL, DIREITOS E SERVICO SOCIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SER3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('SER3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('SER3003', 'DEFESA DE PROJETO DE TESE', 0, NULL);
INSERT INTO "Disciplina" VALUES ('SER3200', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('SER3211', 'ESTAGIO DOCENCIA NA GRADUACAO I', 0, NULL);
INSERT INTO "Disciplina" VALUES ('SER3212', 'ESTAGIO DOCENCIA NA GRADUACAO II', 0, NULL);
INSERT INTO "Disciplina" VALUES ('SOC0201', 'OPT SOCIOLOGIA-NUCL BAS CCS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC0202', 'OPT POLITICA-NUCL BAS CCS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC0203', 'OPT ANTROPOLOGIA-NUCL BAS CCS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SOC0205', 'OPT SOCIOLOGIA-NUC BAS CCS-GEO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC0206', 'OPT SOCIOL-NUC BAS CCS-COM SOC', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC0208', 'OPT SOC PARA CIEN SOC', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC0209', 'OPT CIEN POL PARA CIEN SOC', 8, NULL);
INSERT INTO "Disciplina" VALUES ('SOC0210', 'OPT ANTROP PARA CIEN SOC', 8, NULL);
INSERT INTO "Disciplina" VALUES ('SOC0211', 'OPT CIEN SOC BAC-LIC', 8, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1101', 'AVENTURA SOCIOLOGICA (SOCIOLOGIA I)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1102', 'SOCIOLOGIA II-ESTR E MUD SOC', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1103', 'DUAS VISOES DA MODERNIDADE DO SEC XIX: MARX E WEBE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1104', 'LIBERDADE E ORDEM SOCIAL: TOCQUEVILLE E DURKHEIM', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1106', ' SOCIOLOGIA ALEMA ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1109', 'PENSAMENTO SOCIOLOGICO BRASILEIRO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1114', 'SOCIOLOGIA DA ARTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1120', 'SOCIOLOGIA URBANA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1123', 'MARGINALIDADE SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1125', 'SOCIOLOGIA DA FAMILIA NO BRASIL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1126', ' MOVIMENTOS SOCIAIS URBANOS ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1139', 'ESTUDOS SOCIO-ANTROPOLOGICOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1142', 'POBREZA E DESIGUALDADE SOCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1144', 'TEORIA SOCIOLOGICA CONTEMPORANEA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1157', 'SOCIOLOGIA DA VIDA COTIDIANA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1173', 'SEMINARIOS ESPEC EM SOCIOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1196', 'SOCIEDADE, MERCADO E TERCEIRO SETOR', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1201', 'BASES DO PENSAMENTO POLITICO OCIDENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1202', 'A CONSTRUCAO LIBERAL E SUAS CRITICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1203', 'INST POLITICAS BRASILEIRAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1205', 'POLITICA I-TEORIA POLITICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1209', 'O PENSAMENTO POLITICO BRASILEIRO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1211', ' MODELO POLITICO BRASILEIRO ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1214', 'CONSTRUCAO DA CIDADANIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1220', 'SISTEMAS POLITICOS COMPARADOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1223', ' PARTIDOS POL E ELEIC NO BRASIL ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1239', 'BUROCRACIA NO ESTADO MODERNO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1242', ' POLITICAS PUBLICAS NO BRASIL ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1243', 'DEMOCRACIA E EQUIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1250', 'SINDICALISMO, EMPREGO E MERCADO DE TRABALHO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1271', 'SEMINARIO ESP EM CIEN POLIT', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1286', 'GESTAO E AVALIACAO DE POLITICAS PUBLICAS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1291', ' GLOBALIZACAO E BRASIL ', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1302', 'ANTROPOLOGIA CULTURAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1305', 'TEORIA ANTROPOLOGICA : TEORIAS DA CULTURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1306', 'TEORIA ANTROPOLOGICA: ESCOLA FRANCESA E ESTRUTURAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1307', 'TEORIA ANTROPOLOGICA: ANTROPOLOGIA SOCIAL INGLESA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1321', 'ANTROPOLOGIA VISUAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1328', 'ANTROPOLOGIA DA ARTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1339', 'ANTROPOLOGIA DA MUSICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1343', 'ANTROPOLOGIA DA VIOLENCIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1344', 'ANTROPOLOGIA DO CORPO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1371', 'SEMINARIO ESP EM ANTROPOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1375', 'SEMINARIO ESP EM ANTROPOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1380', 'ANTROPOLOGIA DO CONSUMO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1430', 'POL PUBLICA E MEIO AMBIENTE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1505', 'METODOS E TECNICAS DE PESQUISA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1506', 'METODOS E TECNICAS DE PESQUISA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1507', 'ESTATISTICA PARA CIENCIAS SOCIAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1509', 'O OFICIO DO CIENTISTA SOCIAL', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1514', 'MONOGRAFIA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1515', 'MONOGRAFIA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1518', 'MET/PRAT CIENCIAS SOCIAIS I', 5, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1519', 'METODOLOGIA E PRATICA NAS CIENCIAS SOCIAIS II', 5, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1520', 'MONITORIA I', 5, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1521', 'MONITORIA II', 5, NULL);
INSERT INTO "Disciplina" VALUES ('SOC1572', 'SEMINARIO ESPECIAL EM METODOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('SOC9174', 'CONT BRAZIL DEBATES SOCIOLOGICAL ANTHROPOLOGICAL P', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO0104', 'OPT SEMIN SAGRADA ESCRITURA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO0106', 'OPT FILOSOFIA PARA TEOLOGIA I', 12, NULL);
INSERT INTO "Disciplina" VALUES ('TEO0107', 'OPT FILOSOFIA PARA TEOLOGIA II', 20, NULL);
INSERT INTO "Disciplina" VALUES ('TEO0120', 'OPT DO CURSO DE TEOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO0121', 'OPT DE FILOSOFIA P/ TEOLOGIA I', 16, NULL);
INSERT INTO "Disciplina" VALUES ('TEO0122', 'OPT DE FILOSOFIA P/ TEOLOGIA I', 12, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1230', 'CRISTOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1231', 'O DEUS DA REVELACAO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1232', 'SACRAMENTOS I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1233', 'SACRAMENTOS II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1234', 'MONOGRAFIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1235', 'TEOLOGIA DA ESPIRITUALIDADE', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1236', 'TEOLOGIA PASTORAL I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1237', 'TEOLOGIA PASTORAL II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1238', 'PNEUMATOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1239', 'MONOGRAFIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1240', 'INTRODUCAO AO PENSAR TEOLOGICO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1241', 'TEOLOGIA FUNDAMENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1242', 'ANTROPOLOGIA TEOLOGICA : CRIACAO E PECADO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1243', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1245', 'ECLESIOLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1246', 'ANTROP TEO II:A VIDA DA GRACA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1252', 'ESCATOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1255', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1257', 'MARIOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1258', 'SACRAMENTOS I (INTRODUCAO)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1259', 'SACRAMENTOS II (INIC CRISTA)', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1260', 'SACRAM III (REC/UNC ENFERMOS)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1261', 'SACRAM IV (ORD/MINISTERIOS)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1262', 'SACRAMENTOS V (MATRIMONIO)', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1321', 'INTR GERAL A SAGRADA ESCRITURA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1322', 'EVANG SIN E ATOS DOS APOSTOLOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1323', 'ESCRITOS JOANINOS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1325', 'INTRODUCAO AO PENTATEUCO', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1326', 'LITERATURA PROFETICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1327', 'LITERATURA SAPIENCIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1328', 'ESCRITOS PAULINOS E CARTA AOS HEBREUS', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1329', 'LIV HIST ANTIGO TESTAMENTO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1330', 'LIT INTERTESTAM/APOCALIPTICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1410', 'ETICA SEXUALIDADE E BIOETICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1411', 'MORAL FUNDAMENTAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1413', 'MORAL SOCIO-ECON E POLITICA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1512', 'PATROLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1517', 'HISTORIA DA IGREJA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1518', 'HISTORIA DA IGREJA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1519', 'HISTORIA DA IGREJA NO BRASIL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1520', 'PATROLOGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1635', 'SEMINARIO DE MONOGRAFIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1637', 'SINTESE TEOLOGICA : EXAME COMPLEXIVO', 12, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1640', 'SEMINARIO SAGRADA ESCRITURA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1650', 'SEMINARIO DE TEOLOGIA SISTEMATICO-PASTORAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1651', 'SEMINARIO DE TEOLOGIA SISTEMATICO-PASTORAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1652', ' SEM TEO SISTEMATICO-PASTORAL ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1711', 'DIREITO ECLESIAL', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1712', 'DIREITO MATRIMONIAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1713', 'DIREITO FUNDAMENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1714', 'DIREITO CANONICO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1715', 'DIREITO CANONICO II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1801', 'LITURGIA', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1802', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1811', 'TEOLOGIA PASTORAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1812', 'TEOLOGIA DA ESPIRITUALIDADE', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1813', 'ECUMENISMO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1814', 'METODO DE PESQUISA EM TEOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1815', 'LITURGIA I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1816', 'LITURGIA II', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1817', 'TEO/DIAL INTER-RELIGIOSO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1818', 'TEO/CAMPO REL BRASILEIRO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1902', 'LINGUA GREGA BIBLICA I', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1907', 'LINGUA GREGA BIBLICA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1910', 'LINGUA HEBRAICA BIBLICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1911', 'LINGUA HEBRAICA BIBLICA II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1912', 'NAO CADASTRADO NA PUC', 99, NULL);
INSERT INTO "Disciplina" VALUES ('TEO1913', 'HEBRAICO AVANCADO II', 99, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2242', 'TEOLOGIA E HISTORIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2243', 'QUESTOES ESPECIAIS DE METODO TEOLOGICO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2245', ' QUESTOES ESP CRISTOLOGIA I ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2246', 'QUESTOES ESPECIAIS DE CRISTOLOGIA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2247', 'QUESTOES ESPECIAIS DE ECLESIOLOGIA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2248', 'QUESTOES ESPECIAIS DE ECLESIOLOGIA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2249', 'QUESTOES ESPECIAIS DE ANTROPOLOGIA TEOLOGICA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2250', 'QUESTOES ESPECIAIS DE ANTROPOLOGIA TEOLOGICA II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2251', 'QUESTOES ESPECIAIS DE ESCATOLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2252', 'QUESTOES ESPECIAIS DE SACRAMENTOLOGIA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2253', 'QUESTOES ESPECIAIS SOBRE DEUS I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2254', 'QUESTOES ESPECIAIS SOBRE DEUS II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2255', ' QUESTOES ESP PASTORAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2258', 'MUDANCAS DE PARADIGMA NA TEOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2260', 'TEOLOGIA E ESPIRITUALIDADE', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2261', 'FUNDAMENTOS CRISTOLOGICOS DE UMA ANTROPOLOGIA TEOL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2268', 'QUESTOES GENERO TEOLOGIA FEITA POR MULHERES AMERIC', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2269', 'QUESTOES ATUAIS DE ANTROPOLOGIA TEOLOGICA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2270', ' QUEST ESP DA ESPIRITUAL CRISTA ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2275', 'QUESTOES ESPECIAIS DE ANTROPOLOGIA TEOLOGICA IV', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2276', 'TEMAS ESPECIAIS DE TEOLOGIA E HISTORIA DA IGREJA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2280', 'QUESTOES ESPECIAIS DE ESPIRITUALIDADE CRISTA I', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2281', ' TOP DE HISTORIA DE ISRAEL I ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2282', ' TEM ESPECIAIS ECLESIOLOGIA III ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2284', ' TEMAS ATUAIS TEO PASTORAL I ', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2304', ' INTRO METOD EXEGESE MOD DO AT ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2311', 'EXEGESE DOS LIVROS PROFETICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2313', 'ANALISE TEXTOS EVANG SINOTICOS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2322', 'TEMAS FUNDAMEN DO IV EVANGELHO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2326', ' EXEGESE CARTA AOS HEBREUS ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2330', 'METODOLOGIA EXEGETICA DO ANTIGO TESTAMENTO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2331', 'METODOLOGIA EXEGETICA DO NOVO TESTAMENTO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2334', 'OS PROFETAS DE JUDA NO SECULO VIII-VII', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2340', 'QUESTOES ATUAIS SOBRE O PENTATEUCO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2406', 'NOVOS PARADIGMAS EM ETICA CRISTA', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2505', 'SEMINARIO ESPECIAL II - NOVO TESTAMENTO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2507', 'SEMINARIO ESPECIAL IV - ANTIGO TESTAMENTO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2508', 'ESMINARIO ESPECIAL V - PASTORAL BIBLICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2510', 'SEMINARIO DE MESTRADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2511', 'SEMINARIO ESPECIAL DE DOUTORADO', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2838', 'TEMAS ATUAIS DE TEOLOGIA PASTORAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2839', 'NOVOS DESAFIOS ECLESIAIS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2840', 'JUDAISMO E CRISTIANISMO EM DIALOGO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2841', ' LIT/TEO:INTERDISCIP E RECEPCAO ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2902', 'HEBRAICO II', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2903', 'HEBRAICO III', 2, NULL);
INSERT INTO "Disciplina" VALUES ('TEO2908', 'GREGO BIBLICO I', 4, NULL);
INSERT INTO "Disciplina" VALUES ('TEO3000', 'DISSERTACAO DE MESTRADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('TEO3001', 'TESE DE DOUTORADO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('TEO3004', 'EXAME DE QUALIFICACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('TEO3005', 'EXAME COMPLEXIVO (MESTRADO)', 0, NULL);
INSERT INTO "Disciplina" VALUES ('TEO3210', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('TEO3220', 'ESTAGIO DOCENCIA NA GRADUACAO', 0, NULL);
INSERT INTO "Disciplina" VALUES ('URB2601', 'SISTEMAS DE INFORMACAO GEOGRAFICA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2602', 'HIROLOGIA, FLORESTAS E RECURSOS NATURAIS EM AMBIEN', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2603', 'ENGENHARIA SANITARIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2604', 'GERENCIAMENTO DE RESIDUOS', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2605', 'INVESTIGACAO DE CAMPO E REMEDIACAO', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2606', 'ENERGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2607', 'PLANEJAMENTO URBANO SUSTENTAVEL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2608', 'PLANEJAMENTO URBANO SUSTENTAVEL II', 3, NULL);
INSERT INTO "Disciplina" VALUES ('URB2609', 'TECNOLOGIAS AMBIENTAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('URB2610', 'GESTAO E PLANEJAMENTO DE RECURSOS NATURAIS', 3, NULL);
INSERT INTO "Disciplina" VALUES ('URB2611', 'ADMINISTRACAO E SOCIOLOGIA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2612', 'TRANSPORTES', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2613', 'MANUTENCAO GERENCIAMENTO DO CICLO DE VIDA DE INFRA', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2614', 'DESENVOLVIMENTO INDUSTRIAL E LOGISTICA SUSTENTAVEI', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2617', 'SEMINARIOS EM ENGENHARIA URBANA E AMBIENTAL', 2, NULL);
INSERT INTO "Disciplina" VALUES ('URB2618', 'PROJETO EM TECNOLOGIAS AMBIENTAIS', 1, NULL);
INSERT INTO "Disciplina" VALUES ('URB2619', 'PROJETO EM PLANEJAMENTO URBANO SUSTENTAVEL', 1, NULL);
INSERT INTO "Disciplina" VALUES ('URB2620', 'PROJETO EM GESTAO E PLANEJAMENTO DE RECURSOS NATUR', 1, NULL);
INSERT INTO "Disciplina" VALUES ('URB2690', ' TOP ESP ENG URBANA E AMBIENTAL ', 1, NULL);
INSERT INTO "Disciplina" VALUES ('URB2696', ' TOP ESP ENG URBANA E AMBIENTAL ', 3, NULL);
INSERT INTO "Disciplina" VALUES ('URB3000', 'DISSERTACAO DE MESTRADO', 0, NULL);


--
-- TOC entry 2040 (class 0 OID 35758)
-- Dependencies: 165 2055
-- Data for Name: Log; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2046 (class 0 OID 35939)
-- Dependencies: 174 2055
-- Data for Name: Optativa; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2050 (class 0 OID 36043)
-- Dependencies: 179 2055
-- Data for Name: OptativaAluno; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2051 (class 0 OID 36058)
-- Dependencies: 180 2055
-- Data for Name: OptativaDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2052 (class 0 OID 36075)
-- Dependencies: 182 2055
-- Data for Name: PreRequisitoGrupo; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2053 (class 0 OID 36082)
-- Dependencies: 183 2055
-- Data for Name: PreRequisitoGrupoDisciplina; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2041 (class 0 OID 35818)
-- Dependencies: 167 2055
-- Data for Name: Professor; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "Professor" VALUES (1, 'ABELARDO BORGES BARRETO JUNIOR');
INSERT INTO "Professor" VALUES (2, 'ABIMAR OLIVEIRA DE MORAES');
INSERT INTO "Professor" VALUES (3, 'ABRAHAM ALCAIM');
INSERT INTO "Professor" VALUES (4, 'ACHILLES D AVILA CHIROL');
INSERT INTO "Professor" VALUES (5, 'ADAIR LEONARDO ROCHA');
INSERT INTO "Professor" VALUES (6, 'ADOLFO BORGES FILHO');
INSERT INTO "Professor" VALUES (7, 'ADRIANA ANDRADE BRAGA');
INSERT INTO "Professor" VALUES (8, 'ADRIANA ERTHAL ABDENUR');
INSERT INTO "Professor" VALUES (9, 'ADRIANA F DE S DE ALBUQUERQUE');
INSERT INTO "Professor" VALUES (10, 'ADRIANA FERREIRA BONFATTI');
INSERT INTO "Professor" VALUES (11, 'ADRIANA GIODA');
INSERT INTO "Professor" VALUES (12, 'ADRIANA GRAY DA SILVA REIS');
INSERT INTO "Professor" VALUES (13, 'ADRIANA HADDAD NUDI');
INSERT INTO "Professor" VALUES (14, 'ADRIANA LEIRAS');
INSERT INTO "Professor" VALUES (15, 'ADRIANA LEITE DO PRADO REBELLO');
INSERT INTO "Professor" VALUES (16, 'ADRIANA MEDEIROS FERREIRA DA SILVA');
INSERT INTO "Professor" VALUES (17, 'ADRIANA NOGUEIRA ACCIOLY NOBREGA');
INSERT INTO "Professor" VALUES (18, 'ADRIANA RIBEIRO RICE GEISLER');
INSERT INTO "Professor" VALUES (19, 'ADRIANA SAMPAIO LEITE');
INSERT INTO "Professor" VALUES (20, 'ADRIANA SANSAO FONTES');
INSERT INTO "Professor" VALUES (21, 'ADRIANA VIDAL DE OLIVEIRA');
INSERT INTO "Professor" VALUES (22, 'ADRIANO ANDRADE C DE MENDONCA');
INSERT INTO "Professor" VALUES (23, 'ADRIANO BARCELOS ROMEIRO');
INSERT INTO "Professor" VALUES (24, 'ADRIANO PILATTI');
INSERT INTO "Professor" VALUES (25, 'AFFONSO FERNANDES DE ARAUJO');
INSERT INTO "Professor" VALUES (26, 'AFONSO SANT ANNA BEVILAQUA');
INSERT INTO "Professor" VALUES (27, 'AGNES CHRISTIAN CHAVES FARIA');
INSERT INTO "Professor" VALUES (28, 'ALBERTO BARBOSA RAPOSO');
INSERT INTO "Professor" VALUES (29, 'ALBERTO CIPINIUK');
INSERT INTO "Professor" VALUES (30, 'ALBERTO DE SAMPAIO FERRAZ J SAYAO');
INSERT INTO "Professor" VALUES (31, 'ALCIR DE FARO ORLANDO');
INSERT INTO "Professor" VALUES (32, 'ALDER CATUNDA TIMBO MUNIZ');
INSERT INTO "Professor" VALUES (33, 'ALESSANDRA BAIOCCHI ANTUNES CORREA');
INSERT INTO "Professor" VALUES (34, 'ALESSANDRA CARUSI MACHADO BEZERRA');
INSERT INTO "Professor" VALUES (35, 'ALESSANDRA DE SA MELLO DA COSTA');
INSERT INTO "Professor" VALUES (36, 'ALESSANDRA SILVEIRA DA CRUZ');
INSERT INTO "Professor" VALUES (37, 'ALESSANDRA VANNUCCI');
INSERT INTO "Professor" VALUES (38, 'ALESSANDRO FABRICIO GARCIA');
INSERT INTO "Professor" VALUES (39, 'ALESSANDRO LUCCIOLA MOLON');
INSERT INTO "Professor" VALUES (40, 'ALEX JOBIM FARIAS');
INSERT INTO "Professor" VALUES (41, 'ALEX LUCIO RIBEIRO CASTRO');
INSERT INTO "Professor" VALUES (42, 'ALEXANDRA DE MELLO E SILVA');
INSERT INTO "Professor" VALUES (43, 'ALEXANDRE AUGUSTO FREIRE CARAUTA');
INSERT INTO "Professor" VALUES (44, 'ALEXANDRE BALIU BRAUTIGAM');
INSERT INTO "Professor" VALUES (45, 'ALEXANDRE CANTINI REZENDE');
INSERT INTO "Professor" VALUES (46, 'ALEXANDRE DOS SANTOS SILVA');
INSERT INTO "Professor" VALUES (47, 'ALEXANDRE GABRIEL CHRISTO');
INSERT INTO "Professor" VALUES (48, 'ALEXANDRE MALHEIROS MESLIN');
INSERT INTO "Professor" VALUES (49, 'ALEXANDRE MONTAURY B COUTINHO');
INSERT INTO "Professor" VALUES (50, 'ALEXANDRE SERVINO ASSED');
INSERT INTO "Professor" VALUES (51, 'ALEXANDRE SOUZA CHAVES');
INSERT INTO "Professor" VALUES (52, 'ALEXANDRE STREET DE AGUIAR');
INSERT INTO "Professor" VALUES (53, 'ALFONSO GARCIA RUBIO');
INSERT INTO "Professor" VALUES (54, 'ALFREDO JEFFERSON DE OLIVEIRA');
INSERT INTO "Professor" VALUES (55, 'ALFREDO LAUFER');
INSERT INTO "Professor" VALUES (56, 'ALFREDO LUIZ PORTO DE BRITTO');
INSERT INTO "Professor" VALUES (57, 'ALFREDO SAMPAIO COSTA');
INSERT INTO "Professor" VALUES (58, 'ALICIA MARIA CATALANO DE BONAMINO');
INSERT INTO "Professor" VALUES (59, 'ALICIA OLGA GRIFO DE RAMAL');
INSERT INTO "Professor" VALUES (60, 'ALINE MOREIRA MONCORES');
INSERT INTO "Professor" VALUES (61, 'ALUISIO GRANATO DE ANDRADE');
INSERT INTO "Professor" VALUES (62, 'ALUIZIO ALVES FILHO');
INSERT INTO "Professor" VALUES (63, 'ALUIZIO ANTONIO PIRES');
INSERT INTO "Professor" VALUES (64, 'ALVARO DE LIMA VEIGA FILHO');
INSERT INTO "Professor" VALUES (65, 'ALVARO DE PINHEIRO GOUVEA');
INSERT INTO "Professor" VALUES (66, 'ALVARO HENRIQUE DE SOUZA FERREIRA');
INSERT INTO "Professor" VALUES (67, 'ALVARO PIQUET CARNEIRO P DOS SANTOS');
INSERT INTO "Professor" VALUES (68, 'AMADOR DE CARVALHO PEREZ');
INSERT INTO "Professor" VALUES (69, 'AMALIA GIACOMINI');
INSERT INTO "Professor" VALUES (70, 'AMERICA ADRIANA BENEDIKT');
INSERT INTO "Professor" VALUES (71, 'ANA CAROLINA LETICHEVSKY');
INSERT INTO "Professor" VALUES (72, 'ANA CAROLINA TEIXEIRA DELGADO');
INSERT INTO "Professor" VALUES (73, 'ANA CLAUDIA COUTINHO VIEGAS');
INSERT INTO "Professor" VALUES (74, 'ANA CRISTINA BERNARDO DE OLIVEIRA');
INSERT INTO "Professor" VALUES (75, 'ANA CRISTINA MALHEIROS G CARVALHO');
INSERT INTO "Professor" VALUES (76, 'ANA HELOISA DA COSTA LEMOS');
INSERT INTO "Professor" VALUES (77, 'ANA LUCIA DE LYRA TAVARES');
INSERT INTO "Professor" VALUES (78, 'ANA LUCIA DE MOURA');
INSERT INTO "Professor" VALUES (79, 'ANA LUIZA DE SOUZA NOBRE');
INSERT INTO "Professor" VALUES (80, 'ANA LUIZA MAIA NEVARES');
INSERT INTO "Professor" VALUES (81, 'ANA LUIZA MORALES DE AGUIAR');
INSERT INTO "Professor" VALUES (82, 'ANA LUIZA SARAMAGO STERN');
INSERT INTO "Professor" VALUES (83, 'ANA MARIA BELTRAN PAVANI');
INSERT INTO "Professor" VALUES (84, 'ANA MARIA BRANCO NOGUEIRA DA SILVA');
INSERT INTO "Professor" VALUES (85, 'ANA MARIA DE AZEREDO LOPES TEPEDINO');
INSERT INTO "Professor" VALUES (86, 'ANA MARIA DE TOLEDO PIZA RUDGE');
INSERT INTO "Professor" VALUES (87, 'ANA MARIA NICOLACI DA COSTA');
INSERT INTO "Professor" VALUES (88, 'ANA MARIA QUIROGA');
INSERT INTO "Professor" VALUES (89, 'ANA MARIA STINGEL');
INSERT INTO "Professor" VALUES (90, 'ANA PAULA POLIZZO');
INSERT INTO "Professor" VALUES (91, 'ANA PAULA SANTORO P DE C ALMEIDA');
INSERT INTO "Professor" VALUES (92, 'ANA PAULA VEIGA KIFFER');
INSERT INTO "Professor" VALUES (93, 'ANA WALESKA POLLO CAMPOS MENDONCA');
INSERT INTO "Professor" VALUES (94, 'ANAMARIA DE MORAES');
INSERT INTO "Professor" VALUES (95, 'ANDERSON OLIVEIRA DA SILVA');
INSERT INTO "Professor" VALUES (96, 'ANDRE CABUS KLOTZLE');
INSERT INTO "Professor" VALUES (97, 'ANDRE CHATEAUBRIAND P D MARTINS');
INSERT INTO "Professor" VALUES (98, 'ANDRE HERMANNY TOSTES');
INSERT INTO "Professor" VALUES (99, 'ANDRE LACOMBE PENNA DA ROCHA');
INSERT INTO "Professor" VALUES (100, 'ANDRE LUIS ALBERTON');
INSERT INTO "Professor" VALUES (101, 'ANDRE LUIZ CARVALHAL DA SILVA');
INSERT INTO "Professor" VALUES (102, 'ANDRE LUIZ ROIZMAN');
INSERT INTO "Professor" VALUES (103, 'ANDRE PERECMANIS');
INSERT INTO "Professor" VALUES (104, 'ANDRE SAMPAIO DE OLIVEIRA');
INSERT INTO "Professor" VALUES (105, 'ANDRE SILVA PIMENTEL');
INSERT INTO "Professor" VALUES (106, 'ANDRE TRIGUEIRO MENDES');
INSERT INTO "Professor" VALUES (107, 'ANDREA CHERMAN');
INSERT INTO "Professor" VALUES (108, 'ANDREA FRANCA MARTINS');
INSERT INTO "Professor" VALUES (109, 'ANDREA GOMES BITTENCOURT');
INSERT INTO "Professor" VALUES (110, 'ANDREA LUCIA MACIEL RODRIGUES');
INSERT INTO "Professor" VALUES (111, 'ANDREA SEIXAS MAGALHAES');
INSERT INTO "Professor" VALUES (112, 'ANDREIA CLAPP SALVADOR');
INSERT INTO "Professor" VALUES (113, 'ANGELA DE LUCA REBELLO WAGENER');
INSERT INTO "Professor" VALUES (114, 'ANGELA FILOMENA PERRICONE PASTURA');
INSERT INTO "Professor" VALUES (115, 'ANGELA MARIA CAVALCANTI DA ROCHA');
INSERT INTO "Professor" VALUES (116, 'ANGELA MARIA DE RANDOLPHO PAIVA');
INSERT INTO "Professor" VALUES (117, 'ANGELA MARIA DE REGO MONTEIRO');
INSERT INTO "Professor" VALUES (118, 'ANGELA OURIVIO NIECKELE');
INSERT INTO "Professor" VALUES (119, 'ANGELUCCIA BERNARDES HABERT');
INSERT INTO "Professor" VALUES (120, 'ANNA MARIA SOTERO DA SILVA NETO');
INSERT INTO "Professor" VALUES (121, 'ANNIE GOLDBERG EPPINGHAUS');
INSERT INTO "Professor" VALUES (122, 'ANTONIO BERNARDO MARIANI GUERREIRO');
INSERT INTO "Professor" VALUES (123, 'ANTONIO CARLOS ALKMIM DOS REIS');
INSERT INTO "Professor" VALUES (124, 'ANTONIO CARLOS DE OLIVEIRA');
INSERT INTO "Professor" VALUES (125, 'ANTONIO CARLOS FIGUEIREDO PINTO');
INSERT INTO "Professor" VALUES (126, 'ANTONIO CARLOS FLORES DE MORAES');
INSERT INTO "Professor" VALUES (127, 'ANTONIO CARLOS GOMES DE MATTOS');
INSERT INTO "Professor" VALUES (128, 'ANTONIO CARLOS MATTOSO SALGADO');
INSERT INTO "Professor" VALUES (129, 'ANTONIO CARLOS OLIVEIRA BRUNO');
INSERT INTO "Professor" VALUES (130, 'ANTONIO EDMILSON MARTINS RODRIGUES');
INSERT INTO "Professor" VALUES (131, 'ANTONIO FERNANDO DE CASTRO VIEIRA');
INSERT INTO "Professor" VALUES (132, 'ANTONIO JOAQUIM DE MACEDO SOARES');
INSERT INTO "Professor" VALUES (133, 'ANTONIO JORGE ALABY PINHEIRO');
INSERT INTO "Professor" VALUES (134, 'ANTONIO JOSE AFONSO DA COSTA');
INSERT INTO "Professor" VALUES (135, 'ANTONIO JOSE DE SENA BATISTA');
INSERT INTO "Professor" VALUES (136, 'ANTONIO LUZ FURTADO');
INSERT INTO "Professor" VALUES (137, 'ANTONIO MARCOS HOELZ PINTO AMBROZIO');
INSERT INTO "Professor" VALUES (138, 'ANTONIO ROBERTO M B DE OLIVEIRA');
INSERT INTO "Professor" VALUES (139, 'ARNDT VON STAA');
INSERT INTO "Professor" VALUES (140, 'ARNO FRITZ DAS NEVES BRANDES');
INSERT INTO "Professor" VALUES (141, 'ARTHUR BERNARDES DO AMARAL');
INSERT INTO "Professor" VALUES (142, 'ARTHUR CEZAR DE A ITUASSU FILHO');
INSERT INTO "Professor" VALUES (143, 'ARTHUR HENRIQUE MOTTA DAPIEVE');
INSERT INTO "Professor" VALUES (144, 'ARTHUR MARTINS BARBOSA BRAGA');
INSERT INTO "Professor" VALUES (145, 'ARTURO PISCIOTTI NETTO');
INSERT INTO "Professor" VALUES (146, 'AUGUSTO CESAR PINHEIRO DA SILVA');
INSERT INTO "Professor" VALUES (147, 'AUGUSTO HENRIQUE P DE S W MARTINS');
INSERT INTO "Professor" VALUES (148, 'AUGUSTO IVAN DE FREITAS PINHEIRO');
INSERT INTO "Professor" VALUES (149, 'AUGUSTO LUIZ DUARTE LOPES SAMPAIO');
INSERT INTO "Professor" VALUES (150, 'AUGUSTO SEIBEL MACHADO');
INSERT INTO "Professor" VALUES (151, 'AUTERIVES MACIEL JUNIOR');
INSERT INTO "Professor" VALUES (152, 'BARBARA CASTELLO B R DE ASSUMPCAO');
INSERT INTO "Professor" VALUES (153, 'BARBARA JANE NECYK');
INSERT INTO "Professor" VALUES (154, 'BARBARA JANE WILCOX HEMAIS');
INSERT INTO "Professor" VALUES (155, 'BARBARA PATARO BUCKER');
INSERT INTO "Professor" VALUES (156, 'BEATRIZ CASTRO BARRETO');
INSERT INTO "Professor" VALUES (157, 'BEATRIZ MARIA FIGUEIREDO DE CASTRO');
INSERT INTO "Professor" VALUES (158, 'BEN HUR DE ALBUQUERQUE E SILVA');
INSERT INTO "Professor" VALUES (159, 'BENITO PIROPO DA RIN');
INSERT INTO "Professor" VALUES (160, 'BERNARDO AUGUSTO DE REGO MONTEIRO');
INSERT INTO "Professor" VALUES (161, 'BERNARDO JABLONSKI');
INSERT INTO "Professor" VALUES (162, 'BERNARDO MEDEIROS FERREIRA DA SILVA');
INSERT INTO "Professor" VALUES (163, 'BERNARDO PORTUGAL SILVA RAPOSO');
INSERT INTO "Professor" VALUES (164, 'BERNARDO VELLOSO FERNANDEZ CONDE');
INSERT INTO "Professor" VALUES (165, 'BETHANIA DE ALBUQUERQUE ASSY');
INSERT INTO "Professor" VALUES (166, 'BOJAN MARINKOVIC');
INSERT INTO "Professor" VALUES (167, 'BOYAN SLAVCHEV SIRAKOV');
INSERT INTO "Professor" VALUES (168, 'BRENNO ROMANO MOTTA FILHO');
INSERT INTO "Professor" VALUES (169, 'BRENO MELARAGNO COSTA');
INSERT INTO "Professor" VALUES (170, 'BRUNA SANT ANA AUCAR');
INSERT INTO "Professor" VALUES (171, 'BRUNO DE MOURA BORGES');
INSERT INTO "Professor" VALUES (172, 'BRUNO FEIJO');
INSERT INTO "Professor" VALUES (173, 'BRUNO GARCIA REDONDO');
INSERT INTO "Professor" VALUES (174, 'BRUNO LOPES VIEIRA');
INSERT INTO "Professor" VALUES (175, 'BRUNO MACHADO EIRAS');
INSERT INTO "Professor" VALUES (176, 'BRUNO VAZ DE CARVALHO');
INSERT INTO "Professor" VALUES (177, 'CAIO SALLES MARCONDES DE MOURA');
INSERT INTO "Professor" VALUES (178, 'CAITLIN SAMPAIO MULHOLLAND');
INSERT INTO "Professor" VALUES (179, 'CAMILA DE SOUZA BRAGA');
INSERT INTO "Professor" VALUES (180, 'CAMILLA DJENNE BUARQUE MULLER');
INSERT INTO "Professor" VALUES (181, 'CANDIDA MARIA MONTEIRO R DA COSTA');
INSERT INTO "Professor" VALUES (182, 'CANDIDO FELICIANO DA PONTE NETO');
INSERT INTO "Professor" VALUES (183, 'CARLA FRANCISCA BOTTINO ANTONACCIO');
INSERT INTO "Professor" VALUES (184, 'CARLA GOBEL BURLAMAQUI DE MELLO');
INSERT INTO "Professor" VALUES (185, 'CARLA JUACABA DE ALMEIDA');
INSERT INTO "Professor" VALUES (186, 'CARLA RODRIGUES');
INSERT INTO "Professor" VALUES (187, 'CARLA VIEIRA DE SIQUEIRA');
INSERT INTO "Professor" VALUES (188, 'CARLOS AFFONSO PEREIRA DE SOUZA');
INSERT INTO "Professor" VALUES (189, 'CARLOS ALBERTO DE ALMEIDA');
INSERT INTO "Professor" VALUES (190, 'CARLOS ALBERTO PLASTINO');
INSERT INTO "Professor" VALUES (191, 'CARLOS ANDRE LAMEIRAO CORTES');
INSERT INTO "Professor" VALUES (192, 'CARLOS ANTONIO DA COSTA FERNANDES');
INSERT INTO "Professor" VALUES (193, 'CARLOS AUGUSTO DE O PEIXOTO JR');
INSERT INTO "Professor" VALUES (194, 'CARLOS CESAR GOMES');
INSERT INTO "Professor" VALUES (195, 'CARLOS EDEN SARDENBERG MESQUITA');
INSERT INTO "Professor" VALUES (196, 'CARLOS EDUARDO DUARTE A DE BRITO');
INSERT INTO "Professor" VALUES (197, 'CARLOS EDUARDO FELIX DA COSTA');
INSERT INTO "Professor" VALUES (198, 'CARLOS EDUARDO MUNIZ DA C PEREIRA');
INSERT INTO "Professor" VALUES (199, 'CARLOS EDUARDO S DE VASCONCELLOS');
INSERT INTO "Professor" VALUES (200, 'CARLOS EURICO POGGI DE ARAGAO JR');
INSERT INTO "Professor" VALUES (201, 'CARLOS FREDERICO DE SOUZA COELHO');
INSERT INTO "Professor" VALUES (202, 'CARLOS FREDERICO PEREIRA DA S GAMA');
INSERT INTO "Professor" VALUES (203, 'CARLOS GUILHERME FRANCOVICH LUGONES');
INSERT INTO "Professor" VALUES (204, 'CARLOS GUSTAVO VIANNA DIREITO');
INSERT INTO "Professor" VALUES (205, 'CARLOS HENRIQUE TRANJAN BECHARA');
INSERT INTO "Professor" VALUES (206, 'CARLOS JOSE PEREIRA DE LUCENA');
INSERT INTO "Professor" VALUES (207, 'CARLOS NELSON DE PAULA KONDER');
INSERT INTO "Professor" VALUES (208, 'CARLOS NOBRE CRUZ');
INSERT INTO "Professor" VALUES (209, 'CARLOS PATRICIO MERCADO SAMANEZ');
INSERT INTO "Professor" VALUES (210, 'CARLOS RAJA GABAGLIA MOREIRA PENNA');
INSERT INTO "Professor" VALUES (211, 'CARLOS RAYMUNDO CARDOSO');
INSERT INTO "Professor" VALUES (212, 'CARLOS REBELLO NEGREIROS');
INSERT INTO "Professor" VALUES (213, 'CARLOS ROBERTO CERQUEIRA ALVES');
INSERT INTO "Professor" VALUES (214, 'CARLOS ROBERTO HALL BARBOSA');
INSERT INTO "Professor" VALUES (215, 'CARLOS RODRIGUEZ SUAREZ');
INSERT INTO "Professor" VALUES (216, 'CARLOS SANTOS DE OLIVEIRA');
INSERT INTO "Professor" VALUES (217, 'CARLOS SILVA KUBRUSLY');
INSERT INTO "Professor" VALUES (218, 'CARLOS TOMEI');
INSERT INTO "Professor" VALUES (219, 'CARLOS VALOIS MACIEL BRAGA');
INSERT INTO "Professor" VALUES (220, 'CARLOS VIANA DE CARVALHO');
INSERT INTO "Professor" VALUES (221, 'CARMEM LUCIA BARRETO PETIT');
INSERT INTO "Professor" VALUES (222, 'CARMEN LUIZA HOZANNA FERREIRA');
INSERT INTO "Professor" VALUES (223, 'CAROLINA DE CAMPOS MELO');
INSERT INTO "Professor" VALUES (224, 'CAROLINA DE LIMA AGUILAR');
INSERT INTO "Professor" VALUES (225, 'CAROLINA GUIMARAES DE SOUZA DIAS');
INSERT INTO "Professor" VALUES (226, 'CAROLINA LAMPREIA');
INSERT INTO "Professor" VALUES (227, 'CAROLINA MOULIN AGUIAR');
INSERT INTO "Professor" VALUES (228, 'CASSIA MARIA CHAFFIN GUEDES PEREIRA');
INSERT INTO "Professor" VALUES (229, 'CASSIA QUELHO TAVARES');
INSERT INTO "Professor" VALUES (230, 'CECILIA LIMA DE QUEIROS MATTOSO');
INSERT INTO "Professor" VALUES (231, 'CECILIA MARTINS DE MELLO');
INSERT INTO "Professor" VALUES (232, 'CECILIA VILANI');
INSERT INTO "Professor" VALUES (233, 'CELIA BEATRIZ ANTENEODO DE PORTO');
INSERT INTO "Professor" VALUES (234, 'CELIA EYER DE ARAUJO');
INSERT INTO "Professor" VALUES (235, 'CELIA FERREIRA NOVAES');
INSERT INTO "Professor" VALUES (236, 'CELIO GOMES CAMPOS');
INSERT INTO "Professor" VALUES (237, 'CELIO ROBERTO LIMA RENTROIA');
INSERT INTO "Professor" VALUES (238, 'CELSO BRAGA WILMER');
INSERT INTO "Professor" VALUES (239, 'CELSO DE ALBUQUERQUE SILVA');
INSERT INTO "Professor" VALUES (240, 'CELSO MEIRELLES DE OLIVEIRA SANTOS');
INSERT INTO "Professor" VALUES (241, 'CELSO PINTO CARIAS');
INSERT INTO "Professor" VALUES (242, 'CELSO RAYOL JUNIOR');
INSERT INTO "Professor" VALUES (243, 'CELSO ROMANEL');
INSERT INTO "Professor" VALUES (244, 'CESAR ROMERO JACOB');
INSERT INTO "Professor" VALUES (245, 'CHRISTIANO ARRIGONI COELHO');
INSERT INTO "Professor" VALUES (246, 'CHRISTINE SERTA COSTA');
INSERT INTO "Professor" VALUES (247, 'CILENE APARECIDA NUNES RODRIGUES');
INSERT INTO "Professor" VALUES (248, 'CIRO VALERIO TORRES DA SILVA');
INSERT INTO "Professor" VALUES (249, 'CLARISSE FUKELMAN');
INSERT INTO "Professor" VALUES (250, 'CLARISSE SIECKENIUS DE SOUZA');
INSERT INTO "Professor" VALUES (251, 'CLAUDIA AMORIM GARCIA');
INSERT INTO "Professor" VALUES (252, 'CLAUDIA BRUTT GUIMARAES');
INSERT INTO "Professor" VALUES (253, 'CLAUDIA CRISTINA DE MELLO ROLLIM');
INSERT INTO "Professor" VALUES (254, 'CLAUDIA DA SILVA PEREIRA');
INSERT INTO "Professor" VALUES (255, 'CLAUDIA DE ALCANTARA CHAVES');
INSERT INTO "Professor" VALUES (256, 'CLAUDIA DE FREITAS ESCARLATE');
INSERT INTO "Professor" VALUES (257, 'CLAUDIA DUARTE SOARES');
INSERT INTO "Professor" VALUES (258, 'CLAUDIA FERNANDA CHIGRES');
INSERT INTO "Professor" VALUES (259, 'CLAUDIA HABIB KAYAT');
INSERT INTO "Professor" VALUES (260, 'CLAUDIA LILIA RABELO VERSIANI');
INSERT INTO "Professor" VALUES (261, 'CLAUDIA MARIA MONTEIRO VIANNA');
INSERT INTO "Professor" VALUES (262, 'CLAUDIA MARIA PIMENTEL N DE MIRANDA');
INSERT INTO "Professor" VALUES (263, 'CLAUDIA RENATA MONT A B RODRIGUES');
INSERT INTO "Professor" VALUES (264, 'CLAUDIO ABRAMOVAY FERRAZ DO AMARAL');
INSERT INTO "Professor" VALUES (265, 'CLAUDIO ANDRES TELLEZ ZEPEDA');
INSERT INTO "Professor" VALUES (266, 'CLAUDIO FREITAS DE MAGALHAES');
INSERT INTO "Professor" VALUES (267, 'CLAUDIO GOMES WERNECK DE FREITAS');
INSERT INTO "Professor" VALUES (268, 'CLAUDIO JACINTO DA SILVA');
INSERT INTO "Professor" VALUES (269, 'CLAUDIO LUIS BRAGA DELL ORTO');
INSERT INTO "Professor" VALUES (270, 'CLAUDIO ROQUETTE BOJUNGA');
INSERT INTO "Professor" VALUES (271, 'CLAUDIO VICTOR NASAJON SASSON');
INSERT INTO "Professor" VALUES (272, 'CLEBER MARQUES DE CASTRO');
INSERT INTO "Professor" VALUES (273, 'CLELIA ELISA CABRAL BESSA');
INSERT INTO "Professor" VALUES (274, 'COORDENADOR DE CURSO');
INSERT INTO "Professor" VALUES (275, 'CRESO DA CRUZ SOARES JUNIOR');
INSERT INTO "Professor" VALUES (276, 'CRISTIANO AUGUSTO COELHO FERNANDES');
INSERT INTO "Professor" VALUES (277, 'CRISTINA ADAM SALGADO GUIMARAES');
INSERT INTO "Professor" VALUES (278, 'CRISTINA DA COSTA VIANA');
INSERT INTO "Professor" VALUES (279, 'CRISTINA MARIA MARTINS DE MATOS');
INSERT INTO "Professor" VALUES (280, 'CRISTINE NOGUEIRA NUNES');
INSERT INTO "Professor" VALUES (281, 'CURSO A DISTANCIA');
INSERT INTO "Professor" VALUES (282, 'CYNTHIA PAES DE CARVALHO');
INSERT INTO "Professor" VALUES (283, 'DANIEL ACOSTA AVALOS');
INSERT INTO "Professor" VALUES (284, 'DANIEL ALVES DA COSTA VARGENS');
INSERT INTO "Professor" VALUES (285, 'DANIEL FERNANDES CASTANHEIRA');
INSERT INTO "Professor" VALUES (286, 'DANIEL KAMLOT');
INSERT INTO "Professor" VALUES (287, 'DANIEL MALAGUTI CAMPOS');
INSERT INTO "Professor" VALUES (288, 'DANIEL MESQUITA PEREIRA');
INSERT INTO "Professor" VALUES (289, 'DANIEL PINHA SILVA');
INSERT INTO "Professor" VALUES (290, 'DANIEL SCHWABE');
INSERT INTO "Professor" VALUES (291, 'DANIEL SOARES VELASCO');
INSERT INTO "Professor" VALUES (292, 'DANIEL WELMAN');
INSERT INTO "Professor" VALUES (293, 'DANIELA ALONSO FONTES');
INSERT INTO "Professor" VALUES (294, 'DANIELA CORREA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (295, 'DANIELA GIANNA CLAUDIA B VERSIANI');
INSERT INTO "Professor" VALUES (296, 'DANIELA ROMAO BARBUTO DIAS');
INSERT INTO "Professor" VALUES (297, 'DANIELA TREJOS VARGAS');
INSERT INTO "Professor" VALUES (298, 'DANIELE MEDINA MAIA');
INSERT INTO "Professor" VALUES (299, 'DANIELLE DE ANDRADE MOREIRA');
INSERT INTO "Professor" VALUES (300, 'DANILO MARCONDES DE SOUZA FILHO');
INSERT INTO "Professor" VALUES (301, 'DANILO MARCONDES DE SOUZA NETO');
INSERT INTO "Professor" VALUES (302, 'DANILO ROGERIO ARRUDA');
INSERT INTO "Professor" VALUES (303, 'DANTE BRAZ LIMONGI');
INSERT INTO "Professor" VALUES (304, 'DARCIO AUGUSTO CHAVES FARIA');
INSERT INTO "Professor" VALUES (305, 'DAVID MARTINS VIEIRA');
INSERT INTO "Professor" VALUES (306, 'DEANE DE MESQUITA ROEHL');
INSERT INTO "Professor" VALUES (307, 'DEBORA LOPES PILOTTO DOMINGUES');
INSERT INTO "Professor" VALUES (308, 'DEBORAH CHAGAS CHRISTO');
INSERT INTO "Professor" VALUES (309, 'DEBORAH DANOWSKI');
INSERT INTO "Professor" VALUES (310, 'DELBERIS ARAUJO LIMA');
INSERT INTO "Professor" VALUES (311, 'DELY SOARES BENTES');
INSERT INTO "Professor" VALUES (312, 'DENISE BERRUEZO PORTINARI');
INSERT INTO "Professor" VALUES (313, 'DENISE CHINI SOLOT');
INSERT INTO "Professor" VALUES (314, 'DENISE COSTA LOPES');
INSERT INTO "Professor" VALUES (315, 'DENISE LEZAN DE ALMEIDA');
INSERT INTO "Professor" VALUES (316, 'DENISE MARIA MANO PESSOA');
INSERT INTO "Professor" VALUES (317, 'DENISE MULLER DOS REIS PUPO');
INSERT INTO "Professor" VALUES (318, 'DENISE PINI ROSALEM DA FONSECA');
INSERT INTO "Professor" VALUES (319, 'DENISE STREIT MORSCH');
INSERT INTO "Professor" VALUES (320, 'DIEGO ANIBAL PORTAS');
INSERT INTO "Professor" VALUES (321, 'DIEGO SANTOS VIEIRA DE JESUS');
INSERT INTO "Professor" VALUES (322, 'DIOGO MADUELL VIEIRA');
INSERT INTO "Professor" VALUES (323, 'DJENANE CORDEIRO PAMPLONA');
INSERT INTO "Professor" VALUES (324, 'DOURIVAL DE SOUZA CARVALHO JUNIOR');
INSERT INTO "Professor" VALUES (325, 'EBE CAMPINHA DOS SANTOS');
INSERT INTO "Professor" VALUES (326, 'EDGAR DE BRITO LYRA NETTO');
INSERT INTO "Professor" VALUES (327, 'EDGARD JOSE JORGE FILHO');
INSERT INTO "Professor" VALUES (328, 'EDIRLEI EVERSON SOARES DE LIMA');
INSERT INTO "Professor" VALUES (329, 'EDMAR DAS MERCES PENHA');
INSERT INTO "Professor" VALUES (330, 'EDMUNDO BASTOS TORREAO');
INSERT INTO "Professor" VALUES (331, 'EDMUNDO EUTROPIO COELHO DE SOUZA');
INSERT INTO "Professor" VALUES (332, 'EDNA CAMPOS PACHECO FERNANDES');
INSERT INTO "Professor" VALUES (333, 'EDNA LUCIA OLIVEIRA DA CUNHA LIMA');
INSERT INTO "Professor" VALUES (334, 'EDUARDO BERLINER');
INSERT INTO "Professor" VALUES (335, 'EDUARDO DE ALBUQUERQUE BROCCHI');
INSERT INTO "Professor" VALUES (336, 'EDUARDO JARDIM DE MORAES');
INSERT INTO "Professor" VALUES (337, 'EDUARDO JOSE LOBAO PEGURIER');
INSERT INTO "Professor" VALUES (338, 'EDUARDO JOSE SIQUEIRA P DE SOUZA');
INSERT INTO "Professor" VALUES (339, 'EDUARDO PEREZ OBERG');
INSERT INTO "Professor" VALUES (340, 'EDUARDO PIMENTEL MENEZES');
INSERT INTO "Professor" VALUES (341, 'EDUARDO PUCU DE ARAUJO');
INSERT INTO "Professor" VALUES (342, 'EDUARDO ROCHA DE OLIVEIRA FILHO');
INSERT INTO "Professor" VALUES (343, 'EDUARDO SANY LABER');
INSERT INTO "Professor" VALUES (344, 'EDUARDO THADEU LEITE CORSEUIL');
INSERT INTO "Professor" VALUES (345, 'EDUARDO VASCONCELOS RAPOSO');
INSERT INTO "Professor" VALUES (346, 'EDUARDO ZILBERMAN');
INSERT INTO "Professor" VALUES (347, 'EDWARD HERMANN HAEUSLER');
INSERT INTO "Professor" VALUES (348, 'ELAINE RADICETTI');
INSERT INTO "Professor" VALUES (349, 'ELIANA DE ANDRADE FREIRE');
INSERT INTO "Professor" VALUES (350, 'ELIANA GIAMBIAGI');
INSERT INTO "Professor" VALUES (351, 'ELIANA LUCIA MADUREIRA YUNES GARCIA');
INSERT INTO "Professor" VALUES (352, 'ELIANE BORGES BERUTTI');
INSERT INTO "Professor" VALUES (353, 'ELIANE BOTELHO JUNQUEIRA');
INSERT INTO "Professor" VALUES (354, 'ELIANE GARCIA PEREIRA');
INSERT INTO "Professor" VALUES (355, 'ELIANE GOTTLIEB');
INSERT INTO "Professor" VALUES (356, 'ELISA DOMINGUEZ SOTELINO');
INSERT INTO "Professor" VALUES (357, 'ELISABETH COSTA MONTEIRO');
INSERT INTO "Professor" VALUES (358, 'ELIZA REGINA AMBROSIO');
INSERT INTO "Professor" VALUES (359, 'ELIZABETH BASTOS GRANDMASSON CHAVES');
INSERT INTO "Professor" VALUES (360, 'ELIZABETH TOSTES DE BARROS');
INSERT INTO "Professor" VALUES (361, 'ELMO CAVALCANTE GOMES JUNIOR');
INSERT INTO "Professor" VALUES (362, 'EMANOEL PAIVA OLIVEIRA COSTA');
INSERT INTO "Professor" VALUES (363, 'EMILIO RANGEL CARNEIRO');
INSERT INTO "Professor" VALUES (364, 'ENEIDA LEAL CUNHA');
INSERT INTO "Professor" VALUES (365, 'ENIO FROTA DA SILVEIRA');
INSERT INTO "Professor" VALUES (366, 'ENRIQUE VICTORIANO ANDA');
INSERT INTO "Professor" VALUES (367, 'ERICA DOS SANTOS RODRIGUES');
INSERT INTO "Professor" VALUES (368, 'ERMELINDA RITA DE SAO THIAGO GENTIL');
INSERT INTO "Professor" VALUES (369, 'ERNANI ALMEIDA FERRAZ');
INSERT INTO "Professor" VALUES (370, 'ERNANI DE SOUZA COSTA');
INSERT INTO "Professor" VALUES (371, 'ERNANI DE SOUZA FREIRE FILHO');
INSERT INTO "Professor" VALUES (372, 'ERNESTO CARNEIRO RODRIGUES');
INSERT INTO "Professor" VALUES (373, 'ESTANISLAU BEZERRA FELIX');
INSERT INTO "Professor" VALUES (374, 'ESTHER MARIA MAGALHAES ARANTES');
INSERT INTO "Professor" VALUES (375, 'EUGENIA MARIA PIRES KOELER');
INSERT INTO "Professor" VALUES (376, 'EUGENIO KAHN EPPRECHT');
INSERT INTO "Professor" VALUES (377, 'EUNICIA BARROS BARCELOS FERNANDES');
INSERT INTO "Professor" VALUES (378, 'EURIES BEZERRA LIMA');
INSERT INTO "Professor" VALUES (379, 'EURIPEDES DO AMARAL VARGAS JR');
INSERT INTO "Professor" VALUES (380, 'EVA APARECIDA REZENDE DE MORAES');
INSERT INTO "Professor" VALUES (381, 'EVA GERTRUDES JONATHAN');
INSERT INTO "Professor" VALUES (382, 'EVANDRO DA SILVEIRA GOULART');
INSERT INTO "Professor" VALUES (383, 'EVELYN GRUMACH');
INSERT INTO "Professor" VALUES (384, 'EVERARDO PEREIRA GUIMARAES ROCHA');
INSERT INTO "Professor" VALUES (385, 'FABIANO PELLIN MIELNICZUK');
INSERT INTO "Professor" VALUES (386, 'FABIO ALVES FERREIRA');
INSERT INTO "Professor" VALUES (387, 'FABIO CARVALHO LEITE');
INSERT INTO "Professor" VALUES (388, 'FABIO PINTO LOPES DE LIMA');
INSERT INTO "Professor" VALUES (389, 'FABIO RODRIGO SIQUEIRA BATISTA');
INSERT INTO "Professor" VALUES (390, 'FABRICIO MELLO RODRIGUES DA SILVA');
INSERT INTO "Professor" VALUES (391, 'FATIMA CRISTINA DE MENDONCA ALVES');
INSERT INTO "Professor" VALUES (392, 'FATIMA VENTURA PEREIRA MEIRELLES');
INSERT INTO "Professor" VALUES (393, 'FELIPE GIRDWOOD ACIOLI');
INSERT INTO "Professor" VALUES (394, 'FELIPE GOMBERG');
INSERT INTO "Professor" VALUES (395, 'FELIPE RANGEL CARNEIRO');
INSERT INTO "Professor" VALUES (396, 'FELIPE TAMEGA FERNANDES');
INSERT INTO "Professor" VALUES (397, 'FERNANDA LEITE MENDES E SANTO');
INSERT INTO "Professor" VALUES (398, 'FERNANDA MARIA PEREIRA RAUPP');
INSERT INTO "Professor" VALUES (399, 'FERNANDO ANTONIO FERREIRA DA SILVA');
INSERT INTO "Professor" VALUES (400, 'FERNANDO ANTONIO LUCENA AIUBE');
INSERT INTO "Professor" VALUES (401, 'FERNANDO BETIM PAES LEME');
INSERT INTO "Professor" VALUES (402, 'FERNANDO CAIUBY ARIANI FILHO');
INSERT INTO "Professor" VALUES (403, 'FERNANDO CARLOS RODRIGUES CORTEZI');
INSERT INTO "Professor" VALUES (404, 'FERNANDO CAVALCANTI WALCACER');
INSERT INTO "Professor" VALUES (405, 'FERNANDO COSME RIZZO ASSUNCAO');
INSERT INTO "Professor" VALUES (406, 'FERNANDO DE ALMEIDA SA');
INSERT INTO "Professor" VALUES (407, 'FERNANDO FELICIO DOS S DE CARVALHO');
INSERT INTO "Professor" VALUES (408, 'FERNANDO FERNANDES DE MELLO');
INSERT INTO "Professor" VALUES (409, 'FERNANDO FRANCA COCCHIARALE');
INSERT INTO "Professor" VALUES (410, 'FERNANDO GALVAO DE ANDREA FERREIRA');
INSERT INTO "Professor" VALUES (411, 'FERNANDO HENRIQUE DA SILVEIRA NETO');
INSERT INTO "Professor" VALUES (412, 'FERNANDO LAZARO FREIRE JUNIOR');
INSERT INTO "Professor" VALUES (413, 'FERNANDO NEVES DA COSTA MAIA');
INSERT INTO "Professor" VALUES (414, 'FERNANDO RIBEIRO TENORIO');
INSERT INTO "Professor" VALUES (415, 'FIRLY NASCIMENTO FILHO');
INSERT INTO "Professor" VALUES (416, 'FLAVIA CESAR TEIXEIRA MENDES');
INSERT INTO "Professor" VALUES (417, 'FLAVIA DA COSTA LIMMER');
INSERT INTO "Professor" VALUES (418, 'FLAVIA DE ALMEIDA V DE CASTRO');
INSERT INTO "Professor" VALUES (419, 'FLAVIA DE OLIVEIRA RUA A CIUCCI');
INSERT INTO "Professor" VALUES (420, 'FLAVIA DE SOUZA COSTA N CAVAZOTTE');
INSERT INTO "Professor" VALUES (421, 'FLAVIA MARIA SCHLEE EYLER');
INSERT INTO "Professor" VALUES (422, 'FLAVIA NIZIA DA FONSECA RIBEIRO');
INSERT INTO "Professor" VALUES (423, 'FLAVIA SOLLERO DE CAMPOS');
INSERT INTO "Professor" VALUES (424, 'FLAVIANA DIAS VIEIRA RAYNAUD');
INSERT INTO "Professor" VALUES (425, 'FLAVIO HELENO BEVILACQUA E SILVA');
INSERT INTO "Professor" VALUES (426, 'FLAVIO JOSE VIEIRA HASSELMANN');
INSERT INTO "Professor" VALUES (427, 'FLAVIO MULLER DOS REIS DE S PUPO');
INSERT INTO "Professor" VALUES (428, 'FRANCIS BERENGER MACHADO');
INSERT INTO "Professor" VALUES (429, 'FRANCIS WALESKA ESTEVES DA SILVA');
INSERT INTO "Professor" VALUES (430, 'FRANCISCO ANTUNES MACIEL MUSSNICH');
INSERT INTO "Professor" VALUES (431, 'FRANCISCO DE GUIMARAENS');
INSERT INTO "Professor" VALUES (432, 'FRANCISCO JOSE MOURA');
INSERT INTO "Professor" VALUES (433, 'FRANCISCO OLIVEIRA DE QUEIROZ');
INSERT INTO "Professor" VALUES (434, 'FRANCISCO OTAVIO ARCHILA DA COSTA');
INSERT INTO "Professor" VALUES (435, 'FRANCISCO RONDINELLI JUNIOR');
INSERT INTO "Professor" VALUES (436, 'FREDERICO OLIVEIRA COELHO');
INSERT INTO "Professor" VALUES (437, 'FREDERICO SALAMONI GELLI');
INSERT INTO "Professor" VALUES (438, 'GABRIEL CHAVARRY NEIVA');
INSERT INTO "Professor" VALUES (439, 'GABRIEL DI LEMOS SANTIAGO LIMA');
INSERT INTO "Professor" VALUES (440, 'GABRIEL DO AMARAL BATISTA');
INSERT INTO "Professor" VALUES (441, 'GABRIEL JUCA DE HOLLANDA');
INSERT INTO "Professor" VALUES (442, 'GABRIEL NOGUEIRA DUARTE');
INSERT INTO "Professor" VALUES (443, 'GABRIEL ROBERTO DELLACASA LEVRINI');
INSERT INTO "Professor" VALUES (444, 'GABRIELA DE GUSMAO PEREIRA');
INSERT INTO "Professor" VALUES (445, 'GABRIELLA FERREIRA CHAVES VACCARI');
INSERT INTO "Professor" VALUES (446, 'GEOVAN TAVARES DOS SANTOS');
INSERT INTO "Professor" VALUES (447, 'GERALDO AFONSO SPINELLI M RIBEIRO');
INSERT INTO "Professor" VALUES (448, 'GERALDO DONDICI VIEIRA');
INSERT INTO "Professor" VALUES (449, 'GERALDO FILIZOLA');
INSERT INTO "Professor" VALUES (450, 'GERALDO LUIZ CAMPOS C DE OLIVEIRA');
INSERT INTO "Professor" VALUES (451, 'GERALDO MARQUES RAIMUNDO');
INSERT INTO "Professor" VALUES (452, 'GERALDO MONTEIRO SIGAUD');
INSERT INTO "Professor" VALUES (453, 'GILBERTO MARTINS DE ALMEIDA');
INSERT INTO "Professor" VALUES (454, 'GILBERTO MENDES CORREIA JUNIOR');
INSERT INTO "Professor" VALUES (455, 'GILBERTO MENDONCA TELES');
INSERT INTO "Professor" VALUES (456, 'GILDA HELENA BERNARDINO DE CAMPOS');
INSERT INTO "Professor" VALUES (457, 'GIOVANNA FERREIRA DEALTRY');
INSERT INTO "Professor" VALUES (458, 'GISELE GUIMARAES CITTADINO');
INSERT INTO "Professor" VALUES (459, 'GISELLE MARQUES CAMARA');
INSERT INTO "Professor" VALUES (460, 'GIUSEPPE BARBOSA GUIMARAES');
INSERT INTO "Professor" VALUES (461, 'GLACIR DE OLIVEIRA G ZAPATA');
INSERT INTO "Professor" VALUES (462, 'GLAUCIA AUGUSTO FONSECA');
INSERT INTO "Professor" VALUES (463, 'GLAUCIO LIMA SIQUEIRA');
INSERT INTO "Professor" VALUES (464, 'GLAUCO JOSE DE OLIVEIRA RODRIGUES');
INSERT INTO "Professor" VALUES (465, 'GLORIA FATIMA COSTA DO NASCIMENTO');
INSERT INTO "Professor" VALUES (466, 'GLORIA MARIA TELES');
INSERT INTO "Professor" VALUES (467, 'GREGORIO SALCEDO MUNOZ');
INSERT INTO "Professor" VALUES (468, 'GUILHERME AZEVEDO TOLEDO');
INSERT INTO "Professor" VALUES (469, 'GUILHERME DE ALMEIDA XAVIER');
INSERT INTO "Professor" VALUES (470, 'GUILHERME GUTMAN CORREA DE ARAUJO');
INSERT INTO "Professor" VALUES (471, 'GUILHERME LORENZONI DE ALMEIDA');
INSERT INTO "Professor" VALUES (472, 'GUILHERME NUNES DA COSTA');
INSERT INTO "Professor" VALUES (473, 'GUILHERME PENELLO TEMPORAO');
INSERT INTO "Professor" VALUES (474, 'GUILHERME VALDETARO MATHIAS');
INSERT INTO "Professor" VALUES (475, 'GUILHERME VAZ PORTO BRECHBUHLER');
INSERT INTO "Professor" VALUES (476, 'GUSTAVO CHATAIGNIER G DA COSTA');
INSERT INTO "Professor" VALUES (477, 'GUSTAVO JUNQUEIRA CARNEIRO LEAO');
INSERT INTO "Professor" VALUES (478, 'GUSTAVO MAURICIO GONZAGA');
INSERT INTO "Professor" VALUES (479, 'GUSTAVO MIRANDA ARAUJO');
INSERT INTO "Professor" VALUES (480, 'GUSTAVO ROBICHEZ DE CARVALHO');
INSERT INTO "Professor" VALUES (481, 'GUSTAVO SENECHAL DE GOFFREDO');
INSERT INTO "Professor" VALUES (482, 'GUSTAVO SILVA ARAUJO');
INSERT INTO "Professor" VALUES (483, 'HAMILTON MASSATAKA KAI');
INSERT INTO "Professor" VALUES (484, 'HANS INGO WEBER');
INSERT INTO "Professor" VALUES (485, 'HEIDRUN FRIEDEL K O DE OLIVEIRA');
INSERT INTO "Professor" VALUES (486, 'HELENA CAVALCANTI DE ALBUQUERQUE');
INSERT INTO "Professor" VALUES (487, 'HELENA FERES HAWAD');
INSERT INTO "Professor" VALUES (488, 'HELENA FRANCO MARTINS');
INSERT INTO "Professor" VALUES (489, 'HELENE DE OLIVEIRA SHINOHARA');
INSERT INTO "Professor" VALUES (490, 'HELENE KLEINBERGER SALIM');
INSERT INTO "Professor" VALUES (491, 'HELENICE CHARCHAT FICHMAN');
INSERT INTO "Professor" VALUES (492, 'HELIO CORTES VIEIRA LOPES');
INSERT INTO "Professor" VALUES (493, 'HELOISA CARPENA VIEIRA DE MELLO');
INSERT INTO "Professor" VALUES (494, 'HELOISA MEIRELES GESTEIRA');
INSERT INTO "Professor" VALUES (495, 'HELVECIO DE CARVALHO COUTO');
INSERT INTO "Professor" VALUES (496, 'HENRIQUE BASTOS RAJAO REIS');
INSERT INTO "Professor" VALUES (497, 'HENRIQUE ESTRADA RODRIGUES');
INSERT INTO "Professor" VALUES (498, 'HENRIQUE GASPAR BARANDIER');
INSERT INTO "Professor" VALUES (499, 'HERMANO BRAGA V DE FREITAS FILHO');
INSERT INTO "Professor" VALUES (500, 'HERMES FREDERICO PINHO DE ARAUJO');
INSERT INTO "Professor" VALUES (501, 'HERMES GOMES DA SILVA FILHO');
INSERT INTO "Professor" VALUES (502, 'HERNANI HEFFNER');
INSERT INTO "Professor" VALUES (503, 'HILTON ESTEVES DE BERREDO');
INSERT INTO "Professor" VALUES (504, 'HIROSHI NUNOKAWA');
INSERT INTO "Professor" VALUES (505, 'HORISTA A CONTRATAR');
INSERT INTO "Professor" VALUES (506, 'HORTENCIO ALVES BORGES');
INSERT INTO "Professor" VALUES (507, 'HUGO FUKS');
INSERT INTO "Professor" VALUES (508, 'ICLEA REYS DE ORTIZ');
INSERT INTO "Professor" VALUES (509, 'ILDA LOPES RODRIGUES DA SILVA');
INSERT INTO "Professor" VALUES (510, 'ILMAR ROHLOFF DE MATTOS');
INSERT INTO "Professor" VALUES (511, 'ILZA MARIA FERREIRA PINTO AUTRAN');
INSERT INTO "Professor" VALUES (512, 'INES ALEGRIA ROCUMBACK');
INSERT INTO "Professor" VALUES (513, 'INES KAYON DE MILLER');
INSERT INTO "Professor" VALUES (514, 'INEZ TEREZINHA STAMPA');
INSERT INTO "Professor" VALUES (515, 'IONE BORGES FERREIRA VICENTE');
INSERT INTO "Professor" VALUES (516, 'IRENE RIZZINI');
INSERT INTO "Professor" VALUES (517, 'IRINA ARAGAO DOS SANTOS');
INSERT INTO "Professor" VALUES (518, 'IRINEU ZIBORDI');
INSERT INTO "Professor" VALUES (519, 'IRLEY FERNANDES FRANCO');
INSERT INTO "Professor" VALUES (520, 'IRMA ALMEIDA KLAUTAU LOPES');
INSERT INTO "Professor" VALUES (521, 'ISABEL ALICE OSWALD MONTEIRO LELIS');
INSERT INTO "Professor" VALUES (522, 'ISABEL CRISTINA DOS SANTOS CARVALHO');
INSERT INTO "Professor" VALUES (523, 'ISABEL MARIA NETO DA SILVA MOREIRA');
INSERT INTO "Professor" VALUES (524, 'ISABEL PARANHOS MONTEIRO');
INSERT INTO "Professor" VALUES (525, 'ISABELA FERNANDES SOARES LEITE');
INSERT INTO "Professor" VALUES (526, 'ISABELLA FRANCO GUERRA');
INSERT INTO "Professor" VALUES (527, 'ISAO NISHIOKA');
INSERT INTO "Professor" VALUES (528, 'ISIDORO MAZZAROLO');
INSERT INTO "Professor" VALUES (529, 'ISRAEL FONSECA NUNES JUNIOR');
INSERT INTO "Professor" VALUES (530, 'ISRAEL TABAK');
INSERT INTO "Professor" VALUES (531, 'ITALA MADUELL VIEIRA');
INSERT INTO "Professor" VALUES (532, 'IVALDO GONCALVES DE LIMA');
INSERT INTO "Professor" VALUES (533, 'IVAN FIRMINO SANTIAGO DA SILVA');
INSERT INTO "Professor" VALUES (534, 'IVAN MATHIAS FILHO');
INSERT INTO "Professor" VALUES (535, 'IVANA STOLZE LIMA');
INSERT INTO "Professor" VALUES (536, 'IVANI DE SOUZA BOTT');
INSERT INTO "Professor" VALUES (537, 'IZABEL MARGATO');
INSERT INTO "Professor" VALUES (538, 'IZABEL MARIA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (539, 'JACKELINE LIMA FARBIARZ');
INSERT INTO "Professor" VALUES (540, 'JAIME TUPIASSU PINHO DE CASTRO');
INSERT INTO "Professor" VALUES (541, 'JAIRO DA SILVA BOCHI');
INSERT INTO "Professor" VALUES (542, 'JAKELINE PRATA DE ASSIS PIRES');
INSERT INTO "Professor" VALUES (543, 'JANA TABAK CHOR');
INSERT INTO "Professor" VALUES (544, 'JAQUELINE PASSAMANI Z GUIMARAES');
INSERT INTO "Professor" VALUES (545, 'JEAN PIERRE VON DER WEID');
INSERT INTO "Professor" VALUES (546, 'JENURA CLOTILDE BOFF');
INSERT INTO "Professor" VALUES (547, 'JESUS HORTAL SANCHEZ');
INSERT INTO "Professor" VALUES (548, 'JESUS LANDEIRA FERNANDEZ');
INSERT INTO "Professor" VALUES (549, 'JOANA PESSOA');
INSERT INTO "Professor" VALUES (550, 'JOAO ANTONIO SILVEIRA LINS SUCUPIRA');
INSERT INTO "Professor" VALUES (551, 'JOAO BARBOSA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (552, 'JOAO BATISTA BERTHIER LEITE SOARES');
INSERT INTO "Professor" VALUES (553, 'JOAO BATTISTA BRUNO');
INSERT INTO "Professor" VALUES (554, 'JOAO CARLOS LAUFER CALAFATE');
INSERT INTO "Professor" VALUES (555, 'JOAO CARLOS RIBEIRO PLACIDO');
INSERT INTO "Professor" VALUES (556, 'JOAO DE SA BONELLI');
INSERT INTO "Professor" VALUES (557, 'JOAO DE SOUZA LEITE');
INSERT INTO "Professor" VALUES (558, 'JOAO FRANKLIN ABELARDO P NOGUEIRA');
INSERT INTO "Professor" VALUES (559, 'JOAO GERALDO MACHADO BELLOCCHIO');
INSERT INTO "Professor" VALUES (560, 'JOAO LUIZ DE FIGUEIREDO SILVA');
INSERT INTO "Professor" VALUES (561, 'JOAO LUIZ RENHA');
INSERT INTO "Professor" VALUES (562, 'JOAO MANOEL PINHO DE MELLO');
INSERT INTO "Professor" VALUES (563, 'JOAO MASAO KAMITA');
INSERT INTO "Professor" VALUES (564, 'JOAO MESTIERI');
INSERT INTO "Professor" VALUES (565, 'JOAO PAULO VIEIRA TINOCO');
INSERT INTO "Professor" VALUES (566, 'JOAO RENATO DE SOUZA COELHO BENAZZI');
INSERT INTO "Professor" VALUES (567, 'JOAO RICARDO WANDERLEY DORNELLES');
INSERT INTO "Professor" VALUES (568, 'JOAO ROBERTO LOPES PINTO');
INSERT INTO "Professor" VALUES (569, 'JOAO RUA');
INSERT INTO "Professor" VALUES (570, 'JOAO WANDER N DE ANNUNCIACAO');
INSERT INTO "Professor" VALUES (571, 'JOAQUIM DE SALLES REDIG DE CAMPOS');
INSERT INTO "Professor" VALUES (572, 'JOAQUIM MARCAL FERREIRA DE ANDRADE');
INSERT INTO "Professor" VALUES (573, 'JOB ELOISIO VIEIRA GOMES');
INSERT INTO "Professor" VALUES (574, 'JOEL PORTELLA AMADO');
INSERT INTO "Professor" VALUES (575, 'JORGE ALBERTO ZIETLOW DURO');
INSERT INTO "Professor" VALUES (576, 'JORGE BRANTES FERREIRA');
INSERT INTO "Professor" VALUES (577, 'JORGE FERREIRA DA SILVA');
INSERT INTO "Professor" VALUES (578, 'JORGE LANGONE');
INSERT INTO "Professor" VALUES (579, 'JORGE LUCAS FERREIRA');
INSERT INTO "Professor" VALUES (580, 'JORGE LUIZ CORDEIRO PAULO');
INSERT INTO "Professor" VALUES (581, 'JORGE LUIZ FONTANELLA');
INSERT INTO "Professor" VALUES (582, 'JORGE MANOEL TEIXEIRA CARNEIRO');
INSERT INTO "Professor" VALUES (583, 'JORGE ROBERTO LOPES DOS SANTOS');
INSERT INTO "Professor" VALUES (584, 'JORGE VIANNA MONTEIRO');
INSERT INTO "Professor" VALUES (585, 'JOSAFA CARLOS DE SIQUEIRA');
INSERT INTO "Professor" VALUES (586, 'JOSÃ‰ AGUSTO VEIGA DA COSTA MARQUES');
INSERT INTO "Professor" VALUES (587, 'JOSE ALBERTO DOS REIS PARISE');
INSERT INTO "Professor" VALUES (588, 'JOSE ANTONIO DE OLIVEIRA');
INSERT INTO "Professor" VALUES (589, 'JOSE ANTONIO ORTEGA');
INSERT INTO "Professor" VALUES (590, 'JOSE ANTONIO PIMENTA BUENO');
INSERT INTO "Professor" VALUES (591, 'JOSE AUGUSTO BRANDAO ESTELLITA LINS');
INSERT INTO "Professor" VALUES (592, 'JOSE CARLOS D ABREU');
INSERT INTO "Professor" VALUES (593, 'JOSE CARLOS MILLAN');
INSERT INTO "Professor" VALUES (594, 'JOSE CARLOS RAMALHO MOREIRA');
INSERT INTO "Professor" VALUES (595, 'JOSE CARLOS SOUZA RODRIGUES');
INSERT INTO "Professor" VALUES (596, 'JOSE CORREIA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (597, 'JOSE EUDES ARAUJO ALENCAR');
INSERT INTO "Professor" VALUES (598, 'JOSE EUGENIO LEAL');
INSERT INTO "Professor" VALUES (599, 'JOSE FEDERICO HESS VALDES');
INSERT INTO "Professor" VALUES (600, 'JOSE GUILHERME BERMAN CORREA PINTO');
INSERT INTO "Professor" VALUES (601, 'JOSE HENRIQUE DE CARVALHO');
INSERT INTO "Professor" VALUES (602, 'JOSE LUIZ DE FRANCA FREIRE');
INSERT INTO "Professor" VALUES (603, 'JOSE LUIZ MENDES RIPPER');
INSERT INTO "Professor" VALUES (604, 'JOSE MARCIO ANTONIO G DE CAMARGO');
INSERT INTO "Professor" VALUES (605, 'JOSE MARCUS DE OLIVEIRA GODOY');
INSERT INTO "Professor" VALUES (606, 'JOSE MARIA GOMEZ');
INSERT INTO "Professor" VALUES (607, 'JOSE MARIANI DE SA CARVALHO');
INSERT INTO "Professor" VALUES (608, 'JOSE MAURICIO PAIVA ANDION ARRUTI');
INSERT INTO "Professor" VALUES (609, 'JOSE MAURO PEDRO FORTES');
INSERT INTO "Professor" VALUES (610, 'JOSE NASCIMENTO ARAUJO NETTO');
INSERT INTO "Professor" VALUES (611, 'JOSE OTACIO OLIVEIRA GUEDES');
INSERT INTO "Professor" VALUES (612, 'JOSE OTAVIO VASCONCELLOS NAVES');
INSERT INTO "Professor" VALUES (613, 'JOSE PAULO SILVA DE PAULA');
INSERT INTO "Professor" VALUES (614, 'JOSE PAULO TEIXEIRA');
INSERT INTO "Professor" VALUES (615, 'JOSE RIBAS VIEIRA');
INSERT INTO "Professor" VALUES (616, 'JOSE RICARDO BERGMANN');
INSERT INTO "Professor" VALUES (617, 'JOSE ROBERTO BOISSON DE MARCA');
INSERT INTO "Professor" VALUES (618, 'JOSE ROBERTO DE CASTRO NEVES');
INSERT INTO "Professor" VALUES (619, 'JOSE ROBERTO MORAES D ALMEIDA');
INSERT INTO "Professor" VALUES (620, 'JOSE ROBERTO POTSCH DE C E SILVA');
INSERT INTO "Professor" VALUES (621, 'JOSE ROBERTO RODRIGUES DEVELLARD');
INSERT INTO "Professor" VALUES (622, 'JOSE ROBERTO SANSEVERINO');
INSERT INTO "Professor" VALUES (623, 'JOSE TAVARES ARARUNA JUNIOR');
INSERT INTO "Professor" VALUES (624, 'JOY HELENA WORMS TILL');
INSERT INTO "Professor" VALUES (625, 'JUAREZ DA SILVEIRA FIGUEIREDO');
INSERT INTO "Professor" VALUES (626, 'JUCARA DA SILVA BARBOSA DE MELLO');
INSERT INTO "Professor" VALUES (627, 'JULIA BLOOMFIELD GAMA ZARDO');
INSERT INTO "Professor" VALUES (628, 'JULIA FATIMA DE JESUS CRUZ');
INSERT INTO "Professor" VALUES (629, 'JULIAN FONSECA PENA CHEDIAK');
INSERT INTO "Professor" VALUES (630, 'JULIANA BRACKS DUARTE');
INSERT INTO "Professor" VALUES (631, 'JULIANA DE MELLO JABOR');
INSERT INTO "Professor" VALUES (632, 'JULIANO JUNQUEIRA ASSUNCAO');
INSERT INTO "Professor" VALUES (633, 'JULIETA COSTA SOBRAL');
INSERT INTO "Professor" VALUES (634, 'JULIO CESAR SAMPAIO DO PRADO LEITE');
INSERT INTO "Professor" VALUES (635, 'JULIO CESAR VALLADAO DINIZ');
INSERT INTO "Professor" VALUES (636, 'JULIO DE ALMEIDA LUBIANCO');
INSERT INTO "Professor" VALUES (637, 'JUNIA DE VILHENA');
INSERT INTO "Professor" VALUES (638, 'JUSSARA FRANCISCA DE ASSIS');
INSERT INTO "Professor" VALUES (639, 'JUSTINO ARTUR FERRAZ VIEIRA');
INSERT INTO "Professor" VALUES (640, 'KAI ENNO LEHMANN');
INSERT INTO "Professor" VALUES (641, 'KAI MICHAEL KENKEL');
INSERT INTO "Professor" VALUES (642, 'KARIN KOOGAN BREITMAN');
INSERT INTO "Professor" VALUES (643, 'KARINA SILVEIRA MARTINS DE ARAUJO');
INSERT INTO "Professor" VALUES (644, 'KARL ERIK SCHOLLHAMMER');
INSERT INTO "Professor" VALUES (645, 'KARLA TEREZA FIGUEIREDO LEITE');
INSERT INTO "Professor" VALUES (646, 'KATIA ANCORA DA LUZ');
INSERT INTO "Professor" VALUES (647, 'KATIA MARIA CARLOS ROCHA');
INSERT INTO "Professor" VALUES (648, 'KATIA REGINA DA COSTA SILVA CIOTOLA');
INSERT INTO "Professor" VALUES (649, 'KATIA RODRIGUES MURICY');
INSERT INTO "Professor" VALUES (650, 'KHOSROW GHAVAMI');
INSERT INTO "Professor" VALUES (651, 'LAURO DA GAMA E SOUZA JUNIOR');
INSERT INTO "Professor" VALUES (652, 'LEA MARA BENATTI ASSAID');
INSERT INTO "Professor" VALUES (653, 'LEANDRO SANTOS ABRANTES');
INSERT INTO "Professor" VALUES (654, 'LEANE CORNET NAIDIN');
INSERT INTO "Professor" VALUES (655, 'LEILA BEATRIZ DA SILVA SILVEIRA');
INSERT INTO "Professor" VALUES (656, 'LEILA MATHIAS COSTA');
INSERT INTO "Professor" VALUES (657, 'LEILA MENEZES DUARTE');
INSERT INTO "Professor" VALUES (658, 'LEISE TAVEIRA DOS SANTOS');
INSERT INTO "Professor" VALUES (659, 'LENIRA PEREIRA PINTO ALCURE');
INSERT INTO "Professor" VALUES (660, 'LENIVALDO GOMES DE ALMEIDA');
INSERT INTO "Professor" VALUES (661, 'LEONARDO AFFONSO DE MIRANDA PEREIRA');
INSERT INTO "Professor" VALUES (662, 'LEONARDO AGOSTINI FERNANDES');
INSERT INTO "Professor" VALUES (663, 'LEONARDO BANDEIRA REZENDE');
INSERT INTO "Professor" VALUES (664, 'LEONARDO BERENGER ALVES CARNEIRO');
INSERT INTO "Professor" VALUES (665, 'LEONARDO CARDARELLI LEITE');
INSERT INTO "Professor" VALUES (666, 'LEONARDO COSTA RANGEL');
INSERT INTO "Professor" VALUES (667, 'LEONARDO DE SOUZA CHAVES');
INSERT INTO "Professor" VALUES (668, 'LEONARDO DOS PASSOS MIRANDA NAME');
INSERT INTO "Professor" VALUES (669, 'LEONARDO DUNCAN MOREIRA LIMA');
INSERT INTO "Professor" VALUES (670, 'LEONARDO JUNQUEIRA LUSTOSA');
INSERT INTO "Professor" VALUES (671, 'LEONARDO LIMA GOMES');
INSERT INTO "Professor" VALUES (672, 'LEONARDO SCHLESINGER CAVALCANTI');
INSERT INTO "Professor" VALUES (673, 'LEONEL AZEVEDO DE AGUIAR');
INSERT INTO "Professor" VALUES (674, 'LEONIDAS AUGUSTO CORREIA DE MORAES');
INSERT INTO "Professor" VALUES (675, 'LETICIA CARVALHO DE M FERREIRA');
INSERT INTO "Professor" VALUES (676, 'LETICIA CARVALHO DE SOUZA');
INSERT INTO "Professor" VALUES (677, 'LETICIA DA COSTA PAES');
INSERT INTO "Professor" VALUES (678, 'LETICIA DE ABREU PINHEIRO');
INSERT INTO "Professor" VALUES (679, 'LETICIA DE CAMPOS VELHO MARTEL');
INSERT INTO "Professor" VALUES (680, 'LETICIA HEES ALVES');
INSERT INTO "Professor" VALUES (681, 'LETICIA MARIA SICURO CORREA');
INSERT INTO "Professor" VALUES (682, 'LIANA RIBEIRO DOS SANTOS');
INSERT INTO "Professor" VALUES (683, 'LIDIA LEVY DE ALVARENGA');
INSERT INTO "Professor" VALUES (684, 'LIGIA AMORIM RIZZO');
INSERT INTO "Professor" VALUES (685, 'LIGIA TERESA SARAMAGO PADUA');
INSERT INTO "Professor" VALUES (686, 'LILA CAROLINA MOTA PESSOA I LOPES');
INSERT INTO "Professor" VALUES (687, 'LILIAN SABACK DE SA MORAES');
INSERT INTO "Professor" VALUES (688, 'LILIANA CABRAL BASTOS');
INSERT INTO "Professor" VALUES (689, 'LILIANE RUTH HEYNEMANN');
INSERT INTO "Professor" VALUES (690, 'LINCOLN WOLF DE ALMEIDA NEVES');
INSERT INTO "Professor" VALUES (691, 'LIVIA FRANCA SALLES');
INSERT INTO "Professor" VALUES (692, 'LORENZO JUSTINIANO DIAZ CASADO');
INSERT INTO "Professor" VALUES (693, 'LUCA SCALA');
INSERT INTO "Professor" VALUES (694, 'LUCAS BENDER CARPENA DE M P GARCIA');
INSERT INTO "Professor" VALUES (695, 'LUCIA GOMES RIBEIRO');
INSERT INTO "Professor" VALUES (696, 'LUCIA PEDROSA DE PADUA');
INSERT INTO "Professor" VALUES (697, 'LUCIANA AZEVEDO PEREIRA');
INSERT INTO "Professor" VALUES (698, 'LUCIANA BADIN PEREIRA LIMA');
INSERT INTO "Professor" VALUES (699, 'LUCIANA BORGERTH VIAL CORREA');
INSERT INTO "Professor" VALUES (700, 'LUCIANA BRAFMAN');
INSERT INTO "Professor" VALUES (701, 'LUCIANA LOMBARDO COSTA PEREIRA');
INSERT INTO "Professor" VALUES (702, 'LUCIANA ROCHA DE MAGALHAES BARROS');
INSERT INTO "Professor" VALUES (703, 'LUCIANO PEREIRA SOARES');
INSERT INTO "Professor" VALUES (704, 'LUCIANO ROSA ALONSO ALVARES');
INSERT INTO "Professor" VALUES (705, 'LUCIANO VIANNA ARAUJO');
INSERT INTO "Professor" VALUES (706, 'LUCIANO XIMENES ARAGAO');
INSERT INTO "Professor" VALUES (707, 'LUCIENE ALCINDA DE MEDEIROS');
INSERT INTO "Professor" VALUES (708, 'LUCY CARLINDA DA ROCHA DE NIEMEYER');
INSERT INTO "Professor" VALUES (709, 'LUDOVIC SOUTIF');
INSERT INTO "Professor" VALUES (710, 'LUDOVICO GARMUS');
INSERT INTO "Professor" VALUES (711, 'LUIS ALEXANDRE GRUBITS DE P PESSOA');
INSERT INTO "Professor" VALUES (712, 'LUIS CANDIDO GOMES DE CAMPOS');
INSERT INTO "Professor" VALUES (713, 'LUIS CARLOS SOARES M DOMINGUES');
INSERT INTO "Professor" VALUES (714, 'LUIS CORREA LIMA');
INSERT INTO "Professor" VALUES (715, 'LUIS EDUARDO FERREIRA B MOREIRA');
INSERT INTO "Professor" VALUES (716, 'LUIS FELIPE SAO THIAGO DE CARVALHO');
INSERT INTO "Professor" VALUES (717, 'LUIS FERNANDO ALZUGUIR AZEVEDO');
INSERT INTO "Professor" VALUES (718, 'LUIS FERNANDO FIGUEIRA DA SILVA');
INSERT INTO "Professor" VALUES (719, 'LUIS FERNANDO HOR MEYLL ALVARES');
INSERT INTO "Professor" VALUES (720, 'LUIS FILIPE ROSSI');
INSERT INTO "Professor" VALUES (721, 'LUIS GLAUBER RODRIGUES');
INSERT INTO "Professor" VALUES (722, 'LUIS MANUEL REBELO FERNANDES');
INSERT INTO "Professor" VALUES (723, 'LUIS NACHBIN');
INSERT INTO "Professor" VALUES (724, 'LUIS REZNIK');
INSERT INTO "Professor" VALUES (725, 'LUIS VICENTE BARROS CARDOSO DE MELO');
INSERT INTO "Professor" VALUES (726, 'LUISA CHAVES DE MELO');
INSERT INTO "Professor" VALUES (727, 'LUISA SEVERO BUARQUE DE HOLANDA');
INSERT INTO "Professor" VALUES (728, 'LUIZ ALBERTO CESAR TEIXEIRA');
INSERT INTO "Professor" VALUES (729, 'LUIZ ALENCAR REIS DA SILVA MELLO');
INSERT INTO "Professor" VALUES (730, 'LUIZ ANTONIO LUZIO COELHO');
INSERT INTO "Professor" VALUES (731, 'LUIZ ANTONIO PEREIRA DE GUSMAO');
INSERT INTO "Professor" VALUES (732, 'LUIZ ARANHA CORREA DO LAGO');
INSERT INTO "Professor" VALUES (733, 'LUIZ CAMILLO D P O DE ALMEIDA');
INSERT INTO "Professor" VALUES (734, 'LUIZ CARLOS BARROS DE FREITAS');
INSERT INTO "Professor" VALUES (735, 'LUIZ CARLOS CARDOSO');
INSERT INTO "Professor" VALUES (736, 'LUIZ CARLOS PINHEIRO DIAS PEREIRA');
INSERT INTO "Professor" VALUES (737, 'LUIZ CLAUDIO SALLES CRISTOFARO');
INSERT INTO "Professor" VALUES (738, 'LUIZ EDUARDO DUTRA COELHO DA ROCHA');
INSERT INTO "Professor" VALUES (739, 'LUIZ EDUARDO MELIN C E SILVA');
INSERT INTO "Professor" VALUES (740, 'LUIZ EDUARDO TEIXEIRA BRANDAO');
INSERT INTO "Professor" VALUES (741, 'LUIZ EMYGDIO FRANCO DA ROSA JUNIOR');
INSERT INTO "Professor" VALUES (742, 'LUIZ FELIPE GUANAES REGO');
INSERT INTO "Professor" VALUES (743, 'LUIZ FELIPE JACQUES DA MOTTA');
INSERT INTO "Professor" VALUES (744, 'LUIZ FELIPE RORIS R S DO CARMO');
INSERT INTO "Professor" VALUES (745, 'LUIZ FERNANDO ALMEIDA PEREIRA');
INSERT INTO "Professor" VALUES (746, 'LUIZ FERNANDO BESSA SEIBEL');
INSERT INTO "Professor" VALUES (747, 'LUIZ FERNANDO CAMPOS RAMOS MARTHA');
INSERT INTO "Professor" VALUES (748, 'LUIZ FERNANDO FAVILLA CARRILHO');
INSERT INTO "Professor" VALUES (749, 'LUIZ FERNANDO GOMES SOARES');
INSERT INTO "Professor" VALUES (750, 'LUIZ FERNANDO RIBEIRO SANTANA');
INSERT INTO "Professor" VALUES (751, 'LUIZ FERNANDO VOSS CHAGAS LESSA');
INSERT INTO "Professor" VALUES (752, 'LUIZ FRANCISCO FERREIRA LEO');
INSERT INTO "Professor" VALUES (753, 'LUIZ HENRIQUE ABREU DAL BELLO');
INSERT INTO "Professor" VALUES (754, 'LUIZ JORGE WERNECK VIANNA');
INSERT INTO "Professor" VALUES (755, 'LUIZ PAULO MOREIRA LIMA');
INSERT INTO "Professor" VALUES (756, 'LUIZ PAULO VELLOZO LUCAS');
INSERT INTO "Professor" VALUES (757, 'LUIZ ROBERTO AZEVEDO CUNHA');
INSERT INTO "Professor" VALUES (758, 'LUIZA DE SOUZA E SILVA MARTINS');
INSERT INTO "Professor" VALUES (759, 'LUIZA FERREIRA DE SOUZA LEITE');
INSERT INTO "Professor" VALUES (760, 'LUIZA FERRO COSTA MARCIER');
INSERT INTO "Professor" VALUES (761, 'LUIZA HELENA NUNES ERMEL');
INSERT INTO "Professor" VALUES (762, 'LUIZA MARIA INTERLENGHI');
INSERT INTO "Professor" VALUES (763, 'LUIZA NOVAES');
INSERT INTO "Professor" VALUES (764, 'MADALENA RAMIREZ SAPUCAIA');
INSERT INTO "Professor" VALUES (765, 'MAIRA MACHADO MARTINS');
INSERT INTO "Professor" VALUES (766, 'MAIRA SIMAN GOMES');
INSERT INTO "Professor" VALUES (767, 'MANOEL MARQUES DA COSTA BRAGA NETO');
INSERT INTO "Professor" VALUES (768, 'MANOEL MESSIAS PEIXINHO');
INSERT INTO "Professor" VALUES (769, 'MANOEL VARGAS FRANCO NETTO');
INSERT INTO "Professor" VALUES (770, 'MANUEL ANGEL FERNANDEZ SUAREZ');
INSERT INTO "Professor" VALUES (771, 'MANUEL DE OLIVEIRA MANANGAO');
INSERT INTO "Professor" VALUES (772, 'MANUEL FIASCHI');
INSERT INTO "Professor" VALUES (773, 'MARACY DOMINGUES ALVES');
INSERT INTO "Professor" VALUES (774, 'MARBEY MANHAES MOSSO');
INSERT INTO "Professor" VALUES (775, 'MARCANTONIO GIUSEPPE MARIA C FABRA');
INSERT INTO "Professor" VALUES (776, 'MARCELA COHEN MARTELOTTE');
INSERT INTO "Professor" VALUES (777, 'MARCELA FIGUEIREDO C DE OLIVEIRA');
INSERT INTO "Professor" VALUES (778, 'MARCELA MELO AMORIM');
INSERT INTO "Professor" VALUES (779, 'MARCELLO RAPOSO CIOTOLA');
INSERT INTO "Professor" VALUES (780, 'MARCELLO SORRENTINO');
INSERT INTO "Professor" VALUES (781, 'MARCELO CABUS KLOTZLE');
INSERT INTO "Professor" VALUES (782, 'MARCELO CUNHA MEDEIROS');
INSERT INTO "Professor" VALUES (783, 'MARCELO DE ANDRADE DREUX');
INSERT INTO "Professor" VALUES (784, 'MARCELO DE PAIVA ABREU');
INSERT INTO "Professor" VALUES (785, 'MARCELO EDUARDO HUGUENIN M DA COSTA');
INSERT INTO "Professor" VALUES (786, 'MARCELO FERNANDES PEREIRA');
INSERT INTO "Professor" VALUES (787, 'MARCELO FERNANDEZ PINEIRO');
INSERT INTO "Professor" VALUES (788, 'MARCELO FERNANDEZ TRINDADE');
INSERT INTO "Professor" VALUES (789, 'MARCELO GANTUS JASMIN');
INSERT INTO "Professor" VALUES (790, 'MARCELO GATTASS');
INSERT INTO "Professor" VALUES (791, 'MARCELO GHIARONI DE A E SILVA');
INSERT INTO "Professor" VALUES (792, 'MARCELO GUSTAVO ANDRADE DE SOUZA');
INSERT INTO "Professor" VALUES (793, 'MARCELO JUNQUEIRA CALIXTO');
INSERT INTO "Professor" VALUES (794, 'MARCELO KISCHINHEVSKY');
INSERT INTO "Professor" VALUES (795, 'MARCELO MASSAHARU HATAKEYAMA');
INSERT INTO "Professor" VALUES (796, 'MARCELO MOTTA DE FREITAS');
INSERT INTO "Professor" VALUES (797, 'MARCELO NUNO CARNEIRO DE SOUSA');
INSERT INTO "Professor" VALUES (798, 'MARCELO ROBERTO DE CARVALHO FERRO');
INSERT INTO "Professor" VALUES (799, 'MARCELO ROBERTO V D DE M BEZERRA');
INSERT INTO "Professor" VALUES (800, 'MARCELO ROBERTO VELLOZO A AZEVEDO');
INSERT INTO "Professor" VALUES (801, 'MARCELO TADEU BAUMANN BURGOS');
INSERT INTO "Professor" VALUES (802, 'MARCELO VERDINI MAIA');
INSERT INTO "Professor" VALUES (803, 'MARCIA ANTABI');
INSERT INTO "Professor" VALUES (804, 'MARCIA DO AMARAL PEIXOTO MARTINS');
INSERT INTO "Professor" VALUES (805, 'MARCIA GUARISCHI CORTES');
INSERT INTO "Professor" VALUES (806, 'MARCIA GUERRA PEREIRA');
INSERT INTO "Professor" VALUES (807, 'MARCIA LOBIANCO VICENTE AMORIM');
INSERT INTO "Professor" VALUES (808, 'MARCIA NINA BERNARDES');
INSERT INTO "Professor" VALUES (809, 'MARCIA OLIVE NOVELLINO');
INSERT INTO "Professor" VALUES (810, 'MARCIO ANTONIO SCALERCIO');
INSERT INTO "Professor" VALUES (811, 'MARCIO DA SILVEIRA CARVALHO');
INSERT INTO "Professor" VALUES (812, 'MARCIO GOMES PINTO GARCIA');
INSERT INTO "Professor" VALUES (813, 'MARCIO NUNES DA SILVA');
INSERT INTO "Professor" VALUES (814, 'MARCIO PEZZELLA FERREIRA');
INSERT INTO "Professor" VALUES (815, 'MARCIO RIBEIRO R DE OLIVEIRA');
INSERT INTO "Professor" VALUES (816, 'MARCIO VIEIRA SOUTO COSTA FERREIRA');
INSERT INTO "Professor" VALUES (817, 'MARCIUS HOLLANDA PEREIRA DA ROCHA');
INSERT INTO "Professor" VALUES (818, 'MARCO ALEXANDRE DE OLIVEIRA');
INSERT INTO "Professor" VALUES (819, 'MARCO ANTONIO CASANOVA');
INSERT INTO "Professor" VALUES (820, 'MARCO ANTONIO GOMES TEIXEIRA');
INSERT INTO "Professor" VALUES (821, 'MARCO ANTONIO GRIVET MATTOSO MAIA');
INSERT INTO "Professor" VALUES (822, 'MARCO ANTONIO GUIMARAES DIAS');
INSERT INTO "Professor" VALUES (823, 'MARCO ANTONIO GUSMAO BONELLI');
INSERT INTO "Professor" VALUES (824, 'MARCO ANTONIO MAGALHAES LIMA');
INSERT INTO "Professor" VALUES (825, 'MARCO ANTONIO MAIA FONSECA');
INSERT INTO "Professor" VALUES (826, 'MARCO ANTONIO MEGGIOLARO');
INSERT INTO "Professor" VALUES (827, 'MARCO ANTONIO VILLELA PAMPLONA');
INSERT INTO "Professor" VALUES (828, 'MARCO AURELIO CAVALCANTI PACHECO');
INSERT INTO "Professor" VALUES (829, 'MARCO AURELIO DE SA RIBEIRO');
INSERT INTO "Professor" VALUES (830, 'MARCO AURELIO FAGUNDES ALBERNAZ');
INSERT INTO "Professor" VALUES (831, 'MARCO CREMONA');
INSERT INTO "Professor" VALUES (832, 'MARCOS AMARANTE DE A MAGALHAES');
INSERT INTO "Professor" VALUES (833, 'MARCOS ANTONIO DE SANTANA');
INSERT INTO "Professor" VALUES (834, 'MARCOS COHEN');
INSERT INTO "Professor" VALUES (835, 'MARCOS CRAIZER');
INSERT INTO "Professor" VALUES (836, 'MARCOS GUEDES VENEU');
INSERT INTO "Professor" VALUES (837, 'MARCOS LOPEZ REGO');
INSERT INTO "Professor" VALUES (838, 'MARCOS LUIS BARBATO');
INSERT INTO "Professor" VALUES (839, 'MARCOS OSMAR FAVERO');
INSERT INTO "Professor" VALUES (840, 'MARCOS SEBASTIAO DE PAULA GOMES');
INSERT INTO "Professor" VALUES (841, 'MARCOS VENICIUS SOARES PEREIRA');
INSERT INTO "Professor" VALUES (842, 'MARCOS VIANNA VILLAS');
INSERT INTO "Professor" VALUES (843, 'MARCOS VINICIO MIRANDA VIEIRA');
INSERT INTO "Professor" VALUES (844, 'MARCOS WILLIAM BERNARDO');
INSERT INTO "Professor" VALUES (845, 'MARCUS ANDRE VIEIRA');
INSERT INTO "Professor" VALUES (846, 'MARCUS VINICIUS S P DE ARAGAO');
INSERT INTO "Professor" VALUES (847, 'MARCUS WILCOX HEMAIS');
INSERT INTO "Professor" VALUES (848, 'MARCYLENE DE OLIVEIRA CAPPER');
INSERT INTO "Professor" VALUES (849, 'MARGARETH AMOROSO DE MESQUITA');
INSERT INTO "Professor" VALUES (850, 'MARGARIDA MARIA DE PAULA BASILIO');
INSERT INTO "Professor" VALUES (851, 'MARIA ADELAIDE FERREIRA GOMES');
INSERT INTO "Professor" VALUES (852, 'MARIA ALICE REZENDE DE CARVALHO');
INSERT INTO "Professor" VALUES (853, 'MARIA ANGELA CAMPELO DE MELO');
INSERT INTO "Professor" VALUES (854, 'MARIA ANGELICA OLIVEIRA LUQUEZE');
INSERT INTO "Professor" VALUES (855, 'MARIA CARMEN CASTANHEIRA AVELAR');
INSERT INTO "Professor" VALUES (856, 'MARIA CECILIA DE CARVALHO CHAVES');
INSERT INTO "Professor" VALUES (857, 'MARIA CECILIA GONSALVES CARVALHO');
INSERT INTO "Professor" VALUES (858, 'MARIA CELINA BODIN DE MORAES');
INSERT INTO "Professor" VALUES (859, 'MARIA CELINA IBAZETA');
INSERT INTO "Professor" VALUES (860, 'MARIA CELINA SOARES D ARAUJO');
INSERT INTO "Professor" VALUES (861, 'MARIA CLARA LUCCHETTI BINGEMER');
INSERT INTO "Professor" VALUES (862, 'MARIA CLAUDIA BOLSHAW GOMES');
INSERT INTO "Professor" VALUES (863, 'MARIA CLAUDIA DE FREITAS');
INSERT INTO "Professor" VALUES (864, 'MARIA CRISTINA ASSUMPCAO CARNEIRO');
INSERT INTO "Professor" VALUES (865, 'MARIA CRISTINA BRAVO DE MORAES');
INSERT INTO "Professor" VALUES (866, 'MARIA CRISTINA CARDOSO RIBAS');
INSERT INTO "Professor" VALUES (867, 'MARIA CRISTINA G DE G MONTEIRO');
INSERT INTO "Professor" VALUES (868, 'MARIA CRISTINA M P DE CARVALHO');
INSERT INTO "Professor" VALUES (869, 'MARIA CRISTINA RIBEIRO CARVALHO');
INSERT INTO "Professor" VALUES (870, 'MARIA DA GRACA SALGADO');
INSERT INTO "Professor" VALUES (871, 'MARIA DAS GRACAS DE ALMEIDA CHAGAS');
INSERT INTO "Professor" VALUES (872, 'MARIA DAS GRACAS DIAS PEREIRA');
INSERT INTO "Professor" VALUES (873, 'MARIA DE FATIMA DUARTE H DOS SANTOS');
INSERT INTO "Professor" VALUES (874, 'MARIA DE LOURDES CORREA LIMA');
INSERT INTO "Professor" VALUES (875, 'MARIA DE NAZARETH MACIEL');
INSERT INTO "Professor" VALUES (876, 'MARIA DO CARMO LEITE DE OLIVEIRA');
INSERT INTO "Professor" VALUES (877, 'MARIA ELENA GAVA REDDO ALVES');
INSERT INTO "Professor" VALUES (878, 'MARIA ELENA RODRIGUEZ ORTIZ');
INSERT INTO "Professor" VALUES (879, 'MARIA ELISA NORONHA DE SA MADER');
INSERT INTO "Professor" VALUES (880, 'MARIA ELIZABETH FREIRE SALVADOR');
INSERT INTO "Professor" VALUES (881, 'MARIA ELIZABETH RIBEIRO DOS SANTOS');
INSERT INTO "Professor" VALUES (882, 'MARIA EUCHARES DE SENNA MOTTA');
INSERT INTO "Professor" VALUES (883, 'MARIA FATIMA LUDOVICO DE ALMEIDA');
INSERT INTO "Professor" VALUES (884, 'MARIA FERNANDA F DE OLIVEIRA');
INSERT INTO "Professor" VALUES (885, 'MARIA FERNANDA REZENDE NUNES');
INSERT INTO "Professor" VALUES (886, 'MARIA FERNANDA RODRIGUES C LEMOS');
INSERT INTO "Professor" VALUES (887, 'MARIA HELENA DE SOUZA TAVARES');
INSERT INTO "Professor" VALUES (888, 'MARIA HELENA RODRIGUES NAVAS ZAMORA');
INSERT INTO "Professor" VALUES (889, 'MARIA INES GALVAO FLORES M DE SOUZA');
INSERT INTO "Professor" VALUES (890, 'MARIA INES GARCIA DE F BITTENCOURT');
INSERT INTO "Professor" VALUES (891, 'MARIA INES GURJAO');
INSERT INTO "Professor" VALUES (892, 'MARIA ISABEL MENDES DE ALMEIDA');
INSERT INTO "Professor" VALUES (893, 'MARIA ISABEL MONTEIRO F BARRETO');
INSERT INTO "Professor" VALUES (894, 'MARIA ISABEL PAIS DA SILVA');
INSERT INTO "Professor" VALUES (895, 'MARIA LUCIA DE PAULA OLIVEIRA');
INSERT INTO "Professor" VALUES (896, 'MARIA LUIZA CAMPOS DA SILVA VALENTE');
INSERT INTO "Professor" VALUES (897, 'MARIA LUIZA GOMES TEIXEIRA');
INSERT INTO "Professor" VALUES (898, 'MARIA MAGDALENA LYRA DA SILVA');
INSERT INTO "Professor" VALUES (899, 'MARIA MANUELA RUPP QUARESMA');
INSERT INTO "Professor" VALUES (900, 'MARIA PAULA FROTA');
INSERT INTO "Professor" VALUES (901, 'MARIA REGINA SARAIVA P VELASCO');
INSERT INTO "Professor" VALUES (902, 'MARIA RITA PASSERI SALOMAO');
INSERT INTO "Professor" VALUES (903, 'MARIA SARAH DA SILVA TELLES');
INSERT INTO "Professor" VALUES (904, 'MARIA SUELY MONTEIRO CALDAS');
INSERT INTO "Professor" VALUES (905, 'MARIA TERESA DE FREITAS CARDOSO');
INSERT INTO "Professor" VALUES (906, 'MARIA TEREZA CHAVES DE MELLO');
INSERT INTO "Professor" VALUES (907, 'MARIANA CUSTODIO DO NASCIMENTO LAGO');
INSERT INTO "Professor" VALUES (908, 'MARIANA DE MORAES B P ALBUQUERQUE');
INSERT INTO "Professor" VALUES (909, 'MARIANA DE MORAES PALMEIRA');
INSERT INTO "Professor" VALUES (910, 'MARIANA TROTTA DALLALANA QUINTANS');
INSERT INTO "Professor" VALUES (911, 'MARIANGELA DA SILVA MONTEIRO');
INSERT INTO "Professor" VALUES (912, 'MARIANNA MONTEBELLO WILLEMAN');
INSERT INTO "Professor" VALUES (913, 'MARIE GEORGIANA JOSEPHINE V VIDAL');
INSERT INTO "Professor" VALUES (914, 'MARILENE PEREIRA LOPES');
INSERT INTO "Professor" VALUES (915, 'MARILIA ROTHIER CARDOSO');
INSERT INTO "Professor" VALUES (916, 'MARILIA SOARES MARTINS');
INSERT INTO "Professor" VALUES (917, 'MARINA DE ALMEIDA REGO F DE MELLO');
INSERT INTO "Professor" VALUES (918, 'MARIO ANTONIO PINHEIRO BITENCOURT');
INSERT INTO "Professor" VALUES (919, 'MARIO DE FRANCA MIRANDA');
INSERT INTO "Professor" VALUES (920, 'MARIO DOMINGUES DE PAULA SIMOES');
INSERT INTO "Professor" VALUES (921, 'MARIO GORDILHO FRAGA');
INSERT INTO "Professor" VALUES (922, 'MARIO LUIZ MENEZES GONCALVES');
INSERT INTO "Professor" VALUES (923, 'MARIO ROBERTO CARVALHO DE FARIA');
INSERT INTO "Professor" VALUES (924, 'MARIO RODRIGUES NETO');
INSERT INTO "Professor" VALUES (925, 'MARIVANI DE OLIVEIRA DE A PEREIRA');
INSERT INTO "Professor" VALUES (926, 'MARKUS ENDLER');
INSERT INTO "Professor" VALUES (927, 'MARLENE SABINO PONTES');
INSERT INTO "Professor" VALUES (928, 'MARLEY MARIA BERNARDES R VELLASCO');
INSERT INTO "Professor" VALUES (929, 'MARLI SOUZA COSTA DE CASTRO');
INSERT INTO "Professor" VALUES (930, 'MARTA DE SOUZA LIMA VELASCO');
INSERT INTO "Professor" VALUES (931, 'MARTA REGINA FERNANDEZ Y G MORENO');
INSERT INTO "Professor" VALUES (932, 'MAURA IGLESIAS');
INSERT INTO "Professor" VALUES (933, 'MAURICIO BARRETO ALVAREZ PARADA');
INSERT INTO "Professor" VALUES (934, 'MAURICIO CORTEZ REIS');
INSERT INTO "Professor" VALUES (935, 'MAURICIO DE ALBUQUERQUE ROCHA');
INSERT INTO "Professor" VALUES (936, 'MAURICIO LEONARDO TOREM');
INSERT INTO "Professor" VALUES (937, 'MAURICIO NOGUEIRA FROTA');
INSERT INTO "Professor" VALUES (938, 'MAURICIO REIS VIANA FILHO');
INSERT INTO "Professor" VALUES (939, 'MAURO JOSE DE SOUZA SILVEIRA');
INSERT INTO "Professor" VALUES (940, 'MAURO SCHWANKE DA SILVA');
INSERT INTO "Professor" VALUES (941, 'MAURO SPERANZA NETO');
INSERT INTO "Professor" VALUES (942, 'MELANIE DIMANTAS');
INSERT INTO "Professor" VALUES (943, 'MELISSA LEMOS CAVALIERE');
INSERT INTO "Professor" VALUES (944, 'MELVIN BADRA BENNESBY');
INSERT INTO "Professor" VALUES (945, 'MIA ALESSANDRA DE SOUZA REIS');
INSERT INTO "Professor" VALUES (946, 'MICHELE DAL TOE CASAGRANDE');
INSERT INTO "Professor" VALUES (947, 'MIGUEL BORBA DE SA');
INSERT INTO "Professor" VALUES (948, 'MIGUEL MEDEIROS FERREIRA GOMES');
INSERT INTO "Professor" VALUES (949, 'MIGUEL NATHAN FOGUEL');
INSERT INTO "Professor" VALUES (950, 'MIGUEL SERPA PEREIRA');
INSERT INTO "Professor" VALUES (951, 'MILA DESOUZART DE AQUINO VIANA');
INSERT INTO "Professor" VALUES (952, 'MIRIAM SUTTER MEDEIROS');
INSERT INTO "Professor" VALUES (953, 'MOEMA FALCI LOURES');
INSERT INTO "Professor" VALUES (954, 'MOISES HENRIQUE SZWARCMAN');
INSERT INTO "Professor" VALUES (955, 'MONAH WINOGRAD');
INSERT INTO "Professor" VALUES (956, 'MONICA BAPTISTA CAMPOS');
INSERT INTO "Professor" VALUES (957, 'MONICA BAUMGARTEN DE BOLLE');
INSERT INTO "Professor" VALUES (958, 'MONICA FEIJO NACCACHE');
INSERT INTO "Professor" VALUES (959, 'MONICA FROTA LEAO FEITOSA');
INSERT INTO "Professor" VALUES (960, 'MONICA HERZ');
INSERT INTO "Professor" VALUES (961, 'MONICA SABOIA SADDI');
INSERT INTO "Professor" VALUES (962, 'MONICA SAMPAIO MACHADO');
INSERT INTO "Professor" VALUES (963, 'MURILO SEBE BON MEIHY');
INSERT INTO "Professor" VALUES (964, 'MYRIAN SERTA COSTA');
INSERT INTO "Professor" VALUES (965, 'NADIA DE ARAUJO');
INSERT INTO "Professor" VALUES (966, 'NATHALIA CHEHAB DE SA CAVALCANTE');
INSERT INTO "Professor" VALUES (967, 'NATHALIA MUSSI WEIDLICH');
INSERT INTO "Professor" VALUES (968, 'NEISE RIBEIRO VIEIRA');
INSERT INTO "Professor" VALUES (969, 'NELIO DOMINGUES PIZZOLATO');
INSERT INTO "Professor" VALUES (970, 'NELSON INOUE');
INSERT INTO "Professor" VALUES (971, 'NEY AUGUSTO DUMONT');
INSERT INTO "Professor" VALUES (972, 'NEY COSTA SANTOS FILHO');
INSERT INTO "Professor" VALUES (973, 'NEY ROBERTO DHEIN');
INSERT INTO "Professor" VALUES (974, 'NICHOLAS GREENWOOD ONUF');
INSERT INTO "Professor" VALUES (975, 'NICOLAS ADRIAN REY');
INSERT INTO "Professor" VALUES (976, 'NICOLAU CORCAO SALDANHA');
INSERT INTO "Professor" VALUES (977, 'NILTON GONCALVES GAMBA JUNIOR');
INSERT INTO "Professor" VALUES (978, 'NOEL STRUCHINER');
INSERT INTO "Professor" VALUES (979, 'NOEMI DE LA ROCQUE RODRIGUEZ');
INSERT INTO "Professor" VALUES (980, 'NORMA JONSSEN PARENTE');
INSERT INTO "Professor" VALUES (981, 'NORMA MOREIRA SALGADO FRANCO');
INSERT INTO "Professor" VALUES (982, 'OSCAR GRACA COUTO NETO');
INSERT INTO "Professor" VALUES (983, 'OSWALDO CHATEAUBRIAND FILHO');
INSERT INTO "Professor" VALUES (984, 'OTAVIO AUGUSTO DE CASTRO BRAVO');
INSERT INTO "Professor" VALUES (985, 'OTAVIO LEONIDIO RIBEIRO');
INSERT INTO "Professor" VALUES (986, 'PABLO WALDEMAR RENTERIA');
INSERT INTO "Professor" VALUES (987, 'PATRICIA AMELIA TOMEI');
INSERT INTO "Professor" VALUES (988, 'PATRICIA ITALA FERREIRA');
INSERT INTO "Professor" VALUES (989, 'PATRICIA LUSTOZA DE SOUZA');
INSERT INTO "Professor" VALUES (990, 'PATRICIA MAURICIO CARVALHO');
INSERT INTO "Professor" VALUES (991, 'PAUL ALEXANDER SCHWEITZER');
INSERT INTO "Professor" VALUES (992, 'PAULA CRISTINA DA CUNHA GOMES');
INSERT INTO "Professor" VALUES (993, 'PAULA DRUMOND RANGEL CAMPOS');
INSERT INTO "Professor" VALUES (994, 'PAULO ALVES ROMAO');
INSERT INTO "Professor" VALUES (995, 'PAULO BATISTA GONCALVES');
INSERT INTO "Professor" VALUES (996, 'PAULO CARVALHO DE AZEREDO FILHO');
INSERT INTO "Professor" VALUES (997, 'PAULO CESAR DE ARAUJO');
INSERT INTO "Professor" VALUES (998, 'PAULO CESAR DE MENDONCA MOTTA');
INSERT INTO "Professor" VALUES (999, 'PAULO CESAR DUQUE ESTRADA');
INSERT INTO "Professor" VALUES (1000, 'PAULO CESAR GREENHALGH DE C LIMA');
INSERT INTO "Professor" VALUES (1001, 'PAULO CESAR TEIXEIRA');
INSERT INTO "Professor" VALUES (1002, 'PAULO CEZAR COSTA');
INSERT INTO "Professor" VALUES (1003, 'PAULO DORE FERNANDES');
INSERT INTO "Professor" VALUES (1004, 'PAULO EDUARDO RAMOS DE ARAUJO PENNA');
INSERT INTO "Professor" VALUES (1005, 'PAULO FERNANDO CARNEIRO DE ANDRADE');
INSERT INTO "Professor" VALUES (1006, 'PAULO FERNANDO HENRIQUES BRITTO');
INSERT INTO "Professor" VALUES (1007, 'PAULO FRANCIONI DE MORAES SARMENTO');
INSERT INTO "Professor" VALUES (1008, 'PAULO FREITAS RIBEIRO');
INSERT INTO "Professor" VALUES (1009, 'PAULO JORGE DA SILVA RIBEIRO');
INSERT INTO "Professor" VALUES (1010, 'PAULO JOSE TAPAJOS VIVEIROS');
INSERT INTO "Professor" VALUES (1011, 'PAULO LUIZ MOREAUX LAVIGNE ESTEVES');
INSERT INTO "Professor" VALUES (1012, 'PAULO MANSUR LEVY');
INSERT INTO "Professor" VALUES (1013, 'PAULO MARCELO DE MIRANDA SERRANO');
INSERT INTO "Professor" VALUES (1014, 'PAULO MASSILLON DE FREITAS MARTINS');
INSERT INTO "Professor" VALUES (1015, 'PAULO MESQUITA D AVILA FILHO');
INSERT INTO "Professor" VALUES (1016, 'PAULO RENATO FLORES DURAN');
INSERT INTO "Professor" VALUES (1017, 'PAULO RICARDO PEREZ CUADRAT');
INSERT INTO "Professor" VALUES (1018, 'PAULO ROBERTO DE SOUZA MENDES');
INSERT INTO "Professor" VALUES (1019, 'PAULO ROBERTO SOARES MENDONCA');
INSERT INTO "Professor" VALUES (1020, 'PAULO ROBERTO TAVARES DALCOL');
INSERT INTO "Professor" VALUES (1021, 'PAULO RUBENS DA FONSECA');
INSERT INTO "Professor" VALUES (1022, 'PAULO SOARES ALVES CUNHA');
INSERT INTO "Professor" VALUES (1023, 'PEDRICTO ROCHA FILHO');
INSERT INTO "Professor" VALUES (1024, 'PEDRO CLAUDIO CUNGA BRANDO B CUNHA');
INSERT INTO "Professor" VALUES (1025, 'PEDRO GERALDO CAMARGO ROCHA');
INSERT INTO "Professor" VALUES (1026, 'PEDRO HENRIQUE EVORA ESTEVES AMARAL');
INSERT INTO "Professor" VALUES (1027, 'PEDRO HERMILIO VILLAS BOAS C BRANCO');
INSERT INTO "Professor" VALUES (1028, 'PEDRO LOBAO PEGURIER');
INSERT INTO "Professor" VALUES (1029, 'PEDRO MARCOS NUNES BARBOSA');
INSERT INTO "Professor" VALUES (1030, 'PEDRO PAULO CRISTOFARO');
INSERT INTO "Professor" VALUES (1031, 'PEDRO PAULO SALLES CRISTOFARO');
INSERT INTO "Professor" VALUES (1032, 'PHILIPPE OLIVIER BONDITTI');
INSERT INTO "Professor" VALUES (1033, 'PIEDADE EPSTEIN GRINBERG');
INSERT INTO "Professor" VALUES (1034, 'PIERRE ANDRE ALEXANDRE H P MARTIN');
INSERT INTO "Professor" VALUES (1035, 'PINA MARIA ARNOLDI COCO');
INSERT INTO "Professor" VALUES (1036, 'PROFESSOR DO CCE');
INSERT INTO "Professor" VALUES (1037, 'RACHEL BARROS NIGRO');
INSERT INTO "Professor" VALUES (1038, 'RAFAEL DE CASTRO RUSAK');
INSERT INTO "Professor" VALUES (1039, 'RAFAEL OSWALDO RUGGIERO RODRIGUEZ');
INSERT INTO "Professor" VALUES (1040, 'RAFAEL PINHO SENRA DE MORAIS');
INSERT INTO "Professor" VALUES (1041, 'RAFAEL SOARES GONCALVES');
INSERT INTO "Professor" VALUES (1042, 'RAIMUNDO SAMPAIO NETO');
INSERT INTO "Professor" VALUES (1043, 'RALPH INGS BANNELL');
INSERT INTO "Professor" VALUES (1044, 'RAPHAEL BRAGA DA SILVA');
INSERT INTO "Professor" VALUES (1045, 'RAPHAEL DIAS MARTINS DE PAOLA');
INSERT INTO "Professor" VALUES (1046, 'RAPHAEL SACCHI ZAREMBA');
INSERT INTO "Professor" VALUES (1047, 'RAUL ALMEIDA NUNES');
INSERT INTO "Professor" VALUES (1048, 'RAUL BUENO ANDRADE SILVA');
INSERT INTO "Professor" VALUES (1049, 'RAUL PIERRE RENTERIA');
INSERT INTO "Professor" VALUES (1050, 'RAUL QUEIROZ FEITOSA');
INSERT INTO "Professor" VALUES (1051, 'RAUL ROSAS E SILVA');
INSERT INTO "Professor" VALUES (1052, 'RECEM-DOUTOR');
INSERT INTO "Professor" VALUES (1053, 'REGINA CELIA DE MATTOS');
INSERT INTO "Professor" VALUES (1054, 'REGINA COELI LISBOA SOARES');
INSERT INTO "Professor" VALUES (1055, 'REGINA LEMGRUBER JULIANELE');
INSERT INTO "Professor" VALUES (1056, 'REGINA LUCIA LEMOS LEITE SARDINHA');
INSERT INTO "Professor" VALUES (1057, 'REGINA LUCIA LIMA PONTES');
INSERT INTO "Professor" VALUES (1058, 'REGINA LUCIA MONTEDONIO BORGES');
INSERT INTO "Professor" VALUES (1059, 'REGINA MARIA DE OLIVEIRA BORGES');
INSERT INTO "Professor" VALUES (1060, 'REGINA MARIA MURAT VASCONCELOS');
INSERT INTO "Professor" VALUES (1061, 'REGINA SCHOEMER JARDIM');
INSERT INTO "Professor" VALUES (1062, 'REINALDO CALIXTO DE CAMPOS');
INSERT INTO "Professor" VALUES (1063, 'REINALDO CASTRO SOUZA');
INSERT INTO "Professor" VALUES (1064, 'REJAN RODRIGUES GUEDES BRUNI');
INSERT INTO "Professor" VALUES (1065, 'REJANE CRISTINA DE ARAUJO RODRIGUES');
INSERT INTO "Professor" VALUES (1066, 'REJANE SPITZ');
INSERT INTO "Professor" VALUES (1067, 'REMO MANNARINO FILHO');
INSERT INTO "Professor" VALUES (1068, 'RENATA CELI MOREIRA DA SILVA');
INSERT INTO "Professor" VALUES (1069, 'RENATA GEORGIA MOTTA KURTZ');
INSERT INTO "Professor" VALUES (1070, 'RENATA MACHADO RIBEIRO NUNES');
INSERT INTO "Professor" VALUES (1071, 'RENATA MARIA CANTANHEDE AMARANTE');
INSERT INTO "Professor" VALUES (1072, 'RENATA MATTOS EYER DE ARAUJO');
INSERT INTO "Professor" VALUES (1073, 'RENATA VILANOVA LIMA');
INSERT INTO "Professor" VALUES (1074, 'RENATO BARBOSA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (1075, 'RENATO CORDEIRO GOMES');
INSERT INTO "Professor" VALUES (1076, 'RENATO DA SILVA CARREIRA');
INSERT INTO "Professor" VALUES (1077, 'RENATO DE VIVEIROS LIMA');
INSERT INTO "Professor" VALUES (1078, 'RENATO FONTOURA DE GUSMAO CERQUEIRA');
INSERT INTO "Professor" VALUES (1079, 'RENATO LIMA CHARNAUX SERTA');
INSERT INTO "Professor" VALUES (1080, 'RENATO PETROCCHI');
INSERT INTO "Professor" VALUES (1081, 'RENATO SCHVARTZ');
INSERT INTO "Professor" VALUES (1082, 'RICARDO ARTUR PEREIRA CARVALHO');
INSERT INTO "Professor" VALUES (1083, 'RICARDO AUGUSTO BENZAQUEN DE ARAUJO');
INSERT INTO "Professor" VALUES (1084, 'RICARDO BERNARDO PRADA');
INSERT INTO "Professor" VALUES (1085, 'RICARDO BORGES ALENCAR');
INSERT INTO "Professor" VALUES (1086, 'RICARDO BRAJTERMAN');
INSERT INTO "Professor" VALUES (1087, 'RICARDO DA CUNHA FONTES');
INSERT INTO "Professor" VALUES (1088, 'RICARDO DE SA EARP');
INSERT INTO "Professor" VALUES (1089, 'RICARDO EMMANUEL ISMAEL DE CARVALHO');
INSERT INTO "Professor" VALUES (1090, 'RICARDO ESTEVES');
INSERT INTO "Professor" VALUES (1091, 'RICARDO GALDO CAMELIER');
INSERT INTO "Professor" VALUES (1092, 'RICARDO MIRANDA FILHO');
INSERT INTO "Professor" VALUES (1093, 'RICARDO NOLLA RUIZ');
INSERT INTO "Professor" VALUES (1094, 'RICARDO QUEIROZ AUCELIO');
INSERT INTO "Professor" VALUES (1095, 'RICARDO TANSCHEIT');
INSERT INTO "Professor" VALUES (1096, 'RICARDO TEIXEIRA DA COSTA NETO');
INSERT INTO "Professor" VALUES (1097, 'RITA DE CASSIA MARTINS MONTEZUMA');
INSERT INTO "Professor" VALUES (1098, 'RITA MARIA DE SOUZA COUTO');
INSERT INTO "Professor" VALUES (1099, 'ROBERT BRIAN JAMES WALKER');
INSERT INTO "Professor" VALUES (1100, 'ROBERTA MAURO MEDINA MAIA');
INSERT INTO "Professor" VALUES (1101, 'ROBERTA PORTAS GONCALVES RODRIGUES');
INSERT INTO "Professor" VALUES (1102, 'ROBERTO AUGUSTO DA MATTA');
INSERT INTO "Professor" VALUES (1103, 'ROBERTO BENTES DE CARVALHO');
INSERT INTO "Professor" VALUES (1104, 'ROBERTO CINTRA MARTINS');
INSERT INTO "Professor" VALUES (1105, 'ROBERTO DE MAGALHAES VEIGA');
INSERT INTO "Professor" VALUES (1106, 'ROBERTO GIL UCHOA B DE CARVALHO');
INSERT INTO "Professor" VALUES (1107, 'ROBERTO GOMES MADER GONCALVES');
INSERT INTO "Professor" VALUES (1108, 'ROBERTO HENRIQUE G EPPINGHAUS');
INSERT INTO "Professor" VALUES (1109, 'ROBERTO IERUSALIMSCHY');
INSERT INTO "Professor" VALUES (1110, 'ROBERTO JOSE DE CARVALHO');
INSERT INTO "Professor" VALUES (1111, 'ROBERTO PEIXOTO NOGUEIRA');
INSERT INTO "Professor" VALUES (1112, 'ROBERTO RIBEIRO DE AVILLEZ');
INSERT INTO "Professor" VALUES (1113, 'ROBERTO TEIXEIRA CORREA');
INSERT INTO "Professor" VALUES (1114, 'ROBERTO VELASCO KOPP JUNIOR');
INSERT INTO "Professor" VALUES (1115, 'ROBERTO VILCHEZ YAMATO');
INSERT INTO "Professor" VALUES (1116, 'ROBERTO WERNECK DO CARMO');
INSERT INTO "Professor" VALUES (1117, 'ROBSON LUIZ GAIOFATTO');
INSERT INTO "Professor" VALUES (1118, 'RODOLPHO JACOB MAIER JUNIOR');
INSERT INTO "Professor" VALUES (1119, 'RODRIGO PRIOLI MENEZES');
INSERT INTO "Professor" VALUES (1120, 'RODRIGO REIS SOARES');
INSERT INTO "Professor" VALUES (1121, 'RODRIGO RINALDI DE MATTOS');
INSERT INTO "Professor" VALUES (1122, 'ROGER JAMES VOLKEMA');
INSERT INTO "Professor" VALUES (1123, 'ROGERIO DE GUSMAO PINTO LOPES');
INSERT INTO "Professor" VALUES (1124, 'ROGERIO JOSE BENTO S DO NASCIMENTO');
INSERT INTO "Professor" VALUES (1125, 'ROGERIO LADEIRA FURQUIM WERNECK');
INSERT INTO "Professor" VALUES (1126, 'ROGERIO LUIS DE CARVALHO COSTA');
INSERT INTO "Professor" VALUES (1127, 'ROGERIO ODIVAN BRITO SERRAO');
INSERT INTO "Professor" VALUES (1128, 'ROGERIO RABE');
INSERT INTO "Professor" VALUES (1129, 'ROGERIO REIS DE MELLO');
INSERT INTO "Professor" VALUES (1130, 'ROGERIO RIBEIRO DE OLIVEIRA');
INSERT INTO "Professor" VALUES (1131, 'ROGERIO SCHIFFER DE SOUZA');
INSERT INTO "Professor" VALUES (1132, 'ROMULO BARROSO BAPTISTA');
INSERT INTO "Professor" VALUES (1133, 'ROMULO MIYAZAWA MATTEONI');
INSERT INTO "Professor" VALUES (1134, 'RONALDO BRITO FERNANDES');
INSERT INTO "Professor" VALUES (1135, 'RONALDO DOMINGUES VIEIRA');
INSERT INTO "Professor" VALUES (1136, 'RONALDO EDUARDO CRAMER VEIGA');
INSERT INTO "Professor" VALUES (1137, 'RONALDO RODRIGUES BASTOS');
INSERT INTO "Professor" VALUES (1138, 'ROSA MARINA DE BRITO MEYER');
INSERT INTO "Professor" VALUES (1139, 'ROSALIA MARIA DUARTE');
INSERT INTO "Professor" VALUES (1140, 'ROSALY HERMENGARDA LIMA BRANDAO');
INSERT INTO "Professor" VALUES (1141, 'ROSAMARY ESQUENAZI');
INSERT INTO "Professor" VALUES (1142, 'ROSANA KOHL BINES');
INSERT INTO "Professor" VALUES (1143, 'ROSANE RIERA FREIRE');
INSERT INTO "Professor" VALUES (1144, 'ROSANGELA LUNARDELLI CAVALLAZZI');
INSERT INTO "Professor" VALUES (1145, 'ROSANGELA NUNES DE ARAUJO');
INSERT INTO "Professor" VALUES (1146, 'ROSEMARY FERNANDES DA COSTA');
INSERT INTO "Professor" VALUES (1147, 'ROSI MARQUES MACHADO');
INSERT INTO "Professor" VALUES (1148, 'RUBEN JOSE BAUER NAVEIRA');
INSERT INTO "Professor" VALUES (1149, 'RUBENS NASCIMENTO MELO');
INSERT INTO "Professor" VALUES (1150, 'RUBENS SAMPAIO FILHO');
INSERT INTO "Professor" VALUES (1151, 'RUY LUIZ MILIDIU');
INSERT INTO "Professor" VALUES (1152, 'SALVADOR BEMERGUY');
INSERT INTO "Professor" VALUES (1153, 'SAMANTHA PELAJO');
INSERT INTO "Professor" VALUES (1154, 'SANDER FURTADO DE MENDONCA');
INSERT INTO "Professor" VALUES (1155, 'SANDRA KORMAN DIB');
INSERT INTO "Professor" VALUES (1156, 'SANDRA MARIA CARREIRA POLONIA RIOS');
INSERT INTO "Professor" VALUES (1157, 'SANDRA REGINA DA ROCHA PINTO');
INSERT INTO "Professor" VALUES (1158, 'SANDRA SALOMAO CARVALHO');
INSERT INTO "Professor" VALUES (1159, 'SANTUZA CAMBRAIA NAVES');
INSERT INTO "Professor" VALUES (1160, 'SARA ANGELA KISLANOV');
INSERT INTO "Professor" VALUES (1161, 'SEBASTIAO ARTHUR LOPES DE ANDRADE');
INSERT INTO "Professor" VALUES (1162, 'SELMA DE SA RORIZ REIS');
INSERT INTO "Professor" VALUES (1163, 'SERGIO AUGUSTO BARRETO DA FONTOURA');
INSERT INTO "Professor" VALUES (1164, 'SERGIO BERMUDES');
INSERT INTO "Professor" VALUES (1165, 'SERGIO BERNARDO VOLCHAN');
INSERT INTO "Professor" VALUES (1166, 'SERGIO BESSERMAN VIANNA');
INSERT INTO "Professor" VALUES (1167, 'SERGIO COLCHER');
INSERT INTO "Professor" VALUES (1168, 'SERGIO DA COSTA CORTES');
INSERT INTO "Professor" VALUES (1169, 'SERGIO LEAL BRAGA');
INSERT INTO "Professor" VALUES (1170, 'SERGIO LIFSCHITZ');
INSERT INTO "Professor" VALUES (1171, 'SERGIO LUIZ BONATO');
INSERT INTO "Professor" VALUES (1172, 'SERGIO LUIZ RIBEIRO MOTA');
INSERT INTO "Professor" VALUES (1173, 'SERGIO NOBREGA DE OLIVEIRA');
INSERT INTO "Professor" VALUES (1174, 'SERGIO RICARDO YATES DOS SANTOS');
INSERT INTO "Professor" VALUES (1175, 'SHEILA DAIN');
INSERT INTO "Professor" VALUES (1176, 'SHEILA DE BARCELLOS MAIA JORDAO');
INSERT INTO "Professor" VALUES (1177, 'SHEILA MEJLACHOWICZ');
INSERT INTO "Professor" VALUES (1178, 'SHEILA NAJBERG');
INSERT INTO "Professor" VALUES (1179, 'SIDNEI PACIORNIK');
INSERT INTO "Professor" VALUES (1180, 'SIDNEY NOLASCO DE REZENDE');
INSERT INTO "Professor" VALUES (1181, 'SILVANA APARECIDA FERREIRA MARQUES');
INSERT INTO "Professor" VALUES (1182, 'SILVIA BEATRIZ ALEXANDRA B COSTA');
INSERT INTO "Professor" VALUES (1183, 'SILVIA HELENA SOARES DA COSTA');
INSERT INTO "Professor" VALUES (1184, 'SILVIA MARIA ABU JAMRA ZORNIG');
INSERT INTO "Professor" VALUES (1185, 'SILVIA PATUZZI');
INSERT INTO "Professor" VALUES (1186, 'SILVINA ANA RAMAL');
INSERT INTO "Professor" VALUES (1187, 'SILVIO DE MOURA DIAS');
INSERT INTO "Professor" VALUES (1188, 'SILVIO HAMACHER');
INSERT INTO "Professor" VALUES (1189, 'SILVIO TENDLER');
INSERT INTO "Professor" VALUES (1190, 'SIMONE CARVALHO DE FORMIGA XAVIER');
INSERT INTO "Professor" VALUES (1191, 'SIMONE DINIZ JUNQUEIRA BARBOSA');
INSERT INTO "Professor" VALUES (1192, 'SIMONE ROCHA VALENTE PINTO');
INSERT INTO "Professor" VALUES (1193, 'SINESIO PESCO');
INSERT INTO "Professor" VALUES (1194, 'SOLANGE JOBIM E SOUZA');
INSERT INTO "Professor" VALUES (1195, 'SOLANGE MARTINS JORDAO');
INSERT INTO "Professor" VALUES (1196, 'SONIA DUARTE TRAVASSOS');
INSERT INTO "Professor" VALUES (1197, 'SONIA KRAMER');
INSERT INTO "Professor" VALUES (1198, 'SONIA MARIA GIACOMINI');
INSERT INTO "Professor" VALUES (1199, 'SONIA RENAUX WANDERLEY LOURO');
INSERT INTO "Professor" VALUES (1200, 'STEFAN ZOHREN');
INSERT INTO "Professor" VALUES (1201, 'SUELI BULHOES DA SILVA');
INSERT INTO "Professor" VALUES (1202, 'SUZANA VALLADARES FONSECA');
INSERT INTO "Professor" VALUES (1203, 'TACIO MAURO PEREIRA DE CAMPOS');
INSERT INTO "Professor" VALUES (1204, 'TALITA DE ASSIS BARRETO');
INSERT INTO "Professor" VALUES (1205, 'TANIA HORSTH NORONHA JARDIM');
INSERT INTO "Professor" VALUES (1206, 'TARA KESHAR NANDA BAIDYA');
INSERT INTO "Professor" VALUES (1207, 'TATIANA BARBOSA CARVALHO');
INSERT INTO "Professor" VALUES (1208, 'TATIANA BRAGA BACAL');
INSERT INTO "Professor" VALUES (1209, 'TATIANA DILLENBURG SAINT PIERRE');
INSERT INTO "Professor" VALUES (1210, 'TATIANA MESSER RYBALOWSKI');
INSERT INTO "Professor" VALUES (1211, 'TATIANA OLIVEIRA SICILIANO');
INSERT INTO "Professor" VALUES (1212, 'TELMA DA GRACA DE LIMA LAGE');
INSERT INTO "Professor" VALUES (1213, 'TEMPO CONTINUO A DEFINIR');
INSERT INTO "Professor" VALUES (1214, 'TERESA CRISTINA GONCALVES PANTOJA');
INSERT INTO "Professor" VALUES (1215, 'TERESIA DIANA L VAN A DE M SOARES');
INSERT INTO "Professor" VALUES (1216, 'TEREZA CRISTINA SALDANHA ERTHAL');
INSERT INTO "Professor" VALUES (1217, 'TEREZA MARIA POMPEIA CAVALCANTI');
INSERT INTO "Professor" VALUES (1218, 'TEREZINHA FERES CARNEIRO');
INSERT INTO "Professor" VALUES (1219, 'THADEU KELLER FILHO');
INSERT INTO "Professor" VALUES (1220, 'THAIS HELENA DE LIMA NUNES');
INSERT INTO "Professor" VALUES (1221, 'THAMIS AVILA DALSENTER');
INSERT INTO "Professor" VALUES (1222, 'THEOPHILO ANTONIO DA ROCHA MATTOS');
INSERT INTO "Professor" VALUES (1223, 'THEOPHILO ANTONIO MIGUEL FILHO');
INSERT INTO "Professor" VALUES (1224, 'THEREZA DE MIRANDA CARVALHO');
INSERT INTO "Professor" VALUES (1225, 'THEREZINHA SOUZA DA COSTA');
INSERT INTO "Professor" VALUES (1226, 'THIAGO LEITAO DE SOUZA');
INSERT INTO "Professor" VALUES (1227, 'THIAGO RAGONHA VARELA');
INSERT INTO "Professor" VALUES (1228, 'THOMAS ADAMS');
INSERT INTO "Professor" VALUES (1229, 'THOMAS MAURICE LEWINER');
INSERT INTO "Professor" VALUES (1230, 'THULA RAFAELA DE OLIVEIRA PIRES');
INSERT INTO "Professor" VALUES (1231, 'TOMMASO DEL ROSSO');
INSERT INTO "Professor" VALUES (1232, 'ULISSES FELIPE CAMARDELLA');
INSERT INTO "Professor" VALUES (1233, 'UMBERTO GUATIMOSIM ALVIM');
INSERT INTO "Professor" VALUES (1234, 'VALERIA PEREIRA BASTOS');
INSERT INTO "Professor" VALUES (1235, 'VALTER SINDER');
INSERT INTO "Professor" VALUES (1236, 'VENETIA MARIA CORREA SANTOS');
INSERT INTO "Professor" VALUES (1237, 'VERA ANGELA NOVELLO');
INSERT INTO "Professor" VALUES (1238, 'VERA CRISTINA GONCALVES DE A BUENO');
INSERT INTO "Professor" VALUES (1239, 'VERA LUCIA FOLLAIN DE FIGUEIREDO');
INSERT INTO "Professor" VALUES (1240, 'VERA LUCIA MOREIRA DOS S NOJIMA');
INSERT INTO "Professor" VALUES (1241, 'VERA LUCIA VIEIRA BALTAR');
INSERT INTO "Professor" VALUES (1242, 'VERA MAGIANO HAZAN');
INSERT INTO "Professor" VALUES (1243, 'VERA MARIA CAVALCANTI BERNARDES');
INSERT INTO "Professor" VALUES (1244, 'VERA MARIA FERRAO CANDAU');
INSERT INTO "Professor" VALUES (1245, 'VERA MARIA LANZELLOTTI BALDEZ BOING');
INSERT INTO "Professor" VALUES (1246, 'VERA MARIA MARSICANO DAMAZIO');
INSERT INTO "Professor" VALUES (1247, 'VERA MARIA PEREIRA DE M HENRIQUES');
INSERT INTO "Professor" VALUES (1248, 'VERANISE JACUBOWSKI CORREIA DUBEUX');
INSERT INTO "Professor" VALUES (1249, 'VERONICA GOMES NATIVIDADE');
INSERT INTO "Professor" VALUES (1250, 'VERONICA RODRIGUES FERREIRA GOMES');
INSERT INTO "Professor" VALUES (1251, 'VICENTE GARAMBONE FILHO');
INSERT INTO "Professor" VALUES (1252, 'VICTORIA AMALIA DE B C G DE SULOCKI');
INSERT INTO "Professor" VALUES (1253, 'VINICIUS DE FRANCA MACHADO');
INSERT INTO "Professor" VALUES (1254, 'VINICIUS DO NASCIMENTO CARRASCO');
INSERT INTO "Professor" VALUES (1255, 'VIRGINIA TOTTI GUIMARAES');
INSERT INTO "Professor" VALUES (1256, 'VITOR MANUEL CARNEIRO LEMOS');
INSERT INTO "Professor" VALUES (1257, 'VIVIANE EL HUAIK DE MEDEIROS');
INSERT INTO "Professor" VALUES (1258, 'VLADIMIR MUCURY CARDOSO');
INSERT INTO "Professor" VALUES (1259, 'WALDEMAR CELES FILHO');
INSERT INTO "Professor" VALUES (1260, 'WALDEMAR MONTEIRO DA SILVA JUNIOR');
INSERT INTO "Professor" VALUES (1261, 'WALTER DOS SANTOS TEIXEIRA FILHO');
INSERT INTO "Professor" VALUES (1262, 'WALTER LIMA JUNIOR');
INSERT INTO "Professor" VALUES (1263, 'WALTER NOVAES FILHO');
INSERT INTO "Professor" VALUES (1264, 'WALVYKER ALVES DE SOUZA');
INSERT INTO "Professor" VALUES (1265, 'WASHINGTON BRAGA FILHO');
INSERT INTO "Professor" VALUES (1266, 'WASHINGTON DIAS LESSA');
INSERT INTO "Professor" VALUES (1267, 'WEILER ALVES FINAMORE');
INSERT INTO "Professor" VALUES (1268, 'WEILER ALVES FINAMORE FILHO');
INSERT INTO "Professor" VALUES (1269, 'WELLES ANTONIO MARTINEZ MORGADO');
INSERT INTO "Professor" VALUES (1270, 'WERTHER TEIXEIRA DE AZEVEDO NETO');
INSERT INTO "Professor" VALUES (1271, 'WHEI OH LIN');
INSERT INTO "Professor" VALUES (1272, 'WILSON BUCKER AGUIAR JUNIOR');
INSERT INTO "Professor" VALUES (1273, 'WILSON LUIS BRANCO MARTINS');
INSERT INTO "Professor" VALUES (1274, 'ZENA WINONA EISENBERG');
INSERT INTO "Professor" VALUES (1275, 'ZOY ANASTASSAKIS');


--
-- TOC entry 2038 (class 0 OID 35708)
-- Dependencies: 163 2055
-- Data for Name: TipoUsuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "TipoUsuario" VALUES (1, 'Administrador');
INSERT INTO "TipoUsuario" VALUES (2, 'Coordenador');
INSERT INTO "TipoUsuario" VALUES (3, 'Aluno');


--
-- TOC entry 2047 (class 0 OID 35986)
-- Dependencies: 176 2055
-- Data for Name: Turma; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2049 (class 0 OID 36018)
-- Dependencies: 178 2055
-- Data for Name: TurmaHorario; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2036 (class 0 OID 35689)
-- Dependencies: 161 2055
-- Data for Name: Usuario; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 2042 (class 0 OID 35879)
-- Dependencies: 170 2055
-- Data for Name: VariavelAmbiente; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "VariavelAmbiente" VALUES ('manutencao', false, 'Desculpe. O sistema encontra-se em manutenção. Por favor, tente mais tarde. Obrigado.');


--
-- TOC entry 1969 (class 2606 OID 35861)
-- Dependencies: 162 162 2056
-- Name: PK_Aluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "PK_Aluno" PRIMARY KEY ("FK_Matricula");


--
-- TOC entry 1987 (class 2606 OID 35906)
-- Dependencies: 172 172 172 2056
-- Name: PK_AlunoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "PK_AlunoDisciplina" PRIMARY KEY ("FK_Aluno", "FK_Disciplina");


--
-- TOC entry 1989 (class 2606 OID 35921)
-- Dependencies: 173 173 2056
-- Name: PK_AlunoDisciplinaStatus; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "PK_AlunoDisciplinaStatus" PRIMARY KEY ("PK_Status");


--
-- TOC entry 1999 (class 2606 OID 36005)
-- Dependencies: 177 177 177 2056
-- Name: PK_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "PK_AlunoTurmaSelecionada" PRIMARY KEY ("FK_Aluno", "FK_Turma");


--
-- TOC entry 2013 (class 2606 OID 36146)
-- Dependencies: 186 186 2056
-- Name: PK_Curso; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Curso"
    ADD CONSTRAINT "PK_Curso" PRIMARY KEY ("PK_Curso");


--
-- TOC entry 1985 (class 2606 OID 35900)
-- Dependencies: 171 171 2056
-- Name: PK_Disciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Disciplina"
    ADD CONSTRAINT "PK_Disciplina" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 1977 (class 2606 OID 35767)
-- Dependencies: 165 165 2056
-- Name: PK_Log; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "PK_Log" PRIMARY KEY ("PK_Log");


--
-- TOC entry 1993 (class 2606 OID 35943)
-- Dependencies: 174 174 2056
-- Name: PK_Optativa; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Optativa"
    ADD CONSTRAINT "PK_Optativa" PRIMARY KEY ("PK_Codigo");


--
-- TOC entry 2005 (class 2606 OID 36047)
-- Dependencies: 179 179 179 2056
-- Name: PK_OptativaAluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "PK_OptativaAluno" PRIMARY KEY ("FK_Optativa", "FK_Aluno");


--
-- TOC entry 2007 (class 2606 OID 36062)
-- Dependencies: 180 180 180 2056
-- Name: PK_OptativaDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "PK_OptativaDisciplina" PRIMARY KEY ("FK_Optativa", "FK_Disciplina");


--
-- TOC entry 2009 (class 2606 OID 36081)
-- Dependencies: 182 182 2056
-- Name: PK_PreRequisitoGrupo; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "PK_PreRequisitoGrupo" PRIMARY KEY ("PK_PreRequisitoGrupo");


--
-- TOC entry 2011 (class 2606 OID 36086)
-- Dependencies: 183 183 183 2056
-- Name: PK_PreRequisitoGrupoDisciplina; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "PK_PreRequisitoGrupoDisciplina" PRIMARY KEY ("FK_PreRequisitoGrupo", "FK_Disciplina");


--
-- TOC entry 1979 (class 2606 OID 35822)
-- Dependencies: 167 167 2056
-- Name: PK_Professor; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Professor"
    ADD CONSTRAINT "PK_Professor" PRIMARY KEY ("PK_Professor");


--
-- TOC entry 1975 (class 2606 OID 35725)
-- Dependencies: 164 164 2056
-- Name: PK_Sugestao; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "PK_Sugestao" PRIMARY KEY ("PK_Sugestao");


--
-- TOC entry 1971 (class 2606 OID 35712)
-- Dependencies: 163 163 2056
-- Name: PK_TipoUsuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "PK_TipoUsuario" PRIMARY KEY ("PK_TipoUsuario");


--
-- TOC entry 1997 (class 2606 OID 35994)
-- Dependencies: 176 176 2056
-- Name: PK_Turma; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma" PRIMARY KEY ("PK_Turma");


--
-- TOC entry 2003 (class 2606 OID 36032)
-- Dependencies: 178 178 178 178 178 2056
-- Name: PK_TurmaHorario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "PK_TurmaHorario" PRIMARY KEY ("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal");


--
-- TOC entry 1967 (class 2606 OID 35727)
-- Dependencies: 161 161 2056
-- Name: PK_Usuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "PK_Usuario" PRIMARY KEY ("PK_Login");


--
-- TOC entry 1983 (class 2606 OID 35887)
-- Dependencies: 170 170 2056
-- Name: PK_VariavelAmbiente; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "VariavelAmbiente"
    ADD CONSTRAINT "PK_VariavelAmbiente" PRIMARY KEY ("PK_Variavel");


--
-- TOC entry 1991 (class 2606 OID 35923)
-- Dependencies: 173 173 2056
-- Name: Unique_AlunoDisciplinaStatus_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoDisciplinaStatus"
    ADD CONSTRAINT "Unique_AlunoDisciplinaStatus_Nome" UNIQUE ("Nome");


--
-- TOC entry 2001 (class 2606 OID 36007)
-- Dependencies: 177 177 177 177 177 2056
-- Name: Unique_AlunoTurmaSelecionada; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "Unique_AlunoTurmaSelecionada" UNIQUE ("FK_Aluno", "FK_Turma", "Opcao", "NoLinha");


--
-- TOC entry 2015 (class 2606 OID 36148)
-- Dependencies: 186 186 2056
-- Name: Unique_Curso_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Curso"
    ADD CONSTRAINT "Unique_Curso_Nome" UNIQUE ("Nome");


--
-- TOC entry 1995 (class 2606 OID 35945)
-- Dependencies: 174 174 2056
-- Name: Unique_Optativa_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Optativa"
    ADD CONSTRAINT "Unique_Optativa_Nome" UNIQUE ("Nome");


--
-- TOC entry 1981 (class 2606 OID 35824)
-- Dependencies: 167 167 2056
-- Name: Unique_Professor_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Professor"
    ADD CONSTRAINT "Unique_Professor_Nome" UNIQUE ("Nome");


--
-- TOC entry 1973 (class 2606 OID 35807)
-- Dependencies: 163 163 2056
-- Name: Unique_TipoUsuario_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "Unique_TipoUsuario_Nome" UNIQUE ("Nome");


--
-- TOC entry 2021 (class 2606 OID 35924)
-- Dependencies: 1968 162 172 2056
-- Name: FK_AlunoDisciplina_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2023 (class 2606 OID 35934)
-- Dependencies: 173 172 1988 2056
-- Name: FK_AlunoDisciplina_AlunoDisciplinaStatus; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_AlunoDisciplinaStatus" FOREIGN KEY ("FK_Status") REFERENCES "AlunoDisciplinaStatus"("PK_Status") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2022 (class 2606 OID 35929)
-- Dependencies: 172 1984 171 2056
-- Name: FK_AlunoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoDisciplina"
    ADD CONSTRAINT "FK_AlunoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2026 (class 2606 OID 36008)
-- Dependencies: 1968 162 177 2056
-- Name: FK_AlunoTurmaSelecionada_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2027 (class 2606 OID 36013)
-- Dependencies: 1996 176 177 2056
-- Name: FK_AlunoTurmaSelecionada_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "AlunoTurmaSelecionada"
    ADD CONSTRAINT "FK_AlunoTurmaSelecionada_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2018 (class 2606 OID 36154)
-- Dependencies: 186 162 2012 2056
-- Name: FK_Aluno_Curso; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Curso" FOREIGN KEY ("FK_Curso") REFERENCES "Curso"("PK_Curso") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2017 (class 2606 OID 36149)
-- Dependencies: 1966 162 161 2056
-- Name: FK_Aluno_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Usuario" FOREIGN KEY ("FK_Matricula") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2020 (class 2606 OID 36132)
-- Dependencies: 165 161 1966 2056
-- Name: FK_Log_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "FK_Log_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2030 (class 2606 OID 36053)
-- Dependencies: 179 1968 162 2056
-- Name: FK_OptativaAluno_Aluno; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Aluno" FOREIGN KEY ("FK_Aluno") REFERENCES "Aluno"("FK_Matricula") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2029 (class 2606 OID 36048)
-- Dependencies: 1992 174 179 2056
-- Name: FK_OptativaAluno_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaAluno"
    ADD CONSTRAINT "FK_OptativaAluno_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2032 (class 2606 OID 36068)
-- Dependencies: 1984 180 171 2056
-- Name: FK_OptativaDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2031 (class 2606 OID 36063)
-- Dependencies: 174 1992 180 2056
-- Name: FK_OptativaDisciplina_Optativa; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "OptativaDisciplina"
    ADD CONSTRAINT "FK_OptativaDisciplina_Optativa" FOREIGN KEY ("FK_Optativa") REFERENCES "Optativa"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2035 (class 2606 OID 36092)
-- Dependencies: 183 1984 171 2056
-- Name: FK_PreRequisitoGrupoDisciplina_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2034 (class 2606 OID 36087)
-- Dependencies: 183 2008 182 2056
-- Name: FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupoDisciplina"
    ADD CONSTRAINT "FK_PreRequisitoGrupoDisciplina_PreRequisitoGrupo" FOREIGN KEY ("FK_PreRequisitoGrupo") REFERENCES "PreRequisitoGrupo"("PK_PreRequisitoGrupo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2033 (class 2606 OID 36097)
-- Dependencies: 1984 182 171 2056
-- Name: FK_PreRequisitoGrupo_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "PreRequisitoGrupo"
    ADD CONSTRAINT "FK_PreRequisitoGrupo_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2019 (class 2606 OID 35888)
-- Dependencies: 161 1966 164 2056
-- Name: FK_Sugestao_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Comentario"
    ADD CONSTRAINT "FK_Sugestao_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2028 (class 2606 OID 36026)
-- Dependencies: 176 1996 178 2056
-- Name: FK_TurmaHorario_Turma; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "TurmaHorario"
    ADD CONSTRAINT "FK_TurmaHorario_Turma" FOREIGN KEY ("FK_Turma") REFERENCES "Turma"("PK_Turma") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2025 (class 2606 OID 36038)
-- Dependencies: 167 176 1978 2056
-- Name: FK_Turma_Professor; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "FK_Turma_Professor" FOREIGN KEY ("FK_Professor") REFERENCES "Professor"("PK_Professor") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2016 (class 2606 OID 35971)
-- Dependencies: 163 1970 161 2056
-- Name: FK_Usuario_TipoUsuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "FK_Usuario_TipoUsuario" FOREIGN KEY ("FK_TipoUsuario") REFERENCES "TipoUsuario"("PK_TipoUsuario") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2024 (class 2606 OID 36033)
-- Dependencies: 171 1984 176 2056
-- Name: PK_Turma_Disciplina; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Turma"
    ADD CONSTRAINT "PK_Turma_Disciplina" FOREIGN KEY ("FK_Disciplina") REFERENCES "Disciplina"("PK_Codigo") ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2012-11-30 12:56:34 BRST

--
-- PostgreSQL database dump complete
--

