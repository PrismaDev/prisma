function MicrohorarioController() {
	var formEl = '#microhorario-form';
	var url = 'api/microhorario';
	var defaultQtd=10;
	var formquerystring;
	this.nextPage=0;

	var completeQueryStr = function() {
		return formquerystring+'&Pagina='+this.nextPage+'&Quantidade='+
			defaultQtd;
	}

	this.fetchData = function(newSearch) {
		var me=this;

		if (newSearch) {
			formquerystring = $(formEl).serialize();
			nextPage=0;
		}
		console.log(completeQueryStr());
		
		$.ajax({
			url: url,
			type: 'GET',
			data: completeQueryStr(),
			dataType: 'json',

			success: function(data) {
				if (newSearch)
					me.buildTable(data);
				me.nextPage++;
			}
		});
	}
	
	var formatData = function(data) {
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

		return array;
	}

	this.buildTable = function(data) {
		var array = formatData(data);	
		microhorarioView.changeState(microhorarioView.queryState,array);
	}
}

var microhorarioController = new MicrohorarioController();
