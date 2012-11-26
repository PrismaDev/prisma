<?php

return array(
	'routes' => array(
		'root' => 'Prisma\Controller\LoginController',
		'login' => array(
			'root' => 'Prisma\Controller\LoginController'
		),
		'main' => array(
			'root' => 'Prisma\Controller\MainController'
		),
		'term' => array(
			'root' => 'Prisma\Controller\TermController'
		),
		'error' => array(
			'root' => 'Prisma\Controller\ErrorController'
		),
		'api' => array(
		)
	),
	'error_route' => 'error'
);
