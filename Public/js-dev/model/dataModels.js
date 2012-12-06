ClassModel = Backbone.Model.extend({
	idAttribute: 'PK_Turma'
});

ClassList = Backbone.Collection.extend({
	model: ClassModel
});

SubjectModel = Backbone.Model.extend({
	idAttribute: 'CodigoDisciplina',

	initialize: function() {
		var classesArray = this.get('turmas');
		var classesList = new ClassList(classesArray);
		this.set('turmas',classesList);	
	}
});

SubjectList = Backbone.Collection.extend({
	model: SubjectModel
})

var subjectList = new SubjectList();
