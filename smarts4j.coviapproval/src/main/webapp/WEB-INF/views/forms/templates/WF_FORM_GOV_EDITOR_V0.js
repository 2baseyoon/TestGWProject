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
	
	if(getInfo("Request.readtype")!="preview" && getInfo("Request.readtype")!="govpreview") setSelect();
	
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();


    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
    	
    	var divLen = $$($.parseJSON(XFN_ChangeOutputValue(document.getElementById("APVLIST").value))).find("steps").find("division").valLength();
		if(formJson.Request.isMobile != "Y" && (divLen == 1 || formJson.Request.mode == "REDRAFT"))
			displayDocInfo();
			//$('#tblFormSubject').hide();
		

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
    }
    else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });
        
        //<!--AddWebEditor-->
        LoadEditor("divWebEditorContainer");
     
        //<!--loadMultiRow_Write-->
    }
    
    // 발송대기메뉴 && (실패||대기) --> 수동발송 버튼 활성화
    if (getInfo("Request.govstate") === "SENDWAIT" && ["wait","fail"].indexOf(CFN_GetQueryString("docType")) > -1){
    	$("#btGovDocsSend").show();
    }
}


function setSelect() {
	setSelectSenderMaster();
}

//인장구분 select box 값 세팅
function setSelectSenderMaster() {
	$.ajax({
		url: "/approval/user/selectGovSenderMasterUpper.do",
		type: "POST",
        data: {
        	deptCode: getInfo("AppInfo.dpid")
        },
        async: false,
		success: function(data) {
			var senderMaster = data.list;
			
			for (var i = 0; i < senderMaster.length; i++) {
				var option = document.createElement("option");
				option.setAttribute("value", senderMaster[i].SEND_ID);
				option.setAttribute("data-stamp", nullToBlank(senderMaster[i].STAMP));
				option.setAttribute("data-logo", nullToBlank(senderMaster[i].LOGO));
				option.setAttribute("data-symbol", nullToBlank(senderMaster[i].SYMBOL));
				option.setAttribute("data-chief", nullToBlank(senderMaster[i].NAME));
				option.setAttribute("data-organ", nullToBlank(senderMaster[i].OUNAME));
				option.setAttribute("data-tel", nullToBlank(senderMaster[i].TEL));
				option.setAttribute("data-fax", nullToBlank(senderMaster[i].FAX));
				option.setAttribute("data-homepage", nullToBlank(senderMaster[i].HOMEPAGE));
				option.setAttribute("data-email", nullToBlank(senderMaster[i].EMAIL));
				option.setAttribute("data-zip-code", nullToBlank(senderMaster[i].ZIP_CODE));
				option.setAttribute("data-address", nullToBlank(senderMaster[i].ADDRESS));
				option.setAttribute("data-campaign-t", nullToBlank(senderMaster[i].CAMPAIGN_T));
				option.setAttribute("data-campaign-f", nullToBlank(senderMaster[i].CAMPAIGN_F));
				option.innerText = nullToBlank(senderMaster[i].NAME);
				document.getElementById("SENDERMASTER").appendChild(option);
			}
			
			document.getElementById("SENDERMASTER").value = nullToBlank(formJson.BodyContext.SENDERMASTER);
		},
		error: function(error){
			Common.Error("오류가 발생했습니다.");  // 오류가 발생했습니다.
		}
	});
}

function setSenderMasterAndSealSignAndChief() {
	// 전화번호
	document.getElementById("TELEPHONE").value = event.target.options[event.target.selectedIndex].getAttribute("data-tel");
	// 팩스번호
	document.getElementById("FAX").value = event.target.options[event.target.selectedIndex].getAttribute("data-fax");
	// 홈페이지
	document.getElementById("HOMEURL").value = event.target.options[event.target.selectedIndex].getAttribute("data-homepage");
	// 이메일
	document.getElementById("EMAIL").value = event.target.options[event.target.selectedIndex].getAttribute("data-email");
	// 우편번호
	document.getElementById("ZIPCODE").value = event.target.options[event.target.selectedIndex].getAttribute("data-zip-code");
	// 기관명
	document.getElementById("ADDRESS").value = event.target.options[event.target.selectedIndex].getAttribute("data-address");
	// 스탬프
	document.getElementById("STAMP").value = event.target.options[event.target.selectedIndex].getAttribute("data-stamp");
	// 로고
	document.getElementById("LOGO").value = event.target.options[event.target.selectedIndex].getAttribute("data-logo");
	// 심볼
	document.getElementById("SYMBOL").value = event.target.options[event.target.selectedIndex].getAttribute("data-symbol");
	// 캠페인(상)
	document.getElementById("CAMPAIGN_T").value = event.target.options[event.target.selectedIndex].getAttribute("data-campaign-t");
	// 캠페인(하)
	document.getElementById("CAMPAIGN_F").value = event.target.options[event.target.selectedIndex].getAttribute("data-campaign-f");
	// 기관명
	document.getElementById("ORGAN").value = event.target.options[event.target.selectedIndex].getAttribute("data-organ");

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


function chkdocInfo(obj){
	if(getInfo("Request.templatemode") != "Read" || getInfo("Request.mode") == "REDRAFT"){
		var idx = '1';
		var id = $(obj).attr("id");
		var savedVal = "";
		
		if(id == "RELEASE_CHECK") {//공개여부
			savedVal = $(obj).val();
			
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
				$("#RECEIVE_CHECK").attr("disabled",true); // $("#RECEIVE_CHECK_indoc").attr("disabled",true); $("#RECEIVE_CHECK_else").attr("disabled",true);
				Common.Warning(Common.getDic("msg_selectPaperScanfile"));//종이접수문서 스캔 파일을 첨부하여 기안해야 합니다.
			}else{
				savedVal = 'N';
				$("#CHK_MANUAL_APV").prop("checked", false);
				$("#MANUAL_APV").val("N");
				$("#RECEIVE_CHECK").val("else"); //$("#RECEIVE_CHECK_else").prop("checked","checked");
				$("#btMultiReceive").show();
				$("#RECEIVE_CHECK").attr("disabled",true); // $("#RECEIVE_CHECK_indoc").attr("disabled",false); $("#RECEIVE_CHECK_else").attr("disabled",false);
			}
			document.getElementsByName("MULTI_MANUAL_APV")[idx].value = savedVal;
		}
		else if(id == "RECEIVE_CHECK"){
			savedVal= $(obj).val(); //$(obj).find("input:checked").val();
			if(savedVal == "indoc"){//내부결재
				//$("#btMultiReceive").hide();
				document.getElementById('RECEIVEGOV_NAMES').value = '';
				document.getElementById('ReceiveNames').value = '';
				document.getElementById('DocRecLine').value = '';
				$("#btRecDept").hide();	
				$("#ReceiveLine").hide();
			}
			else if(savedVal == "else"){//시행발송
				//$("#btMultiReceive").show();
				$("#btRecDept").show();
			}
			//document.getElementsByName("MULTI_"+id)[idx].value = savedVal;
		}	
	}
}

//테이블 스타일 픽셀로 변환
function convertHtmlTableStyle(){
	var ContentEle;
	var govState = getInfo("Request.govstate");
	var tableStyleAttributes = ['width','height'];
	if (getInfo("Request.templatemode") == "Read") {
		if(govState == "RECEIVEWAIT" || govState == "RECEIVEPROCESS"){
			ContentEle = $("#docencodebody");
		} else {
			ContentEle = $("#tbContentElement");
		}
		
	} else {
		ContentEle = document.getElementById("tbContentElementFrame").contentWindow.document.getElementById("dext_frame_tbContentElement").contentWindow.document.getElementById("dext5_design_tbContentElement").contentWindow.document.getElementById('dext_body');
	}
	
	$('table,table tr,table td',$(ContentEle)).each(function(){
			var _this = $(this);
			Array.prototype.slice.call( this.attributes ).forEach(function(item,idx){
				tableStyleAttributes.forEach(function(name,idx){
					if( item.name === name ){
						var formatVal;
						if(this.getAttribute( item.name ).indexOf("mm") > -1){
							formatVal = (this.getAttribute( item.name ).replace(/[^0-9\.]/gi,'')*3.77953232) + 'px';
						} else {
							formatVal = (this.getAttribute( item.name ).replace(/[^0-9\.]/gi,'')) + 'px';
						}
						this.removeAttribute( item.name );
						$(_this).css(name,formatVal);
					}
				}.bind(this))
			}.bind(this));
	});
}