<?php

namespace Prisma\Library;

use Framework\Router;
use Framework\Database;

class Auth
{
	public static function accessControl($type)
	{
		if(isset($_COOKIE['type']) && $_COOKIE['type'] == $type && self::isLogged()) 
		{
			return true;
		}

		self::accessDenied();
		return false;
	}

	public static function isLogged()
	{
		if(!isset($_COOKIE['session'])) return false;

		return self::checkHash($_COOKIE['session']);
	}

	public static function login($login, $passwd, $type)
	{
		if($hash = self::checkAccount($login, $passwd, $type))
		{
			self::setSessionCookies($hash, $type);

			return true;
		}
		return false;
	}

	protected static function setSessionCookies($hash, $type)
	{
			$expire = time()+(60*60*24*3); //expires within 3 days

			setcookie('session', $hash, $expire);
			setcookie('type', $type, $expire);
	}

	protected static function checkAccount($login, $passwd, $type)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('UPDATE "Usuario" SET "HashSessao" = ?, "UltimoAcesso" = now() WHERE "PK_Login" = ? AND "Senha" = ? AND "FK_TipoUsuario" = (SELECT "PK_TipoUsuario" FROM "TipoUsuario" WHERE "Nome" = ?);');

		$hash = self::makeHash($login, $passwd);

		$sth->execute(array(
			$hash,
			$login,
			$passwd,
			$type,
		));

		if($sth->rowcount() > 0)
		{
			return $hash;
		}

		return false;
	}

	protected static function makeHash($login, $passwd)
	{
		return sha1( time() . ':' . $login . ':' . $passwd );
	}

	protected static function checkHash($hash)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT 1 FROM "Usuario" WHERE "HashSessao"=?;');
		$sth->execute(array($hash));
	
		return $sth->fetch() != false;
	}

	protected static function accessDenied()
	{
		self::logout();

		Router::redirectRoute('/login?accessDenied');
	}

	public static function logout()
	{
		setcookie('session', '', time()-3600);
		setcookie('type', '', time()-3600);
	}

	/*
	public function savePageLog()
	{
		$sql = 'INSERT INTO \'LogPagina\'(\'FK_CodUsuario\', \'CaminhoPagina\')
			VALUES ('.$_SESSION['auth']['Codigo'].', ''.$_SERVER['SCRIPT_NAME'].'');';
			
		@pg_query($sql);
	}
	*/
}

