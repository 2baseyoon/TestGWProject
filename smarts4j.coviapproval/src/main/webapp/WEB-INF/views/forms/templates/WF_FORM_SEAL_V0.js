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
	var content = $("#divFormContent");
	var defaultPrefix = "WF_FORM_SEAL_";
	var mngDept = getInfo("FormInfo.FormPrefix").replace(defaultPrefix, "");
	if(getInfo("FormInfo.FormPrefix") === mngDept) mngDept = "";
	else mngDept += ";";
	
	['SealGubun', 'Situation', 'Uses'].forEach(function(item){
		var codes = Common.getBaseCode(defaultPrefix + item);
		var bRead = getInfo("Request.templatemode") === "Read";
		if(codes.CacheData && codes.CacheData.length > 0){
			content.find("#" + item).append(codes.CacheData.map(function(code){
				var bOption = false;
				if(code.Reserved2 === "Y" && !bRead){
					if((!mngDept || (code.Reserved1 && code.Reserved1.indexOf(mngDept) > -1)) && code.IsUse === "Y"){
						bOption = true;	
					}
				} else if(bRead || (!bRead && code.IsUse === "Y")){
					bOption = true;
				}
				
				if(bOption) return $("<option>", { value: code.Code, text : code.CodeName });
			}));
		}		
	});
	
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
     
        //<!--loadMultiRow_Write-->
        
        // 전자계약 선택 시 공인인증서 자동 선택
        content.find("#Situation").on("change", function(){
			if(this.value === "ElectronicContract")
				content.find("#SealGubun").val("Acc_cert");
		});        
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
    return bodyContextObj;
}
