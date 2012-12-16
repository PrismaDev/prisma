LayoutView = Backbone.View.extend({
	el: 'body',
	template: '',
	contentView: null,
	loggedIn: false,
	dialogDiv: '#dialogDiv',

	events: {
		'click #open-suggestions-link': 'openSuggestionDialog',
		'click ul div.dropdown-menu': 'preventClose'
	},

	openSuggestionDialog: function() {
		suggestionsView.render();
		$('#dialogDiv').modal('show');
	},

	preventClose: function(e) {
		e.stopPropagation();
	},

	initialize: function() {
		this.template = _.template($('#layout-template').html());
	},

	initJS: function() {
		$('.dropdown-toggle').dropdown();
	},

	setView: function(view) {
		this.contentView=view;
	},

	prepareDialogs: function() {
		if (this.loggedIn) {
			suggestionsView.setElement(this.dialogDiv);
		}
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
