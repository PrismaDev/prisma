var LoginStringsModel = Backbone.Model.extend({
	defaults: {
		'matriculaLabel': 'Matrícula',
		'passwordLabel': 'Senha',
		'submitButtonLabel': 'Login',
		'loginHelpText': 'Para logar, use sua matrícula com sem o\
			dígito verificador e a mesma senha que você utiliza\
			para o PUC Online',
		'forgotPasswordText': 'Se você esqueceu sua senha, <a href=\
			"http://www.puc-rio.br/ensinopesq/academicas/">clique aqui</a>\
			 para acessar o PUC Online e recuperá-la',
		'infoText': 'O PrISMA, Programa de Instrução à Solicitação da\
			Matrícula Acadêmica, é um sistema desenvolvido por alunos\
			em parceria com o professor Sérgio Litschitz que tem como\
			objetivo facilitar o preenchimento da primeira fase da\
			matrícula',
		'openLoginButtonLabel': 'Abre login',
		'tutorialButtonLabel': 'Tutorial - em breve!'
	}
});

var loginStringsModel = new LoginStringsModel();
