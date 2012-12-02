var ClasseslistView = Backbone.View.extend({
	template: '',
	el: '',

	//Cached
	classesDatatable: '',
	classesTableHead: '',
	classesTableBody: '',

	cache: function() {
		this.classesTableHead = this.$('.dataTables_scrollHead');
		this.classesTableBody = this.$('.dataTables_scrollBody');
	},

	resizeW: function() {
		this.classesDatatable.fnAdjustColumnSizing(false);
	},

	resizeH: '',

	initialize: function() {
		this.template = _.template($('#classeslist-template').html());
	},

	initJS: '',

	fetchStrings: function() {
		return {'subjectCodeLabel': 'Disciplina',
			'subjectNameLabel': 'Nome da disciplina',
			'professorNameLabel': 'Professor',
			'classCodeLabel': 'Turma',
			'scheduleLabel': 'Horarios'};
	},

	fetchData: function(classesArray) {
		return $.extend({}, this.fetchStrings(),
			{'classes': classesArray});
	},
	
	render: function(classesArray) {
		this.$el.html(this.template(
			this.fetchData(classesArray)
		));	
		this.initJS();
		this.cache();
	}
});

var MicrohorarioClasseslistView = ClasseslistView.extend({
	el: '',
	resizeH: function() {
		var h=0;
		$(this.el).siblings(':not(.hidden)').each(function(index) {
			h+=$(this).outerHeight();
		});

		var diff = $(this.el).outerHeight()-$(this.el).height();
		var totH = $(this.el).parent()-h-diff;
		
		$(this.el).height(totH);
		var headH = $(this.classesTableHead).outerHeight();
		$(this.classesTableBody).height(totH-headH);
	},

	 initJS: function() {		
		var me = this;
		this.classesDatatable = this.$el.find('table').dataTable({
			'sDom': 't',
			'bPaginate': false,
			'bScrollCollapse': true,
			'sScrollY': '200px',	
			'fnDrawCallback': me.resizeH
		});
	}
});
var microhorarioClasseslistView = new MicrohorarioClasseslistView();

var FaltacursarClasseslistView = ClasseslistView.extend({
	resizeH: function() {
	},

	 initJS: function() {		
		var me = this;
		this.classesDatatable = this.$el.find('table').dataTable({
			'sDom': 'ft',
			'bPaginate': false,
			'bScrollCollapse': true,
			'sScrollY': '200px',	
			'fnDrawCallback': me.resizeH
		});
	}
});
var faltacursarClasseslistView = new FaltacursarClasseslistView();
