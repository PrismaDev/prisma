var FaltacursarModel = Backbone.Model.extend({
	get: function(attributes) {
		return overriddenGet(this, attributes);
	},

	getTableRows: function() {
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
		var opt, optArr = this.get('Optativas');

		for (var i=0; i<optArr.length; i++)
			if (optArr[i][serverDictionary.get('CodigoOptativa')]==codOpt) {
				opt=optArr[i];
				break;
			}
	
		_.each(opt[serverDictionary.get('Disciplinas')], function(subject) {
			var subjectModel = subjectList.get(subject[
				serverDictionary.get('CodigoDisciplina')
			]);
		
			array.push($.extend({}, subjectModel.formatData(true), 
				{'term': opt[serverDictionary.get('PeriodoAno')]}));
		});

		return array;
	},

	getSubjectClasses: function(subjectId) {
		var subjectModel = subjectList.get(subjectId);
		var classList = subjectModel.get('Turmas');
		var array=new Array();

		_.each(classList.models, function(classO) {
			array.push(classO.formatData());
		});

		return array;
	}
});

var faltacursarModel = new FaltacursarModel();
