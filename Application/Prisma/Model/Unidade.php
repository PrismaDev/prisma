<?php

namespace Prisma\Model;

use Framework\Database;

class Unidade
{
	public static function persist($name)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "Unidade"("Nome") VALUES (?);');

		if(!$sth->execute(array($name)))
		{
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}

		return self::getIdByName($name);
	}

	public static function getIdByName($name)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "PK_Unidade" FROM "Unidade" WHERE "Nome" = ?;');

		if(!$sth->execute(array($name)))
		{
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}

		if($result = $sth->fetch())
		{
			return $result['PK_Unidade'];
		}
		else
		{
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): Turma nao encontrada!');
		}
	}
}
