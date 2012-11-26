<?php

namespace Framework;

use Framework\Router;
use Doctrine\Bootstrap as Doctrine;

Class Main
{
	public static function init()
	{
		Doctrine::createConnection(include 'Config/db.php', array());

		Router::init(include 'Config/router.php', $_SERVER['REQUEST_URI']);

		Doctrine::closeConnection();
	}
}

