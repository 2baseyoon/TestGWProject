define(function (require) {
	"use strict";

	/*******************************************************************************
	 * Import
	 ******************************************************************************/
	var UiDefine = require("commonFrameJs/uiFramework/uiDefine"),
		UiUtil = require("commonFrameJs/uiFramework/uiUtil"),
		CommonFrameUtil = require("commonFrameJs/utils/util"),
		UiFrameworkInfo = require("commonFrameJs/uiFramework/uiFrameworkInfo");

	/*******************************************************************************
	 * Private Variables
	 ******************************************************************************/

	var _hideViewClass = UiDefine.HIDE_VIEW_CLASS,
		_sidebarId = UiDefine.SIDEBAR_ID,
		_stylebarId = UiDefine.STYLEBAR_ID,
		_modelessDlgId = UiDefine.MODELESS_DIALOG_ID,
		_toolBoxId = UiDefine.TOOL_BOX_ID,
		_cssMapByLang = {
			en: 'Amazon Ember, tahoma, "Segoe UI", Arial, Sans-Serif',
			ko: '"Malgun Gothic", dotum, Arial, Sans-Serif',
			de: '"Segoe UI", Arial, sans-serif',
			es: '"Segoe UI", Arial, sans-serif',
			fr: '"Segoe UI", Arial, sans-serif',
			it: '"Segoe UI", Arial, sans-serif',
			ja: '"meiryo UI", Arial, sans-serif',
			pt: '"Segoe UI", Arial, sans-serif',
			ru: '"Segoe UI", Arial, sans-serif',
			zn_ch: '"微软雅黑", Arial,sans-serif',
			zn_tw: '"微軟正黑體", Arial,sans-serif',
			nl: '"Segoe UI", Arial, sans-serif'
		},
		_fontFaceString = '@charset "utf-8";@font-face {font-family:"Amazon Ember"; font-style:normal; src:url("./commonFrame/skins/type_a/font/AmazonEmber_W_Rg.woff2") format("woff2"), url("./commonFrame/skins/type_a/font/AmazonEmber_W_Rg.woff") format("woff");}',
		_iframeObj = null,
		_inputElToCache, _defaultValue,
		_inputElObj = null,
		_inputDataCmdObj = null,
		_inputStyleInfo = null,
		_defaultPos = "-9999px",
		_zIndexInfo = null,
		_focusedContainerId = null;

	/*******************************************************************************
	 * Private Functions
	 ******************************************************************************/

	function _insertStyleByLang(target) {
		var styleEl = CommonFrameUtil.createDomEl("style"),
			skinName = UiFrameworkInfo.getSkinName(),
			strFontFace = (window.LangDefine.LangCode === "en" && skinName === "type_a") ? _fontFaceString : "",
			strFontColor = (skinName === "type_a") ? "#404041" : "#333";

		styleEl.innerHTML = strFontFace + " body {font-family:" +
			_cssMapByLang[window.LangDefine.LangCode] +
			"; font-size:12px;} input {font:inherit; color:" + strFontColor + ";}" +
			" input::selection {background-color:#6182d6; color:#fff;}"+
			" input::-moz-selection {background-color:#6182d6; color:#fff;}" +
			" input:focus {outline:0}";

		CommonFrameUtil.appendChildNode(target, styleEl);
	}

	return {
		/*******************************************************************************
		 * Public Methods
		 ******************************************************************************/

		/**
		 * iframe 을 생성하고, onload 시점에 input box 를 만드는 함수
		 * @param {Document} contentDoc			- contentWindow 의 document
		 * @param {Element} parentNode				- 생성한 iframe 을 붙일 parent node
		 * @param {String} id						- iframe 에 부여할 id
		 * @param {Function=} callback				- iframe load 후 실행할 콜백 함수 등록
		 *
		 * @return {void}
		 */
		insertIframeWithInput: function (contentDoc, parentNode, id, callback) {
			var iframeDom = contentDoc.createElement("iframe"),
				containderId;

			switch (id) {
				case UiDefine.IFRAME_STYLEBAR:
					containderId = UiDefine.STYLEBAR_ID;
					break;
				case UiDefine.IFRAME_MODELESS_DIALOG:
					containderId = UiDefine.MODELESS_DIALOG_ID;
					break;
				case UiDefine.IFRAME_TOOLBOX:
					containderId = UiDefine.TOOL_BOX_ID;
					break;
				default: // UiDefine.IFRAME_SIDEBAR
					containderId = UiDefine.SIDEBAR_ID;
					break;
			}

			iframeDom.setAttribute("id", id);

			if (_iframeObj == null) {
				_iframeObj = {};
			}

			_iframeObj[containderId] = {};
			_iframeObj[containderId].iframeEl = iframeDom;

			iframeDom.onload = function () {
				var contentWindow = contentDoc.getElementById(id).contentWindow,
					iframeDoc = contentWindow && contentWindow.document,
					htmlEl, body, inputBoxEl;

				if (iframeDoc) {
					htmlEl = iframeDoc.firstElementChild || iframeDoc.firstChild;
					body = iframeDoc.body;
					inputBoxEl = iframeDoc.createElement("input");

					htmlEl.setAttribute("lang", window.LangDefine.LangCode);
					_insertStyleByLang(htmlEl.firstElementChild);

					inputBoxEl.setAttribute("type", "text");
					inputBoxEl.setAttribute("id", "input_iframe");
					//inputBoxEl에 브라우저 자동완성 해제 속성 추가
					inputBoxEl.setAttribute("autocomplete", "off");

					// default style 지정
					body.style.setProperty("margin", 0);
					body.style.setProperty("padding", 0);
					body.style.setProperty("overflow", "hidden");
					inputBoxEl.style.setProperty("margin", 0);
					inputBoxEl.style.setProperty("min-width", "0");
					inputBoxEl.style.setProperty("height", "100%");
					inputBoxEl.style.setProperty("border", "none");

					CommonFrameUtil.appendChildNode(body, inputBoxEl);

					_iframeObj[containderId].inputBoxEl = inputBoxEl;

					if (callback) {
						callback(parentNode);
					}
				}
			};

			CommonFrameUtil.addClass(iframeDom, UiDefine.HIDE_VIEW_CLASS);
			CommonFrameUtil.appendChildNode(parentNode, iframeDom);
		},

		/**
		 * style property 들을 받아 target 에 set 하는 함수
		 * @param {Element} target				- 대상 target
		 * @param {Object} propObj				- set 할 스타일 property object
		 *
		 * @return {void}
		 */
		setStylePropsToTarget: function (target, propObj) {
			var key;

			if (!target) {
				return;
			}

			for (key in propObj) {
				if (key != null && propObj[key]) {
					target.style.setProperty(key, propObj[key]);
				}
			}
		},

		/**
		 * iframe 위치 및 값을 초기화 하는 함수
		 * @param {Element} target				- 대상 target
		 *
		 * @return {vcacheInputEloid}
		 */
		resetPosToIframe: function (target) {
			var iframeInfo = this.getIframeInfoToInputBox(target),
				containerEl, containerId, iframeEl;

			if (iframeInfo == null) {
				containerEl = UiUtil.findContainerNodeToParent(target);
				containerId = containerEl && containerEl.id;
				iframeInfo = containerId && _iframeObj[containerId];
			}

			iframeEl = iframeInfo && iframeInfo.iframeEl;

			if (iframeEl) {
				this.setStylePropsToTarget(iframeEl, {
					"top": _defaultPos,
					"left": _defaultPos
				});
				target.value = "";
				CommonFrameUtil.addClass(iframeEl, _hideViewClass);
				_focusedContainerId = null;
			}
		},

		/**
		 * iframe 아래에 감춰져 있는 input box 정보를 cache 하는 함수
		 * @param {Element} target				- 대상 target input
		 *
		 * @return {void}
		 */
		cacheInputEl: function (target) {
			_inputElToCache = target;
			_defaultValue = _inputElToCache.value;
		},

		/**
		 * iframe 아래에 감춰져 있는 input box 정보를 reset 하는 함수
		 *
		 * @return {void}
		 */
		resetInputEl: function () {
			_inputElToCache = null;
			_defaultValue = "";
		},

		/**
		 * iframe 아래에 감춰져 있는 input box reference 를 돌려주는 함수
		 *
		 * @return {Element}
		 */
		getInputElToCache: function () {
			return _inputElToCache;
		},

		/**
		 * iframe 아래에 감춰져 있는 input box 의 초기값을 돌려주는 함수
		 *
		 * @return {*}
		 */
		getDefaultValue: function () {
			return _defaultValue;
		},

		/**
		 * 생성 시 캐싱해둔 iframe 들의 정보를 담은 object 를 반환하는 함수
		 *
		 * @return {Object}
		 */
		getIframeObj: function () {
			return _iframeObj;
		},

		/**
		 * id 를 통해 해당 iframe element 의 reference 를 돌려주는 함수
		 * @param {String} id				- UiDefine.STYLEBAR_ID or UiDefine.SIDEBAR_ID
		 *
		 * @return {Object|null}
		 */
		getIframeElFromId: function (id) {
			return (_iframeObj && id && _iframeObj[id] && _iframeObj[id].iframeEl) || null;
		},

		/**
		 * container node 를 통해 해당 container id 를 돌려주는 함수
		 * @param {Element} containerNode
		 * @return {String|null}
		 */
		getIdFromContainerNode: function(containerNode) {
			var id = null;

			if (this.isSidebar(containerNode)) {
				id = _sidebarId;
			} else if (this.isStylebar(containerNode)) {
				id = _stylebarId;
			} else if (this.isToolBox(containerNode)) {
				id = _toolBoxId;
			} else if (this.isModelessDialog(containerNode)) {
				id = _modelessDlgId;
			}

			return id;
		},

		/**
		 * target 을 통해 해당하는 iframe 과 id 정보를 돌려주는 함수
		 * - target 은 iframe 아래 감춰져 있는 input box 임
		 *
		 * @param {Object} target				- target (target 은 iframe 아래 감춰져 있는 input box 임)
		 *
		 * @return {Object|null}
		 */
		getIframeInfoToInputBox: function (target) {
			var sidebarId = UiDefine.SIDEBAR_ID,
				stylebarId = UiDefine.STYLEBAR_ID,
				toolBoxId = UiDefine.TOOL_BOX_ID,
				modelessDlgId = UiDefine.MODELESS_DIALOG_ID;

			if (_iframeObj && _iframeObj[sidebarId] && _iframeObj[sidebarId].inputBoxEl === target) {
				return {
					iframeEl: _iframeObj[sidebarId].iframeEl,
					id: sidebarId
				};
			}

			if (_iframeObj && _iframeObj[stylebarId] && _iframeObj[stylebarId].inputBoxEl === target) {
				return {
					iframeEl: _iframeObj[stylebarId].iframeEl,
					id: stylebarId
				};
			}

			if (_iframeObj && _iframeObj[toolBoxId] && _iframeObj[toolBoxId].inputBoxEl === target) {
				return {
					iframeEl: _iframeObj[toolBoxId].iframeEl,
					id: toolBoxId
				};
			}

			if (_iframeObj && _iframeObj[modelessDlgId] && _iframeObj[modelessDlgId].inputBoxEl === target) {
				return {
					iframeEl: _iframeObj[modelessDlgId].iframeEl,
					id: modelessDlgId
				};
			}

			return null;
		},

		/**
		 * id 를 통해 해당 iframe element 아래 input box 의 reference 를 돌려주는 함수
		 *
		 * @param {String} id				- UiDefine.STYLEBAR_ID or UiDefine.SIDEBAR_ID
		 *
		 * @return {Object}
		 */
		getInputBoxFromId: function (id) {
			return (_iframeObj && id && _iframeObj[id] && _iframeObj[id].inputBoxEl) || null;
		},

		/**
		 * id 를 통해 해당 iframe element 를 찾고, 해당 iframe 아래 input box 가
		 * focus 를 가졌는지 판단하는 함수
		 *
		 * @param {String} id				- UiDefine.STYLEBAR_ID or UiDefine.SIDEBAR_ID
		 *
		 * @return {Boolean}
		 */
		hasFocusToInputOnIframe: function (id) {
			var iFrameEl = _iframeObj && _iframeObj[id] && _iframeObj[id].iframeEl,
				contentDoc = iFrameEl && iFrameEl.contentWindow && iFrameEl.contentWindow.document;

			return !!(contentDoc && (contentDoc.activeElement === _iframeObj[id].inputBoxEl));
		},

		/**
		 * node 가 sidebar 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isSidebar: function(target) {
			return !!(target && (target.id === UiDefine.SIDEBAR_ID));
		},

		/**
		 * node 가 stylebar 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isStylebar: function (target) {
			return !!(target && (target.id === UiDefine.STYLEBAR_ID));
		},

		/**
		 * node 가 tool box 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isToolBox: function (target) {
			return !!(target && (target.id === UiDefine.TOOL_BOX_ID));
		},

		/**
		 * node 가 modelessDialog 인지 아닌지.
		 * @param {Element} target		- 확인할 대상
		 * @returns {boolean}
		 */
		isModelessDialog: function (target) {
			return !!(target && (target.id === UiDefine.MODELESS_DIALOG_ID));
		},

		/**
		 * iframe 이 위치해야 할 position 정보를 계산하여 돌려주는 함수
		 * - webword iframe 처리를 위한 함수
		 *
		 * @param {String} id						- UiDefine.STYLEBAR_ID or UiDefine.SIDEBAR_ID
		 * @param {Object} offset					- iframe 이 가려야할 input box 의 boundingClientRect 값
		 * @param {Boolean} needLeftPos			- left position 값이 필요한지 아닌지.
		 *
		 * @return {Object|null}
		 */
		getPosInfoToIframe: function (id, offset, needLeftPos) {
			var sidebarEl, sidebarOffset, borderLeft, result;

			if (id === _sidebarId) {
				sidebarEl = UiFrameworkInfo.getContainerNode(_sidebarId);
				sidebarOffset = sidebarEl.getBoundingClientRect();
				borderLeft = parseInt(CommonFrameUtil.getCurrentStyle(sidebarEl, "border-left"), 10) || 0;
				result = {};

				if (needLeftPos) {
					result.left = (offset.left - sidebarOffset.left - borderLeft) + "px";
				}

				result.top = (offset.top - sidebarOffset.top) + "px";

				return result;
			}

			return null;
		},

		/**
		 * Resize / scroll event 발생 시 Sidebar 의 iframe 이 active 상태면, 위치를 옮겨주는 함수
		 * - webword iframe 처리를 위한 함수
		 *
		 * @param {Boolean} needLeftPos			- left position 값이 필요한지 아닌지.
		 *
		 * @return {void}
		 */
		setPosIframeToSidebar: function (needLeftPos) {
			var id = _sidebarId,
				iFrameEl = this.getIframeElFromId(id),
				inputEl, offset, posInfo;

			if (iFrameEl && this.hasFocusToInputOnIframe(id)) {
				inputEl = this.getInputElToCache();
				offset = inputEl && inputEl.getBoundingClientRect();

				if (offset) {
					posInfo = this.getPosInfoToIframe(id, offset, needLeftPos);

					if (posInfo) {
						this.setStylePropsToTarget(iFrameEl, posInfo);
					}
				}
			}
		},

		/**
		 * fold 발생 시 Stylebar 의 iframe 이 active 상태면, 위치를 옮겨주는 함수
		 * - webword iframe 처리를 위한 함수
		 *
		 * @param {String} containerID			- iframe input 이 위치한 container id
		 *
		 * @return {void}
		 */
		setPosIframeToStylebar : function (containerID) {
			var id = containerID || _stylebarId,
				iFrameEl = this.getIframeElFromId(id),
				inputEl, offset, styleObj;

			if (iFrameEl && this.hasFocusToInputOnIframe(id)) {
				inputEl = this.getInputElToCache();
				offset = inputEl && inputEl.getBoundingClientRect();

				if (offset) {
					styleObj = {
						"top" : offset.top + "px",
						"left" : offset.left + "px"
					};

					this.setStylePropsToTarget(iFrameEl, styleObj);
				}
			}
		},

		/**
		 * scroll 이벤트 발생 시 내부의 iframe 이 active 상태면, 위치를 옮겨주는 함수
		 * - webword iframe 처리를 위한 함수
		 * @param {Object} e		- event 객체
		 * @return {void}
		 */
		updatePosByScrollEvent: function (e) {
			var containerNode = UiUtil.findContainerNodeToParent(e.target),
				containerID = containerNode && containerNode.id;

			if (containerID) {
				if (containerID === _sidebarId) {
					this.setPosIframeToSidebar(false);
				} else {
					this.setPosIframeToStylebar(containerID);
				}
			}
		},

		/**
		 *
		 * target 의 input element 값으로 iframe input 값 갱신
		 * (cache 하고 있는 대상 input 이어야 갱신함)
		 *
		 * @param {Element} target		- 갱신할 input element
		 *
		 * @return {void}
		 */
		updateInputValue: function (target) {
			var inputBoxEl = this.getInputBoxFromId(_focusedContainerId),
				targetValue = target && target.value;

			if (target && inputBoxEl && CommonFrameUtil.isString(targetValue) && targetValue !== inputBoxEl.value) {
				inputBoxEl.value = targetValue;
				this.cacheInputEl(target);
			}
		},

		/**
		 * original input 의 속성 중 상속받아야 하는 속성을 iframe input 에 설정한다.
		 * @param {Element} inputEl			- original input
		 * @param {Element} containerNode	- original input 이 속한 container 노드
		 */
		setAttrIframeInput : function(inputEl, containerNode) {
			var arrAttrs = ["maxLength"],
				id = this.getIdFromContainerNode(containerNode),
				inputBoxEl = this.getInputBoxFromId(id),
				len = arrAttrs.length,
				i, item, orgAttrVal, curAttrVal;

			if (!(inputEl && inputBoxEl)) {
				return;
			}

			for (i = 0; i < len; i++) {
				item = arrAttrs[i];
				orgAttrVal = inputEl.getAttribute(item);
				curAttrVal = inputBoxEl.getAttribute(item);

				if (orgAttrVal !== curAttrVal) {
					if (!orgAttrVal) {
						inputBoxEl.removeAttribute(item);
					} else {
						inputBoxEl.setAttribute(item, orgAttrVal);
					}
				}
			}
		},

		/**
		 * iframe 이 활성화 되었을 때, iframe 의 위치를 변경해주는 함수
		 * - webword iframe 처리를 위한 함수
		 *
		 * @param {Element} containerNode			- side bar, style bar, tool box(color picker), modeless dialog
		 * @param {Boolean=} isContentSelect		- iframe 활성화시 input 의 contents 를 select 할지 여부
		 *
		 * @return {void}
		 */
		setPosIframeWithInput: function (containerNode, isContentSelect) {
			var _this = this,
				inputEl = this.getInputElToCache(),
				offset, id, value, posInfo, styleObj, iFrameEl, inputBoxEl, targetNode;

			var __getZIndexToContainer = function (el, key) {
				if (!el && !key) {
					return null;
				}

				var wrapNode, parentNode, zIndexStyle, zIndex;

				if (_zIndexInfo == null) {
					_zIndexInfo = {};
				}

				if (_zIndexInfo[key] == null) {
					wrapNode = UiFrameworkInfo.getInfo(UiFrameworkInfo.WRAP_NODE);
					parentNode = el.parentNode;

					// TODO: toolBox 내에서 quickMenu 외 iframe input 을 써야하는 경우 수정 필요 (추후 개선 필요)
					if (_this.isToolBox(containerNode)) {
						targetNode = containerNode.querySelector("." + UiDefine.TOOL_QUICK_MENU);
						zIndexStyle = CommonFrameUtil.getCurrentStyle(targetNode, "z-index");
						zIndex = parseInt(zIndexStyle, 10);
					} else {
						while (parentNode && (parentNode !== wrapNode)) {
							zIndexStyle = CommonFrameUtil.getCurrentStyle(parentNode, "z-index");

							if (zIndexStyle === "auto") {
								parentNode = parentNode.parentNode;
							} else {
								zIndex = parseInt(zIndexStyle, 10);
								break;
							}
						}
					}

					_zIndexInfo[key] = (zIndex == null ? 0 : zIndex);
				}

				return _zIndexInfo[key];
			};

			id = this.getIdFromContainerNode(containerNode);

			if (!inputEl || !id) {
				// iFrameInput 사용하지 않는 container return
				return;
			}

			offset = inputEl.getBoundingClientRect();

			if (id === _sidebarId) {
				posInfo = this.getPosInfoToIframe(id, offset, true);
				styleObj = {
					"width": (offset.width - 1) + "px",
					"height": offset.height + "px",
					"top": (posInfo && posInfo.top) || _defaultPos,
					"left": (posInfo && posInfo.left) || _defaultPos
				};
			} else {
				styleObj = {
					"width": (offset.width - 1) + "px",
					"height": offset.height + "px",
					"top": offset.top + "px",
					"left": offset.left + "px"
				};
			}

			value = __getZIndexToContainer(inputEl, id);
			styleObj["z-index"] = (value != null ? value : 0) + 1;

			iFrameEl = this.getIframeElFromId(id);
			this.setStylePropsToTarget(iFrameEl, styleObj);

			inputBoxEl = this.getInputBoxFromId(id);

			if (!_inputStyleInfo) {
				_inputStyleInfo = {};
			}

			if (!_inputStyleInfo[id]) {
				_inputStyleInfo[id] = {};
				_inputStyleInfo[id].top = parseInt(CommonFrameUtil.getCurrentStyle(inputEl, "paddingTop"), 10) || 0;
				_inputStyleInfo[id].bottom = parseInt(CommonFrameUtil.getCurrentStyle(inputEl, "paddingBottom"), 10) || 0;
				_inputStyleInfo[id].left = parseInt(CommonFrameUtil.getCurrentStyle(inputEl, "paddingLeft"), 10) || 0;
				_inputStyleInfo[id].right = parseInt(CommonFrameUtil.getCurrentStyle(inputEl,"paddingRight"), 10) || 0;

				this.setStylePropsToTarget(_iframeObj[id].inputBoxEl, {
					"padding-top": _inputStyleInfo[id].top + "px",
					"padding-bottom": _inputStyleInfo[id].bottom + "px",
					"padding-left": _inputStyleInfo[id].left + "px",
					"padding-right": _inputStyleInfo[id].right + "px"
				});
			}

			this.setStylePropsToTarget(inputBoxEl, {
				"width": offset.width + "px"
			});

			inputBoxEl.value = inputEl.value;

			if (CommonFrameUtil.hasClass(iFrameEl, _hideViewClass)) {
				CommonFrameUtil.removeClass(iFrameEl, _hideViewClass);
				_focusedContainerId = id;
			}

			if (isContentSelect) {
				if (UiUtil.getBrowserInfo().isSafari) {
					inputBoxEl.focus();
				}

				inputBoxEl.select();
			}
		},

		/**
		 * iframe 이 활성화 되어야 할 필요가 있을 경우, iframe 을 활성화해주는 함수
		 * - webword iframe 처리를 위한 함수
		 *
		 * @param {Element} containerNode			- side bar or style bar
		 * @param {Element} el						- iframe 이 가리는 input box 의 상위에 위치한 command element
		 * @param {Boolean=} isContentSelect		- iframe 활성화시 input 의 contents 를 select 할지 여부
		 * @param {Function=} beforeBlurCallback	- iframe 활성화 이전에 호출되어야 하는 콜백
		 *
		 * @returns {Object}
		 */
		setFocusIframeIfNeeded: function (containerNode, el, isContentSelect, beforeBlurCallback) {
			if (this.getIframeObj() == null) {
				return {"focus" : false};
			}

			var inputEl = (el.nodeName === "INPUT" ? el : el.querySelector("input")),
				objFocus = {
					"focus" : false,
					"sameAreaBlurTarget" : null
				},
				id ,inputBoxEl, inputElToCache, dataCmdEl;

			if (inputEl && inputEl.getAttribute("type") === "text") {
				if (this.isSidebar(containerNode)) {
					id = _sidebarId;
				} else if (this.isStylebar(containerNode)) {
					id = _stylebarId;
				} else if (this.isToolBox(containerNode)) {
					id = _toolBoxId;
				} else if (this.isModelessDialog(containerNode)) {
					id = _modelessDlgId;
				}

				if (id != null && !inputEl.getAttribute("disabled")) {
					if (beforeBlurCallback) {
						beforeBlurCallback();
					}

					inputBoxEl = this.getInputBoxFromId(id);
					inputElToCache = this.getInputElToCache();

					if (inputElToCache != null) {
						dataCmdEl = UiUtil.findCommandElementToParent(inputElToCache, containerNode);
						if (dataCmdEl.getAttribute(UiDefine.DATA_NON_EXEC) !== "true") {
							inputElToCache.value = this.getDefaultValue();
						}

						if (this.hasFocusToInputOnIframe(id)) {
							objFocus.sameAreaBlurTarget = {
								"ele" : inputElToCache,
								"val" : this.getDefaultValue()
							};
						}
					}

					this.cacheInputEl(inputEl);
					this.setPosIframeWithInput(containerNode, isContentSelect);
					this.setAttrIframeInput(inputEl, containerNode);

					if (!isContentSelect) {
						inputBoxEl.focus();
					}

					objFocus.focus = true;
				}
			}

			return objFocus;
		},

		/**
		 * iframe 활성화된 상태에서 tab key 입력 시, 옮겨져야 할 input box 를 찾는 함수
		 * - webword iframe 처리를 위한 함수
		 *
		 * @param {Boolean} inputShiftKey			- shift key 가 눌렸는지 아닌지.
		 * @param {Element} containerNode			- side bar or style bar
		 * @param {Element} inputElToCache			- iframe 이 가리는 input box
		 *
		 * @return {Object|null}
		 */
		findInputEl: function (inputShiftKey, containerNode, inputElToCache) {
			var _this = this,
				id = containerNode.id,
				keyLen = 0,
				inputElList = [],
				ignoreRefTreeKeyArr, refTree, containerRefTree, viewKeys, viewKey, curRefItem, titlePanelEl,
				i, j, querySelectList, querySelectListLen, dataCmdEl, dataCmd, valueKey, index, inputEl, length, target;

			var __isEnableTarget = function (target) {
				var parentNode = target.parentNode,
					result = false,
					targetDataCmdEl, targetDataCmd, targetValueKey, titlePanel;

				// 1. 자신의 부모가 hidden / disable 상태가 아니여야 함
				if (!UiUtil.isHidden(parentNode) && !UiUtil.isDisabled(parentNode)) {
					if (_this.isSidebar(containerNode)) {
						targetDataCmdEl = UiUtil.findCommandElementToParent(inputEl, containerNode);
						targetDataCmd = targetDataCmdEl.getAttribute(UiDefine.DATA_COMMAND);
						targetValueKey = targetDataCmdEl.getAttribute(UiDefine.DATA_VALUE_KEY);
						titlePanel = _inputDataCmdObj[(!targetValueKey ? targetDataCmd : targetDataCmd + "_" + targetValueKey)];

						// 2. 그 target 이 속한 title panel 이 hide / fold 상태가 아니여야함
						if (!CommonFrameUtil.hasClass(titlePanel.parentNode, _hideViewClass)
							&& !CommonFrameUtil.hasClass(titlePanel.parentNode, UiDefine.FOLD_VIEW_CLASS)) {
							result = true;
						}
					} else if (_this.isStylebar(containerNode)) {
						result = true;
					}
				}

				return result;
			};

			if (!_inputElObj) {
				_inputElObj = {};
				_inputDataCmdObj = {};
			}

			// 현재 대상이 style bar 인 경우
			if (id === _stylebarId) {
				// input box 가 caching 되어있지 않다면, caching 을 한다.
				if (!_inputElObj[id]) {
					_inputElObj[id] =
						CommonFrameUtil.getCollectionToArray(containerNode.querySelectorAll("input[type=text]"));
				}

				inputElList = _inputElObj[id];
			} else if (id === _sidebarId) {
				// 현재 대상이 side bar 일 경우
				// 만약 fold 된 상태라면, input box 를 찾지 않고 패스한다.
				if (CommonFrameUtil.hasClass(containerNode, UiDefine.FOLD_VIEW_CLASS)) {
					return null;
				}

				refTree = UiFrameworkInfo.getRefTree();
				containerRefTree = refTree[id];

				// input box 가 caching 되어있지 않다면, caching 을 한다.
				if (!_inputElObj[id]) {
					_inputElObj[id] = {};
					ignoreRefTreeKeyArr = UiDefine.IGNORE_REF_TREE_KEY_ARR;
					if (containerRefTree) {
						viewKeys = Object.keys(containerRefTree);
					}

					if (viewKeys && viewKeys.length) {
						keyLen = viewKeys.length;

						// cache 할 대상인 input element 를 검색하고, caching 하는 과정
						for (i = 0; i < keyLen; ++i) {
							viewKey = viewKeys[i];
							if (ignoreRefTreeKeyArr.indexOf(viewKey) !== -1) {
								continue;
							}
							curRefItem = containerRefTree[viewKey];
							titlePanelEl = curRefItem ? curRefItem.ref : null;

							if (titlePanelEl) {
								querySelectList = CommonFrameUtil.getCollectionToArray(titlePanelEl.querySelectorAll("input[type=text]"));

								// title panel 에서 input box 를 찾도록 했는데, 만약 없다면 캐싱하지 않고 패스한다.
								if (querySelectList.length !== 0) {
									inputElList = inputElList.concat(querySelectList);
									querySelectListLen = querySelectList.length;

									// input box 의 data cmd 를 key 로 한 object 에 title panel node 를 담는다.
									// 이는 추후, 다시 한번 title panel 을 찾을 필요 없도록 하기 위함이다.
									for (j = 0; j < querySelectListLen; ++j) {
										inputEl = querySelectList[j];

										dataCmdEl = UiUtil.findCommandElementToParent(inputEl, titlePanelEl);
										dataCmd =  dataCmdEl.getAttribute(UiDefine.DATA_COMMAND);
										valueKey = dataCmdEl.getAttribute(UiDefine.DATA_VALUE_KEY);

										_inputDataCmdObj[(!valueKey ? dataCmd : (dataCmd + "_" + valueKey))] = titlePanelEl;
									}
								}
							}
						}
					}

					_inputElObj[id] = inputElList;
				} else {
					inputElList = _inputElObj[id];
				}
			}

			// 현재 input box 의 이전 node / 이후 node 를 검색하면서 이동될 input target 을 찾음
			if (inputShiftKey) {
				index = inputElList.indexOf(inputElToCache) - 1;
				while (index > -1) {
					inputEl = inputElList[index--];
					if (__isEnableTarget(inputEl)) {
						target = inputEl;
						break;
					}
				}
			} else {
				index = inputElList.indexOf(inputElToCache) + 1;
				length = inputElList.length;
				while (index < length) {
					inputEl = inputElList[index++];
					if (__isEnableTarget(inputEl)) {
						target = inputEl;
						break;
					}
				}
			}

			return target || null;
		}

	};
});
