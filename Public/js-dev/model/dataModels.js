var HorariosModel = Backbone.Model.extend({
	get: function(attribute) {
		return overriddenGet(this,attribute);
	}
});

var HorariosList = Backbone.Collection.extend({
	model: HorariosModel
});

var ClassModel = Backbone.Model.extend({
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
		console.log(daysAbbr);
		
		_.each(this.get('Horarios').models, function(horario) {
			var span=document.createElement('span');
			console.log(horario);
			span.innerHTML=daysAbbr[horario.get('DiaSemana')-2]+' '
				+horario.get('HoraInicial')+'-'+horario.get('HoraFinal');
			div.appendChild(span);
			div.appendChild(document.createElement('br'));
		});

		return div.innerHTML;
	}
});

ClassList = Backbone.Collection.extend({
	model: ClassModel,

	add: function(models, options) {
		var me=this;
		var array=new Array();

		_.each(models, function(model) {
			if (typeof model == me.model)
				array.push(model);
			else {
				var idName = serverDictionary.get('PK_Turma');
				var nModel = new ClassModel($.extend({},
					{id: model[idName]},model));
				array.push(nModel);
			}
		});

		return Backbone.Collection.prototype.add.call(this,array,options);
	}
});

SubjectModel = Backbone.Model.extend({
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
	model: SubjectModel,

	add: function(models, options) {
		var me=this;
		var array=new Array();

		_.each(models, function(model) {
			if (typeof model == me.model)
				array.push(model);
			else {
				var idName = serverDictionary.get('CodigoDisciplina');
				var nModel = new SubjectModel($.extend({},
					{id: model[idName]},model));
				array.push(nModel);
			}
		});

		return Backbone.Collection.prototype.add.call(this,array,options);
	}
})

var subjectList = new SubjectList();
