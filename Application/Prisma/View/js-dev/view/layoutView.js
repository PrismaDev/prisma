LayoutView = Backbone.View.extend({
	el: 'body',
	template: '',
	contentView: null,
	loggedIn: false,
	dialogDiv: '#dialog-div',

	events: {
		'click #open-suggestions-link': 'openSuggestionDialog',
		'click #open-faq-link': 'openFAQDialog',
		'click #open-tutorial-link': 'openTutorialDialog',
		'click #open-updates-link': 'openUpdatesDialog',
		'click ul div.dropdown-menu': 'preventClose'
	},

	openSuggestionDialog: function() {
		suggestionsView.render();
		$(this.dialogDiv).modal('show');
	},

	openFAQDialog: function() {
		faqView.render();
		$(this.dialogDiv).modal('show');
	},

	openTutorialDialog: function() {
		tutorialView.render();
		$(this.dialogDiv).modal('show');
	},

	openUpdatesDialog: function() {
		updatesView.render();
		updatesView.initTwitter();
		$(this.dialogDiv).modal('show');
	},

	preventClose: function(e) {
		e.stopPropagation();
	},

	initialize: function() {
		this.template = _.template($('#layout-template').html());
	},

	initJS: function() {
		$('.dropdown-toggle').dropdown();
		fbApiController.loadApi();
	},

	setView: function(view) {
		this.contentView=view;
	},

	prepareDialogs: function() {
		if (this.loggedIn) {
			suggestionsView.setElement(this.dialogDiv);
			updatesView.setElement(this.dialogDiv);
		}
		
		faqView.setElement(this.dialogDiv);
		tutorialView.setElement(this.dialogDiv);
	},
	
	render: function() {
		var args = {
			layoutStr: layoutStringsModel,
			loggedIn: this.loggedIn
		};

		if (!this.loggedIn)
			args={
				layoutStr: layoutStringsModel,
				loggedIn: this.loggedIn,
				loginStr: loginStringsModel
			};

		this.$el.html(this.template(args));	
		this.prepareDialogs();
		this.initJS();
	
		if (this.contentView) 
			this.contentView.setElement('#content-div');
	}
});

var layoutView = new LayoutView();
