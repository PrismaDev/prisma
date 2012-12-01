var ClasseslistView = Backbone.View.extend({
	template: '',
	classesDatatable: '',

	resizeW: function() {
		this.classesDatatable.fnAdjustColumnSizing();
	},
	resizeH: function() {},

	initialize: function() {
		this.template = _.template($('#classeslist-template').html());
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
	}
});

var microhorarioClasseslistView = new ClasseslistView({sDom: 't'});
var faltacursarClasseslistView = new ClasseslistView({sDom: 'ft'});
