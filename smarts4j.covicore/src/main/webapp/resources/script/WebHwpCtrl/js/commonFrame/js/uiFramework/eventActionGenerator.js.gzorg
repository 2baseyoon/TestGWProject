define(function (require) {
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var CommonFrameUtil = require("commonFrameJs/utils/util"),
		UiDefine = require("commonFrameJs/uiFramework/uiDefine"),
		UiUtil = require("commonFrameJs/uiFramework/uiUtil"),
		UiFrameworkInfo = require("commonFrameJs/uiFramework/uiFrameworkInfo");

	/*******************************************************************************
	 * Private Variables
	 ******************************************************************************/
	var _prefixToType = UiDefine.PREFIX_TO_TYPE,
		_uiCommandNames = UiDefine.UI_COMMAND_NAME,
		_uiActionType = UiDefine.EVENT_ACTION_TYPE,
		_updateCmd = UiDefine.UPDATE_CMD,
		_defineValue = UiDefine.VALUE,
		_onStr = _defineValue.ON,
		_trueStr = _defineValue.TRUE,
		_dontCareValue = _defineValue.DONT_CARE;

	/*******************************************************************************
	 * Private Functions
	 ******************************************************************************/
	function _getEventActionType(command) {
		var type;

		if (command.charAt(1) === "_") {
			type = _prefixToType[command.charAt(0)] || _uiActionType.TEXT;
		} else {
			type = _uiActionType.TEXT;
		}

		return type;
	}

	return {
		/**
		 * private method (with context)
		 */

		/**
		 * 현재 command, target 에 해당하는 value 반환
		 * @param {String} command
		 * @param {Node} target
		 * @param {String=} valueKey	특정 valueKey 로 한정하고 싶은 경우 지정
		 * @returns {Object} {value, checkedList}
		 * 				- value: {Object|String}
		 * 				- checkedList:[{String}]
		 */
		_getCommandItemValue: function(command, target, valueKey) {
			var valueKeyCmdWidgetArr = UiFrameworkInfo.getInfo(UiFrameworkInfo.COMMANDS_WIDGET_MAP)[command],
				valueKeyIdxArr = UiFrameworkInfo.getInfo(UiFrameworkInfo.COMMANDS_WIDGET_IDX_MAP)[command],
				commandItemIndex = UiFrameworkInfo.getCommandItemIndex(command, target),
				result = {
					value: null,
					checkedList: null
				},
				checkedList, curValueKey, commandElArr, len, i, elLen, j, commandEl;

			if (commandItemIndex === -1) {
				return result;
			}

			len = valueKeyIdxArr.length;
			for (i = 0; i < len; i++) {
				if (valueKeyIdxArr[i] === commandItemIndex) {
					// 현재 commandItem 내의 widget 만
					commandElArr = this.getValueTargetCommands(valueKeyCmdWidgetArr[i]);

					if (commandElArr) {
						if (UiUtil.isSampleWrap(valueKeyCmdWidgetArr[i])) {
							// sample 내부의 checkBox 에 한해서 checkedList 활용
							if (!result.checkedList) {
								result.checkedList = [];
							}
							checkedList = result.checkedList;
						} else {
							checkedList = null;
						}
						elLen = commandElArr.length;

						for (j = 0; j < elLen; j++) {
							commandEl = commandElArr[j];
							curValueKey = UiUtil.getValueKey(commandEl);

							if (!valueKey || curValueKey === valueKey) {
								result.value = this.getValue(commandEl, result.value);

								if (checkedList && curValueKey && CommonFrameUtil.isObject(result.value)
									&& UiUtil.isCheckboxWidget(commandEl) && result.value[curValueKey] === _trueStr) {
									checkedList[checkedList.length] = curValueKey;
								}
							}
						}
					}
				}
			}

			return result;
		},

		/**
		 * public method (with context)
		 */
		/**
		 * ActionObject 생성
		 * @param {String} cmd					- "insert"/"update"/"delete"/"list"
		 * @param {String} type				- text / paragraph / shape / image / cell / table / document / ui
		 * @param {String|Array} name			- Command 명 (갱신/삽입/삭제 대상)
		 * @param {String|Number|Object} value	- 변경 내용을 의미. 자세한 정의는 Confluence 참조
		 * @param {Element=} target			- Event 발생 대상 Element
		 * @param {String=} focus				- focus 줄 대상 Element Name (valueKey or value)
		 * @returns {Object}
		 */
		makeEventActionObj: function(cmd, type, name, value, target, focus) {
			var evtActionObj = {
				cmd: cmd,
				type: type,
				name: name,
				value: CommonFrameUtil.isNumber(value) ? String(value) : value,
				target: target
				// unit, holdLayer property 추가 가능 (별도 addMethod)
			};

			if (focus) {
				evtActionObj = this.addFocusProperty(evtActionObj, focus);
			}

			return evtActionObj;
		},

		/**
		 * ActionObject 생성
		 * @param {String} name			- Command 명 (갱신/삽입/삭제 대상)
		 * @param {String|Object} value	- 변경 내용을 의미. 자세한 정의는 Confluence 참조
		 * @returns {Object}
		 */
		makeUpdateEventAction: function(name, value) {
			return this.makeEventActionObj(_updateCmd, _getEventActionType(name), name, value, null);
		},

		/**
		 * 현재 target 을 실행하는 eventAction return.
		 * @param {Element} target			- 대상
		 * @param {Boolean=} isDblClick	- double click Event 로 발생된 경우
		 * @returns {Object}
		 */
		makeEventAction: function(target, isDblClick) {
			var evtAction = null,
				curValue = null,
				orgTarget = target,
				isHoldLayerMenu = false,
				isCombo, isCheckbox, isAnchorTarget, widgetNode, addValue, orgValue, command, type, dialogCmdValue,
				nodeName, unit, isControlBtn, activeEl, valueKey, dataDblClkCommand, needOffValue, spinnerType,
				selectAllInfo, selectAllValue, selectAllValueStr, valueKeyArr, len, i, curValueKey, selectCheckArr,
				inputWrapEl, valueInfo, checkedList, checkedIdx, curCheckValue;

			if (!target) {
				return null;
			}

			if (isDblClick) {
				dataDblClkCommand = target.getAttribute(UiDefine.DATA_DBL_CLICK_COMMAND);

				if (dataDblClkCommand) {
					// TODO : 해당 data attribute 가 있으면, ui command 발생하도록 추후 구현 예정
				} else if (target.getAttribute(UiDefine.DATA_NON_EXEC) === _trueStr) {
					// execute 하지 않는 target 인 경우, target 변경해서 EventAction 생성 후 target 원복함
					target = UiFrameworkInfo.getResultButtonElementByWidget(target) || target;
				}

			} else {
				isDblClick = false;
			}

			isCombo = UiUtil.isCombo(target.parentNode);
			isAnchorTarget = target.nodeName === "A";
			widgetNode = isAnchorTarget ? target.parentNode : target;

			if (UiUtil.isDisabled(widgetNode)
				|| CommonFrameUtil.hasClass(widgetNode, UiDefine.PREVIEW_COLOR_TEXT_CLASS)) {
				// disabled target 및 spectrum color input target 은 아무동작 하지 않음
				/**
				 * 추후 input 으로부터 change 이벤트로 event action 이 발생되면 안되는 경우에
				 * (ex. input(nonExec="true") 옆에 confirm 버튼이 있는 경우)
				 * 이 예외 조건 대신 범용적으로 구현되어야 할 것으로 보임. (by. igkang & sebang)
 				 */
				target = null;

			} else if (UiUtil.isActionCommandButton(target)) {
				command = UiUtil.getEventActionCommand(target);
				type = _getEventActionType(command);
				isControlBtn = UiUtil.isControlButton(target);

				if (isControlBtn) {
					spinnerType = UiUtil.getSpinnerType(target);

					if (spinnerType) {
						// spinner 인 경우, input widget 으로 target 변경
						widgetNode = widgetNode.parentNode.parentNode;
						target = widgetNode;
						isControlBtn = false; // spinner 에서 inputWrap 으로 이동. 더이상 control 버튼 아님

						if (UiUtil.isDisabled(widgetNode)) {
							return null;
						}
					}
				}

				valueKey = target.getAttribute(UiDefine.DATA_VALUE_KEY);

				// 현재 commandItem 에 적용돼 있는 value 구함 (현재 command 값)
				if (target.getAttribute(UiDefine.DATA_NON_EXEC) === _trueStr) {
					// 실행하지 않는 경우, ui 만 변경
					type = _uiActionType.UI;
				}

				if (UiUtil.isSpectrumColorPickerArea(widgetNode) || CommonFrameUtil.hasClass(widgetNode, UiDefine.PREVIEW_COLOR_TEXT_CLASS)) {
					// 현재 widget 이 spectrum color picker 영역 내에 있는 경우
					curValue = this._getCommandItemValue(command, target).value;
					isHoldLayerMenu = true;
				} else if (UiUtil.isInputWrapWidget(widgetNode)) {
					// 현재 input wrap 에서 발생된 값 사용
					curValue = this.getInputValue(widgetNode, null, true);
					isCheckbox = UiUtil.isCheckboxWidget(widgetNode);

					if (isCheckbox && UiUtil.isButtonDontCare(widgetNode)) {
						// dontCare checkbox 인 경우, 현재 check 된 것으로 인정
						curValue = this.addValue(curValue, _trueStr, valueKey);
					}

					if (UiUtil.isTextInputWidget(target)) {
						unit = UiFrameworkInfo.getUnitInfo(UiUtil.getWidgetName(command, valueKey));
					}
				} else {
					// 현재 적용되어야 할 값 반영 (input 사용하지 않은 widget)
					curValue = this.getButtonOnValue(target);

					if (curValue) {
						unit = target.getAttribute(UiDefine.DATA_UNIT_ATTR);

						// off 값이 만들어 져야 하는 경우 (on 이거나, combo 가 아니면서 dontCare)
						needOffValue = UiUtil.isButtonOn(widgetNode)
							|| (!isCombo && UiUtil.isButtonDontCare(widgetNode));
						nodeName = widgetNode.nodeName;

						if (needOffValue && (nodeName === "A" || nodeName === "DIV")) {
							if (widgetNode.hasAttribute(UiDefine.DATA_SWITCH_BUTTON)) {
								if (UiFrameworkInfo.getModuleName() !== UiDefine.MODULE_NAME_WEBCELL
									&& widgetNode.getAttribute(UiDefine.DATA_SWITCH_BUTTON) !== "repeatable") {
									// switch 버튼은 현재 값을 또 내보내지 않음 (webcell 제외)
									curValue = null;
								}
							} else {
								// switch 버튼이 아니라면, 현재 값은 "off"
								curValue = _defineValue.OFF;
							}
						}
					}
				}

				if (isControlBtn || curValue != null) {
					valueInfo = this._getCommandItemValue(command, target);
					orgValue = valueInfo.value;
					checkedList = valueInfo.checkedList;

					if (isControlBtn) {
						/* 현재 text input 에 focus 돼 있는 상태에서 click 으로 result button 실행하면
						 * change 되기 전의 값으로 EventAction 이 생성되므로, 추가로 값 구함 */
						activeEl = target.ownerDocument.activeElement;

						if (activeEl && UiUtil.isInput(activeEl)) {
							inputWrapEl = UiUtil.getInputWrapWidgetByInput(activeEl);
							if (UiUtil.isTextInputWidget(inputWrapEl)) {
								addValue = this.getValue(inputWrapEl);

								orgValue = this.addValue(
									orgValue, addValue, activeEl.getAttribute(UiDefine.DATA_VALUE_KEY));
							}
						}

						if (!valueKey && curValue === _defineValue.EXECUTE) {
							// valueKey 없이 "execute" value 갖는 경우, orgValue 그대로 사용
							curValue = null;
						}
					}

					curValue = this.addValue(orgValue, curValue, valueKey);

					if (checkedList && curValue && valueKey) {
						// checkedList 에 현재 선택된 값 반영
						checkedIdx = checkedList.indexOf(valueKey);
						curCheckValue = curValue[valueKey];

						if (isCheckbox && curCheckValue === _defineValue.FALSE) {
							// checkbox 값은 현재 함수에서는 "false" 가 "true" 로 지정될 예정인 값
							if (checkedIdx === -1) {
								checkedList[checkedList.length] = valueKey;
							}
						} else if (checkedIdx !== -1) {
							checkedList.splice(checkedIdx, 1);
						}
					}

					dialogCmdValue = UiFrameworkInfo.getValueFromMsgDialogCmdMap(command);

					if (dialogCmdValue && curValue && typeof curValue === "object") {
						curValue.command = dialogCmdValue;
					}

					evtAction = this.makeEventActionObj(_updateCmd, type, command, curValue);

					if (spinnerType) {
						evtAction = this.addSpinnerValue(
							evtAction, valueKey, target, spinnerType === UiDefine.SPINNER_TYPE.UPPER);
					}

					if (unit != null) {
						evtAction = this.addUnitProperty(evtAction, unit, valueKey);
					}

					if (checkedList && checkedList.length) {
						this.addCheckedListProperty(evtAction, checkedList);
					}

				} else {
					// 현재 값과 동일한 경우 등에는 layer menu close 만 동작
					evtAction = this.makeEventActionObj(
						_updateCmd, _uiActionType.UI, _uiCommandNames.CLOSE_MENU, "");
				}

			} else if (UiUtil.isUiCommandButton(target)) {
				command = target.getAttribute(UiDefine.DATA_UI_COMMAND);
				curValue = target.getAttribute(UiDefine.DATA_UI_VALUE) || "";
				evtAction = this.makeEventActionObj(_updateCmd, _uiActionType.UI, command, curValue);
			}

			if (evtAction && target) {
				// dblClick property 추가, dblClick 인 경우 원래의 target 으로 지정
				evtAction.dblClick = isDblClick;
				evtAction.target = (isDblClick && orgTarget) ? orgTarget : target;

				if (orgTarget !== evtAction.target) {
					// target 이 달라진 경우, orgTarget property 추가
					evtAction.orgTarget = orgTarget;
				}

				selectAllInfo = UiFrameworkInfo.getSelectAllInfo(
					command, UiFrameworkInfo.getCommandItemIndex(command, widgetNode));

				if (selectAllInfo && selectAllInfo.selectAllInput) {
					if (selectAllInfo.selectAllInput === UiUtil.getInputElementByWidget(widgetNode)) {
						// selectAll checkbox 누른 경우는 현재값과 반대로 selectAll value 지정
						if (selectAllInfo.selectAllInput.checked) {
							selectAllValue = _defineValue.NOT_ALL;
							selectAllValueStr = _defineValue.FALSE;
							selectCheckArr = selectAllInfo.checkedArr;
						} else {
							selectAllValue = _defineValue.ALL;
							selectAllValueStr = _trueStr;
							selectCheckArr = selectAllInfo.unCheckedArr;
						}

						if (CommonFrameUtil.isObject(evtAction.value)) {
							// selectAllTarget 들에 해당하는 값들 같이 변경
							curValue = evtAction.value;
							valueKeyArr = Object.keys(curValue);
							len = valueKeyArr.length;

							for (i = 0; i < len; i++) {
								curValueKey = valueKeyArr[i];

								if (selectCheckArr.indexOf(curValueKey) !== -1) {
									// 현재 보여지고, 반대 값을 가진 경우에 변경값 지정
									curValue[curValueKey] = selectAllValueStr;
								}
							}
						}

					} else if (type !== _uiActionType.UI) {
						selectAllValue = selectAllInfo.selectAllInput.checked ? _defineValue.ALL : _defineValue.NOT_ALL;
					}

					if (selectAllValue) {
						if (selectAllValue === _defineValue.ALL &&
							Object.keys(selectAllInfo.checkBoxInputs).length
							!== (selectAllInfo.unCheckedArr.length + selectAllInfo.checkedArr.length)) {
							/* 숨겨진(필터된) checkbox 가 1개 이상인 경우
							 * selectAll 값을 "filteredAll" 로 지정 (보여지는것에 한해 selectAll 인 상황) */
							selectAllValue = _defineValue.FILTERED_ALL;
						}

						this.addSelectAllProperty(evtAction, selectAllValue);
					}
				}

				if (isHoldLayerMenu) {
					evtAction.holdLayerMenu = isHoldLayerMenu;
				}
			}

			return evtAction;
		},

		/**
		 * List ActionObject 생성
		 * @param {Array} listArr			- EventAction 의 Array
		 * @returns {Object}
		 */
		makeListEventAction: function(listArr) {
			var listActionObj = this.makeEventActionObj("list", "", "", null, null);
			listActionObj.list = listArr;
			return listActionObj;
		},

		/**
		 * 해당 widget 에서 value 로 사용될 command element return
		 * @param {Element} widgetNode
		 * @returns {Array}
		 */
		getValueTargetCommands: function(widgetNode) {
			var isCombo = UiUtil.isCombo(widgetNode),
				nodes = [],
				valueKeyElsLen = 0,
				valueTarget, commandNodes, customDropdownName, targetBoxEl, dropdownBoxEl,
				valueKeyEls, valueKeyEl, i;

			if (UiUtil.isButtonDontCare(widgetNode) || UiUtil.isTextareaWidget(widgetNode)) {
				nodes[nodes.length] = widgetNode;

			} else if (UiUtil.isInputWrapWidget(widgetNode)) {
				// inputWrapWidget (text combo 포함)

				valueTarget = UiUtil.getInputElementByWidget(widgetNode);
				if (valueTarget) {
					if (valueTarget.type !== "radio" || valueTarget.checked) {
						// checked 되지 않은 radio 는 on 대상 아님 (나머지 inputWrapWidget 은 value 대상)
						nodes[nodes.length] = widgetNode;
					}
				}

			} else if (isCombo || UiUtil.isDropdown(widgetNode) || UiUtil.isSampleWrap(widgetNode)) {
				// dropdown/combo widget 이 widgetNode 으로 지정된 경우, on 된 값을 widgetNode 으로 조정
				customDropdownName = UiUtil.getCustomLayoutDropdownName(widgetNode);

				if (customDropdownName) {
					// dropdown(combo)의 listBox
					dropdownBoxEl = widgetNode.lastElementChild.firstElementChild;

					if (customDropdownName === UiDefine.COLOR_PICKER_CLASS
						&& CommonFrameUtil.hasClass(dropdownBoxEl, UiDefine.DETAIL_COLOR_CONTENT_CLASS)) {
						// 사용자지정탭이 있는 color-picker
						if (dropdownBoxEl.firstElementChild.checked) {
							// 첫번째 탭이 열렸으면, default_color_content
							targetBoxEl = dropdownBoxEl.querySelector("." + UiDefine.DEFAULT_COLOR_CONTENT_CLASS);
						} else {
							// 나머지는 spectrum_color_content
							targetBoxEl = dropdownBoxEl.querySelector("." + UiDefine.SPECTRUM_COLOR_CONTENT_CLASS);
						}

					} else {
						targetBoxEl = widgetNode;
					}

					// on 되어있는 값 + inputWrap widget
					if (targetBoxEl) {
						commandNodes = targetBoxEl.querySelectorAll('.' + _onStr +'[' + UiDefine.DATA_COMMAND + '], .' + UiDefine.INPUT_WRAP_CLASS);
						nodes = CommonFrameUtil.getCollectionToArray(commandNodes);
					}

				} else {
					if (UiUtil.isSampleWrap(widgetNode)) {
						valueKeyEls = widgetNode.querySelectorAll('[' + UiDefine.DATA_COMMAND + '][' + UiDefine.DATA_VALUE_KEY + ']');

						valueKeyElsLen = valueKeyEls.length;
						for (i = 0; i < valueKeyElsLen; i++) {
							valueKeyEl = valueKeyEls[i];
							if (UiUtil.isInputWrapWidget(valueKeyEl) || UiUtil.isButtonOn(valueKeyEl)) {
								nodes[nodes.length] = valueKeyEl;
							}
						}
					}

					if (valueKeyElsLen === 0) {
						valueTarget = widgetNode.querySelector('.' + _onStr + '[' + UiDefine.DATA_COMMAND + ']');
						nodes[nodes.length] = valueTarget;
					}
				}

			} else if (UiUtil.isActionCommandButton(widgetNode)) {
				if (UiUtil.isButtonOn(widgetNode)) {
					nodes[nodes.length] = widgetNode;
				}
			}

			return nodes;
		},

		/**
		 * 기존 addValue 에 현재 addValue 추가
		 * @param {Object|String} orgValue	- 기존 값
		 * @param {Object|String} addValue	- 현재 적용할 값
		 * @param {String=} valueKey		- 현재 적용할 값의 valueKey
		 * @returns {Object|String}
		 */
		addValue: function(orgValue, addValue, valueKey) {
			var isObjTypeOrgValue = (CommonFrameUtil.isObject(orgValue)),
				curValue;

			if (isObjTypeOrgValue || (valueKey && addValue != null)) {
				// object type 의 addValue 가 되어야 하는 command
				if (!orgValue || !isObjTypeOrgValue) {
					orgValue = {};
				}

				if (valueKey) {
					// valueKey 가 있는 경우 추가로 값 지정
					curValue = (CommonFrameUtil.isObject(addValue)) ? addValue[valueKey] : addValue;
					if (curValue != null) { // empty string 은 value 로 인정
						orgValue[valueKey] = curValue;
					}
				}
				// orgValue 를 addValue 로 지정
				addValue = orgValue;

				if (CommonFrameUtil.isEmptyObject(addValue)) {
					addValue = null;
				}

			} else {
				if (addValue == null) { // empty string 은 value 로 인정 이외의 경우는 기존값 보존
					addValue = orgValue;
				}
			}

			return addValue;
		},

		/**
		 * button 이 기본적으로 갖는 값 return
		 * @param {Element} buttonElement
		 * @param {Object=} curValue	현재 object type value 생성중인 경우 지정 (여기에 property 추가해서 return)
		 * @returns {String|Object}
		 */
		getButtonOnValue: function(buttonElement, curValue) {
			var comboValue = (UiUtil.isCombo(buttonElement.parentNode)) ?
					buttonElement.parentNode.getAttribute(UiDefine.DATA_VALUE) : null,
				value = comboValue || buttonElement.getAttribute(UiDefine.DATA_VALUE);

			if (value) {
				if (CommonFrameUtil.isStartsWith(value, "{") && CommonFrameUtil.isEndsWith(value, "}")) {
					value = JSON.parse(value);
				}
			} else {
				if (!UiUtil.isControlButton(buttonElement)) {
					// 기본적으로 on/off 되는 버튼
					value = _onStr;
				}
			}

			return this.addValue(curValue, value, UiUtil.getValueKey(buttonElement));
		},

		/**
		 * 현재 input command element 에 있는 input value 구함
		 * @param {Node} commandElement
		 * @param {Object=} curValue		현재 object type value 생성중인 경우 지정 (여기에 property 추가해서 return)
		 * @param {Boolean=} isInputType	"input" type 으로 현재 text 값 그대로 사용할 경우 true 지정
		 * @returns {String|Object}
		 */
		getInputValue: function(commandElement, curValue, isInputType) {
			var valueTarget = UiUtil.getInputElementByWidget(commandElement),
				value = null,
				inputType, dataValue;

			if (valueTarget) {
				inputType = valueTarget.type;
				if (inputType === "checkbox") {
					value = String(valueTarget.checked);
				} else if (inputType === "file") {
					value = commandElement;
				} else {
					value = valueTarget.value;

					if (CommonFrameUtil.hasClass(commandElement, UiDefine.PREVIEW_COLOR_TEXT_CLASS)) {
						dataValue = isInputType ? null : commandElement.getAttribute(UiDefine.DATA_VALUE);
						if (dataValue) {
							value = dataValue;
						} else {
							value = "#" + value;
						}
					}

					value = value || "";
				}
			}

			return this.addValue(curValue, value, UiUtil.getValueKey(commandElement));
		},

		/**
		 * 현재 textarea command element 에 있는 value 구함
		 * @param {Node} commandElement
		 * @param {Object=} curValue		현재 object type value 생성중인 경우 지정 (여기에 property 추가해서 return)
		 * @returns {String|Object}
		 */
		getTextareaValue: function (commandElement, curValue) {
			var value = null;

			if (UiUtil.isTextareaWidget(commandElement)) {
				value = commandElement.value || "";
			}

			return this.addValue(curValue, value, UiUtil.getValueKey(commandElement));
		},

		/**
		 * 해당 command 내부의 value return
		 * @param {Element} commandElement
		 * @param {Object=} curValue	현재 object type value 생성중인 경우 지정 (여기에 property 추가해서 return)
		 * @returns {String|Object}
		 */
		getValue: function(commandElement, curValue) {
			var value;

			if (!commandElement) {
				return curValue || null;
			}

			if (UiUtil.isButtonDontCare(commandElement)) {
				value = this.addValue(curValue, _dontCareValue, UiUtil.getValueKey(commandElement));

			} else if (UiUtil.isInputWrapWidget(commandElement)) {
				value = this.getInputValue(commandElement, curValue);

			} else if (UiUtil.isTextareaWidget(commandElement)) {
				value = this.getTextareaValue(commandElement, curValue);

			} else {
				value = this.getButtonOnValue(commandElement, curValue);
			}

			return value;
		},

		/**
		 * 해당 command 내부의 value return
		 * @param {String} commandName
		 * @param {Element} widgetEl
		 * @param {String=} valueKey		- valueKey 있는경우 지정
		 * @returns {String}
		 */
		getWidgetValue: function (commandName, widgetEl, valueKey) {
			var value = this._getCommandItemValue(commandName, widgetEl, valueKey).value,
				isObjectValue = CommonFrameUtil.isObject(value);

			if (valueKey || isObjectValue) {
				if (isObjectValue) {
					valueKey = valueKey || UiUtil.getValueKey(widgetEl);
					value = value[valueKey] || null;
				} else {
					value = null;
				}
			}

			return value;
		},

		/**
		 * 현재 eventAction 에 focus property 추가 (focus 줄 수 있는 속성)
		 * @param {Object} eventAction			- 대상
		 * @param {String=} valueKey			- object value 인 경우, 특정 valueKey 지정
		 * @returns {Object}
		 */
		addFocusProperty: function(eventAction, valueKey) {
			if (eventAction) {
				eventAction.focus = valueKey || _onStr;
			}

			return eventAction;
		},

		/**
		 * 현재 eventAction 에 unit 변경 property 추가
		 * @param {Object} eventAction			- 대상 (input)
		 * @param {String=} newUnit			- 단위 (빈 string 또는 미지정시 삭제)
		 * @param {String=} valueKey			- value 가 object type 인 경우, 구분할 key string
		 * 											(미지정시 모든 key 또는 object type 이 아님)
		 * @returns {Object}
		 */
		addUnitProperty: function(eventAction, newUnit, valueKey) {
			var unit;

			if (eventAction) {
				newUnit = newUnit || "";

				if (valueKey) {
					unit = eventAction.unit;

					if (!CommonFrameUtil.isObject(unit)) {
						unit = {};
					}
					unit[valueKey] = newUnit;

				} else {
					unit = newUnit;
				}
				eventAction.unit = unit;
			}

			return eventAction;
		},

		/**
		 * layerMenu close 하지 않도록 하는 property 추가
		 * @param {Object} eventAction			- 대상
		 * @returns {Object}
		 */
		addHoldLayerMenuProperty: function(eventAction) {
			if (eventAction) {
				eventAction.holdLayerMenu = true;
			}

			return eventAction;
		},

		/**
		 * match 동작하도록 하는 match property 추가
		 * @param {Object} eventAction			- 대상
		 * @param {String} matchValue
		 * @param {String=} valueKey			- value 가 object type 인 경우, 구분할 key string
		 * 											(미지정시 모든 key 또는 object type 이 아님)
		 * @returns {Object}
		 */
		addMatchProperty: function(eventAction, matchValue, valueKey) {
			var match;

			if (eventAction && matchValue) {
				if (valueKey) {
					match = eventAction.match;

					if (!CommonFrameUtil.isObject(match)) {
						match = {};
					}
					match[valueKey] = matchValue;

				} else {
					match = matchValue;
				}

				eventAction.match = match;
			}

			return eventAction;
		},

		/**
		 * selectAll 선택여부 property 추가
		 * @param {Object} eventAction			- 대상
		 * @param {String=} value				- "all": 숨겨진 항목 포함 모두 선택
		 * 										  "false" : 선택하지 않음 (기본)
		 * 										  "partial" : 보여지는 것만 모두 선택
		 * @returns {Object}
		 */
		addSelectAllProperty: function(eventAction, value) {
			if (eventAction && value) {
				eventAction.selectAll = value;
			}

			return eventAction;
		},

		/**
		 * uiCommand property 추가 (해당 command 만을 eventAction 대상으로 한정)
		 * @param {Object} eventAction			- 대상
		 * @param {String} uiCommandName		- eventAction 대상으로 한정할 ui command name
		 * @returns {Object}
		 */
		addUiCommandProperty: function (eventAction, uiCommandName) {
			if (eventAction && uiCommandName) {
				eventAction.uiCommand = uiCommandName;
			}

			return eventAction;
		},

		/**
		 * checkedList property 추가 (value 중에서 "true" 인 valueKey 들을 Array 로 담음)
		 * (checkBox 의 선택값을 "true" 로 지정하므로, 선택된 checkBox 들의 이름, 개수를 얻을 수 있음)
		 * @param {Object} eventAction			- 대상
		 * @param {Array} checkedList	- value 중에서 선택된 checkBox 의 valueKey 들의 Array
		 * @returns {Object}
		 */
		addCheckedListProperty: function (eventAction, checkedList) {
			if (eventAction && checkedList) {
				eventAction.checkedList = checkedList;
			}

			return eventAction;
		},

		/**
		 * 현재 eventAction value 를 spinner 적용 이후 value 로 변경
		 * @param {Object} eventAction			- 대상 (input)
		 * @param {String} valueKey
		 * @param {Element} target				- input wrap widget
		 * @param {Boolean} isUpper			- true:upper, false:lower
		 * @returns {Object}
		 */
		addSpinnerValue: function(eventAction, valueKey, target, isUpper) {
			var inputEl = UiUtil.getInputElementByWidget(target),
				unitEl = inputEl ? inputEl.nextElementSibling : null,
				addValue = (unitEl && unitEl.innerText === "cm") ? 0.1 : 1,
				valueProp = eventAction ? eventAction.value : null,
				curValue = 0,
				strCurValue, limit, resultValue;

			if (!isUpper) {
				addValue = addValue * -1;
			}

			if (valueProp) {
				curValue = parseFloat(valueKey ? valueProp[valueKey] : valueProp) || 0;
				strCurValue = String(curValue);
				limit = strCurValue.length - strCurValue.indexOf(".");
			}
			resultValue = String(CommonFrameUtil.getRoundNumber(curValue + addValue, limit));

			if (valueKey) {
				eventAction.value[valueKey] = resultValue;
			} else {
				eventAction.value = resultValue;
			}

			return eventAction;
		},

		/**
		 * 현재 target 을 실행 후, UI 닫는 EventAction 생성 (필요시)
		 * @param {Element} target		- 대상
		 * @returns {Object}
		 */
		makeMenuCloseEventAction: function(target) {
			var eventAction = null,
				value = "",
				name;

			if (UiUtil.isActionCommandButton(target)) {
				// action command 인 경우 menu close 동작 추가
				name = _uiCommandNames.CLOSE_MENU;
				value = "popup";
			}

			if (name) {
				eventAction = this.makeEventActionObj(_updateCmd, _uiActionType.UI, name, value);
			}

			return eventAction;
		},

		/**
		 * 현재 inputElement 의 input event action 생성
		 * @param {Element} textInputEl
		 * @param {Boolean=} isAllValue
		 * @returns {Object}
		 */
		makeInputEventAction: function(textInputEl, isAllValue) {
			var eventAction = null,
				nodeName = textInputEl.nodeName,
				isInputNode = nodeName === "INPUT",
				isTextareaNode = nodeName === "TEXTAREA",
				widgetWrap, name, valueKey, unit, val;

			if (isInputNode) {
				widgetWrap = UiUtil.getInputWrapWidgetByInput(textInputEl);
			} else if (isTextareaNode) {
				widgetWrap = textInputEl;
			}

			name = widgetWrap ? widgetWrap.getAttribute(UiDefine.DATA_COMMAND) : "";

			if (isAllValue == null) {
				if (isInputNode) {
					val = this.getInputValue(widgetWrap, null, true);
				} else if (isTextareaNode) {
					val = this.getTextareaValue(widgetWrap, null);
				}
			} else {
				val = this._getCommandItemValue(name, widgetWrap).value;
			}

			if (name) {
				eventAction = this.makeEventActionObj(
					_updateCmd, _uiActionType.INPUT, name, val, widgetWrap);

				valueKey = UiUtil.getValueKey(widgetWrap);
				unit = UiFrameworkInfo.getUnitInfo(UiUtil.getWidgetName(name, valueKey));

				if (CommonFrameUtil.isString(unit)) {
					this.addUnitProperty(eventAction, unit, valueKey);
				}
			}

			return eventAction;
		},

		isListAction: function(eventAction) {
			return !!(eventAction.list);
		},

		/**
		 * 2개 EventAction 을 ListEventAction 으로 생성
		 * @param {Object=} curAction		- EventAction (없는 경우 addAction return)
		 * @param {Object=} addAction		- EventAction (없는 경우 curAction return)
		 * @returns {Object}	list 또는 단일의 EventAction
		 */
		addEventAction: function(curAction, addAction) {
			var listProp;

			if (addAction && curAction) {
				if (this.isListAction(curAction)) {
					listProp = curAction.list;
				} else {
					listProp = [curAction];
					curAction = this.makeListEventAction(listProp);
				}

				listProp[listProp.length] = addAction;
			}

			return curAction || addAction;
		},

		/**
		 * 원래의 FontName 값으로 돌리는 UI EventAction 으로 변경해주는 함수
		 * @param {Object} eventAction		- EventAction
		 * @param {String} orgValue		- 되돌아갈 FontName
		 * @returns {Object}
		 */
		changeOrgFontUiAction: function(eventAction, orgValue) {
			if (!eventAction) {
				return null;
			}

			eventAction.value = orgValue;
			eventAction.type = _uiActionType.UI;

			return eventAction;
		}
	};
});
