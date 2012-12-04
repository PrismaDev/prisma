var MainView = Backbone.View.extend({
	el: 'body',
	mainTemplate: '',
	layoutTemplate: '',
	rendered: false,
	tabs: {'faltacursar': {
			'li': 'main-faltacursar-li',
			'div': 'main-faltacursar-div',
			'str': '',
			'href': '#faltacursar',
			'view': faltacursarView
		}, 
		'microhorario': {
			'li': 'main-microhorario-li',
			'div': 'main-microhorario-div',
			'str': '',
			'href': '#microhorario',
			'view': microhorarioView
		},
		'selected': {
			'li': 'main-selected-li',
			'div': 'main-selected-div',
			'str': '',
			'href': '#selected',
			'view': selectedView
		}},

	defaultTab: 'faltacursar',		
	
	childrenViews: [
		faltacursarView,
		timetableView,
		selectedView,
		microhorarioView
	],

	//Cached variables
	timetableDiv: '',
	sidebarDiv: '',
	timetableTable: '',
	container: '',
	tabsNav: '',

	testData: {
		'hiStr': 'Olá',
		'user': {'name': 'Bobteco da Silva'},
		'logoutStr': 'Logout',
		'loggedIn': true
	},

	initialize: function() {
		this.mainTemplate = _.template($('#main-template').html());
		this.layoutTemplate = _.template($('#layout-template').html());
		this.fetchStrings();
		var me = this;

		$(window).resize(function() {
			me.resizeH();
			me.resizeW();
		});
	},

	cache: function() {
		this.timetableDiv = $('#main-timetable-div');
		this.sidebarDiv = $('#main-sidebar-div');
		this.timetableTable = $('#main-timetable-div table');
		this.container = $('#container-div');
		this.tabsNav = $('#main-tabs-nav');
	},

	resizeW: function() {
		this.setTimetableWFromSidebarW();
		$.each(this.childrenViews, function(index, value) {
			value.resizeW();
		});
	},

	resizeH: function() {
		this.equalMainDivsHeight();
		$.each(this.childrenViews, function(index, value) {
			value.resizeH();
		});
	},

	//All the -1 in the widths of this function are due to
	//jquery flooring its floats – damn you, jquery

	setTimetableWFromSidebarW: function() {
		var w = $(this.container).width();
	
		var sideW = $(this.sidebarDiv).outerWidth(true);
		var inSideW = $(this.sidebarDiv).width();			
		
		var timeW = $(this.timetableDiv).outerWidth(true);
		var inTimeW = $(this.timetableDiv).width();
		
		var nW = w-sideW;	
		$(this.timetableDiv).width(nW-(timeW-inTimeW)-1);
		
		if ($(this.timetableDiv).width()<$(this.timetableTable).outerWidth(true)) {
			nW = w-timeW;			
			$(this.timetableDiv).width(inTimeW);
			$(this.sidebarDiv).width(nW-(sideW-inSideW)-1);
		}
	},

	initJS: function() {
		var me = this;
		var tabsW = 0;

		$(this.tabsNav).find('li').each(function() {
			tabsW+=$(this).outerWidth(true);
		});
		tabsW+=1 //another flooring problem
			
		$(this.sidebarDiv).resizable({
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
	
		this.tabs[tab].view.resizeW();
		this.tabs[tab].view.resizeH();
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
	},

	equalMainDivsHeight: function() {
		var h = $(this.timetableDiv).height();
		$(this.sidebarDiv).height(h);

		var innerH = h-$(this.tabsNav).height();
		faltacursarView.$el.height(innerH);
		microhorarioView.$el.height(innerH);
		selectedView.$el.height(innerH);
	},	

	render: function() {
		this.$el.html(this.layoutTemplate(this.testData));
		$('#content-div').html(this.mainTemplate({tabs: this.tabs}));
		
		this.renderSubviews();
		this.rendered=true;

		this.cache();
		this.initJS();

//		this.resizeH();
//		this.resizeW();
	}
});

var mainView = new MainView();
