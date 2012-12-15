<?php

namespace Framework;

use Framework\Router;
use Prisma\Model\LogPrisma;
use Prisma\Library\Auth;

class ControllerInvoke
{
	public static function init($class)
	{
		$controller = new $class();

		try{
			echo $controller->handlePhpRequest();
		}
		catch(\Exception $e)
		{
			$ip = $_SERVER['REMOTE_ADDR'];
			$uri = $_SERVER['REQUEST_METHOD'].':'.$_SERVER['REQUEST_URI'];
			$hash = Auth::getSessionHash();
			$user = Auth::getSessionLogin();
			$browser = $_SERVER['HTTP_USER_AGENT'];

			LogPrisma::errorLog($ip, $uri, $hash, $user, $browser, $e->getMessage());

			Router::redirectRoute('/login?unexpectedError');
			return true;
		}
		
		return true;
	}
}

