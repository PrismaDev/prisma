<?php

namespace Prisma\Library;

use Framework\Router;
use Framework\Database;
use Prisma\Model\Usuario;
use Prisma\Model\LogPrisma;

class Auth
{
	protected static $configPath = '../../Config/auth.php';

	public static function accessControl($type, $termCheck = true)
	{
		if(isset($_COOKIE['type']) && $_COOKIE['type'] == $type && self::isLogged()) 
		{
			if($termCheck && $type == 'Aluno' && !Usuario::wasTermAccepted($_COOKIE['login']))
			{
				self::accessDenied();
				return false;
			}

			self::makeLog();
			return true;
		}

		self::accessDenied();
		return false;
	}

	private static function makeLog()
	{
		$ip = $_SERVER['REMOTE_ADDR'];
		$uri = $_SERVER['REQUEST_URI'];
		$hash = $_COOKIE['session'];
		$user = $_COOKIE['login'];
		$browser = $_SERVER['HTTP_USER_AGENT'];

		LogPrisma::pathLog($ip, $uri, $hash, $user, $browser);
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
			self::setSessionCookies($hash, $login, $type);

			return true;
		}
		return false;
	}

	protected static function setSessionCookies($hash, $login, $type)
	{
		$config = include(__DIR__.'/'.self::$configPath);

		$expire 	= time()+$config['expire']; //expires within 3 days
		$path 		= '/';
		$serverName 	= '';//$_SERVER['SERVER_NAME'];
		$secure 	= $config['secure'];

		setcookie('session', $hash, $expire, $path, $serverName, $secure);
		setcookie('login', $login, $expire, $path, $serverName, $secure);
		setcookie('type', $type, $expire, $path, $serverName, $secure);
	}

	protected static function checkAccount($login, $passwd, $type)
	{
		$config = include(__DIR__.'/'.self::$configPath);

		$dbh = Database::getConnection();
		$hash = self::makeHash($login, $passwd);

		$sth = null;
		if($config['usePucOnline'] && $type == 'Aluno')
		{
			if(!self::checkPucOnline($login, $passwd))
			{
				return false;
			}

			$sth = $dbh->prepare('UPDATE "Usuario" SET "HashSessao" = ?, "UltimoAcesso" = now() 
						WHERE "PK_Login" = ? AND 
						"FK_TipoUsuario" = 
						(
							SELECT "PK_TipoUsuario" FROM "TipoUsuario" WHERE "Nome" = ?
						);');

			$sth->execute(array(
				$hash,
				$login,
				$type,
			));
		}
		else
		{
			$sth = $dbh->prepare('UPDATE "Usuario" SET "HashSessao" = ?, "UltimoAcesso" = now() 
						WHERE "PK_Login" = ? AND 
						"FK_TipoUsuario" = 
						(
							SELECT "PK_TipoUsuario" FROM "TipoUsuario" WHERE "Nome" = ?
						);');

			$sth->execute(array(
				$hash,
				$login,
//				sha1($passwd),
				$type,
			));		
		}

		if($sth && $sth->rowcount() > 0)
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
		$config = include(__DIR__.'/'.self::$configPath);

		$dbh = Database::getConnection();
		$sth = $dbh->prepare('SELECT 1 FROM "Usuario" WHERE "HashSessao"=? AND (now() <= "UltimoAcesso" + interval \''.$config['expire'].' second\');');
		$sth->execute(array($hash));
	
		return $sth->fetch() != false;
	}

	protected static function checkPucOnline($login, $passwd)
	{
		$config = include(__DIR__.'/'.self::$configPath);

		$url = $config['PucOnlineAccess']['URL'];

		//set POST variables
		$fields = array
		(
			'Login' => $config['PucOnlineAccess']['Login'],
			'Senha' => $config['PucOnlineAccess']['Senha'],
			'loginAluno' => $login,
			'senhaAluno' => $passwd
		);

		//url-ify the data for the POST
		$fields_string = '';
		foreach($fields as $key=>$value) { $fields_string .= $key.'='.$value.'&'; }
		rtrim($fields_string, '&');

		//open connection
		$ch = curl_init();

		//set the url, number of POST vars, POST data
		curl_setopt($ch,CURLOPT_URL, $url);
		curl_setopt($ch,CURLOPT_POST, count($fields));
		curl_setopt($ch,CURLOPT_POSTFIELDS, $fields_string);
		curl_setopt($ch,CURLOPT_SSL_VERIFYPEER, false);

		ob_start();

		//execute post
		$result = curl_exec($ch);

		$xml = false;
		if($result)
		{
			$xml = simplexml_load_string(ob_get_contents());
		}
		ob_end_clean();

		//close connection
		curl_close($ch);

		return $xml && $xml->resultado == 1;
	}

	public static function accessDenied()
	{
		self::logout();

		Router::redirectRoute('/login?accessDenied');
	}

	public static function logout()
	{
		$config = include(__DIR__.'/'.self::$configPath);

		$path 		= '/';
		$serverName 	= '';//$_SERVER['SERVER_NAME'];
		$secure 	= $config['secure'];

		setcookie('session', '', time()-3600, $path, $serverName, $secure);
		setcookie('login', '', time()-3600, $path, $serverName, $secure);
		setcookie('type', '', time()-3600, $path, $serverName, $secure);
	}
}

