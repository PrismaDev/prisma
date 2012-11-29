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

		self::$dbh = new \PDO($dsn);
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

