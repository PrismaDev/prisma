<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Library\Auth;
use Library\Common;
use Prisma\Model\MicroHorario;
use Prisma\Model\Disciplina;

class MicroHorarioController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');
	}

	public function performGet($url, $arguments, $accept) 
	{
		Auth::accessControl('Aluno');
		$login = Auth::getSessionLogin();

		$microhorario = MicroHorario::getByFilter($login, $arguments);

		$discHash = array();
		foreach($microhorario as $tuple)
		{
			$discHash[$tuple['CodigoDisciplina']] = 1;
		}

		$depend = Disciplina::getByUserDiscSetDepend($login, $discHash);

		$data = Common::namesMinimizer
		(
			json_encode
			(
				array
				(
					'MicroHorario' => $microhorario,
					'Dependencia' => $depend
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
