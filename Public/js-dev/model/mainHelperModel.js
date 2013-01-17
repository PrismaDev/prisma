var HelperModel = Backbone.Model.extend({
	defaults: {
		'active': true,
		'text': '',
		'selector': ''
	},

	deactivate: function() {
		$(this.get('selector')).data('tooltip',false);
		this.set('active', false);
	}
});

var HelpersList = Backbone.Collection.extend({
	model: HelperModel
});

var helpersList = new HelpersList();

helpersList.add({id: 'ableSubjectRow', text: mainHelpersStringsModel.get('ableSubjectRowText')}); 
helpersList.add({id: 'blockedSubjectRow', text: mainHelpersStringsModel.get('blockedSubjectRowText')}); 
helpersList.add({id: 'warningSubjectRow', text: mainHelpersStringsModel.get('warningSubjectRowText')}); 
helpersList.add({id: 'optativaRow', text: mainHelpersStringsModel.get('optativaRowText')}); 
