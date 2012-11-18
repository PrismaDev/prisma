var MicrohorarioView = Backbone.View.extend ({
	el: '#microhorario',
	
	

	renderQuery: function(qstatus, classeslist) {

	},

	returnTemplate: function() {
		var template = _.template($('#microhorario-template').html(),
			{});
		return template;
	},

	render: function() {
		this.$el.html(this.returnTemplate());
	}
});

var microhorarioView = new MicrohorarioView();
