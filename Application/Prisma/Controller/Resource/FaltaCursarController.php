<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Library\Auth;
use Prisma\Model\FaltaCursar;

class FaltaCursarController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');

		Auth::accessControl('Aluno');
	}

	public function performGet($url, $arguments, $accept) 
	{
		return json_encode(FaltaCursar::getAll($_COOKIE['login']));
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		//TODO
	}

}
