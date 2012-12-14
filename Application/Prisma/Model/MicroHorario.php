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

		$filtersAvail = array(
			array('CodigoDisciplina', 0),
			array('NomeDisciplina', 0),
			array('Creditos', 1),
			array('CodigoTurma', 0),
			array('Vagas', 1),
			array('Destino', 0),
			array('HorasDistancia', 1),
			array('SHF', 1),
			array('NomeProfessor', 0),
			array('DiaSemana', 1),
			array('HoraInicial', 1),
			array('HoraFinal', 1),
		);

		foreach($filtersAvail as $filterAvail)
		{
			if(isset($filters[$filterAvail[0]]) && !empty($filters[$filterAvail[0]]))
			{
				if($filterAvail[1])
				{
					$sql .= ' AND "'.$filterAvail[0].'" = :'.$filterAvail[0];
				}
				else
				{
					$sql .= ' AND "'.$filterAvail[0].'" ILIKE :'.$filterAvail[0];
					$filters[$filterAvail[0]] = '%'.$filters[$filterAvail[0]].'%';
				}
			}
		}

		$sql .= ' GROUP BY "CodigoDisciplina", "PK_Turma"';

		if(!isset($filters['Quantidade'])) 
			$filters['Quantidade'] = 5;
		$sql .= ' LIMIT :Quantidade';

		if(isset($filters['Pagina']))
		{
			$filters['Offset'] = $filters['Quantidade']  * $filters['Pagina'];
			unset($filters['Pagina']);

			$sql .= ' OFFSET :Offset';
		}
		$sql .= ';';

		$sth = $dbh->prepare($sql);
		if(!$sth->execute($filters))
		{
			$error = $dbh->errorInfo();
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): '.$error[2]);
		}

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
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

