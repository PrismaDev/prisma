<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Library\Common;
use Library\Auth;
use Prisma\Model\Disciplina;
use Prisma\Model\Optativa;
use Prisma\Model\Usuario;

class FaltaCursarController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');
	}

/*
	public function performGet($url, $arguments, $accept) 
	{
		Auth::accessControl('Aluno');

		$login = Auth::getSessionLogin();

		$disciplinas = Disciplina::getFaltaCursar($login);
		$optativas = Optativa::getByUserDepend($login);

		$discHash = array();
		foreach($disciplinas as $disciplina)
		{
			$discHash[$disciplina['CodigoDisciplina']] = 1;
		}
		foreach($optativas as $optativa)
		{
			foreach($optativa['Disciplinas'] as $disciplina)
			{
				$discHash[$disciplina['CodigoDisciplina']] = 1;
			}
		}
		$depend = Disciplina::getByUserDiscSetDepend($login, $discHash);

		$data = Common::namesMinimizer
		(
			json_encode
			(
				array
				(
					'FaltaCursar' => array(
						'Disciplinas' => $disciplinas,
						'Optativas' => $optativas,
					),
					'Dependencia' => $depend
				)
			)
		);

		return $data;
	}
*/

	public function performPost($url, $arguments, $accept) 
	{
		Auth::accessControl('Administrador');

		if(!isset($_FILES['file'])) return 'error';

		set_time_limit(3600);
		if(Usuario::saveHistoricoFromFile($_FILES['file']['tmp_name']))
		{
			return 'ok';
		}
		else
		{
			return 'error';
		}
	}
}
