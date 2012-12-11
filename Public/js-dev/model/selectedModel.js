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

	removeClass: function(subjectCode, classId) {
		for (var i=0; i<this.maxRows; i++)
			for (var j=0; j<this.nOptions; j++)
				if (options[i][j] &&
					options[i][j].subjectCode==subjectCode &&
					options[i][j].classId==classId) {
					
					options[i][j]=null;
					var classModel = subjectList.get(subjectCode)
							.get('Turmas').get(classId);
					classModel.set('Selecionada',false);
					
					microhorarioClasseslistView.changeRow(subjectCode, classId, false);
					faltacursarClasseslistView.changeRow(subjectCode, classId, false);

					selectedView.render();
					return true;
				}
		return false;
	},

	addClass: function(subjectCode, classId) {
		for (var i=0; i<this.maxRows; i++)
			for (var j=0; j<this.nOptions; j++)
				if (options[i][j]==null) {
					var classModel = subjectList.get(subjectCode)
							.get('Turmas').get(classId);
					console.log(classModel);
					
					options[i][j]={
						'subjectCode': subjectCode,
						'classCode': classModel.get('CodigoTurma'),
						'classId': classId
					}

					classModel.set('Selecionada',true);					
					microhorarioClasseslistView.changeRow(subjectCode, classId, true);
					faltacursarClasseslistView.changeRow(subjectCode, classId, true);

					selectedView.render();
					return true;
				}

		return false;
	},
});

var selectedModel = new SelectedModel();
