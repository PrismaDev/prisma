var HorariosModel = Backbone.Model.extend({
	get: function(attribute) {
		return overriddenGet(this,attribute);
	}
});

var HorariosList = Backbone.Collection.extend({
	model: HorariosModel
});

var ClassModel = Backbone.Model.extend({
	idAttribute: serverDictionary.get('PK_Turma'),

	initialize: function() {
		var horariosArray = this.get('Horarios');
		var horariosList = new HorariosList(horariosArray);
		this.set(serverDictionary.get('Horarios'),horariosList);
	},

	get: function(attribute) {
		return overriddenGet(this,attribute);
	},

	printSchedule: function() {
		var div = document.createElement('div');
		var daysAbbr=classesTableStringsModel.get('daysAbbr');
		
		_.each(this.get('Horarios').models, function(horario) {
			var span=document.createElement('span');
			span.innerHTML=daysAbbr[horario.get('DiaSemana')-2]+' '
				+horario.get('HoraInicial')+'-'+horario.get('HoraFinal');
			div.appendChild(span);
			div.appendChild(document.createElement('br'));
		});

		return div.innerHTML;
	}
});

ClassList = Backbone.Collection.extend({
	model: ClassModel
});

SubjectModel = Backbone.Model.extend({
	idAttribute: serverDictionary.get('CodigoDisciplina'),

	initialize: function() {
		var classesArray = this.get('Turmas');
		var classesList = new ClassList(classesArray);
		this.set(serverDictionary.get('Turmas'),classesList);	
	},

	get: function(attribute) {
		return overriddenGet(this,attribute);
	}
});

SubjectList = Backbone.Collection.extend({
	model: SubjectModel
})

var subjectList = new SubjectList();
