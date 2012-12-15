<?php

chdir(dirname(__DIR__).'/Application');
require_once 'autoload.php';

session_start();
set_time_limit ( 300 );

error_reporting(E_ALL);
//error_reporting(0);

date_default_timezone_set('America/Sao_Paulo');

Framework\Main::init();
