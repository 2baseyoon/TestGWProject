(function () {
    'use strict';

    tinymce.PluginManager.add("coviautosave", function(editor, url) {
        var AUTOSAVE_LIST_KEY = 'covi_autosave_list';
        var AUTOSAVE_CONTENT = 'covi_autosave_content';
        var AUTOSAVE_INTERVAL_KEY = 'covi_autosave_interval';
        var AUTOSAVE_ITEM = 'covi_autosave_item';
        var _delay = tinymce.util.Tools.resolve('tinymce.util.Delay');
        var _env = tinymce.util.Tools.resolve('tinymce.Env');
        var _localStorage = tinymce.util.Tools.resolve('tinymce.util.LocalStorage');
        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
        var _timerId = null;
        var _timerInterval = null;
        var _maxItem = editor.getParam('autosave_item_max', 10);
        var _dialog = null;
        var _autoSaveList = [];
        var _currentSelected = null;

        function getToday(){
            var date = new Date();
            var year = date.getFullYear();
            var month = ("0" + (1 + date.getMonth())).slice(-2);
            var day = ("0" + date.getDate()).slice(-2);
            var time = ("0" + date.getHours()).slice(-2);
            var min = ("0" + date.getMinutes()).slice(-2);
            var sec = ("0" + date.getSeconds()).slice(-2);

            return year + "-" + month + "-" + day + " " + time + ":" + min + ":" + sec;
        }

        function updateTimer(newInterval) {
            _timerInterval = newInterval;
            _delay.clearInterval(_timerId);
            _timerId = _delay.setEditorInterval(editor, function() {
                save();
            }, _timerInterval * 60000);
        }

        function appendItem(itemList, item) {
            itemList.push(item);

            itemList.sort(function(a, b) {
                var keyA = new Date(a.saved_at),
                    keyB = new Date(b.saved_at);

                if (keyA < keyB) return -1;
                if (keyA > keyB) return 1;

                return 0;
            });

            if (itemList.length > _maxItem) {
                itemList = itemList.slice(itemList.length - _maxItem);
            }

            return itemList;
        }

        function getItemList() {
            var itemListStr = _localStorage.getItem(AUTOSAVE_LIST_KEY);
            var itemList = [];

            if (itemListStr !== null) {
                itemList = JSON.parse(itemListStr);
            }

            return itemList;
        }

        function save() {
            if (!editor.dom.isEmpty(editor.getBody())) {
                var itemList = getItemList();
                var item = {
                    saved_at: getToday(),
                    data: editor.getContent({format: 'raw', no_events: true})
                };
                itemList = appendItem(itemList, item);

                _localStorage.setItem(AUTOSAVE_LIST_KEY, JSON.stringify(itemList));
            }

            var intervalStr = _localStorage.getItem(AUTOSAVE_INTERVAL_KEY);

            if (intervalStr === null) {
                clearInterval(_timerId);
                _timerId = null;
            } else {
                var interval = JSON.parse(intervalStr);

                if (interval !== _timerInterval) {
                    updateTimer(interval);
                }
            }
        }

        function makeItemListHTML() {
            var html = "";
            var span = "";
            var spanStyle = 'font-size: 14px; white-space: nowrap; text-overflow: ellipsis; padding-left: 3px;';
            var lastItemIdx = _autoSaveList.length - 1;

            for (var i = lastItemIdx; i >= 0; i--) {
                var id = lastItemIdx - i;
                span = editor.dom.createHTML('span', { style: spanStyle }, _autoSaveList[i].saved_at);
                html += editor.dom.createHTML('li', { class: AUTOSAVE_ITEM, id: id, onclick: "COVI_AUTOSAVE.selectItem('" + id + "')"}, span);
            }

            return html;
        }

        function deleteAutosaveItemFromStorage(key) {
            var itemList = getItemList();

            for (var i = 0; i < itemList.length; i++) {
                if (itemList[i].saved_at === key) {
                    itemList.splice(i, 1);
                    _autoSaveList = itemList;
                    _localStorage.setItem(AUTOSAVE_LIST_KEY, JSON.stringify(itemList));
                    return;
                }
            }
        }

        function deleteSelectedItem() {
            var selectedItem = editor.dom.$.find('.' + AUTOSAVE_ITEM + ".selected");

            if (selectedItem.length > 0) {
                var key = selectedItem[0].innerText;

                deleteAutosaveItemFromStorage(key);
                _dialog.redial(getItemDlgOptions());

                if (_autoSaveList.length > 0) {
                    switchItem(0);
                }
            }
        }

        function deleteItemAll() {
            _localStorage.setItem(AUTOSAVE_LIST_KEY, JSON.stringify([]));
            _autoSaveList = [];
            _dialog.redial(getItemDlgOptions());
        }

        function isEmptyAutosavedList() {
            return _autoSaveList.length == 0;
        }

        function getItemDlgOptions() {

            var itemListHTML = editor.dom.createHTML('ul', {
                id: "covi_autosave_list",
                style: "list-style: none; padding: 0 3px;",
                onmouseover: "this.style.cursor= 'pointer'",
                onmouseout: "this.style.cursor= 'auto'"
            }, makeItemListHTML())

            var contentHTML = editor.dom.createHTML('div', { id: AUTOSAVE_CONTENT, style: 'height: 216px; overflow-x: hidden; overflow-y: hidden; padding: 0 5px;' });

            return {
                title: 'Restore auto save',
                body: {
                    type: 'panel',
                    items: [{
                        name: 'itemlist',
                        type: 'htmlpanel',
                        label: 'Date\/time',
                        html: '<table class="tox-form" cellpadding: 0, cellspacing: 0>' +
                            '<tr>' +
                            '<td><span class="tox-label">' + tinymce.util.I18n.translate("Date\/time") + '</span></td>' +
                            '<td><span class="tox-label">' + tinymce.util.I18n.translate("Content") + '</span></td>' +
                            '</tr>' +
                            '<tr>' +
                            '<td style="width: 150px; height: 200px; border:1px solid #ccc; vertical-align: top;">' + itemListHTML + '</td>' +
                            '<td style="width: 340px; height: 200px; border:1px solid #ccc; vertical-align: top;">' + contentHTML + '</td>' +
                            '</tr></table>'
                    }, {
                        type: 'bar',
                        items: [{
                            name: 'delete',
                            type: 'button',
                            text: 'Delete',
                            disabled: isEmptyAutosavedList()
                        }, {
                            name: 'deleteAll',
                            type: 'button',
                            text: 'Delete all',
                            disabled: isEmptyAutosavedList()
                        }]
                    }]
                },
                onClose: function() {
                    _currentSelected = null;
                },
                onChange: function(api, details) {
                },
                onSubmit: function(api) {
                    if (_currentSelected) {
                        editor.windowManager.confirm("Do you want to apply the selected content?", function(isYes) {
                            if (isYes) {
                                editor.focus();
                                editor.undoManager.transact(function () {
                                    editor.setContent(_currentSelected.data, {format: 'raw'});
                                });
                                editor.selection.setCursorLocation();
                                editor.nodeChanged();
                                api.close();
                            }
                        });
                    }
                },
                onAction: function(api, details) {
                    switch (details.name) {
                        case 'delete':
                            editor.windowManager.confirm("Do you want to delete the selected item?", function(isYes) {
                                if (isYes) {
                                    deleteSelectedItem();
                                }
                            });
                            break;
                        case 'deleteAll':
                            editor.windowManager.confirm("All auto-saved contents are deleted. Would you like to proceed?", function(isYes) {
                                if (isYes) {
                                    deleteItemAll();
                                    api.close();
                                }
                            });
                            break;
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
                    primary: true,
                    disabled: isEmptyAutosavedList()
                }]
            };
        }

        function setContent(savedAt) {
            var contentStyle = editor.getParam('content_style', '', 'string');
            var contentEl = editor.dom.$.find("#" + AUTOSAVE_CONTENT);
            var head = '<base href="' + editor.dom.encode(editor.documentBaseURI.getURI()) + '">';
            var isCtrlKey = _env.mac ? 'e.metaKey' : 'e.ctrlKey && !e.altKey';
            var disableLinkClickScript = '<script>document.addEventListener && document.addEventListener("click", function(e) { var elem = e.target; while(elem) { if (elem.nodeName.toLowerCase() === "a" && !' + isCtrlKey + ') { e.preventDefault(); } elem = elem.parentNode; } }, false);</script>';
            var bodyId = editor.getParam('body_id', 'tinymce', 'string');

            for (var i = 0; i < editor.contentCSS.length; i++) {
                head += '<link type="text/css" rel="stylesheet" href="' + editor.dom.encode(editor.documentBaseURI.toAbsolute(editor.contentCSS[i])) + '">';
            }

            if (contentStyle) {
                head += '<style type="text/css">' + contentStyle + '</style>';
            }

            if (contentEl[0].hasChildNodes()) {
                contentEl[0].innerHTML = "";
            }
            var iframeEl = editor.dom.create('iframe', { style: 'border: none; overflow:auto; width:100%; height:100%;', frameborder: '0' });
            contentEl[0].appendChild(iframeEl);

            var doc = iframeEl.contentWindow.document;

            for (var i = 0; i < _autoSaveList.length; i++) {
                if (_autoSaveList[i].saved_at === savedAt) {
                    doc.open();
                    doc.write('<!DOCTYPE html><html>' + head + '<head></head><body id="' + editor.dom.encode(bodyId) + '" class="mce-content-body" style="margin: 0; width:' + editor.getDoc().body.clientWidth + 'px;">' + _autoSaveList[i].data + disableLinkClickScript + '</body></html>');
                    doc.close();
                    _currentSelected = _autoSaveList[i];
                }
            }
        }

        function switchItem(id) {
            var items = editor.dom.$.find('.' + AUTOSAVE_ITEM);

            for (var i = 0; i < items.length; i++) {
                items[i].style.backgroundColor = '';
                items[i].classList.remove('selected');
            }

            var item = editor.dom.$.find('#' + id);

            if (item.length > 0) {
                item[0].style.backgroundColor = '#dee0e2';
                item[0].classList.add('selected');
                setContent(item[0].innerText);
            }
        }

        function startAutosave(interval, isInit) {
            _timerInterval = interval;

            if (!window.COVI_AUTOSAVE) {
                window.COVI_AUTOSAVE = {
                    selectItem: function (id) {
                        switchItem(id);
                    }
                }
            }

            function setAutosaveInterval() {
                if (_timerId !== null) {
                    clearInterval(_timerId);
                }

                if (_timerInterval !== null && _timerInterval > 0) {
                    _timerId = _delay.setEditorInterval(editor, function () {
                        save();
                    }, _timerInterval * 60000);
                }
            }

            if (isInit) {
                editor.on('init', function () {
                    setAutosaveInterval();
                });
            } else {
                setAutosaveInterval();
            }

            editor.editorManager.on('BeforeUnload', function (e) {
                if (window.COVI_AUTOSAVE) {
                    window.COVI_AUTOSAVE = undefined;
                }

                clearInterval(_timerId);
            });
        }

        function stopAutosave() {
            clearInterval(_timerId);
            _localStorage.removeItem(AUTOSAVE_INTERVAL_KEY);
            _timerId = null;
            _timerInterval = null;
        }

        var intervalStr = _localStorage.getItem(AUTOSAVE_INTERVAL_KEY);

        if (intervalStr !== undefined && intervalStr !== null) {
            var interval = JSON.parse(intervalStr);
            startAutosave(interval, true);
        }

        editor.ui.registry.addMenuItem('coviautosave', {
            text: 'Restore auto save',
            icon: 'restore-draft',
            onAction: function() {
                _autoSaveList = getItemList();
                _dialog = editor.windowManager.open(getItemDlgOptions());

                if (_autoSaveList.length > 0) {
                    switchItem(0);
                }
            },
            onSetup: function(api) {
                api.setDisabled(_timerInterval === null);
            }
        });

        editor.addCommand('coviAutosave', function(ui, info) {
            if (info.enable) {
                _localStorage.setItem(AUTOSAVE_INTERVAL_KEY, JSON.stringify(info.interval));
                startAutosave(info.interval, false);
            } else {
                stopAutosave();
            }
        });
    });
}());