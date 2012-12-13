<?php

namespace Prisma\Model;

use Framework\Database;

class Professor
{
	public static function persist($data)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "Professor"("Nome") VALUES (:Nome);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}

		return self::getId($data['Nome']);
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
