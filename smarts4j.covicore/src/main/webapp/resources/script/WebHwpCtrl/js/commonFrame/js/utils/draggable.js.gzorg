define([
	'jquery',
	'commonFrameJs/utils/util'
], function($, Util) {
	/**
	 *	마우스 드래그 모듈
	 *	@function
	 *	@name excute
	 *		@param {object} options
	 *			@property {element} options.target					- 드래그 이벤트가 동작될 대상 노드.(필수)
	 *			@property {element} options.layer					- 드래그 이벤트가 동작될때 이동할 레이어 노드.(필수)
	 *			@property {Object} options.joinSelectableTarget		- 드래그 이벤트가 동작될 대상 및 이동할 레이어를 동적으로 Selectable Event로 설정 여부
	 *			                                                 	  (joinSelectableTarget=true 일때는 target 과 layer 설정은 무시된다.)
	 *			@property {Object} options.joinSelectableEvent		- Selectable에서 발생한 Event 값 (joinSelectableTarget=true 일때만 유효하다.)
	 *			@property {element} options.doc						- Document 노드(Iframe일때는 Iframe Document를 설정) - 기본값(Document)
	 *			@property {string} options.axis						- "x" : x축이동, "y" : y축 이동
	 *			@property {string or element} options.containment	- 드래그 가능한 영역 설정
	 *				- "parent"		: 상위노드
	 *				- "document"	: 문서전체
	 *				- "window"		: 문서전체
	 *				- Selector		: jQuery 셀렉터
	 *				- Element		: 영역으로 지정할 노드
	 *			@property {object} options.containmentDetails		- 드래그 가능한 영역에서 상하좌우로 픽셀단위로 가감 설정(예 {"left" : "+10"})
	 *				- "left"		: 좌측영역 가감설정
	 *				- "right"		: 우측영역 가감설정
	 *				- "top"			: 상단영역 가감설정
	 *				- "bottom"		: 하단영역 가감설정
	 *			@event {function} options.start						- 드래그가 시작되는 시점에 발생되는 이벤트 콜백 지정
	 *				@callback										- 콜백함수를 값으로 할당. 모든 이벤트는 다음의 파람을 돌려받을수 있음.
	 *					@param {object} event		: jQuery Original Mouse Event
	 *					@param {object} ui event	: UI Event Information(position, offset)
	 *			@event {function} options.stop						- 드래그가 끝나는 시점에 발생되는 이벤트 콜백 지정
	 *			@event {function} options.drag						- 드래그가 진행되는 동안에 발생되는 이벤트 콜백 지정
	 *
	 *	@method
	 *	@name enable												- 드래그 이벤트 동작을 활성화 시킴.
	 *	@name disable												- 드래그 이벤트 동작을 비활성화 시킴.
	 *	@name option												- 옵션값을 가져오거나 설정
	 *		@param {string} optName		: 옵션 프로퍼티 이름
	 *		@param {object} value		: 옵션 프로퍼티 값
	 * 
	 */
	var onMouseDraggable = function(context) {
		var dragActive = false
		, dragMainLayer = null
		, dragLayerPos = [0,0]
		, dragLayerGap = [0,0]
		, dragMousePos = [0,0]
		, containDetails = {}
		, options = {
			"target" : null,
			"layer" : null,
			"joinSelectableTarget" : null,
			"joinSelectableEvent" : null,
			"doc" : document,
			"axis" : "",
			"containment" : null,
			"containmentDetails" : null,
			"disabled" : false
		}
		, events = {
			"start" : null,
			"stop" : null,
			"drag" : null
		};

		//마우스 드래그 모듈 실행
		this.excute = function(ele, layer) {
			if (arguments.length == 1 && typeof(arguments[0]) == "object") {
				var key = null
				, items = arguments[0];
				for (key in items) {
					if (typeof(options[key]) != "undefined") {
						options[key] = items[key];
					} else if (typeof(events[key]) != "undefined") {
						events[key] = items[key];
					}
				}
			} else {
				options.target = ele;
				options.layer = layer;
			}

			if (!(options.target && options.layer)) { return; }

			this.getContainDetail();

			if (options.joinSelectableTarget !== true) {
				$(options.target).bind('mousedown', $.proxy(this.doDraggableDown, this));
			}

			if (this.getContainPostion() || options.joinSelectableTarget === true) {
				$(options.doc).bind('mouseup', $.proxy(this.doDraggableUp, this));
			} else {
				$(options.target).bind('mouseup', $.proxy(this.doDraggableUp, this));
			}
		};

		//마우스다운 이벤트 처리(드래그 프로퍼티 초기값 설정)
		this.doDraggableDown = function(e) {
			if (options.disabled === true) {
				return false;
			}

			var dPoint = this.getEventOffset(e)
			, layerPos = this.getLayerPosition()
			, layerTop = layerPos.top
			, layerLeft = layerPos.left
			, layerGapTop = 0
			, layerGapLeft = 0;
			
			dragActive = true;
			dragMainLayer = options.layer;
			
			layerGapTop = Util.getOffsetTop($(dragMainLayer).get(0)) - layerTop;
			layerGapLeft = Util.getOffsetLeft($(dragMainLayer).get(0)) - layerLeft;

			dragLayerPos = [layerLeft, layerTop];
			dragLayerGap = [Math.max(0, layerGapLeft), Math.max(0, layerGapTop)];
			dragMousePos = [dPoint.x, dPoint.y];

			$(options.doc).bind('mousemove.Draggable', $.proxy(this.doDraggableMove, this));

			if ($.isFunction(events.start)) {
				events.start.call((context || this), e, this.getCustomEventInfo());
			}

			if (e.preventDefault) { e.preventDefault(); }
			if (e.stopPropagation) { e.stopPropagation(); }
			return false;
		};

		//마우스업 이벤트 처리(드래그 프로퍼티 초기화)
		this.doDraggableUp = function (e) {
			if (dragActive === true) {
				dragActive = false;
				dragMainLayer = null;
				dragLayerPos = [0, 0];
				dragLayerGap = [0, 0];
				dragMousePos = [0, 0];

				$(options.doc).unbind('mousemove.Draggable');

				if ($.isFunction(events.stop)) {
					events.stop.call((context || this), e, this.getCustomEventInfo());
				}
			}
		};

		//마우스드래그 이벤트 처리(레이어 포지션 업데이트)
		this.doDraggableMove = function(e) {
			if (!dragActive || options.disabled === true) {
				return;
			}

			var dPoint = this.getEventOffset(e)
			, m_x = dragMousePos[0] - dPoint.x
			, m_y = dragMousePos[1] - dPoint.y
			, conPos = this.getContainPostion()
			, layerPos = this.getLayerPosition()
			, isDrag = false;

			if (!options.axis || options.axis === "x") {
				var valX = dragLayerPos[0] - m_x
				, layerWidth = $(options.layer).outerWidth();

				if (conPos && conPos.isWindow == false) {
					var compXMin = conPos.start[0] - dragLayerGap[0] + (containDetails.left || 0)
					, compXMax = conPos.end[0] - layerWidth - dragLayerGap[0] + (containDetails.right || 0);

					if (valX < compXMin) {
						valX = compXMin;
					} else if (valX > compXMax) {
						valX = compXMax;
					}
				}

				if (layerPos.left != valX) {
					dragMainLayer.style.left = valX + "px";
					isDrag = true;
				}
			}

			if (!options.axis || options.axis === "y") {
				var valY = dragLayerPos[1] - m_y
				, layerHeight = $(options.layer).outerHeight();

				if (conPos && conPos.isWindow == false) {
					var compYMin = conPos.start[1] - dragLayerGap[1] + (containDetails.top || 0)
					, compYMax = conPos.end[1] - layerHeight - dragLayerGap[1] + (containDetails.bottom || 0);

					if (valY < compYMin) {
						valY = compYMin;
					} else if (valY > compYMax) {
						valY = compYMax;
					}
				}

				if (layerPos.top != valY) {
					dragMainLayer.style.top = valY + "px";
					isDrag = true;
				}
			}

			if ($.isFunction(events.drag) && isDrag) {
				events.drag.call((context || this), e, this.getCustomEventInfo());
			}
		};

		//드래그영역 포지션값 반환
		this.getContainPostion = function() {
			var start = []
			,	end = []
			,	$target = null
			,	isWindow = false;

			if (typeof(options.containment) == "string") {
				switch (options.containment) {
					case "parent" :
						$target = $(options.target).parent();
						break;
					case "document" :
					case "window" :
						$target = $(window);
						break;
					default :
						$target = $(options.containment);
				}
			} else {
				if (options.containment) {
					$target = $(options.containment);
					if (/[\#]?document$/i.test($target.get(0).nodeName)) {
						$target = $(window);
					}
				}
			}
			
			if ($.isWindow($target.get(0))) {
				start = [0, 0];
				end = [$target.width(), $target.height()];
				isWindow = true;
			} else {
				if ($target && $target.length && $target.prop("nodeType") != 3) {
                    // 기존 코드
					// var targetWidth = $target.get(0).clientWidth || $target.width()
					// ,	targetHeight = $target.get(0).clientHeight || $target.height();
					var targetWidth = $target.get(0).clientWidth || $target.width()
					,	targetHeight = $target.get(0).clientHeight || $target.height();
					start = [Util.getOffsetLeft($target.get(0)), Util.getOffsetTop($target.get(0))];
					end = [start[0] + targetWidth, start[1] + targetHeight];
				}
			}

			if (start.length && end.length) {
				return {
					"start" : start,
					"end" : end,
					"isWindow" : isWindow
				};
			} else {
				return null;
			}
		};

		//드래그영역 미세조정값 반환
		this.getContainDetail = function() {
			var details = options.containmentDetails;
			if (!(details && typeof(details) == "object")){ return; }

			var parseVal = function(val) {
				var checkStr = /[+-]/.exec(val)
				, detailCalc = 0;

				if (checkStr) {
					var num = val.substring(checkStr.index);
					num = parseInt(num.replace(/[+-]/g, ''));
					if (!isNaN(num)) {
						detailCalc = num * ((checkStr == "-") ? -1 : 1);
					}
				}

				return detailCalc;
			};

			$.each(details, function(key, val) {
				if (key && val) {
					var realVal = parseVal(val);
					if (Util.isNumber(realVal)) {
						containDetails[key] = realVal;
					}
				}
			});
		};

		//커스텀 이벤트 정보값 반환
		this.getCustomEventInfo = function() {
			var offset = {
				"left" : Util.getOffsetLeft($(options.layer).get(0)),
				"top" : Util.getOffsetTop($(options.layer).get(0))
			}
			, posInfo = this.getLayerPosition()
			, position = {
				"left" : posInfo.left,
				"top" : posInfo.top
			};
			
			return {
				"offset" : offset,
				"position" : position
			};
		};

		//이동할 레이어의 현재 포지션값 반환
		this.getLayerPosition = function() {
			var $layer = $(options.layer)
			,	top = parseInt($layer.css('top'))
			,	left = parseInt($layer.css('left'));

			var getPhysicalPos = function(posName) {
				var pos = 0
				, $posContext = $layer.parents().filter(function(idx) {
					return $.inArray($(this).css('position'), ["absolute", "relative"]) != -1;
				});

				if (posName == "top") {
					pos = Util.getOffsetTop($layer.get(0));
					pos -= ($posContext.length) ? Util.getOffsetTop($posContext.get(0)) : 0;
				} else {
					pos = Util.getOffsetLeft($layer.get(0));
					pos -= ($posContext.length) ? Util.getOffsetLeft($posContext.get(0)) : 0;
				}
				
				return pos;
			};

			return {
				"left" : (isNaN(left) ? getPhysicalPos('left') : left),
				"top" : (isNaN(top) ? getPhysicalPos('top') : top)
			};
		};

		//마우스 이벤트 오프셋값 반환
		this.getEventOffset = function(e) {
			return {
				"x" : e.clientX,
				"y" : e.clientY
			};
		};

		/**
		 * MouseDraggable Method
		 */

		//Draggable 동작 활성화
		this.enable = function() {
			options.disabled = false;
		};

		//Draggable 동작 비활성화
		this.disable = function() {
			options.disabled = true;
		};

		/**
		 *	Draggable 옵션값을 가져오거나 설정
		 *		@param optName
		 *			- {Empty}	: 옵션 프로퍼티 전체를 Object(key/value) 형식으로 반환
		 *			- {string}	: 지정한 옵션 프로퍼티값을 반환
		 *			- {object}	: Object(key/value) 형식으로 지정한 프로퍼티 복수개의 값을 설정
		 *		@param value	: 설정할 옵션 프로퍼티 값
		 */
		this.option = function(optName, value) {
			var _this = this
			,	reVal = null
			,	isJoinSelectable = false
			,	evtSelectable = null;

			// 옵션값 가져오기
			var getOptionVal = function(name) {
				var optVal = options[name];
				return (optVal == undefined) ? null : optVal;
			};
			// 옵션값 설정하기
			var setOptionVal = function(name, val) {
				var isSet = false
				,	opt = getOptionVal(name);

				if (opt !== null && $.inArray(name, ["doc", "joinSelectableTarget"]) == -1) {
					var chVal = val;
					if (name === "containment") {
						if (!(options.containment && chVal)) {
							chVal = null;
						}
					} else if ($.inArray(name, ["target", "layer"]) != -1) {
						if (options.joinSelectableTarget === true) {
							isJoinSelectable = true;
						} else {
							chVal = null;
						}
					} else if (name == "joinSelectableEvent") {
						evtSelectable = val;
						chVal = null;
					}

					if (chVal) {
						options[name] = chVal;
						changeOptionWork(name);
						isSet = true;
					}
				}

				return isSet;
			};
			// 옵션값 변경에 따른 추가 작업 수행하기
			var changeOptionWork = function(name) {
				switch (name) {
					case "containmentDetails" :
						_this.getContainDetail();
						break;
				}
			};

			if (arguments.length == 0) {
				reVal = Util.cloneObject(options);
			} else if (arguments.length == 1) {
				if (typeof(arguments[0]) == "object") {
					var key = null
					, items = arguments[0];
					reVal = false;

					for (key in items) {
						if (setOptionVal(key, items[key])) {
							reVal = true;
						}
					}
				} else {
					reVal = getOptionVal(optName);
				}
			} else {
				reVal = setOptionVal(optName, value);
			}

			if (isJoinSelectable === true && evtSelectable) {
				this.doDraggableDown(evtSelectable);
			}

			return reVal;
		};
	};

	return onMouseDraggable;
});