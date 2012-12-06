var FaltacursarModel = Backbone.Model.extend({
	getData: function() {
		var array=new Array();
		console.log(this);			
		
		_.each(this.get('disciplinas'), function(disciplina) {
			var subjectModel = subjectList.get(disciplina.CodigoDisciplina);
	
			var object={
				'code': subjectModel.get('CodigoDisciplina'),
				'name': subjectModel.get('NomeDisciplina'),
				'term': disciplina.PeriodoSugerido,
				'credits': subjectModel.get('Creditos')			
			};

			console.log(object);
			array.push(object);
		});

		return array;
	}
});

var faltacursarModel = new FaltacursarModel();
