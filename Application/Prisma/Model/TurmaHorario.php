<?php

namespace Prisma\Model;

use Framework\Database;

class TurmaHorario
{
	public static function getByTurmaSet($turmaHash)
	{
		$dbh = Database::getConnection();	

		$sql = 'SELECT "FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal", "Unidade"
			FROM "TurmaHorarioUnidade" WHERE "FK_Turma" IN (';

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

		$sth = $dbh->prepare('SELECT "DiaSemana", "HoraInicial", "HoraFinal", "Unidade"
					FROM "TurmaHorarioUnidade" WHERE "FK_Turma" = ?;');
		$sth->execute(array($turmaID));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function persist($data)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "TurmaHorario"("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal", "FK_Unidade")
						VALUES (:FK_Turma, :DiaSemana, :HoraInicial, :HoraFinal, :FK_Unidade);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}
	}
}
