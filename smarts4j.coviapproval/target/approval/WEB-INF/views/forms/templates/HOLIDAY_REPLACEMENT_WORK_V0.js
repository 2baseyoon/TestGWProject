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


//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        //<!--loadMultiRow_Read-->

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        //<!--AddWebEditor-->
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
            document.getElementById("USER2").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("DEPT2").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            $("#UserCode").val(m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false));
            $("#CompanyCode").val(m_oFormMenu.getLngLabel(getInfo("AppInfo.etid"), false));
			if(formJson.Request.mode == "DRAFT"){
				setSubject();	
			}
        }

        //<!--loadMultiRow_Write-->
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
        // 필수 입력 필드 체크
        return EASY.check().result;
    }
}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    return bodyContextObj;
}

//조직도 팝업
var objTr;
function OpenWinEmployee(obj) {
	objTr = $("#rest");
/*	$(objTr).find("input[id=GROUP]").val("");
	$(objTr).find("input[id=CLASS]").val("");
	$(objTr).find("input[id=SABUN]").val("");
	$(objTr).find("input[id=NAME]").val("");*/
	
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B1", "조직도", 1000, 580, "");
}

function Requester_CallBack(pStrItemInfo) {
	var oJsonOrgMap = $.parseJSON(pStrItemInfo);
	
	$.each(oJsonOrgMap.item, function(i, v) {
		$(objTr).find("input[id=AGENCY]").val(CFN_GetDicInfo(v.DN));	
	});
}

// 선택한 날짜에 근무가 설정되어 있는지 체크
function attendDayJobCheck(obj) {
    var userCode = $("#UserCode").val();
    var userName = $("#USER2").val();
    var companyCode = $("#CompanyCode").val();
    var targetDate = $("#AlternativeHolidayDate").val();

    CFN_CallAjax("/approval/legacy/attendDayJobCheck.do", {"UserCode":userCode, "CompanyCode":companyCode, "TargetDate":targetDate}, function (data){
        if(data.status == "SUCCESS"){
            var checkJob = data.checkJob;

            if(checkJob == 0) {
                $(obj).val("");

                Common.Warning(userName + "님은 '" + targetDate + "'에 근무가 설정되어 있지 않습니다.\n 지정일은 근무가 설정되어 있는 날만 가능합니다.");
            }
            setSubject();
        } else{
            Common.Warning("오류가 발생했습니다.");
            return false;
        }
    }, false, 'json');
}

// 휴무일 체크
function checkHolidayOne(obj) {
    var userCode = $("#UserCode").val();
    var userName = $("#USER2").val();
    var companyCode = $("#CompanyCode").val();
    var targetDate = $("#HolidayDate").val();

    CFN_CallAjax("/approval/legacy/attendanceHolidayCheckOne.do", {"UserCode":userCode, "CompanyCode":companyCode, "TargetDate":targetDate}, function (data){
        if(data.status == "SUCCESS"){
            var isHoliday = data.isHoliday.split("/")[0];

            if(isHoliday != "H") {
                $(obj).val("");
                Common.Warning(userName + "님은 '" + targetDate + "'에 휴무가 아닙니다.");
            }
			setSubject();
        } else{
            Common.Warning("오류가 발생했습니다.");
            return false;
        }
    }, false, 'json');
}

// 휴일근무일자로 제목 셋팅
function setSubject(pDate){
	var sUserName = CFN_GetDicInfo(getInfo("AppInfo.usnm"));
	if(formJson && formJson.FormInstanceInfo && formJson.FormInstanceInfo.InitiatorName) sUserName = CFN_GetDicInfo(formJson.FormInstanceInfo.InitiatorName);
	
	var sDate = (pDate) ? pDate : $("#HolidayDate").val();
	var rDateVal = $("#AlternativeHolidayDate").val();

	if(sDate != "" && rDateVal != "") {
		if(sDate.length == 8) sDate = sDate.substring(0,4) + "-" + sDate.substring(4,6) + "-" + sDate.substring(6,8);
		var date = new Date(sDate);
	
		if(rDateVal.length == 8) {
			rDateVal = rDateVal.substring(0,4) + "-" + rDateVal.substring(4,6) + "-" + rDateVal.substring(6,8);
		}
		var rDate = new Date(rDateVal);
	
		//(8/20(일) <-> 8/21(월))
		
		let dayOfWeek_H = date.getDay();
		let dayOfWeek_R = rDate.getDay();
		//0:일, 1:월, 2:화, 3:수, 4:목, 5:금, 6:토
		
		var lang = Common.getSession('lang');
    	let dayNames = {
			"ko" : ["일", "월", "화", "수", "목", "금", "토"],
			"en" : ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
		}
    	var h_dow = dayNames[lang][dayOfWeek_H];
    	var r_dow = dayNames[lang][dayOfWeek_R];
		$("#Subject").val(CFN_GetDicInfo(getInfo("FormInfo.FormName"))+"_"+sUserName + "(" + date.format('MM/dd') + "(" + h_dow+ ") <-> " + rDate.format('MM/dd') + "(" + r_dow + "))");
	}else{
		$("#Subject").val(CFN_GetDicInfo(getInfo("FormInfo.FormName"))+"_"+sUserName);
	}
}
