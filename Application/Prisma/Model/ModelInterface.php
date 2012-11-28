<?php

namespace Prisma\Model;

interface ModelInterface
{
	public function load($obj);

	public function toArray();
}
