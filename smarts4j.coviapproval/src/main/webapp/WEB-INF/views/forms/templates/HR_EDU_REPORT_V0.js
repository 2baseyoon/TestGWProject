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

			
        }

		getRequestData();
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
	$$(bodyContextObj["BodyContext"]).append("eduTime", $("#eduTime").val()); 
	$$(bodyContextObj["BodyContext"]).append("docSeq", CFN_GetQueryString('docSeq')!='undefined'? CFN_GetQueryString('docSeq') : null); 
	$$(bodyContextObj["BodyContext"]).append("procId", CFN_GetQueryString('procId')!='undefined'? CFN_GetQueryString('procId') : null); 
	$$(bodyContextObj["BodyContext"]).append("UserCode", Common.getSession('USERID')); 
	$$(bodyContextObj["BodyContext"]).append("CompanyCode", Common.getSession('DN_Code')); 
    return bodyContextObj;
}

function calSDATEEDATE(obj) {
    var tmpObj = obj;
    while (tmpObj.tagName != "TR") {
        tmpObj = tmpObj.parentNode; 
    }
    if ($(tmpObj).find("input[id=SDATE]").val() != "" && $(tmpObj).find("input[id=EDATE]").val() != "") {
        var SDATE = $(tmpObj).find("input[id=SDATE]").val().split('-');
        var EDATE = $(tmpObj).find("input[id=EDATE]").val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        if (tmpday < 0) {
            alert("이전 일보다 전 입니다. 확인하여 주십시오.");
            $(tmpObj).find("input[id=SDATE]").val("");
            $(tmpObj).find("input[id=EDATE]").val("");
        }
        else {
            $("#NIGHTS").val(tmpday);
            $("#DAYS").val(tmpday + 1);
        }
    }
}

function getRequestData(){
	var params = {
		 docSeq : CFN_GetQueryString('docSeq')!='undefined'? CFN_GetQueryString('docSeq') : null
		,procId : CFN_GetQueryString('procId')!='undefined'? CFN_GetQueryString('procId') : null
	}
	$.ajax({
		type:"POST",
		dataType   : 'json',
		data: params,
		url:"/hrmanage/hrEdu/getEduData.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				var eduMap = data.eduMap;
				$("#eduName").val(eduMap.EDU_NM);
				$("#SDATE").val(eduMap.EDU_START_DATE);
				$("#EDATE").val(eduMap.EDU_END_DATE);
				$("#eduTime").val(eduMap.EDU_TIME);
				$("#eduAgency").val(eduMap.EDU_CENTER);
				$("#SDATE").change();
				
				$("#eduIns").val(eduMap.EDU_INS);
				$("#eduContent").val(eduMap.EDU_CONTENT);
				
			}else{
				alert(data.message);
				window.close();
			}
		}
	}); 
}