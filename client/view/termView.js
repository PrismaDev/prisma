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
