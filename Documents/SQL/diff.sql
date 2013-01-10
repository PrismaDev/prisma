
BEGIN;

CREATE TABLE "TurmaDestino"
(
  "FK_Turma" bigint NOT NULL,
  "Destino" character varying(3) NOT NULL,
  "Vagas" integer NOT NULL DEFAULT 0,
  CONSTRAINT "PK_TurmaDestino" PRIMARY KEY ("FK_Turma", "Destino", "Vagas"),
  CONSTRAINT "FK_TurmaDestino_Turma" FOREIGN KEY ("FK_Turma")
      REFERENCES "Turma" ("PK_Turma") MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);

CREATE OR REPLACE RULE "TurmaDestinoDuplicado" AS
    ON INSERT TO "TurmaDestino"
   WHERE (EXISTS ( SELECT 1
           FROM "TurmaDestino"
          WHERE "TurmaDestino"."FK_Turma" = new."FK_Turma" AND "TurmaDestino"."Destino"::text = new."Destino"::text)) DO INSTEAD  UPDATE "TurmaDestino" SET "Vagas" = new."Vagas"
  WHERE "TurmaDestino"."FK_Turma" = new."FK_Turma" AND "TurmaDestino"."Destino"::text = new."Destino"::text;

DROP VIEW "LogOcupacaoTurma";
CREATE OR REPLACE VIEW "LogOcupacaoTurma" AS 
 SELECT t."FK_Disciplina" AS "CodigoDisciplina", t."Codigo" AS "CodigoTurma", t."PeriodoAno", ats."Opcao", count(DISTINCT ats."FK_Aluno") AS "QuantidadeAluno", td."Destino", td."Vagas", trunc(count(DISTINCT ats."FK_Aluno")::numeric / td."Vagas"::numeric * 100::numeric, 2) AS "Porcentagem"
    FROM "AlunoTurmaSelecionada" ats
       JOIN "Turma" t ON t."PK_Turma" = ats."FK_Turma"
          JOIN "TurmaDestino" td ON t."PK_Turma" = td."FK_Turma"
	    GROUP BY ats."FK_Turma", t."FK_Disciplina", t."Codigo", t."PeriodoAno", ats."Opcao", td."Destino", td."Vagas"
	      ORDER BY ats."FK_Turma", t."FK_Disciplina", t."Codigo", t."PeriodoAno", ats."Opcao", count(DISTINCT ats."FK_Aluno"), td."Destino", td."Vagas", trunc(count(DISTINCT ats."FK_Aluno")::numeric / td."Vagas"::numeric * 100::numeric, 2);

CREATE OR REPLACE VIEW "MicroHorario" AS 
 SELECT d."PK_Codigo" AS "CodigoDisciplina", d."Nome" AS "NomeDisciplina", d."Creditos", t."PK_Turma", t."Codigo" AS "CodigoTurma", t."PeriodoAno", td."Vagas", td."Destino", t."HorasDistancia", t."SHF", p."Nome" AS "NomeProfessor", th."DiaSemana", th."HoraInicial", th."HoraFinal"
   FROM "Disciplina" d
   JOIN "Turma" t ON t."FK_Disciplina"::text = d."PK_Codigo"::text AND t."Deletada" = false
   JOIN "Professor" p ON t."FK_Professor" = p."PK_Professor"
   JOIN "TurmaHorario" th ON th."FK_Turma" = t."PK_Turma"
   JOIN "TurmaDestino" td ON td."FK_Turma" = t."PK_Turma";

DROP VIEW "TurmaProfessor";
CREATE OR REPLACE VIEW "TurmaProfessor" AS 
 SELECT t."PK_Turma", t."Codigo" AS "CodigoTurma", t."FK_Disciplina" AS "CodigoDisciplina", t."PeriodoAno", t."HorasDistancia", t."SHF", p."Nome" AS "NomeProfessor"
   FROM "Turma" t
   JOIN "Professor" p ON t."FK_Professor" = p."PK_Professor"
  WHERE t."Deletada" = false;

CREATE OR REPLACE RULE "TurmaDuplicada" AS
    ON INSERT TO "Turma"
   WHERE (EXISTS ( SELECT 1
           FROM "Turma" t
          WHERE t."FK_Disciplina"::text = new."FK_Disciplina"::text AND t."Codigo"::text = new."Codigo"::text AND t."PeriodoAno" = new."PeriodoAno")) 
          DO INSTEAD  
          UPDATE "Turma" t SET "HorasDistancia" = new."HorasDistancia", "SHF" = new."SHF", "FK_Professor" = new."FK_Professor", "Deletada" = false
  WHERE t."FK_Disciplina"::text = new."FK_Disciplina"::text AND t."Codigo"::text = new."Codigo"::text AND t."PeriodoAno" = new."PeriodoAno";

ALTER TABLE "Turma" DROP COLUMN "Vagas";
ALTER TABLE "Turma" DROP COLUMN "Destino";

COMMIT;

---------------------------------------------------------------------------------

BEGIN;

CREATE SEQUENCE seq_unidade;

CREATE TABLE "Unidade"
(
 "PK_Unidade" bigint NOT NULL DEFAULT nextval('seq_unidade'), 
 "Nome" character varying(50) NOT NULL, 
 CONSTRAINT "PK_Unidade" PRIMARY KEY ("PK_Unidade"), 
 CONSTRAINT "Unique_Unidade_Nome" UNIQUE ("Nome")
 ) 
WITH (
		OIDS = FALSE
     )
	;


CREATE OR REPLACE RULE "UnidadeDuplicada" AS
ON INSERT TO "Unidade"
WHERE (EXISTS ( SELECT 1 FROM "Unidade" u WHERE u."Nome" = new."Nome")) DO INSTEAD NOTHING;


INSERT INTO "Unidade"("Nome")
VALUES ('GAVEA');


ALTER TABLE "TurmaHorario" ADD COLUMN "FK_Unidade" bigint NOT NULL DEFAULT 1;
ALTER TABLE "TurmaHorario" DROP CONSTRAINT "FK_TurmaHorario_Turma";
ALTER TABLE "TurmaHorario" ADD CONSTRAINT "FK_TurmaHorario_Turma" FOREIGN KEY ("FK_Turma")
REFERENCES "Turma" ("PK_Turma") MATCH SIMPLE
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "TurmaHorario" ADD CONSTRAINT "FK_TurmaHorario_Unidade" FOREIGN KEY ("FK_Unidade") REFERENCES "Unidade" ("PK_Unidade") ON UPDATE CASCADE ON DELETE CASCADE;

CREATE OR REPLACE VIEW "TurmaHorarioUnidade" AS 
SELECT th."FK_Turma", th."DiaSemana", th."HoraInicial", th."HoraFinal", u."Nome" AS "Unidade"
FROM "TurmaHorario" th
JOIN "Unidade" u ON u."PK_Unidade" = th."FK_Unidade";

ALTER TABLE "Turma" ADD COLUMN "Deletada" boolean NOT NULL DEFAULT false;
ALTER TABLE "Turma" DROP CONSTRAINT "FK_Turma_Professor";
ALTER TABLE "Turma" DROP CONSTRAINT "PK_Turma_Disciplina";
ALTER TABLE "Turma" ADD CONSTRAINT "FK_Turma_Professor" FOREIGN KEY ("FK_Professor")
REFERENCES "Professor" ("PK_Professor") MATCH SIMPLE
ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "Turma" ADD CONSTRAINT "PK_Turma_Disciplina" FOREIGN KEY ("FK_Disciplina")
REFERENCES "Disciplina" ("PK_Codigo") MATCH SIMPLE
ON UPDATE CASCADE ON DELETE CASCADE;


CREATE OR REPLACE RULE "TurmaDuplicada" AS
    ON INSERT TO "Turma"
       WHERE (EXISTS ( SELECT 1
                  FROM "Turma" t
		            WHERE t."FK_Disciplina"::text = new."FK_Disciplina"::text AND t."Codigo"::text = new."Codigo"::text AND t."PeriodoAno" = new."PeriodoAno")) DO INSTEAD  UPDATE "Turma" t SET "Vagas" = new."Vagas", "Destino" = new."Destino", "HorasDistancia" = new."HorasDistancia", "SHF" = new."SHF", "FK_Professor" = new."FK_Professor", "Deletada" = false
			      WHERE t."FK_Disciplina"::text = new."FK_Disciplina"::text AND t."Codigo"::text = new."Codigo"::text AND t."PeriodoAno" = new."PeriodoAno";


CREATE OR REPLACE VIEW "TurmaProfessor" AS 
 SELECT t."PK_Turma", t."Codigo" AS "CodigoTurma", t."FK_Disciplina" AS "CodigoDisciplina", t."PeriodoAno", t."Vagas", t."Destino", t."HorasDistancia", t."SHF", p."Nome" AS "NomeProfessor"
    FROM "Turma" t
       JOIN "Professor" p ON t."FK_Professor" = p."PK_Professor"
          WHERE t."Deletada" = false;

CREATE OR REPLACE RULE "DeletarTurma" AS
    ON DELETE TO "Turma" DO INSTEAD  (UPDATE "Turma" SET "Deletada" = true
      WHERE "Turma"."PK_Turma" = old."PK_Turma"; DELETE FROM "TurmaHorario" WHERE "FK_Turma" = old."PK_Turma");

CREATE OR REPLACE VIEW "AlunoDisciplinaTurmaSelecionada" AS 
 SELECT t."FK_Disciplina" AS "CodigoDisciplina", ats."FK_Turma", ats."FK_Aluno" AS "MatriculaAluno", ats."Opcao", ats."NoLinha"
    FROM "AlunoTurmaSelecionada" ats
       JOIN "Turma" t ON t."PK_Turma" = ats."FK_Turma" AND t."Deletada" = false;


CREATE OR REPLACE VIEW "MicroHorario" AS 
 SELECT d."PK_Codigo" AS "CodigoDisciplina", d."Nome" AS "NomeDisciplina", d."Creditos", t."PK_Turma", t."Codigo" AS "CodigoTurma", t."PeriodoAno", t."Vagas", t."Destino", t."HorasDistancia", t."SHF", p."Nome" AS "NomeProfessor", th."DiaSemana", th."HoraInicial", th."HoraFinal"
    FROM "Disciplina" d
       JOIN "Turma" t ON t."FK_Disciplina"::text = d."PK_Codigo"::text
          JOIN "Professor" p ON t."FK_Professor" = p."PK_Professor"
	     JOIN "TurmaHorario" th ON th."FK_Turma" = t."PK_Turma" AND t."Deletada" = false
	       ORDER BY d."PK_Codigo", d."Nome", d."Creditos", t."PK_Turma", t."Codigo", t."PeriodoAno", t."Vagas", t."Destino", t."HorasDistancia", t."SHF", p."Nome", th."DiaSemana", th."HoraInicial", th."HoraFinal";

INSERT INTO "Usuario"("PK_Login", "Senha", "Nome", "FK_TipoUsuario")
    VALUES ('admin', '164b0b9234f65b9fc6f01d72fda859241e0935cc', 'Administrador', 1);

CREATE OR REPLACE FUNCTION "LimpaBanco"()
RETURNS void AS
$BODY$
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
$BODY$
LANGUAGE sql VOLATILE
COST 100;
ALTER FUNCTION "LimpaBanco"()
OWNER TO prisma;


COMMIT;

