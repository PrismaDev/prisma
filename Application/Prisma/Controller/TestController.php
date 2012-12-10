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

Class TestController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');
	}

	public function performGet($url, $arguments, $accept) 
	{
		$time = time();

		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "AlunoDisciplinaApto" FROM "PopulaAlunoDisciplinaAptoCache" limit :limit offset :offset;');
		$sth->execute($arguments);

		echo time()-$time,'<br>';

		return $sth->fetch() != false ? 'ok' : 'error';
	}
}

