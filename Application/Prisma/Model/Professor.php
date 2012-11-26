<?php

use Doctrine\Common\Collections\ArrayCollection;

require_once "Turma.php";
require_once "Disciplina.php";
require_once "Horario.php";

/** 
 * @Entity 
 * @Table(name="professor") 
 **/
class Professor
{
	/** 
	 * @Id 
	 * @Column(type="integer", name="pk_professor") 
	 **/
	protected $id;

	/** @Column(type="string", name="matricula", length=20) **/
	protected $matricula;

	/** @Column(type="string", name="nome", length=50) **/
	protected $nome;

	/** @Column(type="boolean", name="imexivel") **/
	protected $imexivel;

	/**
	 * @OneToMany(targetEntity="Turma", mappedBy="professor", cascade={"persist", "merge"})
	 **/
	protected $turmas;

	/**
	 * @ManyToMany(targetEntity="Disciplina", inversedBy="professores", fetch="LAZY")
	 * @JoinTable(name="professor_disciplina",
	 *      joinColumns={@JoinColumn(name="fk_professor", referencedColumnName="pk_professor")},
	 *      inverseJoinColumns={@JoinColumn(name="fk_disciplina", referencedColumnName="pk_disciplina")}
	 *      )
	 **/
	protected $disciplinas;

	/**
	 * @ManyToMany(targetEntity="Horario", inversedBy="professores", fetch="LAZY")
	 * @JoinTable(name="professor_horario",
	 *      joinColumns={@JoinColumn(name="fk_professor", referencedColumnName="pk_professor")},
	 *      inverseJoinColumns={@JoinColumn(name="fk_horario", referencedColumnName="pk_horario")}
	 *      )
	 **/
	protected $horarios;

	/* ---------------------------------------- */

	public function __construct($id, $matricula = "", $nome = "", $imexivel = false)
	{
		$this->id = $id;
		$this->matricula = $matricula;
		$this->nome = $nome;
		$this->imexivel = $imexivel;

		$this->turmas = new ArrayCollection();
		$this->disciplinas = new ArrayCollection();
		$this->horarios = new ArrayCollection();
	}
	
	public function getId()
	{
		return $this->id;
	}

	public function getNome()
	{
		return $this->nome;
	}

	public function getTurmas()
	{
		return $this->turmas->getValues();
	}

	public function addDisciplina($pDisciplina)
	{
		foreach($this->disciplinas->getValues() as $disciplina)
		{
			if($disciplina->getId() == $pDisciplina->getId())
			{
				return false;
			}
		}

		$this->disciplinas[] = $pDisciplina;
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

	public function setImexivel($bool)
	{
		$this->imexivel = $bool;
	}

	public function setMatricula($matricula)
	{
		$this->matricula = $matricula;
	}

	/* ---------------------------------------- */

	public function loadJSON($json, $em)
	{
		$obj = json_decode($json);

		$this->matricula = $obj->matricula;
		$this->nome = $obj->nome;
		$this->imexivel = $obj->imexivel;

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

		$this->turmas->clear();
		if(is_array($obj->idTurmaArray)) foreach($obj->idTurmaArray as $idTurma)
		{
			$turma = $em->find("Turma", $idTurma);

			if($turma != null)
				$this->turmas[] = $turma;
		}

		$this->disciplinas->clear();
		if(is_array($obj->idDiscArray)) foreach($obj->idDiscArray as $idDisc)
		{
			$disc = $em->find("Disciplina", $idDisc);

			if($disc != null)
				$this->disciplinas[] = $disc;
		}

		return true;
	}

	public function prepareToJSON()
	{
		$data = array
		(
			'id' 		=> $this->id,
			'matricula' 	=> $this->matricula,
			'nome'		=> $this->nome,
			'imexivel'	=> $this->imexivel
		);

		$i = 0;
		foreach($this->turmas->getValues() as $turma)
		{
			$data['idTurmaArray'][$i++] = $turma->getId();
		}

		$i = 0;
		foreach($this->disciplinas->getValues() as $disciplina)
		{
			$data['idDiscArray'][$i++] = $disciplina->getId();
		}

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
