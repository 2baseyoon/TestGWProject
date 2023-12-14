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
			if(formJson.Request.mode == "DRAFT") addTypeToSubject();
			
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
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
        // 필수 입력 필드 체크
        if( !EASY.check().result ) {
        	return false;
        }
        
        // 첨부파일 1개이상 필수체크
        if ($("#fileInfo").children().find("input[type=checkbox]").length == 0) {
			Common.Warning('첨부파일을 추가해주세요.');
            return false;
        }
        
        return true;
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

function addTypeToSubject(){
	var strAdd = $("#LETTER_TYPE :selected").text();
	if(strAdd){
		strAdd = "[" + strAdd + "]";
		var strSubject = $("#Subject").val();
		if(strSubject && strSubject.indexOf("[") > -1 && strSubject.indexOf("]") > -1){
			var strDel = strSubject.substring(strSubject.indexOf("["),strSubject.indexOf("]") + 1);
			strSubject = strSubject.replace(strDel,strAdd);
		}else{
			strSubject = strAdd + strSubject;
		}
		$("#Subject").val(strSubject);
	}
}
