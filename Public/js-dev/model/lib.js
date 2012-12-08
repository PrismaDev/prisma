//Must be included before models

function overriddenGet(obj, attr) {
	var chAttr = serverDictionary.get(attr);
	return Backbone.Model.prototype.get.call(obj,chAttr);
}
