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
            
            $.ajax({
            	url : "/covicore/control/GetBaseObjectInfo.do"
                ,type : "POST"
                ,data : {
                	fields : "UserCode,ENTERDATE"
                    ,mode : "UR"
                    ,objId : Common.getSession("UR_Code")
                }
                ,success : function (data) {
                	$("#EnterDate").val( data.result.list[0].ENTERDATE );
                }
            });
        }
     
        //<!--loadMultiRow_Write-->
    }
}

function setLabel() {
}

function setFormInfoDraft() {
}
function diffDate() {
    var SDATE = $("input[name=StartDate]").val().split('-');
    var EDATE = $("input[name=EndDate]").val().split('-');

    var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
    var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
    var tmpday = EOBJDATE - SOBJDATE;
    tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
    
    if (tmpday < 0) {
    	;
    	$(tmpObj).find("input[name=_MULTI_VACATION_EDT]").val("");
    	$(tmpObj).find("input[name=_MULTI_DAYS]").val("");
    	EASY.triggerFormChanged(); //전체 기간 합산일수의 재계산
    }
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