<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Library\Common;
use Prisma\Model\MicroHorario;
use Prisma\Model\Disciplina;
use Prisma\Library\Auth;

class MicroHorarioController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');
	}

	public function performGet($url, $arguments, $accept) 
	{
		Auth::accessControl('Aluno');

		$microhorario = MicroHorario::getByFilter($arguments);

		$disciplinas = array();
		$discUsed = array();
		foreach($microhorario as $row)
		{
			if(isset($discUsed[$row['CodigoDisciplina']])) continue;
			$discUsed[$row['CodigoDisciplina']] = true;

			$disciplinas[] = Disciplina::getByUserIdDepend($_COOKIE['login'], $row['CodigoDisciplina']);
		}

		$data = //Common::namesMinimizer
		(
			json_encode
			(
				array
				(
					'MicroHorario' => $microhorario,
					'Dependencia' => $disciplinas
				)
			)
		);

		return $data;
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		Auth::accessControl('Administrador');

		if(!isset($_FILES['file'])) return 'error';

		if(MicroHorario::saveFromFile($_FILES['file']['tmp_name']))
		{
			return 'ok';
		}
		else
		{
			return 'error';
		}
	}

}
