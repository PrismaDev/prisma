CREATE OR REPLACE VIEW "EstatisticaDemandaTurma" AS 
SELECT "Turma"."FK_Disciplina", "Turma"."Codigo", 
	( 
		SELECT sum("TurmaDestino"."Vagas") AS sum 
		FROM "TurmaDestino" 
		WHERE "TurmaDestino"."FK_Turma" = "Turma"."PK_Turma"
	) AS "Vagas", 
	( 
		SELECT count(*) AS "Demanda"
		FROM 
		( 
			SELECT DISTINCT "AlunoTurmaSelecionada"."FK_Aluno", "AlunoTurmaSelecionada"."FK_Turma"
			FROM "AlunoTurmaSelecionada"
			WHERE "AlunoTurmaSelecionada"."FK_Turma" = "Turma"."PK_Turma"
		) t1
	) AS "Demanda"
FROM "Turma"
WHERE "Turma"."Deletada" = false;

