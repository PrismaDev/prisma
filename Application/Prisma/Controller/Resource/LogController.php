<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Model\LogPrisma;
use Prisma\Library\Auth;

class LogController extends RestController
{
	public function __construct()
	{
		parent::__construct('POST');
	}
	
	public function performGet($url, $arguments, $accept) 
	{
		Auth::accessControl('Aluno');

		if(!isset($arguments['error']))
		{
			return false;
		}

		$ip = $_SERVER['REMOTE_ADDR'];
		$uri = $_SERVER['REQUEST_URI'];
		$hash = Auth::getSessionHash();
		$user = Auth::getSessionLogin();
		$browser = $_SERVER['HTTP_USER_AGENT'];

		LogPrisma::errorLog($ip, $uri, $hash, $user, $browser, $arguments['error']);
	}
}
