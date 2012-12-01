var SelectedView = Backbone.View.extend({
	events: {
		"click #main-selected-div li" : 'handleClick'
	},

	handleClick: function(e) {
		if ($(e.target).hasClass('btn-primary'))
			$(e.target).removeClass('btn-primary');
		else {
			var list = e.target.parent();
			$($(list).find('li')).each(function(idx, element) {
				$(element).removeClass('btn-primary');
			});
			$(e.target).addClass('btn-primary');
		}
	},

	resizeW: function() {},
	resizeH: function() {},

	sortableConfig: function(selector) {
		var me=this;

		$(selector).sortable({
			connectWith: '.selectedSortable',
			receive: function(e, ui) {
				if ($(this).children().length>3)
					$(ui.sender).sortable('cancel');
				if ($(ui.sender).children().length==0)
					$(ui.sender).remove();
				
				if ($('#main-selected-div ul').last().children().length) {
					var ul=document.createElement('ul');
					$(ul).addClass('selectedSortable');
					$('#main-selected-div').append(ul);
					me.sortableConfig(ul);
				}
			}
		});	
	},

	initJS: function() {
		this.sortableConfig('#main-selected-div ul');
	},

	buildRow: function(classArray) {
		var ul = document.createElement('ul');
		$(ul).addClass('selectedSortable');

		for (var i=0; i<classArray.length; i++)
			if (i) $(ul).append('<li class="btn disabled">'+classArray[i].subcode+'-'+
				classArray[i].classcode+'</li>');
			else $(ul).append('<li class="btn btn-primary disabled">'+classArray[0].subcode+'-'+
				classArray[0].classcode+'</li>');
		
		return ul;
	},

	buildSelected: function(rowsArray) {
		var div = document.createElement('div');
		var l = rowsArray.length;
		rowsArray[l]=[];

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
