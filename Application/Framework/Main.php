<?php

namespace Framework;

use Framework\Router;
use Framework\Database;

Class Main
{
	public static function init()
	{
		Database::createConnection(include 'Config/db.php');

		Router::init(include 'Config/router.php', $_SERVER['REQUEST_URI']);

		Database::closeConnection();
	}
}

