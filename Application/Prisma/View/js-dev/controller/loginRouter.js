var LoginRouter = Backbone.Router.extend({
	routes: {
		'': 'login',
		'*span': 'other'
	},

	loadPage: function(error) {
		layoutView.setView(loginView);
		layoutView.loggedIn=false;
		layoutView.render();		
	
		loginView.render(error);
	}
});

var loginRouter = new LoginRouter();

loginRouter.on('route:other', function() {
	this.navigate('', {trigger: true});
});

loginRouter.on('route:login', function() {
	var arr = document.URL.split('?');
	var error=false;	

	if (arr.length>1)
		error = arr[1].split('#')[0];
	this.loadPage(error);
});

//if (history.pushState) { 
//	console.log("pushState supported");
//	Backbone.history.start({pushState: true});
//}
//else {
//	console.log("pushState NOT supported");
	Backbone.history.start();
//}
