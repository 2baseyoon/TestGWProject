(function () {
    'use strict';

    tinymce.PluginManager.add("coviview", function(editor, url) {
		var PX_RULER = editor.getParam('ruler_px') || 3.78; // 3.779527559
        var PADDING_RULER = editor.getParam('ruler_padding') || 13; // in millimeters
        var FORMAT_RULER = editor.getParam('ruler_format') || { width: 210, height: 297 }; // A4 210, 297
        var RULER_SELECTOR = "covi_fixed_ruler_line";
        var RULER_MARK_SELECTOR = "covi_fixed_ruler";
        var _enableRuler = false;

        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
        var _fixedRuler = editor.getParam('fixed_ruler', false);

        var showRulerLine = function(isShow) {
            var rulerLineEl = editor.dom.$.find('.' + RULER_SELECTOR);

            for (var i = 0; i < rulerLineEl.length; i++) {
                rulerLineEl[i].style.display = isShow ? 'block' : 'none';
            }
        }

        var removeRulerLine = function() {
            var rulerLineEl = editor.dom.$.find('.' + RULER_SELECTOR);
            _tool.each(rulerLineEl, function(el) { el.parentNode.removeChild(el); });
        }

        var getRulerLimitX = function() {
            var docRect = editor.getDoc().documentElement.getBoundingClientRect();

            return (docRect.left + (FORMAT_RULER.width - PADDING_RULER * 2 - 3) * PX_RULER);
        }

        var toggleRulerLine = function() {
            removeRulerLine();

            if (_enableRuler) {
                var editAreaEl = editor.dom.$.find('.' + 'tox-edit-area');
                var rulerLineEl = editor.dom.create("div");
                var limitX = getRulerLimitX();
                var rulerLineStyle = "position: absolute; height: 100%; width: 0px; border-left: 1px dashed #f56363;" + "px; left: " + limitX + "px; z-index: 10000000;";

                rulerLineEl.classList.add(RULER_SELECTOR);
                rulerLineEl.setAttribute("style", rulerLineStyle);
                rulerLineEl.setAttribute("contenteditable", false);

                editAreaEl[0].appendChild(rulerLineEl);
            }
        }
        
        var handleExec = function(e) {
            var cmd = e.command.toLowerCase();

			if (_enableRuler && cmd ==='mceprint') {
                showRulerLine(e.type === 'execcommand');
            }

            if (_enableRuler && cmd === 'indent') {
                var selectedBlocks = editor.selection.getSelectedBlocks();
                var indentation = parseInt(editor.getParam('indentation', '30px'));

                _tool.each(selectedBlocks, function(node) {
                    if (node.getAttribute('contenteditable') === 'false') {
                        return;
                    }

                    if ((node.getBoundingClientRect().width - indentation) < indentation) {
                        e.preventDefault();
                    }
                });
            }
            
            if (e.type === 'beforeexeccommand' && cmd === 'mcepagebreak') {
                editor.settings.pagebreak_split_block = true;
            }

            if (e.type === 'execcommand' && cmd === 'mcepagebreak') {
                editor.settings.pagebreak_split_block = false;
                var pageBreakNode = editor.selection.getNode();

                if (pageBreakNode.firstElementChild && pageBreakNode.firstElementChild.classList.contains('mce-pagebreak')) {
                    pageBreakNode.innerHTML = pageBreakNode.innerHTML.replaceAll('&nbsp;', '').trim();
                    editor.dom.setStyle(pageBreakNode, 'marginLeft', null);
                    editor.dom.setStyle(pageBreakNode, 'marginRight', null);
                    editor.dom.setAttrib(pageBreakNode, 'contenteditable', false);
                    editor.dom.setAttrib(pageBreakNode.firstChild, 'contenteditable', false);

                    var nextNode = pageBreakNode.nextSibling;

                    if (nextNode === null) {
                        nextNode = editor.dom.create('p', null, '</br>');
                        pageBreakNode.parentElement.append(nextNode);
                    }

                    editor.selection.setCursorLocation(nextNode, 0);
                }
            }

            if (e.type === 'beforeexeccommand' && cmd === 'mcetoggleformat') {
                var checkToggleType = ['p','h1','h2','h3','h4','h5','h6'];
                var pt2px = function(size) {
                    size = (4 * parseFloat(size) / 3).toFixed(4);
                    size = size === 0 ? 10 : size;
                    size = size + 'px';
                    return size;
                }
                var wrapAll = function (childNodes) {
                    var wrapper = editor.dom.create('p');

                    var parent = childNodes[0].parentNode;
                    var previousSibling = childNodes[0].previousSibling;
                    for (var i = 0; childNodes.length - i; wrapper.firstChild === childNodes[0] && i++) {
                        wrapper.appendChild(childNodes[i]);
                    }

                    var nextSibling = previousSibling ? previousSibling.nextSibling : parent.firstChild;
                    parent.insertBefore(wrapper, nextSibling);
                }
                var setFont = function (node, eventValue) {
                    var fontSize = parseInt(editor.getParam('covi_default_font_size', '10pt'));
                    switch(eventValue) {
                        case 'p':
                            editor.dom.setStyle(node, 'fontSize', pt2px(fontSize));
                            editor.dom.setStyle(node, 'fontWeight', '');
                            break;
                        case 'h1':
                            fontSize = fontSize * 2;
                            editor.dom.setStyle(node, 'fontSize', pt2px(fontSize));
                            editor.dom.setStyle(node, 'fontWeight', 'bold');
                            break;
                        case 'h2':
                            fontSize = fontSize * 1.5;
                            editor.dom.setStyle(node, 'fontSize', pt2px(fontSize));
                            editor.dom.setStyle(node, 'fontWeight', 'bold');
                            break;
                        case 'h3':
                            fontSize = fontSize * 1.17;
                            editor.dom.setStyle(node, 'fontSize', pt2px(fontSize));
                            editor.dom.setStyle(node, 'fontWeight', 'bold');
                            break;
                        case 'h4':
                            fontSize = fontSize * 1;
                            editor.dom.setStyle(node, 'fontSize', pt2px(fontSize));
                            editor.dom.setStyle(node, 'fontWeight', 'bold');
                            break;
                        case 'h5':
                            fontSize = fontSize * 0.83;
                            editor.dom.setStyle(node, 'fontSize', pt2px(fontSize));
                            editor.dom.setStyle(node, 'fontWeight', 'bold');
                            break;
                        case 'h6':
                            fontSize = fontSize * 0.75;
                            editor.dom.setStyle(node, 'fontSize', pt2px(fontSize));
                            editor.dom.setStyle(node, 'fontWeight', 'bold');
                            break;
                        default:
                            break;
                    }
                }
                var preprocess = function (node, eventValue, isToggle) {
                    if (node.parentNode.nodeName.toLowerCase() === 'div') {
                        if (isToggle) {
                            if (eventValue !== 'p') {
                                wrapAll(node.childNodes);
                            } else {
                                e.stopImmediatePropagation();
                                e.preventDefault();
                            }
                        } else {
                            if (node.getAttribute('style') && node.nodeName.toLowerCase() !== eventValue) {
                                setFont(node, eventValue);
                            }
                        }
                    } else {
                        if (node.getAttribute('style') && node.nodeName.toLowerCase() !== eventValue) {
                            setFont(node, eventValue);
                        }
                    }
                }

                if (checkToggleType.indexOf(e.value) > -1) {
                    var nodes = editor.selection.getSelectedBlocks();
                    for (var i = 0; i < nodes.length; i++) {
                        var node = nodes[i];
                        if (checkToggleType.indexOf(node.nodeName.toLowerCase()) > -1) {
                            if (nodes[0].nodeName.toLowerCase() === e.value) { //toggle
                                if (nodes[0].nodeName === node.nodeName) { //Only handle nodes that are toggled
                                    preprocess(node, e.value, true);
                                }
                            } else {
                                preprocess(node, e.value, false);
                            }
                        }
                    }
                }
            }
        };
        
        var handleScroll = function(e) {
            toggleRulerLine();
        }

        var applyRulerToContent = function() {
            if (_enableRuler) {
                editor.dom.remove(RULER_MARK_SELECTOR);
                editor.dom.setStyle(editor.getBody(), "width", getRulerLimitX() - editor.getBody().getBoundingClientRect().left + "px");
            } else {
                editor.dom.setStyle(editor.getBody(), "width", null);
                editor.dom.remove(RULER_MARK_SELECTOR);
            }
        }

        editor.addCommand('coviFixedRuler', function(ui, v) {
            _enableRuler = _fixedRuler;

            toggleRulerLine();
            applyRulerToContent();
        });
		
		editor.ui.registry.addMenuItem('covicode', {
            icon: 'sourcecode',
            text: 'HTML',
            onAction: function() {
                var htmlTabEl = editor.dom.$.find('.covi_tab.covi_tab_html');

                if (htmlTabEl.length > 0) {
                    htmlTabEl[0].click();
                }
            },
        });

        editor.ui.registry.addMenuItem('covipreview', {
            icon: 'preview',
            text: 'Preview',
            onAction: function() {
                var previewTabEl = editor.dom.$.find('.covi_tab.covi_tab_preview');

                if (previewTabEl.length > 0) {
                    previewTabEl[0].click();
                }
            },
        });

        editor.on('BeforeExecCommand', handleExec);
        editor.on('ExecCommand', handleExec);
        editor.on('ScrollContent', handleScroll);

        editor.editorManager.on('BeforeUnload', function (e) {
            editor.off('BeforeExecCommand', handleExec);
            editor.off('ExecCommand', handleExec);
            editor.off('ScrollContent', handleScroll);
        });
    });
}());