var LoginView = Backbone.View.extend({
	el: 'body',
	layoutTemplate: '',
	loginTemplate: '',

	initialize: function() {
		this.layoutTemplate = _.template($('#layout-template').html());
		this.loginTemplate = _.template($('#login-template').html());
	},

	render: function() {
		this.$el.html(this.layoutTemplate);
		$('#content-div').html(this.loginTemplate({str: loginStringsModel}));
	}
});

var loginView = new LoginView();
