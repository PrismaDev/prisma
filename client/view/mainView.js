var MainView = Backbone.View.extend({
	el: 'body',

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

	fetchTemplates: function() {
		return  {timetableTemplate: timetableView.returnTemplate(),
			faltacursarTemplate: faltacursarView.returnTemplate(),
			selectedTemplate: selectedView.returnTemplate(),
			microhorarioTemplate: microhorarioView.returnTemplate()};
	},

	fetchData: function() {
		var data = $.extend({}, this.fetchTemplates(),
			this.fetchStrings());
		return data;
	},

	render: function() {
		var template = _.template($("#main-template").html(),
			this.fetchData());
		this.$el.html(template);
	}
});

var mainView = new MainView();
