var ClasseslistView = Backbone.View.extend({
	template: '',
	el: '',

	//Cached
	classesDatatable: '',
	classesTableHead: '',
	classesTableBody: '',

	cache: function() {
		this.classesTableHead = this.$('.dataTables_scrollHead');
		console.log(this.classesTableHead);
		this.classesTableBody = this.$('.dataTables_scrollBody');
		console.log(this.classesTableBody);
	},

	resizeW: function() {
		this.classesDatatable.fnAdjustColumnSizing(false);
	},

	resizeH: function() {},

	initialize: function() {
		this.template = _.template($('#classeslist-template').html());
	},

	initJS: function() {		
		var me = this;

		this.classesDatatable = this.$el.find('table').dataTable({			
			'sDom': this.options.sDom,
			'bPaginate': false,
			'bScrollCollapse': true,
			'sScrollY': '100px',
			'fnDrawCallback': function(oSettings) {
				me.resizeH();
				console.log('Redraw - '+
					$(me.classesTableBody).height());	
			}
			
		});
	},

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
	}
});
var microhorarioClasseslistView = new MicrohorarioClasseslistView({sDom: 't'});

var FaltacursarClasseslistView = ClasseslistView.extend({
	datatableFilter: '',	
	
	resizeH: function() {
		var h = this.$el.height();
		var headerH= this.$el.find('.dataTables_filter').outerHeight(true)+
			$(this.classesTableHead).outerHeight(true);
		var diff = $(this.classesTableBody).outerHeight(true)-
			$(this.classesTableBody).height();

		$(this.classesTableBody).height(h-headerH-diff);
		console.log($(this.classesTableBody))
	},
});
var faltacursarClasseslistView = new FaltacursarClasseslistView({sDom: 'ft'});
