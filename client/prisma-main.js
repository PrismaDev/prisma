var TimetableView = Backbone.View.extend({
	el: 'body',
	render: function() {
		var template = _.template($('#timetable-template').html(),
			{days: ['Segunda', 'Terca', 'Quarta', 'Quinta',
				'Sexta', 'Sabado'],
			startH: 7, endH: 23});
		return template; 
	}
});

var timetableView = new TimetableView();
var MainView = Backbone.View.extend({
	el: 'body',

	initJQueryUI: function() {
		var me=this;

		$("#main-sidebar-div").resizable({
			handles: 'e, w',
			maxWidth: 0.6*$(window).width(),
			minWidth: 0.25*$(window).width(),
			containment: "parent",

			resize: function(e, ui) {
				var w = $(".row-fluid").width();
				var nW = w-$('#main-sidebar-div').outerWidth();
				$('#main-timetable-div').width(nW);
			}
		});	
	},

	render: function() {
		var template = _.template($("#main-template").html(),
			{faltaCursarTabStr: 'Falta Cursar',
			microHorarioTabStr: 'Micro Horario',
			selectedTabStr: 'Selecionadas',

			timetableTemplate: timetableView.render()});
		this.$el.html(template);
		
		this.initJQueryUI();
	}
});

var mainView = new MainView();
var Router = Backbone.Router.extend({
	routes: {
		'': 'index',
		'login': 'login',
		':mat/term': 'term',
		':mat/main': 'main'
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
});

//if (history.pushState) { 
//	console.log("pushState supported");
//	Backbone.history.start({pushState: true});
//}
//else {
//	console.log("pushState NOT supported");
	Backbone.history.start();
//}
