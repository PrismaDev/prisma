<?php

namespace Prisma\Model;

use Framework\Database;

class Turma
{
	public static function persist($data)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "Turma"("FK_Disciplina", "Codigo", "PeriodoAno", "Vagas", "Destino", "HorasDistancia", "SHF", "FK_Professor")
						VALUES (:FK_Disciplina, :Codigo, :PeriodoAno, :Vagas, :Destino, :HorasDistancia, :SHF, :FK_Professor);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception('['.$error[0].'/'.$error[1].']: '.$error[2]);
		}

		$sth = $dbh->prepare('SELECT "PK_Turma" FROM "Turma" t WHERE t."FK_Disciplina" = :FK_Disciplina AND t."Codigo" = :Codigo AND t."PeriodoAno" = :PeriodoAno;');	
		$sth->execute(array(
			'FK_Disciplina' => $data['FK_Disciplina'],
			'Codigo' => $data['Codigo'],
			'PeriodoAno' => $data['PeriodoAno'],
		));

		if($result = $sth->fetch())
		{
			return $result['PK_Turma'];
		}
		else
		{
			//TODO: handle error
		}
	}
}
