<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Model\MicroHorario;
use Prisma\Model\Disciplina;
use Prisma\Library\Auth;

class MicroHorarioController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');

//		Auth::accessControl('Administrador');
	}

	public function performGet($url, $arguments, $accept) 
	{
		$microhorario = MicroHorario::getByFilter($arguments);

		$disciplinas = array();
		$discUsed = array();
		foreach($microhorario as $row)
		{
			if(isset($discUsed[$row['CodigoDisciplina']])) continue;
			$discUsed[$row['CodigoDisciplina']] = true;

			$disciplinas[] = Disciplina::getByUserIdDepend($_COOKIE['login'], $row['CodigoDisciplina']);
		}

		$data = array(
			'microhorario' => $microhorario,
			'disciplinas' => $disciplinas
		);

		return json_encode($data);
	}
	
	public function performPost($url, $arguments, $accept) 
	{
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
