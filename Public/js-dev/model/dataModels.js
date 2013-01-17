var HorariosModel = Backbone.Model.extend({
	get: function(attribute) {
		return overriddenGet(this,attribute);
	},

	printHorario: function() {
		var daysAbbr=classesTableStringsModel.get('daysAbbr');	
		if (this.get('DiaSemana'))
			return daysAbbr[this.get('DiaSemana')-2]+' '
				+this.get('HoraInicial')+'-'+this.get('HoraFinal')+
				' ('+this.get('Unidade')+');';
		return classesTableStringsModel.get('SHF')+' ('+this.get('Unidade')+');';
	}
});

var HorariosList = Backbone.Collection.extend({
	model: HorariosModel
});

var BlockModel = Backbone.Model.extend({
	get: function(attribute) {
		return overriddenGet(this,attribute);
	},

	printBlock: function() {
		return this.get('Destino')+' ('+this.get('Vagas')+' '+
			classesTableStringsModel.get('placesStr')+');';
	}
});

var BlocksList = Backbone.Collection.extend({
	model: BlockModel
});

var ClassModel = Backbone.Model.extend({
	initialize: function() {
		var horariosArray = this.get('Horarios');
		var horariosList = new HorariosList(horariosArray);
		this.set(serverDictionary.get('Horarios'),horariosList);
	
		var blocksArray = this.get('Destinos');
		var blocksList = new BlocksList(blocksArray);
		this.set(serverDictionary.get('Destino')+'s',blocksList);
	},

	get: function(attribute) {
		if (attribute=='Destinos') {
			var chAttr = serverDictionary.get('Destino')+'s';
			return Backbone.Model.prototype.get.call(this,chAttr);
		}

		return overriddenGet(this,attribute);
	},

	printSchedule: function() {
		var div = document.createElement('div');
		
		_.each(this.get('Horarios').models, function(horario) {
			var span=document.createElement('span');
			span.innerHTML=horario.printHorario();

			div.appendChild(span);
			div.appendChild(document.createElement('br'));
		});

		return div.innerHTML;
	},

	printBlocks: function() {
		var div = document.createElement('div');
		
		_.each(this.get('Destinos').models, function(block) {
			var span=document.createElement('span');
			span.innerHTML=block.printBlock();

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
	},

	getClass: function(subjectCode, classId) {
		return this.get(subjectCode).get('Turmas').get(classId);
	}
})

var subjectList = new SubjectList();
