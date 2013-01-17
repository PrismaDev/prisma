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

var classMap = {};

var ClassModel = Backbone.Model.extend({
	initialize: function() {
		var horariosArray = this.get('Horarios');
		var horariosList = new HorariosList(horariosArray);
		this.set(serverDictionary.get('Horarios'),horariosList);
	
		var blocksArray = this.get('Destinos');
		var blocksList = new BlocksList(blocksArray);
		this.set(serverDictionary.get('Destino')+'s',blocksList);

		classMap[this.get('PK_Turma')]=this;
	},

	get: function(attribute) {
		if (attribute=='Destinos') {
			var chAttr = serverDictionary.get('Destino')+'s';
			return Backbone.Model.prototype.get.call(this,chAttr);
		}

		var res=overriddenGet(this,attribute);

		if (!res) res=overriddenGet(Backbone.Model.prototype.get.call(this, 'subject'),
			attribute);
		return res;
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
	},

	formatData: function() {
		return {
			'subjectCode': this.get('CodigoDisciplina'),
			'subjectName': this.get('NomeDisciplina'),
			'professorName': this.get('NomeProfessor'),
			'code': this.get('CodigoTurma'),
			'schedule': this.printSchedule(),
			'block': this.printBlocks(),
			'subjectCode': this.get('CodigoDisciplina'),
			'classId': this.get('PK_Turma'),
			'status': this.get('Situacao'),
			'able': this.get('Apto')
		};
	}
});

ClassList = Backbone.Collection.extend({
	model: ClassModel,

	add: function(models, options) {
		if (!options.subject) {
			console.log('Must provide subject for class');
			return;
		}
		
		var add = {subject: options.subject};
		return overriddenAdd(this, models, options, 'PK_Turma', add);
	}
});
