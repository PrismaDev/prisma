<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Library\Common;
use Prisma\Library\Auth;
use Prisma\Model\Disciplina;
use Prisma\Model\Optativa;

class FaltaCursarController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');
	}

	public function performGet($url, $arguments, $accept) 
	{
		Auth::accessControl('Aluno');

		$login = $_COOKIE['login'];

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
	
	public function performPost($url, $arguments, $accept) 
	{
		Auth::accessControl('Administrador');

		//TODO
	}

}
