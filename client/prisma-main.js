var TimetableView = Backbone.View.extend({
	el: '#main-timetable-div',
	startH: 7,
	endH: 23,
	ndays: 6,

	buildTableBody: function(classArray) {
		var tbody = document.createElement('tbody');

		for (var hour=this.startH; hour<this.endH; hour++) {
			var tr = document.createElement('tr');
			$(tr).append('<td>'+hour+':00</td>');

			for (var day=0; day<this.ndays; day++)
				$(tr).append('<td></td>');
			$(tbody).append(tr);
		}

		return $(tbody).html();
	},

	fetchData: function() {
		return {days: ['Segunda', 'Terca', 'Quarta', 'Quinta',
				'Sexta', 'Sabado'],
				startH: 7, endH: 23,
				timetableBody: this.buildTableBody()		
			};
	},

	returnTemplate: function() {
		var template = _.template($('#timetable-template').html(),
			this.fetchData());
		return template;
	},

	render: function() {
		this.$el.html(returnTemplate());
	}
});

var timetableView = new TimetableView();
var FaltacursarView = Backbone.View.extend({
	el: '#faltacursar-div',

	initJS: function() {
		$('#faltacursar-table').dataTable();
	},

	fetchStrings: function() {
		return {codeStr: 'Codigo', nameStr: 'Nome da Disciplina',
			moreInfoStr: 'Ementa', termStr: 'Periodo',
			noSubjectsStr: 'Nao ha disciplinas para a busca'};
	},

	fetchSubjects: function() {
		return {subjects: []};
	},

	fetchData: function() {
		var data = $.extend({}, this.fetchStrings(),
			this.fetchSubjects());
		return data;
	},

	returnTemplate: function() {
		var template = _.template($('#faltacursar-template').html(),
			this.fetchData());
		return template;
	},

	render: function() {
		this.$el.html(returnTemplate());
	}
});

var faltacursarView = new FaltacursarView();
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

	initJS: function() {
		this.initJQueryUI();
	},

	fetchStrings: function() {
		return {faltaCursarTabStr: 'Falta Cursar',
			microHorarioTabStr: 'Micro Horario',
			selectedTabStr: 'Selecionadas'};
	},

	fetchData: function() {
		var data = $.extend({}, {timetableTemplate: timetableView.returnTemplate()},
			{faltacursarTemplate: faltacursarView.returnTemplate()},
			this.fetchStrings());
		return data;
	},

	render: function() {
		var template = _.template($("#main-template").html(),
			this.fetchData());
		this.$el.html(template);
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

	mainView.initJS();
	faltacursarView.initJS();
});

//if (history.pushState) { 
//	console.log("pushState supported");
//	Backbone.history.start({pushState: true});
//}
//else {
//	console.log("pushState NOT supported");
	Backbone.history.start();
//}
