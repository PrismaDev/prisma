var LoginView = Backbone.View.extend({
	el: 'body',
	layoutTemplate: '',
	loginTemplate: '',

	events: {
		'click ul div.dropdown-menu': 'preventClose',
		'click #open-login-button': 'openLogin' 
	},

	preventClose: function(e) {
		e.stopPropagation();
	},

	openLogin: function() {
		$('#open-login-button-container').addClass('hidden');
		$('#login-form-container').removeClass('hidden');
	},

	initialize: function() {
		this.layoutTemplate = _.template($('#layout-template').html());
		this.loginTemplate = _.template($('#login-template').html());
	},

	initJS: function() {
		$('.dropdown-toggle').dropdown();
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
