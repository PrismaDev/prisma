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

	setFromServer: function(data) {
		_.each(data, function(row) {
			var subjectCode = row[serverDictionary.get('CodigoDisciplina')];
			var classId = row[serverDictionary.get('FK_Turma')];
			var i = row[serverDictionary.get('NoLinha')];
			var j = row[serverDictionary.get('Opcao')];

			options[i][j] = {
				'subjectCode': subjectCode,
				'classCode': subjectList.get(subjectCode).get('Turmas').get(classId).get('CodigoTurma'),
				'classId': classId
			};
		});
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
					
					microhorarioClasseslistView.changeRow(subjectCode, classId, false);
					faltacursarClasseslistView.changeRow(subjectCode, classId, false);

					$.ajax({
						type: 'DELETE',
						url: '/api/selecionada',
						data: 'json='+JSON.stringify([{FK_Turma: classId}]),
						success: function(msg){
							console.log('DELETE // Disciplina: '+subjectCode+' // Turma: '+classId+' // Msg: '+msg);
						}
					});

					selectedView.render();

					selectedController.runSimulation();
					return true;
				}
		return false;
	},

	addClassModel: function(subjectCode, classId, rowNumber, Option)
	{
		var classModel = subjectList.get(subjectCode)
				.get('Turmas').get(classId);
		console.log(classModel);
		
		options[rowNumber][Option]={
			'subjectCode': subjectCode,
			'classCode': classModel.get('CodigoTurma'),
			'classId': classId
		}

		microhorarioClasseslistView.changeRow(subjectCode, classId, true);
		faltacursarClasseslistView.changeRow(subjectCode, classId, true);

		$.ajax({
			type: 'POST',
			url: '/api/selecionada',
			data: 'json='+JSON.stringify([{FK_Turma: classId, NoLinha: rowNumber, Opcao: Option}]),
			success: function(msg){
				console.log('POST // Disciplina: '+subjectCode+' // Turma: '+classId+' // Msg: '+msg);
			}
		});

		selectedView.render();

		selectedController.runSimulation();
		return true;

	},

	addClass: function(subjectCode, classId) {
		// same subject in row
		for (var i=0; i<this.maxRows; i++)
		{
			for (var j=0; j<this.nOptions; j++)
			{
				if (options[i][j]!=null && options[i][j].subjectCode==subjectCode && j != (this.nOptions-1) && options[i][j+1]==null)
				{
					this.addClassModel(subjectCode, classId, i, j+1);
					return true;
				}
			}
		}

		// seeking for empty row
		for (var i=0; i<this.maxRows; i++)
			if (options[i][0]==null) {
				this.addClassModel(subjectCode, classId, i, 0);
				return true;
			}

		// else
		for (var i=0; i<this.maxRows; i++)
			for (var j=0; j<this.nOptions; j++)
				if (options[i][j]==null) {
					this.addClassModel(subjectCode, classId, i, j);
					return true;
				}

		return false;
	},
});

var selectedModel = new SelectedModel();
