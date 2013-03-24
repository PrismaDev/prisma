function FbApiController() {
	var me=this;

	this.loadApi = function() {
		me.insertScript(document,true);
	}

	this.insertScript = function(element, debug) {
		var js, id = 'facebook-jssdk', ref = element.getElementById('fb-root');
		if (element.getElementById(id)) {return;}
		js = element.createElement('script'); js.id = id; js.async = true;
		js.src = "//connect.facebook.net/en_US/all" + (debug ? "/debug" : "") + ".js";
		ref.parentNode.insertBefore(js, ref);
	}

	window.fbAsyncInit = function() {
    		FB.init({
			status     : false,
			cookie     : true, // set sessions cookies to allow your server to access the session?
			xfbml      : true  // parse XFBML tags on this page?
		});
	};
}

var fbApiController = new FbApiController();
