var FaltacursarView = Backbone.View.extend({
	template: '',

	initialize: function() {
		this.template = _.template($('#faltacursar-template').html());
	},

	initJS: function() {
		var subjectTable = $('#faltacursar-table').dataTable({
			'bPaginate': false,
		});

		$("#faltacursar-table tbody tr").click(function(e) {
			if ($(this).hasClass('row_selected')) {
				$(this).removeClass('row_selected');
        			$('#faltacursar-classesList').addClass('hidden');
			}
			else {
				subjectTable.$('tr.row_selected').removeClass('row_selected');
				$(this).addClass('row_selected');
        			$('#faltacursar-classesList').removeClass('hidden');
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
			{classesListTemplate: ''});
		return data;
	},

	render: function() {
		this.$el.html(this.template(this.fetchData()));
	}
});

var faltacursarView = new FaltacursarView();
