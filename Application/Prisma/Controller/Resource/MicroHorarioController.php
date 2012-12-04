<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Model\MicroHorario;
use Prisma\Library\Auth;

class MicroHorarioController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');

//		Auth::accessControl('Administrador');
	}

	public function performGet($url, $arguments, $accept) 
	{
		return json_encode(MicroHorario::get($_COOKIE['login'], $arguments));
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		if(!isset($_FILES['file'])) return 'error';

		if(MicroHorario::saveFromFile($_FILES['file']['tmp_name']))
		{
			return 'ok';
		}
		else
		{
			return 'error';
		}
	}

}
