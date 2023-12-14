
var COVIEDITOR_CONFIG = {}

var CoviEditor = function(containerID) {
    var _localStorage = tinymce.util.Tools.resolve('tinymce.util.LocalStorage');
    var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
    var _delay = tinymce.util.Tools.resolve('tinymce.util.Delay');
    var _env = tinymce.util.Tools.resolve('tinymce.Env');
    var _parser = tinymce.util.Tools.resolve('tinymce.html.DomParser');
    var _serializer = tinymce.util.Tools.resolve('tinymce.html.Serializer');
    var _timerId = null;
    var _defaultStyle = null;
    var _lineStyleNameMap = {
        solid: 'table-border-solid',
        dotted: 'table-border-dotted',
        dashed: 'table-border-dashed',
        double: 'table-border-double',
        groove: 'table-border-groove',
        ridge: 'table-border-ridge',
        inset: 'table-border-inset',
        outset: 'table-border-outset'
    };
    var DEFAULT_STYLE_KEY = 'covi_default_style';
    var SELECTION_QUICK_BAR_KEY = 'covi_select_quickbar_enable';
    var INSERT_QUICK_BAR_KEY = 'covi_insert_quickbar_enable';

    var getFontList = function(config) {
        var list = config.font_formats.split(';');

        list = _tool.map(list, function(font) {
            var fontArr = font.split('=');

            return {
                text: fontArr[0].trim(),
                value: fontArr[1].trim()
            }
        });

        return list;
    }

    var filePickerFn = function (callback, value, meta) {
        if (meta.filetype === 'image') {
            var input = document.createElement('input');
            input.setAttribute('type', 'file');
            input.setAttribute('accept', 'image/*');

            input.onchange = function() {
                var file = this.files[0];

                var reader = new FileReader();
                reader.onload = function () {
                    var id = 'blobid' + (new Date()).getTime();
                    var blobCache =  tinymce.activeEditor.editorUpload.blobCache;
                    var base64 = reader.result.split(',')[1];
                    var blobInfo = blobCache.create(id, file, base64);
                    blobCache.add(blobInfo);

                    callback(blobInfo.blobUri(), { title: file.name });
                };
                reader.readAsDataURL(file);
            };

            input.click();
        }

        if (meta.filetype === 'file') {
            if (meta.fieldname === 'file' || meta.fieldname === 'bgimage') {
                var acceptImage = '.gif, .jpg, .jpeg, .png, .bmp';
                var acceptVideo = '.wmv, .asf, .swf, .avi, .mpg, .mpeg, .mp4, .flv';
                var acceptFile = '.txt, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .hwp, .zip, .pdf';
                var input = document.createElement('input');
                input.setAttribute('type', 'file');
                input.setAttribute('accept', meta.fieldname === 'bgimage' ? acceptImage : (acceptImage + ', ' + acceptVideo + ', ' + acceptFile));

                input.onchange = function () {
                    var file = this.files[0];

                    callback(file.name, {attach: file});
                };

                input.click();
            } else if (meta.fieldname === 'fileopen') {
                var input = document.createElement('input');
                input.setAttribute('type', 'file');
                input.setAttribute('accept', '.html, .htm, .txt');

                input.onchange = function () {
                    var file = this.files[0];

                    callback(file.name, {attach: file});
                };

                input.click();
            }
        }
    }

    var handleGetContent = function(editor, e) {
		
	
        if (e.covi_out !== undefined && e.content.length) {
            var pageBreakSeparatorRegExp = /&lt;[^&]--\s*pagebreak\s*--&gt;/gi;
            var placeHolderHtml = '';
            e.content = e.content.replace(pageBreakSeparatorRegExp, placeHolderHtml);
        }
        if (e.covi_out && e.content.length > 0) {
            var docEl = editor.getDoc().documentElement;
            var bodyEl = editor.getBody();

			var height = Math.max(bodyEl.scrollHeight, bodyEl.offsetHeight, docEl.clientHeight, docEl.scrollHeight, docEl.offsetHeight)
            
            
            e.content = '<div class="covi_out_wrapper" style="background-image:' + editor.dom.encode(editor.dom.getStyle(bodyEl, 'backgroundImage', true).replace(/\"/gi,"'")) +
                ';background-attachment:' + editor.dom.getStyle(bodyEl, 'backgroundAttachment', true) +
                ';background-repeat:' + editor.dom.getStyle(bodyEl, 'backgroundRepeat', true) +
                ';background-color:' + editor.dom.getStyle(bodyEl, 'backgroundColor', true) +
                ';min-height:100px;">' + e.content + '</div>';
        }
        
        // 23.11.02, covision 자체수정, codeSample 오류 수정, 시작. codeSample 내용이 있으면 에디터에서 적용된 스타일을 inline으로 입력.
		var codeSampleContent = editor.dom.select('pre[class*=language-]', editor.getBody());
		if (codeSampleContent.length > 0) {
			compareMatchStyle(editor, e);
		}
		// 23.11.02, covision 자체수정, codeSample 오류 수정, 끝.
    }

	// 23.11.02, covision 자체수정 내용, codeSample 오류 수정, 시작.
    var compareMatchStyle = function(editor, e) {
		// codeSample에서 적용되어야 하는 style 항목.
		var cssArr = ['background','borderRadius','color','cursor','fontFamily','fontStyle','fontWeight','fontSize','hyphens','lineHeight','margin','opacity','overflow','padding','tabSize','textAlign','textShadow','whiteSpace','wordBreak','wordSpacing','wordWrap'];
		var originElemList = editor.dom.select('*', editor.getBody());
		
		for (var element of originElemList) {
			if ($(element).closest('pre[class*=language-]').length>0) {
				for (var key of cssArr) {
					if (element.style[key] !== undefined) {
						editor.dom.setStyle(element, key, window.getComputedStyle(element)[key]);
					}
				}		
			}
		}
		e.content = editor.getBody().innerHTML;
	}
	// 23.11.02, covision 자체수정 내용, codeSample 오류 수정, 끝.

    var handleBeforeGetContent = function(editor, e) {
        var htmlView = editor.dom.$.find('#covieditorContainer_html');

        if (!e.source_view && !e.preview_view && htmlView.length > 0 && htmlView[0].value.length > 0 && editor.dom.getStyle(htmlView[0], 'display') !== 'none') {
            editor.setContent(htmlView[0].value);
        }

		if (e.covi_out !== undefined) {
			var allElemList = editor.dom.select('*', editor.getBody());
	        var i = allElemList.length;
			var hTag = ['h1','h2','h3','h4','h5','h6'];

	        loadDefaultStyles();

			while(i--) {
            	var el = allElemList[i];

				if (el.style.fontFamily !== undefined && el.style.fontFamily.length === 0) {
					var font;

                    if (window.getComputedStyle(el).fontFamily.length > 0) {
                        font = window.getComputedStyle(el).fontFamily;
                    } else {
                        font = (_defaultStyle && _defaultStyle.font) ? _defaultStyle.font : '';
                    }

                    editor.dom.setStyle(el, 'font-family', font);
                }
                if (el.style.fontSize !== undefined && el.style.fontSize.length === 0) {
                    var fontSize;

                    if (window.getComputedStyle(el).fontSize.length > 0) {
                        fontSize = window.getComputedStyle(el).fontSize;
                    } else {
                        fontSize = (_defaultStyle && _defaultStyle.fontSize) ? _defaultStyle.fontSize : '';
                    }

                    editor.dom.setStyle(el, 'font-size', fontSize)
                }
                if (el.style.lineHeight !== undefined && el.style.lineHeight.length === 0 && el.parentElement.nodeName.toLowerCase() === 'body') {
                    editor.dom.setStyle(el, 'line-height', ((_defaultStyle && _defaultStyle.line_height) ? _defaultStyle.line_height : ''))
                }
                if (!_env.browser.isIE()) {
                    if (el.style.textAlign !== undefined && el.style.textAlign.length === 0) { editor.dom.setStyle(el, 'text-align', window.getComputedStyle(el).textAlign || '') }
                }
                if (el.style.textIndent !== undefined && el.style.textIndent.length === 0) { editor.dom.setStyle(el, 'text-indent', window.getComputedStyle(el).textIndent || '') }
                if (el.style.display !== undefined && el.style.display.length === 0) { editor.dom.setStyle(el, 'display', window.getComputedStyle(el).display || '') }
                if (el.style.float !== undefined && el.style.float.length === 0) { editor.dom.setStyle(el, 'float', 'none') }
                //if (el.style.color !== undefined && el.style.color.length === 0) { editor.dom.setStyle(el, 'color', window.getComputedStyle(el).color || '') }
                if (el.style.paddingLeft !== undefined && el.style.paddingLeft.length === 0) { editor.dom.setStyle(el, 'padding-left', window.getComputedStyle(el).paddingLeft || '') }
                if (el.style.paddingRight !== undefined && el.style.paddingRight.length === 0) { editor.dom.setStyle(el, 'padding-right', window.getComputedStyle(el).paddingRight || '') }
                if (el.style.paddingTop !== undefined && el.style.paddingTop.length === 0) { editor.dom.setStyle(el, 'padding-top', window.getComputedStyle(el).paddingTop || '') }
                if (el.style.paddingBottom !== undefined && el.style.paddingBottom.length === 0) { editor.dom.setStyle(el, 'padding-bottom', window.getComputedStyle(el).paddingBottom || '') }
                if (el.style.marginLeft !== undefined && el.style.marginLeft.length === 0) {
					if (!(el.nodeName.toLowerCase() === 'table' && el.align !== undefined && (el.align === 'left' || el.align === 'center' || el.align === 'right'))) {
                        editor.dom.setStyle(el, 'margin-left', window.getComputedStyle(el).marginLeft || '')
                    } else { 	// 23.11.14, covision 자체수정 float 삭제
						editor.dom.setStyle(el, 'float', '');
					}
                }
                if (el.style.marginRight !== undefined && el.style.marginRight.length === 0) {
                    if (!(el.nodeName.toLowerCase() === 'table' && el.align !== undefined && (el.align === 'left' || el.align === 'center' || el.align === 'right'))) {
                        editor.dom.setStyle(el, 'margin-right', window.getComputedStyle(el).marginRight || '')
                    } else { 	// 23.11.14, covision 자체수정 float 삭제
						editor.dom.setStyle(el, 'float', '');
					}
                }
                if (el.style.marginTop !== undefined && el.style.marginTop.length === 0) { editor.dom.setStyle(el, 'margin-top', window.getComputedStyle(el).marginTop || '') }
                if (el.style.marginBottom !== undefined && el.style.marginBottom.length === 0) { editor.dom.setStyle(el, 'margin-bottom', window.getComputedStyle(el).marginBottom || '') }

                if (el.nodeName.toLowerCase() === 'ul') {
                    editor.dom.setStyle(el, 'listStyleImage', editor.dom.getStyle(el, 'listStyleImage', true));
                    editor.dom.setStyle(el, 'listStylePosition', editor.dom.getStyle(el, 'listStylePosition', true));
                    editor.dom.setStyle(el, 'listStyleType', editor.dom.getStyle(el, 'listStyleType', true));
                }

                if (el.nodeName.toLowerCase() === 'hr') {
                    editor.dom.setStyle(el, 'margin-left', '0px');
                    editor.dom.setStyle(el, 'margin-right', '0px');
                }

				if (hTag.indexOf(el.nodeName.toLowerCase()) > -1) {
                    editor.dom.setStyle(el, 'font-weight', 'bold');
                }

				if (el.classList.contains('mce-pagebreak')) {
                    editor.dom.setStyle(el.parentElement, 'pageBreakBefore', 'always');
            	}

                var dataMceStyle = editor.dom.getAttrib(el, 'data-mce-style');
                if (dataMceStyle) {
                    editor.dom.$(el).attr('style', dataMceStyle);
                    editor.dom.setAttrib(el, 'data-mce-style', null);
                }
                
                if (el.classList.contains('covi_layout')) {
                    el.classList.replace('covi_layout', 'covi_layout_disabled');
                }
			}
        }
    }

    var handleBeforeSetContent = function(editor, e) {
		if (e.covi_out !== undefined) {
			var parser = _parser({validate: true}, editor.schema);
        
            parser.addNodeFilter('div,td', function (nodes) {
                for (var i = 0; i < nodes.length; i++) {
                    var node = nodes[i];
                    var hasWrapper = (node.name === 'div' && node.attr('class') === 'covi_out_wrapper');
                    var hasCoviContentTable = (node.name === 'td' && node.attr('id') === 'tbContentElement');

                    if (hasWrapper) {
                        var styles = new tinymce.html.Styles();
                        var styleObj = styles.parse(node.attr('style'));
                        var backgroundImage = styleObj['background-image'];
                        var backgroundAttachment = styleObj['background-attachment'];
                        var backgroundRepeat = styleObj['background-repeat'];
                        var backgroundColor = styleObj['background-color'];
                        var bodyEl = editor.getBody();

                        if (backgroundImage) {
                            editor.dom.setStyle(bodyEl, 'background-image', backgroundImage);
                        }

                        if (backgroundAttachment) {
                            editor.dom.setStyle(bodyEl, 'background-attachment', backgroundAttachment);
                        }

                        if (backgroundRepeat) {
                            editor.dom.setStyle(bodyEl, 'background-repeat', backgroundRepeat);
                        }

                        if (backgroundColor) {
                            editor.dom.setStyle(bodyEl, 'background-color', backgroundColor);
                        }

                        node.unwrap();
                    }

                    if (hasCoviContentTable) {
                        var parent = node.parent;

                        while (parent) {
                            if (parent.name === 'table' && parent.attr('class') === 'table_form_info_draft') {
                                parent.replace(node);
                                node.unwrap();
                                break;
                            }

                            parent = parent.parent;
                        }
                    }
                }
            });
		
	        parser.addNodeFilter('p', function (nodes) {
	            for (var i = 0; i < nodes.length; i++) {
	                var node = nodes[i];
	                var styles = new tinymce.html.Styles();
	                var styleObj = styles.parse(node.attr('style'));
	                var breakBefore = styleObj['break-before'];
	                if (breakBefore && breakBefore === 'page') {
	                    if (node.firstChild && node.firstChild === node.lastChild && node.firstChild.value !== undefined) {
	                        node.firstChild.value = '<!-- pagebreak -->';
	                    }
	                }
	            }
	        });

	        var rootNode = parser.parse(e.content);
	        e.content = _serializer({}, editor.schema).serialize(rootNode);
		}
		
        if (e.content.length > 0) {
            var pageBreakSeparatorRegExp = /&lt;[^&]--\s*pagebreak\s*--&gt;/gi;
            var placeHolderHtml = '<img src="' + _env.transparentSrc + '" class=mce-pagebreak data-mce-resize="false" data-mce-placeholder />';
            e.content = e.content.replace(pageBreakSeparatorRegExp, placeHolderHtml);
        }
    }

    var postProcessInvalidTag = function(editor) {
        var addMissingNewline = function (elem) {
            if (elem) {
                for (var nodes = elem.childNodes, i = nodes.length; i--;) {
                    var node = nodes[i], nodeType = node.nodeType, nodeName = node.nodeName.toLowerCase();

                    if ((nodeName === 'p' || nodeName === 'span') && node.textContent.length === 0 && node.childElementCount === 0) {
                        node.appendChild(document.createElement('br'));
                    }

                    if (nodeType == 1 || nodeType == 9 || nodeType == 11) {
                        addMissingNewline(node);
                    }
                }
            }
        }

        addMissingNewline(editor.getBody());
    }

	var postProcessCoviLayoutDisabled = function (editor) {
        var oldToken = 'covi_layout_disabled';
        var newToken = 'covi_layout';
        var coviLayouts = editor.getBody().querySelectorAll('.' + oldToken);

        _tool.each(coviLayouts, function (coviLayout) {
            coviLayout.classList.replace(oldToken, newToken);
        });
    }

    var preventDeleteBulletByOutdent = function(editor, e) {
        var bodyEl = editor.getBody();
        var bodyMarginLeft = parseInt(editor.$(bodyEl).css('margin-left'));
        var selectedNode = editor.selection.getNode();
        var selectedNodeName = selectedNode.nodeName.toLowerCase();
        var boundingRect = null;

        if (selectedNodeName === 'ul' || selectedNodeName === 'ol' || selectedNodeName === 'dl') {
            boundingRect = selectedNode.getBoundingClientRect();
        } else if (selectedNodeName === 'li' || selectedNodeName === 'dt' || selectedNodeName === 'dd') {
            boundingRect = selectedNode.parentElement.getBoundingClientRect();
        }

        if (boundingRect) {
            if (boundingRect.left - bodyMarginLeft <= 0) {
                e.preventDefault();
                e.stopImmediatePropagation();
            }
        }
    }
    var loadDefaultStyles = function(config) {
        var defaultStyleStr = _localStorage.getItem(DEFAULT_STYLE_KEY);

        if (defaultStyleStr) {
            _defaultStyle = JSON.parse(defaultStyleStr);
        }

        if (config !== undefined) {
            if (_defaultStyle) {
                config.covi_default_font = _defaultStyle.font || config.covi_default_font;
                config.covi_default_font_size = _defaultStyle.font_size || config.covi_default_font_size;
                config.covi_default_line_height = _defaultStyle.line_height || config.covi_default_line_height;
            } else {
                _defaultStyle = {
                    font: config.covi_default_font,
                    font_size: config.covi_default_font_size,
                    line_height: config.covi_default_line_height
                }

                _localStorage.setItem(DEFAULT_STYLE_KEY, JSON.stringify(_defaultStyle));
            }
        }
    }
	var checkUseQuickbar = function (config) {
        var insertQuickbarValue = JSON.parse(_localStorage.getItem(INSERT_QUICK_BAR_KEY));
        var selectQuickbarValue = JSON.parse(_localStorage.getItem(SELECTION_QUICK_BAR_KEY));
        if (insertQuickbarValue == null) {
            if (config.quickbars_insert_toolbar_enable !== undefined) {
                _localStorage.setItem(INSERT_QUICK_BAR_KEY, JSON.stringify(config.quickbars_insert_toolbar_enable));
            } else {
                _localStorage.setItem(INSERT_QUICK_BAR_KEY, JSON.stringify(false));
            }
        }
        if (selectQuickbarValue == null) {
            if (config.quickbars_selection_toolbar_enable !== undefined) {
                _localStorage.setItem(SELECTION_QUICK_BAR_KEY, JSON.stringify(config.quickbars_selection_toolbar_enable));
            } else {
                _localStorage.setItem(SELECTION_QUICK_BAR_KEY, JSON.stringify(false));
            }
        }
    }
    var initEditor = function(config) {
        var frameHeight = '380';

        if (window.parent.coviEditor != null && window.parent.coviEditor.editorVariables[containerID] != null && window.parent.coviEditor.editorVariables[containerID].frameHeight != undefined) {
            frameHeight = window.parent.coviEditor.editorVariables[containerID].frameHeight - 8;
        }

        loadDefaultStyles(config);
        checkUseQuickbar(config);

        var fontList = getFontList(config);
        var defaultFont = _tool.grep(fontList, function(font) {
            return font.text === config.covi_default_font;
        });
        var contentBodyStyle = 'body { font-family:' + (defaultFont.length > 0 ? defaultFont[0].value : 'arial,helvetica,sans-serif') +
            '; font-size:' + config.covi_default_font_size + '}' +
            ' p { line-height:' + config.covi_default_line_height + ' }';

        var removeInvalidAttrFromCloneEmptyTag = function(editor, e) {
            if (e.target.querySelector) {
                var emptyTag = e.target.querySelector('br[data-mce-bogus="1"]');

                if (emptyTag) {
                    var parents = editor.dom.getParents(emptyTag.parentElement, null, e.target.parentElement);
                    var parentsInfo = [];
                    var parser = _parser({validate: false}, editor.schema);

                    parentsInfo = _tool.map(parents, function(parent) {
                        return {
                            name: parent.nodeName.toLowerCase(),
                            valid: false,
                            node: parent
                        }
                    });

                    _tool.each(parentsInfo, function(parent) {
                        parser.addNodeFilter(parent.name, function (nodes) {
                            parent.valid = true;
                        });
                    });

                    parser.parse(e.target.outerHTML);

                    _tool.each(parentsInfo, function(parent) {
                        if (!parent.valid) {
                            editor.dom.removeAllAttribs(parent.node);
                        }
                    });
                }
            }
        }
        var removeBrowseButtonInLinkDlg = function() {
            var dialogEl = document.body.querySelector('div[role="dialog"]');

            if (dialogEl) {
                var dlgTitle = document.body.querySelector('.tox-dialog__title');

                if (dlgTitle && dlgTitle.textContent === tinymce.util.I18n.translate('Insert/Edit Link')) {
                    var browseBtnEl = document.body.querySelector('.tox-browse-url');

                    if (browseBtnEl) {
                        browseBtnEl.style.display = 'none'
                    }
                }
            }
        }
        var replaceLineStyleItems = function() {
            var dialogEl = document.body.querySelector('div[role="dialog"]');
            var menuEl = document.body.querySelector('div[role="menu"]');

            if (!dialogEl && !menuEl) {
                return;
            }

			var dlgTitle = document.body.querySelector('.tox-dialog__title');
            var listBoxEl = document.body.querySelector('div[role="listbox"]');
            var selectedLabelEl = document.body.querySelector('.tox-listbox__select-label');
            var getLineStyleIcon = function(elem) {
                var result = null;

                if (elem && elem.textContent.length > 0) {
                    var iconName = _lineStyleNameMap[elem.textContent.toLowerCase()];

                    if (dlgTitle !== null && dlgTitle.textContent === tinymce.util.I18n.translate('Insert/Edit Image')) {
                        iconName += '-small';
                    }

                    result = tinymce.IconManager.get("coviicons").icons[iconName];
                }

                return result;
            }
            var setSelectedItem = function() {
                if (selectedLabelEl !== null && selectedLabelEl.textContent.length > 0) {
                    var selectedIcon = getLineStyleIcon(selectedLabelEl);

                    if (selectedIcon) {
                        selectedLabelEl.innerHTML = selectedIcon;
                    }
                }
            }
            var removeHiddenItem = function() {
                var menuItems = document.body.querySelectorAll(".tox-collection__item");

                if (menuItems.length > 0) {
                    var hiddenItemEls = _tool.grep(menuItems, function(item) {
                        return tinymce.util.I18n.translate('Hidden') === item.getAttribute('title');
                    });

                    _tool.each(hiddenItemEls, function(item) {
                        item.parentElement.removeChild(item);
                    });
                }
            }
            var setLineStyleItems = function() {
                var listItemLabelEls = _tool.grep(document.body.querySelectorAll('.tox-collection__item-label'), function(item) {
                    return item.textContent && item.textContent.length > 0 && (tinymce.util.I18n.translate('None') !== item.textContent);
                });

                _tool.each(listItemLabelEls, function(item) {
                    if (tinymce.util.I18n.translate('None') !== item.textContent) {
                        var itemIcon = getLineStyleIcon(item);

                        if (itemIcon) {
                            item.innerHTML = itemIcon;
                        }
                    }
                });
            }

            
            setSelectedItem();

            if (listBoxEl) {
                removeHiddenItem();
                setLineStyleItems();
            }
        }
        
        var fixIEOverwrapDlg = function() {
            var containerEl = document.body.querySelector('.tox-tinymce-aux.tox-platform-ie');

            if (containerEl) {
                var dlgEl = containerEl.querySelector('div[role="dialog"]');

                containerEl.style.position = dlgEl ? "-ms-device-fixed" : "relative";
            }
        }
        var client_upload_handler = function(blobInfo, success, failure, progress) {
            var xhr, formData;

            xhr = new XMLHttpRequest();
            xhr.withCredentials = false;
            xhr.open('POST', config.images_upload_url);

            xhr.upload.onprogress = function (e) {
                progress(e.loaded / e.total * 100);
            };

            xhr.onload = function() {
                var json;

                if (xhr.status === 403) {
                    failure(tinymce.util.I18n.translate('System error.'), { remove: true });
                    return;
                }

                if (xhr.status < 200 || xhr.status >= 300) {
                    failure(tinymce.util.I18n.translate('System error.'), { remove: true });
                    return;
                }

                json = JSON.parse(xhr.responseText);

                if (!json || typeof json.location != 'string') {
                    failure(tinymce.util.I18n.translate('Not allowed file type.'), { remove: true });
                    return;
                }

                success(json.location);
            };

            xhr.onerror = function () {
                failure(tinymce.util.I18n.translate('System error.'), { remove: true });
            };

            formData = new FormData();
            formData.append('file', blobInfo.blob(), blobInfo.filename());

            xhr.send(formData);
        }

        var checkQuickLinkPrefix = function (editor) {
            var quickLinkEl = document.body.querySelector('input[aria-label="Link"]');
            if (quickLinkEl && quickLinkEl.value.length === 0) {
                var prefix = editor.getParam('link_default_protocol', 'http', 'string') + '://';
                quickLinkEl.value = prefix;
            }
        }

        var procSpan = function(editor, e) {
            if (e.target && e.target.tagName && e.target.tagName.toLowerCase() === 'span' && e.target.parentElement && e.target.parentElement.tagName.toLowerCase() === 'p') {
                if (e.target.parentElement.style.fontSize === '') {
                    editor.dom.setStyle(e.target.parentElement, 'fontSize', e.target.style.fontSize);
                }
            } else if (e.target && e.target.querySelectorAll) {
                var spanList = e.target.querySelectorAll('p>span');

                _tool.each(spanList, function(span) {
                    var parentEl = span.parentElement;

                    if (parentEl.style.fontSize === '') {
                        editor.dom.setStyle(parentEl, 'fontSize', span.style.fontSize);
                    }
                });
            }
        }

        var docFilter = function(html) {
            var validElements = 'sub,sup,i,b/strong,u,p[align|style],ul,ol,li,a[name|href|rel|rev],img[src|alt|name|longdesc|height|width|align|border|hspace|vspace|style]'+
                ',table[summary|width|height|border|cellspacing|cellpadding|align|style],caption[align],colgroup[span|width|style],col[span|width|style],thead,tfoot,tbody,tr'+
                ',th[abbr|axis|headers|scope|rowspan|colspan|nowrap|width|height|style],td[abbr|axis|headers|scope|rowspan|colspan|nowrap|width|height|style]';
            var validTags = 'sub,sup,i,b,u,p,ui,ol.li,a,img,table,caption,colgroup,col,thead,tfoot,tbody,tr,th,td';
            var invalidTags = ',textarea,video,audio';
            var invalidAttributes = 'data-mce-src,data-mce-href,data-mce-style,data-mce-selected,data-mce-expando,data-mce-type,data-mce-resize,data-mce-placeholder'+
                ',data-mce-p-src,data-mce-p-type,data-mce-object';
            var schema = tinymce.util.Tools.resolve('tinymce.html.Schema')({
                valid_elements: validElements + invalidTags
            });
            var parser = tinymce.util.Tools.resolve('tinymce.html.DomParser')({validate: true}, schema);
            var serializer = tinymce.util.Tools.resolve('tinymce.html.Serializer')({validate: true}, tinymce.util.Tools.resolve('tinymce.html.Schema')({}));

            var stylesParser = new tinymce.html.Styles();
            var px2mm = function(b, numberAllowed) {
                var a = b + '';
                if ( numberAllowed || a.indexOf('px') > 0 ) {
                    a = parseInt(a);
                    if (isNaN(a)) {
                        return b;
                    }
                    a = (.264583 * a) + 'mm';
                }

                return a;
            }
            var getStyles = function(styles) {
                if (styles['text-indent']) {
                    styles['text-indent'] = px2mm(styles['text-indent'], false);
                }
                if (styles['line-height']) {
                    styles['line-height'] = px2mm(styles['line-height'], false);
                }
                if (styles['margin-left']) {
                    styles['margin-left'] = px2mm(styles['margin-left'], false);
                }
                if (styles['margin-right']) {
                    styles['margin-right'] = px2mm(styles['margin-right'], false);
                }
                if (styles['width']) {
                    styles['width'] = px2mm(styles['width'], true);
                }
                if (styles['height']) {
                    styles['height'] = px2mm(styles['height'], true);
                }

                return styles;
            }
            var setAttribute = function(node, name) {
                var styles = getStyles(stylesParser.parse(node.attr('style')));

                switch(name) {
                    case 'sub': break;
                    case 'sup': break;
                    case 'i': break;
                    case 'b': break;
                    case 'u': break;
                    case 'ul': break;
                    case 'ol': break;
                    case 'li': break;
                    case 'a': break;
                    case 'caption': break;
                    case 'thead': break;
                    case 'tfoot': break;
                    case 'tbody': break;
                    case 'tr': break;
                    case 'p':
                        if (Object.keys(styles).length > 0) {
                            node.attr('style', stylesParser.serialize(styles));
                        }
                        break;
                    case 'img':
                    case 'th':
                    case 'td':
                        if (node.attr('width')) {
                            node.attr('width', px2mm(node.attr('width'), true));
                        }
                        if (node.attr('height')) {
                            node.attr('height', px2mm(node.attr('height'), true));
                        }

                        if (Object.keys(styles).length > 0) {
                            if (styles['width']) {
                                node.attr('width', styles['width']);
                            }
                            if (styles['height']) {
                                node.attr('height', styles['height']);
                            }
                            node.attr('style', null);
                        }
                        break;
                    case 'table':
                        if (node.attr('width')) {
                            node.attr('width', px2mm(node.attr('width'), true));
                        }
                        if (node.attr('height')) {
                            node.attr('height', px2mm(node.attr('height'), true));
                        }

                        if (Object.keys(styles).length > 0) {
                            if (styles['width']) {
                                node.attr('width', styles['width']);
                            }
                            if (styles['height']) {
                                node.attr('height', styles['height']);
                            }
                            if (styles['border']) {
                                node.attr('border', styles['border']);
                            }
                            node.attr('style', null);
                        }
                        break;
                    case 'colgroup':
                    case 'col':
                        if (node.attr('width')) {
                            node.attr('width', px2mm(node.attr('width'), true))
                        }

                        if (Object.keys(styles).length > 0) {
                            if (styles['width']) {
                                node.attr('width', styles['width']);
                            }
                            node.attr('style', null);
                        }
                        break;
                    default:
                        node.attr('style', null);
                        break;
                }
            }

            parser.addNodeFilter(validTags + invalidTags, function(nodes, name) {
                var i = nodes.length;
                while (i--) {
                    if (name === 'textarea') {
                        nodes[i].unwrap();
                    } else if (name === 'video' || name === 'audio') {
                        nodes[i].remove();
                    } else {
                        setAttribute(nodes[i], name);
                    }
                }
            })

            parser.addAttributeFilter(invalidAttributes, function(nodes, name) {
                var i = nodes.length;
                while (i--) {
                    nodes[i].attr(name, null);
                }
            })

            var rootNode = parser.parse(html);
            var result = serializer.serialize(rootNode);

            return result;
        }

        tinymce.init({
            selector: '#covieditorContainer',
            plugins: config.plugins,
            external_plugins: config.external_plugins,
            menubar: config.menubar,
            menu: config.menu,
            toolbar: config.toolbar,
            table_toolbar: config.table_toolbar,
            toolbar_sticky: config.toolbar_sticky,
            image_advtab: true,
            contextmenu: config.contextmenu,
            importcss_append: true,
            mobile: {
                menubar: true
            },
            setup: function(editor) {
                if (_env.browser.isIE()) {
                    var focusToImageToolImage = function () {
                        var imgEl = editor.dom.$.find('.tox-image-tools__image img')
                        if (imgEl.length > 0 && editor.dom.getAttrib(imgEl, 'style')) {

                            editor.getBody().focus();
                            imgEl[0].focus();
                            _delay.clearInterval(_timerId);
                            _timerId = null;
                        }
                    }
                    var imageToolbar = editor.getParam('imagetools_toolbar');

                    editor.settings.imagetools_toolbar = imageToolbar.replace('rotateleft', '').replace('rotateright', '').replace('flipv', '').replace('fliph', '').trim();

                    editor.on('ExecCommand', function (e) {
                        if (e.command === 'mceEditImage') {
                            if (_timerId !== null) {
                                _delay.clearInterval(_timerId);
                            }

                            _timerId = _delay.setEditorInterval(editor, function () {
                                focusToImageToolImage();
                            }, 100);
                        }
                    });
                } else {
                    editor.on('change', function(e) {
                        editor.uploadImages(function() {
                        });
						// procSpan(editor, e);
                    });
                }

                if (editor.settings.invalid_elements.toLowerCase().indexOf('iframe') !== -1) {
                    editor.settings.menu.insert.items = config.menu.insert.items.replace('media', '');
                    editor.settings.toolbar = config.toolbar.replace('media', '');
                }

                editor.on('GetContent', function(e) {
                    handleGetContent(editor, e);
                });


                editor.on('beforeGetContent', function(e) {
                    handleBeforeGetContent(editor, e);
                });

                editor.on('beforeSetContent', function(e) {
                    handleBeforeSetContent(editor, e);
                });

                editor.on('BeforeExecCommand', function(e) {
                    if (e.command === 'outdent') {
                        preventDeleteBulletByOutdent(editor, e);
                    }
                });

                editor.on('SetContent', function(e) {
					
					
                    postProcessInvalidTag(editor, e);
                    if (e.covi_out !== undefined) {
                        postProcessCoviLayoutDisabled(editor);
                    }
                });
            },
            init_instance_callback: function(editor) {
                editor.resetContent('');
                window.COVIEDITOR = window.tinymce;
				window.COVIEDITOR.docFilter = docFilter;
				
				if (config.fixed_ruler) {
                    editor.execCommand('coviFixedRuler');
                }
                
                covi_editor_loaded_event(editor);

                if (editor.getBody().addEventListener) {
                    editor.getBody().addEventListener('DOMNodeInserted', function(e) {
                        removeInvalidAttrFromCloneEmptyTag(editor, e);
						// procSpan(editor, e);
                    }, false);
                }

                if (document.body.addEventListener) {
                    document.body.addEventListener('DOMNodeInserted', function(e) {
                        if (_env.browser.isIE()) {
                            fixIEOverwrapDlg();
                        }
                        removeBrowseButtonInLinkDlg();
                        replaceLineStyleItems();
						checkQuickLinkPrefix(editor);
                    });
                }
            },
            file_picker_callback: filePickerFn,
            file_picker_types: 'file, image',
            link_list: config.link_list,
            templates: config.templates,
            template_cdate_format: config.template_cdate_format,
            template_mdate_format: config.template_mdate_format,
            template_replace_values: config.template_replace_values,
            template_preview_replace_values: config.template_replace_values,
            height: frameHeight,
            image_caption: true,
            quickbars_selection_toolbar: config.quickbars_selection_toolbar,
            quickbars_insert_toolbar: config.quickbars_insert_toolbar,
            quickbars_image_toolbar: config.quickbars_image_toolbar,
            toolbar_mode: config.toolbar_mode,
            content_css: config.content_css,
            content_style: config.content_style + ' ' + contentBodyStyle,
            content_style_ext: config.content_style,
            images_upload_url: config.images_upload_url,
            relative_urls : false,
            
			// 22.05.30 수정, image url 중 hostname 제외(covision 자체 수정 내용).
			remove_script_host : true,
			convert_urls : false,
			// 22.05.30 이전 원본.
			//remove_script_host : false,
            //convert_urls : true,
            
			language: COVIEDITOR_CONFIG.Lang,
            icons_url: config.icons_url,
            icons: config.icons,
            invalid_elements: COVIEDITOR_CONFIG.zXssUse === "1" ? COVIEDITOR_CONFIG.zXssRemoveTags : '',
            extended_valid_elements: COVIEDITOR_CONFIG.zXssAllowedEvents,
            image_title: config.image_title,
            draggable_modal: config.draggable_modal,
            accessibility: config.accessibility,
            contextmenu_never_use_native: true,
            table_column_resizing: 'resizetable',
            link_context_toolbar: config.link_context_toolbar,
            ruler_px: config.ruler_px,
            ruler_padding: config.ruler_padding,
            ruler_format: config.ruler_format,
            autosave_interval_minute: config.autosave_interval_minute,
            autosave_item_max: config.autosave_item_max,
            noneditable_editable_class: config.noneditable_editable_class,
            noneditable_noneditable_class: config.noneditable_noneditable_class,
            font_formats: config.font_formats,
            fontsize_formats: config.fontsize_formats,
            lineheight_formats: config.lineheight_formats,
            covi_default_font: config.covi_default_font,
            covi_default_font_size: config.covi_default_font_size,
            covi_default_line_height: config.covi_default_line_height,
            table_sizing_mode: 'fixed',
            fixed_ruler: config.fixed_ruler,
            table_default_styles: config.table_default_styles,
            fullscreen_native: config.fullscreen_native,
            charmap_append: config.charmap_append,
            skin: 'coviskin',
            nonbreaking_force_tab: true,
            nonbreaking_wrap: config.nonbreaking_wrap,
            default_link_target: config.default_link_target,
            indent_use_margin: true,
            indentation: config.indentation,
            table_style_by_css: true,
            imagetools_toolbar: config.imagetools_toolbar,
            block_formats: config.block_formats,
            textpattern_patterns: config.textpattern_patterns,
            output_wrapper: config.output_wrapper,
            resize: config.resize,
            images_upload_handler: client_upload_handler,
            emoticons_database: config.emoticons_database,
            emoticons_images_url: config.emoticons_images_url,
			resize_img_proportional: config.resize_img_proportional,
			formats: config.formats,
            letterspacing_formats: config.letterspacing_formats,
            covi_templates: config.covi_templates,
            covi_personal_data_protections: config.covi_personal_data_protections,
            covi_table_context_menu: config.covi_table_context_menu,
        });
    }

    // temporary for local test
    if (window.location.protocol === 'file:') {
        var defaultConfig = {
            plugins: "table print importcss searchreplace autolink visualblocks fullscreen image link media template codesample charmap hr pagebreak anchor toc insertdatetime advlist lists wordcount imagetools textpattern noneditable help charmap quickbars emoticons nonbreaking",
            external_plugins: {
                covipaste: "../../../coviplugins/covipaste/plugin.js",
                coviinsert: "../../../coviplugins/coviinsert/plugin.js",
                covilink: "../../../coviplugins/covilink/plugin.js",
                coviformat: "../../../coviplugins/coviformat/plugin.js",
                covitable: "../../../coviplugins/covitable/plugin.js",
                coviaccessibility: "../../../coviplugins/coviaccessibility/plugin.js",
                coviview: "../../../coviplugins/coviview/plugin.js",
                covitabmenu: "../../../coviplugins/covitabmenu/plugin.js",
                coviautosave: "../../../coviplugins/coviautosave/plugin.js",
                covisetting: "../../../coviplugins/covisetting/plugin.js",
                covifile: "../../../coviplugins/covifile/plugin.js",
                coviletterspacing: "../../../coviplugins/coviletterspacing/plugin.js",
                covicasechange: "../../../coviplugins/covicasechange/plugin.js",
                coviruler: "../../../coviplugins/coviruler/plugin.js",
                covianchor: "../../../coviplugins/covianchor/plugin.js",
                covipersonaldataprotection: "../../../coviplugins/covipersonaldataprotection/plugin.js",
            },
            menubar: "file edit view insert format tools table help",
            menu: {
                file: { title: 'File', items: 'newdocument covifileopen | covifiletemplate covifilelayout | covifilesave coviautosave | print ' },
                edit: { title: 'Edit', items: 'undo redo | cut copy paste | covicopyformat covipasteformat | selectall | searchreplace' },
				view: { title: 'View', items: 'visualblocks | covicode covipreview fullscreen | coviruler' },
                insert: { title: 'Insert', items: 'coviinsertbgimage image link media coviinsertiframe codesample | charmap emoticons hr | covipagebreak covianchor toc | insertdatetime' },
                format: { title: 'Format', items: 'lineheight coviletterspacing | bold italic underline strikethrough superscript subscript | removeformat covicopyformat covipasteformat | covinumberlist covibulletlist | coviindent covioutdent | align' },
                tools: { title: 'Tools', items: 'wordcount covicasechange covipersonaldataprotection covisetting' },
                table: { title: 'Table', items: 'coviinserttabledialog covitableselectall | covitablecell covitablerow covitablecolumn covitalbleresizingcell | covitableindent covitableoutdent | covitabletotext | covitableinsertpara | tableprops deletetable | covitableverticalalign | covitablecalc' },
                help: { title: 'Help', items: 'covifilehelp' }
            },
            toolbar: "fontselect fontsizeselect formatselect lineheight coviletterspacing | covifontup covifontdown | bold italic underline strikethrough | forecolor backcolor | removeformat covicopyformat covipasteformat | covinumberlist covibulletlist | alignleft aligncenter alignright alignjustify | indent outdent | undo redo | covipagebreak coviruler | inserttable | charmap emoticons | fullscreen print | image media covifiletemplate link covianchor codesample | coviAccessibilityChecker",
            table_toolbar: 'tableprops tabledelete | tableinsertrowbefore tableinsertrowafter tabledeleterow | tableinsertcolbefore tableinsertcolafter tabledeletecol | tablemergecells tablesplitcells covitablesamewidth covitablesameheight coviTableSameWidthHeight | covitableindent covitableoutdent | covitablealignleft covitablealigncenter covitablealignright covitablealignjustify',
            table_grid: true,
            toolbar_sticky: true,
            contextmenu: "image imagetools covitable covilink",
            image_title: true,
            draggable_modal: true,
            accessibility: 0,
            link_list: [
                {title: 'Tiny Home Page', value: 'https://www.tiny.cloud'},
                {title: 'Tiny Blog', value: 'https://www.tiny.cloud/blog'},
                {title: 'TinyMCE Support resources',
                    menu: [
                        {title: 'TinyMCE Documentation', value: 'https://www.tiny.cloud/docs/'},
                        {title: 'TinyMCE on Stack Overflow', value: 'https://stackoverflow.com/questions/tagged/tinymce'},
                        {title: 'TinyMCE GitHub', value: 'https://github.com/tinymce/'}
                    ]
                }
            ],
            link_context_toolbar: false,
            ruler_px:  3.78,
            ruler_padding: 13,
            ruler_format: { width: 210, height: 297 },
            autosave_interval_minute: 1,
            autosave_item_max: 10,
            noneditable_editable_class: 'coviEditable',
            noneditable_noneditable_class: 'coviNoneEditable',
            font_formats: 'Andale Mono=andale mono,times; Arial=arial,helvetica,sans-serif; Arial Black=arial black,avant garde; Book Antiqua=book antiqua,palatino; Comic Sans MS=comic sans ms,sans-serif; Courier New=courier new,courier; Georgia=georgia,palatino; Helvetica=helvetica; Impact=impact,chicago; Symbol=symbol; Tahoma=tahoma,arial,helvetica,sans-serif; Terminal=terminal,monaco; Times New Roman=times new roman,times; Trebuchet MS=trebuchet ms,geneva; Verdana=verdana,geneva; Webdings=webdings; Wingdings=wingdings,zapf dingbats',
            fontsize_formats: '8pt 10pt 12pt 14pt 16pt 18pt 24pt 36pt 48pt',
            lineheight_formats: '1 1.1 1.2 1.3 1.4 1.5 2',
            covi_default_font: 'Arial',
            covi_default_font_size: '14pt',
            covi_default_line_height: '1.2',
            content_style: 'p { margin-top: 0px; margin-bottom: 0px }',
            templates: [
                { title: 'New Table', description: 'creates a new table', content: '<div class="mceTmpl"><table width="98%%"  border="0" cellspacing="0" cellpadding="0"><tr><th scope="col"> </th><th scope="col"> </th></tr><tr><td> </td><td> </td></tr></table></div>' },
                { title: 'Starting my story', description: 'A cure for writers block', content: 'Once upon a time...' },
                { title: 'New list with dates', description: 'New List with dates', content: '<div class="mceTmpl"><span class="cdate">cdate</span><br /><span class="mdate">mdate</span><h2>My List</h2><ul><li></li><li></li></ul></div>' },
                { title: "Meeting", description: "Meeting", url: "template/meeting.html" }
            ],
            template_cdate_format: '[Date Created (CDATE): %m/%d/%Y : %H:%M:%S]',
            template_mdate_format: '[Date Modified (MDATE): %m/%d/%Y : %H:%M:%S]',
            template_replace_values: {
                username: "Jack Black",
                staffid: "991234"
            },
            template_preview_replace_values: {
                username: "Jack Black",
                staffid: "991234"
            },
            images_upload_url: 'upload_handler.jsp',
            toolbar_mode: 'sliding',
            content_css: 'covicss/covicontent.css',
            icons_url: 'coviicons/icons.js',
            icons: 'coviicons',
            quickbars_selection_toolbar: 'bold italic | quicklink h2 h3 quickimage quicktable',
            quickbars_insert_toolbar: 'quickimage quicktable | hr covipagebreak',
            quickbars_image_toolbar: 'alignleft aligncenter alignright',
            quickbars_selection_toolbar_enable: true,
            quickbars_insert_toolbar_enable: false,
            fixed_ruler: false,
            table_default_styles: {
                'border-collapse': 'collapse', 'width': '70%'
            },
            fullscreen_native: true,
            charmap_append: [
                [0x2600, 'sun'],
                [0x2601, 'cloud']
            ],
            default_link_target: '_blank',
            indentation: '30px',
            imagetools_toolbar: 'editimage imageoptions',
            nonbreaking_wrap: false,
            used_function: "board",
            block_formats: 'Paragraph=p;Heading 1=h1;Heading 2=h2;Heading 3=h3;Heading 4=h4;Heading 5=h5;Heading 6=h6;',
            textpattern_patterns: [
                // {start: '#', format: 'h1'},
                // {start: '##', format: 'h2'},
                // {start: '###', format: 'h3'},
                // {start: '####', format: 'h4'},
                // {start: '#####', format: 'h5'},
                // {start: '######', format: 'h6'},
                // {start: '* ', cmd: 'InsertUnorderedList'},
                // {start: '- ', cmd: 'InsertUnorderedList'},
                // {start: '1. ', cmd: 'InsertOrderedList', value: { 'list-style-type': 'decimal' }},
                // {start: '1) ', cmd: 'InsertOrderedList', value: { 'list-style-type': 'decimal' }},
                // {start: 'a. ', cmd: 'InsertOrderedList', value: { 'list-style-type': 'lower-alpha' }},
                // {start: 'a) ', cmd: 'InsertOrderedList', value: { 'list-style-type': 'lower-alpha' }},
                // {start: 'i. ', cmd: 'InsertOrderedList', value: { 'list-style-type': 'lower-roman' }},
                // {start: 'i) ', cmd: 'InsertOrderedList', value: { 'list-style-type': 'lower-roman' }}
            ],
            resize: false,
            emoticons_database: 'emojiimages',
            emoticons_images_url: 'emoji/72x72/',
			resize_img_proportional: false,
			formats: {
                letterSpacing: {
                    selector: 'h1,h2,h3,h4,h5,h6,p,li,td,th,div',
                    defaultBlock: 'p',
                    styles: { letterSpacing: '%value' }
                }
            },
            letterspacing_formats: '-5px -4px -3px -2px -1px 0px 1px 2px 3px 4px 5px',
            covi_templates: [
                {
                    folder_name: '부서양식',
                    items: [
                        { id: 0, name: "품의서", url: "template/department/품의서.html" },
                        { id: 1, name: "품의서", url: "template/department/품의서.html" }
                    ]
                },
                {
                    folder_name: '총무양식',
                    items: [
                        { id: 0, name: '개인지출결의서', url: "template/general/개인지출결의서.html" },
                        { id: 1, name: '휴가신청서', url: "template/general/휴가신청서.html" }
                    ]
                },
            ],
            covi_personal_data_protections: [
                {
                    regExp: '(([0-9]{2})(0[1-9]|1[0-2])(0[1-9]|[1,2][0-9]|3[0,1]))([- .]?)([1-4][0-9]{6})',
                    messages: '주민등록번호'
                },
                {
                    regExp: '\\+?(((0|82)((2|31|32|33|41|42|43|44|51|52|53|54|55|61|62|63|64|11|12|13|14|15|16|17|18|19|70|80)[-) .]?)([0-9]{3,4}))|((0|82)10[-) .]?[0-9]{4}))[- .]?([0-9]{4})',
                    messages: '전화번호'
                },
                {
                    regExp: '([a-z0-9_\\-\\.]+)@([a-z0-9_\\-\\.]+)\\.([a-z]{2,5})',
                    messages: '이메일'
                },
            ],
            covi_table_context_menu: 'covitableselectall | covitablecell covitablerow covitablecolumn covitalbleresizingcell | covitableindent covitableoutdent | covitabletotext | removeformat covicopyformat covipasteformat | covitableinsertpara | tableprops deletetable | covitableverticalalign | covitablecalc'
        }
        initEditor(defaultConfig);
    } else {
        tinymce.util.XHR.send({
            url: COVIEDITOR_CONFIG.initJson ? COVIEDITOR_CONFIG.initJson : "covi_editor.json",
            success: function(data) {
                var config = JSON.parse(data);

                if (config.license_key) {
                    var decrypted = CryptoJS.AES.decrypt(config.license_key, CryptoJS.MD5("eThWmYq3t6w9z$C&F)J@NcRfUjXn2r4u").toString());
                    var licenseInfo = JSON.parse(decrypted.toString(CryptoJS.enc.Utf8));

                    // TODO: check domain
                    // if (licenseInfo.domain != window.location.hostname) {
                    //    alert("Not allowed domain!!")
                    //}
                    //coviCmn.traceLog(licenseInfo);
                }
                initEditor(config);
            }
        });
    }
}
