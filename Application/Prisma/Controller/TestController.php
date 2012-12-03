<?php

namespace Prisma\Controller;

use Framework\RestController;

use Prisma\Model\MicroHorario;
use Prisma\Model\Disciplina;
use Prisma\Model\Optativa;
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
		return json_encode(Optativa::getByUserDepend(null));
	}
}

