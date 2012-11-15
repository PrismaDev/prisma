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
