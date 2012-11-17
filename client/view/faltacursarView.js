var FaltacursarView = Backbone.View.extend({
	el: '#faltacursar-div',

	initJS: function() {
		$('#faltacursar-table').dataTable();
	},

	fetchStrings: function() {
		return {codeStr: 'Codigo', nameStr: 'Nome da Disciplina',
			moreInfoStr: 'Ementa', termStr: 'Periodo',
			noSubjectsStr: 'Nao ha disciplinas para a busca'};
	},

	fetchSubjects: function() {
		return {subjects: []};
	},

	fetchData: function() {
		var data = $.extend({}, this.fetchStrings(),
			this.fetchSubjects());
		return data;
	},

	returnTemplate: function() {
		var template = _.template($('#faltacursar-template').html(),
			this.fetchData());
		return template;
	},

	render: function() {
		this.$el.html(returnTemplate());
	}
});

var faltacursarView = new FaltacursarView();
