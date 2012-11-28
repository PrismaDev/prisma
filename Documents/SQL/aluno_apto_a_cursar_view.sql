drop view alunoaptoacursar;
create view alunoaptoacursar as
	select a.PK_Matricula as CodAluno, d.PK_Codigo as CodDisc
	from faltacursaraluno fca
	inner join aluno a
	on fca.FK_MatAluno = a.PK_Matricula
	inner join disciplina d
	on d.PK_Codigo = fca.FK_CodDisc
	inner join alunocreditoscursados acc
	on acc.Aluno = a.PK_Matricula
	where 	(select count(*) from prerequisitogrupo where FK_Disciplina = fca.FK_CodDisc) = 0 or
		exists
		(
			select 1
			from prerequisitogrupo prg
			where prg.FK_Disciplina = fca.FK_CodDisc and 
				acc.QtdTotal >= prg.PreReqCredito and
				(
					select count(*)
					from prerequisitogrupodisciplina prgd 
					left join alunodisciplinacursada adc 
					on prgd.FK_Disciplina = adc.FK_Disciplina
					where 	prgd.FK_Grupo = prg.PK_Grupo and 
						adc.FK_Aluno = a.PK_Matricula and 
						adc.FK_Disciplina is null
				) = 0
		);
