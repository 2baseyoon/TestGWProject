﻿//양식별 다국어 정의 부분
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
        
        //<!loadMultiRow_Read>
		if (typeof formJson.BodyContext != 'undefined') {
            //멀티로우
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBLINFO), 'json', '#TBLINFO', 'R');
        }
        //쓰기모드
        if (formJson.BodyContext != null && formJson.BodyContext.TBLINFO != null) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBLINFO), 'json', '#TBLINFO', 'R');
        } else {
            XFORM.multirow.load('', 'json', '#TBLINFO', 'W', { minLength: 1 });
        }
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        //<!AddWebEditor>
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }
     
        //<!loadMultiRow_Write>
        if (formJson.BodyContext != null && formJson.BodyContext.TBLINFO != null) {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBLINFO), 'json', '#TBLINFO', 'W');
        } else {
            XFORM.multirow.load('', 'json', '#TBLINFO', 'W', { minLength: 1 });
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
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("TBLINFO", "rField"));
    return bodyContextObj;
}

function fn_setVAT() {
    $('#TBLINFO').find(".multi-row").not(".pattern-skip").each(function (i) {
    	$("input[name=VAT]").eq(i + 1).val($("input[name=SUPPLY]").eq(i + 1).val()/10);
    });
    fn_setTOTAL();
}

function fn_setTOTAL() {
	var price = 0;
    $('#TBLINFO').find(".multi-row").not(".pattern-skip").each(function (i) {
    	$("input[name=TOTAL]").eq(i + 1).val(parseFloat($("input[name=SUPPLY]").eq(i + 1).val())+parseFloat($("input[name=VAT]").eq(i + 1).val()));
        price += parseFloat($("input[name=TOTAL]").eq(i + 1).val());
    });
    
    $('#TOTAL_SUM').val(price);
}