<?php

namespace Test;

chdir(dirname(__DIR__));
require 'autoload.php';

use Invalid\Path;

class Test
{
	public function __construct()
	{
		new Path();
	}
}

new Test;
