<?php

return array(
	'routes' => array(
		'redirect' => '/login',
		'login' => array(
			'controller' => 'Prisma\Controller\LoginController'
			),
		'main' => array(
			'controller' => 'Prisma\Controller\MainController',
		),
		'term' => array(
			'controller' => 'Prisma\Controller\TermController'
		),
		'error' => array(
			'controller' => 'Prisma\Controller\ErrorController',
		),
		'api' => array(
		)
	),
	'error_route' => '/error'
);
