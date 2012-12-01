<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Model\MicroHorario;

class MicroHorarioController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');
	}

	public function performGet($url, $arguments, $accept) 
	{
		return 'it works';
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		if(!isset($_FILES['file'])) return 'error';

		if(MicroHorario::save($_FILES['file']['tmp_name']))
		{
			return 'ok';
		}
		else
		{
			return 'error';
		}
	}

}