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

	public static function saveFromFile($file)
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

			if(!self::persistRow($row))
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

	private static function persistRow($row)
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

}
