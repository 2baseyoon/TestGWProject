define( function (require){
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var $ = require("jquery"),
		CommonFrameUtil = require("commonFrameJs/utils/util"),
		UiUtil = require("commonFrameJs/uiFramework/uiUtil"),
		UiDefine = require("commonFrameJs/uiFramework/uiDefine"),
		CommonFrameStorage = require("commonFrameJs/utils/storage"),
		UiFrameworkInfo = require("commonFrameJs/uiFramework/uiFrameworkInfo");


	/*******************************************************************************
	 * Defines, Caches
	 ******************************************************************************/
	var _dialogVScrollClass = UiDefine.DIALOG_V_SCROLL_CLASS,
		_defineDataValueAttr = UiDefine.DATA_VALUE,
		_defineTitleAttr = UiDefine.DATA_TITLE_ATTR,
		_defineNlsNameAttr = UiDefine.DATA_NLS_NAME_ATTR,
		_defineMatchAttr = UiDefine.DATA_MATCH_ATTR,
		_constMenuWrapNames = UiDefine.MENU_WRAP_NAME,
		_browserDevice = CommonFrameUtil.getBrowserDevice(),
		_browserInfo = UiUtil.getBrowserInfo(),
		_uri = CommonFrameUtil.parseURL(CommonFrameUtil.addParameterToUrl()),
		_userID = _uri.queryKey["user_id"] || "tester",
		_descTagRegExp = /<(br|strong|\/p)[^>]?>/,
		_localStorageKey = "hcwo_ui_" + _userID,
		_viewNameToStateSaveKey = {
			"toggle_ui_option_view": "tu",
			"side_bar": "sb",
			"menu_bar": "mb",
			"style_bar": "slb",
			"status_bar": "stb",
			"dont_look_again": "dla"
		},
		_saveViewNames = Object.keys(_viewNameToStateSaveKey),
		_targetMenuWrapIdx = { // _menuWraps 중에 append 할 target index
			"title_bar": _constMenuWrapNames.TOOL_BAR,
			"menu_bar": _constMenuWrapNames.TOOL_BAR,
			"style_bar": _constMenuWrapNames.TOOL_BAR,
			"document": _constMenuWrapNames.CONTAINER,
			"comment_bar": _constMenuWrapNames.CONTAINER,
			"side_bar": _constMenuWrapNames.CONTAINER,
			"sheet_tab_bar": _constMenuWrapNames.WRAP,
			"status_bar": _constMenuWrapNames.WRAP,
			"translation": _constMenuWrapNames.CONTAINER,
			"thumbnail_view": _constMenuWrapNames.CONTAINER,
			"context_menu": _constMenuWrapNames.WRAP,
			"modal_dialog": _constMenuWrapNames.WRAP,
			"modeless_dialog": _constMenuWrapNames.WRAP,
			"tool_box": _constMenuWrapNames.WRAP
		};

	/*******************************************************************************
	 * Private Variables
	 ******************************************************************************/
	var _uiStateInfo, _definedSaveKeyArr;

	/*******************************************************************************
	 * Private Functions
	 ******************************************************************************/
	/**
	 * viewName 으로 LocalStorage 저장을 위한 Save Key 로 사용가능하면 return
	 * @param {String} viewName
	 * @returns {String}
	 */
	function _getCustomSaveKey(viewName) {
		var length, i;

		if (!_definedSaveKeyArr) {
			_definedSaveKeyArr = [];
			length = _saveViewNames.length;

			for (i = 0; i < length; i++) {
				// _definedSaveKeyArr 에 key 로 사용중인 값 push
				_definedSaveKeyArr[_definedSaveKeyArr.length] = _viewNameToStateSaveKey[_saveViewNames[i]];
			}
		}

		return (_definedSaveKeyArr.indexOf(viewName) !== -1) ? "" : viewName;
	}

	return {
		/**
		 * sample element 에 필요한 속성 set 한다.
		 * @param {Element=} valueEl
		 * @param {Element=} titleEl
		 * @param {Element=} descEl
		 */
		initAttributeToSampleEl: function(valueEl, titleEl, descEl) {
			var sampleValue = UiDefine.SAMPLE_VALUE;

			if (valueEl) {
				valueEl.setAttribute(_defineDataValueAttr, sampleValue);
				valueEl.removeAttribute(_defineMatchAttr);
			}

			if (titleEl) {
				titleEl.setAttribute(_defineTitleAttr, sampleValue);
			}

			if (descEl) {
				descEl.setAttribute(_defineNlsNameAttr, sampleValue);
				descEl.textContent = "";

				if (descEl.getAttribute("style")) {
					descEl.removeAttribute("style");
				}
			}
		},

		/**
		 * custom event object 를 생성하여 반환.
		 * @param {Object} eventObj			- event 정보 object
		 * @returns {Object}
		 * 		{String} type					- event 종류 (uiResize)
		 * 		{Element} target				- event target
		 *		{String} name					- API명 or Widget명
		 * 		{String} kind					- event 발생 분류 (api, widget)
		 * 		{Element|Array} execTarget		- event 가 실행된 target
		 * 		{String} execValue				- event 가 실행된 값(value)
		 */
		makeCustomEventObject: function (eventObj) {
			return {
				"type" : eventObj.type || "",
				"target" : eventObj.target || null,
				"name" : eventObj.name || "",
				"kind" : eventObj.kind || "",
				"execTarget" : eventObj.execTarget || null,
				"execValue" : eventObj.execValue || ""
			};
		},

		/**
		 * custom event 를 발생시키는 함수
		 * @param eventObj
		 */
		fireCustomEvent: function (eventObj) {
			$.publish("/ui/custom", this.makeCustomEventObject(eventObj));
		},

		/**
		 * DOM 에 기록된 XML 상 name 을 반환하는 함수 (첫번째 class name)
		 * @param {Element} targetElement
		 * @returns {String} name
		 */
		getName: function (targetElement) {
			var nameStr, classList;

			if (targetElement) {
				classList = targetElement.classList || (targetElement.getAttribute("class") || "").split(" ");
				nameStr = classList[0];
			}

			return nameStr || "";
		},

		/**
		 * 다국어 리소스 적용한 string 반환한다.
		 * @param {String} string
		 * @returns {String}
		 */
		getReplaceNlsValue: function(string) {
			var langDefine = UiFrameworkInfo.getLangDefine(),
				nlsStartIndex = string.indexOf("{"),
				nlsEndIndex = string.indexOf("}"),
				dataValue, replaceNlsNameMap, resultStr;

			if (nlsStartIndex !== -1 && nlsEndIndex !== -1 && (nlsStartIndex < nlsEndIndex)) {
				replaceNlsNameMap = UiDefine.REPLACE_NLS_MAP[UiFrameworkInfo.getModuleName()] || null;

				resultStr = string.substring(nlsStartIndex + 1, nlsEndIndex);
				resultStr = replaceNlsNameMap ? (replaceNlsNameMap[resultStr] || resultStr) : resultStr;
				dataValue = (langDefine && langDefine[resultStr]) || resultStr;

				// '{' 의 앞 부분 string
				if (nlsStartIndex !== 0) {
					dataValue = string.substring(0, nlsStartIndex) + dataValue;
				}
				// '}' 의 뒷 부분 string
				if (nlsEndIndex !== string.length - 1) {
					dataValue = dataValue + string.substring(nlsEndIndex + 1, string.length);
				}
			} else {
				dataValue = string;
			}

			return dataValue;
		},

		/**
		 * Style 에 해당하는 값에 대해 숫자로 변환하여 돌려주는 함수
		 * @param {Element} targetEl				- 대상 타겟 element
		 * @param {String} style				    - CSS 프로퍼티 Script Syntax (ex. "marginLeft")
		 * @returns {Number}
		 */
		getNumberFromStyleValue: function(targetEl, style) {
			var result = 0;

			if (targetEl && style) {
				result = parseInt(CommonFrameUtil.getCurrentStyle(targetEl, style) || 0, 10);
			}

			return result;
		},

		/**
		 * EventAction 의 unit property 로 부터 unit 구함
		 * @param {Object|String} unitProperty		- eventAction.unit
		 * @param {String=} valueKey
		 * @returns {String} unit
		 */
		getUnitValue: function(unitProperty, valueKey) {
			var unit = (CommonFrameUtil.isObject(unitProperty) && valueKey) ? unitProperty[valueKey] : unitProperty;
			return (unit == null) ? null : unit;
		},

		/**
		 * EventAction 의 match property 로 부터 match 구함
		 * @param {Object|String} matchProperty		- eventAction.match
		 * @param {String=} valueKey
		 * @returns {String} match
		 */
		getMatchValue: function(matchProperty, valueKey) {
			var match = (CommonFrameUtil.isObject(matchProperty) && valueKey) ? matchProperty[valueKey] : matchProperty;
			return (match == null) ? null : match;
		},

		/**
		 * contextMenu 가 현재 화면에서 벗어났다고 판단되는 경우 조정된 top, left 값 반환
		 * @param {Number} top
		 * @param {Number} left
		 * @returns {Object} {top,left}
		 * @private
		 */
		getPosToContextMenu: function(top, left) {
			var bottom = 0,
				right = 0,
				contextMenuEl = UiFrameworkInfo.getContextMenu(),
				sideBarEl = UiFrameworkInfo.getContainerNode(UiDefine.SIDEBAR_ID),
				sidebarWidth = (sideBarEl && $(sideBarEl).width()) || 0,
				contentWindow = UiFrameworkInfo.getContentWindow(),
				menuHeight = 0,
				menuWidth = 0,
				windowInnerWidth, windowInnerHeight, targetHeight, targetWidth, pos;

			if (contextMenuEl) {
				menuHeight = contextMenuEl.offsetHeight;
				menuWidth = contextMenuEl.offsetWidth;

				if (top > 0) {
					windowInnerHeight = contentWindow.innerHeight;
					targetHeight = top + menuHeight;

					if (targetHeight > windowInnerHeight) {
						// 아래가 닿는 경우 위로 띄우기 시도
						if (top < menuHeight) {
							// 위로 해도 닿는 경우 가장 위를 기준으로 띄운다
							top = 0;
						} else {
							bottom = targetHeight - windowInnerHeight;
						}
					}
				}

				if (left > 0) {
					windowInnerWidth = contentWindow.innerWidth;
					targetWidth = left + menuWidth;

					if (targetWidth > (windowInnerWidth - sidebarWidth)) {
						right = targetWidth - (windowInnerWidth - sidebarWidth);

						if (_browserDevice.isMobile) {
							left = left - right;
							right = 0;
						}

						if (right > 0 && (left - menuWidth) < 0) {
							left = 0;
							right = 0;
						}
					}
				}

			}

			pos = {
				top: bottom > 0 ? top - menuHeight + "px" : top + "px",
				left: right > 0 ? left - menuWidth + "px" : left + "px"
			};

			return pos;
		},

		/**
		 * v scroll class 가 들어갈 대상 element 를 찾아 돌려주는 함수
		 * @param {Element} targetEl
		 * @return {Element}
		 */
		getVScrollElement: function (targetEl) {
			var propertyTitleEl = (targetEl && targetEl.querySelector("." + UiDefine.PROPERTY_TITLE_CLASS)) || null;

			return (propertyTitleEl && propertyTitleEl.nextElementSibling) || null;
		},

		/**
		 * description 지정
		 * @param {Element} descEl
		 * @param {String=} dataValue			- 데이터 미지정시 표시제외
		 * @param {Boolean=} addLineBreak		- true 시 중간에 띄어쓰기 있는 경우 line break 추가
		 */
		setDescription: function(descEl, dataValue, addLineBreak) {
			function __getSpaceCharIdx(string, idx) {
				var replaceIdx = -1;

				if (string.charAt(idx) === " ") {
					replaceIdx = idx;
				}
				return replaceIdx;
			}

			var brReplaceIdx = -1,
				isSlash, isEmptyDescEl, charIdxAdd, charIdx, textValue, divEl;

			if (!descEl) {
				return;
			}

			if (dataValue) {
				if (addLineBreak) {
					charIdxAdd = -1;
					charIdx = dataValue.indexOf("/");

					if (charIdx > 0) {
						isSlash = true;
						brReplaceIdx = charIdx;

					} else {
						charIdx = CommonFrameUtil.getCeilNumber(dataValue.length / 2, 0);

						while (charIdxAdd <= charIdx && brReplaceIdx < 0) {
							charIdxAdd++;
							brReplaceIdx = __getSpaceCharIdx(dataValue, charIdx + charIdxAdd);
							if (brReplaceIdx < 0 && charIdxAdd) {
								brReplaceIdx = __getSpaceCharIdx(dataValue, charIdx - charIdxAdd);
							}
						}
					}

					if (brReplaceIdx > 0) {
						charIdx = isSlash ? brReplaceIdx + 1 : brReplaceIdx;
						textValue = dataValue.substring(0, charIdx) + "<br>" + dataValue.substring(brReplaceIdx + 1);
					} else {
						textValue = dataValue + "<br>";
					}
					descEl.innerHTML = textValue + descEl.innerHTML;
				} else {
					// child 가 empty 일때 더 성능이 좋은 방법 사용
					isEmptyDescEl = !(descEl.firstChild);

					if (dataValue.match(_descTagRegExp)) {
						if (isEmptyDescEl) {
							descEl.innerHTML = dataValue;
						} else {
							divEl = document.createElement("div");
							divEl.innerHTML = dataValue;
							descEl.insertBefore(divEl, descEl.firstChild);
							CommonFrameUtil.unwrap(divEl.firstChild);
						}
					} else {
						if (isEmptyDescEl) {
							descEl.innerText = dataValue;
						} else {
							descEl.insertBefore(document.createTextNode(dataValue), descEl.firstChild);
						}
					}
				}
				CommonFrameUtil.removeClass(descEl, UiDefine.HIDE_DESC_CLASS);
			} else {
				CommonFrameUtil.addClass(descEl, UiDefine.HIDE_DESC_CLASS);
			}
		},

		/**
		 * Font list 에 대한 정보를 세팅하고, parentEl 에 font list 에 대한 DOM 을 세팅해주는 함수
		 *  - Font 는 모듈이 아닌 UI Layer 에서 rendering 까지 수행
		 *
		 * @param {Array} fontList
		 * @param {Object} fontElInfo
		 * @param {Object} fontMap
		 */
		setValueToFontEl: function (fontList, fontElInfo, fontMap) {
			var el, parentEl, fontListLen, valueEl, titleEl, descEl, dataValue, style, title, contents, match, i,
				fontInfo;

			if (!fontList || !fontElInfo) {
				return;
			}

			el = fontElInfo.el;
			parentEl = fontElInfo.parentEl;

			fontListLen = fontList.length;

			valueEl = (el.getAttribute(_defineDataValueAttr) && el) || el.querySelector("[" + _defineDataValueAttr + "]");
			titleEl = (el.getAttribute(_defineTitleAttr) && el) || el.querySelector("[" + _defineTitleAttr + "]");
			descEl = (el.getAttribute(_defineNlsNameAttr) && el) || el.querySelector("[" + _defineNlsNameAttr + "]");

			for (i = 0; i < fontListLen; ++i) {
				fontInfo = fontList[i];
				dataValue = fontInfo.value;
				style = fontInfo.style;
				title = fontInfo.title;
				contents = fontInfo.contents;
				match = fontInfo.match;

				if (contents !== dataValue) {
					fontMap[contents.replace(/[ ]/g, "")] = dataValue;
				}

				if (valueEl) {
					if (dataValue) {
						valueEl.setAttribute(_defineDataValueAttr, dataValue);
					} else {
						valueEl.removeAttribute(_defineDataValueAttr);
					}

					if (match) {
						valueEl.setAttribute(_defineMatchAttr, match);
					} else {
						valueEl.removeAttribute(_defineMatchAttr);
					}
				}

				if (titleEl) {
					if (title) {
						titleEl.setAttribute(_defineTitleAttr, title);
					} else {
						titleEl.removeAttribute(_defineTitleAttr);
					}
				}

				if (descEl) {
					if (style) {
						descEl.setAttribute("style", style);
					} else {
						descEl.removeAttribute("style");
					}

					if (contents) {
						descEl.textContent = contents;
						descEl.removeAttribute(_defineNlsNameAttr);
					} else {
						descEl.textContent = "";
					}
				}

				parentEl.appendChild(el.cloneNode(true));
			}

			this.initAttributeToSampleEl(valueEl, titleEl, descEl);
		},

		/**
		 * Font list 에 대한 정보를 세팅하고, 필요한 위치에 font list 에 대한 DOM 을 세팅해주는 함수
		 *  - Font 는 모듈이 아닌 UI Layer 에서 rendering 까지 수행
		 *
		 * @param {Array} fontList
		 * @param {Array} fontElList
		 * @returns {Object} fontMap
		 */
		setFontListEl: function(fontList, fontElList) {
			if (!fontList || !fontElList || fontElList.length === 0) {
				return {};
			}

			var fontElListLen = fontElList.length,
				fontMap = {},
				i;

			for (i = 0; i < fontElListLen; ++i) {
				this.setValueToFontEl(fontList, fontElList[i], fontMap);
			}

			return fontMap;
		},

		/**
		 * input element 에 text 지정
		 * @param {Element} inputEl
		 * @param {String} value
		 * @param {String} unit			- eventAction.unit
		 * @param {String} valueKey
		 * @param {String} widgetName
		 * @returns {Boolean} result
		 */
		setInputText: function(inputEl, value, unit, valueKey, widgetName) {
			var result = false,
				inputValue, colorValue, unitEl, unitVal, inputScrollWidth, spectrumColorPickerEl, inputWrapEl;

			if (inputEl && inputEl.nodeName === "INPUT") {
				if (inputEl.type === "number") {
					inputValue = parseFloat(value);
				} else {
					inputValue = value;

					/**
					 * color picker spectrum 내부에 있는 input 값은 spectrum color picker 갱신이
					 * 하나의 세트로 동시에 이루어져야 한다.
					 */
					inputWrapEl = UiUtil.getInputWrapWidgetByInput(inputEl);
					if (CommonFrameUtil.hasClass(inputWrapEl, UiDefine.PREVIEW_COLOR_TEXT_CLASS)) {
						if (CommonFrameUtil.isStartsWith(inputValue, "#")) {
							colorValue = inputValue.toUpperCase();
							inputWrapEl.removeAttribute(_defineDataValueAttr);
						} else {
							colorValue = UiDefine.COLOR_PICKER_DEFAULT_COLOR;
							inputWrapEl.setAttribute(_defineDataValueAttr, inputValue);
						}

						inputValue = colorValue.substr(1, colorValue.length - 1);

						if (UiUtil.checkValidationColorCode(colorValue) === UiDefine.VALIDATION_CHECK_RESULT.SUCCESS) {
							// spectrum color picker 색 변경
							spectrumColorPickerEl = CommonFrameUtil.findParentNode(inputEl, "." + UiDefine.SPECTRUM_COLOR_CONTENT_CLASS);
							if (spectrumColorPickerEl) {
								UiUtil.setColorToColorPicker(spectrumColorPickerEl, colorValue);
							}
						}
					}
				}

				if (inputValue !== 0 && !inputValue) {
					inputValue = "";
				}

				if (inputEl.value !== inputValue) {
					inputEl.value = inputValue;

					if (UiFrameworkInfo.getModuleName() === UiDefine.MODULE_NAME_WEBWORD
						&& UiFrameworkInfo.getFocusWidgetInfo().curWidgetEl === inputEl) {
						this.fireCustomEvent({
							kind: UiDefine.CUSTOM_EVENT_KIND.WIDGET,
							target: inputEl,
							type: UiDefine.CUSTOM_EVENT_TYPE.UI_INPUT_CHANGE,
							name: UiDefine.CUSTOM_EVENT_TYPE.UI_INPUT_CHANGE,
							execValue: inputValue
						});
					}

					if (widgetName === "insert_symbols_symbol_input") {
						inputScrollWidth = inputEl.scrollWidth;
						if (inputEl.offsetWidth < inputScrollWidth) {
							inputEl.scrollLeft = inputScrollWidth;
						}
					}
				}

				if (unit != null) {
					unitEl = inputEl.nextElementSibling;
					unitVal = this.getUnitValue(unit, valueKey);

					if (CommonFrameUtil.hasClass(unitEl, UiDefine.UNIT_CLASS)) {
						if (unitVal != null) {
							unitEl.textContent = unitVal || "";

							if (unitVal) {
								CommonFrameUtil.removeClass(unitEl, UiDefine.HIDE_VIEW_CLASS);
							} else {
								CommonFrameUtil.addClass(unitEl, UiDefine.HIDE_VIEW_CLASS);
							}
						}
					}

					if (CommonFrameUtil.isString(unitVal)) {
						UiFrameworkInfo.setUnitInfo(widgetName, unitVal);
					}
				}

				result = true;
			}

			return result;
		},

		/**
		 * textArea element 에 text 지정
		 * @param {Element} textareaEl			- 대상 TextArea element
		 * @param {String} value				- 세팅할 문자열
		 * @returns {Boolean}
		 */
		setTextareaText: function (textareaEl, value) {
			var result = false;

			if (textareaEl) {
				if (!value) {
					value = "";
				}

				if (textareaEl.value !== value) {
					textareaEl.value = value;

					if (textareaEl.scrollTop > 0) {
						textareaEl.scrollTop = 0;
					}
				}

				result = true;
			}

			return result;
		},

		/**
		 * dialogView 가 css 에 의해 자동으로 움직이는 상태(사용자가 움직이지 않은 상태)의 dialog 인지 아닌지 확인.
		 * @param {Element=} dialogView		- Dialog Contents Layer (미지정시 현재 showing 중인 dialog)
		 * @returns {Boolean}
		 */
		isAutoMoveStateDialog: function(dialogView) {
			var result = false;

			dialogView = dialogView || UiFrameworkInfo.getDialogShowing().viewNode;

			if (dialogView) {
				result = (!CommonFrameUtil.isNumber(parseFloat(dialogView.style.left)));
			}

			return result;
		},

		/**
		 * Dialog Contents Layer 의 상단 위치를 화면의 중앙으로 설정해준다.
		 * @param {Element} dialogLayer		- Dialog Contents Layer
		 * @param {Number=} dialogLayerHeight	- offsetHeight (미지정시 계산)
		 * @param {Number=} topPosition		- 중앙이 아닌 원하는 top 위치 (높이가 큰 경우 위로 더 올림)
		 */
		setDialogTopPosition: function(dialogLayer, dialogLayerHeight, topPosition) {
			if (!dialogLayer) {
				return;
			}

			var doc = dialogLayer.ownerDocument,
				wrapNode = doc.getElementById(UiDefine.WRAP_ID),
				winHeight = CommonFrameUtil.getOffsetHeight(wrapNode),
				topPos = 0,
				needVScroll = true,
				dialogHeight, topDiff;

			if (!CommonFrameUtil.isNumber(dialogLayerHeight)) {
				dialogLayerHeight = CommonFrameUtil.getOffsetHeight(dialogLayer);
			}

			dialogHeight = dialogLayerHeight;
			topDiff = winHeight - dialogHeight;

			if (topDiff > 0) {
				needVScroll = false;

				if (CommonFrameUtil.isNumber(topPosition)) {
					topPos = (topPosition + dialogHeight < winHeight) ? topPosition : winHeight - dialogHeight;
				} else {
					topPos = (winHeight / 2) - (dialogHeight / 2);
				}
			}

			this.adjustDialogVScroll(dialogLayer, needVScroll);

			if (dialogLayer.style.top !== topPos + "px") {
				dialogLayer.style.top = topPos + "px";
			}
		},

		/**
		 * LangCode 를 html tag 의 lang 속성으로 값을 세팅해주는 함수.
		 * @param {Window=} contentWindow			- (미지정시 window 사용)
		 * @param {String=} langCode				- (미지정시 "en" 사용)
		 */
		setLangCodeToDom: function(contentWindow, langCode) {
			var contentDoc = contentWindow.document || window.document,
				contentDocHtmlEl = contentDoc ? contentDoc.getElementsByTagName("html")[0] : null;

			if (contentDocHtmlEl) {
				contentDocHtmlEl.setAttribute("lang", langCode || "en");
			}
		},

		/**
		 * titleBar menu 에 mouse over 될 때 호출 (pull down menu 동작 위함)
		 * @param {Element} titleBarCommandEl	- mouseOver 된 titleBarCommandElement
		 * @returns {Boolean}
		 */
		setTitleBarMenuOverOn: function(titleBarCommandEl) {
			if (!(titleBarCommandEl
				&& titleBarCommandEl.getAttribute(UiDefine.DATA_UI_COMMAND) === UiDefine.UI_COMMAND_NAME.TITLE_BAR)) {
				return false;
			}

			var titleBarMenuEl = titleBarCommandEl.parentNode, // titleBar - titlePanel
				titleBarMenuOver = UiFrameworkInfo.getInfo(UiFrameworkInfo.TITLE_BAR_MENU_OVER),
				result = false,
				dropdownListInfo;

			if (titleBarMenuOver !== titleBarMenuEl) {
				if (titleBarMenuOver) {
					CommonFrameUtil.removeClass(titleBarMenuOver, "on");
					result = true;
				}
				UiFrameworkInfo.setInfo(UiFrameworkInfo.TITLE_BAR_MENU_OVER, titleBarMenuEl);

				CommonFrameUtil.addClass(titleBarMenuEl, "on");

				dropdownListInfo = UiFrameworkInfo.getDropdownListInfo();
				if (CommonFrameUtil.hasClass(dropdownListInfo.container, UiDefine.TITLE_BAR_ID)) {
					this.clearArrowKeyHover();
				}
			}

			return result;
		},

		/**
		 * 특정 attribute 에 있는 값 nls 처리
		 * @param {Array} elList
		 * @param {String|Array} attributeName
		 */
		replaceAttrValue: function(elList, attributeName) {
			if (!elList) {
				return;
			}

			var length = elList.length,
				attrLen = 0,
				i, j, el, attrValue, dataValue;

			if (CommonFrameUtil.isArray(attributeName)) {
				attrLen = attributeName.length;
			} else if (CommonFrameUtil.isString(attributeName)) {
				attrLen = 1;
				attributeName = [attributeName];
			}

			for (i = 0; i < length; i++) {
				el = elList[i];

				for (j = 0; j < attrLen; ++j) {
					attrValue = el.getAttribute(attributeName[j]);
					if (attrValue) {
						dataValue = this.getReplaceNlsValue(attrValue);
						if (dataValue && attrValue !== dataValue) {
							el.setAttribute(attributeName[j], dataValue);
						}
					}
				}
			}
		},

		/**
		 * elList 를 배치한 wrap 을 생성해 contentWindow 의 body 에 append 한다.
		 * @param {Array} elList
		 * @param {Window=} contentWindow
		 * @returns {Element} wrapNode
		 */
		appendToMenuWrap: function(elList, contentWindow) {
			var menuWraps = [],
				elListLen, bodyNode, menuNode, wrapNode, el, i, targetWrap, attrObj, curDevice;

			if (!elList) {
				return null;
			}

			elListLen = elList.length;
			contentWindow = contentWindow || window;

			if (_browserDevice.isMobile) {
				curDevice = "mobile";
			} else if ($.browser.smartTV) {
				curDevice = "tv";
			} else {
				curDevice = "pc";
			}

			// wrap
			attrObj = {};
			attrObj[UiDefine.DATA_APP_ATTR] = UiFrameworkInfo.getModuleName();
			attrObj[UiDefine.DATA_DEVICE_ATTR] = curDevice;
			attrObj[UiDefine.DATA_SKIN_ATTR] = UiFrameworkInfo.getSkinName();
			wrapNode = CommonFrameUtil.createDomEl("div", {
				id: UiDefine.WRAP_ID, className: UiDefine.WRAP_ID}, attrObj);
			menuWraps[_constMenuWrapNames.WRAP] = wrapNode;
			// tool_bar
			menuNode = CommonFrameUtil.createDomEl("div", {id: UiDefine.TOOLBAR_ID, className: UiDefine.TOOLBAR_ID});
			wrapNode.appendChild(menuNode);
			menuWraps[_constMenuWrapNames.TOOL_BAR] = menuNode;
			// container
			menuNode = CommonFrameUtil.createDomEl("div", {id: UiDefine.CONTAINER_ID, className: UiDefine.CONTAINER_ID});
			wrapNode.appendChild(menuNode);
			menuWraps[_constMenuWrapNames.CONTAINER] = menuNode;

			for (i = 0; i < elListLen; i++) {
				el = elList[i];
				targetWrap = menuWraps[_targetMenuWrapIdx[el.id || el.firstChild.id]];

				if (targetWrap) {
					targetWrap.appendChild(el);
				}
			}

			bodyNode = contentWindow.document.body;
			bodyNode.insertBefore(wrapNode, bodyNode.firstChild);

			return wrapNode;
		},

		/**
		 * message 의 description, title, class 변경
		 * @param {Element} widget			- message (편집 상태) widget
		 * @param {Object} value			- message value Object
		 * 									  {desc: .., title: .., class: ..}
		 */
		updateMessageTitle: function(widget, value) {
			var descClassVal, newClassVal, titleVal;

			if (widget && value) {
				descClassVal = widget.getAttribute(UiDefine.DATA_DESC_CLASS_ATTR);
				newClassVal = value["class"];
				titleVal = value["title"];

				if (newClassVal !== descClassVal) {
					if (descClassVal) {
						CommonFrameUtil.removeClass(widget, descClassVal);
					}

					if (newClassVal) {
						CommonFrameUtil.addClass(widget, newClassVal);
						widget.setAttribute(UiDefine.DATA_DESC_CLASS_ATTR, newClassVal);
					} else {
						widget.removeAttribute(UiDefine.DATA_DESC_CLASS_ATTR);
					}
				}

				if (titleVal) {
					if (widget.getAttribute("title") !== titleVal) {
						widget.setAttribute("title", titleVal);
					}

				} else {
					widget.removeAttribute("title");
				}
			}
		},

		/**
		 * UI 상태 저장
		 * @param {String} viewName		- 상태 저장할 view name (ex. "toggle_ui_option_view")
		 * 										지정된 view 가 아닌경우 key (간략한 name)
		 * @param {String|Number|Boolean|Object}	value
		 */
		saveUiState: function(viewName, value) {
			var storage = CommonFrameStorage.storage,
				key = _viewNameToStateSaveKey[viewName] || _getCustomSaveKey(viewName),
				moduleName = UiFrameworkInfo.getModuleName(),
				moduleInfo, uiStateInfo;

			if (moduleName && storage && key) {
				uiStateInfo = _uiStateInfo || {};
				moduleInfo = uiStateInfo[moduleName];

				if (value != null) {
					if (!moduleInfo) {
						moduleInfo = {};
						uiStateInfo[moduleName] = moduleInfo;
					}

					moduleInfo[key] = value;
					CommonFrameStorage.setWebStorage(_localStorageKey, JSON.stringify(uiStateInfo));

					// MSIE 는 쿠키 정보에 localStorage 사용여부를 기록하여 저장된 UI 상태정보가 있는지 판단한다.
					if (_browserInfo.isMSIE && CommonFrameUtil.getCookieVal(_localStorageKey) !== "on") {
						CommonFrameUtil.setCookieVal(_localStorageKey, "on", 365);
					}
				}
			}
		},

		/**
		 * UI 상태정보 가져오기
		 * @param {String} viewName		- 상태 가져올 view name (ex. "toggle_ui_option_view")
		 * 										지정된 view 가 아닌경우 key (간략한 name)
		 * @returns {String|Number|Boolean}
		 */
		getUiState: function(viewName) {
			var key = _viewNameToStateSaveKey[viewName] || _getCustomSaveKey(viewName),
				moduleInfo, storage, storageVal, stateValue;

			if (!_uiStateInfo) {
				storage = CommonFrameStorage.storage;
				storageVal = storage && CommonFrameStorage.getWebStorage(_localStorageKey);

				/**
				 * MSIE 는 브라우저 웹사이트 데이터를 삭제해도 localStorage 가 삭제되지 않기 때문에.
				 * 쿠키 정보에 localStorage 저장 여부를 기록하여, 저장된 UI 상태정보가 있는지 판단한다.
				 */
				if (storageVal && _browserInfo.isMSIE) {
					// localStorage 정보가 있어도, 쿠키에 localStorage 저장 여부가 on 이 아니면 상태정보가 없는것으로 간주한다.
					if (CommonFrameUtil.getCookieVal(_localStorageKey) !== "on") {
						storageVal = null;
					}
				}

				if (storageVal) {
					_uiStateInfo = JSON.parse(storageVal);

				} else {
					_uiStateInfo = {};
				}
			}

			moduleInfo = _uiStateInfo[UiFrameworkInfo.getModuleName()];
			stateValue = moduleInfo && moduleInfo[key];

			return (stateValue != null) ? stateValue : null;
		},

		/**
		 * save 대상 view name array 반환
		 * @returns {Array} saveViewNames
		 */
		getSaveViewNames: function() {
			return _saveViewNames;
		},

		/**
		 * target 상위를 올라가며 "menu_box" class 를 가진 node 를 구함
		 * @param {Element} target		- 대상
		 * @param {Node=} limit		- 미지정시 끝까지 찾음
		 * @returns {Element}
		 */
		findMenuBox: function(target, limit) {
			var menuBoxEl = null;

			while (target && !menuBoxEl && limit !== target) {
				if (CommonFrameUtil.hasClass(target, UiDefine.BOX_ELEMENT_CLASS)) {
					menuBoxEl = target;
				}

				target = target.parentNode;
			}

			return menuBoxEl;
		},

		/**
		 * 상황에 따라 target 에 dialog v scroll 을 세팅하거나 없애는 함수
		 *
		 * @param {Element} dialogLayer		- dialog layer
		 * @param {Boolean} needScroll			- 스크롤이 필요한지 여부
		 */
		adjustDialogVScroll: function (dialogLayer, needScroll) {
			var isSearchDocDlg = CommonFrameUtil.hasClass(dialogLayer, UiDefine.DIALOG_SEARCH_DOC_NAME),
				minHeight = "",
				dlgStyle = dialogLayer ? dialogLayer.style : null,
				targetEl, hasDlgVScrollClass;

			if (dlgStyle) {
				targetEl = this.getVScrollElement(dialogLayer);
				hasDlgVScrollClass = CommonFrameUtil.hasClass(targetEl, _dialogVScrollClass);

				if (needScroll) {
					if (targetEl && !hasDlgVScrollClass) {
						CommonFrameUtil.addClass(targetEl, _dialogVScrollClass);

						dlgStyle.height = "100%";
					}
				} else {
					if (targetEl && hasDlgVScrollClass) {
						CommonFrameUtil.removeClass(targetEl, _dialogVScrollClass);

						dlgStyle.height = "";
					}

					if (isSearchDocDlg) {
						minHeight = UiDefine.SEARCH_DOC_DLG_MIN_HEIGHT + "px";
					}
				}

				if (isSearchDocDlg) {
					dlgStyle.minHeight = minHeight;
				}
			}
		},

		/**
		 * 드롭다운 리스트(레이어)의 Tab 포커스 클래스가 있으면 삭제한다.
		 * @param {Element} focusWidget		- 대상 위젯 노드
		 */
		removeLayerKeyFocus : function(focusWidget) {
			if (!focusWidget) {
				return;
			}

			if (focusWidget.nodeName === "LABEL" && CommonFrameUtil.hasClass(focusWidget, UiDefine.LAYER_KEY_FOCUS)) {
				CommonFrameUtil.removeClass(focusWidget, UiDefine.LAYER_KEY_FOCUS);
			}
		},

		/**
		 * 드롭다운 리스트에서 방향키 이동 hover 클래스를 모두 삭제한다.
		 * @param {Boolean=} isForceClear			- 강제 삭제 여부
		 */
		clearArrowKeyHover: function (isForceClear) {
			var listMenu = UiFrameworkInfo.getDropdownBoxList(),
				dropdownListInfo = UiFrameworkInfo.getDropdownListInfo(),
				isFocusableBox, hoverWidgetList, i;

			if (listMenu && !CommonFrameUtil.isEmptyObject(dropdownListInfo)) {
				isFocusableBox = CommonFrameUtil.hasClass(
					listMenu, [UiDefine.FOCUSABLE_PANEL_CLASS, UiDefine.LIST_BOX_CLASS]);

				if (!isFocusableBox || isForceClear) {
					hoverWidgetList = CommonFrameUtil.getCollectionToArray(dropdownListInfo.hoverWidgetList) || [];

					for (i = 0; i < hoverWidgetList.length; i++) {
						CommonFrameUtil.removeClass(hoverWidgetList[i], UiDefine.ARROWKEY_HOVER_CLASS);
						this.removeLayerKeyFocus(hoverWidgetList[i]);
					}

					UiFrameworkInfo.setDropdownListInfo({});
				}
			}
		}
	};
});