var SuggestionsView = DialogView.extend({
	templateId: '#suggestions-template',
	args: {
		suggestionsStr: suggestionsStringsModel
	},

	suggestionsUrl: '/api/sugestao',
	
	events: {
		'submit #suggestions-form': 'sendSuggestion',
		'keypress textarea': 'toggleButton'
	},

	toggleButton: function(e) {
		var el = e.target;

		if(el.value.trim() == '')
			$('#suggestions-form input[type="submit"]').addClass('disabled');
		else
			$('#suggestions-form input[type="submit"]').removeClass('disabled');
	},
	
	sendSuggestion: function() {
		if ($('#suggestions-form input[type="submit"]').hasClass('disabled'))
			return false;		

		$.ajax({
			url: this.suggestionsUrl,
			type: 'POST',
			data: $('#suggestions-form').serialize(),

			success: function() {
				$('#dialog-div').modal('hide');
			}
		});

		return false;	
	}
});

var suggestionsView = new SuggestionsView();

var UpdatesView = DialogView.extend({
	templateId: '#updates-template',
	args: {
		updatesStr: updatesStringsModel,
		layoutStr: layoutStringsModel
	},

	initTwitter: function() {
		twttr.widgets.load();
	}	
});

var updatesView = new UpdatesView();
