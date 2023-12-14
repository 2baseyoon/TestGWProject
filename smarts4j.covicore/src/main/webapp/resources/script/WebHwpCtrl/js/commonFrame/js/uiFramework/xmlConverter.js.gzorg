define(function (require) {
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var $ = require("jquery"),
		CommonFrameUtil = require("commonFrameJs/utils/util"),
		UiDefine = require("commonFrameJs/uiFramework/uiDefine"),
		TemplateDefine = require("commonFrameJs/uiFramework/templateDefine"),
		ColorConverter = require("commonFrameJs/uiFramework/colorConverter"),
		UiFrameworkInfo  = require("commonFrameJs/uiFramework/uiFrameworkInfo"),
		FrameworkUtil  = require("commonFrameJs/uiFramework/frameworkUtil"),
		UiRequester = require("commonFrameJs/uiFramework/uiRequester"),
		UiReferrer = require("commonFrameJs/uiFramework/uiReferrer"),
		UiUtil = require("commonFrameJs/uiFramework/uiUtil");

	/*******************************************************************************
	 * Private Variables
	 ******************************************************************************/

	var _convertXmlToDomHandler = {},
		_xmlAttrToClassCommon = UiDefine.XmlAttrToClassCommon,
		_xmlAttrToClass = UiDefine.XmlAttrToClass,
		_viewControlClass = UiDefine.VIEW_CONTROL_CLASS,
		_buttonClass = UiDefine.BUTTON_CLASS,
		_functionButtonsClass = UiDefine.FUNCTION_BUTTONS_CLASS,
		_onLinkClass = UiDefine.ON_LINK_CLASS,
		_hideForceClass = UiDefine.HIDE_FORCE_CLASS,
		_hideViewClass = UiDefine.HIDE_VIEW_CLASS,
		_foldViewClassName = UiDefine.FOLD_VIEW_CLASS,
		_templateGroupClass = UiDefine.TEMPLATE_GROUP_CLASS,
		_dataNlsName = UiDefine.DATA_NLS_NAME_ATTR,
		_dataTemplateName = UiDefine.DATA_TEMPLATE_NAME,
		_dataTemplateAreaType = UiDefine.DATA_AREA_TYPE,
		_dataTemplateGroupItem = UiDefine.DATA_TEMPLATE_GROUP_ITEM,
		_dataTitle = UiDefine.DATA_TITLE_ATTR,
		_dataPlaceHolder = UiDefine.DATA_PLACEHOLDER_ATTR,
		_dataUnit = UiDefine.DATA_UNIT_ATTR,
		_dataName = UiDefine.DATA_NAME,
		_dataValue = UiDefine.DATA_VALUE,
		_dataValueKey = UiDefine.DATA_VALUE_KEY,
		_dataUiCommand = UiDefine.DATA_UI_COMMAND,
		_dataUiValue = UiDefine.DATA_UI_VALUE,
		_uiCommandNames = UiDefine.UI_COMMAND_NAME,
		_dataSwitchButton = UiDefine.DATA_SWITCH_BUTTON,
		_listTypeMenuArr = UiDefine.LIST_TYPE_MENU_ARR,
		_useDescFunctionButtons = UiDefine.USE_DESC_FUNCTION_BUTTONS,
		_useItemNodeNames = UiDefine.USE_ITEM_NODE_NAMES,
		_svg_icon_html = UiDefine.SVG_ICON_HTML,
		_uiGroupName = "UiGroup",
		_commandWidgetsGroupName = "commandWidgets",
		_commandWidgetsIdxGroupName = "commandWidgetsIdx",
		_updateDescWidgetsGroupName = "updateDesc",
		_sampleItemMoveButtonGroupName = "sampleItemMoveButton",
		_formIDPrefix = "form_",
		_toggleButtonsValueArr = ["toggle", "switch", "switch_repeatable"],
		_templateDefineKeyArr = ["classVal", "text", "val"],
		_hasScrollContainerArr = ["titleBar", "menuBar", "styleBar"],
		_iconSizeAttrArr = UiDefine.DATA_ICON_SIZE_ATTR_VALUE_ARR,
		_xmlAttrToDomAttrMap = {
			"caption": _dataTitle,
			"uiCommand": UiDefine.DATA_UI_COMMAND,
			"uiValue": UiDefine.DATA_UI_VALUE,
			"value": UiDefine.DATA_VALUE
		},
		_showXmlTagToID = {
			translate: UiDefine.TRANSLATE_ID,
			sideBar: UiDefine.SIDEBAR_ID,
			menuBar: UiDefine.MENU_BAR_ID,
			titleBar: UiDefine.TITLE_BAR_ID,
			commentBar: UiDefine.COMMENTBAR_ID
		},
		_useItemNodeNameToWrapNodeName = {
			command: "commands",
			panelGroup: "panelGroups",
			widgetGroup: "widgetGroups",
			dataSet: "dataSets"
		},
		_xmlAttrKeys = Object.keys(_xmlAttrToDomAttrMap),
		_xmlAttrKeysLen = _xmlAttrKeys.length,
		_noop = function _noop(node, className, nodeName, parentInfo){},
		_createDomEl = CommonFrameUtil.createDomEl,
		_templateElMap = {},
		_cachedParentElObj = {},
		_langCode = "",
		_xmlNameToServerPropsMap = {
			"d_save": false,
			"d_save_as_button": false,
			"d_download": true,
			"d_pdf_download": true,
			"d_print": true,
			"e_help": true,
			"e_desktop_confirm": false,
			"e_desktop_execute": false,
			"d_page_setup": true,
			"storage_search_doc": false,
			"u_search_doc_context": false,
			"translate": false,
			"lab": false
		},
		_needDisableList = [],
		_checkDisableSubgroupList = [],
		_skinName = "",
		_cachedDescToCollabo = {},
		_uiCmdBtnArr = [],
		_uiCmdBtnNameArr = [],
		_lazyConvertMode = false,
		// 아래 변수는 converting 시마다 초기화 해야 하므로, initialize() 에서 초기화 필요
		_xmlItemsObj, _customXmlObj, _curRefItem, _commandItemIdx, _commandLastIdxInfo, _templateDir, _unitInfo,
		_widgetNameToValueKeyMap, _commandToValueKeyArrMap, _lazyPanelNames, _lazyUpdateDescNames, _noNameMatchIndex;


	/*******************************************************************************
	 * Private Functions (w/o context)
	 ******************************************************************************/

	/**
	 * name attribute 의 값을 돌려주는 함수
	 * @param node
	 * @returns {*|string|string}
	 * @private
	 */
	function _getName(node) {
		return (node && node.getAttribute("name")) || "";
	}

	/**
	 * node 에 disable 속성이 true 이면 disableList 에 target 을 넣는 함수
	 * @param {Element} target			- XML Node 를 convert 한 HTML fragment
	 * @param {Object} parentInfo
	 * @returns {void}
	 * @private
	 */
	function _pushDisableListIfNeeded(target, parentInfo) {
		var subgroupWrapEl;

		if (parentInfo.disable && target) {
			subgroupWrapEl = parentInfo.subgroupWrapNode;

			if (subgroupWrapEl && CommonFrameUtil.hasClass(subgroupWrapEl, UiDefine.SUB_GROUP_BOX_ELEMENT_CLASS)
				&& _checkDisableSubgroupList.indexOf(subgroupWrapEl) === -1) {

				_checkDisableSubgroupList.push(subgroupWrapEl);
			}
			_needDisableList.push(target);
		}
	}

	/**
	 * node 의 type 값을 돌려주는 함수
	 * @param {Element} node
	 * @param {String=} defaultType
	 * @returns {String}
	 * @private
	 */
	function _getType(node, defaultType) {
		return node.getAttribute("type") || defaultType || "normal";
	}

	/**
	 * className 2개를 합치는 함수
	 * @param {String} className
	 * @param {String} addClassName
	 * @returns {String}
	 * @private
	 */
	function _concatClassName(className, addClassName) {
		var orgClassNameArr, addClassNameArr, newClass, length, i;

		if (className && addClassName) {
			orgClassNameArr = className.split(" ");
			addClassNameArr = addClassName.split(" ");
			length = addClassNameArr.length;

			for (i = 0; i < length; i++) {
				newClass = addClassNameArr[i];
				if (orgClassNameArr.indexOf(newClass) === -1) {
					className += (" " + newClass);
				}
			}
		} else {
			className = className || addClassName;
		}

		return className;
	}

	/**
	 * 적절한 class name 을 만들어 돌려주는 함수
	 * @param {Element} node
	 * @param {String} nameValue
	 * @param {String=} prefixType
	 * @param {String=} nodeName		- node.nodeName 말고 사용해야할 name 이 있는 경우 지정
	 * @returns {*}
	 * @private
	 */
	function _getClassName(node, nameValue, prefixType, nodeName) {
		if (!node) {
			return "";
		}

		var className = nameValue || "",
			attrToClassObj, curAttrObj, attrs, attrLen, attribute, attrName, attrValue, classVal, i;

		nodeName = CommonFrameUtil.getUCFirst(nodeName || node.nodeName);

		if (prefixType) {
			if (_xmlAttrToClass[nodeName]) {
				className = _getClassName(node, nameValue);
			}

			nodeName = CommonFrameUtil.getUCFirst(prefixType) + nodeName;
		}

		attrToClassObj = _xmlAttrToClass[nodeName] || {};
		classVal = attrToClassObj.defaultClass;

		if (classVal) {
			className = _concatClassName(className, classVal);
		}

		classVal = node.getAttribute("class");

		if (classVal) {
			className = _concatClassName(className, classVal);
		}

		attrs = node.attributes;

		if (attrs) {
			attrLen = attrs.length;

			for (i = 0; i < attrLen; i++) {
				attribute = attrs[i];
				attrName = attribute.name;
				attrValue = attribute.value;
				curAttrObj = attrToClassObj[attrName] || _xmlAttrToClassCommon[attrName];

				if (curAttrObj && attrValue) {
					classVal = (typeof curAttrObj === "string") ? curAttrObj : curAttrObj[attrValue];

					if (classVal) {
						className = _concatClassName(className, classVal);
					}
				}
			}
		}

		return className;
	}

	/**
	 * 컨테이너 노드에 필요한 className을 리턴
	 * @param {Element} node
	 * @param {String} name
	 * @returns {String}
	 * @private
	 */
	function _getContainerClass(node, name) {
		var className = _concatClassName(name, UiDefine.CONTAINER_CLASS);

		if (node.getAttribute("hide") === "true") {
			className = _concatClassName(className, _hideForceClass);
		}

		return className;
	}

	function _getCustomDataAttrObject(node, attrObj) {
		var customData = node.getAttribute("customData"),
			customDataKeyValue;

		if (customData) {
			customDataKeyValue = CommonFrameUtil.getTrimText(customData).replace(/ /g, "").split(":");

			if (customDataKeyValue.length === 2) {
				attrObj = attrObj || {};
				attrObj["data-" + customDataKeyValue[0]] = customDataKeyValue[1];
			}
		}

		return attrObj || null;
	}

	function _getCreateContainerDomEl(node, name, isDefaultHide, addClassName) {
		var className = addClassName ? _concatClassName(name, addClassName) : name,
			attrObj = _getCustomDataAttrObject(node);

		if (isDefaultHide) {
			className = _concatClassName(className, _hideViewClass);
		}

		return _createDomEl("div", {id: name, className: _getContainerClass(node, className)}, attrObj);
	}

	function _needNotToConvertXmlNode(name) {
		return (_xmlNameToServerPropsMap[name] != null && !_xmlNameToServerPropsMap[name]);
	}

	function _isContainerView(target) {
		return CommonFrameUtil.hasClass(target, UiDefine.CONTAINER_CLASS);
	}

	function _isLine(target) {
		return (CommonFrameUtil.hasClass(target, UiDefine.HORIZONTAL_LINE_SEPARATOR_CLASS)
			|| CommonFrameUtil.hasClass(target, UiDefine.VERTICAL_LINE_SEPARATOR_WRAP_CLASS));
	}

	/**
	 * Element 혹은 element 들의 array 를 받아 array 로 convert 시켜주는 함수
	 * @param {Element|Array} el
	 * @return {Array}
	 * @private
	 */
	function _convertElToArray(el) {
		if (!el) {
			console.log("[Error] _convertElToArray : el is " + el);
			return [];
		}

		var length = el.length,
			result, i;

		if (length != null) {
			result = [];

			if (!(el instanceof Node) && el.constructor !== "Array") {
				for (i = 0; i < length; ++i) {
					result.push(el[i]);
				}
			} else {
				result = el;
			}
		} else {
			result = [el];
		}

		return result;
	}

	/**
	 * 전달받은 parentNode 에 element 를 child 로 붙여주는 함수
	 * @param {Object} parentNode
	 * @param {Array} elList
	 * @private
	 */
	function _appendChildElList(parentNode, elList) {
		if (!(parentNode && elList.length > 0)) {
			return;
		}

		var len = elList.length,
			i;

		for (i = 0; i < len; ++i) {
			parentNode.appendChild(elList[i]);
		}
	}

	function _setXmlItemsObj(baseXmlList, tagName) {
		if (!(baseXmlList && tagName)) {
			return;
		}

		var xmlListLen = baseXmlList.length || 0,
			curXmlItemObj, i, baseXml, targetXmlNodes, targetXmlNode, child, key;

		for (i = xmlListLen - 1; i >= 0; i--) {
			baseXml = baseXmlList[i];
			targetXmlNodes = baseXml && baseXml.getElementsByTagName(_useItemNodeNameToWrapNodeName[tagName]);
			targetXmlNode = targetXmlNodes && targetXmlNodes[targetXmlNodes.length - 1];

			if (targetXmlNode) {
				child = targetXmlNode.firstElementChild;
			}

			while (child) {
				key = child.getAttribute("name");
				curXmlItemObj = _xmlItemsObj[tagName];
				if (!curXmlItemObj) {
					curXmlItemObj = {};
					_xmlItemsObj[tagName] = curXmlItemObj;
				}
				curXmlItemObj[key] = child;
				child = child.nextElementSibling;
			}
		}
	}

	function _getNodeByXmlItem(nodeName, name, node) {
		if (!(nodeName && CommonFrameUtil.isEndsWith(nodeName, "Item"))) {
			return null;
		}

		var curXmlItemObj, xmlItemNode;

		if (node && node.getAttribute("overwrite") === "true") {
			xmlItemNode = node;

		} else {
			curXmlItemObj = _xmlItemsObj[nodeName.slice(0, -4)]; // 뒤에 Item 빼고
			if (curXmlItemObj) {
				xmlItemNode = curXmlItemObj[name];
			}
		}

		return xmlItemNode || null;
	}

	/**
	 * node 가 sample 에 해당하는 xml tag 이면, 그 부모 노드의 reference 를 저장하는 함수
	 * @param {Element} parentEl
	 * @param {Object} parentInfo
	 * @private
	 */
	function _cacheParentRef(parentEl, parentInfo) {
		var commandName = parentInfo.commandName,
			sampleWrapPostFix = UiDefine.SAMPLE_WRAP_POST_FIX;

		parentEl.setAttribute(
			"class", _concatClassName(parentEl.getAttribute("class"), sampleWrapPostFix));

		UiReferrer.pushWidget(parentEl, commandName + "_" + sampleWrapPostFix);
		// command 내의 widget reference
		if (UiReferrer.pushWidget(parentEl, commandName, _commandWidgetsGroupName)) {
			UiReferrer.pushWidget(parentInfo.commandItemIdx, commandName, _commandWidgetsIdxGroupName, true);
		}
	}

	/**
	 * node 가 sample 에 해당하는 xml tag 이면, convert 된 el 의 ref 를 저장하는 함수
	 * @param {Array|Element} el
	 * @param {Object} parentInfo
	 * @param {String} valueKey
	 * @param {String=} customKey
	 * @private
	 */
	function _setSampleItemMap(el, parentInfo, valueKey, customKey) {
		var commandName = parentInfo.commandName,
			key = customKey || commandName,
			widgetMap = UiReferrer.getWidgetMap() || {},
			selectedArr = widgetMap["selected"],
			isSelectAllTarget = UiFrameworkInfo.isSelectAllTarget(commandName, _commandItemIdx, valueKey),
			selectedValue = null;

		if (isSelectAllTarget) {
			UiFrameworkInfo.removeSelectAllTarget(commandName, _commandItemIdx, valueKey);
			selectedValue = String(selectedArr && (selectedArr.indexOf(el) !== -1));
		}

		el = el.length ? el[0] : el;
		_cacheParentRef(parentInfo.parentEl, parentInfo);
		parentInfo.parentEl.setAttribute(UiDefine.DATA_SAMPLE_NAME, key);
		CommonFrameUtil.addClass(el, UiDefine.SAMPLE_ITEM_CLASS);

		UiReferrer.pushWidget({
			container: parentInfo.rootNodeName,
			valueKey: valueKey,
			parentEl: parentInfo.parentEl,
			el: el,
			isSelectAllTarget: isSelectAllTarget,
			commandItemIndex: _commandItemIdx,
			selected: selectedValue
		}, key, UiDefine.GROUP_NAME_SAMPLE_ITEM);
	}

	function _setUnitInfo(node, parentInfo) {
		var unit = node.getAttribute("unit"),
			valueKey, widgetName;

		if (CommonFrameUtil.isString(unit)) {
			// dropdown 또는 input 에 출력되는 unit 기록
			valueKey = parentInfo.valueKey || node.getAttribute("valueKey");
			widgetName = _getWidgetName(parentInfo.commandName, valueKey);

			_unitInfo[widgetName] = unit;
		}
	}

	function _addMatchAttribute(node, el) {
		var match = node.getAttribute("match"),
			matchGroup = node.getAttribute("matchGroup"),
			result = false;

		el = (el.length === undefined) ? el : el[0];

		if (match) {
			el.setAttribute(UiDefine.DATA_MATCH_ATTR, match);
			result = true;
		}
		if (matchGroup) {
			el.setAttribute(UiDefine.DATA_MATCH_GROUP_ATTR, matchGroup);
		}

		return result;
	}

	function _getWidgetName(commandName, valueKey) {
		var widgetName;

		if (valueKey) {
			widgetName = commandName + "_" + valueKey;
		} else {
			widgetName = commandName;
		}

		return widgetName;
	}

	function _getIconClassName(iconName) {
		return iconName ? _concatClassName(iconName, UiDefine.BTN_INNER_ICON_CLASS) : UiDefine.BTN_INNER_ICON_CLASS;
	}

	function _pushWidgetNameToValueKeyMap(commandName, valueKey, widgetName) {
		if (!widgetName) {
			widgetName = _getWidgetName(commandName, valueKey);
		}

		valueKey = valueKey || "";

		if (_widgetNameToValueKeyMap[widgetName] != null && _widgetNameToValueKeyMap[widgetName] !== valueKey) {
			// commandName 이 다른 widgetName 과 겹치는 경우 문제되기 때문에 warning 한다.
			console.log("[Error] widgetName conflict! ", widgetName);
		}
		_widgetNameToValueKeyMap[widgetName] = valueKey;
	}

	function _pushCommandToValueKeyArrMap(commandName, valueKey) {
		if (valueKey == null) {
			return;
		}

		var valueKeyArr = _commandToValueKeyArrMap[commandName];

		if (!valueKeyArr) {
			valueKeyArr = [];
			_commandToValueKeyArrMap[commandName] = valueKeyArr;
		}

		if (valueKeyArr.indexOf(valueKey) === -1) {
			// valueKey "" 을 포함해서 담는다 (조건부서식처럼 valueKey 유무를 복합으로 사용한 command 있음)
			valueKeyArr[valueKeyArr.length] = valueKey;
		}
	}

	function _pushCommandWidget(refEl, commandName, value, valueKey, parentInfo) {
		var widgetName = _getWidgetName(commandName, valueKey),
			isSampleValue = (value === UiDefine.SAMPLE_VALUE),
			widgetMapKey;

		if (widgetName && !isSampleValue) {
			if (!valueKey && value && !parentInfo.subgroupWrapNode) {
				widgetMapKey = commandName + "_" + value;
				/**
				 * (기존 호환 유지를 위한 코드)
				 * valueKey 없고 value 만 있는 widget 이 subgroup 내에 있지 않은 경우
				 * 별도 key 로 추가 cache 함
				 */
				UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(refEl), widgetMapKey);
				UiReferrer.pushWidget(refEl, widgetMapKey);
			} else {
				UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(refEl), widgetName);
			}
			UiReferrer.pushWidget(refEl, widgetName);

			if (parentInfo.commandName) {
				valueKey = valueKey || "";
				_pushWidgetNameToValueKeyMap(commandName, valueKey, widgetName);
			} else {
				valueKey = null;
			}

			// command 내의 widget reference
			if (UiReferrer.pushWidget(refEl, commandName, _commandWidgetsGroupName)) {
				UiReferrer.pushWidget(parentInfo.commandItemIdx, commandName, _commandWidgetsIdxGroupName, true);
			}
		} else {
			if (isSampleValue) {
				// sampleItem 이더라도 subGroup 내에 있다면 pushWidget
				if (parentInfo.subgroupWrapNode) {
					UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(refEl), widgetName);
					UiReferrer.pushWidget(refEl, widgetName);
				}
			} else {
				// 정적인 sampleItem 의 valueKey 는, 여기서 해당 command 의 valueKey 로 추가함
				valueKey = null;
			}
		}

		if (valueKey != null) {
			_pushCommandToValueKeyArrMap(commandName, valueKey);
		}

		return widgetName;
	}

	function _addDefaultValue(node, el, parentInfo) {
		var defaultValue = parentInfo.defaultValue || node.getAttribute("defaultValue");

		if (defaultValue) {
			el.setAttribute(UiDefine.DATA_DEFAULT_VALUE_ATTR, defaultValue);
			UiReferrer.pushWidget(el, "defaultValue");
		}
	}

	function _addWidgetAttribute(node, el, parentInfo) {
		var value = node.getAttribute("value") || "",
			valueKey = parentInfo.valueKey || node.getAttribute("valueKey"),
			hasCaption = node.hasAttribute("caption"),
			captionVisible = node.getAttribute("captionVisible") !== "false",
			unit = node.getAttribute("unit"),
			commandName, widgetName, key, attrName, attrVal, i, refEl, uiValue, uiCommand;

		el = (el.length === undefined) ? el : el[0];

		for (i = 0; i < _xmlAttrKeysLen; i++) {
			key = _xmlAttrKeys[i];
			attrVal = node.getAttribute(key);
			if (attrVal) {
				if (!uiValue && key === "uiValue") {
					uiValue = _showXmlTagToID[attrVal] || attrVal;
					attrVal = uiValue;
				}

				if (key !== "caption" || captionVisible) {
					attrName = _xmlAttrToDomAttrMap[key];
					el.setAttribute(attrName, attrVal);
				}
			}
		}

		unit = (CommonFrameUtil.isString(unit)) ? unit : parentInfo.unit;

		if (CommonFrameUtil.isString(unit)) {
			el.setAttribute(_dataUnit, unit);
		}

		refEl = parentInfo.subgroupWrapNode || el;
		uiCommand = uiValue ? node.getAttribute("uiCommand") : null;

		if (uiCommand) {
			// ui button name 정보 push
			_uiCmdBtnArr[_uiCmdBtnArr.length] = el;
			_uiCmdBtnNameArr[_uiCmdBtnNameArr.length] = _getName(node);

			if (uiCommand === _uiCommandNames.TOGGLE || uiCommand === _uiCommandNames.FOLD) {
				UiReferrer.pushWidget(el, uiValue, uiCommand + _uiGroupName);
			}

			parentInfo.commandName = _getName(node);
		}

		commandName = parentInfo.commandName || _getName(node);

		if (commandName) {
			widgetName = _pushCommandWidget(refEl, commandName, value, valueKey, parentInfo);
			CommonFrameUtil.addClass(el, commandName, true);
		}

		if (hasCaption && captionVisible) {
			_replaceNlsCaptionValue(el);
		}

		parentInfo.disable = parentInfo.disable || (node.getAttribute("disable") === "true");
		if (node.nodeName !== "template") {
			_pushDisableListIfNeeded(el, parentInfo);
		}

		if (!parentInfo.rootNodeName) {
			console.log("[Error] The " + (widgetName ? "'" + widgetName + "'" : "")
				+ node.nodeName + " should be inside at least one container.");
		}
	}

	function _addCommandAttributes(node, el, parentInfo) {
		var commandName = parentInfo.commandName || "",
			uiCommand = node.getAttribute("uiCommand"),
			valueKey;

		el = (el.length === undefined) ? el : el[0];

		if (commandName && !uiCommand) {
			valueKey = parentInfo.valueKey || node.getAttribute("valueKey");

			el.setAttribute(UiDefine.DATA_COMMAND, commandName);
			if (parentInfo.nonExec || node.getAttribute("nonExec") === "true") {
				el.setAttribute(UiDefine.DATA_NON_EXEC, "true");
			}
			if (valueKey) {
				el.setAttribute(_dataValueKey, valueKey);
			}
		}
	}

	/**
	 * parent node 에 전달받은 child 들을 붙여주는 함수
	 * @param {Element} parentNode
	 * @param {Element|Array} childNodes
	 * @returns {Element}
	 * @private
	 */
	function _appendChildNode(parentNode, childNodes) {
		var isSingleElement = (!childNodes || childNodes instanceof Node),
			childNode, len, i;

		if (parentNode == null || childNodes == null || (!isSingleElement && childNodes.length < 1)) {
			console.log("[Error] Invalid parameter.");
			return null;
		}

		if (isSingleElement) {
			if (typeof childNodes === "string") {
				parentNode.appendChild(document.createTextNode(childNodes));
			} else {
				parentNode.appendChild(childNodes);
			}
		} else {
			i = 0;
			childNode = childNodes[i];

			do {
				if (childNode) {
					len = childNodes.length;

					if (typeof childNode === "string") {
						parentNode.appendChild(document.createTextNode(childNode));
					} else {
						parentNode.appendChild(childNode);
					}
				}

				// appendChild 후 len 이 바뀌면, Array 가 아니고 childNodes 임. (i 증가 시키지 않음)
				i = (len !== childNodes.length) ? 0 : i + 1;
				childNode = childNodes[i];
			} while (childNode);
		}

		return parentNode;
	}

	/**
	 * Source node 의 attribute 중 target node 에 동일한 attribute 가 있다면 override 시키는 함수
	 * @param {Element} targetNode
	 * @param {Element} sourceNode
	 * @param {Array=} targetAttributeNames
	 * @returns {String}
	 * @private
	 */
	function _overrideAttribute(targetNode, sourceNode, targetAttributeNames) {
		var attrs = sourceNode.attributes,
			attrLen, attribute, attrName, attrValue, i;

		if (attrs) {
			attrLen = attrs.length;

			for (i = 0; i < attrLen; i++) {
				attribute = attrs[i];
				attrName = attribute.name;
				attrValue = attribute.value;

				if (attrName !== "name" && attrName !== "overwrite") {
					if ((!targetAttributeNames || targetAttributeNames.indexOf(attrName) !== -1)
						&& targetNode.getAttribute(attrName) !== attrValue) {
						targetNode.setAttribute(attrName, attrValue);
					}
				}
			}
		}
	}

	function _overrideAttributeToChild(targetNode, sourceNode, targetAttributeNames) {
		var curNode = targetNode.firstElementChild;

		while (curNode) {
			_overrideAttribute(curNode, sourceNode, targetAttributeNames);
			curNode = curNode.nextElementSibling;
		}
	}

	/**
	 * NLS 적용된 Description 값 return
	 * @param {Element} node
	 * @param {Object} parentInfo
	 * @param {String=} nlsAttrName	- nls 로 사용할 attribute name
	 * @returns {String}
	 * @private
	 */
	function _getDescription(node, parentInfo, nlsAttrName) {
		var descVal = null,
			attrVal;

		if (!node) {
			return descVal;
		}

		if (nlsAttrName) {
			if (parentInfo.descVisible || (nlsAttrName !== "desc" && nlsAttrName !== "shortcut")) {
				attrVal = node.getAttribute(nlsAttrName);

				if (attrVal) {
					descVal = FrameworkUtil.getReplaceNlsValue(attrVal);
				}
			}
		}

		return descVal;
	}

	/**
	 * Description 지정하고, updateDesc 대상인 경우 관련 widgetMap 에 push
	 * @param {Element} descEl
	 * @param {String=} descVal		- 없는경우 updateDesc 관련 처리
	 * @param {Object=} parentInfo		- line 두줄, fontName 예외처리 확인용
	 * @param {Element=} node			- xml node (updateDesc 확인용. updateDesc 사용하지 않을시 지정하지 않음)
	 * @returns {String}
	 * @private
	 */
	function _setDescription(descEl, descVal, parentInfo, node) {
		var addLineBreak = false,
			name;

		if (!descEl) {
			return "";
		}

		if (node && node.getAttribute("updateDesc") === "true") {
			name = _getName(node);
			UiReferrer.pushWidget(descEl, name, _updateDescWidgetsGroupName);

			if (_lazyUpdateDescNames) {
				_lazyUpdateDescNames[_lazyUpdateDescNames.length] = name;
			}

			descVal = descVal || "";
		}

		if (descVal != null) {
			if (parentInfo && parentInfo.rootNodeName === "menuBar" && !parentInfo.subgroupWrapNode) {
				addLineBreak = true;
			}

			FrameworkUtil.setDescription(descEl, descVal, addLineBreak);

			if ((parentInfo && parentInfo.commandName === UiDefine.EVENT_ACTION_NAMES.FONT_NAME) ||
				(parentInfo && parentInfo.sampleItem) || (node && node.getAttribute("sampleItem"))) {
				// fontName command 와 sampleItem 은 별도 처리를 위해 nlsName 속성 추가
				descEl.setAttribute(_dataNlsName, descVal);
			}
		}

		return descVal;
	}

	function _replaceNlsCaptionValue(elList) {
		if (!CommonFrameUtil.isArray(elList)) {
			elList = [elList];
		}

		FrameworkUtil.replaceAttrValue(elList, ["title", "placeholder"]);
	}

	function _addToggleButtonsToAttrObj(parentInfo, attrObj) {
		var toggleButtons = parentInfo.toggleButtons;

		attrObj = attrObj || {};
		if (toggleButtons === "switch" || toggleButtons === "switch_repeatable") {
			attrObj[_dataSwitchButton] = (toggleButtons === "switch") ? "true" : "repeatable";
		}

		return attrObj;
	}

	function _addUiCommandToAttrObj(name, value, attrObj) {
		attrObj = attrObj || {};

		if (name) {
			attrObj[_dataUiCommand] = name;
		}

		if (value) {
			attrObj[_dataUiValue] = value;
		}

		return attrObj;
	}

	function _setIconSize(btnEl, iconEl, iconSize) {
		var iconSizeArr;

		if (btnEl && iconSize && iconSize !== "none") {
			if (_iconSizeAttrArr.indexOf(iconSize) !== -1) {
				// small, medium... 지정된 크기
				btnEl.setAttribute(UiDefine.DATA_ICON_SIZE_ATTR, iconSize);

			} else {
				btnEl.setAttribute(UiDefine.DATA_ICON_SIZE_ATTR, "custom");

				iconSizeArr = iconSize.split("*");

				if (iconSizeArr.length < 2) {
					// 가로,세로 같은 크기
					iconSizeArr[1] = iconSizeArr[0];
				}

				// icon width, height
				if (iconEl && CommonFrameUtil.isNumber(iconSizeArr[0]) && CommonFrameUtil.isNumber(iconSizeArr[1])) {
					iconEl.style.setProperty("width", iconSizeArr[0] + "px");
					iconEl.style.setProperty("height", iconSizeArr[1] + "px");
				}
			}
		}
	}

	function _getMarginPaddingStyleArray(node, isPadding) {
		var attrStyle = node.getAttribute(isPadding ? "padding" : "margin"),
			styleArr = attrStyle ? attrStyle.split(" ") : null,
			styleVal, i;

		if (styleArr && styleArr.length === 4) {
			for (i = 0; i < 4; i++) {
				styleVal = styleArr[i];

				if (!CommonFrameUtil.isNumber(styleVal)) {
					return null;
				}

				if (styleVal != 0) {
					styleArr[i] = styleVal + "px";
				}
			}
		}

		return styleArr;
	}

	function _setMarginPaddingStyle(node, el, isPadding) {
		var attrStyle = isPadding ? "padding" : "margin",
			styleArr = _getMarginPaddingStyleArray(node, isPadding),
			targetEl;

		if (styleArr) {
			targetEl = (el.length) ? el[0] : el;

			if (targetEl && targetEl.style) {
				targetEl.style.setProperty(attrStyle, styleArr.join(" "));
			}
		}

		return el;
	}

	function _setColorStyle(node, el, textEl) {
		var bgColor = node.getAttribute("bgColor"),
			borderColor = node.getAttribute("borderColor"),
			textColor = node.getAttribute("textColor"),
			targetEl;

		if (!(bgColor || borderColor || textColor)) {
			return;
		}

		targetEl = (el.length) ? el[0] : el;

		if (targetEl && targetEl.style) {
			if (bgColor) {
				targetEl.style.setProperty("background-color", bgColor);
			}

			if (borderColor) {
				targetEl.style.setProperty("border-color", borderColor);
			}

			if (textColor) {
				if (textEl && textEl.style) {
					targetEl = textEl;
				}

				targetEl.style.setProperty("color", textColor);
			}
		}
	}

	function _createOnLinkAnchor(node, attrObj) {
		var name = _getName(node),
			onLinkAttrVal = node.getAttribute("onLink"),
			langCode = _langCode,
			anchorEl, url;

		anchorEl = _createDomEl("a", {className: _onLinkClass}, attrObj);

		if (onLinkAttrVal && CommonFrameUtil.isStartsWith(onLinkAttrVal, "{")
			&& CommonFrameUtil.isEndsWith(onLinkAttrVal, "}")) {
			url = UiDefine[onLinkAttrVal.substring(1, onLinkAttrVal.length - 1)];
		} else {
			url = onLinkAttrVal;
		}

		if (url) {
			if (url.indexOf("{}") > -1 && langCode) {
				if (name === "hwp_message") {
					if (!(langCode === "ko" || langCode === "ja")) {
						langCode = "en-us";
					}
				} else if (name === UiDefine.EVENT_ACTION_NAMES.E_HELP) {
					langCode = "en_us";

					if (_langCode === "ko") {
						langCode = "ko_kr";
					} else if (_langCode === "ru") {
						langCode = "ru_ru";
					}
				}

				url = url.replace("{}", langCode);
			}

			anchorEl.setAttribute("href", url);
			anchorEl.setAttribute("target", "_blank");
		}

		return anchorEl;
	}

	function _createMenuArrowIconButton(iconName, value, option) {
		var btnEl, anchorEl, childEl, className;

		className = _concatClassName(iconName, _buttonClass);
		className = _concatClassName(className, _functionButtonsClass);

		if (option) {
			className = _concatClassName(className, option);
		}

		btnEl = _createDomEl("div", {className: _concatClassName(className, UiDefine.VIEW_BORDER_PREFIX + "_all")},
			_addUiCommandToAttrObj(UiDefine.UI_COMMAND_NAME.MENU_H_SCROLL, value));

		childEl = _createDomEl("div",{className: _getIconClassName(iconName), type: iconName});
		anchorEl = _appendChildNode(_createDomEl("a", {}), childEl);
		btnEl = _appendChildNode(btnEl, anchorEl);

		return btnEl;
	}

	function _createScrollArrowGroup(navBoxClass, scrollClass) {
		if (!navBoxClass && !scrollClass) {
			return null;
		}

		var btnPrevEl, btnNextEl, btnPrevNavEl, btnNextNavEl, childElList, el;

		btnPrevEl = _createMenuArrowIconButton(UiDefine.BUTTON_PREV_ARROW_CLASS, "prev", scrollClass);
		btnNextEl = _createMenuArrowIconButton(UiDefine.BUTTON_NEXT_ARROW_CLASS, "next", scrollClass);

		if (scrollClass === UiDefine.TAB_SCROLL_CLASS) {
			CommonFrameUtil.addClass(btnPrevEl, UiDefine.DISABLE_CLASS);

			childElList = [btnPrevEl, btnNextEl];
		} else {
			btnPrevNavEl = _appendChildNode(_createDomEl("div", {className: UiDefine.BUTTON_PREV_NAV_CLASS}), btnPrevEl);
			btnNextNavEl = _appendChildNode(_createDomEl("div", {className: UiDefine.BUTTON_NEXT_NAV_CLASS}), btnNextEl);

			// tab scroll 의 경우엔 scroll 이 제일 처음에 위치해도 버튼이 감추어지지 않고 disable 됨.
			// 그러나 그 외의 scroll(title/menu/style bar)의 경우에는 버튼이 hide 됨
			CommonFrameUtil.addClass(btnPrevNavEl, _hideViewClass);

			childElList = [btnPrevNavEl, btnNextNavEl];
		}

		el = _appendChildNode(_createDomEl("div", {className: navBoxClass}), childElList);

		return el;
	}

	function _createIconButton(node, parentInfo) {
		var name = _getName(node),
			className = _getClassName(node, name),
			elList = [],
			childArr = [],
			attrObj = _addToggleButtonsToAttrObj(parentInfo),
			attrBorder = node.getAttribute("border"),
			shortcutVal = _getDescription(node, parentInfo, "shortcut"),
			descVal = _getDescription(node, parentInfo, "desc"),
			isOnLink = node.getAttribute("onLink"),
			bindWidget = node.getAttribute("bindWidget"),
			anchorInnerElClass = isOnLink ? _onLinkClass : "",
			iconSize = node.getAttribute("iconSize") || parentInfo.iconArea,
			eventActionNames = UiDefine.EVENT_ACTION_NAMES,
			needIconClass, innerIconElClassName, descEl, btnEl, anchorEl, extendClassName, svgIcons;

		className = _concatClassName(className, _buttonClass);

		if (_listTypeMenuArr.indexOf(parentInfo.rootNodeName) === -1 || !descVal
			|| _useDescFunctionButtons.indexOf(name) !== -1) {
			/* functionButtons (dropdownListData 가 아닌 button).
			 * listType 으로 표시되는 메뉴에서 description 있는 button 은 dropdownListData 로 처리 */

			if (name === eventActionNames.E_HELP || name === eventActionNames.U_SHORTCUT) {
				svgIcons = ((_svg_icon_html[_skinName] && _svg_icon_html[_skinName][name.toUpperCase()]) || "");
				if (svgIcons) {
					childArr[0] = $(svgIcons)[0];
				}
			} else {
				className = _concatClassName(className, _functionButtonsClass);
			}
		}

		if (node.name !== "button") {
			// button 이 아닌데 icon button 생성하는 상황인 경우, button 에 맞는 class 들을 지정받기 위해 호출
			className = _concatClassName(className, _getClassName(node, name, null, "button"));
		}

		if (iconSize) {
			// "none" 으로 지정한 경우 icon 관련 DOM 생성하지 않음
			needIconClass = (iconSize !== "none");
		} else {
			needIconClass = (node.getAttribute("icon") !== "false");
		}

		if (needIconClass) {
			className = _concatClassName(className, UiDefine.NORMAL_BUTTON_CLASS);
		}

		if (!!attrBorder) {
			extendClassName = _concatClassName(className, UiDefine.VIEW_BORDER_PREFIX + "_" + attrBorder);
		}

		if (bindWidget) {
			attrObj[UiDefine.DATA_BIND_WIDGET_ATTR] = _getWidgetName(parentInfo.commandName, bindWidget);
		}

		btnEl = _createDomEl("div", {className: extendClassName || className, type: className}, attrObj);

		if (isOnLink) {
			anchorEl = _createOnLinkAnchor(node);
		} else {
			anchorEl = _createDomEl("a", {className: anchorInnerElClass});
		}

		_setColorStyle(node, btnEl, anchorEl);
		_addMatchAttribute(node, btnEl);

		if (needIconClass && !svgIcons) {
			innerIconElClassName = _getIconClassName(parentInfo.name);
			innerIconElClassName = _concatClassName(innerIconElClassName, anchorInnerElClass);
			childArr[0] = _createDomEl("div",{className: innerIconElClassName, type: className});
			_setIconSize(btnEl, childArr[0], iconSize);
		}

		if (descVal) {
			descEl = _createDomEl("span", {className: anchorInnerElClass});
			_setDescription(descEl, descVal, parentInfo, node);
			childArr[childArr.length] = descEl;

			CommonFrameUtil.addClass(btnEl, UiDefine.HAS_DESCRIPTION_CLASS);
		}

		if (shortcutVal) {
			descEl = _createDomEl("span", {className: _concatClassName(anchorInnerElClass, UiDefine.SHORTCUT_CLASS)});
			_setDescription(descEl, shortcutVal, parentInfo);
			childArr[childArr.length] = descEl;
		}

		anchorEl = _appendChildNode(anchorEl, childArr);
		btnEl = _appendChildNode(btnEl, anchorEl);
		elList.push(btnEl);

		return elList;
	}

	function _convertDom(node, className, nodeName, parentInfo) {
		var childElObj = {
				elList: [],
				boxEl: null
			},
			convertedDomInfo;

		if (_needNotToConvertXmlNode(_getName(node))) {
			return childElObj;
		}

		if (_convertXmlToDomHandler[nodeName]) {
			convertedDomInfo = _convertXmlToDomHandler[nodeName](node, className, nodeName, parentInfo);
			if (convertedDomInfo && convertedDomInfo.el) {
				childElObj.elList = _convertElToArray(convertedDomInfo.el);
				childElObj.boxEl = convertedDomInfo.boxEl;
			}
		} else {
			console.log("[Error] Name : " + nodeName + " is not found.");
		}

		return childElObj;
	}

	function _makeParentInfo(node) {
		return {
			rootNodeName: node.nodeName,
			parentNode: node.parentNode,
			toggleButtons: null,
			commandName: null,
			name: null,
			valueKey: null,
			nonExec: false,
			descVisible: true,
			captionVisible: true,
			subgroupWrapNode: null,
			parentEl: null,
			commandItemIdx: 0,
			defaultValue: null,
			disable: false,
			parentElList: [],
			customXmlObj: CommonFrameUtil.cloneObject(_customXmlObj),
			lazyConverting: _lazyConvertMode,
			sampleItem: "",
			unit: null,
			iconArea: null,
			layout: null,
			direction: null,
			deleteIfHasNotChild: false
		};
	}

	function _getClonedParentInfo(parentInfo) {
		if (!parentInfo) {
			return null;
		}

		return {
			rootNodeName: parentInfo.rootNodeName,
			parentNode: parentInfo.parentNode,
			toggleButtons: parentInfo.toggleButtons,
			commandName: parentInfo.commandName,
			name: parentInfo.name,
			valueKey: parentInfo.valueKey,
			nonExec: parentInfo.nonExec,
			descVisible: parentInfo.descVisible,
			captionVisible: parentInfo.captionVisible,
			subgroupWrapNode: parentInfo.subgroupWrapNode,
			parentEl: parentInfo.parentEl,
			commandItemIdx: parentInfo.commandItemIdx,
			defaultValue: parentInfo.defaultValue,
			disable: parentInfo.disable,
			parentElList: parentInfo.parentElList,
			customXmlObj: CommonFrameUtil.cloneObject(parentInfo.customXmlObj),
			lazyConverting: parentInfo.lazyConverting,
			sampleItem: parentInfo.sampleItem,
			unit: parentInfo.unit,
			iconArea: parentInfo.iconArea,
			layout: parentInfo.layout,
			direction: parentInfo.direction,
			deleteIfHasNotChild: parentInfo.deleteIfHasNotChild
		};
	}

	// customXmlObj 에 접근할 key 구함
	function _getCustomXmlObjKey(nodeName, name, useName) {
		var commandNode;

		if (nodeName === "commandItem") {
			commandNode = _getNodeByXmlItem(nodeName, name);
			if (commandNode && !commandNode.firstElementChild) {
				// command 인데 child 없는 경우 button 으로 처리됨
				nodeName = "button";
			}
		}

		return nodeName + "|" + (useName ? name || "" : "");
	}

	function _getCustomXmlNodes(customXmlObj, nodeName, name, useName, remove) {
		var key = _getCustomXmlObjKey(nodeName, name, useName),
			customXmlNodes;

		if (customXmlObj) {
			customXmlNodes = customXmlObj[key];
			if (remove) {
				delete customXmlObj[key];
			}
		}

		return customXmlNodes || null;
	}

	function _getOverwriteEndNode(overwriteNode, curNode, parentNode) {
		var name = overwriteNode.getAttribute("start"),
			curChildNode, endName;

		endName = overwriteNode.getAttribute("end");

		if (endName) {
			if (curNode && name) {
				// 시작 node 지정된 상황
				curChildNode = curNode;
			} else {
				// 시작 node 지정되지 않은 경우 맨 앞 child 부터
				curChildNode = parentNode ? parentNode.firstElementChild : null;
			}

			while (curChildNode && _getName(curChildNode) !== endName) {
				curChildNode = curChildNode.nextElementSibling;
			}
		}

		// end 미지정시, 또는 못구한 경우 맨 뒤
		return curChildNode || parentNode.lastElementChild;
	}

	// customXmlNode 의 child 들을 customXmlObj 에 추가함
	function _setCustomXmlObj(customXmlObj, customXmlNode) {
		if (!(customXmlNode && customXmlObj)) {
			return;
		}

		var wrapNodeName = customXmlNode.nodeName,
			isCustomTag = wrapNodeName === "custom" || wrapNodeName === "viewMode",
			curNode = customXmlNode.firstElementChild,
			nodeName, name, curNodeArr;

		while (curNode) {
			nodeName = curNode.nodeName;

			if (isCustomTag && _useItemNodeNames.indexOf(nodeName) !== -1) {
				// custom tag 바로 아래에는 "Item" 없이 사용 가능
				nodeName += "Item";
			}

			name = (nodeName === "overwrite") ? curNode.getAttribute("start") : _getName(curNode);
			curNodeArr = _getCustomXmlNodes(customXmlObj, nodeName, name, true);

			if (!curNodeArr) {
				// 해당 key 없는경우 신규 추가
				curNodeArr = [];
				customXmlObj[_getCustomXmlObjKey(nodeName, name, true)] = curNodeArr;
			}
			curNodeArr[curNodeArr.length] = curNode;
			curNode = curNode.nextElementSibling;
		}
	}

	function _updateCustomXmlObj(customXmlObj, customNodes) {
		var customNode, i;

		if (customXmlObj && customNodes) {
			i = 0;
			customNode = customNodes[i];

			while (customNode) {
				if (customNode.getAttribute("overwrite") === "true") {
					// overwrite 사용한 경우, 이하에서 더이상 쓰지 않음. 삭제
					customNodes.splice(i, 1);
				} else {
					// 해당 customNode 이하의 정보를 포함시킴
					_setCustomXmlObj(customXmlObj, customNode);
					i++;
				}

				customNode = customNodes[i];
			}
		}
	}

	function _convertChildDom(node, parentInfo, isLazyConvert) {
		var elList = [],
			doConcatList = true,
			doLineHidden = false,
			rootNodeName = parentInfo && parentInfo.rootNodeName,
			curNode, nextNode, curParentInfo, curElObj, boxEl, childElList, curRefItem, curElList, className, type,
			nodeName, parentEl, customXmlObj, customNodesWithName, sampleItemAttr, curValueKey, name, customNodes,
			customNode, len, i, insertNodes, overwriteNodes, overwriteNode, overwriteEndNode, orgNode,
			lastEl, curEl, isLineToLastEl, parentElList, lastElToParent, idx, style, customKey;

		if (!node) {
			return elList;
		}

		curNode = isLazyConvert ? node : node.firstElementChild;

		if (parentInfo) {
			overwriteNodes = _getCustomXmlNodes(parentInfo.customXmlObj, "overwrite", "", true, true);
			if (overwriteNodes && overwriteNodes.length) {
				overwriteNode = overwriteNodes[overwriteNodes.length - 1];
				if (overwriteNode) {
					childElList = _convertChildDom(overwriteNode, _getClonedParentInfo(parentInfo));
					elList = elList.concat(childElList);

					// start 가 ""인(처음부터 지정된) overwrite 가 있다면 시작할 curNode 구함
					overwriteEndNode = _getOverwriteEndNode(overwriteNode, null, node);
					if (overwriteEndNode) {
						curNode = overwriteEndNode.nextElementSibling;
					}
				}
			}
		}

		while (curNode) {
			curRefItem = _curRefItem;
			nextNode = !isLazyConvert ? curNode.nextElementSibling : null;
			overwriteNode = null;

			curParentInfo = _getClonedParentInfo(parentInfo) || _makeParentInfo(curNode);
			nodeName = curNode.nodeName;
			name = _getName(curNode);

			customXmlObj = curParentInfo.customXmlObj;

			if (name) {
				// name 이 있다면 overwrite start 인지 구함
				overwriteNodes = _getCustomXmlNodes(customXmlObj, "overwrite", name, true, true);
				if (overwriteNodes && overwriteNodes.length) {
					overwriteNode = overwriteNodes[overwriteNodes.length - 1];
					customXmlObj.isNewNode = true;
				}

				curParentInfo.name = name;
			}

			if (curNode.hasAttribute("descVisible")) {
				curParentInfo.descVisible = (curNode.getAttribute("descVisible") === "true");
			}

			if (overwriteNode) {
				// overwriteNode converting
				curParentInfo.parentElList = elList;
				childElList = _convertChildDom(overwriteNode, curParentInfo);
				elList = elList.concat(childElList);

				overwriteEndNode = _getOverwriteEndNode(overwriteNode, curNode, node);
				if (overwriteEndNode) {
					// end 의 다음 node 구함
					nextNode = overwriteEndNode.nextElementSibling;
				}

			} else {
				customNodes = _getCustomXmlNodes(customXmlObj, nodeName, name, false);
				if (name) {
					// name 있는경우 name 포함해서 concat
					customNodesWithName = _getCustomXmlNodes(customXmlObj, nodeName, name, true);
					if (customNodesWithName) {
						customNodes = customNodes ? customNodes.concat(customNodesWithName) : customNodesWithName;
					}

					// insertBefore
					insertNodes = _getCustomXmlNodes(customXmlObj, "insertBefore", name, true, true);
					if (insertNodes && insertNodes.length) {
						customXmlObj.isNewNode = true;
						curParentInfo.parentElList = elList;
						childElList = _convertChildDom(insertNodes[insertNodes.length - 1], parentInfo);
						elList = elList.concat(childElList);
					}
				}

				if (UiDefine.HAS_TYPE_TAG_ARR.indexOf(nodeName) !== -1) {
					type = _getType(curNode);
					className = _getClassName(curNode, name, type);
				} else {
					className = _getClassName(curNode, name);
				}

				if (customNodes) {
					// customNodes 에 있는 속성 덮어씀
					orgNode = customXmlObj.isNewNode ? curNode.cloneNode(false) : null;
					len = customNodes.length;

					for (i = 0; i < len; i++) {
						customNode = customNodes[i];
						_overrideAttribute(curNode, customNode);

						if (customNode.getAttribute("overwrite") === "true") {
							curNode = customNode;
							customXmlObj.isNewNode = true;
						}
					}

					if (orgNode) {
						// 새로 추가된 node 의 경우(overwrite 또는 insertBefore, insertAfter) 추가된 속성 우선
						_overrideAttribute(curNode, orgNode);
					}

					_updateCustomXmlObj(customXmlObj, customNodes);
				}

				if (curNode.getAttribute("delete") !== "true") {
					//1. node 로부터 현재 DOM 을 생성 함
					curElObj = _convertDom(curNode, className, nodeName, curParentInfo);
					boxEl = curElObj.boxEl;
					curElList = curElObj.elList;

					sampleItemAttr = curNode.getAttribute("sampleItem");

					if (sampleItemAttr) {
						curParentInfo.sampleItem = sampleItemAttr;
					}

					style = curNode.getAttribute("style");

					if (style && curParentInfo.sampleItem != null && curElList.length > 0) {
						curElList[0].setAttribute(UiDefine.DATA_SAMPLE_STYLE, style);
					}

					// 2. node 에 자식이 더 있다면, 그 자식들도 재귀적으로 함수를 호출하여 DOM 을 생성함
					if (curElList.length > 0 &&
						curNode.firstElementChild && !CommonFrameUtil.isEndsWith(nodeName, "Item")) {
						curParentInfo.parentNode = curNode;

						if (curNode.getAttribute("nonExec") === "true") {
							curParentInfo.nonExec = true;
						}
						if (curNode.hasAttribute("valueKey")) {
							curParentInfo.valueKey = curNode.getAttribute("valueKey");
						}

						parentEl = boxEl || curElList[curElList.length - 1];

						if (sampleItemAttr && _cachedParentElObj.el == null) {
							_cachedParentElObj.el = curParentInfo.parentEl;
							_cachedParentElObj.node = curNode;
						}

						curParentInfo.parentEl = parentEl;
						curParentInfo.parentElList = curElList;

						childElList = _convertChildDom(curNode, curParentInfo);

						if (childElList.length > 0) {
							_appendChildElList(parentEl, childElList);
						} else if (curParentInfo.deleteIfHasNotChild) {
							// child 가 없다면 현재 curElList 도 삭제처리 (sampleWrap 제외)
							if (parentEl && !CommonFrameUtil.hasClass(parentEl, UiDefine.SAMPLE_WRAP_POST_FIX)) {
								curElList = [];
							}
						}
					}

					curValueKey = curParentInfo.valueKey || curNode.getAttribute("valueKey") || "";

					// sample 관련 처리
					if (sampleItemAttr && sampleItemAttr !== "false") {
						if (_cachedParentElObj.el) {
							if (_cachedParentElObj.node === curNode) {
								curParentInfo.parentEl = _cachedParentElObj.el;
								_cachedParentElObj = {};
							} else {
								console.info("[Warning] Already exist sampleItem at ancestor node.");
							}
						}

						customKey = (sampleItemAttr === "true") ? null : sampleItemAttr.replace(/[ ]/g, "");
						_setSampleItemMap(curElList, curParentInfo, curValueKey, customKey);
					} else {
						if (sampleItemAttr === "false") {
							_cacheParentRef(curParentInfo.parentEl, curParentInfo);
						}

						if (curElList.length > 0) {
							lastEl = elList[elList.length - 1];
							curEl = curElList[curElList.length - 1];

							if (rootNodeName !== UiDefine.DOCUMENT_MENU_ID && _isLine(curEl)) {
								if (!lastEl) {
									parentElList = curParentInfo.parentElList;
									lastElToParent = parentElList && parentElList[parentElList.length - 1];

									// 부모 노드리스트의 마지막 el 이
									// 결과가 없거나, container 노드이거나, line 이고,
									// 자기 자신이 line 이면 자신의 convert 결과를 추가하지 않음.
									if (!lastElToParent || _isContainerView(lastElToParent)
											|| _isLine(lastElToParent) || curElList.length === 1) {
										doConcatList = false;
									}
								} else {
									isLineToLastEl = _isLine(lastEl);

									if (isLineToLastEl) {
										doConcatList = false;
									}
								}
							}

							if (doConcatList) {
								elList = elList.concat(curElList);
							} else {
								doConcatList = true;
							}
						}
					}
				}

				if (name) {
					// insertAfter
					insertNodes = _getCustomXmlNodes(customXmlObj, "insertAfter", name, true, true);
					if (insertNodes && insertNodes.length) {
						customXmlObj.isNewNode = true;
						curParentInfo.parentElList = elList;
						childElList = _convertChildDom(insertNodes[insertNodes.length - 1], parentInfo);
						elList = elList.concat(childElList);
					}
				}
			}

			// 현재 level 시작시점에 있던 refItem 으로 복구
			_curRefItem = curRefItem;
			curNode = nextNode;
		}

		// line 은 1 Depth 까지만 지원하기 때문에, elList 가 1개 이면서 line 일 경우는
		// custom 으로 추가한 경우밖에 없음.
		lastEl = elList.length > 1 && elList[elList.length - 1];

		if (lastEl && rootNodeName !== UiDefine.DOCUMENT_MENU_ID) {
			idx = elList.length - 1;

			while (_isLine(lastEl) || UiUtil.isMessageArea(lastEl) || UiUtil.isHidden(lastEl)) {
				if (_isLine(lastEl)) {
					if (doLineHidden) {
						CommonFrameUtil.addClass(lastEl, _hideViewClass);
					} else {
						elList.splice(idx, 1);
					}
				} else {
					doLineHidden = !UiUtil.isMessageArea(lastEl);
				}

				lastEl = elList[--idx];
			}
		}

		return elList;
	}

	function _convertPanelToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName, parentInfo);

		var type = _getType(node),
			name = _getName(node),
			attrHeight = node.getAttribute("height"),
			attrBorder = node.getAttribute("border"),
			matchType = node.getAttribute("matchType"),
			childElArr = [],
			addViewMap = false,
			isListBox = false,
			isOnLink = node.getAttribute("onLink"),
			isMenuBox = node.getAttribute("menuBox"),
			isFocusablePanel = node.getAttribute("focusablePanel"),
			iconArea = node.getAttribute("iconArea"),
			layout = node.getAttribute("layout"),
			rootNodeName = parentInfo.rootNodeName,
			el, panelEl, boxEl, wrapEl, extendClassName, attrWidth, refTarget, newRefItem, descEl, iconAttr,
			attrObj, btnEl, btnWrapEl, overflowAttr, svgIcons, iconSize, dataSize, caption,
			isSetMatch, refName, noNameStr;

		if (!!attrBorder) {
			extendClassName = UiDefine.VIEW_BORDER_PREFIX + "_" + attrBorder;
		}

		if (type === "title") {
			extendClassName = _concatClassName(extendClassName, UiDefine.PROPERTY_TITLE_CLASS);

			if (rootNodeName === "titleBar") {
				parentInfo.deleteIfHasNotChild = true;
				attrObj = _addUiCommandToAttrObj(_uiCommandNames.TITLE_BAR, name);

				if (node.getAttribute("shortcutArea") === "false") {
					className = _concatClassName(className, UiDefine.SHORTCUT_AREA_NONE);
				}
			}

			descEl = _createDomEl("span");

			if (name === UiDefine.COLLABO_USERS_VIEW) {
				_cachedDescToCollabo[_showXmlTagToID[rootNodeName]] = descEl;
			}

			el = _appendChildNode(_createDomEl("div", {className: extendClassName}, attrObj), descEl);

			if (isMenuBox !== "false") {
				boxEl = _createDomEl("div", {className: _concatClassName(className, UiDefine.BOX_ELEMENT_CLASS)});
			}

			className = name ? name + "_view" : "";
			if (node.getAttribute("control") === "true") {
				el.setAttribute(_dataUiCommand, UiDefine.UI_COMMAND_NAME.FOLD);
				el.setAttribute(_dataUiValue, name);

				btnEl = _createDomEl("div", {className: UiDefine.TITLE_PANEL_VIEW_MODE_BUTTON_CLASS});

				if (rootNodeName === "sideBar" && name === UiDefine.COLLABO_USERS_VIEW) {
					svgIcons = _svg_icon_html[_skinName] ? _svg_icon_html[_skinName].VIEW_CONTROL_TOP : null;

					if (svgIcons) {
						btnEl = $(svgIcons)[0];
					}
				}

				btnWrapEl = _appendChildNode(_createDomEl("div", {className: _viewControlClass}), btnEl);

				el = _appendChildNode(el, btnWrapEl);
			}

			className = _concatClassName(className, UiDefine.TITLE_PANEL_WRAP_CLASS);

			attrObj = _getCustomDataAttrObject(node, {"name": name});
			if (rootNodeName === "sideBar") {
				addViewMap = true;
				if (name !== UiDefine.NO_COLLABO_USERS_VIEW) {
					className = _concatClassName(className, _hideViewClass);
				}
			}
			wrapEl = _createDomEl("div", {className: className}, attrObj);

			_setMarginPaddingStyle(node, wrapEl);
			_setMarginPaddingStyle(node, boxEl, true);

			el = _appendChildNode(wrapEl, [ el, boxEl ]);

			if (isMenuBox === "false") {
				boxEl = wrapEl;
			}
		} else if (type === "subtitle") {
			extendClassName = _concatClassName(extendClassName, UiDefine.PROPERTY_SUBTITLE_CLASS);
			descEl = _createDomEl("span");
			el = _appendChildNode(_createDomEl("div", {className: extendClassName}), descEl);

			if (isMenuBox !== "false") {
				boxEl = _createDomEl("div", {className: _concatClassName(className, UiDefine.BOX_ELEMENT_CLASS)});
			}

			className = name ? name + "_view" : "";
			if (node.getAttribute("control") === "true") {
				el.setAttribute(_dataUiCommand, UiDefine.UI_COMMAND_NAME.FOLD);
				el.setAttribute(_dataUiValue, name);

				btnEl = _createDomEl("div", {className: UiDefine.SUBTITLE_PANEL_VIEW_MODE_BUTTON_CLASS});
				btnWrapEl = _appendChildNode(_createDomEl("div", {className: _viewControlClass}), btnEl);
				el = _appendChildNode(el, btnWrapEl);
			}

			className = _concatClassName(className, UiDefine.SUBTITLE_PANEL_WRAP_CLASS);

			attrObj = _getCustomDataAttrObject(node, {"name": name});
			wrapEl = _createDomEl("div", {className: className}, attrObj);

			_setMarginPaddingStyle(node, wrapEl);
			_setMarginPaddingStyle(node, boxEl, true);

			el = _appendChildNode(wrapEl, [ el, boxEl ]);

			if (isMenuBox === "false") {
				boxEl = wrapEl;
			}
		} else if (type === "subgroup") {
			parentInfo.layout = null;

			el = _createDomEl("a", {className: UiDefine.SUB_GROUP_TITLE_CLASS});

			if (node.getAttribute("shortcutArea") === "false") {
				className = _concatClassName(className, UiDefine.SHORTCUT_AREA_NONE);
			}

			className = _concatClassName(className, UiDefine.SUB_GROUP_BOX_ELEMENT_CLASS);

			if (layout === "buttonGrid") {
				dataSize = node.getAttribute("dataSize");
			} else if (layout === "multiListItem") {
				className = _concatClassName(className, UiDefine.DROPDOWN_LAYOUT_MULTI_LIST_ITEM_CLASS);
			}

			boxEl = _createDomEl("div", {className: className});

			if (dataSize && CommonFrameUtil.isNumber(dataSize)) {
				boxEl.style.setProperty("width", dataSize + "px");
			}

			iconSize = node.getAttribute("iconSize") || parentInfo.iconArea;

			if (iconSize === "none") {
				iconSize = "";
			}

			iconAttr = node.getAttribute("icon");
			if (iconAttr !== "false" || iconSize) {
				childElArr[0] = _createDomEl("div", {className: _getIconClassName(parentInfo.name)});

				if (iconSize) {
					_setIconSize(el, childElArr[0], iconSize);

					if (iconAttr === "false") {
						// iconSize 지정으로 인해 icon DOM 생성한 경우, no_icon class 지정 (아이콘 사용유무 구분)
						CommonFrameUtil.addClass(el, UiDefine.NO_ICON_CLASS);
					}
				}
			}

			descEl = _createDomEl("span");
			childElArr[childElArr.length] = descEl;
			el = _appendChildNode(el, childElArr);

			className = name;
			className = _concatClassName(className, UiDefine.SUB_GROUP_ELEMENT_CLASS);
			attrObj = _getCustomDataAttrObject(node, {"name": name});
			wrapEl = _createDomEl("div", {className: className}, attrObj);

			_setMarginPaddingStyle(node, wrapEl);
			_setMarginPaddingStyle(node, boxEl, true);

			parentInfo.subgroupWrapNode = boxEl;
			refTarget = wrapEl;
			el = _appendChildNode(wrapEl, [ el, boxEl ]);
		} else {
			if (nodeName === "listBox") {
				isListBox = true;
				parentInfo.toggleButtons = "switch";
				className = _concatClassName(className, UiDefine.FOCUSABLE_CLASS);
			}

			if (rootNodeName === "titleBar" && name === UiDefine.COLLABO_USERS_VIEW) {
				className = _concatClassName(className, _hideViewClass);
			}

			if (node.getAttribute("shortcutArea") === "false") {
				className = _concatClassName(className, UiDefine.SHORTCUT_AREA_NONE);
			}

			if (!!attrBorder) {
				extendClassName = _concatClassName(className, UiDefine.VIEW_BORDER_PREFIX + "_" + attrBorder);
			}

			attrObj = _getCustomDataAttrObject(node);

			if (isOnLink) {
				descEl = _createOnLinkAnchor(node);
				el = _createDomEl("div", { className: extendClassName || className }, attrObj);
				el = _appendChildNode(el, descEl);
			} else {
				descEl = _createDomEl("div", { className: extendClassName || className }, attrObj);
				el = descEl;
			}

			_setMarginPaddingStyle(node, el);
			_setMarginPaddingStyle(node, el, true);

			overflowAttr = node.getAttribute("overflowScroll");

			if (overflowAttr) {
				if (overflowAttr === "x") {
					el.style.setProperty("overflow-x", "auto");
					el.style.setProperty("overflow-y", "hidden");
				} else if (overflowAttr === "y") {
					el.style.setProperty("overflow-x", "hidden");
					el.style.setProperty("overflow-y", "auto");
				} else if (overflowAttr === "all") {
					el.style.setProperty("overflow", "auto");
				}
			}

			if (type === "inline") {
				attrWidth = node.getAttribute("width");
				if (_hasScrollContainerArr.indexOf(parentInfo.rootNodeName) === -1
					&& (parentInfo.parentNode.nodeName !== "panel" || _getType(parentInfo.parentNode) !== "normal")) {
					// inline panel 이 normal panel 내부에 있지 않은 경우 log 출력 (가로 scroll 있는 container 제외)
					console.log("[Error] The" + (name ? " '" + name + "'" : "")
						+ " inline panel should be wrapped in a normal panel.");
				}

				if (attrWidth) {
					if (CommonFrameUtil.isEndsWith(attrWidth, "%")) {
						el.style.setProperty("flex", attrWidth.substring(0, attrWidth.length - 1));
					} else if (attrWidth !== "fit") {
						el.style.setProperty("flex", "inherit");
						el.style.setProperty("width", (parseFloat(attrWidth) || 0) + "px");
					} // fit 인 경우 css 에서 style 처리
				}
			}
		}

		if (node.getAttribute("fold") === "true") {
			CommonFrameUtil.addClass(el, _foldViewClassName);
		}

		_setColorStyle(node, el);

		/**
		 * TODO:
		 * panel 에 description 세팅 관련 부분은 임시 처리하는 것으로 하고,
		 * 추후 텍스트를 표현하는 위젯 개념 추가시 위치 이동해야 함.
		 */
		if (descEl) {
			_setDescription(descEl, _getDescription(node, parentInfo, "desc"), parentInfo, node);

			caption = node.getAttribute("caption");
			if (caption) {
				descEl.setAttribute(_dataTitle, caption);
				_replaceNlsCaptionValue(descEl);
			}
		}

		if (isListBox && node.hasAttribute("valueKey")) {
			el.setAttribute(_dataValueKey, node.getAttribute("valueKey"));
		}

		if (attrHeight) {
			el.style.setProperty("height", (parseFloat(attrHeight) || 0) + "px");
		}

		if (matchType) {
			el.setAttribute(UiDefine.DATA_MATCH_TYPE_ATTR, matchType);
		}

		isSetMatch = _addMatchAttribute(node, el);
		if (isSetMatch && !name && (rootNodeName === "modalDialog" || rootNodeName === "modelessDialog")) {
			noNameStr = UiDefine.NO_NAME_MATCH_PREFIX + "_" + _noNameMatchIndex++;
		}

		if (node.getAttribute("hide") === "true") {
			CommonFrameUtil.addClass(el, _hideViewClass);
		}

		if (isFocusablePanel === "true") {
			CommonFrameUtil.addClass(el, UiDefine.FOCUSABLE_PANEL_CLASS + " " + UiDefine.FOCUSABLE_CLASS);
		}

		refName = name || noNameStr;
		if (refName) {
			refTarget = refTarget || boxEl || el;
			newRefItem = UiReferrer.makeRefItem(refTarget);
			UiReferrer.appendItem(_curRefItem, newRefItem, refName, addViewMap);
			_curRefItem = newRefItem;
		}

		if (name) {
			panelEl = CommonFrameUtil.isArray(el) ? el[0] : el;
			if (panelEl) {
				UiReferrer.pushWidget(panelEl, name);
				panelEl.setAttribute(_dataName, name);

				if (_lazyPanelNames && _lazyPanelNames.indexOf(name) === -1) {
					_lazyPanelNames[_lazyPanelNames.length] = name;
				}
			}

			if (boxEl && boxEl !== panelEl && boxEl.parentNode !== panelEl) {
				// box 가 panelEl 의 하위가 아닌경우 따로 push
				UiReferrer.pushWidget(boxEl, name);
				boxEl.setAttribute(_dataName, name);
			}
		}

		if (iconArea) {
			// iconArea 있는 경우, 하위 widget 에 영향을 줌
			if (iconArea === "none") {
				// TODO: 추후 모든 button 처리가 신규 icon button style 로 전환되면 none class 지정하지 않음
				panelEl = boxEl || panelEl || (CommonFrameUtil.isArray(el) ? el[0] : el);
				CommonFrameUtil.addClass(panelEl, UiDefine.ICON_AREA_NONE);
				parentInfo.iconArea = null;
			} else {
				parentInfo.iconArea = iconArea;
			}
		}

		layout = layout || parentInfo.layout;
		if (layout) {
			parentInfo.layout = layout;

			if (layout === "buttonGrid") {
				panelEl = boxEl || panelEl || (CommonFrameUtil.isArray(el) ? el[0] : el);
				CommonFrameUtil.addClass(panelEl, UiDefine.DROPDOWN_LAYOUT_BUTTON_GRID_CLASS);
			}
		}

		return {
			el: el,
			boxEl: boxEl
		};
	}

	function _convertDialogToDom(node, className, nodeName, parentInfo) {
		_noop(node, nodeName, parentInfo);

		var childElArr = [],
			name = _getName(node),
			attrWidth = node.getAttribute("width"),
			attrObj = _getCustomDataAttrObject(node),
			el, wrapEl, btnEl, lazyConvertXmlInfo;

		if (parentInfo.lazyConverting && UiDefine.MESSAGE_DIALOG_LIST.indexOf(name) === -1) {
			/*
			 * parentInfo.lazyConverting 이 true 인 경우에 한해서 Converting 하지 않고
			 * lazyConvertXmlInfo 에 값 저장하도록 함.
			 * 이후 이 저장된 값을 수행할 때는, Converting 하도록 하기 위해,
			 * parentInfo.lazyConverting 값을 false 로 지정.
			 */
			parentInfo.lazyConverting = false;

			lazyConvertXmlInfo = UiFrameworkInfo.getInfo(UiFrameworkInfo.LAZY_CONVERT_XML_INFO) || {};
			lazyConvertXmlInfo[name] = {
				node: node,
				parentInfo: parentInfo,
				curRefItem: _curRefItem
			};

			UiFrameworkInfo.setInfo(UiFrameworkInfo.LAZY_CONVERT_XML_INFO, lazyConvertXmlInfo);
			el = null;
		} else {
			className = _concatClassName(className, _hideViewClass);
			wrapEl = _createDomEl("div", {className: _concatClassName(className, UiDefine.DIALOG_WRAP_CLASS)}, attrObj);

			childElArr[0] = _createDomEl("div", {className: UiDefine.DIALOG_BOX_ELEMENT_CLASS});

			btnEl = _createDomEl("div",
				{className: UiDefine.CLOSE_BTN_CLASS}, _addUiCommandToAttrObj(UiDefine.UI_COMMAND_NAME.HIDE, name));

			className = _viewControlClass;
			if (node.getAttribute("control") !== "true") {
				className = _concatClassName(className, _hideViewClass);
			}

			childElArr[1] = _appendChildNode(_createDomEl("div", {className: className}), btnEl);

			el = _appendChildNode(wrapEl, childElArr);

			if (attrWidth) {
				attrWidth = parseFloat(attrWidth) || 0;
				el.style.setProperty("width", attrWidth + "px");
				el.style.setProperty("margin-left", -(attrWidth / 2) + "px");
			}

			_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name, true);
		}

		return {
			el: el,
			boxEl: childElArr[0]
		};
	}

	function _convertToolToDom(node, className, nodeName, parentInfo) {
		_noop(node, nodeName, parentInfo);

		var name = _getName(node),
			el = _createDomEl("div", {className: className});

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name, true);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertComboToDom(node, className, nodeName, parentInfo) {
		_noop(node, nodeName);

		var attrBorder = node.getAttribute("border"),
			defaultValue = node.getAttribute("defaultValue"),
			arrowDirection = node.getAttribute("arrowDirection") || "down",
			matchType = node.getAttribute("matchType"),
			direction = node.getAttribute("direction"),
			rootNodeName = parentInfo.rootNodeName,
			extendClassName, el;

		if (node.getAttribute("type") !== "input"
			&& (rootNodeName === "modalDialog" || rootNodeName === "modelessDialog")) {
			className = _concatClassName(className, UiDefine.FOCUSABLE_CLASS);
		}

		if (!!attrBorder) {
			extendClassName = _concatClassName(className, UiDefine.VIEW_BORDER_PREFIX + "_" + attrBorder);
		}

		el = _setMarginPaddingStyle(node, _createDomEl("div", {className : extendClassName || className}));

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), parentInfo.commandName);

		if (node.hasAttribute("match")) {
			_addMatchAttribute(node, el);
		}
		_addWidgetAttribute(node, el, parentInfo);
		el.setAttribute(UiDefine.DATA_ARROW_DIRECTION, arrowDirection);

		if (matchType) {
			el.setAttribute(UiDefine.DATA_MATCH_TYPE_ATTR, matchType);
		}

		if (defaultValue) {
			parentInfo.defaultValue = defaultValue;
		}

		if (direction) {
			parentInfo.direction = direction;
		}

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertDropdownToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName);

		var type = _getType(node),
			name = _getName(node),
			dataSize = node.getAttribute("dataSize"),
			attrBorder = node.getAttribute("border"),
			matchType = node.getAttribute("matchType"),
			boxClass = UiDefine.DROPDOWN_BOX_WRAP_CLASS,
			childElArr = [],
			commandName = parentInfo.commandName,
			isComboChild = (parentInfo.parentNode.nodeName === "combo"),
			defaultValue = node.getAttribute("defaultValue"),
			direction = parentInfo.direction || node.getAttribute("direction"),
			valueKey = parentInfo.valueKey || node.getAttribute("valueKey"),
			arrowDirection = node.getAttribute("arrowDirection") || "down",
			arrowClass = UiDefine.BTN_COMBO_ARROW_CLASS + " " + UiDefine.ARROW_DIRECTION_PREFIX + "_" + arrowDirection,
			unit = node.getAttribute("unit"),
			rootNodeName = parentInfo.rootNodeName,
			iconArea = node.getAttribute("iconArea"),
			layout = node.getAttribute("layout"),
			iconName = parentInfo.name,
			el, descEl, elChild, boxEl, extendClassName, sizeValue, contentsAnchor, dropdownAnchor;

		if (defaultValue) {
			parentInfo.defaultValue = defaultValue;
		}

		if (iconArea) {
			parentInfo.iconArea = (iconArea === "none") ? null : iconArea;
		}

		if (isComboChild) {
			type = _getType(parentInfo.parentNode);

		} else {
			if (type === "text") {
				_setUnitInfo(node, parentInfo);
			}

			if (rootNodeName === "modalDialog" || rootNodeName === "modelessDialog") {
				className = _concatClassName(className, UiDefine.FOCUSABLE_CLASS);
			}

			if (!!attrBorder) {
				extendClassName = _concatClassName(className, UiDefine.VIEW_BORDER_PREFIX + "_" + attrBorder);
			}
			el = _createDomEl("div", {className : extendClassName || className});
			if (valueKey) {
				el.setAttribute(_dataValueKey, valueKey);
			}
			el.setAttribute(UiDefine.DATA_ARROW_DIRECTION, arrowDirection);

			if (matchType) {
				el.setAttribute(UiDefine.DATA_MATCH_TYPE_ATTR, matchType);
			}
		}

		className = null;
		boxClass = _concatClassName(boxClass, UiDefine.DROPDOWN_SELECT_LIST_WRAP_CLASS);

		if (type === "color" || type === "colorWithIcon") {
			boxClass = _concatClassName(boxClass, UiDefine.DROPDOWN_COLOR_PICKER_WRAP_CLASS);
			boxClass = _concatClassName(boxClass, UiDefine.DROPDOWN_LAYOUT_CUSTOM_CLASS);
			dataSize = node.getAttribute("dataSize") || "large";
			layout = "custom";

			if (type === "colorWithIcon") {
				childElArr[0] = _createDomEl("div", {className: _getIconClassName(iconName)});
				childElArr[0].appendChild(_createDomEl("span", {className: UiDefine.SELECTED_COLOR_CLASS}));
			} else { // type === "color"
				if (node.getAttribute("icon") !== "false") {
					childElArr[0] = _createDomEl("div", {className: _getIconClassName(iconName)});
				}
				className = UiDefine.SELECTED_COLOR_CLASS;
			}

			if (!parentInfo.defaultValue) {
				parentInfo.defaultValue = "transparent";
			}

		} else {
			if (node.getAttribute("icon") !== "false" && type !== "arrow") {
				childElArr[0] = _createDomEl("div", {className: _getIconClassName(iconName)});
			}

			if (layout === "buttonGrid") {
				boxClass = _concatClassName(boxClass, UiDefine.DROPDOWN_LAYOUT_BUTTON_GRID_CLASS);
			} else if (layout === "custom") {
				boxClass = _concatClassName(boxClass, UiDefine.DROPDOWN_LAYOUT_CUSTOM_CLASS);
			} else if (layout === "multiListItem") {
				boxClass = _concatClassName(boxClass, UiDefine.DROPDOWN_LAYOUT_MULTI_LIST_ITEM_CLASS);

				if (node.getAttribute("shortcutArea") === "false") {
					boxClass = _concatClassName(boxClass, UiDefine.SHORTCUT_AREA_NONE);
				}

				/**
				 * multiListItem layout 인 경우, Box 너비는 자동으로 늘어나도록 하기 때문에
				 * Box 너비를 지정하는 속성인 dataSize 는 지정했더라도 사용하지 않도록 함
				 */
				dataSize = null;
			}
		}

		boxClass = _concatClassName(boxClass, _xmlAttrToClassCommon.textAlign[node.getAttribute("textAlign")]);
		boxEl = _createDomEl("div", {className:boxClass});
		boxEl.setAttribute("title", "");

		parentInfo.layout = layout;

		if (dataSize) {
			sizeValue = _xmlAttrToClassCommon.size[dataSize];

			if (sizeValue) {
				CommonFrameUtil.addClass(boxEl, sizeValue);
			} else if (CommonFrameUtil.isNumber(dataSize)) {
				boxEl.style.setProperty("width", dataSize + "px");
			}
		}

		dropdownAnchor = _createDomEl("a", {className: arrowClass}, _addUiCommandToAttrObj(_uiCommandNames.DROPDOWN, name));
		elChild = [dropdownAnchor, boxEl];

		if (UiDefine.HAS_WIDGET_COMBO_TYPE_ARR.indexOf(type) === -1) {
			descEl = _createDomEl("span", {className: className});
			_setDescription(descEl, _getDescription(node, parentInfo, "desc"), parentInfo, node);

			if (direction === "vertical") {
				_appendChildNode(dropdownAnchor, descEl);
			} else {
				childElArr[childElArr.length] = descEl;
			}

			if (isComboChild) {
				contentsAnchor = _createDomEl("a", null, _addToggleButtonsToAttrObj(parentInfo));
				_addCommandAttributes(node, contentsAnchor, parentInfo);
			} else {
				contentsAnchor = _createDomEl("a", null, _addUiCommandToAttrObj(_uiCommandNames.DROPDOWN, name));
				CommonFrameUtil.addClass(el, UiDefine.HAS_DESCRIPTION_CLASS);
			}

			if (rootNodeName === "titleBar" && node.getAttribute("name") === UiDefine.COLLABO_USERS_LIST) {
				_cachedDescToCollabo[_showXmlTagToID[rootNodeName]] = contentsAnchor;
			}

			if (childElArr.length) {
				contentsAnchor = _appendChildNode(contentsAnchor, childElArr);
			}
			elChild.unshift(contentsAnchor);
		}

		parentInfo.toggleButtons = "switch";

		if (!isComboChild) {
			_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), commandName);

			// dropdown 은 unit 정보를 따로 관리하므로, widget 공통 data-attribute 로 사용하지는 않음
			node.removeAttribute("unit");

			if (node.hasAttribute("match")) {
				_addMatchAttribute(node, el);
			}
			_addWidgetAttribute(node, el, parentInfo);

			el = _appendChildNode(el, elChild);
			parentInfo.subgroupWrapNode = el;

		} else {
			el = elChild;
			parentInfo.subgroupWrapNode = parentInfo.parentEl;
		}

		if (CommonFrameUtil.isString(unit)) {
			// 이하 data 에서 기본적으로 이 unit 사용
			parentInfo.unit = unit;
		}

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: boxEl
		};
	}

	function _convertTitleBarToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.TITLE_BAR_ID,
			el = _getCreateContainerDomEl(node, name),
			titleBarNavEl;

		// resize 등의 상황에서 title bar 의 이동을 위한 navigation btn 생성
		titleBarNavEl = _createScrollArrowGroup(_concatClassName(UiDefine.NAV_BOX_CLASS, _hideViewClass),
			UiDefine.TITLE_BAR_SCROLL_CLASS);

		if (titleBarNavEl) {
			el = _appendChildNode(el, titleBarNavEl);
		}

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertMenuBarToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.MENU_BAR_ID,
			el = _getCreateContainerDomEl(node, name),
			svgIcons = _svg_icon_html[_skinName] ? _svg_icon_html[_skinName].VIEW_CONTROL_TOP : null,
			btnWrapEl, btnEl, menuBarNavEl, attrObj;

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		if (node.getAttribute("control") === "true") {
			attrObj = _addUiCommandToAttrObj(UiDefine.UI_COMMAND_NAME.FOLD, name);
			attrObj[_dataTitle] = "{FoldUnfold}";

			btnEl = _createDomEl("div", {className: UiDefine.MENU_BAR_VIEW_MODE_BUTTON_CLASS}, attrObj);

			if (svgIcons) {
				btnEl = _appendChildNode(btnEl, $(svgIcons)[0]);
			}

			btnWrapEl = _appendChildNode(_createDomEl("div", {className: _viewControlClass}), btnEl);

			if (node.getAttribute("fold") === "true") {
				CommonFrameUtil.addClass(el, _foldViewClassName);
			}

			el = _appendChildNode(el, btnWrapEl);
			_replaceNlsCaptionValue(btnEl);
		}

		// resize 등의 상황에서 menu bar 의 이동을 위한 navigation btn 생성
		menuBarNavEl = _createScrollArrowGroup(_concatClassName(UiDefine.NAV_BOX_CLASS, _hideViewClass),
			UiDefine.MENU_BAR_SCROLL_CLASS);

		if (menuBarNavEl) {
			el = _appendChildNode(el, menuBarNavEl);
		}

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertStyleBarToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.STYLEBAR_ID,
			el = _getCreateContainerDomEl(node, name),
			styleBarNavEl;

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		// resize 등의 상황에서 style bar 의 이동을 위한 navigation btn 생성
		styleBarNavEl = _createScrollArrowGroup(_concatClassName(UiDefine.NAV_BOX_CLASS, _hideViewClass),
			UiDefine.STYLE_BAR_SCROLL_CLASS);

		if (styleBarNavEl) {
			el = _appendChildNode(el, styleBarNavEl);
		}

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertSideBarToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.SIDEBAR_ID,
			el = _getCreateContainerDomEl(node, name),
			svgIcons = _svg_icon_html[_skinName] ? _svg_icon_html[_skinName].VIEW_CONTROL_RIGHT : null,
			btnWrapEl, btnEl, attrObj;

		if (node.getAttribute("control") === "true") {
			attrObj = _addUiCommandToAttrObj(UiDefine.UI_COMMAND_NAME.FOLD, name);
			attrObj[_dataTitle] = "{FoldUnfold}";

			btnEl = _createDomEl("div", {className: UiDefine.SIDE_BAR_VIEW_MODE_BUTTON_CLASS}, attrObj);

			if (svgIcons) {
				btnEl = _appendChildNode(btnEl, $(svgIcons)[0]);
			}

			// sidebar fold control 은 "taskpane" 과 동일하게 widgetMap 에 등록 (비활성화, 활성화 동시 적용)
			UiReferrer.pushWidget(btnEl, UiDefine.EVENT_ACTION_NAMES.U_TASKPANE);

			btnWrapEl = _appendChildNode(_createDomEl("div", {className: _viewControlClass}), btnEl);

			if (node.getAttribute("fold") === "true") {
				CommonFrameUtil.addClass(el, _foldViewClassName);
			}

			el = _appendChildNode(el, btnWrapEl);
			_replaceNlsCaptionValue(btnEl);
		}

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertContextMenuToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.CONTEXT_MENU_ID,
			el = _getCreateContainerDomEl(node, name, true);

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertDocumentToDom(node, className, nodeName, parentInfo) {
		_noop(className, nodeName, parentInfo);

		var name = UiDefine.DOCUMENT_MENU_ID,
			el = _getCreateContainerDomEl(node, name);

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	function _convertCommandItemToDom(node, className, nodeName, parentInfo) {
		_noop(className);

		var name = _getName(node),
			commandNode = _getNodeByXmlItem(nodeName, name, node),
			el, actionCommand, toggleButtons, useValue, commandsWidgetIdxMap, commandWidgetsIdxArr, idx, i, len;

		if (commandNode) {
			commandNode = commandNode.cloneNode(true);
			_overrideAttribute(commandNode, node);

			actionCommand = commandNode.getAttribute("actionCommand");
			if (actionCommand) {
				commandNode.setAttribute("name", actionCommand);
				name = actionCommand;
			}

			parentInfo.commandName = name;

			if (node.getAttribute("captionVisible") === "false") {
				parentInfo.captionVisible = false;
			}

			parentInfo.disable = (commandNode.getAttribute("disable") === "true");

			toggleButtons = commandNode.getAttribute("toggleButtons");
			if (_toggleButtonsValueArr.indexOf(toggleButtons) !== -1) {
				// set toggle
				parentInfo.toggleButtons = toggleButtons;
			}

			useValue = commandNode.getAttribute("useValue");
			if (useValue) {
				// 아직 해당 commandItem 의 index 할당되지 않은 경우 name 할당
				parentInfo.commandItemIdx = _commandLastIdxInfo[useValue] || name;

			} else {
				commandsWidgetIdxMap = UiReferrer.getWidgetGroup(_commandWidgetsIdxGroupName);
				commandWidgetsIdxArr = commandsWidgetIdxMap && commandsWidgetIdxMap[name];
				idx = commandWidgetsIdxArr ? commandWidgetsIdxArr.indexOf(name) : -1;
				if (idx > -1) {
					// name 이 할당돼 있는 idx 를 현재 idx 로 치환
					len = commandWidgetsIdxArr.length;
					for (i = idx; i < len; i++) {
						if (commandWidgetsIdxArr[i] === name) {
							commandWidgetsIdxArr[i] = _commandItemIdx;
						}
					}
				}

				parentInfo.commandItemIdx = _commandItemIdx;
				_commandLastIdxInfo[actionCommand || name] = _commandItemIdx;
			}

			if (!commandNode.firstElementChild) {
				el = _createIconButton(commandNode, parentInfo);
				_addWidgetAttribute(commandNode, el, parentInfo);
				_addCommandAttributes(commandNode, el, parentInfo);
			} else {
				_overrideAttributeToChild(commandNode, commandNode);
				el = _convertChildDom(commandNode, parentInfo);
			}
			_commandItemIdx++;
		} else {
			console.log("[Error] Command : " + name + " is not found.");
		}

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	function _convertSeparatorToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName, parentInfo);

		var attrDir = node.getAttribute("direction") || "horizontal",
			marginStyleArr = _getMarginPaddingStyleArray(node),
			el, childEl;

		if (node.getAttribute("line") === "true") {
			if (attrDir === "horizontal") {
				el = _createDomEl("div", {className: UiDefine.HORIZONTAL_LINE_SEPARATOR_CLASS});

				if (marginStyleArr) {
					el.style.setProperty("margin", marginStyleArr.join(" "));
				}
			} else {
				el = _createDomEl("div", {className: UiDefine.VERTICAL_LINE_SEPARATOR_WRAP_CLASS});
				childEl = _createDomEl("div", {className: UiDefine.VERTICAL_LINE_SEPARATOR_CLASS});

				if (marginStyleArr) {
					childEl.style.setProperty("top", marginStyleArr[0]);
					el.style.setProperty("margin-right", marginStyleArr[1]);
					childEl.style.setProperty("bottom", marginStyleArr[2]);
					el.style.setProperty("margin-left", marginStyleArr[3]);
				}
			}

			if (childEl) {
				el = _appendChildNode(el, childEl);
			}
		} else {
			className = (attrDir === "horizontal") ? UiDefine.HORIZONTAL_NO_LINE_SEPARATOR_CLASS : "";
			el = _createDomEl("div", {className : className});

			_setDescription(el, _getDescription(node, parentInfo, "desc"), parentInfo, node);

			if (marginStyleArr) {
				el.style.setProperty("margin", marginStyleArr.join(" "));
			}
		}

		if (node.getAttribute("hide") === "true") {
			CommonFrameUtil.addClass(el, _hideViewClass);
		}

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertPanelGroupItemToDom(node, className, nodeName, parentInfo) {
		_noop(node);

		var panelGroupNode = _getNodeByXmlItem(nodeName, _getName(node), node),
			el;

		if (panelGroupNode) {
			el = _convertChildDom(panelGroupNode, parentInfo);
		} else {
			console.log("[Error] PanelGroup : " + className + " is not found.");
		}

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertInputToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName);

		var parentNode = parentInfo.parentNode,
			attrBorder = node.getAttribute("border"),
			unitClass = UiDefine.UNIT_CLASS,
			el, descVal, textIconVal, descEl, childElArr, extendClassName, unit, inputEl, spinnerWrapEl, spinnerElArr;

		if (!!attrBorder) {
			extendClassName = _concatClassName(className, UiDefine.VIEW_BORDER_PREFIX + "_" + attrBorder);
		}

		_setUnitInfo(node, parentInfo);

		if (parentNode.nodeName === "combo" && _getType(parentNode) === "input") {
			el = _createDomEl("a", {className : extendClassName || className});
			parentInfo.subgroupWrapNode = parentInfo.parentEl;
		} else {
			el = _createDomEl("div", {className : extendClassName || className});
		}

		className = _concatClassName(UiDefine.INPUT_BOX_CLASS, UiDefine.FOCUSABLE_CLASS);

		//inputEl에 브라우저 자동완성 해제 속성 추가
		inputEl = _createDomEl("input", {type: _getType(node, "text"), className: className}, {autocomplete: "off"});
		childElArr = [inputEl];

		descVal = _getDescription(node, parentInfo, "desc");

		if (descVal) {
			// input 의 desc 는 placeholder 로 변경
			inputEl.setAttribute(_dataPlaceHolder, descVal);
			_replaceNlsCaptionValue(childElArr);
		}

		_addMatchAttribute(node, inputEl);

		textIconVal = _getDescription(node, parentInfo, "textIcon");

		if (textIconVal) {
			descEl = _createDomEl("div", {className: UiDefine.INPUT_TEXT_ICON_CLASS});
			_setDescription(descEl, textIconVal, parentInfo, node);
			childElArr.unshift(descEl);

		} else if (node.getAttribute("icon") !== "false") {
			childElArr.unshift(_createDomEl("div", {className: _getIconClassName(parentInfo.name)}));
		}

		unit = node.getAttribute("unit") || "";
		if (!unit) {
			unitClass = _concatClassName(unitClass, _hideViewClass);
		}
		childElArr[childElArr.length] = _createDomEl("span", {textContent: unit, className: unitClass});

		if (node.getAttribute("spinner") === "true") {
			spinnerWrapEl = _createDomEl("span", {className: UiDefine.SPINNER_WRAP_CLASS});

			spinnerElArr = [_createDomEl("span", {className: UiDefine.SPINNER_UPPER_ARROW_CLASS}),
				_createDomEl("span", {className: UiDefine.SPINNER_LOWER_ARROW_CLASS})];

			_addCommandAttributes(node, spinnerElArr[0], parentInfo);
			_addCommandAttributes(node, spinnerElArr[1], parentInfo);
			childElArr[childElArr.length] = _appendChildNode(spinnerWrapEl, spinnerElArr);
		}

		// input 은 unit 정보를 따로 관리하므로, widget 공통 data-attribute 로 사용하지는 않음
		node.removeAttribute("unit");

		_addWidgetAttribute(node, el, parentInfo);
		_addCommandAttributes(node, el, parentInfo);
		el = _appendChildNode(el, childElArr);
		_addDefaultValue(node, el, parentInfo);

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	function _convertDataToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName);

		var layout = parentInfo.layout,
			subgroupWrapNode = parentInfo.subgroupWrapNode,
			el, attrObj, parentDefaultValue, iconSize;

		if (layout === "buttonGrid" || layout === "multiListItem"
			|| CommonFrameUtil.hasClass(subgroupWrapNode, UiDefine.SUB_GROUP_BOX_ELEMENT_CLASS)
			|| _listTypeMenuArr.indexOf(parentInfo.rootNodeName) !== -1) {
			/**
			 * buttonGrid, multiListItem layout 인 경우,
			 * 또는 listType 으로 처리되어야 하는 container 나 subgroup 인 경우,
			 * 이하 data 를 button 으로 converting 한다.
			 **/
			el = _createIconButton(node, parentInfo);

		} else {
			iconSize = node.getAttribute("iconSize") || parentInfo.iconArea;

			if (iconSize === "none") {
				iconSize = "";
				parentInfo.iconArea = null;
			}

			if (iconSize) {
				// iconSize 지정돼 있거나 list 형태면 icon button 으로 converting
				el = _createIconButton(node, parentInfo);

			} else {
				// default (list_view)
				attrObj = _addToggleButtonsToAttrObj(parentInfo);
				el = _createDomEl("div", {className:className}, attrObj);
				_setDescription(el, _getDescription(node, parentInfo, "desc"), parentInfo, node);
			}
		}

		parentDefaultValue = parentInfo.defaultValue;
		if ((!parentDefaultValue && node.getAttribute("selected") === "true")
			|| (parentDefaultValue && parentDefaultValue === node.getAttribute("value"))) {
			// 상위에 지정돼 있으면 값이 같은 경우, 지정돼 있지 않으면 selected true 인 경우
			UiReferrer.pushWidget(el, "selected");
		}
		_addWidgetAttribute(node, el, parentInfo);
		_addCommandAttributes(node, el, parentInfo);
		_addMatchAttribute(node, el);

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	function _convertImageToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName, parentInfo);

		return {
			el: _setMarginPaddingStyle(node, _createDomEl("div", {className:className})),
			boxEl: null
		};
	}

	function _convertCheckboxToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName);

		var inputEl = _createDomEl("input", {type: "checkbox"}),
			descEl = _createDomEl("span"),
			childElArr = [inputEl, descEl],
			labelEl = _appendChildNode(_createDomEl("label"), childElArr),
			selected = (node.getAttribute("selected") === "true"),
			selectAll = (node.getAttribute("selectAll") === "true"),
			selectAllTarget = (node.getAttribute("selectAllTarget") === "true"),
			el, valueKey;

		className = _concatClassName(className, UiDefine.FOCUSABLE_CLASS);
		el = _appendChildNode(_createDomEl("div", {className:className}), labelEl);

		_setDescription(descEl, _getDescription(node, parentInfo, "desc"), parentInfo, node);

		if (selected) {
			UiReferrer.pushWidget(el, "selected");
		}

		if (node.hasAttribute("match")) {
			_addMatchAttribute(node, inputEl);

			if (!selected) {
				UiReferrer.pushWidget(el, "notCheckedMatch");
			}
		}

		if ((selectAll || selectAllTarget) && (parentInfo.nonExec || node.getAttribute("nonExec") === "true")) {
			if (selectAll) {
				UiFrameworkInfo.setSelectAllWidgetInfo(parentInfo.commandName, _commandItemIdx, inputEl, selected);
			} else if (selectAllTarget) {
				valueKey = parentInfo.valueKey || node.getAttribute("valueKey");
				UiFrameworkInfo.pushSelectAllTarget(parentInfo.commandName, _commandItemIdx, inputEl, valueKey, selected);
			}
		}

		_addWidgetAttribute(node, el, parentInfo);
		_addCommandAttributes(node, el, parentInfo);

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	function _convertButtonToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName);

		var parentNode = parentInfo.parentNode,
			type = _getType(node),
			btnEl, childEl, el, parentDefaultValue, attrBorder, tagName, commandName, move;

		if (parentNode.nodeName === "combo" && _getType(parentNode) === "resultButton") {
			className = _concatClassName(className, UiDefine.HAS_DESCRIPTION_CLASS);
			el = _createDomEl("a", {className: className});
			_setDescription(el, _getDescription(node, parentInfo, "desc"), parentInfo, node);

		} else {
			commandName = parentInfo.commandName;

			if (type === "result") {
				className = _concatClassName(className, UiDefine.RESULT_BUTTON_CLASS);
				className = _concatClassName(className, UiDefine.HAS_DESCRIPTION_CLASS);

				attrBorder = node.getAttribute("border");
				if (attrBorder) {
					className = _concatClassName(className, UiDefine.VIEW_BORDER_PREFIX + "_" + attrBorder);
				}

				if (commandName !== "e_sheet" && commandName !== "e_add_sheet") {
					className = _concatClassName(className, UiDefine.FOCUSABLE_CLASS);
				}

				tagName = (parentInfo.commandName === "e_sheet") ? "div" : "button";
				btnEl = _createDomEl(tagName, {className: className});
				childEl = _createDomEl("span");
				_setDescription(childEl, _getDescription(node, parentInfo, "desc"), parentInfo, node);

				el = _appendChildNode(btnEl, childEl);
			} else {
				el = _createIconButton(node, parentInfo);
			}

			move = node.getAttribute("move");

			if (commandName && move) {
				UiReferrer.pushWidget(el, move, _sampleItemMoveButtonGroupName);
				parentInfo.disable = true;
				_pushDisableListIfNeeded(el, parentInfo);
			}
		}

		parentDefaultValue = parentInfo.defaultValue;
		if ((!parentDefaultValue && node.getAttribute("selected") === "true")
			|| (parentDefaultValue && parentDefaultValue === node.getAttribute("value"))) {
			// 상위에 지정돼 있으면 값이 같은 경우, 지정돼 있지 않으면 selected true 인 경우
			UiReferrer.pushWidget(el, "selected");
		}
		_addWidgetAttribute(node, el, parentInfo);
		_addCommandAttributes(node, el, parentInfo);

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	function _convertSheetTabBarToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.SHEET_TAB_BAR_ID,
			el = _getCreateContainerDomEl(node, name);

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertStatusBarToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.STATUSBAR_ID,
			el = _getCreateContainerDomEl(node, name);

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertTranslateToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.TRANSLATE_ID,
			el = _createDomEl("div", {}),
			boxEl = el,
			childElArr = [],
			btnWrapEl, wrapEl;

		wrapEl = _getCreateContainerDomEl(node, name, true, UiDefine.TRANSLATE_DIR_LEFT);
		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(wrapEl), name);
		el = _appendChildNode(wrapEl, el);

		if (node.getAttribute("control") === "true") {
			childElArr[0] = _createDomEl("div", {className: UiDefine.TRANS_MODE_BUTTON_CLASS});
			childElArr[1] = _createDomEl("div", {className: UiDefine.TRANS_CLOSE_BUTTON_CLASS},
				_addUiCommandToAttrObj(UiDefine.UI_COMMAND_NAME.TOGGLE, name));

			childElArr[0].setAttribute(UiDefine.DATA_TOGGLE_CLASS_ATTR, name + ":" + UiDefine.BOTTOM_VIEW_CLASS);

			btnWrapEl = _appendChildNode(_createDomEl("div", {className: _viewControlClass}), childElArr);

			boxEl = _appendChildNode(boxEl, btnWrapEl);
		}

		return {
			el: el,
			boxEl: boxEl
		};
	}

	function _convertThumbnailToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.THUMBNAIL_ID,
			el = _getCreateContainerDomEl(node, name);

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertModalDialogToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.MODAL_DIALOG_ID,
			el = _getCreateContainerDomEl(node, name, true);

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertModelessDialogToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.MODELESS_DIALOG_ID,
			el = _getCreateContainerDomEl(node, name, true);

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertToolBoxToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.TOOL_BOX_ID,
			el = _getCreateContainerDomEl(node, name);

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertCommentBarToDom(node, className, nodeName, parentInfo) {
		_noop(node, className, nodeName, parentInfo);

		var name = UiDefine.COMMENTBAR_ID,
			el = _getCreateContainerDomEl(node, name, true),
			btnWrapEl, btnEl;

		if (node.getAttribute("control") === "true") {
			btnEl = _createDomEl("div", {className: UiDefine.CLOSE_BTN_CLASS},
				_addUiCommandToAttrObj(UiDefine.UI_COMMAND_NAME.TOGGLE, name));

			UiReferrer.pushWidget(btnEl, UiDefine.EVENT_ACTION_NAMES.U_COMMENT);

			btnWrapEl = _appendChildNode(_createDomEl("div", {className: _viewControlClass}), btnEl);

			el = _appendChildNode(el, btnWrapEl);
			_replaceNlsCaptionValue(btnEl);
		}

		_curRefItem = UiReferrer.appendItem(_curRefItem, UiReferrer.makeRefItem(el), name);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertWidgetGroupItemToDom(node, className, nodeName, parentInfo) {
		_noop(node);

		var elList = [],
			widgetGroupNode = _getNodeByXmlItem(nodeName, _getName(node), node),
			el, divEl, toggleButtons;

		if (widgetGroupNode) {
			widgetGroupNode = widgetGroupNode.cloneNode(true);
			_overrideAttribute(widgetGroupNode, node);
			_overrideAttributeToChild(widgetGroupNode, widgetGroupNode);

			toggleButtons = widgetGroupNode.getAttribute("toggleButtons");
			if (_toggleButtonsValueArr.indexOf(toggleButtons) !== -1) {
				// set toggle
				parentInfo.toggleButtons = toggleButtons;
			}

			el = _convertChildDom(widgetGroupNode, parentInfo);

			if (parentInfo.rootNodeName !== "contextMenu") {
				if (parentInfo.parentNode.nodeName === "combo") {
					el = _convertElToArray(el[0].childNodes);
				} else {
					divEl = el[0];
				}

				elList = elList.concat(el);
			} else {
				elList = elList.concat(_convertElToArray(el));
			}

			if (divEl && className) {
				className = _concatClassName(divEl.getAttribute("class"), className);
				divEl.setAttribute("class", className);
			}

		} else {
			console.log("[Error] Widget : " + className + " is not found.");
		}

		return {
			el: elList,
			boxEl: null
		};
	}

	function _convertDataSetItemToDom(node, className, nodeName, parentInfo) {
		_noop(className, nodeName);

		var dataSetName = _getName(node),
			dataSetNode = _getNodeByXmlItem(nodeName, dataSetName, node),
			elList, toggleButtons;

		if (dataSetNode) {
			dataSetNode = dataSetNode.cloneNode(true);
			_overrideAttribute(dataSetNode, node);
			_overrideAttributeToChild(dataSetNode, dataSetNode);

			toggleButtons = dataSetNode.getAttribute("toggleButtons");
			if (_toggleButtonsValueArr.indexOf(toggleButtons) !== -1) {
				// set toggle
				parentInfo.toggleButtons = toggleButtons;
			}

			elList = _convertChildDom(dataSetNode, parentInfo);
		} else {
			console.log("[Error] DataSet : " + dataSetName + " is not found.");
		}

		return {
			el: elList,
			boxEl: null
		};
	}

	function _convertProgressToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName);

		var wrapEl = _createDomEl("div", {className: className}),
			textPosition = node.getAttribute("textPosition"),
			childElArr = [],
			el;

		if (textPosition === "top") {
			childElArr[0] = _createDomEl("div", {className: UiDefine.PROGRESS_PERCENT_CLASS});
			childElArr[1] = _createDomEl("div", {className: UiDefine.PROGRESS_BAR_AREA_CLASS});
			childElArr[1] = _appendChildNode(childElArr[1],
				_createDomEl("div", {className: UiDefine.PROGRESS_BAR_CLASS}));
		} else {
			childElArr[0] = _createDomEl("div", {className: UiDefine.PROGRESS_BAR_AREA_CLASS});
			childElArr[0] = _appendChildNode(childElArr[0],
				_createDomEl("div", {className: UiDefine.PROGRESS_BAR_CLASS}));
			childElArr[1] = _createDomEl("div", {className: UiDefine.PROGRESS_PERCENT_CLASS});
		}

		el = _appendChildNode(wrapEl, childElArr);
		_addWidgetAttribute(node, el, parentInfo);

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	function _convertTemplateToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName, className);

		var name = _getName(node),
			commandName = parentInfo.commandName,
			valueKey = parentInfo.valueKey,
			nodeCommandNames = [],
			templateWrapEl, el, firstChildEl, rootEl, i, elLen,
			sampleEl, sampleItemAttr, parentEl, clonedParentInfo, commandNodes, len, commandNode, commandValue, selectedEl,
			nodeCommandName, nodeCommandWidget, nodeValueKey, nodeCommandWidgetValue, noColorEl, themeColorEl,
			findElArr, sampleDescElArr, findEl, descValue, removeElList, removeEl, sampleCommandNodes, customKey;

		if (_templateElMap[name]) {
			templateWrapEl = _templateElMap[name].cloneNode(true);
			el = templateWrapEl.children;
		}

		if (!el) {
			console.log("ERROR: " + name + " template is not found!");
			return;
		}

		findElArr = CommonFrameUtil.getCollectionToArray(templateWrapEl.querySelectorAll('[' + _dataNlsName + ']'));
		sampleDescElArr = CommonFrameUtil.getCollectionToArray(
			templateWrapEl.querySelectorAll('[' + UiDefine.DATA_SAMPLE_ITEM + '] [' + _dataNlsName + ']'));
		len = findElArr.length;

		for (i = 0; i < len; i++) {
			findEl = findElArr[i];
			descValue = FrameworkUtil.getReplaceNlsValue(findEl.getAttribute(_dataNlsName));
			_setDescription(findEl, descValue, parentInfo, node);

			if (sampleDescElArr.indexOf(findEl) === -1) {
				findEl.removeAttribute(_dataNlsName);
			}
		}

		if (commandName) {
			commandNodes = CommonFrameUtil.getCollectionToArray(
				templateWrapEl.querySelectorAll("[" + UiDefine.DATA_COMMAND + "]"));
			len = commandNodes.length;

			for (i = 0; i < len; i++) {
				commandNode = commandNodes[i];
				nodeCommandName = commandNode.getAttribute(UiDefine.DATA_COMMAND);

				if (nodeCommandName && nodeCommandName !== commandName) {
					nodeValueKey = commandNode.getAttribute(_dataValueKey);
					commandValue = commandNode.getAttribute(_dataValue);

					if (!(CommonFrameUtil.contains(nodeCommandNames, nodeCommandName)
						|| CommonFrameUtil.contains(nodeCommandNames, nodeCommandName + "_" + nodeValueKey))) {
						nodeCommandWidget = CommonFrameUtil.findParentNode(commandNode.parentNode, "." + nodeCommandName);

						if (nodeCommandWidget) {
							nodeCommandNames.push(nodeCommandName);
							_pushCommandWidget(nodeCommandWidget, nodeCommandName, commandValue, nodeValueKey, parentInfo);

							nodeCommandWidgetValue = nodeCommandWidget.getAttribute(_dataValue);

							if (nodeCommandWidgetValue === commandValue) {
								UiReferrer.pushWidget(commandNode, "selected");
							}
						}
					}
				} else {
					commandNode.setAttribute(UiDefine.DATA_COMMAND, commandName);
					if (parentInfo.nonExec) {
						commandNode.setAttribute(UiDefine.DATA_NON_EXEC, "true");
					}
					if (valueKey || commandNode.hasAttribute(_dataValueKey)) {
						// template 내부의 valueKey 등록
						if (valueKey) {
							commandNode.setAttribute(_dataValueKey, valueKey);
						} else {
							valueKey = commandNode.getAttribute(_dataValueKey);
						}
						_pushWidgetNameToValueKeyMap(commandName, valueKey);
						_pushCommandToValueKeyArrMap(commandName, valueKey);
					}
				}
			}

			if (!parentInfo.subgroupWrapNode) {
				sampleCommandNodes = CommonFrameUtil.getCollectionToArray(
					templateWrapEl.querySelectorAll("[" + UiDefine.DATA_SAMPLE_ITEM + "] [" + UiDefine.DATA_COMMAND + "]"));

				commandNodes = CommonFrameUtil.without(commandNodes, sampleCommandNodes);

				/* template 내부의 command 에 대해 reference 처리
				 * (상위에 reference 된 subgroupWrapNode 가 있거나 sample 내부는 제외) */
				len = commandNodes.length;

				for (i = 0; i < len; i++) {
					commandNode = commandNodes[i];
					commandValue = commandNode.getAttribute(_dataValue);
					if (!commandNode.hasAttribute(UiDefine.DATA_SAMPLE_ITEM) &&
						!CommonFrameUtil.isStartsWith(commandValue, "{")) {
						// JSON object value 로 된 button 은 제외 (바로 실행되어야 하며, on 되지 않는 것으로 가정)
						valueKey = parentInfo.valueKey || commandNode.getAttribute(_dataValueKey);
						_pushCommandWidget(commandNode, commandName, commandValue, valueKey, parentInfo);
					}
				}
			}

			if (parentInfo.defaultValue) {
				selectedEl = el[0].querySelector(UiUtil.getAttrSelectorStr(_dataValue, parentInfo.defaultValue));
				if (selectedEl) {
					UiReferrer.pushWidget(selectedEl, "selected");
				}
			}
		}

		if (CommonFrameUtil.isStartsWith(name, "color_picker")) {
			rootEl = el[0];
			firstChildEl = rootEl.firstElementChild;

			if (firstChildEl && firstChildEl.nodeName === "INPUT") {
				firstChildEl.checked = true;
			}

			if (node.getAttribute("noColorItem") === "false") {
				noColorEl = rootEl.querySelector(".sub_default_color");

				if (noColorEl) {
					if (CommonFrameUtil.hasClass(noColorEl.nextElementSibling, UiDefine.HORIZONTAL_LINE_SEPARATOR_CLASS)) {
						CommonFrameUtil.removeNode(noColorEl.nextElementSibling);
					}
					CommonFrameUtil.removeNode(noColorEl);
				}
			}

			if (node.getAttribute("themeItem") !== "true") {
				themeColorEl = rootEl.querySelector(".theme_color_palette");

				if (themeColorEl) {
					if (CommonFrameUtil.hasClass(themeColorEl.nextElementSibling, UiDefine.HORIZONTAL_LINE_SEPARATOR_CLASS)) {
						CommonFrameUtil.removeNode(themeColorEl.nextElementSibling);
					}
					CommonFrameUtil.removeNode(themeColorEl);
				}
			}

			if (node.getAttribute("spectrum") === "false") {
				removeElList = rootEl.querySelectorAll(".spectrum_color_content, [name='tab'], label");

				if (removeElList) {
					len = removeElList.length;

					for (i = 0; i < len; ++i) {
						CommonFrameUtil.removeNode(removeElList[i]);
					}
				}
			}

			if (node.getAttribute("colorThemeTable") === "false") {
				removeEl = rootEl.querySelector(".default_color_content .color_theme_table_arrow");

				if (removeEl) {
					CommonFrameUtil.removeNode(removeEl);
				}
			}
		}

		_addWidgetAttribute(node, el, parentInfo);
		CommonFrameUtil.addClass(el[0], UiDefine.TEMPLATE_WRAP_CLASS);

		_replaceNlsCaptionValue(
			CommonFrameUtil.getCollectionToArray(
				templateWrapEl.querySelectorAll('[' + _dataTitle + '], [' + _dataPlaceHolder + ']')));

		elLen = el.length;

		for (i = 0; i < elLen; ++i) {
			if (el[i].querySelector) {
				sampleEl = el[i].querySelector("[" + UiDefine.DATA_SAMPLE_ITEM + "]");

				if (sampleEl) {
					break;
				}
			}
		}

		if (sampleEl) {
			parentEl = sampleEl.parentNode;
			sampleItemAttr = sampleEl.getAttribute(UiDefine.DATA_SAMPLE_ITEM);
			sampleEl.removeAttribute(UiDefine.DATA_SAMPLE_ITEM);
			valueKey = parentInfo.valueKey || sampleEl.getAttribute(_dataValueKey) || "";

			if (sampleItemAttr) {
				if (sampleItemAttr !== "false") {
					CommonFrameUtil.removeNode(sampleEl);

					clonedParentInfo = _getClonedParentInfo(parentInfo);
					clonedParentInfo.parentEl = parentEl;
					customKey = (sampleItemAttr === "true") ? null : sampleItemAttr.replace(/[ ]/g, "");
					_setSampleItemMap(sampleEl, clonedParentInfo, valueKey, customKey);
				} else {
					_cacheParentRef(parentEl, parentInfo);
				}
			}
		}

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	function _convertRadioToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName);

		var inputProps = {
				type: nodeName,
				name:_getName(node) + "_" + _commandItemIdx,
				value: node.getAttribute("value")
			},
			inputEl = _createDomEl("input", inputProps),
			descEl = _createDomEl("span"),
			labelEl = _appendChildNode(_createDomEl("label"), [inputEl, descEl]),
			el;

		className = _concatClassName(className, UiDefine.FOCUSABLE_CLASS);
		el = _appendChildNode(_createDomEl("div", {className:className}), labelEl);

		_setDescription(descEl, _getDescription(node, parentInfo, "desc"), parentInfo, node);

		if (node.getAttribute("selected") === "true") {
			UiReferrer.pushWidget(el, "selected");
		}

		_addMatchAttribute(node, inputEl);
		_addWidgetAttribute(node, el, parentInfo);
		_addCommandAttributes(node, el, parentInfo);

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	function _convertLocalFileToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName);

		var name = _getName(node) || parentInfo.valueKey || node.getAttribute("valueKey"),
			wrapEl = _createDomEl("div", {className: className}),
			formEl = _createDomEl("form", {id: _formIDPrefix + name + "_" + _commandItemIdx},
				{method:"post", enctype:"multipart/form-data"}),
			inputName = parentInfo.commandName || name,
			el;

		formEl = _appendChildNode(formEl, _createDomEl("input", {type: "file", className: UiDefine.FOCUSABLE_CLASS},
			{accept: node.getAttribute("accept"), name: inputName}));
		el = _appendChildNode(wrapEl, formEl);

		_addMatchAttribute(node, el);
		_addWidgetAttribute(node, el, parentInfo);
		_addCommandAttributes(node, el, parentInfo);

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	function _convertTextareaToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName);

		var attrBorder = node.getAttribute("border"),
			attrWidth = node.getAttribute("widget"),
			attrHeight = node.getAttribute("height"),
			el;

		className = _concatClassName(className, UiDefine.FOCUSABLE_CLASS);

		if (attrBorder) {
			className = _concatClassName(className, UiDefine.VIEW_BORDER_PREFIX + "_" + attrBorder);
		}

		el = _createDomEl("textarea", {className: className});

		if (attrWidth) {
			el.style.setProperty("widget", (parseFloat(attrWidth) || 0) + "px");
		}

		if (attrHeight) {
			el.style.setProperty("height", (parseFloat(attrHeight) || 0) + "px");
		}

		_addMatchAttribute(node, el);
		_addWidgetAttribute(node, el, parentInfo);
		_addCommandAttributes(node, el, parentInfo);

		_setColorStyle(node, el);
		_setMarginPaddingStyle(node, el);
		_setMarginPaddingStyle(node, el, true);

		return {
			el: el,
			boxEl: null
		};
	}

	function _convertTabGroupToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName, parentInfo);

		var name = _getName(node),
			childArr = [],
			el, newRefItem;

		className = _concatClassName(className, UiDefine.FOCUSABLE_CLASS);

		el = _createDomEl("div", {className: className});
		childArr[0] = _createDomEl("div", {className: UiDefine.TAB_BOX_CLASS});
		childArr[1] = _createScrollArrowGroup(_concatClassName(UiDefine.NAV_BOX_CLASS, _hideViewClass),
			UiDefine.TAB_SCROLL_CLASS);

		el = _appendChildNode(el, childArr);

		if (name) {
			newRefItem = UiReferrer.makeRefItem(el);
			UiReferrer.appendItem(_curRefItem, newRefItem, name, true);
			_curRefItem = newRefItem;

			el.setAttribute(_dataName, name);
		}

		if (node.getAttribute("hide") === "true") {
			CommonFrameUtil.addClass(el, _hideViewClass);
		}

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: childArr[0]
		};
	}

	function _convertTabToDom(node, className, nodeName, parentInfo) {
		_noop(nodeName);

		var el;

		if (!node.getAttribute("valueKey")) {
			parentInfo.valueKey = "tab";
		}
		parentInfo.nonExec = true;
		parentInfo.toggleButtons = "switch";

		el = _createDomEl("div", {className: className}, _addToggleButtonsToAttrObj(parentInfo));
		_setDescription(el, _getDescription(node, parentInfo, "desc"), parentInfo, node);

		_addMatchAttribute(node, el);
		_addWidgetAttribute(node, el, parentInfo);
		_addCommandAttributes(node, el, parentInfo);

		if (node.getAttribute("selected") === "true") {
			UiReferrer.pushWidget(el, "selected");
		}

		return {
			el: _setMarginPaddingStyle(node, el),
			boxEl: null
		};
	}

	return {

		/*******************************************************************************
		 * Public Methods
		 ******************************************************************************/

		initialize: function(templateDirInfo, langCode, serverProps, isViewer) {
			var isTranslationEnabled, moduleName;

			_xmlItemsObj = {};
			_customXmlObj = {};
			_convertXmlToDomHandler = {
				/** container */
				document: _convertDocumentToDom,
				titleBar: _convertTitleBarToDom,
				menuBar: _convertMenuBarToDom,
				styleBar: _convertStyleBarToDom,
				sideBar: _convertSideBarToDom,
				contextMenu: _convertContextMenuToDom,
				statusBar: _convertStatusBarToDom,
				sheetTabBar: _convertSheetTabBarToDom,
				translate: _convertTranslateToDom,
				thumbnail: _convertThumbnailToDom,
				modalDialog: _convertModalDialogToDom,
				modelessDialog: _convertModelessDialogToDom,
				toolBox: _convertToolBoxToDom,
				commentBar: _convertCommentBarToDom,
				/** template */
				template: _convertTemplateToDom,
				/** panel */
				panel: _convertPanelToDom,
				dialog: _convertDialogToDom,
				tool: _convertToolToDom,
				listBox: _convertPanelToDom,
				/** widget */
				combo: _convertComboToDom,
				dropdown: _convertDropdownToDom,
				separator: _convertSeparatorToDom,
				input: _convertInputToDom,
				data: _convertDataToDom,
				image: _convertImageToDom,
				checkbox: _convertCheckboxToDom,
				button: _convertButtonToDom,
				progress: _convertProgressToDom,
				radio: _convertRadioToDom,
				localFile: _convertLocalFileToDom,
				textarea: _convertTextareaToDom,
				tabGroup: _convertTabGroupToDom,
				tab: _convertTabToDom,
				/** item */
				commandItem: _convertCommandItemToDom,
				panelGroupItem: _convertPanelGroupItemToDom,
				widgetGroupItem: _convertWidgetGroupItemToDom,
				dataSetItem: _convertDataSetItemToDom
			};
			UiReferrer.initialize();
			_curRefItem = UiReferrer.getRefTree();
			_commandItemIdx = 1;
			_commandLastIdxInfo = {};
			_unitInfo = {};
			_widgetNameToValueKeyMap = {};
			_commandToValueKeyArrMap = {};
			_langCode = langCode || "en";
			_noNameMatchIndex = 0;

			if (CommonFrameUtil.isObject(templateDirInfo)) {
				_templateDir = templateDirInfo.baseDir;
				moduleName = templateDirInfo.moduleName;

				this.loadTemplate(_templateDir, "common_template");

				if (UiDefine.USE_ADD_TEMPLATE_FILE_MODULE_NAMES.indexOf(moduleName) !== -1) {
					this.loadTemplate(_templateDir, moduleName + "_template");
				}

			} else {
				_templateDir = templateDirInfo;
			}

			//TODO : 추후 스킨 네임을 상위에서 참고할 수 있는 방법 마련
			_skinName = (_templateDir.indexOf("type_a") !== -1 && "type_a") || "default";

			if (serverProps != null && !CommonFrameUtil.isEmptyObject(serverProps)) {
				if (serverProps.isPrintEnabled != null) {
					_xmlNameToServerPropsMap["d_print"] = serverProps.isPrintEnabled;
				}

				if (serverProps.isDownloadEnabled != null) {
					_xmlNameToServerPropsMap["d_download"] = serverProps.isDownloadEnabled;
				}

				if (serverProps.isDownloadAsPdfEnabled != null) {
					_xmlNameToServerPropsMap["d_pdf_download"] = serverProps.isDownloadAsPdfEnabled;
				}

				if (isViewer) {
					if (serverProps.isPrintEnabledForViewer != null) {
						_xmlNameToServerPropsMap["d_print"] = serverProps.isPrintEnabledForViewer;
					}

					if (serverProps.isDownloadEnabledForViewer != null) {
						_xmlNameToServerPropsMap["d_download"] = serverProps.isDownloadEnabledForViewer;
					}

					if (serverProps.isDownloadAsPdfEnabledForViewer != null) {
						_xmlNameToServerPropsMap["d_pdf_download"] = serverProps.isDownloadAsPdfEnabledForViewer;
					}

					_xmlNameToServerPropsMap["d_save"] = false;
					_xmlNameToServerPropsMap["d_save_as_button"] = false;
					_xmlNameToServerPropsMap["d_page_setup"] = false;
				} else {
					if (serverProps.isPrintEnabledForEditor != null) {
						_xmlNameToServerPropsMap["d_print"] = serverProps.isPrintEnabledForEditor;
					}

					if (serverProps.isDownloadEnabledForEditor != null) {
						_xmlNameToServerPropsMap["d_download"] = serverProps.isDownloadEnabledForEditor;
					}

					if (serverProps.isDownloadAsPdfEnabledForEditor != null) {
						_xmlNameToServerPropsMap["d_pdf_download"] = serverProps.isDownloadAsPdfEnabledForEditor;
					}

					if (serverProps.isSaveButtonEnabled != null) {
						_xmlNameToServerPropsMap["d_save"] = serverProps.isSaveButtonEnabled;
					}

					if (serverProps.isSaveAsEnabled != null) {
						_xmlNameToServerPropsMap["d_save_as_button"] = serverProps.isSaveAsEnabled;
					}
				}

				if (serverProps.helpButton != null) {
					_xmlNameToServerPropsMap["e_help"] = serverProps.helpButton;
				}

				// 데스크탑 편집 옵션이 활성화 되어 있으면 해당 버튼을 활성화 한다.
				if (serverProps.isEditOnDesktopEnabled === true) {
					_xmlNameToServerPropsMap["e_desktop_confirm"] = true;
					_xmlNameToServerPropsMap["e_desktop_execute"] = true;
				}

				// 스토리지 지능형 검색 옵션이 활성화 되어 있으면 해당 버튼을 활성화 한다.
				if (serverProps.storageSearchServerUri != null && serverProps.storageSearchAuthKey != null) {
					// 스트링 값으로 빈값일때는 없는것으로 간주한다.
					if (serverProps.storageSearchServerUri !== "" && serverProps.storageSearchAuthKey !== "") {
						_xmlNameToServerPropsMap["storage_search_doc"] = true;
						_xmlNameToServerPropsMap["u_search_doc_context"] = true;
					}
				}

				isTranslationEnabled = serverProps.isTranslationEnabled;

				if (isTranslationEnabled != null) {
					_xmlNameToServerPropsMap["translate"] = isTranslationEnabled;
				}

				if (serverProps.isLabProjectEnabled != null) {
					_xmlNameToServerPropsMap["lab"] = serverProps.isLabProjectEnabled;
				}
			}

			// frameworkInfo 에 uiServerPropsMap 정보를 저장한다.
			UiFrameworkInfo.setInfo(UiFrameworkInfo.UI_SERVER_PROPS_MAP, _xmlNameToServerPropsMap);
		},

		initializeTemplateEl: function (el, langDefine) {
			var findEl, findElArr, elLen, i, j, len, templateGroupItemNum, groupEl, clonedGroup, clonedFindEl,
				valueArr, value, newFragment, tempEl, newEl, newElHtml, textEl, keys, keyLen, keyIdx, key, regPattern;

			tempEl = document.createElement("div");
			findElArr = CommonFrameUtil.getCollectionToArray(el.querySelectorAll('[' + _dataTemplateName + ']'));
			elLen = findElArr.length;

			for (i = 0; i < elLen; i++) {
				findEl = findElArr[i];
				valueArr = TemplateDefine.TEMPLATE_VALUES[findEl.getAttribute(_dataTemplateName)];
				templateGroupItemNum = parseInt(findEl.getAttribute(_dataTemplateGroupItem), 10) || 0;

				if (templateGroupItemNum) {
					groupEl = CommonFrameUtil.findParentNode(findEl, '.' + _templateGroupClass);

					if (groupEl) {
						CommonFrameUtil.removeClass(groupEl, _templateGroupClass);
					}
				}

				findEl.removeAttribute(_dataTemplateName);
				findEl.removeAttribute(_dataTemplateGroupItem);

				if (valueArr) {
					newFragment = document.createDocumentFragment();
					len = valueArr.length;

					for (j = 0; j < len; j++) {
						if (groupEl && j && j % templateGroupItemNum === 0) {
							// group 내 개수가 모두 찬 경우, 현재 el 들을 group 에 담아서 삽입
							findEl.setAttribute(_dataTemplateGroupItem, templateGroupItemNum);
							clonedGroup = groupEl.cloneNode(true);
							clonedFindEl = clonedGroup.querySelector('[' + _dataTemplateGroupItem + ']');
							findEl.removeAttribute(_dataTemplateGroupItem);

							if (clonedFindEl) {
								CommonFrameUtil.insertBefore(clonedFindEl, newFragment);
								CommonFrameUtil.removeNode(clonedFindEl);
								newFragment = document.createDocumentFragment();
							}

							CommonFrameUtil.insertBefore(groupEl, clonedGroup);
						}

						newElHtml = findEl.outerHTML;
						value = valueArr[j];

						keys = Object.keys(value);
						keyLen = keys.length;

						for (keyIdx = 0; keyIdx < keyLen; keyIdx++) {
							key = keys[keyIdx];

							if (_templateDefineKeyArr.indexOf(key) === -1) {
								regPattern = (key.charAt(0) === "$") ? "\\" + key : key;
								newElHtml = newElHtml.replace(new RegExp(regPattern, "g"), value[key]);
							}
						}

						tempEl.innerHTML = newElHtml;
						newEl = tempEl.firstElementChild;
						newFragment.appendChild(newEl);

						if (value.classVal) {
							CommonFrameUtil.addClass(newEl, value.classVal);
						}

						if (value.text) {
							textEl = newEl.firstElementChild ? newEl.querySelector('[' + _dataTemplateAreaType + '="text"]') : newEl;

							if (textEl) {
								FrameworkUtil.setDescription(
									textEl, FrameworkUtil.getReplaceNlsValue(value.text, langDefine));
								textEl.removeAttribute(_dataTemplateAreaType);
							}
						}

						if (value.val) {
							newEl.setAttribute(_dataValue, value.val);
						}
					}

					CommonFrameUtil.insertBefore(findEl, newFragment);
				}

				CommonFrameUtil.removeNode(findEl);
			}

			return el;
		},

		loadTemplate: function (templateDir, templateName) {
			var tempEl = document.createElement("div"),
				templateWrap, curTemplate;

			tempEl.innerHTML = UiRequester.requestTemplate(templateDir, templateName);
			templateWrap = tempEl.firstElementChild;

			if (templateWrap) {
				curTemplate = templateWrap.firstElementChild;
			}

			while (curTemplate) {
				_templateElMap[curTemplate.getAttribute(_dataName)] = this.initializeTemplateEl(curTemplate);
				curTemplate = curTemplate.nextElementSibling;
			}
		},

		// xmlList = [customXml, moduleXml, commonXml]
		convertXmlToDom: function (xmlList, templateDirInfo, langCode, serverProps, isViewer) {
			if (xmlList.length === 0) {
				console.log("[Error] XML List is empty!");

				return;
			}

			var moduleName = UiFrameworkInfo.getModuleName(),
				elFragmentInfo = null,
				colorXmlList = [],
				clonedList, i, len, customXml, moduleXml, commonXml, baseXmlList, viewModeTag, frameXml, elList;

			if (UiDefine.USE_CHANGE_UI_MODE_MODULE_NAMES.indexOf(moduleName) !== -1) {
				clonedList = [];

				for (i = 0, len = xmlList.length; i < len; i++) {
					clonedList[i] = xmlList[i] && xmlList[i].cloneNode(true);
				}

				xmlList = clonedList;
			}

			customXml = xmlList[0];
			moduleXml = xmlList[1];
			commonXml = xmlList[2];

			if (moduleXml && commonXml) {
				baseXmlList = [moduleXml, commonXml];

				frameXml = moduleXml.getElementsByTagName("frame")[0];
				viewModeTag = moduleXml.getElementsByTagName("viewMode")[0];
				colorXmlList.push(commonXml.getElementsByTagName("color")[0]);
				colorXmlList.push(moduleXml.getElementsByTagName("color")[0]);

			} else {
				console.log("[Error] Module or common Xml is not found!");

				return;
			}

			if (frameXml.length === 0) {
				console.log("[Error] Convert error!");

				return;
			}

			this.initialize(templateDirInfo, langCode, serverProps, isViewer);
			_setXmlItemsObj(baseXmlList, "command");
			_setXmlItemsObj(baseXmlList, "panelGroup");
			_setXmlItemsObj(baseXmlList, "widgetGroup");
			_setXmlItemsObj(baseXmlList, "dataSet");

			if (isViewer) {
				_setCustomXmlObj(_customXmlObj, viewModeTag);
				if (customXml) {
					_setCustomXmlObj(_customXmlObj, customXml.getElementsByTagName("viewMode")[0]);
				}

			} else if (customXml) {
				_setCustomXmlObj(_customXmlObj, customXml.firstElementChild || customXml.firstChild);
			}

			if (customXml) {
				colorXmlList.push(customXml.getElementsByTagName("color")[0]);
			}

			elList = _convertChildDom(frameXml);

			if (elList) {
				elFragmentInfo = {};
				elFragmentInfo.elList = elList;
				elFragmentInfo.refTree = UiReferrer.getRefTree();
				elFragmentInfo.widgetMap = UiReferrer.getWidgetMap() || {};
				elFragmentInfo.viewMap = UiReferrer.getViewMap() || {};
				elFragmentInfo.uiWidgetMap = {
					fold: UiReferrer.getWidgetGroup(_uiCommandNames.FOLD + _uiGroupName) || {},
					toggle: UiReferrer.getWidgetGroup(_uiCommandNames.TOGGLE + _uiGroupName) || {}
				};
				elFragmentInfo.commandsWidgetMap = UiReferrer.getWidgetGroup(_commandWidgetsGroupName) || {};
				elFragmentInfo.commandsWidgetIdxMap = UiReferrer.getWidgetGroup(_commandWidgetsIdxGroupName) || {};
				elFragmentInfo.updateDescWidgetMap = UiReferrer.getWidgetGroup(_updateDescWidgetsGroupName) || {};
				elFragmentInfo.sampleItemMap = UiReferrer.getWidgetGroup(UiDefine.GROUP_NAME_SAMPLE_ITEM) || {};
				elFragmentInfo.sampleItemMoveMap = UiReferrer.getWidgetGroup(_sampleItemMoveButtonGroupName) || {};
				elFragmentInfo.unitInfo = _unitInfo;
				elFragmentInfo.color = ColorConverter.convertColorToStyleNode(colorXmlList);
				elFragmentInfo.disableInfo = {
					widgetList: _needDisableList,
					subgroupList: _checkDisableSubgroupList
				};
				elFragmentInfo.descToCollaboView = _cachedDescToCollabo;
				elFragmentInfo.widgetNameToValueKeyMap = _widgetNameToValueKeyMap;
				elFragmentInfo.commandToValueKeyArrMap = _commandToValueKeyArrMap;
				elFragmentInfo.uiCommandButtonInfo = {
					buttonArr: _uiCmdBtnArr,
					nameArr: _uiCmdBtnNameArr
				};
			}

			return elFragmentInfo || null;
		},

		/**
		 * 미뤄놓은 dialog 의 convert 를 진행하여 돌려주는 함수
		 *
		 * @param {Boolean} isLazyConvert		- true: lazyMode, false: normalMode
		 */
		setLazyConvertMode: function (isLazyConvert) {
			_lazyConvertMode = isLazyConvert || false;
		},

		/**
		 * 미뤄놓은 dialog 의 convert 를 진행하여 돌려주는 함수
		 *
		 * @param  {Object} convertXmlInfo		- converting 에 필요한 정보 {node, parentInfo, curRefItem}
		 * @returns {Object}
		 */
		lazyConvertXmlToDom: function (convertXmlInfo) {
			var result = {
					elList: [],
					panelNames: [],
					updateDescNames: []
				},
				node, parentInfo;

			if (!convertXmlInfo) {
				return result;
			}

			node = convertXmlInfo.node;
			parentInfo = convertXmlInfo.parentInfo;
			_curRefItem = convertXmlInfo.curRefItem;

			_lazyPanelNames = [];
			_lazyUpdateDescNames = [];
			result.panelNames = _lazyPanelNames;
			result.updateDescNames = _lazyUpdateDescNames;
			result.elList = _convertChildDom(node, parentInfo, true);

			_lazyPanelNames = null;
			_lazyUpdateDescNames = null;

			return result;
		}
	};
});
