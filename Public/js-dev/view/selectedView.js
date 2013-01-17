var SelectedView = Backbone.View.extend({
	templateRow: '',
	template: '',
	templateDraggable: '',

	initialize: function() {
		this.templateRow = _.template($('#selected-row-template').html());
		this.template = _.template($('#selected-template').html());
		this.templateDraggable = _.template($('#selected-draggable-template').html());
	
		this.initHelpers();
	},	

	initHelpers: function() {
		helpersList.get('selectedRow').set('selector', '#main-selected-div tr');
		helpersList.get('selectedClass').set('selector', '#main-selected-div td:has(div):not(.radio)');
	
		$(helpersList.get('selectedClass').get('selector')).live('mouseover',function(e) {
			e.stopImmediatePropagation();
		});
	},

	changeInfo: function(nCredits, nClasses) {
		var infoC = $('#info-container');

		infoC.find('#qtdCredits').html(nCredits+' '+selectedStringsModel.get('qtdCreditsLabel'));
		infoC.find('#qtdClasses').html(nClasses+' '+selectedStringsModel.get('qtdClassesLabel'));
	},

	events: {
		'click button.close': 'deleteClass',
		'change input[type="radio"]': 'radioChange'
	},

	radioChange: function(e)
	{
		var td = $(e.target).parent();
		var tr = $(td).parent();
		var trIdx = $('#main-selected-div tbody tr').index(tr);

		selectedController.runSimulation(trIdx);
	},

	resize: function() {
		this.calculateHeightDivs();
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
		var div = $(e.target).parent('div');

		var subjectCode = $(div).find('input[type="hidden"][name="subjectCode"]').attr('value');
		var classCode = $(div).find('input[type="hidden"][name="classCode"]').attr('value');
		selectedModel.removeClass(subjectCode, classCode);

		this.equalDroppables();
	},

	buildRow: function(index, classArray) {
		var arr=new Array();

		for (var i=0; i<classArray.length; i++)
			if (classArray[i])
				arr[i]=(this.templateDraggable(classArray[i]));
	
		return	this.templateRow({
			'index': index,
			'options': classArray,
			'template': arr
		});
	},

	buildSelected: function(rowsArray) {
		this.$el.html(this.template({
			selectedStr: selectedStringsModel
		}));
		var tbody = this.$el.find('tbody');

		for (var i=0; i<rowsArray.length; i++)
			$(tbody).append(this.buildRow(i,rowsArray[i]));
	
		for (var i=rowsArray.length; i<selectedModel.maxRows; i++)
			$(tbody).append(this.buildRow(i,[]));
	},

	calculateHeightDivs: function() {
		console.log($('#info-container').height());
		console.log($('#main-selected-div').height());
		$('#table-container').height(
			$('#main-selected-div').height()-$('#info-container').outerHeight(true));
		console.log($('#table-container').height());
	},

	render: function() {
		this.buildSelected(selectedModel.getData());
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

			selectedController.sortLines();
			selectedController.runSimulation();
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
				selectedController.swapPlaces($(this), $(ui.draggable).parent());
				
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

				selectedController.runSimulation();
			},
			accept: '.classDraggable'
		});
	},	

	bindHelpers: function() {
		helperView.create('selectedRow');
		helperView.create('selectedClass');
	},

	initJS: function() {
		this.sortableInit();
		this.draggableInit();
		this.droppableInit();
		this.bindHelpers();
	}
});

var selectedView = new SelectedView();
