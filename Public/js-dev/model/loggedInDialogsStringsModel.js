var SuggestionsStringsModel = Backbone.Model.extend({
	defaults: {
		'dialogTitle': 'Sugestões/Bugs/Comentários...',
		'submitButtonLabel': 'Enviar comentário',
		'resetButtonLabel': 'Limpar campo'
	}
});

var suggestionsStringsModel = new SuggestionsStringsModel();
