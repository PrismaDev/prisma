var TermView = Backbone.View.extend({
	el: '',
	template: '',

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
		this.template = _.template($("#term-template").html());
	},

	render: function() {
		this.$el.html(this.template({
			termStr: termStringsModel
		}));
	}
});

var termView = new TermView();
