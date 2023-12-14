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
        if(typeof formJson.BodyContext.TBLINFO != 'undefined'){
        	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBLINFO), 'json', '#TBLINFO', 'R');
        }else{
        	XFORM.multirow.load('', 'json', '#TBLINFO', 'R');
        }
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
        if(JSON.stringify(formJson.BodyContext) != "{}" && typeof formJson.BodyContext.TBLINFO != 'undefined'){
        	XFORM.multirow.load(JSON.stringify(formJson.BodyContext.TBLINFO), 'json', '#TBLINFO', 'W');

        	// 모바일 내 멀티로우 체크박스 사용을 위한 처리
        	mobile_approval_setMultiCheckAndRadio();
        }else{
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
	var bodyContextObj = {};
	bodyContextObj["BodyContext"] = getFields("mField");
    $$(bodyContextObj["BodyContext"]).append(getMultiRowFields("TBLINFO", "rField"));
    return bodyContextObj;
}

//수량, 단가에 따른 금액 계산
function fn_sum(pObj) {
    var m_index = $("input[name='" + pObj.name + "']").index(pObj);
    var currentRowPrice = parseInt($("input[name='REQ_PRICE']").eq(m_index).val()) * parseInt($("input[name='REQ_EA']").eq(m_index).val());
    var totalPrice = 0;
    
    $("input[name='REQ_TOTAL']").eq(m_index).val(currentRowPrice);
    
    $('#TBLINFO').find(".multi-row").find("input[name='REQ_TOTAL']").each(function (i, obj) {
    	totalPrice += parseInt($(obj).val() == "" ? 0 :$(obj).val());
    });
    
    $('#REQ_TOTALPRICE').val(totalPrice);
}

//멀티로우 행 추가 시 이벤트
XFORM.multirow.event('afterRowAdded', function ($rows) {
	// 멀티로우 체크박스, 라디오 추가
	mobile_approval_addMultiCheckAndRadio($rows);
});

//멀티로우 행 삭제 시 이벤트
XFORM.multirow.event('afterRowRemoved', function () {
	// 멀티로우 체크박스, 라디오 시퀀스 다시 세팅
	mobile_approval_setMultiCheckAndRadio();

    // 전체선택 체크 해제
    $(".multi-row-select-all").prop("checked", false);
    $(".multi-row-select-all").checkboxradio('refresh');
});