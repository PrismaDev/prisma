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
		'': 'index',
		'login': 'login',
		':mat/term': 'term'
	}
});

var router = new Router();
router.on('route:index', function() {
	router.navigate('login', {trigger: true});
});

router.on('route:login', function() {
	loginView.render();
});

router.on('route:term', function() {
	termView.render();
});

if (history.pushState) { 
	console.log("pushState supported");
	Backbone.history.start({pushState: true, root: '/~royalsflush/prismaV2/src/'});
}
else {
	console.log("pushState NOT supported");
	Backbone.history.start();
}
