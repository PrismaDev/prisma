<?php

namespace Prisma\Model;

use Prisma\Model\ModelInterface;
use Prisma\Model\Curso;

class Aluno extends Usuario implements ModelInterface
{
	/* Attributes */

	protected $matricula;
	protected $email;
	protected $curso;


	/* Getters and Setters */

	public function getMatricula() { return $this->matricula; } 
	public function setMatricula($matricula) { $this->matricula = $matricula; } 

	public function getEmail() { return $this->email; } 
	public function setEmail($email) { $this->email = $email; } 

	public function getCurso() { return $this->curso; } 
	public function setCurso(Curso $curso) { $this->curso = $curso; } 


	/* ModelInterface implementation */

	public function load($obj)
	{
		parent::load($obj);

		$this->setMatricula($obj->matricula);
		$this->setEmail($obj->email);
		$this->setCurso($obj->curso); //TODO: variavel pode nao ser valida
	}

	public function toArray()
	{
		$array = parent::toArray();

		$array['matricula'] 	= $this->getMatricula();
		$array['email'] 	= $this->getEmail();
		$array['curso']		= $this->getCurso()->getId();

		return $array;
	}
}

