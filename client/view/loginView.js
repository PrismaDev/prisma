var LoginView = Backbone.View.extend({
	el: 'body',
	render: function() {
		var template = _.template($("#login-template").html(),
			{matriculaStr: 'Matricula:', senhaStr: 'Senha:',
				submitStr: 'Log in'},
			{variable: 'str'});
		this.$el.html(template);
	}
});

var loginView = new LoginView();
