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
			'Strings'		=> 'w',
			'Matricula'		=> 'e',
			'NomeAluno'		=> 'r',
			'Usuario'		=> 'q',
			'CoeficienteRendimento'	=> 't',
			'UltimoAcesso'		=> 'y',
			'Dependencia'		=> 'u',
			'Dependencia'		=> 'i',
			'FaltaCursar'		=> 'o',
			'Selecionadas'		=> 'p',
			'MicroHorario' 		=> 'a',
			'Disciplinas'		=> 's',
			'Turmas'		=> 'd',
			'Optativas'		=> 'f',
			'Horarios'		=> 'g',
			'CodigoDisciplina' 	=> 'h',
			'CodigoTurma' 		=> 'j',
			'CodigoOptativa'	=> 'k',
			'PK_Turma'		=> 'l',
			'FK_Turma'		=> 'z',
			'NomeDisciplina' 	=> 'x',
			'NomeProfessor' 	=> 'c',
			'NomeOptativa'		=> 'v',
			'Creditos'		=> 'b',
			'Situacao'		=> 'n',
			'Apto'			=> 'm',
			'Vagas'			=> 'Q',
			'Destino'		=> 'W',
			'HorasDistancia'	=> 'E',
			'SHF'			=> 'R',
			'PeriodoAno'		=> 'T',
			'Tentativas'		=> 'Y',
			'Opcao'			=> 'U',
			'NoLinha'		=> 'I',
			'DiaSemana'		=> 'O',
			'HoraInicial'		=> 'P',
			'HoraFinal'		=> 'A',
			'Curso'			=> 'S'
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
