function MicrohorarioController() {
	var formEl = '#microhorario-form';
	var url = 'api/microhorario';

	this.fetchData = function() {
		var me=this;

		$.ajax({
			url: url,
			type: 'GET',
			data: $(formEl).serialize(),
			dataType: 'json',

			success: function(data) {
				me.handleData(data);
			}
		});
	}

	this.handleData = function(data) {
		subjectList.add(data[serverDictionary.get('Dependencia')]);
		var array = new Array();		

		_.each(data[serverDictionary.get('MicroHorario')], function(classO) {
			var subjectModel = subjectList.get(
				classO[serverDictionary.get('CodigoDisciplina')]
			);
			var classModel = subjectModel.get('Turmas')
				.get(classO[serverDictionary.get('PK_Turma')]);

			var object={
				'subjectCode': subjectModel.get('CodigoDisciplina'),
				'subjectName': subjectModel.get('NomeDisciplina'),
				'professorName' : classModel.get('NomeProfessor'),
				'schedule': classModel.printSchedule(),
				'code': classModel.get('CodigoTurma'),
				'classId': classModel.get('PK_Turma'),
				'status': subjectModel.get('Situacao'),
				'able': subjectModel.get('Apto')
			};

			array.push(object);
		});

		microhorarioView.changeState(microhorarioView.queryState,array);
	}
}

var microhorarioController = new MicrohorarioController();
