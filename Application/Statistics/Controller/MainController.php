<?php

namespace Statistics\Controller;

use Framework\RestController;
use Framework\ViewLoader;
use Library\Auth;
use Library\Common;
use Statistics\Model\Query;

Class MainController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET');
	}

	public function performGet($url, $arguments, $accept) 
	{
		$data = array
		(
			'username' => 'Julio Test',
			'qtdTotal' => Query::ContagemTotal(),
			'acessoDiario' => json_encode(Query::AcessoDiario()),
			'usoPorCurso' => json_encode(Query::UsoPorCurso()),
			'turmaDemanda' => json_encode(Query::TurmaDemanda()),
			'horarioDemanda' => json_encode(Query::HorarioDemanda()),
			'disciplinaTentativaMedia' => json_encode(Query::DisciplinaTentativaMedia()),
		);

		return ViewLoader::load('Statistics', 'statistics.phtml', $data);
	}
}

