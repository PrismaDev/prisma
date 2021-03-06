function SelectedController() {
	var collidesTime = function(class1Model, class2Model) {
		var times1 = class1Model.get('Horarios').models;
		var times2 = class2Model.get('Horarios').models;

		var gud = true;
		for(var time1Idx in times1)
		{
			var time1 = times1[time1Idx];
			if (!time1.get('DiaSemana'))
				continue;

			for(var time2Idx in times2)
			{
				var time2 = times2[time2Idx];
				if (!time2.get('DiaSemana'))
					continue;

				if(time1.get('DiaSemana') == time2.get('DiaSemana'))
				{
					var hi1, hi2, hf1, hf2;
					hi1 = time1.get('HoraInicial');
					hi2 = time2.get('HoraInicial');
					hf1 = time1.get('HoraFinal');
					hf2 = time2.get('HoraFinal');
					if(hi1 > hi2)
					{
						var s = hi1;
						hi1 = hi2;
						hi2 = s;

						s = hf1;
						hf1 = hf2;
						hf2 = s;
					}

					if(hf1 > hi2)
					{
						gud = false;
						break;
					}
				}
			}
			if(!gud) break;
		}
		return !gud;
	}

	this.runSimulation = function(rowIdx) {
		var accepted= new Array();

		if(rowIdx == undefined || rowIdx < 0) rowIdx = -1;

		var rows = $('#main-selected-div tbody tr');
		var rowCount = 0;
		var creditos = 0;

		_.each(rows, function(row){
			if(rowCount > rowIdx)
			{
				$(row).find('input[type="radio"]').first().attr('checked', true);
			}

			while(1)
			{
				var radioValue = $(row).find('input[type="radio"]:checked').attr('value');

				if(radioValue == 'none')
				{
					break;
				}

				var option = $(row).find('input[type="radio"]:checked').parent('td').next();

				if($(option).find('div').length != 0)
				{
					var classId = $(option).find('input[type="hidden"][name="classCode"]').attr('value');
					var subjectCode = $(option).find('input[type="hidden"][name="subjectCode"]').attr('value');
					var vacancies = $(option).find('input[type="hidden"][name="vacancies"]').attr('value');
					var rank = $(option).find('input[type="hidden"][name="rank"]').attr('value');
					var classModel = subjectList.get(subjectCode).get('Turmas').get(classId);
					var subjectCreditos = subjectList.get(subjectCode).get('Creditos');
					
					var gud = true;
					for(var classIdx in accepted)
					{
						var times = classModel.get('Horarios');					
						var accClassModel = subjectList.getClass(accepted[classIdx].classId);	

						if(subjectCode == accepted[classIdx].subjectCode || collidesTime(classModel, accClassModel))
						{
							gud = false;
							break;
						}
					}

					if(gud && (creditos+subjectCreditos)<=30)
					{
						var cssClass="";
						for (var i=0; i<selectedModel.maxRows; i++)
							if ($(row).hasClass('row'+i)) {
								cssClass=i;
								break;
							}

						creditos += subjectCreditos;

						accepted.push({
							classId: classId,
							subjectCode: subjectCode,
							cssClass: cssClass,
							vacancies: vacancies,
							rank: rank
						});
						break;
					}
				}

				$(option).next().find('input[type="radio"]').attr('checked',true);
			}

			rowCount++;
		});

		timetableView.render(accepted);
		selectedView.changeInfo(creditos,accepted.length);
	}

	var getValues = function(td) {
		if ($(td).find('div').length==0)
			return null;
		
		var classId = $(td).find('input[type="hidden"][name="classCode"]').attr('value');
		var subjectCode = $(td).find('input[type="hidden"][name="subjectCode"]').attr('value');
	
		return {'subjectCode': subjectCode, 'classId': classId,
			'classCode': subjectList.get(subjectCode).get('Turmas').get(classId).get('CodigoTurma')};
	}

	this.sortLines = function() {
		var state = new Array();
		for (var i=0; i<selectedModel.maxRows; i++)
			state[i]=new Array();

		var rows = $('#main-selected-div tbody tr');
		var i=0;

		_.each(rows, function(row) {
			var tds = $(row).find('.class-droppable');	
			var j=0;	

			_.each(tds, function(td) {
				state[i][j]=getValues(td);
				j++;
			});

			i++;
		});

		selectedModel.postAll(state);
	}

	this.swapPlaces = function(tdA, tdB) {
		var ai, bi, aj, bj;
		

		var rows = $('#main-selected-div tbody tr');
		ai = $(rows).index($(tdA).parent());			
		bi = $(rows).index($(tdB).parent());			

		aj = $($(tdA).parent().children('.class-droppable')).index(tdA);
		bj = $($(tdB).parent().children('.class-droppable')).index(tdB);

		selectedModel.swapContent(ai,aj,bi,bj);
	}	
}

var selectedController = new SelectedController();
