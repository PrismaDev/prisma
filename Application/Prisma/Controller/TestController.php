<?php

namespace Prisma\Controller;

use Framework\Database;
use Framework\RestController;
use Prisma\Library\Common;
use Prisma\Model\MicroHorario;
use Prisma\Model\FaltaCursar;
use Prisma\Model\Disciplina;
use Prisma\Model\Optativa;
use Prisma\Model\Selecionada;
use Prisma\Model\Turma;
use Prisma\Model\TurmaHorario;
use Prisma\Model\Usuario;
use Prisma\Model\Sugestao;
use Prisma\Model\Unidade;

Class TestController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');
	}

	public function performGet($url, $arguments, $accept) 
	{
		return 'It works!';
	}
}

