<?php

namespace Framework;

use Framework\ControllerInvoke;

class Router
{
	public static function init($config, $uri)
	{
		$uri_array = explode('/', $uri);

		$route = $config['routes'];
		$uri_len = count($uri_array);
		for( $i = 0 ; $i < $uri_len ; $i++ )
		{
			if(empty($uri_array[$i])) continue;

		 	if(!isset( $route[ $uri_array[$i] ] ))
			{
				header('Location: '.$config['error_route']);
			}

			$route = $route[ $uri_array[ $i ] ];
		}

		if(!isset($route['root']) || empty($route['root']))
		{
			header('Location: '.$config['error_route']);
		}

		ControllerInvoke::init($route['root']);
	}
}

