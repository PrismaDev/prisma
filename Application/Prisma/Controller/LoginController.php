<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Framework\Router;
use Prisma\Library\Auth;
use Prisma\Model\Usuario;

Class LoginController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');

		Auth::logout();
	}

	public function performGet($url, $arguments, $accept) 
	{
		return ViewLoader::load('Prisma', 'general.phtml', array('section' => 'login'));
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		$login 	= $arguments['matricula'];
		$passwd = sha1($arguments['senha']);
		$type 	= $arguments['tipo'];

		if(Auth::login($login, $passwd, $type))
		{
			switch($type)
			{
				case 'Administrador':
					Router::redirectRoute('/admin'); //TODO: verificar se esta correto
					return;

				case 'Coordenador':
					Router::redirectRoute('/stats'); //TODO: verificar se esta correto
					return;

				case 'Aluno':
					if(Usuario::wasTermAccepted($login))
					{
						Router::redirectRoute('/main'); //TODO: pode encaminhar direto pra main
					}
					else
					{
						Router::redirectRoute('/term'); //TODO: pode encaminhar direto pra main
					}
					return;
			}
		}

		Router::redirectRoute('/login?invalidLogin');
	}
}

