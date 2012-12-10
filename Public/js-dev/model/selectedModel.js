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
		return options;
	},

	removeClass: function(subjectCode, classCode) {
		for (var i=0; i<this.maxRows; i++)
			for (var j=0; j<this.nOptions; j++)
				if (options[i][j].subjectCode==subjectCode &&
					options[i][j].classCode==classCode) {
					
					options[i][j]=null;
					console.log(options);
					selectedView.render();
					return true;
				}
		return false;
	},

	addClass: function(subjectCode, classCode) {
		for (var i=0; i<this.maxRows; i++)
			for (var j=0; j<this.nOptions; j++)
				if (options[i][j]==null) {
					options[i][j]={
						'subjectCode': subjectCode,
						'classCode': classCode
					}

					console.log(options);
					selectedView.render();
					return true;
				}

		return false;
	},
});

var selectedModel = new SelectedModel();
