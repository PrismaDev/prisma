<?php

chdir(dirname(__DIR__)."/Application");
require_once "autoload.php";

error_reporting(E_ALL);
//error_reporting(0);

Framework\Main::init();
