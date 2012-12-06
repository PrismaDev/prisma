<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Prisma\Library\Auth;
use Prisma\Library\Common;
use Prisma\Model\Disciplina;
use Prisma\Model\Optativa;
use Prisma\Model\Selecionada;

Class MainController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');

		Auth::accessControl('Aluno');
	}

	public function performGet($url, $arguments, $accept) 
	{
		$login = $_COOKIE['login'];

		$disciplinas = Disciplina::getFaltaCursar($login);
		$optativas = Optativa::getByUserDepend($login);
		$selecionadas = Selecionada::getAll($login);

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
		foreach($selecionadas as $selecionada)
		{
			$discHash[$selecionada['CodigoDisciplina']] = 1;
		}
		$depend = Disciplina::getByUserDiscSetDepend($login, $discHash);

		$data = //Common::namesMinimizer
		(
			json_encode
			(
				array
				(
					'FaltaCursar' => array
					(
						'Disciplinas' => $disciplinas,	
						'Optativas' => $optativas,
					),
					'Selecionadas' => $selecionadas,
					'Dependencia' => $depend
				)
			)
		);

		return ViewLoader::load('Prisma', 'general.phtml', array('section' => 'main', 'DATA_VIEW' => $data));
	}
}

