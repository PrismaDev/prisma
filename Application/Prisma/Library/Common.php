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

	public static function invArray($array)
	{
		if(is_array($array))
		{
			$new = array();

			foreach($array as $k=>$v)
			{
				$new[$v] = $k;
			}

			return $new;
		}
		return false;
	}

	public static function getNamesDictionary()
	{
		return array(
			'"Matricula"'		=> 0,
			'"NomeAluno"'		=> 1,
			'"CR"'			=> 2,
			'"UltimoAcesso"'	=> 3,
			'"Dependencia"'		=> 4,
			'"Dependencia"'		=> 5,
			'"FaltaCursar"'		=> 6,
			'"Selecionadas"'	=> 7,
			'"MicroHorario"' 	=> 8,
			'"Disciplinas"'		=> 9,
			'"Turmas"'		=> 10,
			'"Optativas"'		=> 11,
			'"Horarios"'		=> 12,
			'"CodigoDisciplina"' 	=> 13,
			'"CodigoTurma"' 	=> 14,
			'"CodigoOptativa"'	=> 15,
			'"PK_Turma"'		=> 16,
			'"FK_Turma"'		=> 17,
			'"NomeDisciplina"' 	=> 18,
			'"NomeProfessor"' 	=> 19,
			'"NomeOptativa"'	=> 20,
			'"Creditos"'		=> 21,
			'"Situacao"'		=> 22,
			'"Apto"'		=> 23,
			'"Vagas"'		=> 24,
			'"Destino"'		=> 25,
			'"HorasDistancia"'	=> 26,
			'"SHF"'			=> 27,
			'"PeriodoAno"'		=> 28,
			'"Tentativas"'		=> 29,
			'"Opcao"'		=> 30,
			'"NoLinha"'		=> 31,
			'"DiaSemana"'		=> 32,
			'"HoraInicial"'		=> 33,
			'"HoraFinal"'		=> 34,
		);

		return array(
			'Matricula'		=> 'MT',
			'NomeAluno'		=> 'NA',
			'CR'			=> 'CR',
			'Usuario'		=> 'US',
			'UltimoAcesso'		=> 'UA',
			'Dependencia'		=> 'DP',
			'FaltaCursar'		=> 'FC',
			'Selecionadas'		=> 'SLC',
			'MicroHorario' 		=> 'MH',
			'Disciplinas'		=> 'DCs',
			'Turmas'		=> 'TRs',
			'Optativas'		=> 'OPs',
			'Horarios'		=> 'HRs',
			'CodigoDisciplina' 	=> 'CD',
			'CodigoTurma' 		=> 'CT',
			'CodigoOptativa'	=> 'CO',
			'PK_Turma'		=> 'IDT',
			'FK_Turma'		=> 'IDT',
			'NomeDisciplina' 	=> 'ND',
			'NomeProfessor' 	=> 'NP',
			'NomeOptativa'		=> 'NO',
			'Creditos'		=> 'CR',
			'Situacao'		=> 'ST',
			'Apto'			=> 'APT',
			'Vagas'			=> 'VG',
			'Destino'		=> 'DT',
			'HorasDistancia'	=> 'HD',
		//	'SHF'			=> 'SHF',
			'PeriodoAno'		=> 'PA',
			'Tentativas'		=> 'TTs',
			'Opcao'			=> 'OP',
			'NoLinha'		=> 'NL',
			'DiaSemana'		=> 'DS',
			'HoraInicial'		=> 'HI',
			'HoraFinal'		=> 'HF',
		);

	}

	public static function namesMinimizer($str)
	{
		$dic = self::getNamesDictionary();

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
