var TermRouter = Backbone.Router.extend({
	routes: {
		'': 'term'
	},

	loadPage: function() {
		layoutStringsModel.set('userName',DATA_VIEW.NomeAluno);
	
		layoutView.setView(termView);
		layoutView.loggedIn=true;
		layoutView.render();		

		termView.render();
	}
});

var termRouter = new TermRouter();
termRouter.on('route:term', function() {
	this.loadPage();
});

//if (history.pushState) { 
//	console.log("pushState supported");
//	Backbone.history.start({pushState: true});
//}
//else {
//	console.log("pushState NOT supported");
	Backbone.history.start();
//}
