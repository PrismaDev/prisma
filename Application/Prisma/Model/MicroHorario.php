<?php

namespace Prisma\Model;

use Framework\Database;
use Prisma\Library\Common;

use Prisma\Model\Disciplina;
use Prisma\Model\Professor;
use Prisma\Model\Turma;
use Prisma\Model\TurmaHorario;

class MicroHorario
{
	public static function getByFilter($filters = array())
	{
		$dbh = Database::getConnection();

		$sql = 'SELECT "CodigoDisciplina", "PK_Turma" FROM "MicroHorario" WHERE "PeriodoAno" = '.Common::getPeriodoAno();

		$sql .= self::makeSqlFilter($filters, 'CodigoDisciplina', 0);
		$sql .= self::makeSqlFilter($filters, 'NomeDisciplina', 0);
		$sql .= self::makeSqlFilter($filters, 'Creditos', 1);
		$sql .= self::makeSqlFilter($filters, 'CodigoTurma', 0);
		$sql .= self::makeSqlFilter($filters, 'Vagas', 1);
		$sql .= self::makeSqlFilter($filters, 'Destino', 0);
		$sql .= self::makeSqlFilter($filters, 'HorasDistancia', 1);
		$sql .= self::makeSqlFilter($filters, 'SHF', 1);
		$sql .= self::makeSqlFilter($filters, 'NomeProfessor', 0);
		$sql .= self::makeSqlFilter($filters, 'DiaSemana', 1);
		$sql .= self::makeSqlFilter($filters, 'HoraInicial', 1);
		$sql .= self::makeSqlFilter($filters, 'HoraFinal', 1);

		$sql .= ' GROUP BY "CodigoDisciplina", "PK_Turma"';

		if(isset($filters['Quantidade']))
		{
			$sql .= 'LIMIT '.$filters['Quantidade'];

			if(isset($filters['Pagina']))
			{
				$offset = $filters['Quantidade'] * $filters['Pagina'];

				$sql .= ' OFFSET '.$offset;
			}
		}

		$sql .= ';';

		$sth = $dbh->prepare($sql);
		$sth->execute();

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	private static function makeSqlFilter($filters, $column, $type)
	{
		if(isset($filters[$column]) && !empty($filters[$column]))
		{
			switch($type)
			{
				CASE 0:
					return ' AND "'.$column.'" ILIKE \'%'.$filters[$column].'%\'';

				CASE 1:
					return ' AND "'.$column.'" = '.$filters[$column];
			}
		}

		return '';
	}

	/* --------------------------------------------------------------------------------------- */

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
		while($row = self::csvRead($file))
		{ 
			//skip meta data and header
			if($skip) 
			{
				if(count($row) > 8) 
					$skip = false;

				continue;
			}

			if(count($row) < 9) continue;

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
		/*
			00 -> disciplina
			01 -> nome da disciplina
			02 -> professor
			03 -> creditos
			04 -> turma
			05 -> destino
			06 -> vagas
			07 -> turno
			08 -> horario/sala/unidade
			09 -> horas distancia
			10 -> shf
			11 -> pre-req
		*/

		try{
			$discParams = array(
				'PK_Codigo' 	=> $row[0],
				'Nome' 		=> $row[1],
				'Creditos' 	=> $row[3],
			);
			$discID = Disciplina::persist($discParams);

			/* --------------------------------------------- */

			$profParams = array(
				'Nome' 	=> $row[2],
			);
			$profID = Professor::persist($profParams);

			/* --------------------------------------------- */

			$turmaParams = array(
				'FK_Disciplina'		=> $discID,
				'Codigo'		=> $row[4],
				'PeriodoAno'		=> Common::getPeriodoAno(),
				'Vagas'			=> $row[6],
				'Destino'		=> $row[5],
				'HorasDistancia'	=> $row[9],
				'SHF'			=> $row[10],
				'FK_Professor'		=> $profID,
			);
			$turmaID = Turma::persist($turmaParams);

			/* --------------------------------------------- */

			$horarios = self::csvParseHorario($row[8]);
			$horLen = count($horarios);

			for($i = 0; $i < $horLen; ++$i)
			{
				if(!isset($horarios[$i]['DiaSemana'])) continue;

				$horarioParams = array
				(
					'FK_Turma'	=> $turmaID,
					'DiaSemana'	=> $horarios[$i]['DiaSemana'],
					'HoraInicial'	=> $horarios[$i]['Horario']['Inicial'],
					'HoraFinal'	=> $horarios[$i]['Horario']['Final'],
				);
				TurmaHorario::persist($horarioParams);
			}
		}
		catch(\Exception $e)
		{
			//TODO: log error message
			echo('Query error: '.$e->getMessage());

			return false;
		}

		return true;
	}

	private static function csvRead($file)
	{
		$row = fgetcsv($file, 1000, ';');

		Common::escapeGarbageChars($row);

		return $row;
	}

	private static function csvParseHorario($horarios)
	{
		$horarios = explode('  ', $horarios);

		$hor_len = count($horarios);

		$parsed = array();

		while($hor_len)
		{
			$horario = explode(' ', $horarios[$hor_len-1]);

			$parsed[$hor_len-1] = array();
			
			if(strlen($horario[0]) == 3) //dia da semana
			{
				$parsed[$hor_len-1]['DiaSemana'] = Common::weekdayToInteger($horario[0]);

				$parsed[$hor_len-1]['Horario'] = array();
				list(
					$parsed[$hor_len-1]['Horario']['Inicial'],
					$parsed[$hor_len-1]['Horario']['Final']
				) = explode('-',$horario[1]);

//				$parsed[$hor_len-1]['Sala'] = $horario[2];
//				$parsed[$hor_len-1]['Unidade'] = $horario[4];
			}
			else
			{
				$parsed[$hor_len-1]['Unidade'] = $horario[0];
			}

			--$hor_len;
		}

		return $parsed;
	}
}

