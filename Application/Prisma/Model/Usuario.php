<?php

namespace Prisma\Model;

use Framework\Database;

class Usuario
{
	public static function getById($login)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "Nome" as "NomeUsuario", "UltimoAcesso" FROM "Usuario" WHERE "PK_Login" = ? AND "TermoAceito"=TRUE;');
		$sth->execute(array($login));

		return $sth->fetch(\PDO::FETCH_ASSOC);	
	}

	public static function acceptTerm($login, $accept)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('UPDATE "Usuario" SET "TermoAceito"=? WHERE "PK_Login" = ?;');	
		$sth->execute(array($accept, $login));

		return $sth->rowCount() > 0;
	}

	public static function wasTermAccepted($login)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT 1 FROM "Usuario" WHERE "PK_Login" = ? AND "TermoAceito"=TRUE;');	
		$sth->execute(array($login));

		return $sth->fetch() != false;	
	}

	public static function getId($nome)
	{
		$dbh = Database::getConnection();	

		$sth = $dbh->prepare('SELECT "PK_Professor" FROM "Professor" WHERE "Nome" = ?;');	
		$sth->execute(array($nome));

		if($result = $sth->fetch())
		{
			return $result['PK_Professor'];
		}
		else
		{
			//TODO: handle error
		}
	}

	/* --------------------------------------------------------------- */

	public static function saveAlunoFromFile($file)
	{
		$file = fopen($file, 'r');

		if(!$file)
		{
			// TODO: log
			return false;
		}

		$dbh = Database::getConnection();
		$dbh->beginTransaction();

		$skip = true;
		while($row = fgetcsv($file, 1000, ';'))
		{ 
			if(count($row) < 4) continue;

			if(!self::persistAlunoRow($row))
			{
				$dbh->rollback();
				return false;
			}
		}

		$dbh->commit();
		return true;
	}

	private static function persistAlunoRow($row)
	{
		$dbh = Database::getConnection();

		$sth = $dbh->prepare('INSERT INTO "Usuario"("PK_Login", "Nome", "FK_TipoUsuario") VALUES (?, ?, 3);');
		$sth->execute(array
		(
			$row[0],
			$row[1],
		));

		$sth = $dbh->prepare('INSERT INTO "Aluno"("FK_Matricula", "CoeficienteRendimento", "FK_Curso") VALUES (?, ?, ?);');
		$sth->execute(array
		(
			$row[0],
			(float)str_replace(',','.',$row[2]),
			$row[3],
		));

		return $sth->rowCount() > 0;
	}

	/* --------------------------------------------------------------- */

	public static function saveHistoricoFromFile($file)
	{
		$file = fopen($file, 'r');

		if(!$file)
		{
			// TODO: log
			return false;
		}

		$dbh = Database::getConnection();
		$dbh->beginTransaction();

		$skip = true;
		while($row = fgetcsv($file, 1000, ';'))
		{ 
			if(count($row) < 5) continue;

			if(!self::persistHistoricoRow($row))
			{
			print_r($row);
			print_r($dbh->errorInfo());
				$dbh->rollback();
				return false;
			}
		}

		$dbh->commit();
		return true;
	}

	private static function persistHistoricoRow($row)
	{
		$row[0] = str_pad($row[0], 7, '0', STR_PAD_LEFT);
		if($row[4]=='FC') $row[4] = 'NC';

		if(substr($row[0], 0, 3) == '131') return true;

		$dbh = Database::getConnection();
		$sth = null;

		if(substr($row[3], 0, 1) == 'P' && $row[4] == 'NC') //optativa
		{
			$sth = $dbh->prepare('INSERT INTO "OptativaAluno"("FK_Aluno", "FK_Optativa", "PeriodoSugerido") VALUES (?, ?, ?);');
			$sth->execute(array
			(
				$row[0],
				$row[1],
				$row[2]
			));
		}
		else //disciplina
		{
			$sth = $dbh->prepare('INSERT INTO "AlunoDisciplina"("FK_Aluno", "FK_Disciplina", "Periodo", "FK_TipoDisciplina", "FK_Status", "Tentativas") VALUES (?, ?, ?, ?, ?, ?);');
			$sth->execute($row);
		}

		return $sth->rowCount() > 0;
	}

}
