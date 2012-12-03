<?php

namespace Framework;

class Database
{
	private static $dbh;

	public static function createConnection($config)
	{
		$dsn = substr($config['driver'],4).':';
		$dsn .= 'host='.$config['host'].';';
		$dsn .= 'port='.$config['port'].';';
		$dsn .= 'dbname='.$config['dbname'].';';
		$dsn .= 'user='.$config['user'].';';
		$dsn .= 'password='.$config['password'];

		try{
			self::$dbh = new \PDO($dsn);
		}
		catch(\Exception $e)
		{
			die('Could not connect to database: '.$e->getMessage());
		}
	}

	public static function getConnection()
	{
		return self::$dbh;
	}

	public static function closeConnection()
	{
		self::$dbh = null;
	}
}

