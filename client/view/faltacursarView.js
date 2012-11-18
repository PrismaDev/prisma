var FaltacursarView = Backbone.View.extend({
	el: '#faltacursar-div',

	initJS: function() {
		var subjectTable = $('#faltacursar-table').dataTable({
			'bPaginate': false,
		});

		$("#faltacursar-table tbody tr").click(function(e) {
			if ($(this).hasClass('row_selected')) {
				$(this).removeClass('row_selected');
        			$('#faltacursar-classesList').addClass('hiddenDiv');
			}
			else {
				subjectTable.$('tr.row_selected').removeClass('row_selected');
				$(this).addClass('row_selected');
        			$('#faltacursar-classesList').removeClass('hiddenDiv');
			}
		});
	},		

	fetchStrings: function() {
		return {codeStr: 'Codigo', nameStr: 'Nome da Disciplina',
			moreInfoStr: 'Ementa', termStr: 'Periodo',
			noSubjectsStr: 'Nao ha disciplinas para a busca'};
	},

	fetchSubjects: function() {
		return {subjects: [
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'}
		]};
	},

	fetchData: function() {
		var data = $.extend({}, this.fetchStrings(),
			this.fetchSubjects(),
			{classesListTemplate: _.template($('#classeslist-template').html(),
				{tableid: 'faltacursar-classes-table'})});
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
