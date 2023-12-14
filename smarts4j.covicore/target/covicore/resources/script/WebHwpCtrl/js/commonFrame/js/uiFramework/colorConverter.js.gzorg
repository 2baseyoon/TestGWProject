define(function (require) {
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var CommonFrameUtil = require("commonFrameJs/utils/util"),
		UiDefine = require("commonFrameJs/uiFramework/uiDefine");

	var _colorSelectors = UiDefine.CSS_COLOR_SELECTORS,
		_colorSelectorKeys = Object.keys(_colorSelectors),
		_colorSelectorKeysLen = _colorSelectorKeys.length,
		_colorStyleMap = UiDefine.CSS_COLOR_STYLE_MAP,
		_colorSelectorMap = UiDefine.CSS_COLOR_SELECTOR_MAP,
		_colorContainerSelector = UiDefine.CSS_COLOR_CONTAINER_SELECTOR,
		_containerViewClassSelector = "." + UiDefine.CONTAINER_CLASS,
		_checkSVGSelectorArr = ["GUIDE_BUTTON", "CONTROL_BUTTON"],
		_containerViewClassSelectorLen = _containerViewClassSelector.length,
		_containerNodeToID = {
			document: UiDefine.DOCUMENT_MENU_ID,
			titleBar: UiDefine.TITLE_BAR_ID,
			menuBar: UiDefine.MENU_BAR_ID,
			styleBar: UiDefine.STYLEBAR_ID,
			sideBar: UiDefine.SIDEBAR_ID,
			contextMenu: UiDefine.CONTEXT_MENU_ID,
			statusBar: UiDefine.STATUSBAR_ID,
			translate: UiDefine.TRANSLATE_ID,
			thumbnail: UiDefine.THUMBNAIL_ID,
			modalDialog: UiDefine.MODAL_DIALOG_ID,
			modelessDialog: UiDefine.MODELESS_DIALOG_ID,
			toolBox: UiDefine.TOOL_BOX_ID,
			collaborationPanel: "collaboration_panel",
			quickMenuBox: "quick_menu_box"
		},
		_inhibitNodeToChildList = UiDefine.INHIBIT_CHILD_NODE_LIST,
		_colorCustomNodeList = UiDefine.COLOR_CUSTOM_NODE_LIST,
		_contentsBoxConvertMap = {
			modalDialog: ["contentsBox"],
			collaborationPanel: ["titlePanel", "contentsBox"]
		},
		_parentNodeSelectorMap = {
			"collaboration_panel": ".title_panel[class*='" + UiDefine.COLLABO_USERS_VIEW + "_view']",
			"quick_menu_box": "." + UiDefine.CONTAINER_CLASS + " ." + UiDefine.TOOL_QUICK_MENU
		};

	function _makeStyleRuleString(selector, styleRule) {
		var styleAttrs = Object.keys(styleRule),
			styleLen = styleAttrs.length,
			curRuleStr = "",
			i, styleName, styleValue;

		for (i = 0; i < styleLen; i++) {
			styleName = styleAttrs[i];
			styleValue = styleRule[styleName];

			if (styleValue) {
				curRuleStr += (styleName + ":" + styleValue + ";");
			}
		}

		if (curRuleStr) {
			curRuleStr = (selector + " {" + curRuleStr + "}\n");
		}

		return curRuleStr;
	}

	function _makeCssRule(curColorSelectorMap, selectorArr, isContainer, selectorKey) {
		if (!curColorSelectorMap) {
			return "";
		}

		var cssRuleStr = "",
			containerIDArr = Object.keys(curColorSelectorMap),
			containerLen = containerIDArr.length,
			allIdx = containerIDArr.indexOf("all"),
			parentNodeArr = Object.keys(_parentNodeSelectorMap),
			parentNodeKeyLen = parentNodeArr.length,
			checkSVG = _checkSVGSelectorArr.indexOf(selectorKey) !== -1,
			clonedSelectorArr, curColorContainerSelector, targetContainer, styleRule,
			i, j, selectorLen, targetContainerSelector, curTargetContainerSelector, curSelector, curRuleSelector,
			parentNodeIdx, parentNodeKey, parentNodeSelector, svgSelector, svgParentSelector;

		if (allIdx > 0) {
			containerIDArr.splice(allIdx, 1);
			containerIDArr.unshift("all");
		}

		for (i = 0; i < parentNodeKeyLen; i++) {
			parentNodeKey = parentNodeArr[i];
			parentNodeIdx = containerIDArr.indexOf(parentNodeKey);

			if (parentNodeIdx > -1) {
				containerIDArr.splice(parentNodeIdx, 1);
				containerIDArr.push(parentNodeKey);
			}
		}

		for (i = 0; i < containerLen; i++) {
			targetContainer = containerIDArr[i];
			styleRule = curColorSelectorMap[targetContainer];
			curColorContainerSelector = isContainer ? _colorContainerSelector[targetContainer] : null;
			parentNodeSelector = _parentNodeSelectorMap[targetContainer];
			svgSelector = [];
			svgParentSelector = [];

			curRuleSelector = curColorContainerSelector || selectorArr;

			if (targetContainer !== "all" || checkSVG) {

				// CSS selector 로 시작되는 경우 or 특정 container 내로 한정
				targetContainerSelector = parentNodeSelector || (isContainer ? "#" : ".") + targetContainer;

				clonedSelectorArr = curRuleSelector ? CommonFrameUtil.cloneObject(curRuleSelector) : [""];
				selectorLen = clonedSelectorArr.length;

				for (j = 0; j < selectorLen; j++) {
					if (targetContainer !== "all" && !curColorContainerSelector) {
						curTargetContainerSelector = targetContainerSelector;
						curSelector = clonedSelectorArr[j];

						if (CommonFrameUtil.isStartsWith(curSelector, _containerViewClassSelector)) {
							// 특정 container 의 selector 를 붙여주기 위해 _containerViewClassSelector 제거
							curSelector = curSelector.slice(_containerViewClassSelectorLen);
						} else if (CommonFrameUtil.isStartsWith(curSelector, curTargetContainerSelector)) {
							// container selector 와 동일하다면 그대로 사용
							curTargetContainerSelector = "";
						} else {
							// container selector 로 시작한게 아니라면 공백 추가 (container 의 하위사용을 위해)
							curTargetContainerSelector += " ";
						}

						clonedSelectorArr[j] = curTargetContainerSelector + curSelector;
					}

					if (checkSVG) {
						svgSelector.push(clonedSelectorArr[j]);
						svgParentSelector.push(clonedSelectorArr[j].split(" svg")[0]);
					}
				}

				curRuleSelector = clonedSelectorArr;
			}

			if (curRuleSelector && curRuleSelector.length > 0) {
				curRuleSelector = curRuleSelector.join().trim();

				cssRuleStr += _makeStyleRuleString(curRuleSelector, styleRule);

				if (svgSelector.length > 0 && styleRule["color"]) {
					cssRuleStr += _makeStyleRuleString(svgSelector.join().trim(), {"fill": styleRule["color"]});
					cssRuleStr += _makeStyleRuleString(svgParentSelector.join().trim(), {"background-color": "transparent !important", "border-color": "transparent !important"});
				}
			}
		}

		return cssRuleStr;
	}

	/**
	 *
	 * @param {Object} colorStyleInfo - _addColorStyleInfo() 가 return 한 object
	 * @returns {Element} style element - 만들 필요 없는 경우 null
	 * @private
	 */
	function _makeStyleNode(colorStyleInfo) {
		if (!colorStyleInfo) {
			return null;
		}

		var styleString = "",
			styleNode = null,
			selectorKey, curColorSelectorMap, i;

		for (i = 0; i < _colorSelectorKeysLen; i++) {
			// Define 된 순서대로 확인
			selectorKey = _colorSelectorKeys[i];
			curColorSelectorMap = colorStyleInfo[selectorKey];

			if (curColorSelectorMap) {
				styleString += _makeCssRule(curColorSelectorMap, _colorSelectors[selectorKey], false, selectorKey);
			}
		}

		curColorSelectorMap = colorStyleInfo["CONTAINER"];
		if (curColorSelectorMap) {
			// CONTAINER 에 직접 지정되는 style
			styleString += _makeCssRule(curColorSelectorMap, null, true);
		}

		if (styleString) {
			styleNode = document.getElementById(UiDefine.STYLE_NODE_ID) || document.createElement("style");
			styleNode.setAttribute("id", UiDefine.STYLE_NODE_ID);
			styleNode.innerHTML = styleString;
		}

		return styleNode;
	}

	function _addColorStyleInfo(node, colorStyleInfo, containerID) {
		if (!colorStyleInfo) {
			return colorStyleInfo;
		}

		var nodeName = node.nodeName,
			curNodeContainerID = containerID ? null : _containerNodeToID[nodeName],
			attrs, attribute, attrLen, attrName, curColorSelectorMap, curSelectorKey, colorStyleMapKey,
			i, curStyleName, curValue, curContainerStyleInfo, curRule, curNode, targetContainer, curNodeName;

		if (curNodeContainerID) {
			nodeName = "containers";
			targetContainer = curNodeContainerID;
		} else {
			targetContainer = containerID || "all";
		}

		curColorSelectorMap = _colorSelectorMap[nodeName];

		if (curColorSelectorMap) {
			attrs = node.attributes;
			attrLen = attrs ? attrs.length : 0;

			for (i = 0; i < attrLen; i++) {
				attribute = attrs[i];
				attrName = attribute.name;

				colorStyleMapKey = attrName.slice(0, attrName.indexOf("Color"));

				curStyleName = _colorStyleMap[colorStyleMapKey];
				curValue = attribute.value;

				curSelectorKey = curColorSelectorMap[attrName] || nodeName;
				curContainerStyleInfo = colorStyleInfo[curSelectorKey];
				if (!curContainerStyleInfo) {
					curContainerStyleInfo = {};
					colorStyleInfo[curSelectorKey] = curContainerStyleInfo;
				}

				curRule = curContainerStyleInfo[targetContainer];
				if (!curRule) {
					curRule = {};
					curContainerStyleInfo[targetContainer] = curRule;
				}

				curRule[curStyleName] = curValue;
			}
		}

		if (curNodeContainerID) {
			curNode = node.firstElementChild;
			nodeName = node.nodeName;

			while (curNode) {
				curNodeName = curNode.nodeName;

				// 부모 노드로만 허용된 node 이면서, 허용된 자식이면 color node 를 convert 함
				// 예외적으로 modal dialog / collaborationPanel 의 경우에는 contentsBox 도 허용함.
				if ((_inhibitNodeToChildList.indexOf(nodeName) !== -1 && _colorCustomNodeList.indexOf(curNodeName) !== -1)
					|| (_contentsBoxConvertMap[nodeName] && _contentsBoxConvertMap[nodeName].indexOf(curNodeName) !== -1)) {
					colorStyleInfo = _addColorStyleInfo(curNode, colorStyleInfo, curNodeContainerID);
				}

				curNode = curNode.nextElementSibling;
			}
		}

		return colorStyleInfo;
	}

	return {
		convertColorToStyleNode: function(colorNodes) {
			if (!colorNodes) {
				return null;
			}

			var colorStyleInfo = { // selector 별 css rule 정리
				},
				colorNodesLen = colorNodes.length,
				curNode, i;

			for (i = 0; i < colorNodesLen; i++) {
				if (colorNodes[i]) {
					curNode = colorNodes[i].firstElementChild;

					while (curNode) {
						colorStyleInfo = _addColorStyleInfo(curNode, colorStyleInfo);
						curNode = curNode.nextElementSibling;
					}
				}
			}

			return _makeStyleNode(colorStyleInfo);
		}
	};
});
