<?php

chdir(dirname(__DIR__).'/Application');
require_once 'autoload.php';

error_reporting(E_ALL);
//error_reporting(0);

date_default_timezone_set('America/Sao_Paulo');

Framework\Main::init();
