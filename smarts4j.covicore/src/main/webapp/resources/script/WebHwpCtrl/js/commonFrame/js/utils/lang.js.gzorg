define(function(require){
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var CommonFrameUtil = require("commonFrameJs/utils/util"),
		CommonDefine = require("commonFrameJs/utils/commonDefine");

	return function(){
		/**
		 * 2013.04.22 - han1228@hancom.com
		 * URL 파라메터 lang 이 지정되어 있으면  해당 언어셋 (nls) short locale code 로 변환하여 반환.
		 *
		 * 2020.01.22 - han1228@hancom.com
		 * URL Parameter 를 최소로 줄이고 기존 URL Parameter 로 전달되던 항목을 sessionStorage 로 관리하도록 변경되었다.
		 * 따라서 sessionStorage 에 있는 항목을 포함하여 수동으로 URL String 를 만들어서 parseURL 하도록 수정.
		 */

		var defaultCode = CommonDefine.langCode,
			urls = CommonFrameUtil.parseURL(CommonFrameUtil.addParameterToUrl()),
			locale = "";

		if (urls.queryKey["lang"]) {
			locale = urls.queryKey["lang"].toLowerCase();

			if (locale.length >= 2) {
				if (locale.indexOf("zh") != -1) {
					if (locale.indexOf("tw") != -1 || locale.indexOf("hant") != -1) {
						locale = "zh_tw";		// 중국어 간체
					} else {
						locale = "zh_cn";		// 중국어 번체
					}
				} else if (locale.indexOf("es") != -1 && locale.indexOf("us") != -1) {
					locale = "es_us";			// 스페인어 (미국)
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
