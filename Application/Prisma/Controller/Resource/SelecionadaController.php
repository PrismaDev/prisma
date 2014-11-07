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

		$opcao = array();
		foreach($selecionadas as $sel)
		{
			$content = $sel["CodigoDisciplina"]." - ".Turma::getCode($sel["FK_Turma"]);

			if(!isset($opcao[$sel["NoLinha"]]))
				$opcao[$sel["NoLinha"]] = array();

			$opcao[$sel["NoLinha"]][$sel["Opcao"]] = $content;
		}

		$data .= "Opcao 1;Opcao 2;Opcao 3\n";
		for($i = 0; $i < 12; $i++)
		{
			for($j = 0; $j < 3; $j++)
			{
				if(isset($opcao[$i][$j]))
					$data .= $opcao[$i][$j];

				if($j < 2)
					$data .= ";";
			}
			$data .= "\n";
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
