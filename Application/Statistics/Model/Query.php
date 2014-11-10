<?php

namespace Statistics\Model;

use Framework\Database;

class Query
{
/*
	# quanto ao tema

	- relacao candidato vaga - por turma - por disciplina
	SELECT "FK_Disciplina", "Codigo", "Vagas", "Demanda" FROM "EstatisticaDemandaTurma";

	- quantidade de solicitacoes por horarios
	SELECT "Opcao", "Unidade", "DiaSemana", "HoraInicial", "HoraFinal", "Demanda" FROM "EstatisticaDemandaHorario" ORDER BY "Demanda" DESC;

	- media de tentativas por disciplina
	SELECT "FK_Disciplina", avg("Tentativas") as "MediaTentativas" FROM "AlunoDisciplina" GROUP BY "FK_Disciplina" ORDER BY "MediaTentativas" DESC;
*/
	public static function ContagemTotal()
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT count AS "QuantidadeTotalUsuario" FROM "LogQuantidadeUsuario";');	
		$sth->execute(array());

		if($result = $sth->fetch(\PDO::FETCH_ASSOC))
		{
			return $result['QuantidadeTotalUsuario'];
		}
		else
		{
			throw new \Exception(__FILE__.'(Line '.__LINE__.'): Erro ao pegar ranking do aluno!');
		}
	}

	public static function AcessoDiario()
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT "Data", count AS "QuantidadeUsuario" FROM "LogUsuarioDia";');
		$sth->execute(array());

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function UsoPorCurso()
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT "CodigoCurso", "NomeCurso", "Atual", "Total", "Porcentagem" FROM "LogAlunoCurso";');
		$sth->execute(array());

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function TurmaDemanda()
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT "FK_Disciplina", "Codigo", "Vagas", "Demanda" FROM "EstatisticaDemandaTurma";');
		$sth->execute(array());

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function HorarioDemanda()
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT "Opcao", "Unidade", "DiaSemana", "HoraInicial", "HoraFinal", "Demanda" FROM "EstatisticaDemandaHorario" ORDER BY "Demanda" DESC;');
		$sth->execute(array());

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function DisciplinaTentativaMedia()
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('SELECT "FK_Disciplina", avg("Tentativas") as "MediaTentativas" FROM "AlunoDisciplina" GROUP BY "FK_Disciplina" ORDER BY "MediaTentativas" DESC;');
		$sth->execute(array());

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}



}
