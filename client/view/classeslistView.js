var ClasseslistView = Backbone.View.extend({
	template: '',

	initialize: function() {
		this.template = _.template($('#classeslist-template').html());
	},

	initJS: function() {
		this.$el.find('table').dataTable({
			'bPaginate': false
		});
	},

	render: function(classesArray) {
		this.$el.html(this.template(classesArray));	
	}
});

var microhorarioClasseslistView = new ClasseslistView();
var faltacursarClasseslistView = new ClasseslistView();
