define( function (require){
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var $ = require("jquery"),
		CommonFrameUtil = require("commonFrameJs/utils/util"),
		UiDefine = require("commonFrameJs/uiFramework/uiDefine");


	/*******************************************************************************
	 * Private Variables
	 ******************************************************************************/
	var VALIDATION_CHECK_RESULT = UiDefine.VALIDATION_CHECK_RESULT,
		_colorCheckReg = /^#([A-Fa-f0-9]{6})$/,
		_webCheckReg = /^(file|gopher|news|nntp|telnet|https?|ftps?|sftp):\/\/([a-z0-9-]+\.)+[a-z0-9]{2,4}.*$/,
		_numberCheckReg = /^-?[0-9]\d*(\.\d*)?$/,
		_fileNameStrictCheckReg = /[\\\<\>\:\/\|\?\*\~\%]/,
		_querySelectorReg = /\\/gi,
		_fileNameForbiddenNames = ["con", "prn", "aux", "nul", "com1", "com2", "com3", "com4", "com5", "com6",
			"com7", "com8", "com9", "lpt1", "lpt2", "lpt3", "lpt4", "lpt5", "lpt6", "lpt7", "lpt8", "lpt9"],
		_userAgent = navigator.userAgent && navigator.userAgent.toLowerCase(),
		_isSafari = !!(navigator.vendor
			&& navigator.vendor.indexOf('Apple') > -1
			&& _userAgent
			&& !_userAgent.match('crios')),
		_isMSIE = !!(_userAgent && (_userAgent.indexOf("msie ") > -1 || _userAgent.indexOf("trident/") > -1)),
		_isEdge = !!(_userAgent && _userAgent.indexOf("edge/") > -1),
		_hasClass = $.proxy(CommonFrameUtil.hasClass, CommonFrameUtil),
		_defineValue = UiDefine.VALUE,
		_colorMatrixPickerClass = UiDefine.COLOR_MATRIX_PICKER_CLASS,
		_colorSpectrumPickerClass = UiDefine.COLOR_SPECTRUM_PICKER_CLASS,
		_dialogContainers = [UiDefine.MODAL_DIALOG_ID, UiDefine.MODELESS_DIALOG_ID];

	return {
		/**
		 * 문자열 조건에 따른 유효성 검사
		 * @param {*} value						: 검사할 대상의 값
		 * @param {String|Number=} min				: 최소 길이 혹은 최소 값
		 * @param {String|Number=} max				: 최대 길이 혹은 최대 값
		 * @param {Array=} signArr					: 특수기호 문자열
		 * 											 ex) 제외 할 특수기호 문자열 배열 인자
		 * @returns {Number}						: 검사 결과 값
		 * 											 ex) SUCCESS		: 결과 값이 참일 경우
		 * 												 UNDER_MIN		: 최소 길이 값보다 작을 경우
		 * 												 OVER_MAX		: 최대 길이 값보다 클 경우
		 * 												 WRONG_VALUE	: 잘못된 값일 경우 (String이 아닐 때)
		 * 												 EMPTY_VALUE	: 값이 없을 때
		 * 												 HAS_SIGN		: 제외할 특수기호가 있을 때
		 */
		checkValidationString : function (value, min, max, signArr) {
			var len, result, regExp;

			if (value) {
				if (CommonFrameUtil.isString(value)) {
					len = value.length;

					if (min && len < min) {
						result = VALIDATION_CHECK_RESULT.UNDER_MIN;
					} else if (max && len > max) {
						result = VALIDATION_CHECK_RESULT.OVER_MAX;
					}
				} else {
					result = VALIDATION_CHECK_RESULT.WRONG_VALUE;
				}
			} else {
				result = (min > 0) ? VALIDATION_CHECK_RESULT.EMPTY_VALUE : VALIDATION_CHECK_RESULT.SUCCESS;
			}

			if (!result && signArr && signArr.length) {
				regExp = new RegExp("[\\" + signArr.join("\\") + "]");
				if (regExp.test(value)) {
					result = VALIDATION_CHECK_RESULT.HAS_SIGN;
				}
			}

			return result || VALIDATION_CHECK_RESULT.SUCCESS;
		},

		/**
		 * 웹 주소 유효성 검사
		 * @param {String} value					: 검사할 대상의 값
		 * @returns {Number}						: 검사 결과 값
		 * 											 ex) SUCCESS		: 결과 값이 참일 경우
		 * 												 WRONG_VALUE	: 잘못된 값일 경우 (web주소가 아닐 때)
		 */
		checkValidationWeb : function (value) {
			return (_webCheckReg.test(value)) ? VALIDATION_CHECK_RESULT.SUCCESS : VALIDATION_CHECK_RESULT.WRONG_VALUE;
		},

		/**
		 * 숫자 조건에 따른 유효성 검사
		 * @param {*} value						: 검사할 대상의 값
		 * @param {String|Number=} min				: 최소 길이 혹은 최소 값
		 * @param {String|Number=} max				: 최대 길이 혹은 최대 값
		 * @param {String|Number=} decLen			: 소수점 뒤 자릿 수
		 * @param {Boolean=} hasMinus				: 음수 사용 여부
		 * @returns {Number}						: 검사 결과 값
		 * 											 ex) SUCCESS					: 결과 값이 참일 경우
		 * 												 UNDER_MIN					: 최소 길이 값보다 작을 경우
		 * 												 OVER_MAX					: 최대 길이 값보다 클 경우
		 * 												 OVER_DECIMAL_LENGTH		: 소수점 뒤 자릿 수가 지정된 값보다 클 때
		 * 												 NOT_NUMBER					: 숫자가 아닌 경우
		 * 												 HAS_MINUS_NUMBER			: 음수인 경우
		 */
		checkValidationNumber : function (value, min, max, decLen, hasMinus) {
			var isNumber = _numberCheckReg.test(String(value)),
				originVal = value,
				strValue, dotIdx;

			if (hasMinus && value === "-") {
				return VALIDATION_CHECK_RESULT.SUCCESS;
			}

			if (!isNumber) {
				return VALIDATION_CHECK_RESULT.NOT_NUMBER;
			}

			value = parseFloat(value);

			if (!hasMinus && value < 0) {
				return VALIDATION_CHECK_RESULT.HAS_MINUS_NUMBER;
			}

			min = parseFloat(min);
			if (CommonFrameUtil.isNumber(min)) {
				if (min > value) {
					return VALIDATION_CHECK_RESULT.UNDER_MIN;
				}
			}

			max = parseFloat(max);
			if (CommonFrameUtil.isNumber(max)) {
				if (value > max) {
					return VALIDATION_CHECK_RESULT.OVER_MAX;
				}
			}

			decLen = parseFloat(decLen);
			if (CommonFrameUtil.isNumber(decLen)) {
				strValue = String(value);
				dotIdx = strValue.indexOf(".");

				if (dotIdx !== -1 && strValue.length - (dotIdx + 1) > decLen) {
					return VALIDATION_CHECK_RESULT.OVER_DECIMAL_LENGTH;
				} else if (decLen === 0 && CommonFrameUtil.isEndsWith(String(originVal), ".")) {
					return VALIDATION_CHECK_RESULT.OVER_DECIMAL_LENGTH;
				}
			}

			return VALIDATION_CHECK_RESULT.SUCCESS;
		},

		/**
		 * 색상 코드 유효성 검사
		 * @param {String} value					: 검사할 대상의 값
		 * @returns {Number}						: 검사 결과 값
		 * 											 ex) SUCCESS		: 결과 값이 참일 경우
		 * 												 WRONG_VALUE	: 잘못된 값일 경우 (색상코드가 아닐 때)
		 */
		checkValidationColorCode : function (value) {
			return (_colorCheckReg.test(value)) ? VALIDATION_CHECK_RESULT.SUCCESS : VALIDATION_CHECK_RESULT.WRONG_VALUE;
		},

		/**
		 * 그림 파일 확장자, 사이즈 등을 검사
		 * @param {Node|Element} inputEl			: 검사할 Input 엘리먼트
		 * @returns {Number}						: 검사 결과 값
		 * 											 ex) SUCCESS				: 결과 값이 참일 경우
		 * 												 OVER_MAX				: 5MB보다 클 경우
		 * 												 WRONG_VALUE			: 파일 정보가 없을 경우
		 * 												 UNSUPPORTED_EXTENSION	: 잘못된 파일 확장자일 경우
		 * 																		(gif, jpeg, jpg, png, bmp 만 허용)
		 */
		checkValidationImageFile : function (inputEl) {
			var fileInfo = CommonFrameUtil.getFileInfo(inputEl),
				result;

			if (fileInfo && fileInfo.name) {
				if ((fileInfo.size || 0) > UiDefine.IMAGE_FILE_MAX_SIZE) {
					result = VALIDATION_CHECK_RESULT.OVER_MAX;
				}

				if (!result) {
					if (fileInfo.mainType !== "image" || UiDefine.IMAGE_FILE_TYPE.indexOf(fileInfo.subType) === -1) {
						result =  VALIDATION_CHECK_RESULT.UNSUPPORTED_EXTENSION;
					}
				}
			} else {
				result = VALIDATION_CHECK_RESULT.WRONG_VALUE;
			}

			return result || VALIDATION_CHECK_RESULT.SUCCESS;
		},

		/**
		 * 파일 이름 조건에 따른 유효성 검사
		 * @param {*} value						: 검사할 대상의 값
		 * @param {String} fileExt					: 파일 확장자 명 ("strict" 모드에서만 검사)
		 * @param {String} mode					: 검사 유형
		 * @param {String|Number=} max				: 최대 길이 혹은 최대 값
		 * @returns {Number}						: 검사 결과 값
		 * 											 ex) SUCCESS					: 결과 값이 참일 경우
		 * 												 EMPTY_VALUE				: 값이 없을 때
		 * 												 OVER_MAX					: 최대 길이 값보다 클 경우
		 * 												 INVALID_SPECIAL_CHARACTER	: 제외할 특수기호가 있을 때
		 * 												 WRONG_VALUE				: 잘못된 값일 경우
		 * 												 PROHIBITED_FILE_NAME		: 파일명이 예약어일 경우 (_fileNameForbiddenNames)
		 */
		checkValidationFileName : function (value, fileExt, mode, max) {
			var valueLen = value.length,
				valueLowerCase, i, result;

			if (!value || valueLen === 0) {
				result = VALIDATION_CHECK_RESULT.EMPTY_VALUE;
			}

			max = parseFloat(max);
			if (!result && CommonFrameUtil.isNumber(max) && valueLen > max) {
				result = VALIDATION_CHECK_RESULT.OVER_MAX;
			}

			if (mode === "strict") {
				if (!result && _fileNameStrictCheckReg.test(value)) {
					result = VALIDATION_CHECK_RESULT.INVALID_SPECIAL_CHARACTER;
				}

				if (!result && (!fileExt || fileExt.length === 0)) {
					result = VALIDATION_CHECK_RESULT.WRONG_VALUE;
				}

				valueLowerCase = value.toLocaleLowerCase();

				// integer value zero, sometimes referred to as the ASCII NUL character
				if (!result) {
					for (i = valueLowerCase.length - 1; i >= 0; i--) {
						if (valueLowerCase.charCodeAt(i) <= 31) {
							result = VALIDATION_CHECK_RESULT.WRONG_VALUE;
							break;
						}
					}
				}

				// file names to avoid
				if (!result) {
					valueLowerCase = valueLowerCase.split(".")[0];
					for (i = _fileNameForbiddenNames.length - 1; i >= 0; i--) {
						if (valueLowerCase === _fileNameForbiddenNames[i]) {
							result = VALIDATION_CHECK_RESULT.PROHIBITED_FILE_NAME;
							break;
						}
					}
				}
			} else {
				if (!result && CommonFrameUtil.isInvalidSpecialChar(value)) {
					result = VALIDATION_CHECK_RESULT.INVALID_SPECIAL_CHARACTER;
				}
			}

			return result || VALIDATION_CHECK_RESULT.SUCCESS;
		},

		/**
		 * dst 에 src element 를 append 해주는 함수
		 * @param {Element} src - 붙일 위치의 element
		 * @param {Element} dst - 대상 element
		 * @param {Boolean=} isInsertBefore
		 * @returns {void}
		 */
		appendNodeToTarget: function (src, dst, isInsertBefore) {
			if (src && dst) {
				if (isInsertBefore) {
					dst.insertBefore(src, dst.firstElementChild);
				} else {
					dst.appendChild(src);
				}
			}
		},

		/**
		 * target 을 삭제해주는 함수
		 * @param {Element} target
		 * @returns {void}
		 */
		removeNodeToTarget: function (target) {
			CommonFrameUtil.removeNode(target);
		},

		/**
		 * target 에 해당 클래스가 있는지 없는지 확인하는 함수
		 * @param {Element} target
		 * @param {String} className
		 * @returns {Boolean}
		 */
		hasClassToTarget: function (target, className) {
			return _hasClass(target, className);
		},

		/**
		 * target 에 class 를 추가해주는 함수
		 * - class 가 존재하면 concat 시키며, 없으면 추가할 className 을 설정
		 * @param {Element} target
		 * @param {String} addClassName
		 * @returns {void}
		 */
		addClassToTarget: function (target, addClassName) {
			CommonFrameUtil.addClass(target, addClassName);
		},

		/**
		 * target 에서 지정된 class name 을 삭제해주는 함수
		 * @param {Element} target
		 * @param {String} removeClassName
		 * @returns {void}
		 */
		removeTargetClass: function (target, removeClassName) {
			CommonFrameUtil.removeClass(target, removeClassName);
		},

		/**
		 * target 에 text 를 세팅해주는 함수
		 * @param {Element} target			- text 를 세팅 할 target
		 * @param {String} text			- 세팅 될 text 값
		 */
		insertTextToTarget: function (target, text) {
			var regExp = /<(br|strong|\/p)[^>]?>/;

			if (text.match(regExp)) {
				target.innerHTML = text;
			} else {
				target.textContent = text;
			}
		},

		/**
		 * target 에 text 를 제거해주는 함수
		 * @param {Element} target			- text 를 제거 할 target
		 */
		removeTextFromTarget: function (target) {
			if (target) {
				target.textContent = "";
			}
		},

		/**
		 * target 에 title 을 세팅해주는 함수
		 * @param {Element} target			- text 를 세팅 할 target
		 * @param {String} title			- 세팅 될 title 값
		 */
		insertTitleToTarget: function (target, title) {
			if (target) {
				target.setAttribute("title", title);
			}
		},

		/**
		 * target 에 title 를 제거해주는 함수
		 * @param {Element} target			- text 를 제거 할 target
		 */
		removeTitleFromTarget: function (target) {
			if (target) {
				target.removeAttribute("title");
			}
		},

		/*******************************************************************************
		 * Boolean result method (return true or false, isXXX() method....)
		 ******************************************************************************/

		/**
		 * hidden 된 target 인지 아닌지
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isHidden: function(target) {
			return _hasClass(target, UiDefine.HIDE_VIEW_CLASS);
		},

		/**
		 * 현재 target 이 showing 중인지 아닌지.
		 * @param {Element} target			- target node
		 *
		 * @returns {Boolean}
		 */
		isShowTarget: function (target) {
			return !this.isHidden(target);
		},

		/**
		 * 대상 (target) 의 상위가 Layer 일 경우, Layer 가 showing 중인지 여부
		 * @param {Element} target			- 대상 노드
		 * @returns {boolean}
		 */
		isShowParentLayer : function(target) {
			var layerNode = this.findLayerNodeToParent(target),
				layerOnNode = layerNode;

			// 대상의 상위가 layerNode 가 아니면 false 를 반환한다.
			if (!layerOnNode) {
				return false;
			}

			// layerNode 중 on/off 를 다른 노드 가 관장하는 layerNode 는 대상을 변경해 준다.
			if (_hasClass(layerOnNode, UiDefine.DROPDOWN_SELECT_LIST_WRAP_CLASS)) {
				// Dropdown 은 layerNode 의 이전 노드 (화살표노드 : btn_combo_arrow) 가 on/off 대상이다.
				layerOnNode = layerOnNode.previousElementSibling;
			} else if (_hasClass(target, UiDefine.BOX_ELEMENT_CLASS)) {
				// titleBar Dropdown (Box Element) 은 titleBar Container 가 on/off 대상이다.
				layerOnNode = this.findContainerNodeToParent(layerOnNode);
			}

			return this.isButtonOn(layerOnNode);
		},

		/**
		 * 현재 target 이 disable 중인지 아닌지.
		 * @param {Element} target			- target node
		 *
		 * @returns {Boolean}
		 */
		isDisabled: function(target) {
			return _hasClass(target, UiDefine.DISABLE_CLASS);
		},

		/**
		 * 현재 target 이 fold 중인지 아닌지.
		 * @param {Element} target			- target node
		 *
		 * @returns {Boolean}
		 */
		isFolded: function(target) {
			return CommonFrameUtil.hasClass(target, UiDefine.FOLD_VIEW_CLASS);
		},

		/**
		 * 현재 target 이 가로 혹은 세로 line 인지 아닌지.
		 * @param {Element} target			- target node
		 *
		 * @returns {Boolean}
		 */
		isLine: function (target) {
			return _hasClass(target, UiDefine.HORIZONTAL_LINE_SEPARATOR_CLASS) ||
				_hasClass(target, UiDefine.VERTICAL_LINE_SEPARATOR_WRAP_CLASS);
		},

		/**
		 * target 이 view control 인지 확인하는 함수
		 * @param {Element} target				- 대상 타겟
		 * @returns {Boolean}
		 */
		isViewControl: function (target) {
			return _hasClass(target, UiDefine.VIEW_CONTROL_CLASS);
		},

		/**
		 * target 이 navigation box 인지 확인하는 함수
		 * @param {Element} target				- 대상 타겟
		 * @returns {Boolean}
		 */
		isNavigationBox: function (target) {
			return _hasClass(target, UiDefine.NAV_BOX_CLASS);
		},

		/**
		 * container view 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isContainerView: function(target) {
			return !!(target && _hasClass(target, UiDefine.CONTAINER_CLASS));
		},

		/**
		 * target 이 hwp message 영역인지 확인하는 함수
		 * @param {Element} target				- 대상 타겟
		 * @returns {Boolean}
		 */
		isMessageArea: function (target) {
			return _hasClass(target, UiDefine.HWP_MESSAGE_CLASS);
		},

		/**
		 * target 이 guide 영역인지 확인하는 함수
		 * @param {Element} target				- 대상 타겟
		 * @returns {Boolean}
		 */
		isGuideArea: function (target) {
			return _hasClass(target, UiDefine.GUIDE_CLASS);
		},

		/**
		 * target 이 ui option 영역인지 확인하는 함수
		 * @param {Element} target				- 대상 타겟
		 * @returns {Boolean}
		 */
		isUiOptionArea: function (target) {
			return _hasClass(target, UiDefine.UI_OPTION_AREA);
		},

		/**
		 * target 이 메뉴 스크롤 영역에 포함되어 길이를 계산해야 되는지 확인하는 함수
		 * @param {Element} target				- 대상 타겟
		 * @returns {Boolean}
		 */
		isCalculateArea: function (target) {
			return !(this.isGuideArea(target) || this.isUiOptionArea(target) || this.isMessageArea(target));
		},

		/**
		 * Panel 인지 아닌지.
		 * @param {Element} target		- 확인할 대상 Element
		 * @returns {boolean}
		 */
		isPanel: function(target) {
			return !!(target && _hasClass(target, UiDefine.PANEL_CLASS_ARR));
		},

		/**
		 * TemplateWrap 인지 아닌지.
		 * @param {Element} target		- 확인할 대상 Element
		 * @returns {boolean}
		 */
		isTemplateWrap: function(target) {
			return !!(target && _hasClass(target, UiDefine.TEMPLATE_WRAP_CLASS));
		},

		/**
		 * Action Command 버튼인지 아닌지.
		 * @param {Element} target		- 확인할 대상 버튼
		 * @returns {boolean}
		 */
		isActionCommandButton: function(target) {
			return !!(target && target.nodeType === Node.ELEMENT_NODE && target.hasAttribute(UiDefine.DATA_COMMAND));
		},

		/**
		 * Ui Command 버튼인지 아닌지.
		 * @param {Element} target		- 확인할 대상 버튼
		 * @returns {boolean}
		 */
		isUiCommandButton: function(target) {
			return !!(target && target.nodeType === Node.ELEMENT_NODE && target.hasAttribute(UiDefine.DATA_UI_COMMAND));
		},

		/**
		 * Tab 버튼인지 아닌지.
		 * @param {Element} target		- 확인할 대상 버튼
		 * @returns {boolean}
		 */
		isTabButton: function(target) {
			// target 이 있고, btn_tab 또는 color_picker 의 tab
			return !!(target
			&& (_hasClass(target, UiDefine.BUTTON_TAB_CLASS)
			|| (target.nodeName === "LABEL" && target.hasAttribute(UiDefine.DATA_TAB_BUTTON_TARGET))));
		},

		/**
		 * Dropdown 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isDropdown: function(target) {
			return !!(target && (_hasClass(target, UiDefine.DROPDOWN_CLASS) ||
			_hasClass(target, UiDefine.BTN_COMBO_ARROW_CLASS)));
		},

		/**
		 * Sample wrap 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isSampleWrap: function(target) {
			return !!(target && (_hasClass(target, UiDefine.SAMPLE_WRAP_CLASS)));
		},

		/**
		 * Sample item 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isSampleItem: function(target) {
			return !!(target && (_hasClass(target, UiDefine.SAMPLE_ITEM_CLASS)));
		},

		/**
		 * Result Button 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isResultButton: function(target) {
			return !!(target && _hasClass(target, UiDefine.RESULT_BUTTON_CLASS));
		},

		/**
		 * Combo 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isCombo: function(target) {
			return !!(target && _hasClass(target, UiDefine.COMBO_CLASS));
		},

		/**
		 * Input 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isInput: function(target) {
			return !!(target && target.nodeName === "INPUT");
		},

		/**
		 * Input 을 사용해 만든 widget 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isInputWrapWidget: function(target) {
			return _hasClass(target, UiDefine.INPUT_WRAP_CLASS);
		},

		/**
		 * Radio 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isRadioWidget: function(target) {
			return !!(target && _hasClass(target, UiDefine.RADIO_WIDGET_CLASS));
		},

		/**
		 * TextInput 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isTextInputWidget: function(target) {
			return !!(target && _hasClass(target, UiDefine.INPUT_BOX_WRAP_CLASS));
		},

		/**
		 * Ui Focus 유지하는 widget 인지 아닌지. (xml 상 remainUiFocus="true")
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isRemainUiFocusWidget: function (target) {
			return !!(target && _hasClass(target, UiDefine.REMAIN_UI_FOCUS));
		},

		/**
		 * Checkbox 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isCheckboxWidget: function(target) {
			return !!(target && _hasClass(target, UiDefine.CHECK_BOX_WRAP_CLASS));
		},

		/**
		 * LocalFile 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isLocalFileWidget: function(target) {
			return !!(target && _hasClass(target, UiDefine.LOCAL_FILE_WRAP_CLASS));
		},

		/**
		 * 브라우저 포커스 사용하는 Widget 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isBrowserFocusUsedWidget: function (target) {
			if (!target) {
				return false;
			}

			var widgetEl = target;

			if (this.isInput(target)) {
				widgetEl = this.getInputWrapWidgetByInput(target);
			}

			return this.isTextInputWidget(widgetEl) || this.isLocalFileWidget(widgetEl) || this.isTextareaWidget(widgetEl);
		},

		/**
		 * widget 이 활성화 상태인지 아닌지.
		 * @param {Element} target		- 확인 대상
		 * @returns {boolean}
		 */
		isEnabled: function(target) {
			return !_hasClass(target, UiDefine.DISABLE_CLASS);
		},

		/**
		 * 버튼이 켜져있는지 아닌지.
		 * @param {Element} target		- 버튼이 켜져 있는지 아닌지 확인 대상
		 * @returns {boolean}
		 */
		isButtonOn: function(target) {
			return _hasClass(target, _defineValue.ON);
		},

		/**
		 * 버튼이 DontCare 상태인지 아닌지.
		 * @param {Element} target		- 버튼이 DontCare 상태인지 확인 대상
		 * @returns {boolean}
		 */
		isButtonDontCare: function(target) {
			return _hasClass(target, UiDefine.DONT_CARE_CLASS);
		},

		/**
		 * onLink 속성(실제 브라우저 link 연결된 기본 button)이 있는 Button 인지 아닌지.
		 * @param {Element} target		- 버튼이 켜져 있는지 아닌지 확인 대상
		 * @returns {boolean}
		 */
		isOnLinkButton: function(target) {
			var checkNode = this.findSvgNodeToParent(target),
				findNode;

			if (checkNode && checkNode.nodeName === "svg") {
				checkNode = checkNode.parentNode;
			} else {
				findNode = target;
				while (findNode && findNode.nodeName !== "A"
					&& !this.isActionCommandButton(findNode)
					&& !this.isContainerView(findNode)) {

					findNode = findNode.parentNode;
				}

				if (findNode) {
					checkNode = findNode;
				}
			}

			return _hasClass(checkNode, UiDefine.ON_LINK_CLASS);
		},

		/**
		 * result 버튼, 표 삽입용 button, spinner 버튼 등, 추가 동작을 위한 버튼인지 아닌지
		 * @param {Element} buttonElement	- 확인 대상
		 * @returns {boolean}
		 */
		isControlButton: function(buttonElement) {
			// result button
			var nodeName = buttonElement ? buttonElement.nodeName : "";

			return ((nodeName !== "" && nodeName !== "A" && nodeName !== "DIV" && nodeName !== "TR" && nodeName !== "INPUT")
			|| _hasClass(buttonElement, UiDefine.RESULT_BUTTON_CLASS));
		},

		/**
		 * target 이 dialog (modal 및 modeless) container 영역인지 아닌지
		 * @param {Element|String} targetValue		- 확인 대상 Element (container 내부) 또는 containerID (String)
		 * @returns {Boolean}
		 */
		isDialogContainer: function (targetValue) {
			var containerID, containerNode;

			if (CommonFrameUtil.isString(targetValue)) {
				containerID = targetValue;
			} else {
				containerNode = this.findContainerNodeToParent(targetValue);
				containerID = containerNode && containerNode.id;
			}

			return (containerID && _dialogContainers.indexOf(containerID) !== -1) || false;
		},

		/**
		 * target 이 dialog title 영역내에 있는지 아닌지
		 * @param {Element} target	- 확인 대상
		 * @returns {boolean}
		 */
		isDialogTitleArea: function(target) {
			var containerInfo = this.findContainerInfoToParent(target),
				containerNode = containerInfo.container,
				topNode = containerInfo.topNode,		// 이벤트 발생 지점 상위로 container node
				result = false;

			if (containerNode && topNode && this.isDialogContainer(containerNode.id)) {
				if (target === topNode || CommonFrameUtil.findParentNode(target, '.' + UiDefine.PROPERTY_TITLE_CLASS, topNode)) {
					result = true;
				}
			}

			return result;
		},

		/**
		 * listBox 인지 아닌지.
		 * @param {Element} target			- listBox 인지 확인 대상
		 * @returns {boolean}
		 */
		isListBox: function (target) {
			return _hasClass(target, UiDefine.LIST_BOX_CLASS);
		},

		/**
		 * focusablePanel 인지 아닌지.
		 * @param {Element} target			- focusablePanel 인지 확인 대상
		 * @returns {boolean}
		 */
		isFocusablePanel: function (target) {
			return _hasClass(target, UiDefine.FOCUSABLE_PANEL_CLASS);
		},

		/**
		 * focus 될 대상 인지 아닌지.
		 * @param {Element} target			- focus 될 대상 인지 확인 대상
		 * @returns {boolean}
		 */
		isUiFocusWidget: function (target) {
			return _hasClass(target, UiDefine.FOCUSABLE_CLASS);
		},

		/**
		 * target 이 spectrum color picker 영역 내에 있는지 아닌지
		 * @param {Element} target			- 확인 대상
		 * @returns {boolean}
		 */
		isSpectrumColorPickerArea: function (target) {
			var result = false,
				containerInfo, layerNode, matrixContainerClass, spectrumContainerClass;

			if (!target) {
				return result;
			}

			containerInfo = this.findContainerInfoToParent(target);
			layerNode = containerInfo && containerInfo.layerNode; // 이벤트 발생 지점 상위의 layer node
			matrixContainerClass = UiDefine.COLOR_MATRIX_CONTAINER_CLASS;
			spectrumContainerClass = UiDefine.COLOR_SPECTRUM_CONTAINER_CLASS;

			if (CommonFrameUtil.findParentNode(target, "." + matrixContainerClass + ", ." + spectrumContainerClass, layerNode)) {
				result = true;
			}

			return result;
		},

		/**
		 * viewNode 내부에 el 이 있는지 확인하는 함수 (limit: container node)
		 * @param {Element} viewNode			- el 이 포함됐는지 확인할 view node
		 * @param {Node} el					- 확인 대상
		 * @returns {Boolean}
		 */
		isContainsView: function(viewNode, el) {
			var isContains = false,
				curNode = el;

			while (curNode && !isContains) {
				isContains = (curNode === viewNode);

				// container view 이상은 찾지 않는다
				curNode = (this.isContainerView(curNode)) ? null : curNode.parentNode;
			}

			return isContains;
		},

		/**
		 * textarea widget 인지 아닌지.
		 * @returns {Boolean}
		 */
		isTextareaWidget: function (target) {
			return _hasClass(target, UiDefine.TEXTAREA_BOX_CLASS);
		},

		/*******************************************************************************
		 * Find values method (findXXX() method....)
		 ******************************************************************************/
		/**
		 * 지정한 target 이 svg 의 하위 태그이면, 상위의 svg 태그를 찾아서 반환한다.
		 * 만일 svg 하위 태그가 아니면 target 을 그대로 반환한다.
		 * @param {Element} target			- target node
		 * @returns {Element}
		 */
		findSvgNodeToParent: function(target) {
			var arrSvgChild = ["g", "path", "rect", "polygon"],
				findNode;

			if (target && arrSvgChild.indexOf(target.nodeName) !== -1) {
				findNode = target.parentNode;

				while (findNode && findNode.nodeName !== "svg") {
					findNode = findNode.parentNode;
				}
			}

			return findNode || target;
		},

		/**
		 * 현재 node 상위의 containerNode 구함
		 * @param {Element} target		- 확인할 대상
		 * @param {Element=} wrapNode	- 한계 Node (wrap)
		 * @returns {Element}
		 */
		findContainerNodeToParent: function(target, wrapNode) {
			var containerNode = null;
			while (target && target !== wrapNode && !containerNode) {
				containerNode = this.isContainerView(target) ? target : null;
				target = target.parentNode;
			}
			return (containerNode !== wrapNode) ? containerNode : null;
		},

		/**
		 * 현재 node 상위의 layerNode 구함
		 * @param {Element} target		- 확인할 대상
		 * @returns {Element}
		 */
		findLayerNodeToParent : function(target) {
			return this.findContainerInfoToParent(target, true).layerNode;
		},

		/**
		 * 현재 node 상위의 containerNode 정보를 구함
		 * @param {Element|Node} target				- 확인할 대상
		 * @param {Boolean=} isOnlyLayerNode		- Layer Node 만을 탐색할지 여부
		 * @returns {Object}
		 */
		findContainerInfoToParent: function(target, isOnlyLayerNode) {
			var findInfo = {},
				containerNode = null,
				conTopNode = null,
				layerNode = null,
				menuBox = null,
				titlePanelNode = null,
				conNode;

			while (target && !containerNode) {
				containerNode = this.isContainerView(target) ? target : null;

				if (!containerNode) {
					conNode = target;

					if (_hasClass(target, UiDefine.DROPDOWN_SELECT_LIST_WRAP_CLASS)) {
						layerNode = target;
					} else if (_hasClass(target, UiDefine.BOX_ELEMENT_CLASS)) {
						menuBox = target;
					} else if (_hasClass(target, UiDefine.TITLE_PANEL_WRAP_CLASS)) {
						titlePanelNode = target;
					} else if (_hasClass(target, UiDefine.TOOL_FILTER_DIALOG)) {
						layerNode = target;
					}

					if (isOnlyLayerNode === true && layerNode) {
						break;
					}
				}

				target = target.parentNode;
			}

			if (containerNode && conNode) {
				conTopNode = conNode;

				/**
				 * menu_box 는 layer 가 아닌데, title_bar container 에서는 layer 개념으로 쓰고 있다.
				 * 임시적으로 title_bar 에서만 menu_box 를 layer 로 인정해 준다.
				 * 차후 layer 개념은 layer 라는 표시를 넣어줘야 한다.
				 */
				if (menuBox && !layerNode && containerNode.id === UiDefine.TITLE_BAR_ID) {
					layerNode = menuBox;
				}
			}

			findInfo["layerNode"] = layerNode;

			if (isOnlyLayerNode !== true) {
				findInfo["container"] = containerNode;
				findInfo["topNode"] = conTopNode;
				findInfo["titleWrap"] = titlePanelNode;
			}

			return findInfo;
		},

		/**
		 * target 상위에서 Command Element 구함 (dropdown, combo 의 경우는 바로 하위 command 로 return)
		 * @param {Node} target			- 대상
		 * @param {Node=} limit			- 미지정시 끝까지 찾음
		 * @param {Boolean=} onlyEnabled	- true 시, 활성화된 Command Element 만 찾도록 제한 (비활성화인 경우 더 찾음)
		 * @returns {Element}
		 */
		findCommandElementToParent: function(target, limit, onlyEnabled) {
			var commandEl = null,
				boxEl, arrowEl;

			if (this.isCombo(target) || this.isDropdown(target)) {
				// combo 나 dropdown 를 target 으로 지정한 경우, arrow 를 대표 command 로 인정한다.
				boxEl = target.lastElementChild;
				arrowEl = boxEl && boxEl.previousElementSibling;

				if (arrowEl && arrowEl.nodeName === "A"
					&& _hasClass(arrowEl, UiDefine.BTN_COMBO_ARROW_CLASS)) {
					target = arrowEl;
				}
			}

			while (target && !commandEl && limit !== target) {
				if ((this.isActionCommandButton(target) || this.isUiCommandButton(target))
					&& (!onlyEnabled || this.isEnabled(target))) {
					commandEl = target;
				}
				target = target.parentNode;
			}

			return commandEl;
		},

		/**
		 * target 상위에서 Combo Element 구함
		 * @param {Node} target		- 대상
		 * @param {Node=} limit		- 미지정시 끝까지 찾음
		 * @returns {Element}
		 */
		findComboElementToParent: function(target, limit) {
			var comboEl = null;

			while (target && !comboEl && limit !== target) {
				comboEl = this.isCombo(target) ? target : null;
				target = target.parentNode;
			}

			return comboEl;
		},

		/**
		 * target 상위에서 Command Element 구함
		 * @param {Node} target		- 대상
		 * @param {Node=} limit		- 미지정시 끝까지 찾음
		 * @returns {Element}
		 */
		findCommandWrapToParent: function(target, limit) {
			var buttonEl = null;

			while (target && !buttonEl && limit !== target) {
				if (CommonFrameUtil.hasClass(target, UiDefine.BUTTON_CLASS) ||
					CommonFrameUtil.hasClass(target, UiDefine.SUB_GROUP_BOX_ELEMENT_CLASS) ||
					this.isSampleWrap(target) ||
					(target.nodeName === "DIV" && this.isInputWrapWidget(target))) {
					// inputWrap 은 "DIV" 인 경우로 한정 (dropdown, combo 내부의 input 제외)
					buttonEl = target;
				}
				target = target.parentNode;
			}
			return buttonEl;
		},

		/**
		 * target 하위에서 Widget Element 들을 구함
		 * @param {Element} target		- 대상
		 * @returns {Array}
		 */
		findCommandWidgets: function(target) {
			var widgetArr;

			if (!target) {
				return [];
			}

			widgetArr = CommonFrameUtil.getCollectionToArray(target.getElementsByClassName(UiDefine.BUTTON_CLASS));
			widgetArr = widgetArr.concat(
				CommonFrameUtil.getCollectionToArray(target.getElementsByClassName(UiDefine.RESULT_BUTTON_CLASS)));
			widgetArr = widgetArr.concat(
				CommonFrameUtil.getCollectionToArray(target.getElementsByClassName(UiDefine.INPUT_WRAP_CLASS)));
			widgetArr = widgetArr.concat(
				CommonFrameUtil.getCollectionToArray(target.querySelectorAll('[' + UiDefine.DATA_UI_COMMAND + ']')));

			return CommonFrameUtil.unique(widgetArr);
		},

		/**
		 * target 하위에서 name 을 갖는 Panel Element 들을 구함
		 * @param {Element} target		- 대상
		 * @returns {Array}
		 */
		findNamePanels: function(target) {
			var widgetArr;

			if (!target) {
				return [];
			}

			// 현재 dataName 을 갖는 경우는 panel 만
			widgetArr = CommonFrameUtil.getCollectionToArray(target.querySelectorAll('div[' + UiDefine.DATA_NAME + ']'));

			return widgetArr;
		},


		/*******************************************************************************
		 * Getter values method (getXXX() method....)
		 ******************************************************************************/

		/**
		 * 현재 접속된 Browser 정보를 반환. (현재는 safari 여부만 반환. 추후 확장 예정)
		 * @returns {Object}
		 */
		getBrowserInfo : function () {
			var browserInfo = {};

			browserInfo["isSafari"] = _isSafari;
			browserInfo["isMSIE"] = _isMSIE;
			browserInfo["isEdge"] = _isEdge;

			return browserInfo;
		},

		/**
		 * action command return
		 * @param {Element} target		- 대상
		 * @returns {String}
		 */
		getEventActionCommand: function(target) {
			return (target && target.getAttribute(UiDefine.DATA_COMMAND));
		},

		/**
		 * InputWrapWidget 으로부터 input element 구함.
		 * @param {Element} target		- InputWrapWidget
		 * @returns {Element}
		 */
		getInputElementByWidget: function(target) {
			var curEl = target ? target.firstElementChild : null;

			if (curEl && (this.isLocalFileWidget(target) || this.isCombo(target)
				|| this.isRadioWidget(target) || this.isCheckboxWidget(target))) {
				curEl = curEl.firstElementChild;
			}

			while (curEl && curEl.nodeName !== "INPUT") {
				curEl = curEl.nextElementSibling;
			}

			return curEl;
		},

		/**
		 * input element 으로부터 InputWrapWidget 구함.
		 * @param {Element} inputEl	- Input element
		 * @returns {Node|null}
		 */
		getInputWrapWidgetByInput: function(inputEl) {
			if (!this.isInput(inputEl)) {
				return null;
			}

			var inputType = inputEl.getAttribute("type"),
				inputWrap = inputEl.parentNode;

			if (inputType === "file" || inputType === "checkbox" || inputType === "radio") {
				inputWrap = inputWrap.parentNode;
			}

			return inputWrap;
		},

		/**
		 * spinner element 로 부터 InputWrapWidget 을 구함
		 * @param {Element} target		- spinner element
		 * @param {Element=} limit		- limit element (미지정시 끝까지 찾음)
		 * @returns {Element}
		 */
		getInputWrapWidgetBySpinner : function(target, limit) {
			var inputWrapEl = null;

			while (target && !inputWrapEl && limit !== target) {
				inputWrapEl = this.isTextInputWidget(target) ? target : null;
				target = target.parentNode;
			}

			return inputWrapEl;
		},

		/**
		 * InputWrapWidget 으로부터 form element 구함.
		 * @param {Element} target		- InputWrapWidget (file type)
		 * @returns {Element}
		 */
		getFormElementByWidget: function(target) {
			if (!this.isLocalFileWidget(target)) {
				return null;
			}

			var curEl = target ? target.firstElementChild : null;

			while (curEl && curEl.nodeName !== "FORM") {
				curEl = curEl.nextElementSibling;
			}

			return curEl;
		},

		/**
		 * commandName 와 valueKey 로 widgetName 구함.
		 * @param {String} commandName
		 * @param {String=} valueKey	- value 가 object 인 경우 구분하는 key
		 * @returns {String}
		 */
		getWidgetName: function(commandName, valueKey) {
			return valueKey ? (commandName + "_" + valueKey) : commandName;
		},

		/**
		 * sampleWrap 으로부터 sample name 구함
		 * @param {Element} sampleWrap
		 * @returns {String}
		 */
		getSampleName: function(sampleWrap) {
			return (sampleWrap && sampleWrap.getAttribute(UiDefine.DATA_SAMPLE_NAME)) || "";
		},

		/**
		 * dropdown widget 중 layout 이 custom 인 경우 layout name 을 구한다. (custom 이 아닌경우 "")
		 * @param {Element} widgetEl
		 * @returns {String}
		 */
		getCustomLayoutDropdownName: function(widgetEl) {
			if (!(this.isDropdown(widgetEl) || this.isCombo(widgetEl))) {
				return "";
			}

			var dropdownBoxEl = widgetEl.lastElementChild,
				customLayoutDropdownName = "",
				isCustomLayout = _hasClass(dropdownBoxEl, UiDefine.DROPDOWN_LAYOUT_CUSTOM_CLASS);

			if (isCustomLayout) {
				if (_hasClass(dropdownBoxEl, UiDefine.COLOR_PICKER_CLASS)) {
					customLayoutDropdownName = UiDefine.COLOR_PICKER_CLASS;
				} else {
					customLayoutDropdownName = UiDefine.DROPDOWN_LAYOUT_CUSTOM_CLASS;
				}
			}

			return customLayoutDropdownName;
		},

		/**
		 * EventAction target (commandElement) 으로부터 valueKey 구함
		 * @param {Element} commandElement
		 * @returns {String}
		 */
		getValueKey: function(commandElement) {
			var valueKeyEl;

			if (this.isCombo(commandElement) &&
				commandElement.firstElementChild && commandElement.firstElementChild.nodeName === "A") {
				// input combo 인 경우 a 에 valueKey 가 있음
				valueKeyEl = commandElement.firstElementChild;

			} else {
				valueKeyEl = commandElement;
			}

			return (valueKeyEl && valueKeyEl.getAttribute(UiDefine.DATA_VALUE_KEY)) || null;
		},

		/**
		 * target(element) 로 부터 spinner type 구함
		 * @param {Element} target
		 * @returns {String} UiDefine.SPINNER_TYPE 의 UPPER 또는 LOWER (spinner 아닌경우 "")
		 */
		getSpinnerType: function(target) {
			var type;

			if (CommonFrameUtil.hasClass(target, UiDefine.SPINNER_UPPER_ARROW_CLASS)) {
				type = UiDefine.SPINNER_TYPE.UPPER;
			} else if (CommonFrameUtil.hasClass(target, UiDefine.SPINNER_LOWER_ARROW_CLASS)) {
				type = UiDefine.SPINNER_TYPE.LOWER;
			} else {
				type = "";
			}

			return type;
		},

		/**
		 * key 와 value 로 selector 를 만들어 반환하는 함수
		 * @param {String} attrKey 			- selector 에 사용될 key
		 * @param {String} attrValue 		- selector 에 사용될 key 에 대한 value
		 * @returns {String}
		 */
		getAttrSelectorStr: function(attrKey, attrValue) {
			if (!(attrKey && CommonFrameUtil.isString(attrValue))) {
				return "";
			}

			return '[' + attrKey + '="' + attrValue.replace(_querySelectorReg, "\\\\") + '"]';
		},

		/*******************************************************************************
		 * Color Picker method
		 ******************************************************************************/

		/**
		 * 최근 hsv color 를 세팅하는 함수
		 * @param {Element} spectrumContentEl
		 * @param {Number} h					- hue
		 * @param {Number} s					- saturation
		 * @param {Number} v					- value brightness
		 * @returns {void}
		 */
		setCurHsvColor: function (spectrumContentEl, h, s, v) {
			if (!(spectrumContentEl && CommonFrameUtil.hasClass(spectrumContentEl, UiDefine.SPECTRUM_COLOR_CONTENT_CLASS))) {
				return;
			}

			spectrumContentEl.setAttribute(UiDefine.DATA_HSV_COLOR, (h || 0) + "," + (s || 0) + "," + (v || 0));
		},

		/**
		 * 최근 hsv color 를 반환하는 함수
		 * @param {Element} spectrumContentEl
		 * @return {Object}
		 */
		getCurHsvColor: function (spectrumContentEl) {
			if (!(spectrumContentEl && CommonFrameUtil.hasClass(spectrumContentEl, UiDefine.SPECTRUM_COLOR_CONTENT_CLASS))) {
				return null;
			}

			var hsvStr = spectrumContentEl.getAttribute(UiDefine.DATA_HSV_COLOR),
				hsvColorArr = hsvStr ? hsvStr.split(",") : null,
				hsvColor = null;

			if (hsvColorArr && hsvColorArr.length === 3) {
				hsvColor = {
					h: parseInt(hsvColorArr[0]),
					s: parseInt(hsvColorArr[1]),
					v: parseInt(hsvColorArr[2])
				};
			}

			return hsvColor;
		},

		/**
		 * color picker 에 색상을 세팅하는 함수
		 * @param {Element} target				- color picker 최상위 element
		 * @param {String} hexCode				- hex 색상 값
		 * @returns {void}
		 */
		setColorToColorPicker: function (target, hexCode) {
			var isColorCode = this.checkValidationColorCode(hexCode) === UiDefine.VALIDATION_CHECK_RESULT.SUCCESS,
				rgbCode, hsv, h, s, v, colorPickerContentEl;

			if (!target) {
				return;
			}

			if (!isColorCode) {
				hexCode = UiDefine.COLOR_PICKER_DEFAULT_COLOR;
			}

			rgbCode = CommonFrameUtil.getHexToRgb(hexCode);
			hsv = CommonFrameUtil.getRgbToHsv(rgbCode);
			h = hsv.h;	// hue
			s = hsv.s;	// saturation
			v = hsv.v;	// valueBrightness

			colorPickerContentEl = target.querySelector("." + UiDefine.SPECTRUM_COLOR_CONTENT_CLASS);
			this.setCurHsvColor(colorPickerContentEl, h, s, v);

			// Matrix Color Picker
			this.setMatrixColorPicker(h, s, v, target);
			// Spectrum Color Picker
			this.setSpectrumColorPicker(h, target);

			// 색상 정보 갱신
			this.setColorInformation(target, hexCode);
		},

		/**
		 * matrix color picker 를 세팅하는 함수
		 * @param {Number} h					- hue
		 * @param {Number} s					- saturation
		 * @param {Number} v					- value brightness
		 * @param {Element=} target				- color picker 최상위 element
		 * @param {Element=} matrixEl			- matrix element
		 * @returns {void}
		 */
		setMatrixColorPicker: function (h, s, v, target, matrixEl) {
			if (!((target || matrixEl) && !isNaN(h) && !isNaN(s) && !isNaN(v))) {
				return;
			}

			var colorMatrixPicker = matrixEl || target.querySelector("." + _colorMatrixPickerClass),
				colorMatrixPointer, colorMatrixWidth, colorMatrixHeight, posX, posY;

			// Color Matrix Picker 위치 조정
			if (colorMatrixPicker) {
				colorMatrixPointer = colorMatrixPicker.querySelector("." + UiDefine.COLOR_MATRIX_POINTER_CLASS);

				if (colorMatrixPointer) {
					colorMatrixWidth = parseInt(colorMatrixPicker.style.width, 10);
					colorMatrixHeight = parseInt(colorMatrixPicker.style.height, 10);

					posX = parseInt((s * colorMatrixWidth) / 100, 10);
					posY = colorMatrixHeight - parseInt((v * colorMatrixHeight) / 100, 10);
					colorMatrixPointer.style.left = posX + "px";
					colorMatrixPointer.style.top = posY + "px";

					colorMatrixPicker.style.backgroundColor = CommonFrameUtil.getHsvToHex(h, 100, 100);
				}
			}
		},

		/**
		 * spectrum color picker 를 세팅하는 함수
		 * @param {Number} h					- hue
		 * @param {Element} target				- color picker 최상위 element
		 * @param {Element=} spectrumEl			- spectrum element
		 * @returns {void}
		 */
		setSpectrumColorPicker: function (h, target, spectrumEl) {
			if (!(target && !isNaN(h))) {
				return;
			}

			var colorSpectrumPicker = spectrumEl || target.querySelector("." + _colorSpectrumPickerClass),
				colorMatrixPicker = target.querySelector("." + _colorMatrixPickerClass),
				colorSpectrumPointer, colorSpectrumWidth, posX;

			// Color Spectrum Picker 위치 조정
			if (colorSpectrumPicker && colorMatrixPicker) {
				colorSpectrumPointer = colorSpectrumPicker.querySelector("." + UiDefine.COLOR_SPECTRUM_POINTER_CLASS);

				if (colorSpectrumPointer) {
					colorSpectrumWidth = parseInt(colorSpectrumPicker.style.width, 10);

					posX = parseInt(colorSpectrumWidth - (((360 - h) * colorSpectrumWidth) / 360), 10);
					colorSpectrumPointer.style.left = (posX < 0 ? 0 : posX) + "px";

					colorMatrixPicker.style.backgroundColor = CommonFrameUtil.getHsvToHex(h, 100, 100);
				}
			}
		},

		/**
		 * color picker 의 색상 정보를 갱신하는 함수
		 * @param {Element} target				- color picker 최상위 element
		 * @param {String} hexCode				- hex 색상 값
		 * @returns {void}
		 */
		setColorInformation: function (target, hexCode) {
			if (!(target && hexCode)) {
				return;
			}

			var colorPreviewEl = target.querySelector("." + UiDefine.PREVIEW_COLOR_BLOCK_CLASS),
				colorPreviewTextEl = target.querySelector("." + UiDefine.PREVIEW_COLOR_TEXT_CLASS + " > input"),
				previewText, confirmBtn;

			if (colorPreviewEl) {
				colorPreviewEl.style.backgroundColor = hexCode;
			}

			if (colorPreviewTextEl) {
				if (this.checkValidationColorCode(hexCode) === UiDefine.VALIDATION_CHECK_RESULT.SUCCESS) {
					previewText = hexCode.substr(1, 6);

					colorPreviewTextEl.value = previewText.toUpperCase();
					this.checkUpdateSpectrumColor(colorPreviewTextEl);
				}

				confirmBtn = target.querySelector("." + UiDefine.SPECTRUM_COLOR_CONFIRM_CLASS);

				if (confirmBtn && confirmBtn.hasAttribute(UiDefine.DATA_VALUE)) {
					// 열려있는 동안에만 confirm 버튼에 dataValue 사용
					confirmBtn.setAttribute(UiDefine.DATA_VALUE, hexCode);
				}
			}
		},

		/**
		 * color picker 의 hue 색상 값을 반환하는 함수
		 * @param {Element} target				- 대상 color picker element
		 * @param {Number} x					- 대상 color picker 에서 선택된 x 좌표
		 * @returns {Number|null}
		 */
		getHueFromColorSpectrum: function (target, x) {
			if (!(target && !isNaN(x))) {
				return null;
			}

			var colorPickerWidth,
				result = null;

			if (CommonFrameUtil.hasClass(target, _colorSpectrumPickerClass)) {
				colorPickerWidth = parseInt(target.style.width, 10);
				result = parseInt(360 - (((colorPickerWidth - x) / colorPickerWidth) * 360), 10);

				if (result > 360) {
					result = 360;
				} else if (result < 0) {
					result = 0;
				}
			}

			return result;
		},

		/**
		 * color picker 의 saturation 색상 값을 반환하는 함수
		 * @param {Element} target				- 대상 color picker element
		 * @param {Number} x					- 대상 color picker 에서 선택된 x 좌표
		 * @returns {Number|null}
		 */
		getSaturationFromColorMatrix: function (target, x) {
			if (!(target && !isNaN(x))) {
				return null;
			}

			var colorPickerWidth,
				result = null;

			if (CommonFrameUtil.hasClass(target, _colorMatrixPickerClass)) {
				colorPickerWidth = parseInt(target.style.width, 10);
				result = parseInt((x * 100) / colorPickerWidth, 10);

				if (result > 100) {
					result = 100;
				}
			}

			return result;
		},

		/**
		 * color picker 의 value brightness 색상 값을 반환하는 함수
		 * @param {Element} target				- 대상 color picker element
		 * @param {Number} y					- 대상 color picker 에서 선택된 y 좌표
		 * @returns {Number|null}
		 */
		getValueBrightnessFromColorMatrix: function (target, y) {
			if (!(target && !isNaN(y))) {
				return null;
			}

			var colorPickerHeight,
				result = null;

			if (CommonFrameUtil.hasClass(target, _colorMatrixPickerClass)) {
				colorPickerHeight = parseInt(target.style.height, 10);
				result = parseInt(((colorPickerHeight - y) * 100) / colorPickerHeight, 10);

				if (result > 100) {
					result = 100;
				} else if (result < 0) {
					result = 0;
				}
			}

			return result;
		},

		/**
		 * spectrum color picker 의 값 유효성 검사
		 * @param {Element} target					- 대상 target
		 * @param {Object=} event					- event 객체
		 * @param {Boolean=} isUpdated				- target 의 spectrum color picker 의 update 여부
		 * @returns {Boolean}						- true: 유효성 처리(유효하지 않은 값),
		 * 											  false: 유효성 처리 안함(target 이 없거나 유효한 값인 경우)
		 */
		checkUpdateSpectrumColor: function (target, event, isUpdated) {
			if (!target) {
				return false;
			}

			var result = false,
				inputWrapEl = this.getInputWrapWidgetByInput(target),
				colorVal, layerNode, confirmBtn;

			if (inputWrapEl && CommonFrameUtil.hasClass(inputWrapEl, UiDefine.PREVIEW_COLOR_TEXT_CLASS)) {
				layerNode = this.findLayerNodeToParent(target);

				if (layerNode) {
					this.validateColorPickerInput(event);

					colorVal = target.value;
					confirmBtn = layerNode.querySelector("." + UiDefine.SPECTRUM_COLOR_CONFIRM_CLASS);

					if (!CommonFrameUtil.isStartsWith(colorVal, "#")) {
						colorVal = "#" + colorVal;
					}

					// validation 처리
					if (this.checkValidationColorCode(colorVal) !== UiDefine.VALIDATION_CHECK_RESULT.SUCCESS) {
						CommonFrameUtil.addClass(confirmBtn, UiDefine.DISABLE_CLASS);
					} else {
						CommonFrameUtil.removeClass(confirmBtn, UiDefine.DISABLE_CLASS);

						if (isUpdated) {
							this.setColorToColorPicker(layerNode, colorVal);
						}
					}
				}

				result = true;
			}

			return result;
		},

		/**
		 * spectrum color picker input 값의 유효하지 않은 문자를 처리하는 함수
		 * @param {Object} event					- event 객체
		 * @returns {Boolean}						- true: 정상 값,
		 * 											  false: 비정상 값 (유효하지 않은 문자 처리)
		 */
		validateColorPickerInput: function (event) {
			var result = true,
				inputTarget = event && event.target,
				insertChar, inputVal, insertCharIndex, textNode;

			if (!inputTarget || !this.isInput(inputTarget)) {
				result = false;
			} else {
				inputVal = inputTarget.value;
				insertChar = (event.originalEvent && event.originalEvent.data) || event.data;

				if (!insertChar) {
					insertChar = inputVal.substring(inputTarget.selectionStart - 1, inputTarget.selectionEnd);
				}

				insertCharIndex = inputVal.indexOf(insertChar);

				if (insertCharIndex > -1 && !/([A-Fa-f0-9])/.test(insertChar)) {
					textNode = document.createTextNode(inputVal);
					textNode.deleteData(insertCharIndex, insertChar.length);
					inputTarget.value = textNode.textContent;
					inputTarget.setSelectionRange(insertCharIndex, insertCharIndex);

					result = false;
				}
			}

			return result;
		},

		/**
		 * 인자로 전해받은 타입으로부터 어떤 event action type 인지 정리하여 돌려주는 함수
		 * @param {String} type
		 * @returns {Object}
		 */
		getEventActionType: function (type) {
			var eventActionType = UiDefine.EVENT_ACTION_TYPE,
				result = {
					isEnableType: false,
					isDisableType: false,
					isVisibleType: false,
					isHiddenType: false,
					isVisibleItemType: false,
					isHiddenItemType: false,
					isNormalType: false
				};

			switch (type) {
				case eventActionType.ENABLE:
					result.isEnableType = true;
					break;
				case eventActionType.DISABLE:
					result.isDisableType = true;
					break;
				case eventActionType.VISIBLE:
					result.isVisibleType = true;
					break;
				case eventActionType.HIDDEN:
					result.isHiddenType = true;
					break;
				case eventActionType.VISIBLE_ITEM:
					result.isVisibleItemType = true;
					break;
				case eventActionType.HIDDEN_ITEM:
					result.isHiddenItemType = true;
					break;
				default:
					result.isNormalType = true;
					break;
			}

			return result;
		}
	};
});