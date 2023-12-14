(function () {
    'use strict';

    tinymce.PluginManager.add('coviformat', function(editor, url) {
        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
		var _formats = {
            bold: false,
            italic: false,
            sub: false,
            sup: false,
            lineThrough: false,
            underline: false,
            color: '',
            backgroundColor: '',
            fontSize: '',
            fontFamily: '',
        };
        var _isSelected = function (value, selector) {
            var listElm = editor.dom.getParent(editor.selection.getNode(), selector);
            var listStyle = editor.dom.getStyle(listElm, 'listStyleType');
            return value === listStyle;
        };
        var _isChildOfBody = function (editor, elm) {
            return editor.$.contains(editor.getBody(), elm);
        };
        var _isTableCellNode = function (node) {
            return node && /^(TH|TD)$/.test(node.nodeName);
        };
        var _isListNode = function (editor) {
            return function (node) {
                return node && /^(OL|UL|DL)$/.test(node.nodeName) && _isChildOfBody(editor, node);
            };
        };
        var _findIndex = function (list, predicate) {
            for (var index = 0; index < list.length; index++) {
                var element = list[index];
                if (predicate(element)) {
                    return index;
                }
            }
            return -1;
        };
        var _isWithinList = function (editor, e, nodeName) {
            var tableCellIndex = _findIndex(e.parents, _isTableCellNode);
            var parents = tableCellIndex !== -1 ? e.parents.slice(0, tableCellIndex) : e.parents;
            var lists = _tool.grep(parents, _isListNode(editor));
            return lists.length > 0 && lists[0].nodeName === nodeName;
        };
        var _makeSetupHandler = function (editor, nodeName) {
            return function (api) {
                var nodeChangeHandler = function (e) {
                    api.setActive(_isWithinList(editor, e, nodeName));
                };
                editor.on('NodeChange', nodeChangeHandler);
                return function () {
                    return editor.off('NodeChange', nodeChangeHandler);
                };
            };
        };
        
        editor.ui.registry.addMenuItem('coviindent', {
            text: 'Increase indent',
            icon: 'indent',
            onAction: function() {
                return editor.execCommand('indent');
            }
        });

        editor.ui.registry.addMenuItem('covioutdent', {
            text: 'Decrease indent',
            icon: 'outdent',
            onAction: function() {
                return editor.execCommand('outdent');
            }
        });

        editor.ui.registry.addNestedMenuItem('covinumberlist', {
            text: tinymce.util.I18n.translate("Numbered list"),
            getSubmenuItems: function() {
                return [{
                    type: 'togglemenuitem',
                    text: 'Row header number',
                    icon: 'list-num-default',
                    onAction: function () {
                        editor.execCommand("InsertOrderedList", false, { "list-style-type": "" });
                    },
                    onSetup: function (api) {
                        api.setActive(_isSelected("", 'ol'));
                    }
                }, {
                    type: 'togglemenuitem',
                    text: 'Row header lower alpha',
                    icon: 'list-num-lower-alpha',
                    onAction: function() {
                        editor.execCommand("InsertOrderedList", false, { "list-style-type": "lower-alpha" });
                    },
                    onSetup: function (api) {
                        api.setActive(_isSelected("lower-alpha", 'ol'));
                    }
                }, {
                    type: 'togglemenuitem',
                    text: 'Row header lower greek',
                    icon: 'list-num-lower-greek',
                    onAction: function() {
                        editor.execCommand("InsertOrderedList", false, { "list-style-type": "lower-greek" });
                    },
                    onSetup: function (api) {
                        api.setActive(_isSelected("lower-greek", 'ol'));
                    }
                }, {
                    type: 'togglemenuitem',
                    text: 'Row header lower roman',
                    icon: 'list-num-lower-roman',
                    onAction: function() {
                        editor.execCommand("InsertOrderedList", false, { "list-style-type": "lower-roman" });
                    },
                    onSetup: function (api) {
                        api.setActive(_isSelected("lower-roman", 'ol'));
                    }
                }, {
                    type: 'togglemenuitem',
                    text: 'Row header upper alpha',
                    icon: 'list-num-upper-alpha',
                    onAction: function() {
                        editor.execCommand("InsertOrderedList", false, { "list-style-type": "upper-alpha" });
                    },
                    onSetup: function (api) {
                        api.setActive(_isSelected("upper-alpha", 'ol'));
                    }
                }, {
                    type: 'togglemenuitem',
                    text: 'Row header upper roman',
                    icon: 'list-num-upper-roman',
                    onAction: function() {
                        editor.execCommand("InsertOrderedList", false, { "list-style-type": "upper-roman" });
                    },
                    onSetup: function (api) {
                        api.setActive(_isSelected("upper-roman", 'ol'));
                    }
                }];
            }
        });
		editor.ui.registry.addSplitButton('covinumberlist', {
            tooltip: tinymce.util.I18n.translate("Numbered list"),
            icon: 'ordered-list',
            presets: 'listpreview',
            columns: 1,
            fetch: function (callback) {
                var items = [
                    {
                        type: 'choiceitem',
                        value: '',
                        text: 'Row header number',
                        icon: 'list-num-default'
                    },
                    {
                        type: 'choiceitem',
                        value: 'lower-alpha',
                        text: 'Row header lower alpha',
                        icon: 'list-num-lower-alpha'
                    },
                    {
                        type: 'choiceitem',
                        value: 'lower-greek',
                        text: 'Row header lower greek',
                        icon: 'list-num-lower-greek'
                    },
                    {
                        type: 'choiceitem',
                        value: 'lower-roman',
                        text: 'Row header lower roman',
                        icon: 'list-num-lower-roman'
                    },
                    {
                        type: 'choiceitem',
                        value: 'upper-alpha',
                        text: 'Row header upper alpha',
                        icon: 'list-num-upper-alpha'
                    },
                    {
                        type: 'choiceitem',
                        value: 'upper-roman',
                        text: 'Row header upper roman',
                        icon: 'list-num-upper-roman'
                    }
                ];
                callback(items);
            },
            onAction: function () {
              return editor.execCommand('InsertOrderedList');
            },
            onItemAction: function (_splitButtonApi, value) {
                editor.execCommand("InsertOrderedList", false, { "list-style-type": value });
            },
            select: function (value) {
                return _isSelected(value, 'ol');
            },
            onSetup: _makeSetupHandler(editor, 'OL')
        });

        editor.ui.registry.addNestedMenuItem('covibulletlist', {
            text: tinymce.util.I18n.translate("Bullet list"),
            getSubmenuItems: function() {
                return [{
                    type: 'togglemenuitem',
                    text: 'Row header full circle',
                    icon: 'list-bull-default',
                    onAction: function () {
                        editor.execCommand("InsertUnorderedList", false, { "list-style-type": "" });
                    },
                    onSetup: function (api) {
                        api.setActive(_isSelected("", 'ul'));
                    }
                }, {
                    type: 'togglemenuitem',
                    text: 'Row header empty circle',
                    icon: 'list-bull-circle',
                    onAction: function() {
                        editor.execCommand("InsertUnorderedList", false, { "list-style-type": "circle" });
                    },
                    onSetup: function (api) {
                        api.setActive(_isSelected("circle", 'ul'));
                    }
                }, {
                    type: 'togglemenuitem',
                    text: 'Row header full square',
                    icon: 'list-bull-square',
                    onAction: function() {
                        editor.execCommand("InsertUnorderedList", false, { "list-style-type": "square" });
                    },
                    onSetup: function (api) {
                        api.setActive(_isSelected("square", 'ul'));
                    }
                }];
            }
        });

		editor.ui.registry.addSplitButton('covibulletlist', {
            tooltip: tinymce.util.I18n.translate("Bullet list"),
            icon: 'unordered-list',
            presets: 'listpreview',
            columns: 1,
            fetch: function (callback) {
                var items = [
                    {
                        type: 'choiceitem',
                        value: '',
                        text: 'Row header full circle',
                        icon: 'list-bull-default'
                    },
                    {
                        type: 'choiceitem',
                        value: 'circle',
                        text: 'Row header empty circle',
                        icon: 'list-bull-circle',
                    },
                    {
                        type: 'choiceitem',
                        value: 'square',
                        text: 'Row header full square',
                        icon: 'list-bull-square'
                    }
                ];
                callback(items);
            },
            onAction: function () {
                return editor.execCommand('InsertUnorderedList');
            },
            onItemAction: function (_splitButtonApi, value) {
                editor.execCommand("InsertUnorderedList", false, { "list-style-type": value });
            },
            select: function (value) {
                return _isSelected(value, 'ul');
            },
            onSetup: _makeSetupHandler(editor, 'UL')
        });

		editor.ui.registry.addMenuItem('covicopyformat', {
            text: 'Copy formatting',
            icon: 'copy-format',
            onAction: function() {
                return editor.execCommand('coviCopyFormat');
            }
        });

		editor.ui.registry.addButton('covicopyformat', {
            tooltip: 'Copy formatting',
            icon: 'copy-format',
            onAction: function() {
                return editor.execCommand('coviCopyFormat');
            }
        });
        
        editor.ui.registry.addMenuItem('covipasteformat', {
            text: 'Paste formatting',
            icon: 'paste-format',
            onAction: function() {
                return editor.execCommand('coviPasteFormat');
            }
        });
        
        editor.ui.registry.addButton('covipasteformat', {
            tooltip: 'Paste formatting',
            icon: 'paste-format',
            onAction: function() {
                return editor.execCommand('coviPasteFormat');
            }
        });
        
        editor.addCommand('coviCopyFormat', function() {
            var parser = tinymce.util.Tools.resolve('tinymce.html.DomParser')({validate: true}, editor.schema);
            var styleParser = new tinymce.html.Styles();
            var blocks = editor.selection.getSelectedBlocks();
            var content = editor.selection.getContent({format: 'raw', contextual: true});
            var selectedHtml = "";
            if (blocks.length > 1) {
                selectedHtml = blocks[0].innerHTML;
            } else {
                selectedHtml = content;
            }

            if (selectedHtml && selectedHtml.length > 0) {
                _formats = {
                    bold: false,
                    italic: false,
                    sub: false,
                    sup: false,
                    lineThrough: false,
                    underline: false,
                    color: '',
                    backgroundColor: '',
                    fontSize: '',
                    fontFamily: '',
                };
                parser.addNodeFilter('span,em,strong,sup,sub', function (nodes) {
                    for (var i = 0; i < nodes.length; i++) {
                        var node = nodes[i];
                        switch(node.name) {
                            case "span":
                                var style = styleParser.parse(node.attr('style'));
                                if (style['font-size'] && style['font-size'].length > 0) {
                                    _formats.fontSize = style['font-size'];
                                }
                                if (style['font-family'] && style['font-family'].length > 0) {
                                    _formats.fontFamily = style['font-family'];
                                }
                                if (style['font-weight'] && style['font-weight'] === 'bold') {
                                    _formats.bold = true;
                                }
                                if (style['font-style'] && style['font-style'] === 'italic') {
                                    _formats.italic = true;
                                }
                                if (style['color'] && style['color'].length > 0) {
                                    _formats.color = style['color'];
                                }
                                if (style['background-color'] && style['background-color'].length > 0) {
                                    _formats.backgroundColor = style['background-color'];
                                }
                                if (style['text-decoration'] && style['text-decoration'] === 'underline') {
                                    _formats.underline = true;
                                }
                                if (style['text-decoration'] && style['text-decoration'] === 'line-through') {
                                    _formats.lineThrough = true;
                                }
                                if (style['text-decoration'] && (style['text-decoration'] === 'underline line-through' || style['text-decoration'] === 'line-through underline')) {
                                    _formats.underline = true;
                                    _formats.lineThrough = true;
                                }
                                break;
                            case "em":
                                _formats.italic = true;
                                break;
                            case "strong":
                                _formats.bold = true;
                                break;
                            case "sup":
                                if (!node.prev && !node.next) {
                                    _formats.sup = true;
                                }
                                break;
                            case "sub":
                                if (!node.prev && !node.next) {
                                    _formats.sub = true;
                                }
                                break;
                            default:
                                break;
                        }
                    }
                })
                parser.parse(selectedHtml);
            }
        });
        
        editor.addCommand('coviPasteFormat', function() {
            editor.undoManager.transact(function () {
                editor.execCommand('RemoveFormat');
                if (_formats.bold) {
                    editor.execCommand('Bold');
                }
                if (_formats.italic) {
                    editor.execCommand('italic');
                }
                if (_formats.sub) {
                    editor.execCommand('Subscript');
                }
                if (_formats.sup) {
                    editor.execCommand('Superscript');
                }
                if (_formats.underline) {
                    editor.execCommand('underline');
                }
                if (_formats.lineThrough) {
                    editor.execCommand('strikethrough');
                }
                if (_formats.color && _formats.color.length > 0) {
                    editor.execCommand('mceApplyTextcolor', 'forecolor', _formats.color);
                }
                if (_formats.backgroundColor && _formats.backgroundColor.length > 0) {
                    editor.execCommand('mceApplyTextcolor', 'hilitecolor', _formats.backgroundColor);
                }
                if (_formats.fontSize && _formats.fontSize.length > 0) {
                    editor.execCommand('FontSize', false, _formats.fontSize)
                }
                if (_formats.fontFamily && _formats.fontFamily.length > 0) {
                    editor.execCommand('FontName', false, _formats.fontFamily)
                }
            });
        });
        
        var isList = function(elem) {
            var name = elem.nodeName.toLowerCase();

            return (name === 'ul' || name === 'ol' || name === 'dl');
        }
        var isListItem = function(elem) {
            var name = elem.nodeName.toLowerCase();

            return (name === 'li' || name === 'dt' || name === 'dd');
        }

        editor.on('BeforeExecCommand', function(e) {
            if (e.command === 'InsertOrderedList' || e.command === 'InsertUnorderedList') {
                 var selNode = editor.selection.getNode();
               var selectedNodes = editor.selection.getSelectedBlocks();

               _tool.each(selectedNodes, function(node) {
                  editor.dom.setStyle(node, 'display', null);
               });

               if (editor.dom.getParent(selNode, 'div', editor.dom.getRoot()) && (isList(selNode) || isListItem(selNode))) {
                   editor.dom.setAttrib(selNode, 'data-mce-contenteditable', 'false');
               }
           }
        });

        editor.on('ExecCommand', function(e) {
            if (e.command === 'InsertOrderedList' || e.command === 'InsertUnorderedList') {
                var listItems = editor.getBody().querySelectorAll('ol,ul');
                var selNode = editor.selection.getNode();
                var selectedNodes = editor.selection.getSelectedBlocks();
				
				_tool.each(listItems, function(item) {
                    editor.dom.setStyle(item, 'list-style-position', 'inside');
                });

                _tool.each(selectedNodes, function(node) {
                    editor.dom.setStyle(node, 'display', null);
                });

                editor.dom.setAttrib(selNode, 'data-mce-contenteditable', null);
            }
        });

        return {
        };
    });
}());