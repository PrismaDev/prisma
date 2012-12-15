var MainStringsModel = Backbone.Model.extend({
	defaults: {
		'faltacursarTabLabel': 'Falta Cursar',
		'microhorarioTabLabel': 'Micro Horário',
		'selectedTabLabel': 'Selecionadas'
	}
});
var mainStringsModel = new MainStringsModel();

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
		'submitButtonLabel': 'Buscar',
		'waitingImgURL': '/img/ajax-loader.gif' 
	}
});
var microhorarioStringsModel = new MicrohorarioStringsModel();

var SelectedStringsModel = Backbone.Model.extend({
	defaults: {
		'option1Label': '1ª opção',
		'option2Label': '2ª opção',
		'option3Label': '3ª opção',
		'noneLabel': 'N/A'
	}
});

var selectedStringsModel = new SelectedStringsModel();

var TimetableStringsModel = Backbone.Model.extend({
	defaults: {
		'daysLabel': [
			'Segunda',
			'Terça',
			'Quarta',
			'Quinta',
			'Sexta',
			'Sábado'
		]
	}
});

var timetableStringsModel = new TimetableStringsModel();

var SubjectTableStringsModel = Backbone.Model.extend({
	defaults: {
		'subjectCodeLabel': 'Código da disciplina',
		'subjectNameLabel': 'Nome da disciplina',
		'termLabel': 'Período',
		'creditsLabel': 'Nº de créditos',
		'ementaHeaderLabel': 'Ementa',
		'ementaLinkLabel': 'Ver ementa',
		'ementaBaseLink': 'http://www.puc-rio.br/ferramentas/ementas/ementa.aspx?cd=',
		'ongoingStr': 'Cursando',
		'chosenSubjectStr': 'Selecionada'
	}
});

var subjectTableStringsModel = new SubjectTableStringsModel();

var ClassesTableStringsModel = SubjectTableStringsModel.extend({
	defaults: {
		'classCodeLabel': 'Código da turma',
		'professorNameLabel': 'Professor',
		'scheduleLabel': 'Horários',
		'daysAbbr': [
			'Seg',
			'Ter',
			'Qua',
			'Qui',
			'Sex',
			'Sab'
		]
	}
});
//Based on http://stackoverflow.com/questions/6549149/extending-the-defaults-of-a-model-superclass-in-backbone-js
_.extend(ClassesTableStringsModel.prototype.defaults, 
		SubjectTableStringsModel.prototype.defaults);

var classesTableStringsModel = new ClassesTableStringsModel();
