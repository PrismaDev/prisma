var MainView = Backbone.View.extend({
	el: 'body',
	template: '',
	rendered: false,
	tabs: {'faltacursar': {
			'li': 'main-faltacursar-li',
			'div': 'main-faltacursar-div',
			'str': '',
			'href': '#faltacursar'
		}, 
		'microhorario': {
			'li': 'main-microhorario-li',
			'div': 'main-microhorario-div',
			'str': '',
			'href': '#microhorario'
		},
		'selected': {
			'li': 'main-selected-li',
			'div': 'main-selected-div',
			'str': '',
			'href': '#selected'
		}},

	defaultTab: 'faltacursar',		

	initialize: function() {
		this.template = _.template($('#main-template').html());
		this.fetchStrings();
	},

	initJS: function() {
		$("#main-sidebar-div").resizable({
			handles: 'e, w',
			maxWidth: 0.6*$(window).width(),
			minWidth: 0.25*$(window).width(),
			containment: "parent",

			resize: function(e, ui) {
				var w = $(".row-fluid").width();
				var nW = w-$('#main-sidebar-div').outerWidth();
				$('#main-timetable-div').width(nW-1);
					//the -1 is due to rounding problems
			}
		});	
	},

	setActiveTab: function(tab) {
		$('#main-tabs-nav li').removeClass('active');
		$('#main-tab-panes div').removeClass('active');

		$('#'+this.tabs[tab].li).addClass('active');
		$('#'+this.tabs[tab].div).addClass('active');
	},

	fetchStrings: function() {
		this.tabs.faltacursar.str='Falta Cursar';
		this.tabs.microhorario.str='Micro Horario',
		this.tabs.selected.str='Selecionadas';
	},

	renderSubviews: function() {
		timetableView.setElement('#main-timetable-div');
		timetableView.render();

		faltacursarView.setElement('#main-faltacursar-div');
		faltacursarView.render();

		microhorarioView.setElement('#main-microhorario-div');
		microhorarioView.render();

		selectedView.setElement('#main-selected-div');
		selectedView.render();
		
		this.equalMainDivsHeight();
	},

	equalMainDivsHeight: function() {
		var h = $('#main-timetable-div').height();
		$('#main-sidebar-div').height(h);

		var innerH = h-$('#main-tabs-nav').height();
		$('#main-faltacursar-div').height(innerH);
		$('#main-microhorario-div').height(innerH);
		$('#main-selected-div').height(innerH);
	},	

	render: function() {
		this.$el.html(this.template({tabs: this.tabs}));
		this.initJS();

		this.renderSubviews();
		this.rendered=true;
	}
});

var mainView = new MainView();
