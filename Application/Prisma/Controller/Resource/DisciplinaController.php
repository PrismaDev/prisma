<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Model\Disciplina;
use Library\Auth;

class DisciplinaController extends RestController
{
	public function __construct()
	{
		parent::__construct('POST');
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		Auth::accessControl('Administrador');

		if(!isset($_FILES['file'])) return 'error';

		if(Disciplina::saveFromFile($_FILES['file']['tmp_name']))
		{
			return 'ok';
		}
		else
		{
			return 'error';
		}
	}
}
