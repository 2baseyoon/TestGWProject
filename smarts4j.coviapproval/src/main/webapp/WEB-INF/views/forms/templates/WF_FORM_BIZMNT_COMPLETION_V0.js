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

    $("#btDocLinked").css("display", "none"); // 상단 연결문서 버튼 숨김
	$("#tbLinkInfo").css("display", "none"); // 연결문서, 첨부파일 표시 숨김
	$("#attachTitle").css("display", "none"); // 첨부파일 컨트롤 숨김
	$("#tbFormAttach").css("display", "none");
    
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
        //LoadEditor("divWebEditorContainer");
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

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
        if (document.getElementById("Subject").value == '') {
            Common.Warning('제목을 입력하세요.');
            //SUBJECT.focus();
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
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	
    var bodyContextObj = {};
	var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
    return bodyContextObj;
}

/**
 * 2022.04) 종료보고 프로젝트 비용 상세 팝업
 */
function approvalPopProjectCost(menuId, projId) {
	var str = "/bizmnt/report/goProjCostDetailPopup.do?menuId={0}&projId={1}&showTab={2}";
	var url = String.format(str, menuId, projId, "fromEndProject");
	openMaximizeWinPop(url, '프로젝트 비용 상세', 1);
}

function approvalPopManInputStat(menuId, projId) {
	var str = "/bizmnt/wbs/goWeeklyPopup.do?menuID={0}&projId={1}&showTab={2}";
	var url = String.format(str, menuId, projId, "fromEndProject");
    openMaximizeWinPop(url, '투입 현황표', 2);
}

function openMaximizeWinPop(url, name, type) {
	if(type == 1){
		var iWidth = screen.width;
		var iHeight = screen.height - 90;
		var options = 'top=0, left=0, width=' + iWidth + ', height=' + iHeight + ' status=no, location=no, menubar=no, toolbar=no, scrollbars=yes, resizable=yes';
		var popup = window.open(url, name, options);
		popup.moveTo(0,0);
		popup.resizeTo(screen.availWidth*0.7, screen.availHeight*0.95);
	}else{
		var iWidth = screen.width;
		var iHeight = screen.height - 90;
		var options = 'top=0, left=0, width=' + iWidth + ', height=' + iHeight + ' status=no, location=no, menubar=no, toolbar=no, scrollbars=yes, resizable=yes';
		var popup = window.open(url, name, options);
		popup.moveTo(0,0);
		popup.resizeTo(screen.availWidth, screen.availHeight);
	}
}