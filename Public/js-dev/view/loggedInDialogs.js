var SuggestionsView = DialogView.extend({
	templateId: '#suggestions-template',
	args: {
		suggestionsStr: suggestionsStringsModel
	},

	suggestionsUrl: '/api/sugestao',
	
	events: {
		'submit #suggestions-form': 'sendSuggestion'
	},

	sendSuggestion: function() {
		$.ajax({
			url: this.suggestionsUrl,
			type: 'POST',
			data: $('#suggestions-form').serialize(),

			success: function() {
				$('#dialogDiv').modal('hide');
			}
		});

		return false;	
	}
});

var suggestionsView = new SuggestionsView();
