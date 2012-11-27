var ClasseslistView = Backbone.View.extend({
	template: '',
	sDom: 't',

	initialize: function(options) {
		this.template = _.template($('#classeslist-template').html());

		if (this.options.sDom!=undefined)
			this.sDom = this.options.sDom;
	},

	initJS: function() {
		this.$el.find('table').dataTable({
			'bPaginate': false,
			'sDom': this.sDom
		});
	},

	render: function(classesArray) {
		this.$el.html(this.template(classesArray));	
		this.initJS();
	}
});

var microhorarioClasseslistView = new ClasseslistView();
var faltacursarClasseslistView = new ClasseslistView({sDom: 'ft'});
