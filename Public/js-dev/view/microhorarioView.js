var MicrohorarioView = Backbone.View.extend ({
	template: '',
	waitingTemplate: '',
	noQueryTemplate: '',
	resultsDiv: '',

	//status constants
	noQueryState: 'noQuery',
	queryState: 'query',
	waitingState: 'waiting',

	waitingImgURL: 'http://i.stack.imgur.com/FhHRx.gif',
		
	events: {
		"click #moreFiltersButton": "moreFilters",
		"click #lessFiltersButton": "lessFilters",
		"click #openFiltersButton": "openFilters",
		"click #closeFiltersButton": "closeFilters",
		"submit #microhorario-form": "query"
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

	query: function() {
		this.changeState(this.waitingState);
		microhorarioController.fetchData();
		return false;		
	},

	initialize: function() {
		this.template = _.template($('#microhorario-template').html());
		this.waitingTemplate = _.template($('#microhorario-waiting-template').html());
		this.noQueryTemplate = _.template($('#microhorario-noquery-template').html());
	},

	changeState: function(qState, data) {
		if (typeof data == undefined) data=[];

		if (qState==this.queryState) {
			this.closeFilters();
			microhorarioClasseslistView.render(data);
			return;			
		}

		if (qState==this.noQueryState)
			this.$resultsDiv.html(this.noQueryTemplate({
				str: microhorarioStringsModel
			}));
		else 
			this.$resultsDiv.html(this.waitingTemplate({
				waitingImgURL: this.waitingImgURL
			}));
	},

	resize: function() {
		microhorarioClasseslistView.resize();
	},

	render: function() {
		this.$el.html(this.template({
			str: microhorarioStringsModel
		}));
		
		this.$resultsDiv = $('#microhorario-results');
		microhorarioClasseslistView.setElement(this.$resultsDiv);		
		microhorarioClasseslistView.render([]);
		
		this.changeState(this.noQueryState);		
	}
});

var microhorarioView = new MicrohorarioView();
