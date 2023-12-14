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
		$("#LApvLine,#tblFormSubject,#DocLinkInfoList,#tblDocProperties1").hide();		
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
		$("#btPreView").val("시행문보기");
		if(getInfo("Request.readtype") != "preview"){
			$("#btPreView").show();
		}
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
        
        // 편집모드에서
        ChangePublicAction($("#Publication")[0]);
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
	bodyContextObj.BodyContext.DisclosureCode = $("#Publication option:selected").val()
		
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
		
    return bodyContextObj;
}

var updateReceiveState = function( status , dis){		
	var deferred = $.Deferred();
	var sendData = {			
			formInstId 	: formJson.FormInstanceInfo.FormInstID												
			,status		: status			
		};		
	if (status == "distribute"){
		var dataInfo = JSON.parse(dis);
		sendData["distribDeptId"]   = dataInfo.receiptList[0].code
		sendData["distribDeptName"] = dataInfo.receiptList[0].name
	}
	$.ajax({
		url: "user/updateGovReceiveStatus.do",
		type:"POST",
		data: sendData,		
		success:function (data) { deferred.resolve(data);},
		error:function(response, status, error){ deferred.reject(status); }
	});				
 	return deferred.promise();
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
			,publicationCode	:	bodyContext.DisclosureCode + bodyContext.publicationCode
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
			getInfo("Request.mode") !== "DRAFT" && $("#divFormApvLines,#btPreView,#btOTrans,#tblFormSubject").hide();
			
			$("#bodytable").show();
		},
		error:function(response, status, error){ 
			alert("시행문 변환중 오류가 발생했습니다.");
		}
	});
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

var setPreViewData_old = window.setPreViewData;
var setPreViewData = function(){
	$("#bodytable").hide();
	try{
		if(getInfo("Request.mode") === "DRAFT" || getInfo("Request.mode") === "TEMPSAVE" || getInfo("Request.mode") === "REJECT"){
			preview(setPreViewData_old());
			return;
		}
		preview();
	}finally {
		
	}
}