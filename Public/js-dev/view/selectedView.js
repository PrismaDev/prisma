var SelectedView = Backbone.View.extend({
	templateRow: '',
	templateTable: '',

	initialize: function() {
		this.templateRow = _.template($('#selected-row-template').html());
		this.templateTable = _.template($('#selected-table-template').html());
	},

	initJS: function() {
		var me=this;

		this.$el.find('tbody.selectedSortable').sortable({
			//Based on http://stackoverflow.com/questions/1307705/jquery-ui-sortable-with-table-and-tr-width/1372954#1372954
	
			helper: function(e, tr) {
				var $originals = tr.children();
    				var $helper = tr.clone();

				$helper.children().each(function(index)
    				{
      					$(this).width($originals.eq(index).width())
    					$(this).height($originals.eq(index).height());
				});
    				return $helper;
  			},	
		
			//Based http://www.ilovecolors.com.ar/preserving-radio-button-checked-state-during-drag-and-drop-jquery/
			start: function (e, ui) {
        			var radio_checked= {};
            
				me.$el.find('input[type="radio"]', this).each(function(){
					if($(this).is(':checked'))
						radio_checked[$(this).attr('name')] = $(this).val();
					$(document).data('radio_checked', radio_checked);
				});

			}
		}).bind('sortstop', function (event, ui) {
			var radio_restore = $(document).data('radio_checked');

			$.each(radio_restore, function(index, value){
				$('input[name="'+index+'"][value="'+value+'"]').prop('checked', true);
			});
		});
	},

	buildRow: function(index, classArray) {
		return	this.templateRow({'index': index});
	},

	resizeH: function() {},
	resizeW: function() {},

	buildSelected: function(rowsArray) {
		this.$el.html(this.templateTable(this.fetchStrings()));
		var tbody = this.$el.find('tbody');

		for (var i=0; i<7; i++)
			$(tbody).append(this.buildRow(i,rowsArray[i]));
	},

	fetchStrings: function() {
		return {'option1Label': '1a opcao',
			'option2Label': '2a opcao',
			'option3Label': '3a opcao',
			'noneLabel': 'N/A'};
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
		this.buildSelected(data);
		this.initJS();
	}
});

var selectedView = new SelectedView();
