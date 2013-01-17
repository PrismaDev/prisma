var TimetableView = Backbone.View.extend({
	template: '',
	startH: 7,
	endH: 23,
	ndays: 6,
	ttmat: '',

	initialize: function() {
		this.template = _.template($('#timetable-template').html());
	},

	bindCell: function(el) {
		$(el).click(function() {
			microhorarioView.searchFor($(el).data('day'),
				$(el).data('initTime'), $(el).data('subjectCode'));
		});
	},

	bindCallbacks: function() {
		var ths = this.$el.find('th');

		_.each(ths, function(th, index) {
			$(th).data({'day': (index==0? null: (index-1)+2), 'initTime': null});
		});

		var tds = this.$el.find('td');
		var cnt=0;		

		for (var hour=this.startH; hour<this.endH; hour++) {
			$(tds[cnt++]).data({'day': null, 'initTime': hour,
						'subjectCode': null});			

			for (var day=2; day<this.ndays+2; day++)
				if (this.ttmat[hour][day].span!=0) {	
					if (this.ttmat[hour][day].subjectCode!=null)
						$(tds[cnt++]).data({'subjectCode': this.ttmat[hour][day].subjectCode,
									'day': null, 'initTime': null});
					else
						$(tds[cnt++]).data({'day': day, 'initTime': hour,
									'subjectCode': null});	
				}
		}

		var cells = this.$el.find('td, th');
		var me=this;
		

		_.each(cells, function(cell) {
			me.bindCell(cell);
		})
	},

	formatString: function(timeIdx, classModel, subjectCode) {
		var unit=classModel.get('Horarios').models[timeIdx].get('Unidade');
		return subjectCode+' - '+classModel.get('CodigoTurma')+'<br/>'+
		'<span>'+subjectList.get(subjectCode).get('NomeDisciplina')+'</span><br/>'+
		'<span>('+unit+')</span>';
	},

	processArray: function(classesArray) {
		var timetableMatrix = new Array();

		for (var hour=this.startH; hour<this.endH; hour++) {
			timetableMatrix[hour] = new Array();

			for (var day=2; day<this.ndays+2; day++)
				timetableMatrix[hour][day] = {
					'string':'',
					'span': 1,
					'customClass': null,
					'subjectCode': null
				}
		}

		for (var i=0; i<classesArray.length; i++) {
			var classModel=subjectList.getClass(classesArray[i].classId);
			var h=classModel.get('Horarios').models;		

			for (var j=0; j<h.length; j++) {
				var d=h[j].get('DiaSemana');
				var s=h[j].get('HoraInicial');
				var e=h[j].get('HoraFinal');
			
				if (!d)
					continue;

				timetableMatrix[s][d].string=this.formatString(j,classModel,
					classesArray[i].subjectCode);
				timetableMatrix[s][d].span=Number(e)-Number(s);
				timetableMatrix[s][d].customClass='ttclass'+
					classesArray[i].cssClass;
				timetableMatrix[s][d].subjectCode=classesArray[i].subjectCode;

				for (var k=s+1; k<e; k++)
					timetableMatrix[k][d].span=0;
			}
		}

		return timetableMatrix;
	},

	buildTableBody: function(classesArray) {
		if (classesArray == undefined)
			classesArray=[];

		this.ttmat = this.processArray(classesArray);		
		var tbody = document.createElement('tbody');

		for (var hour=this.startH; hour<this.endH; hour++) {
			var tr = document.createElement('tr');
			var tdH = document.createElement('td');
			
			$(tdH).addClass('text-top');
			$(tdH).html(hour+':00');			

			$(tr).append(tdH);

			for (var day=2; day<this.ndays+2; day++) {
				if (this.ttmat[hour][day].span==0)
					continue;

				var td = document.createElement('td');
				var div = document.createElement('div');

				div.innerHTML = this.ttmat[hour][day].string;
				
				if (this.ttmat[hour][day].customClass)
					$(td).addClass(this.ttmat[hour][day].customClass);
			
				td.rowSpan=this.ttmat[hour][day].span;

				td.appendChild(div);
				tr.appendChild(td);
			}
			$(tbody).append(tr);
		}

		return $(tbody).html();
	},

	render: function(classesArray) {
		this.$el.html(this.template({
			timetableStr: timetableStringsModel
		}));
	
		this.$el.find('tbody').html(this.buildTableBody(classesArray));
		this.bindCallbacks();
		mainView.equalMainDivsHeight();
	}
});

var timetableView = new TimetableView();
