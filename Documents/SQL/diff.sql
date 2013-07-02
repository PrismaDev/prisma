
-----------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION "AlunoDisciplinaApto"("pAluno" character varying, "pDisciplina" character varying)
  RETURNS integer AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-----------------------------------------------------------------------------------------------------------------

-- Function: "LimpaBanco"()

-- DROP FUNCTION "LimpaBanco"();

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
	TRUNCATE "Log" CASCADE;
	TRUNCATE "Comentario" CASCADE;
	TRUNCATE "Unidade" CASCADE;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;

-----------------------------------------------------------------------------------------------------------------

DROP VIEW "PopulaAlunoDisciplinaAptoCacheFaltaCursarDisciplina";
DROP VIEW "PopulaAlunoDisciplinaAptoCacheFaltaCursarOptativa";
DROP VIEW "PopulaAlunoDisciplinaAptoCacheTurmaSelecionada";
DROP VIEW "AlunoPreRequisitoGrupoDisciplinaApto";
DROP VIEW "AlunoPreRequisitoGrupoDisciplina";

DROP TABLE "AlunoDisciplinaAptoCache";
DROP TABLE "VariavelAmbiente";

-----------------------------------------------------------------------------------------------------------------

