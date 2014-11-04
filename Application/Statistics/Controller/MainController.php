<?php

namespace Statistics\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Library\Auth;
use Library\Common;

Class MainController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');
	}

	public function performGet($url, $arguments, $accept) 
	{
		return ViewLoader::load('Statistics', 'test.phtml', array());
	}
}

