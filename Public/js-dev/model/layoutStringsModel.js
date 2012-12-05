var LayoutStringsModel = Backbone.Model.extend({
	defaults: {
		'hiStr': 'Olá',
		'loginStr': 'Login',
		'logoutStr': 'Logout',
		'projectNameStr': 'PrISMA',
		'userName': 'Bobteco da Silva',
		'footerText': 'Esse projeto é uma colaboração dos alunos\
			Julio Ribeiro, Luiza Silva, Gabriel Martinelli,\
			André Marçal, Denis Neves, Glauber Borges e\
			Maurício Fragale com o professor Sérgio Lifschitz. \
			O código é aberto e pode ser encontrado no nosso\
			<a href="http://github.com/PrismaDev/prisma">\
			Github</a>'
	}
});

var layoutStringsModel = new LayoutStringsModel();
