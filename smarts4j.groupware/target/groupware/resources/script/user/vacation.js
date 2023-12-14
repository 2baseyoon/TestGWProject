/* 프로그램 저작권 정보
//이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
//(주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
//(주)코비젼의 지적재산권 침해에 해당됩니다.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
//You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
//as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
//owns the intellectual property rights in and to this program.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
*/

var vacation = {
	bindDateFieldEvent: function(selector){
		var $this = this;
		
		$(selector).css("cursor", "pointer")
					   .hover(function(){
						   $(this).css("text-decoration", "underline");
						   $(this).attr("title", Common.getDic("lbl_Edit"));		//수정
					   }, function() {
					       $(this).css('text-decoration','none');
					   })
					   .click(function(){
						   $this.bindDateInput(this);
					   });
	},
	bindDateInput: function(targetObj){
		if($("span[isEdit=Y]").length < 1 && $(targetObj).attr("isEdit") != "Y"){
			var originDate = this.changeDateFormat($(targetObj).text(), false); 
			
			var inputEle = $("<input/>", { attr: {disabled: "disabled"}, css :{ width : "80px"}});
			
			$(targetObj).html(inputEle)
						.attr("isEdit", "Y");
			
			this.bindEventDateInput(originDate);
		}
	},
	bindEventDateInput: function(originDate){
		var $this = this;
		
		$("span[isEdit=Y] input").datepicker({
			dateFormat: 'yy.mm.dd',
			changeMonth: true, // 월을 바꿀수 있는 셀렉트 박스를 표시한다.
			changeYear: true, // 년을 바꿀 수 있는 셀렉트 박스를 표시한다.
		    showOn: 'button',
		    buttonText : 'calendar',
		    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
            buttonImageOnly: true,
            onSelect: function(dateText, inst) {
            	var parentObj =  $(this).parent();
            	var key = parentObj.attr("name")
            	var isBaseDate = parentObj.hasClass(empType + 'BaseDate');
            	
            	parentObj.attr("isEdit", "N");
            	parentObj.html($this.changeDateFormat(dateText, true))       	
            	
            	if(dateText != inst.lastVal){
            		$this.saveDate(key, dateText);
            		if(isBaseDate){
            			$this.getVacationInfo(strToDate(dateText).format("yyyyMMdd"));
            		}
            	}
			}
		}).datepicker('setDate', originDate);
	},
	/*reverse: true/false 
	true -  yyyy.MM.dd → yyyy년 MM월 dd일
	false -  yyyy년 MM월 dd일 → yyyy.MM.dd*/
	changeDateFormat : function(strDate, reverse){
		var chkLength = (reverse ? 10 : 13); 
		
		if(strDate == undefined || strDate == "" || strDate.length != chkLength){
			return "";
		}
		var strSplit = (reverse ? '.' : ' ');
		var arrDate = strDate.split(strSplit);
		
		var year = arrDate[0].substr(0,4)
		var month = arrDate[1].substr(0,2)
		var day = arrDate[2].substr(0,2)
		
		if(reverse){
			return String.format("{0}년 {1}월 {2}일", year, month, day);
		}else{
			return String.format("{0}.{1}.{2}", year, month, day)
		}
	},
	saveDate: function(pKey, pValue){
		var usePlan;
		var dateObj = {};
		
		if(vacPlan != ''){
			usePlan = vacPlan;
		}else{
			usePlan = new Object();
			usePlan.year = year;
			usePlan.urCode = urCode;
		}
		
		
		if(usePlan[formType] == undefined) usePlan[formType] = {};
		if(usePlan[formType][empType] == undefined) usePlan[formType][empType] = {};
		if(usePlan[formType][empType]["date"] != undefined){
			dateObj = usePlan[formType][empType]["date"];
		}
		dateObj[pKey] = pValue;
		usePlan[formType][empType]["date"] = dateObj;
		
		if(usePlan.months == undefined)	usePlan.months = [];
		if(usePlan.months2 == undefined) usePlan.months2 = []; 
		if(usePlan.months3 == undefined) usePlan.months3 = []; 
		
		$.ajax({
			type : "POST",
			contentType : 'application/json; charset=utf-8',
			data : JSON.stringify(usePlan),
			url : "/groupware/vacation/insertVacationUsePlan.do",
			success:function (data) {
				if(data.status != 'SUCCESS') {
					Common.Warning("<spring:message code='Cache.msg_apv_030' />");
	          	}
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
	},
	bindSavedDate: function(vacPlan){
		if(vacPlan == ''){
			return;
		}
		
		var dateObj =  $$(vacPlan).find(formType + " " + empType + " date");
		
		if(dateObj.length > 0){
			dateObj = dateObj.json();
			for(var key in dateObj) {
				$(".dateField[name='"+key+"']").text(this.changeDateFormat(dateObj[key],true));
			}
		}
	},
	bindSavedPlan: function(vacPlan, offDaysArr){
		var $this = this;

		if(vacPlan == ''){
			return;
		}
		
		var months = $$(vacPlan).find(formType + " " + empType + " months");
		var monthDay = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		
		if (months.concat().length > 0) {
			$.each(months.json(), function(i, v) {
 				var month = v.month;
 				var vacPlan = v.vacPlan;
 				var text = "";
				$.each(vacPlan, function(i, v) {
					var startDate = v.startDate;
					var endDate = v.endDate;
					//20210726 nkpark
					var diffDay = $this.calcWorkingDate(strToDate(startDate), strToDate(endDate), offDaysArr);
					//-->
						//Math.ceil( (strToDate(endDate) - strToDate(startDate)) / (1000*60*60*24) ) + 1;
					
					if(v.hasOwnProperty("isOff") && v.isOff){ // 반차
						diffDay /= 2;
					}
					
					if (text != "") text += ", ";
					if (startDate == endDate) {
						text += startDate;
					} else {
						text += v.startDate + "~" + endDate.substr(endDate.length - 2);
					}
					
					monthDay[month.number()-1] += diffDay;
				});
 				
				var tdObj = $("td[name='monthTd'][month='" + month + "']") 				
				
				if($(tdObj).html() != ""){
					text = ($(tdObj).html() + ", " + text);
				}
				
				$(tdObj).html(text);
			});
			
			$(monthDay).each(function(idx,cnt){
				if(cnt != 0){
					$("td[name='monthCntTd'][month='" + (idx+1) + "']").html(cnt);
				}
			});
			
		}
	},
	bindSavedPlanV2: function(vacPlan, offDaysArr){
		var $this = this;

		if(vacPlan == ''){
			return;
		}

		var months = $$(vacPlan).find(formType + " " + empType + " months");
		var monthDay = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

		if (months.concat().length > 0) {
			$.each(months.json(), function(i, v) {
				var month = v.month;
				var vacPlan = v.vacPlan;
				var text = "";
				var year = "";
				$.each(vacPlan, function(i, v) {
					var startDate = v.startDate;
					var endDate = v.endDate;
					text = "";
					year = new Date(startDate.replace(".","/").replace(".","/")).getFullYear();
					var tdObj = $("td[name='monthTd'][month='" + month + "'][year='"+year+"']");
					var tdObjCnt = $("td[name='monthCntTd'][month='" + month + "'][year='"+year+"']");
					var cnt = Number($(tdObjCnt).html());
					//20210726 nkpark
					var diffDay = $this.calcWorkingDate(strToDate(startDate), strToDate(endDate), offDaysArr);
					//-->
					//Math.ceil( (strToDate(endDate) - strToDate(startDate)) / (1000*60*60*24) ) + 1;

					if(v.hasOwnProperty("isOff") && v.isOff){ // 반차
						diffDay /= 2;
					}

					if (text != "") text += ", ";
					if (startDate == endDate) {
						text += startDate;
					} else {
						text += v.startDate + "~" + endDate.substr(endDate.length - 2);
					}

					if($(tdObj).html() != ""){
						text = ($(tdObj).html() + ", " + text);
					}
					$(tdObj).html(text);

					$(tdObjCnt).html(cnt+diffDay);
				});


			});

		}
	},
	getVacationCreateMethodConfigVal : function(){
		var CreateMethod = "";
		$.ajax({
			type : "POST",
			url : "/groupware/vacation/getVacationConfigVal.do",
			data: {
				getName: "CreateMethod"
			},
			async:false,
			success:function (data) {
				if(data.status == 'SUCCESS') {
					if(data.data!=null && data.data!=""){
						CreateMethod = data.data;
					}
				} else {
					Common.Warning("<spring:message code='Cache.msg_apv_030' />");
				}
			},
			error:function(response, status, error) {
				CFN_ErrorAjax(url, response, status, error);
			}
		});
		return CreateMethod;
	}
	, getVacationInfo: function(pTermDate, pEmpType){
		if(pTermDate == undefined || pTermDate.length != 8){
			return;
		}
		if (pEmpType == undefined){
			pEmpType ="normal";
		}	

		var vacInfo = null;
		
		$.ajax({
			type : "POST",
			async : false,
			data : {
				year : pTermDate.substr(0,4),
				urCode : urCode,
				termDate : pTermDate,
				empType: pEmpType
			},
			url : "/groupware/vacation/getUserVacationInfo.do",
			success:function (list) {
				vacInfo = list.list[0];
				
				if(vacInfo != undefined){
					$("span[name='ownDays']").text(vacInfo.OWNDAYS);
					$("span[name='useDays']").text(vacInfo.USEDAYS);
					$("span[name='remindDays']").text(vacInfo.REMINDDAYS);
					
					remindDays = vacInfo.REMINDDAYS;
				}
				
			},
			error:function(response, status, error) {
				CFN_ErrorAjax("/groupware/vacation/getUserVacationInfo.do", response, status, error);
			}
		});
		
		return vacInfo;
	},
	getVacationInfoV2: function(pTermDate, pEmpType){
		if(pTermDate == undefined || pTermDate.length != 8){
			return;
		}
		if (pEmpType == undefined){
			pEmpType ="normal";
		}

		var vacInfo = null;

		$.ajax({
			type : "POST",
			async : false,
			data : {
				year : pTermDate.substring(0,4),
				urCode : urCode,
				//termDate : pTermDate,
				empType: pEmpType
			},
			url : "/groupware/vacation/getUserVacationInfoV2.do",
			success:function (list) {
				vacInfo = list.list[0];

				if(vacInfo != undefined){
					$("span[name='ownDays']").text(vacInfo.OWNDAYS);
					$("span[name='useDays']").text(vacInfo.USEDAYS);
					$("span[name='remindDays']").text(vacInfo.REMINDDAYS);

					remindDays = vacInfo.REMINDDAYS;
				}

			},
			error:function(response, status, error) {
				CFN_ErrorAjax("/groupware/vacation/getUserVacationInfo.do", response, status, error);
			}
		});

		return vacInfo;
	},
	openVacationUsePlanDetailPopup: function(){
		Common.open("","vacationUsePlanDetailPopup", Common.getDic("lbl_apv_AnnaulUseTerm"), "/groupware/vacation/goVacationUsePlanDetailPopup.do?year="+year+"&urCode="+urCode+"&time=2020&formType="+formType+"&empType="+empType+"&viewType="+viewType+"&rangeDateFrom="+rangeDateFrom+"&rangeDateTo="+rangeDateTo+"&CreateMethod="+CreateMethod,"794px","530px","iframe",true,null,null,true);
		//CFN_OpenWindow("/groupware/vacation/goVacationUsePlanDetailPopup.do?year="+year+"&urCode="+urCode+"&time=2020&formType="+formType+"&empType="+empType, "", 800, 500, "resize");
	},
	calcWorkingDate: function(sdate, edate, offDaysArr) {//날짜 범위내 근무 스케쥴 정보와 비교 하여 휴일 카운팅 처리
		var date1 = new Date(sdate);
		var date2 = new Date(edate);
		//alert(offDaysArr);
		var count = 0;
		while(true) {
			var temp_date = date1;
			if(temp_date.getTime() > date2.getTime()) {
				break;
			} else {
				var month = date1.getMonth()+1;
				if(month<10){
					month = "0"+month;
				}
				var day = date1.getDate();
				if(day<10){
					day = "0"+day;
				}
				var checkDate = date1.getFullYear()+""+month+""+day;
				if(offDaysArr[checkDate]!="HOL"){//업무 스케쥴 정보 기준 근무일 일때만 휴가 카운트 처리
					count++;
				}
				temp_date.setDate(date1.getDate() + 1);
			}
		}
		return count;

	}


}
