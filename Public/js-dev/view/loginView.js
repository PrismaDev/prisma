var LoginView = Backbone.View.extend({
	el: 'body',
	layoutTemplate: '',
	loginTemplate: '',

	initialize: function() {
		this.layoutTemplate = _.template($('#layout-template').html());
		this.loginTemplate = _.template($('#login-template').html());
	},

	initJS: function() {
		$('.dropdown-toggle').dropdown();
		$('ul div.dropdown-menu').click(function(e) {
			e.stopPropagation();
		});
	},
	
	render: function() {
		this.$el.html(this.layoutTemplate({
				loginStr: loginStringsModel,
				layoutStr: layoutStringsModel,
				loggedIn: false
		}));
		$('#content-div').html(this.loginTemplate({
			loginStr: loginStringsModel,
			layoutStr: layoutStringsModel
		}));
		
		this.initJS();
	}
});

var loginView = new LoginView();
