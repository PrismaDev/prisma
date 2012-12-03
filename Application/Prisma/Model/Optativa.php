<?php

namespace Prisma\Model;

use Framework\Database;

class Optativa
{
	public static function getByUserDepend($login)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "Aluno", "CodigoOptativa", "NomeOptativa", "PeriodoSugerido"
					FROM "FaltaCursarOptativa" WHERE "Aluno" = ?;');
		$sth->execute(array($login));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function getDisciplinas($login, $opID)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "Aluno", "CodigoOptativa", "CodigoDisciplina", "Situacao", "Apto"
					FROM "FaltaCursarOptativaDisciplina" WHERE "Aluno" = ? AND "CodigoOptativa" = ?;');
		$sth->execute(array($login, $opID));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}
}
