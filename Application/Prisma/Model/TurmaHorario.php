<?php

namespace Prisma\Model;

use Framework\Database;

class TurmaHorario
{
	public static function persist($data)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "TurmaHorario"("FK_Turma", "DiaSemana", "HoraInicial", "HoraFinal")
						VALUES (:FK_Turma, :DiaSemana, :HoraInicial, :HoraFinal);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception('['.$error[0].'/'.$error[1].']: '.$error[2]);
		}
	}
}
