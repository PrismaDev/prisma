var FaltacursarView = Backbone.View.extend({
	template: '',
	templateRow: '',
	subjectDatatableView: '',

	//Optativas images
	closedImg: 'Setinha Mini copy.PNG',
	openImg: 'Setinha Mini.PNG',
	defaultImgPath: 'img/',

	//Cached variables
	subjectTableWrapper: '',
	classesDiv: '',
	subjectTable: '',
	subjectDatatable: '',
	subjectTableFilter: '',
	subjectTableHeader: '',	
	subjectTableBody: '',	

	initialize: function() {
		this.template = _.template($('#faltacursar-template').html());
		this.templateRow = _.template($('#faltacursar-row-template').html());

		var me=this;
		$(window).resize(function() {
			me.resize();
		});
	},

	cache: function() {
		this.subjectTableWrapper = $('#faltacursar-subject-table_wrapper');
		this.classesDiv = $('#faltacursar-classes-div');
		this.subjectTable = $('#faltacursar-subject-table');
		this.subjectTableFilter = $('#faltacursar-subject-table_wrapper\
					 .dataTables_filter');
		this.subjectTableHeader = $('#faltacursar-subject-table_wrapper\
					 .dataTables_scrollHead');
		this.subjectTableBody = $('#faltacursar-subject-table_wrapper\
					 .dataTables_scrollBody');
	},

	events: {
		"click #faltacursar-subject-table tr": 'clickOnRow',
		"click #faltacursar-subject-table .ementaButton": 'clickOnEmenta',
		"click #close-classes-button" : 'clickOnCloseClasses'
	},

	handleOptativa: function(row) {
		var codOpt = $(row).attr('id');
		var nRows = faltacursarModel.getSubjectsOptativa(codOpt);		
		var rowIdx = this.subjectDatatable.fnGetPosition($(row)[0]);

		if ($(row).hasClass('openOptativa')) {
			$(row).removeClass('openOptativa');
			$(row).find('td.imgCell img').attr('src',this.defaultImgPath+
				this.closedImg);			
			var tmpRow=$(row);
		
			for (var i=0; i<nRows.length; i++) { 
				if ($(tmpRow).next().hasClass('subjectSelected'))
					this.closeClassesDiv();
				this.subjectDatatable.fnDeleteRow(rowIdx+1,null,false);

				//to speed things up, Im not redrawing the table each time,
				//so I need to iterate with tmpRow to go through the entire
				//list of rows, since the html isnt being rewritten

				tmpRow=$(tmpRow).next();
			}
			this.subjectDatatable.fnDraw();
		}
		else {
			$(row).addClass('openOptativa');
			$(row).find('td.imgCell img').attr('src',this.defaultImgPath+
				this.openImg);			
			nRows.reverse();		

			this.addRowsToTable(nRows,rowIdx);
			$(row).next().addClass('extraBorder');
		}
		
		this.calculateScrollTop(row);
	},

	clickOnCloseClasses: function() {
		$(this.subjectTable).find('tr.subjectSelected').removeClass('subjectSelected');
		this.closeClassesDiv();
	},

	changeOptativaLabel: function(codOpt, n) {
		var optLabel = $('#'+codOpt).find('.selected-label');
		$(optLabel).html(n+' '+subjectTableStringsModel.get('nOptativasChosenStr'));	

		if (n) $(optLabel).removeClass('hidden');
		else $(optLabel).addClass('hidden');
	},

	markAsSelected: function(subjectCode, isSelected) {
		row = $('#'+subjectCode);

		if (!isSelected)
			$(row).find('.name .selected-label').addClass('hidden');
		else 
			$(row).find('.name .selected-label').removeClass('hidden');
	},

	closeClassesDiv: function() {
		$(this.subjectTableWrapper).addClass('whole')
						.removeClass('half');
		this.calculateTableScroll();		
		$(this.classesDiv).addClass('hidden');
	},

	clickOnRow: function(e) {
		var row=$(e.target).parents('tr');

		if ($(row).hasClass('optativa'))
			return this.handleOptativa(row);

		if ($(row.find('td').first()).hasClass('dataTables_empty'))
			return;

		if ($(row).hasClass('subjectSelected')) {
			$(row).removeClass('subjectSelected');
        		this.closeClassesDiv();	
		}
		else {
			$(this.subjectTable).find('tr.subjectSelected')
				.removeClass('subjectSelected');
			$(row).addClass('subjectSelected');
			
			$(this.subjectTableWrapper).addClass('half')
						.removeClass('whole');
			this.calculateTableScroll();		

        		$(this.classesDiv).removeClass('hidden');
			$(this.classesDiv).addClass('almostHalf');				

			var id=$(row).attr('id');

			var classModel = faltacursarModel.getSubjectClasses(id).sort(
				function(a,b)
				{
					if(a.code > b.code) return 1;
					if(a.code < b.code) return -1;
					return 0;
				});
			faltacursarClasseslistView.render(
				classModel	
			);
			faltacursarClasseslistView.resize();
		}
	},

	clickOnEmenta: function(e) {
		e.stopPropagation();
	},

	resize: function() {
		if (!this.subjectDatatable)
			this.subjectDatatable = $('#faltacursar-subject-table').dataTable();
		this.subjectDatatable.fnAdjustColumnSizing(false);
		this.calculateTableScroll();
	},

	calculateScrollTop: function(row) {
		var rIndex = this.subjectDatatable.fnGetPosition($(row)[0]);
		var w=0;

		$(this.subjectTableBody).find('tr').slice(0,rIndex+1).each(function(index) {
			w+=$(this).height();
		});

		$(this.subjectTableBody).scrollTop(w);
	},

	calculateTableScroll: function() {
		var h = $(this.subjectTableWrapper).height();				
		var headerH = $(this.subjectTableFilter).outerHeight(true)+
			$(this.subjectTableHeader).outerHeight(true);

		var notHeight = $(this.subjectTableBody).outerHeight(true)-
			$(this.subjectTableBody).height();
		$(this.subjectTableBody).height(h-headerH-notHeight);
	
	},

	initHelpers: function() {
		helpersList.get('ableSubjectRow').set('selector',
			'#faltacursar-subject-table tr:not(.optativa,.subjectWarning, \
			.subjectBlocked, .subjectSelected)');
		helpersList.get('optativaRow').set('selector',
			'#faltacursar-subject-table tr.optativa');
		helpersList.get('blockedSubjectRow').set('selector',
			'#faltacursar-subject-table tr.subjectBlocked:not(.subjectSelected)');
		helpersList.get('warningSubjectRow').set('selector',
			'#faltacursar-subject-table tr.subjectWarning:not(.subjectSelected)');
	},

	bindHelpers: function() {
		helperView.create('ableSubjectRow');
		helperView.create('optativaRow');
		helperView.create('warningSubjectRow');
		helperView.create('blockedSubjectRow');
	},

	initJS: function() {
		var me = this;

		this.subjectDatatable = $('#faltacursar-subject-table').dataTable({
			'sDom': 'ft',
			'bPaginate': false,
			'bScrollCollapse': true,
			'sScrollY': '200px',
			'bSort': false,
			'oLanguage': {
				'sZeroRecords': subjectTableStringsModel.get('noResultsStr'),
				'sSearch': faltacursarStringsModel.get('searchLabel')
			},
			'fnDrawCallback': function(oSettings) {
				me.calculateTableScroll()
			}
		});
		
		$('#faltacursar-subject-table_wrapper').addClass('whole');	
		this.initHelpers();
	},		

	addRowsToTable: function(subjectArray, prevRow) {
		for(idx in subjectArray) {
			var newTr = this.templateRow({
					subject: subjectArray[idx],
					subjectTableStr: subjectTableStringsModel
				});

			if (prevRow==undefined)
				this.subjectDatatable.fnAddTr($(newTr)[0],false);
			else
				this.subjectDatatable.fnAddTrAfter($(newTr)[0],prevRow,false);
		}

		this.subjectDatatable.fnAdjustColumnSizing(true);
		this.bindHelpers();
	},

	render: function() {
		var subjects = faltacursarModel.getTableRows().sort
		(function(a,b){
			if(a.term != b.term)
				return a.term - b.term;
			return a.code - b.code;
		});

		this.$el.html(this.template({
			subjectTableStr: subjectTableStringsModel,
			faltacursarStr: faltacursarStringsModel
		}));
		this.initJS();
		this.cache();
		
		this.addRowsToTable(subjects);
		faltacursarClasseslistView.setElement('#faltacursar-classes-table-div');

		this.subjectDatatable.fnAdjustColumnSizing(false);
		this.calculateTableScroll();
	}
});

var faltacursarView = new FaltacursarView();
