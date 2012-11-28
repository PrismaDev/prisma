<?php

use Doctrine\Common\Collections\ArrayCollection;

require_once "Disciplina.php";

/** 
 * @Entity 
 * @Table(name="enfase") 
 **/
class Enfase
{
	/** 
	 * @Id 
	 * @Column(type="integer", name="pk_enfase") 
	 **/
	protected $id;

	/** @Column(type="string", name="nome", length=20) **/
	protected $nome;

	/**
	 * @ManyToMany(targetEntity="Disciplina", inversedBy="enfases", fetch="LAZY")
	 * @JoinTable(name="enfase_disciplina",
	 *      joinColumns={@JoinColumn(name="fk_enfase", referencedColumnName="pk_enfase")},
	 *      inverseJoinColumns={@JoinColumn(name="fk_disciplina", referencedColumnName="pk_disciplina")}
	 *      )
	 **/
	protected $disciplinas;

	/* ---------------------------------------- */

	public function __construct($id, $nome = "")
 	{
		$this->id = $id;
		$this->nome = $nome;

		$this->disciplinas = new ArrayCollection();
	}

	public function getId()
	{
		return $this->id;
	}

	public function getNome()
	{
		return $this->nome;
	}

	/* ---------------------------------------- */

	public function loadJSON($json, $em)
	{
		$obj = json_decode($json);

		$this->nome = $obj->nome;

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
			'nome'		=> $this->nome
		);

		$i = 0;
		foreach($this->disciplinas->getValues() as $disciplina)
		{
			$data['idDiscArray'][$i++] = $disciplina->getId();
		}

		return $data;
	}


}

?>
