<?php

namespace Framework;

use Framework\Router;
use Prisma\Model\LogPrisma;

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
			$uri = $_SERVER['REQUEST_URI'];
			$hash = $_COOKIE['session'];
			$user = $_COOKIE['login'];
			$browser = $_SERVER['HTTP_USER_AGENT'];

			LogPrisma::errorLog($ip, $uri, $hash, $user, $browser, $e->getMessage());

			Router::redirectRoute('/error');
			return false;
		}
		
		return true;
	}
}

