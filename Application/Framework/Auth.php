<?php

namespace Framework;

use Framework\Router;

abstract class Auth
{
	private $uriToRedirect;

	public function __construct($uriToRedirect)
	{
		$this->uriToRedirect = $uriToRedirect;
	}

	abstract protected function checkAccount($login, $password);

	abstract protected function checkSessionHash($login, $sessionHash);

	public function isLogged($permission)
	{
		if(!isset($_COOKIE['hash'])) return false;
		if(!isset($_COOKIE['login'])) return false;
		if(!isset($_COOKIE['type'])) return false;

		$hashSession 	= $_COOKIE['sessionHash'];
		$login 		= $_COOKIE['login'];

		return $this->checkSessionHash($login, $hashSession);
	}

	public function login($login, $passwd)
	{
		list($success, $hash, $type) = $this->checkAccount($login, $passwd);

		if($success)
		{
			$expire = time()+(60*60*24*3); //expires within 3 days

			setcookie('hash', $hash, $expire);
			setcookie('login', $login, $expire);
			setcookie('type', $type, $expire);

			return true;
		}
		return false;
	}

	public function logout()
	{
		setcookie('hash', '', time()-3600);
		setcookie('login', '', time()-3600);
		setcookie('type', '', time()-3600);

		Router::redirectRoute('/');
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

