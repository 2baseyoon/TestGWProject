var baseUrl = window["BaseUrl"] + "js/";

require["config"]({
    "baseUrl" : baseUrl,
    "paths" : {
        "jquery"          : 'libs/jquery/jquery',
        "jquery_extend"   : 'commonFrame/js/utils/jquery-extend',
        "text"            : 'libs/require/text',
        "i18n"            : 'libs/require/i18n',
        "download"        : 'libs/download/download.min',
        "aes"             : "libs/crypto-js/aes",
        "pbkdf2"          : 'libs/crypto-js/pbkdf2',

        /* Common Library */
        "util"            : 'common/util',
        "errorCode"       : 'common/errorCode',

        /* UI Framework */
        "commonFrameFont"  : 'commonFrame/font',
        "commonFrameCss"  : 'commonFrame/css',
        "commonFrameJs"   : 'commonFrame/js',
        "uiFramework"     : 'commonFrame/js/uiFramework',

        /* Hwp */
        "webhwpapp"       : 'webhwpapp',
        "setup"           : 'webhwpapp/env/setup',
        "polyfill"        : 'webhwpapp/polyfill',
        "webhwpappbase"   : 'webhwpapp/base',
        "hwpview"         : 'webhwpapp/hwpview',
        "frame"           : 'hwpctrlapp/frame',
        "dialog"           : 'hwpctrlapp/frame/Shared/Controller/Module/Dialog',
        "uiView"           : 'hwpctrlapp/frame/Shared/uiView',
        'hwpEventHandler' : 'hwpctrlapp/frame/Shared/hwpEventHandler',
        'uiEventDispatcher' : 'hwpctrlapp/frame/Shared/Framework/uiEventDispatcher',
        'uiEventHandler' : 'hwpctrlapp/frame/uiCtrlEventHandler',
        "imageLoader"     : 'hwpctrlapp/frame/imageLoader',
        "storage"         : 'hwpctrlapp/utils/storage',
        "hwpWebStorage"   : 'webhwpapp/hwp/HwpWebStorage',

        /* default data*/
        "DefaultData"		: 'hwpctrlapp/frame/default',
        "webhwpModule"		: 'webhwp/webhwpModule',
        "notifier"          : 'webhwp/webhwpModule/utils/notifier',
        "accessibility"    : 'webhwp/webhwpModule/Accessibility'
    },

    "shim": {
        "aes"             : { "exports": "CryptoJS" },
        "pbkdf2"          : { "exports": "CryptoJS" }
    }

});

require(['jquery']);
require(['jquery_extend']);
require(['text']);
require(['i18n']);
require(['download']);
require(['util']);
require(['DefaultData']);
require(['commonFrameJs/utils/util']);
require(['commonFrameJs/nls/global']);
require(['commonFrameJs/nls/shortcutMac']);
require(['hwpctrlapp/utils/lang'], function(Lang) {
    if (window.defineLocale !== null) {
        window.defineLocale = Lang();
        if (window.defineLocale) {
            window.defineLocale += "/";
        }
    }

    require(["i18n!commonFrameJs/nls/" + window.defineLocale + "general"], function(res) {
        window.hwp_res = res;
        window["LangDefine"] = res;
        if (window.parent) {
            window.parent["LangDefine"] = res;
        }
    });

    require(["webhwpapp/hwpnls/" + window.defineLocale + "error"], function(res) {
        window.hwp_error_res = res;
    });

    require(["webhwpapp/hwpnls/" + window.defineLocale + "coreEngine"], function(engineRes) {
        window.hwp_engine_res = engineRes;
    });

    require(["webhwpapp/hwpnls/" + window.defineLocale + "hwpGeneral"], function(hwpRes) {
        window.hwp_core_res = hwpRes;
    });
});
