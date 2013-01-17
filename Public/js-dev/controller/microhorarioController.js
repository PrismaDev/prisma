function MicrohorarioController() {
	var formEl = '#microhorario-form';
	var url = '/api/microhorario';
	var defaultQtd=10;
	var formquerystring;
	
	this.end=false;
	this.nextPage=0;

	var me=this;
	
	var completeQueryStr = function() {
		return formquerystring+'&Pagina='+me.nextPage+'&Quantidade='+
			defaultQtd;
	}

	this.fetchData = function(newSearch) {
		if (newSearch) {
			formquerystring = $(formEl).serialize();
			me.nextPage=0; me.end=false;
		}
		if (me.end) 
			return microhorarioClasseslistView.addNextPage(me.end);
		
		$.ajax({
			url: url,
			type: 'GET',
			data: completeQueryStr(),
			dataType: 'json',

			success: function(data) {
				if (newSearch)
					me.buildTable(data);
				else
					me.addRows(data);
				me.nextPage++;
			}
		});
	}
	
	var formatData = function(data) {
		subjectList.add(data[serverDictionary.get('Dependencia')]);
		var array = new Array();		

		_.each(data[serverDictionary.get('MicroHorario')], function(classO) {
			var subjectModel = subjectList.get(
				classO[serverDictionary.get('CodigoDisciplina')]
			);
			var classModel = subjectModel.get('Turmas')
				.get(classO[serverDictionary.get('PK_Turma')]);

			var object={
				'subjectCode': subjectModel.get('CodigoDisciplina'),
				'subjectName': subjectModel.get('NomeDisciplina'),
				'professorName' : classModel.get('NomeProfessor'),
				'schedule': classModel.printSchedule(),
				'block': classModel.printBlocks(),
				'code': classModel.get('CodigoTurma'),
				'classId': classModel.get('PK_Turma'),
				'status': subjectModel.get('Situacao'),
				'able': subjectModel.get('Apto')
			};

			array.push(object);
		});

		return array;
	}

	this.buildTable = function(data) {
		var array = formatData(data);	
		microhorarioView.changeState(microhorarioView.queryState,array);
	}

	this.addRows = function(data) {
		var array = formatData(data);
		
		if (array.length==0)	
			me.end=true;
		microhorarioClasseslistView.addNextPage(me.end,array);
	}
}

var microhorarioController = new MicrohorarioController();

function MicrohorarioValidator() {
	var me=this;

	this.getInt = function(value, length) {
		var nVal = "";

		for (var i=0; i<value.length; i++)
			if (!isNaN(value[i])) {
				nVal+=value[i];

				if (length>0 && nVal.length==length)
					break;
			}

		return nVal;
	}

	this.intMask = function(inputObj, length) {
		inputObj.value = me.getInt(inputObj.value, length);
	}

	this.hourMask = function(inputObj) {
		var val=inputObj.value;
		var colon=-1;

		for (var i=0; i<val.length; i++)
			if (val[i]==':') {
				colon=i;
				break;
			}
		
		if (colon>=0) val=val.substr(0,colon);
		inputObj.value = me.getInt(val, 2);
	}
}

var microhorarioValidator = new MicrohorarioValidator();
