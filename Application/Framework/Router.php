<?php

namespace Framework;

use Framework\ControllerInvoke;

class Router
{
	public static function init($config, $uri)
	{
		$route = self::getRoute($config["routes"], $uri);

		if($route == null || !self::handleRoute($route))
		{
			self::redirectRoute($route["error_route"]);
		}
	}

	private static function getRoute($route, $uri)
	{
		$uri_array = explode('/', $uri);
		$uri_len = count($uri_array);

		for( $i = 0 ; $i < $uri_len ; $i++ )
		{
			if(empty($uri_array[$i])) continue;

		 	if(!isset( $route[ $uri_array[$i] ] ))
			{
				return null;
			}

			$route = $route[ $uri_array[ $i ] ];
		}

		return $route;
	}

	private static function handleRoute($route)
	{
		if(isset($route["redirect"]) && !empty($route["redirect"]))
		{
			self::redirectRoute($route["redirect"]);

			return true;
		}

		if(isset($route["controller"]) && !empty($route["controller"]))
		{
			ControllerInvoke::init($route['controller']);

			return true;
		}
		
		return false;
	}

	public static function redirectRoute($route_uri)
	{
		header('Location: '.$route_uri);
	}
}

