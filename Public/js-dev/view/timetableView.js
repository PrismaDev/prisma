var TimetableView = Backbone.View.extend({
	template: '',
	startH: 7,
	endH: 23,
	ndays: 6,

	initialize: function() {
		this.template = _.template($('#timetable-template').html());
	},

	buildTableBody: function(classArray) {
		var tbody = document.createElement('tbody');

		for (var hour=this.startH; hour<this.endH; hour++) {
			var tr = document.createElement('tr');
			$(tr).append('<td>'+hour+':00</td>');

			for (var day=0; day<this.ndays; day++)
				$(tr).append('<td></td>');
			$(tbody).append(tr);
		}

		return $(tbody).html();
	},

	fetchData: function() {
		return {days: ['Segunda', 'Terca', 'Quarta', 'Quinta',
				'Sexta', 'Sabado'],
				startH: 7, endH: 23,
				timetableBody: this.buildTableBody()		
			};
	},

	returnTemplate: function() {
		var template = _.template($('#timetable-template').html(),
			this.fetchData());
		return template;
	},

	render: function() {
		this.$el.html(this.template(this.fetchData()));
	}
});

var timetableView = new TimetableView();