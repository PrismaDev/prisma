var HelperModel = Backbone.Model.extend({
	defaults: {
		'active': true,
		'text': '',
		'selector': ''
	},

	deactivate: function() {
		$(this.get('selector')).data('tooltip',false);
		this.set('active', false);

		$.ajax({
			url: '/api/aviso',
			type: 'DELETE',
			data: 'json=["'+this.id+'"]',
			dataType: 'json',

			success: function(data) {
				// nothing
			}
		});

	}
});

var HelpersList = Backbone.Collection.extend({
	model: HelperModel,

	deactivateFromServer: function(arr)
	{
		for(var i in arr)
		{
			this.get(arr[i][serverDictionary.get('CodAviso')]).set('active', false);
		}
	}
});

var helpersList = new HelpersList();

//Subject Table Helpers
helpersList.add({id: 'ableSubjectRow', text: mainHelpersStringsModel.get('ableSubjectRowText')}); 
helpersList.add({id: 'blockedSubjectRow', text: mainHelpersStringsModel.get('blockedSubjectRowText')}); 
helpersList.add({id: 'warningSubjectRow', text: mainHelpersStringsModel.get('warningSubjectRowText')}); 
helpersList.add({id: 'optativaRow', text: mainHelpersStringsModel.get('optativaRowText')});
helpersList.add({id: 'selectedSubjectRow', text: mainHelpersStringsModel.get('selectedSubjectRowText')});

//Class Table helpers
helpersList.add({id: 'ableClassRow', text: mainHelpersStringsModel.get('ableClassRowText')});
helpersList.add({id: 'chosenClassRow', text: mainHelpersStringsModel.get('chosenClassRowText')});
helpersList.add({id: 'warningClassRow', text: mainHelpersStringsModel.get('warningClassRowText')});
helpersList.add({id: 'blockedClassRow', text: mainHelpersStringsModel.get('blockedClassRowText')});
helpersList.add({id: 'disabledClassRow', text: mainHelpersStringsModel.get('disabledClassRowText')});

//Timetable helpers
helpersList.add({id: 'timeCell', text: mainHelpersStringsModel.get('timeCellText')});
helpersList.add({id: 'dayCell', text: mainHelpersStringsModel.get('dayCellText')});
helpersList.add({id: 'emptyCell', text: mainHelpersStringsModel.get('emptyCellText')});
helpersList.add({id: 'classCell', text: mainHelpersStringsModel.get('classCellText')});

//Selected helpers
helpersList.add({id: 'selectedRow', text: mainHelpersStringsModel.get('selectedRowText')});
helpersList.add({id: 'selectedClass', text: mainHelpersStringsModel.get('selectedClassText')});
