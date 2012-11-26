<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;

Class LoginController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');
	}

	public function performGet($url, $arguments, $accept) 
	{
		return ViewLoader::load('Prisma', 'general.phtml', array('section' => 'login'));
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		return 'POST';

		//TODO
	}
}

