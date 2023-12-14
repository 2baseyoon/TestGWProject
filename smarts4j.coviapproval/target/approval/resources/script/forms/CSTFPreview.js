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
	postJobForDynamicCtrl();

	removePreviewEvent(); // 양식스토어 미리보기용 이벤트 제거 (개별양식에는 class remove-cstf 사용시 제거됨)
	
    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });    
         
        // 있는 멀티로우 모두 로드
		$(".multi-row-table").each(function(idx,item){
			var table_id = $(item).attr("id");
			if (JSON.stringify(formJson.BodyContext) != "{}") {
				XFORM.multirow.load(JSON.stringify(formJson.BodyContext[table_id]), 'json', '#' + table_id, 'R');            
			} else {
				XFORM.multirow.load('', 'json', '#' + table_id, 'R');
			}
		});

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

		// 에디터 로드
		if($("#divWebEditorContainer").length > 0) LoadEditor("divWebEditorContainer");
		
		// 있는 멀티로우 모두 로드
		$(".multi-row-table").each(function(idx,item){
			var table_id = $(item).attr("id");
			if (JSON.stringify(formJson.BodyContext) != "{}") {
				XFORM.multirow.load(JSON.stringify(formJson.BodyContext[table_id]), 'json', '#' + table_id, 'W');            
			} else {
				XFORM.multirow.load('', 'json', '#' + table_id, 'W', { minLength: 1 });
			}
		});
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpdn_apv"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm_multi"), false);
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
	
	// mFiled
	bodyContextObj["BodyContext"] = getFields("mField");
    // 에디터
	if($("#divWebEditorContainer").length > 0){
		var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
		$$(bodyContextObj["BodyContext"]).append(editorContent);
	}
    // 멀티로우
	$(".multi-row-table").each(function(idx,item){
		var table_id = $(item).attr("id");
		$$(bodyContextObj["BodyContext"]).append(getMultiRowFields(table_id, "rField")); // 멀티로우처리
	});
	// smField
	//$$(bodyContextObj["BodyContext"]).append(getFields("smField"));
	
    return bodyContextObj;    
}

//양식스토어 미리보기용 이벤트 제거 (개별양식에는 class remove-cstf 사용시 제거됨)
function removePreviewEvent(){
	// 메뉴영역 붎필요항목 먼저 삭제
	$("#div_formmenu input[type='button'],#divMenu02,#divMenuRight").not("#btExitPreView,#btPreView").remove();
	
	// 이벤트 제거 (양식 개발시 앱스토어 미리보기에서 이벤트 제거할 영역은 class "remove-cstf"추가)
	var $target = $(".remove-cstf,.remove-cstf *"); 
	
	var arr_event = ["onclick","onchange","onkeydown","onkeypress","onkeyup","onblur","onfocus","onmousedown","onsubmit"
		,"ondragstart","ondragenter","ondrag","ondragover","ondragend","ondragleave","ondrop"];
	
	$target.unbind().css("cursor","auto");
	$.each(arr_event,function(){
		$target.removeAttr(this);
	});
}
