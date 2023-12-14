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

//양식별 후처리를 위한 필수 함수 - 삭제 시 오류 발생
function postRenderingForTemplate() {
    //debugger;
    //공통영역
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        LoadEditor('divWebEditorContainer');

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }
        else {

        }
        
    }

    //setLabel과 setBodyContext 정리 후 상단으로 이동

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
	/*
    var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + "<tbContentElement><![CDATA[" + document.getElementById("dhtml_body").value + "]]></tbContentElement>" + getFields("mField") + "</BODY_CONTEXT>";
    return sBodyContext;
    */
	
    var bodyContextObj = {};
	var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
    return bodyContextObj;
}