<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Framework\Router;
use Prisma\Library\Auth;
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
		return ViewLoader::load('Prisma', 'general.phtml', array('section' => 'term'));
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		Usuario::acceptTerm($_COOKIE['login'], $arguments['acceptedTerm']);

		Router::redirectRoute('/main');
	}
}

