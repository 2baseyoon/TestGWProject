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
	if (getInfo("Request.templatemode") == "Read") {
		$('#formBox').css("margin-top", "-20px");
	} else {
		$('#formBox').css("margin-top", "-45px");
	}

	if(getInfo("Request.templatemode") == "Read" && getInfo('AppInfo.dpid') == Common.getBaseConfig("AuditDept") && getInfo('Request.mode') == "SUBREDRAFT"){ // 감사부서 결재시 작성화면으로 띄움
		$('#btModify').click();
		return false;
	}
	
	$('#AttFileInfoList').hide();
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
	$('#MainTable').hide();
	$('#SubTable1').hide();
	$('#tblFormSubject').hide();

    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        // 에디터 처리
        LoadEditorHWP_Multi("divWebEditorContainer1", 1);
        if (formJson.Request.mode != "DRAFT") {
        	if(formJson.BodyData.SubTable1 != null){
        		$(formJson.BodyData.SubTable1).each(function(i, item){
        			if(i != 0){
        				addTabClass(item.MULTI_DOC_TYPE);
        			}
        		});
        	}
        }

        if (JSON.stringify(formJson.BodyData) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyData.SubTable1), 'json', '#SubTable1', 'R');            
        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'R');
        }
        formDisplaySetFileInfoMulti();
        if(getInfo('AppInfo.dpid') == Common.getBaseConfig("AuditDept")){
        	changeTab($("#writeTab li[doctype=audit]").attr('idx'));
        } else {
        	changeTab(1);
        }
        
        /*if(formJson.Request.gloct == "COMPLETE"){
        	var sendInfo = false;
        	if(formJson.BodyContext.SubTable1 != undefined){
        		$(formJson.BodyContext.SubTable1).each(function(){
        			if(this.MULTI_RECEIVER_TYPE == "Out" && this.MULTI_RECEIVENAMES != ""){
        				sendInfo = true;
        				return false;
        			}
        		});
        	}
        	if(sendInfo && getInfo('AppInfo.usid') == getInfo('FormInstanceInfo.InitiatorID')){
            	$('#btSendRequset').show();	
        	}
        }
        if(formJson.Request.gloct == "STANDBY"){
        	//window.setTimeout("$('#btSendRequset').show();", 5000);
        	$('#btStamp, #btSendApprove').show();	
        }*/
    }
    else {
        if (!_ie) {
            alert("해당 브라우져는 한글기안 작성기능을 지원하지 않습니다.\nInternet Explorer를 이용해주세요.");
            top.close();
        }
    	getSenderList();
    	
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        if (JSON.stringify(formJson.BodyContext) != "{}") {
            XFORM.multirow.load(JSON.stringify(formJson.BodyData.SubTable1), 'json', '#SubTable1', 'W');            

			$(formJson.BodyData.SubTable1).each(function(idx, item){
				if(formJson.BodyData.SubTable1[idx] != null && formJson.BodyData.SubTable1[idx].MULTI_ATTACH_FILE != ""){
					$('#SubTable1 .multi-row').find('[name=MULTI_ATTACH_FILE]')[idx].value = JSON.stringify(formJson.BodyData.SubTable1[idx].MULTI_ATTACH_FILE);
				}
			});

        } else {
            XFORM.multirow.load('', 'json', '#SubTable1', 'W', { minLength: 1 });
        }
        if(getInfo("Request.reuse") == 'Y'){
        	$('#subtable1 .multi-row').find('input[name=MULTI_DOC_TYPE]').each(function(idx, item){
        		if(item.value == "audit"){
        			$(item).parent().parent().remove();
        		}
        	});
        }
        
        // 에디터 처리
    	LoadEditorHWP_Multi("divWebEditorContainer1", 1);
        
        //if (formJson.Request.mode != "DRAFT") {
        	if(formJson.BodyData.SubTable1 != null){
        		$(formJson.BodyData.SubTable1).each(function(i, item){
        			if(i != 0 && (item.MULTI_DOC_TYPE != 'audit')){// && getInfo("Request.reuse") == 'Y'
        				addTabClass(item.MULTI_DOC_TYPE);
        			}
        		});
        	}
        //}

        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {

            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        } else if(formJson.Request.mode == "SUBREDRAFT" && getInfo('AppInfo.dpid') == Common.getBaseConfig("AuditDept")){ // 조직 개편 후 부서코드 변경됨
        	addTabClass("audit");
        	// 대내수신처 버튼만 보이도록 가림
        	$('#buttonOut, #btRecieveIn, #btRecieveOut, #btRecieveEtc').hide();
        	//$('#buttonOpinion, #btReject').show();
        	$('#buttonOpinion').show();
        	$('#btDeptDraft').val("감사기안"); // 감사부서 재기안시 재기안버튼 명칭변경
        }
    }
    
    // 수신부서 화면표시 (수신지정된 안건만 표시함) Start
    if(getInfo('ProcessInfo.SubKind') == "R"){
		$(formJson.BodyData.SubTable1).each(function(idx, item){
	    	var view = false;
	    	if(formJson.BodyData.SubTable1[idx] != null && formJson.BodyData.SubTable1[idx].MULTI_RECEIPTLIST != null && formJson.BodyData.SubTable1[idx].MULTI_RECEIPTLIST != ""){
				var RecList = formJson.BodyData.SubTable1[idx].MULTI_RECEIPTLIST.split(';');
				for(var i = 0; i < RecList.length; i++){
					if(RecList[i].split('|')[0] == getInfo('AppInfo.dpid')){
						view = true;
						break;
					}
				}
			}
			if(!view){
				$("#writeTab li[idx=" + (idx+1) + "]").remove();
				//$("#divWebEditorContainer1").remove();
			} else {
		    	changeTab((idx+1));
			}
		});
    } else if (getInfo('AppInfo.dpid') != Common.getBaseConfig("AuditDept")) {
    	changeTab(1);
    }
    // 수신부서 화면표시 (수신지정된 안건만 표시함) End
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
        if (document.getElementById("FILEATTACH").value == "false") {
            Common.Warning("파일은 최대 3MB까지 업로드 가능합니다.");
            return false;
        }
        
        if(!checkForm_HWPMulti()){
        	return false;
        };
        
        $('#Subject').val($('#tbContentElement1')[0].GetFieldText("SUBJECT"));	// 1안의 제목을 결재문서 제목으로 사용함
        return EASY.check().result;
    }
}

function setBodyContext(sBodyContext) {
}

//본문 XML로 구성
function makeBodyContext() {    
    var bodyContextObj = {};
    var editorContent = {"tbContentElement" : document.getElementById("dhtml_body").value};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
	$$(bodyContextObj["BodyContext"]).append(getMultiRowFields("SubTable1", "stField"));
    return bodyContextObj;
}