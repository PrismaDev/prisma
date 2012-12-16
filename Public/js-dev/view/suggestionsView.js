var SuggestionsView = Backbone.View.extend({
	el: '',
	template: '',	

	initialize: function() {
		this.template = _.template($('#suggestions-template').html());
	},

	initJS: function() {
		$('#dialogDiv').modal();
	},

	render: function() {
		this.$el.html(this.template({
			suggestionsStr: suggestionsStringsModel
		}));

		this.initJS();
	},
});

var suggestionsView = new SuggestionsView();
