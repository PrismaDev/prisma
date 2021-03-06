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
		"click #more-filters-button": "moreFilters",
		"click #less-filters-button": "lessFilters",
		"click #open-filters-button": "openFilters",
		"click #close-filters-button": "closeFilters",
		"submit #microhorario-form": "query",
		"reset #microhorario-form" : "clear"
	},

	//Event handlers
	moreFilters: function() {
		$('#hidden-filters').removeClass('hidden');
		$('#less-filters-button').removeClass('hidden');
		$('#more-filters-button').addClass('hidden');
		
		microhorarioClasseslistView.resize();
	},
	
	lessFilters: function() {
		$('#hidden-filters').addClass('hidden');
		$('#less-filters-button').addClass('hidden');
		$('#more-filters-button').removeClass('hidden');
		
		microhorarioClasseslistView.resize();
	},

	openFilters: function() {
		$('#microhorario-filter').removeClass('hidden');
		$('#open-filters-button').addClass('hidden');
		$('#close-filters-button').removeClass('hidden');

		microhorarioClasseslistView.resize();
	},

	closeFilters: function() {
		$('#microhorario-filter').addClass('hidden');
		$('#open-filters-button').removeClass('hidden');
		$('#close-filters-button').addClass('hidden');
		
		microhorarioClasseslistView.resize();
	},

	searchFor: function(day, initTime, subjectCode) {
		this.clear();

		if (day==null) day='';
		if (initTime==null) initTime='';
		if (subjectCode==null) subjectCode='';
	
		$('input[name="HoraInicial"]').attr('value',initTime);
		$('select[name="DiaSemana"]').find('option[value="'+day+'"]').attr('selected',true);
		$('input[name="CodigoDisciplina"]').attr('value',subjectCode);
		
		mainRouter.navigate('microhorario', {trigger: true});
		this.openFilters();
		this.query();
	},

	query: function() {
		this.changeState(this.waitingState);
		microhorarioController.fetchData(true);
		return false;		
	},

	clear: function() {
		$('input[type="text"]').attr('value','');
		$('select[name="DiaSemana"]').find('option').attr('selected',false);
		$('select[name="DiaSemana"]').find('option[value=""]').attr('selected',true);
		$('input[type="checked"]').attr('checked',false);

		this.changeState(this.noQueryState);
	},

	setFiltersState: function() {
		if ($('#hiddenFilters').find('input:checked, input[type="text"][value!=""],\
				option[value!=""]:selected').length!=0)
			this.moreFilters();
		else
			this.lessFilters();
	},

	initialize: function() {
		this.template = _.template($('#microhorario-template').html());
		this.waitingTemplate = _.template($('#microhorario-waiting-template').html());
		this.noQueryTemplate = _.template($('#microhorario-noquery-template').html());
	},

	changeState: function(qState, data) {
		if (typeof data == undefined) data=[];

		if (qState==this.queryState) {
			this.setFiltersState();
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

	bindValidators: function() {
		$('input[name="Creditos"]').change(function(ev) {
			microhorarioValidator.intMask(ev.target,3);
		});

		$('input[name="HoraInicial"]').change(function(ev) {
			microhorarioValidator.hourMask(ev.target);
		});

		$('input[name="HoraFinal"]').change(function(ev) {
			microhorarioValidator.hourMask(ev.target);
		});
	},

	render: function() {
		this.$el.html(this.template({
			str: microhorarioStringsModel,
			timetableStr: timetableStringsModel
		}));
		
		this.$resultsDiv = $('#microhorario-results');
		microhorarioClasseslistView.setElement(this.$resultsDiv);
	
		this.bindValidators();	
		this.changeState(this.noQueryState);		
	}
});

var microhorarioView = new MicrohorarioView();
