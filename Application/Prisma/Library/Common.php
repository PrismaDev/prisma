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
		//	$str = utf8_encode($str);
			$str = trim($str);

			$str = str_replace(chr(0x00), '', $str);
			$str = str_replace(chr(0xba), '', $str);

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
			'Curso'			=> 'S',
			'Unidade'		=> 'D',
			'Avisos'		=> 'E',
			'CodAviso'		=> 'F',
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
			CASE 'DOM':
				return 1;

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
			CASE 'SÃB':
			CASE 'SÁB':
				return 7;

		}
		return 7;
	}

	/* http://rubsphp.blogspot.com.br/2012/08/convertendo-iso88591-para-utf8-de-forma-segura.html */
	public static function sanitizar_utf8($texto) {
		$saida = '';

		$i = 0;
		$len = strlen($texto);
		while ($i < $len) {
			$char = $texto[$i++];
			$ord  = ord($char);

			// Primeiro byte 0xxxxxxx: simbolo ascii possui 1 byte
			if (($ord & 0x80) == 0x00) {

				// Se e' um caractere de controle
				if (($ord >= 0 && $ord <= 31) || $ord == 127) {

					// Incluir se for: tab, retorno de carro ou quebra de linha
					if ($ord == 9 || $ord == 10 || $ord == 13) {
						$saida .= $char;
					}

					// Simbolo ASCII
				} else {
					$saida .= $char;
				}

				// Primeiro byte 110xxxxx ou 1110xxxx ou 11110xxx: simbolo possui 2, 3 ou 4 bytes
			} else {

				// Determinar quantidade de bytes analisando os bits da esquerda para direita
				$bytes = 0;
				for ($b = 7; $b >= 0; $b--) {
					$bit = $ord & (1 << $b);
					if ($bit) {
						$bytes += 1;
					} else {
						break;
					}
				}

				switch ($bytes) {
					case 2: // 110xxxxx 10xxxxxx
					case 3: // 1110xxxx 10xxxxxx 10xxxxxx
					case 4: // 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
						$valido = true;
						$saida_padrao = $char;
						$i_inicial = $i;
						for ($b = 1; $b < $bytes; $b++) {
							if (!isset($texto[$i])) {
								$valido = false;
								break;
							}
							$char_extra = $texto[$i++];
							$ord_extra  = ord($char_extra);

							if (($ord_extra & 0xC0) == 0x80) {
								$saida_padrao .= $char_extra;
							} else {
								$valido = false;
								break;
							}
						}
						if ($valido) {
							$saida .= $saida_padrao;
						} else {
							$saida .= ($ord < 0x7F || $ord > 0x9F) ? utf8_encode($char) : '';
							$i = $i_inicial;
						}
						break;
					case 1:  // 10xxxxxx: ISO-8859-1
					default: // 11111xxx: ISO-8859-1
						$saida .= ($ord < 0x7F || $ord > 0x9F) ? utf8_encode($char) : '';
						break;
				}
			}
		}
		return $saida;
	}

	/* TODO: function below is not working */
	public static function stripAccents($str)
	{
		$from = 'ãÃâÂáÁàÀäÄêÊéÉèÈëËîÎíÍìÌïÏõÕôÔóÓòÒöÖûÛúÚùÙüÜçÇ';
		$to   = 'aAaAaAaAaAeEeEeEeEiIiIiIiIoOoOoOoOoOuUuUuUuUcC';

		return strtr($str, $from, $to);
	}
}
