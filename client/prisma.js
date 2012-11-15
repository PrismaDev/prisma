var router = Backbone.Router.extend({
	routes: {
		'': 'login'
	}
});

router = new Router();
router.on('route: login'. function() {
	console.log('We have reached the home page');
});
