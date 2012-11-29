
SELECT EXISTS
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
) OR
NOT EXISTS
(
	SELECT 1 FROM "PreRequisitoGrupo" prg WHERE prg."FK_Disciplina" = $2
)
