<?php

namespace Prisma\Controller\Resource;

use Framework\RestController;
use Library\Common;
use Library\Auth;
use Prisma\Model\Selecionada;
use Prisma\Model\Turma;

class SelecionadaController extends RestController
{
	public function __construct()
	{
		parent::__construct('GET, POST');

		Auth::accessControl('Aluno');
	}


	public function performGet($url, $arguments, $accept) 
	{
		$login = Auth::getSessionLogin();

		$selecionadas = Selecionada::getAll($login);

		$data = "Disciplina;Turma;Opcao;Linha\n";
		foreach($selecionadas as $selecionada)
		{
			$data .= $selecionada["CodigoDisciplina"].";";
			$data .= Turma::getCode($selecionada["FK_Turma"]).";";
			$data .= ($selecionada["Opcao"]+1).";";
			$data .= ($selecionada["NoLinha"]+1)."\n";
		}

		header("Content-Disposition: attachment; filename=PrISMA-Horario_selecionado.CSV");
		return $data;
	}

	public function performPost($url, $arguments, $accept) 
	{
		$login = Auth::getSessionLogin();

		$rows = json_decode(str_replace('\\"','"',$arguments['json']));
		$len = count($rows);

		for($i = 0; $i < $len; ++$i)
		{
			if(!Selecionada::persist($login, $rows[$i]))
			{
				return 'error';
			}
		}

		return 'ok';
	}

	public function performDelete($url, $arguments, $accept) 
	{
		$login = Auth::getSessionLogin();

		$rows = json_decode(str_replace('\\"','"',$arguments['json']));
		$len = count($rows);

		for($i = 0; $i < $len; ++$i)
		{
			if(!Selecionada::remove($login, $rows[$i]->FK_Turma))
			{
				return 'error';
			}
		}

		return 'ok';
	}

}
