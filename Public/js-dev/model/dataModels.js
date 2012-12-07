ClassModel = Backbone.Model.extend({
	idAttribute: 'PK_Turma',
	
	printSchedule: function() {
		var div = document.createElement('div');
		var daysAbbr=classesTableStringsModel.get('daysAbbr');

		_.each(this.get('Horarios'), function(horario) {
			var span=document.createElement('span');
			span.innerHTML=daysAbbr[horario.DiaSemana-2]+' '
				+horario.HoraInicial+'-'+horario.HoraFinal+'<br/>';
			div.appendChild(span);
		});

		return div.innerHTML;
	}
});

ClassList = Backbone.Collection.extend({
	model: ClassModel
});

SubjectModel = Backbone.Model.extend({
	idAttribute: 'CodigoDisciplina',

	initialize: function() {
		var classesArray = this.get('Turmas');
		var classesList = new ClassList(classesArray);
		this.set('Turmas',classesList);	
	}
});

SubjectList = Backbone.Collection.extend({
	model: SubjectModel
})

var subjectList = new SubjectList();
