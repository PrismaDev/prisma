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
			'ingroup': ingroup
		};
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

	getClass: function(classId) {
		return classMap[classId];
	}
})

var subjectList = new SubjectList();
