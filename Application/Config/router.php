<?php

return array(
	'routes' => array(
		'action' => array(
			'type' => 'redirect',
			'uri' => '/login',
		),

		'subroutes' => array(
			'login' => array(
				'action' => array(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\LoginController',
				),
			),
			'main' => array(
				'action' => array(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\MainController',
				),
			),
			'term' => array(
				'action' => array(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\TermController',
				),
			),
			'api' => array(
				'subroutes' => array(
					'microhorario' => array(
						'action' => array(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\MicroHorarioController',
						),
					),
				),
			),
			'error' => array(
				'action' => array(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\ErrorController',
				),
			),
		),
	),
	'errorRoute' => '/error'
);
