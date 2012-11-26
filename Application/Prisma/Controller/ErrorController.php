<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;

Class ErrorController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');
	}

	public function performGet($url, $arguments, $accept) 
	{
		return ViewLoader::load('Prisma', 'error.phtml', null);
	}
}

