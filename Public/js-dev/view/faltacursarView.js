var FaltacursarView = Backbone.View.extend({
	template: '',
	subjectDatatableView: '',

	//Cached variables
	subjectTableWrapper: '',
	classesDiv: '',
	subjectTable: '',
	subjectDatatable: '',
	
	initialize: function() {
		this.template = _.template($('#faltacursar-template').html());
	},

	events: {
		"click #faltacursar-subject-table tr": 'clickOnRow'
	},

	cache: function() {
		this.subjectTableWrapper = $('#faltacursar-subject-table_wrapper');
		this.classesDiv = $('#faltacursar-classes-div');
		this.subjectTable = $('#faltacursar-subject-table');
	},

	clickOnRow: function(e) {
		var row=$(e.target).parent('tr');

		if ($(row).hasClass('row_selected')) {
			$(row).removeClass('row_selected');
        		
			$(this.subjectTableWrapper).addClass('whole')
						.removeClass('half');
		
			$(this.classesDiv).addClass('hidden');
		}
		else {
			$(this.subjectTable).find('tr.row_selected')
				.removeClass('row_selected');
			$(row).addClass('row_selected');
			
			$(this.subjectTableWrapper).addClass('half')
						.removeClass('whole');
		
        		$(this.classesDiv).removeClass('hidden');
			$(this.classesDiv).addClass('almostHalf');	
			faltacursarClasseslistView.resizeH();			
		}
	},

	calculateTableScroll: function() {
		
	},

	resizeW: function() {
		this.subjectDatatable.fnAdjustColumnSizing(false);
		this.calculateTableScroll();
		faltacursarClasseslistView.resizeW();
	},
	resizeH: function() {},

	initJS: function() {
		this.subjectDatatable = $('#faltacursar-subject-table').dataTable({
			'sDom': 'ft',
			'bPaginate': false,
			'bScrollCollapse': true,
			'sScrollY': '200px'	
		});
		
		$('#faltacursar-subject-table_wrapper').addClass('whole');
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

		this.cache();
		faltacursarClasseslistView.setElement('#faltacursar-classes-div');
		faltacursarClasseslistView.render([]);
	}
});

var faltacursarView = new FaltacursarView();
