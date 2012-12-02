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
	testArray: [
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'},
		{'subjectCode':'coisa', 'subjectName':'coisa', 'professorName': 'coisa', 'code': 'coisa', 'schedule': 'coisa'}
	],
		
	resizeW: function() {
		microhorarioClasseslistView.resizeW();
	},

	resizeH: function() {
		microhorarioClasseslistView.resizeH();
	},

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

	changeState: function(qStatus, data) {
		if (typeof data == undefined) data=[];

		if (qStatus==this.queryStatus) {
			this.closeFilters();
			microhorarioClasseslistView.render(data);
			microhorarioClasseslistView.resizeH();
			microhorarioClasseslistView.resizeW();
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
		microhorarioClasseslistView.render([]);

		this.changeState(this.queryStatus, this.testArray);		
	}
});

var microhorarioView = new MicrohorarioView();
