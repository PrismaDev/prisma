<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\Router;
use Prisma\Library\Auth;

Class LogoutController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');
	}

	public function performGet($url, $arguments, $accept) 
	{
		session_start();
		Auth::logout();
		Router::redirectRoute('/');
	}
}

