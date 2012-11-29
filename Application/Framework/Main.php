<?php

namespace Framework;

use Framework\Router;

Class Main
{
	public static function init()
	{
		Router::init(include 'Config/router.php', $_SERVER['REQUEST_URI']);
	}
}

