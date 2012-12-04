var MicrohorarioStringsModel = Backbone.Model.extend({
	defaults: {
		'openFiltersStr': 'Abrir filtros',
		'closeFiltersStr': 'Fechar filtros',
		'subjectCodeLabel': 'Código da disciplina',
		'subjectNameLabel': 'Nome da disciplina',
		'professorNameLabel': 'Professor',
		'moreFiltersStr': 'Mais filtros',
		'lessFiltersStr': 'Menos filtros',
		'toggleBlockedDisabledLabel': 'Exibir disciplinas cursadas ou bloqueadas',
		'noQueryStr': 'Não foi feita nenhuma busca',
		'nCreditsLabel': 'Nº de créditos',
		'targetBlockLabel': 'Bloqueio',
		'dayLabel': 'Dia da semana',
		'timeBeginLabel': 'Horário de início',
		'timeEndLabel': 'Horário de término',
		'noFixedScheduleLabel': 'Sem horário fixo',
		'distanceHoursLabel': 'Com horas à distância',
		'resetButtonLabel': 'Limpar campos',
		'submitButtonLabel': 'Buscar'
	}
});

var microhorarioStringsModel = new MicrohorarioStringsModel();
