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
			$str = utf8_encode($str);
			$str = trim($str);

			$str = str_replace(chr(0x00), '', $str);

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
			'"Aluno"'		=> 0,
			'"Strings"'		=> 1,
			'"Matricula"'		=> 2,
			'"NomeAluno"'		=> 3,
			'"CR"'			=> 4,
			'"UltimoAcesso"'	=> 5,
			'"Dependencia"'		=> 6,
			'"Dependencia"'		=> 7,
			'"FaltaCursar"'		=> 8,
			'"Selecionadas"'	=> 9,
			'"MicroHorario"' 	=> 10,
			'"Disciplinas"'		=> 11,
			'"Turmas"'		=> 12,
			'"Optativas"'		=> 13,
			'"Horarios"'		=> 14,
			'"CodigoDisciplina"' 	=> 15,
			'"CodigoTurma"' 	=> 16,
			'"CodigoOptativa"'	=> 17,
			'"PK_Turma"'		=> 18,
			'"FK_Turma"'		=> 19,
			'"NomeDisciplina"' 	=> 20,
			'"NomeProfessor"' 	=> 21,
			'"NomeOptativa"'	=> 22,
			'"Creditos"'		=> 23,
			'"Situacao"'		=> 24,
			'"Apto"'		=> 25,
			'"Vagas"'		=> 26,
			'"Destino"'		=> 27,
			'"HorasDistancia"'	=> 28,
			'"SHF"'			=> 29,
			'"PeriodoAno"'		=> 30,
			'"Tentativas"'		=> 31,
			'"Opcao"'		=> 32,
			'"NoLinha"'		=> 33,
			'"DiaSemana"'		=> 34,
			'"HoraInicial"'		=> 33,
			'"HoraFinal"'		=> 34,
		);

		return array(
			'Aluno'			=> 'ALs',
			'Strings'		=> 'STRs',
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
