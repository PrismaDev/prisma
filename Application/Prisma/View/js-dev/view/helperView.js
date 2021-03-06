var HelperView = Backbone.Model.extend({
	el: 'body',
	curr: null,
	off: true,

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

		if (this.off)
			return;

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
			},
			'show': {
				'solo': true
			},
			'hide': {
				'delay': '800'
			},
			'events': {
				'show': function(e,api) {
					e.stopPropagation();
				} 
			}
		});
	}
});

var helperView = new HelperView();
