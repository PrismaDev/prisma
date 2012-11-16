var MainView = Backbone.View.extend({
	el: 'body',
	render: function() {
		var template = _.template($("#main-template").html());
		this.$el.html(template);
	}
});

var mainView = new MainView();
