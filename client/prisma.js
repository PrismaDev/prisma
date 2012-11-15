var LoginView = Backbone.View.extend({
	el: 'body',
	render: function() {
		this.$el.html('!CONTENT SHOULD SHOW HERE!');
	}
});

var loginView = new LoginView();
var Router = Backbone.Router.extend({
	routes: {
		'': 'login'
	}
});

var router = new Router();
router.on('route:login', function() {
	loginView.render();
});

Backbone.history.start();
