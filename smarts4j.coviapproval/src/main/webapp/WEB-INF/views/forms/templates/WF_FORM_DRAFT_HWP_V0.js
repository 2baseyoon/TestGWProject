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
    setSelect();
    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        //<!--loadMultiRow_Read-->
        LoadEditorHWP("divWebEditorContainer");
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        //<!--AddWebEditor-->
        LoadEditorHWP("divWebEditorContainer");
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpdn_apv"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm_multi"), false);
        }
     
        //<!--loadMultiRow_Write-->
    }
}

function setSelect() {
	setSelectSenderMaster();
}

function setSelectSenderMaster() {
	$.ajax({
		url: "/approval/user/selectGovSenderMasterUpper.do",
		type: "POST",
        data: {
        	deptCode: getInfo("AppInfo.dpid")
        },
        async: false,
		success: function(data) {
			console.log(data.list);
			
			var senderMaster = data.list;
			
			for (var i = 0; i < senderMaster.length; i++) {
				var option = document.createElement("option");
				option.setAttribute("value", senderMaster[i].SEND_ID);
				option.setAttribute("data-sealsign", nullToBlank(senderMaster[i].STAMP));
				option.setAttribute("data-chief", nullToBlank(senderMaster[i].NAME));
				option.innerText = nullToBlank(senderMaster[i].NAME);
				document.getElementById("SENDERMASTER").appendChild(option);
			}
			
			document.getElementById("SENDERMASTER").value = nullToBlank(formJson.BodyContext.BODY_CONTEXT_SENDERMASTER);
		},
		error: function(error){
			Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
		}
	});
}

function setSenderMasterAndSealSignAndChief() {
	document.getElementById("BODY_CONTEXT_SENDERMASTER").value = event.target.options[event.target.selectedIndex].value;
	document.getElementById("STAMP").value = event.target.options[event.target.selectedIndex].getAttribute("data-sealsign");
	document.getElementById("CHIEF").value = event.target.options[event.target.selectedIndex].getAttribute("data-chief");
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
	document.getElementById("SENDERMASTER").value = JSON.parse(sBodyContext).BODY_CONTEXT_SENDERMASTER;
}

//본문 XML로 구성
function makeBodyContext() {
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	var bodyContextObj = {};
	var editorContent = { "tbContentElement" : document.getElementById("dhtml_body").value };
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
    return bodyContextObj;
}

function chkdocInfo(obj){
	if(getInfo("Request.templatemode") != "Read" || getInfo("Request.mode") == "REDRAFT"){
		var idx = '1';
		var id = $(obj).attr("id");
		var savedVal = "";
		
		if(id == "RELEASE_CHECK") {//공개여부
			savedVal = $(obj).find('input:checked').val();
			
			if(savedVal == "1"){
				$("#RELEASE_CHECK").val(savedVal);
				HwpCtrl.PutFieldText("publication", "공개");
				$("#chk_secrecy").prop("checked", false);
			}else{
				$("#RELEASE_CHECK").val(savedVal);
				HwpCtrl.PutFieldText("publication", "비공개");
				$("#chk_secrecy").prop("checked", "checked");
			}
			//document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
			$(obj).val(savedVal);
		}
		else if(id == "RELEASE_CHECK_rec") {//공개여부
			savedVal = $(obj).find('input:checked').val();
			
			if(savedVal == "1"){
				$("#RELEASE_CHECK_rec").val(savedVal);
				//HwpCtrl.PutFieldText("publication", "공개");
				$("#chk_secrecy_rec").prop("checked", false);
			}else{
				$("#RELEASE_CHECK_rec").val(savedVal);
				//HwpCtrl.PutFieldText("publication", "비공개");
				$("#chk_secrecy_rec").prop("checked", "checked");
			}
			//document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
			$(obj).val(savedVal);
		}
		//else if(id == "MANUAL_APV"){//종이접수공문
		else if(id == "CHK_MANUAL_APV"){
			//savedVal = $(obj).find("input").is(":checked");
			savedVal = $(obj).is(":checked");
			$("#CHK_MANUAL_APV").val(savedVal ? "Y" : "N");
			if(savedVal == true){
				savedVal = 'Y';
				$("#CHK_MANUAL_APV").prop("checked", "checked");
				$("#MANUAL_APV").val("Y");
				$("#RECEIVE_CHECK_indoc").prop("checked","checked");
				//document.getElementsByName("MULTI_RECEIVE_CHECK")[idx].value = "indoc";
				$("#btMultiReceive").hide();
				HwpCtrl.PutFieldText("recipient", "내부결재");
				$("#RECEIVE_CHECK_indoc").attr("disabled",true);
				$("#RECEIVE_CHECK_else").attr("disabled",true);
				Common.Warning(Common.getDic("msg_selectPaperScanfile"));//종이접수문서 스캔 파일을 첨부하여 기안해야 합니다.
			}else{
				savedVal = 'N';
				$("#CHK_MANUAL_APV").prop("checked", false);
				$("#MANUAL_APV").val("N");
				$("#RECEIVE_CHECK_else").prop("checked","checked");
				$("#btMultiReceive").show();
				HwpCtrl.PutFieldText("recipient", " ");
				$("#RECEIVE_CHECK_indoc").attr("disabled",false);
				$("#RECEIVE_CHECK_else").attr("disabled",false);
			}
			//document.getElementsByName("MULTI_MANUAL_APV")[idx].value = savedVal;
			//$(obj).val(savedVal);
		}
		else if(id == "RECEIVE_CHECK"){
			savedVal= $(obj).find("input:checked").val();
			if(savedVal == "indoc"){//내부결재
				HwpCtrl.MoveToField("recipient", true, true, false);
				HwpCtrl.PutFieldText("hrecipients", " ");
				HwpCtrl.PutFieldText("recipient", "내부결재");
				HwpCtrl.PutFieldText("recipients", " ");
				$("#btRecDept").hide();
			}
			else if(savedVal == "else"){//시행발송
				HwpCtrl.PutFieldText("recipient", " ");
				$("#btRecDept").show();
			}
			//document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
		}	
		//$("#DOC_NO").val(opener.document.getElementById("DocNo").value);
	}
}
