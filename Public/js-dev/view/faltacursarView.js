var FaltacursarView = Backbone.View.extend({
	template: '',
	templateRow: '',
	subjectDatatableView: '',

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
//		this.templateRow = _.template($('#faltacursar-template-row').html());

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
		"click #faltacursar-subject-table .ementaButton": 'clickOnEmenta'
	},

	handleOptativa: function(row) {
		var codOpt = $(row).attr('id');
		var nRows = faltacursarModel.getSubjectsOptativa(codOpt);		

		if ($(row).hasClass('openOptativa')) {
			$(row).removeClass('openOptativa');
			$($(row).attr('id')+' ~ tr').slice(0,nRows.length).remove();
		}
		else {
			$(row).addClass('openOptativa');
			var arr=new Array();
			console.log(nRows);	
		
/*			_.each(nRows, function(r) {

				console.log(r);
				arr.push(templateRow({subject: r}));
			});*/

	//		$(row).insertAfter(arr);
		}
	},

	clickOnRow: function(e) {
		var row=$(e.target).parent('tr');

		if ($(row).hasClass('optativa'))
			return handleOptativa(row);

		if ($(row).hasClass('subjectBlocked'))
			return;
		if ($(row.find('td').first()).hasClass('dataTables_empty'))
			return;

		if ($(row).hasClass('subjectSelected')) {
			$(row).removeClass('subjectSelected');
        		
			$(this.subjectTableWrapper).addClass('whole')
						.removeClass('half');
			this.calculateTableScroll();		
			$(this.classesDiv).addClass('hidden');
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
			faltacursarClasseslistView.render(
				faltacursarModel.getSubjectClasses(id)
			);
			faltacursarClasseslistView.resize();
			this.calculateScrollTop(row);
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

	initJS: function() {
		var me = this;

		this.subjectDatatable = $('#faltacursar-subject-table').dataTable({
			'sDom': 'ftS',
			'bPaginate': false,
			'bScrollCollapse': true,
			'sScrollY': '200px',
			'bSort': false,
			'fnDrawCallback': function(oSettings) {
				me.calculateTableScroll()
			}
		});
		
		$('#faltacursar-subject-table_wrapper').addClass('whole');
	},		

	render: function() {

		var subjects = faltacursarModel.getSubjects().sort
		(function(a,b){
			return a.term - b.term;
		});

		this.$el.html(this.template({
			subjects: subjects,
			subjectTableStr: subjectTableStringsModel
		}));
		this.initJS();

		this.cache();
		faltacursarClasseslistView.setElement('#faltacursar-classes-div');

		this.subjectDatatable.fnAdjustColumnSizing(false);
		this.calculateTableScroll();
	}
});

var faltacursarView = new FaltacursarView();
