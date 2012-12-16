var LoginView = Backbone.View.extend({
	el: '',
	template: '',

	events: {
		'click #open-login-button': 'openLogin',
		'click #open-tutorial-button': 'openTutorial'
	},

	openTutorial: function() {
		layoutView.openTutorialDialog();
	},

	openLogin: function() {
		$('#open-login-button-container').addClass('hidden');
		$('#login-form-container').removeClass('hidden');
	},

	initialize: function() {
		this.template = _.template($('#login-template').html());
	},

	render: function(error) {
		if (error==undefined)
			error=false;
		console.log(error);

		this.$el.html(this.template({
			loginStr: loginStringsModel,
			layoutStr: layoutStringsModel,
			error: error
		}));
	}
});

var loginView = new LoginView();
