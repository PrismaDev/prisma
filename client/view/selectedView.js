var SelectedView = Backbone.View.extend({
	fetchData: function() {
		return {};
	},

	buildRow: function(classArray) {
		var div = document.createElement('div');

		var ul = document.createElement('ul');
		$(ul).addClass('selectedSortable');

		for (var i=0; i<classArray.length; i++)
			$(ul).append('<li>'+classArray.subcode+'-'+
				classArray.classcode+'</li>');
		
		$(div).append(ul);
		return div;
	},

	buildSelected: function(rowsArray) {
		var div = document.createElement('div');

		for (var i=0; i<rowsArray.length; i++)
			$(div).append(buildRow(rowsArray[i]));

		return $(div).html();
	},

	returnTemplate: function() {
		return '<p>selected view</p>';
	},

	render: function() {
		this.$el.html(this.returnTemplate());
	}
});

var selectedView = new SelectedView();
