var MainView = Backbone.View.extend({
	el: 'body',
	mainTemplate: '',
	layoutTemplate: '',
	rendered: false,
	tabs: {'faltacursar': {
			'li': 'main-faltacursar-li',
			'div': 'main-faltacursar-div',
			'href': '#faltacursar',
			'view': faltacursarView
		}, 
		'microhorario': {
			'li': 'main-microhorario-li',
			'div': 'main-microhorario-div',
			'href': '#microhorario',
			'view': microhorarioView
		},
		'selected': {
			'li': 'main-selected-li',
			'div': 'main-selected-div',
			'href': '#selected',
			'view': selectedView
		}},

	defaultTab: 'faltacursar',		

	//Cached variables
	timetableDiv: '',
	sidebarDiv: '',
	tabsNav: '',

	initialize: function() {
		this.mainTemplate = _.template($('#main-template').html());
		this.layoutTemplate = _.template($('#layout-template').html());
		var me = this;
	
		$(window).resize(function() {
			me.equalMainDivsHeight();
		});
	},

	cache: function() {
		this.timetableDiv = document.getElementById('main-timetable-div');
		this.sidebarDiv = document.getElementById('main-sidebar-div');
		this.tabsNav = document.getElementById('main-tabs-nav');
	},

	equalMainDivsHeight: function() {
		var h = $(this.timetableDiv).height();
		$(this.sidebarDiv).height(h);

		var innerH = h-$(this.tabsNav).height();
		faltacursarView.$el.height(innerH);
		microhorarioView.$el.height(innerH);
		selectedView.$el.height(innerH);
	},	

	setActiveTab: function(tab) {
		$('#main-tabs-nav li').removeClass('active');
		$('#main-tab-panes div').removeClass('active');

		$('#'+this.tabs[tab].li).addClass('active');
		$('#'+this.tabs[tab].div).addClass('active');
	
		this.tabs[tab].view.resize();
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

	render: function() {
		this.$el.html(this.layoutTemplate({
			layoutStr: layoutStringsModel,
			loggedIn: true
		}));
		$('#content-div').html(this.mainTemplate({
			tabs: this.tabs,
			mainStr: mainStringsModel
		}));
		
		this.renderSubviews();
		this.rendered=true;

		this.cache();
		this.equalMainDivsHeight();
	}
});

var mainView = new MainView();
