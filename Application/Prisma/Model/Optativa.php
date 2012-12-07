<?php

namespace Prisma\Model;

use Framework\Database;

class Optativa
{
	public static function getByUserDepend($login)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "CodigoOptativa", "NomeOptativa", "PeriodoSugerido" as "PeriodoAno"
					FROM "FaltaCursarOptativa" WHERE "Aluno" = ?;');
		$sth->execute(array($login));

		$optativas = $sth->fetchAll(\PDO::FETCH_ASSOC);
		$optativasLen = count($optativas);

		for($i = 0; $i < $optativasLen; ++$i)
		{
			$optativas[$i]['Disciplinas'] = self::getByOptativa($optativas[$i]['CodigoOptativa']);
		}

		return $optativas;
	}

	public static function getByOptativa($opID)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT "FK_Disciplina" as "CodigoDisciplina" FROM "OptativaDisciplina" WHERE "FK_Optativa" = ?;');
		$sth->execute(array($opID));

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
