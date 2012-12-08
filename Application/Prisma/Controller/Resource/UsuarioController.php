<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Model\Usuario;
use Prisma\Library\Auth;

class UsuarioController extends RestController
{
	public function __construct()
	{
		parent::__construct('POST');
	}
	
	public function performPost($url, $arguments, $accept) 
	{
//		Auth::accessControl('Administrador');

		if(!isset($_FILES['file'])) return 'error';

		if(Usuario::saveAlunoFromFile($_FILES['file']['tmp_name']))
		{
			return 'ok';
		}
		else
		{
			return 'error';
		}
	}
}
