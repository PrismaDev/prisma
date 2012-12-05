<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Prisma\Library\Auth;
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
		foreach($selecionadas as $selecionada)
		{
			$codigoDisciplina = $selecionada['CodigoDisciplina'];

			if(isset($discUsed[$codigoDisciplina])) 
				continue;
			$discUSed[$codigoDisciplina] = true;

			$depend[] = Disciplina::getByUserIdDepend($login, $codigoDisciplina);
		}

		$data = array(
			'faltacursar' => array(
				'disciplinas' => $disciplinas,	
				'optativas' => $optativas,
			),
			'selecionadas' => $selecionadas,
			'dependencia' => $depend
		);

		return ViewLoader::load('Prisma', 'general.phtml', array('section' => 'main', 'data'=> $data));
	}
}

