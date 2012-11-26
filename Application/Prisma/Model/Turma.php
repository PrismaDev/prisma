<?php

use Doctrine\Common\Collections\ArrayCollection;

require_once "Professor.php";
require_once "Disciplina.php";
require_once "Horario.php";

/** 
 * @Entity 
 * @Table(name="turma") 
 **/
class Turma
{
	/** 
	 * @Id 
	 * @Column(type="integer", name="pk_turma") 
	 **/
	protected $id;

	/** @Column(type="string", name="codigo", length=5) **/
	protected $codigo;

	/** @Column(type="integer", name="periodo_ano") **/
	protected $periodoAno;

	/**
	 * @ManyToOne(targetEntity="Professor", cascade={"persist", "merge"}, fetch="LAZY")
	 * @JoinColumn(name="fk_professor", referencedColumnName="pk_professor")
	 **/
	protected $professor;

	/**
	 * @ManyToOne(targetEntity="Disciplina", cascade={"persist", "merge"}, fetch="LAZY")
	 * @JoinColumn(name="fk_disciplina", referencedColumnName="pk_disciplina")
	 **/
	protected $disciplina;

	/**
	 * @ManyToMany(targetEntity="Horario", inversedBy="turmas", fetch="LAZY")
	 * @JoinTable(name="turma_horario",
	 *      joinColumns={@JoinColumn(name="fk_turma", referencedColumnName="pk_turma")},
	 *      inverseJoinColumns={@JoinColumn(name="fk_horario", referencedColumnName="pk_horario")}
	 *      )
	 **/
	protected $horarios;

	/* ---------------------------------------- */

	public function __construct($id, $codigo = "", $periodoAno = "")
	{
		$this->id = $id;
		$this->codigo = $codigo;
		$this->periodoAno = $periodoAno;

		$this->professor = null;
		$this->disciplina = null;
		$this->horarios = new ArrayCollection();
	}	

	public function getId()
	{
		return $this->id;
	}

	public function getProfessor()
	{
		return $this->professor;
	}

	public function getDisciplina()
	{
		return $this->disciplina;
	}

	public function getCodigo()
	{
		return $this->codigo;
	}

	public function getHorarios()
	{
		return $this->horarios->getValues();
	}

	public function setDisciplina($disciplina)
	{
		$this->disciplina = $disciplina;
	}

	public function setProfessor($professor)
	{
		$this->professor = $professor;
	}

	public function addHorario($em, $diaSemana, $hora)
	{
		$horarioObj = $em->getRepository("Horario")->findOneBy(array("diaSemana" => $diaSemana, "hora" => $hora));

		if($horarioObj == null) return false;
		foreach($this->horarios->getValues() as $horario)
		{
			if($horario->getDiaSemana() == $diaSemana && $horario->getHora() == $hora)
			{
				return false;
			}
		}

		$this->horarios[] = $horarioObj;

		return true;
	}


	/* ---------------------------------------- */

	public function loadJSON($json, $em)
	{
		$obj = json_decode($json);

		$this->codigo = $obj->codigo;
		$this->periodoAno = $obj->periodoAno;

		$this->disciplina = $em->find("Disciplina", $obj->idDisc);

		if(isset($obj->idProfessor))
			$this->professor = $em->find("Professor", $obj->idProfessor);
		else 
			$this->professor = null;

		$this->horarios->clear();
		if(is_array($obj->horarioArray)) foreach($obj->horarioArray as $horario)
		{
			$horarioObj = $em->getRepository("Horario")->findOneBy(array("diaSemana" => $horario->diaSemana, "hora" => $horario->hora));

			if($horarioObj == null)
			{
				$horarioObj = new Horario($horario->diaSemana, $horario->hora);
				$em->persist($horarioObj);
			}

			$this->horarios[] = $horarioObj;
		}

		return true;
	}

	public function prepareToJSON()
	{
		$data = array
		(
			'id' 		=> $this->id,
			'codigo' 	=> $this->codigo,
			'periodoAno'	=> $this->periodoAno,
			'idDisc'	=> $this->disciplina->getId()
		);

		if($this->professor) 
			$data['idProfessor'] = $this->professor->getId();

		$i = 0;
		foreach($this->horarios->getValues() as $horario)
		{
			$data['horarioArray'][$i]['diaSemana'] = $horario->getDiaSemana();
			$data['horarioArray'][$i]['hora'] = $horario->getHora();

			$i++;
		}

		return $data;
	}

}

?>
