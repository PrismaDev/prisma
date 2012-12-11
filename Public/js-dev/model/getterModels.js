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
			var id = disciplina[serverDictionary.get('CodigoDisciplina')];

			var object={
				'code': subjectModel.get('CodigoDisciplina'),
				'name': subjectModel.get('NomeDisciplina'),
				'term': disciplina[serverDictionary.get('PeriodoAno')],
				'credits': subjectModel.get('Creditos'),		
				'able': subjectModel.get('Apto'),
				'status': subjectModel.get('Situacao')
			};

			array.push(object);
		});

		
		_.each(this.get('Optativas'), function(optativa) {
			var object={
				'code': optativa[serverDictionary.get('CodigoOptativa')],
				'name': optativa[serverDictionary.get('NomeOptativa')],
				'term': optativa[serverDictionary.get('PeriodoAno')],
				'credits': '-',
				'able': 2,
				'status': 'NC',
				'optativa': true
			};

			array.push(object);	
		});

		return array;
	},

	getSubjectsOptativa: function(codOpt) {
		var array=new Array();
		var object={
			'code': '123',
			'name':	'343',
			'term': '222222222222222222222222222222222222222222222222',
			'credits': '23',
			'able': '2',
			'status': '2'
		};

		array.push(object);
		return array;
	},

	getSubjectClasses: function(subjectId) {
			   var subjectModel = subjectList.get(subjectId);
			   var classList = subjectModel.get('Turmas');
			   var array=new Array();

			   _.each(classList.models, function(classO) {
					   var object={
					   'professorName': classO.get('NomeProfessor'),
					   'code': classO.get('CodigoTurma'),
					   'schedule': classO.printSchedule(),
					   'subjectCode': subjectModel.get('CodigoDisciplina'),
					   'classId': classO.get('PK_Turma'),
					   'status': subjectModel.get('Situacao'),
					   'able': subjectModel.get('Apto')
					   };

					   array.push(object);
					   });

			   return array;
		   }
});

var faltacursarModel = new FaltacursarModel();
