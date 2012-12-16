var DialogView = Backbone.View.extend({
	el: '',
	template: '',	
	args: '',
	templateId: '',
	
	initialize: function() {
		this.template = _.template($(this.templateId).html());
	},

	initJS: function() {
		this.$el.modal();
	},

	render: function() {
		this.$el.html(this.template(this.args));
		this.initJS();
	}
});


