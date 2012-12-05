<?php

namespace Prisma\Model;

use Framework\Database;

class Selecionada
{
	public static function getAll($aluno)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT "DisciplinaDaTurma"("FK_Turma") as "CodigoDisciplina", "FK_Turma", "Opcao", "NoLinha"
					FROM "AlunoTurmaSelecionada" WHERE "FK_Aluno" = ?;');
		$sth->execute(array($aluno));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function persist($data)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('INSERT INTO "AlunoTurmaSelecionada"("FK_Aluno", "FK_Turma", "Opcao", "NoLinha")
					VALUES (:FK_Aluno, :FK_Turma, :Opcao, :NoLinha);');
		$sth->execute($data);
	
		return $sth->rowCount > 0;
	}
}
