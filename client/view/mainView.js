var MainView = Backbone.View.extend({
	el: 'body',

	initJQueryUI: function() {
		var me=this;

		$("#main-sidebar-div").resizable({
			handles: 'e, w',
			maxWidth: 0.75*$(window).width(),
			minWidth: 0.25*$(window).width(),
			containment: "parent",
		});	
	},

	render: function() {
		var template = _.template($("#main-template").html(),
			{faltaCursarTabStr: 'Falta Cursar',
			microHorarioTabStr: 'Micro Horario',
			selectedTabStr: 'Selecionadas'});
		this.$el.html(template);
		
		this.initJQueryUI();
	}
});

var mainView = new MainView();
