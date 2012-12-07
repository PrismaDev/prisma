<?php

namespace Prisma\Model;

use Framework\Database;

class Usuario
{
	public static function acceptTerm($login, $accept)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('UPDATE "Usuario" SET "TermoAceito"=? WHERE "PK_Login" = ?;');	
		$sth->execute(array($accept, $login));

		return $sth->rowCount() > 0;
	}

	public static function wasTermAccepted($login)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT 1 FROM "Usuario" WHERE "PK_Login" = ? AND "TermoAceito"=TRUE;');	
		$sth->execute(array($login));

		return $sth->fetch() != false;	
	}

	public static function getId($nome)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "PK_Professor" FROM "Professor" WHERE "Nome" = ?;');	
		$sth->execute(array($nome));

		if($result = $sth->fetch())
		{
			return $result['PK_Professor'];
		}
		else
		{
			//TODO: handle error
		}
	}
}
