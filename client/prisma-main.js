var MainView = Backbone.View.extend({
	el: 'body',
	render: function() {
		var template = _.template($("#main-template").html());
		this.$el.html(template);
	}
});

var mainView = new MainView();
var Router = Backbone.Router.extend({
	routes: {
		'': 'index',
		'login': 'login',
		':mat/term': 'term',
		':mat/main': 'main'
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

router.on('route:main', function() {
	mainView.render();
});

if (history.pushState) { 
	console.log("pushState supported");
	Backbone.history.start({pushState: true});
}
else {
	console.log("pushState NOT supported");
	Backbone.history.start();
}
