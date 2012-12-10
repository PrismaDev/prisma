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

	/* ------------------------------------------------------------------- */

	public static function saveFromFile($file)
	{
		$file = fopen($file, 'r');

		if(!$file)
		{
			// TODO: log
			return false;
		}

		$dbh = Database::getConnection();
		$dbh->beginTransaction();

		$dbh->exec('DELETE FROM "Optativa";');

		$skip = true;
		while($row = fgetcsv($file, 1000, ';'))
		{ 
			if(count($row) < 2) continue;

			if(!self::persistRow($row))
			{
				$dbh->rollback();
				return false;
			}
		}

		$dbh->commit();
		return true;
	}

	private static function persistRow($row)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('INSERT INTO "Optativa"("PK_Codigo", "Nome") VALUES (?, ?);');
		$sth->execute(array($row[0], $row[1]));

		if(isset($row[2]) && !empty($row[2]))
		{
			$sth = $dbh->prepare('INSERT INTO "Disciplina"("PK_Codigo", "Nome", "Creditos") VALUES (?, \'Disciplina sem nome\', 0);');
			$sth->execute(array($row[2]));

			$sth = $dbh->prepare('INSERT INTO "OptativaDisciplina"("FK_Optativa", "FK_Disciplina") VALUES (?, ?);');
			$sth->execute(array($row[0], $row[2]));
		}

		return $sth->rowCount() > 0;
	}
}
