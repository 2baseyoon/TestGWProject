define(function(require){
    "use strict";

    /*******************************************************************************
     * Import
     ******************************************************************************/
    var CommonFrameUtil = require("commonFrameJs/utils/util");

    return function(){
        /*
         #### 임시코드 (2013.04.22 - han1228@hancom.com) ####
         - URL 파라메타 또는 API등을 통한 수동 언어셋 변경시 그에 맞게 코드를 재작성 해야함.
         - 현재는 URL 파라메타 lang으로 수동 변경 한다는 가정으로 다국어 수동 변경이 가능하도록 임시코드를 작성한 상태임.
         - 이클립스에서 깨지는 문제 해결중...
         */

        var defaultCode = "ko",// CommonDefine.langCode,
            urls = CommonFrameUtil["parseURL"](window.parent.location.href),
            locale = "";

        if (urls["queryKey"]["lang"]) {
            locale = urls.queryKey["lang"].toLowerCase();

            if (locale.length >= 2) {
                if (locale.indexOf("zh") != -1) {
                    if (locale.indexOf("tw") != -1 || locale.indexOf("hant") != -1) {
                        locale = "zh_tw";		// 중국어 간체
                    } else {
                        locale = "zh_cn";		// 중국어 번체
                    }
                } else {
                    locale = locale.substring(0, 2);
                }
            }
        }

        if (!locale) {
            locale = defaultCode;
        }

        return locale;
    };
});
