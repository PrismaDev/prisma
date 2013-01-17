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
		'waitingImgURL': '/img/ajax-loader.gif',
		'endOfDataMsg': 'Os resultados para essa busca terminaram'
	}
});
var microhorarioStringsModel = new MicrohorarioStringsModel();

var SelectedStringsModel = Backbone.Model.extend({
	defaults: {
		'option1Label': '1ª opção',
		'option2Label': '2ª opção',
		'option3Label': '3ª opção',
		'noneLabel': 'N/A',
		'qtdCreditsLabel': ' crédito(s) na grade atual',
		'qtdClassesLabel': ' turma(s) na grade atual'
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

var FaltacursarStringsModel = Backbone.Model.extend({
	defaults: {
		'closeClassesDivLabel': 'Fechar turmas',
		'searchLabel': 'Buscar:'
	}
});

var faltacursarStringsModel = new FaltacursarStringsModel();

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
		'chosenSubjectStr': 'Selecionada',
		'noResultsStr': 'Não há resultados para essa busca',
		'nOptativasChosenStr': 'selecionada(s) desse grupo'
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
		],
		'emptyTableStr': 'Não há turmas a serem exibidas',
		'SHF': 'Sem horário fixo',
		'blockLabel': 'Destinos',
		'placesStr': 'vagas'
	}
});
//Based on http://stackoverflow.com/questions/6549149/extending-the-defaults-of-a-model-superclass-in-backbone-js
_.extend(ClassesTableStringsModel.prototype.defaults, 
		SubjectTableStringsModel.prototype.defaults);

var classesTableStringsModel = new ClassesTableStringsModel();

var MainHelpersStringsModel = Backbone.Model.extend({
	defaults: {
		'tooltipButtonLabel': 'OK!',
		'ableSubjectRowText': 'Clique na linha de uma disciplina para\
			abrir suas turmas',
		'blockedSubjectRowText': 'Você pode visualizar as turmas dessa disciplina, \
			mas o sistema nos diz que você não tem os pré-requisitos necessários \
			para cursá-la. Temporariamente, adicionar uma turma dessa disciplina está \
			habilitado devido a bugs; clique para visualizar as turmas',
		'warningSubjectRowText': 'Uma disciplina em amarelo significa que você ou está \
			cursando-a nesse período (aquelas marcadas com "Cursando") ou necessita ser aprovado em alguma(s) disciplina(s) \
			que você está cursando. Clique para visualizar as turmas',
		'optativaRowText': 'Clique nessa optativa para abrir suas disciplinas; clique novamente para \
			fechá-las',
		'selectedSubjectRowText': 'Essa disciplina está selecionada, o que significa que suas turmas estão listadas \
			abaixo; clique novamente para fechar as turmas',
		'ableClassRowText': 'Clique nessa turma para selecioná-la; ela aparecerá em uma das opções da aba de \
			selecionadas',
		'chosenClassRowText': 'Essa turma já está selecionada, o que significa que ela está ocupando \
			alguma das posições na aba de selecionadas. Clique novamente para deselecioná-la',
		'warningClassRowText': 'Da mesma forma que disciplinas em amarelo, turmas em amarelo ou estão sendo \
			cursadas (estas têm um texto "Cursando" ao lado) ou é necessária a aprovação em alguma \
			matéria que está sendo cursada para que o pedido seja aprovado',
		'disabledClassRowText': 'Turmas em cinza são de disciplinas que você já cursou',
		'blockedClassRowText': 'Turmas marcadas com vermelho são as que você não tem os pré-requisitos \
			para cursar. Temporariamente, devido a bugs, clique na turma para adicioná-la'
	}
});

var mainHelpersStringsModel = new MainHelpersStringsModel();
