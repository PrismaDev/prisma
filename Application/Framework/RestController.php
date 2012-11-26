<?php

/* http://blog.garethj.com/2009/02/17/building-a-restful-web-application-with-php/ */

/*
	Return codes:

	200 OK: successful request when data is returned
	201 Created: Successful request when something is created at another URL (specified by the value returned in the Location header)
	204 No Content: Successful request when no data is returned
	400 Bad Request: Incorrect parameters specified on request
	404 Not Found: No resource at the specified URL
	405 Method Not Allowed: when a client makes a request using an HTTP verb not supported at the requested URL (supported verbs are returned in the Allow header)
	406 Not Acceptable: Requested data format not supported
	500 Internal Server Error: An unexpected error occurred
	501 Not Implemented: when a client makes a request using an unknown HTTP verb
*/

namespace Framework;

class RestController {

	private $supportedMethods;

	public function __construct($supportedMethods) 
	{
		$this->supportedMethods = $supportedMethods;
	}

	public function handlePhpRequest()
	{
		return $this->handleRawRequest($_SERVER, $_GET, $_POST); 
	}

	public function handleRawRequest($_SERVER, $_GET, $_POST) 
	{
		$url = $this->getFullUrl($_SERVER);

		$method = $_SERVER['REQUEST_METHOD'];
		switch ($method) 
		{
			case 'GET':
			case 'HEAD':
				$arguments = $_GET;
				break;

			case 'POST':
				$arguments = $_POST;
				break;

			case 'PUT':
			case 'DELETE':
				parse_str(file_get_contents('php://input'), $arguments);
				break;
		}

		$accept = $_SERVER['HTTP_ACCEPT'];
		return $this->handleRequest($url, $method, $arguments, $accept);
	}

	protected function getFullUrl($_SERVER) 
	{
		$protocol = empty($_SERVER['HTTPS']) ? 'http' : 'https';
		$location = $_SERVER['REQUEST_URI'];

		if ($_SERVER['QUERY_STRING']) {
			$location = substr($location, 0, strrpos($location, $_SERVER['QUERY_STRING']) - 1);
		}

		return $protocol.'://'.$_SERVER['HTTP_HOST'].$location;
	}

	public function handleRequest($url, $method, $arguments, $accept) 
	{
		switch($method) 
		{
			case 'GET':
				return $this->performGet($url, $arguments, $accept);

			case 'HEAD':
				return $this->performHead($url, $arguments, $accept);

			case 'POST':
				return $this->performPost($url, $arguments, $accept);

			case 'PUT':
				return $this->performPut($url, $arguments, $accept);

			case 'DELETE':
				return $this->performDelete($url, $arguments, $accept);

			default:
				/* 501 (Not Implemented) for any unknown methods */
				header('Allow: ' . $this->supportedMethods, true, 501);
		}
	}

	public function getErrorDescription($code)
	{
		$errorDescription = array(
			200 => 'OK',
			201 => 'Created',
			204 => 'No Content',
			400 => 'Bad Request',
			404 => 'Not Found',
			405 => 'Method Not Allowed',
			406 => 'Not Acceptable',
			500 => 'Internal Server Error',
			501 => 'Not Implemented'
		);

		return isset($errorDescription[$code]) ? $errorDescription[$code] : null; 
	}

	protected function methodNotAllowedResponse() 
	{
		/* 405 (Method Not Allowed) */
		header('Allow: ' . $this->supportedMethods, true, 405);

		return false;
	}

	public function performGet($url, $arguments, $accept) 
	{
		return $this->methodNotAllowedResponse();
	}

	public function performHead($url, $arguments, $accept) 
	{
		return $this->methodNotAllowedResponse();
	}

	public function performPost($url, $arguments, $accept) 
	{
		return $this->methodNotAllowedResponse();
	}

	public function performPut($url, $arguments, $accept) 
	{
		return $this->methodNotAllowedResponse();
	}

	public function performDelete($url, $arguments, $accept) 
	{
		return $this->methodNotAllowedResponse();
	}
}

