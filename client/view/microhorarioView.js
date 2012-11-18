var MicrohorarioView = Backbone.View.extend ({
	el: '#microhorario',

	//status constants
	noQueryStatus: 'noQuery',
	queryStatus: 'query',
	waitingStatus: 'waiting',

	waitingImgURL: 'http://i.stack.imgur.com/FhHRx.gif',

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
			toggleBlocked: 'Exibir disciplinas bloqueadas'};
	},

	fetchData: function(queryResults, qStatus) {
		if (qStatus==this.queryStatus)
			var classeslist = _.template($('#classeslist-template').html(),
				{classesList: queryResults, tableid: 'microhorario-results-table'});

		return $.extend({}, this.fetchStrings(),
			this.fetchConstants(), {qStatus: qStatus,
			classesListTemplate: classeslist});
	},

	returnTemplate: function(queryResults, qStatus) {
		var template = _.template($('#microhorario-template').html(),
			this.fetchData(queryResults,qStatus));
		return template;
	},

	render: function(queryResults, qStatus) {
		this.$el.html(this.returnTemplate(queryResults, qStatus));
	}
});

var microhorarioView = new MicrohorarioView();
