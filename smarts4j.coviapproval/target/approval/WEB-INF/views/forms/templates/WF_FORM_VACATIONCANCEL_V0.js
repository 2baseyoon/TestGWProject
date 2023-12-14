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

var vacday = "", atot = "", appday = "", appdayca = "", useday = "";
var HIDDEN_CLASS = "hidden";
var VACATION_TABLE = "tblVacInfo";
var WORK_HOUR = 8;
var dayOffList;

//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {    
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
        
		$("[name=VACATION_OFF_TYPE]").removeClass(HIDDEN_CLASS);
		
        if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'R', { minLength: 1 });

            // [2016-01-05] gbhwang 'VACATION_OTHER|VACATION_OTHER'와 같이 VACATION_TYPE의 값이 배열인 경우 '연차'로 보이는 오류 수정
            if (typeof formJson.BodyContext.tblVacInfo.VACATION_TYPE != 'String') {
                $("span[name=VACATION_TYPE]").html(formJson.BodyContext.tblVacInfo.VACATION_TYPE_TEXT);
            }
         } else {
            XFORM.multirow.load('', 'json', '#tblVacInfo', 'R');
        }
    } else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("InitiatorCodeDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usid"), false);
            document.getElementById("InitiatedDate").value = formJson.AppInfo.svdt; // 재사용, 임시함에서 오늘날짜로 들어가게함.
            
            if (window.location.href.indexOf("RequestFormInstID") != "undefined") {
                // [2017-01-10 add]
                $("#HID_REQUEST_FIID").val(CFN_GetQueryString("RequestFormInstID"));
                getVacationRequestDate();
            } else {
                if (formJson.Request.mode == "DRAFT" && formJson.Request.gloct == "") {
                    XFORM.multirow.load("", 'json', '#tblVacInfo', 'W', { minLength: 1 });
                }
                else if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
                    XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W', { minLength: 1 });
                }
            }
        	getVacationData();
        } else if (JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext != 'undefined') {
            // [2016-01-05 add] gbhwang 수신부서 내용변경하는 경우 select box값이 로딩되지 않으므로 호출
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.tblVacInfo), 'json', '#tblVacInfo', 'W', { minLength: 1 });

            // [2016-01-05 add] gbhwang 'VACATION_OTHER|VACATION_OTHER'와 같이 VACATION_TYPE의 값이 배열인 경우 '연차'로 보이는 오류 수정
            if (typeof formJson.BodyContext.tblVacInfo.VACATION_TYPE != 'String') {
                $("select[name=VACATION_TYPE]").val(formJson.BodyContext.tblVacInfo.VACATION_TYPE[0]);
            }
        }
        
        $("select[name=VACATION_OFF_TYPE] option[value='0']").text("선택");
    }
    
	if (window.location.href.indexOf("RequestFormInstID") != "undefined" || JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
	    $("#"+ VACATION_TABLE+" tr.multi-row").each(function(){
			setRowFieldsForVacationType(this)
		});
	} else {
		$("#"+ VACATION_TABLE+" tr.multi-row select[name='VACATION_TYPE']").each(function(){
			initRowforVacationTypeChanged(this)
		});
	}
	
    function makeVacationTypeSelect() {
		var useBefore = isBeforeAnnualMember();
        var tarType = $('select[name="VACATION_TYPE"]');
        var oCodeList = Common.getBaseCode("VACATION_TYPE");
        $(oCodeList.CacheData).each(function() {
            if (!(!useBefore && this.Reserved2 === "1")) {
                tarType.append($('<option/>', {
                    value: this.Code,
                    text: CFN_GetDicInfo(this.MultiCodeName),
                    reserved1: this.Reserved1,
                    reserved2: this.Reserved2,
                    reserved3: this.Reserved3
                }));
            }
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

function isBeforeAnnualMember(){
	var useBefore = false;
	try {
		if (Common.getBaseConfig("BeforeAnnualMember").indexOf(getInfo("AppInfo.usid") + ";") > -1) {
			useBefore = true;
	    }
	    if (Common.getBaseConfig("BeforeAnnualMember").indexOf("ALL@" + ";") > -1) {
	    	useBefore = true;
	    }
		
		if (getInfo("Request.templatemode") == "Read") {
			useBefore = true;
		}
	} catch(e) { coviCmn.traceLog(e); }
    return useBefore;
}

function setLabel() {
}

function setFormInfoDraft() {
}

function checkForm(bTempSave) {
	var returnBol = false;
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
	
    if (bTempSave) {
        return true;
    } else {
    	if(document.getElementsByName("_MULTI_VACATION_SDT").length <= 1){
    		Common.Warning("휴가 기간을 입력해주세요.");
    		return false;
    	}
    	
    	// [2017-01-04 add] gbhwang 연차, 반차, 선연차, 선반차 외 사용 연차가 없어도 기안 가능하도록 조건 체크
        var canDraft = true; // 기안 가능 여부
        
        $(".multi-row").find("select[name='VACATION_TYPE'] option:selected").each(function () {
			if($(this).attr("reserved1") == "+"){
				canDraft = false;
				return false;
			}
        });
        
/*        // [2017-01-05 add] gbhwang 사용할 연차의 연도와 휴가 신청 기간의 연도 비교
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
            Common.Warning("취소할 연차의 연도와 입력하신 기간의 연도가 상이합니다.");
            return false;
        }
*/
        // 필수 입력 필드 체크
        if ($("#USE_DAYS").val() == "" || parseFloat($("#USE_DAYS").val()) > parseFloat($("#TotalVac").val())) {
        	$("select[name=VACATION_TYPE]").each(function(){
				if ($(this).attr("reserved1") == "+") {
                    Common.Warning("총 연차일을 초과하였습니다. ");
                    return false;
                }
            });
        }
        // [2017-01-04 gbhwang] 연차, 반차, 선연차, 선반차 제외 경우 사용 연차가 없어도 기안 가능하도록 조건 추가
        else if (parseInt(useday) == 0 && !canDraft) {
        	var noVacation = false;
        	$("select[name=VACATION_TYPE]").each(function(){
				if ($(this).attr("reserved1") == "+") {
                	noVacation = true;
                }
			});
        	if(noVacation){
	            Common.Warning("연차와 반차에 대해서, 해당 년도의 연차 취소 가능 일수가 없습니다.");
	            return false;
        	}
        }
        if (TermCheck()) {
        	if(EASY.check().result){
				returnBol = checkVacationDup(getBodyContext().BodyContext.tblVacInfo);
	        	/* // 휴가기간이 중복되어 있는지 Validation 체크
	        	var tblVacInfo = getBodyContext().BodyContext.tblVacInfo;
	            if(tblVacInfo != undefined){
	            	//legacy/getVacationInfo.do
	            	if(tblVacInfo.length == undefined)
	            		tblVacInfo = [tblVacInfo];
	            	
					var userCode = "";
					if(formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") userCode = formJson.AppInfo.usid;
					else if(formJson.FormInstanceInfo && formJson.FormInstanceInfo.InitiatorID) userCode = formJson.FormInstanceInfo.InitiatorID;
		
	            	CFN_CallAjax("/groupware/vacation/getVacationInfo.do", {"vacationInfo":JSON.stringify(tblVacInfo), "chkType" : "CANCEL", "userCode" : userCode}, function (data){
	    	           	 if(data.status == "SUCCESS"){
	    	           		 var dupVac = data.dupVac;
	    	           		 if(dupVac.length > 0){
	    	           			 var messageStr = "";
	    	           			 
	    	           			 $(dupVac).each(function(){
	    	           				messageStr += " '"+ this._MULTI_VACATION_SDT +" ~ "+ this._MULTI_VACATION_EDT +"',";
	    	           			 });
	    	           			 messageStr = messageStr.substring(0, messageStr.length-1);
	    	           			 messageStr += " 기간에 이미 휴가가 취소되었거나, 휴가일이 아닌 일자가 존재합니다.";
	    	           			 
	    	           			 Common.Warning(messageStr);
	    	           			 returnBol = false; 
	    	           		 }else{
	    	           			returnBol = true;
	    	           		 }
	    	           	 }else{
	    	           		 Common.Warning();
	    	           		 returnBol = false;
	    	           	 }
	    	       	}, false, 'json');
	            }*/
        	
        	}
        }
        else {
            alert("입력하신 기간 확인 후 기안 하시기 바랍니다.");
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
    	//legacy/getVacationInfo.do
    	if(tblVacInfo.length == undefined)
    		tblVacInfo = [tblVacInfo];
    	
		var userCode = "";
		if(formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") userCode = formJson.AppInfo.usid;
		else if(formJson.FormInstanceInfo && formJson.FormInstanceInfo.InitiatorID) userCode = formJson.FormInstanceInfo.InitiatorID;

    	CFN_CallAjax("/groupware/vacation/getVacationInfo.do", {"vacationInfo":JSON.stringify(tblVacInfo), "chkType" : "CANCEL", "userCode" : userCode}, function (data){
           	 if(data.status == "SUCCESS"){
           		 var dupVac = data.dupVac;
           		 if(dupVac.length > 0){
           			 var messageStr = "";
           			 
           			 $(dupVac).each(function(){
           				messageStr += " '"+ this._MULTI_VACATION_SDT +" ~ "+ this._MULTI_VACATION_EDT +"',";
           			 });
           			 messageStr = messageStr.substring(0, messageStr.length-1);
           			 messageStr += " 기간에 이미 휴가가 취소되었거나, 휴가일이 아닌 일자가 존재합니다.";
           			 
					 if(formJson.Request.isMobile == "Y" || _mobile) alert(messageStr);
					 else Common.Warning(messageStr);
				
           			 returnBol = false; 
           		 }else{
           			returnBol = true;
           		 }
           	 }else{
           		 Common.Warning();
           		 returnBol = false;
           	 }
       	}, false, 'json');
    }

	return returnBol;
}
	
function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
   
   	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("tblVacInfo", "rField"));
    return bodyContextObj;
}

function getVacationRequestDate() {
	CFN_CallAjax("/approval/legacy/getFormInstData.do", {"FormInstID":$("#HID_REQUEST_FIID").val()}, function (data){ 
		receiveHTTPData(data); 
	}, false, 'json');
}

function receiveHTTPData(responseData) {
    var errorNode = responseData.error;
    if (errorNode != null && errorNode != undefined) {
        Common.Error("Desc: " + $(errorNode).text());
    } else {
        $(responseData.Table).each(function () {
            setVacationRequestDate(this.BodyContext);
        });
    }
}

function setVacationRequestDate(pData) {
	var jsonObj = $.parseJSON(Base64.b64_to_utf8(pData));
	$("#Sel_Year").val(jsonObj.Sel_Year);
	var ones = $$(Base64.b64_to_utf8(pData)).remove("tblVacInfo").json();

    // 최 하위노드를 찾아서 mField 에 매핑
    getLastNode(ones);

    //멀티로우 Table 값 매핑
    XFORM.multirow.load(JSON.stringify(jsonObj.tblVacInfo), "json", "#tblVacInfo", 'W');
}

function getLastNode(obj) {
	for(var key in obj){
		if($$(obj).find(key).valLength()>0){
			getLastNode($$(obj).find(key).json());
		}else{
			$("[id=" + key.toUpperCase() + "]").val($$(obj).attr(key));
	        $("[id=" + key.toUpperCase() + "]").text($$(obj).attr(key));
		}
	}
}

//기간에 대한 validation 처리 추가
function validateVacDate() {

    $('#tblVacInfo').on('change', '.multi-row [name=_MULTI_VACATION_EDT]', function () {
        var sdt = $(this).prev().prev().val().replace(/-/g, '');
        var edt = $(this).val().replace(/-/g, '');

        if (Number(sdt) > Number(edt)) {
            Common.Warning("시작일 보다 종료일이 먼저일 수 없습니다");
            $(this).val('');
            $(this).parent().find('[name=_MULTI_DAYS]').val(''); //입력된 기간 일수 제거
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

// 휴가 타입에 따른 row 수정
function initRowforVacationTypeChanged(vacationType){	
	var selectedType = $(vacationType).find("option:selected");
    var reserved2 = Number(selectedType.attr("reserved2"));
    var reserved3 = Number(selectedType.attr("reserved3"));
	var changedRow = $(vacationType).parent();
	
    initRowFields(changedRow);
    
    //잔여연차 존재 시 선연차 사용 금지
    if (Number($("#USE_DAYS").text()) - Number($("#_MULTI_TOTAL_DAYS").text()) > 0.0) {
		if(reserved2===1) { //선연차인지 비교
            alert("잔여 연차가 있을 경우 [" + $(vacationType).text() + "]를 선택하실 수 없습니다.");
            $(vacationType).val("");
            return;
        }
    }
    
    if(reserved3 < 1){
		$(changedRow).find("[name=_MULTI_DAYS]").text(reserved3);
    }
    setRowFieldsForVacationType(changedRow);
    EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
}

function initRowFields(row){
    $(row).find("select[name='VACATION_OFF_TYPE']").val("0");
	$(row).find("input").val("");
	$(row).find("[name=_MULTI_DAYS]").text(0);
    EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
}

function setRowFieldsForVacationType(row) {
    var reserved3 = Number($(row).find("[name='_MULTI_DAYS']").text()) || 1;
    var offType = $(row).find("[name=VACATION_OFF_TYPE]");
    var endtimeWrapper = $(row).find(".endtimeWrapper");
    var timeWrapper = $(row).find(".timeWrapper");
    
    timeWrapper.find("input").removeAttr("required");
	if(reserved3 < 1){
		endtimeWrapper.addClass(HIDDEN_CLASS);
		if(reserved3 === 0.5){
			offType.removeClass(HIDDEN_CLASS);
			timeWrapper.addClass(HIDDEN_CLASS);
		} else {
			offType.addClass(HIDDEN_CLASS);
			timeWrapper.removeClass(HIDDEN_CLASS);
			timeWrapper.find("input").attr("required", true);
		}
	} else {
		endtimeWrapper.removeClass(HIDDEN_CLASS);
		timeWrapper.addClass(HIDDEN_CLASS);
		offType.addClass(HIDDEN_CLASS);
	}
	
	EASY.pattern(timeWrapper.find("input"), true);	    
}

function calSDATEEDATE(obj) {
	var selectedTr = $(obj).parents("tr").eq(0);
	var vacationType = selectedTr.find("select[name=VACATION_TYPE]");
	
	if(!vacationType.val()){
		var index = $("#"+VACATION_TABLE+" select[name=VACATION_TYPE]").index(vacationType);
		alert(index + "번째 휴가 유형이 입력되지 않았습니다.");
		$(obj).val("");
	}
	
	var reserved3 = selectedTr.find("select option:selected").attr("reserved3") || "1";
    
	var startDate = selectedTr.find("input[name=_MULTI_VACATION_SDT]");
	var endDate = selectedTr.find("input[name=_MULTI_VACATION_EDT]");
	var vacDays = selectedTr.find("[name=_MULTI_DAYS]");
	
    if (reserved3 != "0.5" && startDate.val() && endDate.val()) {
        var SDATE = startDate.val().split('-');
        var EDATE = endDate.val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        if (tmpday < 0) {
            alert("이전 일보다 전 입니다. 확인하여 주십시오.");
            endDate.val("");
            vacDays.text("0");
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
    } else if (Number(reserved3) < 1 && Number(reserved3) > 0) {
        endDate.val(startDate.val());
        vacDays.text(reserved3);
    }
    
    EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
}

function calculateEndTimeAndSetOffType(startTimeInput){
	var startTime = $(startTimeInput).val();
	if(startTime){
		var row = $(startTimeInput).parent().parent();
		var vacDays = Number(row.find("span[name='_MULTI_DAYS']").text());
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
    var elmlist = responseData.Table;

    $(elmlist).each(function () {
	    vacday = this.VacDay; //총 연차
	    atot = this.RemainVacDay; //잔여연차
//	    appday = this.VacDayUse //신청연차
//	    appdayca = this.DAYSCAN //취소연차
	    useday = this.VacDayUse; //사용연차
        if (atot == "") atot = "0.0";
    });

    $("#TotalVac").val(atot);
    if (vacday == "") {
        //Common.Warning("해당 년도의 연차 사용 가능 일수가 등록되지 않았습니다. 관리자에게 문의하세요."); //잔여휴가일이 없습니다. 기안할 수 없습니다.
        $("[id=VAC_DAYS]").text("0 일");
        $("[id=USE_DAYS]").text("0");
    } else {
		atot = Number(atot);
		vacday = Number(vacday);
		useday = Number(useday);
		
		var vacDaysText = vacday + " 일 (사용 연차 : " + useday + ")";
    	/*if (useday == 0) {
            Common.Warning("취소할 사용 연차가 없습니다.1");
	    }*/
    	
	    $("#VAC_DAYS").text(vacDaysText);
        $("#USE_DAYS").text(atot);
	} 
}

//기간 체크
function TermCheck() {
    var vFirst_S = '';
    var vFirst_E = '';
    var vSecon_S = '';
    var vSecon_E = '';

    var ret = true;

    var len = $("input[name=_MULTI_VACATION_SDT]").length;


    for (var i = 1; i < len; i++) {

        if (!ret) {
            break;
        }

        vFirst_S = $("input[name=_MULTI_VACATION_SDT]").eq(i).val(); //첫번째 행 시작일
        var vFirst_S_Year = vFirst_S.split("-")[0];
        var vFirst_S_Mon = vFirst_S.split("-")[1];
        var vFirst_S_day = vFirst_S.split("-")[2];
        var vFirst_S_Date = new Date(vFirst_S_Year, Number(vFirst_S_Mon)-1, vFirst_S_day);

        vFirst_E = $("input[name=_MULTI_VACATION_EDT]").eq(i).val(); //첫번째 행 종료일
        var vFirst_E_Year = vFirst_E.split("-")[0];
        var vFirst_E_Mon = vFirst_E.split("-")[1];
        var vFirst_E_day = vFirst_E.split("-")[2];
        var vFirst_E_Date = new Date(vFirst_E_Year, Number(vFirst_E_Mon)-1, vFirst_E_day);
        
        var vFirst_Day = $("span[name=_MULTI_DAYS]").eq(i).text();
        var vFirst_S_Option = '';     

        for (var j = i + 1; j < len; j++) {
            vSecon_S = $("input[name=_MULTI_VACATION_SDT]").eq(j).val();
            var vSecon_S_Year = vSecon_S.split("-")[0];
            var vSecon_S_Mon = vSecon_S.split("-")[1];
            var vSecon_S_day = vSecon_S.split("-")[2];
            var vSecon_S_Date = new Date(vSecon_S_Year, Number(vSecon_S_Mon)-1, vSecon_S_day);

            vSecon_E = $("input[name=_MULTI_VACATION_EDT]").eq(j).val();
            var vSecon_E_Year = vSecon_E.split("-")[0];
            var vSecon_E_Mon = vSecon_E.split("-")[1];
            var vSecon_E_day = vSecon_E.split("-")[2];
            var vSecon_E_Date = new Date(vSecon_E_Year, Number(vSecon_E_Mon)-1, vSecon_E_day);
            
            var vSecon_Day = $("span[name=_MULTI_DAYS]").eq(j).text();
            var vSecon_S_Option = '';
            
            if(vFirst_Day==0.5)	vFirst_S_Option = $('select[name=VACATION_OFF_TYPE]').eq(i).val();
            if(vSecon_Day==0.5)	vSecon_S_Option = $('select[name=VACATION_OFF_TYPE]').eq(j).val();
            if(vFirst_Day==0.125) vFirst_S_Option = $("input[name=_MULTI_VACATION_STIME]").eq(i).val();
            if(vSecon_Day==0.125) vSecon_S_Option = $("input[name=_MULTI_VACATION_STIME]").eq(j).val();
            
            if (
           (vSecon_S_Date <= vFirst_S_Date && vSecon_E_Date >= vFirst_E_Date) ||
           (vSecon_S_Date <= vFirst_E_Date && vSecon_E_Date >= vFirst_E_Date) ||
           (vSecon_S_Date >= vFirst_S_Date && vSecon_E_Date <= vFirst_E_Date) ||
           (vSecon_S_Date <= vFirst_S_Date && vSecon_E_Date >= vFirst_E_Date)) {
            	if(vFirst_Day==0.5 && vSecon_Day==0.5 && vFirst_S_Option!=vSecon_S_Option){
        			
        		}else if(vFirst_Day==0.125 && vSecon_Day==0.125 && vFirst_S_Option!=vSecon_S_Option){
        			
        		}else{
        			ret = false;
        			break;
        		}
            }
        }
    }
    return ret;
}