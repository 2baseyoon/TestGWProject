window["_LOG"] =  window["_LOG"] || function(expr) {
    if (!expr) {

        if (expr != null && expr.toString != null) {
            console.debug(expr.toString());
        } else {
            console.debug("[_LOG] null or unknown object");
        }

        if (console.trace != null) {
            console.trace();
        } else {
            if (arguments.callee && arguments.callee.caller) {
                console.debug(arguments.callee.caller);
            } else {
                console.warn("Not Support stack trace in this Browser");
            }
        }
    }
};