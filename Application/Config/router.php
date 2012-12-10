<?php

return array(
	'routes' => array
	(
		'action' => array
		(
			'type' => 'redirect',
			'uri' => '/login',
		),

		'subroutes' => array
		(
			'login' => array
			(
				'action' => array
				(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\LoginController',
				),
			),
			'logout' => array
			(
				'action' => array
				(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\LogoutController',
				),
			),
			'main' => array
			(
				'action' => array
				(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\MainController',
				),
			),
			'term' => array
			(
				'action' => array
				(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\TermController',
				),
			),
			'test' => array
			(
				'action' => array
				(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\TestController',
				),
			),
			'api' => array
			(
				'subroutes' => array
				(
					'microhorario' => array
					(
						'action' => array
						(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\MicroHorarioController',
						),
					),
					'selecionada' => array
					(
						'action' => array
						(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\SelecionadaController',
						),
					),
					'faltacursar' => array
					(
						'action' => array
						(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\FaltaCursarController',
						),
					),
					'curso' => array
					(
						'action' => array
						(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\CursoController',
						),
					),
					'usuario' => array
					(
						'action' => array
						(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\UsuarioController',
						),
					),
					'prerequisito' => array
					(
						'action' => array
						(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\PreRequisitoController',
						),
					),
					'optativa' => array
					(
						'action' => array
						(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\OptativaController',
						),
					),
					'sugestao' => array
					(
						'action' => array
						(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\SugestaoController',
						),
					),
					'disciplina' => array
					(
						'action' => array
						(
							'type' => 'controller',
							'controller' => 'Prisma\Controller\Resource\DisciplinaController',
						),
					),

				),
			),
			'error' => array
			(
				'action' => array
				(
					'type' => 'controller',
					'controller' => 'Prisma\Controller\ErrorController',
				),
			),
		),
	),
	'errorRoute' => '/error'
);
