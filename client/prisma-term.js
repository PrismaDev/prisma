var TermView = Backbone.View.extend({
	el: 'body',
	render: function() {
		var template = _.template($("#term-template").html(),
			{termText: "Testing text area; texttexttextetxtetxtetxtet",
				acceptTermStr: "I accept the terms of ...",
				acceptButtonStr: "Accept and continue",
				backButtonStr: "Back to login"});
		this.$el.html(template);
	}
});

var termView = new TermView();
var Router = Backbone.Router.extend({
	routes: {
		'': 'index',
		'login': 'login',
		'term': 'term',
		'main':'main',
		'main/:tab': 'tabs'
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
	router.navigate('main/'+mainView.defaultTab,
		{trigger: true});
});

router.on('route:tabs', function(tab) {
	if (!mainView.rendered)
		mainView.render();

	if (!mainView.tabs[tab])
		return router.navigate('main/'+mainView.defaultTab,
			{trigger: true, replace: true});
	
	mainView.setActiveTab(tab);
});

//if (history.pushState) { 
//	console.log("pushState supported");
//	Backbone.history.start({pushState: true});
//}
//else {
//	console.log("pushState NOT supported");
	Backbone.history.start();
//}
