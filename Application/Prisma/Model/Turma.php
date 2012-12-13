<?php

namespace Prisma\Model;

use Framework\Database;
use Prisma\Library\Common;
use Prisma\Model\TurmaHorario;

class Turma
{
	public static function getByDisciplinaDepend($discID)
	{
		$turmas = self::getByDisciplina($discID);
		$turmasSize = count($turmas);

		for($i = 0; $i < $turmasSize; ++$i)
		{
			$turmas[$i]['Horarios'] = TurmaHorario::getByTurma($turmas[$i]['PK_Turma']);
		}

		return $turmas;
	}

	public static function getByDisciplina($discID)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "PK_Turma", "CodigoTurma", "PeriodoAno", "Vagas", 
						"Destino", "HorasDistancia", "SHF", "NomeProfessor"
					FROM "TurmaProfessor" WHERE "CodigoDisciplina" = ? AND "PeriodoAno" = ?;');
		$sth->execute(array($discID, Common::getPeriodoAno()));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function getByDiscSetDepend($disciplinaHash)
	{
		$turmas = self::getByDiscSet($disciplinaHash);
		
		$myTurmaHash = array();
		foreach($turmas as $k=>$turma)
		{
			$myTurmaHash[$turma['PK_Turma']] = $k; 
		}

		$horarios = TurmaHorario::getByTurmaSet($myTurmaHash);

		foreach($horarios as $horario)
		{
			$idx = $myTurmaHash[$horario['FK_Turma']];
			unset($horario['FK_Turma']);

			$turmas[$idx]['Horarios'][] = $horario;
		}

		return $turmas;
	}

	public static function getByDiscSet($disciplinaHash)
	{
		$dbh = Database::getConnection();	

		$sql = 'SELECT "PK_Turma", "CodigoDisciplina", "CodigoTurma", "PeriodoAno", "Vagas", 
				"Destino", "HorasDistancia", "SHF", "NomeProfessor"
			FROM "TurmaProfessor" WHERE "PeriodoAno" = ? AND "CodigoDisciplina" IN (';		

		$comma = false;
		foreach($disciplinaHash as $codigoDisciplina=>$index)
		{
			if($index >= 0)
			{
				if(!$comma) $comma = true;
				else $sql .= ', ';

				$sql .= '\''.$codigoDisciplina.'\'';
			}
		}

		$sql .= ');';

		$sth = $dbh->prepare($sql);
		$sth->execute(array(Common::getPeriodoAno()));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function persist($data)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "Turma"("FK_Disciplina", "Codigo", "PeriodoAno", "Vagas", "Destino", "HorasDistancia", "SHF", "FK_Professor")
						VALUES (:FK_Disciplina, :Codigo, :PeriodoAno, :Vagas, :Destino, :HorasDistancia, :SHF, :FK_Professor);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}

		return self::getId($data);
	}

	public static function getId($data)
	{
		$dbh = Database::getConnection();	

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

