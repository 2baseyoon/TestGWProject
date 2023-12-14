define(function (require) {
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var CommonFrameUtil = require("commonFrameJs/utils/util"),
		UiDefine = require("commonFrameJs/uiFramework/uiDefine"),
		UiUtil = require("commonFrameJs/uiFramework/uiUtil");

	var _hideViewClassName = UiDefine.HIDE_VIEW_CLASS,
		_arrowkeysHoverWidgetSelector = UiDefine.FIND_WIDGET_SELECTOR_FOR_HOVER.join(","),
		_allDirMovableBoxSelector = UiDefine.FIND_ALL_DIR_MOVABLE_BOX_FOR_HOVER.join(","),
		_movableBoxSelector = UiDefine.FIND_MOVABLE_BOX_FOR_HOVER.join(","),
		_frameworkInfo = {},
		_refTree = {},
		_dialogShowing = {},
		_dropdownListInfo = {},
		_mouseMoveInfo = null,
		_moduleName, _skinName, _langDefine, _contentWindow, _msgDialogCommandMap, _layerMenuOn,
		_focusWidgetInfo, _mbUId, _activatedDialog, _selectAllInfo;

	return {
		UNIT_INFO: "unitInfo",
		DROPDOWN_MATCH: "dropdownMatch",
		COMBO_NO_USED_STATE: "comboNoUsedState",
		TOOLTIP_LAYER_ON: "tooltipLayerOn",
		TOGGLE_BUTTONS_ON: "toggleButtonsOn",
		WRAP_NODE: "wrapNode",
		BASE_DIR: "baseDir",
		XML_LIST: "xmlList",
		UPDATE_DESC_WIDGET_MAP: "updateDescWidgetMap",
		SAMPLE_ITEM_MOVE_MAP: "sampleItemMoveMap",
		COMMANDS_WIDGET_IDX_MAP: "commandsWidgetIdxMap",
		COMMANDS_WIDGET_MAP: "commandsWidgetMap",
		UI_WIDGET_MAP: "uiWidgetMap",
		VIEW_MAP: "viewMap",
		WIDGET_MAP: "widgetMap",
		EL_FRAGMENT_INFO: "elFragmentInfo",
		WIDGET_NAME_TO_VALUE_KEY_MAP: "widgetNameToValueKeyMap",
		COMMAND_TO_VALUE_KEY_ARR_MAP: "commandToValueKeyArrMap",
		MOUSE_DOWN_TARGET: "mouseDownTarget",
		TITLE_BAR_MENU_OVER: "titleBarMenuOver",
		LAZY_CONVERT_XML_INFO: "lazyConvertXmlInfo",
		UI_SERVER_PROPS_MAP: "uiServerPropsMap",
		TOOL_DATA: "toolData",

		/**
		 * uiFrameworkInfo 초기화
		 */
		initialize: function() {
			_moduleName = "";
			_skinName = "";
			_refTree = null;
			_layerMenuOn = [];
			_langDefine = "";
			_contentWindow = null;
			_dialogShowing = {
				"viewNode": null,
				"value": "",
				"firedWidget": null,
				"firedWidgetName": "",
				"beforeDialogNames": []
			};
			_focusWidgetInfo = {
				"curWidgetEl": null,		// 실제 focus 되는 target (ex. input, button ..)
				"curWidgetWrapEl": null,	// focus 될 대상 widget
				"widgetElObj": {},			// focus 가능한 element 들의 container 별 element list
				"orgInputValue": null		// focus 되는 target 의 기존 value
			};
			_msgDialogCommandMap = {
				"e_dialog_alert" : "",
				"e_dialog_error" : "",
				"e_dialog_confirm" : "",
				"e_dialog_print" : "",
				"e_dialog_download" : "",
				"e_dialog_rename" : "",
				"e_dialog_message_box" : ""
			};
			_frameworkInfo.unitInfo = {};
			_frameworkInfo.dropdownMatch = {};
			_frameworkInfo.comboNoUsedState = {};
			_frameworkInfo.tooltipLayerOn = {};
			_frameworkInfo.toggleButtonsOn = {};
			_frameworkInfo.wrapNode = null;
			_frameworkInfo.baseDir = null;
			_frameworkInfo.xmlList = null;
			_frameworkInfo.updateDescWidgetMap = null;
			_frameworkInfo.sampleItemMoveMap = {};
			_frameworkInfo.commandsWidgetIdxMap = null;
			_frameworkInfo.commandsWidgetMap = null;
			_frameworkInfo.uiWidgetMap = null;
			_frameworkInfo.viewMap = null;
			_frameworkInfo.widgetMap = null;
			_frameworkInfo.elFragmentInfo = null;
			_frameworkInfo.widgetNameToValueKeyMap = null;
			_frameworkInfo.commandToValueKeyArrMap = null;
			_frameworkInfo.titleBarMenuOver = null;
			_frameworkInfo.lazyConvertXmlInfo = {};
			_frameworkInfo.uiServerPropsMap = {};
			_frameworkInfo.toolData = {};
			_mbUId = "";
			_activatedDialog = null;
			_selectAllInfo = {};
		},

		setInfo: function(name, value) {
			if (_frameworkInfo[name] !== undefined) {
				_frameworkInfo[name] = value;
			}
		},

		getInfo: function(name) {
			return _frameworkInfo[name];
		},

		/**
		 * 현재 moduleName 지정
		 * @param {String} moduleName
		 */
		setModuleName: function(moduleName) {
			_moduleName = moduleName;
		},

		/**
		 * Module Name 을 반환
		 * @returns {String}
		 */
		getModuleName: function() {
			return _moduleName;
		},

		/**
		 * 현재 skinName 지정
		 * @param {String} skinName
		 */
		setSkinName: function(skinName) {
			_skinName = skinName;
		},

		/**
		 * skinName 을 반환
		 * @returns {String}
		 */
		getSkinName: function() {
			return _skinName;
		},

		/**
		 * 현재 refTree 지정
		 * @param {Object} refTree
		 */
		setRefTree: function(refTree) {
			_refTree = refTree || {};
		},

		/**
		 * refTree 를 반환
		 * @returns {Object}
		 */
		getRefTree: function() {
			return _refTree;
		},

		/**
		 * langDefine 지정
		 *  @param {String} langDefine
		 */
		setLangDefine: function(langDefine) {
			_langDefine = langDefine;
		},

		/**
		 * langDefine 를 반환
		 * @returns {String}
		 */
		getLangDefine: function() {
			return _langDefine;
		},

		/**
		 * 현재 contentWindow 지정
		 * @param {Window} contentWindow
		 */
		setContentWindow: function(contentWindow) {
			_contentWindow = contentWindow;
		},

		/**
		 * contentWindow 를 반환 (지정하지 않은경우 window)
		 * @returns {Window}
		 */
		getContentWindow: function() {
			return _contentWindow || window;
		},

		/**
		 * 컨테이너 Node 를 반환
		 * @returns {Element}
		 */
		getContainerNode: function(containerID) {
			var containerInfo = (_refTree && _refTree[containerID]) || null;

			return (containerInfo && containerInfo.ref) || null;
		},

		/**
		 * 컨텍스트 메뉴를 반환
		 * @returns {Element}
		 */
		getContextMenu: function() {
			return this.getContainerNode(UiDefine.CONTEXT_MENU_ID);
		},

		/**
		 * 현재 on 되어있는 레이어 메뉴 리스트를 반환
		 * @returns {Array}
		 */
		getLayerMenuOn: function() {
			return _layerMenuOn;
		},

		/**
		 * 현재 on 되어있는 레이어 메뉴 리스트에 추가
		 * @param {Element} layerMenuOn		추가할 레이어 메뉴
		 */
		addLayerMenuOn: function(layerMenuOn) {
			if (_layerMenuOn.indexOf(layerMenuOn) === -1) {
				_layerMenuOn.push(layerMenuOn);
			}
		},

		/**
		 * 현재 on 되어있는 레이어 메뉴 리스트에서 지정한 개수만큼 삭제
		 * @param {Number=} removeLength		삭제할 개수 (미지정시, 전체삭제)
		 * @returns {Array}					삭제된 리스트
		 */
		removeLayerMenuOn: function(removeLength) {
			if (removeLength === undefined) {
				removeLength = _layerMenuOn.length;
			}

			return _layerMenuOn.splice(_layerMenuOn.length - removeLength);
		},

		/**
		 * 현재 열려있는 레이어 메뉴를 반환한다.
		 * @param {Boolean=} isExcludeContextMenu		- contextMenu 제외 여부 (기본값 : false)
		 * @returns {Element}
		 */
		getLayerMenu: function(isExcludeContextMenu) {
			var layerMenu = this.getLayerMenuOn(),
				target = layerMenu[layerMenu.length - 1],
				contextMenu;

			if (!target && !isExcludeContextMenu) {
				contextMenu = this.getContextMenu();
				if (contextMenu && !CommonFrameUtil.hasClass(contextMenu, _hideViewClassName)) {
					target = contextMenu;
				}
			}

			return target;
		},

		/**
		 * 이번 dialog showing 으로 인해 (Dialog 1개로 제한 구현상태)
		 * 닫히는 beforeDialogName 을 추가로 기록하는 함수
		 * @param {String} beforeDialogName	- 현재 showing 때문에 닫혀진 dialog 의 name
		 */
		addBeforeDialogName: function (beforeDialogName) {
			var beforeDlgNames, beforeDlgIdx;

			if (beforeDialogName) {
				beforeDlgNames = _dialogShowing.beforeDialogNames;
				beforeDlgIdx = beforeDlgNames.indexOf(beforeDialogName);

				if (beforeDlgIdx !== -1) {
					// 중복 push 방지
					beforeDlgNames.splice(beforeDlgIdx, 1);
				}

				beforeDlgNames.push(beforeDialogName);
			}
		},

		/**
		 * 자동으로 닫힌 dialog name 들 정보 삭제
		 * @param {String=} beforeDialogName	- 특정 dialog name 만 삭제하는 경우 지정 (미지정시 모두 삭제)
		 */
		removeBeforeDialogName: function (beforeDialogName) {
			var beforeDlgNames = _dialogShowing.beforeDialogNames,
				beforeDlgIdx;

			if (beforeDlgNames.length > 0) {
				if (beforeDialogName) {
					// 특정 dialogName 만 삭제
					beforeDlgIdx = beforeDlgNames.indexOf(beforeDialogName);
					if (beforeDlgIdx !== -1) {
						beforeDlgNames.splice(beforeDlgIdx, 1);
					}
				} else {
					// 모든 dialogName 삭제
					beforeDlgNames.splice(0);
				}
			}
		},

		/**
		 * 현재 화면에 보여지는 dialog 의 정보를 세팅하는 함수
		 * @param {Element=} viewNode			- dialog Element (기본값 : null)
		 * @param {String=} value				- dialog name (기본값 : "")
		 * @param {Element=} firedWidget		- dialog 를 발생시킨 widget (기본값 : null)
		 * @param {String=} firedWidgetName		- dialog 를 발생시킨 widget name (기본값 : "")
		 * @param {String=} beforeDialogName	- 현재 showing 때문에 닫혀진 dialog 의 name
		 */
		setDialogShowing: function (viewNode, value, firedWidget, firedWidgetName, beforeDialogName) {
			_dialogShowing.viewNode = viewNode || null;
			_dialogShowing.value = value || "";
			_dialogShowing.firedWidget = firedWidget || null;
			_dialogShowing.firedWidgetName = firedWidgetName || "";

			// 전에 열려있던(저장된) dialog 를 showing 하는 경우 beforeDialogNames 에서 삭제
			if (value) {
				this.removeBeforeDialogName(value);
			}
			// 이번 dialog 로 인해 닫히는 beforeDialogName 은 추가 기록
			this.addBeforeDialogName(beforeDialogName);
		},

		/**
		 * 현재 화면에 보여지는 dialog 의 정보를 반환하는 함수
		 * @returns {Object}
		 */
		getDialogShowing: function () {
			return _dialogShowing;
		},

		/**
		 * 현재 활성화된 dialog 를 세팅하는 함수
		 * @param {Element=} viewNode			- dialog Element (기본값 : null)
		 */
		setActivatedDialog: function (viewNode) {
			_activatedDialog = viewNode || null;
		},

		/**
		 * 현재 활성화된 dialog 를 반환하는 함수
		 * @returns {Element} viewNode			- dialog Element
		 */
		getActivatedDialog: function () {
			return _activatedDialog;
		},

		/**
		 * focus widget 정보를 세팅 하는 함수
		 * @param {Element} target				- 대상 target widget
		 * @return {void}
		 */
		setFocusWidgetInfo: function (target) {
			if (!target || UiUtil.isDisabled(target)) {
				return;
			}

			var targetWrapEl = target;

			if (UiUtil.isInput(target)) {
				targetWrapEl = UiUtil.getInputWrapWidgetByInput(target);

				// input combo 의 경우
				if (targetWrapEl.nodeName === "A") {
					targetWrapEl = UiUtil.findComboElementToParent(targetWrapEl);
				}
			}

			// focus 형태를 그려주는 대상은 widget 의 wrap element 을 기준으로 한다.
			CommonFrameUtil.removeClass(_focusWidgetInfo.curWidgetWrapEl, UiDefine.WIDGET_FOCUS);
			CommonFrameUtil.addClass(targetWrapEl, UiDefine.WIDGET_FOCUS);
			_focusWidgetInfo.curWidgetWrapEl = targetWrapEl;
			_focusWidgetInfo.curWidgetEl = target;

			if (target.nodeName === "INPUT" && target.getAttribute("type") === "text") {
				_focusWidgetInfo.orgInputValue = target.value;
			} else {
				_focusWidgetInfo.orgInputValue = null;
			}
		},

		/**
		 * focus widget Object 정보를 돌려주는 함수
		 * @return {Object}
		 */
		getFocusWidgetInfo: function () {
			return _focusWidgetInfo;
		},

		/**
		 * 현재 focus widget 정보를 초기화 하는 함수
		 * @param {Boolean=} cancelChange			- true 시, 입력된 값 취소 (원래값으로 되돌아가도록 지정)
		 * @return {void}
		 */
		removeFocusWidgetInfo: function (cancelChange) {
			var curWidgetEl = _focusWidgetInfo.curWidgetEl,
				onlyEnterCommands, commandName, orgVal;

			if (curWidgetEl && curWidgetEl.nodeName === "INPUT" && curWidgetEl.getAttribute("type") === "text") {
				if (!cancelChange) {
					commandName = UiUtil.getInputWrapWidgetByInput(curWidgetEl).getAttribute(UiDefine.DATA_COMMAND);
					onlyEnterCommands = UiDefine.NOT_EXECUTED_BY_CHANGE_INPUT_LIST[this.getModuleName()];

					if (commandName && onlyEnterCommands && onlyEnterCommands.indexOf(commandName) !== -1) {
						// enter 로만 실행해야 하는 command 라면 blur 때 원래 값으로 돌아가도록 처리
						cancelChange = true;
					}
				}

				if (cancelChange) {
					orgVal = _focusWidgetInfo.orgInputValue;

					if (orgVal != null) {
						curWidgetEl.value = orgVal;
					}
				}
			}

			CommonFrameUtil.removeClass(_focusWidgetInfo.curWidgetWrapEl, UiDefine.WIDGET_FOCUS);
			_focusWidgetInfo.curWidgetWrapEl = null;
			_focusWidgetInfo.curWidgetEl = null;
			_focusWidgetInfo.orgInputValue = null;
		},

		/**
		 * focus widget elements object 정보를 세팅 하는 함수
		 * @param {Object} widgetElObj				- container 별 대상 focus widget 의 elements 배열 object 정보
		 * @return {void}
		 */
		setFocusWidgetElObjInfo: function (widgetElObj) {
			_focusWidgetInfo.widgetElObj = widgetElObj;
		},

		/** dialogCommandMap 에 값 지정 (dialog 에 해당하는 command 지정하는 map)
		 * @param {String} dialogName
		 * @param {String} command			- dialog 의 data-command
		 * @returns {String|Object}
		 */
		setDialogCommandMap: function(dialogName, command) {
			_msgDialogCommandMap["e_" + dialogName] = command;
		},

		/** Msg dialog cmd map (command name 에 해당하는 에 세팅된 값을 돌려주는 함수
		 * @param {String} command			- 찾고 싶은 dialog 의 data-command
		 * @returns {String|null}
		 */
		getValueFromMsgDialogCmdMap: function (command) {
			if (_msgDialogCommandMap && _msgDialogCommandMap[command] != null) {
				return _msgDialogCommandMap[command];
			}

			return null;
		},

		/**
		 * Dropdown 의 match 값을 지정하는 함수
		 * @param {String} widgetName	- widget 구분 name (UiUtil.getWidgetName() 의 return 값)
		 * @param {String} matchValue
		 */
		setDropdownMatch: function(widgetName, matchValue) {
			if (!(widgetName && CommonFrameUtil.isString(matchValue))) {
				return;
			}

			var dropdownMatch = this.getInfo(this.DROPDOWN_MATCH);

			if (dropdownMatch) {
				dropdownMatch[widgetName] = matchValue;
			}
		},

		/**
		 * Dropdown 의 match 값을 돌려주는 함수
		 * @param {String} widgetName	- widget 구분 name (UiUtil.getWidgetName() 의 return 값)
		 * @returns {String}
		 */
		getDropdownMatch: function(widgetName) {
			var dropdownMatch = this.getInfo(this.DROPDOWN_MATCH),
				match = dropdownMatch && dropdownMatch[widgetName];

			return (match == null) ? null : match;
		},

		/**
		 * Dropdown 이나 Input 의 단위(ex. pt, px 등)을 지정하는 함수
		 * @param {String} widgetName	- widget 구분 name (UiUtil.getWidgetName() 의 return 값)
		 * @param {String} unit		- 단위
		 */
		setUnitInfo: function(widgetName, unit) {
			if (!(widgetName && CommonFrameUtil.isString(unit))) {
				return;
			}

			var unitInfo = this.getInfo(this.UNIT_INFO);

			if (unitInfo) {
				unitInfo[widgetName] = unit;
			}
		},

		/**
		 * Dropdown 이나 Input 의 단위(ex. pt, px 등)을 돌려주는 함수
		 * @param {String} widgetName	- widget 구분 name (UiUtil.getWidgetName() 의 return 값)
		 * @returns {String}
		 */
		getUnitInfo: function(widgetName) {
			var unitInfo = this.getInfo(this.UNIT_INFO),
				unit = unitInfo && unitInfo[widgetName];

			return (unit == null) ? null : unit;
		},

		/**
		 * 드롭다운 리스트의 인덱스 정보를 업데이트한다.
		 * @param {Number=} index					index 값
		 * @param {(Element|Node)=} currentEl		현재 hover 된 대상 Element (index 미지정시 필수 지정)
		 */
		setDropdownListIndex: function (index, currentEl) {
			var indexVal = index || _dropdownListInfo.index;

			if (currentEl && _dropdownListInfo.listData) {
				indexVal = _dropdownListInfo.listData.indexOf(currentEl);
			}

			if (indexVal !== _dropdownListInfo.index) {
				_dropdownListInfo.index = indexVal;
			}
		},

		/**
		 * 현재 열려 있는 레이어를 기준으로 상위 list box를 반환
		 * @returns {Element|Node}
		 */
		getDropdownBoxList: function () {
			var listMenu, layer;

			if (_dropdownListInfo && _dropdownListInfo.listBox) {
				listMenu = _dropdownListInfo.listBox;
			} else {
				layer = this.getLayerMenu();
				if (layer) {
					if (UiUtil.isContainerView(layer) || CommonFrameUtil.hasClass(layer, UiDefine.TOOL_FILTER_DIALOG)) {
						listMenu = layer;

						if (CommonFrameUtil.hasClass(layer, UiDefine.TITLE_BAR_ID)) {
							listMenu = layer.querySelector("." + UiDefine.TITLE_PANEL_WRAP_CLASS +
								".on ." + UiDefine.BOX_ELEMENT_CLASS);
						}

						listMenu = listMenu.querySelector("." + UiDefine.SUB_GROUP_BOX_ELEMENT_CLASS +
								"." + UiDefine.ARROWKEY_HOVER_CLASS) || listMenu;
					} else {
						listMenu = layer.nextElementSibling;
					}
				}
			}

			return listMenu;
		},

		/**
		 * 드롭다운 리스트 정보를 세팅한다.
		 * @param {Element|Node} listBox			드롭다운 리스트 박스
		 * @param {Number} index					현재 index
		 * @param {Number=} parentIndex				상위 index
		 * @param {Boolean=} isKeyPressed			key가 눌렸는지 여부
		 * @return {Object}
		 */
		initDropdownListInfo: function (listBox, index, parentIndex, isKeyPressed) {
			if (!listBox) {
				return {};
			}

			var containerInfo = UiUtil.findContainerInfoToParent(listBox),
				container = containerInfo.container,
				listArray = CommonFrameUtil.getCollectionToArray(listBox.querySelectorAll(_arrowkeysHoverWidgetSelector)),
				isSubGroup = CommonFrameUtil.hasClass(listBox, UiDefine.SUB_GROUP_BOX_ELEMENT_CLASS),
				isTabGroup = CommonFrameUtil.hasClass(listBox, UiDefine.TAB_GROUP_CLASS);

			_dropdownListInfo = {
				listBox: listBox,
				isCustomStyle: !!(CommonFrameUtil.findParentNode(listBox, _allDirMovableBoxSelector, container)),
				isSubGroup: isSubGroup,
				isTabGroup: isTabGroup,
				container: container,
				isKeyPressed: isKeyPressed,
				index: index,
				parentIndex: parentIndex,
				hoverWidgetList: document.getElementsByClassName(UiDefine.ARROWKEY_HOVER_CLASS),
				listData: listArray.filter(function (node) {
					var hideView = CommonFrameUtil.findParentNode(node, "." + _hideViewClassName, container),
						colorPickerTabWrap = CommonFrameUtil.findParentNode(node, "[class*='content']", listBox.firstElementChild),
						isDisplayNone = CommonFrameUtil.getCurrentStyle(colorPickerTabWrap, "display") === "none",
						subGroupBox = (CommonFrameUtil.findParentNode(node, _movableBoxSelector, container) || container) === listBox,
						isCheckboxOfToolBox = (container && container.id === UiDefine.TOOL_BOX_ID) && UiUtil.isCheckboxWidget(node);

					return !hideView && !isDisplayNone && !isCheckboxOfToolBox && subGroupBox;
				})
			};

			return _dropdownListInfo;
		},

		/**
		 * 드롭다운 리스트 정보를 세팅한다.
		 * @returns {Object}
		 */
		setDropdownListInfo : function (dropdownListInfo) {
			_dropdownListInfo = dropdownListInfo;
		},

		/**
		 * 드롭다운 리스트 정보를 반환한다.
		 * @returns {Object}
		 */
		getDropdownListInfo : function () {
			return _dropdownListInfo;
		},

		/**
		 * target element 가 COMMANDS_WIDGET_MAP 에서 갖는 index return
		 * @param {String} command
		 * @param {Element} target
		 * @return {Number}
		 */
		getCommandItemIndex: function(command, target) {
			if (!(command && target)) {
				return -1;
			}

			var valueKeyCmdWidgetArr = this.getInfo(this.COMMANDS_WIDGET_MAP)[command],
				valueKeyIdxArr = this.getInfo(this.COMMANDS_WIDGET_IDX_MAP)[command],
				valueKeyCmdItemIdx, parentWidgetEl;

			// 현재 commandItem 내의 value 값 종합
			if (valueKeyCmdWidgetArr && valueKeyIdxArr) {
				// "commandsWidgetMap" array 와 mapping 되는 commandsWidgetIdxMap 에서 commandItem Idx 구함
				valueKeyCmdItemIdx = valueKeyIdxArr[valueKeyCmdWidgetArr.indexOf(target)];
				if (valueKeyCmdItemIdx == null) {
					// 해당하는 dom index 없으면, 상위 widget 찾아서 구함
					parentWidgetEl = UiUtil.findCommandWrapToParent(target.parentNode);
					if (parentWidgetEl) {
						valueKeyCmdItemIdx = valueKeyIdxArr[valueKeyCmdWidgetArr.indexOf(parentWidgetEl)];
					}
				}
			}

			return valueKeyCmdItemIdx || -1;
		},

		/**
		 * target element 가 COMMANDS_WIDGET_MAP 에서 갖는 index return
		 * @param {String} cmdName
		 * @param {String=} value
		 * @param {String=} valueKey
		 * @param {Node=} target			특정 widget 에 한정
		 * @param {Object=} widgetMap		기본 widgetMap 외의 경우 지정 (미지정시 기본 widgetMap)
		 * @param {String=} uiCommand		특정 ui command 에 한정
		 * @return {Array}
		 */
		getWidgetArr: function(cmdName, value, valueKey, target, widgetMap, uiCommand) {
			var widgetName = UiUtil.getWidgetName(cmdName, valueKey),
				widgetArr = [],
				inCmdWidget, commandItemIdx, refTree,
				valueKeyCmdWidgetArr, valueKeyIdxArr, len, i, curWidget, tempWidgetArr, dataUiCommand;

			if (UiDefine.USE_DISABLE_CONTAINER_ID_LIST.indexOf(widgetName) !== -1) {
				// disable 가능한 container 인 경우
				refTree = this.getRefTree();
				if (refTree && refTree[widgetName]) {
					widgetArr[0] = refTree[widgetName].ref;
				}

			} else {
				// name panel or widget
				widgetMap = widgetMap || this.getInfo(this.WIDGET_MAP);
				if (widgetMap) {
					value = value || "";
					widgetArr = widgetMap[widgetName] || widgetArr;
				}

				if (widgetArr.length === 0 && valueKey !== UiDefine.SAMPLE_WRAP_POST_FIX) {
					// widget 을 찾지 못한 경우, sample_wrap 이 있다면 해당 wrap 반환
					tempWidgetArr = this.getWidgetArr(cmdName, value, UiDefine.SAMPLE_WRAP_POST_FIX, target, widgetMap);
					len = tempWidgetArr.length;

					for (i = 0; i < len; i++) {
						if (UiUtil.isSampleWrap(tempWidgetArr[i])) {
							widgetArr.push(tempWidgetArr[i]);
						}
					}
				}

				if (target) {
					inCmdWidget = [];
					commandItemIdx = this.getCommandItemIndex(cmdName, target);
					if (commandItemIdx != null) {
						valueKeyCmdWidgetArr = this.getInfo(this.COMMANDS_WIDGET_MAP)[cmdName];
						valueKeyIdxArr = this.getInfo(this.COMMANDS_WIDGET_IDX_MAP)[cmdName];

						len = widgetArr.length;
						for (i = 0; i < len; i++) {
							curWidget = widgetArr[i];
							if (valueKeyIdxArr[valueKeyCmdWidgetArr.indexOf(curWidget)] === commandItemIdx) {
								// 현재 commandItem 내의 widget 만
								inCmdWidget[inCmdWidget.length] = curWidget;
							}
						}
					}

					widgetArr = inCmdWidget;
				}

				if (uiCommand) {
					len = widgetArr.length;

					if (len > 0) {
						inCmdWidget = [];

						for (i = 0; i < len; i++) {
							curWidget = widgetArr[i];
							dataUiCommand = curWidget.getAttribute(UiDefine.DATA_UI_COMMAND);

							if (!dataUiCommand || dataUiCommand === uiCommand) {
								inCmdWidget[inCmdWidget.length] = curWidget;
							}
						}

						widgetArr = inCmdWidget;
					}
				}
			}

			return widgetArr;
		},

		/**
		 * 특정 command 내 widget 으로부터 result button 구함.
		 * @param {Element} target		- widget element
		 * @returns {Element}
		 */
		getResultButtonElementByWidget: function(target) {
			if (!target) {
				return null;
			}

			var cmdName = UiUtil.getEventActionCommand(target),
				cmdEl, resultBtnArr, result, resultLen, i;

			if (!cmdName) {
				/**
				 * dropdown widget 의 경우 command name 이 해당 widget 에 있지 않고
				 * 하위에 있는 data 가 갖는 경우가 있으므로 하위에서 command name 을 찾는다.
				 */
				cmdEl = target.querySelector("[" + UiDefine.DATA_COMMAND + "]");
				cmdName = (cmdEl && cmdEl.getAttribute(UiDefine.DATA_COMMAND)) || "";
			}

			resultBtnArr = cmdName ? this.getWidgetArr(cmdName, "", "execute", target) : [];
			result = (resultBtnArr && resultBtnArr[0]) || "";

			/**
			 * default execute button 은 기본적으로 result button 의 첫번째 버튼을 반환한다.
			 * 그러나, 찾기/바꾸기 다이얼로그의 경우 "찾기" 와 "바꾸기" 의 두가지 result button 이 있기 때문에
			 * "바꾸기" 를 수행해야하는 widget 의 경우는 임시적으로 구분하여 처리한다.
			 */
			if (result && UiUtil.getValueKey(target) === "replace_input") {
				resultLen = resultBtnArr.length;
				i = 0;

				while (i < resultLen && result.getAttribute(UiDefine.DATA_VALUE) !== "replace") {
					result = resultBtnArr[i++];
				}

				result = result || resultBtnArr[0];
			}

			return result || null;
		},

		/** Message bar 다시보지않기 관련한 고유한 id 를 세팅하는 함수
		 * @param {String} mbUId				- unique id
		 * @return {void}
		 */
		setMessageBarUId: function (mbUId) {
			_mbUId = mbUId;
		},

		/**
		 * Message bar 다시보지않기 관련한 고유한 id 를 돌려주는 함수
		 * @return {String}
		 */
		getMessageBarUId: function () {
			return _mbUId;
		},

		/**
		 * 마우스 move 정보를 세팅하는 함수
		 * @param {Object} moveInfo     - mouse move 관련 정보
		 */
		setMouseMoveInfo: function(moveInfo) {
			_mouseMoveInfo = moveInfo;
		},

		/**
		 * 마우스 move 정보를 돌려주는 함수
		 */
		getMouseMoveInfo: function() {
			return _mouseMoveInfo;
		},

		/**
		 * selectAllInfo 초기화 함수
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @return {Object}
		 */
		initSelectAllInfo: function(commandName, commandItemIndex) {
			var curSelectAllInfo = {
				selectAllInput: null, // el
				checkedArr: [], // valueKey Arr...
				unCheckedArr: [], // valueKey Arr...
				checkBoxInputs: {} // valueKey: [el], ...
			};

			_selectAllInfo[commandName + "_" + commandItemIndex] = curSelectAllInfo;

			return curSelectAllInfo;
		},

		/**
		 * selectAllInfo 에서 관리대상인 selectAll Target 인지 여부 확인
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @param {String} valueKey
		 * @return {Boolean}
		 */
		isSelectAllTarget: function(commandName, commandItemIndex, valueKey) {
			var curSelectAllInfo = this.getSelectAllInfo(commandName, commandItemIndex);

			return !!(curSelectAllInfo && curSelectAllInfo.checkBoxInputs[valueKey]);
		},

		/**
		 * selectAllInfo 에서 관리대상인 command 인지 여부 확인
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @return {Boolean}
		 */
		isSelectAllCommand: function(commandName, commandItemIndex) {
			return !!(this.getSelectAllInfo(commandName, commandItemIndex));
		},

		/**
		 * commandName, commandItemIndex 에 해당하는 selectAllInfo 반환
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @return {Object}
		 */
		getSelectAllInfo: function(commandName, commandItemIndex) {
			return _selectAllInfo[commandName + "_" + commandItemIndex];
		},

		/**
		 * selectAllInfo 중 selectAll widget 관련 정보 지정
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @param {Element=} selectAllInput
		 * @return {void}
		 */
		setSelectAllWidgetInfo: function(commandName, commandItemIndex, selectAllInput) {
			var curSelectAllInfo = this.getSelectAllInfo(commandName, commandItemIndex)
				|| this.initSelectAllInfo(commandName, commandItemIndex);

			if (selectAllInput) {
				curSelectAllInfo.selectAllInput = selectAllInput;
			}
		},

		/**
		 * selectAllInfo 의 checkBoxTarget 의 값 변경 정보 갱신
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @param {String=} valueKey				- 미지정시 모든 checkBoxTarget 을 대상으로 함
		 * 											  미지정한 경우 isChecked 는 값 지정 필요
		 * @param {Boolean=} isChecked				- true: checked, false: unChecked (미지정시 현재값 사용)
		 * @return {Boolean} 해당 동작 수행 여부
		 */
		setSelectState: function(commandName, commandItemIndex, valueKey, isChecked) {
			var curSelectAllInfo = this.getSelectAllInfo(commandName, commandItemIndex),
				result = false,
				targetArr, checkArr, idx, targetInput;

			if (curSelectAllInfo && (!valueKey || curSelectAllInfo.checkBoxInputs[valueKey])) {
				// 모두 대상으로 하거나, 대상으로 지정한 valueKey 가 checkBoxInputs (target) 에 포함되는 경우
				if (valueKey && isChecked == null) {
					// valueKey 는 지정됐지만, isChecked 값을 지정하지 않은 경우 현재 값 사용 (둘다 미지정시 수행 불가)
					targetInput = curSelectAllInfo.checkBoxInputs[valueKey][0];
					isChecked = targetInput ? targetInput.checked : null;
				}

				if (isChecked != null) {
					if (isChecked === true) {
						targetArr = curSelectAllInfo.checkedArr;
						checkArr = curSelectAllInfo.unCheckedArr;
					} else {
						targetArr = curSelectAllInfo.unCheckedArr;
						checkArr = curSelectAllInfo.checkedArr;
					}

					if (valueKey) {
						idx = checkArr.indexOf(valueKey);

						if (idx !== -1) {
							// 현재 반대상태 array 에 있어야하고, 제거
							if (idx !== -1) {
								checkArr.splice(idx, 1);
							}

							if (targetArr.indexOf(valueKey) === -1) {
								// 중복삽입 방지
								targetArr[targetArr.length] = valueKey;
							}

							result = true;
						}

					} else {
						// 모두 선택 또는 모두 선택해제
						while (checkArr.length > 0) {
							targetArr[targetArr.length] = checkArr.shift();
						}

						result = true;
					}
				}
			}

			return result;
		},

		/**
		 * selectAllInfo 의 checkBoxTarget 을 visible 상태로 변경
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @param {String=} valueKey				- 미지정시 모든 checkBoxTarget 을 대상으로 함
		 * @return {Boolean} 해당 동작 수행 여부
		 */
		setVisibleSelectAllTarget: function(commandName, commandItemIndex, valueKey) {
			var curSelectAllInfo = this.getSelectAllInfo(commandName, commandItemIndex),
				result = false,
				checkBoxInputs, valueKeyArr, len, uncheckedArr, i;

			if (curSelectAllInfo) {
				checkBoxInputs = curSelectAllInfo.checkBoxInputs;
				uncheckedArr = curSelectAllInfo.unCheckedArr;

				if (valueKey) {
					if (checkBoxInputs[valueKey]) {
						valueKeyArr = [valueKey];
						result = true;
					}

				} else {
					// 전체 지정한 경우
					valueKeyArr = Object.keys(checkBoxInputs);
					result = true;
				}

				if (valueKeyArr) {
					len = valueKeyArr.length;

					for (i = 0; i < len; i++) {
						valueKey = valueKeyArr[i];
						if (uncheckedArr.indexOf(valueKey) === -1) {
							// 중복삽입 방지
							uncheckedArr[uncheckedArr.length] = valueKey;
						}
						this.setSelectState(commandName, commandItemIndex, valueKey);
					}
				}
			}

			return result;
		},

		/**
		 * selectAllInfo 의 checkBoxTarget 을 hidden 상태로 변경
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @param {String=} valueKey				- 미지정시 모든 checkBoxTarget 을 대상으로 함
		 * @return {Boolean} 해당 동작 수행 여부
		 */
		setHiddenSelectAllTarget: function(commandName, commandItemIndex, valueKey) {
			var curSelectAllInfo = this.getSelectAllInfo(commandName, commandItemIndex),
				result = false,
				targetArr, idx;

			if (curSelectAllInfo) {
				if (!valueKey) {
					curSelectAllInfo.checkedArr.splice(0);
					curSelectAllInfo.unCheckedArr.splice(0);

				} else if (curSelectAllInfo.checkBoxInputs[valueKey]) {
					targetArr = curSelectAllInfo.checkedArr;
					idx = targetArr.indexOf(valueKey);

					if (idx === -1) {
						targetArr = curSelectAllInfo.unCheckedArr;
						idx = targetArr.indexOf(valueKey);
					}

					if (idx !== -1) {
						targetArr.splice(idx, 1);
						result = true;
					}
				}
			}

			return result;
		},

		/**
		 * selectAllInfo 의 selectAllTarget 을 추가
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @param {Element} checkInput
		 * @param {String} valueKey
		 * @param {Boolean=} isChecked				- true: checked, false: unChecked (미지정시 checkInput 으로부터 구함)
		 * @return {void}
		 */
		pushSelectAllTarget: function(commandName, commandItemIndex, checkInput, valueKey, isChecked) {
			var curSelectAllInfo = this.getSelectAllInfo(commandName, commandItemIndex)
				|| this.initSelectAllInfo(commandName, commandItemIndex),
				targetCheckBoxArr = curSelectAllInfo.checkBoxInputs[valueKey];

			if (!targetCheckBoxArr) {
				targetCheckBoxArr = [];
				curSelectAllInfo.checkBoxInputs[valueKey] = targetCheckBoxArr;
			}
			targetCheckBoxArr[targetCheckBoxArr.length] = checkInput;

			this.setVisibleSelectAllTarget(commandName, commandItemIndex, valueKey);

			if (isChecked != null) {
				this.setSelectState(commandName, commandItemIndex, valueKey, isChecked);
			}
		},

		/**
		 * selectAllInfo 에서 selectAllTarget 을 삭제
		 * @param {String} commandName
		 * @param {Number} commandItemIndex
		 * @param {String=} valueKey			- 미지정시 모든 checkBoxTarget 을 대상으로 함
		 * @return {Boolean} 해당 동작 수행 여부
		 */
		removeSelectAllTarget: function(commandName, commandItemIndex, valueKey) {
			var curSelectAllInfo = this.getSelectAllInfo(commandName, commandItemIndex),
				result = false,
				targetKeyArr, len, i;

			if (curSelectAllInfo) {
				targetKeyArr = valueKey ? [valueKey] : Object.keys(curSelectAllInfo.checkBoxInputs);
				len = targetKeyArr.length;

				this.setHiddenSelectAllTarget(commandName, commandItemIndex, valueKey);

				for (i = 0; i < len; i++) {
					delete curSelectAllInfo.checkBoxInputs[targetKeyArr[i]];
				}

				result = true;
			}

			return result;
		}
	};
});