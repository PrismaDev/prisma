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
		$horarioDemanda = Query::HorarioDemanda();
		
		$horario = array();
		foreach($horarioDemanda as $demanda)
		{
			$horario[(int)$demanda["DiaSemana"]][(int)$demanda["HoraInicial"]] += (int)$demanda["Demanda"];
		}

		$data = array
		(
			'username' => 'Statistics Account',
			'qtdTotal' => Query::ContagemTotal(),
			'acessoDiario' => json_encode(Query::AcessoDiario()),
			'usoPorCurso' => json_encode(Query::UsoPorCurso()),
			'turmaDemanda' => Query::TurmaDemanda(),
			'horarioDemanda' => $horario,
			'disciplinaTentativaMedia' => Query::DisciplinaTentativaMedia(),
		);

		return ViewLoader::load('Statistics', 'statistics.phtml', $data);
	}
}

