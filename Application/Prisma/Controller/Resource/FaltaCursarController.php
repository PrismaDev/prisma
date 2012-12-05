<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
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

			if(isset($discUSed[$codigoDisciplina])) 
				continue;
			$discUSed[$codigoDisciplina] = true;

			$depend[] = Disciplina::getByUserIdDepend($login, $codigoDisciplina);
		}
		foreach($optativas as $optativa)
		{
			$optDiscLen = count($optativa['disciplinas']);

			foreach($optativa['disciplinas'] as $disciplina)
			{
				$codigoDisciplina = $disciplina['CodigoDisciplina'];

				if(isset($discUSed[$codigoDisciplina])) 
					continue;
				$discUSed[$codigoDisciplina] = true;

				$depend[] = Disciplina::getByUserIdDepend($login, $codigoDisciplina);
			}
		}

		$data = array(
			'faltacursar' => array(
				'disciplinas' => $disciplinas,
				'optativas' => $optativas,
			),
			'dependencia' => $depend
		);

		return json_encode($data);
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		//TODO
	}

}
