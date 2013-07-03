SubjectModel = Backbone.Model.extend({
	initialize: function() {
		var classesArray = this.get('Turmas');
		var classesList = new ClassList();
		classesList.add(classesArray,{subject: this});

		this.set(serverDictionary.get('Turmas'),classesList);	
	},

	get: function(attribute) {
		return overriddenGet(this,attribute);
	},

	formatData: function(ingroup) {
		return {
			'code': this.get('CodigoDisciplina'),
			'name': this.get('NomeDisciplina'),
			'credits': this.get('Creditos'),		
			'able': this.get('Apto'),
			'status': this.get('Situacao'),
			'ingroup': ingroup,
			'chosen': selectedModel.isSelected(this.get('CodigoDisciplina'))
		};
	}
});

SubjectList = Backbone.Collection.extend({
	model: SubjectModel,

	add: function(models, options) {
		return overriddenAdd(this, models, options,
			'CodigoDisciplina');
	},

	getClass: function(classId) {
		return classMap[classId];
	}
})

var subjectList = new SubjectList();
