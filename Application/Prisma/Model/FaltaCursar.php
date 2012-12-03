<?php

namespace Prisma\Model;

use Framework\Database;
use Prisma\Model\Disciplina;
use Prisma\Model\Optativa;
use Prisma\Model\Turma;
use Prisma\Model\TurmaHorario;

class FaltaCursar
{
	public static function getAll($login)
	{
		$data = array();

		$data['Disciplinas'] = self::getDisciplinas($login);
		$data['Optativas'] = self::getOptativas($login);

		return $data;
	}

	public static function getDisciplinas($login)
	{
		$disciplinas = Disciplina::getByUserDepend($login);
		$disciplinasSize = count($disciplinas);
		
		for($i = 0; $i < $disciplinasSize; ++$i)
		{
			$disciplinas[$i]['turmas'] = Turma::getByDisciplina($disciplina[$i]['CodigoDisciplina']);
			$disciplinaSize = count($disciplinas[$i]);

			for($j = 0; $j < $disciplinaSize; ++$j)
			{
				$discipinas[$i][$j]['horarios'] = TurmaHorario::getByTurma($discipinas[$i][$j]['PK_Turma']);
			}
		}

		return $disciplinas;
	}

	public static function getOptativas($login)
	{
		$optativas = Optativa::getByUserDepend($login);
		$optativasSize = count($optativas);

		for($i = 0; $i < $optativasSize; ++$i)
		{
			$optativas[$i]['disciplinas'] = Optativa::getDisciplinas($login, $optativas[$i]['CodigoOptativa']);
		}

		return $optativas;
	}
}
