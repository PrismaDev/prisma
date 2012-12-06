<?php

namespace Prisma\Library;

class Common
{
	public static function getPeriodoAno()
	{
		$ano = date('Y');
		$mes = date('n');

		if($mes > 10)
		{
			return ($ano+1).'1';
		}
		else if ($mes < 3)
		{
			return $ano.'1';
		}
		else
		{
			return $ano.'2';
		}
	}
	
	public static function escapeGarbageChars(&$str)
	{
		if(!isset($str) || empty($str)) return;

		if(is_array($str))
		{
			$len = count($str);
			for($i = 0; $i < $len; ++$i)
			{
				self::escapeGarbageChars($str[$i]);
			}
		}
		else
		{
			$str = trim($str);
			$str = str_replace(chr(0x00), '', $str);
			$str = str_replace(chr(0xa0), '', $str);
			$str = str_replace(chr(0xfe), '', $str);
			$str = str_replace(chr(0xff), '', $str);

			if($str == '') $str = null;
		}
	}

	public static function namesMinimizer($str)
	{
		$dic = array(
			'Dependencia'		=> 'DP',
			'FaltaCursar'		=> 'FC',
			'Selecionada'		=> 'SLC',
			'MicroJorario' 		=> 'MH',
			'Disciplinas'		=> 'DCs',
			'Turmas'		=> 'TRs',
			'Horarios'		=> 'HRs',
			'CodigoDisciplina' 	=> 'CD',
			'CodigoTurma' 		=> 'CT',
			'PK_Turma'		=> 'PKT',
			'NomeDisciplina' 	=> 'ND',
			'NomeProfessor' 	=> 'NP',
			'Creditos'		=> 'CR',
			'Situacao'		=> 'ST',
			'Apto'			=> 'APT',
			'Vagas'			=> 'VG',
			'Destino'		=> 'DT',
			'HorasDistancia'	=> 'HD',
			//'SHF'			=> 'SHF',
			'DiaSemana'		=> 'DS',
			'HoraInicial'		=> 'HI',
			'HoraFinal'		=> 'HF',
		);

		foreach($dic as $k=>$v)
		{
			$str = str_replace($k,$v,$str);
		}

		return $str;
	}

	public static function weekdayToInteger($str)
	{
		switch(strtoupper($str))
		{
			CASE 'SEG': 
				return 2;

			CASE 'TER': 
				return 3;

			CASE 'QUA':
				return 4;

			CASE 'QUI':
				return 5;

			CASE 'SEX':
				return 6;

			CASE 'SAB':
				return 7;

			CASE 'DOM':
				return 1;

		}
		return 0;
	}

	/* TODO: function below is not working */
	public static function stripAccents($str)
	{
		$from = 'ãÃâÂáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏõÕôÔóÓòÒöÖûÛúÚùÙüÜçÇ';
		$to   = 'aAaAaAaAaAeEeEeEeEiIiIiIiIoOoOoOoOoOuUuUuUuUcC';

		return strtr($str, $from, $to);
	}
}
