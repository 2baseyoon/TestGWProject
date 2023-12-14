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

    // 오프라인은 헤더부분 첫번 행 제거
    // 문서유통을 통해 접수할 경우 헤더부분 첫번째 두번째 모두 제거
    $("#TIT_DOC_NO").parent("tr").css("display", "none");
    if (formJson.BodyContext != undefined) {
        if (formJson.BodyContext.HidIsOffline == undefined || formJson.BodyContext.HidIsOffline == "N") {
            $("#TIT_INITIATOR_OU").parent("tr").css("display", "none");
            $("#TIT_DOC_CLASS").parent("tr").find("td").css("border-top", "1px solid #c3d7df");
        }
    }

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
        LoadEditor("divWebEditorContainer");
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);

            if (getInfo("doclisttype") == "20") {
                $("#HidIsOffline").val("Y");
            }
            else {
                $("#HidIsOffline").val("N");
            }
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
	var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
    return bodyContextObj;
}