var TermView = Backbone.View.extend({
	el: 'body',
	layoutTemplate: '',
	termTemplate: '',

	events: {
		'click input[type="submit"]': 'checkAcceptance',
		'change input[type="checkbox"]': 'toggleContinueButton'
	},

	checkAcceptance: function() {
		if ($('input[type="checkbox"]').is(':checked'))
			return true;
		return false;
	},

	toggleContinueButton: function() {
		if ($('input[type="checkbox"]').is(':checked'))
			$('input[type="submit"]').removeClass('disabled');
		else
			$('input[type="submit"]').addClass('disabled');	
	},

	initialize: function() {
		this.layoutTemplate = _.template($("#layout-template").html());
		this.termTemplate = _.template($("#term-template").html());
	},

	render: function() {
		this.$el.html(this.layoutTemplate({
			layoutStr: layoutStringsModel,
			loggedIn: true
		}));

		$('#content-div').html(this.termTemplate({
			termStr: termStringsModel
		}));
	}
});

var termView = new TermView();
