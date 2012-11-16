var MainView = Backbone.View.extend({
	el: 'body',

	adjustSizes: function() {
		var h = $(window).height();
		var w = $(window).width();

		var headerH = $("#main-header-div").height();
		var footerH = $("#main-footer-div").height();

		var middleH = h-headerH-footerH;
		
		$("#main-sidebar-div").css('top', parseFloat(headerH)+'px');
		$("#main-timetable-div").css('top', parseFloat(headerH)+'px');
	
		$("#main-sidebar-div").css('bottom', parseFloat(footerH)+'px');
		$("#main-timetable-div").css('bottom', parseFloat(footerH)+'px');	
	},

	initialize: function() {
		$(window).resize(this.adjustSizes);
	},

	render: function() {
		var template = _.template($("#main-template").html(),
			{faltaCursarTabStr: 'Falta Cursar',
			microHorarioTabStr: 'Micro Horario',
			selectedTabStr: 'Selecionadas'});
		this.$el.html(template);
//		this.adjustSizes();
	}
});

var mainView = new MainView();
