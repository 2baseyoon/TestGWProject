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
        $("input[name*='CallTime']").css("display","");
        
        //<!--loadMultiRow_Read-->
        if (JSON.stringify(formJson.BodyContext) != "{}" && formJson.BodyContext != undefined) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_CALL_INFO), 'json', '#TBL_CALL_INFO', 'R');
        }
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

            $("input[name=UserName]").val(Common.getSession("UR_Name"));  //m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"))
            $("input[name=UserCode]").val(Common.getSession("UR_Code"));
            $("input[name=CompanyCode]").val(Common.getSession("DN_Code"));
            
            setParameterValue();
        }
     
        //<!--loadMultiRow_Write-->
        if (JSON.stringify(formJson.BodyContext) != "{}" && JSON.stringify(formJson.BodyContext) != undefined) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBL_CALL_INFO), 'json', '#TBL_CALL_INFO', 'W');

        	// 모바일 내 멀티로우 체크박스 사용을 위한 처리
        	mobile_approval_setMultiCheckAndRadio();
        } else {
            XFORM.multirow.load('', 'json', '#TBL_CALL_INFO', 'W', { minLength: 1 });
        }

		//제목설정
		if(formJson.Request.mode == "DRAFT"){
			setSubject();
		}
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
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
	$$(bodyContextObj["BodyContext"]).append("Subject", document.getElementById("Subject").value); 
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("TBL_CALL_INFO", "rField"));
    return bodyContextObj;
}

//신청서 오픈 시 파라미터 세팅해주기
function setParameterValue(){
	if(getParam('TargetDate')){  //parameter가 있을 때
		$("input[name=CallDate]").val(getParam('TargetDate'));		
		if(getParam('CommuteType')==1){  //출근
			$("select[name=Division] option:eq(1)").attr("selected","selected");
		}else{  //퇴근
			$("select[name=Division] option:eq(2)").attr("selected","selected");
		}
		
		//제목 설정
		//var date = new Date(getParam('TargetDate')).format('MM/dd');		
		//$("#approval_write_Subject").val("소명 신청서_"+Common.getSession('UR_Name')+"("+date+")");
		mobile_approval_changeSelectBox($("#approval_write_Subject"));
	}	
}

//url에서 parameter값 가져오기
function getParam(name) {
    var params = location.search.substr(location.search.indexOf("?") + 1);
    var value = "";
    params = params.split("&");
    for (var i = 0; i < params.length; i++) {
        var temp = params[i].split("=");
        if (temp[0] == name) { value = temp[1]; }
    }
    return value;
}


//조직도 팝업
var objTr;
function OpenWinEmployee(obj) {
	var sUrl = "/covicore/mobile/org/list.do";
	
	objTr = $(obj).closest("tr");
	
	$(objTr).find("input[name=UserName]").val("");
	$(objTr).find("input[name=UserCode]").val("");
	$(objTr).find("input[name=CompanyCode]").val("");
	 
	window.sessionStorage["mode"] = "SelectUser"; //SelectUser:사용자 선택(3열-1명만),Select:그룹 선택(3열-1개만)
	window.sessionStorage["multi"] = "Y";
	window.sessionStorage["callback"] = "Requester_CallBack();";
	
	mobile_comm_go(sUrl, 'Y');
}

function Requester_CallBack() {
	var pStrItemInfo = '{"item":[' + window.sessionStorage["userinfo"] + ']}';
	var oJsonOrgMap = $.parseJSON(pStrItemInfo);
	var oTR = objTr;
	
	$.each(oJsonOrgMap.item, function(i, v) {
		if(i > 0) {
			XFORM.multirow.addRow($('#TBL_CALL_INFO'));
			oTR = $('#TBL_CALL_INFO').find(".multi-row-selector").last().closest("tr");
		}

		$(oTR).find("input[name=UserName]").val(mobile_comm_getDicInfo(v.DN));
		$(oTR).find("input[name=UserCode]").val(v.UserCode);
		$(oTR).find("input[name=CompanyCode]").val(v.ETID);
	});
	
	setSubject();
}

//첫행 날짜,근무자로 제목 셋팅
function setSubject(obj){
	var sUserName = $("#TBL_CALL_INFO").find(".multi-row").find("[name='UserName']").eq(0).val();
	if(!sUserName) sUserName = CFN_GetDicInfo(getInfo("AppInfo.usnm"));
	
	var sDate = $("#TBL_CALL_INFO").find(".multi-row").find("[name='CallDate']").eq(0).val();
	sDate = (sDate) ? sDate : "";
	if(sDate.length == 8) sDate = sDate.substring(0,4) + "-" + sDate.substring(4,6) + "-" + sDate.substring(6,8);
	var date = new Date(sDate);
	if(!isNaN(date)) {
		var sMonth = String(date.getMonth() + 1).padStart(2, "0");
  		const sDay = String(date.getDate()).padStart(2, "0");
		$("#approval_write_Subject").val(CFN_GetDicInfo(getInfo("FormInfo.FormName"))+"_"+sUserName+"("+sMonth+"/"+sDay+")");
	}else {
		$("#approval_write_Subject").val(CFN_GetDicInfo(getInfo("FormInfo.FormName"))+"_"+sUserName);	
	}
	
	mobile_approval_changeSelectBox($("#approval_write_Subject"));
	
	if(obj) {
		if($("select[name=Division]").val().length>0){
            BeforeCommuteTime();
        }	
	}
	
}

function ChangeMin(obj){
	$(obj).val(pad($(obj).val(), 2));	
}

function pad(n, width) {
	  n = n + '';
	  return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
}

function ChangeDivi(obj){
    $("select[name=Division]").val($(obj).val());
    if($("input[name=CallDate]").val().length>0){
        BeforeCommuteTime();
    }
}

function BeforeCommuteTime(){
    var division = $("select[name=Division]").val();
    var userCode = $("input[name=UserCode]").val();
    var companyCode = $("input[name=CompanyCode]").val();
    var targetDate =  $("input[name=CallDate]").val();

    if(userCode != undefined && targetDate != undefined && division != ""){
        CFN_CallAjax("/approval/legacy/attendanceCommuteTime.do", {"UserCode":userCode, "CompanyCode":companyCode, "TargetDate":targetDate, "Division":division}, function (data){
            if(data.status == "SUCCESS"){
                if(data.commuteTime != undefined){
                    var commDate = data.commuteTime.split(" ")[0];
                    var commTime = data.commuteTime.split(" ")[1].split(":");
                    var bfTime   = commDate+" "+commTime[0]+":"+commTime[1];
                    $("input[name=BeforeTime]").val(bfTime);
                }else{
                    $("input[name=BeforeTime]").val("");
                }

            } else{
                Common.Warning("오류가 발생했습니다.");
                return false;
            }
        }, false, 'json');
    }else{
        $("input[name=BeforeTime]").val("");
    }

}

//멀티로우 행 추가 시 이벤트
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