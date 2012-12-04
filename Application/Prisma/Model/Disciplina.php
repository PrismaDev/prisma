<?php

namespace Prisma\Model;

use Framework\Database;

class Disciplina
{
	public static function getAll()
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "PK_Nome" as "CodigoDisciplina", "Nome" as "NomeDisciplina", "Creditos" FROM "Disciplina";');
		$sth->execute();

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function getMicroHorario($login, $filters)
	{
		$dbh = Database::getConnection();	

		$sql = 'SELECT "CodigoDisciplina", "NomeDisciplina", "Creditos", "Situacao", "Apto"
			FROM "MicroHorarioDisciplina" WHERE "Aluno" = ?';

		if(isset($filters['CodigoDisciplina']) && !empty($filters['CodigoDisciplina']))
		{
			$sql .= ' AND "CodigoDisciplina" ILIKE \'%'.$filters['CodigoDisciplina'].'%\'';
		}
		if(isset($filters['NomeDisciplina']) && !empty($filters['NomeDisciplina']))
		{
			$sql .= ' AND "NomeDisciplina" ILIKE \'%'.$filters['NomeDisciplina'].'%\'';
		}
		if(isset($filters['Creditos']) && !empty($filters['Creditos']))
		{
			$sql .= ' AND "Creditos" = '.$filters['Creditos'].'';
		}

		$sql .= ';';

		$sth = $dbh->prepare($sql);
		$sth->execute(array($login));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function getFaltaCursar($login)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "Aluno", "Nome", "Nome", "Creditos", "Situacao", "PeriodoSugerido", "Tentativas", "Apto"
					FROM "FaltaCursarDisciplina" WHERE "Aluno" = ?;');
		$sth->execute(array($login));

		return $sth->fetchAll(\PDO::FETCH_ASSOC);
	}

	public static function getById($id)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "PK_Nome" as "CodigoDisciplina", "Nome" as "NomeDisciplina", "Creditos" FROM "Disciplina" WHERE "PK_Codigo" = ?;');
		$sth->execute(array($id));

		return $sth->fetch(\PDO::FETCH_ASSOC);
	}

	public static function persist($data)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('INSERT INTO "Disciplina"("PK_Nome", "Nome", "Creditos") VALUES (:PK_Codigo, :Nome, :Creditos);');

		if(!$sth->execute($data))
		{
			$error = $dbh->errorInfo();
			throw new \Exception('['.$error[0].'/'.$error[1].']: '.$error[2]);
		}

		return $data['PK_Nome'];
	}
}
