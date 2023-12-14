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
    	/*var trnum = $("#TBL_CALL_INFO tr").length;
    	for(var j=3; j< trnum;j++){
    		var obj = $("#TBL_CALL_INFO tr:eq("+j+")"); 

    		var userCode = obj.find("input[name=UserCode]").val();
    		var companyCode = obj.find("input[name=CompanyCode]").val();
    		var targetDate =obj.find("input[name=CallDate]").val();
    		var division =obj.find("select[name=Division]").val();
    		
    		if(userCode != undefined && targetDate != undefined && division== ""){
    			Common.Warning('구분을 선택하세요.');
        		return false;
    		}
    	}*/
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
	$$(bodyContextObj["BodyContext"]).append("Subject", document.getElementById("Subject").value); 
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("TBL_CALL_INFO", "rField"));
    return bodyContextObj;
}

//신청서 오픈 시 파라미터 세팅해주기
function setParameterValue(){
	if(CFN_GetQueryString("TargetDate") != "undefined"){  //parameter가 있을 때
		$("input[name=CallDate]").val(CFN_GetQueryString("TargetDate"));		
		if(CFN_GetQueryString("CommuteType")==1){  //출근
			$("select[name=Division] option:eq(1)").attr("selected","selected");
		}else{  //퇴근
			$("select[name=Division] option:eq(2)").attr("selected","selected");
		}
		
		//제목 설정
		//var date = new Date(CFN_GetQueryString("TargetDate")).format('MM/dd');		
		//$("#Subject").val("소명 신청서_"+Common.getSession('UR_Name')+"("+date+")");		

	    BeforeCommuteTime($("input[name=CallDate]"));
	}
	
}

//조직도 팝업
var empobj;
var objTr;
function OpenWinEmployee(obj) {
	empobj=obj;
	objTr = $(obj).closest("tr");
	$(objTr).find("input[name=UserName]").val("");
	$(objTr).find("input[name=UserCode]").val("");
	$(objTr).find("input[name=CompanyCode]").val("");
    
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=B9", "조직도", 1000, 580, "");
}

function Requester_CallBack(pStrItemInfo) {
	var oJsonOrgMap = $.parseJSON(pStrItemInfo);
	
	$.each(oJsonOrgMap.item, function(i, v) {
		if(i == 0) {
			$(objTr).find("input[name=UserName]").val(CFN_GetDicInfo(v.DN));
			$(objTr).find("input[name=UserCode]").val(v.UserCode);
			$(objTr).find("input[name=CompanyCode]").val(v.ETID);
		} else {
			XFORM.multirow.addRow($('#TBL_CALL_INFO'));
			
			var addTr = $('#TBL_CALL_INFO').find(".multi-row").last();
			$(addTr).find("input[name=UserName]").val(CFN_GetDicInfo(v.DN));
			$(addTr).find("input[name=UserCode]").val(v.UserCode);
			$(addTr).find("input[name=CompanyCode]").val(v.ETID);
		}
	});
	
	setSubject();
	BeforeCommuteTime(empobj);
}

// 첫행 날짜,근무자로 제목 셋팅
function setSubject(obj){
	var sUserName = $("#TBL_CALL_INFO").find(".multi-row").eq(0).find("[name='UserName']").val();
	if(!sUserName) sUserName = CFN_GetDicInfo(getInfo("AppInfo.usnm"));
	
	var sDate = $("#TBL_CALL_INFO").find(".multi-row").eq(0).find("[name='CallDate']").val();
	sDate = (sDate) ? sDate : "";
	if(sDate.length == 8) sDate = sDate.substring(0,4) + "-" + sDate.substring(4,6) + "-" + sDate.substring(6,8);
	var date = new Date(sDate);
	if(!isNaN(date)) $("#Subject").val(CFN_GetDicInfo(getInfo("FormInfo.FormName"))+"_"+sUserName+"("+date.format('MM/dd')+")");
	else $("#Subject").val(CFN_GetDicInfo(getInfo("FormInfo.FormName"))+"_"+sUserName);
	
	if(obj) BeforeCommuteTime(obj);
}

function ChangeMin(obj){
	$(obj).val(pad($(obj).val(), 2));	
}

function pad(n, width) {
	  n = n + '';
	  return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
}

function BeforeCommuteTime(obj){
	$(obj).closest("tr").find("input[name=BeforeTime]").val(""); //값 비워주기
	
	var userCode = $(obj).closest("tr").find("input[name=UserCode]").val();
	var companyCode = $(obj).closest("tr").find("input[name=CompanyCode]").val();
	var targetDate = $(obj).closest("tr").find("input[name=CallDate]").val();
	var division = $(obj).closest("tr").find("select[name=Division]").val();
	
	if(userCode != undefined && targetDate != undefined && division != ""){
		CFN_CallAjax("/approval/legacy/attendanceCommuteTime.do", {"UserCode":userCode, "CompanyCode":companyCode, "TargetDate":targetDate, "Division":division}, function (data){
			if(data.status == "SUCCESS"){
				if(data.commuteTime != undefined){
					var commDate = data.commuteTime.split(" ")[0];
					var commTime = data.commuteTime.split(" ")[1].split(":");
					
					$(obj).closest("tr").find("input[name=BeforeTime]").val(commDate+" "+commTime[0]+":"+commTime[1]);
				}
			} else{
				Common.Warning("오류가 발생했습니다.");
				return false;
			}
		}, false, 'json');
	}
	
}
