<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Library\Auth;
use Library\Common;
use Prisma\Model\Disciplina;
use Prisma\Model\Optativa;
use Prisma\Model\Selecionada;
use Prisma\Model\Usuario;
use Prisma\Model\AvisoDesabilitado;

Class MainController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');

		Auth::accessControl('Aluno');
	}

	public function performGet($url, $arguments, $accept) 
	{
		$login = Auth::getSessionLogin();

		$aluno = Usuario::getAlunoById($login);
		$disciplinas = Disciplina::getFaltaCursar($login);
		$optativas = Optativa::getByUserDepend($login);
		$selecionadas = Selecionada::getAll($login);
		$avisos = AvisoDesabilitado::getAllByUser($login);
		$dicionario = Common::getNamesDictionary();

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

		$data = Common::namesMinimizer
		(
			json_encode
			(
				array
				(
					'Usuario' => $aluno,
					'FaltaCursar' => array
					(
						'Disciplinas' => $disciplinas,	
						'Optativas' => $optativas,
					),
					'Selecionadas' => $selecionadas,
					'Dependencia' => $depend,
					'Avisos' => $avisos,
				)
			)
		);
		$data = '{"Dicionario":'.str_replace('\"', '', json_encode($dicionario)).',"Data":'.$data.'}';

		return ViewLoader::load('Prisma', 'general.phtml', array('section' => 'main', 'DATA_VIEW' => $data));
	}
}

