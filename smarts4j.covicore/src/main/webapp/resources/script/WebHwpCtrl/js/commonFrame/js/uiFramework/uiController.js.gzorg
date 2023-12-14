define(function (require) {
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var $ = require("jquery"),
		CommonDefine = require("commonFrameJs/utils/commonDefine"),
		XmlConverter = require("commonFrameJs/uiFramework/xmlConverter"),
		CommonFrameUtil = require("commonFrameJs/utils/util"),
		UiUtil = require("commonFrameJs/uiFramework/uiUtil"),
		FrameworkUtil  = require("commonFrameJs/uiFramework/frameworkUtil"),
		UiDefine = require("commonFrameJs/uiFramework/uiDefine"),
		UiRequester = require("commonFrameJs/uiFramework/uiRequester"),
		UiFrameworkInfo = require("commonFrameJs/uiFramework/uiFrameworkInfo"),
		FontManager = require("commonFrameJs/fontDetect/fontManager"),
		ShortcutStrg = require("commonFrameJs/nls/shortcutStrg"),
		EggTart = require("commonFrameJs/lab/projects/eggTart/eggTart");

	var _langDefine = null,
		_lineStyleNamePrefix = "bdr_style",
		_themeColorClassPostfix = "_background",
		_updateCmd = UiDefine.UPDATE_CMD,
		_eventActionType = UiDefine.EVENT_ACTION_TYPE,
		_disableClass = UiDefine.DISABLE_CLASS,
		_parentDisableClass = UiDefine.PARENT_DISABLE_CLASS,
		_disabledClass = UiDefine.DISABLED_CLASS,
		_hiddenItemClass = UiDefine.HIDDEN_ITEM_CLASS,
		_eventActionNames = UiDefine.EVENT_ACTION_NAMES,
		_uiCommandNames = UiDefine.UI_COMMAND_NAME,
		_toggleUiOptionViewName = _uiCommandNames.TOGGLE_UI_OPTION_VIEW,
		_viewNameListToSave = [UiDefine.SIDEBAR_ID, UiDefine.MENU_BAR_ID, UiDefine.STYLEBAR_ID, UiDefine.STATUSBAR_ID],
		_hideViewClassName = UiDefine.HIDE_VIEW_CLASS,
		_foldViewClassName = UiDefine.FOLD_VIEW_CLASS,
		_subGroupBoxClass = UiDefine.SUB_GROUP_BOX_ELEMENT_CLASS,
		_sampleWrapClass = UiDefine.SAMPLE_WRAP_CLASS,
		_dontCareClass = UiDefine.DONT_CARE_CLASS,
		_spinnerUpperClass = UiDefine.SPINNER_UPPER_ARROW_CLASS,
		_spinnerLowerClass = UiDefine.SPINNER_LOWER_ARROW_CLASS,
		_dropdownSelectListWrapClass = UiDefine.DROPDOWN_SELECT_LIST_WRAP_CLASS,
		_colorPickerClass = UiDefine.COLOR_PICKER_CLASS,
		_dataCommand = UiDefine.DATA_COMMAND,
		_dataUiCommand = UiDefine.DATA_UI_COMMAND,
		_dataUiValue = UiDefine.DATA_UI_VALUE,
		_ignoreRefTreeKeyArr = UiDefine.IGNORE_REF_TREE_KEY_ARR,
		_titleBarId = UiDefine.TITLE_BAR_ID,
		_menuBarId = UiDefine.MENU_BAR_ID,
		_styleBarId = UiDefine.STYLEBAR_ID,
		_sideBarId = UiDefine.SIDEBAR_ID,
		_contextMenuId = UiDefine.CONTEXT_MENU_ID,
		_toolBarContainers = [_titleBarId, _menuBarId, _styleBarId],
		_msgBarClass = UiDefine.MESSAGE_BAR_CLASS,
		_quickMenuClass = UiDefine.TOOL_QUICK_MENU,
		_defineDataValueAttr = UiDefine.DATA_VALUE,
		_defineDataUnitAttr = UiDefine.DATA_UNIT_ATTR,
		_defineDefaultValueAttr = UiDefine.DATA_DEFAULT_VALUE_ATTR,
		_defineDataValueKeyAttr = UiDefine.DATA_VALUE_KEY,
		_defineTitleAttr = UiDefine.DATA_TITLE_ATTR,
		_defineNlsNameAttr = UiDefine.DATA_NLS_NAME_ATTR,
		_defineMatchAttr = UiDefine.DATA_MATCH_ATTR,
		_defineMatchTypeAttr = UiDefine.DATA_MATCH_TYPE_ATTR,
		_defineMatchGroupAttr = UiDefine.DATA_MATCH_GROUP_ATTR,
		_defineDataNameAttr = UiDefine.DATA_NAME,
		_toolLoadingProgress = UiDefine.TOOL_LOADING_PROGRESS,
		_toolFilterDialog = UiDefine.TOOL_FILTER_DIALOG,
		_enableWidgetSelector = '[' + _dataCommand + ']:not(.' + _disableClass + '), ['
								+ _dataUiCommand + ']:not(.' + _disableClass + ')',
		_visibleWidgetSelector = '[' + _dataCommand + ']:not(.' + _hideViewClassName + '), ['
								+ _dataUiCommand + ']:not(.' + _hideViewClassName + ')',
		_alignClassObj = {
			"center": UiDefine.ALIGN_CENTER_CLASS,
			"right": UiDefine.ALIGN_RIGHT_CLASS
		},
		_defineValue = UiDefine.VALUE,
		_onStr = _defineValue.ON,
		_dontCareValue = _defineValue.DONT_CARE,
		_topStr = _defineValue.TOP,
		_leftStr = _defineValue.LEFT,
		_rightStr = _defineValue.RIGHT,
		_autoStr = _defineValue.AUTO,
		_pxStr = _defineValue.PX,
		_uiCallbackMap = {},
		_fontMap = {},
		_uiValueMap = {},
		_uiDisableMap = {},
		_uiHiddenMap = {},
		_uiHiddenItemMap = {},
		_uiLockInfo = {},
		_browserDevice = CommonFrameUtil.getBrowserDevice(),
		_uri = CommonFrameUtil.parseURL(CommonFrameUtil.addParameterToUrl()),
		_isViewMode = false,
		_colorPickerThemeMap = UiDefine.COLOR_PICKER_THEME,
		_uiOptionViewNameArr = [_titleBarId, _menuBarId, _styleBarId, _sideBarId,
			_eventActionNames.E_RULER, UiDefine.FORMULA_BAR_PARENT],
		_foldToggleUiCmds = [_uiCommandNames.FOLD, _uiCommandNames.TOGGLE],
		_watcherMode = UiDefine.APP_UI_MODE.WATCHER,
		_watcherModeEnableCommands = UiDefine.ENABLE_COMMANDS_IN_WATCHER_MODE,
		_watcherModeEnableContexts = UiDefine.ENABLE_CONTEXT_MENU_IN_WATCHER_MODE,
		_msgBarElInfo = {},
		_quickMenuMargin = 20,
		_dialogLayerHeight = 0,
		_dialogVScrollClass = UiDefine.DIALOG_V_SCROLL_CLASS,
		needExtendGeneralTypeA = true,
		_uiCmdBtnInfo = null,
		_toastMessageWrap = null,
		_toastTimer = null,
		_lazyConvertTimer = null,
		_lazyConvertInfo = null,
		_mouseDownTarget = null,
		_menuScrollInfo = {},
		_unsupportedDataList = [],
		_removeShapeArr = null,
		_msgDialogList = UiDefine.MESSAGE_DIALOG_LIST,
		_useChangeUiModeModules = UiDefine.USE_CHANGE_UI_MODE_MODULE_NAMES,
		_fontElListLen = 0,
		_uiOptionsArr, _isHideUiOptionView, _serverProperty, _prevWindowSize, _webFontInfo, _appMode,
		_callbackFnConvertingAfter, _isAutoProgressOn, _cachedDescToCollaboView, _viewModeCssLinkEl, _isBoxOutOfBoundary,
		_customXmlFileName, _allWidgetNameArr, _fontGroupInfo, _sampleValueKeyInfo, _offlineStateNlsArr, _modelessFragment;

	/**
	 * 현재 skin, module 상황에 맞는 dummy image 반환
	 * @param {String} baseDir
	 * @param {String} skinName
	 * @returns {Element}
	 */
	function _getImageByDummy(baseDir, skinName) {
		var moduleName = UiFrameworkInfo.getModuleName() || "webword",
			langCode = _langDefine.LangCode,
			dummyImgSrcArr = UiDefine.DUMMY_IMG_COMMON_LIST,
			dummyImgDefaultSkinObj = UiDefine.DUMMY_IMG_DEFAULT_SKIN_LIST,
			dummyImgModuleList = UiDefine.DUMMY_IMG_MODULE_LIST[moduleName],
			dummyWrapEl = CommonFrameUtil.createDomEl("div", {id: UiDefine.DUMMY_WRAP_ID}, null),
			extendImgSrcArr = [],
			defaultLangCode = "en",
			isTypeASkin = skinName === UiDefine.SKIN_TYPE_A,
			pathname = window.location.pathname,
			isTestMode = pathname.indexOf("framework") !== -1,
			dummyImgPath = baseDir + "skins/" + skinName + "/images/",
			dummyImgVersion = (window.__hctfwoVersion ? "?" + window.__hctfwoVersion : ""),
			dummyImgLangList, dummyImgDefaultLangList, i, len, dummyEl, dummyItem, typeExt, typeIdx, subPath;

		// TestMode 에서 접근할때는 URL 을 재조정 해준다.
		if (isTestMode) {
			subPath = pathname.indexOf("webFramework") !== -1;
			dummyImgPath = (subPath ? "/framework/" : "/") + dummyImgPath;
		}

		// 모듈과 상관없이 언어에 따라 더미로 추가할 이미지리스트를 가지고 온다.
		// 만약 정의되지 않은 언어라면, en 에 해당하는 이미지 리스트를 기본값으로 본다.
		dummyImgLangList = UiDefine.DUMMY_IMG_LANG_LIST[langCode];

		if (!dummyImgLangList || dummyImgLangList.length <= 0) {
			dummyImgLangList = UiDefine.DUMMY_IMG_LANG_LIST[defaultLangCode];
		}

		// 스킨별 이미지 리스트를 추가한다.
		if (isTypeASkin) {
			// type_a skin 용 이미지 리스트와 공용 언어에 따른 이미지 리스트를 추가한다.
			extendImgSrcArr = extendImgSrcArr.concat(UiDefine.DUMMY_IMG_TYPEA_SKIN_LIST);
			extendImgSrcArr = extendImgSrcArr.concat(dummyImgLangList);
			typeExt = "svg";
		} else {
			// 공용 언어에 따른 이미지 리스트를 추가한다.
			typeExt = "png";
			len = dummyImgLangList.length;

			for (i = 0; i < len; ++i) {
				// default skin 에서는 hover 와 관련된 이미지를 제외하고 추가한다.
				if (dummyImgLangList[i].indexOf("hover") === -1) {
					extendImgSrcArr.push(dummyImgLangList[i]);
				}
			}

			// default skin 용 이미지 리스트를 추가한다.
			extendImgSrcArr = extendImgSrcArr.concat(dummyImgDefaultSkinObj.base);

			// default skin 용 언어에 따른 리스트를 추가한다.
			dummyImgDefaultLangList = dummyImgDefaultSkinObj[langCode] || dummyImgDefaultSkinObj[defaultLangCode];
			extendImgSrcArr = extendImgSrcArr.concat(dummyImgDefaultLangList);
		}

		// 언어와 상관없이 모듈에 따라 더미로 추가할 이미지가 있다면 concat 함
		if (dummyImgModuleList && dummyImgModuleList.length > 0) {
			extendImgSrcArr = extendImgSrcArr.concat(dummyImgModuleList);
		}

		// 최종적으로 extend 할 이미지 list 가 완성되면, default 리스트와 concat 함
		dummyImgSrcArr = dummyImgSrcArr.concat(extendImgSrcArr);

		len = dummyImgSrcArr.length;

		for (i = 0; i < len; ++i) {
			// dummy 이미지의 확장자가 스킨별 확장자 (skinExt) 이면, 스킨별 확장자로 대체하여 할당한다.
			typeIdx = dummyImgSrcArr[i].lastIndexOf(".skinExt");

			if (typeIdx !== -1) {
				dummyItem = dummyImgSrcArr[i].substring(0, typeIdx + 1) + typeExt;
			} else {
				dummyItem = dummyImgSrcArr[i];
			}

			dummyEl = CommonFrameUtil.createDomEl("div", null, null);
			dummyEl.style.backgroundImage = "url(" + dummyImgPath + dummyItem + dummyImgVersion + ")";
			dummyWrapEl.appendChild(dummyEl);
		}

		return dummyWrapEl;
	}

	function _getAllWidgetNameArr() {
		var widgetNameToValueKeyMap;

		if (!_allWidgetNameArr) {
			widgetNameToValueKeyMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_NAME_TO_VALUE_KEY_MAP);
			_allWidgetNameArr = widgetNameToValueKeyMap ? Object.keys(widgetNameToValueKeyMap) : [];
		}

		return _allWidgetNameArr;
	}

	/**
	 * uiController 가 가지고 있는 전역 변수를 초기화해준다.
	 */
	function _initGlobalVariable() {
		_menuScrollInfo = {};
		_removeShapeArr = null;
		_msgBarElInfo = {};
		_cachedDescToCollaboView = null;
		_customXmlFileName = null;
		_allWidgetNameArr = null;
		_modelessFragment = null;
		_sampleValueKeyInfo = {};
		_uiLockInfo = {};
	}

	/**
	 * Dialog Contents Layer 의 좌측 위치를 화면의 중앙으로 설정해준다.
	 * @param {Element} dialogLayer		- Dialog Contents Layer
	 * @param {String=} align				- "left" "center"(default) "right"
	 */
	function _setDialogLeftPosition(dialogLayer, align) {
		if (!dialogLayer) {
			return;
		}

		var style = dialogLayer.style,
			winWidth, leftPos;

		if (align === _leftStr) {
			leftPos = parseFloat(style.marginLeft) * -1;
		} else {
			winWidth = dialogLayer.ownerDocument.getElementById(UiDefine.WRAP_ID).offsetWidth;

			if (align === _rightStr) {
				leftPos = winWidth + parseFloat(style.marginLeft);
			} else {
				leftPos = winWidth / 2;
			}
		}

		if (style.left !== leftPos + _pxStr) {
			style.left = leftPos + _pxStr;
		}
	}

	/**
	 * 잠겨져 있는 widget 정보 갱신
	 * (이후 해제될 때 마지막에 받았던 enable/disable 상태로 복구하기 위해 저장)
	 * @param {String} widgetName
	 * @param {Boolean} isDisable		- true: disable, false: enable, null(undefined) remove
	 * @returns {Boolean} success (true: 현재 lock 상태 / false: lock 상태 아님 - 아무 변경 없었음)
	 */
	function _updateUiLockState (widgetName, isDisable) {
		var isLockState = (_uiLockInfo[widgetName] != null);

		if (isLockState) {
			if (isDisable != null) {
				_uiLockInfo[widgetName] = isDisable;
			} else {
				delete _uiLockInfo[widgetName];
			}
		}

		return isLockState;
	}

	var UiController = $.extend({
		/**
		 * private method (with context)
		 */

		/*******************************************************************************
		 * (UiController 내부에서만 사용)
		 * 외부에서는 UI 조작 method 직접 호출 금지. UiController.updateUi() 사용.
		 ******************************************************************************/
		_getSkinName: function() {
			var skinName = _uri.queryKey["skin"];

			if (!skinName) {
				// parameter 에 skinName 이 없는 경우, server.property 확인
				skinName = this.getServerOptions().skin || UiDefine.SKIN_DEFAULT;
			}

			return skinName;
		},

		_getViewNode: function(viewName) {
			var viewNode = this.getViewElement(viewName),
				widgetMap, lazyConvertXmlInfo, dlgConvertInfo, commandName, commandEl, el, result, contentWindow,
				names, len, i, eventAction, valueObj, descObj, descVal, elFragmentInfo, fontElList;

			if (!viewNode && _lazyConvertInfo && !_lazyConvertInfo.isConvertEnd) {
				lazyConvertXmlInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.LAZY_CONVERT_XML_INFO);

				if (lazyConvertXmlInfo && lazyConvertXmlInfo[viewName]) {
					dlgConvertInfo = lazyConvertXmlInfo[viewName];
					delete lazyConvertXmlInfo[viewName];

					result = XmlConverter.lazyConvertXmlToDom(dlgConvertInfo);
					el = result.elList[0];

					if (el) {
						dlgConvertInfo.parentInfo.parentEl.appendChild(el);

						contentWindow = UiFrameworkInfo.getContentWindow();
						widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP);

						elFragmentInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.EL_FRAGMENT_INFO);
						fontElList = elFragmentInfo && elFragmentInfo.sampleItemMap[_eventActionNames.FONT_NAME];

						if (fontElList && _fontElListLen < fontElList.length) {
							len = fontElList.length;

							for (i = _fontElListLen; i < len; ++i) {
								FrameworkUtil.setValueToFontEl(FontManager.getFontList(), fontElList[i], _fontMap);
							}

							_fontElListLen = len;
						}

						this._initUiValue(contentWindow.document, widgetMap, UiFrameworkInfo.getRefTree());

						commandEl = el.querySelector('[' + _dataCommand + ']');
						if (commandEl) {
							commandName = commandEl.getAttribute(_dataCommand);
							this._updateWidgetByUiValueMap(commandName);
						}

						// panel update
						names = result.panelNames;
						len = names.length;

						for (i = 0; i < len; i++) {
							this._updateWidgetByUiValueMap(names[i]);
						}

						// description update
						descObj = _uiValueMap[_uiCommandNames.DESCRIPTION];

						if (descObj && CommonFrameUtil.isObject(descObj)) {
							valueObj = {};
							names = result.updateDescNames;
							len = names.length;

							for (i = 0; i < len; i++) {
								descVal = descObj[names[i]];

								if (CommonFrameUtil.isString(descVal)) {
									valueObj[names[i]] = descVal;
								}
							}

							if (!CommonFrameUtil.isEmptyObject(valueObj)) {
								eventAction = {cmd:_updateCmd, type:_eventActionType.UI, name:_uiCommandNames.DESCRIPTION, value:valueObj};
								this._executeEventAction(eventAction);
							}
						}
					}

					if (CommonFrameUtil.isEmptyObject(lazyConvertXmlInfo)) {
						_lazyConvertInfo.isConvertEnd = true;

						if (_removeShapeArr) {
							this.removeShapeUiNode(_removeShapeArr);
							_removeShapeArr = null;
						}
					}

					viewNode = el;
				}
			}

			if (!viewName) {
				console.log('[Info] Update Ui : "' + viewName + '" is not found.');
			}

			return viewNode;
		},

		/**
		 * dropdown 이 현재 화면에서 벗어났다고 판단되는 경우 조정된 top, bottom, left 값 반환
		 * @param {Element} el
		 * @param {String} arrowDirection		- arrow 방향
		 * @param {Object} layerMenu			- layer object
		 * @param {Boolean} isToggle			- 드롭다운 토글 여부
		 * @returns {Object} {top, bottom,left}
		 * @private
		 */
		_getPosIfDropdownOverflow: function(el, arrowDirection, layerMenu, isToggle) {
			if (!(el && el.childNodes.length > 2)) {
				return null;
			}

			var wrapNode = UiFrameworkInfo.getInfo(UiFrameworkInfo.WRAP_NODE),
				containerNode = UiUtil.findContainerNodeToParent(el, wrapNode),
				offset, parentNode, parentOffset, boxEl, boxMarginTop, boxMarginBottom, boxMarginSize, boxBorderSize,
				boxElOffsetHeight, boxElOffsetWidth, sidebarEl, statusBarEl, parentDropdown, isSideBar, isStatusBar,
				isDialog, isColorPicker, contentWindow, baseTopOffset, screenHeight, baseTarget, top, bottom, left,
				pos, targetHeight, targetWidth, baseOffset, scrollPanel, doRevertDropdownPos, targetElToVScroll,
				sheetTabBarEl, hasVScrollClass, maxHeight, isOutOfBoundary, widgetMap, collaboView, scrollBarWidth;

			if (!containerNode) {
				return null;
			}

			offset = el.getBoundingClientRect();
			parentNode = el.parentNode;
			parentOffset = (parentNode && parentNode.getBoundingClientRect()) || null;
			boxEl = el.lastElementChild;
			boxMarginTop = parseInt(CommonFrameUtil.getCurrentStyle(boxEl, "marginTop") || 0, 10);
			boxMarginBottom = parseInt(CommonFrameUtil.getCurrentStyle(boxEl, "marginBottom") || 0, 10);
			boxMarginSize = boxMarginTop + boxMarginBottom;
			boxBorderSize = parseInt(CommonFrameUtil.getCurrentStyle(boxEl, "borderWidth") || 0, 10) * 2;
			boxElOffsetHeight = boxEl.offsetHeight + boxMarginSize + boxBorderSize;
			boxElOffsetWidth = boxEl.offsetWidth;

			sidebarEl = UiFrameworkInfo.getContainerNode(_sideBarId);
			statusBarEl = UiFrameworkInfo.getContainerNode(UiDefine.STATUSBAR_ID);
			sheetTabBarEl = UiFrameworkInfo.getContainerNode(UiDefine.SHEET_TAB_BAR_ID);
			parentDropdown = layerMenu && CommonFrameUtil.findParentNode(el, "." + _dropdownSelectListWrapClass);

			isSideBar = (sidebarEl && containerNode === sidebarEl);
			isStatusBar = (statusBarEl && containerNode === statusBarEl);
			isDialog = (UiUtil.isDialogContainer(containerNode.id));
			isColorPicker = CommonFrameUtil.hasClass(boxEl, _colorPickerClass) || CommonFrameUtil.hasClass(parentDropdown, _colorPickerClass);
			contentWindow = UiFrameworkInfo.getContentWindow();
			baseTopOffset = 0;
			screenHeight = contentWindow.innerHeight - (statusBarEl ? statusBarEl.offsetHeight : 0) - (sheetTabBarEl ? sheetTabBarEl.offsetHeight : 0);

			if (arrowDirection === _leftStr || arrowDirection === _defineValue.RIGHT) {
				// arrow 의 방향이 "left", "right"
				targetHeight = offset.top + boxElOffsetHeight;
				targetWidth = offset.right + boxElOffsetWidth;
			} else {
				// arrow 의 방향이 "down", "up"
				targetHeight = offset.bottom + boxElOffsetHeight;
				targetWidth = offset.left + boxElOffsetWidth;
			}

			// 기준점의 top 좌표 결정
			// 사이드바의 경우, 사이드바가 기준이고, 그 외에는 현재 자신의 window 가 기준임.
			if (isSideBar) {
				baseTarget = containerNode;
				baseOffset = baseTarget.getBoundingClientRect();
				baseTopOffset = baseOffset.top || 0;
				scrollPanel = baseTarget.querySelector("[" + UiDefine.DATA_SCROLL_CONTENT_ATTR + "=" + _sideBarId + "]") || containerNode;

				if (!isColorPicker) {
					// screenHeight 에서 협업자 목록 높이 제외 (colorPicker 는 별도 스펙대로 동작하므로 무관)
					widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP);
					collaboView = widgetMap[UiDefine.COLLABO_USERS_VIEW] && widgetMap[UiDefine.COLLABO_USERS_VIEW][0];

					if (!collaboView || UiUtil.isHidden(collaboView)) {
						collaboView = widgetMap[UiDefine.NO_COLLABO_USERS_VIEW] && widgetMap[UiDefine.NO_COLLABO_USERS_VIEW][0];
					}

					if (collaboView && !UiUtil.isHidden(collaboView)) {
						screenHeight -= collaboView.offsetHeight;
					}
				}
			}

			if (!isNaN(offset.top)) {
				isOutOfBoundary = !!(targetHeight > screenHeight);
				doRevertDropdownPos = (!isStatusBar && isOutOfBoundary && offset.top - boxElOffsetHeight < baseTopOffset);

				if (arrowDirection === "up") {
					if (offset.top - boxElOffsetHeight > baseTopOffset) {
						top = _autoStr;
						bottom = offset.height;
					}
				} else if (arrowDirection === "down") {
					if (targetHeight > screenHeight) {
						top = _autoStr;
						bottom = offset.height;
					}

					if (isDialog) {
						targetElToVScroll = FrameworkUtil.getVScrollElement(UiUtil.findContainerInfoToParent(el).topNode);

						if (targetElToVScroll) {
							hasVScrollClass = CommonFrameUtil.hasClass(targetElToVScroll, _dialogVScrollClass);
						}
					}

					// 원상복귀하는 기준
					// 1. dropdown box 를 위로 뒤집었더니, 자신의 기준점에 부딫힘
					//    1) dialog 인 경우, v scroll 이 생기지 않았으면 dropdown box 에 scroll 이 생기도록 max height 지정
					// 2. dialog 이면서,  1.이 아닌 경우, 2가지 선택지가 있음
					//    1) v scroll 이 생긴 경우 - menu box 의 가장 윗부분을 기준으로 부딫힌 dropdown box 만 뒤집어야함
					//    2) v scroll 이 생기지 않은 경우 - 기준점(자신의 window)에 부딫히지 않으면 뒤집을 필요 없음
					if (doRevertDropdownPos) {
						// 1번 케이스
						top = null;
						bottom = 0;
					}

					if (isDialog) {
						if (doRevertDropdownPos) {
							if (!hasVScrollClass) {
								// 1.1) 케이스
								maxHeight = window.innerHeight - offset.bottom;
								boxEl.style.maxHeight = maxHeight + _pxStr;
							}
						} else if (hasVScrollClass) {
							baseTopOffset = targetElToVScroll.getBoundingClientRect().top;

							if (offset.top - boxElOffsetHeight < baseTopOffset) {
								// 2.1) 케이스
								top = null;
								bottom = 0;
							}
						}
					}
				} else if (isOutOfBoundary) {
					if (!isSideBar) {
						top = screenHeight - targetHeight;
					}
				}

				if (isSideBar && isColorPicker) {
					bottom = 0;

					if (arrowDirection === "up" || arrowDirection === "down") {
						top = offset.top + offset.height;

						if (scrollPanel && scrollPanel !== baseTarget) {
							baseTarget = scrollPanel;
							baseOffset = baseTarget.getBoundingClientRect();
							baseTopOffset = baseOffset.top || 0;
						}

						if (isToggle) {
							/**
							 * 드롭다운 박스를 처음 open 하거나, 드롭다운 박스 안 탭 메뉴 등을 실행해서 높이가 달라지는 경우는
							 * 이곳에서 출력될 포지션을 결정한다.
							 */

							// 드롭다운 박스가 사이드바 패널 밖으로 (스크롤 길이까지 포함) 넘어가는 경우 (뒤집어짐)
							if (baseTopOffset + CommonFrameUtil.getScrollSize(baseTarget).y < targetHeight + baseTarget.scrollTop) {
								top = offset.top - boxElOffsetHeight;
							// 드롭다운 박스를 처음 open 할 때, 드롭다운 박스 영역이 가려져 있는 경우 (스크린 하단을 넘어가는 경우)
							} else if (isOutOfBoundary) {
								if (offset.bottom < baseTopOffset) {
									// 드롭다운 위젯이 화면 위로 숨겨진 상황에서는 사이드바 상단에 고정시킨다.
									top = baseTopOffset;
								} else if (offset.bottom > baseTopOffset + baseOffset.height) {
									// 드롭다운 위젯이 사이드바 컨텐츠 하단 영역 아래로 숨겨지거나, 걸쳐져 있는 상황에서는 사이드바 하단에 고정시킨다.
									top = baseTopOffset + baseOffset.height - boxElOffsetHeight;
								} else {
									// 예외적인 사항이 아니면, 드롭다운 박스가 가려지더라도 그대로 출력한다. (스크롤을 이동해서 드롭다운 박스 확인 가능한 상태)
									_isBoxOutOfBoundary = true;
								}
							} else {
								// 드롭다운 박스가 스크린 하단에 가져지지 않고 출력되는 경우
								if (offset.bottom < baseTopOffset) {
									// 드롭다운 위젯이 화면 위로 숨겨진 상황에서는 사이드바 상단에 고정시킨다.
									top = baseTopOffset;
								} else if (targetHeight > baseTopOffset + baseOffset.height) {
									// 스크린 하단을 넘지 않지만, 사이드바 컨텐츠 하단 영역을 넘어선 경우는 isOutOfBoundary 로 간주한다.
									_isBoxOutOfBoundary = true;
								}
							}
						} else {
							/**
							 * 아래의 if 조건문은 드롭다운 박스가 위치하는 경우를 순서에 따라 적용한 것이므로
							 * 순서를 유지하는 것이 중요합니다.
							 */

							// 드롭다운 위젯 버튼이 사이드바 상단에 부딪히는 경우
							if (offset.bottom < baseTopOffset) {
								top = baseTopOffset;
							// 드롭다운 위젯 버튼이 사이드바 하단에 부딪히는 경우
							} else if (offset.top > baseTopOffset + baseOffset.height) {
								top = baseTopOffset + baseOffset.height - boxElOffsetHeight;
							// 드롭다운 박스가 사이드바 패널 밖으로 넘어가는 경우 (뒤집어짐)
							} else if (baseTopOffset + CommonFrameUtil.getScrollSize(baseTarget).y < targetHeight + baseTarget.scrollTop) {
								top = offset.top - boxElOffsetHeight;
							} else if (targetHeight > baseTopOffset + baseOffset.height) {
								//처음 클릭하여 열었을 때, 드롭다운 박스가 사이드바 하단에 가려져 있었을 경우
								if (_isBoxOutOfBoundary) {
									if (offset.bottom > baseTopOffset + baseOffset.height) {
										top = baseTopOffset + baseOffset.height - boxElOffsetHeight;
									}
								// 처음 클릭하여 열었을 때, 드롭다운 박스가 사이드바 하단에 가려져 있지 않았을 경우
								} else {
									top = baseTopOffset + baseOffset.height - boxElOffsetHeight;
								}
							} else {
								_isBoxOutOfBoundary = false;
							}
						}
					} else {
						// 드롭다운 박스가 브라우저 화면 밖으로 넘어가고, 자신의 기준점에도 부딪히지 않는 경우 (뒤집어짐)
						if (isOutOfBoundary && !doRevertDropdownPos) {
							top = -boxElOffsetHeight;
						}
					}
				}
			}

			if (!isNaN(offset.left)) {
				scrollBarWidth = 0;

				if (isSideBar) {
					if (isColorPicker) {
						left = offset.left + 2;
					}

					if (CommonFrameUtil.hasScroll(scrollPanel, _topStr)) {
						scrollBarWidth = UiDefine.SIDEBAR_RIGHT_MARGIN;
					}
				}

				if (arrowDirection === _leftStr) {
					if (!(isSideBar && parentOffset && sidebarEl.getBoundingClientRect().left > parentOffset.left - boxElOffsetWidth)
						&& offset.left > boxElOffsetWidth) {
						left = -1 * (offset.width + boxElOffsetWidth) - 2;
					}
				} else if (arrowDirection === _defineValue.RIGHT) {
					if (targetWidth > contentWindow.innerWidth) {
						left = -1 * (offset.width + boxElOffsetWidth) - 2;
					}
				} else if (targetWidth > contentWindow.innerWidth - scrollBarWidth
					&& !CommonFrameUtil.hasClass(el, UiDefine.COLLABO_USERS_LIST)) {
					left = contentWindow.innerWidth - (isSideBar && isColorPicker ? boxElOffsetWidth : targetWidth) - UiDefine.SIDEBAR_RIGHT_MARGIN;
				}
			}

			if (left < 0 && parentDropdown && parentDropdown.previousSibling === layerMenu) {
				if (arrowDirection === _leftStr || arrowDirection === _defineValue.RIGHT) {
					left = left + parentDropdown.getBoundingClientRect().left - offset.left;
				} else {
					left = parentDropdown.getBoundingClientRect().left - offset.left - boxElOffsetWidth;
				}
			}

			pos = {
				top: top ? (typeof top === "number" ? CommonFrameUtil.getRoundNumber(top, 0) + _pxStr : top) : null,
				bottom: bottom ? CommonFrameUtil.getRoundNumber(bottom, 0) + _pxStr : null,
				left: left ? CommonFrameUtil.getRoundNumber(left, 0) + _pxStr : null
			};

			return pos;
		},

		/**
		 * target과 화면을 기준으로 tooltip 의 위치(top, left) 를 반환
		 * @param {Element} target							- target
		 * @param {Element=} tooltipWrapEl					- tooltipWrap
		 * @param {Window=} contentWindow					- (미지정시 window 사용)
		 * @returns {Object} {top,left}
		 * @private
		 */
		_getPosTooltip: function (target, tooltipWrapEl, contentWindow) {
			if (!target) {
				return null;
			}

			var offset = target.getBoundingClientRect(),
				targetTop = offset.top,
				targetLeft = offset.left,
				targetHeight = offset.height,
				targetWidth = offset.width,
				pos = null,
				tooltipHeight, tooltipWidth, tooltipOffsetTop, tooltipOffsetLeft;

			tooltipWrapEl = tooltipWrapEl || this.getToolElement(UiDefine.TOOL_TOOLTIP);
			contentWindow = contentWindow || window;

			if (tooltipWrapEl) {
				tooltipHeight = CommonFrameUtil.getOffsetHeight(tooltipWrapEl);
				tooltipWidth = CommonFrameUtil.getOffsetWidth(tooltipWrapEl);
				tooltipOffsetTop = targetTop + targetHeight;
				tooltipOffsetLeft = targetLeft;

				if (tooltipOffsetLeft + tooltipWidth > contentWindow.innerWidth) {
					tooltipOffsetLeft = targetLeft - tooltipWidth + targetWidth;
				}

				if (tooltipOffsetTop + tooltipHeight > contentWindow.innerHeight) {
					tooltipOffsetTop = targetTop - tooltipHeight;
				}

				pos = {
					top: tooltipOffsetTop,
					left: tooltipOffsetLeft
				};
			}

			return pos;
		},

		/**
		 * 버튼을 켜주는 함수
		 * @param {Element} target		- on 시킬 대상 버튼
		 * @returns {void}
		 */
		_setButtonOn: function(target) {
			this._setButtonDontCareOff(target);
			CommonFrameUtil.addClass(target, _onStr);
		},

		/**
		 * 버튼을 꺼주는 함수
		 * @param {Element} target		- off 시킬 대상 버튼
		 * @returns {void}
		 */
		_setButtonOff: function(target) {
			this._setButtonDontCareOff(target);
			CommonFrameUtil.removeClass(target, _onStr);
		},

		/**
		 * 버튼을 DontCare 상태로 전환하는 함수
		 * @param {Element} target		- dontCare 상태로 전환할 대상 버튼
		 * @returns {void}
		 */
		_setButtonDontCare: function(target) {
			if (!UiUtil.isButtonDontCare(target)) {
				this._setButtonOff(target);
				CommonFrameUtil.addClass(target, _dontCareClass);
			}
		},

		/**
		 * 버튼의 DontCare 상태를 해제하는 함수
		 * @param {Element} target		- dontCare 상태를 해제할 대상 버튼
		 * @returns {void}
		 */
		_setButtonDontCareOff: function(target) {
			if (UiUtil.isButtonDontCare(target)) {
				CommonFrameUtil.removeClass(target, _dontCareClass);
			}
		},

		/**
		 * widget 을 비활성화 시키는 함수
		 * @param {Element} target				- off 시킬 대상 버튼
		 * @param {Boolean=} isParentDisable	- 상위의 disable 처리에 의해 disable 되는 경우 true 지정
		 * @returns {Boolean}
		 */
		_setDisable: function(target, isParentDisable) {
			var result = false,
				inputEl, childDisableTargets, len, i;

			if (!CommonFrameUtil.hasClass(target, _disableClass)) {
				CommonFrameUtil.addClass(target, _disableClass);
				result = true;
			}

			if (isParentDisable) {
				CommonFrameUtil.addClass(target, _parentDisableClass);

				if (UiUtil.isPanel(target) && CommonFrameUtil.hasClass(target, _disabledClass)) {
					// 상위가 disable 되는 경우 하위 panel 의 disabled 는 제거 (이후 같이 enable 처리)
					CommonFrameUtil.removeClass(target, _disabledClass);
				}

			} else {
				CommonFrameUtil.addClass(target, _disabledClass);

				if (UiUtil.isPanel(target) || UiUtil.isContainerView(target)) {
					// 하위에 disable 처리 추가
					childDisableTargets = UiUtil.findCommandWidgets(target).concat(UiUtil.findNamePanels(target));
					len = childDisableTargets.length;

					for (i = 0; i < len; i++) {
						this._setDisable(childDisableTargets[i], true);
					}
				}
			}

			if (UiUtil.isInputWrapWidget(target)) {
				inputEl = UiUtil.getInputElementByWidget(target);
				if (inputEl) {
					inputEl.setAttribute(UiDefine.DISABLED_ATTR, UiDefine.DISABLED_ATTR);
				}
			}

			this.initFocusWidgetInfoIfDisabledHidden(target);

			return result;
		},

		/**
		 * widget 을 활성화 시키는 함수
		 * @param {Element} target				- on 시킬 대상 버튼
		 * @param {Boolean=} isParentEnable	- 상위의 enable 처리에 의해 enable 되는 경우 true 지정
		 * @returns {Boolean}
		 */
		_setEnable: function(target, isParentEnable) {
			var result = false,
				removeDisable = false,
				inputEl, childEnableTargets, len, i;

			if (isParentEnable) {
				// 상위에 의해 disable 해제
				CommonFrameUtil.removeClass(target, _parentDisableClass);

				if (!CommonFrameUtil.hasClass(target, _disabledClass)) {
					// 현재 target 이 disabled 가 아니라면 최종 해제
					removeDisable = true;
				}

			} else {
				// 현재 target 에 대해서 disable 해제 시도 (disabled 는 해제)
				CommonFrameUtil.removeClass(target, _disabledClass);

				if (!CommonFrameUtil.hasClass(target, _parentDisableClass)) {
					// 상위에 disable 된 경우가 아니라면 최종 해제
					removeDisable = true;

					if (UiUtil.isPanel(target) || UiUtil.isContainerView(target)) {
						// 하위에 enable 처리 추가
						childEnableTargets = UiUtil.findCommandWidgets(target).concat(UiUtil.findNamePanels(target));
						len = childEnableTargets.length;

						for (i = 0; i < len; i++) {
							this._setEnable(childEnableTargets[i], true);
						}
					}
				}
			}

			if (removeDisable && CommonFrameUtil.hasClass(target, _disableClass)) {
				CommonFrameUtil.removeClass(target, _disableClass);

				if (UiUtil.isInputWrapWidget(target)) {
					inputEl = UiUtil.getInputElementByWidget(target);
					if (inputEl) {
						inputEl.removeAttribute(UiDefine.DISABLED_ATTR);
					}
				}
				result = true;
			}

			return result;
		},

		/**
		 * widget 을 감추는 함수
		 * @param {Element} target		- off 시킬 대상 버튼
		 * @returns {Boolean}
		 */
		_setHidden: function(target) {
			var result = false;

			if (!CommonFrameUtil.hasClass(target, _hideViewClassName)) {
				CommonFrameUtil.addClass(target, _hideViewClassName);
				result = true;
			}

			return result;
		},

		/**
		 * widget 을 보여주는 함수
		 * @param {Element} target		- on 시킬 대상 버튼
		 * @returns {Boolean}
		 */
		_setVisible: function(target) {
			var result = false;

			if (CommonFrameUtil.hasClass(target, _hideViewClassName)) {
				CommonFrameUtil.removeClass(target, _hideViewClassName);
				this._updateListBoxScroll(target);
				result = true;
			}

			return result;
		},

		/**
		 * widget 에 hidden item class 를 세팅하는 함수
		 * @param {Element} target		- hidden item class 를 세팅할 대상
		 * @returns {Boolean}
		 */
		_setHiddenItem: function (target) {
			var result = false;

			if (!CommonFrameUtil.hasClass(target, _hiddenItemClass)) {
				CommonFrameUtil.addClass(target, _hiddenItemClass);
				result = true;
			}

			return result;
		},

		/**
		 * widget 에 hidden item class 를 삭제하는 함수
		 * @param {Element} target		- hidden item class 를 삭제할 대상
		 * @returns {Boolean}
		 */
		_setVisibleItem: function (target) {
			var result = false;

			if (CommonFrameUtil.hasClass(target, _hiddenItemClass)) {
				CommonFrameUtil.removeClass(target, _hiddenItemClass);
				result = true;
			}

			return result;
		},

		/**
		 * listBox 의 scroll 을 갱신하는 함수
		 * @param {Element} target		- 보여질 view target
		 * @returns {void}
		 */
		_updateListBoxScroll: function (target) {
			var containerInfo = UiUtil.findContainerInfoToParent(target),
				topNode = containerInfo.topNode,
				dlgShowingInfo = UiFrameworkInfo.getDialogShowing(),
				dlgNode = dlgShowingInfo.viewNode,
				dlgContainerId, dlgName, curRefTree, curEl, panelNameArr,
				dataName, i, length, offsetTargetLimit;

			var __getNeedUpdatedListBoxArr = function (refTree) {
				var listBoxArr = [],
					viewKeys, viewKey, viewNode, refItem, keyLen, j;

				viewKeys = Object.keys(refTree);
				viewKeys = CommonFrameUtil.without(viewKeys, _ignoreRefTreeKeyArr);
				keyLen = viewKeys.length;

				if (viewKeys && keyLen) {
					for (j = 0; j < keyLen; j++) {
						viewKey = viewKeys[j];
						refItem = refTree[viewKey];
						viewNode = refItem ? refItem.ref : null;

						if (viewNode && !UiUtil.isHidden(viewNode)) {
							if (UiUtil.isListBox(viewNode)) {
								listBoxArr.push(viewNode);
							}

							listBoxArr = listBoxArr.concat(__getNeedUpdatedListBoxArr(refItem));
						}
					}
				}

				return listBoxArr;
			};

			// 보여지고 있는 dialog 내의 listBox 를 기준으로 scroll 을 갱신한다.
			if (!(target && dlgNode && topNode === dlgNode)) {
				return;
			}

			panelNameArr = [];
			curEl = target;

			while (curEl) {
				// 상위 panel 중 하나라도 hidden 된 상태면 종료한다.
				if (UiUtil.isHidden(curEl)) {
					return;
				}

				if (curEl === topNode) {
					break;
				}

				dataName = curEl.getAttribute(_defineDataNameAttr) || curEl.getAttribute(_defineMatchAttr);
				if (dataName) {
					panelNameArr.push(dataName);
				}

				curEl = curEl.parentElement;
			}

			dlgContainerId = containerInfo.container.id;
			dlgName = dlgShowingInfo.value;
			curRefTree = UiFrameworkInfo.getRefTree()[dlgContainerId][dlgName];
			length = panelNameArr.length;

			// 기록한 name 의 순서에 의해 현재 갱신 대상 refTree 를 구한다.
			for (i = length - 1; i > 0; i--) {
				if (!curRefTree) {
					break;
				}

				curRefTree = curRefTree[panelNameArr[i]];
			}

			if (curRefTree) {
				window.setTimeout(function () {
					var updateListBoxArr = __getNeedUpdatedListBoxArr(curRefTree),
						listBoxEl, onData, scrollTopVal;

					length = updateListBoxArr.length;
					for (i = 0; i < length; i++) {
						listBoxEl = updateListBoxArr[i];

						if (CommonFrameUtil.hasScroll(listBoxEl, _topStr)) {
							onData = listBoxEl.getElementsByClassName(_onStr);

							if (onData && onData.length) {
								onData = onData[0];
								offsetTargetLimit = UiUtil.hasClassToTarget(listBoxEl, UiDefine.INLINE_PANEL_CLASS) ? listBoxEl.offsetParent : listBoxEl;

								scrollTopVal = CommonFrameUtil.getOffsetTop(onData, offsetTargetLimit);
								scrollTopVal -= CommonFrameUtil.getOffsetHeight(listBoxEl) - CommonFrameUtil.getOffsetHeight(onData) - UiDefine.DROPDOWN_DATA_MARGIN;
							} else {
								scrollTopVal = 0;
							}

							listBoxEl.scrollTop = Math.max(0, scrollTopVal);
						}
					}
				}, 0);
			}
		},

		/**
		 * sampleItem 이동 버튼의 활성화/비활성화 처리 (현재 선택한 sampleItem 에 따라 사용 가능한 버튼만 활성화)
		 * @param {Element} sampleItemEl			- 변경된 sampleItem Element
		 * @param {String=} sampleName				- sampleName (미지정시 sampleItem 으로부터 구함. 이미 삭제된 경우 제외)
		 * @returns {void}
		 */
		_updateSampleItemMoveButton: function (sampleItemEl, sampleName) {
			if (!sampleItemEl) {
				return;
			}

			var enableUp = false,
				enableDown = false,
				sampleWrapEl = sampleItemEl.parentNode,
				sampleMoveButtons, isEnabled, moveValue, moveButton, i, len;

			sampleName = sampleName || UiUtil.getSampleName(sampleWrapEl);
			sampleMoveButtons = UiFrameworkInfo.getInfo(UiFrameworkInfo.SAMPLE_ITEM_MOVE_MAP)[sampleName];

			if (!sampleMoveButtons) {
				return;
			}

			if (sampleItemEl.parentNode && UiUtil.isButtonOn(sampleItemEl)) {
				// 해당 sampleItem 이 제거되지 않고 선택돼 있는 상황 (활성화 여부 체크)
				if (sampleItemEl.previousElementSibling) {
					enableUp = true;
				}
				if (sampleItemEl.nextElementSibling) {
					enableDown = true;
				}
			}

			len = sampleMoveButtons.length;

			for (i = 0; i < len; i++) {
				moveButton = sampleMoveButtons[i];
				moveValue = moveButton.getAttribute(_defineDataValueAttr);
				isEnabled = UiUtil.isEnabled(moveButton);

				if ((moveValue === "up" && enableUp) || (moveValue === "down" && enableDown)) {
					if (!isEnabled) {
						this._setEnable(moveButton);
					}
				} else {
					if (isEnabled) {
						this._setDisable(moveButton);
					}
				}
			}
		},

		/**
		 * 현재 converting 완료된 상태에서 다시 xmlList 를 통해 converting
		 * @param {Boolean} isViewMode
		 * @param {Array=} xmlList
		 * @returns {Object} DomInfo		- {refTree, widgetMap}
		 */
		_reConvertXmlToDom: function (isViewMode, xmlList) {
			var contentWindow = UiFrameworkInfo.getContentWindow(),
				refTree = UiFrameworkInfo.getRefTree(),
				contentDocument = contentWindow && contentWindow.document,
				version, linkEl, convertResult, formulaBarParentEl, formulaHeight;

			if (!(refTree && contentDocument)) {
				return null;
			}

			_isViewMode = isViewMode;
			formulaBarParentEl = refTree.document[UiDefine.FORMULA_BAR_PARENT];

			if (formulaBarParentEl && formulaBarParentEl.ref) {
				formulaHeight = formulaBarParentEl.ref.style.height;
			}

			if (isViewMode) {
				version = window.__hctfwoVersion || String((new Date()).getTime());
				linkEl = contentDocument.createElement("link");
				linkEl.setAttribute("rel", "stylesheet");
				linkEl.setAttribute("type", "text/css");
				linkEl.setAttribute("href", "css/hcwo_view.css?" + version);
				_viewModeCssLinkEl = linkEl;
				contentDocument.head.appendChild(linkEl);

			} else if (_viewModeCssLinkEl) {
				CommonFrameUtil.removeNode(_viewModeCssLinkEl);
				_viewModeCssLinkEl = null;
			}

			xmlList = xmlList || UiFrameworkInfo.getInfo(UiFrameworkInfo.XML_LIST);

			CommonFrameUtil.removeNode(contentDocument.getElementById(UiDefine.WRAP_ID));
			_callbackFnConvertingAfter = null;

			convertResult = this.convertXmlToDomByXmlList(UiFrameworkInfo.getModuleName(),
				xmlList, contentWindow, UiFrameworkInfo.getInfo(UiFrameworkInfo.BASE_DIR));

			refTree = convertResult && convertResult.refTree;

			if (refTree && formulaHeight) {
				formulaBarParentEl = refTree.document[UiDefine.FORMULA_BAR_PARENT];

				if (formulaBarParentEl && formulaBarParentEl.ref) {
					formulaBarParentEl.ref.style.height = formulaHeight;
				}
			}

			return convertResult;
		},

		/**
		 * Tool bar 영역의 Navigation box 가 visible 될 필요가 있을 경우, visible 시키는 함수
		 * @param {String} viewName				- totalWidth 를 저장한 대상의 Name. (ex. menuBarId 등)
		 * @returns {void}
		 * @private
		 */
		_visibleToolBarNavBoxIfNeeded: function (viewName) {
			var windowInnerWidth = window.innerWidth || -1,
				menuScrollInfo = this.getMenuScrollInfo(viewName),
				totalWidth, navBoxEl, menuBoxEl, prevBtnNavEl, nextBtnNavEl, curMarginLeft,
				nextBtnWidth, firstChildEl;

			if (windowInnerWidth <= 0 || menuScrollInfo == null) {
				return;
			}

			menuBoxEl = menuScrollInfo.menuBoxEl;
			navBoxEl = menuScrollInfo.navBoxEl;

			if (!menuBoxEl || !navBoxEl) {
				return;
			}

			prevBtnNavEl = navBoxEl.firstElementChild;
			nextBtnNavEl = navBoxEl.lastElementChild;

			totalWidth = menuScrollInfo.totalWidth;

			if (windowInnerWidth <= totalWidth) {
				if (UiUtil.isHidden(navBoxEl)) {
					// nav box 가 감춰져 있다는 것은 최초 문서를 open 하는 시점이거나,
					// 창 resize 중 메뉴 총 길이가 윈도우보다 작아졌을 경우이다.
					this._setVisible(navBoxEl);
				}

				// window 창 사이즈보다 menu 의 총길이가 작으면,
				// next btn 은 무조건 등장한다.
				if (windowInnerWidth < _prevWindowSize) {
					this._setVisible(nextBtnNavEl);
				}

				if (viewName === _titleBarId) {
					firstChildEl = menuBoxEl.firstElementChild;
				} else {
					firstChildEl = navBoxEl.nextElementSibling;
				}

				curMarginLeft = parseInt(firstChildEl.style.marginLeft || 0, 10);
				nextBtnWidth = nextBtnNavEl.offsetWidth;

				// 해당 메뉴의 총 길이에서 margin left 를 뺀 값 = 가려진 메뉴를 제외한 남은 메뉴의 길이
				// window 의 내부 길이에서 next 버튼의 길이를 뺀 값 = 현재 보여주는 메뉴의 길이
				// 현재 보여주는 메뉴의 길이가 같거나 커지면, next 버튼을 가려준다.
				if ((menuScrollInfo.totalWidth + curMarginLeft) <= (windowInnerWidth - nextBtnWidth)) {
					this._setHidden(nextBtnNavEl);
				}
			} else {
				// 이 부분에 들어왔다는 것은 버튼을 더이상 보여줄 필요가 없다는 뜻이다.
				// 그런데 navBox 가 visible 상태이면서 next btn 이 보이고 있다면,
				// nav box 를 감추고 내부 버튼을 초기화시켜준다.
				if (!UiUtil.isHidden(navBoxEl) && !UiUtil.isHidden(nextBtnNavEl)) {
					this._setHidden(navBoxEl);

					this._setHidden(prevBtnNavEl);
				}
			}
		},

		/**
		 * Menu Scroll Child 정보를 1차원 배열로 종합
		 * @param {Array} newChildrenElArr		-
		 * @returns {Object} {end: 최종 대상만 담은 Array, all: 중간 panel 도 모두 담은 Array, totalWidth: 총 너비}
		 * @private
		 */
		_getMenuScrollChildElArray: function(newChildrenElArr) {
			var endChildElArr = [],
				allChildElArr = [],
				isAllCalculateArea = true,
				totalWidth = 0,
				childEl, i, childElArrInfo;

			i = 0;
			childEl = newChildrenElArr[i];

			while (childEl && isAllCalculateArea) {
				if (UiUtil.isCalculateArea(childEl)) {
					allChildElArr.push(childEl);

					if (CommonFrameUtil.hasClass(childEl, UiDefine.NORMAL_PANEL_CLASS)
						|| CommonFrameUtil.hasClass(childEl, UiDefine.INLINE_PANEL_CLASS)) {
						// panel 내부 추가
						childElArrInfo = this._getMenuScrollChildElArray(childEl.children);
						endChildElArr = endChildElArr.concat(childElArrInfo.end);
						allChildElArr = allChildElArr.concat(childElArrInfo.all);
						totalWidth += childElArrInfo.totalWidth;
						isAllCalculateArea = childElArrInfo.isAllCalculateArea;

					} else {
						endChildElArr.push(childEl);
						totalWidth += childEl.offsetWidth;
					}

					totalWidth += (FrameworkUtil.getNumberFromStyleValue(childEl, "marginLeft") +
						FrameworkUtil.getNumberFromStyleValue(childEl, "marginRight"));
				} else {
					// 계산 불가한 영역이 나오면 Scroll 대상 검사 중단
					isAllCalculateArea = false;
				}

				childEl = newChildrenElArr[++i];
			}

			return {
				end: endChildElArr,
				all: allChildElArr,
				totalWidth: totalWidth,
				isAllCalculateArea: isAllCalculateArea
			};
		},

		/**
		 * Menu 의 총길이 및 기타 정보를 저장하는 함수
		 * @param {String} viewName				- totalWidth 를 저장한 대상의 이름 (ex. menuBarId 등)
		 * @param {Element=} menuBoxContainer		- menu 를 감싸고 있는 box
		 * @param {Element=} menuNavBoxEl			- 해당 view 의 navigation box
		 * @returns {Object}
		 * @private
		 */
		_setMenuScrollInfoIfNeeded: function (viewName, menuBoxContainer, menuNavBoxEl) {
			if (!viewName) {
				return {};
			}

			var menuScrollInfo = this.getMenuScrollInfo(viewName) || {},
				menuBoxEl = menuScrollInfo.menuBoxEl || menuBoxContainer || this._getToolBarMenuBox(viewName),
				children, childElArrInfo;

			if (!menuBoxEl) {
				return {};
			}

			if (UiUtil.isFolded(menuBoxEl)) {
				menuScrollInfo.totalWidth = 0;
			} else if (CommonFrameUtil.isEmptyObject(menuScrollInfo) || menuScrollInfo.totalWidth === 0) {
				children = CommonFrameUtil.getCollectionToArray(menuBoxEl.children);

				// Menu bar 의 View control 의 길이는 제외해야한다.
				if (viewName === _menuBarId && UiUtil.isViewControl(children[0])) {
					children.shift();
				}

				// navigation box 의 길이는 이 상황에서 무조건 0 이다.
				// 그러나 어떠한 예외 상황이 들어올지 모르기 때문에,
				// 해당 노드는 길이 계산에서 제외해야한다.
				if (UiUtil.isNavigationBox(children[0])) {
					children.shift();
				}

				childElArrInfo = this._getMenuScrollChildElArray(children);

				menuScrollInfo.totalWidth = childElArrInfo.totalWidth
					+ FrameworkUtil.getNumberFromStyleValue(menuBoxEl, "paddingLeft");
				menuScrollInfo.menuBoxEl = menuBoxEl;
				menuScrollInfo.navBoxEl = menuScrollInfo.navBoxEl || menuNavBoxEl || this._getToolBarNavBox(viewName);
				menuScrollInfo.childElArr = childElArrInfo.end;
			}

			// dialog 가 open 될 때, 혹은 브라우저 창 화면을 resize 할때에는
			// 항상 값을 초기화 해야함.
			menuScrollInfo.direction = "";
			menuScrollInfo.index = 0;

			_menuScrollInfo[viewName] = menuScrollInfo;

			return menuScrollInfo;
		},

		/**
		 * line 이 나와야 되는 상황인지 아닌지 판단하고, 이를 감추거나 보여주도록 하는 함수
		 * @param {Element} lineWrap
		 * @private
		 */
		_updateLineDisplay: function(lineWrap) {
			var needShowLine = false,
				child = lineWrap.firstElementChild,
				lineEl;

			while (child) {
				if (UiUtil.isLine(child)) {
					if (needShowLine) {
						if (!UiUtil.isShowTarget(child)) {
							CommonFrameUtil.removeClass(child, _hideViewClassName);
						}

						lineEl = child;
						needShowLine = false;
					} else if (UiUtil.isShowTarget(child)) {
						CommonFrameUtil.addClass(child, _hideViewClassName);
					}

				} else {
					if (!needShowLine && !UiUtil.isViewControl(child) &&
						!UiUtil.isNavigationBox(child) && UiUtil.isShowTarget(child)) {
						needShowLine = true;
					}
				}

				child = child.nextElementSibling;
			}

			if (!needShowLine && lineEl) {
				CommonFrameUtil.addClass(lineEl, _hideViewClassName);
			}
		},

		_setVisibleLineIfNeeded: function (viewNode) {
			var dataCmdAttr = viewNode.getAttribute("data-command"),
				prevLineEl, prevSibling, nextLineEl, nextSibling;

			var __enableLineElInMyGroup = function (target, findPrevious) {
				var lineEl = null,
					sibling = target;

				while (sibling) {
					if (!UiUtil.isLine(sibling)) {
						if (UiUtil.isShowTarget(sibling)) {
							// line 은 아닌데 이미 켜져있다면, 더이상 진행할 필요가 없다.
							break;
						}

						if (findPrevious) {
							sibling = sibling.previousElementSibling;
						} else {
							sibling = sibling.nextElementSibling;
						}
					} else {
						if (!UiUtil.isShowTarget(sibling)) {
							// line 인데 line 이 hide 상태이면 해당 line 을 돌려준다.
							lineEl = sibling;
						}

						break;
					}
				}

				if (lineEl) {
					if (findPrevious) {
						sibling = lineEl.previousElementSibling;
					} else {
						sibling = lineEl.nextElementSibling;
					}

					while (sibling) {
						if (!UiUtil.isShowTarget(sibling)) {
							if (findPrevious) {
								sibling = sibling.previousElementSibling;
							} else {
								sibling = sibling.nextElementSibling;
							}
						} else {
							if (UiUtil.isLine(sibling) ||
								UiUtil.isViewControl(sibling) || UiUtil.isNavigationBox(sibling)) {
								lineEl = null;
							}

							break;
						}
					}

					if (sibling == null) {
						lineEl = null;
					}
				}

				return lineEl;
			};

			if (dataCmdAttr === _eventActionNames.E_DIALOG_ALERT
				|| dataCmdAttr === _eventActionNames.E_DIALOG_ERROR) {
				prevSibling = viewNode.parentNode.previousElementSibling;

				if (prevSibling && UiUtil.isLine(prevSibling)) {
					prevLineEl = prevSibling;
				}
			} else {
				prevSibling = viewNode.previousElementSibling;
				nextSibling = viewNode.nextElementSibling;

				// 자신의 그룹에서 위쪽 아래쪽 line 중 enable 시킬 line 을 찾아냄.
				prevLineEl = __enableLineElInMyGroup(prevSibling, true);

				if (!prevLineEl) {
					nextLineEl = __enableLineElInMyGroup(nextSibling, false);
				}
			}

			if (prevLineEl) {
				this._setVisible(prevLineEl);
			}

			if (nextLineEl) {
				this._setVisible(nextLineEl);
			}
		},

		_setHideLineIfNeeded: function (viewNode) {
			var dataCmdAttr = viewNode.getAttribute("data-command"),
				needToCheckNextSibling = false,
				prevLineEl, nextLineEl, prevSibling, containerEl, isMenubar, nextSibling;

			if (dataCmdAttr === _eventActionNames.E_DIALOG_ALERT
				|| dataCmdAttr === _eventActionNames.E_DIALOG_ERROR) {
				prevSibling = viewNode.parentNode.previousElementSibling;

				if (prevSibling && UiUtil.isLine(prevSibling)) {
					prevLineEl = prevSibling;
				}
			} else {
				containerEl = UiUtil.findContainerNodeToParent(viewNode);
				isMenubar = (containerEl && containerEl.id === _menuBarId);

				prevSibling = viewNode.previousElementSibling;

				// menubar 의 경우, control 이 제일 처음에 올수 있으므로 이를 체크한다.
				if (isMenubar) {
					if (UiUtil.isViewControl(prevSibling) || UiUtil.isNavigationBox(prevSibling)) {
						prevSibling = null;
					}
				}

				// 이전 형제들을 확인하면서 조건들을 체크한다.
				while (prevSibling) {
					if (!UiUtil.isLine(prevSibling)) {
						if (UiUtil.isShowTarget(prevSibling)) {
							// 내 이전 형제들 중에 hide 되지 않은 형제가 있다면,
							// 굳이 자신의 이후 형제들을 살펴볼 필요가 없다.
							break;
						}

						prevSibling = prevSibling.previousElementSibling;

						// menubar 의 경우, control 이 제일 처음에 올수 있으므로 이를 체크한다.
						if (isMenubar) {
							if (UiUtil.isViewControl(prevSibling) || UiUtil.isNavigationBox(prevSibling)) {
								prevSibling = null;
							}
						}
					} else {
						// prevSibling 이 line 인 경우
						if (UiUtil.isShowTarget(prevSibling)) {
							// 우선 이 경우에는 prevSibling 은 삭제할 대상 후보에 포함될 수 있다.
							// 이후 형제들을 살펴보면서 삭제해야 하는지 판단해야 한다.
							prevLineEl = prevSibling;
						}

						// 혹시나 위에서 line hide 가 되어 있다면, 다음과 같은 경우이다.
						// 1. line 의 이전 child 들은 첫 그룹이거나 그에 준하는 그룹들이다.
						// 2. 1.의 그룹들이 전부 hide 가 된 상태이다.
						// 이 경우에는 자신의 이후 형제들을 살펴볼 필요가 있다.
						needToCheckNextSibling = true;
						break;
					}
				}

				// prevSibling 이 null 이라면, 자신이 속한 그룹이 첫 그룹이라는 의미이다.
				// 이때에는 아래쪽 형제들을 살펴볼 필요가 있다.
				if (prevSibling == null) {
					needToCheckNextSibling = true;
				}

				if (needToCheckNextSibling) {
					nextSibling = viewNode.nextElementSibling;
				}

				while (nextSibling) {
					if (!UiUtil.isLine(nextSibling)) {
						if (UiUtil.isShowTarget(nextSibling)) {
							// 내 이후 형제들 중 하나가 show 상태이므로, 더 이상 수행할 필요가 없다.
							prevLineEl = null;
							nextLineEl = null;

							break;
						}

						nextSibling = nextSibling.nextElementSibling;
					} else {
						if (prevSibling == null) {
							// prevSibling 이 null 이란 것은 다음과 같은 의미이다.
							// 1. 자신(node) 이 속한 곳은 첫 그룹이다.
							// 2. 이 위치에 왔다는 것은 자신 이후의 형제들이 전부 hide 되었다는 소리이다.
							// 3. 그런데 라인을 만났다. -> 라인이 hide 되어있지 않다면 hide 시켜야된다.
							if (UiUtil.isShowTarget(nextSibling)) {
								nextLineEl = nextSibling;

								break;
							}

							// prevSibling 이 null 인데, 아래 line 이 hide 란 것은 다음과 같은 의미이다.
							// 1. 자신(node) 이 속한 곳은 첫 그룹이다.
							// 2. 자신의 아래 그룹이 다 감춰져서 해당 그룹의 윗 line 을 지워버렸다.
							// 3. 그럼 다음을 계속적으로 검색하며 line 이 켜져있는지 쭉 따라가본다.
							nextSibling = nextSibling.nextElementSibling;
						} else {
							if (!prevLineEl) {
								// prevSibling 이 null 이 아닌데 prevLine 이 설정 안되었다는 것은,
								// 1. 자신의 이전 형제들이 전부 hide 이다.
								// 2. 라인을 만났더니 이미 hide 가 되어있다.
								// 3. 그리고 자신의 이후 형제들도 전부 hide 이다.
								// 4. 그런데 라인을 만났다. -> 라인이 hide 되어있지 않다면 hide 시켜야된다.
								if (UiUtil.isShowTarget(nextSibling)) {
									nextLineEl = nextSibling;
								}
							}

							break;
						}
					}
				}

			}

			if (prevLineEl) {
				this._setHidden(prevLineEl);
			}

			if (nextLineEl) {
				this._setHidden(nextLineEl);
			}
		},

		_setVisibleTitleMenuIfNeeded: function (widget) {
			if (!widget) {
				return;
			}

			var containerEl = UiUtil.findContainerNodeToParent(widget),
				parentEl, target;

			if (containerEl === UiFrameworkInfo.getContainerNode(_titleBarId)) {
				parentEl = widget.parentNode;

				if (CommonFrameUtil.hasClass(parentEl, UiDefine.BOX_ELEMENT_CLASS)) {
					target = parentEl && parentEl.parentNode;

					if (target) {
						this._setVisible(target);
					}
				}
			}
		},

		_setHideTitleMenuIfNeeded: function (widget) {
			if (!widget) {
				return;
			}

			var containerEl = UiUtil.findContainerNodeToParent(widget),
				isHideToTitle = true,
				parentEl, children, length, i, target;

			if (containerEl === UiFrameworkInfo.getContainerNode(_titleBarId)) {
				parentEl = widget.parentNode;

				if (CommonFrameUtil.hasClass(parentEl, UiDefine.BOX_ELEMENT_CLASS)) {
					children = parentEl.childNodes;
					length = children.length;

					for (i = 0; i < length; ++i) {
						if (!UiUtil.isHidden(children[i])) {
							isHideToTitle = false;

							break;
						}
					}

					if (isHideToTitle) {
						target = parentEl.parentNode;

						if (target) {
							this._setHidden(target);
						}
					}
				}
			}
		},

		/**
		 * Tool bar 의 menu box 를 리턴하는 함수
		 * @param {String} viewName		- tool bar 의 view name (ex. title_bar ...)
		 * @returns {Element|null}
		 *
		 * @private
		 */
		_getToolBarMenuBox: function (viewName) {
			var menuBoxEl = null,
				toolBarEl = UiFrameworkInfo.getContainerNode(viewName);

			if (toolBarEl) {
				if (viewName === _titleBarId) {
					menuBoxEl = toolBarEl.lastElementChild;
				} else {
					menuBoxEl = toolBarEl;
				}
			}

			return menuBoxEl;
		},

		/**
		 * Tool bar 의 nav box 를 리턴하는 함수
		 * @param {String} viewName		- tool bar 의 view name (ex. title_bar ...)
		 * @returns {Element|null}
		 *
		 * @private
		 */
		_getToolBarNavBox: function (viewName) {
			var navBoxEl = null,
				toolBarEl = UiFrameworkInfo.getContainerNode(viewName);

			if (toolBarEl) {
				navBoxEl = toolBarEl.firstElementChild;

				if (navBoxEl) {
					if (viewName === _menuBarId && UiUtil.isViewControl(navBoxEl)) {
						navBoxEl = navBoxEl.nextElementSibling;
					}
				}
			}

			return navBoxEl;
		},

		_showView: function(viewNode, containerNode, value, evtTarget) {
			if (!(viewNode && UiFrameworkInfo.getRefTree())) {
				return false;
			}

			var curLayerMenu = UiFrameworkInfo.getLayerMenu(),
				isDialogWrap = false,
				callbackInfo = {},
				updated, containerID, tabGroupEl, tabBoxEl, menuScrollInfo, tabBoxNavEl, firedWidgetName,
				dlgShowingInfo, beforeDialogName, dlgHAlign, dialogTop, viewPositionEl, tabBoxOffsetWidth;

			containerNode = containerNode || UiUtil.findContainerNodeToParent(viewNode);
			containerID = containerNode ? containerNode.id : "";

			if (containerID === _contextMenuId && viewNode === containerNode) {
				this._openContextMenu(value && value.pos, curLayerMenu);

			} else {
				if (CommonFrameUtil.hasClass(viewNode, UiDefine.DIALOG_WRAP_CLASS) && UiUtil.isDialogContainer(containerID)) {
					// TODO: dialog 가 1개만 지원되는 경우로 한정하여 구현. 추후 dialog 여러개 지원시 수정 필요.
					// dialog 가 새로 띄울 dialog 와 다른 경우
					dlgShowingInfo = UiFrameworkInfo.getDialogShowing();
					if (dlgShowingInfo.viewNode && dlgShowingInfo.viewNode !== viewNode) {
						// evtTarget 이 없는 경우 firedWidgetName 유지 (ui 동작으로 dialog 를 띄운게 아니고 eventAction 으로 띄운 경우)
						if (!evtTarget) {
							firedWidgetName = dlgShowingInfo.firedWidgetName;
						}

						beforeDialogName = dlgShowingInfo.value;

						// 기존 dialog close
						this.closeDialog(dlgShowingInfo.viewNode);
					}

					this.closeLayerMenu();

					callbackInfo = {
						key: UiDefine.UI_CALLBACK_KEY_DIALOG,
						value: value,
						isDialogShow: true,
						isBefore: true
					};
					_uiCallbackMap[UiDefine.UI_CALLBACK_KEY_DIALOG](callbackInfo);
					// isDialog
					isDialogWrap = true;

					if (!firedWidgetName && evtTarget) {
						firedWidgetName = this.getUiButtonName(evtTarget) || evtTarget.getAttribute(UiDefine.DATA_VALUE);
					}

					UiFrameworkInfo.setDialogShowing(viewNode, value, evtTarget, firedWidgetName, beforeDialogName);
					UiFrameworkInfo.setActivatedDialog(viewNode);
					CommonFrameUtil.removeClass(containerNode, _hideViewClassName);
				}

				updated = this._setShowHideClassOfViewNode(viewNode, containerNode, "show");
				this._updateListBoxScroll(viewNode);

				// Dialog Layer 의 높이를 동적으로 설정해준다.
				if (isDialogWrap) {
					this.hideQuickMenu();
					this._saveDialogHeight();
					this.removeFocusWidgetInfo();

					if (value === "dialog_search_doc") {
						// 정보 찾기 dialog 는 sidebar 위치에 뜨도록 처리
						viewPositionEl = UiFrameworkInfo.getContainerNode(_sideBarId);

						if (viewPositionEl) {
							dialogTop = CommonFrameUtil.getOffsetTop(viewPositionEl, null);
						}
						dlgHAlign = _rightStr;
					}

					FrameworkUtil.setDialogTopPosition(viewNode, _dialogLayerHeight, dialogTop);

					if (containerID === UiDefine.MODELESS_DIALOG_ID) {
						_setDialogLeftPosition(viewNode, dlgHAlign);
					} else {
						viewNode.style.left = "";
					}

					callbackInfo.isBefore = false;
					_uiCallbackMap[UiDefine.UI_CALLBACK_KEY_DIALOG](callbackInfo);

					// Dialog 에서 tab 이 존재할 경우의 처리를 해준다.
					tabGroupEl = viewNode.querySelector("." + UiDefine.TAB_GROUP_CLASS);

					if (tabGroupEl) {
						menuScrollInfo = this.getMenuScrollInfo(value);

						if (!menuScrollInfo) {
							this._setMenuScrollInfoIfNeeded(value, tabGroupEl.firstElementChild, tabGroupEl.lastElementChild);
						} else {
							this._setMenuScrollInfoIfNeeded(value);
						}

						menuScrollInfo = this.getMenuScrollInfo(value);
						tabBoxEl = menuScrollInfo.menuBoxEl;
						tabBoxNavEl = menuScrollInfo.navBoxEl;

						if (!tabBoxEl || !tabBoxNavEl) {
							return false;
						}

						// tab 들의 길이가 tabBox 보다 클 경우, nav 버튼에 대한 세팅을 진행함
						// 단, tabBoxEl 이 rendering 이 돼 있지 않은 경우는 대상에서 제외한다.
						tabBoxOffsetWidth = tabBoxEl.offsetWidth;
						if (menuScrollInfo && tabBoxOffsetWidth && (tabBoxOffsetWidth < menuScrollInfo.totalWidth)) {
							// tab box navigation 이 hide 되어있다면 visible 해준다.
							if (UiUtil.isHidden(tabBoxNavEl)) {
								this._setVisible(tabBoxNavEl);
							}

							// tab 의 버튼 및 margin 초기화를 진행한다.
							if (tabBoxEl.firstElementChild.style.marginLeft) {
								tabBoxEl.firstElementChild.style.removeProperty("margin-left");
							}

							// prev 버튼이 enable 이라면 disable 시킨다.
							if (UiUtil.isEnabled(tabBoxNavEl.firstElementChild)) {
								this._setDisable(tabBoxNavEl.firstElementChild);
							}

							// next 버튼이 disable 이라면 enable 시킨다.
							if (UiUtil.isDisabled(tabBoxNavEl.lastElementChild)) {
								this._setEnable(tabBoxNavEl.lastElementChild);
							}
						}
					}
				} else if (_toolBarContainers.indexOf(containerID) !== -1) {
					this.updateToolBarScroll();
				} else if (updated && UiUtil.isDialogContainer(containerID)) {
					this._needToUpdateDialogHeight();
				}
			}

			return true;
		},

		_hideView: function(viewNode, containerNode, isItemView) {
			if (!(viewNode && UiFrameworkInfo.getRefTree())) {
				return false;
			}

			var curLayerMenu = UiFrameworkInfo.getLayerMenu(),
				updated, containerID, isDialogContainer, screenEl;

			containerNode = containerNode || UiUtil.findContainerNodeToParent(viewNode);
			containerID = containerNode && containerNode.id;
			isDialogContainer = UiUtil.isDialogContainer(containerID);

			if (!isItemView && curLayerMenu && curLayerMenu !== viewNode
				&& UiUtil.isContainsView(viewNode, curLayerMenu)) {
				// viewNode 내부에 curLayerMenu 가 있는 경우 닫는다.
				this.closeLayerMenu();
			}

			if (isDialogContainer && CommonFrameUtil.hasClass(viewNode, UiDefine.DIALOG_WRAP_CLASS)) {
				// isDialog
				this.closeDialog(viewNode);

			} else if (containerID === _contextMenuId && viewNode === containerNode) {
				this._closeContextMenu();

			} else {
				updated = this._setShowHideClassOfViewNode(viewNode, containerNode, "hide");

				if (CommonFrameUtil.hasClass(viewNode, _msgBarClass)) {
					// x 버튼을 통해 message bar 를 hidden 시키는 경우,
					// message bar 아래 screen 이 켜져있으면 같이 hidden 할 수 있도록 함.
					screenEl = _msgBarElInfo.screenEl;
					if (screenEl && !UiUtil.isHidden(screenEl)) {
						this._setHidden(screenEl);
					}

					this._setEnableEditDesktop();
				} else if (updated && isDialogContainer) {
					this._needToUpdateDialogHeight();
				}
			}

			return true;
		},

		/**
		 * view(panel) 이름을 통해 해당하는 view 를 show 시켜주는 함수 (나머지 닫음)
		 * @param {Object} value				- show EventAction value
		 */
		_showCurrentView: function(value) {
			if (!(value && UiFrameworkInfo.getRefTree())) {
				return false;
			}

			var refTree = UiFrameworkInfo.getRefTree(),
				names = value.names,
				container = value.container,
				isSideBar = (container === UiDefine.SIDEBAR_ID),
				curContainerRefTree = refTree[container],
				keyLen = 0,
				enableContextLen = _watcherModeEnableContexts.length,
				enableName, enableNames, viewKeys, containerNode, curRefItem, i, viewKey, viewNode, contextMenuEl;

			if (_appMode === _watcherMode) {
				enableNames = [];

				for (i = 0; i < enableContextLen; i++) {
					enableName = _watcherModeEnableContexts[i];
					if (names.indexOf(enableName) !== -1) {
						enableNames[enableNames.length] = enableName;
					}
				}

				if (enableNames.length) {
					names = enableNames;
				} else {
					// 허용된 context 가 없는 경우 모두 null 할당
					curContainerRefTree = null;
					container = null;
				}
			}

			if (curContainerRefTree) {
				containerNode = curContainerRefTree.ref;
				viewKeys = Object.keys(curContainerRefTree);

				if (viewKeys && viewKeys.length) {
					keyLen = viewKeys.length;

					for (i = 0; i < keyLen; i++) {
						viewKey = viewKeys[i];
						if (_ignoreRefTreeKeyArr.indexOf(viewKey) !== -1) {
							continue;
						}
						curRefItem = curContainerRefTree[viewKey];
						viewNode = curRefItem ? curRefItem.ref : null;

						if (viewNode) {
							if (isSideBar) {
								// sideBar 이하의 title
								viewNode = viewNode.parentNode;
							}

							if (names.indexOf(viewKey) === -1) {
								this._hideView(viewNode, containerNode, true);
							} else {
								this._showView(viewNode, containerNode, value);
							}
						}
					}
				}

				if (container === _contextMenuId) {
					contextMenuEl = curContainerRefTree.ref;
					this._updateLineDisplay(contextMenuEl);
					this._openContextMenu(value.pos);
				}
			}

			return !!keyLen;
		},

		/**
		 * view(container, panel) 이름을 통해 해당하는 view 를 toggle 시켜주는 함수
		 * @param {Element} viewNode		- show 를 해줄 view
		 * @param {Object} value			- show EventAction value
		 * @param {String} viewName			- show 할 view 의 name
		 * @param {Boolean=} on				- 현재 상태와 관계없이 "on"(보이기)시 true, "off"(숨기기)시 false
		 */
		_toggleView: function(viewNode, value, viewName, on) {
			if (!(UiFrameworkInfo.getRefTree() && viewNode)) {
				return false;
			}

			var containerNode = UiUtil.findContainerNodeToParent(viewNode),
				toggleUiWidgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.UI_WIDGET_MAP)[_uiCommandNames.TOGGLE],
				result = false;

			on = (on != null) ? on : UiUtil.isHidden(viewNode);

			if (on) {
				this._showView(viewNode, containerNode, value);
				this._updateWidget(toggleUiWidgetMap, viewName, _onStr, null, _uiCommandNames.TOGGLE);
			} else {
				this._hideView(viewNode, containerNode);
				this._offToggleCommandButton(viewName, _uiCommandNames.TOGGLE);
				result = true;
			}

			return result;
		},

		/**
		 * view(container, panel) 이름을 통해 해당하는 view 를 fold 시켜주는 함수
		 * @param {Element} viewNode			- show 를 해줄 view
		 * @param {String} viewName			- show 할 view 의 name
		 * @param {Boolean=} on				- 현재 상태와 관계없이 "on"(접기해제)시 true, "fold"(접기)시 false (default)
		 */
		_foldView: function(viewNode, viewName, on) {
			if (!(UiFrameworkInfo.getRefTree() && viewNode)) {
				return false;
			}

			var containerNode = UiUtil.findContainerNodeToParent(viewNode),
				containerID = containerNode ? containerNode.id : "",
				foldUiWidgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.UI_WIDGET_MAP)[_uiCommandNames.FOLD],
				curLayerMenu = UiFrameworkInfo.getLayerMenu(),
				result = false;

			if (curLayerMenu && curLayerMenu !== viewNode) {
				this.closeLayerMenu();
			}

			if (containerID === UiDefine.SIDEBAR_ID && viewNode !== containerNode) {
				// sideBar 이하의 title
				viewNode = viewNode.parentNode;
			}

			on = (on != null) ? on : UiUtil.isFolded(viewNode);

			if (on) {
				CommonFrameUtil.removeClass(viewNode, _foldViewClassName);
				this._updateWidget(foldUiWidgetMap, viewName, _onStr, null, _uiCommandNames.FOLD);
				this.updateToolBarScroll();
			} else {
				CommonFrameUtil.addClass(viewNode, _foldViewClassName);
				this._offToggleCommandButton(viewName, _uiCommandNames.FOLD);
				result = true;
			}

			if (UiUtil.isDialogContainer(containerID)) {
				this._needToUpdateDialogHeight();
			}

			return result;
		},

		_setSaveUiButtonState: function (viewName, saveVal) {
			if (FrameworkUtil.getSaveViewNames().indexOf(viewName) !== -1) {
				FrameworkUtil.saveUiState(viewName, saveVal);
			}
		},

		/**
		 * 클릭한 버튼에 해당하는 tab 을 show 시켜주는 함수
		 * @param {Element} tabButton		- 클릭한 button element
		 * @returns {boolean}
		 */
		_showTab: function(tabButton) {
			if (!UiUtil.isTabButton(tabButton)) {
				return false;
			}

			var parentNode = tabButton.parentNode,
				value = tabButton.getAttribute(UiDefine.DATA_TAB_BUTTON_TARGET),
				inputNode = parentNode.querySelector("[class*=" + value + "]"),
				dropdownBoxEl, dropdownInfo, layerMenu, curDropdownBoxEl;

			if (inputNode) {
				// tab 을 보여줄때 dropdownBox 가 color theme 인 경우 닫아준다.
				layerMenu = UiFrameworkInfo.getLayerMenu();
				curDropdownBoxEl = layerMenu && layerMenu.nextElementSibling;
				if (curDropdownBoxEl && CommonFrameUtil.hasClass(curDropdownBoxEl.parentElement, _uiCommandNames.COLOR_THEME)) {
					this.closeLayerMenu(curDropdownBoxEl);
				}

				inputNode.checked = true;

				dropdownBoxEl = UiFrameworkInfo.getDropdownBoxList();
				// 컬러픽커 탭 일때는 탭 이동시 포지션 및 키보드 이동 정보를 재설정 해준다.
				if (CommonFrameUtil.hasClass(dropdownBoxEl, UiDefine.DROPDOWN_COLOR_PICKER_WRAP_CLASS)) {
					this.setDropdownPosition(dropdownBoxEl);

					/**
					 * 컬러픽커 탭 이동이 일어나면 키보드 이동 대상이 달라진다.
					 * 따라서 컬러픽커 탭 이동 일때는 dropdownListInfo 를 초기화 해준다.
					 */
					dropdownInfo = UiFrameworkInfo.getDropdownListInfo();
					UiFrameworkInfo.initDropdownListInfo(dropdownBoxEl, (dropdownInfo.index != null ? dropdownInfo.index : -1));
				}
			}

			return !!inputNode;
		},

		_initUiValue: function(contentDoc, widgetMap) {
			var uiWidgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.UI_WIDGET_MAP),
				uiCmdNames, viewNode, uiCommand, widgetNames, curWidgetMap, widgetNameLen, needUpdate,
				widgetArr, len, i, j, widget, element, widgetName, slideBackgroundRef, targetNode;

			if (widgetMap) {
				if (widgetMap["selected"]) {
					widgetArr = widgetMap["selected"];
					len = widgetArr.length;

					for (i = 0; i < len; i++) {
						widget = widgetArr[i];
						if (UiUtil.isInputWrapWidget(widget)) {
							element = UiUtil.getInputElementByWidget(widget);
							if (element) {
								element.checked = true;
								this._updateRadioCheckboxMatch(widget, false);
							}
						} else {
							this._updateWidget(widgetMap,
								UiUtil.getEventActionCommand(widget), widget.getAttribute(_defineDataValueAttr) || _onStr,
								UiUtil.getValueKey(widget));
						}
					}
					delete widgetMap.selected;
				}

				if (widgetMap["notCheckedMatch"]) {
					widgetArr = widgetMap["notCheckedMatch"];
					len = widgetArr.length;

					for (i = 0; i < len; i++) {
						this._updateRadioCheckboxMatch(widgetArr[i], false);
					}

					delete widgetMap.notCheckedMatch;
				}

				if (widgetMap["defaultValue"]) {
					widgetArr = widgetMap["defaultValue"];
					len = widgetArr.length;

					for (i = 0; i < len; i++) {
						widget = widgetArr[i];
						this._updateWidget(widgetMap, UiUtil.getEventActionCommand(widget),
							widget.getAttribute(_defineDefaultValueAttr), UiUtil.getValueKey(widget));

						widget.removeAttribute(_defineDefaultValueAttr);
					}
					delete widgetMap.defaultValue;
				}

				widgetName = UiUtil.getWidgetName(_eventActionNames.E_SLIDE_BACKGROUND, "slide_bgcolor");

				if (widgetMap[widgetName]) {
					slideBackgroundRef = widgetMap[widgetName][0];

					if (slideBackgroundRef) {
						targetNode = slideBackgroundRef.querySelector(".sub_default_color");
					}

					if (targetNode && targetNode.getAttribute(_defineDataValueAttr) !== _autoStr) {
						targetNode.setAttribute(_defineDataValueAttr, _autoStr);

						if (targetNode.lastElementChild) {
							targetNode.lastElementChild.textContent = _langDefine.color_picker_auto_color;
						}
					}
				}
			}

			if (uiWidgetMap) {
				// 기본적으로 xml convert level 에서 on 시킨 view 의 경우, 여기서 toggle(fold) 버튼 on 시킴
				uiCmdNames = Object.keys(uiWidgetMap);
				len = uiCmdNames.length;

				for (i = 0; i < len; i++) {
					uiCommand = uiCmdNames[i];
					curWidgetMap = uiWidgetMap[uiCommand];
					widgetNames = Object.keys(curWidgetMap);
					widgetNameLen = widgetNames.length;

					for (j = 0; j < widgetNameLen; j++) {
						widgetName = widgetNames[j];
						viewNode = this._getViewNode(widgetName);
						needUpdate = false;

						if (uiCommand === _uiCommandNames.FOLD) {
							needUpdate = !UiUtil.isFolded(viewNode);
						} else {
							needUpdate = !UiUtil.isHidden(viewNode);
						}

						if (needUpdate) {
							this._updateWidget(curWidgetMap, widgetName, _onStr, null, uiCommand);
						}
					}
				}
			}
		},

		_loadUiState: function() {
			var viewNames = FrameworkUtil.getSaveViewNames(),
				viewNamesLen = viewNames.length,
				uiOptionStr = _uri.queryKey[UiDefine.UI_OPTION],
				i, viewName, uiState, viewNode;

			if (uiOptionStr) {
				this._initUiOption(uiOptionStr);
			}

			for (i = 0; i < viewNamesLen; i++) {
				viewName = viewNames[i];
				uiState = (_viewNameListToSave.indexOf(viewName) !== -1) ? FrameworkUtil.getUiState(viewName) : null;

				if (uiState) {
					viewNode = this._getViewNode(viewName);

					if (CommonFrameUtil.isStartsWith(uiState, _uiCommandNames.TOGGLE)) {
						if (!UiUtil.isHidden(viewNode)) {
							this._toggleView(viewNode, null, viewName, (uiState === _defineValue.TOGGLE_ON));
						}
					} else {
						if (!UiUtil.isFolded(viewNode)) {
							// 현재 이미 fold 된 경우, converter 또는 xml 상에서 fold 한 것임. (접기 우선)
							this._foldView(viewNode, viewName, (uiState === _onStr));
						}
					}
				}
			}

			if (_uiOptionsArr && _uiOptionsArr.length > 0) {
				if (FrameworkUtil.getUiState(_toggleUiOptionViewName) === false) {
					this._showViewByUiOption();
				} else {
					// 지정된 값이 없거나(default) true 지정
					this._hideViewByUiOption();
				}
			}
		},

		_initUiOption: function(uiOptionStr) {
			var viewNode, len, i, char;

			// 초기화
			_uiOptionsArr = [];
			len = _uiOptionViewNameArr.length;

			if (!_isViewMode && uiOptionStr && uiOptionStr.length >= len) {
				for (i = 0; i < len; i++) {
					char = uiOptionStr.charAt(i);

					if (char === "0") {
						_uiOptionsArr[_uiOptionsArr.length] = _uiOptionViewNameArr[i];

					} else if (char !== "1") {
						// 비정상 input (option 사용하지 않음)
						_uiOptionsArr = [];
						break;
					}
				}
			}

			if (_uiOptionsArr.length > 0) {
				// 숨겨지는 view 가 있으면 toggle ui option view 버튼 보이기
				viewNode = this._getViewNode(UiDefine.UI_OPTION_AREA);
				this._showView(viewNode);
			}
		},

		_hideViewByUiOption: function() {
			if (!_uiOptionsArr) {
				return;
			}

			var viewNodeArr = [],
				toggleUiWidgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.UI_WIDGET_MAP)[_uiCommandNames.TOGGLE],
				len = _uiOptionsArr.length,
				widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP),
				updateDescValue, widgetNodes, widget, viewNode, viewName, btnNodes, btnLen, i, j, needUpdDes;

			for (i = 0; i < len; i++) {
				viewName = _uiOptionsArr[i];
				viewNode = this._getViewNode(viewName);
				this._hideView(viewNode);

				// toggle(fold) button off
				this._offToggleCommandButton(viewName);

				// toggle(fold) button 비활성화
				btnNodes = toggleUiWidgetMap[viewName];
				btnLen = (btnNodes && btnNodes.length) || 0;
				for (j = 0; j < btnLen; j++) {
					this._setDisable(btnNodes[j]);
				}

				if (viewNode) {
					viewNodeArr.push(viewNode);
				}
			}

			widgetNodes = widgetMap[_toggleUiOptionViewName];
			len = widgetNodes && widgetNodes.length;

			for (i = 0; i < len; i++) {
				widget = widgetNodes[i];
				this._setButtonOff(widget);
				if (!needUpdDes && CommonFrameUtil.hasClass(widget, UiDefine.HAS_DESCRIPTION_CLASS)) {
					needUpdDes = true;
				}
			}

			if (needUpdDes) {
				updateDescValue = {};
				updateDescValue[_toggleUiOptionViewName] = _langDefine.ShowToolbars;
				this._updateDescription(updateDescValue);
			}

			_isHideUiOptionView = true;
			FrameworkUtil.saveUiState(_toggleUiOptionViewName, _isHideUiOptionView);

			return viewNodeArr;
		},

		_showViewByUiOption: function() {
			if (!_uiOptionsArr) {
				return;
			}

			var viewNodeArr = [],
				len = _uiOptionsArr.length,
				widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP),
				toggleUiWidgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.UI_WIDGET_MAP)[_uiCommandNames.TOGGLE],
				updateDescValue, widgetNodes, widget, isFold, i, j, viewName, viewNode, btnNodes, btnLen, btnEl, needUpdDes;

			for (i = 0; i < len; i++) {
				viewName = _uiOptionsArr[i];
				viewNode = this._getViewNode(viewName);
				this._showView(viewNode);

				isFold = UiUtil.isFolded(viewNode);

				// toggle(fold) button 비활성화
				btnNodes = toggleUiWidgetMap[viewName];
				btnLen = (btnNodes && btnNodes.length) || 0;

				for (j = 0; j < btnLen; j++) {
					btnEl = btnNodes[j];
					this._setEnable(btnEl);
					this._setButtonOn(btnEl);
					this._pushToggleCommandButton(viewName, btnEl);
				}

				if (viewNode) {
					viewNodeArr.push(viewNode);
				}
			}

			widgetNodes = widgetMap[_toggleUiOptionViewName];
			len = widgetNodes && widgetNodes.length;

			for (i = 0; i < len; i++) {
				widget = widgetNodes[i];
				this._setButtonOn(widget);
				if (!needUpdDes && CommonFrameUtil.hasClass(widget, UiDefine.HAS_DESCRIPTION_CLASS)) {
					needUpdDes = true;
				}
			}

			if (needUpdDes) {
				updateDescValue = {};
				updateDescValue[_toggleUiOptionViewName] = _langDefine.HideToolbars;
				this._updateDescription(updateDescValue);
			}

			_isHideUiOptionView = false;
			FrameworkUtil.saveUiState(_toggleUiOptionViewName, _isHideUiOptionView);

			return viewNodeArr;
		},

		/**
		 * 지정한 name 들의 description 변경
		 * @param {Object} value				- {name: desc, name: desc...}
		 * @returns {boolean}
		 */
		_updateDescription: function(value) {
			var result = false,
				keys, keyLen, i, j, name, widget, widgetMapArr, widgetLen, descStr, appModeDefine;

			if (!CommonFrameUtil.isObject(value)) {
				return result;
			}

			if (_appMode === _watcherMode && value[UiDefine.SIDEBAR_CATEGORY]) {
				value[UiDefine.SIDEBAR_CATEGORY] = _langDefine.WatcherMode;
			}

			keys = Object.keys(value);
			keyLen = keys.length;
			appModeDefine = UiDefine.APP_UI_MODE;

			for (i = 0; i < keyLen; i++) {
				name = keys[i];
				widgetMapArr = UiFrameworkInfo.getInfo(UiFrameworkInfo.UPDATE_DESC_WIDGET_MAP)[name];

				if (widgetMapArr) {
					result = true;
					descStr = value[name];
					widgetLen = widgetMapArr.length;

					for (j = 0; j < widgetLen; j++) {
						widget = widgetMapArr[j];

						if (name === "message") {
							if (CommonFrameUtil.isObject(descStr)) {
								FrameworkUtil.updateMessageTitle(widget, descStr);
								descStr = descStr.desc;
							}
						} else if (name === "file_name" && _appMode !== appModeDefine.EDITOR) {
							if (_appMode === appModeDefine.VIEWER) {
								descStr += " (" + _langDefine.ReadOnly + ")";
							} else if (_appMode === appModeDefine.WATCHER) {
								descStr += " (" + _langDefine.WatcherMode + ")";
							}
						}

						if (widget.textContent !== descStr) {
							CommonFrameUtil.emptyNode(widget);
							FrameworkUtil.setDescription(widget, descStr);
						}
					}
				}
			}

			return result;
		},

		/**
		 * Dialog tab 영역에 대한 scroll 을 처리하는 함수
		 * @param {Object} value				- 스크롤 방향을 결정하는 값(prev, next)
		 * @returns {Boolean}
		 */
		_updateTabScroll: function (value) {
			var dialogName = UiFrameworkInfo.getDialogShowing().value,
				menuScrollInfo = this.getMenuScrollInfo(dialogName),
				tabBoxEl, navBoxEl, tabBoxWidth,
				totalWidth, direction, index, childElList, firstTabEl,
				curMarginLeft, marginLeft, length, i, offsetWidth, prevBtnEl, nextBtnEl;

			if (!menuScrollInfo) {
				return false;
			}

			tabBoxEl = menuScrollInfo.menuBoxEl;
			navBoxEl = menuScrollInfo.navBoxEl;
			totalWidth = menuScrollInfo.totalWidth || 0;
			direction = menuScrollInfo.direction;
			index = menuScrollInfo.index;

			if (!tabBoxEl || !navBoxEl || totalWidth === 0 || tabBoxEl.children.length === 0) {
				return false;
			}

			tabBoxWidth = tabBoxEl.offsetWidth;
			childElList = tabBoxEl.children;
			length = childElList.length;

			firstTabEl = childElList[0];
			curMarginLeft = parseInt(firstTabEl.style.marginLeft || 0, 10) * -1;
			prevBtnEl = navBoxEl.firstElementChild;
			nextBtnEl = navBoxEl.lastElementChild;

			if (value === _defineValue.PREV) {
				// prev 버튼을 눌렀을 때, next 가 disable 되어 있다면 해제해준다.
				if (UiUtil.isDisabled(nextBtnEl)) {
					this._setEnable(nextBtnEl);
				}

				if (direction !== value) {
					offsetWidth = 0;

					for (i = index; 0 <= i; --i) {
						offsetWidth += childElList[i].offsetWidth;

						if (tabBoxWidth < offsetWidth) {
							marginLeft = curMarginLeft - (offsetWidth - tabBoxWidth);
							index = i;

							break;
						}
					}
				} else {
					index = index - 1;
					marginLeft = curMarginLeft - childElList[index].offsetWidth;
				}

				if (index !== 0 && UiUtil.isLine(childElList[index - 1])) {
					marginLeft = marginLeft - childElList[index - 1].offsetWidth;
					index = index - 1;
				}

				if (index === 0) {
					firstTabEl.style.removeProperty("margin-left");

					// prev 가 더이상 움직이지 못하므로, prev 를 disable 해준다.
					if (!UiUtil.isDisabled(prevBtnEl)) {
						this._setDisable(prevBtnEl);
					}
				} else {
					firstTabEl.style.setProperty("margin-left", (marginLeft * -1) + _pxStr);
				}

				menuScrollInfo.direction = _defineValue.PREV;
			} else if (value === _defineValue.NEXT) {
				// next 버튼을 눌렀을 때, prev 가 disabled 되어 있다면 해제해준다.
				if (UiUtil.isDisabled(prevBtnEl)) {
					this._setEnable(prevBtnEl);
				}

				if (!direction || direction !== value) {
					offsetWidth = 0;

					for (i = index; i < length; ++i) {
						offsetWidth += childElList[i].offsetWidth;

						if (tabBoxWidth < offsetWidth) {
							marginLeft = curMarginLeft + (offsetWidth - tabBoxWidth);
							index = i;

							break;
						}
					}
				} else {
					index = index + 1;
					marginLeft = curMarginLeft + childElList[index].offsetWidth;
				}

				if (index !== length && UiUtil.isLine(childElList[index + 1])) {
					marginLeft = marginLeft + childElList[index + 1].offsetWidth;
					index = index + 1;
				}

				firstTabEl.style.setProperty("margin-left", (marginLeft * -1) + _pxStr);

				if (index === length - 1) {
					// next 로 더이상 움직이지 못하므로, next 를 disable 해준다.
					if (!UiUtil.isDisabled(nextBtnEl)) {
						this._setDisable(nextBtnEl);
					}
				}

				menuScrollInfo.direction = _defineValue.NEXT;
			}

			menuScrollInfo.index = index;

			return true;
		},

		/**
		 * list 의 item 중, start idx 로부터 첫번째로 visible 인 element 를 찾아 돌려주는 함수
		 * @param {Array} elList				- 검사할 리스트
		 * @param {Number} startIdx			- 검색 시작 인덱스
		 * @param {Number} endIdx				- 검색 종료 인덱스
		 *
		 * @returns {Object}
		 */
		_findVisibleElInfoFromChildElList: function (elList, startIdx, endIdx) {
			var elInfo = null,
				i = startIdx,
				el;

			if (!elList || startIdx < 0 || endIdx < -1) {
				return elInfo;
			}

			while (i !== endIdx) {
				el = elList[i];

				// 해당 함수는 visible 된 element 를 찾는 함수이다.
				// 그리고 밖에서는 line 인지를 체크하게 되는데, 이때 message area 등
				// calculate area 가 아닌 영역들도 체크해야 한다.
				// 그리고 calculate area 가 아닌 영역은 hidden 처리가 되었을 수 있다.
				// 따라서 hidden 이 아닌 타겟을 우선적으로 체크하여 돌려주며, 그렇지 않더라도
				// calculate area 가 아닌 영역일 경우에도 해당 element 를 돌려주도록 한다.
				if (!UiUtil.isHidden(el) || !UiUtil.isCalculateArea(el)) {
					elInfo = {
						el: el,
						idx: i
					};

					break;
				}

				if (startIdx < endIdx) {
					i++;
				} else {
					i--;
				}
			}

			return elInfo;
		},

		/**
		 * Toolbar 의 스크롤 버튼을 누를 경우, 이동시켜 줄 값을 구해 돌려주는 함수
		 * @param {String} dir					- 움직일 방향
		 * @param {String} prevDir				- 직전에 움직였던 방향
		 * @param {Array} elList				- 검사할 리스트
		 * @param {Number} startIdx			- 검색 시작 인덱스
		 * @param {Number} posX				- 기준이 되는 x 좌표
		 * @param {Number} prevMarginLeft		- 이전 적용되어 있는 마진 값
		 * @param {Element=} target			- 이동 할 target 의 command element
		 *
		 * @returns {Object}
		 */
		_calculateMarginToToolBarScroll: function (dir, prevDir, elList, startIdx, posX, prevMarginLeft, target) {
			var marginInfo = null,
				i = startIdx,
				isDirPrev = (dir === _defineValue.PREV),
				childPosX = 0,
				endIdx, el, childPos, childMarginLeft, curMarginRight, targetIdx;

			if (isDirPrev) {
				i = (prevDir !== dir) ? elList.length - 1 : i - 1;
				endIdx = 0;

			} else {
				if (prevDir && prevDir === dir) {
					i++;
				}
				endIdx = elList.length - 1;
			}

			if ((isDirPrev && i < endIdx) || (!isDirPrev && i > endIdx)) {
				return marginInfo;
			}

			targetIdx = endIdx;

			while (i !== endIdx) {
				el = elList[i];

				if (UiUtil.isCalculateArea(el) && !UiUtil.isHidden(el)) {
					childPos = el.getBoundingClientRect();

					if (isDirPrev) {
						childMarginLeft = FrameworkUtil.getNumberFromStyleValue(el, "marginLeft");
						childPosX = childPos.left - childMarginLeft;

						// 이동되어야 하는 target 까지 체크
						if (childPosX <= posX && (!target || el == target)) {
							targetIdx = i;
							break;
						}
					} else {
						curMarginRight = FrameworkUtil.getNumberFromStyleValue(el, "marginRight");
						childPosX = childPos.left + childPos.width + curMarginRight;

						// 이동되어야 하는 target 까지 체크
						if (posX < childPosX && (!target || el == target)) {
							targetIdx = i;
							break;
						}
					}
				}

				if (isDirPrev) {
					i--;
				} else {
					i++;
				}
			}

			marginInfo = {
				marginLeft: prevMarginLeft + childPosX - posX,
				idx: targetIdx
			};

			return marginInfo;
		},

		/**
		 * resize 중 tool bar menu 의 감추어진 영역이 보여야 할 경우,
		 * resize 한만큼 margin left 를 업데이트 하는 함수
		 *
		 * @param {String} toolBarId		- tool bar 의 id (ex. title bar 의 id, menu bar id ...)
		 * @returns {void|Boolean}
		 * @private
		 */
		_updateMarginLeftToToolBar: function (toolBarId) {
			var menuScrollInfo = this.getMenuScrollInfo(toolBarId),
				prevWindowSize = _prevWindowSize,
				curWindowSize = window.innerWidth,
				isUpdateLeft = false,
				menuWrapEl, navBoxEl, nextBtnNavEl, curMarginLeft, firstChildEl;

			if (menuScrollInfo == null) {
				return;
			}

			menuWrapEl = menuScrollInfo.menuBoxEl;
			navBoxEl = menuScrollInfo.navBoxEl;

			if (!menuWrapEl || !navBoxEl) {
				return;
			}

			nextBtnNavEl = navBoxEl.lastElementChild;

			firstChildEl = menuWrapEl.firstElementChild;

			if (toolBarId !== _titleBarId) {
				firstChildEl = navBoxEl.nextElementSibling;
			}

			if (!firstChildEl) {
				return;
			}

			curMarginLeft = parseInt(firstChildEl.style.marginLeft || 0, 10);

			if (!UiUtil.isHidden(navBoxEl) && UiUtil.isHidden(nextBtnNavEl)) {
				curMarginLeft = curMarginLeft + (curWindowSize - prevWindowSize);
				isUpdateLeft = true;

				if (0 <= curMarginLeft) {
					firstChildEl.style.removeProperty("margin-left");

					this._setHidden(navBoxEl);
					this._setHidden(navBoxEl.firstElementChild);
					this._setVisible(nextBtnNavEl);
				} else {
					firstChildEl.style.setProperty("margin-left", curMarginLeft + _pxStr);
				}
			} else if (UiUtil.isHidden(navBoxEl) && curMarginLeft < 0) {
				firstChildEl.style.removeProperty("margin-left");
			}

			return isUpdateLeft;
		},

		/**
		 * menu (tab, menubar, titlebar 등) 대한 scroll 을 해야하는 상황에만 scroll 시키는 함수
		 * @param {Element} target				- 대상 target
		 * @returns {Boolean} 스크롤 했다면 true / 아닐경우 false
		 */
		_updateToolBarScrollIfNeeded: function (target) {
			var toolBarIdList = [_titleBarId, _menuBarId, _styleBarId],
				containerEl = UiUtil.findContainerNodeToParent(target),
				direction = "",
				commandWrapEl, toolBarId, menuScrollInfo, menuBoxEl, navBoxEl,
				posX, targetOffset, targetPosX, nextBtnNavEl;

			if (!containerEl || toolBarIdList.indexOf(containerEl.id) === -1) {
				return false;
			}

			toolBarId = containerEl.id;
			menuScrollInfo = this.getMenuScrollInfo(toolBarId);

			if (!menuScrollInfo || UiUtil.isHidden(menuScrollInfo.navBoxEl)) {
				return false;
			}

			menuBoxEl = menuScrollInfo.menuBoxEl;
			navBoxEl = menuScrollInfo.navBoxEl;
			commandWrapEl = UiUtil.findCommandWrapToParent(target, containerEl) || target.parentNode;
			targetOffset = commandWrapEl.getBoundingClientRect();

			// 1. prev 방향으로 이동해야 되는 상황인지 먼저 체크
			if (!UiUtil.isHidden(navBoxEl.firstElementChild)) {
				posX = menuBoxEl.getBoundingClientRect().left + FrameworkUtil.getNumberFromStyleValue(menuBoxEl, "paddingLeft");
				targetPosX = targetOffset.left - FrameworkUtil.getNumberFromStyleValue(commandWrapEl, "marginLeft");

				if (targetPosX < posX) {
					direction = _defineValue.PREV;
				}
			}

			// 2. prev 로 이동해야 할 상황이 아니면, next 로 이동해야 되는 상황인지 체크
			if (!direction) {
				nextBtnNavEl = navBoxEl.lastElementChild;

				if (UiUtil.isHidden(nextBtnNavEl)) {
					return false;
				}

				posX = nextBtnNavEl.getBoundingClientRect().left;
				targetPosX = targetOffset.left + targetOffset.width +
					FrameworkUtil.getNumberFromStyleValue(commandWrapEl, "marginRight");

				if (posX < targetPosX) {
					direction = _defineValue.NEXT;
				}
			}

			// 3. prev 혹은 next 로 이동해야 할 상황이면 menu 를 스크롤 해줌
			if (direction) {
				this._updateToolBarScroll(toolBarId, direction, commandWrapEl);

				return true;
			}

			return false;
		},

		/**
		 * Tool bar 영역(title bar/menu bar/style bar)에 대한 scroll 을 처리하는 함수
		 * @param {String} toolBarId				- tool bar container 의 id (ex. title_bar / menu_bar ...)
		 * @param {String} value				- 스크롤 방향을 결정하는 값(prev, next)
		 * @param {Element=} target				- 이동 할 target 의 command element
		 * @returns {Boolean}
		 */
		_updateToolBarScroll: function (toolBarId, value, target) {
			var menuScrollInfo = this.getMenuScrollInfo(toolBarId),
				startIdx = 0,
				curMarginLeft, menuBoxEl, navBoxEl, paddingLeft, paddingRight,
				totalWidth, direction, index, childElList, firstMenuEl,
				marginLeft, length, prevBtnNavEl, nextBtnNavEl,
				childEl, posX, menuBoxWidth, marginInfo, elInfo;

			if (!menuScrollInfo) {
				return false;
			}

			menuBoxEl = menuScrollInfo.menuBoxEl;
			navBoxEl = menuScrollInfo.navBoxEl;
			totalWidth = menuScrollInfo.totalWidth || 0;
			direction = menuScrollInfo.direction;
			index = menuScrollInfo.index;

			if (!menuBoxEl || !navBoxEl || totalWidth === 0 || menuBoxEl.children.length === 0) {
				return false;
			}

			paddingLeft = FrameworkUtil.getNumberFromStyleValue(menuBoxEl, "paddingLeft");
			paddingRight = FrameworkUtil.getNumberFromStyleValue(menuBoxEl, "paddingRight");

			childElList = menuScrollInfo.childElArr;
			length = childElList.length;

			if (toolBarId === _titleBarId) {
				firstMenuEl = menuBoxEl.children[0];
			} else {
				firstMenuEl = navBoxEl.nextElementSibling;
			}

			if (!firstMenuEl) {
				return false;
			}

			curMarginLeft = parseInt(firstMenuEl.style.marginLeft || 0, 10) * -1;

			prevBtnNavEl = navBoxEl.firstElementChild;
			nextBtnNavEl = navBoxEl.lastElementChild;

			if (value === _defineValue.PREV) {
				if (UiUtil.isHidden(prevBtnNavEl)) {
					return true;
				}

				// prev 버튼을 눌렀을 때, next 가 hide 되어 있다면 해제해준다.
				if (UiUtil.isHidden(nextBtnNavEl)) {
					this._setVisible(nextBtnNavEl);
				}

				posX = prevBtnNavEl.getBoundingClientRect().right;

				// prev 버튼을 누를 경우, 적절한 target 을 찾고 해당 타겟이 옮길 마진과 index 를 구해온다.
				marginInfo = this._calculateMarginToToolBarScroll(
					value, direction, childElList, index, posX, curMarginLeft, target);

				if (!marginInfo) {
					return false;
				}

				marginLeft = marginInfo.marginLeft;
				index = marginInfo.idx;

				// index 가 처음이 아니면서 이전 idx 가 라인이면, 라인까지 포함하여 움직이도록 조정한다.
				if (index !== startIdx) {
					elInfo = this._findVisibleElInfoFromChildElList(childElList, index - 1, startIdx - 1);

					if (elInfo) {
						childEl = elInfo.el;

						if (UiUtil.isLine(childEl)) {
							index = elInfo.idx;
							marginLeft -= (childEl.offsetWidth +
							FrameworkUtil.getNumberFromStyleValue(childEl, "marginLeft") +
							FrameworkUtil.getNumberFromStyleValue(childEl, "marginRight"));
						}
					}
				}

				if (index === startIdx) {
					// prev 로 더이상 움직이지 못하므로, prev 를 hide 하고 margin 을 제거한다.
					firstMenuEl.style.removeProperty("margin-left");

					if (!UiUtil.isHidden(prevBtnNavEl)) {
						this._setHidden(prevBtnNavEl);
					}
				} else {
					firstMenuEl.style.setProperty("margin-left", (marginLeft * -1) + _pxStr);
				}

				menuScrollInfo.direction = _defineValue.PREV;
			} else if (value === _defineValue.NEXT) {
				if (UiUtil.isHidden(nextBtnNavEl)) {
					return true;
				}

				// next 버튼을 눌렀을 때, prev 가 hide 되어 있다면 해제해준다.
				if (UiUtil.isHidden(prevBtnNavEl)) {
					this._setVisible(prevBtnNavEl);
				}

				posX = nextBtnNavEl.getBoundingClientRect().left;
				marginInfo = this._calculateMarginToToolBarScroll(
					value, direction, childElList, index, posX, curMarginLeft, target);

				if (!marginInfo) {
					return false;
				}

				marginLeft = marginInfo.marginLeft;
				index = marginInfo.idx;

				if (index !== length - 1) {
					elInfo = this._findVisibleElInfoFromChildElList(childElList, index + 1, length);

					if (elInfo) {
						childEl = elInfo.el;

						// next idx 가 라인이라면 해당 width 까지 포함
						// next idx 가 calculate 대상이 아니라면, idx 만 next idx 로 대체
						if (UiUtil.isLine(childEl)) {
							index = elInfo.idx;
							marginLeft += (childEl.offsetWidth +
							FrameworkUtil.getNumberFromStyleValue(childEl, "marginLeft") +
							FrameworkUtil.getNumberFromStyleValue(childEl, "marginRight"));
						} else if (!UiUtil.isCalculateArea(childEl)) {
							index = elInfo.idx;

							if (index !== length - 1 && UiUtil.isUiOptionArea(childElList[index + 1])) {
								index++;
							}
						}
					}
				}

				// 최대 margin 값은 menuBoxWidth
				menuBoxWidth = menuBoxEl.offsetWidth - (paddingLeft + paddingRight);

				if (index === length - 1) {
					// next 로 더이상 움직이지 못하므로, next 를 hide 하고 margin 최대치로 처리한다.
					marginLeft = totalWidth - menuBoxWidth;

					if (!UiUtil.isHidden(nextBtnNavEl)) {
						this._setHidden(nextBtnNavEl);
					}
				} else {
					// 마진은 최대 줄 수 있는 값이 정해져 있으므로, 이 값을 넘어가면 보정해준다.
					if (totalWidth - menuBoxWidth <= marginLeft) {
						marginLeft = totalWidth - menuBoxWidth;
					}
				}

				firstMenuEl.style.setProperty("margin-left", (marginLeft * -1) + _pxStr);
				menuScrollInfo.direction = _defineValue.NEXT;
			}

			menuScrollInfo.index = index;

			return true;
		},

		/**
		 * menu (tab, menubar, titlebar 등) 대한 scroll 을 처리하는 함수
		 * @param {Element} target				- 대상 target
		 * @param {Object} uiValue				- node 에 있는 ui value
		 * @returns {Boolean}
		 */
		_updateMenuScroll: function (target, uiValue) {
			var result = false,
				isClosed = false,
				containerEl, toolBarId;

			// TODO: Tab 에 대해서는 이전에 구현된 내용이기 때문에
			// 해당 코드가 반영된 이후, 리팩토링을 통해 tab 과 그 외 스크롤 처리 함수들을 하나로 통합할 예정이다.
			if (CommonFrameUtil.hasClass(target, UiDefine.TAB_SCROLL_CLASS)) {
				result = this._updateTabScroll(uiValue);
			} else {
				isClosed = this.closeLayerMenu();

				if (!isClosed) {
					containerEl = UiUtil.findContainerNodeToParent(target);
					toolBarId = containerEl && containerEl.id;
				}

				result = this._updateToolBarScroll(toolBarId, uiValue);
			}

			return result;
		},

		/**
		 * 현재 대상 dropdown toggle
		 * @param {Element} target				- toggle 할 target node
		 * @returns {Boolean} toggle 결과 (true:on, false:off)
		 */
		_toggleDropdown: function (target) {
			var layerMenu = UiFrameworkInfo.getLayerMenuOn(),
				curLayerMenu = layerMenu[layerMenu.length - 1],
				btnComboArrowClass = UiDefine.BTN_COMBO_ARROW_CLASS,
				isArrow = CommonFrameUtil.hasClass(target, btnComboArrowClass),
				arrowNode = isArrow ? target : target.nextElementSibling,
				boxEl = arrowNode ? arrowNode.nextElementSibling : null,
				parentNode = target.parentNode,
				result = false,
				scrollTopVal = 0,
				radioInputEl, onDropdownData, confirmBtn, inputEl, inputColorVal, hsvColor, colorPickerContentEl;

			target = target || curLayerMenu;

			if (target.getAttribute(_dataUiCommand) !== _uiCommandNames.DROPDOWN || !boxEl) {
				return false;
			}

			// 최근 dropdown 의 layer 를 누른 경우
			if (curLayerMenu === arrowNode) {
				if (layerMenu.length > 1) {
					CommonFrameUtil.removeClass(target, _onStr);
					UiFrameworkInfo.removeLayerMenuOn(1);

					if (UiUtil.isDropdown(parentNode) || UiUtil.isCombo(parentNode)) {
						CommonFrameUtil.removeClass(parentNode, UiDefine.DROPDOWN_HOVER_CLASS);
					}

				} else {
					this.closeLayerMenu();
				}
			} else {
				// 그렇지 않고 dropdown 이 disable 상태가 아닌 경우
				if (!CommonFrameUtil.hasClass(parentNode, _eventActionType.DISABLE)) {
					// dropdown layer 안에 dropdown 을 누른 상태가 아닌 경우
					if (!CommonFrameUtil.findParentNode(parentNode, "." + _dropdownSelectListWrapClass)) {
						this.closeLayerMenu();

						// dropdown layer 안에 dropdown 을 누른 상태가 아니면서,
						// 상위의 dropdown 을 누른경우 모든 layer 를 닫고 끝낸다.
						if (CommonFrameUtil.contains(layerMenu, target)) {
							return false;
						}
					}

					if (CommonFrameUtil.hasClass(boxEl, _colorPickerClass)) {
						radioInputEl = boxEl.querySelector("input[type=radio]:checked");
						// checked 된 radio 가 없으면 첫번째 radio 를 checked 한다.
						if (!radioInputEl) {
							radioInputEl = boxEl.querySelector("input[type=radio]");
							if (radioInputEl) {
								radioInputEl.checked = true;
							}
						}

						inputEl = boxEl.querySelector("." + UiDefine.PREVIEW_COLOR_TEXT_CLASS + ">input");

						if (inputEl) {
							// color picker 열릴 때, 현재 input 값을 confirm 버튼에 setting
							confirmBtn = boxEl.querySelector("." + UiDefine.SPECTRUM_COLOR_CONFIRM_CLASS);
							inputColorVal = "#" + inputEl.value;

							if (confirmBtn) {
								confirmBtn.setAttribute(UiDefine.DATA_VALUE, inputColorVal);
							}

							// 현재 hsv 색상 정보 갱신
							hsvColor = CommonFrameUtil.getHexToHsv(inputColorVal);
							colorPickerContentEl = boxEl.querySelector("." + UiDefine.SPECTRUM_COLOR_CONTENT_CLASS);
							UiUtil.setCurHsvColor(colorPickerContentEl, hsvColor.h, hsvColor.s, hsvColor.v);
						}
					}

					CommonFrameUtil.addClass(arrowNode, _onStr);
					if (UiUtil.isDropdown(parentNode) || UiUtil.isCombo(parentNode)) {
						CommonFrameUtil.addClass(parentNode, UiDefine.DROPDOWN_HOVER_CLASS);
					}

					this.setDropdownPosition(boxEl);

					if (CommonFrameUtil.hasClass(boxEl, _dropdownSelectListWrapClass) && CommonFrameUtil.hasScroll(boxEl, _topStr)) {
						onDropdownData = boxEl.getElementsByClassName(_onStr);

						if (onDropdownData && onDropdownData.length) {
							onDropdownData = onDropdownData[0];

							scrollTopVal = CommonFrameUtil.getOffsetTop(onDropdownData, boxEl);
							scrollTopVal -= CommonFrameUtil.getOffsetHeight(boxEl) - CommonFrameUtil.getOffsetHeight(onDropdownData) - UiDefine.DROPDOWN_DATA_MARGIN;
						}

						boxEl.scrollTop = Math.max(0, scrollTopVal);
					}

					result = true;
					UiFrameworkInfo.addLayerMenuOn(arrowNode);
				}
			}

			return result;
		},

		/**
		 * dropdown box의 위치(position)를 적용하는 함수
		 * @param {Element=} boxEl      - dropdown box 엘리먼트
		 */
		setDropdownPosition : function(boxEl) {
			var layerMenu = UiFrameworkInfo.getLayerMenuOn(),
				firstLayerMenu = layerMenu[0],
				isToggle = false,
				parentNode, boxElStyle, arrowDirection, pos;

			if (!boxEl) {
				//스크롤 or 리사이즈 할 경우
				if (!firstLayerMenu) {
					return;
				}

				boxEl = firstLayerMenu.nextElementSibling;
				parentNode = firstLayerMenu.parentNode;

				if (!CommonFrameUtil.hasClass(boxEl, UiDefine.DROPDOWN_SELECT_LIST_WRAP_CLASS)) {
					// dropdown 의 box 가 아니라면 boxEl 로 취급하지 않음
					boxEl = null;
				}

			} else {
				//드롭다운 버튼을 클릭해서 처음 레이어가 open 되는 경우
				parentNode = boxEl.parentNode;
				isToggle = true;
			}

			if (parentNode && boxEl) {
				boxElStyle = boxEl.style;
				boxElStyle.removeProperty(_topStr);
				boxElStyle.removeProperty(_defineValue.BOTTOM);
				boxElStyle.removeProperty(_leftStr);

				arrowDirection = parentNode.getAttribute(UiDefine.DATA_ARROW_DIRECTION);

				pos = this._getPosIfDropdownOverflow(parentNode, arrowDirection, firstLayerMenu, isToggle);

				if (pos) {
					if (pos.top) {
						boxElStyle.setProperty(_topStr, pos.top);
					}

					if (pos.bottom) {
						boxElStyle.setProperty(_defineValue.BOTTOM, pos.bottom);
					}

					if (pos.left) {
						boxElStyle.setProperty(_leftStr, pos.left);
					}
				}
			}
		},

		/**
		 * 현재 대상 titleBar toggle
		 * @param {Element} target				- toggle 할 target node
		 * @returns {Boolean} toggle 결과 (true:on, false:off)
		 */
		_toggleTitleBarMenu: function(target) {
			var result = false,
				isTitleBarMenuOn = this.isTitleBarMenuOn(),
				titleBarMenu;

			this.closeLayerMenu();

			if (!isTitleBarMenuOn) {
				titleBarMenu = UiFrameworkInfo.getContainerNode(_titleBarId);
				CommonFrameUtil.addClass(titleBarMenu, _onStr);
				UiFrameworkInfo.addLayerMenuOn(titleBarMenu);

				if (target) {
					FrameworkUtil.setTitleBarMenuOverOn(target);
				}
			}

			return result;
		},

		/**
		 * 현재 대상 menu toggle (여러개 중복 on 가능한 경우에만 사용)
		 * @param {Element} target		- toggle 할 target node
		 */
		_toggleMenu: function(target) {
			if (UiUtil.isButtonOn(target)) {
				CommonFrameUtil.removeClass(target, _onStr);
			} else {
				CommonFrameUtil.addClass(target, _onStr);
			}
		},

		/**
		 * context menu open
		 * @param {Object=} pos				- open 할 위치 {top,left} (미지정시 마지막값)
		 * @param {Element=} curLayerMenu		- 현재 열려있는 layerMenu (미지정시 구함)
		 */
		_openContextMenu: function(pos, curLayerMenu) {
			var contextMenu = UiFrameworkInfo.getContextMenu(),
				contextMenuStyle = contextMenu.style,
				resultPos;

			curLayerMenu = curLayerMenu || UiFrameworkInfo.getLayerMenu();

			if (curLayerMenu && curLayerMenu !== contextMenu) {
				this.closeLayerMenu();
			}

			CommonFrameUtil.removeClass(contextMenu, _hideViewClassName);

			contextMenuStyle.removeProperty(_topStr);
			contextMenuStyle.removeProperty(_leftStr);

			if (pos && pos.top != null && pos.left != null) {
				resultPos = FrameworkUtil.getPosToContextMenu(pos.top, pos.left);

				contextMenuStyle.setProperty(_topStr, resultPos.top);
				contextMenuStyle.setProperty(_leftStr, resultPos.left);
			}
		},

		/**
		 * context menu close
		 */
		_closeContextMenu: function() {
			var contextMenuEl = UiFrameworkInfo.getContextMenu(),
				isClosed = false;

			if (contextMenuEl && !CommonFrameUtil.hasClass(contextMenuEl, _hideViewClassName)) {
				CommonFrameUtil.addClass(contextMenuEl, _hideViewClassName);
				isClosed = true;
			}

			return isClosed;
		},

		// commandName 에 해당하는 toggleButton 끔
		_offToggleCommandButton: function(commandName, uiCommand, valueKey) {
			if (!commandName) {
				return [];
			}

			var toggleButtonOn = UiFrameworkInfo.getInfo(UiFrameworkInfo.TOGGLE_BUTTONS_ON),
				curToggleOnButtonsArr = toggleButtonOn[commandName],
				isFontNameCmd = (commandName === _eventActionNames.FONT_NAME || valueKey === _eventActionNames.FONT_NAME),
				curToggleButtonOn = [],
				curBtn, len, i;

			if (curToggleOnButtonsArr) {
				len = curToggleOnButtonsArr.length;

				for (i = 0; i < len; i++) {
					curBtn = curToggleOnButtonsArr[i];

					if (!uiCommand || uiCommand === curBtn.getAttribute(_dataUiCommand)) {
						this._setButtonOff(curBtn);

						if (isFontNameCmd && CommonFrameUtil.hasClass(curBtn, UiDefine.NO_SUCH_FONT_DATA_CLASS)) {
							this._setHidden(curBtn);
						}
					} else {
						curToggleButtonOn[curToggleButtonOn.length] = curBtn;
					}
				}
				toggleButtonOn[commandName] = curToggleButtonOn;
			}

			return curToggleOnButtonsArr || [];
		},

		// commandName 으로 toggleButton 에 buttonNode 추가
		_pushToggleCommandButton: function(commandName, buttonNode) {
			var toggleButtonOn = UiFrameworkInfo.getInfo(UiFrameworkInfo.TOGGLE_BUTTONS_ON),
				curToggleOnButtonsArr = toggleButtonOn[commandName];

			if (!curToggleOnButtonsArr) {
				curToggleOnButtonsArr = [];
				toggleButtonOn[commandName] = curToggleOnButtonsArr;
			}

			curToggleOnButtonsArr[curToggleOnButtonsArr.length] = buttonNode;
		},

		_addCommandValueKey: function (cmdName, newValueKeyArr, sampleName) {
			var valueKeyArrMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.COMMAND_TO_VALUE_KEY_ARR_MAP),
				valueKeyArr = valueKeyArrMap[cmdName] || [],
				widgetNameToValueKeyMap, i, newKeyLength, valueKey;

			if (!sampleName) {
				sampleName = cmdName;
			}

			if (valueKeyArr.length && newValueKeyArr.length) {
				// 중복 제거
				newValueKeyArr = CommonFrameUtil.without(newValueKeyArr, valueKeyArr);
			}

			newKeyLength = newValueKeyArr.length;

			if (newKeyLength) {
				_sampleValueKeyInfo[sampleName] = (_sampleValueKeyInfo[sampleName] || []).concat(newValueKeyArr);
				valueKeyArrMap[cmdName] = valueKeyArr.concat(newValueKeyArr);

				widgetNameToValueKeyMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_NAME_TO_VALUE_KEY_MAP);

				for (i = 0; i < newKeyLength; i++) {
					valueKey = newValueKeyArr[i];
					widgetNameToValueKeyMap[UiUtil.getWidgetName(cmdName, valueKey)] = valueKey;
				}
			}
		},

		_removeCommandValueKey: function (cmdName, removeValueKeyArr, isRemoveAll, sampleName) {
			var valueKeyArrMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.COMMAND_TO_VALUE_KEY_ARR_MAP),
				valueKeyArr = valueKeyArrMap[cmdName],
				removeKeyLength = removeValueKeyArr ? removeValueKeyArr.length : 0,
				widgetNameToValueKeyMap, i;

			if (!sampleName) {
				sampleName = cmdName;
			}

			if (removeKeyLength && valueKeyArr && valueKeyArr.length) {
				valueKeyArrMap[cmdName] = CommonFrameUtil.without(valueKeyArr, removeValueKeyArr);

				_sampleValueKeyInfo[sampleName] = isRemoveAll ?
					[] : CommonFrameUtil.without(_sampleValueKeyInfo[sampleName], removeValueKeyArr);

				widgetNameToValueKeyMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_NAME_TO_VALUE_KEY_MAP);

				for (i = 0; i < removeKeyLength; i++) {
					delete widgetNameToValueKeyMap[UiUtil.getWidgetName(cmdName, removeValueKeyArr[i])];
				}
			}
		},

		_checkUpdateSubgroup: function(checkSubgroupBoxArr, type) {
			var isEnableType = (type === _eventActionType.ENABLE),
				isDisableType = (!isEnableType && type === _eventActionType.DISABLE),
				isHiddenType = (type === _eventActionType.HIDDEN),
				isVisibleType = (!isHiddenType && type === _eventActionType.VISIBLE),
				isNormalType = (!isDisableType && !isEnableType && !isHiddenType && !isVisibleType),
				updated, subgroupBox, subgroupParentEl, parentSubgroupEl, containerNode;

			if (!isNormalType && checkSubgroupBoxArr && checkSubgroupBoxArr.length) {
				subgroupBox = checkSubgroupBoxArr.shift();

				while (subgroupBox) {
					updated = false;
					subgroupParentEl = subgroupBox.parentNode;

					if (isEnableType) {
						if (UiUtil.isDisabled(subgroupParentEl) && subgroupBox.querySelector(_enableWidgetSelector)) {
							// 현재 enable 수행했고, subgroup 이 disable 이면 활성화 여부 검사
							this._setEnable(subgroupParentEl);
							updated = true;
						}
					} else if (isDisableType) { // isDisableType
						if (!UiUtil.isDisabled(subgroupParentEl) && !subgroupBox.querySelector(_enableWidgetSelector)) {
							// 현재 disable 수행했고, subgroup 이 enable 이면 비활성화 여부 검사
							this._setDisable(subgroupParentEl);
							updated = true;
						}
					} else if (isVisibleType) {
						if (UiUtil.isHidden(subgroupParentEl) && subgroupBox.querySelector(_visibleWidgetSelector)) {
							this._setVisible(subgroupParentEl);
							updated = true;
						}
					} else {
						if (!UiUtil.isHidden(subgroupParentEl) && !subgroupBox.querySelector(_visibleWidgetSelector)) {
							// 현재 subgroup 이 hidden 이 안되었는데, 각 버튼이 전부 hidden 이면 hide 를 수행
							this._setHidden(subgroupParentEl);
							updated = true;
						}
					}

					if (updated) {
						containerNode = UiUtil.findContainerNodeToParent(subgroupParentEl);

						if (containerNode) {
							parentSubgroupEl = CommonFrameUtil.findParentNode(
								subgroupParentEl.parentNode, "." + _subGroupBoxClass, containerNode);
						}

						if (parentSubgroupEl && checkSubgroupBoxArr.indexOf(parentSubgroupEl) === -1) {
							checkSubgroupBoxArr.push(parentSubgroupEl);
						}
					}

					subgroupBox = checkSubgroupBoxArr.shift();
				}
			}
		},

		/**
		 * 수행된 eventAction 을 통해 현재 UI 값 (value, disable, hidden 상태) 저장
		 * @param {Object} eventAction
		 * @param {String=} valueKey
		 */
		_updateUiValueMap: function(eventAction, valueKey) {
			if (!_lazyConvertInfo || _lazyConvertInfo.isConvertEnd) {
				return;
			}

			var value = valueKey ? eventAction.value[valueKey] : eventAction.value,
				type = eventAction.type,
				cmdName = eventAction.name,
				targetMap, targetKey, targetArr, isRemove, isNormalType, curValue, index;

			switch (type) {
				case _eventActionType.ENABLE:
					targetMap = _uiDisableMap;
					isRemove = true;
					break;

				case _eventActionType.DISABLE:
					targetMap = _uiDisableMap;
					break;

				case _eventActionType.VISIBLE:
					targetMap = _uiHiddenMap;
					isRemove = true;
					break;

				case _eventActionType.HIDDEN:
					targetMap = _uiHiddenMap;
					break;

				case _eventActionType.VISIBLE_ITEM:
					targetMap = _uiHiddenItemMap;
					isRemove = true;
					break;

				case _eventActionType.HIDDEN_ITEM:
					targetMap = _uiHiddenItemMap;
					break;

				default: // normal type
					targetMap = _uiValueMap;
					isNormalType = true;
			}

			if (valueKey) {
				curValue = targetMap[cmdName];

				if (!curValue || !CommonFrameUtil.isObject(curValue)) {
					if (isRemove) {
						// 이미 해당 값이 없는 상황
						curValue = null;
					} else {
						curValue = {};
						targetMap[cmdName] = curValue;
					}
				}

				/* (valueKey 가 없는 경우와 같은 형태로 변수 치환)
				 * targetMap 을 value Object 로 처리. 일반 value 와 마찬가지 형태로, 현재 valueKey 를 key 로 삼음 */
				targetMap = curValue;
				targetKey = valueKey;

			} else {
				targetKey = cmdName;
			}

			if (targetMap) {
				if (isNormalType) {
					targetMap[targetKey] = value;

				} else {
					targetArr = targetMap[targetKey];

					if ((!targetArr && !isRemove) || (targetArr && !CommonFrameUtil.isArray(targetArr))) {
						targetArr = [];
						targetMap[targetKey] = targetArr;
					}

					if (targetArr) {
						if (value == null) {
							value = "";
						}

						if (value === "") {
							// 전체를 대상으로 하는 value
							targetArr.splice(0, targetArr.length);

							if (!isRemove) {
								targetArr[0] = "";
							}

						} else {
							index = targetArr.indexOf(value);

							if (isRemove) {
								if (index > -1) {
									targetArr.splice(index, 1);
								}

							} else {
								if (index === -1 && targetArr[0] !== "") {
									targetArr[targetArr.length] = value;
								}
							}
						}
					}
				}
			}
		},

		_updateUiShowInfo: function(type, commandName, showValueArr, valueKey) {
			if (!CommonFrameUtil.isArray(showValueArr)) {
				return;
			}

			var length = showValueArr.length,
				widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP),
				value = valueKey ? {} : null,
				curValue, eventAction, i;

			for (i = 0; i < length; i ++) {
				curValue = showValueArr[i];

				if (valueKey) {
					value[valueKey] = curValue;
				} else {
					value = curValue;
				}

				eventAction = {cmd: _updateCmd, type: type, name: commandName, value: value};
				this._updateWidgetByEventAction(widgetMap, eventAction, valueKey);
			}
		},

		/**
		 * 저장된 ui 상태를 update 하는 함수 (disable, hidden, hidden item 값)
		 * @param {Object} uiStatusMap
		 * @param {String} commandName
		 * @param {String} evtActionType
		 */
		_updateUiStatus: function (uiStatusMap, commandName, evtActionType) {
			var uiStatus, valueKeys, length, i, valueKey;

			if (!uiStatusMap || !commandName || !evtActionType) {
				return;
			}

			uiStatus = uiStatusMap[commandName];

			if (uiStatus != null) {
				if (CommonFrameUtil.isObject(uiStatus)) {
					valueKeys = Object.keys(uiStatus);
					length = valueKeys.length;

					for (i = 0; i < length; i++) {
						valueKey = valueKeys[i];
						this._updateUiShowInfo(evtActionType, commandName, uiStatus[valueKey], valueKey);
					}
				} else {
					this._updateUiShowInfo(evtActionType, commandName, uiStatus);
				}
			}
		},

		/**
		 * widget 을 현재 저장된 값으로 setting (value, disable, hidden 값)
		 * @param {String} commandName
		 */
		_updateWidgetByUiValueMap: function(commandName) {
			if (!_lazyConvertInfo || _lazyConvertInfo.isConvertEnd) {
				return;
			}

			var widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP),
				curUiValue = _uiValueMap[commandName],
				valueKeys, length, eventAction, i;

			if (curUiValue != null) {
				valueKeys = (CommonFrameUtil.isObject(curUiValue)) ? Object.keys(curUiValue) : [null];
				length = valueKeys.length;

				for (i = 0; i < length; i++) {
					eventAction = {cmd:_updateCmd, type:"normal", name:commandName, value:curUiValue};
					this._updateWidgetByEventAction(widgetMap, eventAction, valueKeys[i]);
				}
			}

			this._updateUiStatus(_uiDisableMap, commandName, _eventActionType.DISABLE);
			this._updateUiStatus(_uiHiddenMap, commandName, _eventActionType.HIDDEN);
			this._updateUiStatus(_uiHiddenItemMap, commandName, _eventActionType.HIDDEN_ITEM);
		},

		// dropdown data 변경시, 상위의 dropdown, combo 도 갱신
		_updateDropdown: function(target, eventAction, valueKey, subDataWidget, evtWidget) {
			var dropdownValue = valueKey ? eventAction.value[valueKey] : eventAction.value,
				isDontCareValue = (dropdownValue === _dontCareValue),
				isDropdown = UiUtil.isDropdown(target),
				isCombo = !isDropdown && UiUtil.isCombo(target),
				firstChildEl = target.firstElementChild,
				dropdownAnchorEl = (firstChildEl && firstChildEl.nodeName === "A") ? firstChildEl : null,
				widgetName = UiUtil.getWidgetName(eventAction.name, valueKey),
				comboNoUsedState = UiFrameworkInfo.getInfo(UiFrameworkInfo.COMBO_NO_USED_STATE),
				unit = FrameworkUtil.getUnitValue(eventAction.unit, valueKey),
				isNotSpectrum = false,
				unitInfo, updateDropdownColor, iconDiv, dropdownColorEl, dropdownAnchorItem, isColorType, curAnchorValue, evtTarget;

			if (isDontCareValue) {
				this._setButtonDontCare(target);
				dropdownValue = "";

			} else {
				this._setButtonDontCareOff(target);
			}

			if (dropdownAnchorEl && (isDropdown || isCombo)) {
				dropdownAnchorItem = dropdownAnchorEl.firstElementChild;
				if (dropdownAnchorItem && CommonFrameUtil.hasClass(dropdownAnchorItem, UiDefine.BTN_INNER_ICON_CLASS)) {
					iconDiv = dropdownAnchorItem;
					dropdownAnchorItem = dropdownAnchorItem.nextElementSibling;
				}

				if (CommonFrameUtil.hasClass(target, UiDefine.COMBO_ICON_STYLE)) { // normal type
					if (isCombo && (subDataWidget || target.getAttribute(_defineDataValueAttr) === dropdownValue)) {
						this._pushToggleCommandButton(widgetName, target);
						this._setButtonOn(target);
					}

				} else if (CommonFrameUtil.hasClass(target, UiDefine.DROPDOWN_TEXT_TYPE)) { // text type
					// text type 인 경우, dropdown 에서 사용자에게 표시되는 value 로 변경
					dropdownValue = (subDataWidget && subDataWidget.textContent) || String(dropdownValue);

					if (eventAction.name === UiDefine.EVENT_ACTION_NAMES.FONT_NAME &&
						FontManager.getInvalidLicenseFontList().indexOf(dropdownValue) !== -1) {
						// font 의 경우, license 문제로 표시 제외해야 하는 경우 empty string 으로 표현
						dropdownValue = "";
					}

					if (isCombo) {
						FrameworkUtil.setInputText(dropdownAnchorItem, dropdownValue, unit, valueKey, widgetName);

					} else {
						if (CommonFrameUtil.isString(unit)) {
							UiFrameworkInfo.setUnitInfo(widgetName, unit);
						}

						if (dropdownValue && isDropdown) {
							// dropdown 인 경우는 뒤에 단위를 붙여줌
							unitInfo = UiFrameworkInfo.getUnitInfo(widgetName);
							if (unitInfo) {
								dropdownValue += (" " + unitInfo);
							}
						}

						if (iconDiv) { // icon
							dropdownAnchorItem.textContent = dropdownValue;
						} else {
							dropdownAnchorEl.textContent = dropdownValue;
						}
					}

				} else if (CommonFrameUtil.hasClass(target, UiDefine.DROPDOWN_COLOR_WITH_ICON_TYPE)
					|| CommonFrameUtil.hasClass(target, UiDefine.DROPDOWN_COLOR_TYPE)) { // color, colorWithIcon type

					evtTarget = eventAction.target;

					if (evtWidget && evtWidget !== target) {
						// 현재 color dropdown(combo) 외부에서 발생된 event 는 color 선택한 상황이 아니므로 제외한다.
						evtTarget = null;
					}

					isNotSpectrum = !(CommonFrameUtil.hasClass(evtTarget, UiDefine.COLOR_MATRIX_CONTAINER_CLASS)
						&& CommonFrameUtil.hasClass(evtTarget, UiDefine.COLOR_SPECTRUM_CONTAINER_CLASS));

					if (!evtWidget || (evtTarget && isNotSpectrum)) {
						// spectrum or matrix target 인 경우, ui 를 update 하지 않고 내부적으로만 값 적용중인 상태이므로 제외
						if (isCombo) {
							/* combo 색의 변경 여부는 사용자가 직접 Event 발생시켜서 변경하기 전/후로 나눠진다.
							 * 1. 직접 변경한 이전 : 항상 같이 갱신
							 * 2. 직접 변경한 이후 : 사용자가 직접 변경할 때만 갱신
							 */
							if (evtTarget) {
								updateDropdownColor = true;
								comboNoUsedState[widgetName] = true;
							} else {
								updateDropdownColor = !comboNoUsedState[widgetName];
							}
						} else {
							updateDropdownColor = true;
						}
					}

					isColorType = CommonFrameUtil.hasClass(target, UiDefine.DROPDOWN_COLOR_TYPE);
					dropdownColorEl = isColorType ? dropdownAnchorItem : (iconDiv && iconDiv.firstElementChild);

					if (!isDontCareValue && updateDropdownColor && dropdownColorEl) {
						// combo/dropdown 외부로 표시되는 색 변경
						curAnchorValue = dropdownAnchorEl.getAttribute(_defineDataValueAttr);
						if (curAnchorValue && curAnchorValue !== "transparent" && !CommonFrameUtil.isStartsWith(curAnchorValue, "#")) {
							// 기존 theme color
							CommonFrameUtil.removeClass(dropdownColorEl, curAnchorValue + _themeColorClassPostfix);
						}

						if (dropdownValue === "transparent") {
							dropdownColorEl.style.removeProperty("background-color");
							if (isColorType) {
								dropdownColorEl.style.removeProperty("background-image");
							}

						} else {
							if (CommonFrameUtil.isStartsWith(dropdownValue, "#")) {
								if (UiUtil.checkValidationColorCode(dropdownValue) === UiDefine.VALIDATION_CHECK_RESULT.SUCCESS) {
									dropdownColorEl.style.setProperty("background-color", dropdownValue);
								}
							} else { // theme color value
								dropdownColorEl.style.removeProperty("background-color");
								CommonFrameUtil.addClass(dropdownColorEl, dropdownValue + _themeColorClassPostfix);
							}

							if (isColorType) {
								dropdownColorEl.style.setProperty("background-image", "inherit");
							}
						}

						if (isCombo) {
							// 사용자가 직접 EventAction 발생시킨 경우 combo 에 값 변경
							target.setAttribute(_defineDataValueAttr, dropdownValue);
						}

						// anchor 에 현재 표시되는 값 기록
						dropdownAnchorEl.setAttribute(_defineDataValueAttr, dropdownValue);
					}

				} else if (CommonFrameUtil.hasClass(target, UiDefine.DROPDOWN_LINE_STYLE_TYPE)) { // lineStyle type
					if (dropdownAnchorItem) {
						if (dropdownValue) {
							dropdownAnchorItem.setAttribute("class", _lineStyleNamePrefix + "_" + dropdownValue);
						} else {
							dropdownAnchorItem.removeAttribute("class");
						}
					}
				}
			}
		},

		_updateDropdownMatch : function(widget, subDataWidget, isListBoxMatch) {
			var dropdownData = subDataWidget,
				widgetParent = widget ? widget.parentNode : null,
				isUpdateScroll = false,
				updated = false,
				result, widgetWrap, match, matchType, matchNode, matchTarget, matchFuncName, noneMatchFuncName,
				arrMatch, scrollNode, i, len, matchVal, matchNodeParent, matchGroup, matchSelector;

			if (!(dropdownData && widgetParent)) {
				return;
			}

			match = dropdownData.getAttribute(_defineMatchAttr);

			if (!match) {
				return;
			}

			matchType = widgetParent.getAttribute(_defineMatchTypeAttr);
			matchGroup = dropdownData.getAttribute(_defineMatchGroupAttr);

			// widget 의 부모 노드에 matchType 이 없으면, 상위로 올라가면서 matchType 를 찾는다.
			if (!matchType) {
				widgetParent = CommonFrameUtil.findParentNode(widgetParent, "[" + _defineMatchTypeAttr + "]");

				if (widgetParent) {
					matchType = widgetParent.getAttribute(_defineMatchTypeAttr);
				}
			}

			if (!matchType) {
				return;
			}

			if (matchType === "block") {
				matchFuncName = "_setVisible";
				noneMatchFuncName = "_setHidden";
			} else if (matchType === _eventActionType.ENABLE) {
				matchFuncName = "_setEnable";
				noneMatchFuncName = "_setDisable";
			}

			if (!(matchFuncName && noneMatchFuncName)) {
				return;
			}

			widgetWrap = UiUtil.findCommandWrapToParent(subDataWidget.parentNode, widgetParent);
			matchSelector = "[" + _defineMatchAttr + "]";

			if (matchGroup) {
				matchSelector += "[" + _defineMatchGroupAttr + "=" + matchGroup + "]";
			}

			arrMatch = widgetParent.querySelectorAll(matchSelector);
			len = arrMatch.length;

			for (i = 0; i < len; i++) {
				matchNode = arrMatch[i];
				matchNodeParent = matchNode.parentNode;
				matchTarget = matchNode;
				matchVal = (matchNode.getAttribute(_defineMatchAttr) || "").split("|");

				if ((widgetWrap && widgetWrap === UiUtil.findCommandWrapToParent(matchNodeParent, widgetParent))
					|| (isListBoxMatch && UiUtil.isListBox(matchNodeParent))) {
					continue;
				}

				if (matchNode.nodeName === "INPUT") {
					matchTarget = UiUtil.getInputWrapWidgetByInput(matchNode);
				}

				if (matchVal && matchVal.indexOf(match) !== -1) {
					isUpdateScroll = CommonFrameUtil.hasClass(matchTarget, _hideViewClassName);
					result = this[matchFuncName](matchTarget);

					if (matchType === "block") {
						scrollNode = matchTarget;

						while (scrollNode !== widgetParent) {
							if (scrollNode.style.overflowY === _autoStr) {
								if (isUpdateScroll && scrollNode.scrollTop > 0) {
									scrollNode.scrollTop = 0;
								}

								break;
							}

							scrollNode = scrollNode.parentNode;
						}
					}
				} else {
					result = this[noneMatchFuncName](matchTarget);
				}

				updated = updated || result;
			}

			// dialog 가 showing 중이면서,
			// dialog 의 컨텐츠가 숨김/보이기 처리시 높이 및 위치 정보를 갱신한다.
			if (updated && matchType === "block") {
				this._needToUpdateDialogHeight(widget);
			}
		},

		_updateRadioCheckboxMatch : function(widget, isAutoFocus, evtTargetWidget) {
			var inputNode = widget ? UiUtil.getInputElementByWidget(widget) : null,
				widgetParent = widget ? widget.parentNode : null,
				inputType = inputNode ? inputNode.getAttribute("type") : "",
				updated = false,
				result, isChecked, match, matchType, matchNode, matchTarget, matchFuncName, noneMatchFuncName,
				inputChildNode, firstMatchNode, isMatched, arrMatch, i, len, matchGroup, matchSelector, matchVal;

			if (!(inputNode
				&& inputNode.nodeName === "INPUT"
				&& widgetParent
				&& ["radio", "checkbox"].indexOf(inputType) !== -1)) {
				return;
			}

			isChecked = String(inputNode.checked) === _defineValue.TRUE;
			match = inputNode.getAttribute(_defineMatchAttr);
			matchType = widgetParent.getAttribute(_defineMatchTypeAttr);
			matchGroup = inputNode.getAttribute(_defineMatchGroupAttr);

			// match 가 없으면 중단.
			if (!match) {
				return;
			}

			// widget 의 부모 노드에 matchType 이 없으면, 상위로 올라가면서 matchType 를 찾는다.
			if (!matchType) {
				widgetParent = CommonFrameUtil.findParentNode(widgetParent, "[" + _defineMatchTypeAttr + "]");

				if (widgetParent) {
					matchType = widgetParent.getAttribute(_defineMatchTypeAttr);
				}
			}

			if (matchType === "block") {
				matchFuncName = "_setVisible";
				noneMatchFuncName = "_setHidden";
			} else if (matchType === _eventActionType.ENABLE) {
				matchFuncName = "_setEnable";
				noneMatchFuncName = "_setDisable";
			}

			// matchType 에 해당하는 funcName 이 없으면 중단.
			if (!(matchFuncName && noneMatchFuncName)) {
				return;
			}

			matchSelector = "[" + _defineMatchAttr + "]";

			if (inputType === "checkbox") {
				matchSelector = "[" + _defineMatchAttr + "='" + match + "']";
			}

			if (matchGroup) {
				matchSelector += "[" + _defineMatchGroupAttr + "=" + matchGroup + "]";
			}

			arrMatch = widgetParent.querySelectorAll(matchSelector);
			len = arrMatch.length;

			for (i = 0; i < len; i++) {
				matchNode = arrMatch[i];
				matchTarget = matchNode;

				if (matchNode && matchNode.getAttribute("type") !== inputType) {
					if (matchNode.nodeName === "INPUT") {
						matchTarget = UiUtil.getInputWrapWidgetByInput(matchTarget);
					}

					if (inputType === "radio") {
						matchVal = (matchNode.getAttribute(_defineMatchAttr) || "").split("|");
						isMatched = isChecked && matchVal && matchVal.indexOf(match) !== -1;
					} else {
						isMatched = CommonFrameUtil.hasClass(matchNode, UiDefine.MATCH_REVERSE_CLASS) ? !isChecked : isChecked;
					}

					if (isMatched) {
						result = this[matchFuncName](matchTarget);

						if (!firstMatchNode) {
							firstMatchNode = matchTarget;
						}
					} else {
						result = this[noneMatchFuncName](matchTarget);
					}

					updated = updated || result;
				}
			}

			// isAutoFocus=true 이고 match 된 첫번째 노드가 input 일때만 autoFocus 를 수행한다.
			if (isAutoFocus === true && firstMatchNode) {
				// 현재 이벤트가 발생한 widget 일 경우만 autoFocus 를 수행한다.
				if (widget === evtTargetWidget) {
					inputChildNode = UiUtil.getInputElementByWidget(firstMatchNode);

					if (inputChildNode
						&& inputChildNode.nodeName === "INPUT"
						&& inputChildNode.getAttribute("type") !== "checkbox") {
						inputChildNode.focus();
					}
				}
			}

			// dialog 가 showing 중이면서,
			// dialog 의 컨텐츠가 숨김/보이기 처리시 높이 및 위치 정보를 갱신한다.
			if (updated && matchType === "block") {
				this._needToUpdateDialogHeight(widget);
			}
		},

		_updateTabMatch : function(widget) {
			var match = widget.getAttribute(_defineMatchAttr),
				tabBoxEl = widget.parentNode,
				tabGroupEl = tabBoxEl.parentNode,
				widgetParent = tabGroupEl.parentNode,
				updated = false,
				result, curChildEl, matchValue;

			curChildEl = widgetParent.firstElementChild;

			while (curChildEl) {
				matchValue = curChildEl.getAttribute(_defineMatchAttr);
				if (matchValue) {
					if (matchValue === match) {
						result = this._setVisible(curChildEl);
					} else {
						result = this._setHidden(curChildEl);
					}
				}

				updated = updated || result;
				curChildEl = curChildEl.nextElementSibling;
			}

			// dialog 가 showing 중이면서,
			// dialog 의 컨텐츠가 숨김/보이기 처리시 높이 및 위치 정보를 갱신한다.
			if (updated) {
				this._needToUpdateDialogHeight(widget);
			}
		},

		_updateEventActionMatch: function(widget, match) {
			var matchType = widget && widget.getAttribute(_defineMatchTypeAttr),
				updated = false,
				result, matchNode, matchTarget, matchFuncName, noneMatchFuncName, arrMatch, i, len, matchVal;

			if (matchType === "block") {
				matchFuncName = "_setVisible";
				noneMatchFuncName = "_setHidden";
			} else if (matchType === _eventActionType.ENABLE) {
				matchFuncName = "_setEnable";
				noneMatchFuncName = "_setDisable";
			}

			if (!(match && matchFuncName && noneMatchFuncName)) {
				return;
			}

			arrMatch = widget.querySelectorAll("[" + _defineMatchAttr + "]");
			len = arrMatch.length;

			for (i = 0; i < len; i++) {
				matchNode = arrMatch[i];
				matchTarget = matchNode;
				matchVal = (matchNode.getAttribute(_defineMatchAttr) || "").split("|");

				if (matchNode.nodeName === "INPUT") {
					matchTarget = UiUtil.getInputWrapWidgetByInput(matchNode);
				}

				if (matchVal && matchVal.indexOf(match) !== -1) {
					result = this[matchFuncName](matchTarget);

				} else {
					result = this[noneMatchFuncName](matchTarget);
				}

				updated = updated || result;
			}

			// dialog 가 showing 중이면서,
			// dialog 의 컨텐츠가 숨김/보이기 처리시 높이 및 위치 정보를 갱신한다.
			if (updated && matchType === "block") {
				this._needToUpdateDialogHeight(widget);
			}
		},

		_updateWidget: function(widgetMap, cmdName, value, valueKey, uiCommand) {
			var eventAction = {
					cmd: _updateCmd,
					name: cmdName,
					value: value
				},
				objVal;

			if (valueKey) {
				objVal = {};
				objVal[valueKey] = value;
				eventAction.value = objVal;
			}

			if (uiCommand) {
				eventAction.uiCommand = uiCommand;
			}

			return this._updateWidgetByEventAction(widgetMap, eventAction, valueKey);
		},

		_updateWidgetByEventAction: function(widgetMap, eventAction, valueKey, widgetNode) {
			if (!valueKey && CommonFrameUtil.isObject(eventAction.value)) {
				return [];
			}

			var value = valueKey ? eventAction.value[valueKey] : eventAction.value,
				type = eventAction.type,
				cmdName = eventAction.name,
				target = eventAction.target,
				uiCommand = eventAction.uiCommand,
				evtActionType = UiUtil.getEventActionType(type),
				widgetName = UiUtil.getWidgetName(cmdName, valueKey),
				checkSubgroupBoxArr = null,
				widgetArr = UiFrameworkInfo.getWidgetArr(cmdName, value, valueKey, widgetNode, widgetMap, uiCommand),
				widget = widgetArr[0] || null,
				isComboDropdown, subDataWidget, subDataWidgets, unit, match, isDontCareValue, curValue,
				widgetValue, update, inputEl, isRadio, isCheckbox, hasSubGroupBoxClass,
				boxEl, hasSampleWrapClass, toggleOffWidgets, widgetIdx, selector, updateDescVal,
				targetLayerNode, evtTargetWidget, queryStr, needVisibilityExecute, isChecked, isUpdateSelectAll,
				cmdItemIndex, widgetParent, orgFontValue, checkMoveEl, isLockState, updated;

			if (target) {
				// eventAction.target 의 상위로부터 widget 구함
				targetLayerNode = UiUtil.findContainerInfoToParent(target).layerNode;

				if (targetLayerNode
					&& (UiUtil.isDropdown(targetLayerNode.parentNode) || UiUtil.isCombo(targetLayerNode.parentNode))) {
					evtTargetWidget = targetLayerNode.parentNode;
				} else if (UiUtil.isCombo(target.parentNode)) {
					evtTargetWidget = target.parentNode;
				} else {
					evtTargetWidget = target;
				}
			}

			if (evtActionType.isNormalType) {
				toggleOffWidgets = this._offToggleCommandButton(widgetName, uiCommand, valueKey);
				if (value === _defineValue.OFF) {
					// off 인 경우 이미 수행 종료됨
					checkMoveEl = widget;
					widget = null;
					widgetArr = widgetArr.length ? widgetArr : toggleOffWidgets;
				}

			} else if (evtActionType.isEnableType) {
				isLockState = _updateUiLockState(widgetName, false);

				if (isLockState) {
					// 현재 lock 되어있는 경우 활성화는 막는다.
					widget = null;
				} else if (_appMode === _watcherMode && _watcherModeEnableCommands.indexOf(cmdName) === -1) {
					// watcher mode 인 경우 허용되지 않은 enable 은 제외
					widget = null;
				} else if (_uiOptionsArr) {
					// uiOption 에 의해 비활성화되어있는 버튼은 활성화하지 않음
					if (_isHideUiOptionView && widget
						&& _uiOptionsArr.indexOf(this.getUiValue(widget)) !== -1
						&& _foldToggleUiCmds.indexOf(widget.getAttribute(_dataUiCommand)) !== -1) {
						widget = null;
					}
				}

			} else if (evtActionType.isDisableType) {
				_updateUiLockState(widgetName, true);
			}

			if (_uiValueMap && !widgetNode) {
				this._updateUiValueMap(eventAction, valueKey);
			}

			widgetIdx = 0;
			while (widget) {
				update = false;
				needVisibilityExecute = false;
				orgFontValue = null;

				hasSubGroupBoxClass = CommonFrameUtil.hasClass(widget, _subGroupBoxClass);
				hasSampleWrapClass = CommonFrameUtil.hasClass(widget, _sampleWrapClass);

				if (!evtActionType.isNormalType) {
					// disable, enable, hidden 처리
					isComboDropdown = UiUtil.isDropdown(widget) || UiUtil.isCombo(widget);
					if (hasSubGroupBoxClass || hasSampleWrapClass || isComboDropdown) {
						// subgroup 인 경우, 아래에서 command widget 찾음 (uiCommand widget 포함)
						queryStr = '[' + _dataCommand + '="' + cmdName + '"]';
						if (valueKey) {
							queryStr += '[' + _defineDataValueKeyAttr + '="' + valueKey + '"]';
						}
						queryStr += ', .' + cmdName + '[' + _dataUiCommand +']';

						subDataWidgets = widget.querySelectorAll(queryStr);
						// NodeList 를 Array 변환후 widgetArr 에 concat
						widgetArr = widgetArr.concat(CommonFrameUtil.getCollectionToArray(subDataWidgets));

						if (isComboDropdown) {
							if (!valueKey || UiUtil.getValueKey(widget) == valueKey) {
								// 현재 dropdown/combo 대상
								needVisibilityExecute = true;
							}

						} else if (hasSubGroupBoxClass) {
							checkSubgroupBoxArr = checkSubgroupBoxArr || [];
							if (checkSubgroupBoxArr.indexOf(widget) === -1) {
								// checkSubgroupBoxArr 에 추가 (추후에 subgroup 의 비활성화/활성화 여부 검사)
								checkSubgroupBoxArr[checkSubgroupBoxArr.length] = widget;
							}
						}

					} else {
						needVisibilityExecute = true;
					}

					if (needVisibilityExecute) {
						widgetValue = widget.getAttribute(UiDefine.DATA_VALUE);
						if (value === widgetValue || !value) {
							// widgetValue 가 없거나 같아야 함.

							if (evtActionType.isEnableType) {
								updated = this._setEnable(widget);

							} else if (evtActionType.isDisableType) {
								updated = this._setDisable(widget);

							} else if (evtActionType.isVisibleType) {
								this._setVisibleLineIfNeeded(widget);
								updated = this._setVisible(widget);
								this._setVisibleTitleMenuIfNeeded(widget);

								cmdItemIndex = UiFrameworkInfo.getCommandItemIndex(cmdName, widget);
								isUpdateSelectAll = UiFrameworkInfo.setVisibleSelectAllTarget(cmdName, cmdItemIndex, valueKey);
							} else if (evtActionType.isHiddenType) {
								this._setHideLineIfNeeded(widget);
								updated = this._setHidden(widget);
								this._setHideTitleMenuIfNeeded(widget);
								this.initFocusWidgetInfoIfDisabledHidden(target);

								cmdItemIndex = UiFrameworkInfo.getCommandItemIndex(cmdName, widget);
								isUpdateSelectAll = UiFrameworkInfo.setHiddenSelectAllTarget(cmdName, cmdItemIndex, valueKey);
							} else if (evtActionType.isVisibleItemType) {
								updated = this._setVisibleItem(widget);
							} else if (evtActionType.isHiddenItemType) {
								updated = this._setHiddenItem(widget);
							}

							// dialog 가 showing 중이면서,
							// dialog 의 컨텐츠가 숨김/보이기 처리시 높이 및 위치 정보를 갱신한다.
							if (updated && (evtActionType.isVisibleType || evtActionType.isHiddenType)) {
								this._needToUpdateDialogHeight(widget);
							}
						}
					}

				} else {
					isDontCareValue = (value === _dontCareValue);
					isComboDropdown = UiUtil.isDropdown(widget) || UiUtil.isCombo(widget);

					if (isComboDropdown || hasSubGroupBoxClass || hasSampleWrapClass) {
						boxEl = isComboDropdown ? widget.lastElementChild : widget;

						if (boxEl) {
							if (eventAction.uiCommand) {
								selector = '[' + _dataUiCommand + '="' + eventAction.uiCommand + '"]['
									+ _dataUiValue + '="' + cmdName + '"]';
							} else {
								selector = '[' + _dataCommand + '="' + cmdName + '"]';

								if (value !== _onStr) {
									// 폰트 value 는 default font name 으로 치환하여 on 여부를 확인한다.
									if (cmdName === _eventActionNames.FONT_NAME) {
										orgFontValue = value;
										value = this.getGlobalFontName(value, _defineValue.DEFAULT);

										/**
										 * 웹폰트는 CSS 에 지정된 폰트명을 사용하므로, default 값을 사용하면 안된다.
										 * 현재 웹폰트는 한국어만 지정되어 있으므로, global 폰트명으로 다시 셋팅해 준다.
										 */
										if (_webFontInfo && _webFontInfo.webFontRender.indexOf(value) !== -1) {
											value = this.getGlobalFontName(value, "ko");
										}
									}
									// color picker 의 hex code value 는 모두 대문자로 통일한다.
									if (CommonFrameUtil.hasClass(boxEl, UiDefine.DROPDOWN_COLOR_PICKER_WRAP_CLASS)
										&& UiUtil.checkValidationColorCode(value) === UiDefine.VALIDATION_CHECK_RESULT.SUCCESS) {
										value = value.toUpperCase();
									}

									if (hasSampleWrapClass && valueKey) {
										selector += '[' + _defineDataValueKeyAttr + '="' + valueKey + '"]';
									} else {
										selector += UiUtil.getAttrSelectorStr(_defineDataValueAttr, value);
									}
								}

								unit = FrameworkUtil.getUnitValue(eventAction.unit, valueKey);

								if (CommonFrameUtil.isString(unit)) {
									// 단위조건 있는 경우
									selector += '[' + _defineDataUnitAttr + '="' + unit + '"]'
								}

								if (UiUtil.getCustomLayoutDropdownName(widget)) {
									// custom 인 경우, input 도 포함
									selector += ', .' + UiDefine.INPUT_BOX_WRAP_CLASS
										+ '[' + _dataCommand + '="' + cmdName + '"]';
								}
							}

							subDataWidgets = CommonFrameUtil.getCollectionToArray(boxEl.querySelectorAll(selector));
							subDataWidget = subDataWidgets[0];

							if ((cmdName === _eventActionNames.FONT_NAME || valueKey === _eventActionNames.FONT_NAME)
								&& !isDontCareValue
								&& (!subDataWidget || CommonFrameUtil.hasClass(subDataWidget, UiDefine.NO_SUCH_FONT_DATA_CLASS))
								&& FontManager.getInvalidLicenseFontList().indexOf(value) === -1) {
								/**
								 * font name 에 한해서, 해당 font 없는 경우 'no_such_font'(해당글꼴없음) data 활용.
								 * description 은 default font 값이 아닌 입력값(orgFontValue)으로 출력.
								 */
								orgFontValue = orgFontValue || value;

								if (!subDataWidget) {
									subDataWidget = boxEl.querySelector('.' + UiDefine.NO_SUCH_FONT_DATA_CLASS);

									if (subDataWidget) {
										subDataWidget.setAttribute(_defineDataValueAttr, value);

										if (!updateDescVal) {
											// 모든 no_such_font 의 description 갱신 (action 당 1회만 수행)
											updateDescVal = {};
											updateDescVal[UiDefine.NO_SUCH_FONT_DATA_CLASS] = orgFontValue;
											this._updateDescription(updateDescVal);
										}
										subDataWidget.style.fontFamily = value;
										subDataWidgets = [subDataWidget];
									}
								}

								this._setVisible(subDataWidget);
							}

							widgetArr = widgetArr.concat(subDataWidgets);

						} else {
							subDataWidget = null;
						}

						if (isComboDropdown) {
							this._updateDropdown(widget, eventAction, valueKey, subDataWidget, evtTargetWidget);

							// dropdown 또는 combo 내에서 선택된 subDataWidget 에 match 가 있으면 업데이트 해준다.
							if (subDataWidget) {
								this._updateDropdownMatch(widget, subDataWidget);
							}

							// dropdown 또는 combo 내에서 동작할 match 를 지정한 경우 업데이트 해준다.
							match = FrameworkUtil.getMatchValue(eventAction.match, valueKey);

							if (match && UiFrameworkInfo.getDropdownMatch(widgetName) !== match) {
								this._updateEventActionMatch(widget, match);
								UiFrameworkInfo.setDropdownMatch(widgetName, match);
							}
						}

					} else {
						if (UiUtil.isTextInputWidget(widget)) {
							inputEl = UiUtil.getInputElementByWidget(widget);

							if (isDontCareValue) {
								curValue = "";
								this._setButtonDontCare(widget);
							} else {
								curValue = value;
								this._setButtonDontCareOff(widget);
							}

							update = FrameworkUtil.setInputText(inputEl, curValue, eventAction.unit, valueKey, widgetName);

							// spectrum color input 의 경우 origin color value 값을 지정한다.
							if (CommonFrameUtil.hasClass(widget, UiDefine.PREVIEW_COLOR_TEXT_CLASS)) {
								widget.setAttribute(UiDefine.DATA_ORIGIN_COLOR_VALUE, curValue);
							}
						} else if (UiUtil.isLocalFileWidget(widget)) {
							inputEl = UiUtil.getInputElementByWidget(widget);
							if (inputEl && !value) {
								if (inputEl.value) {
									inputEl.value = "";
								}
								update = true;
							}

						} else if (UiUtil.isTextareaWidget(widget)) {
							update = FrameworkUtil.setTextareaText(widget, value);
						} else {
							widgetValue = widget.getAttribute(_defineDataValueAttr);
							if ((value === widgetValue || !widgetValue || isDontCareValue)
								&& UiUtil.getValueKey(widget) == valueKey) {
								// widgetValue 가 없거나 같고, valueKey 값이 둘 다 없거나 같아야 함.

								isRadio = UiUtil.isRadioWidget(widget);
								isCheckbox = UiUtil.isCheckboxWidget(widget);

								if (isRadio || isCheckbox) {
									inputEl = UiUtil.getInputElementByWidget(widget);

									if (inputEl) {
										if (isRadio) {
											inputEl.checked = !isDontCareValue;

											// 연결된 match 도 업데이트 해준다.
											this._updateRadioCheckboxMatch(widget, true, evtTargetWidget);

										} else {
											isChecked = (value == _defineValue.TRUE);
											inputEl.checked = isChecked;

											if (isDontCareValue) {
												this._setButtonDontCare(widget);
											} else {
												this._setButtonDontCareOff(widget);

												// 연결된 match 도 업데이트 해준다.
												this._updateRadioCheckboxMatch(widget, true, evtTargetWidget);
											}

											cmdItemIndex = UiFrameworkInfo.getCommandItemIndex(cmdName, widget);
											isUpdateSelectAll = UiFrameworkInfo.setSelectState(
												cmdName, cmdItemIndex, valueKey, isChecked);
										}
									}

								} else {
									if (!UiUtil.isControlButton(widget)) {
										// 연결된 match 업데이트
										if (UiUtil.isTabButton(widget)) {
											this._updateTabMatch(widget);
										} else {
											widgetParent = widget.parentNode;
											if (UiUtil.isListBox(widgetParent)) {
												this._updateDropdownMatch(widgetParent, widget, true);
											}
										}

										if (isDontCareValue) {
											if (!widget.hasAttribute(UiDefine.DATA_SWITCH_BUTTON)) {
												this._setButtonDontCare(widget);
											}
										} else {
											this._setButtonOn(widget);
											checkMoveEl = widget;
										}

										update = true;
									}
								}
							}
						}

						if (update) {
							this._pushToggleCommandButton(widgetName, widget);
						}
					}
				}

				if (isUpdateSelectAll) {
					// update
					this.updateSelectAllInfo(cmdName, cmdItemIndex);
				}

				widget = widgetArr[++widgetIdx];
			}

			if (evtActionType.isNormalType && checkMoveEl && UiUtil.isSampleItem(checkMoveEl)) {
				// sampleItem move 버튼 활성/비활성 갱신
				this._updateSampleItemMoveButton(checkMoveEl);
			}

			this._checkUpdateSubgroup(checkSubgroupBoxArr, type);

			return widgetArr;
		},

		_executeEventAction: function(eventAction) {
			var widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP),
				value = eventAction.value,
				target = eventAction.target,
				type = eventAction.type,
				isObjValue = CommonFrameUtil.isObject(value),
				focus = eventAction.focus,
				eventActionName = eventAction.name,
				updated = false,
				valueKeyArrMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.COMMAND_TO_VALUE_KEY_ARR_MAP),
				nameArr, widgetArr, widget, focusWidget, valueKeys, valueKey, len, i, j, focusEl, isTextInput,
				widgetNameToValueKeyMap, valueKeyLen, curWidgetArr, isArrayActionName, valueKeyArr, focusWidgetInfo;

			if (widgetMap) {
				if (type === _eventActionType.UI) {
					updated = this._executeUiCommandEventAction(eventAction);
					if (target && !updated && !eventAction.holdLayerMenu) {
						if (target.getAttribute(UiDefine.DATA_NON_EXEC) === _defineValue.TRUE
							&& CommonFrameUtil.findChildNode(UiFrameworkInfo.getLayerMenu(), "first", target)) {
							this.hideTooltip();
						} else {
							this.closeLayerMenu(target);
						}
					}

					if (CommonFrameUtil.hasClass(target, _spinnerUpperClass)
						|| CommonFrameUtil.hasClass(target, _spinnerLowerClass)) {
						target = target.parentNode.parentNode;
					}
				} else {
					if (target) {
						this.removeFocusWidgetInfo();
					}

					target = null;
				}

				if (!updated) {
					if (isObjValue) {
						if (_lazyConvertInfo && !_lazyConvertInfo.isConvertEnd) {
							// lazyConverting 중인 상황에서는 valueKey 제한하지 않음
							valueKeyArr = Object.keys(value);
							valueKeys = valueKeyArr;
						} else {
							// widget 이 valueKey 로 나눠지며, 해당 widget 을 구체적으로 지정
							valueKeyArr = valueKeyArrMap[eventActionName];
							valueKeys = valueKeyArr ? Object.keys(value) : [];
						}

						len = valueKeys.length;

						for (i = 0; i < len; i++) {
							valueKey = valueKeys[i];

							if (valueKeyArr.indexOf(valueKey) !== -1) {
								widgetArr = this._updateWidgetByEventAction(widgetMap, eventAction, valueKey, target);
								widget = widgetArr ? widgetArr[0] : null;

								if (widget) {
									updated = true;
									if (!focusWidget && focus === valueKey) {
										focusWidget = widget;
									}
								}
							}
						}

					} else {
						isArrayActionName = CommonFrameUtil.isArray(eventActionName);
						widgetNameToValueKeyMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_NAME_TO_VALUE_KEY_MAP);

						if (eventActionName === _eventActionNames.ALL_COMMANDS_NAME) { // 전체 commands
							nameArr = _getAllWidgetNameArr();
							value = "";
						} else if (isArrayActionName) {
							nameArr = eventActionName;
							value = "";
						} else { // 단일 name
							nameArr = [eventActionName];
						}

						widgetArr = [];
						len = nameArr.length;

						for (i = 0; i < len; i++) {
							eventActionName = nameArr[i];
							valueKeyArr = valueKeyArrMap[eventActionName];

							if (widgetNameToValueKeyMap[eventActionName]) {
								// valueKey 포함된 name - 분리
								valueKey = widgetNameToValueKeyMap[eventActionName];
								eventActionName = eventActionName.slice(0, (valueKey.length + 1) * -1);
								valueKeyArr = [valueKey];
							} else if (!value && valueKeyArr && UiDefine.EVENT_ACTION_SPECIAL_TYPES.indexOf(type) !== -1) {
								// 모든 valueKey 대상 (disable, hidden 등 normal type 아닌 경우에 한함)
								value = "";
							} else {
								valueKeyArr = [null];
							}

							eventAction.name = eventActionName;
							eventAction.value = value;
							valueKeyLen = valueKeyArr.length;

							for (j = 0; j < valueKeyLen; j++) {
								curWidgetArr = this._updateWidgetByEventAction(
									widgetMap, eventAction, valueKeyArr[j], target);

								widgetArr = widgetArr.concat(curWidgetArr);
							}
						}

						widget = (widgetArr.length > 0) ? widgetArr[widgetArr.length - 1] : null;

						if (widget) {
							updated = true;
							focusWidget = (focus === _onStr) ? widget : null;
						}
					}

					if (!widget && value === _defineValue.OFF) {
						// "off" 는 이미 off 상태인 경우 대상 widget 을 찾지 못할 수 있음. 수행한 것으로 처리.
						updated = true;
					}

					if (focusWidget && (UiUtil.isInputWrapWidget(focusWidget) || UiUtil.isResultButton(focusWidget))) {
						// 현재 inputWrap Widget 과 resultButton 만 focus 허용
						if (UiUtil.isInputWrapWidget(focusWidget)) {
							focusEl = UiUtil.getInputElementByWidget(focusWidget);
							isTextInput = UiUtil.isTextInputWidget(focusWidget);
						} else {
							focusEl = focusWidget;
						}

						if (isTextInput) {
							if (UiFrameworkInfo.getModuleName() === UiDefine.MODULE_NAME_WEBWORD) {
								// webword (iframe input 사용 module) 은 직접 focus() 하지 않고 custom event 사용
								FrameworkUtil.fireCustomEvent({
									kind: UiDefine.CUSTOM_EVENT_KIND.WIDGET,
									target: focusEl,
									type: UiDefine.CUSTOM_EVENT_TYPE.UI_INPUT_FOCUS,
									name: UiDefine.CUSTOM_EVENT_TYPE.UI_INPUT_FOCUS
								});

							} else {
								focusEl.focus();
							}

						} else {
							this.setWidgetFocus(focusEl);
						}
					}
				}
			}

			if (!updated) {
				console.log('[Info] Update Ui : "' + eventAction.name + '" is not found.');
			}

			return updated;
		},

		/**
		 * ui command 실행
		 * @param {Object} eventAction
		 * @returns {Object}
		 */
		_executeUiCommandEventAction: function(eventAction) {
			var orgTarget = eventAction.target,
				target = orgTarget,
				uiCommand = eventAction.name,
				value = eventAction.value,
				result = false,
				closeLayer = false,
				customEventData = {},
				viewName, uiValue, viewNodeArr, uiState, mbUId, onBtnEl;

			switch(uiCommand) {
				case _uiCommandNames.DROPDOWN:
					this._updateToolBarScrollIfNeeded(target);
					this._toggleDropdown(target);
					result = true;
					break;

				case _uiCommandNames.SHOW:
					viewName = this.getUiValue(target) || value;
					target = this._getViewNode(viewName);
					this._showView(target, null, value, orgTarget);
					this._setSaveUiButtonState(viewName, _defineValue.TOGGLE_ON);
					result = true;
					closeLayer = true;
					break;

				case _uiCommandNames.HIDE:
					viewName = this.getUiValue(target) || value;
					target = this._getViewNode(viewName);
					this._hideView(target);
					this._setSaveUiButtonState(viewName, _defineValue.TOGGLE_OFF);
					result = true;
					closeLayer = true;
					break;

				case _uiCommandNames.TOGGLE:
					viewName = this.getUiValue(target) || value;
					target = this._getViewNode(viewName);
					result = this._toggleView(target, value, viewName);
					this._setSaveUiButtonState(viewName, result ? _defineValue.TOGGLE_OFF : _defineValue.TOGGLE_ON);
					result = true;
					closeLayer = true;
					break;

				case _uiCommandNames.FOLD:
					viewName = this.getUiValue(target) || value;
					target = this._getViewNode(viewName);
					result = this._foldView(target, viewName);
					this._setSaveUiButtonState(viewName, result ? _uiCommandNames.FOLD : _onStr);
					result = true;

					if (orgTarget) {
						this.hideTooltip();
					}
					break;

				case _uiCommandNames.ITEM_SHOW:
					this._showCurrentView(value);
					result = true;
					break;

				case _uiCommandNames.TITLE_BAR:
					this._updateToolBarScrollIfNeeded(target);
					this._toggleTitleBarMenu(target);
					result = true;
					break;

				case _uiCommandNames.CLOSE_MENU:
					if (value === _defineValue.ALL) {
						this.closeAllMenu();
					} else {
						this.closeLayerMenu(target);
					}
					result = true;
					break;

				case _uiCommandNames.TAB:
					result = this._showTab(target);
					break;

				case _uiCommandNames.DESCRIPTION:
					result = this._updateDescription(value);
					break;

				case _uiCommandNames.MENU_H_SCROLL:
					uiValue = this.getUiValue(target);
					result = this._updateMenuScroll(target, uiValue);
					break;

				case _uiCommandNames.TOGGLE_UI_OPTION_VIEW:
					this._updateToolBarScrollIfNeeded(target);

					if (_isHideUiOptionView) {
						viewNodeArr = this._showViewByUiOption();
						customEventData.execValue = UiDefine.UI_COMMAND_NAME.SHOW;

					} else {
						viewNodeArr = this._hideViewByUiOption();
						customEventData.execValue = UiDefine.UI_COMMAND_NAME.HIDE;
					}
					customEventData.type = UiDefine.CUSTOM_EVENT_TYPE.UI_RESIZE;
					customEventData.name = uiCommand;
					customEventData.execTarget = viewNodeArr;
					break;
				case _uiCommandNames.DONT_LOOK_AGAIN:
					mbUId = UiFrameworkInfo.getMessageBarUId();

					if (mbUId) {
						viewName = uiCommand;
						uiState = FrameworkUtil.getUiState(viewName) || [];

						if (uiState && uiState.indexOf(mbUId) === -1) {
							uiState.push(mbUId);
							FrameworkUtil.saveUiState(viewName, uiState);
							UiFrameworkInfo.setMessageBarUId("");
							this.hideMsgBar();
						}
					}

					break;
				case _uiCommandNames.COLOR_THEME:
					this.setColorPickerOfTheme(value, target);

					onBtnEl = target.parentNode.querySelector("." + _onStr);
					if (onBtnEl !== target) {
						if (onBtnEl) {
							this._setButtonOff(onBtnEl);
						}
						this._setButtonOn(target);
					}

					break;
			}

			if (closeLayer && orgTarget) {
				this.closeLayerMenu(orgTarget);
			}

			// custom event 발생이 필요한 경우 함수를 호출한다.
			if (!CommonFrameUtil.isEmptyObject(customEventData)) {
				// TODO: 추후 API 구분이 필요할 시 처리 필요.
				customEventData.kind = UiDefine.CUSTOM_EVENT_KIND.WIDGET;
				customEventData.target = orgTarget;
				if (!customEventData.execTarget) {
					customEventData.execTarget = target;
				}

				FrameworkUtil.fireCustomEvent(customEventData);
			}

			return result;
		},

		/**
		 * Message bar 의 DOM 을 초기에 cache 하는 함수
		 * @param {Element} msgBarEl			- message bar element
		 * @private
		 *
		 * @returns {Object}
		 */
		_initMsgBar: function (msgBarEl) {
			if (!msgBarEl) {
				return {};
			}

			var toolScreenEl = this.getToolElement(UiDefine.TOOL_SCREEN);

			return {
				msgBarEl: msgBarEl,
				msgArea: msgBarEl.querySelector("." + UiDefine.MSG_AREA_CLASS) || null,
				msgProgressArea: msgBarEl.querySelector("." + UiDefine.MSG_PROGRESS_CLASS) || null,
				refreshBtn: msgBarEl.querySelector("." + UiDefine.MSG_REFRESH_BUTTON_CLASS) || null,
				closeBtn: msgBarEl.querySelector("." + UiDefine.MSG_CLOSE_BUTTON_CLASS) || null,
				dlaBoxEl: msgBarEl.querySelector("." + UiDefine.MSG_DONT_LOOK_AGAIN_BOX_CLASS) || null,
				checkBoxEl: msgBarEl.querySelector("." + UiDefine.MSG_DONT_LOOK_AGAIN_BTN_CLASS + " input") || null,
				screenEl: toolScreenEl && toolScreenEl.firstElementChild || null
			};
		},

		/**
		 * Message bar 의 내용을 초기화하는 함수
		 *
		 * @returns {void}
		 */
		_resetMsgBar: function () {
			var msgBarEl, msgProgressArea, msgArea, refreshBtn, closeBtn, screenEl, dlaBoxEl, checkBoxEl;

			if (!_msgBarElInfo.msgBarEl) {
				return;
			}

			// message 영역을 빈 값으로 초기화 시켜준다.
			msgArea = _msgBarElInfo.msgArea;

			if (msgArea) {
				msgArea.textContent = "";
			}

			msgBarEl = _msgBarElInfo.msgBarEl;

			// error type 의 class 가 있다면 제거하여 초기화 시켜준다.
			if (CommonFrameUtil.hasClass(msgBarEl, UiDefine.MSG_ERROR_CLASS)) {
				CommonFrameUtil.removeClass(msgBarEl, UiDefine.MSG_ERROR_CLASS);
			}

			// screen_msg class 가 있다면 제거하여 초기화 시켜준다.
			if (CommonFrameUtil.hasClass(msgBarEl, UiDefine.MSG_SCREEN_CLASS)) {
				CommonFrameUtil.removeClass(msgBarEl, UiDefine.MSG_SCREEN_CLASS);
			}

			// progress 영역이 hidden 이 아니면 hide 시켜준다.
			msgProgressArea = _msgBarElInfo.msgProgressArea;

			if (msgProgressArea && !UiUtil.isHidden(msgProgressArea)) {
				this._setHidden(msgProgressArea);
			}

			// refresh 버튼이 hidden 이 아니면 hide 시켜준다.
			refreshBtn = _msgBarElInfo.refreshBtn;

			if (refreshBtn && !UiUtil.isHidden(refreshBtn)) {
				this._setHidden(refreshBtn);
			}

			// close 버튼이 hidden 이 아니면 hide 시켜준다.
			closeBtn = _msgBarElInfo.closeBtn;

			if (closeBtn && !UiUtil.isHidden(closeBtn)) {
				this._setHidden(closeBtn);
			}

			// tool screen 이 hidden 이 아니면 hide 시켜준다.
			screenEl = _msgBarElInfo.screenEl;

			if (screenEl && !UiUtil.isHidden(screenEl)) {
				this._setHidden(screenEl);
			}

			// 다시보지않기 영역이 hidden 이 아니면 hide 시켜준다.
			dlaBoxEl = _msgBarElInfo.dlaBoxEl;

			if (dlaBoxEl && !this.isHidden(dlaBoxEl)) {
				this._setHidden(dlaBoxEl);
			}

			// 다시보지않기 버튼이 있다면, check 를 해제시켜준다.
			checkBoxEl = _msgBarElInfo.checkBoxEl;

			if (checkBoxEl) {
				checkBoxEl.checked = false;
			}

			// 다시보지않기 관련 unique id 를 초기화시켜준다.
			UiFrameworkInfo.setMessageBarUId("");
		},

		_setViewMode : function() {
			var appMode = window.hcwoAppMode,
				isViewer = false;

			if (appMode) {
				if (appMode.indexOf("_viewer") !== -1) {
					isViewer = true;
				}

				delete window.hcwoAppMode;
			}

			if (_browserDevice.isMobile) {
				EggTart.setMobileViewMode();

				if (!isViewer) {
					// Mobile 에서 접근시 viewMode 로 강제 전환 시킨다. (Mobile Editing 지원 전까지 임시 스펙)
					isViewer = true;
				}
			}

			_isViewMode = isViewer;
		},

		/**
		 * callback map 을 초기화 하는 함수
		 * - 현재는 dialog 에 대해서만 취급한다.
		 * - 기본적으로 아무 동작도 안하는 noop 을 기본등록 한다.
		 * @private
		 */
		_initUiCallbackMap: function () {
			var noop = function (){};

			// 현재는 dialog 에 대해서만 제공하므로 dialog 만 초기화.
			// 추후 callback 들이 더 추가된다면, key 들을 더 추가해야 함.
			_uiCallbackMap = {
				"dialog" : noop
			};
		},

		/**
		 * collaboration 상황에서 유저의 숫자를 세팅하는 함수
		 * @param {Array} elList
		 * @param {Number} count
		 * @private
		 */
		_setTextToUserCount: function (elList, count) {
			if (!CommonFrameUtil.isArray(elList)) {
				return;
			}

			var len = elList.length,
				elFragmentInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.EL_FRAGMENT_INFO),
				i, targetEl, containerNode, key, desc, contents;

			if (!_cachedDescToCollaboView) {
				_cachedDescToCollaboView = elFragmentInfo.descToCollaboView;

				for (key in _cachedDescToCollaboView) {
					if (key != null) {
						_cachedDescToCollaboView[key] = _cachedDescToCollaboView[key].textContent;
					}
				}
			}

			if (CommonFrameUtil.isEmptyObject(_cachedDescToCollaboView)) {
				return;
			}

			for (i = 0; i < len; ++i) {
				targetEl = elList[i].firstElementChild;
				containerNode = UiUtil.findContainerNodeToParent(targetEl);
				desc = _cachedDescToCollaboView[containerNode && containerNode.id];

				if (desc) {
					contents = CommonFrameUtil.substitute(desc, {"users_count" : count});

					if (UiUtil.isDropdown(targetEl)) {
						this._updateDropdown(targetEl, {
							name: UiDefine.COLLABO_USERS_LIST,
							value: contents
						});
					} else {
						targetEl = targetEl.firstElementChild;

						if (targetEl) {
							targetEl.textContent = contents;
						}
					}
				}
			}
		},

		/**
		 * Delete 할 sample node 를 찾는 함수
		 * @param {Element} parentNode
		 * @param {String=} dataValue
		 * @param {String=} dataValueKey
		 * @returns {Element}
		 * @private
		 */
		_findSampleItemNode: function (parentNode, dataValue, dataValueKey) {
			var selector = dataValue ? UiUtil.getAttrSelectorStr(_defineDataValueAttr, dataValue) : "",
				targetNode, curParentNode;

			if (dataValueKey) {
				selector += "[" + _defineDataValueKeyAttr + "='" + dataValueKey + "']";
			}

			if (selector) {
				targetNode = parentNode.querySelector(selector);
			}

			if (targetNode != null) {
				curParentNode = targetNode.parentNode;

				while (curParentNode != null && !UiUtil.isSampleWrap(curParentNode)) {
					targetNode = curParentNode;
					curParentNode = targetNode.parentNode;
				}
			}

			return targetNode;
		},

		/**
		 * dialog 의 현재 높이정보를 저장하는 함수
		 * @param {Boolean=} forcedMod				- 높이값 갱신 여부
		 * @private
		 */
		_saveDialogHeight: function (forcedMod) {
			var dialogLayer = UiFrameworkInfo.getDialogShowing().viewNode,
				height, hasDlgVScrollClass;

			if (dialogLayer) {
				height = CommonFrameUtil.getOffsetHeight(dialogLayer);

				/*
				 * forcedMod 이거나 아직 초기화한 dialogLayerHeight 가 없는 경우,
				 * 또는 VScroll 없는 상태로 현재 높이와 다를 경우에만 갱신한다.
				 */
				if (forcedMod || !_dialogLayerHeight) {
					_dialogLayerHeight = height;
				} else if (_dialogLayerHeight !== height) {
					hasDlgVScrollClass = CommonFrameUtil.hasClass(
						FrameworkUtil.getVScrollElement(dialogLayer), _dialogVScrollClass);

					if (!hasDlgVScrollClass) {
						_dialogLayerHeight = height;
					}
				}
			}
		},

		_initializeFontList: function(elFragmentInfo, fontDetectMode, skinName) {
			var fontList, fontElList;

			if (elFragmentInfo && elFragmentInfo.sampleItemMap) {
				fontList = FontManager.getFontList();

				if (!fontList) {
					FontManager.initialize(_langDefine.LangCode, fontDetectMode, skinName, _fontGroupInfo);
					fontList = FontManager.getFontList();
				}
				// 웹폰트 정보를 전역변수에 할당한다. (현재 한국어 웹폰트만 있으므로, ko 만 할당)
				_webFontInfo = FontManager.getWebFontInfoByLocale("ko");

				fontElList = elFragmentInfo.sampleItemMap[_eventActionNames.FONT_NAME];

				if (fontElList) {
					_fontElListLen = fontElList.length;
					_fontMap = FrameworkUtil.setFontListEl(fontList, fontElList);
				}
			}
		},

		/**
		 * dialog 가 높이 갱신이 필요하면 처리하는 함수
		 * @param {Element=} checkTargetInDialog	- 동작이 발생된 위치가 Dialog container 내부인지 확인하는 DOM.
		 * 											  미 지정시 확인 없이 갱신을 진행하므로, 이 함수를 호출하는 곳에서
		 * 											  다이얼로그인지 확인하지 않았으면 대상 노드를 보내야 한다.
		 * @private
		 */
		_needToUpdateDialogHeight: function (checkTargetInDialog) {
			var dialogView = UiFrameworkInfo.getDialogShowing().viewNode,
				adjustLeft = true;

			if (!dialogView || (checkTargetInDialog && !UiUtil.isDialogContainer(checkTargetInDialog))) {
				// 현재 dialog 열려있지 않거나, 동작 발생한 위치가 dialog 내부가 아닌 경우
				return;
			}

			// VScroll 제거 후 Dialog 높이정보 갱신
			FrameworkUtil.adjustDialogVScroll(dialogView, false);
			this._saveDialogHeight(true);

			if (FrameworkUtil.isAutoMoveStateDialog(dialogView)) {
				/**
				 * 사용자가 움직이지 않은 Dialog 는 중앙을 유지할 것이기 때문에 VScroll 처리만 수행
				 * 사용자가 움직인 Dialog 는 top, left 모두 예외처리 수행
				 * ※ 이동량 0 지정시 현재 위치에서 예외처리 (window 벗어난 경우 조정)만 수행함.
				 */
				adjustLeft = false;
			}

			this.adjustDialogPos(adjustLeft, true);
		},

		/**
		 * 네트워크 연결상태에서만 활성화 되어야 하는 메뉴 활성화
		 * @private
		 */
		_setEnableNetworkMenus: function () {
			this.updateUi(
				{cmd:_updateCmd, type:_eventActionType.ENABLE, name:UiDefine.NEED_NETWORK_MENU_LIST, value:""});
			this._setEnableEditDesktop();
		},

		/**
		 * 네트워크 연결상태에서만 활성화 되어야 하는 메뉴 비활성화
		 * @private
		 */
		_setDisableNetworkMenus: function () {
			this.updateUi(
				{cmd:_updateCmd, type:_eventActionType.DISABLE, name:UiDefine.NEED_NETWORK_MENU_LIST, value:""});
			this._setDisableEditDesktop();
		},

		/**
		 * [데스크탑 편집] 버튼을 enable 하는 함수
		 * @param {Array=} widgetList				- [데스크탑 편집] 위젯 배열 리스트
		 * @private
		 *
		 * @return {void}
		 */
		_setEnableEditDesktop: function (widgetList) {
			var widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP),
				editDesktopWidget = widgetList || (widgetMap ? widgetMap[_eventActionNames.E_DESKTOP_CONFIRM] : null),
				widget, len, i;

			// 항상 노출되는 "데스크탑에서 편집" 버튼이 disabled 상태라면, enable 시켜준다.
			if (editDesktopWidget) {
				len = editDesktopWidget.length;

				for (i = 0; i < len; i++) {
					widget = editDesktopWidget[i];

					if (widget && UiUtil.isDisabled(widget)) {
						this._setEnable(widget);
					}
				}
			}
		},

		/**
		 * [데스크탑 편집] 버튼을 disable 하는 함수
		 * @param {Array=} widgetList				- [데스크탑 편집] 위젯 배열 리스트
		 * @private
		 *
		 * @return {void}
		 */
		_setDisableEditDesktop: function (widgetList) {
			var widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP),
				editDesktopWidget = widgetList || (widgetMap ? widgetMap[_eventActionNames.E_DESKTOP_CONFIRM] : null),
				widget, len, i;

			// 항상 노출되는 "데스크탑에서 편집" 버튼이 enabled 상태라면, disable 시켜준다.
			if (editDesktopWidget) {
				len = editDesktopWidget.length;

				for (i = 0; i < len; i++) {
					widget = editDesktopWidget[i];

					if (widget && UiUtil.isEnabled(widget)) {
						this._setDisable(widget);
					}
				}
			}
		},

		/**
		 * view node 의 show/hide class 를 세팅 하는 함수
		 * @param {Element} viewNode			- show/hide 대상 view
		 * @param {Element} containerNode		- container node
		 * @param {String} viewType				- "show", "hide"
		 *
		 * @returns {Boolean}
		 * @private
		 */
		_setShowHideClassOfViewNode: function (viewNode, containerNode, viewType) {
			if (!(viewNode && containerNode)) {
				return false;
			}

			var parentNode = viewNode.parentNode,
				isNoneNameViewOfContextMenu = (containerNode.id === _contextMenuId && parentNode !== containerNode
					&& CommonFrameUtil.hasClass(parentNode, UiDefine.NORMAL_PANEL_CLASS)),
				result = false,
				isAllHidden, childNodes, length, i;

			if (viewType === "show") {
				if (CommonFrameUtil.hasClass(viewNode, _hideViewClassName)) {
					CommonFrameUtil.removeClass(viewNode, _hideViewClassName);
					result = true;
				}

				if (isNoneNameViewOfContextMenu && UiUtil.isHidden(parentNode)) {
					CommonFrameUtil.removeClass(parentNode, _hideViewClassName);
				}
			} else {
				if (!CommonFrameUtil.hasClass(viewNode, _hideViewClassName)) {
					CommonFrameUtil.addClass(viewNode, _hideViewClassName);
					result = true;
				}

				if (isNoneNameViewOfContextMenu) {
					childNodes = parentNode.childNodes;
					length = childNodes.length;
					isAllHidden = true;

					for (i = 0; i < length; i++) {
						if (!UiUtil.isHidden(childNodes[i])) {
							isAllHidden = false;
							break;
						}
					}

					if (isAllHidden) {
						CommonFrameUtil.addClass(parentNode, _hideViewClassName);
					}
				}
			}

			if (viewType === "show") {
				this._setVisibleLineIfNeeded(viewNode);
			} else {
				this._setHideLineIfNeeded(viewNode);
			}

			return result;
		},

		/**
		 * attribute 값과 name 을 치환하거나 setting 하는 함수.
		 * @param {Element} el						- 대상 dom 을 포함한 wrap element
		 * @param {String|Object} replaceInfo		- String 인 경우 "value"
		 * 											  Object 인 경우 {orgAttrVal: "replaceVal", ...}
		 * @param {String} attributeName			- 대상 attribute name
		 * @param {String=} replaceAttrName			- attribute name 을 대체할 경우 지정 (기존 속성 삭제)
		 * @param {Boolean=} containsEl				- el 도 attribute 치환 대상으로 포함할건지 (default: false)
		 * @returns {Array} 실제 반영된 replaceVal Array
		 */
		_replaceAttribute: function (el, replaceInfo, attributeName, replaceAttrName, containsEl) {
			var result = [],
				elArr, elLen, elIdx, childEl, value, setAttrName;

			if (!(el && replaceInfo)) {
				return result;
			}

			elArr = CommonFrameUtil.getCollectionToArray(el.querySelectorAll("[" + attributeName + "]"));
			if (containsEl && el.hasAttribute(attributeName)) {
				elArr.push(el);
			}

			elLen = elArr.length;

			for (elIdx = 0; elIdx < elLen; elIdx++) {
				childEl = elArr[elIdx];
				value = CommonFrameUtil.isObject(replaceInfo) ?
					replaceInfo[childEl.getAttribute(attributeName)] : replaceInfo;

				if (value) {
					if (replaceAttrName && replaceAttrName !== attributeName) {
						// attribute name 대체되는 경우 기존 attribute 삭제
						childEl.removeAttribute(attributeName);
						setAttrName = replaceAttrName;
					} else {
						setAttrName = attributeName;
					}

					if (setAttrName === _defineDataValueAttr && UiUtil.isTextInputWidget(childEl)) {
						// input text 에 data-value 지정시에는 data-value 속성 대신 실제 값 지정
						this.setValueToInput(childEl, value);
					} else {
						childEl.setAttribute(setAttrName, value);
					}

					result.push(value);
				}
			}

			return result;
		},

		/**
		 * 단축키 정보를 통해서 단축키 Item 을 생성 및 내용을 채워서 반환하는 함수.
		 * @param {Node} descNode				- 단축키 아이템을 구성할 Template 노드 (TR)
		 * @param {String} descText				- 단축키 설명
		 * @param {Array} shortcutList			- 단축키 내용 (배열)
		 * @param {String=} subDescText			- 단축키 보조 설명
		 * @returns {Node|null}
		 * @private
		 */
		_makeShortcutInfoItem : function (descNode, descText, shortcutList, subDescText) {
			var langDefine = window.LangDefine,
				arrArrowStr = ["Right", "Left", "Up", "Down"],
				eleTempDesc = descNode ? descNode.cloneNode(true) : null,
				eleDescText, eleDescKey, i, len, item, j, arrShortcut, shortcutLen, shortcutText, shortcutClass,
				eleParentSpan, isInvalidShortcut, newOrNode;

			var insertSpanNode = function (descKeyNode, objCls, val) {
				var spanNode = CommonFrameUtil.createDomEl("span", objCls);

				UiUtil.insertTextToTarget(spanNode, val);
				descKeyNode.appendChild(spanNode);

				return spanNode;
			};

			len = (shortcutList && shortcutList.length) || 0;

			if (eleTempDesc && len) {
				eleDescText = eleTempDesc.firstElementChild;
				eleDescKey = eleDescText.nextElementSibling;

				if (descText) {
					insertSpanNode(eleDescText, null, langDefine[descText] || descText);
				}

				// 2 depth 에 의해 보조 설명이 있으면, 단축키 랜더링 부분의 맨 처음에 넣어준다.
				if (subDescText && len) {
					insertSpanNode(eleDescKey, null, "(" + (langDefine[subDescText] || subDescText) + ") ");
				}

				for (i = 0; i < len; i++) {
					item = shortcutList[i];
					isInvalidShortcut = !!(!_browserDevice.IsMac && item && /^command/i.test(item.trim()));

					if (item && !isInvalidShortcut) {
						eleParentSpan = CommonFrameUtil.createDomEl("span");
						arrShortcut = item.split("+");
						shortcutLen = arrShortcut.length;

						for (j = 0; j < shortcutLen; j++) {
							shortcutText = arrShortcut[j];
							shortcutClass = "";

							if (shortcutText) {
								shortcutText = shortcutText.trim();
								shortcutText = CommonFrameUtil.getUCFirst(shortcutText.replace(/^only_/, ""));

								/**
								 * 단축키의 특수키 정보는 정의된 정보로 대체하고, 나머지는 그대로 출력해 준다.
								 */
								if (shortcutText === "Command") {
									shortcutText = String.fromCharCode(8984);
								} else if (shortcutText === "Space") {
									shortcutText = langDefine.SpaceBar;
								} else if (shortcutText === "Movekeys") {
									shortcutText = langDefine.MoveKeys;
								} else if (arrArrowStr.indexOf(shortcutText) !== -1) {
									// 이미지로 대체되는 특수키 정보는 문자를 제거하고 CSS Class 를 등록한다.
									shortcutClass = "movekeys_" + shortcutText.toLowerCase();
									shortcutText = "";
								}

								/**
								 * 맥 장비일때는 ctrl, option (alt), shift 도 기호로 변환하여 출력한다.
								 */
								if (_browserDevice.IsMac) {
									if (shortcutText === "Ctrl") {
										shortcutText = String.fromCharCode(8963);
									} else if (shortcutText === "Alt") {
										shortcutText = String.fromCharCode(8997);
									} else if (shortcutText === "Shift") {
										shortcutText = String.fromCharCode(8679);
									}
								} else if (_langDefine.LangCode === "de") {
									// 맥이 아닌 독일어의 경우 Ctrl 대신 Strg 사용
									if (shortcutText === "Ctrl") {
										shortcutText = "Strg";
									}
								}

								insertSpanNode(eleParentSpan, {className: shortcutClass}, shortcutText);

								// 맥 장비가 아닐때만 + 기호를 만들어 준다.
								if (!_browserDevice.IsMac && j < shortcutLen - 1) {
									shortcutClass = "concat";
									insertSpanNode(eleParentSpan, {className: shortcutClass}, " + ");
								}
							}

							eleDescKey.appendChild(eleParentSpan);
						}

						// 단축키 정보가 한셋트 표현될 때마다 or 문자를 넣어준다.
						if (i < len - 1) {
							shortcutClass = "or";
							newOrNode = insertSpanNode(eleDescKey, {className: shortcutClass}, " " + langDefine.Or + " ");
						}
					}
				}

				// 단축키 출력 부분의 마지막 Node 가 Or 노드이면 제거해 준다.
				if (eleDescKey && eleDescKey.lastElementChild === newOrNode) {
					eleDescKey.removeChild(newOrNode);
				}
			}

			// 단축키 정보가 하나도 만들어지지 않았으면 null 값으로 반환한다.
			if (!(eleDescKey && eleDescKey.firstElementChild)) {
				eleTempDesc = null;
			}

			return eleTempDesc;
		},

		/**
		 * 단축키 Object 에서 weboffice.properties 비활성화 부분이 있으면 Object 에서 제거하여 반환하는 함수.
		 * @param {Object} objShortcut		- 단축키 정보 Object
		 * @returns {Object}
		 * @private
		 */
		_resetShortcutInfoByServerProps : function (objShortcut) {
			var uiServerProps = UiFrameworkInfo.getInfo(UiFrameworkInfo.UI_SERVER_PROPS_MAP);

			if (!(objShortcut && uiServerProps && !CommonFrameUtil.isEmptyObject(uiServerProps))) {
				return objShortcut;
			}

			if (objShortcut.File) {
				// weboffice.properties Print 활성화 여부 체크
				if (!uiServerProps[UiDefine.EVENT_ACTION_NAMES.D_PRINT] && objShortcut.File.Print) {
					delete objShortcut.File.Print;
				}

				// weboffice.properties Save 활성화 여부 체크
				if (!uiServerProps[UiDefine.EVENT_ACTION_NAMES.D_SAVE] && objShortcut.File.Save) {
					delete objShortcut.File.Save;
				}

				// weboffice.properties SaveAs 활성화 여부 체크
				if (!uiServerProps[UiDefine.EVENT_ACTION_NAMES.U_D_SAVE_AS] && objShortcut.File.DocumentSaveAs) {
					delete objShortcut.File.DocumentSaveAs;
				}
			}

			if (objShortcut.Others) {
				// weboffice.properties help (도움말) 활성화 여부 체크
				if (!uiServerProps[UiDefine.EVENT_ACTION_NAMES.E_HELP] && objShortcut.Others.Help) {
					delete objShortcut.Others.Help;
				}
			}

			return objShortcut;
		},

		/**
		 * public method (with context)
		 */

		/**
		 * UI Framework 에서 제공하는 Util 용 메소드 연결
		 * uiUtil 은 uiController 를 통해서만 접근하고 직접 접근은 하지 않는것을 원칙으로 한다.
		 */
		uiUtil : UiUtil,

		/**
		 * (Mobile View 처리 관련 lab project) EggTart 에서 제공하는 전용 메소드 연결
		 * EggTart 는 uiController 를 통해서만 접근하고 직접 접근은 하지 않는것을 원칙으로 한다.
		 */
		eggTart : EggTart,

		/**
		 * server.property 정보를 세팅하는 함수.
		 */
		setServerOptions: function () {
			if (window.serverProps) {
				_serverProperty = window.serverProps;

				delete window.serverProps;
			} else {
				_serverProperty = {};
			}
		},

		/**
		 * server.property 정보 가져오는 함수.
		 *
		 * @return {object}
		 */
		getServerOptions: function () {
			return _serverProperty;
		},

		/**
		 * 최종 결정된 skin 정보를 돌려주는 함수.
		 *
		 * @return {string}
		 */
		getSkinName: function() {
			return UiFrameworkInfo.getSkinName();
		},

		/**
		 * moduleName 에 해당하는 xml 을 dom 으로 converting
		 * @param {Function} fn		- callback function
		 * @param {Object=} context	- (미지정시 this 사용)
		 */
		bindCallbackAfterConverting: function(fn, context) {
			if (typeof fn !== "function") {
				return;
			}

			if (!context) {
				context = this;
			}

			_callbackFnConvertingAfter = $.proxy(fn, context);
		},

		/**
		 * font 를 그룹별로 나눠 "match" 동작 할 수 있도록 지정.
		 * convertXmlToDom() 호출 전에 지정 필요
		 * @param {Object} fontGroupInfo
		 * 					{
		 * 					  "matchValue1" : ["fontValue1", "fontValue2", ...],
		 * 					  ...
		 * 					}
		 */
		setFontGroupInfo: function (fontGroupInfo) {
			_fontGroupInfo = fontGroupInfo;
		},

		/**
		 * Lazy Converting mode 로 동작하도록 지정
		 * @param {Number=} autoConvertTimer	- auto lazy converting 시작 시간.(단위:ms)
		 * 										음수 지정시 auto converting 하지 않음.
		 * 										(loading 완료 후부터. 미지정시 -1)
		 * @param {Number=} intervalTime	- convert 1건 사이의 간격시간 (단위:ms) (미지정시 200)
		 */
		setLazyConvertMode: function(autoConvertTimer, intervalTime) {
			XmlConverter.setLazyConvertMode(true);

			_lazyConvertInfo = {
				autoConvertTimer: (CommonFrameUtil.isNumber(autoConvertTimer)) ? autoConvertTimer : -1,
				intervalTime: (CommonFrameUtil.isNumber(intervalTime) && intervalTime >= 0) ? intervalTime : 200,
				isConvertEnd: false
			};
		},

		/**
		 * 원하는 시점에 auto lazy converting 시작 하도록 하는 함수
		 * @param {Number=} delayTime		- 지연해서 시작할 시간 (단위:ms) (미지정시 0)
		 */
		startLazyConvertTimer: function(delayTime) {
			var lazyConvertXmlInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.LAZY_CONVERT_XML_INFO),
				dialogNames, widgetMap;

			if (!_lazyConvertInfo || !lazyConvertXmlInfo) {
				return;
			}

			dialogNames = Object.keys(lazyConvertXmlInfo);
			widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP);

			var __lazyConvert = (function() {
				var dialogName = dialogNames.shift(),
					time = 0,
					viewNode;

				if (dialogName && !_lazyConvertInfo.isConvertEnd) {
					if (!widgetMap[dialogName]) {
						viewNode = this._getViewNode(dialogName);
						time = viewNode ? _lazyConvertInfo.intervalTime : 0;
					}

					_lazyConvertTimer = window.setTimeout(__lazyConvert, time);

				} else {
					_lazyConvertTimer = null;
					_lazyConvertInfo.isConvertEnd = true;
				}
			}).bind(this);

			if (_lazyConvertTimer) {
				window.clearTimeout(_lazyConvertTimer);
			}

			_lazyConvertInfo.isConvertEnd = false;
			delayTime = (CommonFrameUtil.isNumber(delayTime) && delayTime >= 0) ? delayTime : 0;
			_lazyConvertTimer = window.setTimeout(__lazyConvert, delayTime);
		},

		/**
		 * 지정된 custom file name (moduleName + "Custom") 대신 사용할 file name 지정
		 * @param {String} customFileName	- ("" 지정시 기본값으로 변경)
		 */
		setCustomXmlFileName: function (customFileName) {
			_customXmlFileName = customFileName || "";
		},

		/**
		 * moduleName 에 해당하는 xml 을 dom 으로 converting
		 * @param {String} moduleName		- webword, webshow, webcell
		 * @param {Window=} contentWindow	- (미지정시 window 사용)
		 * @param {String=} baseDir		- commonFrame 을 갖는 directory 지정
		 * @param {String=} fontDetectMode	- font detect 모드 (UiDefine.FONT_DETECT_MODE 에 정의된 값)
		 * 									GLOBAL: 언어별 (일반, default)
		 * 									GLOBAL_EXTEND: 언어별 확장 (global 과 무관한 사항 추가)
		 * 									CHARACTER_SET: 언어와 관계없는 별도 분류
		 * @returns {Object} DomInfo		- {refTree, widgetMap}
		 */
		convertXmlToDom: function (moduleName, contentWindow, baseDir, fontDetectMode) {
			var skinName;

			this._setViewMode();
			this.setServerOptions();
			skinName = this._getSkinName();

			if (baseDir) {
				if (!CommonFrameUtil.isEndsWith(baseDir, "/")) {
					baseDir += "/";
				}
			} else {
				baseDir = "";
			}

			return this.convertXmlToDomByXmlList(
				moduleName, this.getXmlList(moduleName, contentWindow, baseDir, skinName),
				contentWindow, baseDir, skinName, fontDetectMode);
		},

		/**
		 * 특정 xml 을 dom 으로 converting
		 * @param {String} moduleName		- webword, webshow, webcell
		 * @param {Array} xmlList
		 * @param {Window=} contentWindow	- (미지정시 window 사용)
		 * @param {String=} baseDir		- commonFrame 을 갖는 directory 지정
		 * @param {String=} skinName		- (미지정시 구함)
		 * @param {String=} fontDetectMode	- font detect 모드 (UiDefine.FONT_DETECT_MODE 에 정의된 값)
		 * 									GLOBAL: 언어별 (일반, default)
		 * 									GLOBAL_EXTEND: 언어별 확장 (global 과 무관한 사항 추가)
		 * 									CHARACTER_SET: 언어와 관계없는 별도 분류
		 * @returns {Object} xmlList		- {refTree, widgetMap}
		 */
		convertXmlToDomByXmlList: function (moduleName, xmlList, contentWindow, baseDir, skinName, fontDetectMode) {
			var result, contentDoc, contentDocHead, elFragmentInfo, rootWindow, refTree,
				templateDirInfo, widgetMap, len, i, disableList, toastMsgWrap, msgBarEl, parentNode,
				collaboUserViewList, targetEl, nlsResource, modalFragment, dialogName;

			if (baseDir) {
				if (!CommonFrameUtil.isEndsWith(baseDir, "/")) {
					baseDir += "/";
				}
			} else {
				baseDir = "";
			}

			skinName = skinName || this._getSkinName();

			contentWindow = contentWindow || window;
			rootWindow = contentWindow.parent === window ? window : contentWindow.parent;

			contentDoc = contentWindow.document;
			contentDocHead = contentDoc.head;
			_langDefine = contentWindow.LangDefine || rootWindow.LangDefine;

			if (!_langDefine) {
				console.log("[Error] LangDefine is not found.");
				return null;
			}

			// convert 이후 정보 초기화 (전역변수 포함)
			_initGlobalVariable();
			UiFrameworkInfo.initialize();
			UiFrameworkInfo.setSkinName(skinName);
			UiFrameworkInfo.setModuleName(moduleName);
			UiFrameworkInfo.setContentWindow(contentWindow);
			UiFrameworkInfo.setLangDefine(_langDefine);
			UiFrameworkInfo.setInfo(UiFrameworkInfo.XML_LIST, xmlList);
			UiFrameworkInfo.setInfo(UiFrameworkInfo.BASE_DIR, baseDir);

			baseDir += "commonFrame/";
                  
			templateDirInfo = {
				baseDir: baseDir + "skins/" + skinName + "/html/",
				moduleName: moduleName
			};

			if (skinName === UiDefine.SKIN_TYPE_A && needExtendGeneralTypeA) {
				nlsResource = UiRequester.requestNls(baseDir + "js/nls/" + (_langDefine.LangCode === "en" ? "root" : _langDefine.LangCode) + "/", "generalTypeA");
				if (nlsResource) {
					$.extend(window.LangDefine, nlsResource);
				}

				needExtendGeneralTypeA = false;
			}

			if (_langDefine.LangCode === "de" && !_browserDevice.IsMac) {
				// Mac 이 아닌 독일어의 경우, Ctrl 대신 Strg 사용
				$.extend(window.LangDefine, ShortcutStrg);
			}

			if (_lazyConvertTimer) {
				window.clearTimeout(_lazyConvertTimer);
				_lazyConvertTimer = null;
			}

			elFragmentInfo = XmlConverter.convertXmlToDom(
				xmlList, templateDirInfo, _langDefine.LangCode, _serverProperty, _isViewMode);

			if (!elFragmentInfo) {
				console.log("[Error] Xml Converting Error.");
				return null;
			}

			disableList = elFragmentInfo.disableInfo.widgetList;
			if (disableList && disableList.length) {
				len = disableList.length;

				for (i = 0; i < len; ++i) {
					this._setDisable(disableList[i]);
				}

				this._checkUpdateSubgroup(elFragmentInfo.disableInfo.subgroupList, _eventActionType.DISABLE);
			}

			if (elFragmentInfo.sampleItemMap) {
				if (!_callbackFnConvertingAfter) {
					this._initializeFontList(elFragmentInfo, fontDetectMode, skinName);
				}

				// TODO: 현재 collaboration user 표시 부분이 각 모듈마다 다르다.
				// (워드: button, 셀/쇼: panel)
				// panel 에는 value 를 담는 개념이 없기 때문에, data-value 세팅이 될 수 없다.
				// 즉, 협업 유저를 지우기 위한 deleteSampleElement() 에서 지우는 기준이 되는 data-value 를
				// 사용하기 위해 협업유저에 한해 강제로 value 를 세팅한다.
				// 이는 추후 어떠한 방법으로 해결할지 논의하고 수정이 필요하다.
				collaboUserViewList = elFragmentInfo.sampleItemMap["collabo_user"];
				len = (collaboUserViewList && collaboUserViewList.length) || 0;

				for (i = 0; i < len; ++i) {
					targetEl = collaboUserViewList[i].el.querySelector("." + UiDefine.USER_NAME_CLASS);

					if (targetEl && !targetEl.getAttribute(UiDefine.DATA_VALUE)) {
						targetEl.setAttribute(UiDefine.DATA_VALUE, UiDefine.SAMPLE_VALUE);
					}
				}
			}

			UiFrameworkInfo.setInfo(UiFrameworkInfo.EL_FRAGMENT_INFO, elFragmentInfo);

			if (elFragmentInfo.color) {
				contentDocHead.appendChild(elFragmentInfo.color);
			}

			refTree = elFragmentInfo.refTree;
			UiFrameworkInfo.setRefTree(refTree);
			widgetMap = elFragmentInfo.widgetMap;
			UiFrameworkInfo.setInfo(UiFrameworkInfo.WIDGET_MAP, widgetMap);
			UiFrameworkInfo.setInfo(UiFrameworkInfo.UI_WIDGET_MAP, elFragmentInfo.uiWidgetMap);
			UiFrameworkInfo.setInfo(UiFrameworkInfo.COMMANDS_WIDGET_MAP, elFragmentInfo.commandsWidgetMap);
			UiFrameworkInfo.setInfo(UiFrameworkInfo.COMMANDS_WIDGET_IDX_MAP, elFragmentInfo.commandsWidgetIdxMap);
			UiFrameworkInfo.setInfo(UiFrameworkInfo.UPDATE_DESC_WIDGET_MAP, elFragmentInfo.updateDescWidgetMap);
			UiFrameworkInfo.setInfo(UiFrameworkInfo.SAMPLE_ITEM_MOVE_MAP, elFragmentInfo.sampleItemMoveMap);

			if (_callbackFnConvertingAfter && !_lazyConvertInfo) {
				if (refTree.modal_dialog) {
					modalFragment = document.createDocumentFragment();

					for (dialogName in refTree.modal_dialog) {
						if (_msgDialogList.indexOf(dialogName) === -1 && !(dialogName === "ref" || dialogName === "parentItem")) {
							modalFragment.appendChild(refTree.modal_dialog[dialogName].ref);
						}
					}
				}

				if (refTree.modeless_dialog) {
					_modelessFragment = document.createDocumentFragment();

					for (dialogName in refTree.modeless_dialog) {
						if (_msgDialogList.indexOf(dialogName) === -1 && !(dialogName === "ref" || dialogName === "parentItem")) {
							_modelessFragment.appendChild(refTree.modeless_dialog[dialogName].ref);
						}
					}
				}
			}

			UiFrameworkInfo.setInfo(UiFrameworkInfo.WRAP_NODE, FrameworkUtil.appendToMenuWrap(elFragmentInfo.elList, contentWindow));
			UiFrameworkInfo.setInfo(UiFrameworkInfo.UNIT_INFO, elFragmentInfo.unitInfo);
			UiFrameworkInfo.setInfo(UiFrameworkInfo.WIDGET_NAME_TO_VALUE_KEY_MAP, elFragmentInfo.widgetNameToValueKeyMap);
			UiFrameworkInfo.setInfo(UiFrameworkInfo.COMMAND_TO_VALUE_KEY_ARR_MAP, elFragmentInfo.commandToValueKeyArrMap);
			toastMsgWrap = this.getToolElement(UiDefine.TOOL_TOAST_MSG);
			_toastMessageWrap = toastMsgWrap || null;

			_uiCmdBtnInfo = elFragmentInfo.uiCommandButtonInfo;

			msgBarEl = widgetMap && widgetMap[_msgBarClass] && widgetMap[_msgBarClass][0];

			if (msgBarEl) {
				if (refTree[UiDefine.DOCUMENT_MENU_ID] && refTree[UiDefine.DOCUMENT_MENU_ID].ref) {
					parentNode = refTree[UiDefine.DOCUMENT_MENU_ID].ref.parentNode;

					parentNode.appendChild(msgBarEl);
				}
			}

			UiFrameworkInfo.setInfo(UiFrameworkInfo.VIEW_MAP, elFragmentInfo.viewMap);

			if (_callbackFnConvertingAfter) {
				// UI 가 바로 표시되므로, progress 표시하지 않았어도 자동 표시
				if (!this.isToolOn(_toolLoadingProgress)) {
					this.showTool(_toolLoadingProgress);
					// auto progress 임을 표시
					_isAutoProgressOn = true;
				}

			} else {
				this._initUiValue(contentDoc, widgetMap);
			}

			FrameworkUtil.setLangCodeToDom(contentWindow, _langDefine.LangCode);

			this._loadUiState();
			this._initUiCallbackMap();

			result = {
				refTree: elFragmentInfo.refTree ||  null,
				widgetMap: elFragmentInfo.widgetMap || null
			};

			// paint 이후에 수행해, 최대한 UI 가 빨리 표시되도록 처리
			window.setTimeout($.proxy(function() {
				var wrapNode = UiFrameworkInfo.getInfo(UiFrameworkInfo.WRAP_NODE);

				if (_callbackFnConvertingAfter) {
					this._initializeFontList(elFragmentInfo, fontDetectMode, skinName);
					this._initUiValue(contentDoc, widgetMap);

					if (_isAutoProgressOn) {
						// 자동 표시한 progress 는 hide
						this.hideTool(_toolLoadingProgress);
						_isAutoProgressOn = false;
					}

					_callbackFnConvertingAfter(result);
					_callbackFnConvertingAfter = null;
				}

				if (wrapNode) {
					window.setTimeout($.proxy(function() {
						if (_lazyConvertInfo) {
							if (_lazyConvertInfo.autoConvertTimer >= 0) {
								// autoConvertTimer 를 0 보다 작게 지정한 경우, auto lazy converting 하지 않음
								this.startLazyConvertTimer(_lazyConvertInfo.autoConvertTimer);
							}

						} else {
							if (modalFragment && refTree.modal_dialog) {
								refTree.modal_dialog.ref.appendChild(modalFragment);
							}

							if (_modelessFragment && refTree.modeless_dialog) {
								refTree.modeless_dialog.ref.appendChild(_modelessFragment);
								_modelessFragment = null;
							}

							if (_removeShapeArr) {
								this.removeShapeUiNode(_removeShapeArr);
								_removeShapeArr = null;
							}
						}

						wrapNode.appendChild(_getImageByDummy(baseDir, skinName));
						this.updateToolBarScroll();
					}, this), 0);
				}
			}, this), 0);

			return result;
		},

		/**
		 * App mode 지정 (EDITOR, VIEWER, WATCHER)
		 * - 공통적으로 EDITOR 지정 후 -> VIEWER 또는 WATCHER 로 변경 지정 가능
		 * - 단, UiDefine.USE_CHANGE_UI_MODE_MODULE_NAMES 에 해당하는 module 에 한해서 isChangeUiMode 지정시
		 * - VIEWER -> EDITOR 변경 지정 가능
		 * @param {Number} appMode				- UiDefine.APP_UI_MODE 중 하나의 모드
		 * @param {Boolean=} isChangeUiMode	- "e_change_ui_mode" command 에 의한 변경인 경우 true (default:false)
		 * @returns {Object} convertResult	- view mode 로 변경시 {refTree, widgetMap} 또는 null
		 */
		setAppUiMode: function(appMode, isChangeUiMode) {
			var appModeDefine = UiDefine.APP_UI_MODE,
				xmlList = UiFrameworkInfo.getInfo(UiFrameworkInfo.XML_LIST),
				convertResult = null,
				isValidMode = false,
				moduleName = UiFrameworkInfo.getModuleName(),
				useChangeUiModeModule = (_useChangeUiModeModules.indexOf(moduleName) !== -1),
				categoryVal, eventAction;

			if (!xmlList) {
				return null;
			}

			isChangeUiMode = (isChangeUiMode && useChangeUiModeModule);

			if (appMode === appModeDefine.EDITOR) {
				if (_appMode == null || (isChangeUiMode && _appMode === appModeDefine.VIEWER)) {
					isValidMode = true;

					if (_appMode === appModeDefine.VIEWER) {
						convertResult = this._reConvertXmlToDom(false, xmlList);
					}
				}

			} else if (appMode === appModeDefine.VIEWER) {
				if (_appMode == null || _appMode === appModeDefine.EDITOR) {
					isValidMode = true;

					if (!_isViewMode) {
						_uiOptionsArr = null;
						convertResult = this._reConvertXmlToDom(true, xmlList);

						// 미지원 스펙 리스트가 있으면, dialog_viewer 의 content 를 변경해준다.
						if (_unsupportedDataList.length > 0) {
							this.setUnsupportedDataMessage();
						}
					}

					if (useChangeUiModeModule) {
						// 읽기용보기 / 편집용보기 버튼 지원하는 Module 만 사용
						if (isChangeUiMode) {
							// 보기 메뉴 보여주고, viewer 를 선택한 것으로 처리
							eventAction = {
								list: [
									{cmd: _updateCmd, type: _eventActionType.EDIT, name: UiDefine.EVENT_ACTION_NAMES.E_CHANGE_UI_MODE, value: "viewer"},
									{cmd: _updateCmd, type: _eventActionType.VISIBLE, name: "view", value: ""}
								]
							};

						} else {
							// 사용자에 의한 view mode 전환이 아닌 경우 ui mode 전환 버튼 숨김
							eventAction = {cmd:_updateCmd, type:_eventActionType.HIDDEN, name:UiDefine.EVENT_ACTION_NAMES.E_CHANGE_UI_MODE, value:""};
						}

						this.updateUi(eventAction);
					}
				}

			} else if (appMode === appModeDefine.WATCHER) {
				if (_appMode == null || _appMode === appModeDefine.EDITOR) {
					isValidMode = true;

					/**
					 * 지정된 command 제외 모든 command 비활성화 및
					 * 관전모드에서 자동으로 지정되는 ui 갱신 (sidebar 관전모드 안내, ruler hide)
					 */
					categoryVal = {};
					categoryVal[UiDefine.SIDEBAR_CATEGORY] = _langDefine.WatcherMode;

					this.updateUi({
						list: [
							{cmd:_updateCmd, type:_eventActionType.DISABLE, name:_eventActionNames.ALL_COMMANDS_NAME, value:""},
							{cmd:_updateCmd, type:_eventActionType.ENABLE, name:_watcherModeEnableCommands, value:""},
							{cmd:_updateCmd, type:_eventActionType.UI, name:_uiCommandNames.DESCRIPTION, value:categoryVal},
							{cmd:_updateCmd, type:_eventActionType.UI, name:_uiCommandNames.ITEM_SHOW, value:{names:[UiDefine.WATCHER_MODE_MESSAGE], container:UiDefine.SIDEBAR_ID}},
							{cmd:_updateCmd, type:_eventActionType.UI, name:_uiCommandNames.HIDE, value:UiDefine.EVENT_ACTION_NAMES.E_RULER},
							{cmd:_updateCmd, type:_eventActionType.HIDDEN, name:UiDefine.EVENT_ACTION_NAMES.U_SHOW_RULER, value:""},
							{cmd:_updateCmd, type:_eventActionType.HIDDEN, name:UiDefine.SECTION_PROPERTY, value:""}
						]
					});
				}
			}

			if (isValidMode) {
				_appMode = appMode;

				if (!(appMode === appModeDefine.EDITOR || isChangeUiMode)) {
					/* editor mode 또는 사용자에 의한 ui mode 변경인 경우 xml 유지
					 * (재 변경 가능) */
					UiFrameworkInfo.setInfo(UiFrameworkInfo.XML_LIST, null);
				}
			}

			return convertResult;
		},

		/**
		 * command name, value 값 등으로 widget Element Array 구함
		 * @param {String} cmdName
		 * @param {String=} value					해당 value 로 한정
		 * @param {String=} valueKey				해당 valueKey 로 한정 (해당 widget 이 valueKey 있는경우 지정)
		 * @param {Element=} groupWidgetEl			해당 Widget Group (CommandItem) 에 한정
		 * 											같은 Group 내에 있는 아무 widget element 지정 가능
		 * 											(해당 Widget 이 있는 영역으로 한정)
		 * @return {Array}
		 */
		getWidgetElementList: function (cmdName, value, valueKey, groupWidgetEl) {
			return UiFrameworkInfo.getWidgetArr(cmdName, value, valueKey, groupWidgetEl);
		},

		/**
		 * 현재 보여지고 있는 dialog 정보 return
		 * @returns {Object}
		 */
		getDialogShowingInfo: function() {
			return UiFrameworkInfo.getDialogShowing();
		},

		/**
		 * 현재 열려 있는 레이어를 기준으로 상위 list box를 반환
		 * @returns {Element|Node}
		 */
		getDropdownBoxList: function() {
			return UiFrameworkInfo.getDropdownBoxList();
		},

		/**
		 * 드롭다운 리스트 정보를 반환한다.
		 * @returns {Object}
		 */
		getDropdownListInfo: function() {
			return UiFrameworkInfo.getDropdownListInfo();
		},

		/**
		 * xmlNameList 로부터 xmlList return
		 * @param {String} moduleName		- webword, webcell, webshow, webhwp, webhwpctrl
		 * @param {Window=} contentWindow	- (미지정시 window 사용)
		 * @param {String=} baseDir		- commonFrame 을 갖는 directory 지정
		 *									(webhwpctrl 에 한해서 /xml 및 /html 있는 dir 경로 직접 지정)
		 * @param {String=} skinName		- (미지정시 default. webhwpctrl 는 미사용)
		 * @returns {Array} xmlList
		 */
		getXmlList: function(moduleName, contentWindow, baseDir, skinName) {
			var xmlList = [],
				customFileName;

			if (baseDir) {
				if (!CommonFrameUtil.isEndsWith(baseDir, "/")) {
					baseDir += "/";
				}
			} else {
				baseDir = "";
			}

			if (UiDefine.USE_CUSTOM_XML_MODULE_NAMES.indexOf(moduleName) !== -1) {
				contentWindow = contentWindow || window;

				if (!_customXmlFileName && contentWindow.isUnitTest === true) {
					xmlList[0] = null;

					delete contentWindow.isUnitTest;
				} else {
					customFileName = _customXmlFileName || (moduleName + "Custom");
					xmlList[0] = UiRequester.requestXml(baseDir + "skins", customFileName);
				}
			}

			baseDir += "commonFrame/skins/" + (skinName || UiDefine.SKIN_DEFAULT) + "/xml/";

			xmlList[1] = UiRequester.requestXml(baseDir + moduleName + ".xml");
			xmlList[2] = UiRequester.requestXml(baseDir + "common.xml");

			return xmlList;
		},

		/**
		 * cmdName 에서 사용중인 valueKey Array 를 반환한다.
		 * cmdName 이 없으면 null 반환.
		 * Array 내에서 empty string 값("")은 valueKey 가 없는 value 가 있음을 나타냄.
		 * @param {String} cmdName			- command name
		 * @returns {Array|null} valueKeyArr (null 인 경우 해당 command 없음)
		 */
		getValueKeyList: function(cmdName) {
			var valueKeyArr = UiFrameworkInfo.getInfo(UiFrameworkInfo.COMMAND_TO_VALUE_KEY_ARR_MAP)[cmdName];

			// valueKeyArr 는 clone 후 return
			return valueKeyArr ? valueKeyArr.slice(0) : null;
		},

		/**
		 * ui 갱신 요청
		 * @param {Object} eventAction
		 * @returns {Boolean}
		 */
		updateUi: function(eventAction) {
			if (!CommonFrameUtil.isObject(eventAction)) {
				return false;
			}

			var listAction = eventAction.list,
				listIdx = 0,
				curAction = listAction ? listAction[0] : eventAction,
				result = false;

			while(curAction) {
				result = this._executeEventAction(curAction) || result;
				curAction = listAction ? listAction[++listIdx] : null;
			}

			return result;
		},

		/**
		 * 오픈된 Layer Menu (dropdownMenu, titleBarMenu, tool filter dialog) 중 가장 마지막 Layer Menu 를 반환
		 * @returns {*|Element|null}
		 */
		getLastLayerMenu : function() {
			return UiFrameworkInfo.getLayerMenu(true) || null;
		},

		/**
		 * contextMenu, dropdownMenu, titleBarMenu 닫음
		 * @param {Object=} el				- command element
		 */
		closeLayerMenu: function(el) {
			var layerMenuList = UiFrameworkInfo.getLayerMenuOn(),
				layerMenuListLen = layerMenuList.length,
				removeArrIndex = -1,
				isClosed = false,
				dropdownWrapEl, curArrowNode, target, i, boxEl, isClosedCurBox, targetParent,
				isColorPicker, focusWidgetInfo;

			FrameworkUtil.clearArrowKeyHover();

			if (layerMenuListLen > 0) {
				if (el) {
					if (CommonFrameUtil.hasClass(el, UiDefine.BTN_COMBO_ARROW_CLASS)) {
						curArrowNode = el;
					} else {
						dropdownWrapEl = CommonFrameUtil.findParentNode(el, "." + _dropdownSelectListWrapClass);
						curArrowNode = dropdownWrapEl ? dropdownWrapEl.previousElementSibling : null;
					}
				}

				for (i = 0; i < layerMenuListLen; i++) {
					target = layerMenuList[i];
					isClosedCurBox = false;

					if (el && curArrowNode) {
						// command element 가 있고 dropdown 하위에 있는 경우
						if (target === curArrowNode) {
							removeArrIndex = i;
						}

						if (removeArrIndex > -1) {
							isClosedCurBox = true;
							CommonFrameUtil.removeClass(target, _onStr);
						}
					} else {
						isClosedCurBox = true;

						if (CommonFrameUtil.hasClass(target, _toolFilterDialog)) {
							// tool filter dialog 인 경우
							this.hideTool(_toolFilterDialog);
						} else {
							// command element 가 없거나 독립적인 command 인 경우
							CommonFrameUtil.removeClass(target, _onStr);
						}
					}

					// 현재 boxEl 이 닫히게 된 상황
					if (isClosedCurBox) {
						targetParent = target.parentNode;

						if (UiUtil.isDropdown(targetParent) || UiUtil.isCombo(targetParent)) {
							CommonFrameUtil.removeClass(targetParent, UiDefine.DROPDOWN_HOVER_CLASS);
						}

						// 현재 닫히는 boxEl style 에 maxHeight 속성이 있다면 삭제함
						boxEl = (targetParent && targetParent.lastElementChild);

						if (boxEl && boxEl.style && boxEl.style.maxHeight) {
							CommonFrameUtil.removeStyleProperty(boxEl, "max-height");
						}

						// color picker layer 가 닫힐 때 color picker input 을 원래 값으로 돌리고 blur 처리한다.
						isColorPicker = UiController.setDefaultValueToSpectrumColor(boxEl);
						if (isColorPicker) {
							focusWidgetInfo = this.getFocusWidgetInfo();

							if (focusWidgetInfo && focusWidgetInfo.curWidgetEl) {
								focusWidgetInfo.curWidgetEl.blur();
							}
						}
					}
				}

				if (removeArrIndex > -1) {
					UiFrameworkInfo.removeLayerMenuOn(layerMenuListLen - removeArrIndex);
				} else {
					UiFrameworkInfo.removeLayerMenuOn();
				}

				isClosed = true;

			} else {
				isClosed = this._closeContextMenu();
			}

			isClosed = this.hideTooltip() || isClosed;

			return isClosed;
		},

		/**
		 * Dialog 를 hide 시키는 함수
		 * @param {Element=} target		- close 할 dialog_wrap element (미지정시 현재 열려있는 dialog)
		 * @returns {boolean}
		 */
		closeDialog: function(target) {
			var showingInfo = UiFrameworkInfo.getDialogShowing(),
				callbackInfo = {},
				targetDialog = target || showingInfo.viewNode,
				result = false,
				focusWidgetEl, eventObj, dialogName, beforeDlgName;

			if (!(targetDialog && CommonFrameUtil.hasClass(targetDialog, UiDefine.DIALOG_WRAP_CLASS))) {
				return false;
			}

			focusWidgetEl = UiFrameworkInfo.getFocusWidgetInfo().curWidgetEl;
			if (focusWidgetEl && UiUtil.findContainerNodeToParent(focusWidgetEl) === targetDialog.parentNode) {
				this.removeWidgetFocus();
			}

			this.closeLayerMenu();
			dialogName = FrameworkUtil.getName(targetDialog);
			// target 을 미지정시 모든 dialog 를 close 하는 상황이므로 기록된 beforeDialogName 모두 삭제
			beforeDlgName = target ? dialogName : null;

			if (!UiUtil.isHidden(targetDialog)) {
				callbackInfo = {
					key: UiDefine.UI_CALLBACK_KEY_DIALOG,
					value: dialogName,
					isDialogShow: false,
					isBefore: true
				};
				_uiCallbackMap[UiDefine.UI_CALLBACK_KEY_DIALOG](callbackInfo);

				eventObj = {
					kind: UiDefine.CUSTOM_EVENT_KIND.WIDGET,
					target: targetDialog,
					type: UiDefine.CUSTOM_EVENT_TYPE.UI_CLOSE_DIALOG,
					name: dialogName,
					execValue: "before"
				};
				FrameworkUtil.fireCustomEvent(eventObj);

				if (targetDialog.style) {
					targetDialog.style.height = "";
				}

				_dialogLayerHeight = null;
				FrameworkUtil.adjustDialogVScroll(targetDialog, false);

				CommonFrameUtil.addClass(targetDialog.parentNode, _hideViewClassName);
				CommonFrameUtil.addClass(targetDialog, _hideViewClassName);
				UiFrameworkInfo.setDialogShowing();
				UiFrameworkInfo.setActivatedDialog();
				UiFrameworkInfo.removeBeforeDialogName(beforeDlgName);

				callbackInfo.isBefore = false;
				_uiCallbackMap[UiDefine.UI_CALLBACK_KEY_DIALOG](callbackInfo);

				eventObj.execValue = "after";
				FrameworkUtil.fireCustomEvent(eventObj);
				result = true;
			} else {
				UiFrameworkInfo.removeBeforeDialogName(beforeDlgName);
			}

			return result;
		},

		/**
		 * dialog 포함 모든 menu 닫음
		 */
		closeAllMenu: function() {
			this.hideQuickMenu();
			this.closeLayerMenu();
			this.closeDialog();
		},

		/**
		 * titleBar menu 에 mouse over 될 때 호출 (pull down menu 동작 위함)
		 * @param {Element} titleBarCommandEl	- mouseOver 된 titleBarCommandElement
		 * @returns {Boolean}
		 */
		setTitleBarMenuOverOn: function(titleBarCommandEl) {
			return FrameworkUtil.setTitleBarMenuOverOn(titleBarCommandEl);
		},

		/**
		 * 현재 esc 로 close 가능한 dialog 가 열려있는지 아닌지
		 * @returns {Boolean}
		 */
		isEscCloseableDialogShowing: function() {
			var activatedDlg = UiFrameworkInfo.getActivatedDialog(),
				showingDlgValue;

			if (activatedDlg && activatedDlg === UiFrameworkInfo.getDialogShowing().viewNode) {
				showingDlgValue = UiFrameworkInfo.getDialogShowing().value;
			}

			return !!(showingDlgValue && UiDefine.UNABLE_CLOSE_DIALOG_ARR.indexOf(showingDlgValue) === -1);
		},

		/**
		 * name 에 해당하는 panel 하위에서 Widget Element 들을 구함
		 * @param {String} panelName	- panel 이름
		 * @returns {Array}
		 */
		findCommandWidgetsByPanelName: function(panelName) {
			var widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP),
				panelElArr = widgetMap && widgetMap[panelName],
				commandWidgets = [],
				len, i;

			if (panelElArr) {
				len = panelElArr.length;

				for (i = 0; i < len; i++) {
					commandWidgets = commandWidgets.concat(UiUtil.findCommandWidgets(panelElArr[i]));
				}
			}

			return commandWidgets;
		},

		/**
		 * view name 이 dialog 에 포함되는지 여부 return
		 * @param {String} name		- 확인할 대상
		 * @returns {boolean}
		 */
		isDialogName: function(name) {
			return this.isModelessDialogName(name) || this.isModalDialogName(name);
		},

		/**
		 * view name 이 modeless dialog 에 포함되는지 여부 return
		 * @param {String} name		- 확인할 대상
		 * @returns {boolean}
		 */
		isModelessDialogName: function(name) {
			var dialogContainer = UiFrameworkInfo.getRefTree()[UiDefine.MODELESS_DIALOG_ID];

			return !!(dialogContainer && dialogContainer[name]);
		},

		/**
		 * view name 이 modal dialog 에 포함되는지 여부 return
		 * @param {String} name		- 확인할 대상
		 * @returns {boolean}
		 */
		isModalDialogName: function(name) {
			var dialogContainer = UiFrameworkInfo.getRefTree()[UiDefine.MODAL_DIALOG_ID];

			return !!(dialogContainer && dialogContainer[name]);
		},

		/**
		 * 현재 표시되고 있는 modeless Dialog Element 구함.
		 * @returns {Element}
		 */
		getShowingModelessDialogElement: function() {
			var dialogView = UiFrameworkInfo.getDialogShowing().viewNode;

			if (dialogView && dialogView.parentNode.id !== UiDefine.MODELESS_DIALOG_ID) {
				dialogView = null;
			}

			return dialogView || null;
		},

		/**
		 * modeless dialog 내부의 모든 scroll 영역 반환.
		 * 아직 dialog 들이 container 에 append 되지 않은 상태의 modeless fragment 내부 포함.
		 * scroll event bind 등 내부 dom 을 구해야 할 경우 사용.
		 * @returns {Array}
		 */
		getModelessScrollAreaList: function () {
			var modelessWrap = UiFrameworkInfo.getContainerNode(UiDefine.MODELESS_DIALOG_ID),
				list = $(modelessWrap).find("." + UiDefine.PROPERTY_TITLE_CLASS).next().get();

			if (_modelessFragment) {
				list = list.concat(
					$(_modelessFragment.querySelectorAll("." + UiDefine.PROPERTY_TITLE_CLASS)).next().get());
			}

			return list;
		},

		/**
		 * 현재 표시되고 있는 modal dialog Element 구함.
		 * @returns {Element}
		 */
		getShowingModalDialogElement: function() {
			var dialogView = UiFrameworkInfo.getDialogShowing().viewNode;

			if (dialogView && dialogView.parentNode.id !== UiDefine.MODAL_DIALOG_ID) {
				dialogView = null;
			}

			return dialogView || null;
		},

		/**
		 * viewName 을 통해 view element 구함.
		 * @param {String} viewName
		 * @returns {Element}
		 */
		getViewElement: function(viewName) {
			if (!viewName) {
				return null;
			}

			var viewInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.VIEW_MAP)[viewName],
				viewNode = viewInfo ? viewInfo.ref : null,
				widgetMapArr;

			if (!viewNode) {
				widgetMapArr = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP)[viewName]
					|| UiFrameworkInfo.getInfo(UiFrameworkInfo.UPDATE_DESC_WIDGET_MAP)[viewName];

				if (widgetMapArr) {
					viewNode = widgetMapArr[0];
				}
			}

			if (!viewNode) {
				console.log('[Info] Update Ui : "' + viewName + '" is not found.');
			}

			return viewNode;
		},

		/**
		 * 현재 화면에 보여지는 dialog 의 container 를 반환한다.
		 * @returns {Element|null}
		 */
		getContainerOfDialogShowing: function () {
			var dialogShowingNode = UiFrameworkInfo.getDialogShowing().viewNode,
				containerInfo = UiUtil.findContainerInfoToParent(dialogShowingNode);

			return (containerInfo && containerInfo.container) || null;
		},

		/**
		 * Sample 로 보관한 Element 들에 정보를 채워 돌려주는 함수. (단일 description)
		 * @param {String} cmdName				- 가져올 sample 에 대한 cmdName (ex. "font_name")
		 * @param {Array} valueInfoList		- 세팅할 값들에 대한 정보에 대한 list
		 *                                         valueInfoList: [
		 *                                              {
		 *                                                  dataValue: "malgungothic", (data-value 에 포함될 값)
		 *                                                  title: "malgun gothic", (title 속성에 setting 될 값)
		 *                                                  ph: "글꼴", (placeholder)
		 *                                                  desc: "맑은 고딕" (description),
		 *                                                  bgColor: "#b2f1d3" (ot 협업 유저 컬러)
		 *                                                  style: "font-family:'gothic'" (적용할 스타일) - 무조건 desc
		 *                                                         DOM 에만 추가.
		 *                                                  dataValueKey: "", (data-value-key 에 포함될 값 ) - 체크박스 에서만 사용
		 *                                                  selected: "true" or "false", (선택 상태) - 체크박스 에서만 사용
		 *                                              },
		 *                                              { ... }
		 *                                          ];
		 * @param {Boolean} isRender				- 미리 렌더링 시킬지 여부
		 * @param {Boolean=} isRenderBefore		- isRender 가 true 일 경우에만 체크,
		 *                                              true 인 경우 앞에 삽입. false 면 뒤에 삽입
		 * @returns {Array}
		 */
		getSampleElementListByCmdName: function (cmdName, valueInfoList, isRender, isRenderBefore) {
			var fragmentInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.EL_FRAGMENT_INFO),
				sampleKeyName = (cmdName && cmdName.replace(/[ ]/g, "")) || "",
				sampleItemList = fragmentInfo.sampleItemMap[sampleKeyName],
				valueKeyArrMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.COMMAND_TO_VALUE_KEY_ARR_MAP),
				resultList = [],
				elList = [],
				sampleItemLen, valueInfoListLen, definePhNameAttr, sampleItem, valueInfo, el,
				valueKeyEl, valueEl, titleEl, phEl, descEl, bgColorEl, clonedEl, matchEl, inputEl,
				valueKey, value, title, ph, desc, bgColor, match, style, selected, i, j;

			if (!sampleItemList || sampleItemList.length === 0) {
				return [];
			}

			sampleItemLen = sampleItemList.length;

			if (!valueInfoList || valueInfoList.length === 0) {
				console.log("[ERROR]: need valueInfoList.");
				return [];
			}

			if (!_sampleValueKeyInfo[cmdName]) {
				_sampleValueKeyInfo[cmdName] = [];
			}

			valueInfoListLen = valueInfoList.length;

			definePhNameAttr = UiDefine.DATA_PLACEHOLDER_ATTR;

			for (i = 0; i < sampleItemLen; ++i) {
				sampleItem = sampleItemList[i];
				el = sampleItem.el;

				valueKeyEl = (el.getAttribute(_defineDataValueKeyAttr) && el) || el.querySelector("[" + _defineDataValueKeyAttr + "]");
				valueEl = (el.getAttribute(_defineDataValueAttr) && el) || el.querySelector("[" + _defineDataValueAttr + "]");
				titleEl = (el.getAttribute(_defineTitleAttr) && el) || el.querySelector("[" + _defineTitleAttr + "]");
				phEl = (el.getAttribute(definePhNameAttr) && el) || el.querySelector("[" + definePhNameAttr + "]");
				descEl = (el.getAttribute(_defineNlsNameAttr) && el) || el.querySelector("[" + _defineNlsNameAttr + "]");
				matchEl = (el.getAttribute(_defineMatchAttr) && el) || el.querySelector("[" + _defineMatchAttr + "]");
				bgColorEl = el.querySelector("." + UiDefine.USER_COLOR_CLASS);

				for (j = 0; j < valueInfoListLen; ++j) {
					valueInfo = valueInfoList[j];

					// sampleItem 의 valueKey 및 selected 는 checkbox 의 경우에만 설정 가능 (제약 사항)
					if (valueKeyEl && UiUtil.isCheckboxWidget(valueKeyEl)) {
						valueKey = valueInfo.dataValueKey;
						if (valueKey) {
							valueKeyEl.setAttribute(_defineDataValueKeyAttr, valueKey);

							selected = valueInfo.selected != null ? valueInfo.selected : sampleItem.selected;
							if (selected) {
								inputEl = UiUtil.getInputElementByWidget(valueKeyEl);
								inputEl.checked = (selected === _defineValue.TRUE);
							}

							if (!valueKeyArrMap[cmdName]) {
								valueKeyArrMap[cmdName] = [];
							}

							if (valueKeyArrMap[cmdName].indexOf(valueKey) === -1) {
								valueKeyArrMap[cmdName].push(valueKey);
								_sampleValueKeyInfo[cmdName].push(valueKey);
							}
						}
					}

					if (valueEl) {
						value = valueInfo.dataValue;
						if (value) {
							valueEl.setAttribute(_defineDataValueAttr, value);
						} else {
							valueEl.removeAttribute(_defineDataValueAttr);
						}
					}

					if (titleEl) {
						title = valueInfo.title;
						if (title) {
							titleEl.setAttribute(_defineTitleAttr, title);
						} else {
							titleEl.removeAttribute(_defineTitleAttr);
						}
					}

					if (matchEl) {
						match = valueInfo.match;
						if (match) {
							matchEl.setAttribute(_defineMatchAttr, match);
						} else {
							matchEl.removeAttribute(_defineMatchAttr);
						}
					}

					if (phEl) {
						ph = valueInfo.ph;
						if (ph) {
							phEl.setAttribute(definePhNameAttr, ph);
						} else {
							phEl.removeAttribute(definePhNameAttr);
						}
					}

					if (descEl) {
						style = valueInfo.style;
						if (style) {
							descEl.setAttribute(UiDefine.STYLE_ATTR, style);
						} else {
							descEl.removeAttribute(UiDefine.STYLE_ATTR);
						}

						desc = valueInfo.desc;
						if (desc) {
							descEl.textContent = desc;
							descEl.removeAttribute(_defineNlsNameAttr);
						} else {
							descEl.textContent = "";
						}
					}

					if (bgColorEl) {
						bgColor = valueInfo.bgColor;
						if (bgColor) {
							bgColorEl.style.setProperty("background-color", bgColor);
						} else {
							bgColorEl.style.setProperty("background-color", "#000000");
						}
					}

					clonedEl = el.cloneNode(true);

					if (isRender) {
						if (isRenderBefore) {
							sampleItem.parentEl.insertBefore(clonedEl, sampleItem.parentEl.firstElementChild);
						} else {
							sampleItem.parentEl.appendChild(clonedEl);
						}
					}

					elList.push(clonedEl);

					if (sampleItem.isSelectAllTarget) {
						UiFrameworkInfo.pushSelectAllTarget(
							cmdName, sampleItem.commandItemIndex, UiUtil.getInputElementByWidget(clonedEl), valueKey, (selected === _defineValue.TRUE));
					}
				}

				if (sampleItem.isSelectAllTarget) {
					this.updateSelectAllInfo(cmdName, sampleItem.commandItemIndex);
				}

				FrameworkUtil.initAttributeToSampleEl(valueEl, titleEl, descEl);

				resultList.push({
					container: sampleItem.container,
					parentEl: sampleItem.parentEl,
					elList: elList
				});

				elList = [];
			}

			return resultList;
		},

		/**
		 * Sample 로 보관한 Element 들에 정보를 채워 돌려주는 함수. (복수 description)
		 * @param {String} cmdName				- 가져올 sample 에 대한 cmdName (ex. "d_save_as")
		 * @param {Array} valueInfoList		- 세팅할 값들에 대한 정보에 대한 list
		 *                                         valueInfoList: [
		 *                                              {
		 *                                                  dataValue: "item1", (data-value 에 포함될 값)
		 *                                                  dataValueObj: { // DATA_SAMPLE_VALUE 값과 Key 일치하면 치환
		 *                                                      valueName: "sampleValue1",
		 *                                                      valueName2: "sampleValue2"
		 *                                                  }
		 *                                                  dataValueKeyObj: { // DATA_SAMPLE_VALUE_KEY 값과 Key 일치하면 치환
		 *                                                      keyName: "sampleKey1",
		 *                                                      keyName2: "sampleKey2"
		 *                                                  }
		 *                                                  className: "type_docx",
		 *                                                  descValObj: { // DATA_NLS_NAME_ATTR 값과 Key 일치하면 치환
		 *                                                      descVal: "sampleDesc1",
		 *                                                      descVal2: "sampleDesc2"
	 	 *                                                  },
		 *                                                  styleObj: { // DATA_SAMPLE_STYLE 값과 Key 일치하면 치환
		 *                                                      dataStyleVal: "color:#ff0000;",
		 *                                                      dataStyleVal2: "background-color:#aabbcc;"
		 *                                                  },
		 *                                                  titleObj: { // DATA_SAMPLE_TITLE 값과 Key 일치하면 치환
		 *                                                      titleVal: "malgun gothic",
		 *                                                      titleVal2: "font",
		 *                                                  }
		 *                                              },
		 *                                              { ... }
		 *                                          ];
		 * @param {Boolean} isRender				- 미리 렌더링 시킬지 여부
		 * @param {Boolean=} isRenderBefore		- isRender 가 true 일 경우에만 체크,
		 *                                              true 인 경우 앞에 삽입. false 면 뒤에 삽입
		 * @param {String=} sampleName				- cmdName 을 따르지 않고 customName 지정한 경우 추가 지정
		 * @returns {Array}
		 */
		getSampleElementListToDescObj: function (cmdName, valueInfoList, isRender, isRenderBefore, sampleName) {
			var fragmentInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.EL_FRAGMENT_INFO),
				sampleKeyName = (sampleName || cmdName || "").replace(/[ ]/g, ""),
				sampleItemList = fragmentInfo.sampleItemMap[sampleKeyName],
				resultList = [],
				elList = [],
				sampleDescElMap = {},
				sampleItemLen, sampleItem, valueInfoListLen, valueInfo, el, valueEl, className, descValObj, descVal,
				key, descEl, clonedEl, i, j, newValueKeyArr, bindWidgetEl, bindWidgetValue, bindWidgetValueKey;

			var __initAttributeToSampleEl = function (valueEl, sampleDescElMap) {
				var key, el;

				if (valueEl) {
					valueEl.setAttribute(_defineDataValueAttr, UiDefine.SAMPLE_VALUE);
				}

				if (!CommonFrameUtil.isEmptyObject(sampleDescElMap)) {
					for (key in sampleDescElMap) {
						el = sampleDescElMap[key];

						if (el != null) {
							el.setAttribute(_defineNlsNameAttr, key);
							el.textContent = "";
							if (el.hasAttribute(_defineTitleAttr)) {
								el.setAttribute(_defineTitleAttr, "");
							}
						}
					}
				}
			};

			if (!sampleItemList || sampleItemList.length === 0) {
				return [];
			}

			sampleItemLen = sampleItemList.length;

			if (!valueInfoList || valueInfoList.length === 0) {
				console.log("[ERROR]: need valueInfoList.");
				return [];
			}

			valueInfoListLen = valueInfoList.length;

			for (i = 0; i < sampleItemLen; ++i) {
				sampleItem = sampleItemList[i];
				el = sampleItem.el;

				valueEl = (el.getAttribute(_defineDataValueAttr) && el) || el.querySelector("[" + _defineDataValueAttr + "]");

				bindWidgetEl = el.querySelector("[" + UiDefine.DATA_BIND_WIDGET_ATTR + "]");
				bindWidgetValue = bindWidgetEl ? bindWidgetEl.getAttribute(UiDefine.DATA_BIND_WIDGET_ATTR) : null;

				for (j = 0; j < valueInfoListLen; ++j) {
					valueInfo = valueInfoList[j];

					if (!valueInfo) {
						continue;
					}

					if (valueEl) {
						if (valueInfo.dataValue) {
							valueEl.setAttribute(_defineDataValueAttr, valueInfo.dataValue);
						} else {
							valueEl.removeAttribute(_defineDataValueAttr);
						}
					}

					if (valueInfo.className) {
						CommonFrameUtil.addClass((valueEl || el), valueInfo.className);
					}

					descValObj = valueInfo.descValObj;

					if (descValObj) {
						for (key in descValObj) {
							if (sampleDescElMap[key] == null) {
								if (el.getAttribute(_defineNlsNameAttr) === key) {
									descEl = el;
								} else {
									descEl = el.querySelector("[" + _defineNlsNameAttr + "='" + key + "']");
								}

								sampleDescElMap[key] = descEl || null;
							} else {
								descEl = sampleDescElMap[key];
							}

							if (descEl) {
								descVal = descValObj[key];

								if (descVal !== "") {
									descEl.textContent = descVal;
									descEl.removeAttribute(_defineNlsNameAttr);
								} else {
									descEl.textContent = "";
								}

								if (descEl.hasAttribute(_defineTitleAttr)) {
									descEl.setAttribute(_defineTitleAttr, descVal);
								}
							}
						}
					}

					clonedEl = el.cloneNode(true);

					if (isRender) {
						if (isRenderBefore) {
							sampleItem.parentEl.insertBefore(clonedEl, sampleItem.parentEl.firstElementChild);
						} else {
							sampleItem.parentEl.appendChild(clonedEl);
						}
					}

					if (valueInfo.dataValueKeyObj) {
						newValueKeyArr = this._replaceAttribute(
							clonedEl, valueInfo.dataValueKeyObj, UiDefine.DATA_SAMPLE_VALUE_KEY, _defineDataValueKeyAttr, true);

						if (newValueKeyArr.length === 0) {
							// template 이 아닌 경우 dataValueKey 그대로 들어있음. 못찾은 경우 "data-value-key" 로 수행
							newValueKeyArr = this._replaceAttribute(
								clonedEl, valueInfo.dataValueKeyObj, _defineDataValueKeyAttr, null, true);
						}

						this._addCommandValueKey(cmdName, newValueKeyArr, sampleName);

						if (bindWidgetValue) {
							// 일치하는 valueKey 가 들어있는 경우 DATA_BIND_WIDGET_ATTR 의 값도 같이 처리
							bindWidgetValueKey = valueInfo.dataValueKeyObj[bindWidgetValue];
							if (bindWidgetValueKey) {
								this._replaceAttribute(clonedEl,
									UiUtil.getWidgetName(cmdName, bindWidgetValueKey), UiDefine.DATA_BIND_WIDGET_ATTR);
							}
						}
					}

					if (valueInfo.dataValueObj) {
						this._replaceAttribute(
							clonedEl, valueInfo.dataValueObj, UiDefine.DATA_SAMPLE_VALUE, _defineDataValueAttr, true);
					}

					if (valueInfo.styleObj) {
						this._replaceAttribute(
							clonedEl, valueInfo.styleObj, UiDefine.DATA_SAMPLE_STYLE, UiDefine.STYLE_ATTR, true);
					}

					if (valueInfo.titleObj) {
						this._replaceAttribute(
							clonedEl, valueInfo.titleObj, UiDefine.DATA_SAMPLE_TITLE, _defineTitleAttr, true);
					}

					elList.push(clonedEl);

					// valueEl 은 해당 valueInfoList 가 끝나기 전까지 재활용한다.
					// class 는 덮어쓰는 성격이 아니라 추가되는 성격이므로,
					// 미리 지워주지 않으면 매 루프마다 체크해야 될 부분이 많아진다.
					// 따라서, class 만 특수하게 매 루프 마지막에 class 삭제를 진행해준다.
					if (valueEl && className) {
						CommonFrameUtil.removeClass(valueEl, className);
					}
				}

				__initAttributeToSampleEl(valueEl, sampleDescElMap);

				resultList.push({
					container: sampleItem.container,
					parentEl: sampleItem.parentEl,
					elList: elList
				});

				elList = [];
			}

			return resultList;
		},

		/**
		 * 특정 sampleItem Element 를 위/아래로 이동하는 함수.
		 * @param {String} cmdName				- 가져올 sample 에 대한 cmdName (ex. "d_save_as")
		 * @param {Boolean} isUpDirection		- 위쪽 방향인 경우 true, 아래쪽 방향인 경우 false
		 * @param {String=} dataValue			- 이동 대상 dataValue. 미지정시 value 와 무관 (단, dataValueKey 지정)
		 * @param {String=} dataValueKey		- 이동 대상 dataValueKey. 미지정시 valueKey 와 무관 (단, dataValue 지정)
		 * @returns {Boolean}
		 */
		moveSampleElement: function (cmdName, isUpDirection, dataValue, dataValueKey) {
			var fragmentInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.EL_FRAGMENT_INFO),
				sampleItemList = fragmentInfo.sampleItemMap[cmdName],
				result = false,
				curSampleItem, i, targetEl, baseNode;

			if (!sampleItemList || sampleItemList.length === 0) {
				return result;
			}

			i = 0;
			curSampleItem = sampleItemList[i];

			while (curSampleItem) {
				targetEl = this._findSampleItemNode(curSampleItem.parentEl, dataValue, dataValueKey);

				if (targetEl) {
					if (isUpDirection) {
						baseNode = targetEl.previousElementSibling;
						CommonFrameUtil.insertBefore(baseNode, targetEl);
					} else {
						baseNode = targetEl.nextElementSibling;
						CommonFrameUtil.insertAfter(baseNode, targetEl);
					}

					// sampleItem move 버튼 활성/비활성 갱신
					this._updateSampleItemMoveButton(targetEl);

					result = !!baseNode;
					break;
				}

				curSampleItem = sampleItemList[++i];
			}

			return result;
		},

		/**
		 * 만들어져 있는 cmdName 에 해당하는 Sample Element 을 삭제하는 함수.
		 * @param {String} cmdName				- 가져올 sample 에 대한 cmdName (ex. "d_save_as")
		 * @param {String=} dataValue		    - 지울 dataValue. 미지정시 value 와 관계 없이 전체 삭제
		 * @param {String=} dataValueKey		- 지울 dataValueKey. 미지정시 valueKey 와 관계 없이 삭제
		 * @param {String=} sampleName			- cmdName 을 따르지 않고 customName 지정한 경우 추가 지정
		 * @returns {Boolean}
		 */
		deleteSampleElement: function (cmdName, dataValue, dataValueKey, sampleName) {
			var fragmentInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.EL_FRAGMENT_INFO),
				sampleKeyName = (sampleName || cmdName || "").replace(/[ ]/g, ""),
				sampleItemList = fragmentInfo.sampleItemMap[sampleKeyName],
				result = false,
				isRemoveAllSample = !(dataValue || dataValueKey),
				removedValueKeyArr = isRemoveAllSample ? _sampleValueKeyInfo[sampleName || cmdName] : [],
				selectAllTargetRemoved, i, sampleItemLen, sampleItem, parentEl, targetEl, cmdItemIndex, removedValueKey,
				checkMoveEl, child;

			if (!sampleItemList || sampleItemList.length === 0) {
				return result;
			}

			sampleItemLen = sampleItemList.length;

			for (i = 0; i < sampleItemLen; ++i) {
				sampleItem = sampleItemList[i];
				parentEl = sampleItem.parentEl;
				cmdItemIndex = sampleItem.commandItemIndex;

				if (isRemoveAllSample) {
					if (UiFrameworkInfo.isSelectAllCommand(cmdName, cmdItemIndex)) {
						selectAllTargetRemoved = UiFrameworkInfo.removeSelectAllTarget(cmdName, cmdItemIndex);
					}

					// remove All child
					child = parentEl.lastChild;
					while (child) {
						if (!checkMoveEl && UiUtil.isButtonOn(child)) {
							sampleName = UiUtil.getSampleName(parentEl);
							checkMoveEl = child;
						}
						parentEl.removeChild(child);
						child = parentEl.lastChild;
					}
					result = true;
				} else {
					targetEl = this._findSampleItemNode(parentEl, dataValue, dataValueKey);

					if (targetEl) {
						removedValueKey = UiUtil.getValueKey(targetEl);

						if (removedValueKeyArr.indexOf(removedValueKey) === -1
							&& _sampleValueKeyInfo[sampleKeyName].indexOf(removedValueKey) !== -1) {
							removedValueKeyArr.push(removedValueKey);
						}

						if (UiFrameworkInfo.isSelectAllCommand(cmdName, cmdItemIndex)) {
							selectAllTargetRemoved = UiFrameworkInfo.removeSelectAllTarget(
								cmdName, cmdItemIndex, removedValueKey);
						}

						if (UiUtil.isButtonOn(targetEl)) {
							sampleName = UiUtil.getSampleName(parentEl);
							checkMoveEl = targetEl;
						}
						CommonFrameUtil.removeNode(targetEl);
						result = true;
					}
				}

				if (selectAllTargetRemoved) {
					this.updateSelectAllInfo(cmdName, cmdItemIndex);
				}
			}

			this._removeCommandValueKey(cmdName, removedValueKeyArr, isRemoveAllSample, sampleName);

			/* sampleItem move 버튼 활성/비활성 갱신
			 * sampleName 은 sampleWrap 에 기록돼 있어, 삭제되면 얻어낼 수 없으므로 인자로 전달
			 */
			this._updateSampleItemMoveButton(checkMoveEl, sampleName);

			return result;
		},

		/**
		 * 가로선에 해당하는 DOM 을 만들어줌
		 * @returns {Element}
		 */
		getHorizontalLineElement: function() {
			return CommonFrameUtil.createDomEl("div", {className: UiDefine.HORIZONTAL_LINE_SEPARATOR_CLASS});
		},

		/**
		 * font content 로부터 font value 를 돌려줌
		 * @param {String} key
		 * @returns {String}
		 */
		getFontValue: function(key) {
			return _fontMap[key.replace(/[ ]/g, "")] || key;
		},

		/**
		 * ui command value 를 돌려주는 함수
		 * - button 에 uiValue 값이 있고, 이를 돌려줌
		 * @param {Element} buttonEl		- 대상 버튼
		 * @returns {String}
		 */
		getUiValue: function(buttonEl) {
			return buttonEl ? (buttonEl.getAttribute(_dataUiValue) || null) : null;
		},

		/**
		 * widget(panel) 에 했던 update description 정보를 받을 수 있음
		 *
		 * @param {String} name		- description 대상 widget(panel) name
		 * @returns {Object}	{desc, title, class} 정보 return (없는 widget이나 panel 의 경우 빈 object)
		 */
		getDescriptionInfo: function(name) {
			var result = {},
				widget, widgetMapArr;

			widgetMapArr = UiFrameworkInfo.getInfo(UiFrameworkInfo.UPDATE_DESC_WIDGET_MAP)[name];
			widget = widgetMapArr && widgetMapArr[0];

			if (widget) {
				result["desc"] = widget.textContent || "";
				result["title"] = widget.getAttribute("title") || "";
				result["class"] = widget.getAttribute(UiDefine.DATA_DESC_CLASS_ATTR) || "";
			}

			return result;
		},

		/**
		 * ui match 속성으로 연결된 대상 노드를 반환
		 * @param {Element} widget				- command element (evtAction 의 target)
		 * @param {Element} parentWidget		- widget 상위 widget
		 * @returns {Element|null}
		 */
		getMatchNode : function(widget, parentWidget) {
			if (!widget) {
				return null;
			}

			var matchTarget = UiUtil.getInputElementByWidget(widget) || widget,
				widgetParent = parentWidget || widget.parentNode,
				findNode = null,
				match, matchNode, arrMatch, i, len;

			if (!(matchTarget && widgetParent)) {
				return null;
			}

			match = matchTarget.getAttribute(UiDefine.DATA_MATCH_ATTR);

			if (!match) {
				return null;
			}

			arrMatch = widgetParent.querySelectorAll("[" + UiDefine.DATA_MATCH_ATTR + "='" + match + "']");
			len = arrMatch.length;

			for (i = 0; i < len; i++) {
				matchNode = arrMatch[i];

				if (matchNode && matchNode !== matchTarget && matchNode !== widget) {
					findNode = matchNode;
					break;
				}
			}

			return findNode;
		},

		/**
		 * 배열에 들어있는 class 에 해당되는 DOM 들을 삭제하는 함수
		 *
		 * @param {Array} arr		- 삭제할 DOM 의 class 들을 모아놓은 배열
		 * @returns {void}
		 */
		removeShapeUiNode: function(arr) {
			var document = UiFrameworkInfo.getContentWindow().document,
				insertShapeEl = document.getElementsByClassName(_eventActionNames.S_INSERT_SHAPE)[0], // 추후 UiDefine 추가해야 함.
				len = arr.length,
				parentNodeArr = [],
				i, parentNode, parentNodeArrLen, node, titleNode, boxNode;

			if (!insertShapeEl) {
				_removeShapeArr = arr;
				return;
			}

			for (i = 0; i < len; ++i) {
				node = insertShapeEl.getElementsByClassName(arr[i])[0];

				if (node) {
					if (!parentNode || parentNode !== node.parentNode) {
						parentNode = node.parentNode;

						if (parentNodeArr.indexOf(parentNode) === -1) {
							parentNodeArr[parentNodeArr.length] = parentNode;
						}
					}

					CommonFrameUtil.removeNode(node);
				}
			}

			parentNodeArrLen = parentNodeArr.length;

			for (i = 0; i < parentNodeArrLen; ++i) {
				if (!parentNodeArr[i].firstElementChild) {
					boxNode = parentNodeArr[i].parentNode;
					titleNode = boxNode && boxNode.previousElementSibling;

					if (titleNode && boxNode) {
						CommonFrameUtil.removeNode(titleNode);
						CommonFrameUtil.removeNode(boxNode);
					}
				}
			}
		},

		/**
		 * container 단위별 width height 정보를 반환하는 함수
		 *
		 * @param {String} containerName		- size 정보를 알고싶은 container 이름
		 *                                        ex) side_bar,
		 * @returns {Object} {width : ..., height: ...}
		 */
		getContainerSizeInfo: function(containerName) {
			var containerEl = UiFrameworkInfo.getContainerNode(containerName);

			return {
				width: (containerEl && containerEl.offsetWidth) || 0,
				height: (containerEl && containerEl.offsetHeight) || 0
			};
		},

		/**
		 * tool element 를 가져오는 함수
		 * @param {String} toolName			- element 를 가져올 tool name
		 * @returns {Element}
		 */
		getToolElement: function (toolName) {
			var containerRefTree = UiFrameworkInfo.getRefTree()[UiDefine.TOOL_BOX_ID],
				toolWrapEl = containerRefTree ? containerRefTree[toolName] : null;

			return toolWrapEl ? toolWrapEl.ref : null;
		},

		/**
		 * tool 을 화면에서 보여주는 함수
		 * @param {String} toolName			- 표시 할 tool name
		 * @param {Object=} pos				- 표시 할 위치 {top,left} (미지정시 초기화값)
		 * @param {(String|Object)=} data	- 필요시 저장해 놓을 data
		 */
		showTool: function (toolName, pos, data) {
			var toolWrapEl = this.getToolElement(toolName),
				scrollBox;

			if (toolWrapEl) {
				this._setButtonOn(toolWrapEl);

				if (_isAutoProgressOn && toolName === _toolLoadingProgress) {
					// 명시적으로 show 했으니 더이상 auto progress 가 아닌것으로 표시
					_isAutoProgressOn = false;
				}

				if (pos) {
					if (pos.top) {
						toolWrapEl.style.top = pos.top + _pxStr;
					}
					if (pos.left) {
						toolWrapEl.style.left = pos.left + _pxStr;
					}
				}

				this.setToolData(toolName, data);
			}

			if (toolName === _toolFilterDialog) {
				UiFrameworkInfo.addLayerMenuOn(toolWrapEl);

				scrollBox = toolWrapEl && toolWrapEl.querySelector(".filter_list");
				if (scrollBox) {
					scrollBox.scrollTop = 0;
				}
			}
		},

		/**
		 * tool 을 화면에서 숨기는 함수
		 * @param {String} toolName			- 숨길 tool name
		 */
		hideTool: function (toolName) {
			var toolWrapEl = this.getToolElement(toolName);

			if (toolWrapEl) {
				this._setButtonOff(toolWrapEl);
				CommonFrameUtil.removeStyleProperty(toolWrapEl, _topStr);
				CommonFrameUtil.removeStyleProperty(toolWrapEl, _leftStr);

				if (this.getToolData(toolName) !== undefined) {
					this.setToolData(toolName, null);
				}
			}

			if (toolName === _toolFilterDialog) {
				UiFrameworkInfo.removeLayerMenuOn();
			}
		},

		/**
		 * tool 관련 data 를 저장해 놓는 함수
		 * @param {String} toolName			- tool name
		 * @param {(String|Object)=} data	- 필요시 저장해 놓을 data
		 */
		setToolData: function (toolName, data) {
			if (!toolName) {
				return;
			}

			UiFrameworkInfo.getInfo(UiFrameworkInfo.TOOL_DATA)[toolName] = data;
		},


		/**
		 * tool 관련 data 를 반환하는 함수
		 * @param {String} toolName			- tool name
		 * @returns {(String|Object)}
		 */
		getToolData: function (toolName) {
			return UiFrameworkInfo.getInfo(UiFrameworkInfo.TOOL_DATA)[toolName];
		},

		/**
		 * tool 이 활성화 상태인지 확인하는 함수
		 * @param {String} toolName						- tool name
		 * @returns {Boolean}
		 */
		isToolOn: function (toolName) {
			var toolWrapEl = this.getToolElement(toolName),
				result = false;

			if (toolWrapEl) {
				result = UiUtil.isButtonOn(toolWrapEl);
			}

			return result;
		},

		/**
		 * titleBar 가 열려있는 상태인지 확인하는 함수
		 * @returns {Boolean}
		 */
		isTitleBarMenuOn: function () {
			var titleBarMenu = UiFrameworkInfo.getContainerNode(_titleBarId),
				layerMenu = UiFrameworkInfo.getLayerMenuOn();

			return (layerMenu[layerMenu.length - 1] === titleBarMenu);
		},

		/**
		 * tooltip 을 화면에 표시하는 함수
		 * @param {Element} target				- tooltip 을 표시할 target
		 * @param {String} value				- tooltip 내용
		 * @param {Object=} pos				- open 할 위치 {top,left} (미지정시 target의 바로 하단 위치)
		 */
		showTooltip: function (target, value, pos) {
			var tooltip = UiDefine.TOOL_TOOLTIP,
				tooltipLayerOn = UiFrameworkInfo.getInfo(UiFrameworkInfo.TOOLTIP_LAYER_ON),
				tooltipWrapEl = this.getToolElement(tooltip),
				tooltipPosition = pos;

			if (!tooltipWrapEl) {
				return;
			}

			tooltipWrapEl.firstElementChild.textContent = value;

			if (CommonFrameUtil.isEmptyObject(tooltipLayerOn)) {
				tooltipLayerOn.tooltipWrap = tooltipWrapEl;
				tooltipLayerOn.target = target;
			}

			if (!(pos && pos.top && pos.left)) {
				tooltipPosition = this._getPosTooltip(target, tooltipWrapEl, UiFrameworkInfo.getContentWindow());
			}

			this.showTool(tooltip, tooltipPosition);
		},

		/**
		 * tooltip 을 화면에서 숨기는 함수
		 */
		hideTooltip: function() {
			var tooltipLayerOn = UiFrameworkInfo.TOOLTIP_LAYER_ON,
				tooltipLayer = UiFrameworkInfo.getInfo(tooltipLayerOn),
				isClosed = false;

			if (!CommonFrameUtil.isEmptyObject(tooltipLayer)) {
				if (tooltipLayer.tooltipWrap) {
					this.hideTool(UiDefine.TOOL_TOOLTIP);
					UiFrameworkInfo.setInfo(tooltipLayerOn, {});
					isClosed = true;
				}
			}

			return isClosed;
		},

		/**
		 * toast message 를 화면에 표시하는 함수
		 * @param {String} value		- tooltip 내용
		 * @param {Object=} option		- 위치 및 animation 이동 값 지정 (inline style. %, px 등 단위사용)
		 * 									{	top: {String=} 시작 top 값, (단위포함 / bottom 중복불가)
		 * 										left: {String=} 시작 left 값, (단위포함 / right 중복불가)
		 * 										right: {String=} 시작 right 값, (단위포함 / left 중복불가)
		 *	 									bottom: {String=} 시작 bottom 값, (단위포함 / top 중복 불가)
		 * 										direction: {String=} 이동방향 "top"(기본) 또는 "bottom"
		 * 										move: {Number=} 이동할 값, (px 단위. 미지정시 높이값)
		 * 										opacity: {Number=} 시작 opacity 값, (미지정시 0.3)
		 * 										align: {String=} 가로정렬 값, ("left"-default "center" "right" 중 1가지)
		 * 									}
		 * 									(미지정시 기본위치: 우측 하단에서 높이만큼)
		 * @param {Number=} time		- 지속시간 (초 단위. 미지정시 default 3)
		 */
		showToast: function (value, option, time) {
			var toastWrapEl = _toastMessageWrap,
				$toastWrapEl = $(toastWrapEl),
				toastMsgEl = toastWrapEl && toastWrapEl.firstElementChild,
				useMarginBottom = false,
				animateObj = {
					opacity: 1
				},
				posTop, posLeft, posRight, posBottom, posMove, align, opacity, toastWrapElStyle, alignClass, curAlign;

			if (option) {
				posTop = option.top;
				posLeft = option.left;
				posRight = option.right;
				posBottom = option.bottom;
				posMove = option.move;
				opacity = option.opacity;
				align = option.align;
			}

			if (toastMsgEl && value) {
				toastWrapElStyle = toastWrapEl.style;

				if (UiUtil.isButtonOn(toastWrapEl)) {
					$toastWrapEl.stop();
					toastWrapElStyle.margin = 0;
				} else {
					this._setButtonOn(toastWrapEl);
				}

				// top-bottom 관련 position
				if (posTop != null) {
					if (posTop !== toastWrapElStyle.top) {
						toastWrapElStyle.top = posTop;
					}
					toastWrapElStyle.bottom = _autoStr;
				} else if (posBottom != null) {
					if (posBottom !== toastWrapElStyle.bottom) {
						toastWrapElStyle.bottom = posBottom;
					}
					toastWrapElStyle.top = _autoStr;
					useMarginBottom = true;
				} else {
					toastWrapElStyle.removeProperty(_topStr);
					toastWrapElStyle.removeProperty(_defineValue.BOTTOM);
				}

				// left-right 관련 position
				if (posLeft != null) {
					if (posLeft !== toastWrapElStyle.left) {
						toastWrapElStyle.left = posLeft;
					}
					toastWrapElStyle.right = _autoStr;
				} else if (posRight != null) {
					if (posRight !== toastWrapElStyle.right) {
						toastWrapElStyle.right = posRight;
					}
					toastWrapElStyle.left = _autoStr;
				} else {
					toastWrapElStyle.removeProperty(_leftStr);
					toastWrapElStyle.removeProperty(_defineValue.RIGHT);
				}

				// 내용 추가
				if (value !== toastMsgEl.textContent) {
					CommonFrameUtil.emptyNode(toastMsgEl);
					FrameworkUtil.setDescription(toastMsgEl, value);
				}

				// animation move 관련
				if (posMove == null) {
					posMove = toastWrapEl.offsetHeight;
					if (!option || CommonFrameUtil.isEmptyObject(option)) {
						// pos 조정하지 않았다면 기본적으로 이동 10px 추가
						posMove += 10;
					}
				}
				posMove = parseInt(posMove);

				if (posMove && (!option || option.direction !== _defineValue.BOTTOM)) {
					posMove *= -1;
				}
				if (useMarginBottom) {
					animateObj.marginBottom = posMove * -1;
				} else {
					animateObj.marginTop = posMove;
				}

				toastWrapElStyle.opacity = CommonFrameUtil.isNumber(opacity) ? opacity : 0.3;
				$toastWrapEl.stop().animate(animateObj, 500);

				alignClass = _alignClassObj[align];
				curAlign = toastMsgEl.getAttribute(UiDefine.DATA_ALIGN_H) || null;

				if (!alignClass) {
					// left 또는 비정상 값
					align = null;
				}

				if (align !== curAlign) {
					if (curAlign) { // 기존 값 삭제
						CommonFrameUtil.removeClass(toastMsgEl, _alignClassObj[curAlign]);
					}

					if (align) { // 신규 값 지정
						toastMsgEl.setAttribute(UiDefine.DATA_ALIGN_H, align);
						CommonFrameUtil.addClass(toastMsgEl, alignClass);
					} else {
						toastMsgEl.removeAttribute(UiDefine.DATA_ALIGN_H);
					}
				}

				if (_toastTimer) {
					clearTimeout(_toastTimer);
				}

				_toastTimer = setTimeout($.proxy(function() {
					this.hideToast();
					_toastTimer = null;
				}, this), time ? (time * 1000) : 3000);
			}
		},

		/**
		 * toast message 를 숨기는 함수
		 */
		hideToast: function () {
			var toastWrapEl = _toastMessageWrap,
				$toastWrapEl = $(toastWrapEl);

			if (toastWrapEl) {
				if (_toastTimer) {
					clearTimeout(_toastTimer);
				}

				$toastWrapEl.stop().animate({margin: 0, opacity: 0.3}, 500,
					$.proxy(function() {
						this._setButtonOff(toastWrapEl)
					}, this));
			}
		},

		/**
		 * Quick menu 가 켜져 있는지 확인하는 함수
		 * @returns {Boolean}
		 */
		isShowQuickMenu: function () {
			return this.isToolOn(_quickMenuClass);
		},

		/** Quick menu 를 showing 하는 함수
		 *
		 * @param {Object} posInfo				- Quick menu 를 표시할 좌표 ({x : (number), y : (number)})
		 * @return {void}
		 */
		showQuickMenu: function (posInfo) {
			if (!(posInfo && !CommonFrameUtil.isEmptyObject(posInfo) &&
				(_appMode == null || _appMode === UiDefine.APP_UI_MODE.EDITOR))) {
				return;
			}

			var quickMenuEl = this.getToolElement(_quickMenuClass),
				mouseDownTarget = _mouseDownTarget,
				contentWindow = UiFrameworkInfo.getContentWindow(),
				windowInnerWidth = contentWindow.innerWidth,
				windowInnerHeight = contentWindow.innerHeight,
				isMouseDownInEditArea = false,
				x, y, menuWidth, menuHeight, containerNode;

			if (mouseDownTarget && !CommonFrameUtil.hasClass(mouseDownTarget, UiDefine.EDIT_AREA)) {
				containerNode = UiUtil.findContainerInfoToParent(mouseDownTarget).container;
				if (containerNode && containerNode.id === UiDefine.DOCUMENT_MENU_ID) {
					isMouseDownInEditArea = true;
				}

				_mouseDownTarget = null;
			}

			if (quickMenuEl && isMouseDownInEditArea) {
				x = posInfo.x;
				y = posInfo.y;

				if (CommonFrameUtil.isNumber(x) && CommonFrameUtil.isNumber(y)) {
					this.showTool(_quickMenuClass);
					menuWidth = quickMenuEl.offsetWidth;
					menuHeight = quickMenuEl.offsetHeight;

					if (windowInnerHeight < y + menuHeight) {
						// 1. 메뉴가 밑으로 넘어갈 경우
						y = windowInnerHeight - menuHeight;
					} else if (y - menuHeight - _quickMenuMargin < 0) {
						// 2. menu 가 위로 넘어갈 경우
						y += _quickMenuMargin;
					} else {
						y = y - menuHeight - _quickMenuMargin;
					}

					if (windowInnerWidth < x + menuWidth) {
						// 메뉴가 오른쪽으로 넘어갈 경우
						x = windowInnerWidth - menuWidth;
					}

					if (x < 0) {
						// 메뉴가 왼쪽으로 넘어갈 경우
						x = 0;
					}

					quickMenuEl.style.top = y + _pxStr;
					quickMenuEl.style.left = x + _pxStr;
				}
			}
		},

		/**
		 * Quick menu 를 닫는 함수
		 *
		 * @param {Object=} el				- command element
		 * @returns {Boolean} 닫았으면 true, 닫지 않았다면 false
		 */
		hideQuickMenu: function (el) {
			var isClosed = false;

			if (!this.isShowQuickMenu()) {
				return isClosed;
			}

			if (!el || (UiUtil.findContainerInfoToParent(el).topNode !== this.getToolElement(_quickMenuClass))) {
				this.hideTool(_quickMenuClass);

				isClosed = true;
			}

			return isClosed;
		},

		/**
		 * mousedown 일어난 경우 target 정보 setting (menu show 를 위한 정보)
		 *
		 * @param {Object} target			- command element
		 * @returns {Boolean} 닫았으면 true, 닫지 않았다면 false
		 */
		setMouseDownTarget: function(target) {
			_mouseDownTarget = target;
		},

		/** context menu 의 subgroup box 위치를 조정하는 함수
		 *
		 * @param {Element} subGroupBoxEl			- context menu 의 sub group box element
		 */
		setPosSubBox: function (subGroupBoxEl) {
			var contentWindow = UiFrameworkInfo.getContentWindow(),
				offset, subBoxVPos, winHeight, defaultTop, defaultLeftPos, winWidth, subBoxHPos, marginLeft, menuEl;

			if (!subGroupBoxEl) {
				return;
			}

			if (subGroupBoxEl.style.top) {
				CommonFrameUtil.removeStyleProperty(subGroupBoxEl, _topStr);
			}

			if (subGroupBoxEl.style.left) {
				CommonFrameUtil.removeStyleProperty(subGroupBoxEl, _leftStr);
			}

			winHeight = contentWindow.innerHeight;
			offset = subGroupBoxEl.getBoundingClientRect();
			subBoxVPos = offset.top + offset.height;

			if (subBoxVPos > winHeight) {
				defaultTop = parseFloat(CommonFrameUtil.getCurrentStyle(subGroupBoxEl, _topStr)) || 0;
				subGroupBoxEl.style.top = ((winHeight - subBoxVPos) + defaultTop) + _pxStr;
			}

			winWidth = contentWindow.innerWidth;
			subBoxHPos = offset.left + offset.width;

			if (subBoxHPos > winWidth) {
				defaultLeftPos = parseFloat(CommonFrameUtil.getCurrentStyle(subGroupBoxEl, _leftStr)) || 0;
				marginLeft = parseFloat(CommonFrameUtil.getCurrentStyle(subGroupBoxEl, "margin-left")) || 0;

				menuEl = subGroupBoxEl.parentNode.parentNode;

				if (menuEl && offset.width <= menuEl.getBoundingClientRect().left) {
					subGroupBoxEl.style.left = -(offset.width + marginLeft + defaultLeftPos) + _pxStr;
				}
			}
		},

		/**
		 * Dialog top position 을 현재 화면 사이즈에 맞게 위치하도록 조정하는 함수
		 *
		 * @param {Element=} target			- Dialog Element, 지정하지 않으면 현재 출력된 dialog 로 할당
		 */
		setDialogTopPos : function(target) {
			var dialogView = target || UiFrameworkInfo.getDialogShowing().viewNode,
				containerNode = UiUtil.findContainerNodeToParent(dialogView);

			if (containerNode && dialogView) {
				if (containerNode.id === UiDefine.MODELESS_DIALOG_ID) {
					// 이동량 0,0 지정해서 현재 위치에서 예외처리(window 벗어난 경우 조정)만 수행
					this.adjustDialogPos(true, true);

				} else {
					/** modal 은 기본위치가 화면 중앙. 초기 위치로 돌아가기 위해
					 * css 로 50% 지정돼 있으므로 별도 지정된 left 제거. */
					dialogView.style.left = "";
					FrameworkUtil.setDialogTopPosition(dialogView, _dialogLayerHeight);
				}
			}
		},

		/**
		 * Dialog top position 을 원하는 위치로 조정하는 함수
		 *
		 * @param {Number=} addLeft		- 왼쪽 증가량
		 * @param {Number=} addTop			- 위쪽 증가량
		 * @param {Boolean=} isAdjustPos	- UiFramework 에 의해 위치 조정 시도하는 경우 true 지정
		 * 									  (기본값 돌아가는 상황, window size 조절 상황 등)
		 * @returns {Object} {top,left} 실제 증가량
		 */
		moveDialogPos: function(addLeft, addTop, isAdjustPos) {
			var dialogView = UiFrameworkInfo.getDialogShowing().viewNode,
				moveInfo = {
					top: 0,
					left: 0
				},
				isMoved = false,
				doc, curTop, curLeft, wrapEl, styleProp, top, left, winWidth, winHeight,
				dlgWidth, dlgHeight, marginLeft;

			if (dialogView) {
				styleProp = dialogView.style;
				doc = dialogView.ownerDocument;
				wrapEl = doc.getElementById(UiDefine.WRAP_ID);

				if (CommonFrameUtil.isNumber(addTop)) {
					winHeight = CommonFrameUtil.getOffsetHeight(wrapEl);

					if (!_dialogLayerHeight) {
						dlgHeight = CommonFrameUtil.getOffsetHeight(dialogView);
					} else {
						dlgHeight = _dialogLayerHeight;
					}

					curTop = parseInt(styleProp.top || 0, 10);
					top = curTop + addTop;

					if (top + dlgHeight > winHeight) {
						top = winHeight - dlgHeight;
					}

					if (top < 0) {
						top = 0;
					}

					if (isAdjustPos) {
						FrameworkUtil.adjustDialogVScroll(dialogView, (winHeight < dlgHeight));
					}

					if (curTop !== top) {
						styleProp.top = top + _pxStr;
						moveInfo.top = top - curTop;
						isMoved = true;
					}
				}

				if (CommonFrameUtil.isNumber(addLeft)) {
					winWidth =  wrapEl.offsetWidth;

					if (FrameworkUtil.isAutoMoveStateDialog(dialogView)) {
						// left style 없는경우 초기화
						_setDialogLeftPosition(dialogView);
					}

					dlgWidth = parseInt(styleProp.width || 0, 10);
					curLeft = parseInt(styleProp.left || 0, 10);
					marginLeft = parseInt(styleProp.marginLeft || 0, 10);
					left = curLeft + addLeft;

					if (left + dlgWidth + marginLeft > winWidth) {
						left = winWidth - dlgWidth - marginLeft;
					}
					if (left + marginLeft < 0) {
						left = marginLeft * -1;
					}

					if (curLeft !== left) {
						styleProp.left = left + _pxStr;
						moveInfo.left = left - curLeft;
						isMoved = true;
					}
				}

				if (isMoved) {
					FrameworkUtil.fireCustomEvent({
						kind: UiDefine.CUSTOM_EVENT_KIND.WIDGET,
						target: dialogView,
						type: UiDefine.CUSTOM_EVENT_TYPE.UI_DIALOG_MOVE,
						name: UiDefine.CUSTOM_EVENT_TYPE.UI_DIALOG_MOVE
					});
				}
			}

			return moveInfo;
		},

		/**
		 * Dialog top position 을 확인하고, 예외적인 위치에 있는 경우 조정해주는 함수
		 *
		 * @param {Boolean=} adjustLeft	- 왼쪽 확인
		 * @param {Boolean=} adjustTop		- 위쪽 확인
		 * @returns {Object} {top,left} 실제 증가량
		 */
		adjustDialogPos: function (adjustLeft, adjustTop) {
			return this.moveDialogPos(adjustLeft ? 0 : null, adjustTop ? 0 : null, true);
		},

		/**
		 * target을 기준으로 tooltip 의 위치를 조정하는 함수
		 */
		setTooltipPos : function() {
			var tooltipLayer = UiFrameworkInfo.getInfo(UiFrameworkInfo.TOOLTIP_LAYER_ON),
				tooltipWrapEl, tooltipTarget, tooltipPosition;

			if (!CommonFrameUtil.isEmptyObject(tooltipLayer)) {
				tooltipWrapEl = tooltipLayer.tooltipWrap;
				tooltipTarget = tooltipLayer.target;
			}

			if (tooltipTarget) {
				tooltipPosition = this._getPosTooltip(tooltipTarget, tooltipWrapEl, UiFrameworkInfo.getContentWindow());

				if (tooltipPosition) {
					tooltipWrapEl.style.top = tooltipPosition.top + _pxStr;
					tooltipWrapEl.style.left = tooltipPosition.left + _pxStr;
				}
			}
		},

		/**
		 * 해당 widget 잠금. (enable action 과 관계없이 비활성화 상태로 계속 유지)
		 * 이후 해제될 때 마지막에 받았던 enable/disable 상태 없는경우 lock 하기 전상태로 복구
		 * @param {String} widgetName
		 * @param {Boolean} lockState		- true: 잠금 / false: 해제
		 */
		setUiLock: function (widgetName, lockState) {
			var curCmdLockInfo = _uiLockInfo[widgetName],
				disableState, widgetEl, evtAction;

			if (lockState) {
				widgetEl = UiFrameworkInfo.getWidgetArr(widgetName)[0];

				if (widgetEl && UiUtil.isEnabled(widgetEl)) {
					disableState = false;
					evtAction = {cmd:_updateCmd, type: _eventActionType.DISABLE, name:widgetName, value:""};
				} else {
					disableState = true;
				}
				_uiLockInfo[widgetName] = disableState;
			} else {
				if (!curCmdLockInfo) {
					evtAction = {cmd:_updateCmd, type:_eventActionType.ENABLE, name:widgetName, value:""};
				}

				delete _uiLockInfo[widgetName];
			}

			if (evtAction) {
				this.updateUi(evtAction);
			}
		},

		/** resize 시 tool bar (title/menu/style bar) 의 scroll 부분을 update 하는 함수
		 *
		 * @returns {void|Boolean}
		 */
		updateToolBarScroll: function () {
			var refTree = UiFrameworkInfo.getRefTree(),
				isUpdateToToolBar = false;

			if (!refTree) {
				return;
			}

			if (refTree[_titleBarId] && !UiUtil.isHidden(refTree[_titleBarId].ref)) {
				this._setMenuScrollInfoIfNeeded(_titleBarId);
				this._visibleToolBarNavBoxIfNeeded(_titleBarId);
				this._updateMarginLeftToToolBar(_titleBarId);
			}

			if (refTree[_menuBarId] && !UiUtil.isHidden(refTree[_menuBarId].ref)) {
				this._setMenuScrollInfoIfNeeded(_menuBarId);
				this._visibleToolBarNavBoxIfNeeded(_menuBarId);
				this._updateMarginLeftToToolBar(_menuBarId);
			}

			if (refTree[_styleBarId] && !UiUtil.isHidden(refTree[_styleBarId].ref)) {
				this._setMenuScrollInfoIfNeeded(_styleBarId);
				this._visibleToolBarNavBoxIfNeeded(_styleBarId);
				isUpdateToToolBar = this._updateMarginLeftToToolBar(_styleBarId);
			}

			_prevWindowSize = window.innerWidth;

			return isUpdateToToolBar;
		},

		/**
		 * MenuScrollInfo 를 돌려주는 함수
		 * @param {String} viewName		- 대상 menu 의 view 이름 (ex. menubar id 등)
		 * @returns {Object|null}
		 */
		getMenuScrollInfo: function (viewName) {
			return (viewName && _menuScrollInfo && _menuScrollInfo[viewName]) || null;
		},

		/** Msg dialog 에 값을 세팅해주는 함수
		 *
		 * @param {String} dialogName					- 띄울 Msg dialog 의 name. refTree 문서 참조
		 * @param {String} cmd							- 확인 버튼을 눌렀을 때, 어떠한 행동을 해야될지에 대한 command
		 * @param {String} title						- message box 의 제목
		 * @param {String} content						- message box 본문 내용
		 * @param {Boolean} needOpacity				- dialog 의 배경에 대한 opacity 를 불투명으로 선택하는지 아닌지.
		 * @param {String=} errorContent				- Stack trace 메세지
		 * @param {Boolean=} excludeProgressIcon		- msg dialog 의 progress icon 을 없앨지 말지.
		 * @param {String=} imgIcon					- msg dialog 중 alert/confirm type 이며
		 * 													excludeIcon 이 false 일 때, icon 종류를 결정.
		 * @returns {void}
		 */
		setValuesToMsgDialog: function(dialogName, cmd, title, content, needOpacity, errorContent, excludeProgressIcon, imgIcon) {
			var msgDialogInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.VIEW_MAP)[dialogName],
				dialogIconList = UiDefine.DIALOG_ICON_ARR,
				target, resultBtnList, titleEl, contentsEl, modalDialogEl, errorMsgAreaEl,
				parentEl, progressIconEl, infoIconEl, i, len;

			if (msgDialogInfo) {
				target = msgDialogInfo.ref;

				if (target) {
					// result button 초기화
					resultBtnList = UiFrameworkInfo.getWidgetArr("e_" + dialogName, "", "execute");

					if (resultBtnList && resultBtnList.length > 0) {
						len = resultBtnList.length;

						for (i = 0; i < len; ++i) {
							if (CommonFrameUtil.hasClass(resultBtnList[i], _hideViewClassName)) {
								CommonFrameUtil.removeClass(resultBtnList[i], _hideViewClassName);
							}
						}
					}

					titleEl = target && target.querySelector("." + UiDefine.PROPERTY_TITLE_CLASS);
					contentsEl = target && target.querySelector("." + UiDefine.MESSAGE_CLASS);
				}

				if (titleEl) {
					if (title != "") {
						if (UiUtil.isHidden(titleEl)) {
							CommonFrameUtil.removeClass(titleEl, _hideViewClassName);
						}

						titleEl.firstElementChild.textContent = "";
						UiUtil.insertTextToTarget(titleEl.firstElementChild, (title != null ? title : ""));
					} else {
						CommonFrameUtil.addClass(titleEl, _hideViewClassName);
					}
				}

				if (contentsEl) {
					contentsEl.textContent = "";
					UiUtil.insertTextToTarget(contentsEl, (content != null ? content : ""));
				}

				modalDialogEl = UiFrameworkInfo.getContainerNode(UiDefine.MODAL_DIALOG_ID);

				if (needOpacity) {
					UiUtil.addClassToTarget(modalDialogEl.ref, UiDefine.MODAL_ERROR_CLASS);
				} else {
					UiUtil.removeTargetClass(modalDialogEl.ref, UiDefine.MODAL_ERROR_CLASS);
				}

				errorMsgAreaEl = target && target.querySelector("." + UiDefine.ERROR_MSG_AREA_CLASS);

				if (errorMsgAreaEl) {
					if (errorContent) {
						UiUtil.removeTargetClass(errorMsgAreaEl, _hideViewClassName);
						FrameworkUtil.setTextareaText(errorMsgAreaEl, errorContent);
					} else {
						UiUtil.addClassToTarget(errorMsgAreaEl, _hideViewClassName);
					}
				}

				progressIconEl = target && target.querySelector(".img_loading");

				if (progressIconEl) {
					parentEl = progressIconEl.parentNode;

					if (excludeProgressIcon) {
						UiUtil.addClassToTarget(parentEl, _hideViewClassName);
					} else {
						UiUtil.removeTargetClass(parentEl, _hideViewClassName);
					}
				}

				infoIconEl = target && target.querySelector(".img_dialog_icon");

				if (infoIconEl) {
					parentEl = infoIconEl.parentNode;

					if (imgIcon) {
						CommonFrameUtil.removeClass(infoIconEl, dialogIconList.join(" "));

						if (imgIcon && dialogIconList.indexOf(imgIcon) !== -1) {
							CommonFrameUtil.addClass(infoIconEl, imgIcon);
							UiUtil.removeTargetClass(parentEl, _hideViewClassName);
						}
					} else {
						UiUtil.addClassToTarget(parentEl, _hideViewClassName);
					}
				}

				UiFrameworkInfo.setDialogCommandMap(dialogName, cmd);
			}
		},

		/**
		 * 단축키 가이드 다이얼로그에 단축키 정보를 랜더링 해주는 함수
		 * @param {Object} shortcutInfo		- 단축키 정보 Object
		 * @returns {void}
		 */
		setValuesToShortcutDialog : function (shortcutInfo) {
			var langDefine = window.LangDefine,
				shortcutObj = CommonFrameUtil.cloneObject(shortcutInfo),
				newFragment, dialogContainer, shortcutDlgInfo, shortcutTempInfo, eleShortcutTemp, eleShortcutPanel,
				orgTempTitle, eleTempTitle, eleTempTable, eleTempTbody, category, shortcutItem, shortcutItemInfo, desc,
				subDesc, orgTempDesc, newTempDesc, subShortcutItem;

			if (!shortcutObj || typeof shortcutObj !== "object") {
				return;
			}

			// reftree 를 통해 shortcut info template 정보를 찾는다.
			dialogContainer = UiFrameworkInfo.getRefTree()[UiDefine.MODAL_DIALOG_ID];
			shortcutDlgInfo = dialogContainer ? dialogContainer.dialog_shortcut_info : null;
			shortcutTempInfo = shortcutDlgInfo ? shortcutDlgInfo.shortcut_info : null;

			if (!shortcutTempInfo) {
				return;
			}

			// template 최상위와 다이얼로그 panel 최상위를 구한다.
			eleShortcutTemp = shortcutTempInfo.ref;
			eleShortcutPanel = eleShortcutTemp ? eleShortcutTemp.parentNode : null;
			newFragment = document.createDocumentFragment();

			if (!(eleShortcutTemp && eleShortcutPanel)) {
				return;
			}

			// weboffice.properties 정보에 따라 비활성화 단축키 정보는 제거한다.
			shortcutObj = this._resetShortcutInfoByServerProps(shortcutObj);

			// shortcut object 를 파싱해 DOM 으로 변경한다.
			for (category in shortcutObj) {
				if (shortcutObj.hasOwnProperty(category)) {
					shortcutItemInfo = shortcutObj[category];
					orgTempTitle = eleShortcutTemp.firstElementChild;
					eleTempTitle = orgTempTitle.cloneNode(true);
					eleTempTable = orgTempTitle.nextElementSibling.cloneNode(true);
					eleTempTbody = eleTempTable.getElementsByTagName("tbody")[0];
					orgTempDesc = eleTempTbody.getElementsByTagName("tr")[0];

					// 복잡도가 높은 loop 문 이므로, continue 구문을 사용한다.
					if (!(shortcutItemInfo && eleTempTitle && orgTempDesc)) {
						continue;
					}

					// shortcut title (분류) 를 할당한다.
					UiUtil.insertTextToTarget(eleTempTitle, langDefine[category] || category);

					// key 정보를 파싱하여 DOM 을 구성하고 값을 할당 한다.
					for (desc in shortcutItemInfo) {
						newTempDesc = null;

						if (shortcutItemInfo.hasOwnProperty(desc)) {
							shortcutItem = shortcutItemInfo[desc];

							if (CommonFrameUtil.isArray(shortcutItem)) {
								newTempDesc = this._makeShortcutInfoItem(orgTempDesc, desc, shortcutItem);

								if (newTempDesc) {
									eleTempTbody.appendChild(newTempDesc);
								}
							} else if (CommonFrameUtil.isObject(shortcutItem)) {
								/**
								 * 2 depth 단축키 정의 일때는 1 depth key 값인 description 은 보조 설명으로 처리한다.
								 * 단축키의 특성상 2 depth 까지만 지원한다.
								 */
								for (subDesc in shortcutItem) {
									newTempDesc = null;

									if (shortcutItem.hasOwnProperty(subDesc)) {
										subShortcutItem = shortcutItem[subDesc];

										if (CommonFrameUtil.isArray(subShortcutItem)) {
											newTempDesc = this._makeShortcutInfoItem(orgTempDesc, subDesc, subShortcutItem, desc);
										}

										if (newTempDesc) {
											eleTempTbody.appendChild(newTempDesc);
										}
									}
								}
							}
						}
					}

					// 파싱 및 DOM 변환이 완료 되었으면, 기존 Template DOM 은 제거하고 변환된 DOM 은 fragment 에 담는다.
					CommonFrameUtil.removeNode(orgTempDesc);

					// 변환된 DOM 이 있을때에만 fragment 에 담는다.
					if (eleTempTbody && eleTempTbody.firstElementChild) {
						newFragment.appendChild(eleTempTitle);
						newFragment.appendChild(eleTempTable);
					}
				}
			}

			// 최종 변환이 완료 되었으면, Template 로 사용한 DOM 은 제거하고 다이얼로그 panel 에 랜더링 한다.
			eleShortcutPanel.appendChild(newFragment);
			CommonFrameUtil.removeNode(eleShortcutTemp);
		},

		/**
		 * Msg dialog 에 지정된 command 를 반환하는 함수
		 *
		 * @param {String} dialogName				- Msg dialog 의 name
		 * @returns {String|Object|null}
		 */
		getMsgDialogCommand: function (dialogName) {
			var result = null;

			if (dialogName && UiDefine.MESSAGE_DIALOG_LIST.indexOf(dialogName) !== -1) {
				result = UiFrameworkInfo.getValueFromMsgDialogCmdMap("e_" + dialogName);
			}

			return result;
		},

		/** 협업 접속 인원에 따라 접속/미접속에 해당하는 DOM 을 표시해주는 함수
		 *
		 * @param {Number} count					- 접속한 유저 수
		 * @returns {void}
		 */
		setDisplayOtUserList: function (count) {
			var widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP),
				collaboUserElList = widgetMap[UiDefine.COLLABO_USERS_VIEW],
				noCollaboUserElList = widgetMap[UiDefine.NO_COLLABO_USERS_VIEW],
				editDesktopWidget = widgetMap[UiDefine.EVENT_ACTION_NAMES.E_DESKTOP_CONFIRM],
				targetList = noCollaboUserElList,
				enableTargetList = [],
				desktopLen, j, item, parentItem;

			var __showTarget = function (elList) {
				if (!CommonFrameUtil.isArray(elList)) {
					return;
				}

				var len = elList.length,
					i;

				for (i = 0; i < len; ++i) {
					if (CommonFrameUtil.hasClass(elList[i], _hideViewClassName)) {
						CommonFrameUtil.removeClass(elList[i], _hideViewClassName);
					}
				}
			};

			var __hideTarget = function (elList) {
				if (!CommonFrameUtil.isArray(elList)) {
					return;
				}

				var len = elList.length,
					i;

				for (i = 0; i < len; ++i) {
					if (!CommonFrameUtil.hasClass(elList[i], _hideViewClassName)) {
						CommonFrameUtil.addClass(elList[i], _hideViewClassName);
					}
				}
			};

			// [데스크탑 편집] 버튼이 있으면 시나리오에 따라 enable/disable 또는 show/hide 해준다.
			if (editDesktopWidget != null) {
				desktopLen = editDesktopWidget.length;

				for (j = 0; j < desktopLen; j++) {
					item = editDesktopWidget[j];
					parentItem = item.parentNode;

					if (parentItem
						&& CommonFrameUtil.hasClass(parentItem, "edit_desktop")
						&& parentItem.previousElementSibling
						&& CommonFrameUtil.hasClass(parentItem.previousElementSibling, "user_list")) {

						// type_a 스킨의 협업 리스트와 나란히 있는 [데스크탑 편집] 버튼은 시나리오 상 enable/disable 이 아닌 show/hide 해준다.
						targetList = targetList.concat(item);
					} else {
						// 그외 [데스크탑 편집] 버튼은 enable/disable 해준다.
						enableTargetList = enableTargetList.concat(item);
					}
				}
			}

			if (count == null || count < 2) {
				/** noCollaboUserEl이 hide 되어 있다면, show시켜준다.
				 * collaboUserEl 이 show 되어 있다면, hide 시켜준다.
				 * (단, 데스크탑에서 편집 widget 이 존재한다면,
				 * 데스크탑에서 편집 widget 도 같이 visible 시켜준다.)
				 **/
				__showTarget(targetList);
				__hideTarget(collaboUserElList);

				if (enableTargetList.length) {
					this._setEnableEditDesktop(enableTargetList);
				}
			} else {
				/** noCollaboUserEl 이 show 되어 있다면, hide 시켜준다.
				 * (단, 데스크탑에서 편집 widget 이 존재한다면,
				 * 데스크탑에서 편집 widget 도 같이 hide 시켜준다.)
				 **/
				__hideTarget(targetList);

				// target 에 값을 세팅한 후, collabUserEl 이 hide 되어 있다면, show 시켜준다.
				this._setTextToUserCount(collaboUserElList, count);
				__showTarget(collaboUserElList);

				if (enableTargetList.length) {
					this._setDisableEditDesktop(enableTargetList);
				}
			}
		},

		/**
		 * 모듈에서 필요한 callback 을 등록하는 함수
		 * - 현재는 dialog 에 대해서만 취급한다.
		 * @param {String} key		: key 값 (현재는 dialog 라는 key 만 허용한다.)
		 * @param {function} func			: function reference
		 */
		registerUiCallback: function (key, func) {
			if (_uiCallbackMap[key]) {
				_uiCallbackMap[key] = func;
			}
		},

		/**
		 * inputWrapWidget 에 value 를 세팅하는 함수.
		 * @param {Element} target				- InputWidget target
		 * @param {String} value				- value
		 */
		setValueToInput: function (target, value) {
			var inputEl;

			if (UiUtil.isTextInputWidget(target)) {
				inputEl = UiUtil.getInputElementByWidget(target);
				if (inputEl) {
					inputEl.value = value;
				}
			}
		},

		/**
		 * 지정한 폰트명의 글로벌 폰트명을 반환
		 * 예) 현재언어 : 한국어(ko), fontName : Gulim -> 굴림 반환)
		 * @param {String} fontName		- 폰트명
		 * @param {String=} langCode		- 반환할 글로벌 폰트의 언어코드를 강제로 지정 (예 => 한국어 : ko, 영어 : en)
		 * @returns {string}				- 글로벌 폰트명(등록된 글로벌 폰트명이 없이면 fontName 반환)
		 */
		getGlobalFontName : function (fontName, langCode) {
			var globalName = "";

			if (fontName && FontManager.getFontList()) {
				globalName = FontManager.getMatchedFontNameByLocale(fontName, langCode);
			}

			return globalName;
		},

		/**
		 * 지정한 폰트명이 사용가능한 폰트명인지 반환
		 * 예)
		 * @param {String} fontName		- 폰트명
		 * @returns {Boolean}				- 사용가능 여부
		 */
		isValidFontName: function(fontName) {
			var globalName,
				singleFontList;

			if (fontName && FontManager.getFontList()) {
				globalName = FontManager.getMatchedFontNameByLocale(fontName, null, true);
			}

			if (!globalName) {
				singleFontList = FontManager.getSingleFontList();

				if (singleFontList && singleFontList.indexOf(fontName) !== -1) {
					globalName = fontName;
				}
			}

			return !!globalName;
		},

		/**
		 * 마지막 layerMenu 를 기준으로 color picker 에 색상을 채우는 함수
		 * @param {String} theme				- 세팅 할 theme 값
		 * @param {Element=} target			- color picker 를 찾는 기준이 될 element
		 * @returns {void}
		 */
		setColorPickerOfTheme: function (theme, target) {
			var layerMenu = UiFrameworkInfo.getLayerMenu(),
				paletteColorClass = UiDefine.PALETTE_COLOR_CLASS,
				colorPickerThemeMap, paletteColorNodes,
				colorPickerEl, paletteColorNode, colorInput, orgColor, color, curTheme, len, i;

			if (theme && (CommonFrameUtil.hasClass(layerMenu, UiDefine.BTN_COMBO_ARROW_CLASS) || target)) {
				target = target || layerMenu;

				/**
				 * 마지막 layerMenu 를 기준으로 colorPicker element 를 찾는다.
				 * 현재 converting dom 구조상 color picker 의 경우
				 * layerMenu(arrow node) 의 다음 node 가 ui_color_picker 클래스를 가지는 것을 fix 하여 구현한다.
				 *
				 * (2018.01.18 by sebang)
				 */
				if (CommonFrameUtil.hasClass(target.nextElementSibling, _colorPickerClass)) {
					colorPickerEl = target.nextElementSibling;
				} else {
					colorPickerEl = CommonFrameUtil.findParentNode(target, "." + _colorPickerClass);
				}

				if (colorPickerEl) {
					curTheme = colorPickerEl.getAttribute(UiDefine.DATA_CURRENT_THEME) || _defineValue.DEFAULT;

					if (curTheme !== theme) {
						colorPickerThemeMap = _colorPickerThemeMap[theme] || _colorPickerThemeMap[_defineValue.DEFAULT];
						colorInput = colorPickerEl.querySelector("." + UiDefine.PREVIEW_COLOR_TEXT_CLASS);
						orgColor = colorInput && colorInput.getAttribute(UiDefine.DATA_ORIGIN_COLOR_VALUE) || "";
						colorPickerEl.setAttribute(UiDefine.DATA_CURRENT_THEME, theme);
						paletteColorNodes = colorPickerEl.querySelectorAll("." + paletteColorClass + ":not(.theme)");
						len = paletteColorNodes.length;

						for (i = 0; i < len; i++) {
							paletteColorNode = paletteColorNodes[i];
							color = colorPickerThemeMap[i];

							if (!color) {
								break;
							}

							paletteColorNode.setAttribute(_defineDataValueAttr, color);
							paletteColorNode.style.backgroundColor = color;

							if (UiUtil.isButtonOn(paletteColorNode)) {
								this._setButtonOff(paletteColorNode);
							}

							if (orgColor === color) {
								this._setButtonOn(paletteColorNode);
								this._pushToggleCommandButton(paletteColorNode.getAttribute(_dataCommand), paletteColorNode);
							}
						}
					}
				}
			}
		},

		/**
		 * Message bar 의 내용을 채워 보여주는 함수
		 * @param {String} msgValue			- message bar 에 표시할 메세지
		 * @param {String} type				- "error" 혹은 ""
		 * 										  해당 타입에 따라 배경색이 변경됨
		 * @param {Boolean} showRefreshBtn		- refresh 버튼을 보여줄 것인지 아닌지.
		 * @param {Boolean} showCloseBtn		- close 버튼을 보여줄 것인지 아닌지.
		 * @param {Boolean} showScreen			- 화면을 덮는 투명 screen 을 보여줄 것인지 아닌지.
		 * @param {Boolean} showProgress		- 프로그레스(뺑글이)를 보여줄 것인지 아닌지.
		 * @param {String=} mbUId				- message bar 고유 id. 해당 값이 들어오면
		 * 										  다시보지 않기 옵션 활성화
		 * @returns {void}
		 */
		showMsgBar: function (msgValue, type, showRefreshBtn, showCloseBtn, showScreen, showProgress, mbUId) {
			var msgBarEl = _msgBarElInfo.msgBarEl,
				elFragmentInfo, widgetMap, msgProgressArea, msgArea, refreshBtn, closeBtn, screenEl,
				uiState, dlaBoxEl, uniqueId, offlineStateNlsKeyArr, nlsStr, len, i;

			if (!msgBarEl) {
				elFragmentInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.EL_FRAGMENT_INFO);

				if (!elFragmentInfo) {
					return;
				}

				widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP);
				msgBarEl = widgetMap && widgetMap[_msgBarClass][0];

				if (!msgBarEl) {
					return;
				}

				// Msg bar 를 최초에 열 경우, DOM 을 캐싱하여 _msgBarElInfo 에 보관한다.
				_msgBarElInfo = this._initMsgBar(msgBarEl);
			}

			// Msg bar 를 열기 전에는 항상 초기값으로 reset 을 진행한다.
			this._resetMsgBar();

			if (mbUId) {
				UiFrameworkInfo.setMessageBarUId(mbUId);
				uiState = FrameworkUtil.getUiState(_uiCommandNames.DONT_LOOK_AGAIN);

				uniqueId = UiFrameworkInfo.getMessageBarUId();

				// 해당 unique id 가 local storage 에 저장되어 있다면, message bar 를 보여주지 않고
				// _mbUId 를 초기화한다. 만약 해당 아이디가 저장되어 있지 않다면,
				// 다시보지않기 영역을 visible 해준다.
				if (uiState && uiState.indexOf(uniqueId) !== -1) {
					uniqueId = "";
					UiFrameworkInfo.setMessageBarUId(uniqueId);
				} else {
					dlaBoxEl = _msgBarElInfo.dlaBoxEl;

					if (dlaBoxEl) {
						this._setVisible(dlaBoxEl);
					}
				}
			}

			// 아래 조건을 만족한다는 것은, 이미 다시보지않기를 체크한 id 로 또 showMsgBar 를
			// 호출했을 때이다. 따라서 이때에는 바로 리턴하도록 한다.
			if (mbUId && uniqueId === "") {
				return;
			}

			// message 가 있다면 적절한 위치에 세팅한다.
			if (msgValue) {
				msgArea = _msgBarElInfo.msgArea;

				if (msgArea) {
					this.uiUtil.insertTextToTarget(msgArea, msgValue);
				}

				if (!_offlineStateNlsArr) {
					_offlineStateNlsArr = [];
					offlineStateNlsKeyArr = UiDefine.OFFLINE_STATE_NLS_KEY_ARR;
					len = offlineStateNlsKeyArr.length;

					for (i = 0; i < len; i++) {
						nlsStr = window.LangDefine[offlineStateNlsKeyArr[i]];

						if (nlsStr) {
							_offlineStateNlsArr.push(nlsStr);
						}
					}
				}

				// Msg bar 에 오프라인 상태 메세지를 설정하는 경우, title bar 의 데스크탑 편집 버튼을 비활성화 시킨다.
				if (_offlineStateNlsArr.indexOf(msgValue) !== -1) {
					this._setDisableNetworkMenus();
				}
			}

			// error type 으로 넘어오면, 빨간 색 배경으로 표시하기 위한 class 를 넣어준다.
			if (type === UiDefine.MSG_ERROR_TYPE) {
				if (!CommonFrameUtil.hasClass(msgBarEl, UiDefine.MSG_ERROR_CLASS)) {
					CommonFrameUtil.addClass(msgBarEl, UiDefine.MSG_ERROR_CLASS);
				}
			}

			// 새로 고침 버튼을 showing 해야할 경우 visible 시켜준다.
			if (showRefreshBtn) {
				refreshBtn = _msgBarElInfo.refreshBtn;

				if (refreshBtn) {
					this._setVisible(refreshBtn);
				}
			}

			// 닫기 버튼을 showing 해야할 경우 visible 시켜준다.
			if (showCloseBtn) {
				closeBtn = _msgBarElInfo.closeBtn;

				if (closeBtn) {
					this._setVisible(closeBtn);
				}
			}

			// tool 영역에 있는 screen 을 showing 해야할 경우 visible 시켜준다.
			if (showScreen) {
				screenEl = _msgBarElInfo.screenEl;

				if (screenEl) {
					this._setVisible(screenEl);

					// screen 이 생겼다면, message bar 를 더 높게 띄우기 위해 screen_msg 클래스를 추가한다.
					CommonFrameUtil.addClass(msgBarEl, UiDefine.MSG_SCREEN_CLASS);
				}
			}

			// messageBar 의 progress 영역을 showing 해야할 경우 visible 시켜준다.
			if (showProgress) {
				msgProgressArea = _msgBarElInfo.msgProgressArea;

				if (msgProgressArea) {
					this._setVisible(msgProgressArea);
				}
			}

			// message bar 영역을 열기 전에 quick menu 가 show 되있으면 hide 시킨다.
			this.hideQuickMenu();

			// 모든 결정을 끝냈으면, message bar 영역을 visible 한다.
			this._setVisible(msgBarEl);
		},

		/**
		 * Message bar 를 감추는 함수
		 * @returns {void}
		 */
		hideMsgBar: function () {
			if (!_msgBarElInfo.msgBarEl) {
				return;
			}

			var screenEl = _msgBarElInfo.screenEl;

			// message bar 영역을 hide 시켜준다.
			this._setHidden(_msgBarElInfo.msgBarEl);

			// screen 영역이 hidden 이 아닐경우, hidden 시켜준다.
			if (screenEl && !UiUtil.isHidden(screenEl)) {
				this._setHidden(screenEl);
			}

			this._setEnableNetworkMenus();
		},

		/**
		 * 미지원 스펙 중, 강제 viewer 로 전환될 스펙이 포함되어 있는지 확인하는 함수
		 * @param {Array|String} unsupportedDataList		- 미지원 스펙 리스트
		 *
		 * @returns {Boolean} 강제 viewer 로 전환시킬 스펙이 포함되어 있으면 true, 아닐 경우 false
		 */
		containUnsupportedDataList: function (unsupportedDataList) {
			var isContained = false,
				moduleName = UiFrameworkInfo.getModuleName(),
				checkUnsupported, defineUnsupportedDatList, i, len;

			if (!unsupportedDataList) {
				return isContained;
			}

			if (typeof unsupportedDataList === "string" && CommonFrameUtil.isStartsWith(unsupportedDataList, "[")) {
				unsupportedDataList = JSON.parse(unsupportedDataList);
			}

			if (!CommonFrameUtil.isArray(unsupportedDataList)) {
				return isContained;
			}

			if (moduleName) {
				defineUnsupportedDatList = CommonDefine.UNSUPPORTED_DATA_LIST[moduleName];

				if (!defineUnsupportedDatList) {
					return isContained;
				}

				checkUnsupported = defineUnsupportedDatList.concat(CommonDefine.UNSUPPORTED_DATA_LIST.common);
				len = unsupportedDataList.length;

				for (i = 0; i < len; ++i) {
					if (checkUnsupported.indexOf(unsupportedDataList[i]) !== -1) {
						isContained = true;
						_unsupportedDataList.push(unsupportedDataList[i]);
					}
				}
			}

			return isContained;
		},

		/**
		 * 미지원 스펙 리스트를 포함한 안내 메세지를 돌려주는 함수
		 *
		 */
		setUnsupportedDataMessage: function () {
			var msg = "",
				langDefine = window.LangDefine,
				openFailMsg = langDefine.OpenFailNotSupportedDataMessage,
				len = _unsupportedDataList.length,
				i, unsupportedDataRes, resultMsg, msgDialogInfo, dialogEl, contentsEl;

			for (i = 0; i < len; ++i) {
				unsupportedDataRes = langDefine["UnsupportedProp" + _unsupportedDataList[i]];

				if (unsupportedDataRes) {
					msg = msg ? (msg + ", " + unsupportedDataRes) : unsupportedDataRes;
				}
			}

			if (msg) {
				msg = "(" + msg + ")";
			}

			resultMsg = CommonFrameUtil.substitute(openFailMsg, {UnsupportedProps: msg});

			// 결과가 바뀌었다면, ${...} 내용이 교체되었음을 의미한다.
			// 이럴 경우에만 dialog_viewer 를 찾아 해당 내용을 교체시켜준다.
			if (resultMsg !== openFailMsg) {
				msgDialogInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.VIEW_MAP)[_eventActionNames.U_DIALOG_VIEWER];

				dialogEl = msgDialogInfo && msgDialogInfo.ref;

				if (dialogEl) {
					contentsEl = dialogEl && dialogEl.querySelector("." + UiDefine.MESSAGE_CLASS);

					if (contentsEl) {
						contentsEl.textContent = "";
						UiUtil.insertTextToTarget(contentsEl, resultMsg);
					}
				}
			}

			// 임시 저장해뒀던 미지원 스펙 목록 초기화
			_unsupportedDataList = [];
		},

		/**
		 * container 내 target 을 기준으로 스크롤 위치를 변경하는 함수
		 *
		 * @param {Element} target				- focus 된 target element
		 * @returns {Boolean}
		 */
		moveToScrollOfContainer: function(target) {
			var containerInfo = target && UiUtil.findContainerInfoToParent(target),
				containerNode = containerInfo && containerInfo.container,
				containerId = containerNode && containerNode.id,
				sNode, sNodeOffsetHeight, sNodeScrollTop,
				targetOffsetTop, targetOffsetHeight, margin, offsetTemp;

			if (!containerId) {
				return false;
			}

			// titleBar, styleBar, menuBar 인 경우
			if (_toolBarContainers.indexOf(containerId) !== -1) {
				this._updateToolBarScrollIfNeeded(target);
			}
			else {
				// contextMenu 인 경우
				if (containerId === UiDefine.CONTEXT_MENU_ID) {
					sNode = containerNode;
				}
				// 그 외 containerNode 인 경우
				else {
					sNode = containerInfo && containerInfo.topNode;

					// dialog 의 경우
					if (UiUtil.isDialogContainer(containerId)) {
						sNode = sNode.querySelector("." + UiDefine.DIALOG_V_SCROLL_CLASS);
					}
				}

				if (CommonFrameUtil.hasScroll(sNode, _topStr)) {
					targetOffsetTop = CommonFrameUtil.getOffsetTop(target, sNode);
					targetOffsetHeight = CommonFrameUtil.getOffsetHeight(target);
					sNodeOffsetHeight = CommonFrameUtil.getOffsetHeight(sNode);
					sNodeScrollTop = sNode.scrollTop;
					margin = 10;
					offsetTemp = targetOffsetTop + targetOffsetHeight - sNodeOffsetHeight;

					if (sNodeScrollTop < offsetTemp) {
						sNode.scrollTop = offsetTemp + margin;
					} else if (targetOffsetTop < sNodeScrollTop) {
						sNode.scrollTop = targetOffsetTop - margin;
					}
				}
			}
		},

		hideEditDesktop: function () {
			var widgetMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP),
				widgetList, len, i, containerInfo;

			// Error dialog 에 "데스크탑에서 편집" 버튼이 있다면 모듈 로딩 후 감춰준다.
			if (!_isAutoProgressOn && widgetMap && widgetMap[_eventActionNames.E_DESKTOP_EXECUTE]) {
				widgetList = widgetMap[_eventActionNames.E_DESKTOP_EXECUTE];
				len = widgetList.length;

				for (i = 0; i < len; ++i) {
					containerInfo = UiUtil.findContainerInfoToParent(widgetList[i]);

					if (containerInfo && containerInfo.container.id === UiDefine.MODAL_DIALOG_ID &&
						CommonFrameUtil.hasClass(containerInfo.topNode, "dialog_error")) {
						this._setHidden(widgetList[i]);

						break;
					}
				}
			}
		},

		/**
		 * 지정한 Widget 에 포커스를 해제하는 함수 (FocusWidgetInfo 삭제, 물리적 Focus Blur)
		 * @param {Boolean=} cancelChange			- true 시, 입력된 값 취소 (원래값으로 되돌아가도록 지정)
		 */
		removeWidgetFocus: function (cancelChange) {
			var curFocusTarget = UiController.getFocusWidgetInfo().curWidgetEl;

			if (curFocusTarget) {
				if (cancelChange) {
					this.removeFocusWidgetInfo(true);
				}

				if (UiUtil.isBrowserFocusUsedWidget(curFocusTarget)) {
					curFocusTarget.blur();
				}

				if (!cancelChange) {
					this.removeFocusWidgetInfo();
				}
			}
		},

		/**
		 * 지정한 Widget 에 포커스를 설정하는 함수 (FocusWidgetInfo 등록, 물리적 Focus 설정)
		 * @param {Element} newFocusTarget			- 포커스 대상 Widget Element
		 */
		setWidgetFocus: function (newFocusTarget) {
			if (!newFocusTarget) {
				return;
			}

			this.removeWidgetFocus();
			this.setFocusWidgetInfo(newFocusTarget);

			if (newFocusTarget && UiUtil.isBrowserFocusUsedWidget(newFocusTarget)) {
				newFocusTarget.focus();
			}
		},

		/**
		 * focus widget Object 정보를 돌려주는 함수
		 * @return {Object}
		 */
		getFocusWidgetInfo: function () {
			return UiFrameworkInfo.getFocusWidgetInfo();
		},

		/**
		 * focus widget 정보를 세팅 하는 함수
		 * @param {Element} target				- 대상 target widget
		 * @return {void}
		 */
		setFocusWidgetInfo: function (target) {
			var topLayerMenu = UiFrameworkInfo.getLayerMenuOn()[0],
				layerWidget = topLayerMenu && topLayerMenu.parentNode,
				activeDlg = null,
				topNode;

			UiFrameworkInfo.setFocusWidgetInfo(target);

			if (UiFrameworkInfo.getDialogShowing().viewNode) {
				// 현재 focus 들어가는 input 이 dialog 내부의 input 이면, 해당 dialog 를 activeDialog 로 처리
				topNode = UiUtil.findContainerInfoToParent(target).topNode;
				if (CommonFrameUtil.hasClass(topNode, UiDefine.DIALOG_WRAP_CLASS)) {
					activeDlg = topNode;
				}
			}
			UiFrameworkInfo.setActivatedDialog(activeDlg);

			if (this.isInput(target) && layerWidget && UiFrameworkInfo.getFocusWidgetInfo().curWidgetWrapEl !== layerWidget
				&& !UiUtil.findLayerNodeToParent(target)) {
				this.closeLayerMenu();
			}

			FrameworkUtil.clearArrowKeyHover(true);
			this.moveToScrollOfContainer(target);
		},

		/**
		 * 현재 focus widget 정보를 초기화 하는 함수
		 * @param {Boolean=} cancelChange			- true 시, 입력된 값 취소 (원래값으로 되돌아가도록 지정)
		 * @return {void}
		 */
		removeFocusWidgetInfo: function(cancelChange) {
			var listMenu = UiFrameworkInfo.getDropdownBoxList();

			UiFrameworkInfo.removeFocusWidgetInfo(cancelChange);

			/**
			 * focusablePanel 및 listBox 의 경우,
			 * focus widget 정보를 초기화시에 방향키 이동도 초기화되어야 하므로 arrowKeyHover 정보를 clear 한다.
			 */
			if (listMenu && (UiUtil.isListBox(listMenu) || UiUtil.isFocusablePanel(listMenu))) {
				FrameworkUtil.clearArrowKeyHover(true);
			}
		},

		/**
		 * target 이 focusWidget 일 때 disable 혹은 hidden 이면 focusWidget 정보를 초기화하는 함수
		 * @param {Element} target				- 대상 target
		 * @returns {void}
		 */
		initFocusWidgetInfoIfDisabledHidden: function(target) {
			if (!target || !(UiUtil.isDisabled(target) || UiUtil.isHidden(target))) {
				return;
			}

			var focusWidgetEl = this.getFocusWidgetInfo().curWidgetEl;

			if (focusWidgetEl && focusWidgetEl === target) {
				this.removeFocusWidgetInfo();
			}
		},

		/**
		 * dialog 의 active 상태를 세팅하는 함수
		 *
		 * @param {Element=} viewNode
		 * @return {void}
		 */
		setActivatedDialog: function (viewNode) {
			UiFrameworkInfo.setActivatedDialog(viewNode);
		},

		/**
		 * Active 된 dialog 를 돌려주는 함수
		 *
		 * @returns {Element|null}
		 */
		getActivatedDialog: function () {
			return UiFrameworkInfo.getActivatedDialog();
		},

		/**
		 * ui 상태를 저장하는 함수
		 *
		 * @param {String} viewName
		 * @param {String|Number|Boolean|Object} value
		 * @returns {void}
		 */
		saveUiState: function (viewName, value) {
			FrameworkUtil.saveUiState(viewName, value);
		},

		/**
		 * ui 상태를 local storage 에서 꺼내오는 함수
		 *
		 * @param {String} viewName
		 * @returns {String|Number|Boolean}
		 */
		getUiState: function (viewName) {
			return FrameworkUtil.getUiState(viewName);
		},

		/**
		 * 현재 Ui Menu 가 Focus 받고 있는지 돌려주는 함수
		 * @return {Boolean}
		 */
		isUiMenuFocus: function() {
			var onMenu = UiFrameworkInfo.getLayerMenu() || UiFrameworkInfo.getActivatedDialog()
				|| UiFrameworkInfo.getFocusWidgetInfo().curWidgetEl;

			return !!onMenu;
		},

		/**
		 * UI Button element 의 xml 상 name 정보를 돌려주는 함수
		 * @param {Element} buttonEl		- 대상 ui button widget
		 * @return {String} uiButtonName (찾지 못한 경우 "")
		 */
		getUiButtonName: function(buttonEl) {
			var btnName = "",
				btnIdx;

			if (!buttonEl || !_uiCmdBtnInfo) {
				return btnName;
			}

			btnIdx = _uiCmdBtnInfo.buttonArr.indexOf(buttonEl);

			if (btnIdx > -1) {
				btnName = _uiCmdBtnInfo.nameArr[btnIdx];
			}

			return btnName;
		},

		/**
		 * color picker 에서 선택된 색상을 세팅하는 함수
		 * @param {Element} target					- 대상 target
		 * @param {Object} posInfo					- color picker 에서 선택된 좌표 ({x : (number), y : (number)})
		 * @param {Boolean=} isUpdateColorInfo		- color info 의 갱신 여부
		 * @return {Object}							- {result: (Boolean) 수행 여부, spectrumArea: (String) "matrix", "spectrum"}
		 */
		selectSpectrumColor: function(target, posInfo, isUpdateColorInfo) {
			var containerInfo = UiUtil.findContainerInfoToParent(target),
				layerNode = containerInfo && containerInfo.layerNode,
				colorPickerEl = CommonFrameUtil.findParentNode(target, "." + UiDefine.COLOR_SPECTRUM_PICKER_CLASS
																+ ", ." + UiDefine.COLOR_MATRIX_PICKER_CLASS, layerNode),
				colorPickerContentEl, previewColorInputEl, offsetTarget, posX, posY, hexCode, inputHsv,
				hsv, orgH, orgS, orgV, h, s, v, spectrumArea;

			function _resultValue(result, spectrumArea) {
				return {
					result: result,
					spectrumArea: spectrumArea || ""
				};
			}

			if (!target || !(posInfo && !CommonFrameUtil.isEmptyObject(posInfo)) || !colorPickerEl) {
				return _resultValue(false);
			}

			colorPickerContentEl = layerNode && layerNode.querySelector("." + UiDefine.SPECTRUM_COLOR_CONTENT_CLASS);
			previewColorInputEl = colorPickerContentEl && colorPickerContentEl.querySelector(
				"." + UiDefine.PREVIEW_COLOR_TEXT_CLASS + "> input");
			hexCode = previewColorInputEl && previewColorInputEl.value;
			hsv = UiUtil.getCurHsvColor(colorPickerContentEl);

			if (!hsv) {
				hsv = CommonFrameUtil.getHexToHsv(hexCode);
			}

			if (hsv != null && typeof hsv === "object") {
				orgH = hsv.h;
				orgS = hsv.s;
				orgV = hsv.v;
			}

			if (isNaN(orgH) || isNaN(orgS) || isNaN(orgV)) {
				return _resultValue(false);
			}

			posX = 0;
			posY = 0;
			offsetTarget = colorPickerEl;

			while (offsetTarget) {
				posX += (offsetTarget.offsetLeft - offsetTarget.scrollLeft + offsetTarget.clientLeft);
				posY += (offsetTarget.offsetTop - offsetTarget.scrollTop + offsetTarget.clientTop);
				offsetTarget = offsetTarget.offsetParent;
			}

			posX = posInfo.x - posX;
			posY = posInfo.y - posY;

			if (CommonFrameUtil.hasClass(colorPickerEl, UiDefine.COLOR_SPECTRUM_PICKER_CLASS)) {
				// spectrum color picker 인 경우
				h = UiUtil.getHueFromColorSpectrum(colorPickerEl, posX);
				s = orgS;
				v = orgV;

				UiUtil.setSpectrumColorPicker(h, colorPickerContentEl, colorPickerEl);
				spectrumArea = "spectrum";
			} else {
				// matrix color picker 인 경우
				h = orgH;
				s = UiUtil.getSaturationFromColorMatrix(colorPickerEl, posX);
				v = UiUtil.getValueBrightnessFromColorMatrix(colorPickerEl, posY);

				UiUtil.setMatrixColorPicker(h, s, v, colorPickerContentEl, colorPickerEl);
				spectrumArea = "matrix";

				/**
				 * color input 의 hue 색상 값과 기록된 hue 색상 값을 비교하여
				 * 다른 경우 컬러피커 스펙트럼 바 영역도 갱신 한다.
				 */
				inputHsv = CommonFrameUtil.getHexToHsv(hexCode);
				if (inputHsv && inputHsv.h !== h) {
					UiUtil.setSpectrumColorPicker(h, colorPickerContentEl);
				}
			}

			UiUtil.setCurHsvColor(colorPickerContentEl, h, s, v);
			hexCode = CommonFrameUtil.getHsvToHex(h, s, v);

			if (isUpdateColorInfo) {
				// 색상 정보 갱신
				UiUtil.setColorInformation(colorPickerContentEl, hexCode);
			}

			return _resultValue(true, spectrumArea);
		},

		/**
		 * color picker position 의 위치를 조정하는 함수
		 *
		 * @param {Object} eventObj				- event object
		 * @param {Object} orgMoveInfo			- move info 정보
		 * @returns {Object} {top,left} 		- 실제 증가량
		 */
		moveColorPickerPos: function(eventObj, orgMoveInfo) {
			var listMenu = UiFrameworkInfo.getDropdownBoxList(),
				isColorPicker = CommonFrameUtil.hasClass(listMenu, UiDefine.COLOR_PICKER_CLASS),
				moveInfo = {
					top: 0,
					left: 0
				},
				target, orgX, orgY, addLeft, addTop, curTop, curLeft, styleProp, top, left,
				marginTop, marginLeft, pointerClass, pointerEl, pickerEl, pickerClass, pickerWidth, pickerHeight,
				spectrumArea, isMatrixPicker, isSpectrumPicker, isValid;

			if (orgMoveInfo && eventObj) {
				target = orgMoveInfo.target;
				orgX = orgMoveInfo.x;
				orgY = orgMoveInfo.y;
				addLeft = eventObj.clientX - orgX;
				addTop = eventObj.clientY - orgY;
				spectrumArea = orgMoveInfo.spectrumArea;

				isValid = CommonFrameUtil.isNumber(orgX) && CommonFrameUtil.isNumber(orgY)
						&& CommonFrameUtil.isNumber(addLeft) && CommonFrameUtil.isNumber(addTop);
			}

			if (target && isColorPicker && isValid) {
				isMatrixPicker = (spectrumArea === "matrix");
				isSpectrumPicker = (spectrumArea === "spectrum");

				if (isMatrixPicker || isSpectrumPicker) {
					if (isMatrixPicker) {
						pickerClass = UiDefine.COLOR_MATRIX_PICKER_CLASS;
						pointerClass = UiDefine.COLOR_MATRIX_POINTER_CLASS;
					} else {
						pickerClass = UiDefine.COLOR_SPECTRUM_PICKER_CLASS;
						pointerClass = UiDefine.COLOR_SPECTRUM_POINTER_CLASS;
					}

					pickerEl = listMenu.querySelector("." + pickerClass);
					pointerEl = listMenu.querySelector("." + pointerClass);
					styleProp = pointerEl.style;

					// top 위치 조정
					if (isMatrixPicker && addTop !== 0) {
						pickerHeight = parseInt(pickerEl.style.height || 0, 10);
						curTop = parseInt(styleProp.top || 0, 10);
						marginTop = parseInt(styleProp.marginTop || 0, 10);
						top = curTop + addTop;

						if (top + marginTop > pickerHeight) {
							top = pickerHeight;
						} else if (top + marginTop < 0) {
							top = 0;
						}

						if (curTop !== top) {
							styleProp.top = top + _pxStr;
							moveInfo.top = top - curTop;
						}
					}

					// left 위치 조정
					if (addLeft !== 0) {
						pickerWidth = parseInt(pickerEl.style.width || 0, 10);
						curLeft = parseInt(styleProp.left || 0, 10);
						marginLeft = parseInt(styleProp.marginLeft || 0, 10);
						left = curLeft + addLeft;

						if (left + marginLeft > pickerWidth) {
							left = pickerWidth;
						} else if (left + marginLeft < 0) {
							left = marginLeft * -1;
						}

						if (curLeft !== left) {
							styleProp.left = left + _pxStr;
							moveInfo.left = left - curLeft;
						}
					}

					// color picker 색상 세팅
					this.selectSpectrumColor(target, {x: moveInfo.left + orgX, y: moveInfo.top + orgY}, true);
				}
			}

			return moveInfo;
		},

		/**
		 * Spectrum Color Picker 내 컬러코드 입력 input box 에 default value 로 설정한다.
		 *
		 * @param {Element} layerNode				- 대상 layerNode (없는 경우 commandEl 지정 필요)
		 * @returns {Boolean}						- 수행 여부
		 */
		setDefaultValueToSpectrumColor: function (layerNode) {
			var result = false;

			if (!(layerNode && CommonFrameUtil.hasClass(layerNode, UiDefine.COLOR_PICKER_CLASS))) {
				return result;
			}

			var commandEl = layerNode.querySelector("." + UiDefine.PREVIEW_COLOR_TEXT_CLASS),
				colorValue, cmdName, confirmBtn;

			if (commandEl) {
				// dropdown 이 열려있는 동안 confirm 버튼에 지정한 값 삭제
				confirmBtn = layerNode.querySelector("." + UiDefine.SPECTRUM_COLOR_CONFIRM_CLASS);
				if (confirmBtn) {
					confirmBtn.removeAttribute(_defineDataValueAttr);
				}

				// origin color value 로 복원
				cmdName = commandEl.getAttribute(_dataCommand);
				colorValue = commandEl.getAttribute(UiDefine.DATA_ORIGIN_COLOR_VALUE) || "";

				if (cmdName && colorValue != null) {
					FrameworkUtil.setInputText(
						UiUtil.getInputElementByWidget(commandEl), colorValue, null, null, cmdName);
				}

				result = true;
			}

			return result;
		},

		/**
		 * EventAction Object 생성 전, command element 가 colorPicker Layer 가 떠있는 경우 layer 를 닫는다.
		 *
		 * 해당 함수는 click 이벤트가 발생했을 때 호출되며, command 를 수행하는 target 이 있을 때만 체크한다.
		 * 웹워드의 iframe input 의 경우 함수 호출 이전 또는 이후에 닫히기 때문에 이 함수 내에서는 고려하지 않아도 된다.
		 *
		 * @param {Element} commandElement
		 * @returns {Boolean}					- close layer 수행 여부
		 */
		checkCloseColorPickerLayerByExecuteWidget: function (commandElement) {
			var result = false,
				layerMenu;

			if (!commandElement || UiUtil.isUiCommandButton(commandElement)) {
				return result;
			}

			layerMenu = UiFrameworkInfo.getDropdownBoxList();

			if (layerMenu && CommonFrameUtil.hasClass(layerMenu, UiDefine.DROPDOWN_COLOR_PICKER_WRAP_CLASS)
				&& !UiUtil.isShowParentLayer(commandElement)) {
				UiController.closeLayerMenu();
				result = true;
			}

			return result;
		},

		/**
		 * 현재 selectAllInfo 에 맞게 selectAll checkBox 의 값 상태 갱신
		 * - 대상이 없는 경우 : 기본값 상태 처리 및 비활성화
		 * - 대상이 모두 체크 : 체크처리
		 * - 이외의 경우 : 체크 해제처리
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @returns {void}
		 */
		updateSelectAllInfo: function (commandName, commandItemIndex) {
			var curSelectAllInfo = UiFrameworkInfo.getSelectAllInfo(commandName, commandItemIndex),
				isEmptySelectAllTarget = false,
				isDisabled, selectedAllInput, selectAllInputWrap, unCheckedLen;

			if (curSelectAllInfo) {
				unCheckedLen = curSelectAllInfo.unCheckedArr.length;
				selectedAllInput = curSelectAllInfo.selectAllInput;

				if (unCheckedLen > 0) {
					selectedAllInput.checked = false;

				} else {
					if (curSelectAllInfo.checkedArr.length) {
						selectedAllInput.checked = true;

					} else {
						selectedAllInput.checked = UiDefine.SELECT_ALL_DEFAULT_VALUE;
						isEmptySelectAllTarget = true;
					}
				}

				selectAllInputWrap = UiUtil.getInputWrapWidgetByInput(selectedAllInput);
				isDisabled = UiUtil.isDisabled(selectAllInputWrap);

				if (isEmptySelectAllTarget) {
					if (!isDisabled) {
						this._setDisable(selectAllInputWrap);
					}

				} else {
					if (isDisabled) {
						this._setEnable(selectAllInputWrap);
					}
				}
			}
		},

		/**
		 * target 에 bindWidget 으로 정의한 command 와 valueKey, widget 정보를 반환.
		 *
		 * @returns {Object|null}
		 */
		getBindWidgetInfo: function () {
			var result = null,
				dialogShowingInfo = UiFrameworkInfo.getDialogShowing(),
				firedWidget, bindWidgetValue, widgetNameToValueKeyMap, cmdName, valueKey,
				widget, containerInfo, containerNode, findNode;

			if (dialogShowingInfo) {
				firedWidget = dialogShowingInfo.firedWidget;
				bindWidgetValue = firedWidget && firedWidget.getAttribute(UiDefine.DATA_BIND_WIDGET_ATTR);

				if (bindWidgetValue) {
					widgetNameToValueKeyMap = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_NAME_TO_VALUE_KEY_MAP);
					valueKey = widgetNameToValueKeyMap[bindWidgetValue];
					cmdName = bindWidgetValue.slice(0, -1 * (valueKey.length + 1));

					containerInfo = UiUtil.findContainerInfoToParent(firedWidget);
					containerNode = containerInfo.container;
					findNode = UiUtil.isDialogContainer(containerNode.id) ? containerInfo.topNode : containerNode;

					widget = findNode.querySelector("[" + _dataCommand + "=" + cmdName + "]" +
						"[" + _defineDataValueKeyAttr + "=" + valueKey + "]");

					result = {
						command: cmdName,
						valueKey: valueKey,
						widget: widget
					};
				}
			}

			return result;
		}
	}, UiUtil);

	// UiController.uiUtil 로 접근 가능하도록 추가 지정
	UiController.uiUtil.isValidFontName = UiController.isValidFontName;

	return UiController;
});
