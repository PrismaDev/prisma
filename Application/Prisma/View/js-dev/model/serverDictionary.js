var ServerDictionary = Backbone.Model.extend({
	defaults: {
			'Dependencia'           : 'Dependencia',
                       	'FaltaCursar'           : 'FaltaCursar',
                        'Selecionada'           : 'Selecionada',
                        'MicroHorario'          : 'MicroHorario',
                        'Disciplinas'           : 'Disciplinas',
                        'Turmas'                : 'Turmas',
                        'Optativas'             : 'Optativas',
                        'Horarios'              : 'Horarios',
                        'CodigoDisciplina'      : 'CodigoDisciplina',
                        'CodigoTurma'           : 'CodigoTurma',
                        'CodigoOptativa'        : 'CodigoOptativa',
                        'PK_Turma'              : 'PK_Turma',
                        'FK_Turma'              : 'FK_Turma',
                        'NomeDisciplina'        : 'NomeDisciplina',
                        'NomeProfessor'         : 'NomeProfessor',
                        'NomeOptativa'          : 'NomeOptativa',
                        'Creditos'              : 'Creditos',
                        'Situacao'              : 'Situacao',
                        'Apto'                  : 'Apto',
                        'Vagas'                 : 'Vagas',
                        'Destino'               : 'Destino',
                        'HorasDistancia'        : 'HorasDistancia',
                        'PeriodoAno'            : 'PeriodoAno',
                        'Tentativas'            : 'Tentativas',
                        'Opcao'                 : 'Opcao',
                        'NoLinha'               : 'NoLinha',
                        'DiaSemana'             : 'DiaSemana',
                        'HoraInicial'           : 'HoraInicial',
                        'HoraFinal'             : 'HoraFinal'
	}
});

var serverDictionary = new ServerDictionary();
