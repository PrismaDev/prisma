var SelectedView = Backbone.View.extend({
	initJS: function() {
		$('#main-selected-div ul').sortable({
			connectWith: '.selectedSortable',
			receive: function(e, ui) {
				if ($(this).children().length>3)
					$(ui.sender).sortable('cancel');
			}
		});	
	},

	buildRow: function(classArray) {
		var div = document.createElement('div');

		var ul = document.createElement('ul');
		$(ul).addClass('selectedSortable');

		for (var i=0; i<classArray.length; i++)
			$(ul).append('<li>'+classArray[i].subcode+'-'+
				classArray[i].classcode+'</li>');
		
		$(div).append(ul);
		return div;
	},

	buildSelected: function(rowsArray) {
		var div = document.createElement('div');

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
