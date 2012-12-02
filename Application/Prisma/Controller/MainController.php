<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Prisma\Library\Auth;

Class MainController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');

//		Auth::accessControl('Aluno');
	}

	public function performGet($url, $arguments, $accept) 
	{
		return ViewLoader::load('Prisma', 'general.phtml', array('section' => 'main'));
	}
}

