(function () {
    'use strict';
    
    tinymce.PluginManager.add("covipersonaldataprotection", function (editor, url) {
        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
        var _dialog = null;
        var _checkResult = [];
        var _selectedIndex = -1;
        var _personal_data_items;
        var _previewEl;

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
        var find$2 = function (text, pattern, start, finish) {
            if (start === void 0) {
                start = 0;
            }
            if (finish === void 0) {
                finish = text.length;
            }
            var regex = pattern.regex;
            regex.lastIndex = start;
            var results = [];
            var match;
            while (match = regex.exec(text)) {
                var matchedText = match[0];
                var matchStart = match.index + match[0].indexOf(matchedText);
                var matchFinish = matchStart + matchedText.length;
                if (matchFinish > finish) {
                    break;
                }
                results.push({
                    start: matchStart,
                    finish: matchFinish,
                    text: matchedText,
                    type: pattern.type
                });
                regex.lastIndex = matchFinish;
            }
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
                            matchedText: match.text,
                            matchedType: match.type
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
        var find$1 = function (pattern, sections) {
            return bind(sections, function (section) {
                var elements = section.elements;
                var content = map(elements, get$1).join('');
                var positions = find$2(content, pattern, section.sOffset, content.length - section.fOffset);
                return extract(elements, positions);
            });
        };
        var moveSelection = function (index) {
            mark(_checkResult[index]);
            _selectedIndex = index;
        };

        function selection(anchorNode, anchorOffset, focusNode, focusOffset) {
            var win = editor.getWin();
            var sel = win.getSelection ? win.getSelection() : win.document.selection;

            if (sel) {
                try {
                    sel.removeAllRanges();
                    if (anchorNode && focusNode) {
                        sel.setBaseAndExtent(anchorNode, anchorOffset, focusNode, focusOffset);
                    }
                } catch (ex) {
                }
            }
        }

        function mark(matches) {
            var firstPos = matches[0];
            var endPos = matches[matches.length - 1];
            var textNode = firstPos.element.dom;
            selection(firstPos.element.dom, firstPos.start, endPos.element.dom, endPos.finish);
            if (textNode.parentNode) {
                editor.selection.scrollIntoView(textNode.parentNode);
            }
        }

        function makeCheckResult() {
            var node = editor.getBody();
            var textSections = fromNode(editor.dom, node);
            var personalDataProtectionPatterns = editor.getParam('covi_personal_data_protections', [], 'array');

            _checkResult = [];
            _selectedIndex = -1;
            _tool.each(personalDataProtectionPatterns, function (item) {
                var pattern = {
                    regex: new RegExp(item.regExp, "gi"),
                    type: item.messages
                };
                var matches = find$1(pattern, textSections);
                _checkResult = _checkResult.concat(matches);
            });
        }

        function makeCellText(text) {
            var td = document.createElement("TD");
            td.innerHTML = text;

            return td;
        }

        function makeHeader() {
            var headerStyle = "border-right: 1px solid #ccc; border-bottom: 1px solid #ccc; font-weight: bold; vertical-align: middle; text-align: center; padding: 3px; background-color: #d9d9d9;";
            var headerStyle_1 = "border-right: 0px solid #ccc; border-bottom: 1px solid #ccc; font-weight: bold; vertical-align: middle; text-align: center; padding: 3px; background-color: #d9d9d9;";
            return "<thead><tr>" +
                "<th style='" + "width:150px; " + headerStyle + "'>" + tinymce.util.I18n.translate('Element')+ "</th>" +
                "<th style='" + "width:250px; " + headerStyle_1 + "'>" + tinymce.util.I18n.translate('Content')+ "</th>" +
                "</tr></thead>";
        }

        function makeRow(item, index) {
            var tr = document.createElement("TR");
            var td1 = makeCellText(item.matchedType);
            var td2 = makeCellText(item.matchedText);

            td1.setAttribute("style", "width: 150px; max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; border-right: 1px solid #ccc; border-bottom: 1px solid #ccc; padding: 3px");
            td2.setAttribute("style", "width: 250px; max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; border-right: 0px solid #ccc; border-bottom: 1px solid #ccc; padding: 3px");

            tr.setAttribute("style", "width:100%; vertical-align: middle;");
            tr.setAttribute("class", "personal_data_item_row");
            tr.setAttribute("index", index);
            tr.setAttribute("onMouseOver", "this.style.cursor='pointer'");
            tr.setAttribute("onMouseOut", "this.style.cursor='auto'");
            tr.setAttribute("onClick", "coviPersonalDataProtection.selectItem(this);");
            tr.appendChild(td1);
            tr.appendChild(td2);

            return tr.outerHTML;
        }

        function makeRowHtml() {
            var rowHtml = "";
            for (var i = 0; i < _checkResult.length; i++) {
                var item = _checkResult[i][0];
                rowHtml += makeRow(item, i);
            }

            return rowHtml;
        }

        function updatePreViewText(index) {
            if (_previewEl) {
                var previewText = _checkResult[index][0].matchedText;
                if (previewText.length > 0) {
                    previewText = previewText.replace(/[a-zA-Z\d]/g, '*');
                    _previewEl.innerText = previewText;
                }
            }
        }

        function updateSelectedItem(index) {
            var items = document.getElementsByClassName("personal_data_item_row");

            for (var i = 0; i < items.length; i++) {
                items[i].style.backgroundColor = i == index ? "#EEE" : "#FFF";
            }

            moveSelection(index);
            updatePreViewText(index);
        }

        function removeCheckResult(removeIndex) {
            if (removeIndex >= 0) {
                _checkResult.splice(removeIndex, 1);
                if (_checkResult.length > 0) {
                    _personal_data_items.innerHTML = makeRowHtml();

                    if (removeIndex < _checkResult.length) {
                        updateSelectedItem(removeIndex);
                    } else {
                        updateSelectedItem(_checkResult.length - 1);
                    }
                    _dialog.enable('replace');
                } else {
                    _personal_data_items.innerHTML = "";
                    _previewEl.innerText = "";
                    _checkResult = [];
                    _selectedIndex = -1;
                    selection();
                    _dialog.disable('replace');
                }
            }
        }

        function replacePersonalData(index) {
            var matches = _checkResult[index];
            if (matches) {
                _tool.each(matches, function (pos) {
                    var textNode = pos.element.dom;
                    var replaceText = textNode.textContent.slice(pos.start, pos.finish);
                    replaceText = replaceText.replace(/[a-zA-Z\d]/g, '*');
                    textNode.replaceData(pos.start, replaceText.length, replaceText);
                });
                removeCheckResult(index);
            }
        }

        function bindGlobalEl() {
            _personal_data_items = document.getElementById("covi_personal_data_items");
            _previewEl = document.getElementById("covi_personal_data_preview");
        }

        function getDlgOptions() {
            makeCheckResult();

            if (!window.coviPersonalDataProtection) {
                window.coviPersonalDataProtection = {
                    selectItem: function (obj) {
                        var index = parseInt(obj.getAttribute('index'));
                        updateSelectedItem(index)
                    },
                }
            }

            return {
                title: tinymce.util.I18n.translate("Privacy"),
                body: {
                    type: 'panel',
                    items: [{
                        type: 'htmlpanel',
                        html: "<div style='width:100%; height:200px; overflow:auto; border:1px solid #ccc; box-sizing:border-box' ><table style='width:100%; border:0px solid #ccc; font-size: 14px;' cellpadding='0' cellspacing='0'>" + makeHeader() +
                              "<tbody id='covi_personal_data_items'>" + makeRowHtml() + "</tbody></table></div><br/>"
                    }, {
                        type: 'htmlpanel',
                        html: "<div style='border: 1px solid #d9d9d9;'>" +
                            "<table style='width: 100%; border-collapse: collapse;'>" +
                            "<thead><tr style='height: 20px;'><th style='vertical-align: middle; text-align: center; background-color: #d9d9d9;'>"+tinymce.util.I18n.translate("Preview the editing result")+"</th></tr></thead>" +
                            "<tbody><tr style='height: 35px;'><td style='padding: 10px; vertical-align: middle; text-align: center;'><span id='covi_personal_data_preview'></span></td></tr></tbody>" +
                            "</table>" +
                            "</div>",
                    }]
                },
                onClose: function() {
                    if (window.coviPersonalDataProtection) {
                        window.coviPersonalDataProtection = undefined;
                    }
                    editor.focus();
                    selection();
                },
                onChange: function (api, details) {
                },
                onSubmit: function (api) {
                    if (_selectedIndex >= 0) {
                        editor.undoManager.transact(function () {
                            replacePersonalData(_selectedIndex);
                        });
                    }
                },
                buttons: [{
                    type: 'submit',
                    name: 'replace',
                    text: 'Replace',
                    disabled: true
                }, {
                    text: 'Close',
                    type: 'cancel',
                    onclick: 'close'
                }]
            }
        }

        editor.ui.registry.addMenuItem('covipersonaldataprotection', {
            text: tinymce.util.I18n.translate("Privacy"),
            icon: 'personal-information-detection',
            onAction: function() {
                _dialog = editor.windowManager.open(getDlgOptions());
                _dialog.focus();
                bindGlobalEl();
                if (_checkResult.length > 0) {
                    updateSelectedItem(0);
                    _dialog.enable('replace');
                }
            },
        });
    });
}());