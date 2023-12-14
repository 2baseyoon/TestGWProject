(function () {
    'use strict';

    tinymce.PluginManager.add("covitabmenu", function(editor, url) {
        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
        var _serializer = tinymce.util.Tools.resolve('tinymce.html.Serializer');
        var _parser = tinymce.util.Tools.resolve('tinymce.html.DomParser')({validate: false}, editor.schema);

        var TAB_MENU = {
            design: {
                title: tinymce.util.I18n.translate("Design"),
                classList: 'covi_tab covi_tab_design',
                selector: '.covi_tab.covi_tab_design'
            },
            html: {
                title: 'HTML',
                classList: 'covi_tab covi_tab_html',
                selector: '.covi_tab.covi_tab_html'
            },
            preview: {
                title: tinymce.util.I18n.translate("Preview"),
                classList: 'covi_tab covi_tab_preview',
                selector: '.covi_tab.covi_tab_preview'
            }
        }
        var TAB_MENU_BUTTON_STYLE = "width: 72px; color: rgba(34,47,62,.7); fontSize: 12px; fontWeight: 800; height: 100%; overflow: hidden; padding: 0 8px; position: relative; text-align: center;";
        var TAB_MENU_SELECTED_COLOR = "#dee0e2";
        var EDIT_AREA_SELECTOR = "tox-edit-area";
        var VIEW_DESIGN_SELECTOR = "covieditorContainer_ifr";
        var VIEW_HTML_SELECTOR = "covieditorContainer_html";
        var VIEW_PREVIEW_SELECTOR = "covieditorContainer_preview";

        function switchTabMenu(selector) {
            var tabs = editor.dom.$.find(".covi_tab");

            _tool.each(tabs, function(tab) {
                tab.style.backgroundColor = "";
            });

            editor.dom.$.find(selector)[0].style.backgroundColor = TAB_MENU_SELECTED_COLOR;
        }

        function setContent(editor, html) {
            editor.focus();
            editor.undoManager.transact(function () {
                editor.setContent(html);
            });
            editor.selection.setCursorLocation();
            editor.nodeChanged();
        }

        function initDesignView() {
            toggleLayoutClass(true);
        }

        function initHTMLView() {
            var content = editor.getContent({source_view: true });
            var htmlView = editor.dom.$.find("#" + VIEW_HTML_SELECTOR);

            htmlView[0].value = content;
        }

        function toggleLayoutClass(isEnable) {
            var sourceSel = isEnable ? 'covi_layout_disabled' : 'covi_layout';
            var targetSel = isEnable ? 'covi_layout' : 'covi_layout_disabled';
            var layoutTable = editor.dom.$('.' + sourceSel);

            if (layoutTable.length > 0) {
                layoutTable[0].className = layoutTable[0].className.replace(sourceSel, targetSel);
            }
        }

        function getPreviewContent() {
            var contentStyle = editor.getParam('content_style', '', 'string');
            var head = '<base href="' + editor.dom.encode(editor.documentBaseURI.getURI()) + '">';
            var bodyId = editor.getParam('body_id', 'tinymce', 'string');

            for (var i = 0; i < editor.contentCSS.length; i++) {
                head += '<link type="text/css" rel="stylesheet" href="' + editor.dom.encode(editor.documentBaseURI.toAbsolute(editor.contentCSS[i])) + '">';
            }

            if (contentStyle) {
                head += '<style type="text/css">' + contentStyle + '</style>';
            }

            toggleLayoutClass(false);

            var bodyData = editor.getContent({preview_view: true});
            var pageBreakSeparatorRegExp = /&lt;[^&]--\s*pagebreak\s*--&gt;/gi;

            bodyData = bodyData.replace(pageBreakSeparatorRegExp, '');

            return '<!DOCTYPE html><html>' + head + '<head></head><body id="' + editor.dom.encode(bodyId) + '_priview' + '" class="mce-content-body" style="' + editor.dom.encode(editor.getBody().style.cssText) + '">' + bodyData + '</body></html>';
        }

        function initPreviewView() {
            var previewIframeEl = editor.dom.$.find("#" + VIEW_PREVIEW_SELECTOR);
            var doc = previewIframeEl[0].contentWindow.document;
            var html = getPreviewContent();

            doc.open();
            doc.write(html);
            doc.close();

            _tool.each(doc.getElementsByTagName('a'), function(link) {
               link.target = "_blank";
            });
        }

        function hidePopups() {
            var topDlgEl = document.getElementsByClassName("tox-pop tox-pop--top");
            var bottomDlgEl = document.getElementsByClassName("tox-pop tox-pop--bottom");
            var leftDlgEl = document.getElementsByClassName("tox-pop tox-pop--left");
            var rightDlgEl = document.getElementsByClassName("tox-pop tox-pop--right");

            if (topDlgEl.length > 0) {
                topDlgEl[0].style.display = 'none';
            }

            if (bottomDlgEl.length > 0) {
                bottomDlgEl[0].style.display = 'none';
            }

            if (leftDlgEl.length > 0) {
                leftDlgEl[0].style.display = 'none';
            }

            if (rightDlgEl.length > 0) {
                rightDlgEl[0].style.display = 'none';
            }
        }

        function switchView(selector) {
            var designView = editor.dom.$.find("#" + VIEW_DESIGN_SELECTOR);
            var htmlView = editor.dom.$.find("#" + VIEW_HTML_SELECTOR);
            var previewView = editor.dom.$.find("#" + VIEW_PREVIEW_SELECTOR);

            if (editor.dom.getStyle(htmlView[0], 'display') !== 'none') {
                setContent(editor, htmlView[0].value);
                htmlView[0].value = '';
            }

            if (editor.dom.getStyle(previewView[0], 'display') !== 'none') {
                previewView[0].contentDocument.body.innerHTML = '';
            }

            editor.dom.setStyle(designView[0], 'display', 'none');
            editor.dom.setStyle(htmlView[0], 'display', 'none');
            editor.dom.setStyle(previewView[0], 'display', 'none');

            switch(selector) {
                case VIEW_DESIGN_SELECTOR:
                    editor.dom.setStyle(designView[0], 'display', 'block');
                    editor.ui.enable();
                    initDesignView();
                    editor.execCommand('coviRulerShow', false, true);
                    break;
                case VIEW_HTML_SELECTOR:
                    editor.dom.setStyle(htmlView[0], 'display', 'block');
                    editor.ui.disable();
                    hidePopups();
                    initHTMLView();
                    editor.execCommand('coviRulerShow', false, false);
                    break;
                case VIEW_PREVIEW_SELECTOR:
                    editor.dom.setStyle(previewView[0], 'display', 'block');
                    editor.ui.disable();
                    hidePopups();
                    initPreviewView();
                    editor.execCommand('coviRulerShow', false, false);
                    break;
                default:
                    editor.dom.setStyle(designView[0], 'display', 'block');
                    editor.ui.enable();
                    break;
            }
        }

        if (!window.COVI_TAB_MENU) {
            window.COVI_TAB_MENU = {
                setDesignView: function() {
                    switchTabMenu(TAB_MENU.design.selector);
                    switchView(VIEW_DESIGN_SELECTOR);
                },
                setHTMLView: function() {
                    switchTabMenu(TAB_MENU.html.selector);
                    switchView(VIEW_HTML_SELECTOR);
                },
                setPreview: function() {
                    switchTabMenu(TAB_MENU.preview.selector);
                    switchView(VIEW_PREVIEW_SELECTOR);
                },
                buttonStyle: TAB_MENU_BUTTON_STYLE
            };
        }

        function createMenuCell(menu, fn) {
            var cell = editor.dom.create('span');
            var btn = editor.dom.create('button', { class: menu.classList, style: COVI_TAB_MENU.buttonStyle,
                onmouseover: "this.style.cursor='pointer'", onmouseout: "this.style.cursor='auto'", onclick: fn}, menu.title);

            cell.appendChild(btn);

            return cell;
        }

        function initTabMenuBar() {
            var exist = editor.dom.$.find(".covi_tab_menu");

            if (exist.length > 0) {
                exist[0].parentNode.removeChild(exist[0]);
            }

            var editorContainerEl = editor.dom.$.find(".tox-editor-container");
            var tabMenuEl = editor.dom.create('div', { class: 'tox-statusbar covi_tab_menu', style: 'height: 20px; padding: 0;'});
            var tableEl = editor.dom.create('table', { style: 'height: 20px;', cellpadding: '0', cellspacing: '0' });
            var trEl = editor.dom.create('tr');
            var tdEl = editor.dom.create('td');
            var spanDesignEl = createMenuCell(TAB_MENU.design, "COVI_TAB_MENU.setDesignView()");
            var spanHtmlEl = createMenuCell(TAB_MENU.html, "COVI_TAB_MENU.setHTMLView()");
            var spanPreviewEl = createMenuCell(TAB_MENU.preview, "COVI_TAB_MENU.setPreview()");

            tdEl.appendChild(spanDesignEl);
            tdEl.appendChild(spanHtmlEl);
            tdEl.appendChild(spanPreviewEl);
            trEl.appendChild(tdEl);
            tableEl.appendChild(trEl);
            tabMenuEl.appendChild(tableEl);

            editor.dom.insertAfter(tabMenuEl, editorContainerEl[0]);
        }

        function initViews() {
            var htmlView = editor.dom.create('textarea', {
                id: VIEW_HTML_SELECTOR,
                style: "display:none; width:100%; height:100%; resize:none; white-space: pre-wrap;"
            });

            var preview = editor.dom.create('iframe', {
                id: VIEW_PREVIEW_SELECTOR,
                frameborder: 0,
                allowtransparency: true,
                style: "display:none; width:100%; height:100%"
            });

            var editArea = editor.dom.$.find("." + EDIT_AREA_SELECTOR);

            if (editArea.length > 0) {
                editArea[0].appendChild(htmlView);
                editArea[0].appendChild(preview);
            }
        }

        editor.on('init', function() {
            initTabMenuBar();
            initViews();
            COVI_TAB_MENU.setDesignView();
        });

        editor.editorManager.on('BeforeUnload', function(e) {
            if (window.COVI_TAB_MENU) {
                window.COVI_TAB_MENU = undefined;
            }
        });

        editor.ui.registry.addMenuItem('preview', {
            icon: 'preview',
            text: 'Preview',
            onAction: function () {
                var content = getPreviewContent(editor);
                var dataApi = editor.windowManager.open({
                    title: 'Preview',
                    size: 'large',
                    body: {
                        type: 'panel',
                        items: [{
                            name: 'preview',
                            type: 'iframe',
                            sandboxed: true
                        }]
                    },
                    buttons: [{
                        type: 'cancel',
                        name: 'close',
                        text: 'Close',
                        primary: true
                    }],
                    initialData: { preview: content },
                    onClose: function() {
                        toggleLayoutClass(true);
                    }
                });
                dataApi.focus('close');
            }
        });

        editor.on('BeforeExecCommand', function(e) {
            if (e.command === 'mcePrint') {
                var selectedList = editor.dom.$("*[data-mce-selected*=1]");
                var resizeHandles = editor.dom.$('*[class=mce-resizehandle]');

                _tool.each(selectedList, function(el) {
                    editor.dom.setAttrib(el, 'data-mce-selected', null);
                });

                _tool.each(resizeHandles, function(el) {
                    editor.dom.setStyle(el, 'display', 'none');
                });

                toggleLayoutClass(false);
            }
        });

        editor.on('ExecCommand', function(e) {
            if (e.command === 'mcePrint') {
                toggleLayoutClass(true);
            }
        });

    });
}());