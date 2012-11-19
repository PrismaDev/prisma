var MicrohorarioView = Backbone.View.extend ({
	template: '',

	//status constants
	noQueryStatus: 'noQuery',
	queryStatus: 'query',
	waitingStatus: 'waiting',

	waitingImgURL: 'http://i.stack.imgur.com/FhHRx.gif',

	initialize: function() {
		this.template = _.template($('#microhorario-template').html());
	},

	events: {
		"click #moreFiltersButton": "openFilters",
		"click #lessFiltersButton": "closeFilters"
	},

	//Event handlers
	openFilters: function() {
		alert('hihi');
		$('#hiddenFilters').removeClass('hidden');
		$('#moreFiltersButton').addClass('hidden');
	},
	
	closeFilters: function() {
		$('#hiddenFilters').addClass('hidden');
		$('#moreFiltersButton').removeClass('hidden');
	},

	//Methods
	fetchConstants: function() {
		return {noQuery: this.noQueryStatus,
			query: this.queryStatus,
			waiting: this.waitingStatus,
			waitingImg: this.waitingImgURL};
	},

	fetchStrings: function() {
		return {noQueryStr: 'No query',
			subjectCodeStr: 'Codigo da Disciplina:',
			subjectNameStr: 'Nome da Disciplina:',
			professorNameStr: 'Nome do Professor:',
			toggleBlocked: 'Exibir disciplinas bloqueadas',
			moreFiltersStr: 'More filters',
			lessFiltersStr: 'Less filters'		
		};
	},

	fetchData: function(queryResults, qStatus) {
		if (qStatus==this.queryStatus)
			var classeslist = _.template($('#classeslist-template').html(),
				{classesList: queryResults, tableid: 'microhorario-results-table'});

		return $.extend({}, this.fetchStrings(),
			this.fetchConstants(), {qStatus: qStatus,
			classesListTemplate: classeslist});
	},

	render: function(queryResults, qStatus) {
		this.$el.html(this.template(
			this.fetchData(queryResults, qStatus)));
	}
});

var microhorarioView = new MicrohorarioView();
