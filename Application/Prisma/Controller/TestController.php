<?php

namespace Prisma\Controller;

use Framework\RestController;

use Prisma\Model\MicroHorario;
use Prisma\Model\FaltaCursar;
use Prisma\Model\Disciplina;
use Prisma\Model\Optativa;
use Prisma\Model\Selecionada;
use Prisma\Model\Turma;
use Prisma\Model\TurmaHorario;

Class TestController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');
	}

	public function performGet($url, $arguments, $accept) 
	{
		return json_encode(Disciplina::getById('JUR1932'));
	//	return json_encode(Turma::getByDisciplina('INF1007'));
	//	return json_encode(MicroHorario::get('aluno', array('CodigoDisciplina'=>'inf')));
	}
}

