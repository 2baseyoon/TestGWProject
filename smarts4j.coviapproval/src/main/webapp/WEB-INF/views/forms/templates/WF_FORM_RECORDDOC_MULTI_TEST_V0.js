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
    	
    	var divLen = $$($.parseJSON(XFN_ChangeOutputValue(document.getElementById("APVLIST").value))).find("steps").find("division").valLength();
		if(formJson.Request.isMobile != "Y" && (divLen == 1 || formJson.Request.mode == "REDRAFT"))
			displayDocInfo();
		$('#tblFormSubject').hide();

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        var idx = $("#writeTab li.on").attr("idx");
        LoadEditor("divWebEditorContainer1", idx);
        
        //<!--loadMultiRow_Read-->

    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        // 에디터 처리
        //<!--AddWebEditor-->
        //LoadEditor("divWebEditorContainer");
        LoadEditor("divWebEditorContainer1", 1);
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

        	document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            
            document.getElementById("DRAFTER_ID").value = getInfo("AppInfo.usid");
            document.getElementById("DRAFTER_NAME").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
            document.getElementById("DRAFTER_DEPT").value = getInfo("AppInfo.dpid");
            document.getElementById("DRAFTER_DEPTNM").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
        }
     
        //<!--loadMultiRow_Write-->
    }
    
    // 발송대기메뉴 && (실패||대기) --> 수동발송 버튼 활성화
    if (getInfo("Request.govstate") === "SENDWAIT" && ["wait","fail"].indexOf(CFN_GetQueryString("docType")) > -1){
    	$("#btGovDocsSend").show();
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
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("SubTable1", "stField"));
    return bodyContextObj;
}


function chkdocInfo(obj){
	if(getInfo("Request.templatemode") != "Read" || getInfo("Request.mode") == "REDRAFT"){
		var idx = '1';
		var id = $(obj).attr("id");
		var savedVal = "";
		
		if(id == "RELEASE_CHECK") {//공개여부
			savedVal = $(obj).val(); //$(obj).find('input:checked').val();
			
			if(savedVal == "1"){
				$("#RELEASE_CHECK").val(savedVal);
				$("#chk_secrecy").prop("checked", false);
				$("#RELEASE_CODE").hide();
			}else{
				$("#RELEASE_CHECK").val(savedVal);
				$("#chk_secrecy").prop("checked", "checked");
				$("#RELEASE_CODE").show();
			}
			document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
			$(obj).val(savedVal);
		}
		else if(id == "RELEASE_CHECK_rec") {//공개여부
			savedVal = $(obj).find('input:checked').val();
			
			if(savedVal == "1"){
				$("#RELEASE_CHECK_rec").val(savedVal);
				$("#chk_secrecy_rec").prop("checked", false);
			}else{
				$("#RELEASE_CHECK_rec").val(savedVal);
				$("#chk_secrecy_rec").prop("checked", "checked");
			}
			document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
			$(obj).val(savedVal);
		}
		else if(id == "CHK_MANUAL_APV"){
			savedVal = $(obj).is(":checked");
			$("#CHK_MANUAL_APV").val(savedVal ? "Y" : "N");
			if(savedVal == true){
				savedVal = 'Y';
				$("#CHK_MANUAL_APV").prop("checked", "checked");
				$("#MANUAL_APV").val("Y");
				$("#RECEIVE_CHECK").val("indoc"); //$("#RECEIVE_CHECK_indoc").prop("checked","checked");
				document.getElementsByName("MULTI_RECEIVE_CHECK")[idx].value = "indoc";
				$("#btMultiReceive").hide();
				$("#RECEIVE_CHECK").attr("disabled",true); //$("#RECEIVE_CHECK_indoc").attr("disabled",true); $("#RECEIVE_CHECK_else").attr("disabled",true);
				Common.Warning(Common.getDic("msg_selectPaperScanfile"));//종이접수문서 스캔 파일을 첨부하여 기안해야 합니다.
			}else{
				savedVal = 'N';
				$("#CHK_MANUAL_APV").prop("checked", false);
				$("#MANUAL_APV").val("N");
				$("#RECEIVE_CHECK").val("else"); //$("#RECEIVE_CHECK_else").prop("checked","checked");
				$("#btMultiReceive").show();
				$("#RECEIVE_CHECK").attr("disabled",true); //$("#RECEIVE_CHECK_indoc").attr("disabled",false); $("#RECEIVE_CHECK_else").attr("disabled",false);
			}
			document.getElementsByName("MULTI_MANUAL_APV")[idx].value = savedVal;
		}
		else if(id == "RECEIVE_CHECK"){
			savedVal= $(obj).val(); //$(obj).find("input:checked").val();
			if(savedVal == "indoc"){//내부결재
				$("#btMultiReceive").hide();
				//$("#btRecDept").hide();	
			}
			else if(savedVal == "else"){//시행발송
				$("#btMultiReceive").show();
				//$("#btRecDept").show();
			}
			document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
		}	
	}
}
