<?php

use Doctrine\Common\Collections\ArrayCollection;

require_once "Professor.php";
require_once "Turma.php";

/** 
 * @Entity 
 * @Table(name="horario") 
 **/
class Horario
{
	/** 
	 * @Id
	 * @Column(type="integer", name="pk_horario") 
	 * @generatedValue(strategy="SEQUENCE") 
	 * @SequenceGenerator(sequenceName="horario_seq", initialValue=1, allocationSize=1)
	 **/
	protected $id = null;

	/** @Column(type="integer", name="dia_semana") **/
	protected $diaSemana;

	/** @Column(type="integer", name="hora") **/
	protected $hora;

	/**
	 * @ManyToMany(targetEntity="Professor", mappedBy="horarios")
	 **/
	protected $professores;

	/**
	 * @ManyToMany(targetEntity="Turma", mappedBy="horarios")
	 **/
	protected $turmas;

	/* ---------------------------------------- */

	public function __construct($diaSemana, $hora)
 	{
		$this->diaSemana = $diaSemana;
		$this->hora = $hora;

		$this->professores = new ArrayCollection();
		$this->turmas = new ArrayCollection();
	}

	public function getId()
	{
		return $this->id;
	}

	public function getDiaSemana()
	{
		return $this->diaSemana;
	}

	public function getHora()
	{
		return $this->hora;
	}
}

?>
