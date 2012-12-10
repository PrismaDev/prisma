var SelectedModel = Backbone.Model.extend({
	options: '',
	viewEl: '#main-selected-div tbody',
	maxRows: 12,
	nOptions: 3,

	initialize: function() {
		options=new Array();

		for (var i=0; i<this.maxRows; i++)
			options[i]=new Array();
	
		for (var i=0; i<this.maxRows; i++)
			for (var j=0; j<this.nOptions; j++)
				options[i][j]=null;
	},

	getData: function() {

	},

	addClass: function(subjectId, classId) {
		for (var i=0; i<this.maxRows, i++)
			for (var j=0; j<this.nOptions; j++)
				if (options[i][j]==null) {
					options[i][j]={
						'subjectCode': subjectId,
						'classId': classId
					}

					selectedView.render();
					return true;
				}

		return false;
	}

	viewChanged: function() {
		
	}
});
