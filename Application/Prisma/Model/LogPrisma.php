<?php

namespace Prisma\Model;

use Framework\Database;
use Framework\Router;

class LogPrisma 
{
	public static function pathLog($ip, $uri, $hash, $user)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('INSERT INTO "Log"("IP", "URI", "HashSessao", "FK_Usuario") VALUES (?, ?, ?, ?);');

		if(!$sth->execute(array($ip, $uri, $hash, $user)))
		{	
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}
	}

	public static function errorLog($ip, $uri, $hash, $user, $notes)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('INSERT INTO "Log"("IP", "URI", "HashSessao", "FK_Usuario", "Erro", "Notas") VALUES (?, ?, ?, ?, true, ?);');

		if($sth->execute(array($ip, $uri, $hash, $user, $notes)))
		{
			return true;
		}
		else
		{	
			// TODO
		}
	}
}
