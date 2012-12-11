var ClasseslistView = Backbone.View.extend({
	template: '',
	el: '',
	subjectInfo: '',

	//Cached
	classesDatatable: '',
	classesTableHead: '',
	lassesTableBody: '',

	events: {
		'click .dataTables_scrollBody tr': 'clickOnClass'
	},

	clickOnClass: function(e) {
		var row = $(e.target).parent('tr');
		
		if ($(row).hasClass('subjectBlocked'))
			return;
		if ($(row).hasClass('subjectDisabled'))
			return;

		var subjectCode = $(row).find('input[type="hidden"][name="subjectCode"]').attr('value');
		var classId = $(row).find('input[type="hidden"][name="classId"]').attr('value');

		if ($(row).hasClass('classChosen')) {
			$(row).removeClass('classChosen');
			selectedModel.removeClass(subjectCode,classId);
		}
		else {
			$(row).addClass('classChosen');
			selectedModel.addClass(subjectCode,classId);
		}
	},

	changeRow: function(subjectCode, classId, select) {
		this.$el.find('tr').each(function() {		
			var _subjectCode = $(this).find('input[type="hidden"][name="subjectCode"]').attr('value');
			var _classId = $(this).find('input[type="hidden"][name="classId"]').attr('value');	

			if (_subjectCode==subjectCode && _classId==classId) {
				if (select) $(this).addClass('classChosen');
				else $(this).removeClass('classChosen');
			}
		});
	},

	markChosenRows: function() {
		var ch = selectedModel.getData();

		for (var i=0; i<selectedModel.maxRows; i++)
			for (var j=0; j<selectedModel.nOptions; j++)
				if (ch[i][j]) this.changeRow(ch[i][j].subjectCode, ch[i][j].classId, true);
	},

	cache: function() {
		this.classesTableHead = this.$('.dataTables_scrollHead');
		this.classesTableBody = this.$('.dataTables_scrollBody');
	},

	resize: function() {
		this.classesDatatable.fnDraw(false);
	},

	calculateTableScroll: function() {},

	initialize: function() {
		this.template = _.template($('#classeslist-template').html());
	},

	initJS: function() {		
		var me = this;

		this.classesDatatable = this.$el.find('table').dataTable({			
			'sDom': this.options.sDom,
			'bPaginate': false,
			'bScrollCollapse': true,
			'sScrollY': '100px',
			'bSort': false,
			'fnDrawCallback': function(oSettings) {
				me.calculateTableScroll();
			}
		});
	},

	render: function(classesArray) {
		this.$el.html(this.template({
			classes: classesArray,
			classesTableStr: classesTableStringsModel,
			subjectInfo: this.subjectInfo
		}));	

		this.initJS();
		this.cache();
		this.calculateTableScroll();
		this.markChosenRows();
	}
});

var MicrohorarioClasseslistView = ClasseslistView.extend({
	subjectInfo: true,

	calculateTableScroll: function() {
		var h=0;
		if (!$('#microhorario-filter').hasClass('hidden'))
			h+=$('#microhorario-filter').outerHeight(true);
		h+=$('#microhorario-togglefilter').outerHeight(true);
	
		var diff = $(this.el).outerHeight(true)-$(this.el).height();
		var totH = $(this.el).parent().height()-h-diff;
	
		$(this.el).height(totH);
		var headH = $(this.classesTableHead).outerHeight();
		$(this.classesTableBody).height(totH-headH);
	}
});
var microhorarioClasseslistView = new MicrohorarioClasseslistView({sDom: 't'});

var FaltacursarClasseslistView = ClasseslistView.extend({
	subjectInfo: false,

	calculateTableScroll: function() {
		var h = this.$el.height();
		var headerH= this.$el.find('.dataTables_filter').outerHeight(true)+
			$(this.classesTableHead).outerHeight(true);
		var diff = $(this.classesTableBody).outerHeight(true)-
			$(this.classesTableBody).height();

		$(this.classesTableBody).height(h-headerH-diff);
	},
});
var faltacursarClasseslistView = new FaltacursarClasseslistView({sDom: 'ft'});
