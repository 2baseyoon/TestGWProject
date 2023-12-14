(function () {
    'use strict';

    tinymce.PluginManager.add('covifile', function(editor, url) {
        var _dialog = null;
        var _env = tinymce.util.Tools.resolve('tinymce.Env');
        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
        var _delay = tinymce.util.Tools.resolve('tinymce.util.Delay');
		var _templateArray = "";
		
        function isSupportedFile(filename) {
            if (filename.indexOf('.') === -1) {
                return false;
            }

            var fileExt = filename.split('.').pop().trim().toLowerCase();

            return (fileExt === 'html' || fileExt === 'htm' || fileExt === 'txt');
        }

        function applyHeadStyle(html) {
            try {
                var _tempDoc = null;
                var cssRules = null;
                var parser = tinymce.util.Tools.resolve('tinymce.html.DomParser')({validate: false}, editor.schema);
                var serializer = tinymce.util.Tools.resolve('tinymce.html.Serializer');

                var getTempDoc = function() {
                    if (!_tempDoc) {
                        var iframe = document.createElement("IFRAME");
                        iframe.style.display = "none",
                            document.body.appendChild(iframe);
                        var doc = iframe.contentWindow.document;
                        doc.open();
                        doc.write("<html><head></head><body></body></html>");
                        doc.close();
                        _tempDoc = doc;
                    }

                    return _tempDoc;
                }
                var extractCSSStyleRule = function(styleRules) {
                    var cssStyleRule = {};

                    for (var i = 0; i < styleRules.length; i++) {
                        if (styleRules[i].type == CSSRule.STYLE_RULE) {
                            cssStyleRule[styleRules[i].selectorText] = styleRules[i].style;
                        }
                    }

                    return cssStyleRule;
                }
                var getCSSRule = function(selector) {
                    if (cssRules == null) {
                        return null;
                    }

                    if (cssRules[selector]) {
                        return cssRules[selector];
                    } else {
                        var pattern1 = new RegExp("\\." + selector + "\\b\\s*(,)");
                        var pattern2 = new RegExp("\\." + selector + "$");

                        for (var key in cssRules) {
                            if (pattern1.test(key) || pattern2.test(key)) {
                                return cssRules[key];
                            }
                        }

                        for (var key in cssRules) {
                            var keys = key.split(',');
                            if (keys.length > 1) {
                                for (var i = 0; i < keys.length; i++) {
                                    var k = keys[i].trim();
                                    if (k === selector) {
                                        return cssRules[key];
                                    }
                                }
                            }
                        }
                    }
                    return null;
                }
                var mergeStylesToInline = function(node, cssRule) {
                    var tempEl = document.createElement('div');
                    tempEl.style.cssText = node.attr('style');

                    for (var i = 0; i < cssRule.length; i++) {
                        var styleName = cssRule[i];

                        tempEl.style[styleName] = cssRule[styleName];
                    }
                    node.attr('style', tempEl.style.cssText);
                    tempEl.remove();
                }
                var mergeStylesToClassStyle = function(tagRule, classRule) {
                    for (var i = 0; i < tagRule.length; i++) {
                        var styleName = tagRule[i];

                        classRule[styleName] = tagRule[styleName];
                    }
                }

                if (html && html.length > 0) {
                    parser.addNodeFilter('style', function(nodes) {
                        for (var i = 0; i < nodes.length; i++) {

                            var tempDoc = getTempDoc();
                            var head = tempDoc.getElementsByTagName("HEAD")[0];
                            var style = tempDoc.createElement("STYLE");

                            if (nodes[i].firstChild && nodes[i].firstChild.value) {
                                style.innerHTML = nodes[i].firstChild.value.replaceAll('hairline', 'dotted');

                                head.appendChild(style);
                                if (cssRules == null) {
                                    cssRules = extractCSSStyleRule(style.sheet.cssRules);
                                } else {
                                    Object.assign(cssRules, extractCSSStyleRule(style.sheet.cssRules))
                                }
                                style.parentNode.removeChild(style);

                                if (nodes[i].parent.name === 'head') {
                                    nodes[i].parent.remove();
                                } else {
                                    nodes[i].remove();
                                }
                            }
                        }
                    });

                    parser.addNodeFilter('table,th,tr,td,col,p,h1,h2,h3,h4,h5,h6,em,strong', function(nodes) {
                        for (var i = 0; i < nodes.length; i++) {
                            var node = nodes[i];
                            var css = cssRules ? getCSSRule(node.name) : null;

                            if (css) {
                                if (node.attr('style')) {
                                    mergeStylesToInline(node, css);
                                } else {
                                    node.attr('style', css.cssText);
                                }
                            }
                        }
                    });

                    parser.addAttributeFilter('class', function(nodes, name) {
                        for (var i = 0; i < nodes.length; i++) {
                            var node = nodes[i];
                            var value = node.attr('class');

                            if (value) {
                                var css = cssRules ? getCSSRule(value) : null;

                                if (css) {
                                    if (getCSSRule(node.name)) {
                                        var tagRule = getCSSRule(node.name);
                                        mergeStylesToClassStyle(tagRule, css);
                                    }

                                    if (node.attr('style')) {
                                        mergeStylesToInline(node, css);
                                    } else {
                                        node.attr('style', css.cssText);
                                    }
                                	
									node.attr('class', null);
								}
                            }
                        }
                    });

                    parser.addAttributeFilter('id', function(nodes, name) {
                        for (var i = 0; i < nodes.length; i++) {
                            var node = nodes[i];
                            var value = node.attr('id');

                            if (value) {
                                var id = '#' + value;
                                var css = cssRules ? getCSSRule(id) : null;

                                if (css) {
                                    if (node.attr('style')) {
                                        mergeStylesToInline(node, css);
                                    } else {
                                        node.attr('style', css.cssText);
                                    }
                                }

                                node.attr('id', null);
                            }
                        }
                    });

                    var rootNode = parser.parse(html);
                    html = serializer({ validate: editor.getParam('validate') }, editor.schema).serialize(rootNode);
                }
            } catch (e) {
            	coviCmn.traceLog("Failed to set style to html inline");
            }

            return html;
        }


        function checkTxtFile(filename, rawData) {
            var fileExt = filename.split('.').pop().trim().toLowerCase();
            if (fileExt === 'txt') {
                rawData = rawData.replace(/>/g, '&lt;');
                rawData = rawData.replace(/>/g, '&gt;');
                var rawDataArr = rawData.split(/\r\n|\r|\n/);
                var newStr = '';
                rawDataArr.forEach((str) => {
                    str = str.replace(/\s/g, '&nbsp;');
                    newStr += '<p>' + str + '</p>';
                });

                rawData = newStr;
			} else if (fileExt === 'html' || fileExt === 'htm') {
                rawData = applyHeadStyle(rawData);
            }

            return rawData;
        }

        function getFileOpenDlgOptions() {
            var initData = null;


            return {
                title: 'File open',
                body: {
                    type: 'panel',
                    items: [{
                        name: 'fileopen',
                        type: 'urlinput',
                        filetype: 'file',
                        label: 'File'
                    }, {
                        type: 'htmlpanel',
                        html: '<br/><p>* ' + tinymce.util.I18n.translate('Supported extensions are html, htm, txt.') + '</p>'
                    }]
                },
                initialData: initData,
                onClose: function() {

                },
                onChange: function(api, details) {

                },
                onSubmit: function(api) {
                    var data = api.getData();

                    if (data.fileopen && data.fileopen.meta && data.fileopen.meta.attach) {
                        var file = data.fileopen.meta.attach;

                        if (isSupportedFile(file.name)) {
                            editor.windowManager.confirm("Do you want to apply the selected file?", function (isYes) {
                                if (isYes) {
                                    var reader = new FileReader();

                                    reader.onload = function () {
                                        editor.focus();
                                        editor.undoManager.transact(function () {
                                            //editor.setContent(reader.result);
											editor.setContent(checkTxtFile(file.name, reader.result));
                                        });
                                        editor.selection.setCursorLocation();
                                        editor.nodeChanged();
                                        api.close();
                                    };
                                    reader.readAsText(file, 'UTF-8');
                                }
                            });
                        } else {
                            editor.windowManager.alert("Supported extensions are html, htm, txt.");
                        }
                    } else {
                        api.close();
                    }
                },
                buttons: [{
                    text: 'Close',
                    type: 'cancel',
                    onclick: 'close'
                }, {
                    type: 'submit',
                    name: 'apply',
                    text: 'Apply',
                    primary: true
                }]
            };
        }

        function makeLayoutTableContents() {
            var html = '<div class="covi_layout_dlg_items">' +
                '            <div class="contents">' +
                '                <div class="con con_th">' +
                '                    <table style="border-spacing: 2px" id="temp_table"><tbody>';

            for (var i = 0; i < 3; i++) {
                var tr = '<tr>';

                for (var j = 0; j < 4; j++) {
                    var index = (j + 1) + i * 4;

                    tr += '<td style="cursor: pointer; padding: 20px; border: 1px solid #ccc;"' + 'onclick="coviLayer.selectItem(this);"' + 'url="layout/layout' + index + '.html">' +
                        '  <a href="javascript:void(0);">' +
                        '      <img name="layout1" src="img/layout/layout' + index + '.png" style="border: 1px solid #ccc; height: 61px; width: 61px;">' +
                        '  </a>' +
                        '</td>';
                }

                tr += '</tr>'
                html += tr;
            }

            html += '</tbody></table></div></div></div>';

            return html;
        }

		function makeItemListHTML(index) {
            var html = "";
            var span = "";
            var file = '<span class="icon"><img src="img/file.gif" width="16" height="16"></span>';
            var listItem = "";
            var spanStyle = 'font-size: 14px; white-space: nowrap; text-overflow: ellipsis; padding-left: 5px;';
            var items = _templateArray[index].items;

            for (var i = 0; i < items.length; i++) {
                span = editor.dom.createHTML('span', { style: spanStyle }, items[i].name);
                listItem  = file + span;
                html += editor.dom.createHTML('li', { class: 'template_item_list', id: items[i].id, url: items[i].url, onclick: "coviTemplateItemList.selectItem(this)"}, listItem);
            }

            return html;
        }
        
        function makeTemplateTableContents() {
            function makeFolderListHTML() {
                var html = "";
                var span = "";
                var folder = '<span class="icon"><img src="img/folder.gif" width="16" height="16"></span>';
                var listItem = "";
                var spanStyle = 'font-size: 14px; white-space: nowrap; text-overflow: ellipsis; padding-left: 5px;';

                for (var i = 0; i <  _templateArray.length; i++) {
                    span = editor.dom.createHTML('span', { style: spanStyle }, _templateArray[i].folder_name);
                    listItem = folder + span;
                    if (i == 0) {
                        html += editor.dom.createHTML('li', { class: 'template_folder_list selected', style: 'background-color: #dee0e2', id: i, onclick: "coviTemplateFolderList.selectItem(this)"}, listItem);
                    } else {
                        html += editor.dom.createHTML('li', { class: 'template_folder_list', id: i, onclick: "coviTemplateFolderList.selectItem(this)"}, listItem);
                    }
                }

                return html;
            }
            var folderListHTML = editor.dom.createHTML('ul', {
                id: "covi_template_folder_list",
                style: "list-style: none; padding: 2px 3px; height: 300px; overflow: auto; margin-bottom: 3px;",
                onmouseover: "this.style.cursor= 'pointer'",
                onmouseout: "this.style.cursor= 'auto'"
            }, makeFolderListHTML());
            var itemListHTML = editor.dom.createHTML('ul', {
                id: "covi_template_item_list",
                style: "list-style: none; padding: 2px 3px; height: 300px; overflow: auto; margin-bottom: 3px;",
                onmouseover: "this.style.cursor= 'pointer'",
                onmouseout: "this.style.cursor= 'auto'"
            }, makeItemListHTML(0));

            var html = '<table class="tox-form" style="padding-left: 8px">' +
                '<tr>' +
                '<td><span class="tox-label">' + tinymce.util.I18n.translate("Template") + '</span></td>' +
                '<td><span class="tox-label">' + tinymce.util.I18n.translate("Template list") + '</span></td>' +
                '</tr>' +
                '<tr>' +
                '<td class="covi_template_dlg_templates" style="width: 200px; height: 300px; border:1px solid #ccc; vertical-align: top;">' + folderListHTML + '</td>' +
                '<td class="covi_template_dlg_items" style="width: 200px; height: 300px; border:1px solid #ccc; vertical-align: top;">' + itemListHTML + '</td>' +
                '</tr></table>'

            return html
        }
        
        function changeTemplateItemList(index) {
            var itemListHTML = editor.dom.createHTML('ul', {
                id: "covi_template_item_list",
                style: "list-style: none; padding: 2px 3px; height: 300px; overflow: auto; margin-bottom: 3px;",
                onmouseover: "this.style.cursor= 'pointer'",
                onmouseout: "this.style.cursor= 'auto'"
            }, makeItemListHTML(index));
            var templateItemEl = editor.dom.$.find(".covi_template_dlg_items");
            if (templateItemEl[0].hasChildNodes()) {
                templateItemEl[0].innerHTML = "";
            }
            templateItemEl[0].innerHTML = itemListHTML;
        }
        
        function getLayoutDlgOptions() {
            if (!window.coviLayer) {
                window.coviLayer = {
                    selectItem: function(obj) {
                        var items = document.querySelectorAll(".covi_layout_dlg_items td");
                        _tool.each(items, function(item) {
                            item.style.backgroundColor = '';
                            item.classList.remove('selected');
                        });

                        obj.style.backgroundColor = "#dee0e2";
                        obj.classList.add('selected');
                    }
                }
            }

            return {
                title: 'Layout',
                size: 'small',
                body: {
                    type: 'panel',
                    items: [{
                        type: 'htmlpanel',
                        html: makeLayoutTableContents()
                    }]
                },
                onClose: function() {
                    if (window.coviLayer) {
                        window.coviLayer = undefined;
                    }
                },
                onChange: function(api, details) {
                },
                onSubmit: function(api) {
                    var item = document.querySelector(".covi_layout_dlg_items .selected");

                    if (item) {
                        tinymce.util.XHR.send({
                            url: item.getAttribute('url'),
                            success: function (response) {
                                editor.setContent(response);

                                _dialog.close();
                            },
                            error: function (message) {
                                editor.windowManager.alert('Could not load the specified layout.');
                            }
                        });
                    }
                },
                buttons: [{
                    text: 'Close',
                    type: 'cancel',
                    onclick: 'close'
                }, {
                    type: 'submit',
                    name: 'apply',
                    text: 'Apply',
                    primary: true
                }]
            };
        }

		function getTemplateDlgOptions() {
            if (!window.coviTemplateFolderList) {
                window.coviTemplateFolderList = {
                    selectItem: function(obj) {
                        var items = document.querySelectorAll("#covi_template_folder_list li");
                        _tool.each(items, function(item) {
                            item.style.backgroundColor = '';
                            item.classList.remove('selected');
                        });

                        obj.style.backgroundColor = "#dee0e2";
                        obj.classList.add('selected');
                        changeTemplateItemList(obj.id);
                    }
                }
            }
            if (!window.coviTemplateItemList) {
                window.coviTemplateItemList = {
                    selectItem: function(obj) {
                        var items = document.querySelectorAll("#covi_template_item_list li");
                        _tool.each(items, function(item) {
                            item.style.backgroundColor = '';
                            item.classList.remove('selected');
                        });

                        obj.style.backgroundColor = "#dee0e2";
                        obj.classList.add('selected');
                    }
                }
            }
            _templateArray = editor.getParam('covi_templates', '', 'array');
            return {
                title: 'Template',
                body: {
                    type: 'panel',
                    items: [{
                        type: 'htmlpanel',
                        html: makeTemplateTableContents()
                    }]
                },
                onChange: function (api, details) {
                },
                onSubmit: function (api) {
                    var item = document.querySelector("#covi_template_item_list .selected");
                    
                    if (item) {
                        tinymce.util.XHR.send({
                            url: item.getAttribute('url'),
                            success: function (response) {
                                editor.setContent(response);

                                _dialog.close();
                            },
                            error: function (message) {
                                editor.windowManager.alert('Could not load the specified template.');
                            }
                        });
                    }
                },
                buttons: [{
                    text: 'Close',
                    type: 'cancel',
                    onclick: 'close'
                }, {
                    type: 'submit',
                    name: 'apply',
                    text: 'Apply',
                    primary: true
                }]
            }
        }

        editor.ui.registry.addMenuItem('covifileopen', {
            text: 'File open...',
            icon: 'file-open',
            onAction: function() {
                _dialog = editor.windowManager.open(getFileOpenDlgOptions());
            },
        });

        editor.ui.registry.addMenuItem('covifilesave', {
            text: 'Save',
            icon: 'save',
            onAction: function() {
                var contentStyle = editor.getParam('content_style', '', 'string');
                var content = '<html><head><style type="text/css">' + contentStyle + '</style></head><body>' + editor.getContent({format: 'raw', no_events: true}) + '</body></html>';
                var blob = new Blob([content], {type: 'text/html;charset=utf-8'});
                var fileName = 'Untitled.html';
                var a = document.createElement('a');

                if (_env.ie) {
                    if (window.navigator.msSaveOrOpenBlob) {
                        window.navigator.msSaveOrOpenBlob(blob, fileName);
                    } else {
                        var url = window.URL.createObjectURL(blob);
                        a.href = url;
                        a.download = fileName;
                        document.body.appendChild(a);
                        a.click();
                        setTimeout(function() {
                            document.body.removeChild(a);
                            window.URL.revokeObjectURL(url);
                        }, 0);
                    }
                } else {
                    a.href = window.URL.createObjectURL(blob);
                    a.download = fileName;
                    a.style.display = 'none';

                    document.body.appendChild(a);
                    a.click();
                    document.body.removeChild(a);
                }
            },
        });

        editor.ui.registry.addButton('covifilesave', {
            icon: 'save',
            tooltip: 'Save',
            onAction: function() {
                var contentStyle = editor.getParam('content_style', '', 'string');
                var content = '<html><head><style type="text/css">' + contentStyle + '</style></head><body>' + editor.getContent({format: 'raw'}) + '</body></html>';
                var blob = new Blob([content], {type: 'text/html;charset=utf-8'});
                var fileName = 'Untitled.html';
                var a = document.createElement('a');

                if (_env.ie) {
                    if (window.navigator.msSaveOrOpenBlob) {
                        window.navigator.msSaveOrOpenBlob(blob, fileName);
                    } else {
                        var url = window.URL.createObjectURL(blob);
                        a.href = url;
                        a.download = fileName;
                        document.body.appendChild(a);
                        a.click();
                        setTimeout(function() {
                            document.body.removeChild(a);
                            window.URL.revokeObjectURL(url);
                        }, 0);
                    }
                } else {
                    a.href = window.URL.createObjectURL(blob);
                    a.download = fileName;
                    a.style.display = 'none';

                    document.body.appendChild(a);
                    a.click();
                    document.body.removeChild(a);
                }
            },
        });

        editor.ui.registry.addMenuItem('covifilelayout', {
            text: 'Layout...',
            icon: 'covi-file-layout',
            onAction: function() {
                _dialog = editor.windowManager.open(getLayoutDlgOptions());

                _delay.setEditorTimeout(editor, function() {
                    var defaultSelected = document.querySelector(".covi_layout_dlg_items td");
                    coviLayer.selectItem(defaultSelected);
                }, 0);
            },
        });
		
		editor.ui.registry.addButton('covifiletemplate', {
			tooltip: 'Template...',
            icon: 'template',
            onAction: function() {
                _dialog = editor.windowManager.open(getTemplateDlgOptions());
            },
        });
        
		editor.ui.registry.addMenuItem('covifiletemplate', {
            icon: 'template',
            text: 'Template...',
            onAction: function() {
                _dialog = editor.windowManager.open(getTemplateDlgOptions());
            },
        });

		editor.ui.registry.addMenuItem('covifilehelp', {
            icon: 'help',
            text: 'User Help',
            onAction: function() {
                var _width = 1120;
                var _height = 720;
                var _left = Math.ceil(( window.screen.width - _width )/2);
                var _top = Math.ceil(( window.screen.height - _height )/2);

				let openUrl = "help/publish/index.html?ver=" + COVIEDITOR_CONFIG.editorVersion;
				window.open(openUrl, "_blank", "width="+_width+",height="+_height+",top="+_top+",left="+_left+", menubar=no, toolbar=no");
            },
        });

    });
}());