//양식별 다국어 정의 부분
var localLang_ko = {
    localLangItems: {
        selMessage: "●휴일이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_en = {
    localLangItems: {
        selMessage: "●vacation이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_ja = {
    localLangItems: {
        selMessage: "●休日이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var localLang_zh = {
    localLangItems: {
        selMessage: "●休日이 포함된 연차를 사용할 경우 [추가]버튼을 이용하여 개별 입력하시기 바랍니다.",
        allVacDays: "총연차"

    }
};

var HIDDEN_CLASS = "hidden";
var VACATION_TABLE = "tblVacInfo";
var WORK_HOUR = 8;
var appVacProcessCheck = Common.getBaseConfig("AppVacProcessCheck");
var vacationKindData = null;
//var targetVacArrTmp = new Array();
var targetVacArr = new Array();
var vacmode = "";
var vacmode2 = "";
var dayOffList;

//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {

	initRowforVacationTypeChanged($("select[name=VACATION_OFF_TYPE]"));

    loadVacationInfo();
    // 휴가 타입 셀렉트박스 옵션 추가
    makeVacationTypeSelect();
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
	getUserDayOffDate();

    //Subject 숨김처리
    $('#tblFormSubject').hide();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        if(appVacProcessCheck !== "NONE"){
            $("#PRC_DAYS").show();
        }
        
		$("[name=VACATION_OFF_TYPE]").removeClass(HIDDEN_CLASS);
		
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
            $('#spanSelYear').html('년');
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext[VACATION_TABLE]), 'json', '#' + VACATION_TABLE, 'R');
        }

        //특정 디자인 수정
        $('#VAC_REASON').removeAttr('style');
        //휴가유형별 휴가정보 테이블 tr숨기기
        $("#trExtraTable").hide();
        $("#trVacRange").attr("rowspan","1");
        
    } else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        
		document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt; // 재사용, 임시함에서 오늘날짜로 들어가게함.
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
			$("#InitiatorOUDisplay").val(m_oFormMenu.getLngLabel(formJson.AppInfo.dpnm, false));
	        $("#InitiatorCodeDisplay").val(m_oFormMenu.getLngLabel(formJson.AppInfo.usid, false));
	        $("#InitiatorDisplay").val(m_oFormMenu.getLngLabel(formJson.AppInfo.usnm, false));
	        $("#NUMBER").val(Common.GetObjectInfo("UR", Common.getSession("UR_Code"), "Mobile").Mobile);
			getVacationData();
		} else if((formJson.Request.mode == "APPROVAL" || formJson.Request.mode == "REDRAFT") && getInfo("Request.editmode") == 'Y') {
			getVacationData();
        }

        if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext[VACATION_TABLE]), 'json', '#'+ VACATION_TABLE, 'W');
        } else {
            XFORM.multirow.load('', 'json', '#'+ VACATION_TABLE, 'W', { minLength: 1 });
        }
        
		$("select[name=VACATION_OFF_TYPE] option[value='0']").text("선택");
    }
    
    if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
	    $("#"+ VACATION_TABLE+" tr.multi-row").each(function(){
			setRowFieldsForVacationType(this)
		});
	} else {
		$("#"+ VACATION_TABLE+" tr.multi-row select[name='VACATION_TYPE']").each(function(){
			initRowforVacationTypeChanged(this)
		});
	}

/*    $("#Sel_Year").on('change', function() {
        getVacationData();
        loadVacationInfo();
    });*/
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

function makeVacationTypeSelect() {
    var useBefore = isBeforeAnnualMember();
    var tarType = $('select[name="VACATION_TYPE"]');
    //var oCodeList = Common.getBaseCode("VACATION_TYPE");
    //컬럼 정보 조회
    $.ajax({
        url : "/groupware/vacation/getUserVacTypeInfo.do",
        type: "POST",
        dataType : 'json',
        async: false,
        success:function (data) {
            var listData = data.list;
            if(listData.length>0){
                for(var i=0;i<listData.length;i++){
                    var isUse = listData[i].IsUse;
                    if(isUse==="N"){
                        continue;
                    }
                    var reserved1 = listData[i].Reserved1;
                    var reserved2 = listData[i].Reserved2==""?"":listData[i].Reserved2;
                    var reserved3 = listData[i].Reserved3;
                    var listCode = listData[i].Code;
                    var codeName = listData[i].CodeName;
                    var groupCode = listData[i].GroupCode;
                    var groupCodeName = listData[i].GroupCodeName;
                    var multiCodeName = CFN_GetDicInfo(listData[i].MultiCodeName);
                    if(multiCodeName!=""){
                        codeName = multiCodeName;
                    }
                    //console.log(listData[i]);

                    if (reserved2 != "none" && !(!useBefore && reserved2 === "1") && (existUserVacationInfo(listCode, groupCode) || reserved1==="N")) { // 선연차 제외
                        tarType.append($('<option/>', {
                            value: listCode,
                            text: codeName,
                            reserved1: reserved1,
                            reserved2: reserved2,
                            reserved3: reserved3,
                            groupCode: groupCode,
                            groupCodeName: groupCodeName
                        }));
                    }
                }
            }
        }
    });

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
    } catch (e) { coviCmn.traceLog(e); }
    return useBefore;
}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
    if (document.getElementById("Subject").value == "") {
        document.getElementById("Subject").value = CFN_GetDicInfo(getInfo("AppInfo.usnm")) + " - " + CFN_GetDicInfo(getInfo("FormInfo.FormName"));
    }
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
		document.getElementById("Subject").value = CFN_GetDicInfo(getInfo("AppInfo.usnm")) + " - " + CFN_GetDicInfo(getInfo("FormInfo.FormName"))+" ("+datestr+")";
	}


    var returnBol = true;

    if (bTempSave) {
        return true;
    } else {
        if(document.getElementsByName("_MULTI_VACATION_SDT").length <= 1){
            Common.Warning("휴가 기간을 입력해주세요.");
            return false;
        }

        /* [2017-01-04 add] gbhwang 사용할 연차의 연도와 휴가 신청 기간의 연도 비교
        var isSame = true; // 사용할 연차의 연도와 휴가 신청 기간의 연도 동일 여부
        $("[name=_MULTI_VACATION_SDT],[name=_MULTI_VACATION_EDT]").each(function () {
            if ($(this).val() != "") {
                if ($(this).val().substring(0, 4) != $("#Sel_Year").val()) {
                    isSame = false;
                    return false;
                }
            }
        });

        if (!isSame) {
            Common.Warning("사용할 연차의 연도와 입력하신 기간의 연도가 상이합니다.");
            return false;
        }*/

        //[2016-06-29 modi kimjh] - 선연차, 연차 같이 사용
        //잔여 연차 일보다 신청 일수가 더 많을때
        var Slen = $("select[name=VACATION_TYPE]").length;
        var sValue = 0.0; //선연차, 선번차 값 구하기
        var eValue = 0.0;//반차, 연차 값 구하기
        var eCodeName = "";
        for (var i = 1; i < Slen; i++) {
            if ($('select[name=VACATION_OFF_TYPE]').eq(i).is(':visible') && ($('select[name=VACATION_OFF_TYPE]').eq(i).val() == "" || $('select[name=VACATION_OFF_TYPE]').eq(i).val() == "0")) {
            	Common.Warning(Common.getDic("msg_enter_half_day")); //반차 종류를 입력하세요.
                return false;
            }
            var selectedOption = $('select[name=VACATION_TYPE]').eq(i).find("option:selected");
            if (selectedOption.attr("reserved1") === "Y" && (selectedOption.attr("reserved2") != null && selectedOption.attr("reserved2") !== "" && selectedOption.attr("reserved2") != "min")) { //선연차, 선반차 일수 넣기
                eCodeName += (eCodeName.indexOf(selectedOption.text()) < 0 ? selectedOption.text() + "," : "");
                sValue += Number($("[name=_MULTI_DAYS]").eq(i).text().replace(/[^0-9.]/g, ""));
            }
            if (selectedOption.attr("reserved1") === "Y" && (selectedOption.attr("reserved2") == null || selectedOption.attr("reserved2") === "" || selectedOption.attr("reserved2") == "min")) { //그 외 가감 연차 일수 넣기
                eValue += Number($("[name=_MULTI_DAYS]").eq(i).text().replace(/[^0-9.]/g, ""));
            }
        }

        var _useDays = Number($("#VACATION_DAY").val()); // 잔여연차.
        
        //if (!calSDATEEDATE($("input[name=_MULTI_VACATION_EDT]").last())) return;
        
//        calSDATEEDATE
        /*
        // 잔여연차가 0개 미만인 경우에는 연차&반차를 제외하고 사용 가능함.
        // 승인대기중 연차 체크
        if ((eValue > 0 && _useDays <= 0) || (_useDays < eValue && _useDays > 0)) { 
            Common.Warning(Common.getDic("msg_apv_chk_remain_vacation")); //잔여 연차일을 초과하였습니다.
            return false;
        }
        
        if(appVacProcessCheck !== "NONE"){
        	var _processInfo;
        	CFN_CallAjax("/approval/legacy/getVacationProcessInfo.do", 
        		{
					"UR_CODE":getInfo("AppInfo.usid"),
					"year":document.getElementById("Sel_Year").value
				}, 
				function (data){
	        		if(data.status == "SUCCESS"){
	        			_processInfo = data.vacInfo;
	        		}
        		},
        	 false, "json");
        	if(_processInfo){
        		var _processDays = Number(_processInfo["days"]);
        		var _processCnt = Number(_processInfo["cnt"]);
        		if(appVacProcessCheck === "SUM" && _useDays < (_processDays + eValue) && _useDays > 0){
        			// 승인대기중인 결재건의 연차일수를 합산하여 체크
    				Common.Warning(Common.getDic("msg_apv_chk_remain_vacation")); //잔여 연차일을 초과하였습니다.
    				return false;
        		}else if(appVacProcessCheck === "REJECT" && _processCnt > 0){
        			// 승인대기중인 결재건이 존재할 경우 중복기안 불가.
    				Common.Warning(Common.getDic("msg_apv_chk_remain_vac_process")); //승인대기중인 휴가신청서 완료후 상신이 가능합니다.
    				return false;
        		}
        	}
        }
*/
        if (appVacProcessCheck === "REJECT" && Number($("#PRC_DAYS").text()) > 0){
        	Common.Warning(Common.getDic("msg_apv_chk_remain_vac_process")); //승인대기중인 휴가신청서 완료후 상신이 가능합니다.
			return false;
        }
        
        if (sValue > 0.0 && _useDays > eValue ) {
            Common.Warning(Common.getDic("lbl_apv_vacation_remaining") + " [" + eCodeName.slice(0, -1) + "] " + Common.getDic("lbl_apv_vacation_remainingText"));
            //잔여 연차가 있을 경우 --- 를 선택하실 수 없습니다.
            return false;
        }
        if (document.getElementById("SaveTerm").value == '') {
            Common.Warning(Common.getDic("lbl_apv_InputRetention")); //보존년한을 선택하세요.
            return false;
        }
        else if (document.getElementById("NUMBER").value == '') {
            Common.Warning(Common.getDic("msg_apv_chk_emergency_contact")); //비상연락처를 입력해주세요.
            return false;
        }
        else {
            if (TermCheck()) {
                if(EASY.check().result){
                	returnBol = checkVacationDup(getBodyContext().BodyContext.tblVacInfo)
/*                    // 휴가기간이 중복되어 있는지 Validation 체크
                    if(tblVacInfo != undefined){
                        if(tblVacInfo.length == undefined)
                            tblVacInfo = [tblVacInfo];

                        CFN_CallAjax("/groupware/vacation/getVacationInfo.do", {"vacationInfo":JSON.stringify(tblVacInfo)}, function (data){
                            if(data.status == "SUCCESS"){
                                var dupVac = data.dupVac;
                                if(dupVac.length > 0){
                                    var messageStr = "";

                                    $(dupVac).each(function(){
                                        messageStr += " '"+ this._MULTI_VACATION_SDT +" ~ "+ this._MULTI_VACATION_EDT +"',";
                                    });
                                    messageStr = messageStr.substring(0, messageStr.length-1);
                                    messageStr += " 기간에 이미 휴가가 신청되어 있습니다.";

                                    Common.Warning(messageStr);
                                    returnBol = false;
                                }else{
                                    returnBol = true;
                                }
                            }else{
                                Common.Warning("휴가 기간 체크 중 오류가 발생하였습니다.");
                                returnBol = false;
                            }
                        }, false, 'json');
                    }*/
                }else{
                    returnBol = false;
                }
            }
            else {
                Common.Warning(Common.getDic("lbl_apv_vacation_remainingCheck"));//입력하신 기간 확인 후 기안 하시기 바랍니다.
                returnBol = false;
            }
        }
    }

    return returnBol;
}
    
function checkFormForRead(){
	var tblVacInfo = formJson.BodyContext.tblVacInfo;
	return checkVacationDup(tblVacInfo);
}
// 휴가기간이 중복되어 있는지 Validation 체크
function checkVacationDup(tblVacInfo){
	var returnBol = true;
	 if(tblVacInfo != undefined && $("#ACTIONINDEX").val() != "REJECT" && $("#ACTIONINDEX").val() != "DISAGREE"){
         if(tblVacInfo.length == undefined)
             tblVacInfo = [tblVacInfo];

		var userCode = "";
		if(formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") userCode = formJson.AppInfo.usid;
		else if(formJson.FormInstanceInfo && formJson.FormInstanceInfo.InitiatorID) userCode = formJson.FormInstanceInfo.InitiatorID;
		
         CFN_CallAjax("/groupware/vacation/getVacationInfo.do", {"vacationInfo":JSON.stringify(tblVacInfo), "userCode" : userCode, "chkType" : formJson.Request.mode}, function (data){
             if(data.status == "SUCCESS"){
                 var dupVac = data.dupVac;
                 if(dupVac.length > 0){
                     var messageStr = "";

                     $(dupVac).each(function(){
                         messageStr += " '"+ this._MULTI_VACATION_SDT +" ~ "+ this._MULTI_VACATION_EDT +"',";
                     });
                     messageStr = messageStr.substring(0, messageStr.length-1);
                     messageStr += " 기간에 이미 휴가가 신청되어 있습니다.";
     
					 if(formJson.Request.isMobile == "Y" || _mobile) alert(messageStr);
					 else Common.Warning(messageStr);
				
                     returnBol = false;
                 }else{
                     returnBol = true;
                 }
             }else{
                 Common.Warning("휴가 기간 체크 중 오류가 발생하였습니다.");
                 returnBol = false;
             }
         }, false, 'json');
     }

	 return returnBol;
}

function setBodyContext(sBodyContext) {
}

//본문 JSON으로 구성
function makeBodyContext() {

    var bodyContextObj = {};
    bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblVacInfo", "rField"));
    return bodyContextObj;
}

//기간에 대한 validation 처리 추가
function validateVacDate() {

    $('#tblVacInfo').on('change', '.multi-row [name=_MULTI_VACATION_EDT]', function () {
        var sdt = $(this).prev().prev().val().replace(/-/g, '');
        var edt = $(this).val().replace(/-/g, '');

        if (Number(sdt) > Number(edt)) {
            Common.Warning("시작일 보다 종료일이 먼저일 수 없습니다");
            $(this).val('');
            $(this).parent().find('[name=_MULTI_DAYS]').text(''); //입력된 기간 일수 제거
            EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
        }

        var selectedYear = document.getElementById("Sel_Year").value;
        var clickedYear = $(this).val().split('-')[0];

        if (selectedYear != clickedYear && clickedYear != '') {
            Common.Warning("연차년도와 동일 년도의 날짜로 선택하시기 바랍니다. ");
            $(this).val('');
        }

    });

    $('#tblVacInfo .multi-row').on('change', '[name=_MULTI_VACATION_SDT]', function () {
        var selectedYear = document.getElementById("Sel_Year").value;
        var clickedYear = $(this).val().split('-')[0];

        if (selectedYear != clickedYear && clickedYear != '') {
            Common.Warning("연차년도와 동일 년도의 날짜로 선택하시기 바랍니다. ");
            $(this).val('');
        }

    });

}

function calSDATEEDATE(obj) {
    var selectedTr = $(obj).parents("tr").eq(0);
    var vacationType = selectedTr.find("select[name=VACATION_TYPE]");
    var index= $(obj).parents("tr").index();
    
/*    if (!vacationType.val()) {
        index = $("#" + VACATION_TABLE + " select[name=VACATION_TYPE]").index(vacationType);
        alert(Common.getDic("msg_apv_selectNthVacType").format(index)); // {0}번째 휴가 유형이 입력되지 않았습니다.
        $(obj).val("");
        return;
    }*/

    var vactype = vacationType.val();
    var groupcode = vacationType.find("option:selected").attr("groupcode");
    var reserved1 = vacationType.find("option:selected").attr("reserved1");
    var reserved2 = vacationType.find("option:selected").attr("reserved2");
    var reserved3 = 0;
    if(reserved2 != "min"){
    	reserved3 = Number(vacationType.find("option:selected").attr("reserved3")) || 1;
    } else{
    	var rewardType = selectedTr.find("select[name=REWARD_TYPE]");
    	var selectedType = $(rewardType).find("option:selected");
        reserved3 = Number(selectedType.val());
    }

    var startDate = selectedTr.find("input[name=_MULTI_VACATION_SDT]");
    var endDate = selectedTr.find("input[name=_MULTI_VACATION_EDT]");
    var vacDays = selectedTr.find("[name=_MULTI_DAYS]");
	
	if(startDate.val()) {
		var requestStartDate = new Date(startDate.val());
		
		if(dayOffList.indexOf(requestStartDate.toISOString().substring(0, 10)) != -1) {
			alert(Common.getDic("msg_notSelectedHoliday")); //휴일을 시작날짜로 선택할 수 없습니다.
			
			startDate.val("");
			selectedTr.find("span[name=_MULTI_DAYS]").text("0");
	        selectedTr.find("[name='_MULTI_TOTAL_DAYS']").text("0");
		}
	}

    if (reserved3 >= 1 && startDate.val() && endDate.val()) {
        var SDATE = startDate.val().split('-');
        var EDATE = endDate.val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        if (tmpday < 0) {
            alert(Common.getDic("msg_Mobile_InvalidStartDate")); // "이전 일보다 전 입니다. 확인하여 주십시오."
            endDate.val("");
            vacDays.text(0);
        } else { /* 휴일 포함인 경우, 설정 기간에서 휴일을 제외한 신청일수를 설정해주는 부분*/
			var dayOffCnt = 0;
			var requestDate = new Date(startDate.val());

			for (var i = 0; i <= tmpday; i++) {
				requestDate.setDate(SOBJDATE.getDate() + i);

				if (dayOffList.indexOf(requestDate.toISOString().substring(0, 10)) != -1) dayOffCnt++;
			}

			// 휴일을 제외하고 신청일수를 계산
			if(dayOffCnt == 0) {
				vacDays.text((tmpday + 1 - dayOffCnt) * reserved3);
			} else {
				vacDays.text(Common.getDic("lbl_excludeHoliday") + " " + ((tmpday + 1 - dayOffCnt) * reserved3));
			}
		}
    } else if (reserved3 < 1 && reserved3 > 0) {
        endDate.val(startDate.val());
        vacDays.text(reserved3);
    }

    //미차감
    if(reserved1==="N")  return;
    if(reserved2!=1 && vacDays.text().replace(/[^0-9.]/g, "")>0){//선연차 허용 시 체크 안함.
        //휴가 잔여 수 체크 및 휴가 가능일 여부 판단
        var len = $("input[name=_MULTI_VACATION_SDT]").length;
        var vRemainVacDay = 0;
        for (var j = 0; j < targetVacArr.length; j++) {
            var targetVacKind = targetVacArr[j].VacKind;
            var ExpSdate = Number(targetVacArr[j].ExpSdate);
            var ExpEdate = Number(targetVacArr[j].ExpEdate);
        	selectedTr.attr("vacIndex", -1);
        	selectedTr.find("[name='_MULTI_VAC_INDEX']").text("-1");
            
            if (startDate.val().replaceAll('-','')>=ExpSdate && endDate.val().replaceAll('-','')<=ExpEdate){
                if (groupcode  == "PUBLIC" && targetVacKind == "PUBLIC" ){
                	selectedTr.attr("vacIndex", j);
                	selectedTr.find("[name='_MULTI_VAC_INDEX']").text(j);
                	break;
                }
                else if(groupcode  != "PUBLIC" && targetVacKind == vactype){
                	selectedTr.attr("vacIndex", j);
                	selectedTr.find("[name='_MULTI_VAC_INDEX']").text(j);
                	break;
                }
            }     
        }
        
        if (selectedTr.attr("vacIndex") == -1){
            Common.Warning("휴가 기간에 맞는 휴가 정보가 없습니다.");
            endDate.val("");
            vacDays.text(0);
            return false;
        }
        else{	//휴가 유형이 같은 것끼리 잔여 휴가 체크하기
        	remainTot = Number(targetVacArr[selectedTr.attr("vacIndex")].RemainVacDay);
        	if (appVacProcessCheck == "SUM") remainTot = remainTot - Number(targetVacArr[selectedTr.attr("vacIndex")].VacDayProc);
        	for (var i = 2; i <= index; i++) {//_MULTI_DAYS
        		if (selectedTr.attr("vacIndex") == $("#tblVacInfo tr:eq("+i+")").attr("vacIndex")){
        			var findTr =  $("#tblVacInfo tr:eq("+i+")");
//        			console.log("find row : "+i+":"+remainTot+"< "+ Number(findTr.find("span[name='_MULTI_DAYS']").text()));
        			
        			if (remainTot < Number(findTr.find("span[name='_MULTI_DAYS']").text().replace(/[^0-9.]/g, ""))) {
                        Common.Warning("가능 휴가 기간 중 휴가일 수 가 초과 되었습니다.");
                        findTr.find("input[name=_MULTI_VACATION_EDT]").val("");
                        findTr.find("span[name=_MULTI_DAYS]").text("0");
                        findTr.find("[name='_MULTI_TOTAL_DAYS']").text("0");
                        return false;
                    }else{
						remainTot = remainTot - Number(findTr.find("span[name='_MULTI_DAYS']").text().replace(/[^0-9.]/g, ""));
                    	//var vFirst_Day = $("span[name='_MULTI_DAYS']").eq(k).text();
                    	findTr.find("[name='_MULTI_TOTAL_DAYS']").text(remainTot);
                    }
        		}
        	}
        	
        }
        /*
        
        //휴가 전부 체크해서 잔여 휴가 재계산
        for (var i = 1; i < len; i++) {
        	//체크할 휴가 정보 찾기
            var vacationReserved3 = Number($('select[name=VACATION_TYPE]').eq(i).find("option:selected").attr("reserved3"));
            var VacKind = $('select[name=VACATION_TYPE]').eq(i).find("option:selected").val();
            var GroupCode= $('select[name=VACATION_TYPE]').eq(i).find("option:selected").attr("groupcode");
            
            var VacSdts = $("input[name='_MULTI_VACATION_SDT']").eq(i).val();
            var VacEdts = $("input[name='_MULTI_VACATION_EDT']").eq(i).val();
            var vFirst_S_Date = Number(VacSdts.replace("-", "").replace("-", ""));
            var vFirst_E_Date = Number(VacEdts.replace("-", "").replace("-", ""));
            var vRemainVacDay = 0;

            for (var j = 0; j < targetVacArr.length; j++) {
                var targetVacKind = targetVacArr[j].VacKind;
                var ExpSdate = Number(targetVacArr[j].ExpSdate);
                var ExpEdate = Number(targetVacArr[j].ExpEdate);
                targetVacArr[j].TotRemainVacDay = targetVacArr[j].RemainVacDay;
                
                if (vFirst_S_Date>=ExpSdate && vFirst_E_Date<=ExpEdate){
	                if (GroupCode  == "PUBLIC" && targetVacKind == "PUBLIC" ){
	                	$("#tblVacInfo tr:eq("+i+")").attr("vacIndex", j);
	                	$("#tblVacInfo tr:eq("+i+") [name='_MULTI_VAC_INDEX']").text(j);
	                	break;
	                }
	                else if(GroupCode  != "PUBLIC" && targetVacKind == GroupCode+"_"+VacKind){
	                	$("#tblVacInfo tr:eq("+i+")").attr("vacIndex", j);
	                	$("#tblVacInfo tr:eq("+i+") [name='_MULTI_VAC_INDEX']").text(j);
	                	vRemainVacDay = targetVacArr[j].RemainVacDay;
	                	break;
	                }
                }     
            }
            
            for (var k = 1; k < i; k++) {
            
            }
        }
        
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

                var vFirst_Day = $("span[name='_MULTI_DAYS']").eq(k).text();
                //console.log("vFirst_Day>"+vFirst_Day);
                if (vFirst_Day <= 0) {
                    continue;
                }

                if (vacationReserved3 < 1 && isExistVacationData(VacKind, vFirst_S_Date, vFirst_S_Date) === 0) {
                    Common.Warning("휴가 기간에 맞는 휴가 정보가 없습니다.");
                    $("input[name=_MULTI_VACATION_SDT]").eq(k).val("");
                    $("span[name=_MULTI_DAYS]").eq(k).text("0");
                    return;
                }
                if (vacationReserved3 === 1 && isExistVacationData(VacKind, vFirst_S_Date, vFirst_E_Date) === 0) {
                    Common.Warning("휴가 기간에 맞는 휴가 정보가 없습니다.");
                    $("input[name=_MULTI_VACATION_EDT]").eq(k).val("");
                    $("span[name=_MULTI_DAYS]").eq(k).text("0");
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
                            Common.Warning("휴가 기간에 맞는 휴가 정보가 없습니다.");
                            $("input[name=_MULTI_VACATION_SDT]").eq(k).val("");
                            $("span[name=_MULTI_DAYS]").eq(k).text("0");
                            return false;
                        }

                        if (remainTot < vacationReserved3) {
                            Common.Warning("(1)가능 휴가 기간 중 휴가일 수 가 초과 되었습니다.");
                            $("input[name=_MULTI_VACATION_SDT]").eq(k).val("");
                            $("span[name=_MULTI_DAYS]").eq(k).text("0");
                            return false;
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
                            Common.Warning("휴가 기간에 맞는 휴가 정보가 없습니다.");
                            $("input[name=_MULTI_VACATION_EDT]").eq(k).val("");
                            $("span[name=_MULTI_DAYS]").eq(k).text("0");
                            return false;
                        }

                        if (remainTot < (vacationReserved3 * vFirst_Day)) {
                            Common.Warning("(2)가능 휴가 기간 중 휴가일 수 가 초과 되었습니다.");
                            $("input[name=_MULTI_VACATION_EDT]").eq(k).val("");
                            $("span[name=_MULTI_DAYS]").eq(k).text("0");
                            return false;
                        }
                    }
                }//end if 1
            }//end for row vac
            vacReDays.text(""+remainTot+"-("+vacationReserved3+"*"+ vFirst_Day+"");
        }*/
    }
    EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
    return true;
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


function calculateEndTimeAndSetOffType(startTimeInput){
	var startTime = $(startTimeInput).val();
	if(startTime){
		var row = $(startTimeInput).parent().parent();
		var vacDays = Number(row.find("span[name='_MULTI_DAYS']").text().replace(/[^0-9.]/g, ""));
		var endTimeInput = $(startTimeInput).next("input");
		var startHour = parseInt(startTime.substring(0,2));
		var startMinutes = parseInt(startTime.substring(3));
		var endTime = new Date();
		endTime.setHours(startHour + WORK_HOUR * vacDays, startMinutes);
		var endHour = String(endTime.getHours()).padStart(2, "0");
		var endMinutes = String(endTime.getMinutes()).padStart(2, "0");
		endTimeInput.val(endHour+":"+endMinutes);
		
		$(row).find("[name=VACATION_OFF_TYPE]").val((startHour < 12) ? "AM" : "PM");
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

// 휴가 타입에 따른 row 수정
function initRowforVacationTypeChanged(vacationType){
    var vacationKindType = "";
	var selectedType = $(vacationType).find("option:selected");
    var reserved2 = selectedType.attr("reserved2");
    var reserved3 = Number(selectedType.attr("reserved3"));
    var changedRow = $(vacationType).parent();
	//var selectedValue = $(vacationType).find("option:selected").val();
    var remainVacDay = 0.0;
    /*
    targetVacArr = new Array();
    if(selectedValue!="0" && selectedValue != undefined) {
    	console.log("why set")
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
                , "VacDayProc": parseFloat(jsonVacKindData[i].VacDayProc)
                , "VacDay": parseFloat(jsonVacKindData[i].VacDay)
                , "ExpSdate": jsonVacKindData[i].Sdate
                , "ExpEdate": jsonVacKindData[i].Edate
            };
            targetVacArr.push(vacdata);
        }

    }*/
    initRowFields(changedRow);


    //잔여연차 존재 시 선연차 사용 금지
    //if (Number($("#USE_DAYS").text()) - Number($("#_MULTI_TOTAL_DAYS").text()) > 0.0) {
    if (vacationKindType==="PUBLIC" && remainVacDay - Number($("#_MULTI_TOTAL_DAYS").text()) > 0.0) {
		if(reserved2 == 1) { //선연차인지 비교
            alert("잔여 연차가 있을 경우 [" + $(vacationType).text() + "]를 선택하실 수 없습니다.");
            $(vacationType).val("");
            return;
        }
    }
    
    if(reserved3 < 1){
		$(changedRow).find("[name=_MULTI_DAYS]").text(reserved3);
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
    
    EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
}

function initRowFields(row){
    $(row).find("select[name='VACATION_OFF_TYPE']").val("0");
	$(row).find("input").val("");
	$(row).find("[name=_MULTI_DAYS]").text(0);
    EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
}

function setRowFieldsForVacationType(row) {
    var reserved3 = Number($(row).find("[name='_MULTI_DAYS']").text().replace(/[^0-9.]/g, "")) || 1;
    var offType = $(row).find("[name=VACATION_OFF_TYPE]");
    var endtimeWrapper = $(row).find(".endtimeWrapper");
    var timeWrapper = $(row).find(".timeWrapper");
    var groupcode = $(row).find("select[name=VACATION_TYPE]").find("option:selected").attr("groupcode");
    var vactype =  $(row).find("select[name=VACATION_TYPE]").val();
    
    timeWrapper.find("input").removeAttr("required");
	if(reserved3 < 1){
		endtimeWrapper.addClass(HIDDEN_CLASS);
		if(reserved3 === 0.5){
			//반차
			offType.removeClass(HIDDEN_CLASS);
			timeWrapper.addClass(HIDDEN_CLASS);
		} else {
			//시간차
			offType.addClass(HIDDEN_CLASS);
			timeWrapper.removeClass(HIDDEN_CLASS);
			timeWrapper.find("input").attr("required", true);
		}
	} else {
		//연차
		endtimeWrapper.removeClass(HIDDEN_CLASS);
		timeWrapper.addClass(HIDDEN_CLASS);
		offType.addClass(HIDDEN_CLASS);
	}
	
	for (var j = 0; j < targetVacArr.length; j++) {
		var targetVacKind = targetVacArr[j].VacKind;
		
		$(row).attr("vacIndex", -1);
		$(row).find("[name='_MULTI_VAC_INDEX']").text("-1");
		
		if (groupcode  == "PUBLIC" && targetVacKind == "PUBLIC" ){
			$(row).attr("vacIndex", j);
			$(row).find("[name='_MULTI_VAC_INDEX']").text(j);
			break;
		}
		else if(groupcode  != "PUBLIC" && targetVacKind == vactype){
			$(row).attr("vacIndex", j);
			$(row).find("[name='_MULTI_VAC_INDEX']").text(j);
			break;
		}
	}
	
	EASY.pattern(timeWrapper.find("input"), true);	    
}

function setRowFieldsForRewardVacationType(rewardType) {
	var selectedType = $(rewardType).find("option:selected");
    var changedRow = $(rewardType).parent();
    var reserved3 = Number(selectedType.val());
    
    initRowFields(changedRow);
    if(reserved3 < 1){
		$(changedRow).find("[name=_MULTI_DAYS]").text(reserved3);
    }
    setRowFieldsForVacationType(changedRow);
}

//USE_DAY 가져오는 함수 끝 여기서 부터 선연차, 선반차 가져오는 함수 시작해야함

var objTxtSelect;
function OpenWinEmployee(szObject) {
    objTxtSelect = document.getElementById(szObject);
    objTxtSelect.value = "";

    CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B9","",1000,580,"");
}

function Requester_CallBack(pStrItemInfo) {
    var oJsonOrgMap = $.parseJSON(pStrItemInfo);
    var I_Users = oJsonOrgMap.item;
    if(I_Users.length > 0){
		var deputy_names = [];
		var deputy_codes = [];
		var self_selected = false;
		for(var i = 0; i < I_Users.length; i++) {
		    var I_User = oJsonOrgMap.item[i];
		
		    if(I_User != undefined){
		        if (getInfo("AppInfo.usid") != I_User.AN) {
		            deputy_names.push(CFN_GetDicInfo(I_User.DN));
		            deputy_codes.push(I_User.UserCode);
		        }
		        else {
					self_selected = true;
		            
		        }
		    }
		}
		
		if(self_selected === true) {
			if(I_Users.length == 1){
				alert('직무대행자로 본인이 선택되었습니다.\r\n다시 선택하세요');
				return;
			}else if(I_Users.length > 1){
				alert('직무대행자로 본인이 포함되어 있습니다.\r\n본인은 제외됩니다.');
			}
		}
        objTxtSelect.value = CFN_GetDicInfo(deputy_names.join(", ")); // DEPUTY_NAME
        document.getElementById("DEPUTY_CODE").value = deputy_codes.join(", "); // DEPUTY_CODE
	}
}

//기간 체크
function TermCheck() {
    var ret = true;
    var len = $("input[name=_MULTI_VACATION_SDT]").length;

    for (var i = 1; i < len; i++) {
        if (!ret) {
            break;
        }

        var vFirst_S_Date = new Date($("input[name=_MULTI_VACATION_SDT]").eq(i).val().replaceAll("-", "/"));
        var vFirst_E_Date = new Date($("input[name=_MULTI_VACATION_EDT]").eq(i).val().replaceAll("-", "/"));
        var vFirst_Day = Number($("span[name=_MULTI_DAYS]").eq(i).text().replace(/[^0-9.]/g, ""));
        var vFirst_S_Option = '';
		var vFirst_S_Time = '';
		var vFirst_E_Time = '';

		if(vFirst_Day===0.5){ // 반차인 경우 오전(0000~1200) , 오후(1200~2400) 전체시간으로 중복체크
			vFirst_S_Option = $("input[name=_MULTI_VACATION_SDT]").eq(i).siblings('select[name=VACATION_OFF_TYPE]').val();
			if(vFirst_S_Option == "AM"){
				vFirst_S_Time = 0;
				vFirst_E_Time = 1200;	
			}else if(vFirst_S_Option == "PM"){
				vFirst_S_Time = 1200;
				vFirst_E_Time = 2400;
			}
		}else if(vFirst_Day<0.5) {
			vFirst_S_Time = $("input[name=_MULTI_VACATION_SDT]").eq(i).closest("tr").find("input[name=_MULTI_VACATION_STIME]").val();
			if(vFirst_S_Time) vFirst_S_Time = Number(vFirst_S_Time.replaceAll(":", ""));
			vFirst_E_Time = $("input[name=_MULTI_VACATION_SDT]").eq(i).closest("tr").find("input[name=_MULTI_VACATION_ETIME]").val();
			if(vFirst_E_Time) vFirst_E_Time = Number(vFirst_E_Time.replaceAll(":", ""));
		}
		
        for (var j = i + 1; j < len; j++) {
            var vSecon_S_Date = new Date($("input[name=_MULTI_VACATION_SDT]").eq(j).val().replaceAll("-", "/"));
            var vSecon_E_Date = new Date($("input[name=_MULTI_VACATION_EDT]").eq(j).val().replaceAll("-", "/"));
            var vSecon_Day = Number($("span[name=_MULTI_DAYS]").eq(j).text().replace(/[^0-9.]/g, ""));
            var vSecon_S_Option = '';
			var vSecon_S_Time = 0;
			var vSecon_E_Time = 0;
            
            if(vSecon_Day===0.5){
				vSecon_S_Option = $("input[name=_MULTI_VACATION_SDT]").eq(j).siblings('select[name=VACATION_OFF_TYPE]').val();
				if(vSecon_S_Option == "AM"){
					vSecon_S_Time = 0;
					vSecon_E_Time = 1200;	
				}else if(vSecon_S_Option == "PM"){
					vSecon_S_Time = 1200;
					vSecon_E_Time = 2400;
				}
			}else if(vSecon_Day<0.5){
				vSecon_S_Time = $("input[name=_MULTI_VACATION_SDT]").eq(j).closest("tr").find("input[name=_MULTI_VACATION_STIME]").val();
				if(vSecon_S_Time) vSecon_S_Time = Number(vSecon_S_Time.replaceAll(":", ""));
				vSecon_E_Time = $("input[name=_MULTI_VACATION_SDT]").eq(j).closest("tr").find("input[name=_MULTI_VACATION_ETIME]").val();
				if(vSecon_E_Time) vSecon_E_Time = Number(vSecon_E_Time.replaceAll(":", ""));
			} 
   	
			if (vFirst_S_Date <= vSecon_E_Date && vFirst_E_Date >= vSecon_S_Date){ // 날짜 중복 체크
				if(vFirst_Day <= 0.5 && vSecon_Day <= 0.5 && !(vFirst_S_Time < vSecon_E_Time && vFirst_E_Time > vSecon_S_Time)){ // 시간 중복 체크
				}else{
        			ret = false;
                	break;
        		}
            }
        }
    }

    return ret;
}

function getVacationData() {
	CFN_CallAjax("/groupware/vacation/getVacationData.do", 
	{
		"UR_CODE":document.getElementById("InitiatorCodeDisplay").value,
		"year":document.getElementById("Sel_Year").value
	}, function (data){ 
    	 receiveHTTPGetData(data);
	}, false, 'json');
}

function receiveHTTPGetData(responseData) {
	var vacday = "", atot = "0.0", appday = "", appdayca = "", useday = "", procday = "";
	var elmlist = responseData.Table;
	$(elmlist).each(function () {
	    vacday = this.VacDay; //총 연차
	    atot = this.RemainVacDay; //잔여연차
//	    appday = this.VacDayUse //신청연차
//	    appdayca = this.DAYSCAN //취소연차
	    useday = this.VacDayUse; //사용연차
		procday = this.VacDayProc; //승인대기중연차
	});

    if (vacday === "") {
        Common.Warning("해당 년도의 연차 사용 가능 일수가 등록되지 않았습니다. 관리자에게 문의하세요."); //잔여휴가일이 없습니다. 기안할 수 없습니다.
        $("#VAC_DAYS").text("0 일");
        $("#USE_DAYS").text("0");
    } else {
		atot = Number(atot);
		vacday = Number(vacday);
		useday = Number(useday);
		procday = Number(procday);

		if (atot <= 0 || vacday - useday < 0 || vacday - atot < 0) {
	        Common.Warning(Common.getDic("msg_apv_NoVacDaysAskAdmin")); //"잔여 연차가 없습니다. 관리자에게 문의 하시기 바랍니다.") 
        }
        
        var vacDaysText = vacday + " 일 (사용 연차 : " + useday + ")";
		var procDaysText = "";
		
        if(appVacProcessCheck === "SUM" || appVacProcessCheck === "REJECT"){
        	procDaysText = $("#PRC_DAYS").text() != "" ? $("#PRC_DAYS").text() : " (승인중 : "+ procday +")";
        	
        	$("#PRC_DAYS").text(procDaysText).show();
        }
        
	    $("#VAC_DAYS").text(vacDaysText);
        $("#USE_DAYS").text(atot);
        $("#VACATION_DAY").val(atot);
	}
}

function loadVacationInfo(){
    var params = new Object();
    var nowYear = $("#Sel_Year").val();
	var schUserCode = getInfo("AppInfo.usid");
    
    if((formJson.Request.mode == "APPROVAL" || formJson.Request.mode == "REDRAFT") && getInfo("Request.editmode") == 'Y' && $("#InitiatorCodeDisplay").val()) {
    	schUserCode = $("#InitiatorCodeDisplay").val();
    }
    
    params = {
        "year" : ""+nowYear,
        "schTypeSel" : "userCode",
        "schTxt" : schUserCode
    };

    $.ajax({
        type : "POST",
        data : params,
        async: false,
        url : "/groupware/vacation/getVacationListByKind.do",
        success: function (list) {
            vacationKindData = JSON.stringify(list.list);
            $("#extraTable tbody").html("");
            var data = list.list;
            if(data.length>0){
                $.each(data, function(i, v) {
                	if ((v.VacKind=="PUBLIC" && v.CurYear == "Y") || v.RemainVacDay>0){
	                    var row = $("<tr class='VacationRow "+(v.CurYear == "Y"?" ERBoxbg":"")+"' data-VacKind='"+v.VacKind+"'>")
	//                        .append($("<td>",{"style":"font-size: 12px;width:80px;text-align: center;"}).text(v.Year))
	                        .append($("<td>",{"style":"font-size: 12px;width:107px;text-align: center;"}).text((v.VacKind=="PUBLIC"?v.Year+" ":"")+v.VacName))
	                        .append($("<td>",{"style":"font-size: 12px;width:50px;text-align: center;"}).text(v.VacDay))
	                        .append($("<td>",{"style":"font-size: 12px;width:50px;text-align: center;"}).text(v.RemainVacDay+((appVacProcessCheck === "SUM" || appVacProcessCheck === "REJECT")?"("+v.VacDayProc+")":"")))
	                        .append($("<td>",{"style":"font-size: 12px;width:140px;text-align: center;"}).text(v.ExpDate))
	                        .append($("<td>",{"style":"font-size: 12px;width:140px;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;","title":v.Reason}).text(v.Reason!=null?v.Reason:""));
	                    $("#extraTable tbody").append(row);
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
            }else{
                var row = "<tr class='VacationRow'><td colspan='5' style='text-align: center;'>"+Common.getDic("msg_apv_NoVacDaysAskAdmin")+"</td></tr>";
                $("#extraTable tbody").html(row);
            }

        },
        error:function(response, status, error) {
            CFN_ErrorAjax( "/groupware/vacation/getVacationListByKind.do", response, status, error);
        }
    });

}