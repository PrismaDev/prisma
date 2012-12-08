var FaltacursarModel = Backbone.Model.extend({
	get: function(attributes) {
		return overriddenGet(this, attributes);
	},

	getSubjects: function() {
		var array=new Array();
		
		_.each(this.get('Disciplinas'), function(disciplina) {
			var subjectModel = subjectList.get(disciplina[
				serverDictionary.get('CodigoDisciplina')
			]);
	
			var object={
				'code': subjectModel.get('CodigoDisciplina'),
				'name': subjectModel.get('NomeDisciplina'),
				'term': disciplina[serverDictionary.get('PeriodoAno')],
				'credits': subjectModel.get('Creditos')			
			};

			array.push(object);
		});

		return array;
	},

	getSubjectClasses: function(subjectId) {
		var subjectModel = subjectList.get(subjectId);
		var classList = subjectModel.get('Turmas');
		console.log(classList);
		var array=new Array();

		_.each(classList.models, function(classO) {
			var object={
				'professorName': classO.get('NomeProfessor'),
				'code': classO.get('CodigoTurma'),
				'schedule': classO.printSchedule()
			};

			array.push(object);
		});

		return array;
	}
});

var faltacursarModel = new FaltacursarModel();


