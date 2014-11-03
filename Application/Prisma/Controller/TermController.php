<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Framework\Router;
use Library\Auth;
use Prisma\Model\Usuario;

Class TermController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');

		Auth::accessControl('Aluno', false);
	}

	public function performGet($url, $arguments, $accept) 
	{
		$data = json_encode(Usuario::getAlunoById(Auth::getSessionLogin()));
		return ViewLoader::load('Prisma', 'general.phtml', array('section' => 'term', 'DATA_VIEW' => $data));
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		Usuario::acceptTerm(Auth::getSessionLogin(), $arguments['acceptedTerm']);

		Router::redirectRoute('/main');
	}
}

