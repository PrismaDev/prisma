var TermRouter = Backbone.Router.extend({
	routes: {
		'': 'term'
	}
});

var termRouter = new TermRouter();
termRouter.on('route:term', function() {
	termView.render();
});

//if (history.pushState) { 
//	console.log("pushState supported");
//	Backbone.history.start({pushState: true});
//}
//else {
//	console.log("pushState NOT supported");
	Backbone.history.start();
//}
