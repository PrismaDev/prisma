var SelectedView = Backbone.View.extend({
	templateRow: '',
	templateTable: '',

	testArray: [
		[
			{subjectCode: 'aa1', classCode: 'bbb'},
			{subjectCode: 'aa2', classCode: 'bbb'}
		],
		[
			{subjectCode: 'aa3', classCode: 'bbb'}
		],
		[
			{subjectCode: 'aa4', classCode: 'bbb'},
			{subjectCode: 'aa5', classCode: 'bbb'},
			{subjectCode: 'aa6', classCode: 'bbb'}
		],
		[
			{subjectCode: 'aa7', classCode: 'bbb'},
			{subjectCode: 'aa8', classCode: 'bbb'}
		],
		[
			{subjectCode: 'aa9', classCode: 'bbb'},
			{subjectCode: 'a10', classCode: 'bbb'},
			{subjectCode: 'a11', classCode: 'bbb'}
		]
	],

	initialize: function() {
		this.templateRow = _.template($('#selected-row-template').html());
		this.templateTable = _.template($('#selected-table-template').html());
	},

	events: {
		'click button.close': 'deleteClass' 
	},

	resize: function() {},

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
		this.equalDroppables();
		button.parentNode.parentNode.removeChild(button.parentNode);
	},

	buildRow: function(index, classArray) {
		return	this.templateRow({
			'index': index,
			'options': classArray
		});
	},

	buildSelected: function(rowsArray) {
		this.$el.html(this.templateTable({
			selectedStr: selectedStringsModel
		}));
		var tbody = this.$el.find('tbody');

		for (var i=0; i<rowsArray.length; i++)
			$(tbody).append(this.buildRow(i,rowsArray[i]));
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
			revert: 'invalid',
			zIndex: 1000
		});
	},

	droppableInit: function() {
		var $drop = this.$el.find('td.classDroppable').droppable({
			drop: function(event, ui) {
				console.log('this:');
				console.log($(this));
				console.log('draggable:')
				console.log(ui.draggable);
				if ($(this).has('div.classDraggable')) {
					$(ui.draggable).parent().append(
						$(this).find('div.classDraggable')
					);
				}			

				$(ui.draggable).css({
					'left': '0px',
					'right': '0px',
					'top': '0px',
					'bottom': '0px'
				});
				$(this).append($(ui.draggable));
			},
			accept: '.classDraggable'
		});
	},	

	initJS: function() {
		this.sortableInit();
		this.draggableInit();
		this.droppableInit();
	}
});

var selectedView = new SelectedView();
