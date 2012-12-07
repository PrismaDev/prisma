var MainRouter = Backbone.Router.extend({
	routes: {
		'': 'main',
		':tab': 'tabs'
	},

	loadPage: function() {
		subjectList.add(DATA_VIEW.Dependencia);
		faltacursarModel.set(DATA_VIEW.FaltaCursar);
		mainView.render();
	}
});

var mainRouter = new MainRouter();

mainRouter.on('route:main', function() {
	this.loadPage();
	mainRouter.navigate(mainView.defaultTab,
		{trigger: true});
});

mainRouter.on('route:tabs', function(tab) {
	if (!mainView.tabs[tab])
		return mainRouter.navigate(mainView.defaultTab,
			{trigger: true, replace: true});
	
	if (!mainView.rendered)
		this.loadPage();
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
