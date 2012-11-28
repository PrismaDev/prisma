--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.5
-- Dumped by pg_dump version 9.1.5
-- Started on 2012-11-28 19:34:57 BRST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 172 (class 3079 OID 11646)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 1936 (class 0 OID 0)
-- Dependencies: 172
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

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
    "FK_Curso" integer NOT NULL
);


ALTER TABLE public."Aluno" OWNER TO prisma;

--
-- TOC entry 167 (class 1259 OID 35783)
-- Dependencies: 6
-- Name: Curso; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Curso" (
    "PK_Curso" integer NOT NULL,
    "Nome" character varying(50) NOT NULL
);


ALTER TABLE public."Curso" OWNER TO prisma;

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
-- TOC entry 1937 (class 0 OID 0)
-- Dependencies: 166
-- Name: seq_log; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_log', 3, true);


--
-- TOC entry 165 (class 1259 OID 35758)
-- Dependencies: 1891 1892 1893 6
-- Name: Log; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Log" (
    "PK_Log" bigint DEFAULT nextval('seq_log'::regclass) NOT NULL,
    "DataHora" timestamp with time zone DEFAULT now() NOT NULL,
    "IP" character varying(15),
    "URI" character varying(100),
    "HashSessao" character varying(20),
    "Erro" boolean DEFAULT false NOT NULL,
    "Notas" text,
    "FK_Usuario" character varying(20) NOT NULL
);


ALTER TABLE public."Log" OWNER TO prisma;

--
-- TOC entry 169 (class 1259 OID 35868)
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
-- TOC entry 1938 (class 0 OID 0)
-- Dependencies: 169
-- Name: seq_professor; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_professor', 1, false);


--
-- TOC entry 168 (class 1259 OID 35818)
-- Dependencies: 1894 6
-- Name: Professor; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Professor" (
    "PK_Professor" bigint DEFAULT nextval('seq_professor'::regclass) NOT NULL,
    "Nome" character varying(100) NOT NULL
);


ALTER TABLE public."Professor" OWNER TO prisma;

--
-- TOC entry 170 (class 1259 OID 35870)
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
-- TOC entry 1939 (class 0 OID 0)
-- Dependencies: 170
-- Name: seq_sugestao; Type: SEQUENCE SET; Schema: public; Owner: prisma
--

SELECT pg_catalog.setval('seq_sugestao', 1, false);


--
-- TOC entry 164 (class 1259 OID 35718)
-- Dependencies: 1889 1890 6
-- Name: Sugestao; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Sugestao" (
    "PK_Sugestao" bigint DEFAULT nextval('seq_sugestao'::regclass) NOT NULL,
    "FK_Usuario" character varying(20) NOT NULL,
    "Comentario" text NOT NULL,
    "DataHora" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public."Sugestao" OWNER TO prisma;

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
-- Dependencies: 1888 6
-- Name: Usuario; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "Usuario" (
    "PK_Login" character varying(20) NOT NULL,
    "Senha" character varying(20) NOT NULL,
    "Nome" character varying(100),
    "HashSessao" character varying(20),
    "TermoAceito" boolean DEFAULT false NOT NULL,
    "FK_TipoUsuario" integer NOT NULL
);


ALTER TABLE public."Usuario" OWNER TO prisma;

--
-- TOC entry 171 (class 1259 OID 35879)
-- Dependencies: 1895 6
-- Name: VariavelAmbiente; Type: TABLE; Schema: public; Owner: prisma; Tablespace: 
--

CREATE TABLE "VariavelAmbiente" (
    "PK_Variavel" character varying(30) NOT NULL,
    "Habilitada" boolean DEFAULT true NOT NULL,
    "Descricao" text
);


ALTER TABLE public."VariavelAmbiente" OWNER TO prisma;

--
-- TOC entry 1924 (class 0 OID 35695)
-- Dependencies: 162 1931
-- Data for Name: Aluno; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 1928 (class 0 OID 35783)
-- Dependencies: 167 1931
-- Data for Name: Curso; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 1927 (class 0 OID 35758)
-- Dependencies: 165 1931
-- Data for Name: Log; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 1929 (class 0 OID 35818)
-- Dependencies: 168 1931
-- Data for Name: Professor; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 1926 (class 0 OID 35718)
-- Dependencies: 164 1931
-- Data for Name: Sugestao; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 1925 (class 0 OID 35708)
-- Dependencies: 163 1931
-- Data for Name: TipoUsuario; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "TipoUsuario" VALUES (1, 'Administrador');
INSERT INTO "TipoUsuario" VALUES (2, 'Coordenador');
INSERT INTO "TipoUsuario" VALUES (3, 'Aluno');


--
-- TOC entry 1923 (class 0 OID 35689)
-- Dependencies: 161 1931
-- Data for Name: Usuario; Type: TABLE DATA; Schema: public; Owner: prisma
--



--
-- TOC entry 1930 (class 0 OID 35879)
-- Dependencies: 171 1931
-- Data for Name: VariavelAmbiente; Type: TABLE DATA; Schema: public; Owner: prisma
--

INSERT INTO "VariavelAmbiente" VALUES ('manutencao', false, 'Desculpe. O sistema encontra-se em manutenção. Por favor, tente mais tarde. Obrigado.');


--
-- TOC entry 1899 (class 2606 OID 35861)
-- Dependencies: 162 162 1932
-- Name: PK_Aluno; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "PK_Aluno" PRIMARY KEY ("FK_Matricula");


--
-- TOC entry 1909 (class 2606 OID 35787)
-- Dependencies: 167 167 1932
-- Name: PK_Curso; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Curso"
    ADD CONSTRAINT "PK_Curso" PRIMARY KEY ("PK_Curso");


--
-- TOC entry 1907 (class 2606 OID 35767)
-- Dependencies: 165 165 1932
-- Name: PK_Log; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "PK_Log" PRIMARY KEY ("PK_Log");


--
-- TOC entry 1913 (class 2606 OID 35822)
-- Dependencies: 168 168 1932
-- Name: PK_Professor; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Professor"
    ADD CONSTRAINT "PK_Professor" PRIMARY KEY ("PK_Professor");


--
-- TOC entry 1905 (class 2606 OID 35725)
-- Dependencies: 164 164 1932
-- Name: PK_Sugestao; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Sugestao"
    ADD CONSTRAINT "PK_Sugestao" PRIMARY KEY ("PK_Sugestao");


--
-- TOC entry 1901 (class 2606 OID 35712)
-- Dependencies: 163 163 1932
-- Name: PK_TipoUsuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "PK_TipoUsuario" PRIMARY KEY ("PK_TipoUsuario");


--
-- TOC entry 1897 (class 2606 OID 35727)
-- Dependencies: 161 161 1932
-- Name: PK_Usuario; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "PK_Usuario" PRIMARY KEY ("PK_Login");


--
-- TOC entry 1917 (class 2606 OID 35887)
-- Dependencies: 171 171 1932
-- Name: PK_VariavelAmbiente; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "VariavelAmbiente"
    ADD CONSTRAINT "PK_VariavelAmbiente" PRIMARY KEY ("PK_Variavel");


--
-- TOC entry 1911 (class 2606 OID 35805)
-- Dependencies: 167 167 1932
-- Name: Unique_Curso_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Curso"
    ADD CONSTRAINT "Unique_Curso_Nome" UNIQUE ("Nome");


--
-- TOC entry 1915 (class 2606 OID 35824)
-- Dependencies: 168 168 1932
-- Name: Unique_Professor_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "Professor"
    ADD CONSTRAINT "Unique_Professor_Nome" UNIQUE ("Nome");


--
-- TOC entry 1903 (class 2606 OID 35807)
-- Dependencies: 163 163 1932
-- Name: Unique_TipoUsuario_Nome; Type: CONSTRAINT; Schema: public; Owner: prisma; Tablespace: 
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "Unique_TipoUsuario_Nome" UNIQUE ("Nome");


--
-- TOC entry 1919 (class 2606 OID 35850)
-- Dependencies: 167 1908 162 1932
-- Name: FK_Aluno_Curso; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Curso" FOREIGN KEY ("FK_Curso") REFERENCES "Curso"("PK_Curso") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1920 (class 2606 OID 35855)
-- Dependencies: 162 161 1896 1932
-- Name: FK_Aluno_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Aluno"
    ADD CONSTRAINT "FK_Aluno_Usuario" FOREIGN KEY ("FK_Matricula") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1922 (class 2606 OID 35863)
-- Dependencies: 161 1896 165 1932
-- Name: FK_Log_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Log"
    ADD CONSTRAINT "FK_Log_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1921 (class 2606 OID 35874)
-- Dependencies: 1896 161 164 1932
-- Name: FK_Sugestao_Usuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Sugestao"
    ADD CONSTRAINT "FK_Sugestao_Usuario" FOREIGN KEY ("FK_Usuario") REFERENCES "Usuario"("PK_Login") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 1918 (class 2606 OID 35737)
-- Dependencies: 163 1900 161 1932
-- Name: FK_Usuario_TipoUsuario; Type: FK CONSTRAINT; Schema: public; Owner: prisma
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "FK_Usuario_TipoUsuario" FOREIGN KEY ("FK_TipoUsuario") REFERENCES "TipoUsuario"("PK_TipoUsuario") ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2012-11-28 19:34:57 BRST

--
-- PostgreSQL database dump complete
--

