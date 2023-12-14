//양식별 다국어 정의 부분
var localLang_ko = {
    localLangItems: {
		startDate : "시작일",
		date : "날짜"
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

const HIDDEN_CLASS = "hidden";
const VACATION_TABLE = "tblVacInfo";
var targetVacArr = new Array();
var vacationKindData = null;
var dayOffList;
	
//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
	
    loadVacationInfo();
    // 휴가 타입 셀렉트박스 옵션 추가
    makeVacationTypeSelect();

    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
	getUserDayOffDate();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });

		$("[name=VACATION_OFF_TYPE]").removeClass(HIDDEN_CLASS);

        //<!--loadMultiRow_Read-->
        if(typeof formJson.BodyContext[VACATION_TABLE] != 'undefined'){
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext[VACATION_TABLE]), 'json', '#' + VACATION_TABLE, 'R');
        }else{
			XFORM.multirow.load('', 'json', '#' + VACATION_TABLE, 'R');
        }

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        //<!--AddWebEditor-->

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
            document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt; // 재사용, 임시함에서 오늘날짜로 들어가게함.
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false);
            document.getElementById("approval_write_Subject").value = mobile_comm_getDicInfo(getInfo("AppInfo.usnm")) + " - " + mobile_comm_getDicInfo(getInfo("FormInfo.FormName"));
            mobile_approval_changeSelectBox($("#approval_write_Subject"));

            getData();

            // 세션 정보에 휴대폰 정보가 생기면 최초 로딩 시 값 자동 세팅되도록 추가 필요
        }


        //<!--loadMultiRow_Write-->
        if(JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext[VACATION_TABLE] != 'undefined'){
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext[VACATION_TABLE]), 'json', "#"+VACATION_TABLE, 'W');

            // 모바일 내 멀티로우 체크박스 사용을 위한 처리
            mobile_approval_setMultiCheckAndRadio();
        }else{
            XFORM.multirow.load('', 'json', "#"+VACATION_TABLE, 'W', { minLength: 1 });
        }

        $("#approval_write_Subject").attr("readonly", "readonly");
    }
        
    if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
	    $("#"+ VACATION_TABLE+" tr").each(function(idx, row){
			if($(row).hasClass("multi-row") && $(row).find("select[name=VACATION_TYPE]").length > 0){
		    	var changeRow = $("#"+VACATION_TABLE).find("tr:nth-child(n+"+(idx+1)+"):nth-child(-n+"+(idx+5)+")");
				setRowFieldsForVacationType(changeRow);
			}
		});
	} else {
		$("#"+ VACATION_TABLE+" tr.multi-row select[name='VACATION_TYPE']").each(function(){
			initRowforVacationTypeChanged(this)
		});
	}

}

function getUserDayOffDate() {
	$.ajax({
		url: "/groupware/attendHolidaySts/getUserDayOffDate.do",
		type: "GET",
		data: {},
		success: function(result) {
			if (result.status == "SUCCESS") {
				dayOffList = result.dayOffInfo;
			}
		}
	});
}

function makeVacationTypeSelect() {
    var useBefore = isBeforeAnnualMember();
    var tarType = $('select[name="VACATION_TYPE"]');
    var optionHtml = "";
    $.ajax({
        url : "/groupware/vacation/getUserVacTypeInfo.do",
        type: "POST",
        dataType : 'json',
        async: false,
        success:function (data) {
            var listData = data.list;
            console.log("listData.length>"+listData.length);
            if(listData.length>0){
                for(var i=0;i<listData.length;i++){
                    var isUse = listData[i].IsUse;
                    if(isUse==="N"){
                        continue;
                    }
                    var reserved1 = listData[i].Reserved1;
                    var reserved2 = listData[i].Reserved2;
                    var reserved3 = listData[i].Reserved3;
                    var listCode  = listData[i].Code;
                    var codeName  = listData[i].CodeName;
                    var groupCode = listData[i].GroupCode;
                    var groupCodeName = listData[i].GroupCodeName;
                    var multiCodeName = CFN_GetDicInfo(listData[i].MultiCodeName);
                    if(multiCodeName!==""){
                        codeName = multiCodeName;
                    }

                    if (reserved2 != "none" && !(!useBefore && reserved2 === "1") && (existUserVacationInfo(listCode, groupCode) || reserved1==="N")) { // 선연차 제외
                        console.log(listCode);
                        optionHtml += "<option value=\""+listCode+"\" reserved1=\""+reserved1+"\" reserved2=\""+reserved2+"\" reserved3=\""+reserved3+"\" groupCode=\""+groupCode+"\" groupCodeName=\""+groupCodeName+"\">"+codeName+"</option>";

                    }
                }
            }
            tarType.html(optionHtml);
        }
    });
}

function existUserVacationInfo(Code, GroupCode){
    var rtn = false;
    var jsonVacKindData = JSON.parse(vacationKindData);
    for (var i = 0; i < jsonVacKindData.length; i++) {
        if (jsonVacKindData[i].VacKind === "PUBLIC" && GroupCode === "PUBLIC") {
            rtn = true;
            break;
        }else if(jsonVacKindData[i].VacKind === Code){
            rtn = true;
            break;
        }
    }
    return rtn;
}

function isBeforeAnnualMember() {
	var useBefore = false;
    try {
    	if(Common.getBaseConfig("isUseBeforeAnnual") == "Y"){//선연차 전체(전사)사용.
   		 useBefore = true;
	   	} else{
	        if (Common.getBaseConfig("BeforeAnnualMember").indexOf(getInfo("AppInfo.usid") + ";") > -1) {
	            useBefore = true;
	        }
	         if (Common.getBaseConfig("BeforeAnnualMember").indexOf("ALL@" + ";") > -1) {
	            useBefore = true;
	        }
	
	        if (getInfo("Request.templatemode") == "Read") {
	            useBefore = true;
	        }
	   	}
    } catch (e) { mobile_comm_log(e); }
    return useBefore;

}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
	
	var datestr = "";
	$("input[name=_MULTI_VACATION_SDT]").each(function (i, sobj){
		 var sd = $(sobj).val();
		 var ed = $("input[name=_MULTI_VACATION_EDT]").eq(i).val();
		 if(sd != "" && ed != ""){
		 if (datestr != "") datestr += "/";
		 datestr += sd;
		 if (sd != ed) datestr += "~"+ed;
		 }
	});
	 
	if (datestr != "" || datestr != null) {
		document.getElementById("approval_write_Subject").value = mobile_comm_getDicInfo(getInfo("AppInfo.usnm")) + " - " + mobile_comm_getDicInfo(getInfo("FormInfo.FormName"))+" ("+datestr+")";
		mobile_approval_changeSelectBox($("#approval_write_Subject"));
	}
	
    let returnBol = true;

    if (bTempSave) {
        return true;
    } else {
        if($("input[name='_MULTI_VACATION_SDT']").length <= 1){
            alert("휴가 기간을 입력해주세요.");
            return false;
        }

        /* 사용할 연차의 연도와 휴가 신청 기간의 연도 동일 여부
        let isSame = true;
        $("[name=_MULTI_VACATION_SDT],[name=_MULTI_VACATION_EDT]").each(function () {
            if ($(this).val() != "") {
                if ($(this).val().substring(0, 4) != $("#Sel_Year").val()) {
                    isSame = false;
                    return false;
                }
            }
        });

        if (!isSame) {
            alert(mobile_comm_getDic("msg_apv_vacYearIsDifferent")); // 사용할 연차의 연도와 입력하신 기간의 연도가 상이합니다.
            return false;
        }*/

        //잔여 연차 일보다 신청 일수가 더 많을때
        const Slen = $("select[name=VACATION_TYPE]").length;
        let sValue = 0.0; //선연차, 선번차 값 구하기
        let eValue = 0.0;//반차, 연차 값 구하기
        let eCodeName = "";
        for (let i = 1; i < Slen; i++) {
        	if ($('select[name=VACATION_OFF_TYPE]').eq(i).is(':visible') && ($('select[name=VACATION_OFF_TYPE]').eq(i).val() == "" || $('select[name=VACATION_OFF_TYPE]').eq(i).val() == "0")) {
        		alert(mobile_comm_getDic("msg_enter_half_day")); //반차 종류를 입력하세요.
                return false;
            }
			const selectedOption = $('select[name=VACATION_TYPE]').eq(i).find("option:selected");
			if (selectedOption.attr("reserved1") == "Y" && (selectedOption.attr("reserved2") != null && selectedOption.attr("reserved2") != "" && selectedOption.attr("reserved2") != "min")) { //선연차, 선반차 일수 넣기
                    eCodeName += (eCodeName.indexOf(selectedOption.text()) < 0 ? selectedOption.text() + "," : "");
                    sValue += parseFloat($("input[name=_MULTI_DAYS]").eq(i).val());
            }
            if (selectedOption.attr("reserved1") == "Y" && (selectedOption.attr("reserved2") == null || selectedOption.attr("reserved2") == "" || selectedOption.attr("reserved2") == "min")) { //그 외 가감 연차 일수 넣기
                eValue += parseFloat($("input[name=_MULTI_DAYS]").eq(i).val());
            }            
        }
/*
        const _useDays = parseFloat($("#VACATION_DAY").val()); // 잔여연차.
        if (eValue > 0 && _useDays <= 0) { //
            alert(mobile_comm_getDic("msg_apv_chk_remain_vacation")); //잔여 연차일을 초과하였습니다.
            return false;
        }

        if (_useDays < eValue && _useDays > 0) { //
            alert(mobile_comm_getDic("msg_apv_chk_remain_vacation")); //잔여 연차일을 초과하였습니다.
            return false;
        }
		*/
        
		const appVacProcessCheck = Common.getBaseConfig("AppVacProcessCheck"); 
        if (appVacProcessCheck === "REJECT" && Number($("#PRC_DAYS").text()) > 0){
        	alert(mobile_comm_getDic("msg_apv_chk_remain_vac_process")); //승인대기중인 휴가신청서 완료후 상신이 가능합니다.
			return false;
        }

        /*
        // 승인대기중 연차 체크
        if(appVacProcessCheck !== "NONE"){
            var _processInfo;
            CFN_CallAjax("/approval/legacy/getVacationProcessInfo.do", {"UR_CODE":getInfo("AppInfo.usid"),"year":document.getElementById("Sel_Year").value}, function (data){
                if(data.status == "SUCCESS"){
                    _processInfo = data.vacInfo;
                }
            }, false, "json");
            if(_processInfo){
                const _processDays = Number(_processInfo["days"]);
                const _processCnt = Number(_processInfo["cnt"]);
                if(appVacProcessCheck === "SUM"){
                    // 승인대기중인 결재건의 연차일수를 합산하여 체크
                    if (_useDays < (_processDays + eValue) && _useDays > 0) {
                        alert(mobile_comm_getDic("msg_apv_chk_remain_vacation")); //잔여 연차일을 초과하였습니다.
                        return false;
                    }
                }else if(appVacProcessCheck === "REJECT"){
                    // 승인대기중인 결재건이 존재할 경우 중복기안 불가.
                    if (_processCnt > 0) {
                        alert(mobile_comm_getDic("msg_apv_chk_remain_vac_process")); //승인대기중인 휴가신청서 완료후 상신이 가능합니다.
                        return false;
                    }
                }
            }
        }
*/
        if (sValue > 0.0 && _useDays > eValue) {
            alert(mobile_comm_getDic("lbl_apv_vacation_remaining") + " [" + eCodeName.slice(0, -1) + "] " + mobile_comm_getDic("lbl_apv_vacation_remainingText"));
            //잔여 연차가 있을 경우 --- 를 선택하실 수 없습니다.
            return false;
        }

        if (document.getElementById("NUMBER").value == '') {
            alert(mobile_comm_getDic("msg_apv_chk_emergency_contact")); //비상연락처를 입력해주세요.
            return false;
        }

        if (TermCheck()) {
            if(EASY.check().result){
				returnBol = checkVacationDup(getBodyContext().BodyContext[VACATION_TABLE]);
                /*// 휴가기간이 중복되어 있는지 Validation 체크
                let tblVacInfo = getBodyContext().BodyContext[VACATION_TABLE];
                if(tblVacInfo != undefined){
                    //legacy/getVacationInfo.do
                    if(tblVacInfo.length == undefined)
                        tblVacInfo = [tblVacInfo];

					var userCode = "";
					if(formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") userCode = formJson.AppInfo.usid;
					else if(formJson.FormInstanceInfo && formJson.FormInstanceInfo.InitiatorID) userCode = formJson.FormInstanceInfo.InitiatorID;
					
                    CFN_CallAjax("/groupware/vacation/getVacationInfo.do", {"vacationInfo":JSON.stringify(tblVacInfo), "userCode" : userCode}, function (data){
                        if(data.status == "SUCCESS"){
                            const dupVac = data.dupVac;
                            if(dupVac.length > 0){
                                let messageStr = "";

                                $(dupVac).each(function(){
                                    messageStr += " '"+ this._MULTI_VACATION_SDT +" ~ "+ this._MULTI_VACATION_EDT +"',";
                                });

                                alert(mobile_comm_getDic("msg_apv_duplicateVac").format(messageStr.substring(0, messageStr.length-1)), "Warning", function(){
                                    return false;
                                });
                                returnBol = false;
                            }else{
                                returnBol = true;
                            }
                        }
                    }, false, 'json');
                }*/
            }else{
                returnBol = false;
            }
        }
        else {
            alert(mobile_comm_getDic("lbl_apv_vacation_remainingCheck"));//입력하신 기간 확인 후 기안 하시기 바랍니다.
            returnBol = false;
        }
    }

    return returnBol;
}

function checkFormForRead(){
	var tblVacInfo = formJson.BodyContext[VACATION_TABLE];
	return checkVacationDup(tblVacInfo);
}
// 휴가기간이 중복되어 있는지 Validation 체크
function checkVacationDup(tblVacInfo){
	var returnBol = true;
    if(tblVacInfo != undefined && $("#ACTIONINDEX").val() != "REJECT" && $("#ACTIONINDEX").val() != "DISAGREE"){
        //legacy/getVacationInfo.do
        if(tblVacInfo.length == undefined)
            tblVacInfo = [tblVacInfo];

		var userCode = "";
		if(formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") userCode = formJson.AppInfo.usid;
		else if(formJson.FormInstanceInfo && formJson.FormInstanceInfo.InitiatorID) userCode = formJson.FormInstanceInfo.InitiatorID;
		
        CFN_CallAjax("/groupware/vacation/getVacationInfo.do", {"vacationInfo":JSON.stringify(tblVacInfo), "userCode" : userCode}, function (data){
            if(data.status == "SUCCESS"){
                const dupVac = data.dupVac;
                if(dupVac.length > 0){
                    let messageStr = "";

                    $(dupVac).each(function(){
                        messageStr += " '"+ this._MULTI_VACATION_SDT +" ~ "+ this._MULTI_VACATION_EDT +"',";
                    });

                    alert(mobile_comm_getDic("msg_apv_duplicateVac").format(messageStr.substring(0, messageStr.length-1)), "Warning", function(){
                        return false;
                    });
                    returnBol = false;
                }else{
                    returnBol = true;
                }
            }
        }, false, 'json');
    }

	return returnBol;
}
	
function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
    let bodyContextObj = {};
    bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields(VACATION_TABLE, "rField"));
    return bodyContextObj;
}

//사용자 연차 정보 가져오기
function getData() {
    CFN_CallAjax("/groupware/vacation/getVacationData.do", {"UR_CODE":getInfo("AppInfo.usid"),"year":$("#Sel_Year").val()}, function (data){
        receiveHTTPGetData(data);
    }, false, 'json');
}

function receiveHTTPGetData(responseData) {
    const elmlist = responseData.Table;
    let vacday = "";
    let atot = "0.0";
    let appday = "";
    let appdayca = "";
    let useday = "";
    let procday = "";

    $(elmlist).each(function () {
	    vacday = this.VacDay; //총 연차
	    atot = this.RemainVacDay; //잔여연차
//	    appday = this.VacDayUse //신청연차
//	    appdayca = this.DAYSCAN //취소연차
	    useday = this.VacDayUse; //사용연차
		procday = this.VacDayProc; //승인대기중연차
    });

    if (vacday == "") {
        alert(mobile_comm_getDic("msg_apv_RegistVacDays")); //해당 년도의 연차 사용 가능 일수가 등록되지 않았습니다.\r\n관리자에게 문의하세요.

        $("#VAC_DAYS").text("0");
        $("#USE_DAYS").text("0");
    } else {
		vacday = Number(vacday);
		useday = Number(useday);
		atot = Number(atot);
        if ((vacday - useday < 0) || (atot <= 0)) {
            alert(mobile_comm_getDic("msg_apv_NoVacDaysAskAdmin")); //잔여 연차가 없습니다.\r\n관리자에게 문의 하시기 바랍니다.
        }
		const appVacProcessCheck = Common.getBaseConfig("AppVacProcessCheck");
        $("#USE_DAYS").text(atot);
        $("#VACATION_DAY").val(atot);
        if(appVacProcessCheck == "SUM" || appVacProcessCheck == "REJECT"){
            $("#PRC_DAYS").text(" "+ (Number(procday)) +"");
            $(".process_days_row").show();
            $("#process_days_row_td").attr("colspan","1");
        }else{
            $(".process_days_row").hide();
            $("#process_days_row_td").attr("colspan","3");
        }
        $("#VAC_DAYS").text(mobile_comm_getDic("lbl_apv_displayVacDaysInfo").format(vacday, useday));
    }
}


function loadVacationInfo(){
	const appVacProcessCheck = Common.getBaseConfig("AppVacProcessCheck");

    var nowYear = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss")).getFullYear();
    var params = {
        "year" : ""+nowYear,
        "schTypeSel" : "userCode",
        "schTxt" : getInfo("AppInfo.usid")
    };

    $.ajax({
        type : "POST",
        data : params,
        async: false,
        url : "/groupware/vacation/getVacationListByKind.do",
        success: function (list) {
            vacationKindData = JSON.stringify(list.list);
            $("#tblVacKind tbody").html("");
            var data = list.list;
            $.each(data, function(i, v) {
            	if ((v.VacKind=="PUBLIC" && v.CurYear == "Y") ||	v.RemainVacDay>0){
	                var row = $("<tr class='VacationRow"+(v.CurYear == "Y"?" social_timeline":"")+"' data-VacKind='"+v.VacKind+"'>")
	                    .append($("<td class=\"appforms_table_td\" style=\"text-align: center;\">").text((v.VacKind=="PUBLIC"?v.Year+" ":"")+v.VacName))
	                    .append($("<td class=\"appforms_table_td\" style=\"text-align: center;\">").text(v.VacDay))
	                    .append($("<td class=\"appforms_table_td\" style=\"text-align: center;\">").text(v.RemainVacDay+((appVacProcessCheck === "SUM" || appVacProcessCheck === "REJECT")?"("+v.VacDayProc+")":"")))
	                    .append($("<td class=\"appforms_table_td\" style=\"text-align: center;\">").text(v.ExpDate));
	
	                $("#tblVacKind tbody").append(row);
	                if (v.CurYear == "Y"){
	                    $("#Sel_Year").val(v.Year);
	                }   
                    var vacdata = {
                            "VacKind": v.VacKind
                            , "RemainVacDay": parseFloat(v.RemainVacDay)
                            , "VacDayProc": parseFloat(v.VacDayProc)
                            , "VacDay": parseFloat(v.VacDay)
                            , "ExpSdate": v.Sdate
                            , "ExpEdate": v.Edate
                        };
                    targetVacArr.push(vacdata);

            	}
            });

        },
        error:function(response, status, error) {
            CFN_ErrorAjax( "/groupware/vacation/getVacationListByKind.do", response, status, error);
        }
    });

}
//조직도에서 직무대행자 선택
function OpenWinEmployee() {
    const sUrl = "/covicore/mobile/org/list.do";

    window.sessionStorage["mode"] = "SelectUser"; //SelectUser:사용자 선택(3열-1명만),Select:그룹 선택(3열-1개만)
    window.sessionStorage["multi"] = "Y";
    window.sessionStorage["callback"] = "Requester_CallBack();";

    mobile_comm_go(sUrl, 'Y');
}

function Requester_CallBack() {
    var pStrItemInfo = '{"item":[' + window.sessionStorage["userinfo"] + ']}';
    var oJsonOrgMap = $.parseJSON(pStrItemInfo);
//    var I_User;
//    I_User = oJsonOrgMap.item[0];
//    if (I_User != undefined) {
//        if (getInfo("AppInfo.usid") != I_User.AN) {
//            $("#DEPUTY_CODE").val(I_User.UserCode);
//            $("#DEPUTY_NAME").val(mobile_comm_getDicInfo(I_User.DN));
//        } else {
//            alert(mobile_comm_getDic("msg_apv_selectdeuptyuser")); // 직무대행자로 본인이 선택되었습니다.\r\n다시 선택하세요
//        }
//    }
    
    
    var I_Users = oJsonOrgMap.item;
    if(I_Users.length > 0){
		var deputy_names = [];
		var deputy_codes = [];
		var self_selected = false;
		for(var i = 0; i < I_Users.length; i++) {
		    var I_User = oJsonOrgMap.item[i];
		
		    if(I_User != undefined){
		        if (getInfo("AppInfo.usid") != I_User.AN) {
		            deputy_names.push(mobile_comm_getDicInfo(I_User.DN));
		            deputy_codes.push(I_User.UserCode);
		        }
		        else {
					self_selected = true;
		            
		        }
		    }
		}
		
		if(self_selected === true) {
			if(I_Users.length == 1){
				alert(mobile_comm_getDic("msg_apv_selectdeuptyuser")); // 직무대행자로 본인이 선택되었습니다.\r\n다시 선택하세요
				return;
			}else if(I_Users.length > 1){
				alert('직무대행자로 본인이 포함되어 있습니다.\r\n본인은 제외됩니다.');
			}
		}
        $("#DEPUTY_CODE").val(deputy_codes.join(", "));
        $("#DEPUTY_NAME").val(deputy_names.join(", "));
//        objTxtSelect.value = CFN_GetDicInfo(deputy_names.join(", ")); // DEPUTY_NAME
//        document.getElementById("DEPUTY_CODE").value = deputy_codes.join(", "); // DEPUTY_CODE
	}
}

function isExtraType(code){
    var isExtra = false;
    for(var i=0;i<targetVacArr.length;i++){
        if(targetVacArr[i].VacKind===code){
            isExtra = true;
            break;
        }
    }
    return isExtra;
}

//연차데이터중 날짜 범위 내, 휴가유형이 매칭 되는 데이타 유무 확인
function isExistVacationData(vkind, sdate, edate){
    var rtn = 0;
    for(var j=0;j<targetVacArr.length;j++) {

        var targetVacKind = targetVacArr[j].VacKind;
        var ExpSdate = Number(targetVacArr[j].ExpSdate);
        var ExpEdate = Number(targetVacArr[j].ExpEdate);
        var isExtraTypeVal = isExtraType(vkind);
        if(targetVacKind==="PUBLIC" && isExtraTypeVal===true){
            continue;
        }
        if(targetVacKind!=="PUBLIC" && (isExtraTypeVal===false || vkind!==targetVacKind)){
            continue;
        }
        //console.log(sdate+":"+ExpSdate+" | "+edate+":"+ExpEdate)
        if(sdate>=ExpSdate && edate<=ExpEdate){
            rtn ++;
        }
    }
    //console.log("rtn:"+rtn)
    return rtn;
}


// 휴가 종류 변경에 따른 row 수정
function initRowforVacationTypeChanged(obj) {
    //var m_index = $("select[name=VACATION_TYPE]").index(obj);
//    targetVacArr = new Array();
    var trIndex = $("#"+VACATION_TABLE).find("tr").index($(obj).parents("tr").eq(0));
    var selectedOption = $(obj).find("option:selected");
    var reserved2 = selectedOption.attr("reserved2");
    var reserved3 = parseFloat(selectedOption.attr("reserved3"));
    var changedRow = $("#"+VACATION_TABLE).find("tr:nth-child(n+"+(trIndex+1)+"):nth-child(-n+"+(trIndex+5)+")");
    var vacationKindType = "";
    var remainVacDay = 0.0;
    var selectedValue = $(obj).find("option:selected").val();
/*
    if(selectedValue!="0" && selectedValue != undefined) {
        var publicVacKind = "";
        var jsonVacKindData = JSON.parse(vacationKindData);
        for (var i = 0; i < jsonVacKindData.length; i++) {
            if (jsonVacKindData[i].VacKind === "PUBLIC") {
                vacationKindType = publicVacKind;
                remainVacDay =  parseFloat(jsonVacKindData[i].RemainVacDay);
                //$("#VACATION_DAY").val(parseFloat(jsonVacKindData[i].RemainVacDay));
            }
            var vacdata = {
                "VacKind": jsonVacKindData[i].VacKind
                , "RemainVacDay": parseFloat(jsonVacKindData[i].RemainVacDay)
                , "TotRemainVacDay": parseFloat(jsonVacKindData[i].RemainVacDay)
                , "VacDay": parseFloat(jsonVacKindData[i].VacDay)
                , "ExpSdate": jsonVacKindData[i].Sdate
                , "ExpEdate": jsonVacKindData[i].Edate
            };
            targetVacArr.push(vacdata);
        }

    }
*/
    initRowFields(changedRow);

    //잔여연차 존재 시 선연차 사용 금지
    /*if (parseFloat($("#USE_DAYS").text()) - parseFloat($("#_MULTI_TOTAL_DAYS").text()) > 0.0) {
        if(reserved2===1) { //선연차인지 비교
            alert("잔여 연차가 있을 경우 [" + selectedOption.text() + "]를 선택하실 수 없습니다.");
            $(obj).val("");
            return;
        }
    }*/
    if (vacationKindType==="PUBLIC" && remainVacDay - parseFloat($("#_MULTI_TOTAL_DAYS").text()) > 0.0) {
        if(reserved2==1) { //선연차인지 비교
            alert("잔여 연차가 있을 경우 [" + selectedOption.text() + "]를 선택하실 수 없습니다.");
            $(obj).val("");
            return;
        }
    }

    if(reserved3 < 1){
		$(changedRow).find("[name=_MULTI_DAYS]").val(reserved3);
    }
    
    var rewardType = $(changedRow).find("[name=REWARD_TYPE]");
    if(reserved2 != "min"){
        rewardType.addClass(HIDDEN_CLASS);
    	setRowFieldsForVacationType(changedRow);
    } else{
    	//보상휴가
        rewardType.html("");
        rewardType.append("<option value='1'>연차</option>");
        if(reserved3 <= 0.5){
        	rewardType.append("<option value='0.5'>반차</option>")
        }     
        if(reserved3 <= 0.375){
        	rewardType.append("<option value='0.375'>3시간차</option>")
        } 
        if(reserved3 <= 0.25){
        	rewardType.append("<option value='0.25'>2시간차</option>")
        } 
        if(reserved3 <= 0.125){
        	rewardType.append("<option value='0.125'>1시간차</option>")
        } 
        rewardType.removeClass(HIDDEN_CLASS);
        rewardType.trigger("change");
    }
    
	calcTotalVacDays(); //전체 기간 합산일수의 재계산
}

function initRowFields(row){
    $(row).find("select[name='VACATION_OFF_TYPE']").val("0");
	$(row).find("input").val("");
	$(row).find("[name=_MULTI_DAYS]").val(0);
	calcTotalVacDays(); //전체 기간 합산일수의 재계산
}

function setRowFieldsForVacationType(row) {
    const reserved3 = Number($(row).find("[name='_MULTI_DAYS']").val()) || 1;
    const offType = $(row).find("[name=VACATION_OFF_TYPE]");
    const endTimeWrapper = $(row).filter(".endtimeWrapper");
    const timeWrapper = $(row).filter(".timeWrapper");
    
    // 모바일용
   	let rowLength = 3;
    const startTimeWrapper = $(row).filter(".starttimeWrapper");
   	let startTimeText = ""; 
    
    timeWrapper.find("input").removeAttr("required");
	if(reserved3 < 1){
		endTimeWrapper.addClass(HIDDEN_CLASS);
		if(reserved3 === 0.5){
			offType.removeClass(HIDDEN_CLASS);
			timeWrapper.addClass(HIDDEN_CLASS);
			rowLength = 2;
		} else {
			offType.addClass(HIDDEN_CLASS);
			timeWrapper.removeClass(HIDDEN_CLASS);
			timeWrapper.find("input").attr("required", true);
			rowLength = 4;
		}
		startTimeText = getInfo("localLangItems.date");
	} else {
		endTimeWrapper.removeClass(HIDDEN_CLASS);
		timeWrapper.addClass(HIDDEN_CLASS);
		offType.addClass(HIDDEN_CLASS);
		startTimeText = getInfo("localLangItems.startDate");
	}	
	
	startTimeWrapper.find("th").text(startTimeText);
	startTimeWrapper.find("input").attr("title", startTimeText);
	
	
	$(row).eq(0).find("th:first-child").attr("rowspan", rowLength);		
	
	EASY.pattern(timeWrapper.find("input"), true);	    
}

function setRowFieldsForRewardVacationType(rewardType) {
	var selectedType = $(rewardType).find("option:selected");
    var reserved3 = Number(selectedType.val());
	var trIndex = $("#"+VACATION_TABLE).find("tr").index($(rewardType).parents("tr").eq(0));
	var changedRow = $("#"+VACATION_TABLE).find("tr:nth-child(n+"+(trIndex+1)+"):nth-child(-n+"+(trIndex+5)+")");

    initRowFields(changedRow);
    if(reserved3 < 1){
		$(changedRow).find("[name=_MULTI_DAYS]").val(reserved3);
    }
    setRowFieldsForVacationType(changedRow);
}

//시작일, 종료일 입력에 따른 유효성 체크
function calSDATEEDATE(obj) {
    const m_index = $("input[name=" + obj.name + "]").index(obj);
	const vacationType = $("select[name=VACATION_TYPE]").eq(m_index);
//	const index= $(obj).parents("tr").index();
  
/*    if (!vacationType.val()) {
        alert(mobile_comm_getDic("msg_apv_selectNthVacType").format(i)); // {0}번째 휴가 유형이 입력되지 않았습니다.
		$(obj).val("");
		return;
    }
 */   
	const vactype = vacationType.val();
    const groupcode = vacationType.find("option:selected").attr("groupcode");
    const reserved1 = vacationType.find("option:selected").attr("reserved1");
    var reserved2 = vacationType.find("option:selected").attr("reserved2");
    var reserved3 = 0;
    if(reserved2 != "min"){
    	reserved3 = Number(vacationType.find("option:selected").attr("reserved3")) || 1;
    } else{
    	var selectedType = 	$("select[name=REWARD_TYPE]").find("option:selected").eq(m_index - 1);
        reserved3 = Number(selectedType.val());
    }
    
	const startDate = $("input[name=_MULTI_VACATION_SDT]").eq(m_index);
	const endDate = $("input[name=_MULTI_VACATION_EDT]").eq(m_index);
	const vacDays = $("input[name=_MULTI_DAYS]").eq(m_index);
	const vacReDays = $("span[name=_MULTI_TOTAL_DAYS]").eq(m_index);
	const appVacProcessCheck = Common.getBaseConfig("AppVacProcessCheck");
	
	if(startDate.val()) {
		var requestStartDate = new Date(startDate.val());
		
		if(dayOffList.indexOf(requestStartDate.toISOString().substring(0, 10)) != -1) {
			alert(Common.getDic("msg_notSelectedHoliday")); //휴일을 시작날짜로 선택할 수 없습니다.
			
			startDate.val("");
			vacDays.val("0");
	        vacReDays.text("0");
		}
	}

    if (reserved3 >= 1 && startDate.val() && endDate.val()) { // 연차일 경우
        const SDATE = startDate.val().split('-');
        const EDATE = endDate.val().split('-');

        const SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        const EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        let tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        if (tmpday < 0) {
            alert(mobile_comm_getDic("msg_Mobile_InvalidStartDate"));           
            endDate.val("");
            vacDays.val(0);
        } else { /* 휴일 포함인 경우, 설정 기간에서 휴일을 제외한 신청일수를 설정해주는 부분*/
			var dayOffCnt = 0;
			const requestDate = new Date(startDate.val());

			for (var i = 0; i <= tmpday; i++) {
				requestDate.setDate(SOBJDATE.getDate() + i);

				if (dayOffList.indexOf(requestDate.toISOString().substring(0, 10)) != -1) dayOffCnt++;
			}

			// 휴일을 제외하고 신청일수를 계산
			vacDays.val((tmpday + 1 - dayOffCnt) * reserved3);
		}
    } else if (reserved3 < 1 && reserved3 > 0) {
        endDate.val(startDate.val());
        vacDays.val(reserved3);
    }

    //미차감
    if(reserved1==="N")  return;
    if(reserved2!=1 && vacDays.val()>0){//선연차 허용 시 체크 안함.
        //휴가 잔여 수 체크 및 휴가 가능일 여부 판단
        var len = $("input[name=_MULTI_VACATION_SDT]").length;
        var vRemainVacDay = 0;
        for (var j = 0; j < targetVacArr.length; j++) {
            var targetVacKind = targetVacArr[j].VacKind;
            var ExpSdate = Number(targetVacArr[j].ExpSdate);
            var ExpEdate = Number(targetVacArr[j].ExpEdate);

        	$("span[name='_MULTI_VAC_INDEX']").eq(m_index).text("-1");
            
            if (startDate.val().replaceAll('-','')>=ExpSdate && endDate.val().replaceAll('-','')<=ExpEdate){
                if (groupcode  == "PUBLIC" && targetVacKind == "PUBLIC" ){
                	$("span[name='_MULTI_VAC_INDEX']").eq(m_index).text(j);
                	break;
                }
                else if(groupcode  != "PUBLIC" && targetVacKind == vactype){
                	$("span[name='_MULTI_VAC_INDEX']").eq(m_index).text(j);
                	break;
                }
            }     
        }
        
        if ($("span[name='_MULTI_VAC_INDEX']").eq(m_index).text() == -1){
            Common.Warning("휴가 기간에 맞는 휴가 정보가 없습니다.");
            endDate.val("");
            vacDays.val(0);
            return false;
        }
        else{	//휴가 유형이 같은 것끼리 잔여 휴가 체크하기
        	remainTot = Number(targetVacArr[$("span[name='_MULTI_VAC_INDEX']").eq(m_index).text()].RemainVacDay);
        	if (appVacProcessCheck == "SUM") remainTot = remainTot - Number(targetVacArr[$("span[name='_MULTI_VAC_INDEX']").eq(m_index).text()].VacDayProc);
        	for (var i = 0; i <= len; i++) {//_MULTI_DAYS
        		if ($("span[name='_MULTI_VAC_INDEX']").eq(m_index).text() == $("span[name='_MULTI_VAC_INDEX']").eq(i).text()){
//        			var findTr =  $("#tblVacInfo tr:eq("+i+")");
        			
        			if (remainTot < Number($("span[name='_MULTI_DAYS']").eq(i).text())) {
                        Common.Warning("가능 휴가 기간 중 휴가일 수 가 초과 되었습니다.");
                        $("input[name=_MULTI_VACATION_EDT]").eq(i).val("");
                        $("input[name=_MULTI_DAYS]").eq(i).val("0");
                        $("span[name='_MULTI_TOTAL_DAYS']").eq(i).text("0");
                        return false;
                    }else{
                    	remainTot = remainTot - Number($("input[name='_MULTI_DAYS']").eq(i).val())
                    	//var vFirst_Day = $("span[name='_MULTI_DAYS']").eq(k).text();
                    	$("[name='_MULTI_TOTAL_DAYS']").eq(i).text(remainTot);
                    }
        		}
        	}
        	
        }
        
        /*
    //calcTotalVacDays(); //전체 기간 합산일수의 재계산
    if(reserved2!==1) {//선연차 허용 시 체크 안함.
        //휴가 잔여 수 체크 및 휴가 가능일 여부 판단
        var len = $("input[name=_MULTI_VACATION_SDT]").length;
        //console.log("targetVacArr>"+JSON.stringify(targetVacArr));
        for (var j = 0; j < targetVacArr.length; j++) {

            var targetVacKind = targetVacArr[j].VacKind;
            var ExpSdate = Number(targetVacArr[j].ExpSdate);
            var ExpEdate = Number(targetVacArr[j].ExpEdate);
            //console.log("######"+targetVacKind+"#######["+ExpSdate+ " ~ "+ExpEdate+"]#######");
            //console.log("len>"+len);
            targetVacArr[j].TotRemainVacDay = targetVacArr[j].RemainVacDay;
            for (var k = 1; k < len; k++) {
                var vacationReserved1 = $('select[name=VACATION_TYPE]').eq(k).find("option:selected").attr("reserved1");
                if(vacationReserved1==="N") {//미차감
                    continue;
                }
                //console.log("@@@@@@@@@@@@@@["+k+"]@@@@@@@@@@@@");
                var vacationReserved3 = Number($('select[name=VACATION_TYPE]').eq(k).find("option:selected").attr("reserved3"));
                var VacKind = $('select[name=VACATION_TYPE]').eq(k).find("option:selected").val();
                var isExtraTypeVal = isExtraType(VacKind);
                if (targetVacKind === "PUBLIC" && isExtraTypeVal === true) {
                    continue;
                }
                if (targetVacKind !== "PUBLIC" && (isExtraTypeVal === false || VacKind !== targetVacKind)) {
                    continue;
                }
                //console.log("&&&&& isExtraTypeVal:"+isExtraTypeVal+",VacKind:"+VacKind+", vacationReserved3:"+vacationReserved3+", targetVacKind:"+targetVacKind);

                var VacSdts = $("input[name='_MULTI_VACATION_SDT']").eq(k).val();
                var VacEdts = $("input[name='_MULTI_VACATION_EDT']").eq(k).val();
                var vFirst_S_Date = Number(VacSdts.replace("-", "").replace("-", ""));
                var vFirst_E_Date = Number(VacEdts.replace("-", "").replace("-", ""));

                var vFirst_Day = $("input[name='_MULTI_DAYS']").eq(k).val();
                //console.log("vFirst_Day>"+vFirst_Day);
                //console.log("vacationReserved3>"+vacationReserved3);
                if (vFirst_Day <= 0) {
                    continue;
                }

                if (vacationReserved3 < 1 && isExistVacationData(VacKind, vFirst_S_Date, vFirst_S_Date) === 0) {
                    alert("휴가 기간에 맞는 휴가 정보가 없습니다.");
                    $("input[name=_MULTI_VACATION_SDT]").eq(k).val("");
                    $("input[name=_MULTI_DAYS]").eq(k).val("0");
                    return;
                }
                if (vacationReserved3 === 1 && isExistVacationData(VacKind, vFirst_S_Date, vFirst_E_Date) === 0) {
                    alert("휴가 기간에 맞는 휴가 정보가 없습니다.");
                    $("input[name=_MULTI_VACATION_EDT]").eq(k).val("");
                    $("input[name=_MULTI_DAYS]").eq(k).val("0");
                    return;
                }

                if (vacationReserved3 < 1 && (vFirst_S_Date < ExpSdate || vFirst_S_Date > ExpEdate)) {
                    continue;
                }

                if (vacationReserved3 === 1
                    && (vFirst_S_Date < ExpSdate || vFirst_S_Date > ExpEdate
                        || vFirst_E_Date < ExpSdate && vFirst_E_Date > ExpEdate)) {
                    continue;
                }

                var TotRemainVacDay = targetVacArr[j].TotRemainVacDay;
                //console.log("TotRemainVacDay>"+TotRemainVacDay);
                var remainTot = TotRemainVacDay;
                if (vacationReserved3 < 1) {
                    if (VacSdts !== "" && vFirst_S_Date >= ExpSdate && vFirst_S_Date <= ExpEdate
                        && remainTot >= vacationReserved3) {
                        targetVacArr[j].TotRemainVacDay = remainTot - vacationReserved3;
                    } else {
                        if (VacSdts !== "" && (vFirst_S_Date < ExpSdate || vFirst_S_Date > ExpEdate)) {
                            alert("휴가 기간에 맞는 휴가 정보가 없습니다.");
                            $("input[name=_MULTI_VACATION_SDT]").eq(k).val("");
                            $("input[name=_MULTI_DAYS]").eq(k).val("0");
                            return;
                        }

                        if (remainTot < vacationReserved3) {
                            alert("가능 휴가 기간 중 휴가일 수 가 초과 되었습니다.");
                            $("input[name=_MULTI_VACATION_SDT]").eq(k).val("");
                            $("input[name=_MULTI_DAYS]").eq(k).val("0");
                            return;
                        }

                    }
                }//end if < 1

                if (vacationReserved3 === 1) {
                    if (remainTot >= (vacationReserved3 * vFirst_Day) &&
                        VacSdts !== "" && vFirst_S_Date >= ExpSdate && vFirst_S_Date <= ExpEdate &&
                        VacEdts !== "" && vFirst_E_Date >= ExpSdate && vFirst_E_Date <= ExpEdate) {
                        targetVacArr[j].TotRemainVacDay = remainTot - (vacationReserved3 * vFirst_Day);
                    } else {
                        if (VacSdts !== "" && VacEdts !== ""
                            && (vFirst_S_Date < ExpSdate || vFirst_S_Date > ExpEdate || vFirst_E_Date < ExpSdate || vFirst_E_Date > ExpEdate)) {
                            alert("휴가 기간에 맞는 휴가 정보가 없습니다.");
                            $("input[name=_MULTI_VACATION_EDT]").eq(k).val("");
                            $("input[name=_MULTI_DAYS]").eq(k).val("0");
                            return;
                        }

                        if (remainTot < (vacationReserved3 * vFirst_Day)) {
                            alert("가능 휴가 기간 중 휴가일 수 가 초과 되었습니다.");
                            $("input[name=_MULTI_VACATION_EDT]").eq(k).val("");
                            $("input[name=_MULTI_DAYS]").eq(k).val("0");
                            return;
                        }
                    }
                }//end if 1
            }//end for row vac
        }
        */
        calcTotalVacDays(); //전체 기간 합산일수의 재계산
    }
}

function calculateEndTimeAndSetOffType(startTimeInput){
	const WORK_HOUR = 8;
	const startTime = $(startTimeInput).val();
	if(startTime){
	    const trIndex = $("#"+VACATION_TABLE).find("tr").index($(startTimeInput).parents("tr").eq(0));
	    const row = $("#"+VACATION_TABLE).find("tr:nth-child(n+"+(trIndex-3)+"):nth-child(-n+"+(trIndex+2)+")");
		const vacDays = Number(row.find("[name='_MULTI_DAYS']").val());
		const endTimeInput = $(row).find("input[name='_MULTI_VACATION_ETIME']");
		const startHour = parseInt(startTime.substring(0,2));
		const startMinutes = parseInt(startTime.substring(3));
		const endTime = new Date();
		endTime.setHours(startHour + WORK_HOUR * vacDays, startMinutes);
		const endHour = String(endTime.getHours()).padStart(2, "0");
		const endMinutes = String(endTime.getMinutes()).padStart(2, "0");
		endTimeInput.val(endHour+":"+endMinutes);
		
		$(row).find("[name=VACATION_OFF_TYPE]").val((startHour < 12) ? "AM" : "PM");
	}
}

//기간 중복 여부 체크
function TermCheck() {
    let vFirst_S = '';
    let vFirst_E = '';
    let vSecon_S = '';
    let vSecon_E = '';
    let ret = true;
    const len = $("input[name=_MULTI_VACATION_SDT]").length;

    for (let i = 1; i < len; i++) {
        if (!ret) {
            break;
        }

        vFirst_S = $("input[name=_MULTI_VACATION_SDT]").eq(i).val(); //첫번째 행 시작일
        const vFirst_S_Year = vFirst_S.split("-")[0];
        const vFirst_S_Mon = vFirst_S.split("-")[1];
        const vFirst_S_day = vFirst_S.split("-")[2];
        const vFirst_S_Date = new Date(vFirst_S_Year, Number(vFirst_S_Mon)-1, vFirst_S_day);

        vFirst_E = $("input[name=_MULTI_VACATION_EDT]").eq(i).val(); //첫번째 행 종료일
        const vFirst_E_Year = vFirst_E.split("-")[0];
        const vFirst_E_Mon = vFirst_E.split("-")[1];
        const vFirst_E_day = vFirst_E.split("-")[2];
        const vFirst_E_Date = new Date(vFirst_E_Year, Number(vFirst_E_Mon)-1, vFirst_E_day);

        var vFirst_Day = $("select[name=VACATION_TYPE] option:selected").eq(i).attr("reserved3");
        var vFirst_S_Option = '';

        for (let j = i + 1; j < len; j++) {
            vSecon_S = $("input[name=_MULTI_VACATION_SDT]").eq(j).val();
            const vSecon_S_Year = vSecon_S.split("-")[0];
            const vSecon_S_Mon = vSecon_S.split("-")[1];
            const vSecon_S_day = vSecon_S.split("-")[2];
            const vSecon_S_Date = new Date(vSecon_S_Year, Number(vSecon_S_Mon)-1, vSecon_S_day);

            vSecon_E = $("input[name=_MULTI_VACATION_EDT]").eq(j).val();
            const vSecon_E_Year = vSecon_E.split("-")[0];
            const vSecon_E_Mon = vSecon_E.split("-")[1];
            const vSecon_E_day = vSecon_E.split("-")[2];
            const vSecon_E_Date = new Date(vSecon_E_Year, Number(vSecon_E_Mon)-1, vSecon_E_day);

            var vSecon_Day = $("select[name=VACATION_TYPE] option:selected").eq(j).attr("reserved3");
            var vSecon_S_Option = '';
            
            if(vFirst_Day===0.5)	vFirst_S_Option = $('select[name=VACATION_OFF_TYPE]').eq(i).val();
            if(vSecon_Day===0.5)	vSecon_S_Option = $('select[name=VACATION_OFF_TYPE]').eq(j).val();
            if(vFirst_Day<0.5) vFirst_S_Option = $("input[name=_MULTI_VACATION_STIME]").eq(i).val();
            if(vSecon_Day<0.5) vSecon_S_Option = $("input[name=_MULTI_VACATION_STIME]").eq(j).val();
            
            if (
                (vSecon_S_Date <= vFirst_S_Date && vSecon_E_Date >= vFirst_E_Date) ||
                (vSecon_S_Date <= vFirst_E_Date && vSecon_E_Date >= vFirst_E_Date) ||
                (vSecon_S_Date >= vFirst_S_Date && vSecon_E_Date <= vFirst_E_Date) ||
                (vSecon_S_Date <= vFirst_S_Date && vSecon_E_Date >= vFirst_E_Date)) {
	            	if(vFirst_Day===0.5 && vSecon_Day===0.5 && vFirst_S_Option!=vSecon_S_Option){
	        			
	        		}else if(vFirst_Day<0.5 && vSecon_Day<0.5 && vFirst_S_Option!=vSecon_S_Option){
	        			
	        		}else{
	        			ret = false;
	                	break;
	        		}
            }
        }
    }
    return ret;
}

// 전체 총 신청할 연차 개수 계산
function calcTotalVacDays() {
    let totalVac = 0.0;

    $(".multi-row").find("input[name='_MULTI_DAYS']").each(function() {
        if($(this).val()) {
            totalVac += Number($(this).val());
        }
    });

    $("#_MULTI_TOTAL_DAYS").text(totalVac);
}

// 멀티로우 행 추가 시 이벤트
XFORM.multirow.event('afterRowAdded', function ($rows) {
    // 멀티로우 체크박스, 라디오 추가
    mobile_approval_addMultiCheckAndRadio($rows);
});

//멀티로우 행 삭제 시 이벤트
XFORM.multirow.event('afterRowRemoved', function () {
    // 멀티로우 체크박스, 라디오 시퀀스 다시 세팅
    mobile_approval_setMultiCheckAndRadio();

    // 전체선택 체크 해제
    $(".multi-row-select-all").prop("checked", false);
    $(".multi-row-select-all").checkboxradio('refresh');
});
