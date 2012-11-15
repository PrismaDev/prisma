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
