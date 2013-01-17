//Must be included before models

function overriddenGet(obj, attr) {
	var chAttr = serverDictionary.get(attr);
	return Backbone.Model.prototype.get.call(obj,chAttr);
}

function overriddenAdd(obj, models, options, idName, add) {
	var array=new Array();
	idName = serverDictionary.get(idName);
	if (!add) add={};

	_.each(models, function(model) {
		if (typeof model == obj.model)
			obj.add(model);
		else {
			var nModel = new obj.model($.extend({},add,{id: model[idName]},model));
			array.push(nModel);
		}
	});

	return Backbone.Collection.prototype.add.call(obj,array,options);
}
