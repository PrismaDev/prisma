<?php

namespace Prisma\Model;

use Framework\Database;
use Prisma\Library\Common;

use Prisma\Model\Disciplina;
use Prisma\Model\Professor;
use Prisma\Model\Turma;
use Prisma\Model\TurmaDestino;
use Prisma\Model\TurmaHorario;
use Prisma\Model\Unidade;

class MicroHorario
{
	public static function getByFilter($login, $filters = array())
	{
		$filters['Aluno'] = $login;

		$dbh = Database::getConnection();

		$sql = 'SELECT "CodigoDisciplina", "PK_Turma" FROM "MicroHorario" mh
				LEFT JOIN "AlunoDisciplina" ad
					on mh."CodigoDisciplina" = ad."FK_Disciplina" and "FK_Aluno" = :Aluno and ad."FK_Status" <> \'AP\'
				WHERE "PeriodoAno" = '.Common::getPeriodoAno();

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
					$filters[$filterAvail[0]] = str_replace(' ', '%', $filters[$filterAvail[0]]);

					$sql .= ' AND "'.$filterAvail[0].'" ILIKE :'.$filterAvail[0];
					$filters[$filterAvail[0]] = '%'.$filters[$filterAvail[0]].'%';
				}
			}
			else
			{
				unset($filters[$filterAvail[0]]);
			}
		}

		$sql .= ' GROUP BY ad."Periodo", "CodigoDisciplina", "PK_Turma"
				ORDER BY ad."Periodo", "CodigoDisciplina", "PK_Turma"';

		if(!isset($filters['Quantidade'])) 
			$filters['Quantidade'] = 5;
		else if($filters['Quantidade'] > 20)
			$filters['Quantidade'] = 20;
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
			'HorasDistancia'	=> $row[9],
			'SHF'			=> $row[10],
			'FK_Professor'		=> $profID,
		);
		$turmaID = Turma::persist($turmaParams);

		/* --------------------------------------------- */

		$destinoParams = array(
			'FK_Turma'	=> $turmaID,
			'Destino'	=> $row[5],
			'Vagas'		=> $row[6],
		);
		TurmaDestino::persist($destinoParams);

		/* --------------------------------------------- */

		$horarios = self::csvParseHorario($row[8]);
		$horLen = count($horarios);

		for($i = 0; $i < $horLen; ++$i)
		{
			$unidadeID = Unidade::persist($horarios[$i]['Unidade']);

			$horarioParams = null;
			if(isset($horarios[$i]['DiaSemana']))
			{
				$horarioParams = array
				(
					'FK_Turma'	=> $turmaID,
					'DiaSemana'	=> $horarios[$i]['DiaSemana'],
					'HoraInicial'	=> $horarios[$i]['Horario']['Inicial'],
					'HoraFinal'	=> $horarios[$i]['Horario']['Final'],
					'FK_Unidade'	=> $unidadeID,
				);
			}
			else
			{
				$horarioParams = array
				(
					'FK_Turma'	=> $turmaID,
					'DiaSemana'	=> 0,
					'HoraInicial'	=> 0,
					'HoraFinal'	=> 0,
					'FK_Unidade'	=> $unidadeID,
				);
			}

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
		$horarios = explode(' ', trim($horarios));

		$offset = 0;
		$parsed = array();
		$parsedIdx = 0;
		while(isset($horarios[$offset]))
		{
			$lenFirst = strlen($horarios[$offset+0]);

			if($lenFirst < 3)
			{
				$offset++;
				continue;
			}

			$parsed[$parsedIdx] = array();
			
			if($lenFirst == 3) //dia da semana
			{
				$parsed[$parsedIdx]['DiaSemana'] = Common::weekdayToInteger($horarios[$offset+0]);
				list
				(
					$parsed[$parsedIdx]['Horario']['Inicial'],
					$parsed[$parsedIdx]['Horario']['Final']
				) = explode('-',$horarios[$offset+1]);

				$parsed[$parsedIdx]['Unidade'] = $horarios[$offset+4];

				$offset += 6;
			}
			else
			{
				$parsed[$parsedIdx]['Unidade'] = $horarios[$offset+0];

				$offset += 2;
			}
			$parsedIdx++;
		}

		return $parsed;
	}
}

