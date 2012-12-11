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

					microhorarioClasseslistView.changeRow(subjectCode, classId, true);
					faltacursarClasseslistView.changeRow(subjectCode, classId, true);

					$.ajax({
						type: 'POST',
						url: '/api/selecionada',
						data: 'json='+JSON.stringify([{FK_Turma: classId, NoLinha: i, Opcao: j}]),
						success: function(msg){
							console.log('POST // Disciplina: '+subjectCode+' // Turma: '+classId+' // Msg: '+msg);
						}
					});

					selectedView.render();
					return true;
				}

		return false;
	},
});

var selectedModel = new SelectedModel();
