var ClasseslistView = Backbone.View.extend({
	template: '',
	el: '',
	subjectInfo: '',

	//Cached
	classesDatatable: '',
	classesTableHead: '',
	classesTableBody: '',

	events: {
		'click .dataTables_scrollBody tr': 'clickOnClass'
	},

	clickOnClass: function(e) {
		var row = $(e.target).parent('tr');

		if ($(row).hasClass('chosen')) {
			$(row).removeClass('chosen');
		}
		else {
			$(row).addClass('chosen');
		}
	},

	cache: function() {
		this.classesTableHead = this.$('.dataTables_scrollHead');
		this.classesTableBody = this.$('.dataTables_scrollBody');
	},

	resize: function() {
		this.classesDatatable.fnDraw(false);
	},

	calculateTableScroll: function() {},

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
				me.calculateTableScroll();
			}
		});
	},

	render: function(classesArray) {
		this.$el.html(this.template({
			classes: classesArray,
			classesTableStr: classesTableStringsModel,
			subjectInfo: this.subjectInfo
		}));	

		this.initJS();
		this.cache();
		this.calculateTableScroll();
	}
});

var MicrohorarioClasseslistView = ClasseslistView.extend({
	subjectInfo: true,

	calculateTableScroll: function() {
		var h=0;
		if (!$('#microhorario-filter').hasClass('hidden'))
			h+=$('#microhorario-filter').outerHeight(true);
		h+=$('#microhorario-togglefilter').outerHeight(true);
	
		var diff = $(this.el).outerHeight(true)-$(this.el).height();
		var totH = $(this.el).parent().height()-h-diff;
	
		$(this.el).height(totH);
		var headH = $(this.classesTableHead).outerHeight();
		$(this.classesTableBody).height(totH-headH);
	}
});
var microhorarioClasseslistView = new MicrohorarioClasseslistView({sDom: 't'});

var FaltacursarClasseslistView = ClasseslistView.extend({
	subjectInfo: false,

	calculateTableScroll: function() {
		var h = this.$el.height();
		var headerH= this.$el.find('.dataTables_filter').outerHeight(true)+
			$(this.classesTableHead).outerHeight(true);
		var diff = $(this.classesTableBody).outerHeight(true)-
			$(this.classesTableBody).height();

		$(this.classesTableBody).height(h-headerH-diff);
	},
});
var faltacursarClasseslistView = new FaltacursarClasseslistView({sDom: 'ft'});
