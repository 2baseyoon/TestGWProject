define(function () {
	var lSto;

	try {
		lSto = window.localStorage;
	} catch (exc) {
		lSto = null;
		console.log("Unable to get localStorage");
	}

	return {
		storage : lSto,

		getWebStorage : function(key) {
			var val = this.storage && this.storage.getItem(key);

			if (val === undefined || val === "") {
				val = "";
			}

			return val;
		},

		setWebStorage : function(key, value) {
			if (this.storage) {
				this.storage.setItem(key, value);
			}
		},

		removeWebStorage : function(key) {
			if (this.storage) {
				this.storage.removeItem(key);
			}
		},

		clearWebStorage : function() {
			if (this.storage) {
				this.storage.clear();
			}
		}
	};
});