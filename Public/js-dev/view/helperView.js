var HelperView = Backbone.Model.extend({
	el: 'body',
	curr: null,

	formatTooltip: function(tooltipId) {
		var tooltipModel = helpersList.get(tooltipId);
		
		return '<span>'+tooltipModel.get('text')+'</span><br/>\
			<button id="'+tooltipId+'tooltip" class="btn btn-primary btn-small">'+
			mainHelpersStringsModel.get('tooltipButtonLabel')
			+'</button>';
	},

	create: function(tooltipId, targetEl) {
		var tooltipModel = helpersList.get(tooltipId);
		var me=this;		

		if (this.curr) {
			$(this.curr).tooltip('destroy');
			this.curr=tooltipModel.get('selector');
		}

		if (!tooltipModel.get('active'))
			return;

		console.log($(tooltipModel.get('selector')));
		$(tooltipModel.get('selector')).tooltip({
			'html': true,
			'title': this.formatTooltip(tooltipId),
			'delay': {show: '100', hide: '700'},
			'placement': 'bottom',
			'container': 'body'
		});

		$('#'+tooltipId+'tooltip').live('click', function() {
			helpersList.get(tooltipId).deactivate();
		});
	}
});

var helperView = new HelperView();
