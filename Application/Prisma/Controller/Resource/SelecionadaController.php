<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Library\Common;
use Prisma\Library\Auth;
use Prisma\Model\Selecionada;
use Prisma\Model\Disciplina;

class SelecionadaController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');

		Auth::accessControl('Aluno');
	}

	public function performGet($url, $arguments, $accept) 
	{
		$login = $_COOKIE['login'];

		$selecionadas = Selecionada::getAll($login);

		$discHash = array();
		foreach($selecionadas as $selecionada)
		{
			$discHash[$selecionada['CodigoDisciplina']] = 1;
		}
		$depend = Disciplina::getByUserDiscSetDepend($login, $discHash);

		$data = Common::namesMinimizer
		(
			json_encode
			(
				array
				(
					'Selecionadas' => $selecionadas,
					'Dependencia' => $depend
				)
			)
		);

		return $data;
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		$login = $_COOKIE['login'];

		$rows = json_decode($arguments['json']);
		$len = count($rows);

		for($i = 0; $i < $len; ++$i)
		{
			if(!Selecionada::persist($login, $rows[$i]))
			{
				return 'error';
			}
		}

		return 'ok';
	}

}
