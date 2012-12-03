<?php

namespace Prisma\Model;

use Framework\Database;

class Disciplina
{
	public static function getAll()
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "PK_Codigo" as "CodigoDisciplina", "Nome" as "NomeDisciplina", "Creditos" FROM "Disciplina";');
		$sth->execute();

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function getByUserDepend($login)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "Aluno", "Codigo" as "CodigoDisciplina", "Nome", "Creditos", "Situacao", "Tentativas", "Apto"
					FROM "FaltaCursarDisciplina" WHERE ad."FK_Aluno" = ?;');
		$sth->execute(array($login));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
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

		$sth = $dbh->prepare('INSERT INTO "Disciplina"("PK_Codigo", "Nome", "Creditos") VALUES (:PK_Codigo, :Nome, :Creditos);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception('['.$error[0].'/'.$error[1].']: '.$error[2]);
		}

		return $data['PK_Codigo'];
	}
}
