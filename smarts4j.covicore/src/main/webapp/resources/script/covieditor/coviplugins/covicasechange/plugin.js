(function () {
    'use strict';
    
    tinymce.PluginManager.add('covicasechange', function (editor, url) {
        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');

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

        var typeOf = function (x) {
            var t = typeof x;
            if (x === null) {
                return 'null';
            } else if (t === 'object' && (Array.prototype.isPrototypeOf(x) || x.constructor && x.constructor.name === 'Array')) {
                return 'array';
            } else if (t === 'object' && (String.prototype.isPrototypeOf(x) || x.constructor && x.constructor.name === 'String')) {
                return 'string';
            } else {
                return t;
            }
        };
        var isType$1 = function (type) {
            return function (value) {
                return typeOf(value) === type;
            };
        };
        var isArray = isType$1('array');

        var noop = function () {
        };
        var constant = function (value) {
            return function () {
                return value;
            };
        };
        var identity = function (x) {
            return x;
        };
        var never = constant(false);
        var always = constant(true);
        var none = function () {
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
                map: none,
                each: noop,
                bind: none,
                exists: never,
                forall: always,
                filter: function () {
                    return none();
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
        var from = function (value) {
            return value === null || value === undefined ? NONE : some(value);
        };
        var Optional = {
            some: some,
            none: none,
            from: from
        };

        var nativeSlice = Array.prototype.slice;
        var nativePush = Array.prototype.push;
        var map = function (xs, f) {
            var len = xs.length;
            var r = new Array(len);
            for (var i = 0; i < len; i++) {
                var x = xs[i];
                r[i] = f(x, i);
            }
            return r;
        };
        var each = function (xs, f) {
            for (var i = 0, len = xs.length; i < len; i++) {
                var x = xs[i];
                f(x, i);
            }
        };
        var groupBy = function (xs, f) {
            if (xs.length === 0) {
                return [];
            } else {
                var wasType = f(xs[0]);
                var r = [];
                var group = [];
                for (var i = 0, len = xs.length; i < len; i++) {
                    var x = xs[i];
                    var type = f(x);
                    if (type !== wasType) {
                        r.push(group);
                        group = [];
                    }
                    wasType = type;
                    group.push(x);
                }
                if (group.length !== 0) {
                    r.push(group);
                }
                return r;
            }
        };
        var foldl = function (xs, f, acc) {
            each(xs, function (x, i) {
                acc = f(acc, x, i);
            });
            return acc;
        };
        var flatten = function (xs) {
            var r = [];
            for (var i = 0, len = xs.length; i < len; ++i) {
                if (!isArray(xs[i])) {
                    throw new Error('Arr.flatten item ' + i + ' was not an array, input: ' + xs);
                }
                nativePush.apply(r, xs[i]);
            }
            return r;
        };
        var bind = function (xs, f) {
            return flatten(map(xs, f));
        };
        var sort = function (xs, comparator) {
            var copy = nativeSlice.call(xs, 0);
            copy.sort(comparator);
            return copy;
        };
        var hasOwnProperty = Object.hasOwnProperty;
        var has = function (obj, key) {
            return hasOwnProperty.call(obj, key);
        };

        var DOCUMENT = 9;
        var DOCUMENT_FRAGMENT = 11;
        var ELEMENT = 1;
        var TEXT = 3;

        var type = function (element) {
            return element.dom.nodeType;
        };
        var isType = function (t) {
            return function (element) {
                return type(element) === t;
            };
        };
        var isText$1 = isType(TEXT);

        var compareDocumentPosition = function (a, b, match) {
            return (a.compareDocumentPosition(b) & match) !== 0;
        };
        var documentPositionPreceding = function (a, b) {
            return compareDocumentPosition(a, b, Node.DOCUMENT_POSITION_PRECEDING);
        };
        var fromHtml = function (html, scope) {
            var doc = scope || document;
            var div = doc.createElement('div');
            div.innerHTML = html;
            if (!div.hasChildNodes() || div.childNodes.length > 1) {
                console.error('HTML does not have a single root node', html);
                throw new Error('HTML must have a single root node');
            }
            return fromDom(div.childNodes[0]);
        };
        var fromTag = function (tag, scope) {
            var doc = scope || document;
            var node = doc.createElement(tag);
            return fromDom(node);
        };
        var fromText = function (text, scope) {
            var doc = scope || document;
            var node = doc.createTextNode(text);
            return fromDom(node);
        };
        var fromDom = function (node) {
            if (node === null || node === undefined) {
                throw new Error('Node cannot be null or undefined');
            }
            return { dom: node };
        };
        var fromPoint = function (docElm, x, y) {
            return Optional.from(docElm.dom.elementFromPoint(x, y)).map(fromDom);
        };
        var SugarElement = {
            fromHtml: fromHtml,
            fromTag: fromTag,
            fromText: fromText,
            fromDom: fromDom,
            fromPoint: fromPoint
        };
        var bypassSelector = function (dom) {
            return dom.nodeType !== ELEMENT && dom.nodeType !== DOCUMENT && dom.nodeType !== DOCUMENT_FRAGMENT || dom.childElementCount === 0;
        };
        var all = function (selector, scope) {
            var base = scope === undefined ? document : scope.dom;
            return bypassSelector(base) ? [] : map(base.querySelectorAll(selector), SugarElement.fromDom);
        };

        var children = function (element) {
            return map(element.dom.childNodes, SugarElement.fromDom);
        };
        var spot = function (element, offset) {
            return {
                element: element,
                offset: offset
            };
        };
        var leaf = function (element, offset) {
            var cs = children(element);
            return cs.length > 0 && offset < cs.length ? spot(cs[offset], 0) : spot(element, offset);
        };
        var NodeValue = function (is, name) {
            var get = function (element) {
                if (!is(element)) {
                    throw new Error('Can only get ' + name + ' value of a ' + name + ' node');
                }
                return getOption(element).getOr('');
            };
            var getOption = function (element) {
                return is(element) ? Optional.from(element.dom.nodeValue) : Optional.none();
            };
            var set = function (element, value) {
                if (!is(element)) {
                    throw new Error('Can only set raw ' + name + ' value of a ' + name + ' node');
                }
                element.dom.nodeValue = value;
            };
            return {
                get: get,
                getOption: getOption,
                set: set
            };
        };

        var api = NodeValue(isText$1, 'text');
        var get$1 = function (element) {
            return api.get(element);
        };

        var descendants = function (scope, selector) {
            return all(selector, scope);
        };

        var global = tinymce.util.Tools.resolve('tinymce.dom.TreeWalker');

        var isSimpleBoundary = function (dom, node) {
            return dom.isBlock(node) || has(dom.schema.getShortEndedElements(), node.nodeName);
        };
        var isContentEditableFalse = function (dom, node) {
            return dom.getContentEditable(node) === 'false';
        };
        var isContentEditableTrueInCef = function (dom, node) {
            return dom.getContentEditable(node) === 'true' && dom.getContentEditableParent(node.parentNode) === 'false';
        };
        var isHidden = function (dom, node) {
            return !dom.isBlock(node) && has(dom.schema.getWhiteSpaceElements(), node.nodeName);
        };
        var isBoundary = function (dom, node) {
            return isSimpleBoundary(dom, node) || isContentEditableFalse(dom, node) || isHidden(dom, node) || isContentEditableTrueInCef(dom, node);
        };
        var isText = function (node) {
            return node.nodeType === 3;
        };
        var nuSection = function () {
            return {
                sOffset: 0,
                fOffset: 0,
                elements: []
            };
        };
        var toLeaf = function (node, offset) {
            return leaf(SugarElement.fromDom(node), offset);
        };
        var walk = function (dom, walkerFn, startNode, callbacks, endNode, skipStart) {
            if (skipStart === void 0) {
                skipStart = true;
            }
            var next = skipStart ? walkerFn(false) : startNode;
            while (next) {
                var isCefNode = isContentEditableFalse(dom, next);
                if (isCefNode || isHidden(dom, next)) {
                    var stopWalking = isCefNode ? callbacks.cef(next) : callbacks.boundary(next);
                    if (stopWalking) {
                        break;
                    } else {
                        next = walkerFn(true);
                        continue;
                    }
                } else if (isSimpleBoundary(dom, next)) {
                    if (callbacks.boundary(next)) {
                        break;
                    }
                } else if (isText(next)) {
                    callbacks.text(next);
                }
                if (next === endNode) {
                    break;
                } else {
                    next = walkerFn(false);
                }
            }
        };
        var collectTextToBoundary = function (dom, section, node, rootNode, forwards) {
            if (isBoundary(dom, node)) {
                return;
            }
            var rootBlock = dom.getParent(rootNode, dom.isBlock);
            var walker = new global(node, rootBlock);
            var walkerFn = forwards ? walker.next.bind(walker) : walker.prev.bind(walker);
            walk(dom, walkerFn, node, {
                boundary: always,
                cef: always,
                text: function (next) {
                    if (forwards) {
                        section.fOffset += next.length;
                    } else {
                        section.sOffset += next.length;
                    }
                    section.elements.push(SugarElement.fromDom(next));
                }
            });
        };
        var collect = function (dom, rootNode, startNode, endNode, callbacks, skipStart) {
            if (skipStart === void 0) {
                skipStart = true;
            }
            var walker = new global(startNode, rootNode);
            var sections = [];
            var current = nuSection();
            collectTextToBoundary(dom, current, startNode, rootNode, false);
            var finishSection = function () {
                if (current.elements.length > 0) {
                    sections.push(current);
                    current = nuSection();
                }
                return false;
            };
            walk(dom, walker.next.bind(walker), startNode, {
                boundary: finishSection,
                cef: function (node) {
                    finishSection();
                    if (callbacks) {
                        sections.push.apply(sections, callbacks.cef(node));
                    }
                    return false;
                },
                text: function (next) {
                    current.elements.push(SugarElement.fromDom(next));
                    if (callbacks) {
                        callbacks.text(next, current);
                    }
                }
            }, endNode, skipStart);
            if (endNode) {
                collectTextToBoundary(dom, current, endNode, rootNode, true);
            }
            finishSection();
            return sections;
        };
        var collectRangeSections = function (dom, rng) {
            var start = toLeaf(rng.startContainer, rng.startOffset);
            var startNode = start.element.dom;
            var end = toLeaf(rng.endContainer, rng.endOffset);
            var endNode = end.element.dom;
            return collect(dom, rng.commonAncestorContainer, startNode, endNode, {
                text: function (node, section) {
                    if (node === endNode) {
                        section.fOffset += node.length - end.offset;
                    } else if (node === startNode) {
                        section.sOffset += start.offset;
                    }
                },
                cef: function (node) {
                    var sections = bind(descendants(SugarElement.fromDom(node), '*[contenteditable=true]'), function (e) {
                        var ceTrueNode = e.dom;
                        return collect(dom, ceTrueNode, ceTrueNode);
                    });
                    return sort(sections, function (a, b) {
                        return documentPositionPreceding(a.elements[0].dom, b.elements[0].dom) ? 1 : -1;
                    });
                }
            }, false);
        };
        var fromRng = function (dom, rng) {
            return rng.collapsed ? [] : collectRangeSections(dom, rng);
        };
        var fromNode = function (dom, node) {
            var rng = dom.createRng();
            rng.selectNode(node);
            return fromRng(dom, rng);
        };
        var fromNodes = function (dom, nodes) {
            return bind(nodes, function (node) {
                return fromNode(dom, node);
            });
        };
        var find$2 = function (text, start, finish) {
            if (start === void 0) {
                start = 0;
            }
            if (finish === void 0) {
                finish = text.length;
            }

            var results = [];
            var matches = text.substring(start, finish);
            var matchStart = 0;
            var matchFinish = 0;
            matches = matches.split(' ');
            _tool.each(matches, function (match, index) {
                var matchedText = match;
                if (index === 0) {
                    matchStart = start;
                } else {
                    matchStart = matchFinish + 1;
                }
                matchFinish = matchStart + matchedText.length;
                if (matchFinish > finish) {
                    return results;
                }
                results.push({
                    start: matchStart,
                    finish: matchFinish,
                    text: matchedText
                });
            });

            return results;
        };
        var extract = function (elements, matches) {
            var nodePositions = foldl(elements, function (acc, element) {
                var content = get$1(element);
                var start = acc.last;
                var finish = start + content.length;
                var positions = bind(matches, function (match, matchIdx) {
                    if (match.start < finish && match.finish > start) {
                        return [{
                            element: element,
                            start: Math.max(start, match.start) - start,
                            finish: Math.min(finish, match.finish) - start,
                            matchId: matchIdx,
                            matchedText: match.text
                        }];
                    } else {
                        return [];
                    }
                });
                return {
                    results: acc.results.concat(positions),
                    last: finish
                };
            }, {
                results: [],
                last: 0
            }).results;
            return groupBy(nodePositions, function (position) {
                return position.matchId;
            });
        };
        var find$1 = function (sections) {
            return bind(sections, function (section) {
                var elements = section.elements;
                var content = map(elements, get$1).join('');
                var positions = find$2(content, section.sOffset, content.length - section.fOffset);
                return extract(elements, positions);
            });
        };

        var findWords = function () {
            var nodes = editor.dom.select('td[data-mce-selected],th[data-mce-selected]');
            var textSections = nodes.length > 0 ? fromNodes(editor.dom, nodes) : fromRng(editor.dom, editor.selection.getRng());
            var words = find$1(textSections);

            return words;
        }

        var changeLowerCase = function (words) {
            _tool.each(words, function (text) {
                var textNode = text.element.dom;
                var replaceText = textNode.textContent.slice(text.start, text.finish);
                replaceText = replaceText.toLowerCase();
                textNode.replaceData(text.start, replaceText.length, replaceText);
            });
        }

        var changeUpperCase = function (words) {
            _tool.each(words, function (text) {
                var textNode = text.element.dom;
                var replaceText = textNode.textContent.slice(text.start, text.finish);
                replaceText = replaceText.toUpperCase();
                textNode.replaceData(text.start, replaceText.length, replaceText);
            });
        }

        var changeTitleCase = function (words) {
            _tool.each(words, function (text, index) {
                var textNode = text.element.dom;
                var replaceText = textNode.textContent.slice(text.start, text.finish);
                var capitalize = function (word) {
                    return word.replace(/(^|\s)\S/, function (char) {
                        var upperCase = char.toUpperCase();
                        return upperCase;
                    });
                }

                replaceText = replaceText.toLowerCase();
                if (index === 0) {
                    replaceText = capitalize(replaceText);
                }
                textNode.replaceData(text.start, replaceText.length, replaceText);
            });
        }

        editor.addCommand('coviLowerCase', function() {
            editor.undoManager.transact(function () {
                var bookmark = editor.selection.getBookmark();
                var wordsArray = findWords();
                _tool.each(wordsArray, function (words) {
                    changeLowerCase(words);
                });
                editor.selection.moveToBookmark(bookmark);
            })
        });
        editor.addCommand('coviUpperCase', function() {
            editor.undoManager.transact(function () {
                var bookmark = editor.selection.getBookmark();
                var wordsArray = findWords();
                _tool.each(wordsArray, function (words) {
                    changeUpperCase(words);
                });
                editor.selection.moveToBookmark(bookmark);
            })
        });
        editor.addCommand('coviTitleCase', function() {
            editor.undoManager.transact(function () {
                var bookmark = editor.selection.getBookmark();
                var wordsArray = findWords();
                _tool.each(wordsArray, function (words) {
                    changeTitleCase(words);
                });
                editor.selection.moveToBookmark(bookmark);
            })
        });

        editor.ui.registry.addNestedMenuItem('covicasechange', {
            text: "Conversion",
            icon: "change-case",
            getSubmenuItems: function () {
                return [{
                    type: 'menuitem',
                    text: 'Convert to uppercase',
                    shortcut: 'Meta+Shift+U',
                    onAction: function () {
                        editor.execCommand("coviUpperCase");
                    }
                }, {
                    type: 'menuitem',
                    text: 'Convert to lower case',
                    shortcut: 'Meta+Shift+L',
                    onAction: function () {
                        editor.execCommand("coviLowerCase");
                    }
                }, {
                    type: 'menuitem',
                    text: 'Capitalize the first letter',
                    shortcut: 'Meta+Shift+C',
                    onAction: function () {
                        editor.execCommand("coviTitleCase");
                    }
                }]
            }
        });
        editor.shortcuts.add('Meta+Shift+U', 'Convert to uppercase', 'coviUpperCase');
        editor.shortcuts.add('Meta+Shift+L', 'Convert to lower case', 'coviLowerCase');
        editor.shortcuts.add('Meta+Shift+C', 'Capitalize the first letter', 'coviTitleCase');
    })
}());