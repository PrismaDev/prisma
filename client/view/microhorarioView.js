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
		"click #moreFiltersButton": "openFilters",
		"click #lessFiltersButton": "closeFilters"
	},

	//Event handlers
	openFilters: function() {
		$('#hiddenFilters').removeClass('hidden');
		$('#lessFiltersButton').removeClass('hidden');
		$('#moreFiltersButton').addClass('hidden');
	},
	
	closeFilters: function() {
		$('#hiddenFilters').addClass('hidden');
		$('#lessFiltersButton').addClass('hidden');
		$('#moreFiltersButton').removeClass('hidden');
	},

	//Methods
	initialize: function() {
		this.template = _.template($('#microhorario-template').html());
		this.waitingTemplate = _.template($('#microhorario-waiting-template').html());
		this.noQueryTemplate = _.template($('#microhorario-noquery-template').html());
	},

	changeState: function(qStatus, data = []) {
//		if (qStatus==this.queryStatus)
//			return microhorarioClasseslistView.render(data);
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
			lessFiltersStr: 'Less filters'		
		};
	},

	render: function() {
		this.$el.html(this.template(this.fetchStrings()));
		this.$resultsDiv = $('#microhorario-results');

		this.changeState(this.noQueryStatus);		
	}
});

var microhorarioView = new MicrohorarioView();
