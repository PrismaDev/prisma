var MainRouter = Backbone.Router.extend({
	routes: {
		'': 'main',
		':tab': 'tabs'
	}
});

var mainRouter = new MainRouter();

mainRouter.on('route:main', function() {
	mainView.render();
	mainRouter.navigate(mainView.defaultTab,
		{trigger: true});
});

mainRouter.on('route:tabs', function(tab) {
	if (!mainView.tabs[tab])
		return mainRouter.navigate(mainView.defaultTab,
			{trigger: true, replace: true});
	
	if (!mainView.rendered)
		mainView.render();
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
