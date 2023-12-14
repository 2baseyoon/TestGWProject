define(function (require) {
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var CommonFrameUtil = require("commonFrameJs/utils/util"),
		UiDefine = require("commonFrameJs/uiFramework/uiDefine");

	/*******************************************************************************
	 * Private Variables
	 ******************************************************************************/
	var _refTree, _widgetMap, _widgetGroup, _viewMap;

	/*******************************************************************************
	 * Private Functions (w/o context)
	 ******************************************************************************/
	//

	return {

		/**
		 * public method (with context)
		 */
		initialize: function() {
			_refTree = {};
			_widgetMap = {};
			_widgetGroup = {};
			_viewMap = {};
		},

		getRefTree: function() {
			return _refTree;
		},

		getWidgetMap: function() {
			return _widgetMap;
		},

		getViewMap: function() {
			return _viewMap;
		},

		getWidgetGroup: function(groupName) {
			return _widgetGroup[groupName];
		},

		makeRefItem: function(ref) {
			return {
				ref: ref
			}
		},

		appendItem: function(parent, item, name, addViewMap) {
			parent[name] = item;
			item.parentItem = parent;

			if (addViewMap || CommonFrameUtil.hasClass(item.ref, UiDefine.CONTAINER_CLASS)) {
				_viewMap[name] = item;
			}

			return item;
		},

		pushWidget: function(widget, name, groupName, withoutCheckUnique) {
			var widgetArr,
				widgetGroupObj;

			if (CommonFrameUtil.isArray(widget)) {
				widget = widget[0];
			}

			if (groupName) {
				widgetGroupObj = _widgetGroup[groupName];
				if (!widgetGroupObj) {
					widgetGroupObj = {};
					_widgetGroup[groupName] = widgetGroupObj;
				}
			} else {
				widgetGroupObj = _widgetMap;
			}

			widgetArr = widgetGroupObj[name];

			if (!widgetArr) {
				widgetArr = [];
				widgetGroupObj[name] = widgetArr;
			}

			if (withoutCheckUnique || widgetArr.indexOf(widget) === -1) {
				widgetArr[widgetArr.length] = widget;
			} else {
				widget = null;
			}
			return widget;
		}

		/**
		 * private methods (with context)
		 */
		//

	};
});
