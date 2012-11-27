var LoginRouter = Backbone.Router.extend({
	routes: {
		'': 'login'
	}
});

var loginRouter = new LoginRouter();
loginRouter.on('route:login', function() {
	loginView.render();
});

//if (history.pushState) { 
//	console.log("pushState supported");
//	Backbone.history.start({pushState: true});
//}
//else {
//	console.log("pushState NOT supported");
	Backbone.history.start();
//}
