var FaltacursarView = Backbone.View.extend({
	template: '',

	initialize: function() {
		this.template = _.template($('#faltacursar-template').html());
	},

	events: {
		"click #faltacursar-subject-table tr": 'clickOnRow'
	},

	clickOnRow: function(e) {
		var row=$(e.target).parent('tr');

		if ($(row).hasClass('row_selected')) {
			$(row).removeClass('row_selected');
			this.resizeWhole();
        		
			$('#faltacursar-classes-div').addClass('hidden');
		}
		else {
			$('.table tr.row_selected').removeClass('row_selected');
			$(row).addClass('row_selected');

        		$('#faltacursar-classes-div').removeClass('hidden');
			faltacursarClasseslistView.render([]);
			
			this.resizeFiftyfifty();
		}
	},

	calcTbodySize: function(hei, id) {
		$(id).height(hei);
	},

	resizeFiftyfifty: function() {
		var divH = $('#main-faltacursar-div').height()-1; //compensate 1px border

		this.calcTbodySize(divH/2, '#faltacursar-subject-table_wrapper');
		this.calcTbodySize(divH/2, '#faltacursar-classes-div');
	},

	resizeWhole: function() {
		var divH = $('#main-faltacursar-div').height();
		this.calcTbodySize(divH, '#faltacursar-subject-table_wrapper');
	},

	initJS: function() {
		var subjectTable = $('#faltacursar-subject-table').dataTable({
			'bPaginate': false,
			'sDom': 'ft'
		});
	},		

	fetchStrings: function() {
		return {codeStr: 'Codigo', nameStr: 'Nome da Disciplina',
			moreInfoStr: 'Ementa', termStr: 'Periodo',
			infoStr: 'Ementa'};
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
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'}
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

		faltacursarClasseslistView.setElement('#faltacursar-classes-div');
	}
});

var faltacursarView = new FaltacursarView();
