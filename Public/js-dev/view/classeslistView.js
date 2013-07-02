var ClasseslistView = Backbone.View.extend({
	templateTable: '',
	templateRow: '',
	el: '',
	subjectInfo: '',

	//Cached
	classesDatatable: null,
	classesTableHead: '',
	classesTableBody: '',

	events: {
		'click .dataTables_scrollBody tr': 'clickOnClass'
	},

	clickOnClass: function(e) {
		var row = $(e.target).parents('tr');
		
//		if ($(row).hasClass('subjectBlocked'))
//			return;
		if ($(row).hasClass('subjectDisabled'))
			return;
		if ($(row.find('td').first()).hasClass('dataTables_empty'))
			return;

		var subjectCode = $(row).find('input[type="hidden"][name="subjectCode"]').attr('value');
		var classId = $(row).find('input[type="hidden"][name="classId"]').attr('value');

		if ($(row).hasClass('classChosen')) {
			$(row).removeClass('classChosen');
			selectedModel.removeClass(subjectCode,classId);

			if (selectedModel.get('addedSinceLastView')>0)
				selectedModel.set('addedSinceLastView',
					selectedModel.get('addedSinceLastView')-1);
		}
		else {
			$(row).addClass('classChosen');
			selectedModel.addClass(subjectCode,classId);
		
			selectedModel.set('addedSinceLastView',
				selectedModel.get('addedSinceLastView')+1);
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

	cache: function() {
		this.classesTableHead = this.$('.dataTables_scrollHead');
		this.classesTableBody = this.$('.dataTables_scrollBody');
	},

	resize: function() {
		if (this.classesDatatable)
			this.classesDatatable.fnDraw(false);
	},

	calculateTableScroll: function() {},

	initialize: function() {
		this.templateTable = _.template($('#classeslist-template').html());
		this.templateRow = _.template($('#classeslist-row-template').html());
	},

	initHelpers: function() {
		helpersList.get('ableClassRow').set('selector',
			'.dataTables_scrollBody tr:not(.subjectDisabled, .classChosen, \
			.subjectBlocked, .subjectWarning)');
		helpersList.get('chosenClassRow').set('selector',
			'.dataTables_scrollBody tr.classChosen');
		helpersList.get('warningClassRow').set('selector',
			'.dataTables_scrollBody tr.subjectWarning:not(.classChosen)');
		helpersList.get('blockedClassRow').set('selector',
			'.dataTables_scrollBody tr.subjectBlocked:not(.classChosen)');
		helpersList.get('disabledClassRow').set('selector',
			'.dataTables_scrollBody tr.subjectDisabled');
	},

	initJS: function() {
		var me = this;

		this.classesDatatable = this.$el.find('table').dataTable({			
			'sDom': this.options.sDom,
			'bPaginate': false,
			'bScrollCollapse': true,
			'sScrollY': '20000px', //equals inf 
			'bSort': false,
			'oLanguage': {
				'sEmptyTable': classesTableStringsModel.get('emptyTableStr'),
				'sSearch': faltacursarStringsModel.get('searchLabel')
			},
			'fnDrawCallback': function(oSettings) {
				me.calculateTableScroll();
			}
		});
//		this.initHelpers();
	},

	bindHelpers: function() {
		helperView.create('ableClassRow');
		helperView.create('chosenClassRow');
		helperView.create('warningClassRow');
		helperView.create('blockedClassRow');
		helperView.create('disabledClassRow');
	},

	addRowsToTable: function(classesArray) {
		for(idx in classesArray) {
			var newTr = this.templateRow({
					classO: classesArray[idx],
					classesTableStr: classesTableStringsModel,
					subjectInfo: this.subjectInfo
				});
			this.classesDatatable.fnAddTr($(newTr)[0],false);
		}
		
		this.classesDatatable.fnAdjustColumnSizing(true);
		this.bindHelpers();
	},

	render: function(classesArray) {
		this.$el.html(this.templateTable({
			classesTableStr: classesTableStringsModel,
			subjectInfo: this.subjectInfo
		}));	

		this.initJS();
		this.cache();
		
		this.addRowsToTable(classesArray);
		this.calculateTableScroll();
	}
});

var MicrohorarioClasseslistView = ClasseslistView.extend({
	subjectInfo: true,
	waitingData: false,
	waitingTemplate: '',
	alertTemplate: '',
	endOfDataMsg: false,

	initialize: function() {
		this.templateTable = _.template($('#classeslist-template').html());
		this.templateRow = _.template($('#classeslist-row-template').html());
		this.waitingTemplate = _.template($('#microhorario-waiting-template').html());
		this.alertTemplate = _.template($('#microhorario-end-of-data-template').html());
	},

	events: {
		'click .dataTables_scrollBody tr': 'clickOnClass',
		'click .dataTables_scrollBody tr .ementaButton': 'clickOnEmenta'
	},

	clickOnEmenta: function(e) {
		e.stopPropagation();
	},

	addNextPage: function(end, data) {
		$(this.classesTableBody).find('div').remove();
		
		if (end) {
			$(this.classesTableBody).append(this.alertTemplate({
				str: microhorarioStringsModel
			}));
			this.endOfDataMsg=true;
		}
		else {
			var tableScrollTop = $(this.classesTableBody).scrollTop();
			this.addRowsToTable(data);	
			$(this.classesTableBody).scrollTop(tableScrollTop);
		}

		this.waitingData=false;
	},

	bindEndOfScroll: function() {
		var me=this;

		this.$el.find('.dataTables_scrollBody').scroll(function() {
			if (!$(this).scrollTop())
				return;
			if($(this).scrollTop() + $(this).innerHeight()
					== $(this)[0].scrollHeight) {

				if (me.waitingData) return;
			
				me.waitingData=true;
				var div = document.createElement('div');
				$(div).html(me.waitingTemplate({
					str: microhorarioStringsModel 
				}));
				
				$(me.classesTableBody).append(div);
				microhorarioController.fetchData(false);
			}
		});
	},

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

		this.bindEndOfScroll();
	}
});
var microhorarioClasseslistView = new MicrohorarioClasseslistView({sDom: 't'});

var FaltacursarClasseslistView = ClasseslistView.extend({
	subjectInfo: false,

	calculateTableScroll: function() {
		var h = this.$el.parent().height();
		var closeButtonH = this.$el.parent().find('#close-classes-div')
				.outerHeight(true);
		var headerH= this.$el.find('.dataTables_filter').outerHeight(true)+
			$(this.classesTableHead).outerHeight(true);
		var diff = $(this.classesTableBody).outerHeight(true)-
			$(this.classesTableBody).height();

		var calcH=h-headerH-closeButtonH-diff;

		if (calcH<$(this.classesTableBody).height())
			$(this.classesTableBody).height(calcH);
	}
});
var faltacursarClasseslistView = new FaltacursarClasseslistView({sDom: 'ft'});
