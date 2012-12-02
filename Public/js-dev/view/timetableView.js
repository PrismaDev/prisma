var TimetableView = Backbone.View.extend({
	template: '',
	startH: 7,
	endH: 23,
	ndays: 6,

	testArray: [
		{
			'nome': 'A',
			'horarios': [
			{
				'diaSemana': 0,
				'horaInicial': 7,
				'horaFinal': 11
			},
			{
				'diaSemana': 2,
				'horaInicial': 7,
				'horaFinal': 11	
			}]
		},
		{
			'nome': 'B',
			'horarios': [
			{
				'diaSemana': 1,
				'horaInicial': 9,
				'horaFinal': 10
			},
			{
				'diaSemana': 2,
				'horaInicial': 13,
				'horaFinal': 15	
			}]
		}

	],

	initialize: function() {
		this.template = _.template($('#timetable-template').html());
	},

	processArray: function(classesArray) {
		var timetableMatrix = new Array();

		for (var hour=this.startH; hour<this.endH; hour++) {
			timetableMatrix[hour] = new Array();

			for (var day=0; day<this.ndays; day++)
				timetableMatrix[hour][day] = {
					'string':'',
					'span': 1,
					'customClass': null
				}
		}

		for (var i=0; i<classesArray.length; i++)
			for (var j=0; j<classesArray[i].horarios.length; j++) {
				var d=classesArray[i].horarios[j].diaSemana;
				var s=classesArray[i].horarios[j].horaInicial;
				var e=classesArray[i].horarios[j].horaFinal;

				timetableMatrix[s][d].string=classesArray[i].nome;
				timetableMatrix[s][d].span=Number(e)-Number(s);
				timetableMatrix[s][d].customClass='ttclass'+i;

				for (var k=s+1; k<e; k++) {
					timetableMatrix[k][d].span=0;
					timetableMatrix[k][d].customClass='ttclass'+i;
				}
			}

		return timetableMatrix;
	},

	buildTableBody: function(classesArray) {
		if (typeof classesArray == undefined)
			classesArray=[];

		var ttmat = this.processArray(classesArray);		
		var tbody = document.createElement('tbody');

		for (var hour=this.startH; hour<this.endH; hour++) {
			var tr = document.createElement('tr');
			$(tr).append('<td class="text-top">'+hour+':00</td>');

			for (var day=0; day<this.ndays; day++) {
				if (ttmat[hour][day].span==0)
					continue;

				var td = document.createElement('td');
				var div = document.createElement('div');

				div.innerHTML = ttmat[hour][day].string;
				
				if (ttmat[hour][day].customClass)
					$(td).addClass(ttmat[hour][day].customClass);
			
				td.rowSpan=ttmat[hour][day].span;

				td.appendChild(div);
				tr.appendChild(td);
			}
			$(tbody).append(tr);
		}

		return $(tbody).html();
	},

	resizeW: function() {},
	resizeH: function() {},

	fetchData: function(classesArray) {
		return {days: ['Segunda', 'Terca', 'Quarta', 'Quinta',
				'Sexta', 'Sabado'],
				startH: 7, endH: 23,
				timetableBody: 
					this.buildTableBody(classesArray)		
			};
	},

	render: function(classesArray) {
		if (!classesArray) classesArray = this.testArray;
		this.$el.html(this.template(this.fetchData(classesArray)));
	}
});

var timetableView = new TimetableView();
