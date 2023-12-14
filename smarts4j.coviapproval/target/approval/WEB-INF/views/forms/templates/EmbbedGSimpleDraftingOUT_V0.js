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
        
    // 한국투자공사 추가 - 대외공개 범위
    //if (getInfo("ExtInfo.UsePublicAction") == "Y") {
    	$("#trPublicAction").show();
    //}
    if( ["GOVACCEPT"].indexOf( getInfo("Request.mode") ) > -1 ){
    	$("#trPublicAction").hide().prev().hide();    	
    	$("#headname").hide();
    	$("#TIT_INITIATOR").parents("tbody").hide();    	
    }

    // 완료함에서 미리보기시에 상단 회사로고 안보이도록 처리
    if(getInfo("Request.mode") === "COMPLETE" && getInfo("Request.readtype") === "preview") {
    	$("#headname").hide();
    	$("#TIT_INITIATOR").parents("tbody").hide();
    	$("#trPublicAction").hide();
    }
    
    // KIC 문서유통 접수대기함에서 문서표시 관련 20200915    
    getInfo("Request.mode") === "GOVACCEPT" && $("#btPrint,#btPrintView,#tblDocProperties1,#DocLinkInfoList").hide();
    
    //대외공문 접수문서 여부 확인  
    var GovRecDocYN = checkGovReceiveDoc();
    
    // 대외시행문 수신문서 O
	if(GovRecDocYN == 'Y'){
		$("#LApvLine,#tblFormSubject,#tblDocProperties1").hide();
		if($("#DocLinks").val() === '') $("#DocLinkInfoList").hide();
	}
	
	// 재기안시에 반송
	if(getInfo("Request.mode") == "REDRAFT" && getInfo("Request.gloct") == "DEPART") {
    	$("#btRejectOut").show();
    }
    	
	// 인쇄모드시 문서번호등 숨김처리
	if(getInfo("Request.readtype") == "preview") {
    	$("#tblDocProperties1").hide();
    	$("#tbLinkInfo").hide();
    	$("#btUseTask").hide();
    }
	
	// 대외접수문서가 아니거나 DRAFT 일 경우 미리보기 버튼 명칭 변경
	if(GovRecDocYN != 'Y'){
		$("#btPreView").show();
		$("#btPreView").val("시행문보기");
	}

    // 미리보기시 의견 영역 숨김
    if (getInfo("Request.readtype") == "preview") {
    	$("#CommentList").hide();
    }
	
    //읽기 모드 일 경우
    if (getInfo("Request.templatemode") == "Read") {

        $('*[data-mode="writeOnly"]').each(function () {
            $(this).hide();
        });
        
        //<!--loadMultiRow_Read-->
    }else {
        $('*[data-mode="readOnly"]').each(function () {
            $(this).hide();
        });

        // 에디터 처리
        //<!--AddWebEditor-->
        LoadEditor("divWebEditorContainer");
        
        if (formJson.Request.mode == "DRAFT" || formJson.Request.mode == "TEMPSAVE") {
            document.getElementById("InitiatorOUDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.dpnm"), false);
            document.getElementById("InitiatorDisplay").value = m_oFormMenu.getLngLabel(getInfo("AppInfo.usnm"), false);
        }     
        //<!--loadMultiRow_Write-->
    }    
    
    formJson.FormInstanceInfo.govAcceptDate && formJson.FormInstanceInfo.govAcceptDate.length > 0 && $("#sihengRecpt").text( "("+formJson.FormInstanceInfo.govAcceptDate+")" );
        
    // 문서번호가 있을경우 표시
    if($("#sihengRecpt").length == 1 && formJson.ProcessInfo != null) {
    	var DocNo = (formJson.ProcessInfo.ProcessDescription.Reserved2 == "") ? formJson.ProcessInfo.ProcessDescription.Reserved1 : formJson.ProcessInfo.ProcessDescription.Reserved2;
    	var DisplaySiheng = DocNo + " " + $("#sihengRecpt").html();
    	$("#sihengRecpt").html(DisplaySiheng);
    }
    // 문서번호가 있을경우 표시
    if($("#sihengRecpt").length == 1 && formJson.ProcessInfo == null) {
    	var DocNo = formJson.FormInstanceInfo.DocNo;
    	var DisplaySiheng = DocNo + " " + $("#sihengRecpt").html();
    	$("#sihengRecpt").html(DisplaySiheng);
    }
    
    //개인송신자 회신
    if(getInfo("Request.isgovDocReply") === "Y" && getInfo("Request.gov24sender") != 'undefined'){
    	$("#RECEIVEGOV_TEXT").attr('readonly', true);
    	$("#via").attr('readonly', true);
    	$("#btGovRecDept").removeAttr("onclick");
    	$("#RECEIVEGOV_NAMES").val(getInfo("Request.gov24sender"));
    	$("#RECEIVEGOV_INFO").val(getInfo("Request.gov24sender").split(":")[8]);
    	
    	var param = {};
    	var chkList = [];   	
    	$.ajax({
    		url: "/approval/govDocs/docLink.do",
    		type:"POST",
    		data: {
    			formInstId 	: getInfo("Request.govFormInstID")
    		},		
    		success:function (data) 
    		{ 
    			param.processID = data.ProcessID;
    			param.formPrefix = data.FormPrefix;
    			param.subject = data.FormSubject;
    			param.forminstanceID = data.FormInstID;
    			param.bstored = false;
    			param.businessData1 = data.BusinessData1;
    			param.businessData2 = data.BusinessData2;
    			
    			chkList.push(param);
    			docLinks.addItem(chkList);
    		}
    	});				
    }
    // 발송대기메뉴 && (실패||대기) --> 수동발송 버튼 활성화
    if(getInfo("Request.govstate") === "SENDWAIT" && ["wait","fail"].indexOf(CFN_GetQueryString("docType")) > -1){
    	$("#btGovDocsSend").show();
    }
}

//비공개 사유
function ShowPublicActionHelp() {
    var sTitle = "HELP";
    
    var sUrl2 = "form/goSecOptionHelpPopup.do";
    var iHeight = 530; var iWidth = 830;

    var nLeft = (screen.width - iWidth) / 2;
    var nTop = (screen.height - iHeight) / 2;
    var sWidth = iWidth.toString() + "px";
    var sHeight = iHeight.toString() + "px";
    var sLeft = nLeft.toString() + "px";
    var sTop = nTop.toString() + "px";

    CFN_OpenWindow(sUrl2, "", iWidth, iHeight, "resize");
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
	var editorContent = {
		"tbContentElement" 		: document.getElementById("dhtml_body").value
		,"tbContentElementHWP" 	: convertHWP( document.getElementById("dhtml_body").value )
	};
	
	bodyContextObj["BodyContext"] = $.extend(editorContent, getFields("mField"));
	//비공개 사유	
	bodyContextObj.BodyContext.publicationCode = Array.prototype.slice.call( $("[name=SecurityOption1]") ).reduce( function(acc,cur,idx,arr){ return acc += cur.checked ? "Y" : "N" },""); 
	bodyContextObj.BodyContext.publicationValue = $("#Publication option:selected").text();
	bodyContextObj.BodyContext.SaveTerm = $("#Publication option:selected").val()
		
	//대외수신처 + 수기 입력 수신처
	var receiveCodes = [];
	var receiveNames = [];	
	$("#RECEIVEGOV_NAMES").val().length > 0 && $("#RECEIVEGOV_NAMES").val().split(";").map(function(item,index){
		var size = item.split(':').length;
		receiveCodes = receiveCodes.concat( item.split(':')[1] );
		receiveNames = receiveNames.concat( item.split(':')[size-1] );		
	});
	bodyContextObj.BodyContext.receiver = receiveCodes.join(';');
	bodyContextObj.BodyContext.receiverName = receiveNames.concat( $("#RECEIVEGOV_TEXT").val().length > 0 ? $("#RECEIVEGOV_TEXT").val().split(";") : [] ).join(',');
	if (getInfo("Request.isgovDocReply") == "Y") {
		bodyContextObj.BodyContext.govDocReply = "Y";
		bodyContextObj.BodyContext.govFormInstID = getInfo("Request.govFormInstID");
	}
		
    return bodyContextObj;
}

var callPacker = function(status){	
	try {
    	$.ajax({
			url: "/approval/govDocs/callPacker.do",
			type:"POST",
			data: {
				formInstId 	: formJson.FormInstanceInfo.FormInstID
				,processId 	: formJson.FormInstanceInfo.ProcessID
				,receiver 	: formJson.BodyContext.receiver
				,type 		: status || "send"
			},				
			success:function (data) { 
				data.status === "OK" && Common.Inform("발송되었습니다.","",function(){ 
					$("#btGovDocsSend").hide();
					opener.docFunc.refresh(); 
                });
			},  
			error:function(response, status, error){ 
                    Common.Inform("처리 실패하였습니다.", 'Information Dialog', null);
                }
		});
    } catch (e) {
        Common.Error(e.message);
    }	
}

var preview = function(openerObj){		
		
	var bodyContext = getInfo("Request.mode") === "DRAFT" ? opener.makeBodyContext().BodyContext : formJson.BodyContext;	
	
	$.ajax({
		url: "/approval/govDocs/preview.do",
		type:"POST",
		data: {
			bodyContext 		: 	JSON.stringify( { tbContentElementHWP : bodyContext.tbContentElementHWP , via : bodyContext.via } )
			,receiverName 		: 	bodyContext.receiverName
			,approvalContext	: 	getInfo("Request.mode") === "DRAFT" ?  $("#APVLIST",opener.document).val() : JSON.stringify(formJson.ApprovalLine)
			,processSubject		:	formJson.FormInstanceInfo.Subject
			,publicationCode	:	bodyContext.SaveTerm + bodyContext.publicationCode
			,publicationValue	:	bodyContext.publicationValue
			,regNumberCode		:	""
			,docNumber			:	formJson.FormInstanceInfo.DocNo || ""
			,enForceDate		:	formJson.FormInstanceInfo.CompletedDate || ""
			,emailAddress		:	getInfo("AppInfo.ussip")
			,initiatorID		:	getInfo("AppInfo.usid")
			,requestMode		:	getInfo("Request.mode")
		},		
		success:function (data) {
			$("#tbContentElement").empty().append(data.content);			
			getInfo("Request.mode") !== "DRAFT" && $("#divFormApvLines,#btPreView,#btOTrans,#btPrint,#tblFormSubject").hide();
		},
		error:function(response, status, error){ 
			console.log( response ) 
		}
	});
}



//추가발송, 중복발송
function btSend_Click() {
	_CallBackMethod = OrgMap_CallBack;
	CFN_OpenWindow("/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod&szObject=&type="+"C9"+"&setParamData=_setParamdata", "", "1060px", "580px");
}

//배부이력
function govDocDistInfo(){
	CFN_OpenWindow("goReceiptReadListPage.do?" + "&ProcessID=0" + "&FormInstID=" + getInfo("FormInstanceInfo.FormInstID") + "&GovDocs=distribution", "", "1060px", "580px");
}

function OrgMap_CallBack(pStrItemInfo) {
    var oJsonOrgMap = $.parseJSON(pStrItemInfo);
    
    
    var approvalLineObj ={
    	steps : {
    		datecreated : ""	
	   		,division : {
	   			divisiontype	: "send"
	   			,processID : ""
				,name	: Common.getDic("lbl_apv_circulation_sent")
				,oucode	: getInfo("AppInfo.dpid_apv")
				,ouname	: getInfo("AppInfo.dpdn_apv")
				,status : "pending"
				,taskinfo : {				
					status 	: "inactive"
	                ,result : "inactive"
	                ,kind 	: "send"
	                ,datereceived : getInfo("AppInfo.svdt_TimeZone")
				}
				,step : {
					unittype : "person"
					,routetype : "approve"
					,name : Common.getDic("lbl_apv_writer")
					,ou : {
						code : getInfo("AppInfo.dpid_apv")
						,name : getInfo("AppInfo.dpdn_apv")
						,person : {
							code 		: getInfo("AppInfo.usid")
	                        ,name 		: getInfo("AppInfo.usnm_multi")
	                        ,position 	: getInfo("AppInfo.uspc") + ";" + getInfo("AppInfo.uspn_multi")
	                        ,title 		: getInfo("AppInfo.ustc") + ";" + getInfo("AppInfo.ustn_multi")
	                        ,level 		: getInfo("AppInfo.uslc") + ";" + getInfo("AppInfo.usln_multi")
	                        ,oucode 	: getInfo("AppInfo.dpid")
	                        ,ouname 	: getInfo("AppInfo.dpnm_multi")
	                        ,sipaddress : getInfo("AppInfo.ussip")
	                        ,taskinfo	: {
	                        	status 	: "inactive"
	                            ,result : "inactive"
	                            ,kind 	: "charge"
	                            ,datereceived : getInfo("AppInfo.svdt_TimeZone")
	                            ,visible : "n"
	                        }
						}
					}
				}    	
	   		}
    	}	
    } 
   
    
    if (oJsonOrgMap != null) {
    	m_oInfoSrc.m_bFrmExtDirty = true; 
    	
    	var objArr_person = new Array();
    	var objArr_ou = new Array();
    	
    	var dataInfo = {};
    	var dataInfoStr = "";
    	var dataContext = m_oInfoSrc.getDefaultJSON();
    	dataContext.FormData = m_oInfoSrc.getFormJSON().FormData;
    	
    	//dataInfo.piid = m_oInfoSrc.getInfo("ProcessInfo.ParentProcessID");    	
    	dataInfo.piid = "0";    	
    	dataInfo.approvalLine = JSON.stringify(approvalLineObj);    	
    	dataInfo.docNumber = m_oInfoSrc.getInfo("FormInstanceInfo.DocNo");
    	dataInfo.context = JSON.stringify(dataContext);
    	
        var strflag = true;

        var oChildren = $$(oJsonOrgMap).find("item");
        $$(oChildren).concat().each(function (i, oChild) {
        	var dataInfo_receiptList = {};
        	
            var cmpoucode = ";" +  $$(oChild).attr("AN") + ";";
            if (m_oInfoSrc.document.getElementById("ReceiptList").value.indexOf(cmpoucode) > -1) {
                strflag = false;
            }
            var currNode = {};
            if ($$(oChild).attr("itemType") == "user") {
            	$$(dataInfo_receiptList).attr("code", $$(oChild).attr("AN"));
            	$$(dataInfo_receiptList).attr("name", $$(oChild).attr("DN"));
            	$$(dataInfo_receiptList).attr("type", "1");
            	$$(dataInfo_receiptList).attr("status", "inactive");
            	
            	objArr_person.push(dataInfo_receiptList);
            } else {
            	$$(dataInfo_receiptList).attr("code", $$(oChild).attr("AN"));
            	$$(dataInfo_receiptList).attr("name", $$(oChild).attr("DN"));
            	$$(dataInfo_receiptList).attr("type", "0");
            	$$(dataInfo_receiptList).attr("status", "inactive");
            	
            	objArr_ou.push(dataInfo_receiptList);
            }
        });
        
        var sMsg = Common.getDic("msg_apv_191");//"해당 항목들을 발송하시겠습니까?"
        if(strflag == false) sMsg = Common.getDic("msg_apv_345");

        Common.Confirm(sMsg, "Confirmation Dialog", function (result) {
            if (result) {
            	if(objArr_person.length > 0) { // 사용자
            		dataInfo.receiptList = objArr_person;
            		dataInfo.type = "1";
            		
            		dataInfoStr = JSON.stringify(dataInfo);
            		
            		startDistribution(dataInfoStr);
            	}
            	if(objArr_ou.length > 0) { // 부서
            		dataInfo.receiptList = objArr_ou;
            		dataInfo.type = "0";
            		
            		dataInfoStr = JSON.stringify(dataInfo);
            		
            		startDistribution(dataInfoStr);
            	}
            	if (objArr_person.length == 0 && objArr_ou.length == 0){
            		Common.Warning(Common.getDic("msg_apv_003"));	
            	}
            }
        });
    }
}

function addVisibleAttributeSendPerson() {
	var apvLineObj = $.parseJSON($("#APVLIST").val());	
	var oSendPersonNode = $$(apvLineObj).find("steps>division[divisiontype='send']>step[unittype='person']>ou>person");	
	var elmNextTaskInfo = oSendPersonNode.attr("taskinfo");    
    elmNextTaskInfo["visible"] = "n";	
	$("#APVLIST").val(JSON.stringify(apvLineObj));
}

function ChangePublicAction(dataInfo){
	var seldata = $(dataInfo).val();
	if(seldata == 1){
		$("input[name=SecurityOption1]").prop("checked",false);
		$("input[name=SecurityOption1]").prop("disabled", true);
	}else { 
		$("input[name=SecurityOption1]").prop("disabled",false);
	}
}

function govDocReply(){
    var sUrl = "/approval/approval_Form.do?formID=" + getInfo("FormInfo.FormID") + "&mode=DRAFT&isgovDocReply=Y&senderInfo="+getInfo("BodyContext.sender")+"&govFormInstID="+getInfo("FormInstanceInfo.FormInstID");
    var width = "790";
	if(IsWideOpenFormCheck(getInfo("FormInfo.FormPrefix"), getInfo("FormInfo.FormID"))){
		width = "1070";
	}
	if(getInfo("Request.ReplyFlag") == "Y"){
		Common.Confirm("이미 회신한 문서입니다. 다시 회신하시겠습니까?", "Confirmation Dialog", function (result) {
			if(result){
				CFN_OpenWindow(sUrl, "", width, (window.screen.height - 100), "resize", "false");
			}else{ return; }
		});
	}else{
		CFN_OpenWindow(sUrl, "", width, (window.screen.height - 100), "resize", "false");
	}
}