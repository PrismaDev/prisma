<?php

namespace Prisma\Model;

use Framework\Database;
use Prisma\Model\Turma;

class Disciplina
{
	public static function getAll()
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "PK_Nome" as "CodigoDisciplina", "Nome" as "NomeDisciplina", "Creditos" FROM "Disciplina";');
		$sth->execute();

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function getFaltaCursar($login)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "FK_Disciplina" as "CodigoDisciplina", "PeriodoSugerido", "Tentativas"
					FROM "AlunoDisciplina" WHERE "FK_Status" <> \'CP\' AND "FK_Aluno" = ?;');
		$sth->execute(array($login));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function getByUserIdDepend($login, $id)
	{
		$disciplina = self::getByUserId($login, $id);
		$disciplina['turmas'] = Turma::getByDisciplinaDepend($id);

		return $disciplina;
	}

	public static function getByUserId($login, $id)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "CodigoDisciplina", "NomeDisciplina", "Creditos", "Situacao", "Apto"
					FROM "MicroHorarioDisciplina" WHERE "Aluno" = ? AND "CodigoDisciplina" = ?;');
		$sth->execute(array($login, $id));

		return $sth->fetch(\PDO::FETCH_ASSOC);
	}


	public static function getById($id)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "PK_Codigo" as "CodigoDisciplina", "Nome" as "NomeDisciplina", "Creditos" FROM "Disciplina" WHERE "PK_Codigo" = ?;');
		$sth->execute(array($id));

		return $sth->fetch(\PDO::FETCH_ASSOC);
	}

	public static function persist($data)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "Disciplina"("PK_Nome", "Nome", "Creditos") VALUES (:PK_Codigo, :Nome, :Creditos);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception('['.$error[0].'/'.$error[1].']: '.$error[2]);
		}

		return $data['PK_Nome'];
	}
}
