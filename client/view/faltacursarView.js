var FaltacursarView = Backbone.View.extend({
	template: '',

	initialize: function() {
		this.template = _.template($('#faltacursar-template').html());
	},

	events: {
		"click #faltacursar-table tr": 'clickOnRow'
	},

	clickOnRow: function(e) {
		var row=$(e.target).parent('tr');

		if ($(row).hasClass('row_selected')) {
			$(row).removeClass('row_selected');
        		$('#faltacursar-classesList').addClass('hidden');
		}
		else {
			$('#faltacursar-table tr.row_selected').removeClass('row_selected');
			$(row).addClass('row_selected');
        		$('#faltacursar-classesList').removeClass('hidden');

			faltacursarClasseslistView.render([]);
		}
	},

	initJS: function() {
		var subjectTable = $('#faltacursar-table').dataTable({
			'bPaginate': false
		});
	},		

	fetchStrings: function() {
		return {codeStr: 'Codigo', nameStr: 'Nome da Disciplina',
			moreInfoStr: 'Ementa', termStr: 'Periodo'};
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
			this.fetchSubjects());
		return data;
	},

	render: function() {
		this.$el.html(this.template(this.fetchData()));
		this.initJS();
	
		faltacursarClasseslistView.setElement('#faltacursar-classesList');
	}
});

var faltacursarView = new FaltacursarView();
