var TermView = Backbone.View.extend({
	el: 'body',
	render: function() {
		var template = _.template($("#term-template").html(),
			{termText: "Testing text area; texttexttextetxtetxtetxtet",
				acceptTermStr: "I accept the terms of ...",
				acceptButtonStr: "Accept and continue",
				backButtonStr: "Back to login"},
			{variable: 'str'});
		this.$el.html(template);
	}
});

var termView = new TermView();
var Router = Backbone.Router.extend({
	routes: {
		'': 'login',
		'term': 'term'
	}
});

var router = new Router();
router.on('route:login', function() {
	loginView.render();
});

router.on('route:term', function() {
	termView.render();
});

Backbone.history.start();
