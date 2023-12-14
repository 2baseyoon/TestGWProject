//양식별 다국어 정의 부분
var localLang_ko = {
	localLangItems: {
	}
};

var localLang_en = {
	localLangItems: {
	}
};

var localLang_ja = {
	localLangItems: {
	}
};

var localLang_zh = {
	localLangItems: {
	}
};

function setWorkType(){
	CFN_CallAjax("/groupware/attendReq/getScheduleList.do", {}, function (data){ 
		var tarType = $('select[name="WORK_TYPE"]');
		$(data.list).each(function(i, v) {
			tarType.append($('<option/>', { 
				value: v.SchSeq,
				text : v.SchName,
				time : v.WorkTimeMon
			}));
			if(i == 0) {
				if(getInfo("Request.templatemode") == "Write") $('[name="lbl_worktime"]').css("margin-left","22px"); // 원래사이즈는 18px
				$('[name="_MULTI_WORK_TIME"]').val(v.WorkTimeMon);
			}
		});
		/* 2023.07.19. 이아람대리 요청
		tarType.append($('<option/>', { // 직접입력
			value: "N",
			text : Common.getDic("lbl_Mail_DirectInput"),
			style : "font-weight:bold;"
		}));
		*/
	}, false, 'json');
}

//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
	// 체크박스, radio 등 공통 후처리
	postJobForDynamicCtrl();

	//Subject 숨김처리
	//$('#tblFormSubject').hide();
	
	$("#HID_COMPANTYCODE").val(Common.getSession("DN_Code"));
	
	setWorkType();
	
	if ((typeof CFN_GetQueryString == "function" && CFN_GetQueryString("RequestFormInstID") != "undefined") || (formJson.BodyContext && formJson.BodyContext.HID_PROCESSID)) {
		$("#headname").text("근무일정 변경 신청서");
		$("#approval_view_formname").text("근무일정 변경 신청서");
	}
		
	//읽기 모드 일 경우
	if (getInfo("Request.templatemode") == "Read") {

		$('*[data-mode="writeOnly"]').each(function () {
			$(this).hide();
		});
		
		if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
			$(".chkHolidayLabel").hide(); // 모바일 체크박스 동작이 이상해서 다시그리는 것으로 변경
			XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblWorkScheduleInfo), 'json', '#tblWorkScheduleInfo', 'R');
			displayTimeForLoad();
			displayHolidayForRead(); // 모바일 체크박스 동작이 이상해서 다시그리는 것으로 변경
		} else {
			XFORM.multirow.load('', 'json', '#tblWorkScheduleInfo', 'R');
		}

		//특정 디자인 수정
		$('#SCHEDULE_REASON').removeAttr('style');
	} else {
		$('*[data-mode="readOnly"]').each(function () {
			$(this).hide();
		});

		document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt; // 재사용, 임시함에서 오늘날짜로 들어가게함.
		
		if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
			document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.dpnm, false);
			document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
			document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usnm, false);
			
			if (CFN_GetQueryString("RequestFormInstID") != "undefined") {
				$("#HID_WORK_SCHEDULE_FIID").val(CFN_GetQueryString("RequestFormInstID"));
				getWorkScheduleData();
			}else{
				if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
					XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblWorkScheduleInfo), 'json', '#tblWorkScheduleInfo', 'W');
					displayTimeForLoad();
				} else {
					XFORM.multirow.load('', 'json', '#tblWorkScheduleInfo', 'W', { minLength: 1 });
				}
			}

            if (CFN_GetQueryString("RequestProcessID") != "undefined") {
				$("#HID_PROCESSID").val(CFN_GetQueryString("RequestProcessID"));
			}
			
			if(formJson.Request.mode == "DRAFT"){
				setSubject();
			}
		}else{
			if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
				XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblWorkScheduleInfo), 'json', '#tblWorkScheduleInfo', 'W');
			} else {
				XFORM.multirow.load('', 'json', '#tblWorkScheduleInfo', 'W', { minLength: 1 });
			}
		}
	}
}

function clickHolidayLabel(thisObj){
	var idx = $(".chkHolidayLabel").index(thisObj);
	
	if($("tr.multi-period").eq(idx).find(".chkHoliday").prop("checked")){
		chkCompanyHoliday(idx);
	}
}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
	if (bTempSave) {
		return true;
	} else {
		if(document.getElementsByName("_MULTI_SCHEDULE_SDT").length <= 1){
			Common.Warning("근무 일정을 추가해 주세요.");
			return false;
		}else if($("#SCHEDULE_REASON").val() == ""){
			Common.Warning("사유를 입력해 주세요.");
			return false;
		}else{
			var chkValid = false;
			
			$("#tblWorkScheduleInfo").find(".multi-row").each(function(idx,item){
				if($(item).find("[name='_MULTI_SCHEDULE_SDT']").val() == "" || $(item).find("[name='_MULTI_SCHEDULE_EDT']").val() == "" ){
					Common.Warning("근무일정 날짜를 입력해 주세요.");
					chkValid = true;
					return false;
				}else if($(item).find("[name='WORK_TYPE']").val() == "N"
					&& ($(item).find("[name='_MULTI_WORK_START_H']").val() == "" || $(item).find("[name='_MULTI_WORK_START_M']").val() == ""
						|| $(item).find("[name='_MULTI_WORK_END_H']").val() == "" || $(item).find("[name='_MULTI_WORK_END_M']").val() == "")
					){
					Common.Warning("근무일정 시간을 입력해 주세요.");
					chkValid = true;
					return false;
				}
			});
			
			if(chkValid) return false;
		}
	}
	
	return true;
}

function getWorkScheduleData() {
	CFN_CallAjax("/approval/legacy/getFormInstData.do", {"FormInstID":$("#HID_WORK_SCHEDULE_FIID").val()}, function (data){ 
		receiveHTTPState(data); 
	}, false, 'json');
}

function receiveHTTPState(dataresponseXML) {
	var xmlReturn = dataresponseXML.Table;
	var errorNode = dataresponseXML.error;
	if (errorNode != null && errorNode != undefined) {
		Common.Error("Desc: " + $(errorNode).text());
	} else {
		$(xmlReturn).each(function (i, elm) {
			SetData(elm.BodyContext);
		});
	}
}

function SetData(pData) {
	var jsonObj = $.parseJSON(Base64.b64_to_utf8(pData)); // xml을 json으로 변경하기
	var ones = $$(Base64.b64_to_utf8(pData)).remove("tblWorkScheduleInfo").json();
	
	// 최하위노드를 찾아서  mField에 매핑
	GetLastNode(ones);
	
	//멀티로우 Table 값 매핑
	XFORM.multirow.load(JSON.stringify(jsonObj.tblWorkScheduleInfo), "json", "#tblWorkScheduleInfo", 'W');
}

function GetLastNode(obj) {
	for(var key in obj){
		if($$(obj).find(key).valLength()>0){
			GetLastNode($$(obj).find(key).json());
		}else{
			$("[id=" + key.toUpperCase() + "]").val($$(obj).attr(key));
			$("[id=" + key.toUpperCase() + "]").text($$(obj).attr(key));
		}
	}
}

function setBodyContext(sBodyContext) {
}

function validateScheduleDate() {
}

function chkCompanyHoliday(idx) {
	var sDate = $("input[name=_MULTI_SCHEDULE_SDT]").eq(idx).val();
	var eDate = $("input[name=_MULTI_SCHEDULE_EDT]").eq(idx).val();
	var companyHoliday = "";
	
	if(sDate != "" && eDate != ""){
		sDate = new Date(sDate);
		eDate = new Date(eDate);
		
		CFN_CallAjax("/covicore/anniversary/getAnniversaryList.do", {
			"domainID": Common.getSession("DN_ID"),
			"anniversaryType": "Company",
			"startYear": new Date().getFullYear()
		}, function (data){ 
			$(data.list).each(function(i, v) {
				var solarDate = new Date(v.SolarDate);
				
				if(sDate.getTime() <= solarDate.getTime() && eDate.getTime() >= solarDate.getTime()){
					companyHoliday += v.SolarDate + ";";
				}
			});
		}, false, 'json');
		
		$(".chkHoliday").eq(idx).closest("label").find("input[name=companyHoliday]").val(companyHoliday);
	}
}

function calSDATEEDATE(obj) {
	// 현재 객채(input) 에서 제일 가까이 있는 tr을 찾음
	var tmpObj = $(obj).closest("tr");
	var len = $("#tblWorkScheduleInfo tr.multi-row").length;
	
	var m_index;
	if (obj.name == "_MULTI_SCHEDULE_EDT") {
		m_index = $("input[name=_MULTI_SCHEDULE_EDT]").index(obj);
	} else {
		m_index = $("input[name=_MULTI_SCHEDULE_SDT]").index(obj);
	}
	
	var sDate = $("input[name=_MULTI_SCHEDULE_SDT]").eq(m_index).val();
	var eDate = $("input[name=_MULTI_SCHEDULE_EDT]").eq(m_index).val();
	
	if(sDate != "" && eDate != ""){
		if(sDate > eDate){
			Common.Warning(Common.getDic("msg_StartDateCannotAfterEndDate")); // 시작일은 종료일 보다 이후일 수 없습니다.
			$("input[name=_MULTI_SCHEDULE_SDT]").eq(m_index).val("");
			$("input[name=_MULTI_SCHEDULE_EDT]").eq(m_index).val("");
		}else{
			for(var i = 1; i <= len; i++){
				if(m_index != i){
					var startDate = $("input[name=_MULTI_SCHEDULE_SDT]").eq(i).val();
					var endDate = $("input[name=_MULTI_SCHEDULE_EDT]").eq(i).val();
					
					if(((sDate >= startDate && sDate <= endDate) && (eDate >= startDate && eDate <= endDate))
							|| (sDate == startDate || sDate == endDate || eDate == startDate || eDate == endDate)
							|| (sDate <= startDate && eDate >= startDate && eDate <= endDate)
							|| (sDate >= startDate && sDate <= endDate && eDate >= endDate)
							|| (sDate <= startDate && eDate >= endDate)){
						Common.Warning("선택한 근무 일자가 기존에 지정한 일자에 포함됩니다.");
						$("input[name=_MULTI_SCHEDULE_SDT]").eq(m_index).val("");
						$("input[name=_MULTI_SCHEDULE_EDT]").eq(m_index).val("");
					}
				}
			}
		}
	}
	
	if($("input[name=_MULTI_SCHEDULE_SDT]").eq(m_index).val() != "" 
		&& $("input[name=_MULTI_SCHEDULE_EDT]").eq(m_index).val() != ""){
		if($(".chkHoliday").eq(m_index).prop("checked")){
			chkCompanyHoliday(m_index);
		}
	}

	setSubject();	
}

// 첫행 시작일자로 제목 셋팅
function setSubject(){
	var sUserName = CFN_GetDicInfo(getInfo("AppInfo.usnm"));
	if(formJson && formJson.FormInstanceInfo && formJson.FormInstanceInfo.InitiatorName) sUserName = CFN_GetDicInfo(formJson.FormInstanceInfo.InitiatorName);
	
	var sDate = $("#tblWorkScheduleInfo").find(".multi-row").eq(0).find("[name='_MULTI_SCHEDULE_SDT']").val();
	sDate = (sDate) ? sDate : "";
	if(sDate.length == 8) sDate = sDate.substring(0,4) + "-" + sDate.substring(4,6) + "-" + sDate.substring(6,8);
	var date = new Date(sDate);
	if(!isNaN(date)) $("#Subject").val($("#headname").text()+"_"+sUserName+"("+date.format('MM/dd')+")");
	else $("#Subject").val($("#headname").text()+"_"+sUserName);
}

// 근무일정에 맞는 근무시간 표시
function displayTime(obj) {
	var tmpObj = $(obj).closest("tr");
	var sTime = $(obj).find("option:selected").attr("time");
	if(sTime){
		$(tmpObj).find("[name='_MULTI_WORK_TIME']").val(sTime);
	}else{
		$(tmpObj).find("[name='_MULTI_WORK_TIME']").val("");
	}
}
// 미사용(이전 데이터를 위해 함수만 유지)
function displayTimeForLoad(){
	$(formJson.BodyContext.tblWorkScheduleInfo).each(function(idx,item){
		var targetRow = $("#tblWorkScheduleInfo").find(".multi-row").eq(idx);
		if($(targetRow).length == 1 && item.WORK_TYPE == "N"){
			$(targetRow).find("[name='div_manual']").show();
			if(getInfo("Request.templatemode") == "Write") $(targetRow).find("[name='div_manual']").css("margin-left","22px"); // 원래사이즈는 18px
		} 
	});
}

// 모바일 체크박스 동작이 이상해서 다시그리는 것으로 변경
function displayHolidayForRead(){
	$("#tblWorkScheduleInfo").find(".multi-row").each(function(idx,item){
		if(formJson.BodyContext.tblWorkScheduleInfo && formJson.BodyContext.tblWorkScheduleInfo[idx] && formJson.BodyContext.tblWorkScheduleInfo[idx].opt == "Y"){
			$(item).find(".chkHolidayLabel").after("<span>■ 회사휴무일 제외</span>");	
		}else{
			$(item).find(".chkHolidayLabel").after("<span>□ 회사휴무일 제외</span>");
		}
	});
}
					
//본문 XML로 구성
function makeBodyContext() {
   	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblWorkScheduleInfo", "rField"));
	return bodyContextObj;
}
