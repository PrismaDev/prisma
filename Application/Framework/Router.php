<?php

namespace Framework;

use Framework\ControllerInvoke;

class Router
{
	public static function init($config, $uri)
	{
		$uri = self::removeGetParam($uri);

		$route = self::getRoute($config['routes'], $uri);

		if($route == null || !self::handleRoute($route))
		{
			self::redirectRoute($config['errorRoute']);
		}
	}

	private static function removeGetParam($uri)
	{
		$array = explode('?', $uri);
		return $array[0];
	}

	private static function getRoute($route, $uri)
	{
		$uriArray = explode('/', $uri);
		$uriArrayLen = count($uriArray);

		for( $i = 0 ; $i < $uriArrayLen ; $i++ )
		{
			if(empty($uriArray[$i])) continue;

		 	if(!isset( $route['subroutes'][ $uriArray[$i] ] ))
			{
				return null;
			}

			$route = $route['subroutes'][ $uriArray[ $i ] ];
		}

		return $route;
	}

	private static function handleRoute($route)
	{
		if(!isset($route['action']))
		{
			return false;
		}

		switch($route['action']['type'])
		{
			case 'redirect':
				return self::redirectRoute($route['action']['uri']);

			case 'controller':
				return ControllerInvoke::init($route['action']['controller']);
		}

		return false;
	}

	public static function redirectRoute($routeUri)
	{
		header('Location: '.$routeUri);

		return true;
	}
}

