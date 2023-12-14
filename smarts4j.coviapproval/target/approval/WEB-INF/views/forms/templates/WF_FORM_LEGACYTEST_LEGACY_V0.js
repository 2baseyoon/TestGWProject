//양식별 다국어 정의 부분
// 다국어처리 
var localLang_ko = {
    localLangItems: {
    	lbl_formsample: '샘플ko', 
        lbl_formlanguage: '다국어ko'
    }
};

var localLang_en = {
    localLangItems: {
    	lbl_formsample: '샘플en', 
        lbl_formlanguage: '다국어en'
    }
};

var localLang_ja = {
    localLangItems: {
    	lbl_formsample: '샘플ja', 
        lbl_formlanguage: '다국어ja'
    }
};

var localLang_zh = {
    localLangItems: {
    	lbl_formsample: '샘플zh', 
        lbl_formlanguage: '다국어zh'
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
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.SI_LEGACYTEST_LEGACY_BTRIP_COST), 'json', '#SI_LEGACYTEST_LEGACY_BTRIP_COST', 'R');            
        } else {
            XFORM.multirow.load('', 'json', '#SI_LEGACYTEST_LEGACY_BTRIP_COST', 'R');
        }
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }
        // 멀티로우처리
        if (JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyContext.SI_LEGACYTEST_LEGACY_BTRIP_COST), 'json', '#SI_LEGACYTEST_LEGACY_BTRIP_COST', 'W');
        } else {
            XFORM.multirow.load('', 'json', '#SI_LEGACYTEST_LEGACY_BTRIP_COST', 'W', { minLength: 1 }); //minLength 값에따라 로딩시 기본행 수 셋팅함 
        }
        setTimeout("calcData()", 1000); // 합계/기간계산 xeasy로드후
    }
    
    //readonly로 수정불가능하게
    $('input[type="text"], textarea').prop('readonly', true);
    $('input[data-pattern="date"]').attr('disabled', true);
    $('select').attr('disabled', true);
    $('.multi-row-control').css('display', 'none');
    //첨부파일 숨기기
    document.getElementById("tbFormAttach").style.display = "none";
    document.getElementById("tbLinkInfo").style.display = "none";
    document.getElementById("attachTitle").style.display = "none";
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
    var bodyContextObj = {};
    bodyContextObj["BodyContext"] = getFields("mField");
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("SI_LEGACYTEST_LEGACY_BTRIP_COST", "rField")); // 멀티로우처리
    return bodyContextObj;    
}


//멀티로우추가처리 
XFORM.multirow.event('afterRowAdded', function ($rows) { //멀티로우 [추가버튼] 실행 시 
	console.log("행추가! - 총" + $('#SI_LEGACYTEST_LEGACY_BTRIP_COST').find('tr.multi-row').length + "행"); 
}); 
XFORM.multirow.event('afterRowRemoved', function ($rows) { //멀티로우 [삭제버튼] 실행 시 
	console.log("행삭제! - 총" + $('#SI_LEGACYTEST_LEGACY_BTRIP_COST').find('tr.multi-row').length + "행"); 
}); 

// 합계/기간계산 xeasy로드후
function calcData(){
	$("#img_calc").trigger("click"); // 합계계산
	$("#BT_E_DATE").trigger("change"); // 기간계산	
}

