_alert = window.alert
window.alert = function(msg) {};

define([
    "imageLoader",
    "hwpview/darthVader",
    "hwpview/viewcomponent/viewComponent",
    "hwpview/viewcomponent/CaretView",
    "hwpview/vender/measureText",
    "polyfill/PolyfillLoader",
    'accessibility/AccessibleManager',
    "webhwpapp/Events/FocusManager",
    "webhwpapp/Events/RootEDBuilder",
    "webhwpapp/hwp/CoreEngine/CoreDoc/HWPCTRLINFOINIT",
    "webhwpapp/hwp/CoreEngine/CoreDoc/HwpCtxHelper",
    "webhwpapp/hwp/CoreEngine/CoreDoc/CHwpCaret",
    'webhwpapp/hwp/HwpDef',
    'webhwpapp/hwp/HwpSetID',
    'webhwpapp/hwp/CHwpParameterSet',
    'webhwpapp/hwp/CoreEngine/CoreDoc/HwpEnum',
    "webhwpapp/hwp/CoreEngine/CoreDoc/CHwpDocument",
    "webhwpapp/hwpaction/hwpActionManager",
    "webhwpapp/hwpAppEngineSite",
    "webhwpapp/hwpview/hwpViewSite",
    "webhwpapp/hwp/CoreEngine/HwpClipboard",
    "webhwpapp/hwp/CoreEngine/CoreDoc/CHwpUndOperManager",
    // 'webhwpapp/hwp/HwpWebStorage'

], function (ImageLoader, Presenter, ViewComponent, CaretView,
             MeasureText, PFLoader, AccessibleManager, FocusManager,
             RootEDBuilder, HWPCTRLINFOINIT, HwpCtxHelper, CHwpCaret, HwpDef, HwpSetID, CHwpParameterSet, HwpEnum, CHwpDocument,
             HwpActionManager, HwpEngineSite, HwpViewSite, CHwpClipboard, CHwpUndOperManager) {

    var HwpApp = {};
    var PrevShowState = false; // 내부 Visible 관련
    var PrevFocusState = false; // 외부와 Focus 관련

    HwpApp["Initialize"] = function(envProp, engineRes, hwpRes, CollaborManager) {

        if (envProp == null && _alert != null) {
            _alert("환경설정 정보가 필요합니다. 관리자에게 문의해주시기 바랍니다.");
        }

        if (envProp.SupportCanvas == false && _alert != null) {
            _alert("Canvas가 지원되지 않는 웹브라우저 입니다. 관리자에게 문의해주시기 바랍니다.");
        }

        if (envProp.SupportTextContent == false) {
            PFLoader.LoadTextContent();
        }

        HwpApp.EnvProp = envProp;

        // LINK RESOURCES
        HwpApp.resource = engineRes;

        // 한글전용 리소스
        HwpApp.hwpResource = hwpRes;

        HwpApp.UndOperManager = null;//CHwpUndOperManager; // TODO: 동시편집 시 null 제거 필요 (2019.07.03 홍승아)

        // HwpApp.WebStorage = HwpWebStorage;

        //TODO : Focus Manager를 HwpApp에 붙여야하는지 window에 붙여야하는지 검토 필요
        window.FocusManager = FocusManager;
        window.FocusManager.onchange = function(target, force) {
            if (target == FocusManager.TARGET_TYPE.FOCUS_FRAME) {
                // console.log("######### SET FOCUS_FRAME");
                //console.trace();
                if (HwpApp.CaretView != null) {
                    HwpApp.CaretView.Disabled(true);
                    if (HwpApp.CaretView.IsFocus() || !HwpApp.CaretView.IsEnableIme()) {
                        PrevShowState = HwpApp.CaretView.IsVisibility(); // default
                        if (PrevShowState) {
                            PrevShowState = true; // default
                            HwpApp.CaretView.SetVisibility(false);
                        }
                        HwpApp.CaretView.KillFocus();
                    } else {
                        if (HwpApp.CaretView.IsVisibility()) {
                            HwpApp.CaretView.SetVisibility(false);
                            HwpApp.CaretView.KillFocus();
                        }
                    }
                }
            } else {
                // console.log("######### SET FOCUS_VIEW");
                //console.trace();
                if (HwpApp.CaretView != null) {
                    HwpApp.CaretView.Disabled(false);
                    if (force == true) {
                        HwpApp.CaretView.SetVisibility(true);
                        HwpApp.CaretView.SetFocus();
                    } else {
                        HwpApp.CaretView.SetVisibility(PrevShowState);
                        HwpApp.CaretView.SetFocus();
                    }
                }
            }
        };

        this.LoadCss("./style/webhwpapp.css");

        // requestAnimationFrame .... setTimeout check
        // PFLoader.LoadRequestAnimationFrame();
        // PFLoader.LoadMathHypot();

        HwpApp.base = HwpApp.base || {};

        if (HwpApp.base.MeasureText == null) {
            var mode = envProp.TextMeasureMode == "canvas" ? MeasureText.MODE.CANVAS : MeasureText.MODE.DOM;
            HwpApp.base.MeasureText = (new MeasureText(mode)); //
            // HwpApp.base.MeasureText.Initialize(function() {
            //     console.log("success");
            // }, function() {
            //     console.log("faile");
            // });
        }

        // CREATE DOCUMENT
        HWPCTRLINFOINIT.Initialize(); // initialize HwpCtrl Create function ...
        HwpCtxHelper.Initialize();
        HwpApp.document = new CHwpDocument();// new DOCUMENT
        if (HwpApp.document == null) {
            return false;
        }

        HwpApp.HwpEngineSite = new HwpEngineSite();
        HwpApp.document.SetEngineSite(HwpApp.HwpEngineSite);

        var pMarker = HwpApp.document._CreateMarker(null, HwpDef.HWPMKR_TYPE_SELECTION, null);
        HwpApp.hwpCaret = new CHwpCaret(pMarker);

        // Create Caret View;
        HwpApp.CaretView = new CaretView(HwpApp.hwpCaret);

        // ActionManager
        HwpApp.ActionManager = new HwpActionManager(HwpApp.document);
        HwpApp.document.SetActionManager(HwpApp.ActionManager);
        if (HwpApp.UiEventListener != null) {
            HwpApp.ActionManager.SetUIEventListener(HwpApp.UiEventListener);
        }

        // ViewComponent new or initialize ()
        HwpApp.viewComponent = new ViewComponent(HwpApp.CaretView);

        // LINK PRESENTER
        HwpApp.presenter = new Presenter(this, HwpApp.document, HwpApp.viewComponent, HwpApp.CaretView, HwpApp.ActionManager);

        // Clipboard
        // HwpApp.clipboard = new CHwpClipboard(HwpApp.document, HwpApp.EnvProp.BrowserInfo, HwpApp);

        // State - 어플리케이션 글로벌 상태 정보(HWPSETID_APP_STATE)
        HwpApp.appState = CHwpParameterSet.HwpCreateParameterSet(HwpSetID.HWPSETID_APP_STATE);

        HwpApp.HwpViewSite = new HwpViewSite(/*HwpApp.document, */HwpApp.viewComponent, HwpApp.CaretView);

        if (pMarker._GetMarkerType() != HwpDef.HWPMKR_TYPE_CONTENTS)
            pMarker._SetViewSite(HwpApp.HwpViewSite); // _SetViewSite()는  웹한글/웹한글기안기 전용...

        // Attach Root Event Dispatcher
        var Builder = new RootEDBuilder();

        HwpApp.RootEventDispatcher = Builder.Build(FocusManager, null);
        // HwpApp.RootEventDispatcher.SetShortCutDispatcher(HwpApp.presenter.GetShortCutEventDispatcher());
        // HwpApp.RootEventDispatcher.SetImeDispatcher(HwpApp.CaretView.GetEventDispatcher());
        // HwpApp.RootEventDispatcher.SetViewDispatcher(HwpApp.presenter.GetEventDispatcher());
        // HwpApp.RootEventDispatcher.SetClipBoardDispatcher(HwpApp.clipboard.GetEventDispatcher());
        HwpApp.RootEventDispatcher.AttachEventDispatcher(window);

        // 웹브라우저 자체 / IFRAME 의 FOCUS와 BLUR 이벤트를 이용해서 커서 처리
        var InitEventLister = function(documentElm) {
            documentElm.onfocus = function(e) {
                // console.log("#### documentElm.onfocus prev focus statue : " + PrevFocusState);
                if (PrevFocusState) {
                    window.FocusManager.SetFocusTarget(FocusManager.TARGET_TYPE.FOCUS_VIEW)
                }
                PrevFocusState = true;
            };
            documentElm.onblur = function(e) {
                // console.log("#### documentElm.onblur : " + HwpApp.CaretView.IsFocus());
                if (HwpApp.CaretView.IsFocus()) {
                    PrevFocusState = true;
                    window.FocusManager.SetFocusTarget(FocusManager.TARGET_TYPE.FOCUS_FRAME)
                } else {
                    PrevFocusState = false;
                }
            };
        };
        InitEventLister(window);

        // pMarker.SetViewUpdateListener(HwpApp.presenter.GetUpdateListener());
        pMarker.SetViewCommandHandler(HwpApp.presenter.GetCommandHandler());
        pMarker.SetViewNotifyHandler(HwpApp.presenter.GetNotifyListener());

        this.m_CollaborManager = CollaborManager;
        if (this.m_CollaborManager) {
            HwpApp.document.SetCollaborManager(this.m_CollaborManager);
            HwpApp.document.SetCollaborListener(this.m_CollaborManager.GetCollaborListener());
        }
    };

    HwpApp.Blur = function() {
        window.FocusManager.SetFocusTarget(FocusManager.TARGET_TYPE.FOCUS_FRAME);
        HwpApp.CaretView.Disabled(true);
    };

    HwpApp.Focus = function() {
        if (Presenter.ISPAUSE()) {
            return;
        }

        if (TargetDOM != null && TargetDOM.focus) {
            TargetDOM.focus();
        }

        HwpApp.CaretView.Disabled(false);
        window.FocusManager.SetFocusTarget(FocusManager.TARGET_TYPE.FOCUS_VIEW);
    };

    HwpApp.LoadCss = function(url) {
        var link = document.createElement("link");
        link.type = "text/css";
        link.type = "stylesheet";
        link.href = url;
        document.getElementsByTagName("head")[0].appendChild(link);
    };

    HwpApp.GetFaceItems = function(lang, array) {
        return HwpApp.document.GetFaceItems(lang, array);
    };

    HwpApp["SetUIEventListener"] = function(uiEventListener) {
        HwpApp.UiEventListener = uiEventListener;
        if (HwpApp.ActionManager != null) {
            HwpApp.ActionManager.SetUIEventListener(uiEventListener);
        }
    };

    HwpApp.SetUndOperManagerHelper = function (helper) {
        if (HwpApp.UndOperManager) {
            HwpApp.UndOperManager.SetHelper(helper);
        }
        HwpApp.document.SetUndOperManager(HwpApp.UndOperManager);
    };

    HwpApp.RESUME = function() {
         // 최초 로딩 시
         // 렌더링이 다시 일어나도록 처리
         var oldModified = window.HwpApp.document.IsModified();
         Presenter.RESUME(HwpApp.document);
         if (HwpApp.NOT_EMPTY_READY_QUEUE()) {
             HwpApp.READY_QUEUE_FLUSH();
         }
         window.HwpApp.document.SetModifiedFlag(oldModified);
    };

    HwpApp.ISPAUSE = function() {
        return Presenter.ISPAUSE();
    };

    HwpApp.InitView = function (targetDom) {
        // TargetDOM = targetDom;
        // _CreateHwpView(targetDom);
        // var elementData = _UpdateHwpView();
        // HwpApp.viewComponent.Init(eventListener, elementData.divLeft, elementData.divTop,
        //     elementData.divWidth, elementData.divHeight, elementData.paperCanvas, elementData.editCanvas);
        //
        // // 웹접근성을 위한 함수(CHwpDocument에 멤버변수에 추가)
        // HwpApp.InitAccessbility();
        //
        // HwpApp.clipboard.setTargetDom(TargetDOM);
    };

    HwpApp.UpdateView = function () {
        // if (Presenter.ISPAUSE()) {
        //     return;
        // }
        // var elementData = _UpdateHwpView();
        // HwpApp.viewComponent.UpdateView(elementData.divLeft, elementData.divTop,
        //     elementData.divWidth, elementData.divHeight);
    };

    var ResizeViewTimeoutHandle = null;
    HwpApp.ResizeView = function () {
        // if (Presenter.ISPAUSE()) {
        //     return;
        // }
        //
        // if (ResizeViewTimeoutHandle != null) {
        //     window.clearTimeout(ResizeViewTimeoutHandle);
        //     ResizeViewTimeoutHandle = setTimeout(function () {
        //         var elementData = _UpdateHwpView();
        //         HwpApp.viewComponent.ResizeView(elementData.divLeft, elementData.divTop,
        //             elementData.divWidth, elementData.divHeight,
        //             elementData.paperCanvas, elementData.editCanvas);
        //         ResizeViewTimeoutHandle = null;
        //     }.bind(this), 200);
        // } else {
        //     ResizeViewTimeoutHandle = setTimeout(function () {
        //         var elementData = _UpdateHwpView();
        //         HwpApp.viewComponent.ResizeView(elementData.divLeft, elementData.divTop,
        //             elementData.divWidth, elementData.divHeight,
        //             elementData.paperCanvas, elementData.editCanvas);
        //         ResizeViewTimeoutHandle = null;
        //     }.bind(this), 50);
        // }
    };

    HwpApp.ResetDocument = function() {
        // TODO : 절대로 함부로 쓰지 마세요. (임시방편입니다.)
        HwpApp.document = new CHwpDocument();// new DOCUMENT
        if (HwpApp.document == null) {
            return false;
        }
        HwpApp.document.SetEngineSite(HwpApp.HwpEngineSite);
        var pMarker = HwpApp.document._CreateMarker(null, HwpDef.HWPMKR_TYPE_SELECTION, null);
        pMarker.SetViewUpdateListener(HwpApp.presenter.GetUpdateListener());
        pMarker.SetViewCommandHandler(HwpApp.presenter.GetCommandHandler());
        pMarker.SetViewNotifyHandler(HwpApp.presenter.GetNotifyListener());
        HwpApp.hwpCaret.SetMarker(pMarker);
        if (pMarker._GetMarkerType() != HwpDef.HWPMKR_TYPE_CONTENTS && HwpApp.HwpViewSite != null)
            pMarker._SetViewSite(HwpApp.HwpViewSite); // _SetViewSite()는  웹한글/웹한글기안기 전용...
        HwpApp.ActionManager.SetDocument(HwpApp.document);
        HwpApp.ActionManager.NotifyDialogParam();
        HwpApp.document.SetActionManager(HwpApp.ActionManager);

        // LINK PRESENTER
        HwpApp.presenter.SetDocument(HwpApp.document);
        // HwpApp.clipboard.SetDocument(HwpApp.document);

        if (this.m_CollaborManager) {
            HwpApp.document.SetCollaborManager(this.m_CollaborManager);
            HwpApp.document.SetCollaborListener(this.m_CollaborManager.GetCollaborListener());
        }

        if (HwpApp.UndOperManager != null) {
            HwpApp.UndOperManager.FreeHistory(HwpEnum.UndoType, -1);
            HwpApp.document.SetUndOperManager(HwpApp.UndOperManager);
        }

        // 웹접근성을 위한 함수(CHwpDocument에 멤버변수에 추가)
        HwpApp.InitAccessbility();

        return true;
    };

    HwpApp.FlushData = function() {
        // ImageLoader.FlushData();
        HwpApp.presenter.SetFlushFlag(true);
        HwpApp.document.DeleteContents();
        // HwpApp.presenter.FlushData();
        HwpApp.presenter.SetFlushFlag(false);
        HwpApp.ResetDocument();
    };

    HwpApp.LoadBinData = function(bindata, callback) {
        // ImageLoader.LoadBinImage(this, bindata, callback);
    };

    HwpApp.CloseDialog = function() {
        if(HwpApp.UiEventListener)
            HwpApp.UiEventListener.uiCloseDialogAction();
    };

    //////////////////////////////////////////////////////////////////////////////////
    // TODO : Event Dispatcher와 분리하고 어떻게 처리할지 고민해주세요~
    HwpApp.InitEventListener = function () {
        // var hcwoViewScroll = document.getElementById("hcwoViewScroll");
        // if(hcwoViewScroll) {
        //     hcwoViewScroll.addEventListener("scroll", function(e) {
        //         HwpApp.viewComponent.SetEvent(e, "SCROLL_EVENT");
        //         if(e.preventDefault) {
        //             e.preventDefault();
        //         } else {
        //             e.returnValue = false;
        //         }
        //         return false;
        //     });
        // }
    };

    HwpApp.GetPropertiesData = function () {
        // TODO : marker 제어는 좀더 밑으로 내려가야 된다.
        var pmarker = HwpApp.document.GetPrimaryMarker();

        var contextID = HwpApp.document._GetPager().GetContextID();
        contextID = contextID != null ? contextID : 1;

        var charShape = pmarker.GetCharShapeHandler().GetProperties();
        var paraShape = pmarker.GetParaShapeHandler().GetProperties();

        var layout = {};
        pmarker.GetRange().GetTextPosInfo().GetLayoutInfo(layout);
        return {
            marker : pmarker,
            contextID : contextID,
            charShape : charShape,
            paraShape : paraShape,
            layout : layout
        }
    };

    var eventListener = {
        UpdateScrollData : function(elementWidth, elementHeight, offsetX, offsetY) {
            HwpApp.SetScrollElementData(elementWidth, elementHeight, offsetX, offsetY);
            var viewListener = window.HwpApp.UIListener && window.HwpApp.UIListener.GetFrameListener();
            if (viewListener && viewListener.ViewEvent != null) {
                viewListener.ViewEvent("");
            }
        },
        UpdateZoomWidget : function (value, option) {
            var viewListener = window.HwpApp.UIListener && window.HwpApp.UIListener.GetFrameListener();
            if (viewListener && viewListener.ViewEvent != null) {
                viewListener.ViewEvent("zoom", value, option);
            }
        },
        UpdateUIEvent : function () {
            var viewListener = window.HwpApp.UIListener && window.HwpApp.UIListener.GetFrameListener();
            if (viewListener && viewListener.ViewEvent != null) {
                viewListener.ViewEvent("ui", null);
            }
        }
    };

    ////////////////////////////////////////////////////////////////////
    // webhwpctrl 요청 함수 /------------------------
    ////////////////////////////////////////////////////////////////////

    var webhwpctrlFlag = {
        verticalScrollShow : true,
        verticalScrollValue : 1,
        horizontalScrollShow : true,
        horizontalScrollValue : 1
    };

    HwpApp.READY_QUEUE = [];

    HwpApp.NOT_EMPTY_READY_QUEUE = function() {
        return HwpApp.READY_QUEUE.length > 0;
    };

    HwpApp.READY_QUEUE_FLUSH = function() {
        var queueLen = HwpApp.READY_QUEUE.length;
        for (var i = 0; i < queueLen; i++) {
            HwpApp.READY_QUEUE[i].func(HwpApp.READY_QUEUE[i].arg);
        }
        HwpApp.READY_QUEUE = [];
    };

    HwpApp.CtrlAPI_ShowVerticalScroll = function (isShow) {
        // if (Presenter.ISPAUSE()) {
        //     HwpApp.READY_QUEUE.push({func:HwpApp.CtrlAPI_ShowVerticalScroll, arg: isShow});
        // } else {
        //     var hcwoViewScrollVertical = document.getElementById("hcwoViewScrollVertical");
        //     if (isShow === false) {
        //         hcwoViewScrollVertical.style.height = 1 + "px";
        //         webhwpctrlFlag.verticalScrollShow = false;
        //     } else {
        //         hcwoViewScrollVertical.style.height = webhwpctrlFlag.verticalScrollValue + "px";
        //         webhwpctrlFlag.verticalScrollShow = true;
        //     }
        // }
    };

    HwpApp.CtrlAPI_ShowHorizontalScroll = function (isShow) {
        // if (Presenter.ISPAUSE()) {
        //     HwpApp.READY_QUEUE.push({func:HwpApp.CtrlAPI_ShowHorizontalScroll, arg: isShow});
        // } else {
        //     var hcwoViewScrollHorizontal = document.getElementById("hcwoViewScrollHorizontal");
        //     if (isShow === false) {
        //         hcwoViewScrollHorizontal.style.width = 1 + "px";
        //         webhwpctrlFlag.horizontalScrollShow = false;
        //     } else {
        //         hcwoViewScrollHorizontal.style.width = webhwpctrlFlag.horizontalScrollValue + "px";
        //         webhwpctrlFlag.horizontalScrollShow = true;
        //     }
        // }
    };

    HwpApp.CtrlAPI_ShowLoadingBar = function (isShow) {
        if (Presenter.ISPAUSE()) {
            HwpApp.READY_QUEUE.push({func:HwpApp.CtrlAPI_ShowLoadingBar, arg: isShow});
        } else {
            // FullDown 메뉴바
            if (HwpApp.UiEventListener && HwpApp.UiEventListener.updateWebHwpCtrlEvtAction) {
                HwpApp.UiEventListener.updateWebHwpCtrlEvtAction("LoadingBar", isShow);
            }
        }
    };

    HwpApp.CtrlAPI_ShowMenuBar = function (isShow) {
        if (Presenter.ISPAUSE()) {
            HwpApp.READY_QUEUE.push({func:HwpApp.CtrlAPI_ShowMenuBar, arg: isShow});
        } else {
            // FullDown 메뉴바
            if (HwpApp.UiEventListener && HwpApp.UiEventListener.updateWebHwpCtrlEvtAction) {
                HwpApp.UiEventListener.updateWebHwpCtrlEvtAction("MenuBar", isShow);
            }
        }
    };

    HwpApp.CtrlAPI_ShowToolBar = function (isShow) {
        if (Presenter.ISPAUSE()) {
            HwpApp.READY_QUEUE.push({func:HwpApp.CtrlAPI_ShowToolBar, arg: isShow});
        } else {
            // 서식바
            if (HwpApp.UiEventListener && HwpApp.UiEventListener.updateWebHwpCtrlEvtAction) {
                HwpApp.UiEventListener.updateWebHwpCtrlEvtAction("StyleBar", isShow);
            }
        }
    };

    HwpApp.CtrlAPI_ShowRibbon = function (isShow) {
        if (Presenter.ISPAUSE()) {
            HwpApp.READY_QUEUE.push({func:HwpApp.CtrlAPI_ShowRibbon, arg: isShow});
        } else {
            // 메뉴 툴바
            if (HwpApp.UiEventListener && HwpApp.UiEventListener.updateWebHwpCtrlEvtAction) {
                HwpApp.UiEventListener.updateWebHwpCtrlEvtAction("ToolBar", isShow);
            }
        }
    };

    HwpApp.CtrlAPI_FoldRibbon = function (isFold) {
        if (Presenter.ISPAUSE()) {
            HwpApp.READY_QUEUE.push({func:HwpApp.CtrlAPI_FoldRibbon, arg: isFold});
        } else {
            // 메뉴 툴바
            if (HwpApp.UiEventListener && HwpApp.UiEventListener.updateWebHwpCtrlEvtAction) {
                HwpApp.UiEventListener.updateWebHwpCtrlEvtAction("ToolBarFold", isFold);
            }
        }
    };

    HwpApp.CtrlAPI_ShowStatusBar = function (isShow) {
        if (Presenter.ISPAUSE()) {
            HwpApp.READY_QUEUE.push({func:HwpApp.CtrlAPI_ShowStatusBar, arg: isShow});
        } else {
            // 하단 상태바
            if (HwpApp.UiEventListener && HwpApp.UiEventListener.updateWebHwpCtrlEvtAction) {
                HwpApp.UiEventListener.updateWebHwpCtrlEvtAction("StatusBar", isShow);
            }
        }
    };

    HwpApp.CtrlAPI_ShowCaret = function (isShow) {
        // if (Presenter.ISPAUSE()) {
        //     HwpApp.READY_QUEUE.push({func:HwpApp.CtrlAPI_ShowCaret, arg: isShow});
        // } else {
        //     HwpApp.viewComponent.CtrlAPI_ShowCaret(isShow);
        // }
    };

    HwpApp.CtrlAPI_ShowPageTooltip = function (isShow) {
        if (Presenter.ISPAUSE()) {

        } else {
            // TODO :Tooltip 추가 되면 구현
        }
    };

    HwpApp.CtrlAPI_InsertMenu = function () {
        if (Presenter.ISPAUSE()) {

        } else {
            // TODO : CustomUI 작업 후 구현
        }
    };

    HwpApp.CtrlAPI_AppendMenu = function () {
        if (Presenter.ISPAUSE()) {

        } else {
            // TODO : CustomUI 작업 후 구현
        }
    };

    HwpApp.CtrlAPI_RemoveMenu = function () {
        if (Presenter.ISPAUSE()) {

        } else {
            // TODO : CustomUI 작업 후 구현
        }
    };

    HwpApp.CtrlAPI_SetToolBar = function () {
        if (Presenter.ISPAUSE()) {

        } else {
            // TODO : CustomUI 작업 후 구현
        }
    };

    HwpApp.CtrlAPI_OnClipboardFontCheck = function (callback) {
        // var _callback = callback;
        // HwpApp.clipboard.CtrlAPI_OnClipboardFontCheck(function (result) {
        //     if (typeof _callback === 'function') {
        //         _callback(result);
        //     }
        // });
    };

    HwpApp.CtrlAPI_OnMouseLButtonDown = function (callback) {
        // var _callback = callback;
        // HwpApp.presenter.CtrlAPI_OnMouseLButtonDown(function (x, y) {
        //     if (typeof _callback === 'function') {
        //         _callback(x, y);
        //     }
        // });
    };

    HwpApp.CtrlAPI_OnMouseLButtonUp = function (callback) {
        // var _callback = callback;
        // HwpApp.presenter.CtrlAPI_OnMouseLButtonUp(function (x, y) {
        //     if (typeof _callback === 'function') {
        //         _callback(x, y);
        //     }
        // });
    };

    HwpApp.CtrlAPI_OnScroll = function (callback) {
        // var _callback = callback;
        // HwpApp.viewComponent.CtrlAPI_OnScroll(function () {
        //     if (typeof _callback === 'function') {
        //         _callback();
        //     }
        // });
    };

    HwpApp.CtrlAPI_NotifyMessage = function (callback) {
        // // TODO : ActionManager 말고 더 좋은 곳이 있을까?
        // var _callback = callback;
        // HwpApp.ActionManager.CtrlAPI_NotifyMessage(function (Msg, WParam, LParam) {
        //     if (typeof _callback === 'function') {
        //         _callback(Msg, WParam, LParam);
        //     }
        // });
    };

    ////////////////////////////////////////////////////////////////////
    // webhwpctrl 요청 함수 ------------------------------/
    ////////////////////////////////////////////////////////////////////

    var TargetDOM;
    var SCROLL_SIZE = 16;

    // TODO : Create 와 PageInfo 분리할 필요 있음 (의견 : 김다현)
    var _CreateHwpView = function (targetDom) {
        // TargetDOM = targetDom;
        // TargetDOM.style.overflow = "hidden";
        //
        // if (HwpApp.presenter) {
        //     HwpApp.presenter.makeDraggable(TargetDOM);
        // }
        //
        // TargetDOM.addEventListener("click", function(e) {
        //     // ##
        //     FocusManager.SetFocusTarget(FocusManager.TARGET_TYPE.FOCUS_VIEW);
        //     HwpApp.CaretView.SetFocus();
        //     // ##
        // });
        //
        // var divWidth = TargetDOM.clientWidth;
        // var divHeight = TargetDOM.clientHeight;
        //
        // var hcwoViewScrollHorizontal, hcwoViewScrollVertical, editCanvas;
        // var paperCanvas = document.getElementById("PaperCanvas") || null;
        // if (!paperCanvas) {
        //     paperCanvas = document.createElement('canvas');
        //     paperCanvas.id = "PaperCanvas";
        //     paperCanvas.width = divWidth - SCROLL_SIZE;
        //     paperCanvas.height = divHeight;
        //     paperCanvas.style.position = "fixed";
        //     paperCanvas.style.left = targetDom.style.left;
        //     paperCanvas.style.top = targetDom.style.top;
        //     TargetDOM.appendChild(paperCanvas);
        //
        //     editCanvas = document.createElement('canvas');
        //     editCanvas.id = "EditCanvas";
        //     editCanvas.width = divWidth - SCROLL_SIZE;
        //     editCanvas.height = divHeight;
        //     editCanvas.style.position = "fixed";
        //     editCanvas.style.left = targetDom.style.left;
        //     editCanvas.style.top = targetDom.style.top;
        //     TargetDOM.appendChild(editCanvas);
        //
        //     hcwoViewScroll = document.createElement("div");
        //     hcwoViewScroll.setAttribute("id", "hcwoViewScroll");
        //     hcwoViewScroll.style.position = "fixed";
        //     hcwoViewScroll.style.overflow = "auto";
        //     TargetDOM.appendChild(hcwoViewScroll);
        //
        //     hcwoViewScrollHorizontal = document.createElement("div");
        //     hcwoViewScrollHorizontal.setAttribute("id", "hcwoViewScrollHorizontal");
        //     hcwoViewScrollHorizontal.style.position = "absolute";
        //     hcwoViewScrollHorizontal.style.height = 1 + "px";
        //     hcwoViewScroll.appendChild(hcwoViewScrollHorizontal);
        //
        //     hcwoViewScrollVertical   = document.createElement("div");
        //     hcwoViewScrollVertical.setAttribute("id", "hcwoViewScrollVertical");
        //     hcwoViewScrollVertical.style.position = "absolute";
        //     hcwoViewScrollVertical.style.width = 1 + "px";
        //     hcwoViewScroll.appendChild(hcwoViewScrollVertical);
        //
        //     TargetDOM.appendChild(HwpApp.CaretView.GetElement());
        //
        //     // ##
        //     FocusManager.SetFocusTarget(FocusManager.TARGET_TYPE.FOCUS_VIEW);
        //     HwpApp.CaretView.SetFocus();
        //     // ##
        //
        //     HwpApp.CaretView.SetPositionPX(0, 0);
        //     HwpApp.CaretView.SetHeightHwpUnit(1000);
        // }
        //
        // var hcwoViewScroll = document.getElementById("hcwoViewScroll");
        // if (hcwoViewScroll) {
        //     hcwoViewScroll.style.width = divWidth + "px";
        //     hcwoViewScroll.style.height = divHeight + "px";
        // }
    };

    var _UpdateHwpView = function() {
        // var divWidth = TargetDOM.clientWidth;
        // var divHeight = TargetDOM.clientHeight;
        //
        // if (HwpApp.presenter) {
        //     HwpApp.presenter.makeDraggable(TargetDOM);
        // }
        //
        // var hScrollSize = 0;
        // var hcwoViewScrollHorizontal = document.getElementById("hcwoViewScrollHorizontal");
        // if (hcwoViewScrollHorizontal && divWidth < hcwoViewScrollHorizontal.clientWidth) {
        //     hScrollSize = SCROLL_SIZE;
        // }
        //
        // var paperCanvas = document.getElementById("PaperCanvas");
        // if (paperCanvas) {
        //     if (paperCanvas.width != (divWidth - SCROLL_SIZE)) {
        //         paperCanvas.width = divWidth - SCROLL_SIZE;
        //     }
        //     if (paperCanvas.height != (divHeight - hScrollSize)) {
        //         paperCanvas.height = divHeight - hScrollSize;
        //     }
        // }
        //
        // var editCanvas = document.getElementById("EditCanvas");
        // if (editCanvas) {
        //     if (editCanvas.width != (divWidth - SCROLL_SIZE)) {
        //         editCanvas.width = divWidth - SCROLL_SIZE;
        //     }
        //     if (editCanvas.height != (divHeight - hScrollSize)) {
        //         editCanvas.height = divHeight - hScrollSize;
        //     }
        // }
        //
        // var hcwoViewScroll = document.getElementById("hcwoViewScroll");
        // if (hcwoViewScroll) {
        //     hcwoViewScroll.style.width = divWidth + "px";
        //     hcwoViewScroll.style.height = divHeight + "px";
        // }
        //
        // return {
        //     divLeft : TargetDOM.getBoundingClientRect().left,
        //     divTop : TargetDOM.getBoundingClientRect().top,
        //     divWidth : divWidth - SCROLL_SIZE,
        //     divHeight : divHeight - hScrollSize,
        //     paperCanvas : paperCanvas,
        //     editCanvas : editCanvas
        // };
    };

    HwpApp["SetScrollElementData"] = function (elementWidth, elementHeight, offsetX, offsetY, isEdgeScroll) {
        // if (elementHeight > -1) {
        //     if (webhwpctrlFlag.verticalScrollShow) {
        //         var hcwoViewScrollVertical = document.getElementById("hcwoViewScrollVertical");
        //         if (hcwoViewScrollVertical && hcwoViewScrollVertical.style.height !== elementHeight + "px") {
        //             hcwoViewScrollVertical.style.height = elementHeight + "px";
        //         }
        //     }
        //     webhwpctrlFlag.verticalScrollValue = elementHeight;
        // }
        // if (elementWidth > -1) {
        //     if (webhwpctrlFlag.horizontalScrollShow) {
        //         var hcwoViewScrollHorizontal = document.getElementById("hcwoViewScrollHorizontal");
        //         if (hcwoViewScrollHorizontal && hcwoViewScrollHorizontal.style.width !== elementWidth + "px") {
        //             hcwoViewScrollHorizontal.style.width = elementWidth + "px";
        //         }
        //
        //         if (TargetDOM.clientWidth < elementWidth) {
        //             var paperCanvas = document.getElementById("PaperCanvas");
        //             if (paperCanvas && paperCanvas.height == TargetDOM.clientHeight && paperCanvas.height > 0) {
        //                 HwpApp.UpdateView();
        //             }
        //         }
        //     }
        //     webhwpctrlFlag.horizontalScrollValue = elementWidth;
        // }
        //
        // var hcwoViewScroll = document.getElementById("hcwoViewScroll");
        // if(hcwoViewScroll) {
        //     if (isEdgeScroll) {
        //         hcwoViewScroll.scrollLeft += offsetX;
        //     } else {
        //         if (hcwoViewScroll.scrollLeft !== offsetX) {
        //             hcwoViewScroll.scrollLeft = offsetX;
        //         }
        //     }
        //     if (isEdgeScroll) {
        //         hcwoViewScroll.scrollTop += offsetY;
        //     } else {
        //         if (hcwoViewScroll.scrollTop !== offsetY) {
        //             hcwoViewScroll.scrollTop = offsetY;
        //         }
        //     }
        // }
    };

    HwpApp.DoCompositionEnd = function(){
        // HwpApp.CaretView.DoCompositionEnd();
    };

    HwpApp.InitAccessbility = function() {
        var accessbleManager = new AccessibleManager();
        accessbleManager.Init("webhwp");
        HwpApp.document.SetAccessibility(accessbleManager);
    };

    HwpApp.GetActionManager = function(isCoreAction) {
        return isCoreAction === true ? HwpApp.CoreActionManager : HwpApp.ActionManager;
    };

    HwpApp.SetCoreActionManager = function(actionManager) {
        HwpApp.CoreActionManager = actionManager;
    };

    HwpApp.SetEditLock = function(lock) {
        window.HwpApp.Status.setLoadingStatus(!lock);

        var pmarker = HwpApp.document.GetPrimaryMarker();
        pmarker.SetImeLock(lock);
    };

    HwpApp.IsImeLock = function() {
        var pmarker = HwpApp.document.GetPrimaryMarker();
        return pmarker.IsImeLock();
    };

    return HwpApp;
});
