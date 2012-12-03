var SelectedView = Backbone.View.extend({
	template: '',

	initialize: function() {
		this.template = _.template($('#selected-row-template').html());
	},

	initJS: function() {
		this.$el.find('ul.selectedSortable').sortable();
	},

	buildRow: function(index, classArray) {
		return this.template({'index': index,
				'orStr': 'OU',
				'noneStr': 'N/A'});
	},

	resizeH: function() {},
	resizeW: function() {},

	buildSelected: function(rowsArray) {
		var ul = document.createElement('ul');
		$(ul).addClass('selectedSortable');
		
		var l = rowsArray.length;
		rowsArray[l]=[];

		for (var i=0; i<7; i++)
			$(ul).append(this.buildRow(i,rowsArray[i]));

		return ul;
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
