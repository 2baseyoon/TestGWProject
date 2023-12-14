/**
 * coviInput
 * @class coviInput
 * CommonControls.js 로 이동
 */
var coviInput = {
	init : function(){
		this.setInputPattern();
		this.setNumber();
		this.setMoney();
		this.setSwitch();
		this.setSlider();
		this.setTwinSlider();
		this.setDate();	
	},
	setInputPattern : function() {
		/* input box */
		$("input[mode=money]").each(function(){
			$(this).bindPattern({
				pattern : "money",
				allow_minus : ($(this).attr("allow_minus") == "true" ? true : false),
				max_length : parseFloat($(this).attr("max_length")),
				max_round : parseFloat($(this).attr("max_round"))
			})
		});
		$("input[mode=moneyint]").each(function(){
			$(this).bindPattern({
				pattern : "moneyint",
				max_length : parseFloat($(this).attr("max_length"))
			})
		});
		$("input[mode=number]").each(function(){
			$(this).bindPattern({
				pattern : "number",
				allow_minus : ($(this).attr("allow_minus") == "true" ? true : false),
				max_length : parseFloat($(this).attr("max_length")),
				max_round : parseFloat($(this).attr("max_round"))
			})
		});
		$("input[mode=numberint]").each(function(){
			$(this).bindPattern({
				pattern : "numberint",
				max_length : parseFloat($(this).attr("max_length"))
			})
		});
		$("input[mode=date]").each(function(){
			$(this).bindPattern({
				pattern : "date"
			})
		});
		$("input[mode=date-ymd]").each(function(){
			$(this).bindPattern({
				pattern : "date(년월일)"
			})
		});
		$("input[mode=datetime]").each(function(){
			$(this).bindPattern({
				pattern : "datetime"
			})
		});
		$("input[mode=time]").each(function(){
			$(this).bindPattern({
				pattern : "time"
			})
		});
		$("input[mode=date-slash]").each(function(){
			$(this).bindPattern({
				pattern : "date(/)"
			})
		});
		$("input[mode=datetime-ymd]").each(function(){
			$(this).bindPattern({
				pattern : "datetime(년월일)"
			})
		});
		$("input[mode=custom]").each(function(){
			$(this).bindPattern({
				pattern : "custom",
				max_length : parseFloat($(this).attr("max_length")),
				patternString : $(this).attr("patternString")
			})
		});
		$("input[mode=bizno]").each(function(){
			$(this).bindPattern({
				pattern : "bizno"
			})
		});
		$("input[mode=phone]").each(function(){
			$(this).bindPattern({
				pattern : "phone"
			})
		});
	},
	
	/* Number */
	setNumber : function(){
		$("input[kind=number]").each(function(){
			$(this).bindNumber({
				max : parseFloat($(this).attr("num_max")),
				min : parseFloat($(this).attr("num_min"))
			})
		});
	},
	
	setMoney : function(){
		$("input[kind=money]").each(function(){
			$(this).bindMoney({
				max : parseFloat($(this).attr("money_max")),
				min : parseFloat($(this).attr("money_min"))
			})
		});
	},
	
	/* Switch */
	setSwitch : function(pReadOnly){
		$("input[kind=switch]").each(function(){
			$(this).bindSwitch({
				off : ($(this).attr("off_value")),
				on : ($(this).attr("on_value")),
				readonly : pReadOnly == true ? true : false
			})
		});
	},
	
	/* Slider */
	setSlider : function(){
		$("input[kind=slider]").each(function(){
			$(this).bindSlider({
				min : parseFloat($(this).attr("slider_min")),
				max : parseFloat($(this).attr("slider_max")),
				snap : parseFloat($(this).attr("snap")),
				unit : $(this).attr("unit")
			})
		});
	},
	
	setTwinSlider : function(){
		$("input[kind=twinslider]").each(function(){
			$(this).bindTwinSlider({
				min : parseFloat($(this).attr("twslider_min")),
				max : parseFloat($(this).attr("twslider_max")),
				snap : parseFloat($(this).attr("snap")),
				unit : $(this).attr("unit"),
				separator : $(this).attr("separator")
			})
		});
	},
	
	/* Segment Method */
	/**
	 * setSegment
	 * @method setSegment
	 * @param id - HTML Element target ID
	 * @param option - 바인드될 데이터. [{optionValue:0, optionText:"왼쪽"}, ... ]
	 */
	setSegment : function(id, option){
		$("#"+id).bindSegment({
			options : option
		});
	},
	
	/**
	 * setCssSegment
	 * @method setCssSegment
	 * @param id - HTML Element target ID
	 * @param theme_name - css 파일 안에서 적용될 style name
	 * @param option - 바인드될 데이터. [{optionValue:0, optionText:"왼쪽", addClass:"type1"}, ... ]
	 * @param css_name - 사용자 지정 css 파일명. (해당 파일의 위치 url 포함)
	 */
	setCssSegment : function(id, theme_name, option, css_name){
		var head = document.getElementsByTagName('head')[0];
		var link = document.createElement('link');
		link.type = "text/css";
		link.rel = "stylesheet";
		link.href = css_name;
		
		head.appendChild(link);
		
		$("#"+id).bindSegment({
			theme : theme_name,
			options : option
		});
	},
	
	/* Selector Method */
	/**
	 * SimpleBindSelector
	 * @method SimpleBindSelector
	 * @param id - HTML Element target ID
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param option - 바인드될 데이터. [{optionValue:1, optionText:"Seoul"}, ... ]
	 * @param positionfixed - expandBox position CSS 를 fixed 할지 여부. selector 가 fixed 된 엘리먼트 위에 위치하는 경우 사용. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param finder - finder 버튼 사용 여부. [true | false]
	 * @param finder_onclick - finder 버튼 클릭 이벤트 함수
	 */
	SimpleBindSelector : function(id, appendable, option, positionfixed, direction, finder, finder_onclick){
		
		if(finder == true){
			$("#"+id).bindSelector({
				appendable : appendable,
				options : option,
				positionFixed : positionfixed,
				direction : direction,
				finder : {
					onclick: function(){
						var fn = new Function(finder_onclick);
						fn();
					}
				}
			});
		}else{
			$("#"+id).bindSelector({
				appendable : appendable,
				options : option,
				positionFixed : positionfixed,
				direction : direction
			});
		}
	},
	
	/**
	 * AjaxBindSelector
	 * @method AjaxBindSelector
	 * @param id - HTML Element target ID
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param positionfixed - expandBox position CSS 를 fixed 할지 여부. selector 가 fixed 된 엘리먼트 위에 위치하는 경우 사용. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param url - AJAX 데이터 호출 URL
	 * @param param - AJAX 데이터 호출 URL 파라미터
	 */
	AjaxBindSelector : function(id, appendable, positionfixed, direction, url, param){
		$("#"+id).bindSelector({
			appendable: appendable,
			positionFixed : positionfixed,
			direction : direction,
			ajaxUrl : url,
			ajaxPars: param
		});
	},
	
	/**
	 * MultiSelector
	 * @method MultiSelector
	 * @param id - HTML Element target ID
	 * @param options - 바인드될 데이터. [{name:"opt1", width:200, options:[{optionValue:1, optionText:"Seoul"}, ... ]}, ... ]
	 */
	MultiSelector : function(id, options){
		var myMultiSelector = new AXMultiSelector();
		myMultiSelector.setConfig({
			targetID : id,
			optionGroup: options
		});
	},
	
	/**
	 * UserBindSelector
	 * @method UserBindSelector
	 * @param id - HTML Element target ID
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param positionfixed - expandBox position CSS 를 fixed 할지 여부. selector 가 fixed 된 엘리먼트 위에 위치하는 경우 사용. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param optionvalue - 바인드된 데이터의 사용자 지정 value 명
	 * @param optiontext - 바인드된 데이터의 사용자 지정 text 명
	 * @param opion - 바인드될 데이터. [{CD:1, NM:"Seoul"}, ... ]
	 */
	UserBindSelector : function(id, appendable, positionfixed, direction, optionvalue, optiontext, option){
		$("#"+id).bindSelector({
			positionFixed : positionfixed,
			direction : direction,
			reserveKeys: {
				optionValue: optionvalue,
				optionText : optiontext
			},
			appendable : appendable,
			onsearch : function(objID, objVal, callBack) {
				setTimeout(function(){
					callBack({
						options: option
					});
					// return {options : option}
				}, 100);
			}
		});
	},
	
	/* TagSelector Method */
	/**
	 * SimpleBindTagSelector
	 * @method SimpleBindTagSelector
	 * @param id - HTML Element target ID
	 * @param opion - 바인드될 데이터. [{optionValue:1, optionText:"Seoul"}, ... ]
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param selectorWidth - selectorWidth 값이 없으면 인풋의 너비를 이용.
	 * @param optionValue_hname - 태그가 추가될 때 생성되는 optionValue input hidden name값
	 * @param optionText_hname - 태그가 추가될 때 생성되는 optionText input hidden name값
	 */
	SimpleBindTagSelector : function(id, option, appendable, direction, selectorWidth, optionValue_hname, optionText_hname){
		$("#"+id).bindTagSelector({
			appendable : appendable,
			direction : direction,
			selectorWidth: selectorWidth,
			optionValue_inputName: optionValue_hname,
			optionText_inputName: optionText_hname,
			options: option
		});
	},
	
	/**
	 * AjaxBindTagSelector
	 * @method AjaxBindTagSelector
	 * @param id - HTML Element target ID
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param url - AJAX 데이터 호출 URL
	 * @param param - AJAX 데이터 호출 URL 파라미터
	 */
	AjaxBindTagSelector : function(id, appendable, direction, url, param){
		$("#"+id).bindTagSelector({
			appendable : appendable,
			direction : direction,
			ajaxUrl : url,
			ajaxPars : param
		});
	},
	
	/**
	 * UserBindTagSelector
	 * @method UserBindTagSelector
	 * @param id - HTML Element target ID
	 * @param opion - 바인드될 데이터. [{VL:1, TX:"Seoul"}, ... ]
	 * @param appendable - option에 정해진 값 외의 입력 가능 여부. [true | false]
	 * @param direction - expandBox의 위/아래 열리는 방향을 지정. 기본값은 ""이며 "bottom"을 사용하는 경우 expandBox의 방향이 밑에서 위로 열리게 됨
	 * @param selectorWidth - selectorWidth 값이 없으면 인풋의 너비를 이용.
	 * @param optionValue_hname - 태그가 추가될 때 생성되는 optionValue input hidden name값
	 * @param optionText_hname - 태그가 추가될 때 생성되는 optionText input hidden name값
	 * @param optionvalue - 바인드된 데이터의 사용자 지정 value 명
	 * @param optiontext - 바인드된 데이터의 사용자 지정 text 명
	 */
	UserBindTagSelector : function(id, option, appendable, direction, selectorWidth, optionValue_hname, optionText_hname, optionvalue, optiontext){
		$("#"+id).bindTagSelector({
			appendable : appendable,
			direction : direction,
			selectorWidth: selectorWidth,
			optionValue_inputName: optionValue_hname,
			optionText_inputName: optionText_hname,
			 reserveKeys: {
				 optionValue: optionvalue,
				 optionText: optiontext
			 },
			onsearch: function(objID, kword, callBack){
				callBack(option);
				/*
				return option;
				*/
			}
		});
	},
	
	/* Validator Method */
	/**
	 * setValidator
	 * @method setValidator
	 * @param formname - validation이 적용될 form name
	 * @param required_msg - 필수체크할 경우 나타나는 alert창의 메시지
	 * @return [true | false] - validation check를 했을 때 잘못된 input 이 있을 경우 false를 반환
	 */
	setValidator : function(formname, required_msg){
		var objValidator = new AXValidator();
		objValidator.setConfig({
			targetFormName : formname
		});
		if(required_msg == undefined) {
			required_msg = "은(는) 필수 입력값입니다.";
		 }
		
		var alertmsg = "";
		var validateResult = objValidator.validate();
		if (!validateResult) {
			
			AXConfig.AXValidator.validateErrMessage.required = objValidator.getErrorElement()[0].name + required_msg;
			alertmsg = objValidator.getErrorMessage();
			
			AXUtil.alert(alertmsg);
			objValidator.getErrorElement().focus();
			
			return false;
		}else{
			return true;
		}
	},
	
	/* Date */
	setDate : function(){
		$("input[kind=date]").each(function(){
			$(this).bindDate({
				align : $(this).attr("date_align"),
				valign : $(this).attr("date_valign"),
				separator : $(this).attr("date_separator"),
				selectType : $(this).attr("date_selectType"),
				defaultSelectType: $(this).attr("date_defaultSelectType"),
				defaultDate : $(this).attr("defaultDate"),
				minDate : $(this).attr("minDate"),
				maxDate : $(this).attr("maxDate"),
				onBeforeShowDay : function(date){
					var fn = new Function("date", "return "+$("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay"));
					return fn(date);
				}
			});
			if($(this).attr("vali_early") == "true"){
				$(this).setConfigInput({
					onChange:{
						earlierThan:$(this).attr("vali_date_id"), err:"시작일을 종료일의 이전으로 선택하세요"
	                }
				});
			}else if($(this).attr("vali_late") == "true"){
				$(this).setConfigInput({
					onChange : {
	                    laterThan:$(this).attr("vali_date_id"), err:"종료일을 시작일의 이후로 선택하세요"
	                }
				});
			}
		});
		
		$("input[kind=datetime]").each(function(){
			$(this).bindDateTime({
				align : $(this).attr("date_align"),
				valign : $(this).attr("date_valign"),
				separator : $(this).attr("date_separator"),
				selectType : $(this).attr("date_selectType"),
				defaultSelectType: $(this).attr("date_defaultSelectType"),
				defaultDate : $(this).attr("defaultDate"),
				minDate : $(this).attr("minDate"),
				maxDate : $(this).attr("maxDate"),
				onBeforeShowDay : function(date){
					var fn = new Function("date", "return "+$("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay"));
					return fn(date);
				}
			});
			if($(this).attr("vali_early") == "true"){
				$(this).setConfigInput({
					onChange:{
						earlierThan:$(this).attr("vali_date_id"), err:"시작일을 종료일의 이전으로 선택하세요"
	                }
				});
			}else if($(this).attr("vali_late") == "true"){
				$(this).setConfigInput({
					onChange : {
	                    laterThan:$(this).attr("vali_date_id"), err:"종료일을 시작일의 이후로 선택하세요"
	                }
				});
			}
		});
		$("input[kind=twindate]").each(function(){
			$(this).bindTwinDate({
				startTargetID : $(this).attr("date_startTargetID"),
				align : $(this).attr("date_align"),
				valign : $(this).attr("date_valign"),
				separator : $(this).attr("date_separator"),
				selectType : $(this).attr("date_selectType"),
				defaultSelectType: $(this).attr("date_defaultSelectType"),
				defaultDate : $(this).attr("defaultDate"),
				minDate : $(this).attr("minDate"),
				maxDate : $(this).attr("maxDate"),
				buttonText : $(this).attr("date_buttonText"),
				onBeforeShowDay : function(date){
					var fn = new Function("date", "return "+$("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay"));
					return fn(date);
				}
			})
		});
		$("input[kind=twindatetime]").each(function(){
			$(this).bindTwinDateTime({
				startTargetID : $(this).attr("date_startTargetID"),
				align : $(this).attr("date_align"),
				valign : $(this).attr("date_valign"),
				separator : $(this).attr("date_separator"),
				selectType : $(this).attr("date_selectType"),
				defaultSelectType: $(this).attr("date_defaultSelectType"),
				defaultDate : $(this).attr("defaultDate"),
				minDate : $(this).attr("minDate"),
				maxDate : $(this).attr("maxDate"),
				buttonText : $(this).attr("date_buttonText"),
				onBeforeShowDay : function(date){
					var fn = new Function("date", "return "+$("#"+this.config.targetID.split("_")[2]).attr("onBeforeShowDay"));
					return fn(date);
				}
			})
		});
	}
};

$(window).load(function(){
	/*
	 * bind 되는 시점 상의 문제가 있음
	 * 먼저 bind되어 버리면 위치가 뒤로 밀림
	 * 임시로 지연 로드 시켜 봄
	 * */
	
	setTimeout(function() { coviInput.init(); }, 500);
	//coviInput.init();
	
	
	/*
	coviInput.setInputPattern();
	coviInput.setNumber();
	coviInput.setMoney();
	coviInput.setSwitch();
	coviInput.setSlider();
	coviInput.setTwinSlider();
	coviInput.setDate();
	*/
});