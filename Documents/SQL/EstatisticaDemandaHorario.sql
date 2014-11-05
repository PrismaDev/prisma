REATE OR REPLACE VIEW "EstatisticaDemandaHorario" AS 
SELECT ats."Opcao", ( SELECT "Unidade"."Nome"
		FROM "Unidade"
		WHERE "Unidade"."PK_Unidade" = th."FK_Unidade") AS "Unidade", th."DiaSemana", th."HoraInicial", th."HoraFinal", count(*) AS "Demanda"
FROM "AlunoTurmaSelecionada" ats
JOIN "TurmaHorario" th ON th."FK_Turma" = ats."FK_Turma"
GROUP BY ats."Opcao", th."DiaSemana", th."HoraInicial", th."HoraFinal", th."FK_Unidade";

