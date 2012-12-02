var FaltacursarView = Backbone.View.extend({
	template: '',
	subjectDatatableView: '',

	//Cached variables
	subjectTableWrapper: '',
	classesDiv: '',
	subjectTable: '',
	subjectDatatable: '',
	subjectTableFilter: '',
	subjectTableHeader: '',	
	subjectTableBody: '',	

	testArray: [
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'}
	],


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
		this.subjectTableFilter = $('#faltacursar-subject-table_wrapper\
					 .dataTables_filter');
		this.subjectTableHeader = $('#faltacursar-subject-table_wrapper\
					 .dataTables_scrollHead');
		this.subjectTableBody = $('#faltacursar-subject-table_wrapper\
					 .dataTables_scrollBody');
	},

	clickOnRow: function(e) {
		var row=$(e.target).parent('tr');

		if ($(row).hasClass('row_selected')) {
			$(row).removeClass('row_selected');
        		
			$(this.subjectTableWrapper).addClass('whole')
						.removeClass('half');
			this.calculateTableScroll();		
			$(this.classesDiv).addClass('hidden');
		}
		else {
			$(this.subjectTable).find('tr.row_selected')
				.removeClass('row_selected');
			$(row).addClass('row_selected');
			
			$(this.subjectTableWrapper).addClass('half')
						.removeClass('whole');
			this.calculateTableScroll();		

        		$(this.classesDiv).removeClass('hidden');
			$(this.classesDiv).addClass('almostHalf');				

			faltacursarClasseslistView.resizeH();
			faltacursarClasseslistView.resizeW();
		}
	},

	calculateTableScroll: function() {
		var h = $(this.subjectTableWrapper).height();				
		var headerH = $(this.subjectTableFilter).outerHeight(true)+
			$(this.subjectTableHeader).outerHeight(true);

		var notHeight = $(this.subjectTableBody).outerHeight(true)-
			$(this.subjectTableBody).height();
		$(this.subjectTableBody).height(h-headerH-notHeight);
	},

	resizeW: function() {
		this.subjectDatatable.fnAdjustColumnSizing(false);
		this.calculateTableScroll();
		faltacursarClasseslistView.resizeW();
	},

	resizeH: function() {
		this.calculateTableScroll();
		faltacursarClasseslistView.resizeH();
	},

	initJS: function() {
		var me = this;

		this.subjectDatatable = $('#faltacursar-subject-table').dataTable({
			'sDom': 'ft',
			'bPaginate': false,
			'bScrollCollapse': true,
			'sScrollY': '200px',
			'fnDrawCallback': function(oSettings) {
				me.calculateTableScroll()
			}
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
		faltacursarClasseslistView.render(this.testArray);

		this.resizeH();
		this.resizeW();
	}
});

var faltacursarView = new FaltacursarView();
