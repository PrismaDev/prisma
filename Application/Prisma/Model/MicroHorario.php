<?php

namespace Prisma\Model;

use Framework\Database;
use Prisma\Library\Common;

class MicroHorario
{
	public static function get($filters)
	{
		
	}

	public static function save($file)
	{
		$file = fopen($file, 'r');

		if(!$file)
		{
			return 'Erro ao abrir arquivo'; //TODO: tratar melhor isso aqui
		}

		$rowNumber = 0;
		while($row = self::readCSV($file))
		{
			if(count($row) < 6) continue; //skip meta data

			//TODO: save
		}
		
		return true;
	}

	private static function readCSV($file)
	{
		$row = fgetcsv($file, 1000, ';');

		Common::escapeGarbageChars($row);

		return $row;
	}

	private static function parseHorario($horarios)
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
				$parsed[$hor_len-1]['diaSemana'] = $horario[0];

				list(
					$parsed[$hor_len-1]['horario']['inicial'],
					$parsed[$hor_len-1]['horario']['final']
				) = explode('-',$horario[1]);

				$parsed[$hor_len-1]['sala'] = $horario[2];
				$parsed[$hor_len-1]['unidade'] = $horario[4];
			}
			else
			{
				$parsed[$hor_len-1]['unidade'] = $horario[0];
			}

			--$hor_len;
		}

		return $parsed;
	}
}

