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
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            
            $("#hidUR_Code").val(getInfo("AppInfo.usid")); // 기안자 UR_Code 세팅
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
        if (document.getElementById("Subject").value == '') {
            Common.Warning('제목을 입력하세요.');
            //SUBJECT.focus();
            return false;
        } else if (document.getElementById("SaveTerm").value == '') {
            Common.Warning('보존년한을 선택하세요.');
            return false;
        } else {
            return EASY.check().result;
        }
    }
}
function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	
    var bodyContextObj = {};
	var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
    return bodyContextObj;
}

function calSDATEEDATE(obj) {
    var tmpObj = $(obj).closest("tr");

    if ($(tmpObj).find("input[id=SDATE]").val() != "" && $(tmpObj).find("input[id=EDATE]").val() != "") {
        var SDATE = $(tmpObj).find("input[id=SDATE]").val().split('-');
        var EDATE = $(tmpObj).find("input[id=EDATE]").val().split('-');

        var SOBJDATE = new Date(parseInt(SDATE[0], 10), parseInt(SDATE[1], 10) - 1, parseInt(SDATE[2], 10));
        var EOBJDATE = new Date(parseInt(EDATE[0], 10), parseInt(EDATE[1], 10) - 1, parseInt(EDATE[2], 10));
        var tmpday = EOBJDATE - SOBJDATE;
        tmpday = parseInt(tmpday, 10) / (1000 * 3600 * 24);
        if (tmpday < 0) {
            alert("이전 일보다 전 입니다. 확인하여 주십시오.");
            $(obj).val("");
        }
        else if(tmpday >= 92) { // 최대 3개월까지 신청가능.(31 + 30 + 31일인 경우 고려하여 92일)
        	alert("사용기간은 최대 3개월까지 신청 가능합니다.");
            $(obj).val("");
        }
    }
}

function fn_displayTR() {
	if($("#VDI_TYPE").val() == "DEL" || formJson.BodyContext.VDI_TYPE == "DEL") {
		$("#termTR").hide();
	}
	else {
		$("#termTR").show();
	}
}
