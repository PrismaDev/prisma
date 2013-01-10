<?php

namespace Prisma\Model;

use Framework\Database;

class TurmaDestino
{
	public static function getByTurmaSet($turmaHash)
	{
		$dbh = Database::getConnection();	

		$sql = 'SELECT "FK_Turma", "Destino", "Vagas" FROM "TurmaDestino" WHERE "FK_Turma" IN (';

		$comma = false;
		foreach($turmaHash as $codigoTurma=>$index)
		{
			if($index >= 0)
			{
				if(!$comma) $comma = true;
				else $sql .= ', ';

				$sql .= $codigoTurma;
			}
		}

		$sql .= ');';

		$sth = $dbh->prepare($sql);
		$sth->execute();

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function getByTurma($turmaID)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "Destino", "Vagas"	FROM "TurmaDestino" WHERE "FK_Turma" = ?;');
		$sth->execute(array($turmaID));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function persist($data)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "TurmaDestino"("FK_Turma", "Destino", "Vagas")
						VALUES (:FK_Turma, :Destino, :Vagas);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}
	}
}
