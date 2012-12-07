<?php

namespace Prisma\Model;

use Framework\Database;
use Prisma\Model\Turma;

class Disciplina
{
	public static function getFaltaCursar($login)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "FK_Disciplina" as "CodigoDisciplina", "Periodo" as "PeriodoAno", "Tentativas"
					FROM "AlunoDisciplina" WHERE "FK_Status" <> \'CP\' AND "FK_Aluno" = ?;');
		$sth->execute(array($login));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function getByUserIdDepend($login, $id)
	{
		$disciplina = self::getByUserId($login, $id);
		$disciplina['Turmas'] = Turma::getByDisciplinaDepend($id);

		return $disciplina;
	}

	public static function getByUserId($login, $id)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "CodigoDisciplina", "NomeDisciplina", "Creditos", "Situacao", "Apto"
					FROM "MicroHorarioDisciplina" WHERE "Aluno" = ? AND "CodigoDisciplina" = ?;');
		$sth->execute(array($login, $id));

		return $sth->fetch(\PDO::FETCH_ASSOC);
	}

	public static function getByUserDiscSetDepend($login, $disciplinaHash)
	{
		$disciplinas = self::getByUserDiscSet($login, $disciplinaHash);

		$myDiscHash = array();
		foreach($disciplinas as $k=>$disciplina)
		{
			$myDiscHash[$disciplina['CodigoDisciplina']] = $k;
		}

		$turmas = Turma::getByDiscSetDepend($myDiscHash);

		foreach($turmas as $turma)
		{
			$idx = $myDiscHash[$turma['CodigoDisciplina']];
			unset($turma['CodigoDisciplina']);

			$disciplinas[$idx]['Turmas'][] = $turma;
		}

		return $disciplinas;
	}

	public static function getByUserDiscSet($login, $disciplinaHash)
	{
		$dbh = Database::getConnection();

		$sql = 'SELECT "CodigoDisciplina", "NomeDisciplina", "Creditos", "Situacao", "Apto"
				FROM "MicroHorarioDisciplina" WHERE "Aluno" = ? AND "CodigoDisciplina" IN (';

		$comma = false;
		foreach($disciplinaHash as $codigoDisciplina=>$index)
		{
			if($index >= 0)
			{
				if(!$comma) $comma = true;
				else $sql .= ', ';

				$sql .= '\''.$codigoDisciplina.'\'';
			}
		}

		$sql .= ');';

		$sth = $dbh->prepare($sql);
		$sth->execute(array($login));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function persist($data)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "Disciplina"("PK_Codigo", "Nome", "Creditos") VALUES (:PK_Codigo, :Nome, :Creditos);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception('['.$error[0].'/'.$error[1].']: '.$error[2]);
		}

		return $data['PK_Codigo'];
	}
}
