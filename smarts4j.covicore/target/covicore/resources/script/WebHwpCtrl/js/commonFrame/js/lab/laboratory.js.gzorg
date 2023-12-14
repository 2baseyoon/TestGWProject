define(function (require) {
    "use strict";

    /*******************************************************************************
     * Import
     ******************************************************************************/

    var $ = require("jquery"),
        LabConfigController = require("commonFrameJs/lab/configController"),
        LabTemplete = require("text!../../../commonFrame/html/lab/lab_dialog.html"),
        Util = require("commonFrameJs/utils/util");

    /*******************************************************************************
     * Private Variables
     ******************************************************************************/

    var _dialogWrap;

    /*******************************************************************************
     * Constructor
     ******************************************************************************/

    var Laboratory = function () {
        this.isRender = false;
    };

    /*********************************************
     * Public method
     **********************************************/

    /**
     * 실험실 프로퍼티창을 렌더한다.
     *
     */
    Laboratory.prototype.render = function () {
        var divEl = document.createElement("div"),
            domEl;

        domEl = LabTemplete;

        if (domEl == null) {
            console.error("Error : domEl isn't a string");
            return;
        }

        divEl.innerHTML = domEl;
        _dialogWrap = document.getElementById("dialog") || document.getElementsByClassName("dialog_wrap")[0];

        if (_dialogWrap) {
            _dialogWrap.appendChild(divEl.childNodes[0]);

            this.initEvtHandler();

            this.isRender = true;
        }
    };

    /**
     * 실험실 프로퍼티창을 보여준다.
     */
    Laboratory.prototype.show = function () {
        var userId = LabConfigController.getUserId(),
            configInfo = Util.getItemFromLocalStorage("configInfo") || {},
            resistConfigInfo = LabConfigController.getDefaultConfigInfo(),
            labMenuAll = document.getElementsByClassName("lab_menu"),
            labMenuAllLen = labMenuAll.length,
            removeMenu, labMenuName, key, subKey, subConf, labMenu, subMenu, enableBtn, configBtn, i;

        configInfo = configInfo[userId];

        if (!configInfo) {
            configInfo = resistConfigInfo;
        }

        // 등록되지 않은 실험실 모듈 메뉴는 제거한다.
        for (i = 0; i < labMenuAllLen; i++) {
            labMenuName = labMenuAll[i].id.split("_")[1];

            if (!resistConfigInfo[labMenuName]) {
                removeMenu = document.getElementById("lab_" + labMenuName);
                removeMenu.parentNode.removeChild(removeMenu);
                labMenuAllLen -= 1;
            }
        }

        if (labMenuAllLen === 0) {
            if (!this.el.getElementsByClassName("empty_laboratory")[0]) {
                var msgWrapDiv = document.createElement("div"),
                    dialogTlDiv = document.createElement("div"),
                    dialogMsgDiv = document.createElement("div");

                msgWrapDiv.className = "message_wrap empty_laboratory";
                dialogTlDiv.className = "dialog_tl";
                dialogTlDiv.textContent = "등록된 실험실 메뉴가 없습니다.";
                dialogMsgDiv.className = "dialog_message";
                dialogMsgDiv.textContent = "현재 등록된 실험실 메뉴가 존재하지 않습니다.";

                msgWrapDiv.appendChild(dialogTlDiv);
                msgWrapDiv.appendChild(dialogMsgDiv);

                this.el.removeChild(this.el.getElementsByClassName("dialog_tl")[0]);
                this.el.getElementsByClassName("dialog_message")[0].appendChild(msgWrapDiv);
            }
        } else {
            for (key in resistConfigInfo) {
                labMenu = document.getElementById("lab_" + key);

                if (labMenu != null) {
                    enableBtn = labMenu.getElementsByClassName("switchbtn")[0];
                    configBtn = labMenu.getElementsByTagName("input")[0];

                    if (configInfo[key].enabled) {
                        Util.addClass(enableBtn, "switchon");
                        configBtn.setAttribute("disabled", false);
                    } else {
                        Util.removeClass(enableBtn, "switchon");
                        configBtn.setAttribute("disabled", true);
                    }

                    subConf = configInfo[key].subConf;

                    for (subKey in subConf) {
                        subMenu = labMenu.querySelector("input[name=" + subKey +"]");

                        if (subMenu) {
                            subMenu.setAttribute("checked", subConf[subKey]);
                        }
                    }
                }
            }
        }

        _dialogWrap.style.display = "block";
        this.el.style.display = "";
    };

    /**
     * 실험실 이벤트 핸들러를 초기화 한다.
     */
    Laboratory.prototype.initEvtHandler = function () {
        var switchBtnEls, switchBtnElsLen, i;

        this.el = _dialogWrap.getElementsByClassName("layer_labView")[0];
        this.el.style.display = "none";

        switchBtnEls = this.el.querySelectorAll(".switchbtn");
        switchBtnElsLen = switchBtnEls.length;

        this.el.getElementsByClassName("confirm")[0].addEventListener("click", _onClickSummitBtn.bind(this));
        this.el.getElementsByClassName("dialog_close")[0].addEventListener("click", _close.bind(this));

        for (i = 0; i < switchBtnElsLen; i++) {
            switchBtnEls[i].addEventListener("click", _onClickCheckBtn.bind(this));
        }
    };

    /*********************************************
     * Event handler
     **********************************************/

    /**
     * 실험실 설정 프로퍼티 창의 확인 버튼 click 시 해당 설정 값을 설정해주는 처리를 한다.
     * @private
     */
    function _onClickSummitBtn() {
        var configInfo = Util.getItemFromLocalStorage("configInfo") || {},
            userId = LabConfigController.getUserId(),
            labMenu = this.el.getElementsByClassName("lab_menu"),
            labMenuLen = labMenu.length,
            configObj = {},
            obj = {},
            subConf = {},
            i, j, key, labId, labInput, labInputLen, enabled;

        if (labMenuLen > 0) {
            if (!configInfo[userId]) {
                configInfo[userId] = {};
            }

            for (i = 0; i < labMenuLen; i++) {
                labId = labMenu[i].id.split("lab_")[1];
                labInput = labMenu[i].querySelectorAll("ul > input");
                enabled = labMenu[i].getElementsByClassName("switchbtn")[0];

                labInputLen = labInput.length;

                for (j = 0; j < labInputLen; j++) {
                    subConf[labInput[j].getAttribute("name")] = labInput[j].checked;
                }

                obj["enabled"] = Util.hasClass(enabled, "switchon");
                obj["subConf"] = $.extend({}, subConf);
                configObj[labId] = $.extend({}, obj);
                subConf = {};
            }

            for (key in configObj) {
                configInfo[userId][key] = configObj[key];
            }

            Util.setItemToLocalStorage("configInfo", configInfo);

            LabConfigController.exec();
        }

        _close.bind(this)();
    }

    /**
     * 실험실 기능의 활성화 여부(on/off) 버튼 click 시 해당 하위 옵션 메뉴를 enabled/disabled 처리를 한다.
     * @param {Object} e                             : 이벤트 객체
     * @private
     */
    function _onClickCheckBtn(e) {
        var checkbox = e.target.getElementsByClassName("switch_checkbox"),
            labMenu = Util.findParentNode(e.target, ".lab_menu"),
            labInput = labMenu.getElementsByTagName("input")[0];

        if (checkbox) {
            Util.toggleClass(e.target, "switchon");

            if (!Util.hasClass(e.target, "switchon")) {
                labInput.setAttribute("disabled", true);
            } else {
                labInput.setAttribute("disabled", false);
            }
        }
    }

    /*********************************************
     * Private method
     **********************************************/

    /**
     * 싦험실 설정 관련 Dialog를 display none 설정한다.
     * @private
     */
    function _close() {
        _dialogWrap.style.display = "none";
        this.el.style.display = "none";
    }

    return new Laboratory();
});
