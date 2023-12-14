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

    setSelect();
	
    // 체크박스, radio 등 공통 후처리
    postJobForDynamicCtrl();
    
    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {
    	
    	//문서정보 숨김처리
		var divLen = $$($.parseJSON(XFN_ChangeOutputValue(document.getElementById("APVLIST").value))).find("steps").find("division").valLength();
		if(formJson.Request.isMobile != "Y" && (divLen == 1 || formJson.Request.mode == "REDRAFT"))
			displayDocInfo();
    	
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
			Common.Error("<spring:message code='Cache.msg_apv_030' />");  // 오류가 발생했습니다.
		}
	});
}

function setSenderMasterAndSealSignAndChief() {
	// 발신자 명
	document.getElementById("CHIEF").value = event.target.options[event.target.selectedIndex].getAttribute("data-chief");
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
	// 주소
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
	
	var filePath = "";
	var gfileId= "";

	HwpCtrl.PutFieldText("logo", " ");
	if($.trim(document.getElementById("LOGO").value) != "") {
		filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId($.trim(document.getElementById("LOGO").value));
		gfileId = $.trim(document.getElementById("LOGO").value); 
		m_arrConverImgArr.push({
			TYPE:"ICON",
			IMGNAME:"logo",
			FILEPATH :filePath,
			WIDTH: 70,
			HEIGHT :70,					
			BINARYDATA :getFileBinaryData(gfileId,70,70)				
		});
	}

	HwpCtrl.PutFieldText("symbol", " ");
	if($.trim(document.getElementById("SYMBOL").value) != "") {
		filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId($.trim(document.getElementById("SYMBOL").value));
		gfileId = $.trim(document.getElementById("SYMBOL").value); 
		m_arrConverImgArr.push({
			TYPE:"ICON",
			IMGNAME:"symbol",
			FILEPATH :filePath,
			WIDTH: 70,
			HEIGHT :70,					
			BINARYDATA :getFileBinaryData(gfileId,70,70)					
		});					
	}
	
	HwpCtrl.PutFieldText("sealsign", " ");
	if($.trim(document.getElementById("STAMP").value) != "") {
		filePath = Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId($.trim(document.getElementById("STAMP").value));
		gfileId = $.trim(document.getElementById("STAMP").value);
		m_arrConverImgArr.push({
			TYPE:"ICON",
			IMGNAME:"sealsign",
			FILEPATH :filePath,
			WIDTH: 100,
			HEIGHT :100,
			BINARYDATA :getFileBinaryData(gfileId,100,60)					
		});
	}
	
	HwpCtrl.PutFieldText("chief", !$.trim(document.getElementById("CHIEF").value) ? " " : $.trim(document.getElementById("CHIEF").value));
	HwpCtrl.PutFieldText("organ", !$.trim(document.getElementById("ORGAN").value) ? " " : $.trim(document.getElementById("ORGAN").value));
	HwpCtrl.PutFieldText("telephone", !$.trim(document.getElementById("TELEPHONE").value) ? " " : $.trim(document.getElementById("TELEPHONE").value));
	HwpCtrl.PutFieldText("fax", !$.trim(document.getElementById("FAX").value) ? " " : $.trim(document.getElementById("FAX").value));
	HwpCtrl.PutFieldText("homepage", !$.trim(document.getElementById("HOMEURL").value) ? " " : $.trim(document.getElementById("HOMEURL").value));
	HwpCtrl.PutFieldText("email", !$.trim(document.getElementById("EMAIL").value) ? " " : $.trim(document.getElementById("EMAIL").value));
	HwpCtrl.PutFieldText("zipcode", !$.trim(document.getElementById("ZIPCODE").value) ? " " : $.trim(document.getElementById("ZIPCODE").value));
	HwpCtrl.PutFieldText("address", !$.trim(document.getElementById("ADDRESS").value) ? " " : $.trim(document.getElementById("ADDRESS").value));
	HwpCtrl.PutFieldText("headcampaign", !$.trim(document.getElementById("CAMPAIGN_T").value) ? " " : $.trim(document.getElementById("CAMPAIGN_T").value));
	HwpCtrl.PutFieldText("footcampaign", !$.trim(document.getElementById("CAMPAIGN_F").value) ? " " : $.trim(document.getElementById("CAMPAIGN_F").value));

	ConvertToBinaryToHWP(HwpCtrl);//이미지 로딩 
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

//본문 XML로 구성
function makeBodyContext() {
    /*var sBodyContext = "";
    sBodyContext = "<BODY_CONTEXT>" + getFields("mField") + "</BODY_CONTEXT>";*/
	var bodyContextObj = {};
	var editorContent = { "tbContentElement" : document.getElementById("dhtml_body").value };
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
	
	//대외수신처
	var receiveCodes = [];
	var receiveNames = [];	
	$("#RECEIVEGOV_NAMES").val().length > 0 && $("#RECEIVEGOV_NAMES").val().split(";").map(function(item,index){
		var size = item.split(':').length;
		receiveCodes = receiveCodes.concat( item.split(':')[1] );
		receiveNames = receiveNames.concat( item.split(':')[size-1] );		 
	});
	bodyContextObj.BodyContext.receiver = receiveCodes.join(';');
	bodyContextObj.BodyContext.receiverName = receiveNames.join(',');
	if (getInfo("Request.isgovDocReply") == "Y") {
		bodyContextObj.BodyContext.govDocReply = "Y";
		bodyContextObj.BodyContext.govFormInstID = getInfo("Request.govFormInstID");
	}
	
    return bodyContextObj;
}

function setHwpFieldText() {
	if (formJson.Request.mode == "COMPLETE") {
		HwpCtrl.PutFieldText("docnumber", formJson.FormInstanceInfo.DocNo); // 등록번호
        HwpCtrl.PutFieldText("enforcedate", formJson.FormInstanceInfo.CompletedDate.substring(0, 10)); // 시행일자
	}
}

var callPacker = function(status){	
	try {
		HwpCtrl.MoveToField('body', true, true, true);
		HwpCtrl.SaveAs("test.xml", "PUBDOCBODY", "saveblock;", function (res) {
			//alert(res.downloadUrl);
			
	    	$.ajax({
				url: "/govdocs/service/callPacker.do", // local:govdocs, prd:covigovdocs
				type:"POST",
				data: {
					formInstId 	: formJson.FormInstanceInfo.FormInstID
					,processId 	: formJson.FormInstanceInfo.ProcessID
					,type 		: status || "send"
					,bodyUrl	: res.downloadUrl
					,bodySize	: res.size
//					,receiver 		: formJson.BodyContext.RECEIVE_INFO.split("^")[1]
//					,receiverName 	: formJson.BodyContext.RECEIVE_INFO.split("^")[0]
					,bodyUniqueID	: res.uniqueId,
					/*stampUrl: nullToBlank(formJson.BodyContext.STAMP) == "" ? "" : Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(formJson.BodyContext.STAMP),
	    			logoUrl: nullToBlank(formJson.BodyContext.LOGO) == "" ? "" : Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(formJson.BodyContext.LOGO),
	    			symbolUrl: nullToBlank(formJson.BodyContext.SYMBOL) == "" ? "" : Common.agentFilterGetData("smart4j.path", "P") + coviCmn.loadImageId(formJson.BodyContext.SYMBOL)*/
					stampUrl: formJson.BodyContext.STAMP,
	    			logoUrl: formJson.BodyContext.LOGO,
	    			symbolUrl: formJson.BodyContext.SYMBOL
				},				
				success:function (data) { 
					data.status === "OK" && Common.Inform("발송되었습니다.","",function(){ 
						$("#btGovDocsSend").hide();
						$("#btGovDocsReSend").hide();
						opener.docFunc.refresh(); 
						window.close();
	                });
				},  
				error:function(response, status, error){ 
	                    Common.Inform("처리 실패하였습니다.", 'Information Dialog', null);
	                }
			});
			
		});
		HwpCtrl.MoveToField('body', true, true, false);

    } catch (e) {
        Common.Error(e.message);
    }	
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
				HwpCtrl.PutFieldText("publication", "공개");
				$("#chk_secrecy").prop("checked", false);
				$("#RELEASE_CODE").hide();
			}else{
				$("#RELEASE_CHECK").val(savedVal);
				HwpCtrl.PutFieldText("publication", "비공개");
				$("#chk_secrecy").prop("checked", "checked");
				$("#RELEASE_CODE").show();
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
				$("#RECEIVE_CHECK").val("indoc"); //$("#RECEIVE_CHECK_indoc").prop("checked","checked");
				//document.getElementsByName("MULTI_RECEIVE_CHECK")[idx].value = "indoc";
				$("#btMultiReceive").hide();
				HwpCtrl.PutFieldText("recipient", "내부결재");
				$("#RECEIVE_CHECK").attr("disabled",true); //$("#RECEIVE_CHECK_indoc").attr("disabled",true); $("#RECEIVE_CHECK_else").attr("disabled",true);
				Common.Warning(Common.getDic("msg_selectPaperScanfile"));//종이접수문서 스캔 파일을 첨부하여 기안해야 합니다.
			}else{
				savedVal = 'N';
				$("#CHK_MANUAL_APV").prop("checked", false);
				$("#MANUAL_APV").val("N");
				$("#RECEIVE_CHECK").val("else"); //$("#RECEIVE_CHECK_else").prop("checked","checked");
				$("#btMultiReceive").show();
				HwpCtrl.PutFieldText("recipient", " ");
				$("#RECEIVE_CHECK").attr("disabled",true); //$("#RECEIVE_CHECK_indoc").attr("disabled",false); $("#RECEIVE_CHECK_else").attr("disabled",false);
			}
			//document.getElementsByName("MULTI_MANUAL_APV")[idx].value = savedVal;
			//$(obj).val(savedVal);
		}
		else if(id == "RECEIVE_CHECK"){
			savedVal= $(obj).val(); //$(obj).find("input:checked").val();
			if(savedVal == "indoc"){//내부결재
				HwpCtrl.MoveToField("recipient", true, true, false);
				HwpCtrl.PutFieldText("hrecipients", " ");
				HwpCtrl.PutFieldText("recipient", "내부결재");
				HwpCtrl.PutFieldText("recipients", " ");
				document.getElementById('RECEIVEGOV_NAMES').value = '';
				document.getElementById('ReceiveNames').value = '';
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