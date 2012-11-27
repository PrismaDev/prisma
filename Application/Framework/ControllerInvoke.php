<?php

namespace Framework;

class ControllerInvoke
{
	public static function init($class)
	{
		$controller = new $class();

		echo $controller->handlePhpRequest();
		
		return true;
	}
}

