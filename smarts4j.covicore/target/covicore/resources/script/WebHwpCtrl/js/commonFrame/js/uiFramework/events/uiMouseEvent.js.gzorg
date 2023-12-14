define(function (require) {
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var CommonFrameUtil = require("commonFrameJs/utils/util"),
		UiUtil = require("commonFrameJs/uiFramework/uiUtil"),
		UiFrameworkInfo = require("commonFrameJs/uiFramework/uiFrameworkInfo"),
		FrameworkUtil = require("commonFrameJs/uiFramework/frameworkUtil"),
		UiDefine = require("commonFrameJs/uiFramework/uiDefine"),
		UiController = require("commonFrameJs/uiFramework/uiController");

	var _formulaResizeClass = UiDefine.FORMULA_RESIZE,
		_arrowkeysHoverWidgetSelector = UiDefine.FIND_WIDGET_SELECTOR_FOR_HOVER.join(","),
		_movableBoxSelector = UiDefine.FIND_MOVABLE_BOX_FOR_HOVER.join(","),
		_arrowKeysHoverClass = UiDefine.ARROWKEY_HOVER_CLASS,
		_subGroupClass = UiDefine.SUB_GROUP_ELEMENT_CLASS,
		_subGroupBoxClass = UiDefine.SUB_GROUP_BOX_ELEMENT_CLASS;

	/**
	 * mouse move 시, 드롭다운 리스트의 move target을 찾아 hover 처리한다.
	 * @param {Element|Node} target				이벤트 타겟
	 */
	function _checkHoverMove(target) {
		var listMenu = UiFrameworkInfo.getDropdownBoxList(),
			dropdownListInfo = UiFrameworkInfo.getDropdownListInfo(),
			dropdownContainerInfo, arrowKeyHoverWidget, subGroup, moveTarget, hoverWidget, index, length,
			targetContainerInfo, i, newListBox, targetLayer, targetContainer, dropdownContainer;

		if (!(listMenu && target)
			|| CommonFrameUtil.hasClass(target, _subGroupBoxClass)
			//라디오, 체크박스 여백 부분 제외
			|| UiUtil.isRadioWidget(target)
			|| UiUtil.isCheckboxWidget(target)) {
			return;
		}

		targetContainerInfo = UiUtil.findContainerInfoToParent(target);
		dropdownContainerInfo = UiUtil.findContainerInfoToParent(listMenu);
		targetContainer = targetContainerInfo.container;
		dropdownContainer = dropdownContainerInfo.container;

		moveTarget = CommonFrameUtil.findParentNode(target, _arrowkeysHoverWidgetSelector, targetContainer);

		if (moveTarget) {
			targetLayer = CommonFrameUtil.findParentNode(moveTarget, _movableBoxSelector);

			// target layer 가 리스트박스, 포커스패널 인 경우 mouse hover 대상에서 제외
			if (UiUtil.isListBox(targetLayer) || UiUtil.isFocusablePanel(targetLayer)) {
				return;
			} else if (!targetLayer || ((dropdownContainer && targetContainer) && dropdownContainer !== targetContainer)) {
				if (dropdownListInfo.listBox && !dropdownListInfo.isKeyPressed) {
					FrameworkUtil.clearArrowKeyHover(true);
				}

				return;
			}

			subGroup = CommonFrameUtil.findParentNode(moveTarget, "." + _subGroupClass, targetContainer);
			arrowKeyHoverWidget = CommonFrameUtil.getCollectionToArray(dropdownListInfo.hoverWidgetList) || [];
			newListBox = targetLayer;
			index = arrowKeyHoverWidget.indexOf(newListBox);
			length = arrowKeyHoverWidget.length;

			// arrowKeyHover class 를 제거한다. (moveTarget 기준)
			for (i = (index > -1 ? index : 0); i < length; i++) {
				hoverWidget = arrowKeyHoverWidget[i];

				// moveTarget 이 targetLayer 안에 있지 않는 경우만 class 를 제거
				if (hoverWidget !== targetLayer) {
					CommonFrameUtil.removeClass(arrowKeyHoverWidget[i], _arrowKeysHoverClass);
					FrameworkUtil.removeLayerKeyFocus(arrowKeyHoverWidget[i]);
				}
			}

			CommonFrameUtil.addClass(moveTarget, _arrowKeysHoverClass);

			// subGroup 의 경우 하위 subGroupBox 가 열려있지 않은 경우
			if (subGroup && (listMenu !== CommonFrameUtil.findParentNode(moveTarget, "." + _subGroupBoxClass, subGroup))) {
				CommonFrameUtil.addClass(subGroup.lastChild, _arrowKeysHoverClass);
				newListBox = subGroup.lastChild;
				//subGroupBox 위치 조정
				UiController.setPosSubBox(newListBox);
			}

			if (newListBox !== dropdownListInfo.listBox) {
				dropdownListInfo = UiFrameworkInfo.initDropdownListInfo(newListBox, 0, dropdownListInfo.parentIndex);
			}

			if (dropdownListInfo.listBox) {
				dropdownListInfo.isKeyPressed = false;
				UiFrameworkInfo.setDropdownListInfo(dropdownListInfo);
				UiFrameworkInfo.setDropdownListIndex(null, moveTarget);
			}
		} else {
			if (dropdownListInfo.listBox && !dropdownListInfo.isKeyPressed) {
				FrameworkUtil.clearArrowKeyHover();
			}
		}
	}

	function _getFormulaBarEl() {
		var formulaBarArr = UiFrameworkInfo.getInfo(UiFrameworkInfo.WIDGET_MAP)[_formulaResizeClass] || null,
			formulaBarEl = formulaBarArr && formulaBarArr[0];

		return formulaBarEl || null;
	}

	return {
		/**
		 * UI 관련 마우스 다운 이벤트 콜백 함수
		 * @param {Object} e                    - 이벤트 객체
		 * @param {Object} containerInfo        - 컨테이너 노드 정보
		 * @returns {Boolean}                   - 이벤트 금지 여부
		 */
		doMouseDownEvent: function (e, containerInfo) {
			var target = e.target,
				isStopEvent = false,
				targetContainerInfo = containerInfo || UiController.findContainerInfoToParent(target),
				containerNode = targetContainerInfo && targetContainerInfo.container,
				result;

			if (!containerNode) {
				return isStopEvent;
			}

			if (target === _getFormulaBarEl()) {
				UiFrameworkInfo.setMouseMoveInfo({
					target: target,
					x: e.clientX,
					y: e.clientY
				});

				isStopEvent = true;
			} else if (UiController.isDialogTitleArea(target)) {
				UiFrameworkInfo.setMouseMoveInfo({
					containerNode: targetContainerInfo.container,
					target: targetContainerInfo.topNode,
					x: e.clientX,
					y: e.clientY
				});
			} else if (UiController.isSpectrumColorPickerArea(target)) {
				result = UiController.selectSpectrumColor(target, {x: e.clientX, y: e.clientY});
				UiFrameworkInfo.setMouseMoveInfo({
					containerNode: targetContainerInfo.container,
					target: target,
					layerNode: containerInfo.layerNode,
					spectrumArea: result.spectrumArea,
					x: e.clientX,
					y: e.clientY
				});
			}

			return isStopEvent;
		},

		/**
		 * UI 관련 마우스 무브 이벤트 콜백 함수
		 * @param {Object} e            - 이벤트 객체
		 */
		doMouseMoveEvent: function (e) {
			var target = e.target,
				moveInfo = UiFrameworkInfo.getMouseMoveInfo(),
				moveInfoTarget, formulaHeight, targetParent, posInfo, isFolded;

			_checkHoverMove(target);

			if (moveInfo) {
				// mouse left button down 상태
				if ((e.buttons & 1) === 1) {
					moveInfoTarget = moveInfo.target;

					if (moveInfoTarget && moveInfoTarget === _getFormulaBarEl()) {
						targetParent = moveInfoTarget.parentNode;

						if (targetParent) {
							isFolded = UiUtil.isFolded(targetParent);
							formulaHeight = e.clientY - targetParent.getBoundingClientRect().top;

							if (formulaHeight <= UiDefine.FORMULA_MIN_HEIGHT) {
								if (targetParent.style.height) {
									targetParent.style.height = "";
								}

								if (!isFolded) {
									UiController._foldView(targetParent, UiDefine.FORMULA_BAR_PARENT, false);
								}

							} else {
								if (formulaHeight > UiDefine.FORMULA_MAX_HEIGHT) {
									formulaHeight = UiDefine.FORMULA_MAX_HEIGHT;
								}

								if (formulaHeight !== parseFloat(targetParent.style.height)) {
									targetParent.style.height = formulaHeight + "px";
								}

								if (isFolded) {
									UiController._foldView(targetParent, UiDefine.FORMULA_BAR_PARENT, true);
								}
							}

							UiController.closeLayerMenu();
						}
					} else {
						if (CommonFrameUtil.hasClass(moveInfo.layerNode, UiDefine.COLOR_PICKER_CLASS)) {
							// colorPicker layer menu 인 경우
							posInfo = UiController.moveColorPickerPos(e, moveInfo);
						} else {
							// dialog view 인 경우
							posInfo = UiController.moveDialogPos(e.clientX - moveInfo.x, e.clientY - moveInfo.y);
						}

						moveInfo.x += posInfo.left;
						moveInfo.y += posInfo.top;

						UiFrameworkInfo.setMouseMoveInfo(moveInfo);
					}
				} else {
					UiFrameworkInfo.setMouseMoveInfo(null);
				}
			}
		},

		/**
		 * UI 관련 마우스 업 이벤트 콜백 함수
		 * @param {Object} e            - 이벤트 객체
		 */
		doMouseUpEvent: function (e) {
			var moveInfo = UiFrameworkInfo.getMouseMoveInfo(),
				moveInfoTarget;

			if (moveInfo) {
				moveInfoTarget = moveInfo.target;

				if (moveInfoTarget && moveInfoTarget === _getFormulaBarEl()) {
					FrameworkUtil.fireCustomEvent({
						kind: UiDefine.CUSTOM_EVENT_KIND.WIDGET,
						type: UiDefine.CUSTOM_EVENT_TYPE.UI_RESIZE,
						execTarget: moveInfoTarget,
						name: UiDefine.FORMULA_RESIZE
					});
				} else if (CommonFrameUtil.hasClass(moveInfo.layerNode, UiDefine.COLOR_PICKER_CLASS)) {
					UiController.selectSpectrumColor(moveInfoTarget, {x: moveInfo.x, y: moveInfo.y}, true);
				}

				UiFrameworkInfo.setMouseMoveInfo(null);
			}
		}
	};
});