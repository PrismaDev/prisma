<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Prisma\Library\Auth;
use Prisma\Model\FaltaCursar;
use Prisma\Model\Selecionada;

Class MainController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');

//		Auth::accessControl('Aluno');
	}

	public function performGet($url, $arguments, $accept) 
	{
		$data = array(
			'faltacursar' => FaltaCursar::getAll($_COOKIE['login']),
			'selecionadas' => Selecionada::getAll($_COOKIE['login'])
		);

		return ViewLoader::load('Prisma', 'general.phtml', array('section' => 'main', 'data' => $data));
	}
}

