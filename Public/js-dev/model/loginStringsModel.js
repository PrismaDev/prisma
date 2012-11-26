var LoginStringsModel = Backbone.Model.extend({
	defaults: {
		'matriculaLabel': 'Matrícula',
		'passwordLabel': 'Senha',
		'submitButtonLabel': 'Login'
	}
});

var loginStringsModel = new LoginStringsModel();
