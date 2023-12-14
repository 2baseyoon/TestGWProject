define([
    "jquery",
    "commonFrameJs/utils/commonDefine",
	"commonFrameJs/uiFramework/uiDefine",
    "commonFrameJs/utils/util"
], function ($, CommonDefine, UiDefine, Util) {
    "use strict";

    var _isWebFontRender = false, // 랜더링 웹폰트 사용 여부
		_fontDetectMode = UiDefine.FONT_DETECT_MODE.GLOBAL,
		_baseLicenseList = [],
		_invalidLicenseList = [],
        _validSingleFontList = [],
        _$browser, _langCode, _globalNames, _fontInfo, _fontList, _reverseFontGlobalNames,
        _baseFonts, _testSize, _bd, _div, _sp, _baseWidth, _baseHeight, _fontFallbackMap, _skinName,
		_fontMatchValueMap;

    function _initDefaultFontList() {
        var idx, len, bFont;

        _baseFonts = ["monospace", "MS Sans Serif", "MS Serif"];
        _testSize = "72px";
        _bd = document.body;
        _div = document.createElement("div");
        _sp = document.createElement("span");
        _baseWidth = {};
        _baseHeight = {};
        _fontFallbackMap = {
            "NanumGothic": "NanumGothic,나눔고딕"
        };

        _div.style.position = "absolute";
        _div.style.top = "-10000px";
        _div.style.left = "-10000px";
        _div.appendChild(_sp);

        _sp.style.fontSize = _testSize;
        _sp.innerHTML = _testSize;

        // 렌더링을 최소화 하기위해 body 에 먼저 Testing Wrap 을 렌더링 시킨다.
        _bd.appendChild(_div);

        // Font Detect 에 사용할 기본 폰트 크기를 저장한다.
        for (idx = 0, len = _baseFonts.length; idx < len; ++idx) {
            bFont = _baseFonts[idx];
            _sp.style.fontFamily = bFont;

            _baseWidth[bFont] = _sp.offsetWidth;
            _baseHeight[bFont] = _sp.offsetHeight;
        }

        // 렌더링된 Testing Wrap 을 제거한다.
        _bd.removeChild(_div);
    }

    function _detect(fontNameObj, useFontList) {
        var detectedFontNameArr = [],
			fontNameArr, fontLang, i, j, len, fontNameToSet, detected, baseFontName, baseFontLen;

        if (!(fontNameObj && typeof fontNameObj === "object")) {
            return detectedFontNameArr;
        }

		baseFontLen = _baseFonts.length;
        _bd.appendChild(_div);

		for (fontLang in fontNameObj) {
			if (fontNameObj.hasOwnProperty(fontLang)) {
				fontNameArr = fontNameObj[fontLang];
				len = fontNameArr.length;

				for (i = 0; i < len; ++i) {
					fontNameToSet = fontNameArr[i];
					detected = false;

					if (!useFontList || useFontList.indexOf(fontNameToSet) !== -1) {
						// 기본 폰트와 결합하여 렌더링 시키고, 결과를 도출한다.
						for (j = 0; j < baseFontLen; ++j) {
							baseFontName = _baseFonts[j];

							// Font Fallback 의 정확도를 위해 Default baseFontName 와 결합하여, fontFamily 를 설정한다.
							_sp.style.fontFamily = (_fontFallbackMap[fontNameToSet] || fontNameToSet) + ',' + baseFontName;

							// 기본 폰트와 사이즈 정보가 다르다면, 렌더링이 가능한 것으로 간주한다.
							detected = (_sp.offsetWidth !== _baseWidth[baseFontName] ||
								_sp.offsetHeight !== _baseHeight[baseFontName]);

							// 랜더링이 가능한 것으로 간주 되었으면, 빠져 나간다.
							if (detected === true) {
								break;
							}
						}
					}

					detectedFontNameArr.push({
						font : fontNameToSet,
						detected : detected,
						langCode : fontLang
					});
				}
			}
		}

        _bd.removeChild(_div);

        return detectedFontNameArr;
    }

    function _getFontListByLocale(langCode) {
        // 정의된 국가별 폰트 목록
        var winSysBit = Util.getWindowsSystemBit(),
			device = Util.getBrowserDevice(),
            defaultFontMap = CommonDefine.fonts,
			noneExtendDeviceFontMap = CommonDefine.fontNoneExtendDevice,
			commonFontMap = CommonDefine.fontCommon,
			fontLicense = CommonDefine.fontLicense,
            fontList = {},
			etcDetect = [],
            isWin32Chrome = !!(winSysBit === "32bit" && _$browser.chrome),
			isTizenBrowser = !!(device.isTizen && _$browser.samsungBrowser),
			langFontMap, defaultFontInfo, otherFonts, locale, fontInfo, fontType, monotype;

        // 환경에 맞는 font 목록을 할당한다.
		langFontMap = isTizenBrowser ? noneExtendDeviceFontMap : defaultFontMap;

        // 현재 국가 코드에 해당하는 폰트 목록이 없으면, 기본 언어 코드 폰트 목록을 가져온다.
		defaultFontInfo = langFontMap[langCode];

		if (!defaultFontInfo) {
			_langCode = CommonDefine.langCode;
			defaultFontInfo = langFontMap[_langCode];
		} else {
			_langCode = langCode;
		}

        _globalNames = CommonDefine.fontGlobalNames;
        _fontInfo = CommonDefine.fontInfo;

        // 현재 국가에 맞는 폰트 정보를 먼저 추가한다.
		fontList[_langCode] = defaultFontInfo.default;

		// 라이센스 확인을 위한 추가 Detect font 가 있으면 추가한다.
		monotype = fontLicense.monotype[_langCode];
		if (monotype) {
			etcDetect = etcDetect.concat(monotype.extend);
			_baseLicenseList = _baseLicenseList.concat(monotype.default);
		}

        // 현재 국가는 extend 로 분류된 확장 폰트 목록도 추가한다.
        if (isWin32Chrome === true) {
            /**
             * Windows 32bit PC 의 Chrome 브라우저 접속이면, 저사양 PC 메모리 이슈가 발생될 수 있으므로..
             * extend 도 extendLight(축소된 폰트 목록) 로 추가한다.
             */
            if (defaultFontInfo.extendLight && defaultFontInfo.extendLight.length) {
				fontList[_langCode] = fontList[_langCode].concat(defaultFontInfo.extendLight);
            }
        } else if (defaultFontInfo.extend && defaultFontInfo.extend.length) {
			fontList[_langCode] = fontList[_langCode].concat(defaultFontInfo.extend);
        }

        // 나머지 국가는 기본 폰트로 분류된 목록만 추가한다.
        for (locale in langFontMap) {
			if (langFontMap.hasOwnProperty(locale)) {
				fontInfo = langFontMap[locale];

				if (locale !== _langCode) {
					// Windows 32bit PC 의 Chrome 브라우저 접속이면, 나머지 국가의 기본 폰트도 defaultLight(축소된 폰트 목록) 로 추가한다.
					otherFonts = isWin32Chrome === true ? fontInfo.defaultLight : fontInfo.default;

					if (otherFonts && otherFonts.length) {
						fontList[locale] = otherFonts;
					}
				}
			}
        }

		// 라이센스 확인을 위한 추가 Detect font 가 없으면 시스템에 따라 추가한다.
		if (!etcDetect.length) {
			monotype = fontLicense.monotype.en;

			if (isWin32Chrome === true) {
				etcDetect = monotype.default.concat(monotype.extend);
			} else {
				etcDetect = etcDetect.concat(monotype.extend);
				_baseLicenseList = _baseLicenseList.concat(monotype.default);
			}
		}

		// font detect mode 가 global_extend 이면 다국어와 상관없는 공용 폰트 목록도 포함시킨다.
		if (_fontDetectMode === UiDefine.FONT_DETECT_MODE.GLOBAL_EXTEND) {
			for (fontType in commonFontMap) {
				if (commonFontMap.hasOwnProperty(fontType)) {
					fontInfo = commonFontMap[fontType];

					if (fontInfo && fontInfo.length) {
						fontList[fontType] = fontInfo;
					}
				}
			}

			_baseLicenseList = _baseLicenseList.concat(fontLicense.monotype.symbol);
		} else {
			// global_extend 가 아니면, 라이센스 확인이 필요한 폰트를 추가한다.
			etcDetect = etcDetect.concat(fontLicense.monotype.symbol);
		}

		fontList["etc"] = etcDetect;

        return fontList;
    }

    function _getEnableFontList(fonts) {
        if (!fonts || Util.isEmptyObject(fonts)) {
            return [];
        }

        var useFontList = _fontMatchValueMap ? Object.keys(_fontMatchValueMap) : null,
			detectedFontNameArr = _detect(fonts, useFontList),
            len = detectedFontNameArr.length,
            curLangFontInfo = _fontInfo[_langCode], // 현재 국가 코드의 추가폰트정보를 가져온다.
			globalFontInfo = _fontInfo[UiDefine.FONT_DETECT_MODE.GLOBAL],	// 전체 국가에 해당되는 추가폰트정보를 가져온다.
            arrWebFontRender = curLangFontInfo ? curLangFontInfo.webFontRender : null,
			arrWebFontGlobalRender = globalFontInfo ? globalFontInfo.webFontRender : null,
			isNoneDetect = !!($.platform.tizen && _$browser.samsungBrowser),
			fontLicense = CommonDefine.fontLicense,
            font = null,
            format = null,
            enableFontArr = [],
            i, isEnable, isWebFont, isGlobalWebFont, monotype, onlySkinWebFonts;

        /**
         * font full name 이 Global 속성일 경우, Global Font Name 정보를 가져온다.
         * @param {String} fontName - font full name
         * @returns {Object}
         */
        var _getGlobalNameInfo = function (fontName) {
            var globalNameInfo = null,
                globalKey;

            if (fontName) {
                // font full name 을 key name 형식으로 변경(공백제거) 하여 대입한다.
                globalKey = fontName.replace(/[ ]/g, "");
                globalNameInfo = _globalNames[globalKey];
            }

            return globalNameInfo;
        };

        /**
         * font full name 을 UI Format 에 맞게 Object 형식으로 만들어 반환한다.
         * @param {String} fontName 		- font full name
		 * @param {String} fontLangCode 	- font 가 속한 Language code
         * @returns {Object}
         */
        var _makeFontListFormat = function (fontName, fontLangCode) {
            if (!fontName || fontLangCode === "etc") {
				return null;
            }

            // font full name 이 Global 속성일 경우, 현재 국가에 맞는 font name 이 있으면 가져온다.
            var globalNameInfo = _getGlobalNameInfo(fontName),
                globalName = globalNameInfo ? globalNameInfo[_langCode] : null,
                fontFormat = {},
                fontRename, styleName;

            // global 폰트 목록에 없으면 single 폰트 배열에 저장한다.
            if (!globalNameInfo) {
                _validSingleFontList.push(fontName);
            }

            if (!globalName) {
                globalName = fontName;
            } else {
                /**
                 * 현재 국가의 Global 폰트명이 있고, eastAsia 국가 일때는 lang Attribute 를 추가해 준다.
                 * 단 맥용 Apple SD 산돌고딕 Neo 는 한글용 fontFamily 로 랜더링에 문제가 있어 제외한다.
                 * (Mac MS word 2016 테스트시 영문 폰트[Apple SD Gothic Neo] 랜더링 문제 없음 확인.)
                 */
                if ($.inArray(_langCode, ["ko", "ja", "zh_cn", "zh_tw"]) !== -1 &&
                    fontName !== "Apple SD Gothic Neo") {
                    fontFormat.lang = _langCode;
                }

                /**
                 * 웹폰트는 두종류로 나누어질 계획이다.
                 *   1. webFontRender : Fonts 폴더의 TTF 가 일부 웹브라우저의 랜더링에 문제가 있어 웹폰트가 사용되는 경우.
                 *   2. webFontService : 웹폰트 전용 폰트로 webOffice 글꼴목록의 웹폰트 항목에서 서비스 되는 경우.
                 *      (차후 웹 전용 폰트를 지원하게 될때)
                 * 두 종류의 웹폰트가 사용될때는 웹폰트 폰트명이 모두 동일해야 하므로, global font name 으로 통일한다.
                 */
                if (isWebFont === true) {
                    fontName = globalName;

                    if (_$browser.msie) {
                        fontRename = CommonDefine.fontRenames[fontName];

                        if (fontRename) {
                            styleName = fontName + "," + fontRename;
                        }
                    }
                }
            }

            if (!styleName) {
                styleName = fontName;
            }

            fontFormat.value = fontName;
            fontFormat.style = "font-family:" + styleName;
            fontFormat.contents = globalName;
            fontFormat.title = globalName;
			fontFormat.langCode = fontLangCode;

			// 폰트가 문자전용폰트(symbol) 이면 style 적용시 폰트명이 비정상적으로 출력되므로 style 을 강제로 제거해 준다.
			if (fontLangCode === "symbol") {
				fontFormat.style = "";
			}

			if (_fontMatchValueMap && _fontMatchValueMap[fontName]) {
				fontFormat.match = _fontMatchValueMap[fontName];
			}

            return fontFormat;
        };

        // Detect 한 결과 중 true 값이 있으면, 결과값에 할당한다.
        for (i = 0; i < len; ++i) {
            font = detectedFontNameArr[i];
            isEnable = font.detected;
            isWebFont = false;
			isGlobalWebFont = !!(arrWebFontGlobalRender && arrWebFontGlobalRender.indexOf(font.font) !== -1);

			if (isGlobalWebFont || (arrWebFontRender && arrWebFontRender.indexOf(font.font) !== -1)) {
				onlySkinWebFonts = isGlobalWebFont
									? globalFontInfo.webFontOnlySkin[_skinName]
									: curLangFontInfo.webFontOnlySkin[_skinName];

				if (!onlySkinWebFonts || (onlySkinWebFonts.indexOf(font.font) !== -1)) {
					isWebFont = true;

					if (_isWebFontRender === false) {
						_isWebFontRender = true;
					}
				}
            }

            // Detect 는 실패했어도 웹폰트 적용 폰트이면 목록에 포함 시킨다.
            if (!isEnable && isWebFont) {
            	if (!_fontMatchValueMap || _fontMatchValueMap[font.font]) {
            		// 웹폰트도 font 제한된 경우는 _fontMatchValueMap 에 포함된 경우만 사용
					isEnable = true;
				}
            } else if (!isEnable && isNoneDetect) {
            	/**
				 * Detect 여부와 상관없이 출력되어야 하는 환경에서는 무조건 포함 시킨다.
				 * 예를 들어 Smart-tv 에서는 폰트가 한가지 종류밖에 없는 경우가 있다. (폰트는 하나이고 굵기에 따라 종류가 나눠지는 케이스)
				 * 이런 경우는 Detect 가 비정상적으로 동작된다. 따라서 이런 경우는 Detect 성공 여부와 상관없이 출력해 준다.
				 */
				isEnable = true;
			}

            if (isEnable === true) {
                format = _makeFontListFormat(font.font, font.langCode);

                if (format) {
                    enableFontArr.push(format);
                }
            } else {
				// Detect 에 실패했고 라이센스 체크 폰트면 라이센트 Array 에 추가한다.
				if (font.langCode === "etc") {
					_invalidLicenseList.push(font.font);
				} else {
					monotype = fontLicense.monotype[font.langCode];

					if (monotype && _baseLicenseList.indexOf(font.font) !== -1) {
						_invalidLicenseList.push(font.font);
					}
				}
			}
        }

        return enableFontArr;
    }

    return {
        initialize: function (langCode, fontDetectMode, skinName, fontGroupInfo) {
            var shortBlankNode, curLangFontInfo, languageCode, groupNames, groupName, groupLen, groupIdx,
				fontNames, fontName, fontLen, fontIdx;

            /**
             * TODO: Test 를 최소화하면서 수정을 하기 위해 아래와 같이 node 를 내부에서
             * 직접 구하도록 함.
             * 추후에 UI 가 수정되면 이 부분도 신경쓰고 변경해줘야 함.
             */
            shortBlankNode = $('div.hcwo_product_title span:last-child').get(0);

            if (!shortBlankNode) {
                shortBlankNode = $('.titlebar span:last-child').get(0);
            }

            /**
            * TODO: private value 선언 시 assign 하려했으나 시점 차이로 문제가 있어 init 시에 초기화함
            * 추후 다시 확인 후 수정해야함
            */
            _$browser = $.browser;

			/**
			 * font detect mode 값이 전달되었으면, mode 값을 할당한다.
			 * font detect mode 의 값은 다음과 같이 정의 된다.
			 * 	- "global" : 언어별 (일반, default) - uiDefine.GLOBAL
			 * 	- "global_extend" : 언어별 확장 (global 과 무관한 사항 추가) - uiDefine.GLOBAL_EXTEND
			 * 	- "character_set" : 언어와 관계없는 별도 분류 - uiDefine.CHARACTER_SET
			 */
			if (fontDetectMode) {
				_fontDetectMode = fontDetectMode;
			}

			/**
			 * skin 값을 할당한다.
			 * skin 에 따라 font detect 항목이 다른 경우 사용한다.
			 */
			_skinName = skinName || "default";

			/**
			 * fontGroupInfo 값을 통해 match 값 지정을 위한 정보 초기화한다.
			 */
			if (fontGroupInfo) {
				_fontMatchValueMap = {};

				groupNames = Object.keys(fontGroupInfo);
				groupLen = groupNames.length;

				for (groupIdx = 0; groupIdx < groupLen; groupIdx++) {
					groupName = groupNames[groupIdx];
					fontNames = fontGroupInfo[groupName];
					fontLen = fontNames.length;

					for (fontIdx = 0; fontIdx < fontLen; fontIdx++) {
						fontName = fontNames[fontIdx];

						_fontMatchValueMap[fontName] = _fontMatchValueMap[fontName] ?
							(_fontMatchValueMap[fontName] + "|" + groupName) : groupName;
					}
				}
			} else {
				_fontMatchValueMap = null;
			}

            /**
             * langCode 가 최초에 가공되어 들어오지 않았으면, 방어코드 차원으로 가공하여 사용한다.
             * 현재는 langCode 중 zh_cn , zh_tw (중국어 간체, 번체)만 5글자이므로,
             * 이 경우에만 그대로 사용하도록 한다.
             **/
            if (langCode != null && langCode.length === 5) {
                languageCode = langCode.substring(0, 2);

                if (languageCode !== "zh") {
                    langCode = languageCode;
                }
            }

            _initDefaultFontList();
            _fontList = _getEnableFontList(_getFontListByLocale(langCode));

            /**
             * IE11 에서 동적으로 웹폰트를 적용하면, 적용되지 않는 문제가 있다.
             * 따라서 정적인 페이지의 의미없는 곳에 웹폰트 fontFamily 를 연결해서 먼저 다운로드 받도록 해야만 적용이 된다.
             * 이렇게 되면 항상 웹폰트를 다운로드 받게 되므로, IE 브라우저 이고, 웹폰트가 적용되는 언어에만 적용하도록 한다.
             */
            if (shortBlankNode && _$browser.msie && _isWebFontRender === true) {
                curLangFontInfo = CommonDefine.fontInfo[langCode];

                if (curLangFontInfo && curLangFontInfo.webFontNames) {
                    shortBlankNode.style.fontFamily = curLangFontInfo.webFontNames.join(",");
                }
            }
        },

        /**
         * 최종적으로 가공된 font list 를 돌려주는 함수
         * @returns {Array|Null}                - font list
         */
        getFontList: function () {
            return _fontList;
        },

        /**
         * fontGlobalNames 를 돌려주는 함수
         * @returns {object}                - fontGlobalNames
         */
        getFontGlobalNames: function () {
            return CommonDefine.fontGlobalNames;
        },

        /**
         * global 폰트로 등록되지 않은 유효한 single 폰트(하나의 언어만을 지원하는 폰트) 리스트를 돌려주는 함수.
         */
        getSingleFontList : function() {
            return _validSingleFontList;
        },

		/**
		 * webFont Info 정보를 돌려주는 함수
		 * @param {String} langCode		- 국가(언어)코드
		 * @returns {*}
		 */
		getWebFontInfoByLocale : function(langCode) {
			return CommonDefine.fontInfo[langCode];
		},

		/**
		 * 라이센스 체크 폰트 중 Detect 에 실패한 font list 를 반환하는 함수
		 * @returns {Array}
		 */
		getInvalidLicenseFontList : function() {
			return _invalidLicenseList;
		},

        /**
         * global font name(예 : 맑은 고딕) 일때,
         * 정의된 그에 맞는 font full name (예 : "Malgun Gothic" or 맑은고딕 )이 있으면, 반환한다.
         *
         * @param {String} fontName        - font-family name
		 * @param {String=} langCode		- 반환할 글로벌 폰트의 언어코드를 강제로 지정 (예 => 한국어 : ko, 영어 : en)
         * @param {Boolean=} checkValid    - 유효하지 않은 경우 반환은 fontName 인자가 아니라 ""
         * @returns {string}               - font null name (없으면 빈 스트링)
         */
        getMatchedFontNameByLocale: function (fontName, langCode, checkValid) {
            if (!fontName) {
                return "";
            }

            if (_reverseFontGlobalNames == undefined) {
                _reverseFontGlobalNames = (function () {
                    var objKeyNames = {},
                        fontKeyName, fontInfo, key, gName;

                    for (fontKeyName in _globalNames) {
                        fontInfo = _globalNames[fontKeyName];

                        for (key in fontInfo) {
                            gName = fontInfo[key];

                            if (gName) {
                                objKeyNames[gName.replace(/[ ]/g, "")] = fontKeyName;
                            }
                        }
                    }

                    return objKeyNames;
                })();
            }

            var fontGlobalName = _reverseFontGlobalNames[fontName.replace(/[ ]/g, "")],
                matchedFontName = checkValid ? "" : fontName,
                fontInfo;

            if (fontGlobalName) {
                fontInfo = _globalNames[fontGlobalName];
                matchedFontName = fontInfo[(langCode || _langCode)] || fontInfo.default;
            }

            return matchedFontName;
        }
    };
});
