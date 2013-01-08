var LoginStringsModel = Backbone.Model.extend({
	defaults: {
		'matriculaLabel': 'Matrícula',
		'matriculaMaxLength': '7',
		'passwordLabel': 'Senha',
		'submitButtonLabel': 'Login',
		'loginHelpText': 'Para logar, use sua matrícula sem o\
			dígito verificador e a mesma senha que você utiliza\
			para o PUC Online',
		'forgotPasswordText': 'Se você esqueceu sua senha, <a href=\
			"http://www.puc-rio.br/ensinopesq/academicas/">clique aqui</a>\
			 para acessar o PUC Online e recuperá-la',
		'infoText': 'O PrISMA, Programa de Instrução à Solicitação da\
			Matrícula Acadêmica, é um sistema desenvolvido por alunos\
			em parceria com o professor Sérgio Lifschitz que tem como\
			objetivo facilitar o preenchimento da primeira fase da\
			matrícula',
		'openLoginButtonLabel': 'Fazer login',
		'tutorialButtonLabel': 'Tutorial',
		'invalidLoginErrorMsg': 'Login e/ou senha inválidos!',
		'accessDeniedErrorMsg': 'Você precisa se logar para acessar essa página',
		'pageDoesNotExistErrorMsg': 'A página que você está acessando não existe no nosso sistema',
		'unexpectedErrorMsg': 'O sistema se comportou de forma inesperada - fique tranquilo,\
			recebemos o erro e assim que possível ele será corrigido'
	}
});

var loginStringsModel = new LoginStringsModel();
