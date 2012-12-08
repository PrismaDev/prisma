<?php

namespace Prisma\Model;

use Framework\Database;

class PreRequisito
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

		$dbh->exec('DELETE FROM "PreRequisitoGrupo";');

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

		$sth = $dbh->prepare('INSERT INTO "Disciplina"("PK_Codigo", "Nome", "Creditos") VALUES (?, \'<SEM_NOME>\', 0);');
		$sth->execute(array($row[0]));

		$sth = $dbh->prepare('INSERT INTO "PreRequisitoGrupo"("CreditosMinimos", "FK_Disciplina") VALUES (?, ?);');
		$sth->execute(array($row[1], $row[0]));

		$sth = $dbh->query('SELECT currval(\'seq_prerequisito\');');
		$prID = $sth->fetch();
		$prID = $prID['currval'];

		for($i = 2; $i <= 5; ++$i)
		{
			if(isset($row[$i]) && !empty($row[$i]))
			{
				$sth = $dbh->prepare('INSERT INTO "Disciplina"("PK_Codigo", "Nome", "Creditos") VALUES (?, \'<SEM_NOME>\', 0);');
				$sth->execute(array($row[$i]));

				$sth = $dbh->prepare('INSERT INTO "PreRequisitoGrupoDisciplina"("FK_PreRequisitoGrupo", "FK_Disciplina") VALUES (?, ?);');
				$sth->execute(array($prID, $row[$i]));
			}
		}

		return $sth->rowCount() > 0;
	}
}

