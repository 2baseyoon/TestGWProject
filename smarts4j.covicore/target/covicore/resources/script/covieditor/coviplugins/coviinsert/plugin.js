(function () {
    'use strict';

    tinymce.PluginManager.add('coviinsert', function(editor, url) {
        var _dialog = null;
        var _file = null;
        var _selectedAnchor = null;
        var _selectedIframe = null;
        var _accLevel = editor.getParam('accessibility', 0);
        var INSERT_FILE_SELECTOR = 'covi-insert-file';
        var ALIGN_TYPE_MAP = {
            JustifyLeft: 'left',
            JustifyCenter: 'center',
            JustifyRight: 'right',
            JustifyFull: 'justify'
        };

        function isUrl(str) {
            var regexp =  /^(?:(?:https?|ftp):\/\/)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/\S*)?$/;

            return regexp.test(str);
        }

        function insertLink(url, desc) {
            var linkAttrs = {
                href: url,
                rel: null,
                target: null,
                title: desc,
                class: INSERT_FILE_SELECTOR
            }

            editor.insertContent(editor.dom.createHTML('a', linkAttrs, editor.dom.encode(_file.name)));
        }

        function genUniqFileName(name) {
            var extStartPos = _file.name.lastIndexOf('.');

            extStartPos = extStartPos > -1 ? extStartPos : _file.name.length - 1;

            return [_file.name.slice(0, extStartPos), ("_" + (new Date()).getTime()), _file.name.slice(extStartPos)].join('');
        }

        function uploadFile(success, fail) {
            var xhr = new XMLHttpRequest();
            xhr.open('POST', editor.getParam('images_upload_url'));
            xhr.onload = function () {
                var json;

                if (xhr.status != 200) {
                    fail();
                    return;
                }

                json = JSON.parse(xhr.responseText);

                if (!json || typeof json.location != 'string') {
                    fail();
                    return;
                }

                success(json.location);
            }

            var formData = new FormData();
            var fileName = genUniqFileName(_file.name);

            formData.append('file', _file, fileName);

            xhr.send(formData);
        }

        function getFileDlgOptions() {
            var selected = editor.selection.getNode();
            var initData = null;

            if (selected && selected.tagName === 'A') {
                _selectedAnchor = selected;

                initData = {
                    file: {
                        value: selected.text,
                        meta: { original: { value: selected.text } }
                    },
                    title: selected.title
                }
            }

            return {
                title: 'Insert/Edit File',
                body: {
                    type: 'panel',
                    items: [{
                        name: 'file',
                        type: 'urlinput',
                        filetype: 'file',
                        label: 'File'
                    }, {
                        name: 'title',
                        type: 'input',
                        label: 'Title'
                    }]

                },
                initialData: initData,
                onClose: function() {
                    _selectedAnchor = null;
                    _file = null;
                },
                onChange: function(api, details) {
                    var data = api.getData();

                    if (data.file.meta.attach && details.name === 'file') {
                        _file = data.file.meta.attach;
                        api.setData({ title: ""});
                    }
                },
                onSubmit: function(api) {

                    if (_file) {
                        var success = function(url) {
                            if (_selectedAnchor) {
                                _selectedAnchor.setAttribute('href', url);
                                _selectedAnchor.setAttribute('data-mce-href', url);
                                _selectedAnchor.setAttribute('title', api.getData().title);
                                _selectedAnchor.text = _file.name;
                            } else {
                                insertLink(url, api.getData().title);
                            }

                            api.close();
                        };

                        var fail = function() {
                            tinymce.activeEditor.notificationManager.open({
                                text: [
                                    'Failed to upload file: {0}',
                                    _file.name
                                ],
                                type: 'error',
                                timeout: 3000,
                                closeButton: true
                            });

                            api.close();
                        };

                        // temporary for local test
                        if (window.location.protocol === 'file:') {
                            fail();
                            return;
                        }

                        uploadFile(success, fail);
                    } else if (_selectedAnchor) {
                        var data = api.getData();

                        _selectedAnchor.text = data.file.value;
                        _selectedAnchor.title = data.title;
                        api.close();
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
                    name: 'save',
                    text: 'Save',
                    primary: true
                }]
            };
        }

        function getIframeDlgOptions() {
            var selected = editor.selection.getNode();
            var initData = null;

            if (selected && selected.classList.contains("mce-object-iframe")) {
                _selectedIframe = selected;

                initData = {
                    source: {
                        value: _selectedIframe.getAttribute('data-mce-p-src'),
                        meta: { original: { value: _selectedIframe.getAttribute('data-mce-p-src') } }
                    },
                    title: _selectedIframe.getAttribute('data-mce-p-title')
                }
            }

            return {
                title: 'Insert/Edit Iframe',
                body: {
                    type: 'panel',
                    items: [{
                        name: 'source',
                        type: 'urlinput',
                        label: 'Url'
                    }, {
                        name: 'title',
                        type: 'input',
                        label: 'Title'
                    }]
                },
                initialData: initData,
                onClose: function() {
                    _selectedIframe = null;
                },
                onChange: function(api, details) {
                    if (details.name === 'source') {
                        api.setData({ title: ""});
                    }
                },
                onSubmit: function(api) {
                    var data = api.getData();
                    var url = data.source.value;

                    if (isUrl(url)) {
                        if (url.indexOf("http://") < 0 || url.indexOf("https://") < 0) {
                            url = "http://" + url;
                        }
                    } else {
                        tinymce.activeEditor.notificationManager.open({
                            text: [
                                'Invalid URL: {0}',
                                url
                            ],
                            type: 'error',
                            timeout: 3000,
                            closeButton: true
                        });

                        api.close();
                        return;
                    }

                    if (_selectedIframe) {
                        var mceIframes = editor.dom.$(".mce-object-iframe");

                        for (var i = 0; i < mceIframes.length; i++) {
                            mceIframes[i].setAttribute('data-mce-p-src', url);
                            mceIframes[i].setAttribute('data-mce-p-title', data.title);

                            var iframe = mceIframes[i].firstChild;

                            if (iframe.tagName === 'IFRAME') {
                                iframe.setAttribute('src', url);
                                iframe.setAttribute('title', data.title);
                            }
                        }
                    } else {
                        var linkAttrs = {
                            src: url,
                            title: data.title,
                            scrolling: "auto",
                            frameborder: "0"
                        }

                        editor.insertContent(editor.dom.createHTML('iframe', linkAttrs, ''));
                    }
                    api.close();
                },
                buttons: [{
                    text: 'Close',
                    type: 'cancel',
                    onclick: 'close'
                }, {
                    type: 'submit',
                    name: 'save',
                    text: 'Save',
                    primary: true
                }]
            };
        }

        function getBGImageDlgOptions() {
            var body = editor.getBody();
            var initData = {
                bgcolor: '#FFFFFF'
            };

            if (body && body.style.backgroundImage.length > 0) {
                var url = body.style.backgroundImage.replace(/^url\(["']?/, '').replace(/["']?\)$/, '');
                initData.bgimage = {
                    value: url,
                    meta: {
                        original: {
                            value: url
                        }
                    }
                };
                initData.options = body.style.backgroundAttachment;
                initData.repeat = body.style.backgroundRepeat;
                initData.bgcolor = (body.style.backgroundColor && body.style.backgroundColor.length > 0) ? body.style.backgroundColor : '#FFFFFF';
            }

            return {
                title: 'Insert/Edit Background image',
                body: {
                    type: 'panel',
                    items: [{
                        name: 'bgimage',
                        type: 'urlinput',
                        filetype: 'file',
                        label: 'Source'
                    }, {
                        name: 'options',
                        type: 'selectbox',
                        label: 'Options',
                        size: 1,
                        items: [
                            { value: 'default', text: 'default' },
                            { value: 'scroll', text: 'scroll' },
                            { value: 'fixed', text: 'fixed' }
                        ]
                    }, {
                        name: 'repeat',
                        type: 'selectbox',
                        label: 'Repeat',
                        size: 1,
                        items: [
                            { value: 'no-repeat', text: 'No repeat' },
                            { value: 'repeat', text: 'Repeat' },
                            { value: 'repeat-x', text: 'Horizontal repeat' },
                            { value: 'repeat-y', text: 'Vertical repeat' }
                        ]
                    }, {
                        name: 'bgcolor',
                        type: 'colorinput',
                        label: 'Background color'
                    }, {
                        name: 'rmbg',
                        type: 'checkbox',
                        label: 'Remove background'
                    }]
                },
                initialData: initData,
                onClose: function() {
                    _file = null;
                },
                onChange: function(api, details) {
                    var data = api.getData();

                    if (data.bgimage.meta.attach && details.name === 'bgimage') {
                        _file = data.bgimage.meta.attach;
                    }
                },
                onSubmit: function(api) {
                    var data = api.getData();

                    var success = function(url) {
                        body.style.backgroundImage = data.rmbg ? '' : "url('" + url + "')";;
                        body.style.backgroundAttachment = data.rmbg ? '' : data.options;
                        body.style.backgroundRepeat = data.rmbg ? '' : data.repeat;
                        body.style.backgroundColor = data.rmbg ? '' : data.bgcolor;

                        api.close();
                    };

                    var fail = function() {
                        tinymce.activeEditor.notificationManager.open({
                            text: [
                                'Failed to upload file: {0}',
                                _file.name
                            ],
                            type: 'error',
                            timeout: 3000,
                            closeButton: true
                        });

                        api.close();
                    };

                    // temporary for local test
                    if (window.location.protocol === 'file:') {
                        success('');
                        return;
                    }

                    if (data.rmbg === true || _file === null) {
                        var url = _file === null ? data.bgimage.value : '';
                        success(url);
                        return;
                    }

                    uploadFile(success, fail);
                },
                buttons: [{
                    text: 'Close',
                    type: 'cancel',
                    onclick: 'close'
                }, {
                    type: 'submit',
                    name: 'save',
                    text: 'Save',
                    primary: true
                }]
            };
        }

        function accAlert(e, message) {
            if (_accLevel > 0) {
                var requiredMsg = tinymce.util.I18n.translate('This is a required field.');

                if (_accLevel === 1) {
                    editor.windowManager.alert(message);
                } else if (_accLevel === 2) {
                    e.preventDefault();
                    editor.windowManager.alert(message + ' ' + requiredMsg);
                }
            }
        }

        editor.ui.registry.addMenuItem('coviinsertfile', {
            text: 'File...',
            icon: 'document-properties',
            onAction: function() {
                _dialog = editor.windowManager.open(getFileDlgOptions());
            },
        });

        if (editor.settings.invalid_elements.toLowerCase().indexOf('iframe') == -1) {
            editor.ui.registry.addMenuItem('coviinsertiframe', {
                text: 'Iframe...',
                icon: 'embed-page',
                onAction: function() {
                    _dialog = editor.windowManager.open(getIframeDlgOptions());
                    document.getElementsByClassName("tox-form__controls-h-stack")[0].lastChild.style.display = "none";
                }
            });
        }

        editor.ui.registry.addMenuItem('coviinsertbgimage', {
            text: 'Background image...',
            icon: 'image',
            onAction: function() {
                _dialog = editor.windowManager.open(getBGImageDlgOptions());
            }
        });

        editor.ui.registry.addToggleButton('coviinsertfile', {
            icon: 'document-properties',
            tooltip: 'Insert/Edit File',
            onAction: function() {
                _dialog = editor.windowManager.open(getFileDlgOptions());
            },
            onSetup: function(api) {
                var nodeChangeHandler = function (e) {
                    api.setActive(e.element.className.indexOf(INSERT_FILE_SELECTOR) > -1 && e.element.tagName === 'A');
                };
                editor.on('NodeChange', nodeChangeHandler);
                return function () {
                    return editor.off('NodeChange', nodeChangeHandler);
                };
            }
        });

        editor.ui.registry.addContextMenu('coviinsertfile', {
            update: function(element) {
                return (element.className.indexOf(INSERT_FILE_SELECTOR) > -1 && element.tagName === 'A') ? 'coviinsertfile' : '';
            }
        });

        editor.ui.registry.addMenuItem('covipagebreak', {
            text: 'Page break',
            icon: 'page-break',
            onAction: function () {
                editor.undoManager.transact(function () {
                    editor.execCommand('mcePageBreak');
                });
            }
        });

        editor.ui.registry.addButton('covipagebreak', {
            icon: 'page-break',
            tooltip: 'Page break',
            onAction: function () {
                editor.undoManager.transact(function () {
                	editor.execCommand('mcePageBreak');
                });
            }
        });

        if (_accLevel > 0) {
            editor.on('BeforeExecCommand', function (e) {
                if (e.command === 'mceUpdateImage') {
                    if (e.value.alt.trim().length === 0) {
                        accAlert(e, tinymce.util.I18n.translate('No image alternative description.'));
                    }
                }

                if (e.command === 'mceInsertContent') {
                    if (e.value.trim().indexOf('<iframe') === 0) {
                        tinymce.util.Tools.resolve('tinymce.html.SaxParser')({
                            validate: false,
                            start: function (name, attrs) {
                                if (name === 'iframe' && attrs.map.title.trim().length === 0) {
                                    accAlert(e, tinymce.util.I18n.translate('No iframe title.'));
                                }
                            }
                        }).parse(e.value);
                    }
                }
            });
        }

        editor.on('BeforeExecCommand', function(e) {
            var selectedNode = editor.selection.getNode();

            if (selectedNode.nodeName.toLowerCase() === 'img') {
                if (e.command === 'JustifyLeft' || e.command === 'JustifyCenter' || e.command === 'JustifyRight' || e.command === 'JustifyFull') {
                    var parentNode = selectedNode.parentNode;
                    var parentNodeName = parentNode.nodeName.toLowerCase();

                    if (parentNodeName === editor.dom.getRoot().nodeName.toLowerCase()) {
                        parentNode = editor.dom.create('p', { style: 'text-align:' + ALIGN_TYPE_MAP[e.command]});
                        selectedNode.wrap(parentNode);
                    }

                    if (parentNodeName !== 'p' && parentNodeName !== 'div') {
                        e.preventDefault();
                    }
                }
            }
        });

        editor.on('ExecCommand', function(e) {
            var selectedNode = editor.selection.getNode();

            if (selectedNode.nodeName.toLowerCase() === 'img') {
                if (e.command === 'JustifyLeft' || e.command === 'JustifyCenter' || e.command === 'JustifyRight' || e.command === 'JustifyFull') {
                    var parentNode = selectedNode.parentNode;
                    var parentNodeName = parentNode.nodeName.toLowerCase();

                    if (parentNodeName === 'p' || parentNodeName === 'div') {
                        editor.dom.setStyle(parentNode, 'text-align', ALIGN_TYPE_MAP[e.command]);
                    }

                    editor.dom.setStyle(selectedNode, 'float', null);
                }
            }
        });

        editor.on('ScrollIntoView', function(e) {
            if (e.elm.id === 'mce_marker') {
                e.preventDefault();
            }
        });

        return {
        };
    });
}());