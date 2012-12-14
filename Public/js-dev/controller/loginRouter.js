var LoginRouter = Backbone.Router.extend({
	routes: {
		'': 'login',
		'*span': 'other'
	}
});

var loginRouter = new LoginRouter();

loginRouter.on('route:other', function() {
	this.navigate('', {trigger: true});
});

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
