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
		var me = this;

		$(window).resize(function() {
			me.setTimetableWFromSidebarW();
		});
	},

	//All the -1 in the widths of this function are due to
	//jquery flooring its float – damn you, jquery
	setTimetableWFromSidebarW: function() {
		var w = $(".row-fluid").width();
		
		var sideW = $('#main-sidebar-div').outerWidth(true);
		var inSideW = $('#main-sidebar-div').width();			
		
		var timeW = $('#main-timetable-div').outerWidth(true);
		var inTimeW = $('#main-timetable-div').width();
		
		var nW = w-sideW;	
		$('#main-timetable-div').width(nW-(timeW-inTimeW)-1);
	
		if ($('#main-timetable-div').width()<
			$('#main-timetable-div table').width()) {
			nW = w-timeW;
			
			$('#main-timetable-div').width(inTimeW);
			$('#main-sidebar-div').width(nW-(sideW-inSideW)-1);
		}
	},

	initJS: function() {
		var me = this;
		var tabsW = 0;

		$('#main-sidebar-div li').each(function() {
			tabsW+=$(this).outerWidth();
		});
			
		$("#main-sidebar-div").resizable({
			handles: 'e, w',
			minWidth: tabsW,
			containment: "parent",
			resize: me.setTimetableWFromSidebarW
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

		faltacursarView.resizeWhole();
	},	

	render: function() {
		this.$el.html(this.template({tabs: this.tabs}));

		this.renderSubviews();
		this.rendered=true;

		this.initJS();
		this.setTimetableWFromSidebarW();
	}
});

var mainView = new MainView();
