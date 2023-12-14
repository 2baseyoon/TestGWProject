define(function () {
    return {
        storage : window.localStorage,

        getWebStorage : function(key) {
            var val = this.storage.getItem(key);
            if(val === undefined || val === "") {
                val = "";
            }

            return val;
        },

        setWebStorage : function(key, value) {
            this.storage.setItem(key, value);
        },

        removeWebStorage : function(key) {
            //delete this.storage[key];
            this.storage.removeItem(key);
        },

        clearWebStorage : function() {
            this.storage.clear();
        }
    };
});