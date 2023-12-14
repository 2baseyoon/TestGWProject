var __hctfwoVersion = "M40RC9";

(function() {
	var regExpToSkinName = /skin=([^\&]+)/,
		ua = navigator.userAgent.toLowerCase(),
		i, len, scriptNode, hasViewType, viewType, locationHref, skinName, href, matchSkin, appMode;

	var writeCss = function(dir, viewType) {
		if (!viewType) {
			return false;
		}

		var arrCss = viewType.split("|"),
			length = arrCss.length,
			cssIdx;

		for (cssIdx = 0; cssIdx < length; cssIdx++) {
			if (arrCss[cssIdx]) {
				window.document.write('<link rel="stylesheet" type="text/css" href="'
					+ dir + arrCss[cssIdx] + '.css?' + __hctfwoVersion + '"/>');
			}
		}

		return true;
	};

	var _getServerPropsToServer = function (hrefString, skinName) {
		var url = "",
			regExpToApp = /smb_app=([^\&]+)/,
			matchResult, xhr, matchAppName;

		var __onResponseXhr = function (e) {
			if (e.target.responseText) {
				window.serverProps = JSON.parse(e.target.responseText);
			} else if (e.target.response) {
				window.serverProps = JSON.parse(e.target.response);
			}

			if (window.serverProps && skinName) {
				window.serverProps.skin = skinName;
			}
		};

		var __getAjaxState = function() {
			if (xhr.readyState == 4){
				if (!(xhr.status == 200 || xhr.status == 304 || xhr.status == 0)) {
					console.error("[XHR Error] " + xhr.status);
					return;
				}
			}
		};

		if (hrefString) {
			matchAppName = hrefString.match(regExpToApp);
			matchResult = matchAppName ? matchAppName[1] : "";


			if (matchResult) {
				if (matchResult.indexOf("write_") !== -1) {
					url = "/weboffice/serverProps";
				} else if (matchResult.indexOf("calc_") !== -1) {
					url = "/webCalc/serverProps";
				} else if (matchResult.indexOf("show_") !== -1) {
					url = "/webShow/serverProps";
				} else if (matchResult.indexOf("hwp_") !== -1) {
					url = "/webhwp/serverProps";
				} else {
					// 웹기안기 에서는 Props 정보를 쓰지 않으므로 수행하지 않음.
					url = "";
				}

				// viewMode 를 체크하기 위해서 임시적으로 전역변수에 저장해준다.
				window.hcwoAppMode = matchResult;
			}
		}

		if (url !== "") {
			if (window.XMLHttpRequest) {
				try {
					xhr = new XMLHttpRequest();
					xhr.addEventListener("load", __onResponseXhr);
					xhr.addEventListener("error", function (e) {console.error("xhr error", e);});
					xhr.addEventListener("abort", function (e) {console.error("xhr abort", e);});
					xhr.open("GET", url, false);
					xhr.onreadystatechange = __getAjaxState;
					xhr.send();
				} catch (e) {
					console.error("xhr error", e);
				}
			}
		}
	};

	var _addSubPathIfNeeded = function (urlPath) {
		var pathname = window.location.pathname,
			subPath = pathname.indexOf("webFramework") !== -1,
			isTestMode = pathname.indexOf("framework") !== -1,
			addPath = urlPath;

		if (isTestMode) {
			if (subPath) {
				// tomcat 서버의 경로로 tester 에 접근했을 경우 경로
				addPath = "/framework/" + urlPath;
			} else {
				// cheese cake 으로 tester 에 접근했을 경우 경로
				addPath = "/" + urlPath;
			}
		}

		return addPath;
	};

	var _setDocumentDefaultTitle = function (location) {
		var titleNls = {"ko" : "불러오는 중", "en" : "Loading"},
			defaultTitle = titleNls["en"],
			titleEl = window.document.getElementsByTagName("title")[0],
			regExpToLang = /lang=([^\&]+)/,
			matchLang, matchTitle;

		if (!titleEl) {
			return;
		}

		matchLang = location.match(regExpToLang);

		if (matchLang && matchLang[1]) {
			matchTitle = titleNls[matchLang[1].substring(0, 2)];

			if (matchTitle) {
				defaultTitle = matchTitle;
			}
		}

		titleEl.innerHTML = defaultTitle + "...";
	};

	if (window.document.scripts) {
		locationHref = window.location.href.toLowerCase();
		matchSkin = locationHref.match(regExpToSkinName);
		skinName = matchSkin ? matchSkin[1] : "";

		_getServerPropsToServer(locationHref, skinName);

		skinName = skinName || (window.serverProps && window.serverProps.skin) || "default";
		href = _addSubPathIfNeeded(
			'commonFrame/skins/' + skinName + '/css/hcwo.css' + (__hctfwoVersion ? "?" + __hctfwoVersion : ""));
		// hcwo.css 를 link 할 node (href 는 skin 구한 이후에 UiController 에서 추가됨)
		window.document.write('<link rel="stylesheet" type="text/css" href="' + href + '"/>');

		// Smart-TV 에서 접속한 경우 전용 CSS 를 추가해 준다.
		if (skinName === "default" && /smart-tv/.test(ua)) {
			writeCss("commonFrame/skins/" + skinName + "/css/", "hcwo_tv");
		}

		// 기본 브라우저 title 을 설정한다.
		_setDocumentDefaultTitle(locationHref);

		len = window.document.scripts.length;

		for (i = 0; i < len; i++) {
			scriptNode = document.scripts[i];

			if (scriptNode) {
				viewType = scriptNode.getAttribute("data-type");
				if (viewType && writeCss("", viewType)) {
					hasViewType = true;
				}

				viewType = scriptNode.getAttribute("data-framework");
				if (viewType && writeCss("commonFrame/css/", viewType)) {
					hasViewType = true;
				}
			}

			if (hasViewType) {
				break;
			}
		}

		appMode = window.hcwoAppMode;
		if ((appMode && appMode.indexOf("_viewer") !== -1)
			|| (/(mobile|android|ipad|iphone)/i.test(ua))) {
			// viewer 전용 css 추가
			writeCss("", "css/hcwo_view");
		}
	}
}());
