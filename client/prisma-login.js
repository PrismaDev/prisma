var LoginView = Backbone.View.extend({
	el: 'body',
	layoutTemplate: '',
	loginTemplate: '',

	initialize: function() {
		this.layoutTemplate = _.template($('#layout-template').html());
		this.loginTemplate = _.template($('#login-template').html());
	},

	render: function() {
		this.$el.html(this.layoutTemplate);
		$('#content-div').html(this.loginTemplate({str: loginStringsModel}));
	}
});

var loginView = new LoginView();
var LoginStringsModel = Backbone.Model.extend({
	defaults: {
		'matriculaLabel': 'Matrícula',
		'passwordLabel': 'Senha',
		'submitButtonLabel': 'Login'
	}
});

var loginStringsModel = new LoginStringsModel();
var Router = Backbone.Router.extend({
	routes: {
		'': 'index',
		'login': 'login',
		'term': 'term',
		'main':'main',
		'main/:tab': 'tabs'
	}
});

var router = new Router();
router.on('route:index', function() {
	router.navigate('login', {trigger: true});
});

router.on('route:login', function() {
	loginView.render();
});

router.on('route:term', function() {
	termView.render();
});

router.on('route:main', function() {
	mainView.render();
	router.navigate('main/'+mainView.defaultTab,
		{trigger: true});
});

router.on('route:tabs', function(tab) {
	if (!mainView.tabs[tab])
		return router.navigate('main/'+mainView.defaultTab,
			{trigger: true, replace: true});
	
	if (!mainView.rendered)
		mainView.render();
	mainView.setActiveTab(tab);
});

//if (history.pushState) { 
//	console.log("pushState supported");
//	Backbone.history.start({pushState: true});
//}
//else {
//	console.log("pushState NOT supported");
	Backbone.history.start();
//}
