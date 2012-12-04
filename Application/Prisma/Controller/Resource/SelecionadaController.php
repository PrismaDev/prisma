<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Library\Auth;
use Prisma\Model\Selecionada;

class SelecionadaController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');

//		Auth::accessControl('Aluno');
	}

	public function performGet($url, $arguments, $accept) 
	{
		return json_encode(Selecionada::getAll($_COOKIE['login']));
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		$rows = json_decode($arguments['json']);
		$len = count($rows);

		for($i = 0; $i < $len; ++$i)
		{
			if(!Selecionada::persist($rows[$i]))
			{
				return 'error';
			}
		}

		return 'ok';
	}

}
