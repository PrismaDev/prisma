<?php

namespace Prisma\Model;

use Framework\Database;

class Sugestao 
{
	public static function persist($login, $comment)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "Comentario"("FK_Usuario", "Comentario") VALUES (?, ?);');

		if($sth->execute(array($login, $comment)))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}
