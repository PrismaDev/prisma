<?php

namespace Framework;

Class ViewLoader
{
	public static function load($module, $path, $data)
	{
		$fullpath = dirname(__DIR__).'/'.$module.'/View/'.$path;

		if(file_exists($fullpath))
		{
			ob_start();

			include $fullpath;

			$view = ob_get_contents();

			ob_end_clean();

			return $view;
		}
		else
		{
			//TODO
		}
	}
}
