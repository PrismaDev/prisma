var MicrohorarioView = Backbone.View.extend ({
	template: '',
	waitingTemplate: '',
	noQueryTemplate: '',
	resultsDiv: '',

	//status constants
	noQueryState: 'noQuery',
	queryState: 'query',
	waitingState: 'waiting',

	events: {
		"click #moreFiltersButton": "moreFilters",
		"click #lessFiltersButton": "lessFilters",
		"click #openFiltersButton": "openFilters",
		"click #closeFiltersButton": "closeFilters",
		"submit #microhorario-form": "query",
		"reset #microhorario-form" : "clear"
	},

	//Event handlers
	moreFilters: function() {
		$('#hiddenFilters').removeClass('hidden');
		$('#lessFiltersButton').removeClass('hidden');
		$('#moreFiltersButton').addClass('hidden');
		
		microhorarioClasseslistView.resize();
	},
	
	lessFilters: function() {
		$('#hiddenFilters').addClass('hidden');
		$('#lessFiltersButton').addClass('hidden');
		$('#moreFiltersButton').removeClass('hidden');
		
		microhorarioClasseslistView.resize();
	},

	openFilters: function() {
		$('#microhorario-filter').removeClass('hidden');
		$('#openFiltersButton').addClass('hidden');
		$('#closeFiltersButton').removeClass('hidden');

		microhorarioClasseslistView.resize();
	},

	closeFilters: function() {
		$('#microhorario-filter').addClass('hidden');
		$('#openFiltersButton').removeClass('hidden');
		$('#closeFiltersButton').addClass('hidden');
		
		microhorarioClasseslistView.resize();
	},

	searchFor: function(day, initTime) {
		console.log(day);
		console.log(initTime);

		if (initTime)
			$('input[name="HoraInicial"]').attr('value',initTime);
		if (day)
			$('select[name="DiaSemana"]').find('option[value="'+day+'"]').attr('selected',true);
		
		mainView.setActiveTab('microhorario');
		this.openFilters();
		this.query();
	},

	query: function() {
		this.changeState(this.waitingState);
		microhorarioController.fetchData(true);
		return false;		
	},

	clear: function() {
		this.changeState(this.noQueryState);
	},

	initialize: function() {
		this.template = _.template($('#microhorario-template').html());
		this.waitingTemplate = _.template($('#microhorario-waiting-template').html());
		this.noQueryTemplate = _.template($('#microhorario-noquery-template').html());
	},

	changeState: function(qState, data) {
		if (typeof data == undefined) data=[];

		if (qState==this.queryState) {
			this.lessFilters();
			microhorarioClasseslistView.render(data);
			return;			
		}

		if (qState==this.noQueryState)
			this.$resultsDiv.html(this.noQueryTemplate({
				str: microhorarioStringsModel
			}));
		else 
			this.$resultsDiv.html(this.waitingTemplate({
				str: microhorarioStringsModel
			}));
	},

	resize: function() {
		microhorarioClasseslistView.resize();
	},

	render: function() {
		this.$el.html(this.template({
			str: microhorarioStringsModel,
			timetableStr: timetableStringsModel
		}));
		
		this.$resultsDiv = $('#microhorario-results');
		microhorarioClasseslistView.setElement(this.$resultsDiv);
		
		this.changeState(this.noQueryState);		
	}
});

var microhorarioView = new MicrohorarioView();
