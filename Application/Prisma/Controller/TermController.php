<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Prisma\Library\Auth;

Class TermController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');

		Auth::accessControl('Aluno');
	}

	public function performGet($url, $arguments, $accept) 
	{
		//TODO

		return ViewLoader::load('Prisma', 'term.phtml', array());
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		return 'POST';

		//TODO
	}
}

