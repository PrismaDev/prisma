var LayoutStringsModel = Backbone.Model.extend({
	defaults: {
		'hiStr': 'Olá',
		'loginStr': 'Login',
		'logoutStr': 'Logout',
		'commentsStr': 'Sugestões',
		'updatesStr': 'Updates',
		'FAQStr': 'FAQ',
		'tutorialStr': 'Vídeo-tutorial',
		'codTutorialYoutube': 'XHF8WOJ6xI0',
		'projectNameStr': 'PrISMA',
		'userName': 'Bobteco da Silva',
		'footerText': 'Esse projeto é uma colaboração dos alunos\
			Julio Ribeiro, Luiza Silva, Gabriel Martinelli,\
			André Marçal, Denis Neves, Glauber Borges e\
			Maurício Fragale com o professor Sérgio Lifschitz. \
			Contato: prisma@inf.puc-rio.br',
		'twitter': 'PrISMAPUCRio',
		'twitterId': '352202307385036800'
	}
});

var layoutStringsModel = new LayoutStringsModel();
