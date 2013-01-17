var HelperView = Backbone.Model.extend({
	el: 'body',

	formatTooltip: function(tooltipId) {
		var tooltipModel = helpersList.get(tooltipId);
		
		return '<span>'+tooltipModel.get('text')+'</span><br/>\
			<button id="'+tooltipId+'tooltip" class="btn btn-primary btn-small">'+
			mainHelpersStringsModel.get('tooltipButtonLabel')
			+'</button>';
	},

	create: function(tooltipId, targetEl) {
		var tooltipModel = helpersList.get(tooltipId);
		
		if (!tooltipModel.get('active'))
			return;

		$(tooltipModel.get('selector')).tooltip({
			'html': true,
			'title': this.formatTooltip(tooltipId),
			'delay': {show: '100', hide: '700'}
		});

		$('#'+tooltipId+'tooltip').live('click', function() {
			helpersList.get(tooltipId).deactivate();
		});
	}
});

var helperView = new HelperView();
