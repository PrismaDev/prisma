<?php

use Doctrine\Common\Collections\ArrayCollection;

require_once "Turma.php";
require_once "Enfase.php";
require_once "Professor.php";

/** 
 * @Entity 
 * @Table(name="disciplina") 
 **/
class Disciplina
{
	/** 
	 * @Id 
	 * @Column(type="integer", name="pk_disciplina") 
	 **/
	protected $id;

	/** @Column(type="string", name="codigo", length=7) **/
	protected $codigo;

	/** @Column(type="string", name="nome", length=30) **/
	protected $nome;

	/** @Column(type="integer", name="creditos") **/
	protected $creditos;

	/**
	 * @OneToMany(targetEntity="Turma", mappedBy="disciplina", cascade={"persist", "merge"})
	 **/
	protected $turmas;

	/**
	 * @ManyToMany(targetEntity="Professor", mappedBy="disciplinas")
	 **/
	protected $professores;

	protected $optativas;
	protected $optativas;

	/* ---------------------------------------- */

	public function __construct($id, $codigo = "", $nome = "", $qtdHoras = 0, $periodoGrade = 1)
 	{
		$this->id = $id;
		$this->codigo = $codigo;
		$this->nome = $nome;
		$this->qtdHoras = $qtdHoras;
		$this->periodoGrade = $periodoGrade;

		$this->turmas = new ArrayCollection();
		$this->enfases = new ArrayCollection();
		$this->professores = new ArrayCollection();
	}

	public function getId()
	{
		return $this->id;
	}

	public function getCodigo()
	{
		return $this->codigo;
	}

	public function getNome()
	{
		return $this->nome;
	}

	public function getPeriodoGrade()
	{
		return $this->periodoGrade;
	}

	public function getEnfases()
	{
		return $this->enfases->getValues();
	}

	/* ---------------------------------------- */

	public function loadJSON($json, $em)
	{
		$obj = json_decode($json);

		$this->codigo = $obj->codigo;
		$this->nome = $obj->nome;
		$this->qtdHoras = $obj->qtdHoras;
		$this->periodoGrade = $obj->periodoGrade;

		$this->turmas->clear();
		if(is_array($obj->idTurmaArray)) foreach($obj->idTurmaArray as $idTurma)
		{
			$turma = $em->find("Turma", $idTurma);

			if($turma != null)
				$this->turmas[] = $turma;
		}
		
		$this->professores->clear();
		if(is_array($obj->idProfessorArray)) foreach($obj->idProfessorArray as $idProfessor)
		{
			$professor = $em->find("Professor", $idProfessor);

			if($professor != null)
				$this->professores[] = $professor;
		}
		
		$this->enfases->clear();
		if(is_array($obj->idEnfaseArray)) foreach($obj->idEnfaseArray as $idEnfase)
		{
			$enfase = $em->find("Enfase", $idEnfase);

			if($enfase != null)
				$this->enfases[] = $enfase;
		}

		return true;
	}

	public function prepareToJSON()
	{
		$data = array
		(
			'id' 		=> $this->id,
			'codigo' 	=> $this->codigo,
			'nome' 		=> $this->nome,
			'qtdHoras' 	=> $this->qtdHoras,
			'periodoGrade' 	=> $this->periodoGrade
		);

		$i = 0;
		foreach($this->turmas->getValues() as $turma)
		{
			$data['idTurmaArray'][$i++] = $turma->getId();
		}

		$i = 0;
		foreach($this->professores->getValues() as $professor)
		{
			$data['idProfessorArray'][$i++] = $professor->getId();
		}

		$i = 0;
		foreach($this->enfases->getValues() as $enfase)
		{
			$data['idEnfaseArray'][$i++] = $enfase->getId();
		}

		return $data;
	}
}

?>
