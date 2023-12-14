define([
	"jquery",
	"commonFrameJs/utils/util"
], function ($, Util) {

	var _headNode = null,
		_viewportAdded = false,
		_toolbarElement, // toolbar div
		_scrollElement, // scroll 대상이 되는 div
		_curScrollTop, // 현재 scrollTop 값
		_toolbarHeight,
		_isToolbarVisible = true,
		_scrollDiff = 0, // 현재 scroll 양
		_contentWidth, // 배율 조정 전 너비
		_contentViewWidth, // 배율 조정 이후 너비
		_viewScaleValue = 1, // 배율
		_defaultScrollBarWidth = 17,
		_scrollBarWidth,
		_contentElement,
		_fitWidthMode = false;

	function _getHeadNode() {
		if (!_headNode) {
			_headNode = document.getElementsByTagName("head")[0];
		}

		return _headNode;
	}

	/**
	 * 최소, 최대값 제한 범위에 넘어서는 경우 변경해서 return
	 * @param {Number} scaleValue
	 * @returns {Number}
	 */
	function getValidScaleValue(scaleValue) {
		if (!scaleValue || scaleValue < 0.3) {
			scaleValue = 0.3;
		} else if (scaleValue > 2) {
			scaleValue = 2;
		} else {
			scaleValue = Util.getRoundNumber(scaleValue, 3);
		}

		return scaleValue;
	}

	/**
	 * styleScaleValue 값에 맞게 scale 값 지정 (1인경우 제거)
	 * @param {Number} styleScaleValue
	 * @author <a href="mailto:igkang@hancom.com">강인구</a>
	 */
	function _setScalingStyleValue(styleScaleValue) {
		if (!_contentElement) {
			return;
		}

		var styleProp = _contentElement.style;

		styleScaleValue = getValidScaleValue(styleScaleValue);

		if (styleScaleValue === 1) {
			styleProp.removeProperty("transform-origin");
			styleProp.removeProperty("transform");
			styleProp.removeProperty("overflow-y");

		} else {
			styleProp.setProperty("transform-origin", "left top");
			styleProp.setProperty("transform", "scale(" + styleScaleValue + ")");
			styleProp.setProperty("overflow-y", "visible");
		}
	}

	/**
	 * 지정한 영역의 너비가 device-width 보다 커지는 경우, maxContentWidth 값에 맞게 축소
	 * device 너비에 맞게 scale 조정, 상위 element 에는 overflow-x hidden 처리
	 * 정상 동작 하려면 setViewContentWidth() 로 크기가 지정되어야 함.
	 * @author <a href="mailto:igkang@hancom.com">강인구</a>
	 */
	function _scalingContentDownToFitTheDeviceWidth() {
		if (!(_contentElement && _contentViewWidth)) {
			return;
		}

		var clientWidth = document.body.clientWidth,
			styleScaleValue;

		if (_fitWidthMode) {
			styleScaleValue = Util.getFloorNumber((clientWidth - _scrollBarWidth * 2) / _contentWidth, 3);
			_contentElement.style.setProperty("margin-left", _scrollBarWidth + "px");

		} else {
			styleScaleValue = _viewScaleValue;
			_contentElement.style.removeProperty("margin-left");
		}

		_setScalingStyleValue(styleScaleValue);
	}

	function _preventMultiTouchEvent(e) {
		if (e.touches && e.touches.length > 1) {
			e.preventDefault();
			return false;
		}
	}

	return {
		/**
		 * device 너비에 맞는 viewport 지정 및 scale 조정 block 처리,
		 */
		setMobileViewMode : function() {
			var metaTag,
				headNode;

			if (!_viewportAdded) {
				headNode = _getHeadNode();

				metaTag = document.createElement("meta");
				metaTag.setAttribute("name", "viewport");
				metaTag.setAttribute("content", "width=device-width, initial-scale=1.0," +
					" maximum-scale=1.0, minimum-scale=1.0, user-scalable=no");
				headNode.appendChild(metaTag);

				if (window.addEventListener) {
					window.addEventListener("touchstart", _preventMultiTouchEvent, false);
				} else if (window.attachEvent) {
					window.attachEvent("touchstart", _preventMultiTouchEvent);
				}

				_viewportAdded = true;
			}
		},

		/**
		 * scroll 하는 경우, toolbar 를 자동으로 감춰지게 하기 위한 처리 추가
		 * @param {Element} toolbarElement		  toolbar 로 사용하는 Element
		 * @param {Element} scrollElement		   scroll event 가 발생하는 Element
		 * @param {Function} callback			   조정값(px)을 인자로한 callback 등록
		 *										   callback 의 return 값 (false : 실패, true||undefined : 성공)
		 * @author <a href="mailto:igkang@hancom.com">강인구</a>
		 */
		addAutoHideToolbarEvent : function(toolbarElement, scrollElement, callback) {
			if (!(toolbarElement && scrollElement && callback)) {
				return;
			}

			_toolbarElement = toolbarElement;
			_scrollElement = scrollElement;
			_curScrollTop = _scrollElement.scrollTop;

			_scrollElement.addEventListener("scroll", function(/*e*/) {
				var afterScrollTop = _scrollElement.scrollTop,
					afterMarginValue,
					callbackReturnValue,
					curScrollDiff,
					isScrollDown;

				if (!_toolbarHeight) {
					_toolbarHeight = _toolbarElement.offsetHeight;
				}

				if (afterScrollTop < _toolbarHeight) {
					// toolbar 높이보다 적은 경우에는 무조건 보여지게 처리
					afterMarginValue = 0;
					_scrollDiff = 0;
					isScrollDown = false;

				} else {
					curScrollDiff = afterScrollTop - _curScrollTop;
					if ((curScrollDiff > 0 && _scrollDiff < 0) || (curScrollDiff < 0 && _scrollDiff > 0)) {
						// 반대 방향으로 scroll 바뀐 경우
						_scrollDiff = 0;
					}

					_scrollDiff += curScrollDiff;
					isScrollDown = (_scrollDiff > 0);

					if (isScrollDown) {
						if (_isToolbarVisible && _scrollDiff >= _toolbarHeight) {
							afterMarginValue = _toolbarHeight * -1;
						}

					} else {
						if (!_isToolbarVisible && _scrollDiff <= _toolbarHeight * -1) {
							afterMarginValue = 0;
						}
					}
				}

				if (afterMarginValue !== undefined) {
					callbackReturnValue = callback(afterMarginValue);

					if (callbackReturnValue === true || callbackReturnValue === undefined) {
						_isToolbarVisible = !isScrollDown;
					}
				}

				_curScrollTop = afterScrollTop;
			});
		},

		/**
		 * view 영역 scale 조정
		 * @param {Number} scaleValue	   0.3~2 범위 내의 실수 (배율)
		 * @param {Boolean} fitWidth		너비에 맞게 축소/확대
		 * @author <a href="mailto:igkang@hancom.com">강인구</a>
		 */
		setViewScaleValue : function(scaleValue, fitWidth) {
			var changedStyleScaleValue = false;

			scaleValue = getValidScaleValue(scaleValue);

			fitWidth = fitWidth || false;

			if (_viewScaleValue !== scaleValue) {
				// 배율 변경된 경우
				_viewScaleValue = scaleValue;
				_contentViewWidth = _contentWidth * _viewScaleValue;
				// 변경된 배율에 맞게 scale style 값 변경 필요
				changedStyleScaleValue = true;
			}

			if (_fitWidthMode !== fitWidth) {
				// 너비에맞게 설정 변경되는 경우
				if (fitWidth) {
					// 너비에 맞춰서 scale style 값 변경 필요
					changedStyleScaleValue = true;

					if (window.addEventListener) {
						window.addEventListener("resize", _scalingContentDownToFitTheDeviceWidth, false);
					} else if (window.attachEvent) {
						window.attachEvent("onresize", _scalingContentDownToFitTheDeviceWidth);
					}
					_fitWidthMode = true;

				} else {
					_setScalingStyleValue(_viewScaleValue);

					if (window.removeEventListener) {
						window.removeEventListener("resize", _scalingContentDownToFitTheDeviceWidth, false);
					} else if (window.detachEvent) {
						window.detachEvent("onresize", _scalingContentDownToFitTheDeviceWidth);
					}
					_fitWidthMode = false;
				}
			}

			if (changedStyleScaleValue) {
				_scalingContentDownToFitTheDeviceWidth();
			}
		},

		/**
		 * view 하는 content 의 너비 지정 (scale 축소를 위한 값 지정)
		 * @param {Element} contentElement
		 * @param {Number} contentWidth			content 너비 값. (px)
		 * @param {Number=} scrollBarWidth			scrollbar 너비 값. (px) 미지정시 내부 정의된 값
		 * @author <a href="mailto:igkang@hancom.com">강인구</a>
		 */
		setViewContentWidth : function(contentElement, contentWidth, scrollBarWidth) {
			_contentElement = contentElement;
			_contentWidth = contentWidth;
			_contentViewWidth = contentWidth * _viewScaleValue;
			_scrollBarWidth = scrollBarWidth || _defaultScrollBarWidth;

			if (_fitWidthMode) {
				// 너비에맞게 지정된 경우에만 scale 값 조정 필요
				_scalingContentDownToFitTheDeviceWidth();
			}
		}
	};
});