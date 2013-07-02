<?php

namespace Prisma\Model;

use Framework\Database;

class Curso 
{
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

		$skip = true;
		while($row = fgetcsv($file, 1000, ';'))
		{ 
			if(count($row) < 2) continue;
			unset($row[count($row)-1]);

			if(!self::persistRow($row))
			{
				$dbh->rollback();

				$error = $dbh->errorInfo();
				throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
			}
		}

		$dbh->commit();
		return true;
	}

	private static function persistRow($row)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('INSERT INTO "Curso"("PK_Curso", "Nome") VALUES (?, ?);');
		$sth->execute($row);

		return $sth->rowCount() > 0;
	}
}

