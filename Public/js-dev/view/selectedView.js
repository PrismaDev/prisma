var SelectedView = Backbone.View.extend({
	templateRow: '',
	templateTable: '',

	testArray: [
		[
			{subjectCode: 'aaa', classCode: 'bbb'},
			{subjectCode: 'aaa', classCode: 'bbb'}
		],
		[
			{subjectCode: 'aaa', classCode: 'bbb'}
		],
		[
			{subjectCode: 'aaa', classCode: 'bbb'},
			{subjectCode: 'aaa', classCode: 'bbb'},
			{subjectCode: 'aaa', classCode: 'bbb'}
		],
		[
			{subjectCode: 'aaa', classCode: 'bbb'},
			{subjectCode: 'aaa', classCode: 'bbb'}
		],
		[
			{subjectCode: 'aaa', classCode: 'bbb'},
			{subjectCode: 'aaa', classCode: 'bbb'},
			{subjectCode: 'aaa', classCode: 'bbb'}
		]
	],

	initialize: function() {
		this.templateRow = _.template($('#selected-row-template').html());
		this.templateTable = _.template($('#selected-table-template').html());
	},

	events: {
		'click button.close': 'deleteClass' 
	},

	equalDroppables: function() {
		var $tr = this.$el.find('tbody tr').first();
		var w = $tr.width();
		var occupy=0;

		var $tds = $tr.find('td.classDroppable').each(function(index) {
			occupy+=$(this).width();
		});

		var perc = Math.ceil((100.*occupy)/(3.*w));
		$tds.css('width',perc+'%');
	},

	deleteClass: function(e) {
		var button = e.target;
		$(button.parentNode.parentNode).addClass('empty');
		this.equalDroppables();
		button.parentNode.parentNode.removeChild(button.parentNode);
	},

	buildRow: function(index, classArray) {
		return	this.templateRow({
			'index': index,
			'options': classArray
		});
	},

	resizeH: function() {},
	resizeW: function() {},

	buildSelected: function(rowsArray) {
		this.$el.html(this.templateTable(this.fetchStrings()));
		var tbody = this.$el.find('tbody');

		for (var i=0; i<rowsArray.length; i++)
			$(tbody).append(this.buildRow(i,rowsArray[i]));
	},

	fetchStrings: function() {
		return {'option1Label': '1a opcao',
			'option2Label': '2a opcao',
			'option3Label': '3a opcao',
			'noneLabel': 'N/A'};
	},

	fetchData: function() { //this will be a model function
		return this.testArray;
	},

	render: function() {
		var data = this.fetchData();
		this.buildSelected(data);
		this.initJS();
	},

	sortableInit: function() {
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

	draggableInit: function() {
		this.$el.find('div.classDraggable').draggable({
			revert: 'invalid'
		});
	},

	droppableInit: function() {
		var $drop = this.$el.find('td.classDroppable').droppable({
			drop: function(event, ui) {	
				$(this).append($(ui.draggable));
			},
			out: function(event, ui) {
			//	$(this).enable();
				$(ui.draggable).css({
					'position': 'relative',
					'top':'0px','bottom':'0px',
					'left':'0px','right': '0px'});
				$(ui.draggable).removeClass('inplace');
			}
		});
	},	

	initJS: function() {
		this.sortableInit();
		this.draggableInit();
		this.droppableInit();
	}
});

var selectedView = new SelectedView();
