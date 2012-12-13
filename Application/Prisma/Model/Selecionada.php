<?php

namespace Prisma\Model;

use Framework\Database;

class Selecionada
{
	public static function getAll($aluno)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT "CodigoDisciplina", "FK_Turma", "Opcao", "NoLinha" FROM "AlunoDisciplinaTurmaSelecionada" WHERE "MatriculaAluno" = ?;');
		$sth->execute(array($aluno));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function persist($login, $data)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('INSERT INTO "AlunoTurmaSelecionada"("FK_Aluno", "FK_Turma", "Opcao", "NoLinha")
					VALUES (?, ?, ?, ?);');

		if($sth->execute(array($login,$data->FK_Turma,$data->Opcao,$data->NoLinha,)))
		{
			return true;
		}
		else
		{
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}
	}

	public static function remove($login, $turma)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('DELETE FROM "AlunoTurmaSelecionada" WHERE "FK_Aluno" = ? AND "FK_Turma" = ?;');

		if($sth->execute(array($login, $turma)))
		{
			return true;
		}
		else
		{
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}
	}
}
