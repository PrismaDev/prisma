var DialogView = Backbone.View.extend({
	el: '',
	template: '',	
	args: {},
	templateId: '',
	
	initialize: function() {
		this.template = _.template($(this.templateId).html());
	},

	initJS: function() {
		this.$el.modal();
	},

	render: function() {
		this.$el.html(this.template(this.args));
		this.initJS();
	}
});

var FAQView = DialogView.extend({
	args: {
		faqStr: faqStringsModel
	},
	templateId: '#faq-template'
});

var faqView = new FAQView();

var TutorialView = DialogView.extend({
	args: {
		layoutStr: layoutStringsModel
	},
	templateId: '#tutorial-template',
	player: null,

	initJS: function() {
		//From github.com/twitter/bootstrap/issues/675/

		var me=this;
		this.$el.modal().css({
			'margin-left': function() {
				return -($(this).width()/2);
			}
		}).addClass('tutorial').on('hidden', function() {
			me.$el.empty();
			me.$el.removeClass('tutorial');
		});

		this.player = new YT.Player('yt-player', {
			height: '390',
			width: '640',
			videoId: layoutStringsModel.get('codTutorialYoutube')
		});
	}
});

var tutorialView = new TutorialView();
