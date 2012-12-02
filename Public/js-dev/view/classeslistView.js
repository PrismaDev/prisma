var ClasseslistView = Backbone.View.extend({
	template: '',

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
		this.resizeH = this.options.resizeH;
	},

	initJS: function() {		
		this.classesDatatable = this.$el.find('table').dataTable({
			'sDom': this.options.sDom,
			'bPaginate': false,
			'bScrollCollapse': true,
			'sScrollY': '200px'	
		});
	},

	render: function(classesArray) {
		this.$el.html(this.template(classesArray));	
		this.initJS();
		this.cache();
	}
});

var microhorarioClasseslistView = new ClasseslistView({
	sDom: 't',
	resizeH: function() {
		var h=0;
		this.$el.siblings(':not(.hidden)').each(function(index) {
			h+=$(this).outerHeight();
		});

		var diff = this.$el.outerHeight()-this.$el.height();
		var totH = this.$el.parent()-h-diff;
		
		this.$el.height(totH);
		var headH = $(this.classesTableHead).outerHeight();
		$(this.classesTableBody).height(totH-headH);
	}
});
var faltacursarClasseslistView = new ClasseslistView({
	sDom: 'ft',
	resizeH: function() {
	}
});
