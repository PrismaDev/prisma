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
			'logout' => array(
				'action' => array(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\LogoutController',
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
			'test' => array(
				'action' => array(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\TestController',
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
					'selecionada' => array(
						'action' => array(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\SelecionadaController',
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
