<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Model\AvisoDesabilitado;
use Library\Auth;

class AvisoController extends RestController
{
	public function __construct()
	{
		parent::__construct('POST');

		Auth::accessControl('Aluno');
	}

	public function performPost($url, $arguments, $accept) 
	{
		$login = Auth::getSessionLogin();

		$rows = json_decode(str_replace('\\"','"',$arguments['json']));
		$len = count($rows);

		for($i = 0; $i < $len; ++$i)
		{
			if(!AvisoDesabilitado::del($login, $rows[$i]))
			{
				return 'error';
			}
		}

		return 'ok';
	}

	public function performDelete($url, $arguments, $accept) 
	{
		$login = Auth::getSessionLogin();

		$rows = json_decode(str_replace('\\"','"',$arguments['json']));
		$len = count($rows);

		for($i = 0; $i < $len; ++$i)
		{
			if(!AvisoDesabilitado::add($login, $rows[$i]))
			{
				return 'error';
			}
		}

		return 'ok';
	}

}
