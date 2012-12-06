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

		Auth::accessControl('Aluno');
	}

	public function performGet($url, $arguments, $accept) 
	{
		$login = $_COOKIE['login'];

		$disciplinas = Disciplina::getFaltaCursar($login);
		$optativas = Optativa::getByUserDepend($login);

		$discUsed = array(); 
		$depend = array();
		foreach($disciplinas as $disciplina)
		{
			$codigoDisciplina = $disciplina['CodigoDisciplina'];

			if(isset($discUsed[$codigoDisciplina])) 
				continue;
			$discUSed[$codigoDisciplina] = true;

			$depend[] = Disciplina::getByUserIdDepend($login, $codigoDisciplina);
		}
		foreach($optativas as $optativa)
		{
			foreach($optativa['Disciplinas'] as $disciplina)
			{
				$codigoDisciplina = $disciplina['CodigoDisciplina'];

				if(isset($discUsed[$codigoDisciplina])) 
					continue;
				$discUSed[$codigoDisciplina] = true;

				$depend[] = Disciplina::getByUserIdDepend($login, $codigoDisciplina);
			}
		}

		$data = //Common::namesMinimizer
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
		//TODO
	}

}
