(function () {
    'use strict';
    
    tinymce.PluginManager.add("covianchor", function (editor, url) {
        var _tool = tinymce.util.Tools.resolve('tinymce.util.Tools');
        var _dialog = null;
        var _anchorList = [];
        var _selectedIndex = -1;
        var _bookmarkName;
        var _btnAddEl;
        var _btnUpdateEl;
        var _btnDeleteEl;
        var namedAnchorSelector = 'a:not([href])';

        function makeItemListHTML(index) {
            var html = "";
            var spanStyle = 'font-size: 14px; white-space: nowrap; text-overflow: ellipsis; padding-left: 5px;';
            var listItems = editor.getBody().querySelectorAll(namedAnchorSelector);

            _anchorList = [];
            _selectedIndex = index;

            _tool.each(listItems, function (item) {
                _anchorList.push(item);
            });

            for (var i = 0; i < _anchorList.length; i++) {
                var span = editor.dom.createHTML('span', { style: spanStyle }, _anchorList[i].id);
                html += editor.dom.createHTML('li', { class: 'anchor_item_list', id: _anchorList[i].id, index: i, onclick: "coviAnchor.selectItem(this)"}, span);
            }

            return html;
        }
        function makeAnchorListContents() {
            var itemListHTML = editor.dom.createHTML('ul', {
                id: "covi_anchor_item_list",
                style: "list-style: none; padding: 2px 3px;",
                onmouseover: "this.style.cursor= 'pointer'",
                onmouseout: "this.style.cursor= 'auto'"
            }, makeItemListHTML(-1));

            var html = '<div style="width: 100%; padding-left: 20px; position: relative;">' +
                '<table style="width: 100%; font-size: 12px; color: #484848; font-weight: bold; margin-top: 20px;">' +
                '<tr>' +
                '<td style="padding-bottom: 5px; vertical-align: bottom;"><label>'+tinymce.util.I18n.translate("Name")+'</label></td>' +
                '<td style="text-align: right;">' +
                '<button type="button" id="add_bookmark" onclick="coviAnchor.add()" style="color: #484848; border: 1px solid #adadad; font-size: 11px; padding: 4px 12px; margin-right: 10px; cursor: pointer;">' + tinymce.util.I18n.translate("Add") + '</button>' +
                '<button type="button" id="update_bookmark" onclick="coviAnchor.update()" style="color: #aaaaaa; border: 1px solid #adadad; padding: 4px 12px; font-size: 11px; margin-right: 10px; cursor: default">' + tinymce.util.I18n.translate("Edit") + '</button>' +
                '<button type="button" id="delete_bookmark" onclick="coviAnchor.delete()" style="color: #aaaaaa; border: 1px solid #adadad; padding: 4px 12px; font-size: 11px; cursor: default;">' + tinymce.util.I18n.translate("Delete") + '</button>' +
                '</td></tr>' +
                '<tr>' +
                '<td colspan="2">' +
                '<input type="text" id="name_bookmark" style="outline: none; width: 100%; height: 24px; border: 1px solid #adadad; text-indent: 3px;">' +
                '</td></tr></table>' +
                '<table style="width: 100%; border: 1px solid #adadad; font-size: 12px; color: #484848; font-weight: bold; margin-top: 20px;">' +
                '<tr>' +
                '<td style="text-align: center; border-bottom: 1px solid #adadad; padding: 7px 0px;"><label>' + tinymce.util.I18n.translate("Bookmark list") + '</label></td>' +
                '</tr>' +
                '<tr>' +
                '<td><div id="covi_anchor_list" style="width: 100%; height: 80px; overflow-y: auto; overflow-x: hidden;">' + itemListHTML + '</div>' +
                '</td></tr></table>' +
                '</div>'

            return html;
        }
        function bindGlobalEl() {
            _bookmarkName = editor.dom.$.find("#name_bookmark")[0];
            _btnAddEl = editor.dom.$.find("#add_bookmark")[0];
            _btnUpdateEl = editor.dom.$.find("#update_bookmark")[0];
            _btnDeleteEl = editor.dom.$.find("#delete_bookmark")[0];
        }
        function setAddButton(enabled) {
            if (enabled) {
                _btnAddEl.disabled = false;
                _btnAddEl.style.color = '#484848';
                _btnAddEl.style.cursor = 'pointer';
            } else {
                _btnAddEl.disabled = true;
                _btnAddEl.style.color = '#aaaaaa';
                _btnAddEl.style.cursor = 'default';
            }
        }
        function setUpdateButton(enabled) {
            if (enabled) {
                _btnUpdateEl.disabled = false;
                _btnUpdateEl.style.color = '#484848';
                _btnUpdateEl.style.cursor = 'pointer';
            } else {
                _btnUpdateEl.disabled = true;
                _btnUpdateEl.style.color = '#aaaaaa';
                _btnUpdateEl.style.cursor = 'default';
            }
        }
        function setDeleteButton(enabled) {
            if (enabled) {
                _btnDeleteEl.disabled = false;
                _btnDeleteEl.style.color = '#484848';
                _btnDeleteEl.style.cursor = 'pointer';
            } else {
                _btnDeleteEl.disabled = true;
                _btnDeleteEl.style.color = '#aaaaaa';
                _btnDeleteEl.style.cursor = 'default';
            }
        }
        function setButtonStatus(statusAddBtn, statusUpdateBtn, statusDeleteBtn) {
            setAddButton(statusAddBtn);
            setUpdateButton(statusUpdateBtn);
            setDeleteButton(statusDeleteBtn);
            if (statusUpdateBtn && statusDeleteBtn) {
                _dialog.enable('go');
            } else {
                _dialog.disable('go');
            }
        }
        function isvalidId(id) {
            return /^[A-Za-z][A-Za-z0-9\-:._]*$/.test(id);
        }
        function isSameId(id) {
            for (var i = 0; i < _anchorList.length; i++) {
                if (_anchorList[i].id === id) {
                    return true;
                }
            }

            return false;
        }

        function getDlgOptions() {
            if (!window.coviAnchor) {
                window.coviAnchor = {
                    add: function () {
                        addAnchor(_bookmarkName.value);
                    },
                    update: function () {
                        if (_selectedIndex > -1) {
                            updateAnchor(_bookmarkName.value, _anchorList[_selectedIndex]);
                            var items = document.querySelectorAll("#covi_anchor_item_list li");
                            items[_selectedIndex].style.backgroundColor = "#EEE";
                        }
                    },
                    delete: function () {
                        if (_selectedIndex > -1) {
                            removeAnchor(_anchorList[_selectedIndex]);
                            refreshAnchorItemList();
                            _bookmarkName.value = '';
                            setButtonStatus(true, false, false);
                        }
                    },
                    selectItem: function (obj) {
                        var items = document.querySelectorAll("#covi_anchor_item_list li");
                        if (_selectedIndex > -1) {
                            items[_selectedIndex].style.backgroundColor = "#FFF";
                        }
                        obj.style.backgroundColor = "#EEE";
                        _selectedIndex = parseInt(obj.getAttribute('index'));
                        _bookmarkName.value = _anchorList[_selectedIndex].id;
                        setButtonStatus(false, true, true);
                    }
                }
            }
            return {
                title: 'Bookmark',
                body: {
                    type: 'panel',
                    items: [{
                        type: 'htmlpanel',
                        html: makeAnchorListContents()
                    }]
                },
                onClose: function() {
                    if (window.coviAnchor) {
                        window.coviAnchor = undefined;
                    }
                },
                onChange: function (api, details) {
                },
                onSubmit: function (api) {
                    goToAnchor();
                    api.close();
                },
                buttons: [{
                    type: 'submit',
                    name: 'go',
                    text: 'Go',
                    disabled: true
                }, {
                    text: 'Close',
                    type: 'cancel',
                    onclick: 'close'
                }]
            }
        }

        function removeAnchor(node) {
            editor.undoManager.transact(function () {
                editor.dom.remove(node, true);
            });
        }

        function addAnchor(id) {
            if (!isvalidId(id)) {
                editor.windowManager.alert('Id should start with a letter, followed only by letters, numbers, dashes, dots, colons or underscores.');
            } else if(isSameId(id)) {
                editor.windowManager.alert('This is a duplicate name.');
            } else {
                editor.undoManager.transact(function () {
                    editor.insertContent(editor.dom.createHTML('a', { id: id }));
                });
                refreshAnchorItemList();
                _bookmarkName.value = '';
                setButtonStatus(false, false, false);
            }
        }

        function updateAnchor(id, anchorElement) {
            if (!isvalidId(id)) {
                editor.windowManager.alert('Id should start with a letter, followed only by letters, numbers, dashes, dots, colons or underscores.');
            } else if(isSameId(id)) {
                editor.windowManager.alert('This is a duplicate name.');
            } else {
                anchorElement.removeAttribute('name');
                anchorElement.id = id;
                editor.addVisual();
                editor.undoManager.add();
                updateAnchorItemList();
            }
        }

        function updateAnchorItemList() {
            var itemListHTML = editor.dom.createHTML('ul', {
                id: "covi_anchor_item_list",
                style: "list-style: none; padding: 2px 3px;",
                onmouseover: "this.style.cursor= 'pointer'",
                onmouseout: "this.style.cursor= 'auto'"
            }, makeItemListHTML(_selectedIndex));

            var anchorItemListEl = editor.dom.$.find("#covi_anchor_list");
            if (anchorItemListEl[0].hasChildNodes()) {
                anchorItemListEl[0].innerHTML = "";
            }
            anchorItemListEl[0].innerHTML = itemListHTML;
        }

        function refreshAnchorItemList() {
            var itemListHTML = editor.dom.createHTML('ul', {
                id: "covi_anchor_item_list",
                style: "list-style: none; padding: 2px 3px;",
                onmouseover: "this.style.cursor= 'pointer'",
                onmouseout: "this.style.cursor= 'auto'"
            }, makeItemListHTML(-1));

            var anchorItemListEl = editor.dom.$.find("#covi_anchor_list");
            if (anchorItemListEl[0].hasChildNodes()) {
                anchorItemListEl[0].innerHTML = "";
            }
            anchorItemListEl[0].innerHTML = itemListHTML;
        }

        function goToAnchor() {
            if (_selectedIndex > -1) {
                editor.selection.scrollIntoView(_anchorList[_selectedIndex], true);
            }
        }

        function openBookmarkDlg() {
            _dialog = editor.windowManager.open(getDlgOptions());
            _dialog.focus();
            bindGlobalEl();
            setButtonStatus(true, false, false);
        }

        editor.ui.registry.addButton('covianchor', {
            icon: 'bookmark',
            tooltip: 'Bookmark',
            onAction: openBookmarkDlg
        });

        editor.ui.registry.addMenuItem('covianchor', {
            text: 'Bookmark',
            icon: 'bookmark',
            onAction: openBookmarkDlg
        });
    });
}());
