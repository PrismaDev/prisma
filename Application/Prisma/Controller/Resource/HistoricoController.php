<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Model\Usuario;
use Prisma\Library\Auth;

class HistoricoController extends RestController
{
	public function __construct()
	{
		parent::__construct('POST');
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		Auth::accessControl('Administrador');

		if(!isset($_FILES['file'])) return 'error';

		set_time_limit ( 3600 );

		if(Usuario::saveHistoricoFromFile($_FILES['file']['tmp_name']))
		{
			return 'ok';
		}
		else
		{
			return 'error';
		}
	}
}
