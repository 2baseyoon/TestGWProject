/**
 * Created by hancom on 2018-02-07.
 */
var HwpCtrlApp = {};
var LayoutView = {};
var ImageLoader = {};
var TestApi = {};

var WebHwpCtrlDefine = {
    "editorUIName" : {
        //ID
        "frameID" : "hwpctrl_frame",
    }
};

HwpCtrlApp["Initialize"] = function (id, baseurl, callback) {
    this._initOffice(id, baseurl, callback);
    var contentWindow = document.getElementById(WebHwpCtrlDefine.editorUIName.frameID).contentWindow;
    $(contentWindow).resize(function () {
        $(contentWindow.document.getElementById(WebHwpCtrlDefine.editorUIName.frameID))["ready"](function () {
            HwpCtrlApp.UpdateLayout();
        });
    });
};

HwpCtrlApp["UpdateLayout"] = function () {
    // HwpCtrlApp.layoutView.resize();
    if (HwpCtrlApp.hwpApp != null) {
        HwpCtrlApp.hwpApp.UpdateView();
        HwpCtrlApp.hwpApp.ResizeView();
    }
};

HwpCtrlApp["_initOffice"] = function(id, baseurl, callback) {
    LayoutView.initialize(id, baseurl, callback);
};

//Layout View 생성
LayoutView["initialize"] = function(id, baseurl, callback) {

    var hwpctrlNode = document.getElementById(id);
    var iframe = document.createElement("iframe");
    iframe.setAttribute("id", WebHwpCtrlDefine.editorUIName.frameID);
    iframe.setAttribute("src", "./hwpctrlmain.html");
    iframe.setAttribute("marginwidth", "0");
    iframe.setAttribute("marginheight", "0");
    iframe.setAttribute("hspace", "0");
    iframe.setAttribute("vspace", "0");
    iframe.setAttribute("frameborder", "0");
    iframe.setAttribute("scrolling", "no");
    iframe.setAttribute("style", "width:"+hwpctrlNode.offsetWidth+"px; height:"+hwpctrlNode.offsetHeight+"px;");

    iframe.onload = function() {
    var iFrame = document.getElementById(WebHwpCtrlDefine.editorUIName.frameID);
        var contentWindow = iFrame.contentWindow;
        if (baseurl == null || baseurl =="") {
            baseurl = location.href;
        }
        contentWindow.BaseUrl = getBaseUrl(baseurl);

        contentWindow.callbackFn = function() {
            HwpCtrlApp.hwpApp = contentWindow.HwpApp;
            HwpCtrlApp.hwpCtrlImpl = contentWindow.HwpCtrlImpl;
            HwpCtrlApp.hwpCtrlIntf.Impl = HwpCtrlApp.hwpCtrlImpl;
            callback();
        };

        // contentWindow.document.onclick = function() {
    	// // Iframe 내부와 외부 Foucus가 따로 관리되기 때문에 화면 안쪽 클릭 시 정상적으로 Foucus를 회수하기 위해 넣은 코드
         //    var frameDocument = iFrame.contentDocument || iFrame.contentWindow.document;
        //
         //    // IE에서 다이얼로그 로딩 하였지만 포커스가 빠지는 이슈수정(아래로직 주석처리)
    	// //iframe.focus();
    	// //frameDocument.activeElement.focus();
    // }
    };

    hwpctrlNode.appendChild(iframe);
};
