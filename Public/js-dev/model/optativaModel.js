var OptativaModel = Backbone.Model.extend({
	get: function(attribute) {
		return overriddenGet(this, attribute);
	},
	
	belongToOptativa: function(subject) {
		if (typeof subject == SubjectModel)
			subject = subject.get('CodigoDisciplina');

		var disc = this.get('Disciplinas');
		
		for (idx in disc) {
			if (disc[idx] == subject)
				return true;
		}

		return false;
	},

	countChosen: function() {
		var count=0, d=this.get('Disciplinas');
		var dRef=serverDictionary.get('CodigoDisciplina');

		for (idx in d) {
			if (selectedModel.isSelected(d[idx][dRef]))
				count++;
		}

		console.log(count);
		return count;
	},

	formatData: function() {
		return {
			'code': this.get('CodigoOptativa'),
			'name': this.get('NomeOptativa'),
			'term': this.get('PeriodoAno'),
			'credits': '-',
			'able': 2,
			'status': this.getStatus(),
			'optativa': true,
			'nSubjectsChosen': this.countChosen()
		};
	},

	getStatus: function() {
		return 'NC';
	}
});

var OptativasList = Backbone.Collection.extend({
	model: OptativaModel,

	add: function(models, options) {
		return overriddenAdd(this, models, options, 'CodigoOptativa');
	}
});
