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
		console.log(el);

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
				$('#dialogDiv').modal('hide');
			}
		});

		return false;	
	}
});

var suggestionsView = new SuggestionsView();

var UpdatesView = DialogView.extend({
	templateId: '#updates-template',
	args: {
		updatesStr: updatesStringsModel
	},

	initTwitter: function() {
		twttr.widgets.load();
	}	
});

var updatesView = new UpdatesView();
