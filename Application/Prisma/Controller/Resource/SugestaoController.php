<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Prisma\Model\Sugestao;
use Prisma\Library\Auth;

class SugestaoController extends RestController
{
	public function __construct()
	{
		parent::__construct('POST');
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		Auth::accessControl('Aluno');

		if(!isset($arguments['comentario'])) return 'error';

		if(Sugestao::persist(Auth::getSessionLogin(), $arguments['comentario']))
		{
			return 'ok';
		}
		else
		{
			return 'error';
		}
	}
}
