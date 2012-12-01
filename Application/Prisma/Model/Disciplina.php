<?php

namespace Prisma\Model;

use Framework\Database;

class Disciplina
{
	public static function persist($data)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "Disciplina"("PK_Codigo", "Nome", "Creditos") VALUES (:PK_Codigo, :Nome, :Creditos);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception('['.$error[0].'/'.$error[1].']: '.$error[2]);
		}

		return $data['PK_Codigo'];
	}
}
