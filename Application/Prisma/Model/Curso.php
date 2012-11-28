<?php

namespace Prisma\Model;

use Prisma\Model\ModelInterface;

class Curso implements ModelInterface
{
	/* Attributes */

	protected $id;
	protected $nome;


	/* Getters and Setters */

	public function getId() { return $this->id; } 
	public function setId($id) { $this->id = $id; } 

	public function getNome() { return $this->nome; } 
	public function setNome($nome) { $this->nome = $nome; } 


	/* ModelInterface implementation */

	public function load($obj)
	{
		$this->id($obj->id);
		$this->nome($obj->nome);
	}

	public function toArray()
	{
		return array(
			'id' 	=> $this->getId(),
			'nome' 	=> $this->getNome()
		);
	}
}

