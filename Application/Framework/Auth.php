<?php

namespace Framework

class Auth
{
	public static function verify($login, $passwd)
	{
		// TODO: implement database query for that 
		$login_bd = 'prisma';
		$passwd_bd = sha1('ptest');

		return $login == $login_bd && $passwd == $passwd_bd;
	}

	public static function isLogged()
	{
		if(!isset($_SESSION['auth'])) return false;

		$login = $_SESSION['auth']['login'];
		$passwd = $_SESSION['auth']['passwd'];

		return verify($login, $passwd);
	}

	public static function login($login, $passwd)
	{
		if(verify($login, $passwd))
		{
			$_SESSION = array();
			$_SESSION['auth'] = array();
			$_SESSION['auth']['login'] = $login;
			$_SESSION['auth']['passwd'] = $passwd;

			return true;
		}
		return false;
	}

	public static function logout()
	{
		session_unset();
		session_destroy();
		unset($_SESSION);
		$_SESSION = array();
	}

	/* -->> shall be handled by apache
	public static function httpsCheck()
	{
		if ($_SERVER['HTTPS'] != 'on') { 
		    $url = 'https://'. $_SERVER['SERVER_NAME'] . '/papelmanteiga/src'; 
		    header('Location: $url'); 
		    exit; 
		}  
	}
	*/

	/*
	public static function savePageLog()
	{
		$sql = "INSERT INTO \"LogPagina\"(\"FK_CodUsuario\", \"CaminhoPagina\")
			VALUES (".$_SESSION['auth']['Codigo'].", '".$_SERVER['SCRIPT_NAME']."');";
			
		@pg_query($sql);
	}
	*/
}
