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
        
    }else {
    	$('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

    	if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
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
        if (document.getElementById("Subject").value == '') {
            Common.Warning('제목을 입력하세요.');
            //SUBJECT.focus();
            return false;
        } else if (document.getElementById("SaveTerm").value == '') {
            Common.Warning('보존년한을 선택하세요.');
            return false;
        } else {
        	// 필수 입력 필드 체크 
            return EASY.check().result;
        }
    }
}

function setBodyContext(sBodyContext) {
}

function makeBodyContext() {
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    return bodyContextObj;
}



