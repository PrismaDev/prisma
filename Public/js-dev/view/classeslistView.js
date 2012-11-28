var ClasseslistView = Backbone.View.extend({
	template: '',
	datatableView: '',

	initialize: function() {
		this.template = _.template($('#classeslist-template').html());
	},

	initJS: function() {		
		this.datatableView = new DatatableView({
			el: this.$el.find('table'),
			sDom: this.options.sDom
		})
	},

	render: function(classesArray) {
		this.$el.html(this.template(classesArray));	
		this.initJS();
	}
});

var microhorarioClasseslistView = new ClasseslistView({sDom: 't'});
var faltacursarClasseslistView = new ClasseslistView({sDom: 'ft'});
