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
        
        $('[data-mode="writeOnly"][class="multi-row-selector-wrap"]').remove();

        //멀티로우 처리
        if (typeof formJson.BodyContext != 'undefined' && JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.MULTI_TABLE), 'json', '#MULTI_TABLE', 'R');
        } else {
            XFORM.multirow.load('', 'json', '#MULTI_TABLE', 'R');
        }

        if (typeof formJson.BodyContext != 'undefined' && JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.MULTI_SUM_TABLE), 'json', '#MULTI_SUM_TABLE', 'R');
        } else {
            XFORM.multirow.load('', 'json', '#MULTI_SUM_TABLE', 'R');
        }

        if (JSON.stringify(formJson.BodyData) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyData.SubTable1), 'json', '#SubTable1', 'R');            
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'R');
        }
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        //<!--AddWebEditor-->
        LoadEditor("divWebEditorContainer");

        //멀티로우 처리
        if (typeof formJson.BodyContext != 'undefined' && JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.MULTI_TABLE), 'json', '#MULTI_TABLE', 'W');
        } else {
            XFORM.multirow.load('', 'json', '#MULTI_TABLE', 'W', { minLength: 1, maxLength: 10 });
        }

        if (typeof formJson.BodyContext != 'undefined' && JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.MULTI_SUM_TABLE), 'json', '#MULTI_SUM_TABLE', 'W');
        } else {
            XFORM.multirow.load('', 'json', '#MULTI_SUM_TABLE', 'W', { minLength: 1, maxLength: 10 });
        }

        if (JSON.stringify(formJson.BodyData) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyData.SubTable1), 'json', '#SubTable1', 'W');            
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'W', { minLength: 1, maxLength: 10 });
        }
        
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
	
    var bodyContextObj = {};
	var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
	
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("MULTI_TABLE", "rField"));
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("MULTI_SUM_TABLE", "rField"));
	
    return bodyContextObj;
}

//조직도 유형
//A0 - 직원 조회용(2열)
//B1 - 사용자 선택(3열-1명만)
//B9 - 사용자 선택(3열-여러명)
//C1 - 그룹 선택(3열-1개만)
//C9 - 그룹 선택(3열-여러개)
//D1 - 사용자/그룹 선택(3열-1개만)
//D9 - 사용자/그룹 선택(3열-여러개)
var objTxtSelect;
function OpenWinEmployee(szObject) {
	objTxtSelect = document.getElementById(szObject);
	objTxtSelect.value = "";
	 
	var sType = "B1";
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=Requester_CallBack&type=" + sType,"<spring:message code='Cache.lbl_apv_org'/>",1000,580,"");
}

function Requester_CallBack(pStrItemInfo) {
	var oJsonOrgMap =  $.parseJSON(pStrItemInfo);
	
	if(oJsonOrgMap.item.length < 1) return;
	
	var I_User = oJsonOrgMap.item[0];
	objTxtSelect.value = CFN_GetDicInfo(I_User.DN);
	//CFN_GetDicInfo(I_User.PO.split("&")[1]); //직위
	//CFN_GetDicInfo(I_User.TL.split("&")[1]); //직책
	//CFN_GetDicInfo(I_User.LV.split("&")[1]); //직급
}

