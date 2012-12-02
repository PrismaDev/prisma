var SelectedView = Backbone.View.extend({
	initJS: function() {
		this.$el.find('ul.selectedSortable').sortable();
	},

	buildRow: function(classArray) {
	/*	var ul = document.createElement('ul');
		$(ul).addClass('selectedSortable');

		for (var i=0; i<classArray.length; i++)
			if (i) $(ul).append('<li class="btn disabled">'+classArray[i].subcode+'-'+
				classArray[i].classcode+'</li>');
			else $(ul).append('<li class="btn btn-primary disabled">'+classArray[0].subcode+'-'+
				classArray[0].classcode+'</li>');
		
		return ul;*/

		var li = document.createElement('li');
		li.innerHTML = "coisa";

		return li;
	},

	resizeH: function() {},
	resizeW: function() {},

	buildSelected: function(rowsArray) {
		var ul = document.createElement('ul');
		$(ul).addClass('selectedSortable');
		
		var l = rowsArray.length;
		rowsArray[l]=[];

		for (var i=0; i<5; i++)
			ul.appendChild(this.buildRow(rowsArray[i]));

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
