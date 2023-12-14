define(function (require) {
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var UiKeyEvent = require("commonFrameJs/uiFramework/events/uiKeyEvent"),
		UiMouseEvent = require("commonFrameJs/uiFramework/events/uiMouseEvent"),
		UiDefine = require("commonFrameJs/uiFramework/uiDefine");

	var _inputContainerIdArr = [
			UiDefine.MODAL_DIALOG_ID, UiDefine.MODELESS_DIALOG_ID, UiDefine.STYLEBAR_ID, UiDefine.SIDEBAR_ID, UiDefine.TOOL_BOX_ID];

	return {
		uiKeyEvent: UiKeyEvent,

		uiMouseEvent: UiMouseEvent,

		/**
		 * Input Tag 에 Event bind 해야하는 Container Element Array 반환하는 함수
		 * @param {Object} refTree
		 * @returns {Array} (Element Array)
		 */
		getInputEventContainerList: function(refTree) {
			if (!refTree) {
				return [];
			}

			var length = _inputContainerIdArr.length,
				result = [],
				i, refTreeItem;

			for (i = 0; i < length; i++) {
				refTreeItem = refTree[_inputContainerIdArr[i]];

				if (refTreeItem && refTreeItem.ref) {
					result[result.length] = refTreeItem.ref;
				}
			}

			return result;
		}
	};
});