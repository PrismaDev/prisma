<?php

spl_autoload_register(null, false);
spl_autoload_extensions('.php,.inc,.class,.interface');

function _autoload($classname) {
	$classname = ltrim($classname, '\\');
	$filename  = '';
	$namespace = '';
	if ($lastnspos = strripos($classname, '\\')) {
		$namespace = substr($classname, 0, $lastnspos);
		$classname = substr($classname, $lastnspos + 1);
		$filename  = str_replace('\\', '/', $namespace) . '/';
	}
	$filename .= str_replace('_', '/', $classname) . '.php';

	if(file_exists($filename))
	{
		require $filename;
	}
	else
	{
		//TODO
	}
}

spl_autoload_register('_autoload', false);

