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
		
		foreach($disciplinas as $disciplina)
		{
			$disciplina['turmas'] = Turma::getByDisciplina($disciplina['CodigoDisciplina']);

			foreach($disciplina['turmas'] as $turma)
			{
				$turma['horarios'] = TurmaHorario::getByTurma($turma['PK_Turma']);
			}
		}

		return $disciplinas;
	}

	public static function getOptativas($login)
	{
		$optativas = Optativa::getByUserDepend($login);

		foreach($optativas as $optativa)
		{
			$optativa['disciplinas'] = Optativa::getDisciplinas($login, $optativa['CodigoOptativa']);
		}

		return $optativas;
	}
}
