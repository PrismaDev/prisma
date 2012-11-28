<?php

namespace Prisma\Model;

use Prisma\Model\ModelInterface;

class Usuario implements ModelInterface
{
	/* Attributes */

	protected $login;
	protected $senha;
	protected $nome;


	/* Getters and Setters */

	public function getLogin() { return $this->login; } 
	public function setLogin($login) { $this->login = $login; } 

	public function getSenha() { return $this->Senha; } 
	public function setSenha($senha) { $this->senha = $senha; } 

	public function getNome() { return $this->nome; } 
	public function setNome($nome) { $this->nome = $nome; } 


	/* ModelInterface implementation */

	public function load($obj)
	{
		$this->setLogin($obj->login);
		$this->setSenha($obj->senha);
		$this->setNome($obj->nome);
	}

	public function toArray()
	{
		return array(
			'login' => $this->getLogin(),
			'senha' => $this->getSenha(),
			'nome' 	=> $this->getNome()
		);
	}
}

