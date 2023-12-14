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
        if (JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.JWF_DRAFT_LEGACY_TARGET_SAMPLEMULTI), 'json', '#JWF_DRAFT_LEGACY_TARGET_SAMPLEMULTI', 'R');            
        } else {
            XFORM.multirow.load('', 'json', '#JWF_DRAFT_LEGACY_TARGET_SAMPLEMULTI', 'R');
        }
		$(".removeRead").remove();

    }else {
    	$('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

    	if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
			// EASY.init(); 이후 합계,기간계산 실행
			if(formJson.Request.mode == "DRAFT") calcData(); 
        }
    	
		// 멀티로우처리
        if (JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.JWF_DRAFT_LEGACY_TARGET_SAMPLEMULTI), 'json', '#JWF_DRAFT_LEGACY_TARGET_SAMPLEMULTI', 'W');
        } else {
            XFORM.multirow.load('', 'json', '#JWF_DRAFT_LEGACY_TARGET_SAMPLEMULTI', 'W', { minLength: 1 }); 
        }
    }
    
	// 외부연동시 html 표시 영역
    if (formJson.BodyContext.JSONHtml) $('#legacyHtml').html($('#JSONHtml').val()); //외부연동 시 사용하는 div
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
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("JWF_DRAFT_LEGACY_TARGET_SAMPLEMULTI", "rField")); // 멀티로우처리
    return bodyContextObj;
}

// EASY.init(); 이후 합계,기간계산 실행
var itv_calcData;
function calcData(){
	try {
		 itv_calcData = setInterval(function(){
			if($("#BT_E_DATE").hasClass("pattern-active")){
				$("#btnPeriod").trigger("click"); // 기간계산
				$("#btnCalc").trigger("click"); // 합계계산
				clearInterval(itv_calcData);
			}				
		 }, 1000);
	 } catch (e) {
		 clearInterval(itv_calcData);
	 }	
}




