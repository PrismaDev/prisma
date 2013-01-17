var FaltacursarModel = Backbone.Model.extend({
	get: function(attributes) {
		return overriddenGet(this, attributes);
	},

	set: function(attributes) {
		var discId = serverDictionary.get('Disciplinas');
		Backbone.Model.prototype.set.call(this,discId,attributes[discId]);	
	
		var optId = serverDictionary.get('Optativas');
		var optativasList = new OptativasList(attributes[optId]);
		Backbone.Model.prototype.set.call(this,optId,optativasList);
	},

	getTableRows: function() {
		var array=new Array();
		
		_.each(this.get('Disciplinas'), function(disciplina) {
			var subjectModel = subjectList.get(disciplina[
				serverDictionary.get('CodigoDisciplina')
			]);
			
			array.push($.extend({}, subjectModel.formatData(false), 
				{'term': disciplina[serverDictionary.get('PeriodoAno')]}));
		});

		
		_.each(this.get('Optativas').models, function(optativa) {	
			array.push(optativa.formatData());	
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
