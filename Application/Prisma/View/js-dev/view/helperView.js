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

		if (!tooltipModel.get('active'))
			return;

		$(tooltipModel.get('selector')).qtip({
			'content': {
				'text': this.formatTooltip(tooltipId)
			},
			'position': {
				'my': 'top center',
				'at': 'bottom center',
				'viewport': $(window)
			},
			'style': {
				'classes': 'qtip-bootstrap qtip-blue'
			}
		});
	}
});

var helperView = new HelperView();
