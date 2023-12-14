(function () {
    'use strict';

    tinymce.PluginManager.add("covisetting", function(editor, url) {
        var _dialog = null;
        var _localStorage = tinymce.util.Tools.resolve('tinymce.util.LocalStorage');
        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
        var AUTOSAVE_INTERVAL_SELECTOR = "covi_autosave_interval";
        var AUTOSAVE_INTERVAL_KEY = 'covi_autosave_interval';
        var DEFAULT_STYLE_KEY = 'covi_default_style';
        var SELECTION_QUICK_BAR_KEY = 'covi_select_quickbar_enable';
        var INSERT_QUICK_BAR_KEY = 'covi_insert_quickbar_enable';

        function getFontList() {
            var list = editor.getParam('font_formats').split(';');

            list = _tool.map(list, function(font) {
                var fontArr = font.split('=');

                return {
                    text: fontArr[0].trim(),
                    value: fontArr[1].trim()
                }
            });

            return list;
        }

        function getFontSizeList() {
            var list = editor.getParam('fontsize_formats').split(' ');

            list = _tool.map(list, function(fontSize) {
                return {
                    text: fontSize.trim(),
                    value: fontSize.trim()
                }
            });

            return list;
        }

        function getLineHeightList() {
            var list = editor.getParam('lineheight_formats').split(' ');

            list = _tool.map(list, function(lineHeight) {
                return {
                    text: lineHeight.trim(),
                    value: lineHeight.trim()
                }
            });

            return list;
        }

        function initAutosave(initData) {
            var intervalStr = _localStorage.getItem(AUTOSAVE_INTERVAL_KEY);

            if (intervalStr) {
                var interval = JSON.parse(intervalStr);

                if (interval !== undefined || interval !== null) {
                    initData.autosaveCheck = true;
                    initData.interval = interval;
                }
            }
        }

        function initFontInfo(initData, fontList) {
            var defaultStyleStr = _localStorage.getItem(DEFAULT_STYLE_KEY);
            var defaultStyle = null;
            var font;

            if (defaultStyleStr) {
                defaultStyle = JSON.parse(defaultStyleStr);

                if (defaultStyle !== undefined && defaultStyle !== null) {
                    var foundFont = _tool.grep(fontList, function(font) {
                        return font.text === defaultStyle.font;
                    });
                    initData.font = foundFont.length > 0 ? foundFont[0].value : 'arial,helvetica,sans-serif';
                    initData.fontSize = defaultStyle.font_size;
                    initData.lineHeight = defaultStyle.line_height;
                }
            } else {
                var defaultFont = editor.getParam('covi_default_font', 'Arial');
                font = _tool.grep(fontList, function(font) {
                    return font.text === defaultFont;
                });

                initData.font = font.length > 0 ? font[0].value : 'arial,helvetica,sans-serif';
                initData.fontSize = editor.getParam('covi_default_font_size', '14pt');
                initData.lineHeight = editor.getParam('covi_default_line_height', '1.2');

                _localStorage.setItem(DEFAULT_STYLE_KEY, JSON.stringify({
                    font: font.length > 0 ? font[0].text : 'Arial',
                    font_size: initData.fontSize,
                    line_height: initData.lineHeight
                }));
            }
        }

        function initQuickbar(initData) {
            var selectionQuickbarEnable = JSON.parse(_localStorage.getItem(SELECTION_QUICK_BAR_KEY));
            var insertQuickbarEnable = JSON.parse(_localStorage.getItem(INSERT_QUICK_BAR_KEY));

            if (selectionQuickbarEnable == null) {
                selectionQuickbarEnable = editor.getParam('quickbars_selection_toolbar_enable', false);
                _localStorage.setItem(SELECTION_QUICK_BAR_KEY, JSON.stringify(selectionQuickbarEnable));
            }
            if (insertQuickbarEnable == null) {
                insertQuickbarEnable = editor.getParam('quickbars_insert_toolbar_enable', false);
                _localStorage.setItem(INSERT_QUICK_BAR_KEY, JSON.stringify(insertQuickbarEnable));
            }

            initData.selectionQuickbar = selectionQuickbarEnable;
            initData.insertQuickbar = insertQuickbarEnable;
        }

        function applyAutosave(data) {
            if (data.autosaveCheck) {
                var interval = editor.dom.$.find("#" + AUTOSAVE_INTERVAL_SELECTOR);

                if (interval.length > 0) {
                    editor.execCommand('coviAutosave', false, { enable: true, interval: interval[0].value.length === 0 ? '1' : interval[0].value });
                }
            } else {
                editor.execCommand('coviAutosave', false, { enable: false, interval: null });
            }
        }

        function applyFontInfo(data) {
            var contentBodyStyle = 'body { font-family:' + data.font +
                '; font-size:' + data.fontSize + '}' +
                ' p { line-height:' + data.lineHeight + ' }';
            var contentStyle = editor.getParam('content_style_ext');
            var styleEl = editor.dom.$('style:last-child');
            var fontList = getFontList();
            var font = _tool.grep(fontList, function(font) {
                return font.value === data.font;
            });

            editor.settings.content_style = contentStyle + ' ' + contentBodyStyle;

            if (styleEl.length > 0) {
                styleEl[0].innerHTML = editor.settings.content_style;
            }

            _localStorage.setItem(DEFAULT_STYLE_KEY, JSON.stringify({
                font: font.length > 0 ? font[0].text : 'Arial',
                font_size: data.fontSize,
                line_height: data.lineHeight
            }));
            
            editor.nodeChanged();
        }

        function applyQuickbar(data) {
            _localStorage.setItem(SELECTION_QUICK_BAR_KEY, JSON.stringify(data.selectionQuickbar));
            _localStorage.setItem(INSERT_QUICK_BAR_KEY, JSON.stringify(data.insertQuickbar));
        }

        function getDlgOptions() {
            var initData = {
                autosaveCheck: false,
                interval: '',
                selectionQuickbar: false,
                insertQuickbar: false,
                font: '',
                fontSize: '',
                lineHeight: ''
            };
            var fontList = getFontList();

            var fontSizeList = getFontSizeList();
            var lineHeightList = getLineHeightList();
            initAutosave(initData);
            initFontInfo(initData, fontList);
            initQuickbar(initData);

            var intervalHTML = '<div class="tox-form__group" style="width: 100%; padding-left: 15px;">' +
                '<input id="' + AUTOSAVE_INTERVAL_SELECTOR + '" class="tox-textfield" type="number" min="1" style="width:100px; text-align:right" value="' +
                initData.interval + '"' + (initData.autosaveCheck ? '' : 'disabled= "disabled"')  +'>' +
                '<span style="margin-left: 5px;">' + tinymce.util.I18n.translate('Minute') + '</span></input></div>'

            return {
                title: 'Settings',
                body: {
                    type: 'panel',
                    items: [{
                        type: 'bar',
                        items: [{
                            name: 'autosaveCheck',
                            type: 'checkbox',
                            label: 'Use auto save'
                        }, {
                            name: 'interval',
                            type: 'htmlpanel',
                            html: intervalHTML
                        }]

                    }, {
                        type: 'bar',
                        items: [{
                            name: 'selectionQuickbar',
                            type: 'checkbox',
                            label: 'Use text selection area toolbar'
                        }]
                    }, {
                        type: 'bar',
                        items: [{
                            name: 'insertQuickbar',
                            type: 'checkbox',
                            label: 'Use insert toolbar'
                        }]
                    }, {
                        type: 'htmlpanel',
                        html: '<br/>'
                    }, {
                        name: 'font',
                        type: 'selectbox',
                        label: 'Default font',
                        size: 1,
                        items: fontList
                    }, {
                        name: 'fontSize',
                        type: 'selectbox',
                        label: 'Default font size',
                        size: 1,
                        items: fontSizeList
                    }, {
                        name: 'lineHeight',
                        type: 'selectbox',
                        label: 'Default line height',
                        size: 1,
                        items: lineHeightList
                    }]
                },
                initialData: initData,
                onClose: function() {

                },
                onChange: function(api, details) {
                    var data = api.getData();


                    if (details.name === 'autosaveCheck') {
                        var interval = editor.dom.$.find("#" + AUTOSAVE_INTERVAL_SELECTOR);

                        if (interval.length > 0) {
                            if (data.autosaveCheck) {
                                interval[0].removeAttribute('disabled');
                            } else {
                                interval[0].setAttribute('disabled', 'disabled');
                            }
                        }
                    }

                },
                onSubmit: function(api) {
                    var data = api.getData();

                    applyAutosave(data);
                    applyFontInfo(data);
                    applyQuickbar(data);

                    api.close();
                },
                buttons: [{
                    text: 'Close',
                    type: 'cancel',
                    onclick: 'close'
                }, {
                    type: 'submit',
                    name: 'ok',
                    text: 'Ok',
                    primary: true
                }]
            };
        }

        function upAndDownFontSize(up) {
            var currentFontSize = editor.queryCommandValue('FontSize');
            var defaultFontSize = editor.getParam('covi_default_font_size', '14pt');
            var MAX_FONT_SIZE = 48;
            var MIM_FONT_SIZE = 8;

            if (currentFontSize) {
                if (/[0-9.]+px$/.test(currentFontSize)) {
                    currentFontSize = Math.round(parseInt(currentFontSize, 10) * 72 / 96) + 'pt';
                }
            } else {
                currentFontSize = defaultFontSize;
            }
            currentFontSize = parseInt(currentFontSize, 10);

            if (up) {
                if (++currentFontSize > MAX_FONT_SIZE) {
                    currentFontSize = MAX_FONT_SIZE;
                }
            } else {
                if (--currentFontSize < MIM_FONT_SIZE) {
                    currentFontSize = MIM_FONT_SIZE;
                }
            }
            currentFontSize = currentFontSize + 'pt';
            editor.execCommand('FontSize', false, currentFontSize);
        }

        editor.ui.registry.addMenuItem('covisetting', {
            text: 'Settings...',
            icon: 'preferences',
            onAction: function() {
                _dialog = editor.windowManager.open(getDlgOptions());
                _dialog.focus();
            },
        });
        
        editor.ui.registry.addButton('covifontup', {
            tooltip: 'Increase font size',
            icon: 'increase-font-size',
            onAction: function () {
                return editor.execCommand('coviFontsizeUp');
            }
        });
        editor.ui.registry.addButton('covifontdown', {
            tooltip: 'Reduce font size',
            icon: 'reduce-font-size',
            onAction: function () {
                return editor.execCommand('coviFontsizeDown');
            }
        });
        editor.addCommand('coviFontsizeUp', function () {
            upAndDownFontSize(true);
        });
        editor.addCommand('coviFontsizeDown', function () {
            upAndDownFontSize(false);
        });
        
    });
}());