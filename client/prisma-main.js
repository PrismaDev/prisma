var TimetableView = Backbone.View.extend({
	template: '',
	startH: 7,
	endH: 23,
	ndays: 6,

	initialize: function() {
		this.template = _.template($('#timetable-template').html());
	},

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
		this.$el.html(this.template(this.fetchData()));
	}
});

var timetableView = new TimetableView();
var FaltacursarView = Backbone.View.extend({
	template: '',

	initialize: function() {
		this.template = _.template($('#faltacursar-template').html());
	},

	events: {
		"click #faltacursar-table tr": 'clickOnRow'
	},

	clickOnRow: function(e) {
		var row=$(e.target).parent('tr');

		if ($(row).hasClass('row_selected')) {
			$(row).removeClass('row_selected');
        		$('#faltacursar-classesList').addClass('hidden');
		}
		else {
			$('#faltacursar-table tr.row_selected').removeClass('row_selected');
			$(row).addClass('row_selected');
        		$('#faltacursar-classesList').removeClass('hidden');

			faltacursarClasseslistView.render([]);
		}
	},

	initJS: function() {
		var subjectTable = $('#faltacursar-table').dataTable({
			'bPaginate': false
		});
	},		

	fetchStrings: function() {
		return {codeStr: 'Codigo', nameStr: 'Nome da Disciplina',
			moreInfoStr: 'Ementa', termStr: 'Periodo'};
	},

	fetchSubjects: function() {
		return {subjects: [
			{code: 'MAT1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'},
			{code: 'ENG1015', name: 'Teste teste teste', term: '2', link: '#'}
		]};
	},

	fetchData: function() {
		var data = $.extend({}, this.fetchStrings(),
			this.fetchSubjects());
		return data;
	},

	render: function() {
		this.$el.html(this.template(this.fetchData()));
		this.initJS();
	
		faltacursarClasseslistView.setElement('#faltacursar-classesList');
	}
});

var faltacursarView = new FaltacursarView();
var SelectedView = Backbone.View.extend({
	initJS: function() {
		$('#main-selected-div ul').sortable({
			connectWith: '.selectedSortable',
			receive: function(e, ui) {
				if ($(this).children().length>3)
					$(ui.sender).sortable('cancel');
			}
		});	
	},

	buildRow: function(classArray) {
		var div = document.createElement('div');

		var ul = document.createElement('ul');
		$(ul).addClass('selectedSortable');

		for (var i=0; i<classArray.length; i++)
			$(ul).append('<li>'+classArray[i].subcode+'-'+
				classArray[i].classcode+'</li>');
		
		$(div).append(ul);
		return div;
	},

	buildSelected: function(rowsArray) {
		var div = document.createElement('div');

		for (var i=0; i<rowsArray.length; i++)
			$(div).append(this.buildRow(rowsArray[i]));

		return $(div).html();
	},

	fetchData: function() { //this will be a model function
		return [
			[
				{subcode: 'ENG1232',
				classcode: '3VA'},
				{subcode: 'ENG1232',
				classcode: '3VA'}
			],
			[
				{subcode: 'ENG1232',
				classcode: '3VA'}
			],
			[	
				{subcode: 'ENG1232',
				classcode: '3VA'},
				{subcode: 'ENG1232',
				classcode: '3VA'},
				{subcode: 'ENG1232',
				classcode: '3VA'}
			]
		];
	},

	render: function() {
		var data = this.fetchData();
		this.$el.html(this.buildSelected(data));
		this.initJS();
	}
});

var selectedView = new SelectedView();
var MicrohorarioView = Backbone.View.extend ({
	template: '',
	waitingTemplate: '',
	noQueryTemplate: '',
	resultsDiv: '',

	//status constants
	noQueryStatus: 'noQuery',
	queryStatus: 'query',
	waitingStatus: 'waiting',

	waitingImgURL: 'http://i.stack.imgur.com/FhHRx.gif',

	events: {
		"click #moreFiltersButton": "moreFilters",
		"click #lessFiltersButton": "lessFilters",
		"click #openFiltersButton": "openFilters",
		"click #closeFiltersButton": "closeFilters"
	},

	//Event handlers
	moreFilters: function() {
		$('#hiddenFilters').removeClass('hidden');
		$('#lessFiltersButton').removeClass('hidden');
		$('#moreFiltersButton').addClass('hidden');
	},
	
	lessFilters: function() {
		$('#hiddenFilters').addClass('hidden');
		$('#lessFiltersButton').addClass('hidden');
		$('#moreFiltersButton').removeClass('hidden');
	},

	openFilters: function() {
		$('#microhorario-filter').removeClass('hidden');
		$('#openFiltersButton').addClass('hidden');
		$('#closeFiltersButton').removeClass('hidden');
	},

	closeFilters: function() {
		$('#microhorario-filter').addClass('hidden');
		$('#openFiltersButton').removeClass('hidden');
		$('#closeFiltersButton').addClass('hidden');
	},

	//Methods
	initialize: function() {
		this.template = _.template($('#microhorario-template').html());
		this.waitingTemplate = _.template($('#microhorario-waiting-template').html());
		this.noQueryTemplate = _.template($('#microhorario-noquery-template').html());
	},

	changeState: function(qStatus, data = []) {
		if (qStatus==this.queryStatus) {
			microhorarioClasseslistView.render(data);
			this.closeFilters();
			return;			
		}

		if (qStatus==this.noQueryStatus)
			this.$resultsDiv.html(this.noQueryTemplate({
				noQueryStr: 'No query' //temporary
			}));
		else 
			this.$resultsDiv.html(this.waitingTemplate({
			waitingImgURL: this.waitingImgURL
		}));
	},

	fetchStrings: function() {
		return {noQueryStr: 'No query',
			subjectCodeStr: 'Codigo da Disciplina:',
			subjectNameStr: 'Nome da Disciplina:',
			professorNameStr: 'Nome do Professor:',
			toggleBlocked: 'Exibir disciplinas bloqueadas',
			moreFiltersStr: 'More filters',
			lessFiltersStr: 'Less filters',
			openFiltersStr: 'Open filters',
			closeFiltersStr: 'Close filters'		
		};
	},

	render: function() {
		this.$el.html(this.template(this.fetchStrings()));
		
		this.$resultsDiv = $('#microhorario-results');
		microhorarioClasseslistView.setElement(this.$resultsDiv);		

		this.changeState(this.noQueryStatus);		
	}
});

var microhorarioView = new MicrohorarioView();
var MainView = Backbone.View.extend({
	el: 'body',
	template: '',

	initialize: function() {
		this.template = _.template($('#main-template').html());
	},

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
				$('#main-timetable-div').width(nW-1);
					//the -1 is due to rounding problems
			}
		});	
	},

	initJS: function() {
		this.initJQueryUI();
		faltacursarView.initJS();
	},

	fetchStrings: function() {
		return {faltaCursarTabStr: 'Falta Cursar',
			microHorarioTabStr: 'Micro Horario',
			selectedTabStr: 'Selecionadas'};
	},

	renderSubviews: function() {
		timetableView.setElement('#main-timetable-div');
		timetableView.render();

		faltacursarView.setElement('#main-faltacursar-div');
		faltacursarView.render();

		microhorarioView.setElement('#main-microhorario-div');
		microhorarioView.render();

		selectedView.setElement('#main-selected-div');
		selectedView.render();
	},

	render: function() {
		this.$el.html(this.template(this.fetchStrings()));
		this.initJS();

		this.renderSubviews();
	}
});

var mainView = new MainView();
var ClasseslistView = Backbone.View.extend({
	template: '',

	initialize: function() {
		this.template = _.template($('#classeslist-template').html());
	},

	initJS: function() {
		this.$el.find('table').dataTable({
			'bPaginate': false
		});
	},

	render: function(classesArray) {
		this.$el.html(this.template(classesArray));	
		this.initJS();
	}
});

var microhorarioClasseslistView = new ClasseslistView();
var faltacursarClasseslistView = new ClasseslistView();
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
