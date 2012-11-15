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
var Router = Backbone.Router.extend({
	routes: {
		'': 'login',
		'term': 'term'
	}
});

var router = new Router();
router.on('route:login', function() {
	loginView.render();
});

router.on('route:term', function() {
	termView.render();
});

Backbone.history.start();
