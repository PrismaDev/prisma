<?php

namespace Prisma\Model;

use Framework\Database;

class AvisoDesabilitado 
{
	public static function add($login, $helperID)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('INSERT INTO "AvisoDesabilitado"("CodAviso", "FK_Aluno") VALUES (?, ?);');
		
		if($sth->execute(array($helperID, $login)))
			return true;
		else
			return false;
	}

	public static function del($login, $helperID)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('DELETE FROM "AvisoDesabilitado" WHERE "CodAviso" = ? AND "FK_Aluno" = ?;');
		
		if($sth->execute(array($helperID, $login)))
			return true;
		else
			return false;
	}

	public static function getAllByUser($login)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT "CodAviso" FROM "AvisoDesabilitado" WHERE "FK_Aluno" = ?;');
		$sth->execute(array($login));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}
}

