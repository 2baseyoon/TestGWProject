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

	var _hideViewClassName = UiDefine.HIDE_VIEW_CLASS,
		_subGroupClass = UiDefine.SUB_GROUP_ELEMENT_CLASS,
		_dropdownSelectListWrapClass = UiDefine.DROPDOWN_SELECT_LIST_WRAP_CLASS,
		_titleBarId = UiDefine.TITLE_BAR_ID,
		_contextMenuId = UiDefine.CONTEXT_MENU_ID,
		_titlePanelClass = UiDefine.TITLE_PANEL_WRAP_CLASS,
		_keyCodeMap = CommonFrameUtil.keyCodeMap,
		_arrowUpKeyCode = parseInt(_keyCodeMap.up, 10),
		_arrowDownKeyCode = parseInt(_keyCodeMap.down, 10),
		_arrowLeftKeyCode = parseInt(_keyCodeMap.left, 10),
		_arrowRightKeyCode = parseInt(_keyCodeMap.right, 10),
		_homeKeyCode = parseInt(_keyCodeMap.home, 10),
		_tabKeyCode = parseInt(_keyCodeMap.tab, 10),
		_endKeyCode = parseInt(_keyCodeMap.end, 10),
		_pageUpKeyCode = parseInt(_keyCodeMap.pageup, 10),
		_pageDownKeyCode = parseInt(_keyCodeMap.pagedown, 10),
		_arrowKeysHoverClass = UiDefine.ARROWKEY_HOVER_CLASS,
		_layerTabFocusClass = UiDefine.LAYER_KEY_FOCUS,
		_ignoreRefTreeKeyArr = UiDefine.IGNORE_REF_TREE_KEY_ARR,
		_foldViewClassName = UiDefine.FOLD_VIEW_CLASS,
		_dialogContainers = [UiDefine.MODAL_DIALOG_ID, UiDefine.MODELESS_DIALOG_ID],
		_navigationKeys = [_homeKeyCode, _endKeyCode, _pageUpKeyCode, _pageDownKeyCode, _tabKeyCode],
		_dataUiCommand = UiDefine.DATA_UI_COMMAND,
		_findWidgetSelector = "." + UiDefine.FOCUSABLE_CLASS,
		_movableBoxSelector = UiDefine.FIND_MOVABLE_BOX_FOR_HOVER.join(",");

	function _isEnableFindWidget(target, containerNode) {
		if (!target) {
			return;
		}

		var isEnable = false,
			targetCmdEl = UiUtil.findCommandElementToParent(target, containerNode) || target;

		if (targetCmdEl) {
			if (targetCmdEl.getAttribute(_dataUiCommand) === UiDefine.UI_COMMAND_NAME.DROPDOWN) {
				targetCmdEl = target;
			}

			// targetCmdEl 가 offsetWidth 를 가지고 있고 (화면에 보이고 있음의 기준)
			// hide, disable 상태가 아니고 dropdown 의 서브메뉴에 있지 않아야 함
			if (targetCmdEl.offsetWidth !== 0 && !UiUtil.isHidden(targetCmdEl) && !UiUtil.isDisabled(targetCmdEl)
				&& !CommonFrameUtil.findParentNode(targetCmdEl, "." + UiDefine.DROPDOWN_SELECT_LIST_WRAP_CLASS, containerNode)) {
				isEnable = true;

				// listBox or focusablePanel 일 때 하위에 widget 이 없는 경우 제외
				// TODO: 하위 아이템이 모두 hide 또는 disable 이 될 경우 확인이 필요함.
				if ((UiUtil.isListBox(targetCmdEl) || UiUtil.isFocusablePanel(targetCmdEl))
					&& !targetCmdEl.querySelector("." + UiDefine.BUTTON_CLASS)) {
					isEnable = false;
				}
			}
		}

		return isEnable;
	}

	function _setWidgetElObj(containerId, curRefItem, widgetElObj, dialogName) {
		if (!containerId || !curRefItem || !widgetElObj) {
			return [];
		}

		var viewNode = curRefItem.ref,
			isDialog = _dialogContainers.indexOf(containerId) !== -1,
			widgetElList = isDialog ? [] : widgetElObj[containerId],
			findWidgetList;

		if (viewNode) {
			findWidgetList = CommonFrameUtil.getCollectionToArray(viewNode.querySelectorAll(_findWidgetSelector));

			if (findWidgetList.length !== 0) {
				widgetElList = widgetElList.concat(findWidgetList);
			}

			if (!isDialog) {
				widgetElObj[containerId] = widgetElList;
			} else if (dialogName) {
				widgetElObj[containerId][dialogName] = widgetElList;
			}

			UiFrameworkInfo.setFocusWidgetElObjInfo(widgetElObj);
		}

		return widgetElList;
	}

	return {
		/**
		 * 드롭다운 리스트에서 방향키로 이동 시, 대상 위젯을 찾은 다음 hover 처리를 한다.
		 * @param {Number} keyCode						키 코드 (숫자)
		 * @param {Element|Node} listMenu				드롭다운 리스트 박스
		 * @returns {Node}								방향키로 이동할 대상 위젯
		 */
		moveToTargetByArrowKeys: function (keyCode, listMenu) {
			var target = null,
				isDoubleDropdown = false,
				dropdownListInfo = UiFrameworkInfo.getDropdownListInfo(),
				isLeftOrRight, isLeftOrUp, targetDir, curLayer, onItem, targetTop, targetHeight, listMenuHeight,
				beforeTarget, scrollVal, dropdownListLen, isRevolving, curIndex, titlePanelList, offsetTargetLimit,
				initListMenu;

			//리스트 아이템의 위치를 기준으로 다음 선택할 대상을 찾는다.
			var __findTargetByPos = function (currentEl) {
				var nextTarget = null,
					firstTarget = null,
					i, currentClientRect, currentPos, comparePosVal, beforeDif, currentDif,
					targetPos, targetClientRect, listItem, isValidTopPos;

				if (!(currentEl && dropdownListInfo.listData)) {
					return nextTarget;
				}

				targetClientRect = currentEl.getBoundingClientRect();
				targetPos = isLeftOrRight ? targetClientRect.left : targetClientRect.top;

				for (i = 0; i < dropdownListInfo.listData.length; i++) {
					listItem = dropdownListInfo.listData[i];

					if (listItem !== currentEl) {
						currentClientRect = listItem.getBoundingClientRect();
						currentPos = isLeftOrRight ? currentClientRect.left : currentClientRect.top;
						comparePosVal = !!(isLeftOrUp ? targetPos > currentPos : targetPos < currentPos);
						isValidTopPos = !(isLeftOrRight && targetClientRect.top !== currentClientRect.top);

						if (comparePosVal && isValidTopPos) {
							currentDif = Math.abs(targetClientRect.top - currentClientRect.top) + Math.abs(targetClientRect.left - currentClientRect.left);

							// left 와 top 를 기준으로 가장 근접한 (값이 적은) 위치에 있으면 대상으로 인정한다.
							if (!beforeDif || beforeDif > currentDif) {
								beforeDif = currentDif;
								nextTarget = listItem;

								// UP/DOWN 이동일때 기존 아이템의 left 값이 비교하는 아이템의 크기의 사이에 위치하면 우선순위를 부여한다.
								if (!isLeftOrRight
									&& listItem !== firstTarget
									&& currentClientRect.left <= targetClientRect.left
									&& currentClientRect.right >= targetClientRect.left) {

									firstTarget = listItem;
								}
							}
						}
					}
				}

				return firstTarget || nextTarget;
			};

			// param 잘못된 값 여부 체크 (QUnit 버그 처리)
			if (!CommonFrameUtil.isNumber(keyCode) || listMenu == null) {
				return null;
			}

			isLeftOrRight = (keyCode === _arrowLeftKeyCode || keyCode === _arrowRightKeyCode);
			isLeftOrUp = (keyCode == _arrowLeftKeyCode || keyCode == _arrowUpKeyCode);
			targetDir = isLeftOrUp ? -1 : 1;

			if (dropdownListInfo.isCustomStyle) {
				curLayer = UiFrameworkInfo.getLayerMenu();
				curLayer = curLayer ? curLayer.nextElementSibling: null;

				//드롭다운 안에 드롭다운이 열렸을 때 (이중 레이어)
				if (curLayer !== listMenu && CommonFrameUtil.hasClass(curLayer, _dropdownSelectListWrapClass)
					&& !CommonFrameUtil.hasClass(listMenu, UiDefine.SUB_GROUP_BOX_ELEMENT_CLASS)) {
					FrameworkUtil.clearArrowKeyHover();
					dropdownListInfo = UiFrameworkInfo.getDropdownListInfo();
					listMenu = curLayer;
					isDoubleDropdown = true;
				}
			}

			//드롭다운 리스트 정보 초기 세팅
			if (CommonFrameUtil.isEmptyObject(dropdownListInfo)) {
				dropdownListInfo = UiFrameworkInfo.initDropdownListInfo(listMenu, -1);
			}

			//이전 선택되었던 메뉴 or 'on' 되어 있는 메뉴
			if (dropdownListInfo.index === -1) {
				if (CommonFrameUtil.hasClass(listMenu,
					[_dropdownSelectListWrapClass, UiDefine.LIST_BOX_CLASS, UiDefine.TAB_GROUP_CLASS, UiDefine.FOCUSABLE_PANEL_CLASS])) {
					onItem = listMenu.querySelectorAll(".on");
					beforeTarget = onItem[(dropdownListInfo.isCustomStyle && !isDoubleDropdown) ? onItem.length - 1 : 0];

					UiFrameworkInfo.setDropdownListIndex(null, beforeTarget);
				}

				if (keyCode === _tabKeyCode) {
					if (beforeTarget) {
						target = beforeTarget;
					} else {
						target = dropdownListInfo.listData[0];
						UiFrameworkInfo.setDropdownListIndex(null, target);
					}
				}
			} else {
				beforeTarget = dropdownListInfo.listData[dropdownListInfo.index];
			}

			dropdownListLen = dropdownListInfo.listData.length;

			//커스텀 스타일(그리드 or 칼라피커 or 도형) 드롭다운은 위젯들의 위치를 검사하여 찾는다.
			if (dropdownListInfo.isCustomStyle && _navigationKeys.indexOf(keyCode) === -1) {
				if (beforeTarget && dropdownListLen > 0) {
					target = __findTargetByPos(beforeTarget);
					if (target) {
						UiFrameworkInfo.setDropdownListIndex(null, target);
					}
				}
			}

			if (!target) {
				//오른쪽 방향키로 서브 그룹 메뉴 레이어를 열 때
				if (keyCode === _arrowRightKeyCode && CommonFrameUtil.hasClass(beforeTarget, _subGroupClass)) {
					listMenu = beforeTarget.lastChild;
					CommonFrameUtil.addClass(listMenu, _arrowKeysHoverClass);
					dropdownListInfo = UiFrameworkInfo.initDropdownListInfo(listMenu, 0, dropdownListInfo.index);
					beforeTarget = null;
					listMenu.scrollTop = 0;
					UiController.setPosSubBox(listMenu);
				//왼쪽 방향키로 서브 그룹 메뉴 레이어를 닫을 때
				} else if (keyCode === _arrowLeftKeyCode && dropdownListInfo.isSubGroup) {
					curIndex = dropdownListInfo.parentIndex;
					CommonFrameUtil.removeClass(dropdownListInfo.listBox, _arrowKeysHoverClass);
					initListMenu = CommonFrameUtil.findParentNode(listMenu.parentNode, _movableBoxSelector, dropdownListInfo.container)
						|| dropdownListInfo.container;
					dropdownListInfo = UiFrameworkInfo.initDropdownListInfo(initListMenu, curIndex || 0);

					if (typeof curIndex !== "number") {
						UiFrameworkInfo.setDropdownListIndex(null, listMenu.parentNode);
					}
				//타이틀바 메뉴에서 왼쪽, 오른쪽 방향키 이동할 경우
				} else if (isLeftOrRight && CommonFrameUtil.hasClass(dropdownListInfo.container, _titleBarId)) {
					listMenu = CommonFrameUtil.findParentNode(listMenu, "." + _titlePanelClass);

					if (listMenu) {
						titlePanelList = listMenu.parentNode.childNodes;

						do {
							listMenu = listMenu ? listMenu[isLeftOrUp ? "previousElementSibling" : "nextElementSibling"]
								: titlePanelList[isLeftOrUp ? titlePanelList.length - 1 : 0];
						} while (!CommonFrameUtil.hasClass(listMenu, _titlePanelClass));

						FrameworkUtil.setTitleBarMenuOverOn(listMenu.firstElementChild);

						dropdownListInfo = UiFrameworkInfo.initDropdownListInfo(listMenu.lastChild, 0);
					}
				//홈, 페이지업 키로 메뉴 첫번째 아이템으로 이동할 때
				} else if (keyCode === _homeKeyCode || keyCode === _pageUpKeyCode) {
					dropdownListInfo.index = 0;
				//엔드, 페이지다운 키로 메뉴 마지막 아이템으로 이동할 때
				} else if (keyCode === _endKeyCode || keyCode === _pageDownKeyCode) {
					dropdownListInfo.index = dropdownListLen - 1;
				//위, 아래 방향키 이동 or 탭 그룹/커스텀 박스에서 왼쪽, 오른쪽 방향키 이동
				} else if (!isLeftOrRight || (isLeftOrRight && (dropdownListInfo.isTabGroup || dropdownListInfo.isCustomStyle))) {
					dropdownListInfo.index += targetDir;

					isRevolving = CommonFrameUtil.hasClass(dropdownListInfo.container, [_titleBarId, _contextMenuId])
									|| dropdownListInfo.isCustomStyle
									|| dropdownListInfo.isTabGroup;

					if (dropdownListInfo.index === dropdownListLen || (dropdownListInfo.isCustomStyle && keyCode == _arrowDownKeyCode)) {
						dropdownListInfo.index = isRevolving ? 0 : dropdownListLen - 1;
					} else if (dropdownListInfo.index <= -1 || (dropdownListInfo.isCustomStyle && keyCode == _arrowUpKeyCode)) {
						dropdownListInfo.index = isRevolving ? dropdownListLen - 1 : 0;
					}
				}

				target = dropdownListInfo.listData[dropdownListInfo.index];
			}

			//드롭다운 리스트 아이템의 클래스 설정 및 scroll 처리
			if (target && beforeTarget !== target) {
				if (!dropdownListInfo.isKeyPressed) {
					dropdownListInfo.isKeyPressed = true;
				}

				UiFrameworkInfo.setDropdownListInfo(dropdownListInfo);

				if (!CommonFrameUtil.hasClass(target, _arrowKeysHoverClass)) {
					CommonFrameUtil.addClass(target, _arrowKeysHoverClass);

					// Layer 레벨의 전용 Key Focus 대상이면 전용 클래스를 추가한다.
					if (target.nodeName === "LABEL" && !CommonFrameUtil.hasClass(target, _layerTabFocusClass)) {
						CommonFrameUtil.addClass(target, _layerTabFocusClass);
					}
				}

				if (beforeTarget) {
					CommonFrameUtil.removeClass(beforeTarget, _arrowKeysHoverClass);

					// Layer 레벨의 전용 Key Focus 가 있으면 제거한다.
					FrameworkUtil.removeLayerKeyFocus(beforeTarget);
				}

				offsetTargetLimit = UiUtil.hasClassToTarget(listMenu, UiDefine.INLINE_PANEL_CLASS) ? listMenu.offsetParent : listMenu;

				targetTop = CommonFrameUtil.getOffsetTop(target, offsetTargetLimit);
				targetHeight = CommonFrameUtil.getOffsetHeight(target);
				listMenuHeight = CommonFrameUtil.getOffsetHeight(listMenu);

				if (keyCode === _arrowUpKeyCode || keyCode === _homeKeyCode || keyCode === _pageUpKeyCode) {
					scrollVal = targetTop - 4;
				} else if (keyCode === _arrowDownKeyCode || keyCode === _endKeyCode || keyCode === _pageDownKeyCode) {
					scrollVal = targetTop;
					scrollVal -= listMenuHeight - targetHeight - 4;
				}

				if (listMenuHeight + listMenu.scrollTop < targetTop + targetHeight || listMenu.scrollTop > targetTop) {
					listMenu.scrollTop = Math.max(0, scrollVal);
				}
			}

			return target;
		},

		/**
		 * input element 가 활성화된 상태에서 tab key 입력 시, 다음 focus 대상의 input element 를 찾는 함수
		 *
		 * @param {Boolean} inputShiftKey					- shift key 가 눌렸는지 아닌지.
		 * @param {Element} containerNode					- side bar, style bar, modal dialog
		 * @param {Boolean=} isFocusReturn					- focus 가 끝까지 갔을 때, 다시 처음으로 돌아갈건지 여부 (default: false)
		 * @param {Element=} curWidgetEl					- 현재 focus widget element (default: 내부 변수)
		 *
		 * @return {Element|null}
		 */
		findFocusWidgetEl: function (inputShiftKey, containerNode, isFocusReturn, curWidgetEl) {
			if (containerNode == null) {
				return null;
			}

			var id = containerNode.id,
				keyLen = 0,
				widgetElList = [],
				isDialog = _dialogContainers.indexOf(id) !== -1,
				widgetElObj = UiFrameworkInfo.getFocusWidgetInfo().widgetElObj || {},
				isEmptyWidgetElList = false,
				dialogName = "",
				refTree, containerRefTree, viewKeys, viewKey, i, orgIndex, widgetEl, target, dialogShowingInfo;

			var __findPrevWidgetTarget = function (startIndex) {
				var resultTarget = null,
					index = startIndex;

				while (index > -1) {
					widgetEl = widgetElList[index--];
					if (_isEnableFindWidget(widgetEl, containerNode)) {
						resultTarget = widgetEl;
						break;
					}
				}

				return resultTarget;
			};

			var __findNextWidgetTarget = function (startIndex) {
				var resultTarget = null,
					index = startIndex,
					length = widgetElList.length;

				while (index < length) {
					widgetEl = widgetElList[index++];
					if (_isEnableFindWidget(widgetEl, containerNode)) {
						resultTarget = widgetEl;
						break;
					}
				}

				return resultTarget;
			};

			// 만약 containerNode 가 fold 혹은 hide 된 상태라면, widget element 를 찾지 않고 패스한다.
			if (CommonFrameUtil.hasClass(containerNode, _foldViewClassName)
				|| CommonFrameUtil.hasClass(containerNode, _hideViewClassName)) {
				return null;
			}

			refTree = UiFrameworkInfo.getRefTree();
			containerRefTree = refTree && refTree[id];

			if (containerRefTree) {
				if (!widgetElObj[id]) {
					isEmptyWidgetElList = true;
					widgetElObj[id] = isDialog ? {} : [];
				}

				if (isDialog) {
					dialogShowingInfo = UiFrameworkInfo.getDialogShowing();

					if (dialogShowingInfo) {
						dialogName = dialogShowingInfo.value;
						isEmptyWidgetElList = !widgetElObj[id][dialogName];
					}
				}

				// widget element 가 caching 되어있지 않다면, caching 을 한다.
				if (isEmptyWidgetElList) {
					// styleBar, contextMenu, menuBar, dialog 인 경우
					if (id === UiDefine.STYLEBAR_ID || id === UiDefine.CONTEXT_MENU_ID || id === UiDefine.MENU_BAR_ID || isDialog) {
						if (isDialog) {
							containerRefTree = containerRefTree[dialogName];
						}

						widgetElList = _setWidgetElObj(id, containerRefTree, widgetElObj, dialogName);
					} else {
						// 그 외 containerNode 의 경우
						viewKeys = Object.keys(containerRefTree);
						keyLen = (viewKeys && viewKeys.length) || 0;

						// cache 할 대상인 widget element 를 검색하고, caching 하는 과정
						for (i = 0; i < keyLen; ++i) {
							viewKey = viewKeys[i];
							if (_ignoreRefTreeKeyArr.indexOf(viewKey) === -1) {
								widgetElList = _setWidgetElObj(id, containerRefTree[viewKey], widgetElObj);
							}
						}
					}
				} else {
					if (!isDialog) {
						widgetElList = widgetElObj[id];
					} else if (dialogName) {
						widgetElList = widgetElObj[id][dialogName];
					}
				}
			}

			if (widgetElList && widgetElList.length > 0) {
				if (!curWidgetEl) {
					curWidgetEl = UiFrameworkInfo.getFocusWidgetInfo().curWidgetEl;
				}

				// 현재 widget element 의 이전, 이후 node 를 검색하면서 이동될 widget target 을 찾는다.
				orgIndex = widgetElList.indexOf(curWidgetEl);

				if (inputShiftKey) {
					target = __findPrevWidgetTarget(orgIndex - 1);
				} else {
					target = __findNextWidgetTarget(orgIndex + 1);
				}

				// isFocusReturn 옵션이 true 인 경우, 보이는 영역의 처음으로 돌아가 widget target 을 찾는다.
				if (isFocusReturn == true && !target) {
					if (inputShiftKey) {
						target = __findPrevWidgetTarget(widgetElList.length - 1);
					} else {
						target = __findNextWidgetTarget(0);
					}
				}
			}

			return target || null;
		},

		getKeyEventFocusTarget: function() {
			var target = UiController.getFocusWidgetInfo().curWidgetEl;

			if (!target && UiController.getContainerOfDialogShowing()) {
				target = UiController.getShowingModalDialogElement();
			}

			return target || null;
		},

		getSpinnerTarget: function(keyCode) {
			var focusTarget = this.getKeyEventFocusTarget(),
				focusParentEl = focusTarget && focusTarget.parentNode,
				spinnerTarget = null,
				spinnerWrap;

			if (focusParentEl && (keyCode === _arrowUpKeyCode || keyCode === _arrowDownKeyCode)
				&& UiUtil.isTextInputWidget(focusParentEl) && !UiUtil.isCombo(focusParentEl.parentNode)) {
				//스피너 증감
				spinnerWrap = focusParentEl.querySelector("." + UiDefine.SPINNER_WRAP_CLASS);

				if (spinnerWrap) {
					spinnerTarget = (keyCode === _arrowUpKeyCode) ?
						spinnerWrap.firstElementChild : spinnerWrap.lastElementChild;
				}
			}

			return spinnerTarget;
		},

		/**
		 * 방향키 keyDown event 처리 함수
		 * @param {Object} e					- 이벤트 객체
		 * @returns {Object}					- {	executeWidget: {Element|null} 수행 대상 widget,
		 * 										   	isStopEvent: {Boolean} 이벤트 정지 여부}
		 */
		doArrowKeyDown: function (e) {
			var target = e.target,
				keyCode = e.keyCode,
				isUpDownKey = (keyCode === _arrowUpKeyCode || keyCode === _arrowDownKeyCode),
				listMenu = UiFrameworkInfo.getDropdownBoxList(),
				isStopEvent = false,
				isMovable = true,
				execWidget = this.getSpinnerTarget(keyCode) || null,
				focusTarget, commandEl, tab, focusInputWrap;

			/*
			var blurForceTextInput = function(eleInput, eleInputWrap) {
				var activeEl = document.activeElement,
					containerNode;

				if (!(eleInput && eleInputWrap)) {
					return;
				}

				if (activeEl && activeEl.nodeName === "IFRAME") {
					activeEl.blur();

					 // * safari 브라우저는 iframe 에 blur 를 해도 activeElement 가 iframe 에서 빠지지 않을 수 있다.
					 // * 따라서 다시한번 검사해서 여전히 iframe 에 머무르고 있으면 focus 를 window 로 전환시켜 준다.
					activeEl = document.activeElement;
					if (activeEl && activeEl.nodeName === "IFRAME") {
						window.focus();
					}
				} else {
					eleInput.blur();
				}

				containerNode = UiUtil.findContainerInfoToParent(eleInputWrap).container;
				if (containerNode && containerNode === UiController.getContainerOfDialogShowing()) {
					UiFrameworkInfo.setFocusWidgetInfo(eleInput);
				}
			}; */

			if (execWidget) {
				isStopEvent = true;
			} else if (listMenu) {
				// dropdown box 열린 상태
				focusTarget = this.getKeyEventFocusTarget();

				if (focusTarget && UiUtil.isInput(focusTarget)) {
					focusInputWrap = UiUtil.getInputWrapWidgetByInput(focusTarget);

					// Layer 레벨의 text input 에서는 방향키에 따른 Layer Item 이동은 하지 않는다.
					if (UiUtil.isTextInputWidget(focusInputWrap)) {
						commandEl = focusInputWrap.parentNode;

						/**
						 * text input wrap 의 바로 상위 노드가 combo 일때만 상/하 방향키 이동 수행한다.
						 * 참고로 findCommandWrapToParent 를 통해 위로 탐색하여 commandWrap 를 찾으면 안된다.
						 */
						if (!(UiUtil.isCombo(commandEl) && isUpDownKey)) {
							isMovable = false;
						}
					} else {
						// tool filter dialog 안 input (radio, checkbox, file, text) 에서는 방향키 이동시 아무 동작 하지 않는다.
						if (CommonFrameUtil.hasClass(listMenu, UiDefine.TOOL_FILTER_DIALOG)) {
							isMovable = false;
						}
					}
				}

				if (isMovable) {
					isStopEvent = !!(this.moveToTargetByArrowKeys(keyCode, listMenu));

					if (target.nodeName !== "INPUT" || [_arrowLeftKeyCode, _arrowRightKeyCode].indexOf(keyCode) === -1) {
						isStopEvent = true;
					}
				}
			} else {
				if (isUpDownKey) {
					focusTarget = this.getKeyEventFocusTarget();

					if (focusTarget) {
						commandEl = UiUtil.findCommandWrapToParent(focusTarget);

						if (!UiUtil.isBrowserFocusUsedWidget(commandEl || focusTarget)) {
							if (UiUtil.isDropdown(commandEl) || UiUtil.isCombo(commandEl)) {
								//드롭다운 레이어 토글 (target)
								execWidget = commandEl.childNodes[1];
							}

							isStopEvent = true;
						}
					}
				} else if (keyCode === _arrowRightKeyCode || keyCode === _arrowLeftKeyCode) {
					focusTarget = this.getKeyEventFocusTarget();

					if (CommonFrameUtil.hasClass(focusTarget, UiDefine.TAB_GROUP_CLASS)) {
						//다이얼로그 탭 그룹 이동
						tab = this.moveToTargetByArrowKeys(keyCode, focusTarget);

						if (tab) {
							tab.click();
						}
					}
				}
			}

			return {
				"executeWidget": execWidget,
				"isStopEvent": isStopEvent
			};
		},

		doTabKeyDown: function(e) {
			var curFocusTarget = this.getKeyEventFocusTarget(),
				isModalDialogTarget = (curFocusTarget && curFocusTarget === UiController.getShowingModalDialogElement()),
				containerNode = UiUtil.findContainerInfoToParent(curFocusTarget).container,
				findTarget = null,
				result = false,
				layerMenu = UiFrameworkInfo.getLayerMenu(),
				isToolFilterDlg = CommonFrameUtil.hasClass(layerMenu, UiDefine.TOOL_FILTER_DIALOG);

			if (!isToolFilterDlg && (UiUtil.isUiFocusWidget(curFocusTarget) || isModalDialogTarget)) {
				// 현재 widget 기준으로 이동 될 widget target
				findTarget = this.findFocusWidgetEl(e.shiftKey, containerNode, true);

				if (findTarget != null) {
					// 포커스 대상을 이동하기 전 열려 있는 layer 가 있다면 닫는다.
					UiController.closeLayerMenu();
					// 이동할 대상에 Focus 를 설정한다.
					UiController.setWidgetFocus(findTarget);

					// 이동할 대상이 ListBox or FocusablePanel 이면 arrowkey_hover class 를 추가로 등록해 준다.
					if (UiUtil.isListBox(findTarget) || UiUtil.isFocusablePanel(findTarget)) {
						this.moveToTargetByArrowKeys(e.keyCode, findTarget);
					}
				}

				result = true;
			} else if (curFocusTarget || layerMenu) {
				result = true;
			}

			return result;
		},

		doEnterKeyDown: function(e) {
			var target = this.getKeyEventFocusTarget(),
				isInputTag = UiUtil.isInput(target),
				containerNode = UiUtil.findContainerInfoToParent(target).container,
				isDialogContainer = containerNode && containerNode === UiController.getContainerOfDialogShowing(),
				listMenu = UiFrameworkInfo.getDropdownBoxList(),
				execWidget = isInputTag ? UiUtil.getInputWrapWidgetByInput(target) : target,
				dropdownListInfo, isExec, isTextWidget, isExecuteInput, onlyEnterCommands, hasArrowKeyHover, orgInputVal;

			if (listMenu) {
				dropdownListInfo = UiFrameworkInfo.getDropdownListInfo();
				hasArrowKeyHover = !CommonFrameUtil.isEmptyObject(dropdownListInfo);

				if (execWidget && execWidget.getAttribute(UiDefine.DATA_NON_EXEC) !== "true"
					&& UiUtil.isTextInputWidget(execWidget)) {
					isExecuteInput = true;
				}

			} else if (isDialogContainer || target) {
				if (execWidget) {
					if (UiUtil.isLocalFileWidget(execWidget)) {
						target.click();
						execWidget = null;
					} else if (UiController.isTextareaWidget(e.target)) {
						execWidget = null;
					} else {
						isExec = execWidget.getAttribute(UiDefine.DATA_NON_EXEC) !== "true";
						isTextWidget = UiUtil.isTextInputWidget(execWidget);

						if (isExec && isTextWidget) {
							isExecuteInput = true;
						} else if (UiUtil.isListBox(execWidget) || UiUtil.isFocusablePanel(execWidget)
							|| CommonFrameUtil.hasClass(execWidget, UiDefine.TAB_GROUP_CLASS)) {
							execWidget = null;
						} else {
							// dialog 내 focus 된 text widget / dropdown / button combo 에서
							// enter 를 누른경우 command target 으로 변경하여 event action 을 처리한다.
							if (isDialogContainer && (isTextWidget || UiUtil.isDropdown(execWidget) || UiUtil.isCombo(execWidget))) {
								execWidget = this.getResultButtonElementByWidget(execWidget) || execWidget;
								if (UiUtil.isEnabled(execWidget)) {
									isExec = true;
								}
							}

							if (isExec) {
								// input 태그 이벤트는 App 레벨에서 추가 처리가 있으므로, isAppSend=true 로 할당한다.
								if (!UiController.getShowingModelessDialogElement()) {
									UiFrameworkInfo.removeFocusWidgetInfo();
								}
							} else {
								execWidget = null;
							}
						}
					}
				}
			}

			if (isExecuteInput) {
				if (hasArrowKeyHover) {
					/**
					 * input text 에 focus 있는 상태로 dropdown 이 열려있었던 상황 (input 도 동시에 blur)
					 * 또, 하위에 값이 "on" 되어있는 경우는 input 값은 원복시킴 (사용하지않음)
					 **/
					orgInputVal = UiController.getFocusWidgetInfo().orgInputValue;
					if (orgInputVal != null) {
						target.value = orgInputVal;
					}
				} else {
					/**
					 * enter key 로만 실행하는 input 을 제외하고는 모두 blur 후 "change" event 에서 실행하므로,
					 * enter key 에서 execWidget 으로 사용하지 않음.
					 */
					onlyEnterCommands = UiDefine.NOT_EXECUTED_BY_CHANGE_INPUT_LIST[UiFrameworkInfo.getModuleName()];

					if (onlyEnterCommands
						&& onlyEnterCommands.indexOf(UiUtil.getEventActionCommand(execWidget)) !== -1) {
						// "change" 로 실행하지 않는다면, enter 때 값 갱신하고 실행하도록 처리
						UiController.setFocusWidgetInfo(target);
					} else {
						// 이외의 경우는 blur 이후 "change" 이벤트에서 실행하므로 추가 실행하지 않음
						execWidget = null;
					}
				}

				target.blur();
			}

			if (hasArrowKeyHover) {
				execWidget = dropdownListInfo.listData[dropdownListInfo.index];

				// listMenu 의 실행 위젯이 dropdown element 이면 arrow element 로 변경해 준다.
				if (CommonFrameUtil.hasClass(execWidget, UiDefine.DROPDOWN_CLASS)) {
					execWidget = UiController.findCommandElementToParent(execWidget);
				}
			}

			return execWidget;
		},

		doSpaceKeyDown: function(e) {
			var target = this.getKeyEventFocusTarget(),
				execWidget = null;

			if (target) {
				// input checkbox / radio 에서 space 키가 눌리면 command 를 실행한다.
				if (UiUtil.isRadioWidget(target) || UiUtil.isCheckboxWidget(target)) {
					// input 태그 이벤트는 App 레벨에서 추가 처리가 있으므로, isAppSend=true 로 할당한다.
					execWidget = target;
				} else if (UiUtil.isInput(target) && target.type === "file") {
					// input localFile 에서 space 키가 눌리면 click 이벤트를 발생시킨다.
					target.click();
				}
			}

			return execWidget;
		},

		doEscKeyDown: function (e) {
			var isClosed = UiController.closeLayerMenu(UiController.getLastLayerMenu()),
				closedType = UiDefine.CLOSED_TYPE.NONE,
				dlgShowingInfo, dlgNode, closeBtnEl, execWidget;

			// esc 를 눌렀을 때, layer 가 모두 닫혀있고,
			// quick menu 가 열려있으면 close 를 시도한다.
			if (isClosed) {
				closedType = UiDefine.CLOSED_TYPE.LAYER_MENU;

			} else {
				isClosed = UiController.hideQuickMenu();

				if (isClosed) {
					closedType = UiDefine.CLOSED_TYPE.QUICK_MENU;
				}

				if (UiController.isEscCloseableDialogShowing()) {
					dlgShowingInfo = UiController.getDialogShowingInfo();
					dlgNode = dlgShowingInfo.viewNode;

					if (dlgNode) {
						closeBtnEl = dlgNode.querySelector("." + UiDefine.CLOSE_BTN_CLASS);

						if (closeBtnEl) {
							closedType = UiDefine.CLOSED_TYPE.DIALOG;
							execWidget = closeBtnEl;
						}
					}
				}
			}

			return {
				"executeWidget": execWidget || null,
				"closedType": closedType
			};
		},

		doInputEvent: function (e) {
			var focusWidgetInfo = UiFrameworkInfo.getFocusWidgetInfo(),
				focusWidgetEl = focusWidgetInfo.curWidgetEl,
				focusWidgetWrapEl = focusWidgetInfo.curWidgetWrapEl;

			if (focusWidgetEl && UiUtil.isInput(focusWidgetEl)) {
				if (!CommonFrameUtil.isEmptyObject(UiFrameworkInfo.getDropdownListInfo())) {
					// input 에 focus 있고 arrowKeyHover 가 있는 상태에서 "input" event 시 arrowKeyHover 는 삭제
					FrameworkUtil.clearArrowKeyHover(true);
				}

				if (focusWidgetWrapEl && UiUtil.isButtonDontCare(focusWidgetWrapEl)) {
					/*
					 * dontCare 상태의 input 에 input event 발생시 해당 widget 은 dontCare 종료
					 * 이후 input type 아닌 EventAction 발생시 정식으로 dontCare 종료됨
					 **/
					UiController._setButtonDontCareOff(focusWidgetWrapEl);
				}
			}
		},

		/**
		 * 특정 command 내 widget 으로부터 result button 구함.
		 * @param {Element} target		- widget element
		 * @returns {Element}
		 */
		getResultButtonElementByWidget: function (target) {
			return UiFrameworkInfo.getResultButtonElementByWidget(target) || target;
		},

		/**
		 * target 이 현재 focus widget 과 다르면 제거.
		 * @param {Element} target				- event target
		 * @param {Object} containerInfo		- containerInfo
		 * @param {Element} commandEl			- 상위 commandEl 지정
		 */
		blurFocusWidgetIfDiffTarget: function (target, containerInfo, commandEl) {
			if (!(target && containerInfo && containerInfo.container)) {
				return;
			}

			var curFocusWidgetInfo = UiController.getFocusWidgetInfo(),
				curFocusWidget = curFocusWidgetInfo.curWidgetEl,
				isEqualTarget = false,
				isSetFocusWidget = false,
				textInputValidTypes = ["text", "number", "url"],
				dialogContainer = UiController.getContainerOfDialogShowing(),
				cancelChange = false,
				containerNode = containerInfo.container,
				activeEl, curContainerInfo, curContainerNode, isNotDocumentArea, focusBoxEl, isTargetInputEl,
				cmdParentEl, curFocusCmdWrapEl, isSavableWidget, isTargetTextInputEl;

			var __isEqualFocusTarget = function (orgTarget, curCmdEl, containerNode) {
				var result = false,
					orgCmdEl = UiUtil.findCommandElementToParent(orgTarget, containerNode);

				if (orgCmdEl === curCmdEl) {
					result = true;
				} else if (UiUtil.isTabButton(curCmdEl)) {
					result = (curCmdEl.parentNode.parentNode === orgTarget);
				} else if (UiUtil.isDropdown(orgTarget) || UiUtil.isCombo(orgTarget)) {
					result = (UiUtil.findCommandWrapToParent(curCmdEl, containerNode) === orgTarget);
				}

				return result;
			};

			UiFrameworkInfo.setActivatedDialog(dialogContainer === containerNode ? UiFrameworkInfo.getDialogShowing().viewNode : null);

			isNotDocumentArea = !(containerNode.id === UiDefine.DOCUMENT_MENU_ID && !commandEl);

			// 웹오피스 document 영역이 아닌지 판단한다.
			if (isNotDocumentArea) {
				if (curFocusWidget) {
					if (commandEl) {
						isEqualTarget = __isEqualFocusTarget(curFocusWidget, commandEl, containerNode);
					} else {
						curContainerInfo = UiUtil.findContainerInfoToParent(curFocusWidget);
						curContainerNode = curContainerInfo.container;

						if ((curContainerNode && curContainerNode.id === UiDefine.MODELESS_DIALOG_ID)
							|| containerNode.id === UiDefine.MODELESS_DIALOG_ID) {
							// modeless dialog 를 눌렀거나 현재 modeless dialog focus

							if (containerInfo.topNode === curContainerInfo.topNode) {
								// 현재 focus 와 같은 dialog 인 경우에 한해서만 유지
								isEqualTarget = true;
							}

						} else if (!UiController.isSpectrumColorPickerArea(target)) {
							// modeless dialog 및 color picker spectrum 을 제외하고 여백을 누른 경우는 현재 focus 유지
							isEqualTarget = true;
						}
					}
				}
			}

			// event target 이 최근 focus target 과 같지 않다면 focus 정보를 제거한다.
			if (!isEqualTarget) {
				isTargetInputEl = UiUtil.isInput(target);

				if (curFocusWidget) {
					activeEl = document.activeElement;
					if (activeEl && activeEl.nodeName === "IFRAME") {
						activeEl.blur();
						/**
						 * safari 브라우저는 iframe 에 blur 를 해도 activeElement 가 iframe 에서 빠지지 않을 수 있다.
						 * 따라서 다시한번 검사해서 여전히 iframe 에 머무르고 있으면 focus 를 window 로 전환시켜 준다.
						 */
						activeEl = document.activeElement;
						if (activeEl && activeEl.nodeName === "IFRAME") {
							window.focus();
						}
						UiController.removeFocusWidgetInfo();
					} else {
						/**
						 * textInput (Combo) 에 focus 있는 상태로 dropdown 내부의 항목을 선택한 경우
						 * 선택(클릭)한 값을 실행하고, 현재 input 값을 "change" 이벤트에서 실행하지 않도록 하기 위해
						 * focus 를 빼면서 현재값을 취소시킨다.
						 */
						if (CommonFrameUtil.hasClass(containerInfo.layerNode, _dropdownSelectListWrapClass)
							&& UiUtil.isCombo(curFocusWidgetInfo.curWidgetWrapEl)
							&& UiUtil.isTextInputWidget(UiUtil.getInputWrapWidgetByInput(curFocusWidget))
							&& curFocusWidgetInfo.curWidgetWrapEl.lastElementChild === containerInfo.layerNode) {
							cancelChange = true;
						}
						UiController.removeWidgetFocus(cancelChange);
					}
				}

				// 웹오피스 document 영역이 아니고 저장 가능한 widget 일 경우 focus 정보를 저장한다.
				if (isNotDocumentArea) {
					isTargetTextInputEl = isTargetInputEl ? (textInputValidTypes.indexOf(target.type) !== -1) : false;
					isSavableWidget = commandEl && !isTargetTextInputEl && !UiUtil.isRadioWidget(target) && !UiUtil.isCheckboxWidget(target);

					/**
					 * input target 이 아닌 command 일 경우 focus 정보 저장 대상 widget 이다.
					 * radio, checkbox 의 경우, target 자체가 command 인 경우는 제외 한다. (이 경우는 command 내부를 눌렀을 때만 focus 정보를 저장)
					 */
					if (isSavableWidget) {
						/**
						 * nonExecute="true" 인 경우 focus 정보를 저장한다.
						 * dialog 내 widget 이거나 radio, checkbox 인 경우는 nonExecute 여부와 상관없이 저장한다.
						 */
						if (dialogContainer || UiUtil.isRadioWidget(commandEl) || UiUtil.isCheckboxWidget(commandEl) || commandEl.getAttribute(UiDefine.DATA_NON_EXEC) === "true") {
							cmdParentEl = commandEl.parentNode;
							if (commandEl.getAttribute(_dataUiCommand) === "dropdown" || UiUtil.isCombo(cmdParentEl)) {
								commandEl = cmdParentEl;
							}

							// 다이얼로그 내 combo widget 의 경우는 대한 focus 정보를 저장한다.
							if (dialogContainer) {
								if (UiUtil.isTabButton(commandEl)) {
									commandEl = commandEl.parentNode.parentNode;
								} else if (UiUtil.isCombo(commandEl) && UiUtil.isInputWrapWidget(commandEl)) {
									commandEl = commandEl.querySelector("." + UiDefine.FOCUSABLE_CLASS);
								} else if (UiUtil.isInput(curFocusWidget)) {
									curFocusCmdWrapEl = UiUtil.findCommandWrapToParent(curFocusWidget);
									if (UiUtil.isCombo(curFocusCmdWrapEl) && UiUtil.findCommandWrapToParent(commandEl, containerNode) === curFocusCmdWrapEl) {
										commandEl = curFocusWidget;
									}
								}
							}

							if (UiUtil.isUiFocusWidget(commandEl)) {
								UiController.setFocusWidgetInfo(commandEl);
								isSetFocusWidget = true;
							}
						}

						if (!isSetFocusWidget) {
							focusBoxEl = CommonFrameUtil.findParentNode(target, '.' + UiDefine.LIST_BOX_CLASS + ", ." + UiDefine.FOCUSABLE_PANEL_CLASS, containerNode);

							if (focusBoxEl) {
								UiController.setFocusWidgetInfo(focusBoxEl);
								UiFrameworkInfo.setDropdownListInfo(UiFrameworkInfo.initDropdownListInfo(focusBoxEl, -1));
							}
						}
					} else if (isTargetTextInputEl && UiUtil.getBrowserInfo().isMSIE
						&& UiUtil.isBrowserFocusUsedWidget(curFocusWidget)) {
						/**
						 * IE 에서 focus 될 event target 이 text input 일 때
						 * 이전 focus input blur 를 발생시키면 mousedown event 를 그대로 두어도
						 * focus 가 되지 않는 버그가 있어서 추가로 focus 처리
						 */
						target.focus();
					}
				}
			}
		}
	};
});