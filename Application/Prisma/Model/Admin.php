<?php

namespace Prisma\Model;

use Prisma\Model\ModelInterface;

class Admin extends Usuario implements ModelInterface
{
	/* Attributes */


	/* Getters and Setters */


	/* ModelInterface implementation */

	public function load($obj)
	{
	}

	public function toArray()
	{
		return array();
	}
}

