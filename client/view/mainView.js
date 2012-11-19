var MainView = Backbone.View.extend({
	el: 'body',
	template: '',

	initialize: function() {
		this.template = _.template($('#main-template').html());
	},

	initJQueryUI: function() {
		var me=this;

		$("#main-sidebar-div").resizable({
			handles: 'e, w',
			maxWidth: 0.6*$(window).width(),
			minWidth: 0.25*$(window).width(),
			containment: "parent",

			resize: function(e, ui) {
				var w = $(".row-fluid").width();
				var nW = w-$('#main-sidebar-div').outerWidth();
				$('#main-timetable-div').width(nW);
			}
		});	
	},

	initJS: function() {
		this.initJQueryUI();
	},

	fetchStrings: function() {
		return {faltaCursarTabStr: 'Falta Cursar',
			microHorarioTabStr: 'Micro Horario',
			selectedTabStr: 'Selecionadas'};
	},

	renderSubviews: function() {
		timetableView.setElement('#main-timetable-div');
		timetableView.render();

		faltacursarView.setElement('#main-faltacursar-div');
		faltacursarView.render();

		microhorarioView.setElement('#main-microhorario-div');
		microhorarioView.render([],
			microhorarioView.noQueryStatus);

		selectedView.setElement('#main-selected-div');
		selectedView.render();
	},

	render: function() {
		this.$el.html(this.template(this.fetchStrings()));
		this.renderSubviews();
	}
});

var mainView = new MainView();
