(function () {
    'use strict';

    tinymce.PluginManager.add('coviletterspacing', function(editor, url) {
		var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
        var map$2 = function (xs, f) {
            var len = xs.length;
            var r = new Array(len);
            for (var i = 0; i < len; i++) {
                var x = xs[i];
                r[i] = f(x, i);
            }
            return r;
        };
        var getLetterSpacingFormats = function (editor) {
            return editor.getParam('letterspacing_formats', '-5px -4px -3px -2px -1px 0px 1px 2px 3px 4px 5px', 'string').split(' ');
        };
        var exists = function (xs, pred) {
            for (var i = 0, len = xs.length; i < len; i++) {
                var x = xs[i];
                if (pred(x, i)) {
                    return true;
                }
            }
            return false;
        };
        var forall = function (xs, pred) {
            for (var i = 0, len = xs.length; i < len; ++i) {
                var x = xs[i];
                if (pred(x, i) !== true) {
                    return false;
                }
            }
            return true;
        };
        var noop = function () {
        };
        var constant = function (value) {
            return function () {
                return value;
            };
        };
        var never = constant(false);
        var always = constant(true);
        var identity = function (x) {
            return x;
        };
        var none$2 = function () {
            return NONE;
        };
        var NONE = function () {
            var call = function (thunk) {
                return thunk();
            };
            var id = identity;
            var me = {
                fold: function (n, _s) {
                    return n();
                },
                isSome: never,
                isNone: always,
                getOr: id,
                getOrThunk: call,
                getOrDie: function (msg) {
                    throw new Error(msg || 'error: getOrDie called on none.');
                },
                getOrNull: constant(null),
                getOrUndefined: constant(undefined),
                or: id,
                orThunk: call,
                map: none$2,
                each: noop,
                bind: none$2,
                exists: never,
                forall: always,
                filter: function () {
                    return none$2();
                },
                toArray: function () {
                    return [];
                },
                toString: constant('none()')
            };
            return me;
        }();
        var some = function (a) {
            var constant_a = constant(a);
            var self = function () {
                return me;
            };
            var bind = function (f) {
                return f(a);
            };
            var me = {
                fold: function (n, s) {
                    return s(a);
                },
                isSome: always,
                isNone: never,
                getOr: constant_a,
                getOrThunk: constant_a,
                getOrDie: constant_a,
                getOrNull: constant_a,
                getOrUndefined: constant_a,
                or: self,
                orThunk: self,
                map: function (f) {
                    return some(f(a));
                },
                each: function (f) {
                    f(a);
                },
                bind: bind,
                exists: bind,
                forall: bind,
                filter: function (f) {
                    return f(a) ? me : NONE;
                },
                toArray: function () {
                    return [a];
                },
                toString: function () {
                    return 'some(' + a + ')';
                }
            };
            return me;
        };
        var from$1 = function (value) {
            return value === null || value === undefined ? NONE : some(value);
        };
        var Optional = {
            some: some,
            none: none$2,
            from: from$1
        };
        var Cell = function (initial) {
            var value = initial;
            var get = function () {
                return value;
            };
            var set = function (v) {
                value = v;
            };
            return {
                get: get,
                set: set
            };
        };
        var __assign = function () {
            __assign = Object.assign || function __assign(t) {
                for (var s, i = 1, n = arguments.length; i < n; i++) {
                    s = arguments[i];
                    for (var p in s)
                        if (Object.prototype.hasOwnProperty.call(s, p))
                            t[p] = s[p];
                }
                return t;
            };
            return __assign.apply(this, arguments);
        };
        var singleton = function (doRevoke) {
            var subject = Cell(Optional.none());
            var revoke = function () {
                return subject.get().each(doRevoke);
            };
            var clear = function () {
                revoke();
                subject.set(Optional.none());
            };
            var isSet = function () {
                return subject.get().isSome();
            };
            var get = function () {
                return subject.get();
            };
            var set = function (s) {
                revoke();
                subject.set(Optional.some(s));
            };
            return {
                clear: clear,
                isSet: isSet,
                get: get,
                set: set
            };
        };
        var value = function () {
            var subject = singleton(noop);
            var on = function (f) {
                return subject.get().each(f);
            };
            return __assign(__assign({}, subject), { on: on });
        };
        var watcher = function (editor, value, callback) {
            return editor.formatter.formatChanged('letterSpacing', callback, false, { value: value }).unbind;
        };
        var getCurrent = function (editor, value) {
            var selectedBlocks = editor.selection.getSelectedBlocks();
            var checkNode = function (node) {
                return editor.formatter.match('letterSpacing', { value: value }, node, false);
            }
            var checkAllDescendants = function (node, childNodes) {
                _tool.each(childNodes, function (childNode) {
                    var letterSpacing = editor.dom.getStyle(childNode, 'letter-spacing');
                    if (letterSpacing) {
                        editor.dom.setStyle(node, 'letter-spacing', letterSpacing);
                        editor.dom.setStyle(childNode, 'letter-spacing', '');
                    }
                    checkAllDescendants(node, childNode.childNodes);
                })
            }
            var checkLetterSpacing = function (selectedBlocks) {
                if (selectedBlocks && selectedBlocks.length > 0) {
                    for (var i = 0; i < selectedBlocks.length; i++) {
                        var node = selectedBlocks[i];
                        if (node.nodeName.toLowerCase() === 'p' && node.firstChild) {
                            checkAllDescendants(node, node.childNodes);
                        }
                    }
                }
            }
            checkLetterSpacing(selectedBlocks);
            if (selectedBlocks.length > 1) {
                return forall(selectedBlocks, checkNode);
            } else {
                return exists(selectedBlocks, checkNode);
            }
        };
        var setCurrent = function (editor, value) {
			editor.undoManager.transact(function () {
           		editor.formatter.toggle('letterSpacing', { value: value });
           	});
            editor.nodeChanged();
        };
        var getMenuItems = function () {
            var options = getLetterSpacingFormats(editor);
            var current = value();
            return map$2(options, function (value) {
                return {
                    type: 'togglemenuitem',
                    text: value,
                    onSetup: function (api) {
                        var setActive = function (active) {
                            if (active) {
                                current.on(function (oldApi) {
                                    return oldApi.setActive(false);
                                });
                                current.set(api);
                            }
                            api.setActive(active);
                        };
                        setActive(getCurrent(editor, value));
                        var unbindWatcher = watcher(editor, value, setActive);
                        return function () {
                            current.clear();
                            unbindWatcher();
                        }
                    },
                    onAction: function () {
                        return setCurrent(editor, value);
                    },
                }
            })
        };

        editor.ui.registry.addMenuButton('coviletterspacing', {
            tooltip: 'Letter spacing',
            icon: 'letter-spacing',
            fetch: function (callback) {
                return callback(getMenuItems());
            },
        });

		editor.ui.registry.addNestedMenuItem('coviletterspacing', {
            text: 'Letter spacing',
            icon: 'letter-spacing',
            getSubmenuItems: function () {
                var options = getLetterSpacingFormats(editor);
                var current = value();
                return map$2(options, function (value) {
                    return {
                        type: 'togglemenuitem',
                        text: value,
                        onSetup: function (api) {
                            var setActive = function (active) {
                                if (active) {
                                    current.on(function (oldApi) {
                                        return oldApi.setActive(false);
                                    });
                                    current.set(api);
                                }
                                api.setActive(active);
                            };
                            setActive(getCurrent(editor, value));
                            var unbindWatcher = watcher(editor, value, setActive);
                            return function () {
                                current.clear();
                                unbindWatcher();
                            }
                        },
                        onAction: function () {
                            return setCurrent(editor, value);
                        },
                    }
                })
            },
        });

        return {
        };
    });
}());