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
		Selecionada::persist(array(
			'FK_Aluno' => 'aluno',
			'FK_Turma' => 3,
			'Opcao' => 4,
			'NoLinha' => 5
		));
		return json_encode(Selecionada::get('aluno'));
	}
}

