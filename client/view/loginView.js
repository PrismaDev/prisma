var LoginView = Backbone.View.extend({
	el: 'body',
	render: function() {
		var template = _.template($("#login-template").html(),
				{str: loginStringsModel});
		this.$el.html(template);
	}
});

var loginView = new LoginView();
