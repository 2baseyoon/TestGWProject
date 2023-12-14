(function () {
    'use strict';

    tinymce.PluginManager.add('coviaccessibility', function(editor, url) {
        var _dialog;
        var _checkResult = [];
        var WHITE_SPACES_EXP = /\s+/g;
        var INVALID_MARK_ICO = tinymce.IconManager.get("coviicons").icons["accessibility-check"];
        var VALID_MARK_ICO = tinymce.IconManager.get("default").icons["checkmark"];
        var INVALUE_ITEM_TYPE = {
            TABLE: 0,
            IMG: 1,
            IFRAME: 2,
            ANCHOR: 3,
            DUPLICATE: 4
        }
        var INVALID_ITEM_ID = "covi_id";
        var FIX_INPUT_SELECTOR = {
            CAPTION: "covi_fix_caption",
            SUMMARY: "covi_fix_summary",
            ALT: "covi_fix_alt",
            TITLE: "covi_fix_title",
            DUPLICATE: "covi_fix_dup"
        }
        var ACC_IGNORE_SELECTOR = "covi_acc_ignore";
        var ACC_IGNORE_EXP = /\s?covi_acc_ignore/g;
        var DUPLICATE_ID_ARROW = "&nbsp&#8594&nbsp";

        function makeFixInputItem(label, value, selector) {
            return "<label class='tox-label'>" + label + "</label>" +
                "<input class='tox-textfield' id='" + selector + "' type='text' data-alloy-tabstop='true' value='" + value + "'>";
        }

        function makeCellText(text, width, color) {
            var td = document.createElement("TD");
            td.setAttribute("style", "width:" + width + "; border-right: 1px solid #ccc; border-bottom: 1px solid #ccc; padding: 3px" + (color ? ("; color:" + color + ";") : ""));
            td.innerHTML = text;

            return td;
        }

        function makeCellIcon() {
            var td = document.createElement("TD");
            td.setAttribute("style", "width:33%; height: 80%; border-right: 0px solid #ccc; border-bottom: 1px solid #ccc; padding: 3px");

            var span = document.createElement("SPAN");
            span.innerHTML = INVALID_MARK_ICO;

            td.appendChild(span);

            return td;
        }

        function makeHeader() {
            var headerStyle = "border-right: 1px solid #ccc; border-bottom: 1px solid #ccc; font-weight: bold; text-align: center; padding: 3px;";
            var headerStyle_1 = "border-right: 0px solid #ccc; border-bottom: 1px solid #ccc; font-weight: bold; text-align: center; padding: 3px;";
            return "<thead><tr>" +
                "<th style='" + "width:15%; " + headerStyle + "'>" + tinymce.util.I18n.translate('Element')+ "</th>" +
                "<th style='" + "width:80%; " + headerStyle + "'>" + tinymce.util.I18n.translate('Content')+ "</th>" +
                "<th style='" + "width:5%; " + headerStyle_1 + "'></th></tr></thead>";
        }

        function makeRow(item) {
            var tr = document.createElement("TR");
            var td1 = makeCellText(item.targetEl.tagName, "15%");
            var td2 = makeCellText(item.desc, "80%");
            var td3 = makeCellIcon();

            if (item.duplicate) {
                var p = document.createElement("span");
                p.setAttribute("style", "color: red;")
                p.innerHTML = DUPLICATE_ID_ARROW + item.duplicate;

                td2.appendChild(p);
            }

            tr.setAttribute("style", "width:100%; vertical-align: middle;");
            tr.setAttribute("class", "invalid_item_row");
            tr.setAttribute(INVALID_ITEM_ID, item.targetEl.getAttribute(INVALID_ITEM_ID));
            tr.setAttribute("onMouseOver", "this.style.cursor='pointer'");
            tr.setAttribute("onMouseOut", "this.style.cursor='auto'");
            tr.setAttribute("onClick", "COVI_ACCESSIBILITY.coviSelectInvalidItem('" + item.targetEl.getAttribute(INVALID_ITEM_ID) + "');");
            tr.appendChild(td1);
            tr.appendChild(td2);
            tr.appendChild(td3);

            return tr.outerHTML;
        }

        function findCheckResultItemByID(id) {
            for (var i = 0; i < _checkResult.length; i++) {
                if (_checkResult[i].targetEl.getAttribute(INVALID_ITEM_ID) == id) {
                    return _checkResult[i];
                }
            }

            return null;
        }

        function getDlgOptions() {
            var rowHtml = "";

            for (var i = 0; i < _checkResult.length; i ++) {
                var item = _checkResult[i];

                item.targetEl.setAttribute(INVALID_ITEM_ID, "invalid_item_" + i);
                rowHtml += makeRow(item);
            }

            return {
                title: 'Accessibility',
                body: {
                    type: 'panel',
                    items: [{
                        type: 'htmlpanel',
                        html: "<div style='width:100%; height:200px; overflow:auto; border:1px solid #ccc; box-sizing:border-box' ><table style='width:100%; border:0px solid #ccc; font-size: 14px;' cellpadding='0' cellspacing='0'>" + makeHeader() +
                              "<tbody id='invalid_items'>" + rowHtml + "</tbody></table></div><br/>"
                    }, {
                        type: 'htmlpanel',
                        html: "<div id='covi_fix_area'></div>" +
                            "<div id='covi_fix_ignore' style='display: flex; float: right; align-items: center; margin-top: 10px; font-size: 12px;'>" +
                            "<input type='checkbox' style='width:24px;'>" + (tinymce.util.I18n.getCode() == "ko_KR" ? "\uBBF8\uC785\uB825" : tinymce.util.I18n.translate("Ignore")) + "</input>" +
                            "</div><br/>" +
                            "<div style='display: flex; justify-content: center; align-items: center; margin-top: 10px'>" +
                            "<button type='button' data-alloy-tabstop='true' class='tox-button' onclick='COVI_ACCESSIBILITY.applyFix();'>" + tinymce.util.I18n.translate("Apply") + "</button>" +
                            "</div>",
                    }]
                },
                onClose: function () {
                    if (window.COVI_ACCESSIBILITY) {
                        if (COVI_ACCESSIBILITY.selectedElem !== null) {
                            COVI_ACCESSIBILITY.selectedElem.style.border = COVI_ACCESSIBILITY.unselectedBorderStyle;
                        }

                        window.COVI_ACCESSIBILITY = undefined;
                    }

                    var markedElems = editor.dom.$("*[covi_id]");

                    for (var i = 0; i < markedElems.length; i++) {
                        markedElems[i].removeAttribute(INVALID_ITEM_ID);
                    }
                },
                buttons: [
                    {
                        text: 'Close',
                        type: 'cancel',
                        onclick: 'close'
                    }
                ]
            };
        }

        function showIgnoreOption(parentEl, isShow) {
            var ignoreCheckboxEl = parentEl.querySelector("#covi_fix_ignore");

            if (ignoreCheckboxEl) {
                ignoreCheckboxEl.style.display = isShow ? "flex" : "none";
            }
        }

        function updateSelectedInvalidItem(id) {
            var items = document.getElementsByClassName("invalid_item_row");

            for (var i = 0; i < items.length; i++) {
                items[i].style.backgroundColor = items[i].getAttribute(INVALID_ITEM_ID) == id ? "#EEE" : "#FFF";
            }

            var fixAreaEl = document.getElementById("covi_fix_area");

            if (fixAreaEl) {
                fixAreaEl.innerHTML = "";

                var itemInfo = findCheckResultItemByID(id);

                showIgnoreOption(fixAreaEl.parentElement, true);

                if (itemInfo.type == INVALUE_ITEM_TYPE.TABLE) {
                    if (itemInfo.caption !== undefined && itemInfo.caption === false) {
                        var captionDiv = document.createElement("DIV");
                        captionDiv.innerHTML = makeFixInputItem(tinymce.util.I18n.translate("Title"), itemInfo.inputCaption, FIX_INPUT_SELECTOR.CAPTION);
                        fixAreaEl.appendChild(captionDiv);
                    }

                    if (itemInfo.summary !== undefined && itemInfo.summary === false) {
                        var summaryDiv = document.createElement("DIV");
                        summaryDiv.innerHTML = makeFixInputItem(tinymce.util.I18n.translate("Summary"), itemInfo.inputSummary, FIX_INPUT_SELECTOR.SUMMARY);
                        fixAreaEl.appendChild(summaryDiv);
                    }
                } else {
                    var div = document.createElement("DIV");

                    if (itemInfo.type == INVALUE_ITEM_TYPE.IMG) {
                        div.innerHTML = makeFixInputItem(tinymce.util.I18n.translate("Description"), itemInfo.inputAlt, FIX_INPUT_SELECTOR.ALT);
                    } else if (itemInfo.type == INVALUE_ITEM_TYPE.IFRAME || itemInfo.type == INVALUE_ITEM_TYPE.ANCHOR) {
                        div.innerHTML = makeFixInputItem(tinymce.util.I18n.translate("Title"), itemInfo.inputTitle, FIX_INPUT_SELECTOR.TITLE);
                    } else if (itemInfo.type == INVALUE_ITEM_TYPE.DUPLICATE) {
                        div.innerHTML = makeFixInputItem("ID", itemInfo.duplicate, FIX_INPUT_SELECTOR.DUPLICATE);
                        showIgnoreOption(fixAreaEl.parentElement, false);
                    }

                    fixAreaEl.appendChild(div);
                }
            }
        }

        function updateSelectedInvalidTargetElem(id) {
            if (COVI_ACCESSIBILITY.selectedElem !== null) {
                COVI_ACCESSIBILITY.selectedElem.style.border = COVI_ACCESSIBILITY.unselectedBorderStyle;
            }

            var selectedElem = editor.dom.$("*[covi_id*=" + id + "]")[0];

            COVI_ACCESSIBILITY.selectedElem = selectedElem;
            COVI_ACCESSIBILITY.unselectedBorderStyle = selectedElem.style.border;
            selectedElem.style.border = '2px solid red';

            var iframeWin = editor.getWin();

            iframeWin.scroll(0, 0);

            var elemRect = selectedElem.getBoundingClientRect();

            iframeWin.scroll(elemRect.left, elemRect.top);
        }

        function toggleFixedMark(id, isValid) {
            var elems = document.getElementsByClassName("invalid_item_row");

            for (var i = 0; i < elems.length; i++) {
                if (elems[i].getAttribute(INVALID_ITEM_ID) == id) {
                    elems[i].lastChild.firstChild.innerHTML = isValid ? VALID_MARK_ICO : INVALID_MARK_ICO;
                }
            }
        }

        function setIgnore(item, isIgnore) {

            if (isIgnore) {
                item.targetEl.classList.add(ACC_IGNORE_SELECTOR);
            } else {
                item.targetEl.classList.remove(ACC_IGNORE_SELECTOR);
            }

            // for tiny internal iframe tag
            if (item.type == INVALUE_ITEM_TYPE.IFRAME) {
                var parentEl = item.targetEl ? item.targetEl.parentElement : null;

                if (parentEl !== null) {
                    var className = parentEl ? parentEl.getAttribute("data-mce-p-class") : "";

                    if (className === null) {
                        className = "";
                    }

                    if (isIgnore) {
                        if (ACC_IGNORE_EXP.test(className) == false) {
                            className = ((className.replace(WHITE_SPACES_EXP, '').length > 0) ? " " : "") + ACC_IGNORE_SELECTOR;
                        }
                    } else {
                        className = className.replace(ACC_IGNORE_EXP, '');
                    }

                    parentEl.setAttribute("data-mce-p-class", className);
                }
            }
        }

        function initAccessibility() {
            if (window.COVI_ACCESSIBILITY === undefined) {
                window.COVI_ACCESSIBILITY = {
                    selectedElem: null
                };

                COVI_ACCESSIBILITY.coviSelectInvalidItem = function (id) {
                    document.getElementsByClassName("tox-dialog-wrap__backdrop")[0].style.backgroundColor = "rgba(255,255,255,.0)";
                    updateSelectedInvalidItem(id);
                    updateSelectedInvalidTargetElem(id);
                }

                COVI_ACCESSIBILITY.applyFix = function () {
                    var selectedId = COVI_ACCESSIBILITY.selectedElem.getAttribute(INVALID_ITEM_ID);

                    if (selectedId !== undefined && selectedId.length > 0) {
                        var selectedItem = findCheckResultItemByID(selectedId);

                        if (selectedItem) {
                            var isFixed = false;
                            var isIgnore = document.getElementById("covi_fix_ignore").firstChild.checked;

                            setIgnore(selectedItem, isIgnore);

                            if (selectedItem.type == INVALUE_ITEM_TYPE.TABLE) {
                                var captionInput = document.getElementById(FIX_INPUT_SELECTOR.CAPTION);
                                var summaryInput = document.getElementById(FIX_INPUT_SELECTOR.SUMMARY);

                                if (captionInput) {
                                    var existCaptionEl = selectedItem.targetEl.getElementsByTagName("CAPTION");

                                    selectedItem.inputCaption = captionInput.value;

                                    if (existCaptionEl.length > 0) {
                                        existCaptionEl[0].innerText = captionInput.value;
                                    } else {
                                        var captionEl = document.createElement("CAPTION");
                                        captionEl.innerText = captionInput.value;
                                        selectedItem.targetEl.appendChild(captionEl);
                                    }
                                }

                                if (summaryInput) {
                                    selectedItem.inputSummary = summaryInput.value;
                                    selectedItem.targetEl.setAttribute("summary", summaryInput.value);
                                }

                                isFixed = (checkTable(selectedItem.targetEl) === null);
                            } else if (selectedItem.type == INVALUE_ITEM_TYPE.IMG) {
                                var altInput = document.getElementById(FIX_INPUT_SELECTOR.ALT);

                                if (altInput) {
                                    selectedItem.inputAlt = altInput.value;
                                    selectedItem.targetEl.setAttribute("alt", altInput.value);
                                }

                                isFixed = (checkImg(selectedItem.targetEl) === null);
                            } else if (selectedItem.type == INVALUE_ITEM_TYPE.IFRAME) {
                                var titleInput = document.getElementById(FIX_INPUT_SELECTOR.TITLE);

                                if (titleInput) {
                                    selectedItem.inputTitle = titleInput.value;
                                    selectedItem.targetEl.setAttribute("title", titleInput.value);
                                    selectedItem.targetEl.parentElement.setAttribute("data-mce-p-title", titleInput.value);
                                }

                                isFixed = (checkIframe(selectedItem.targetEl) === null);
                            } else if (selectedItem.type == INVALUE_ITEM_TYPE.ANCHOR) {
                                var titleInput = document.getElementById(FIX_INPUT_SELECTOR.TITLE);

                                if (titleInput) {
                                    selectedItem.inputTitle = titleInput.value;
                                    selectedItem.targetEl.setAttribute("title", titleInput.value);
                                }

                                isFixed = (checkAnchor(selectedItem.targetEl) === null);
                            } else if (selectedItem.type == INVALUE_ITEM_TYPE.DUPLICATE) {
                                var duplicateInput = document.getElementById(FIX_INPUT_SELECTOR.DUPLICATE);

                                if (duplicateInput) {
                                    selectedItem.duplicate = duplicateInput.value;
                                    selectedItem.targetEl.setAttribute("id", duplicateInput.value);
                                }

                                isFixed = (editor.dom.$("*[id*=" + duplicateInput.value + "]").length <= 1);
                            }

                            toggleFixedMark(selectedId, isFixed);
                        }
                    }
                }
            }
        }

        function isExistAttrValue(elem, attrName) {
            attrName = attrName.toLowerCase();

            return elem[attrName] != null && elem[attrName].replace(WHITE_SPACES_EXP, '').length > 0;
        }

        function isIgnore(elem) {
            return elem.className.indexOf(ACC_IGNORE_SELECTOR) > -1;
        }

        function checkTable(elem) {
            if (isIgnore(elem)) {
                return null;
            }

            var result = null;
            var isCaption = (elem.caption != null && elem.caption.innerHTML.replace(WHITE_SPACES_EXP, '').length > 0);
            var isSummary = isExistAttrValue(elem, "summary");
            var desc = "";

            if (!isCaption && !isSummary) {
                desc = tinymce.util.I18n.translate("Caption and summary are not provided");
            } else if (!isCaption) {
                desc = tinymce.util.I18n.translate("Caption is not provided");
            } else if (!isSummary) {
                desc = tinymce.util.I18n.translate("Summary is not provided");
            }

            if (!isCaption || !isSummary) {
                result = {
                    type: INVALUE_ITEM_TYPE.TABLE,
                    targetEl: elem,
                    caption: isCaption,
                    summary: isSummary,
                    inputCaption: "",
                    inputSummary: "",
                    desc: desc,
                    etc: ""
                };
            }

            return result;
        }

        function checkImg(elem) {
            if (isIgnore(elem)) {
                return null;
            }

            var result = null;
            var isAlt = isExistAttrValue(elem, "alt");

            if (!isAlt) {
                result = {
                    type: INVALUE_ITEM_TYPE.IMG,
                    targetEl: elem,
                    alt: isAlt,
                    inputAlt: "",
                    desc: tinymce.util.I18n.translate("Alternative text is not provided"),
                    etc: ""
                }
            }

            return result;
        }

        function checkIframe(elem) {
            if (isIgnore(elem)) {
                return null;
            }

            var result = null;
            var title = elem.parentElement.getAttribute("data-mce-p-title");
            var isTitle = title != null && title.replace(WHITE_SPACES_EXP, '').length > 0;

            if (!isTitle) {
                result = {
                    type: INVALUE_ITEM_TYPE.IFRAME,
                    targetEl: elem,
                    title: isTitle,
                    isIframe: true,
                    inputTitle: "",
                    desc: tinymce.util.I18n.translate("Title is not provided"),
                    etc: ""
                }
            }

            return result;
        }

        function checkAnchor(elem) {
            if (isIgnore(elem)) {
                return null;
            }

            var result = null;
            var isTitle = isExistAttrValue(elem, "title");

            if (!isTitle) {
                result = {
                    type: INVALUE_ITEM_TYPE.ANCHOR,
                    targetEl: elem,
                    title: isTitle,
                    inputTitle: "",
                    desc: tinymce.util.I18n.translate("Title is not provided"),
                    etc: ""
                }
            }

            return result;
        }

        function checkAccessibility() {
            var rootEl = editor.dom.getRoot();
            var allTagEl = rootEl.getElementsByTagName('*');
            var allIds = {};
            var duplicatedIds = [];
            _checkResult = [];

            for (var i = 0; i < allTagEl.length; i++) {
                var result = null;
                var elem = allTagEl[i];

                if (elem.tagName.toUpperCase() == "TABLE") {
                    result = checkTable(elem);
                } else if (elem.tagName.toUpperCase() == "IMG") {
                    result = checkImg(elem);
                } else if (elem.tagName.toUpperCase() == "IFRAME") {
                    result = checkIframe(elem);
                } else if (elem.tagName.toUpperCase() == "A") {
                    result = checkAnchor(elem);
                }

                if (result != null) {
                    _checkResult.push(result);
                }

                if (elem.id && elem.id.length > 0) {
                    if (allIds[elem.id] === undefined) {
                        allIds[elem.id] = 1;
                    } else {
                        duplicatedIds.push(elem.id);
                    }
                }
            }

            for (var i = 0; i < duplicatedIds.length; i++) {
                var elems = editor.dom.$("*[id*=" + duplicatedIds[i] + "]");

                for (var j = 0; j < elems.length; j++) {
                    var duplicateInfo = {
                        type: INVALUE_ITEM_TYPE.DUPLICATE,
                        targetEl: elems[j],
                        duplicate: duplicatedIds[i],
                        desc: tinymce.util.I18n.translate("A duplicate id is used"),
                        etc: ""
                    }

                    _checkResult.push(duplicateInfo);
                }
            }
        }

        function openAccessibilityCheckDlg() {
            initAccessibility();
            checkAccessibility();

            if (_checkResult.length > 0) {
                _dialog = editor.windowManager.open(getDlgOptions());
                COVI_ACCESSIBILITY.coviSelectInvalidItem(_checkResult[0].targetEl.getAttribute(INVALID_ITEM_ID));
            } else {
                tinymce.activeEditor.notificationManager.open({
                    text: 'There are no violations',
                    type: 'info',
                    timeout: 3000,
                    closeButton: true
                });
            }
        }

        editor.ui.registry.addButton('coviAccessibilityChecker', {
            icon: 'accessibility-check',
            tooltip: 'Accessibility',
            onAction: openAccessibilityCheckDlg
        });

        editor.ui.registry.addMenuItem('coviAccessibilityChecker', {
            text: 'Accessibility',
            icon: 'accessibility-check',
            onAction: openAccessibilityCheckDlg
        });

        return {
            getMetadata: function () {
                return  {
                    name: 'Accessibility',
                    url: 'https://www.covision.co.kr/'
                };
            }
        };
    });

}());