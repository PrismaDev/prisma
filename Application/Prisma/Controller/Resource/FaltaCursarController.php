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

		$disciplinasLen = count($disciplinas);
		$optativasLen = count($optativas);

		$discUsed = array(); 
		$depend = array();
		for($i = 0; $i < $disciplinasLen; ++$i)
		{
			$codigoDisciplina = $disciplinas[$i]['CodigoDisciplina'];

			if(isset($discUSed[$codigoDisciplina])) 
				continue;
			$discUSed[$codigoDisciplina] = true;

			$depend[] = Disciplina::getByUserIdDepend($login, $codigoDisciplina);
		}
		for($i = 0; $i < $optativasLen; ++$i)
		{
			$optDiscLen = count($optativas[$i]['disciplinas']);

			for($j = 0; $j < $optDiscLen; ++$j)
			{
				$codigoDisciplina = $optativas[$i]['disciplinas'][$j]['CodigoDisciplina'];

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
			'disciplinas' => $depend
		);

		return json_encode($data);
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		//TODO
	}

}
