define([
    'jquery',
    'util',
    'commonFrameJs/uiFramework/uiController',
    'commonFrameJs/uiFramework/uiDefine'
], function ($, Util, UiController, UiDefine) {
    "use strict";

    var FrameBuilder = {};

    FrameBuilder["NONE"] = 0;
    FrameBuilder["CONVERTING"] = 1;
    FrameBuilder["DONE"] = 2;

    FrameBuilder["DomHandler"] = null;
    FrameBuilder["LoadStatus"] = FrameBuilder["NONE"];

    FrameBuilder.build = function(contentWindow, callback) {
        var baseurl;
        if (FrameBuilder.LoadStatus == FrameBuilder["NONE"]) {
            baseurl = window["BaseUrl"];
            if (baseurl == null || baseurl == "") {
                baseurl = Util["getBaseUrl"](location.href);
            }
            UiController["bindCallbackAfterConverting"](callback);
            var base = baseurl + "js/";
            UiController["setLazyConvertMode"](1000);
            FrameBuilder.DomHandler = UiController["convertXmlToDom"]("webhwpctrl", contentWindow, base, UiDefine["FONT_DETECT_MODE"]["GLOBAL_EXTEND"]);
            FrameBuilder.LoadStatus = FrameBuilder["DONE"];
        } else {
            if (callback) {
                callback();
            }
        }
    };

    // HwpEventHandler = require("frame/hwpCtrlEventHandler"),
    // DialogManager = require("frame/Dialog/DialogManager"),
    // FocusManager = require('webhwpapp/Events/FocusManager');
    FrameBuilder.bindEvent = function(contentWindow, hwpApp, hwpEventHandler, uiEventDispatcher, uiEventHandler) {
        uiEventDispatcher.initialize();
        this.setUIEvent(contentWindow.document, FrameBuilder.DomHandler["refTree"], null, uiEventHandler);
        /****** resize Event ******/
        // $window.on("resize", $.proxy(UiEventHandler.doResizeEvent, UiEventHandler));
    };

    FrameBuilder.setUIEvent = function(documentEl, refTree, id, uiEventHandler) {
        // 이 부분은 UI 에 대한 Event 를 거는 곳입니다.
        // event 를 걸때, callback 은 uiEventHandler 의 method 를 이용하면 됩니다.
        var _document = $(documentEl),
            documentContainerView = refTree[UiDefine["DOCUMENT_MENU_ID"]];

        var documentContainer = _document["find"]("#" + UiDefine["DOCUMENT_MENU_ID"]);
        var _titleBar = _document["find"]("#" + UiDefine["TITLE_BAR_ID"]);
        var _modalDialog = _document["find"]("#" + UiDefine["MODAL_DIALOG_ID"]);
        var _modelessDialog = _document["find"]("#" + UiDefine["MODELESS_DIALOG_ID"]);
        var _styleBar = _document["find"]("#" + UiDefine["STYLEBAR_ID"]);
        var _contextMenu = _document["find"]("#" + UiDefine["CONTEXT_MENU_ID"]);

        uiEventHandler.initialize();
        _document["mousedown"]($["proxy"](uiEventHandler["doMouseDownEvent"], uiEventHandler));
        _document["click"]($["proxy"](uiEventHandler["doMouseClickEvent"], uiEventHandler));

        if (documentContainerView) {
            /****** Mouse Event ******/
            _document["on"]("selectstart", $["proxy"](uiEventHandler["doSelectStartEvent"], uiEventHandler));
            _document["mousemove"]($["proxy"](uiEventHandler["doMouseMoveEvent"], uiEventHandler));
            _document["mouseup"]($["proxy"](uiEventHandler["doMouseUpEvent"], uiEventHandler));
            $(documentContainerView["ref"])["mouseup"]($["proxy"](uiEventHandler["doMouseUpEvent"], uiEventHandler));
            _document["contextmenu"]($["proxy"](uiEventHandler["doContextMenuEvent"], uiEventHandler));
            $(documentContainerView["ref"])["dblclick"]($["proxy"](uiEventHandler["doDblClickEvent"], uiEventHandler));
            _document["mouseover"]($["proxy"](uiEventHandler["doMouseOverDocumentEvent"], uiEventHandler));
            _contextMenu["mouseover"]($["proxy"](uiEventHandler["doMouseOverEvent"], uiEventHandler));
            _titleBar["mouseover"]($["proxy"](uiEventHandler["doMouseOverEvent"], uiEventHandler));

            /***** Wheel Event ******/
            documentContainer["on"]("wheel",$["proxy"](uiEventHandler["doDocumentWheelEventDispatcher"], uiEventHandler));

            /****** Key Event ******/
            _document["keydown"]($["proxy"](uiEventHandler["doKeyDownEvent"], uiEventHandler));
            _modalDialog["on"]("keyup", "input, textarea", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));
            _modalDialog["on"]("input", "input, textarea", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));
            _modalDialog["on"]("compositionend", "input, textarea", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));

            _modelessDialog["on"]("keyup", "input", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));
            _modelessDialog["on"]("input", "input", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));
            _modelessDialog["on"]("compositionend", "input", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));

            _styleBar["on"]("keyup", "input", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));
            _styleBar["on"]("input", "input", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));
            _styleBar["on"]("compositionend", "input", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));

            /****** focus Event ******/
            _modalDialog["on"]("change", "input, textarea", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));
            _modalDialog["on"]("blur", "input, textarea", $["proxy"](uiEventHandler["doInputBlurEvent"], uiEventHandler));

            _modelessDialog["on"]("change", "input", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));
            _modelessDialog["on"]("blur", "input", $["proxy"](uiEventHandler["doInputBlurEvent"], uiEventHandler));

            _styleBar["on"]("change", "input", $["proxy"](uiEventHandler["inputEventDispatcher"], uiEventHandler));
            _styleBar["on"]("blur", "input", $["proxy"](uiEventHandler["doInputBlurEvent"], uiEventHandler));

            _document["on"]("focus", '.' + UiDefine["INPUT_BOX_WRAP_CLASS"] + " > input," + '.' + UiDefine["LOCAL_FILE_WRAP_CLASS"] + " input," +
                "textarea" + '.' + UiDefine["TEXTAREA_BOX_CLASS"],
                $["proxy"](uiEventHandler["doInputFocusEvent"], uiEventHandler));

            /****** resize Event ******/
            $(window)["resize"]($["proxy"](uiEventHandler["doResizeEvent"], uiEventHandler));
        }
    };

    return FrameBuilder;
});
