<?php

namespace Prisma\Controller;

use Framework\RestController;
use Framework\ViewLoader;

Class TermController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');
	}

	public function performGet($url, $arguments, $accept) 
	{
		//TODO

		return "Not implemented yet...";
	}
	
	public function performPost($url, $arguments, $accept) 
	{
		return 'POST';

		//TODO
	}
}

