<?php

namespace Doctrine;

use Doctrine\ORM\Tools\Setup;
use Doctrine\ORM\EntityManager;

class Bootstrap
{
	private static $em = null;

	public static function createConnection($dbParams, $modelPath)
	{
		self::closeConnection();

		$config = Setup::createAnnotationMetadataConfiguration($modelPath, true);
		self::$em = EntityManager::create($dbParams, $config);
	}

	public static function getConnection()
	{
		return self::$em;
	}

	public static function closeConnection()
	{
		if(self::$em != null)
		{
			self::$em->getConnection()->close();
		}
	}
}
