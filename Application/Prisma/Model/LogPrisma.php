<?php

namespace Prisma\Model;

use Framework\Database;
use Framework\Router;

class LogPrisma 
{
	public static function pathLog($ip, $uri, $hash, $user, $browser)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('INSERT INTO "Log"("IP", "URI", "HashSessao", "FK_Usuario", "Browser") VALUES (?, ?, ?, ?, ?);');

		if(!$sth->execute(array($ip, $uri, $hash, $user, $browser)))
		{	
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}
	}

	public static function errorLog($ip, $uri, $hash, $user, $browser, $notes)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('INSERT INTO "Log"("IP", "URI", "HashSessao", "FK_Usuario", "Erro", "Notas", "Browser") VALUES (?, ?, ?, ?, true, ?, ?);');

		if($sth->execute(array($ip, $uri, $hash, $user, $notes, $browser)))
		{
			return true;
		}
		else
		{	
			print_r($dbh->errorInfo());
			exit;
		}
	}
}
