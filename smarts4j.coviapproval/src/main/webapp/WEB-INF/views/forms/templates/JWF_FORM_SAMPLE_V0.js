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
        
        // 멀티로우처리
        //<!--loadMultiRow_Read-->
        if (JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.multi_table), 'json', '#multi_table', 'R');            
        } else {
            XFORM.multirow.load('', 'json', '#multi_table', 'R');
        }

        if (JSON.stringify(formJson.BodyData) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyData.SubTable1), 'json', '#SubTable1', 'R');            
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'R');
        }

        $(".removeRead").remove();
        
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터처리
        //<!--AddWebEditor-->
        LoadEditor("divWebEditorContainer");
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }
     
        // 멀티로우처리
        //<!--loadMultiRow_Write-->
        //if (typeof formJson.BODY_CONTEXT != 'undefined') { 
        if (JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.multi_table), 'json', '#multi_table', 'W');
        } else {
            XFORM.multirow.load('', 'json', '#multi_table', 'W', { minLength: 1 }); // minLength 값에따라 로딩시 기본행 수 셋팅함 
        }

        if (JSON.stringify(formJson.BodyData) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyData.SubTable1), 'json', '#SubTable1', 'W');            
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'W', { minLength: 1 });
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

//본문 XML로 구성
function makeBodyContext() {
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	
    var bodyContextObj = {};
	
    // 에디터처리
    var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("multi_table", "rField")); // 멀티로우처리
	
	$$(bodyContextObj["BodyContext"]).append(getFields("smField"));
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("SubTable1", "stField"));
	
    return bodyContextObj;    
}


//멀티로우추가처리 추가/삭제 콜백 
XFORM.multirow.event('afterRowAdded', function ($rows) { //멀티로우 [추가버튼] 실행 시 
alert("행추가! - 총" + $('#multi_table').find('tr.multi-row').length + "행a"); 
}); 
XFORM.multirow.event('afterRowRemoved', function ($rows) { //멀티로우 [삭제버튼] 실행 시 
alert("행삭제! - 총" + $('#multi_table').find('tr.multi-row').length + "행b"); 
}); 

