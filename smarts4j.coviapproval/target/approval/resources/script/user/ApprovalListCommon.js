var g_commentAttachList = [];

var strPiid_List = "";
var strWiid_List = "";
var strFiid_List = "";
var strPtid_List = "";
var strBizData2_List = "";
var strTaskID_List = "";
var strKind_List = "";

var SessionObj = Common.getSession();

var doEngineBatchApprovalCnt = 0;
var errorCnt = 0;

/**
 * 결재문서함 조회 공통 전처리
 * @param fInitApprovalList
 * @param fSetGrid
 */
function initApprovalListComm(fInitApprovalList, fSetGrid) {
	var _listCntEl;
	
	_listCntEl = $("select[id='selectPageSize']");
	
	if(_listCntEl.length > 0) {
    	if(CFN_GetCookie("ApvListPageSize")) {
            _listCntEl.val(CFN_GetCookie("ApvListPageSize"));
        }
    	
        _listCntEl.on("change", function() {
            CFN_SetCookieDay("ApvListPageSize", $(this).find("option:selected").val(), 31536000000);

            fSetGrid();
        });
	}
	
	fInitApprovalList();
}

/**
 * 새로고침
 */
function Refresh(){
	CoviMenu_GetContent(location.href.replace(location.origin, ""), false);
}

/**
 * 사용자 전자결재 비밀번호 확인
 * @param strPassword
 * @returns {Boolean}
 */
function chkCommentWrite(strPassword){
	var returnval = false;

	$.ajax({
		url:"/approval/chkCommentWrite.do",
		type:"post",
		data: {
			"ur_code" : SessionObj["USERID"],
			"password" : aesUtil.encrypt(proaas, proaaI, proaapp, strPassword)
		},
		async:false,
		success:function (res) {				
			if(res){					
				returnval = true;					
			} else {					
				returnval = false;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/chkCommentWrite.do", response, status, error);
		}
	});
	return returnval;
}

//사용자 전자결재 비밀번호 사용유무 조회
function chkUsePasswordYN(){
	var returnval = false;
	
	$.ajax({
		url:"/approval/chkUsePasswordYN.do",
		type:"post",
		data: {
			"ur_code" : Common.getSession("USERID")
		},
		async:false,
		success:function (res) {				
			if(res){					
				returnval = true;					
			} else {					
				returnval = false;
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/chkUsePasswordYN.do", response, status, error);
		}
	});
	return returnval;
}
/**
 * 일괄결재
 * @param gridObj
 * @param approvalType
 * @param buttonType
 */
function BatchApproval(gridObj, approvalType, useFido){
	strPiid_List = "";
	strWiid_List = "";
	strFiid_List = "";
	strPtid_List = "";
	strKind_List = "";
	
	strBizData2_List = "";
	strTaskID_List = "";
	
	//일괄 결재 사용을 하지 않는 문서는 체크 제외
	var excludeItem = false;
	var recItemChk = false;
	var dAdtItemChk = false;
	var getApvAgrOpt = Common.getBaseConfig("ApvAgreementOpt").split(";")[0]; //합의자 결재시 : 동의 옵션 확인
	$.each(gridObj.getCheckedListWithIndex(1), function(idx,obj){
		if(typeof obj.item.ExtInfo == 'undefined'  || obj.item.ExtInfo.UseBlocApprove != 'Y' || (obj.item.FormSubKind == "T009" && getApvAgrOpt == "Y")){
			excludeItem = true;
			gridObj.checkedColSeq(1,false,obj.index);
		} else if(typeof obj.item.ExtInfo !== 'undefined' && obj.item.ExtInfo.UseBlocApprove === "Y" && (obj.item.FormSubKind === "R" || obj.item.FormSubKind === "T008")){
			// 수신부서 1인결재 옵션 체크
			if(typeof obj.item.SchemaContext !== 'undefined' && obj.item.SchemaContext.scChrRedraft.isUse !== "Y"){
				recItemChk = true;
				gridObj.checkedColSeq(1,false,obj.index);
			}
		} else if(approvalType == "DEPT" && (obj.item.FormSubKind == "AD" || obj.item.FormSubKind == "AE")) {
			dAdtItemChk = true;
			gridObj.checkedColSeq(1,false,obj.index);
		}
	});
	
	var msgConfirm = '';
	var msgWarning = '';

	if(excludeItem){
		msgConfirm += Common.getDic("msg_blocApprove");  	//일괄결재를 지원하지 않는 양식은 항목에서 제외됩니다.
		msgWarning += Common.getDic("msg_blocApprove");  	//일괄결재를 지원하지 않는 양식은 항목에서 제외됩니다.
		
		msgConfirm += "\n";
		msgWarning += "\n";
	}
	if(recItemChk){
		msgConfirm += Common.getDic("msg_apv_513");  	//수신부서 1인결재가 허용되지 않는 문서는 제외됩니다.
		msgWarning += Common.getDic("msg_apv_513");  	//수신부서 1인결재가 허용되지 않는 문서는 제외됩니다.
		
		msgConfirm += "\n";
		msgWarning += "\n";
	}
	if(dAdtItemChk){
		msgConfirm += Common.getDic("msg_apv_518"); 	//부서감사, 부서준법은 1인 접수가 불가능하여 항목에서 제외됩니다.
		msgWarning += Common.getDic("msg_apv_518"); 	//부서감사, 부서준법은 1인 접수가 불가능하여 항목에서 제외됩니다.
		
		msgConfirm += "\n";
		msgWarning += "\n";
	}
	msgConfirm += Common.getDic("msg_127");  // 처리 하시겠습니까?
	msgWarning += Common.getDic("msg_apv_003"); //선택된 항목이 없습니다.
	
	// 체크된 항목 확인
	//var checkApprovalList = gridObj.getCheckedList(0);
	var checkApprovalList = gridObj.getCheckedList(1);
	if(checkApprovalList.length == 0){
		Common.Warning(msgWarning);
	}else if(checkApprovalList.length > 0){
		Common.Confirm(msgConfirm, "", function(result){ // 처리 하시겠습니까?
			if(result){
				// 결재 비밀번호 사용여부
				var usePwdDocCnt = checkApprovalList.filter(doc => doc.SchemaContext.scWFPwd && doc.SchemaContext.scWFPwd.isUse == 'Y').length;
				
				if (usePwdDocCnt > 0 && chkUsePasswordYN()) {
					Common.Password(Common.getDic("msg_apv_508"), null, Common.getDic("lbl_apv_ApvPwd_Check"), function (apvToken) {
						if (apvToken) {
							if (apvToken.indexOf("e1Value:") > -1) { //생체인증 처리  
								this.fidoCallBack = function(){
									switchBatchApproval(checkApprovalList, approvalType, apvToken, this.g_authKey);
								}
								Common.open("", "checkFido", Common.getDic("lbl_RequestUserAuth"), "/covicore/control/checkFido.do?logonID="+SessionObj["UR_Code"]+"&authType=Approval", "400px", "510px", "iframe", true, null, null, true); //사용자 본인인증 요청
							}else{
								if(chkCommentWrite(apvToken)){
									// 결재 진행
									switchBatchApproval(checkApprovalList, approvalType, apvToken);
								}else{
									// 비밀번호 틀림
									Common.Warning(Common.getDic("msg_PasswordChange_02"));
								}
							}
						}
					});
					
					  // 생체인증 버튼 제어
                    if (useFido == "Y") {
                        setTimeout(function () {
                            var oTargetObj = $("#alert_container").find("#popup_e1")
                            $(oTargetObj).find("strong").text(Common.getDic("lbl_Biometrics"));
                            $(oTargetObj).show();
                        }, 350);
                    }
				}else{
					switchBatchApproval(checkApprovalList, approvalType);
				}
			}
		});
	}else{
		Common.Warning(Common.getDic("msg_ScriptApprovalError"));			// 오류 발생
	}
}

/**
 * 담당업무함, 부서수신함에서 호출했을 경우, 결재선 변경 필요
 * @param approvalList
 * @param approvalType
 */
var arrDomainDataList = {};
function switchBatchApproval(approvalList, approvalType, apvToken, authKey){
	
	var apvToken = aesUtil.encrypt(proaas, proaaI, proaapp, apvToken || "");
	var authKey = authKey || "";

	if(approvalType == "JOBFUNCTION" || approvalType == "DEPT"){
		var processIDs = new Array();
		
		var oApprovalList = {"approvalList" : approvalList};
		
		//부서수신함에서 합의, 협조는 제외 (TODO 부서협조 접수, 반려 스키마 체크시 개발 필요)
		var length = $$(oApprovalList).find("approvalList").concat().length;
		if(approvalType == "DEPT"){
			var oRemove = $$(oApprovalList).find("approvalList").concat().has("[FormSubKind=C],[FormSubKind=AS]");
			for(var i=0; i<oRemove.length; i++){
				$$(oApprovalList).find("approvalList").remove($$(oRemove).eq(0).index());
			}
		}
		
		if($$(oApprovalList).find("approvalList").concat().length > 0)
			processIDs = $$(oApprovalList).find("approvalList").concat().attr("ProcessID");
		
		// 체크항목 결재선 조회
		if($$(oApprovalList).find("approvalList").concat().length > 0){
			$.ajax({
				url:"/approval/getBatchApvLine.do",
				data: {
					"processIDArr" : processIDs.toString()
				},
				type:"post",
				success:function (res) {
					if(res.length > 0){
						if(!SessionObj["ApprovalParentGR_Name"]) SessionObj["ApprovalParentGR_Name"] = SessionObj["GR_MultiName"];
						
						// 각 데이터에 결재선 데이터 포함
						$(res).each(function(i, obj){
							var oApvList = obj.DomainDataContext;
							var formSubKind = $$(oApprovalList).find("approvalList[ProcessID='"+$$(obj).attr("ProcessID")+"']").attr("FormSubKind");
							
							if(formSubKind == "R" || formSubKind == "T008"){		// 수신
								var oCurrentOUNode = $$(oApvList).find("steps > division").children().find("[divisiontype='receive']").has(">taskinfo[status='pending']");
								
								var oRecOUNode = $$(oCurrentOUNode).find("step").has(">ou>taskinfo[status='pending']");	//$$(oCurrentOUNode).find("step:has(ou>taskinfo[status='pending'])");
		                        if (oRecOUNode.length != 0) $$(oCurrentOUNode).find("step").has(">ou>taskinfo[status='pending']").remove();
								
								var oJFNode = $$(oCurrentOUNode).find("step").has("ou>role>taskinfo[status='pending'], ou>role>taskinfo[status='reserved']"); //201108
		                        var bHold = false; //201108 보류여부
		                        var oComment = null;
		                        if (oJFNode.length != 0) {
		                            var oHoldTaskinfo = $$(oJFNode).find("ou>role>taskinfo[status='reserved']");
		                            if (oHoldTaskinfo.length != 0) {
		                                bHold = true;
		                                oComment = $$(oHoldTaskinfo).find("comment").clone();
		                            }
		                            $$(oCurrentOUNode).eq(0).remove("step");
		                        }
	
		                        var deptID = SessionObj["ApprovalParentGR_Code"];
		                        var deptName = SessionObj["ApprovalParentGR_Name"];
	
		                        $$(oCurrentOUNode).attr("oucode", deptID);		// 부서 id
		                        $$(oCurrentOUNode).attr("ouname", deptName);		// 부서 명
		                        
		                        $$(oCurrentOUNode).find("[taskinfo]").attr("status", "pending");
		                        $$(oCurrentOUNode).find("[taskinfo]").attr("result", "pending");
		                        
		                        var oStep = {};
		                        var oOU = {};
		                        var oPerson = {};
		                        var oTaskinfo = {};
	
		                        $$(oStep).attr("unittype", "person");
		                        $$(oStep).attr("routetype", "approve");
		                        $$(oStep).attr("name", Common.getDic("lbl_apv_ChargeDept"));	//gLabel__ChargeDept);
		                        
		                        $$(oOU).attr("code", deptID);		// 부서 id
		                        $$(oOU).attr("name", deptName);		// 부서 명
		                        
		                        $$(oPerson).attr("code", SessionObj["USERID"]);		// 사용자 id
		                        $$(oPerson).attr("name", SessionObj["UR_MultiName"]);		// 사용자 명
		                        $$(oPerson).attr("position", SessionObj["UR_JobPositionCode"] + ";" + SessionObj["UR_MultiJobPositionName"]);							// position 코드;position 명
		                        $$(oPerson).attr("title", SessionObj["UR_JobTitleCode"] + ";" + SessionObj["UR_MultiJobTitleName"]);				// title 코드;title 명
		                        $$(oPerson).attr("level", SessionObj["UR_JobLevelCode"] + ";" + SessionObj["UR_MultiJobLevelName"]);								// level 코드;level 명
		                        $$(oPerson).attr("oucode", SessionObj["DEPTID"]);			// 부서 id
		                        $$(oPerson).attr("ouname", SessionObj["GR_MultiName"]);		// 부서 명
		                        $$(oPerson).attr("sipaddress", SessionObj["UR_Mail"]);		// 사용자 이메일
		                        
		                        $$(oTaskinfo).attr("status", (bHold == true ? "reserved" : "pending")); //201108
		                        $$(oTaskinfo).attr("result", (bHold == true ? "reserved" : "pending")); //201108
		                        $$(oTaskinfo).attr("kind", "charge");
		                        $$(oTaskinfo).attr("datereceived", XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss", new Date()));			// 현재 시각
		                        if (bHold) $$(oTaskinfo).append(oComment); //201108
		                        
		                        $$(oPerson).append("taskinfo", oTaskinfo);
		                        
		                        $$(oOU).append("person", oPerson);
		                        
		                        $$(oStep).append("ou", oOU);
		                        
		                        $$(oCurrentOUNode).append("step", oStep);
		                        
							}/*else if(formSubKind == "AS"){		// 부서협조
								//TODO
							}*/
							
	                        $$(oApprovalList).find("approvalList[ProcessID='"+$$(obj).attr("ProcessID")+"']").append("ApvLine", oApvList);
						});
						approvalList = $$(oApprovalList).find("approvalList").json();
						doEngineBatchApproval(approvalList, approvalType, apvToken, authKey);
					}else{
						Common.Inform(Common.getDic("msg_apv_319"));
						
						setDocreadCount(approvalType);
						
						if(typeof(setAccountDocreadCount) != "undefined") {
							setAccountDocreadCount();
						}
						
						if(typeof(setSubMenu) != "undefined") {
							setSubMenu();
						}
						
						ListGrid.reloadList();
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/getBatchApvLine.do", response, status, error);
				}
			});
		}else{
			Common.Inform(Common.getDic("msg_apv_319"));
			ListGrid.reloadList();
		}
	}else{
		var processIDs = new Array();
		
		var oApprovalList = {"approvalList" : approvalList};			
		if($$(oApprovalList).find("approvalList").concat().length > 0)
			processIDs = $$(oApprovalList).find("approvalList").concat().attr("ProcessID");
		
		// 체크항목 결재선 조회
		if($$(oApprovalList).find("approvalList").concat().length > 0){
			$.ajax({
				url:"/approval/getBatchApvLine.do",
				data: {
					"processIDArr" : processIDs.toString()
				},
				type:"post",
				success:function (res) {
					if(res.length > 0){
						// 각 데이터에 결재선 데이터 포함
						$(res).each(function(i, obj){
							// 검토 진행 중 결재 못하도록 함.
							var domainDataContext = obj.DomainDataContext;
							var oCurrApprovalList = $$(oApprovalList).find("approvalList[ProcessID='"+$$(obj).attr("ProcessID")+"']");
							var oCurrentPersonNode = $$(domainDataContext).find("steps > division > step > ou[wiid="+ oCurrApprovalList.attr("WorkItemID") +"] > person");
							
							if($$(oCurrentPersonNode).find(">taskinfo").attr("result") === "consultation"){
								alert(Common.getDic("lbl_apv_notBatchApvConsultingDoc")); // 검토 요청 중인 문서는 일괄 결재 대상에서 제외됩니다.
								approvalList = approvalList.filter(function(item) { if(item.ProcessID !== $$(obj).attr("ProcessID")) return this; })
							} else if (oCurrApprovalList.attr("FormSubKind") == "T023"){
								alert(Common.getDic("lbl_apv_notBatchApvConsultDoc")); //"검토 문서는 일괄 결재 대상에서 제외됩니다."
								approvalList = approvalList.filter(function(item) { if(item.ProcessID !== $$(obj).attr("ProcessID")) return this; })
							} else {
								arrDomainDataList[$$(obj).attr("ProcessID")] = obj.DomainDataContext;
							}
						});
						
						doEngineBatchApproval(approvalList, approvalType, apvToken, authKey);
					}else{
						Common.Inform(Common.getDic("msg_apv_319"));
						
						setDocreadCount(approvalType);
						
						if(typeof(setAccountDocreadCount) != "undefined") {
							setAccountDocreadCount();
						}
						
						if(typeof(setSubMenu) != "undefined") {
							setSubMenu();
						}
						
						ListGrid.reloadList();
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/getBatchApvLine.do", response, status, error);
				}
			});
		}else{
			Common.Inform(Common.getDic("msg_apv_319"));
			ListGrid.reloadList();
		}
	}
}

// 일괄결재 진행
var doEngineBatchApprovalCnt = 0;
var errorCnt = 0;
/**
 * 일괄결재 진행
 * @param approvalList
 * @param approvalType
 */
function doEngineBatchApproval(approvalList, approvalType, apvToken, authKey){
	doEngineBatchApprovalCnt =0;
	errorCnt = 0;
	
	// 일괄결재 API 호출
	Common.Progress();
	
	var sSign = getUserSignInfo(SessionObj["USERID"]);
	$(approvalList).each(function(i, obj){
		var actionMode = "";
		var subkind = obj.FormSubKind;
		var taskId = obj.TaskID;
		var mode = "APPROVAL";
		
		if(subkind == "T009" || subkind == "T004"){		// 합의 및 협조
			actionMode = "AGREE";
			mode = "PCONSULT";
		}else if((subkind == "C" || subkind == "AS" || subkind == "AD") && approvalType == "DEPT"){
			actionMode = "REDRAFT";
			mode = "SUBREDRAFT";
		}else if(subkind == "T016"){
			actionMode = "APPROVAL";
			mode = "AUDIT";
		}else if(subkind == "T008"){
			actionMode = "APPROVAL";
			mode = "REDRAFT";
		}else{
			actionMode = "APPROVAL";
			if(obj.ProcessName == "Sub"){
				mode = "SUBAPPROVAL";
			}else{
				mode = "APPROVAL";
			}
		}
		
	    var sJsonData = {};
	    
	    $.extend(sJsonData, {"mode": mode});
	    $.extend(sJsonData, {"subkind": subkind});
	    $.extend(sJsonData, {"taskID": taskId});
    	$.extend(sJsonData, {"FormInstID" : obj.FormInstID});
	    $.extend(sJsonData, {"actionMode": actionMode});
	    $.extend(sJsonData, {"actionComment": ""});
	    $.extend(sJsonData, {"actionComment_Attach": "[]"});
	    $.extend(sJsonData, {"signimagetype" : sSign});
	    $.extend(sJsonData, {"gloct" : ""});
	    $.extend(sJsonData, {"isBatch": "Y"}); // 일괄결재 표시여부
	    $.extend(sJsonData, {"processName": obj.ProcessName}); //프로세스이름
	    $.extend(sJsonData, {"g_password" : apvToken});
	    $.extend(sJsonData, {"g_authKey" : authKey});
	    $.extend(sJsonData, {"formID" : obj.FormID});
	    $.extend(sJsonData, {"formDraftkey" : obj.formDraftkey});
	    $.extend(sJsonData, {"usid" : obj.InitiatorID});
	    if(obj.ApvLine != undefined){
	    	$.extend(sJsonData, {"processID" : obj.ProcessID});
	    	$.extend(sJsonData, {"ChangeApprovalLine" : obj.ApvLine});
	    }
	    
	    // 대결자가 결재하는 경우 결재선 변경
	    if(arrDomainDataList[obj.ProcessID] != null && arrDomainDataList[obj.ProcessID] != undefined) {
	    	var apvList = setDeputyList(mode, subkind, taskId, actionMode, "", obj.FormInstID, "N", obj.ProcessID, obj.UserCode);
		    
		    if(apvList != arrDomainDataList[obj.ProcessID]){
		    	$.extend(sJsonData, {"processID" : obj.ProcessID});
		    	$.extend(sJsonData, {"ChangeApprovalLine" : apvList});
		    }	
	    }
	    
	    var formData = new FormData();
	    // 양식 기안 및 승인 정보
		formData.append("formObj", Base64.utf8_to_b64(JSON.stringify(sJsonData)));
		
		setTimeout(function(){
			$.ajax({
				url:"/approval/draft.do",
				data: formData,
				type:"post",
				dataType : 'json',
				processData : false,
		        contentType : false,
				success:function (res) {
					++doEngineBatchApprovalCnt;
					if((res.status == "FAIL" && res.message.indexOf("NOTASK")<0) || res.status == "FAIL")
						errorCnt++;
					
					if(doEngineBatchApprovalCnt == approvalList.length){
						if(errorCnt > 0)
							Common.Warning(Common.getDic("msg_BatchApprovalResult").replace("{0}", approvalList.length).replace("{1}", errorCnt));
						else
							Common.Inform(Common.getDic("msg_apv_alert_006"));
						
						setDocreadCount(approvalType == "DEPT" ? approvalType : "USER");
						
						if(typeof(setAccountDocreadCount) != "undefined") {
							setAccountDocreadCount();
						}
						
						if(typeof(setSubMenu) != "undefined") {
							setSubMenu();
						}
						
						ListGrid.reloadList();
						
						if(ListGrid.page.pageSize * (ListGrid.page.pageNo-1) == (ListGrid.page.listCount-1) ){
							$("input[id=AXPaging][value="+(ListGrid.page.pageNo-1)+"]").click();
						}
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/approval/draft.do", response, status, error);
				}
			});
		}, 0);
	});
	
	if($(approvalList).length == 0){
		Common.Inform(Common.getDic("msg_apv_319"));
		
		setDocreadCount(approvalType == "DEPT" ? approvalType : "USER");
		
		if(typeof(setAccountDocreadCount) != "undefined") {
			setAccountDocreadCount();
		}
		
		if(typeof(setSubMenu) != "undefined") {
			setSubMenu();
		}
		
		ListGrid.reloadList();
	}
}

// Mobile 호환성 처리
var g_dicFormInfo = null;
if(!window.Dictionary) {
	window.Dictionary = function(){
		var _item = new Object();
		this.Add = function(key, value) {
			_item[key] = value;
		};
		this.item = function(key){
			return _item[key];
		}
	}
} else if(!_mobile){ // 모바일 예외처리
	// 부서 수신함 [일괄결재선] 기능에서 결재선 지정창 띄울때 결재양식과 동일하게 opener.getInfo("Request.mode") 로 가져와서 제어하려고 사용하는듯, 경비결재에서도 사용중
	// 모바일은 리스트/양식 간에 객체가 공유되므로 양식에서 getInfo 모두 오류발생해서 예외처리
	g_dicFormInfo = new Dictionary();
	g_dicFormInfo.Add("Request.mode","DEPTLIST");
	g_dicFormInfo.Add("CLSYS","approval");
	g_dicFormInfo.Add("etid","A1");
}

// 일괄결재선
var batchApvLineGrid;
/**
 * 일괄결재선
 * @param approvalList
 */
function BatchApvLine(approvalList){
	
	//일괄 결재 사용을 하지 않는 문서는 체크 제외
	var excludeItem = false;
	$.each(approvalList.getCheckedListWithIndex(1), function(idx,obj){
		if(typeof obj.item.ExtInfo == 'undefined'  || obj.item.ExtInfo.UseBlocApprove != 'Y'){
			excludeItem = true;
			approvalList.checkedColSeq(1,false,obj.index);
		}
	});
	
	var msgWarning = '';

	if(excludeItem){
		msgWarning += Common.getDic("msg_blocApprove");  	//일괄결재를 지원하지 않는 양식은 항목에서 제외됩니다.
		msgWarning += "\n";
	}
	msgWarning += Common.getDic("msg_apv_003"); //선택된 항목이 없습니다.
	
	var checkApprovalList = approvalList.getCheckedList(1);
	if(checkApprovalList.length == 0){
		Common.Warning(msgWarning);
	}else if(checkApprovalList.length > 0){

		if(!SessionObj["ApprovalParentGR_Name"]) SessionObj["ApprovalParentGR_Name"] = SessionObj["GR_MultiName"];
		
		batchApvLineGrid = approvalList;
		
		var strApvListBATCH = {};
		
		var deptID = SessionObj["ApprovalParentGR_Code"];
        var deptName = SessionObj["ApprovalParentGR_Name"];
		
        var oSteps = {};
		var oTaskInfo = {};
		var oDivision = {};
		var oStep = {};
		var oOu = {};
		var oPerson = {};
		var oPTaskInfo = {};
		
		$$(oTaskInfo).attr("kind", "receive");
		$$(oTaskInfo).attr("result", "pending");
		$$(oTaskInfo).attr("status", "pending");
		
		$$(oDivision).append("taskinfo", $$(oTaskInfo).json());
		
		$$(oStep).attr("name", "담당부서");
		$$(oStep).attr("unittype", "person");
		$$(oStep).attr("routetype", "approve");
		
		$$(oOu).attr("name", deptName);
		$$(oOu).attr("code", deptID);
		
		$$(oPerson).attr("code", SessionObj["USERID"]);		// 사용자 id
        $$(oPerson).attr("name", SessionObj["UR_MultiName"]);		// 사용자 명
        $$(oPerson).attr("position", SessionObj["UR_JobPositionCode"] + ";" + SessionObj["UR_MultiJobPositionName"]);							// position 코드;position 명
        $$(oPerson).attr("title", SessionObj["UR_JobTitleCode"] + ";" + SessionObj["UR_MultiJobTitleName"]);				// title 코드;title 명
        $$(oPerson).attr("level", SessionObj["UR_JobLevelCode"] + ";" + SessionObj["UR_MultiJobLevelName"]);								// level 코드;level 명
        $$(oPerson).attr("oucode", SessionObj["DEPTID"]);			// 부서 id
        $$(oPerson).attr("ouname", SessionObj["GR_MultiName"]);		// 부서 명
        $$(oPerson).attr("sipaddress", SessionObj["UR_Mail"]);		// 사용자 이메일
		
        $$(oPTaskInfo).attr("kind", "charge");
		$$(oPTaskInfo).attr("result", "pending");
		$$(oPTaskInfo).attr("status", "pending");
		$$(oPTaskInfo).attr("datereceived", XFN_getDateTimeString("yyyy-MM-dd HH:mm:ss", new Date()));			// 현재 시각
		
		$$(oPerson).append("taskinfo", $$(oPTaskInfo).json());
        
		$$(oOu).append("person", $$(oPerson).json());
		
		$$(oStep).append("ou", $$(oOu).json());
		
		$$(oDivision).append("step", $$(oStep).json());
		
		$$(oDivision).attr("name", "수신");
		$$(oDivision).attr("divisiontype", "receive");
		
		$$(oSteps).append("division", $$(oDivision).json());
		
		$$(strApvListBATCH).append("steps", $$(oSteps).json());
		
		document.getElementById("APVLIST").value = JSON.stringify($$(strApvListBATCH).json());
		
	    var iHeight = 580;
	    var iWidth = 1110;
	    var sSize = "fix";
	    
	    var sUrl = "/approval/approvalline.do";
	    CFN_OpenWindow(sUrl, "", iWidth, iHeight, sSize);
	}
}

/**
 * 일괄결재선 조직도에서 확인 버튼
 * @param approvalType
 */
function goBatchApvLine(approvalType){
	var recItemChk = false;
	var addApvList = $.parseJSON(document.getElementById("APVLIST").value);
	if($$(addApvList).find("step").has("taskinfo[kind!='charge']").length == 0){
		$.each(batchApvLineGrid.getCheckedListWithIndex(1), function(idx,obj){
			if(typeof obj.item.SchemaContext !== 'undefined' && obj.item.SchemaContext.scChrRedraft.isUse !== "Y"){
				recItemChk = true;
				batchApvLineGrid.checkedColSeq(1,false,obj.index);
			}
		});
	}
	
	var msgWarning = '';

	if(recItemChk){
		msgWarning += Common.getDic("msg_apv_513");  	//수신부서 1인결재가 허용되지 않는 문서는 제외됩니다.
		msgWarning += "\n";
	}

	var checkApprovalList = batchApvLineGrid.getCheckedList(1);
	if(checkApprovalList.length == 0){
		msgWarning += Common.getDic("msg_apv_003"); //선택된 항목이 없습니다.
		Common.Warning(msgWarning);
	}else if(checkApprovalList.length > 0){
		batchApvLineGrid = checkApprovalList;
		msgWarning += Common.getDic("msg_127");
		Common.Confirm(msgWarning, "", function(result){
			if(result){
				// 결재 비밀번호 사용여부
				if(chkUsePasswordYN()){
					Common.Password(Common.getDic("msg_apv_508"), null, Common.getDic("lbl_apv_ApvPwd_Check"), function (apvToken) {
						if (apvToken) {
							if(chkCommentWrite(apvToken)){
								// 결재 진행
								switchBacthApvLine(batchApvLineGrid, approvalType, apvToken, this.g_authKey);
							}else{
								// 비밀번호 틀림
								Common.Warning(Common.getDic("msg_PasswordChange_02"));
							}
	                    }
					});
				}else{
					switchBacthApvLine(batchApvLineGrid, approvalType);
				}
			}
		});
	}
}

/**
 * 일괄결재선 결재선 수정
 * @param approvalList
 * @param approvalType
 */
function switchBacthApvLine(approvalList, approvalType, apvToken, authKey){

	var apvToken = aesUtil.encrypt(proaas, proaaI, proaapp, apvToken || "");
	var authKey = authKey || "";

	if(approvalType == "DEPT"){
		var processIDs = new Array();
		
		$(approvalList).each(function(i,obj){
			processIDs.push($$(obj).attr("ProcessID"));
		});
		
		// 체크항목 결재선 조회
		$.ajax({
			url:"/approval/getBatchApvLine.do",
			data: {
				"processIDArr" : processIDs.toString()
			},
			type:"post",
			success:function (res) {
				if(res.length > 0){
					// 각 데이터에 결재선 데이터 포함
					var oApprovalList = {"approvalList" : approvalList};
					$(res).each(function(i, obj){
						var oApvList = obj.DomainDataContext;
						var addApvList = $.parseJSON(document.getElementById("APVLIST").value);

						var formSubKind = $$(oApprovalList).find("approvalList[ProcessID='"+$$(obj).attr("ProcessID")+"']").attr("FormSubKind");
						
						if(formSubKind == "R"){				//부서수신
							$$(oApvList).find("division[processID='"+$$(obj).attr("ProcessID")+"']").find("step").remove();
							$$(oApvList).find("division[processID='"+$$(obj).attr("ProcessID")+"']").append("step", $$(addApvList).find("step").json());
						}else if(formSubKind == "C" || formSubKind == "AS"){		//부서합의
							var oStep;
							
							oStep = $$(addApvList).find("step>ou>person");
							
							// 재기안자 정보 수정
							$$(oStep).concat().eq(0).find("taskinfo").attr("result", "inactive");
							$$(oStep).concat().eq(0).find("taskinfo").attr("status", "inactive");
							$$(oStep).concat().eq(0).find("taskinfo").remove("datereceived");
							
							if($$(oApvList).find("division").find("step > ou[code='"+SessionObj["DEPTID"]+"']").has("taskinfo[result=pending").length > 0){
    							$$(oApvList).find("division").find("step > ou[code='"+SessionObj["DEPTID"]+"']").has("taskinfo[result=pending").append("person",$$(oStep).json());
							} else {
    							$$(oApvList).find("division").find("step > ou").has("[code='"+SessionObj["DEPTID"]+"'] > taskinfo[result=pending").append("person",$$(oStep).json());
							}
						}else{
							
						}
						
                        $$(oApprovalList).find("approvalList[ProcessID='"+$$(obj).attr("ProcessID")+"']").append("ApvLine", oApvList);
					});
					approvalList = $$(oApprovalList).find("approvalList").json();
					doEngineBatchApproval(approvalList, approvalType, apvToken, authKey);
				}else{
					Common.Inform(Common.getDic("msg_apv_319"));
					
					setDocreadCount(approvalType);
					
					if(typeof(setAccountDocreadCount) != "undefined") {
						setAccountDocreadCount();
					}
					
					if(typeof(setSubMenu) != "undefined") {
						setSubMenu();
					}
					
					ListGrid.reloadList();
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/getBatchApvLine.do", response, status, error);
			}
		});
	}else{
		doEngineBatchApproval(approvalList, approvalType, apvToken, authKey);
	}
}

/**
 * 일괄확인
 * @param gridObj
 */
function BatchCheck(gridObj){
	strPiid_List = "";
	strWiid_List = "";
	strFiid_List = "";
	strPtid_List = "";
	strKind_List = "";
	
	strBizData2_List = "";
	strTaskID_List = "";
	
	var str_mode = g_mode.toUpperCase();
	
	var excludeItem = false;
	if (document.getElementById("bstored") != null && document.getElementById("bstored").value == "true") {
	} else {
		$.each(gridObj.getCheckedListWithIndex(1), function(idx,obj){
			if(typeof obj.item.ExtInfo == 'undefined'  || obj.item.ExtInfo.UseBlocCheck != 'Y'){
				excludeItem = true;
				gridObj.checkedColSeq(1,false,obj.index);
			}
		});
	}
	
	var msgWarning = '';
	if(excludeItem){
		msgWarning += Common.getDic("msg_blocCheck");		//일괄확인을 지원하지 않는 양식은 항목에서 제외됩니다.
		msgWarning += "\n";
	}
	msgWarning += Common.getDic("msg_apv_003");			//선택된 항목이 없습니다.
	
	// 체크된 항목 확인
	//var checkCheckList = gridObj.getCheckedList(0);
	var checkCheckList = gridObj.getCheckedList(1);
	if(checkCheckList.length == 0){
		Common.Warning(msgWarning);
	}else if(checkCheckList.length > 0){
		// 양식 오픈
		for(var i = 0; i < checkCheckList.length; i++){
			//if(mnid_chk == "477" || mnid_chk == "478" || mnid_chk == "479" || mnid_chk == "483"){
			if(str_mode == "PREAPPROVAL" || str_mode == "APPROVAL" || str_mode == "PROCESS" || str_mode == "TCINFO" || str_mode == "DEPTTCINFO"){
				strPiid_List += checkCheckList[i].ProcessID == "undefined" || checkCheckList[i].ProcessID == undefined ? ";" : checkCheckList[i].ProcessID + ";";
				strWiid_List += checkCheckList[i].WorkItemID == "undefined" || checkCheckList[i].WorkItemID == undefined ? ";" : checkCheckList[i].WorkItemID + ";";
			}else{
				strPiid_List += checkCheckList[i].ProcessArchiveID == "undefined" || checkCheckList[i].ProcessArchiveID == undefined ? ";" : checkCheckList[i].ProcessArchiveID + ";";
				strWiid_List += checkCheckList[i].WorkitemArchiveID == "undefined" || checkCheckList[i].WorkitemArchiveID == undefined ? ";" : checkCheckList[i].WorkitemArchiveID + ";";
			}
			
			if(str_mode == "DEPTTCINFO") {
				strPtid_List += checkCheckList[i].ReceiptID == "undefined" || checkCheckList[i].ReceiptID == undefined ? ";" : checkCheckList[i].ReceiptID + ";";
			} else {
				strPtid_List += checkCheckList[i].UserCode == "undefined" || checkCheckList[i].UserCode == undefined ? ";" : checkCheckList[i].UserCode + ";";
			}

			
			strFiid_List += checkCheckList[i].FormInstID == "undefined" || checkCheckList[i].FormInstID == undefined ? ";" : checkCheckList[i].FormInstID + ";";
			/*strPtid_List += checkCheckList[i].UserCode == "undefined" || checkCheckList[i].UserCode == undefined ? ";" : checkCheckList[i].UserCode + ";";*/
			strKind_List += checkCheckList[i].FormSubKind == "undefined" || checkCheckList[i].FormSubKind == undefined ? ";" : checkCheckList[i].FormSubKind + ";";
			
			strBizData2_List += checkCheckList[i].BusinessData2 == "undefined" || checkCheckList[i].BusinessData2 == undefined ? ";" : checkCheckList[i].BusinessData2 + ";";
			strTaskID_List += checkCheckList[i].TaskID == "undefined" || checkCheckList[i].TaskID == undefined ? ";" : checkCheckList[i].TaskID + ";";
		}
		
		var mode = "";
		var ProcessID = strPiid_List.split(";")[0];
		var WorkItemID = strWiid_List.split(";")[0];
		var FormInstID = strFiid_List.split(";")[0];
		var userID = "";
		var UserCode = strPtid_List.split(";")[0];
		var Kind = strKind_List.split(";")[0];
		
		var BizData2 = strBizData2_List.split(";")[0];
		var TaskID = strTaskID_List.split(";")[0];
		
		var archived = "false";
		var bstored = "false";
		//switch (mnid_chk){
		switch (str_mode){
			case "PREAPPROVAL" : 		// 예고함
				mode="PREAPPROVAL";
				gloct = "PREAPPROVAL";
				userID=UserCode;
				break;
			case "APPROVAL" :    // 미결함
				mode="APPROVAL";
				gloct = "APPROVAL";
				userID=UserCode;
				break;
			case "PROCESS" :		// 진행함
				mode="PROCESS";
				gloct = "PROCESS";
				userID=UserCode;
				break;
			case "COMPLETE" : 	// 완료함
				mode="COMPLETE"; 
				gloct = "COMPLETE"; 
				archived="true"; 
				userID=UserCode; 
				if (document.getElementById("bstored") != null && document.getElementById("bstored").value == "true") {
					bstored = "true";
				}
				break;
			case "REJECT" : 		// 반려함
				mode="REJECT"; 
				gloct = "REJECT";
				archived="true"; 
				userID=UserCode; 
				break;
			case "TCINFO" :		// 참조/회람함 
				mode="COMPLETE";
				gloct = "TCINFO";
				archived = "";
				userID=UserCode;
				if (document.getElementById("bstored") != null && document.getElementById("bstored").value == "true") {
					bstored = "true";
				}
				break;
			case "DEPTTCINFO" :		// 참조/회람함 
				mode="COMPLETE";
				gloct = "DEPART";
				archived = "";
				userID=UserCode;
				if (document.getElementById("bstored") != null && document.getElementById("bstored").value == "true") {
					bstored = "true";
				}
				break;
			case "DEPTCOMPLETE":	// 부서 참조/회람함(이관함)
				mode="COMPLETE"; 
				gloct = "COMPLETE"; 
				archived="true"; 
				userID=UserCode;
				if (document.getElementById("bstored") != null && document.getElementById("bstored").value == "true") {
					bstored = "true";
				}
				break;
		}
		var width = 1070; //일괄확인 가로양식으로 띄우기

		if(excludeItem){
			Common.Warning(Common.getDic("msg_blocCheck"),"Warning",function(ret){	//일괄확인을 지원하지 않는 양식은 항목에서 제외됩니다.
				CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&userCode="+userID+"&gloct="+gloct+"&forminstanceID="+FormInstID+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N"+"&subkind="+Kind+"&ExpAppID="+BizData2+"&taskID="+TaskID, "", width, (window.screen.height - 100), "resize");
			}); 
		}else{
			CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&userCode="+userID+"&gloct="+gloct+"&forminstanceID="+FormInstID+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N"+"&subkind="+Kind+"&ExpAppID="+BizData2+"&taskID="+TaskID+"&bstored="+bstored, "", width, (window.screen.height - 100), "resize");
		}
	}else{
		Common.Error(Common.getDic("msg_ScriptApprovalError"));			// 오류 발생
	}
}

/**
 * 삭제
 */
function DeleteCheck(gridObj,type){
	// 체크된 항목 확인
	var checkCheckList 		= gridObj.getCheckedList(1);
	var FormInstIdTemp 		= []; //임시함Form인서트아이디
	var FormInstId 	   		= "";
	var FormInstBoxIdTemp 	= []; //임시함Form인서트박스아이디
	var FormInstBoxId 		= "";
	var WorkItemIdTemp 		= []; //반려함Form인서트박스아이디
	var WorkItemId 			= "";
	//
	if(checkCheckList.length == 0){
		Common.Warning(Common.getDic("msg_apv_003"));				//선택된 항목이 없습니다.
	}else if(checkCheckList.length > 0){
		//
		if(type == "TempSave"){ //임시함
			for(var i = 0; i < checkCheckList.length; i++){
				FormInstIdTemp.push(checkCheckList[i].FormInstID)
				FormInstBoxIdTemp.push(checkCheckList[i].FormTempInstBoxID)
			}
			FormInstId = FormInstIdTemp.join(",");
			FormInstBoxId = FormInstBoxIdTemp.join(",");
			//
		}else{ //반려함
			for(var i = 0; i < checkCheckList.length; i++){
				WorkItemIdTemp.push(checkCheckList[i].WorkitemArchiveID);
			}
			WorkItemId = WorkItemIdTemp.join(",");
		}
		Common.Confirm(Common.getDic("msg_apv_093"), "Inform", function (result) {
			if (result) {
				$.ajax({
					url:"/approval/deleteTempSaveList.do",
					type:"post",
					data:{
		 				"FormInstId":FormInstId,
		 				"FormInstBoxId":FormInstBoxId,
		 				"WorkItemId":WorkItemId,
		 				"type":type
						},
					async:false,
					success:function (res) {
						ListGrid.reloadList(); //Grid만 reload되도록 변경
					},
					error:function(response, status, error){
						CFN_ErrorAjax("/approval/deleteTempSaveList.do", response, status, error);
					}
				});
			}
		});
	}else{
		Common.Error(Common.getDic("msg_ScriptApprovalError"));			// 오류 발생
	}
}

/* 엑셀저장 */
/**
 * 함 엑설저장
 * @param selectParams
 * @param headerData
 * @param listCount
 */
function ExcelDownLoad(selectParams, headerData, listCount){
	var queryID = "";
	var title = "";
	
	switch (g_mode.toUpperCase()){
	case "APPROVAL":									// 개인 - 미결함
		queryID = "selectApprovalListExcel";
		title = "ApprovalBoxList";
		break;
	case "PROCESS":										// 개인 - 진행함
		queryID = "selectProcessListExcel";
		title = "ProcessBoxList";
		break;
	case "COMPLETE":									// 개인 - 완료함
		queryID = "selectCompleteListExcel";
		if(bstored == "true"){queryID ="selectStoreCompleteListExcel";} // 이관문서 엑셀다운로드
		if (typeof(g_submode) != "undefined" && g_submode == "Admin"){ // 2020-12-02 이관문서)
			queryID = "selectCompleteListExcelStoreAdmin";
		}
		title = "CompleteBoxList";
		break;
	case "REJECT":											// 개인 - 반려함
		queryID = "selectRejectListExcel";
		if(bstored == "true"){queryID ="selectStoreRejectListExcel";} // 이관문서 엑셀다운로드
		title = "RejectBoxList";
		break;
	case "TCINFO":										// 개인 - 참조회람함
		queryID = "selectTCInfoListExcel";
		if(bstored == "true"){queryID ="selectStoreTCInfoListExcel";} //  이관문서 엑셀다운로드
		title = "TCInfoBoxList";
		break;
	case "RECEXHIBIT":									// 개인 - 수신공람함
		queryID = "selectReceiveExhibitListExcel";
		title = "RecExhibitBoxList";
		break;
	case "DEPTCOMPLETE":					// 부서 - 완료함
		queryID = "selectDeptDraftCompleteListExcel";	
		if(bstored == "true"){queryID ="selectStoreDeptDraftCompleteListExcel";} // 이관문서 엑셀다운로드 	
		title = "DeptDraftCompleteBoxList";
		break;
	case "SENDERCOMPLETE":					// 부서 - 발신함
		queryID = "selectDeptSenderCompleteListExcel";
		title = "DeptSenderCompleteBoxList";
		break;
	case "RECEIVE":								// 부서 - 수신함
		queryID = "selectDeptReceiveListExcel";
		title = "DeptReceiveBoxList";
		break;
	case "RECEIVECOMPLETE":					// 부서 - 수신처리함
		queryID = "selectDeptReceiveCompleteListExcel";
		title = "DeptReceiveCompleteBoxList";
		break;
	case "DEPTTCINFO":									// 부서 - 참조회람함
		queryID = "selectDeptTCInfoListExcel";
		if(bstored == "true"){queryID ="selectStoreDeptTCInfoListExcel";} // 이관문서 엑셀다운로드
		title = "DeptTCInfoBoxList";
		break;
	case "DEPTPROCESS":					// 부서 - 진행함
		queryID = "selectDeptReceiveProcessListExcel";
		title = "DeptReceiveProcessBoxList";
		break;
	case "DEPTRECEXHIBIT":					// 부서 - 수신공람함
		queryID = "selectDeptReceiveExhibitListExcel";
		title = "DeptReceiveExhibitBoxList";
		break;
	case "JOBAPPROVAL":								// 담당업무 - 미결함
		queryID = "selectJobFunctionApprovalListExcel";
		title = "JobFunction_ApprovalList";
		break;
	case "JOBPROCESS":								// 담당업무 - 진행함
		queryID = "selectJobFunctionProcessListExcel";
		title = "JobFunction_ProcessList";
		break;
	case "JOBCOMPLETE":								// 담당업무 - 완료함
		queryID = "selectJobFunctionCompleteListExcel";
		title = "JobFunction_CompleteList";
		break;
	case "JOBREJECT":									// 담당업무 - 반려함
		queryID = "selectJobFunctionRejectListExcel";
		title = "JobFunction_RejectList";
		break;
    case "AUDITDEPTPROCESS":                            // 감사함 - 진행함
        queryID = "selectAuditDeptProcessListExcel";
        title = "AuditDeptCompleteBoxList";
        break;
    case "AUDITDEPTCOMPLETE":                            // 감사함 - 완료함
		queryID = "selectAuditDeptCompleteListExcel";
		title = "AuditDeptCompleteBoxList";
		break;
	case "BIZDOCPROCESS":								// 업무문서함 - 진행함
		queryID = "selectBizDocProcessListExcel";
		title = "BizDoc_ProcessList";
		break;
	case "BIZDOCCOMPLETE":								// 업무문서함 - 완료함
		queryID = "selectBizDocCompleteListExcel";
		title = "BizDoc_CompleteList";
		break;
	case "DOCTYPE":										// 문서분류함
		queryID = "selectDocTypeListExcel";
		title = "DocTypeList";
		break;
	case "SIMPLEAGGREGATION":
		selectParams["aggFormId"] = $("#aggregationBoxs").val(); 
		title = "SimpleAggregationList";
		break;
	}
	
	if(listCount == 0){
		Common.Warning(Common.getDic("msg_apv_279"));							//저장할 문서가 없습니다.
	}else if(listCount > 0){
		if(confirm(Common.getDic("msg_ExcelDownMessage"))){
			location.href = "/approval/user/approvalListExcelDownload.do?"
				+"selectParams="+encodeURIComponent(JSON.stringify(selectParams))
				+"&queryID="+queryID
				+"&title="+title
				+"&approvalListType="+approvalListType
				+"&headerkey="+encodeURIComponent(headerData[0])
				+"&headername="+encodeURIComponent(encodeURIComponent(headerData[1]))			// 한글 깨짐 문제 때문에 두번 encode
				+"&bstored="+bstored; // 이관문서
		}
	}else{
		Common.Error(Common.getDic("msg_ScriptApprovalError"));			// 오류 발생
	}
}


/**
 * 엑셀 저장시 필요한 헤더값 저장
 * 반드시 Grid의 Header 변수는 jsp 의 스크립트에서 전역 변수로 "headerData"로 선언해야 함
 */
function getHeaderDataForExcel(){
	var returnArr = new Array();
	var headerKey = "";
	var headerName = "";
	
	//Grid List 내부에 이미지와 상세정보가 제목 내부에 표시될경우 header의 정보를 참조하지 않음
	if($(".listinfo").length>0){
		//if(mnid==479){}
		if(g_mode.toUpperCase() == "PROCESS"){
			headerKey = "SubKind,FormSubject,InitiatorUnitName,InitiatorName,Finished,FormName,IsFile,IsComment,IsModify,";
		}else{
			headerKey = "SubKind,FormSubject,InitiatorUnitName,InitiatorName,Created,FormName,IsFile,IsComment,IsModify,";
		}
		headerName = String.format("{0};{1};{2};{3};{4};{5};{6};{7};{8};",Common.getDic("lbl_apv_gubun"),Common.getDic("lbl_apv_subject"),Common.getDic("lbl_DraftDept"),Common.getDic("lbl_apv_writer"),Common.getDic("lbl_RepeateDate"),Common.getDic("lbl_FormNm"),Common.getDic("lbl_File"),Common.getDic("lbl_comment"),Common.getDic("lbl_Modify"));
	}
	else {
		for(var i=0;i<headerData.length; i++){
			if(headerData[i].key != "showInfo"){
				if(headerData[i].key == "IsComment") headerData[i].label = "의견"
				if(headerData[i].key == "IsModify") headerData[i].label = "수정"
				
				if(headerData[i].formatter != "checkbox"){
					headerKey += headerData[i].key + ",";
					headerName += headerData[i].label + ";";
				}
			}
		}
	}
	
	returnArr.push(headerKey.slice(0,-1));
	returnArr.push(headerName);
	return returnArr;
}
/**
 * 엑셀 저장시 필요한 헤더값 저장
 * 반드시 Grid의 Header 변수는 jsp 의 스크립트에서 전역 변수로 "headerData"로 선언해야 함
 */
function getHeaderDataForExcel_Eac(){
	var returnArr = new Array();
	var headerKey = "";
	var headerName = "";
	if($(".listinfo").length>0)
	{
		if(g_mode.toUpperCase() == "PROCESS"){
			headerKey = "SubKind,FormSubject,InitiatorUnitName,InitiatorName,Finished,FormName,";
		}else{
			headerKey = "SubKind,FormSubject,InitiatorUnitName,InitiatorName,Created,FormName,";
		}
		headerName = String.format("{0};{1};{2};{3};{4};{5};",Common.getDic("lbl_apv_gubun"),Common.getDic("lbl_apv_subject"),Common.getDic("lbl_DraftDept"),Common.getDic("lbl_apv_writer"),Common.getDic("lbl_RepeateDate"),Common.getDic("lbl_FormNm"));
		
	}
	
	for(var i=0;i<headerData.length; i++){
		if(headerKey.indexOf(headerData[i].key)>-1)
			continue;
		if(headerData[i]['showExcel']){//true
			if(headerData[i].formatter != "checkbox"){
				headerKey += headerData[i].key + ",";
				headerName += headerData[i].label + ";";
			}
		}
	}
	
	returnArr.push(headerKey.slice(0,-1));
	returnArr.push(headerName);
	return returnArr;
}

//탭 구조일 경우 처리
var _func = $;
if($("#tab").css("display") != "none" && $(".l-contents-tabs").css("display") != undefined && $(".l-contents-tabs").css("display") != "none") {
	_func = accountCtrl.getInfoStr;
}

/* 검색 관련 세팅 함수 */
/* approvalListType :
		개인결재함 - user
		부서결재함 - dept
		담당업무함 - jobFunction
		감사문서함 - auditDept
		업무문서함 - bizDoc
		개인폴더함 - userFolder
		관리자:결재문서관리툴 - listAdmin
 */
/**
 * 조회할 때 필요한 Parameter 세팅
 * @param gridObj
 */
function setSelectParams(gridObj){
	
	var seGroupID = _func("#seGroupID");
	var hiddenGroupWord = _func("#hiddenGroupWord");
	var DeputyFromDate = _func("#DeputyFromDate");
	var DeputyToDate = _func("#DeputyToDate");		
	var seSearchID = _func("#seSearchID");
	var searchInput = _func("#searchInput");
	var lowDept = _func("#lowDept");
	
	if(DeputyFromDate.length == 0) {
		DeputyFromDate = _func("#"+g_mode+"DeputyFromDate");
		DeputyToDate = _func("#"+g_mode+"DeputyToDate");
	}
	
	var sePersonID = _func("#sePersonID");
	var titleNm = _func("#titleNm");
	var userNm = _func("#userNm");
	var txtFormSubject = _func("#txtFormSubject");
	var txtInitiatorName = _func("#txtInitiatorName");
	var txtInitiatorUnitName = _func("#txtInitiatorUnitName");
	var txtFormName = _func("#txtFormName");
	var txtDocNo = _func("#txtDocNo");
	var selectDateType = _func("#selectDateType");
	
	var seFuncId = _func("#seFuncId");
	
	var searchGroupType = (typeof(schFrmSeGroupID) != "undefined" && schFrmSeGroupID != "") ? schFrmSeGroupID : seGroupID.attr("value");
	if (typeof(schFrmSeGroupWord) != "undefined" && schFrmSeGroupWord != "") {
		hiddenGroupWord.val(schFrmSeGroupWord);
	}
	var searchGroupWord = searchGroupType == "all" ? "" : hiddenGroupWord.val();
	var startDate = (typeof(schFrmDeputyFromDate) != "undefined" && schFrmDeputyFromDate != "") ? schFrmDeputyFromDate : DeputyFromDate.val();
	var endDate = (typeof(schFrmDeputyToDate) != "undefined" && schFrmDeputyToDate != "") ? schFrmDeputyToDate : DeputyToDate.val();
	
	// 검색 UI 변경으로 인해 수정
	//var searchType = (typeof(schFrmSeSearchID) != "undefined" && schFrmSeSearchID != "") ? schFrmSeSearchID : seSearchID.attr("value");
	//var searchWord = (typeof(schFrmSearchInput) != "undefined" && schFrmSearchInput != "") ? schFrmSearchInput : searchInput.val();
	
	// 상세검색 열림 여부
	var searchType = "";
	var searchWord = "";
	
	var formSubject = (typeof(schFrmFormSubject) != "undefined" && schFrmFormSubject != "") ? schFrmFormSubject : txtFormSubject.val();
	var initiatorName = (typeof(schFrmInitiatorName) != "undefined" && schFrmInitiatorName != "") ? schFrmInitiatorName : txtInitiatorName.val();
	var initiatorUnitName = (typeof(schFrmInitiatorUnitName) != "undefined" && schFrmInitiatorUnitName != "") ? schFrmInitiatorUnitName : txtInitiatorUnitName.val();
	var formName = (typeof(schFrmFormName) != "undefined" && schFrmFormName != "") ? schFrmFormName : txtFormName.val();
	var docNo = (typeof(schFrmDocNo) != "undefined" && schFrmDocNo != "") ? schFrmDocNo : txtDocNo.val();
	
	if (_func('#DetailSearch').css('display') == "none") { // all
		searchType = "all";
		searchWord = _func("#searchInput").val();
	} else if (_func('#DetailSearch').css('display') == "block"){ // 상세검색
		searchType = seSearchID.attr("value");
		searchWord = _func("#titleNm").val();
	} else { // _func('#DetailSearch').length == 0, 업무문서함 등 개인&부서결재함 제외
		searchType = (typeof(schFrmSeSearchID) != "undefined" && schFrmSeSearchID != "") ? schFrmSeSearchID : seSearchID.attr("value");
		searchWord = (typeof(schFrmSearchInput) != "undefined" && schFrmSearchInput != "") ? schFrmSearchInput : searchInput.val();
	}
	
	var sortKey = gridObj.nowSortHeadObj==undefined ? "": gridObj.nowSortHeadObj.key //gridObj.nowSortHeadObj.key;
	var sortDirec = gridObj.nowSortHeadObj==undefined ? "": gridObj.nowSortHeadObj.sort;
	var isCheckSubDept = null;
	if(lowDept.prop('checked') == true){
		isCheckSubDept = 1;
	}else{
		isCheckSubDept = 0;
	}
	
	var businessData1 = "APPROVAL";
	if(location.search.split("&")[0].indexOf("CLSYS") > -1) { 
		businessData1 = location.search.split("&")[0].replace("?CLSYS=", "").toUpperCase();
	}
	
	
	//겸직자 법인별 조회 요건 사용 시 처리
	var approvallistCompanyCode;
	if(Common.getBaseConfig("IsUseAddJobApprovalList") == "Y"){
		if(_func("#selCompanyCode").attr("value") == "undefined" || _func("#selCompanyCode").attr("value") == undefined || _func("#selCompanyCode").attr("value") == ""){
			approvallistCompanyCode = "";
		}else{
			approvallistCompanyCode = _func("#selCompanyCode").attr("value");
		}
	}else{
		approvallistCompanyCode="";
	}

	selectParams = {
			"searchType":searchType,
			"searchWord":searchWord,
			"encodeSearchWord":Base64.utf8_to_b64(searchWord),
			"searchGroupType":searchGroupType,
			"searchGroupWord":searchGroupWord,
			"formSubject":formSubject,
			"initiatorName":initiatorName,
			"initiatorUnitName":initiatorUnitName,
			"formName":formName,
			"docNo":docNo,
			"startDate":startDate,
			"endDate":endDate,
			"sortColumn":sortKey,
			"sortDirection":sortDirec,
			"isCheckSubDept":isCheckSubDept,
			"bstored":bstored, // 이관문서 여부
			"businessData1":businessData1,
			"companyCode" : approvallistCompanyCode,
			"submode" : (typeof(g_submode) == "undefined" ? "" : g_submode) // 20210126 이관문서
		};
	if(approvalListType=="user"){
		if(g_mode == "user"){ // 관리자-전자결재-사용자문서보기
			selectParams.userID = _func("#userId").val();
			selectParams.adminYn = ""; //관리자-전자결재-사용자문서보기(구분값 관리자페이지에서는 삭제된 데이터가 보여야함) //[수정] 관리자 페이지에서도 사용자문서보기에서는  보이면 안됨
		}else{ //사용자-전자결재-개인결재함
			var userID = sePersonID.attr("value");
			if(typeof userID == "string" && userID.indexOf(";") > -1){
				userID = userID.split(";")[0];
			}
			if(userID == "undefined" || userID == undefined || userID == "all")
				userID = SessionObj["USERID"];
			
			selectParams.userID = userID;
			
			//selectParams.titleNm = (typeof(schFrmTitleNm) != "undefined" && schFrmTitleNm != "") ? schFrmTitleNm : titleNm.val();
			//selectParams.userNm = (typeof(schFrmUserNm) != "undefined" && schFrmUserNm != "") ? schFrmUserNm : userNm.val();
			
			selectParams.selectDateType = selectDateType.val();
		}
	}else if(approvalListType=="dept"){
		if(g_mode == "dept"){ //관리자-전자결재-부서문서보기
			selectParams.deptID = _func("#deptId").val();
			selectParams.adminYn = ""; //관리자-전자결재-부서문서보기(구분값 관리자페이지에서는 삭제된 데이터가 보여야함) //[수정] 관리자 페이지에서도 사용자문서보기에서는  보이면 안됨
		}else{ //사용자-전자결재-부서결재함
			var deptID = _func("#seDeptID").attr("value");
			if(deptID == "undefined" || deptID == undefined || deptID == "all"){
				deptID = SessionObj["ApprovalParentGR_Code"];
			}else{
				deptID = deptID.split(";")[0];
				
				var sDate = _func("#seDeptID").attr("value").split(";")[1];
				var eDate = _func("#seDeptID").attr("value").split(";")[2];
				
				if(sDate == "0000.00.00")
					sDate = "";
				if(eDate == "0000.00.00")
					eDate = "";

				
				if(sDate != undefined && eDate != undefined){
					if(startDate == undefined || startDate == "" || endDate == undefined || endDate == ""){
						selectParams.startDate = sDate;
						selectParams.endDate = eDate;
					}else if(startDate != undefined && startDate != "" && endDate != undefined && endDate != ""){
						if(startDate < sDate || endDate > eDate){
							Common.Warning("해당 부서에 대해서 조회 가능한 기간은 " + sDate + " 부터 " + eDate + " 까지 입니다.");
							
							selectParams.startDate = sDate;
							selectParams.endDate = eDate;
						}
					}
				}
			}
			
			selectParams.deptID = deptID;
			
			//selectParams.titleNm = (typeof(schFrmTitleNm) != "undefined" && schFrmTitleNm != "") ? schFrmTitleNm : _func("#titleNm").val();
			//selectParams.userNm = (typeof(schFrmUserNm) != "undefined" && schFrmUserNm != "") ? schFrmUserNm : _func("#userNm").val();
			
			selectParams.selectDateType = _func("#selectDateType").val();
		}
	}else if(approvalListType=="jobFunction"){
		viewsrchTop = "330";
		srchTop = "205";
		selectParams.jobFunctionCode = (typeof(schFrmJobFunctionId) != "undefined" && schFrmJobFunctionId != "") ? schFrmJobFunctionId : seFuncId.attr('value');
	}else if(approvalListType=="auditDept"){
		viewsrchTop = "330";
		srchTop = "160";
		
		if (typeof(schFrmDeptID) != "undefined"  && schFrmDeptID != "") {
			_func("#checkDeptId").val(schFrmDeptID);
		}
		selectParams.deptID = _func("#checkDeptId").val();
	}else if(approvalListType=="bizDoc"){
		viewsrchTop = "330";
		srchTop = "205";
		selectParams.bizDocCode = (typeof(schFrmSeBizID) != "undefined" && schFrmSeBizID != "") ? schFrmSeBizID : _func("#seBizID").attr("value");
	}else if(approvalListType=="userFolder"){
		selectParams.userID = SessionObj["USERID"];
		selectParams.folderId = _func("#folderId").val();
		selectParams.folderMode = _func("#folderMode").val();
	}else if(approvalListType=="listAdmin"){
		selectParams.selectEntinfoListData = _func("#selectEntinfoListData").val(); // 계열사코드
		selectParams.selectSearchTypeDate = _func("#selectSearchTypeDate").val(); // 날짜코드
		selectParams.selectSearchTypeDoc = _func("#selectSearchTypeDoc").val(); // 문서코드
	}else if(approvalListType=="docType"){
		selectParams.userID = SessionObj["USERID"];
		selectParams.deptID = SessionObj["GR_Code"];
		selectParams.docClassID = _func("#docClassID").val(); // 계열사코드
	}
}

// select box 세팅
/* mode :
	예고함 - PreApproval
	미결함 - Approval
	진행함 - Process
	완료함 - Complete
	반려함 - Reject
	임시함 - TempSave
	참조/회람함 - TCInfo
	부서완료함 - DeptComplete 
	부서발신함 - SenderComplete 
	부서수신함 - Receive
	부서수신완료함 - DeptReceiveComplete
	부서진행함 - DeptReceiveProcess
	부서참조/회람함 - DeptTCInfo
	담당업무함 - jobFunction
	개인폴더함 - userFolder
	url : 그룹별 검색할 때 데이터 가져오는 URL
*/
/**
 * 함 Select Box 세팅
 * @param gridObj
 * @param mode
 * @param url
 */
function setSelect(gridObj, mode, url){
	var groupHtml;
	var searchHtml;
	
	var selectGroupType = _func("#selectGroupType");
	var selectSearchType = _func("#selectSearchType");
			
	// 20210126 이관문서함에서 사용
	var bstored = "false";
	if (document.getElementById("bstored") != null && document.getElementById("bstored").value.toLowerCase() == "true") {
		bstored = document.getElementById("bstored").value.toLowerCase();
	}
	
	var dataGroup = clientGetApprovalListSelectData("selectGroupType", mode);
	if(dataGroup.status == "SUCCESS" && dataGroup.list && dataGroup.list.length > 0){
		groupHtml = "<span class=\"selTit\" ><a id=\"seGroupID\" onclick=\"clickSelectBox(this);\" value=\""+dataGroup.list[0].optionValue+"\" class=\"up\">"+dataGroup.list[0].optionText+"</a></span>"
		groupHtml += "<div class=\"selList\" style=\"width:95px;display: none;\">";
		$(dataGroup.list).each(function(index){
			// 20210126 이관문서쪽 수정 : 이관문서일때 FormPrefix 는 WF_MIGRATION 으로 고정되어 있어서 다른 양식이라도 하나로 인식됨.
			if (this.optionValue == "FormPrefix" && bstored == "true"){
				groupHtml += "<a class=\"listTxt\" value=\"FormName\" onclick=\"clickGroupSelectBoxList(this);\" id=\""+"grp_FormName\">"+this.optionText+"</a>"
			}else if (this.optionValue == "InitiatorUnitID" && bstored == "true"){
				groupHtml += "<a class=\"listTxt\" value=\"InitiatorUnitName\" onclick=\"clickGroupSelectBoxList(this);\" id=\""+"grp_InitiatorUnitName\">"+this.optionText+"</a>"
			}else{
				groupHtml += "<a class=\"listTxt\" value=\""+this.optionValue+"\" onclick=\"clickGroupSelectBoxList(this);\" id=\""+"grp_"+this.optionValue+"\">"+this.optionText+"</a>"
			}
		});
		groupHtml += "</div>";
		selectGroupType.html(groupHtml);
	}else{
		groupHtml = "<span class=\"selTit\" ><a id=\"seGroupID\" onclick=\"clickSelectBox(this);\" value=\""+""+"\" class=\"up\">"+""+"</a></span>"
		groupHtml += "<div class=\"selList\" style=\"width:95px;display: none;\">";
		groupHtml += "</div>";
		selectGroupType.html(groupHtml);
	}
	
	var dataSearch = clientGetApprovalListSelectData("selectSearchType", mode);
	if(dataSearch.status == "SUCCESS" && dataSearch.list && dataSearch.list.length > 0){
		searchHtml = "<span class=\"selTit\" ><a id=\"seSearchID\" onclick=\"clickSelectBox(this);\" value=\""+dataSearch.list[0].optionValue+"\" class=\"up\">"+dataSearch.list[0].optionText+"</a></span>"
		searchHtml += "<div class=\"selList\" style=\"width:100px;display: none;\">";
		$(dataSearch.list).each(function(index){
			// 20210126 이관문서쪽 수정 : 이관문서일때 본문내용 알 수 없음
			if (this.optionValue == "BodyContextOrg" && bstored == "true") { 
			}else{
				searchHtml += "<a class=\"listTxt\" value=\""+this.optionValue+"\" onclick=\"clickSelectBox(this);\" id=\""+"sch_"+this.optionValue+"\">"+this.optionText+"</a>"
			}
		});
		searchHtml += "</div>";
		selectSearchType.html(searchHtml);
	}else{
		searchHtml = "<span class=\"selTit\" ><a id=\"seSearchID\" onclick=\"clickSelectBox(this);\" value=\""+""+"\" class=\"up\">"+""+"</a></span>"
		searchHtml += "<div class=\"selList\" style=\"width:100px;display: none;\">";
		searchHtml += "</div>";
		selectSearchType.html(searchHtml);
	}

}

// 결재함 공통 Select Box Data(getApprovalListSelectData.do 에서 client로 이동) 
function clientGetApprovalListSelectData(filter, mode){
	var listData = [];
	var returnList = {};
	try{
		if(filter == "selectSearchType"){
			if(mode.indexOf("Dept") > -1 || mode.toUpperCase() == "SENDERCOMPLETE" || mode.toUpperCase() == "RECEIVE" || mode.toUpperCase() == "RECEIVECOMPLETE" || mode.toUpperCase() == "RECEXHIBIT"){ //부서결재함
				if(mode.toUpperCase() == "DEPTCOMPLETE" || mode.toUpperCase() == "SENDERCOMPLETE" || mode.toUpperCase() == "RECEIVECOMPLETE" || mode.toUpperCase() == "RECEXHIBIT"){ // 완료함||발신함||수신완료함||수신공람함
					listData.push({"optionValue":"FormSubject","optionText":Common.getDic("lbl_apv_subject")});
					listData.push({"optionValue":"InitiatorUnitName","optionText":Common.getDic("lbl_DraftDept")});
					listData.push({"optionValue":"InitiatorName","optionText":Common.getDic("lbl_apv_writer")});
					listData.push({"optionValue":"FormName","optionText":Common.getDic("lbl_apv_formname")});
					listData.push({"optionValue":"DocNo","optionText":Common.getDic("lbl_apv_DocNo")});
					// 제목+기안자명+기안부서명 검색
					if(Common.getBaseConfig("useSearchBodyContext") == "Y"){
						listData.push({"optionValue":"all","optionText":Common.getDic("lbl_apv_subject") + "+"});
					}
				}
				else if(mode.toUpperCase() == "RECEIVE" || mode.toUpperCase() == "DEPTPROCESS"){	// 수신함||진행함
					listData.push({"optionValue":"Subject","optionText":Common.getDic("lbl_apv_subject")});
					listData.push({"optionValue":"InitiatorUnitName","optionText":Common.getDic("lbl_DraftDept")});
					listData.push({"optionValue":"InitiatorName","optionText":Common.getDic("lbl_apv_writer")});
					listData.push({"optionValue":"FormName","optionText":Common.getDic("lbl_apv_formname")});
				}
				else{
					if(mode.toUpperCase() == "AUDITDEPT"){ //감사문서함
						listData.push({"optionValue":"FormSubject","optionText":Common.getDic("lbl_apv_subject")});
						listData.push({"optionValue":"InitiatorName","optionText":Common.getDic("lbl_apv_writer")});
						listData.push({"optionValue":"FormName","optionText":Common.getDic("lbl_apv_formname")});
					}
					else{	//참조/회람함
						listData.push({"optionValue":"FormSubject","optionText":Common.getDic("lbl_apv_subject")});
						listData.push({"optionValue":"InitiatorUnitName","optionText":Common.getDic("lbl_DraftDept")});
						listData.push({"optionValue":"InitiatorName","optionText":Common.getDic("lbl_apv_writer")});
						listData.push({"optionValue":"FormName","optionText":Common.getDic("lbl_apv_formname")});
						listData.push({"optionValue":"DocNo","optionText":Common.getDic("lbl_apv_DocNo")});
						// 제목+기안자명+기안부서명 검색
						if(Common.getBaseConfig("useSearchBodyContext") == "Y"){
							listData.push({"optionValue":"all","optionText":Common.getDic("lbl_apv_subject") + "+"});
						}
					}
				}
			}
			else{ // 개인결재함 || 개인폴더함
				if(mode.toUpperCase() == "USERFOLDER"){ // 개인폴더함
					listData.push({"optionValue":"FormSubject","optionText":Common.getDic("lbl_apv_subject")});
					listData.push({"optionValue":"InitiatorName","optionText":Common.getDic("lbl_apv_writer")});
					listData.push({"optionValue":"FormName","optionText":Common.getDic("lbl_apv_formname")});
				}
				else if(mode.toUpperCase() == "DOCTYPE"){ // 문서분류함
					listData.push({"optionValue":"FormSubject","optionText":Common.getDic("lbl_apv_subject")});
					listData.push({"optionValue":"InitiatorUnitName","optionText":Common.getDic("lbl_DraftDept")});
					listData.push({"optionValue":"InitiatorName","optionText":Common.getDic("lbl_apv_writer")});
					listData.push({"optionValue":"FormName","optionText":Common.getDic("lbl_apv_formname")});
					listData.push({"optionValue":"DocNo","optionText":Common.getDic("lbl_apv_DocNo")});
				}
				else if(mode.toUpperCase() == "COMPLETE" || mode.toUpperCase() == "TCINFO" || mode.toUpperCase() == "RECEXHIBIT" || mode.toUpperCase() == "Admin"){					// 완료함 20210126 이관문서 관리자문서함 추가
					listData.push({"optionValue":"FormSubject","optionText":Common.getDic("lbl_apv_subject")});
					listData.push({"optionValue":"InitiatorUnitName","optionText":Common.getDic("lbl_DraftDept")});
					listData.push({"optionValue":"InitiatorName","optionText":Common.getDic("lbl_apv_writer")});
					listData.push({"optionValue":"FormName","optionText":Common.getDic("lbl_apv_formname")});
					listData.push({"optionValue":"DocNo","optionText":Common.getDic("lbl_apv_DocNo")});
					// 제목+기안자명+기안부서명 검색
					if(Common.getBaseConfig("useSearchBodyContext") == "Y"){
						listData.push({"optionValue":"all","optionText":Common.getDic("lbl_apv_subject") + "+"});
					}
				}
				else if(mode.toUpperCase() == "TEMPSAVE"){			// 임시함
					listData.push({"optionValue":"Subject","optionText":Common.getDic("lbl_apv_subject")});
				}
				else{
					listData.push({"optionValue":"FormSubject","optionText":Common.getDic("lbl_apv_subject")});
					listData.push({"optionValue":"InitiatorUnitName","optionText":Common.getDic("lbl_DraftDept")});
					listData.push({"optionValue":"InitiatorName","optionText":Common.getDic("lbl_apv_writer")});
					listData.push({"optionValue":"FormName","optionText":Common.getDic("lbl_apv_formname")});
				}
			}
			returnList["list"] = listData;
		}
		else if(filter == "selectGroupType"){
			if(mode.toUpperCase() == "AUDITDEPT"){ //감사문서함
				listData.push({"optionValue":"all","optionText":Common.getDic("lbl_Whole")});
				listData.push({"optionValue":"Date","optionText":Common.getDic("lbl_apv_date_by")});
				listData.push({"optionValue":"InitiatorID","optionText":Common.getDic("lbl_apv_initiator_by")});
				listData.push({"optionValue":"FormPrefix","optionText":Common.getDic("lbl_apv_form_by")});
			}
			else if(mode.toUpperCase() == "TEMPSAVE"){				// 임시함
				listData.push({"optionValue":"all","optionText":Common.getDic("lbl_Whole")});
				listData.push({"optionValue":"Date","optionText":Common.getDic("lbl_apv_date_by")});
				listData.push({"optionValue":"FormPrefix","optionText":Common.getDic("lbl_apv_form_by")});
			}
			else if(mode.toUpperCase() == "PREAPPROVAL" || mode.toUpperCase() == "APPROVAL" || mode.toUpperCase() == "PROCESS" || mode.toUpperCase() == "COMPLETE" || mode.toUpperCase() == "REJECT" || mode.toUpperCase() == "TCINFO"){
				listData.push({"optionValue":"all","optionText":Common.getDic("lbl_Whole")});
				listData.push({"optionValue":"Date","optionText":Common.getDic("lbl_apv_date_by")});
				listData.push({"optionValue":"InitiatorID","optionText":Common.getDic("lbl_apv_initiator_by")});
				listData.push({"optionValue":"InitiatorUnitID","optionText":Common.getDic("lbl_apv_initiatou_by")});
				listData.push({"optionValue":"FormPrefix","optionText":Common.getDic("lbl_apv_form_by")});
				listData.push({"optionValue":"SubKind","optionText":Common.getDic("lbl_apv_approval_by")});
			}
			else{
				listData.push({"optionValue":"all","optionText":Common.getDic("lbl_Whole")});
				listData.push({"optionValue":"Date","optionText":Common.getDic("lbl_apv_date_by")});
				listData.push({"optionValue":"InitiatorID","optionText":Common.getDic("lbl_apv_initiator_by")});
				listData.push({"optionValue":"InitiatorUnitID","optionText":Common.getDic("lbl_apv_initiatou_by")});
				listData.push({"optionValue":"FormPrefix","optionText":Common.getDic("lbl_apv_form_by")});
			}
			returnList["list"] = listData;
		}
		
		returnList["result"] = "ok";
		returnList["status"] = "SUCCESS";
		returnList["message"] = "조회되었습니다";
	}catch(e){
		returnList["status"] = "FAIL";
		returnList["message"] = Common.getDic("msg_apv_030");
	}
	return returnList;
}

/***
 * 그룹별 Select Box
 * @param pObj
 */
function clickGroupSelectBoxList(pObj){
	clickSelectBox(pObj);
	
ListGrid.bindGrid({
	page:{
		pageNo:1,
		pageSize:$("#selectPageSize").val(),
		pageCount:1
	},
	list:[]
});

	setGroupType(ListGrid, groupUrl);
}

/* mode :
	사용자문서보기 - user
	부서문기보기 - dept
*/
/**
 * select box 세팅 // 관리자-전자결재-사용자문서확인
 * @param gridObj
 * @param mode
 */
function setSelectAdmin(gridObj, mode){
	_func("#selectSearchTypeAdmin").bindSelect({
		reserveKeys: {
			options: "list",
			optionValue: "TypeCode",
			optionText: "DisplayName"
		},
		ajaxUrl: "/approval/user/getApprovalListSelectData.do",
		ajaxPars: {"filter": "selectSearchTypeAdmin", "mode":mode},
		ajaxAsync:false,
		onchange: function(){
			if(mode == "user"){
				if(_func("#userId").val() == ""){
					Common.Warning(Common.getDic("msg_selectretireuser"));
					return false;
				}
				g_listMode = _func("#selectSearchTypeAdmin").val();
				setGrid();
			}else{
				if(_func("#deptId").val() == ""){
					Common.Warning(Common.getDic("msg_238"));
					return false;
				}
				g_listMode = _func("#selectSearchTypeAdmin").val();
				setGrid();
			}
		}
	});
}

/**
 * 그룹별 보기 Select Box 클릭했을 경우
 * @param gridObj
 * @param url
 */
function setGroupType(gridObj, url){
	setSelectParams(gridObj);
	
	var groupLiestDiv = _func("#groupLiestDiv");
	var groupLiestArea = _func("#groupLiestArea");
	var DetailSearch = _func("#DetailSearch");
	
	if(selectParams.searchGroupType != "all"){
		var lang = SessionObj["lang"];
		groupLiestDiv.show();
		groupLiestArea.empty();
		
		$.ajax({
			url:url,
			data:selectParams,
			type:"post",
			async: false,
			success: function (res) {					
				if(res.list.length == 0){
					groupLiestArea.css('text-align','center');
					groupLiestArea.append(Common.getDic("msg_NoDataList"));				//조회할 목록이 없습니다
					ListGrid.bindGrid({page:{pageNo:1,pageSize:10,pageCount:1},list:[]});
				}else if(res.list.length > 0){
					$(res.list).each(function(index){
						groupLiestArea.append("<li><a onclick='setSearchGroupWord(\""+this.fieldID+"\");' id='fieldName_" + this.fieldID + "'>"+CFN_GetDicInfo(this.fieldName,lang)+" ("+this.fieldCnt+")</a></li>");
					});
				}else{
					Common.Error(Common.getDic("msg_ScriptApprovalError"));			// 오류 발생
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax(url, response, status, error);
			}
		});
		groupLiestArea.show();
		//$('#DetailSearch').hide();
		//DetailSearch.removeClass("active");
		
	}else{
		groupLiestDiv.hide();
		groupLiestArea.empty();
		
		try {
			if(accountCtrl.getViewPageDivID().indexOf("JobFunction") > -1 && typeof(setApprovalListData_JF) == "function") {
				setApprovalListData_JF();			
			} else {
				setApprovalListData();
			}	
		} catch(e) {
			setApprovalListData();
		}			
	}
	
	$(".contbox").css('top', $(".content").height());
}

/**
 * 검색 값 Validation Check
 * @returns {Boolean}
 */
function searchValueValidationCheck(){
	var searchType = _func("#seSearchID").attr("value");
	var searchWord = _func("#searchInput").val();
	var searchGroupType = _func("#seGroupID").attr("value");
	var startDate = _func("#startdate").val();
	var endDate = _func("#enddate").val();

	if(searchType=="" && searchWord !=""){
		Common.Warning(Common.getDic("lbl_apv_searchcomment_chang"));					//검색조건을 선택하세요
		return false;
	}
	return true;
}

/**
 * 개인결재함 특정 사용자 보기 SelectBox 데이터
 */
function setSelectPerson(){
	var searchGroupType = null;
	var searchGroupWord = null;
	var deptID;
	var deptHtml;
	
	var selectPerson = _func("#selectPerson");
	
	$.ajax({
		url:"/approval/user/getPersonDirectorOfPerson.do",
		type:"post",
		data:{
			"UserCode":SessionObj["USERID"],
			"EntCode":SessionObj["DN_Code"]
		},
		async:false,
		success:function (data) {
			if(data.list != undefined &&data.list.length > 0){
				selectPerson.show();
				deptHtml = "<span class=\"selTit\" ><a id=\"sePersonID\" onclick=\"clickSelectBox(this);\" value=\""+"all"+"\" class=\"up\">"+Common.getDic("lbl_USER_NAME_01")+"</a></span>"
				deptHtml += "<div class=\"selList\" style=\"width:105px;display: none;\">";
				deptHtml += "<a class=\"listTxt\" value=\""+"all"+"\" onclick=\"clickPersonSelectBoxList(this);\" id=\""+"all"+"\">"+Common.getDic("lbl_USER_NAME_01")+"</a>"; // 사용자명
				$(data.list).each(function(index){
					var value = this.UserCode;
					/*
					if(this.ViewStartDate != undefined && this.ViewStartDate != "")
						value += ";" + this.ViewStartDate;
					if(this.ViewEndDate != undefined && this.ViewEndDate != "")
						value += ";" + this.ViewEndDate;
					*/
					deptHtml += "<a class=\"listTxt\" value=\""+value+"\" onclick=\"clickPersonSelectBoxList(this);\" id=\""+this.UserCode+"\">"+CFN_GetDicInfo(this.UserName)+"</a>";
				});
				deptHtml += "</div>";
				selectPerson.html(deptHtml);
			}else{
				selectPerson.hide();
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getPersonDirectorOfPerson.do", response, status, error);
		}
	});
}

/**
 * 부서결재함 특정 부서 보기 SelectBox 데이터
 */
function setSelectDept(){
	var searchGroupType = null;
	var searchGroupWord = null;
	var deptID;
	var deptHtml;
	$.ajax({
		url:"/approval/user/getPersonDirectorOfUnitData.do",
		type:"post",
		data:{
			"UserCode":SessionObj["USERID"],
			"UnitCode":SessionObj["DEPTID"],
			"EntCode":SessionObj["DN_Code"]
		},
		async:false,
		success:function (data) {
			if(data.list != undefined &&data.list.length > 0){
				_func("#selectDept").show();
				deptHtml = "<span class=\"selTit\" ><a id=\"seDeptID\" onclick=\"clickSelectBox(this);\" value=\""+data.list[0].UnitCode+"\" class=\"up\">"+data.list[0].UnitName+"</a></span>"
				deptHtml += "<div class=\"selList\" style=\"width:105px;display: none;\">";
				$(data.list).each(function(index){
					var value = this.UnitCode;
					
					deptHtml += "<a class=\"listTxt\" value=\""+value+"\" onclick=\"clickDeptSelectBoxList(this);\" id=\""+this.UnitCode+"\">"+CFN_GetDicInfo(this.UnitName)+"</a>";
				});
				deptHtml += "</div>";
				_func("#selectDept").html(deptHtml);
			}else{
				_func("#selectDept").hide();
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getPersonDirectorOfUnitData.do", response, status, error);
		}
	});
}

/**
 * 특정 사용자 보기 SelectBox
 * @param pObj
 */
function clickPersonSelectBoxList(pObj){
	clickSelectBox(pObj);
	
	var searchGroupType = (typeof (schFrmSeGroupID) != "undefined" && schFrmSeGroupID != "") ? schFrmSeGroupID
		: $("#seGroupID").attr("value");
	clickSelectBox($("#seGroupID"));
	clickGroupSelectBoxList($("#selectGroupType").find(".selList > a[value='"+searchGroupType+"']").get(0));
}

/**
 * 특정 부서 보기 SelectBox
 * @param pObj
 */
function clickDeptSelectBoxList(pObj){
	clickSelectBox(pObj);

	var searchGroupType = (typeof (schFrmSeGroupID) != "undefined" && schFrmSeGroupID != "") ? schFrmSeGroupID
			: $("#seGroupID").attr("value");
	clickSelectBox($("#seGroupID"));
	clickGroupSelectBoxList($("#selectGroupType").find(".selList > a[value='"+searchGroupType+"']").get(0));
}

/**
 * 복사버튼
 */
function onClickFolderListPopup(){
	Common.open("","onClickFolderListPopup",Common.getDic("lbl_apv_userfoldertitle"),"/approval/user/UserFolderListAddPopup.do?&mode=copy","500px","470px","iframe",true,null,null,true);
}

/**
 * 새로운폴더버튼
 */
function onClickNewFolderPop(){
	Common.open("","onClickFolderListPopup",Common.getDic("btn_apv_userfolderadd"),"/approval/user/UserNewFolderAddPopup.do?&type=1Lv","500px","130px","iframe",true,null,null,true);
}

/**
 * 새로운 하위폴더버튼
 */
function onClick2LvNewFolderPop(FolderID){		
	Common.open("","onClickFolderListPopup",Common.getDic("btn_apv_userfolderadd"),"/approval/user/UserNewFolderAddPopup.do?&type=2Lv&FolderID="+FolderID+"","500px","130px","iframe",true,null,null,true);
}

/**
 * 폴더이동
 * @param gridObj
 * @returns {Boolean}
 */
function onClickMoveFolderPop(gridObj){
	var checkApprovalList = gridObj.getCheckedList(0);
	if(checkApprovalList.length == 0){
		Common.Warning(Common.getDic("msg_apv_003"));				//선택된 항목이 없습니다.
		return false;
	}
	
	Common.open("","onClickMoveFolderPop",Common.getDic("lbl_apv_userfolder_2"),"/approval/user/UserFolderListAddPopup.do?&mode=move","500px","465px","iframe",true,null,null,true);
}

/**
 * 폴더명 수정버튼
 * @param gridObj
 * @returns {Boolean}
 */
function onClickUpdtFolderPop(gridObj){
	var checkApprovalList = gridObj.getCheckedList(0);
	if(checkApprovalList.length == 0){
		Common.Warning(Common.getDic("msg_apv_003"));				//선택된 항목이 없습니다.
		return false;
	}
	if(checkApprovalList.length > 1){
		Common.Warning(Common.getDic("msg_apv_326"));
		return false;
	}
	//
	Common.open("","onClickUpdtFolderPop",Common.getDic("btn_apv_folderEdit"),"/approval/user/UserUpdtFolderAddPopup.do","350px","130px","iframe",true,null,null,true);
}

function getUserSignInfo(usercode){
	var retVal = "";
	
	$.ajax({
	    url: "/approval/user/getUserSignInfo.do",
	    type: "POST",
	    data: {
			"UserCode" : usercode
		},
		async:false,
	    success: function (res) {
	    	if(res.status == 'SUCCESS'){
	    		retVal = res.data;
	    	} else if(res.status == 'FAIL'){
	    		Common.Error(res.message);
	    	}
        },
        error:function(response, status, error){
			CFN_ErrorAjax("getUserSignInfo.do", response, status, error);
		}
	});
	
	return retVal;
}

function SerialApproval(businessData1) {
	CFN_OpenWindow("/approval/approval_SerialApprovalForm.do?businessData1="+businessData1, "", 1200, (window.screen.height - 100), "scroll");
}

function openFileList_comment(pObj, idx, pGubun){
	if(!axf.isEmpty($(pObj).parent().find('.file_box').html())){
		$(pObj).parent().find('.file_box').remove();
		return false;
	}
	$('.file_box').remove();
	
	var vHtml = "<ul class='file_box'>";
	vHtml += "<li class='boxPoint'></li>";
	for(var i=0; i<g_commentAttachList[idx].length;i++){
		vHtml += "<li><a onclick='attachFileDownLoadCall_comment("+g_commentAttachList[idx][i].id+", \"" + g_commentAttachList[idx][i].savedname + "\", \"" + g_commentAttachList[idx][i].FileToken + "\")'>"+g_commentAttachList[idx][i].name+"</a></li>";
	}
	
	vHtml += "</ul>";
	$(pObj).parent().append(vHtml);
}

function attachFileDownLoadCall_comment(fileid, filename, filetoken) {
	Common.fileDownLoad(fileid, filename, filetoken);
}

// 6개월 기간 체크
function getCurrentSixMonth(pEDay) {
	var newDate = new Date();
	var strSDay;
	var strEDay;
	var yy;
	var mm;
	var dd;
	var returnDay;
		
	strEDay = pEDay;

	var arr_pEDay = pEDay.split('-');

	yy = arr_pEDay[0];
	mm = arr_pEDay[1];
	dd = arr_pEDay[2];

	if (mm * 1 < 7) {
		yy = ((yy * 1) - 1) + '';
		if (((mm * 1) + 6) < 10) {
			mm = '0' + ((mm * 1) + 6);
		} else {
			mm = ((mm * 1) + 6) + '';
		}
	} else {
		mm = '0' + ((mm * 1) - 6);
	}

	strSDay = yy + "-" + mm + "-" + dd;

	return returnDay = strSDay + "^" + strEDay;
}

function setDeputyList(mode, subkind, taskId, actionMode, actionComment, forminstID, isMobile, processID, UserCode) {//대결일 경우 처리
	try {
		var sessionObj = Common.getSession(); //전체호출
		var jsonApv = arrDomainDataList[processID];

		if(!sessionObj["ApprovalParentGR_Name"]) sessionObj["ApprovalParentGR_Name"] = sessionObj["GR_MultiName"];
		
        if (mode == "APPROVAL" || mode == "PCONSULT" || mode == "RECAPPROVAL" || mode == "SUBAPPROVAL" || mode == "AUDIT") { //기안부서결재선 및 수신부서 결재선
            var oFirstNode; //step에서 taskinfo select로 변경

            if (mode == "APPROVAL" || mode == "SUBAPPROVAL" || mode == "AUDIT") {
                oFirstNode = $$(jsonApv).find("steps>division>step[routetype='approve']>ou>person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "']>taskinfo[status='pending'], steps>division>step[routetype='approve']>ou>role:has(person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'])");
                
                if ((mode == "SUBAPPROVAL" || mode == "AUDIT")  && oFirstNode.length == 0) {
                	oFirstNode = $$(jsonApv).find("steps>division>step[routetype!='approve']>ou>person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "']>taskinfo[status='pending'], steps>division>step[routetype='approve']>ou>role:has(person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'])");
                }
                if (oFirstNode.length == 0) { //편집 후 결재 시 대결 오류로 인하여 소스 추가
                    oFirstNode = $$(jsonApv).find("steps>division>step[routetype='approve']>ou>person[code='" + sessionObj["USERID"] + "']>taskinfo[status='pending'][kind='substitute']");
                }
            } else if (mode == "RECAPPROVAL") {
                oFirstNode = $$(jsonApv).find("steps>division[divisiontype='receive']>step[routetype='approve']>ou>person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "']>taskinfo[status='pending'], steps>division[divisiontype='receive']>step[routetype='approve']>ou>role:has(person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'])");
                if (oFirstNode.length == 0) { //편집 후 결재 시 대결 오류로 인하여 소스 추가
                    oFirstNode = $$(jsonApv).find("steps>division[divisiontype='receive']>step[routetype='approve']>ou>person[code='" + sessionObj["USERID"] + "']>taskinfo[status='pending'][kind='substitute']");
                }
            } else if (mode == "PCONSULT") {
                oFirstNode = $$(jsonApv).find("steps>division>step>ou>person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "']>taskinfo[status='pending'], steps>division>step>ou>role>taskinfo:has(person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'])[status='pending']");
            } else if (mode == "AUDIT") {
                oFirstNode = $$(jsonApv).find("steps>division>step[routetype='audit']>ou>person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'] > taskinfo[status='pending'], steps>division>step[routetype='audit']>ou>role:has(person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'])");
            } else {
                oFirstNode = $$(jsonApv).find("steps>division>step[unittype='ou'][routetype='receive']>ou>person[code!='" + sessionObj["USERID"] + "']>taskinfo[kind!='charge'][status='pending']");
            }
            if (oFirstNode.length != 0) {
                var m_bDeputy = true; var m_bApvDirty = true; var elmOU; var elmPerson;
                switch (mode) {
                    case "APPROVAL":
                    case "PCONSULT":
                    case "SUBAPPROVAL":
                    case "RECAPPROVAL":
                    case "AUDIT":
                        elmOU = $$(oFirstNode).parent().parent();
                        elmPerson = $$(oFirstNode).parent();
                        break;
                }
                var elmTaskInfo = $$(elmPerson).find("taskinfo");
                var skind = $$(elmTaskInfo).attr("kind");
                var sallottype = "serial";
                var elmStep = $$(elmOU).parent();
                try { if ($$(elmStep).attr("allottype") != null) sallottype = $$(elmStep).attr("allottype"); } catch (e) { coviCmn.traceLog(e); }
                //taskinfo kind에 따라 처리  일반결재 -> 대결, 대결->사용자만 변환, 전결->전결, 기존사용자는 결재안함으로
                switch (skind) {
                    case "substitute": //대결
                        if (actionMode == "APPROVAL") {
                            $$(elmOU).attr("code", sessionObj["ApprovalParentGR_Code"]);
                            $$(elmOU).attr("name", sessionObj["ApprovalParentGR_Name"]);
                        }
                        $$(elmPerson).attr("code", sessionObj["USERID"]);
                        $$(elmPerson).attr("name", sessionObj["UR_MultiName"]);
                        $$(elmPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
                        $$(elmPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
                        $$(elmPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
                        $$(elmPerson).attr("oucode", sessionObj["DEPTID"]);
                        $$(elmPerson).attr("ouname", sessionObj["GR_MultiName"]);
                        $$(elmPerson).attr("sipaddress", sessionObj.UR_Mail);
                        $$(elmTaskInfo).attr("datereceived", new Date().format('yyyy-MM-dd HH:mm:ss'));
                        break;
                    /*case "authorize"://전결 결재안함
                        $$(elmTaskInfo).attr("status", "completed");
                        $$(elmTaskInfo).attr("result", "skipped");
                        $$(elmTaskInfo).attr("kind", "skip");
                        $$(elmTaskInfo).remove("datereceived");
                        break;*/
                    case "consent": //합의 -> 후열
                    case "charge":  //담당 -> 후열
                    case "consult":
                    case "normal":  //일반결재 -> 후열
                    case "authorize"://전결 결재안함
                        $$(elmTaskInfo).attr("status", "inactive");
                        $$(elmTaskInfo).attr("result", "inactive");
                        $$(elmTaskInfo).attr("kind", "bypass");
                        $$(elmTaskInfo).remove("datereceived");
                        break;
                }
                if (skind == "authorize" || skind == "normal" || skind == "consent" || skind == "charge" || skind == "consult") {
                    var oStep = {};
                    var oOU = {};
                    var oPerson = {};
                    var oTaskinfo = {};
                    
                    $$(oTaskinfo).attr("status", "pending");
                    $$(oTaskinfo).attr("result", "pending");
                    $$(oTaskinfo).attr("kind", (skind == "authorize") ? skind : "substitute");
                    $$(oTaskinfo).attr("datereceived", new Date().format('yyyy-MM-dd HH:mm:ss'));
                    
                    $$(oPerson).attr("code", sessionObj["USERID"]);
                    $$(oPerson).attr("name", sessionObj["UR_MultiName"]);
                    $$(oPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
                    $$(oPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
                    $$(oPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
                    $$(oPerson).attr("oucode", sessionObj["DEPTID"]);
                    $$(oPerson).attr("ouname", sessionObj["GR_MultiName"]);
                    $$(oPerson).attr("sipaddress", sessionObj.UR_Mail);
                    
                    if(mode == "SUBAPPROVAL") {
                    	$$(oPerson).attr("wiid", $$(elmPerson).attr("wiid"));
                    	$$(oPerson).attr("taskid", $$(elmPerson).attr("taskid"));
                    }
                    
                    $$(oPerson).append("taskinfo", oTaskinfo);
                    
                    $$(elmOU).append("person", oPerson);							// person이 object일 경우를 위해서 추가하여 배열로 만듬
                    
                    if(mode == "SUBAPPROVAL") {
                    	// todo: person의 index 구하는 방법 변경할 수 있으면 다른방법으로 교체할 것
                    	$$(elmOU).find("person").json().splice(parseInt(oFirstNode.parent().path().substr(oFirstNode.parent().path().lastIndexOf("/")+8, 1)), 0, oPerson);
                    } else {
                    	$$(elmOU).find("person").json().splice(0, 0, oPerson);			// 다시 앞에 추가
                    }
                    $$(elmOU).find("person").concat().eq($$(elmOU).find("person").concat().length-1).remove();			// 배열로 만들기 위해서 추가했던 person을 지움
                    
                    if (skind == 'charge') {
                        oFirstNode = oStep;
                        
                        var oStep = {};
                        var oOU = {};
                        var oPerson = {};
                        var oTaskinfo = {};
                        
                        $$(oStep).attr("unittype", "person");
                        $$(oStep).attr("routetype", "approve");
                        $$(oStep).attr("name", Common.getDic("lbl_apv_writer"));		//gLabel__writer);
                        
                        $$(oOU).attr("code", sessionObj["ApprovalParentGR_Code"]);
                        $$(oOU).attr("name", sessionObj["ApprovalParentGR_Name"]);
                        
                        $$(oPerson).attr("code", sessionObj["USERID"]);
                        $$(oPerson).attr("name", sessionObj["UR_MultiName"]);
                        $$(oPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
                        $$(oPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
                        $$(oPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
                        $$(oPerson).attr("oucode", sessionObj["DEPTID"]);
                        $$(oPerson).attr("ouname", sessionObj["GR_MultiName"]);
                        $$(oPerson).attr("sipaddress", sessionObj.UR_Mail);
                        
                        $$(oTaskinfo).attr("status", "complete");
                        $$(oTaskinfo).attr("result", "complete");
                        $$(oTaskinfo).attr("kind", "charge");
                        $$(oTaskinfo).attr("datereceived", new Date().format('yyyy-MM-dd HH:mm:ss'));
                        $$(oTaskinfo).attr("datecompleted", new Date().format('yyyy-MM-dd HH:mm:ss'));
                        
                        $$(oPerson).append("taskinfo", oTaskinfo);
                        
                        $$(oOU).append("person", oPerson);
                        
                        $$(oStep).append("ou", oOU);
                        
                        $$(jsonApv).find("steps>division").append("step", oStep);
                        $$(jsonApv).find("steps>division>step").json().splice(0, 0, oStep);
                        $$(jsonApv).find("steps>division>step").concat().eq($$(jsonApv).find("steps>division>step").concat().length-1).remove();
                    }
                }

                var oResult = $$(jsonApv).json();
                return JSON.stringify(oResult);
            }
            else {
            	return arrDomainDataList[processID];
            }
        }
        else if(mode == "REDRAFT") {
        	var oApvList = jsonApv;
        	var oCurrentOUNode = $$(oApvList).find("steps > division").children().find("[divisiontype='receive']").has(">taskinfo[status='pending']");
            if (oCurrentOUNode == null) {
            	var oDiv = {};
            	$$(oDiv).attr("taskinfo", {});
            	$$(oDiv).attr("step", {});
            	$$(oDiv).attr("divisiontype", "receive");
            	$$(oDiv).attr("name", Common.getDic("lbl_apv_ChargeDept"));
                $$(oDiv).attr("oucode", sessionObj["ApprovalParentGR_Code"]);
                $$(oDiv).attr("ouname", sessionObj["ApprovalParentGR_Name"]);
            	
                $$(oDiv).find("taskinfo").attr("status", "pending");
                $$(oDiv).find("taskinfo").attr("result", "pending");
                $$(oDiv).find("taskinfo").attr("kind", "receive");
                $$(oDiv).find("taskinfo").attr("datereceived", new Date().format('yyyy-MM-dd HH:mm:ss'));
            	
            	$$(oApvList).find("division").push(oDiv);
            	
                oCurrentOUNode = $$(oApvList).find("steps > division:has(>taskinfo[status='pending'])[divisiontype='receive']");
            }
            var oRecOUNode = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");
            if (oRecOUNode.length != 0 && $$(oRecOUNode).find("ou").hasChild("person").length == 0) $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']").remove();
            var oChargeNode = $$(oCurrentOUNode).find("step").has("ou>person>taskinfo[status='pending']");

            //담당 수신자 대결
            var isChkDeputy = false;

            if (oChargeNode.length != 0) {
                //담당 수신자 대결 S ----------------------------------------
                var objDeputyOU = $$(oApvList).find("steps>division[divisiontype='receive']>step>ou");
                var chkObjPersonNode = $$(objDeputyOU).find("person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "']").find(">taskinfo[status='pending']");
                var chkObjRoleNode = $$(objDeputyOU).find("role:has(person[code='" + UserCode + "'][code!='" + sessionObj["USERID"] + "'])");

                if (0 < (chkObjPersonNode.length + chkObjRoleNode.length)) {
                    isChkDeputy = true;
                }
                //담당 수신자 대결 E -----------------------------------------
            	
                var oRecApprovalNode = $$(oCurrentOUNode).find("step>ou>person>taskinfo[status='inactive']");
                if (oRecApprovalNode.length != 0) {
                	for(var i=0; i<oRecApprovalNode.length; i++){
                		var RecApprovalNode = oRecApprovalNode.concat().eq(i);
                		oCurrentOUNode.concat().eq(0).remove(RecApprovalNode.parent().parent().parent());
                	}
                }

                //person의 takinfo가 inactive가 있는 경우 routetype을 변경함
                var nodesInactives = $$(oCurrentOUNode).find("step[routetype='receive']").has("ou > person > taskinfo[status='inactive']");

                $$(nodesInactives).each(function (i, nodesInactive) {
                    $$(nodesInactive).attr("unittype", "person");
                    $$(nodesInactive).attr("routetype", "approve");
                    $$(nodesInactive).attr("name", Common.getDic("lbl_apv_ChargeDept"));	
                });

            }
            
        	var oJFNode = $$(oCurrentOUNode).find("step").has("ou>role>taskinfo[status='pending'], ou>role>taskinfo[status='reserved']"); 
            var bHold = false; //201108 보류여부
            var oComment = null;
            if (oJFNode.length != 0) {
                var oHoldTaskinfo = $$(oJFNode).find("ou>role>taskinfo[status='reserved']");
                if (oHoldTaskinfo.length != 0) {
                    bHold = true;
                    oComment = $$(oHoldTaskinfo).find("comment").json();
                    
                    // 보류한 사용자와 로그인한 사용자가 다른 경우
                    if($$(oComment).attr("reservecode") != undefined && $$(oComment).attr("reservecode") != getInfo("AppInfo.usid")) {
                    	Common.Warning(Common.getDic("msg_apv_holdOther")); // 해당 양식은 다른 사용자가 보류한 문서입니다.
                    	bHold = false;
                	}
                }
                //$$(oCurrentOUNode).eq(0).remove($$(oJFNode).eq(0));
                $$(oCurrentOUNode).eq(0).remove("step");
            }

            $$(oCurrentOUNode).attr("oucode", sessionObj["ApprovalParentGR_Code"]);
            $$(oCurrentOUNode).attr("ouname", sessionObj["ApprovalParentGR_Name"]);
            
            $$(oCurrentOUNode).find("taskinfo").attr("status", "pending");
            $$(oCurrentOUNode).find("taskinfo").attr("result", "pending");
            
            var oStep = {};
            var oOU = {};
            var oPerson = {};
            var oTaskinfo = {};

            $$(oStep).attr("unittype", "person");
            $$(oStep).attr("routetype", "approve");
            $$(oStep).attr("name", Common.getDic("lbl_apv_ChargeDept"));
            
            $$(oOU).attr("code", sessionObj["ApprovalParentGR_Code"]);
            $$(oOU).attr("name", sessionObj["ApprovalParentGR_Name"]);
            
            $$(oPerson).attr("code", sessionObj["USERID"]);
            $$(oPerson).attr("name", sessionObj["UR_MultiName"]);
            $$(oPerson).attr("position", sessionObj["UR_JobPositionCode"] + ";" + sessionObj["UR_MultiJobPositionName"]);
            $$(oPerson).attr("title", sessionObj["UR_JobTitleCode"] + ";" + sessionObj["UR_MultiJobTitleName"]);
            $$(oPerson).attr("level", sessionObj["UR_JobLevelCode"] + ";" + sessionObj["UR_MultiJobLevelName"]);
            $$(oPerson).attr("oucode", sessionObj["DEPTID"]);
            $$(oPerson).attr("ouname", sessionObj["GR_MultiName"]);
            $$(oPerson).attr("sipaddress", sessionObj.UR_Mail);
            
            $$(oTaskinfo).attr("status", (bHold == true ? "reserved" : "pending")); 
            $$(oTaskinfo).attr("result", (bHold == true ? "reserved" : "pending")); 
            $$(oTaskinfo).attr("kind", "charge");
            $$(oTaskinfo).attr("datereceived", new Date().format('yyyy-MM-dd HH:mm:ss'));
            if (bHold) $$(oTaskinfo).attr("comment", oComment); 
            
            $$(oPerson).append("taskinfo", oTaskinfo);
            
            $$(oOU).append("person", oPerson);
            
            $$(oStep).append("ou", oOU);
            
            // 조건 추가 - charge가 있는 경우에만 실행
            // receive division의 첫번째 step 교체
            if($$(oCurrentOUNode).find("step > ou > person > taskinfo[kind='charge']").length > 0) {                        
                $$(oCurrentOUNode).append("step", oStep);
                $$(oCurrentOUNode).find("step").concat().eq(0).remove();
            }
            else {
            	$$(oCurrentOUNode).append("step", oStep);
            }
            
            //담당 수신자 대결 S ---------------------------------------------
            if (isChkDeputy) {
            	//Common.Warning(Common.getDic("msg_ApprovalDeputyWarning"));
            	
                var objOriginalApprover = $$(oChargeNode).find('ou').find("person");
                $$(objOriginalApprover).attr('title', $$(objOriginalApprover).attr('title'));
                $$(objOriginalApprover).attr('level', $$(objOriginalApprover).attr('level'));
                $$(objOriginalApprover).attr('position', $$(objOriginalApprover).attr('position'));

                $$(objOriginalApprover).find('taskinfo').remove('datereceived');
                $$(objOriginalApprover).find('taskinfo').attr('kind', 'bypass');
                $$(objOriginalApprover).find('taskinfo').attr('result', 'inactive');
                $$(objOriginalApprover).find('taskinfo').attr('status', 'inactive');
                
                // [2015-05-28 modi] 현재 대결인 division에만 추가하도록
                //objDeputyOU = $(oApvList).find("steps > division[divisiontype='receive'] > step > ou");
                //objDeputyOU = $$(oApvList).find("steps>division").has("taskinfo[status='pending']").find("step>ou");
                //$$(objDeputyOU).append("person", $$(objOriginalApprover).json());
                
                // [2020-10-23] person 추가에서 step 추가로 변경
                $$(oChargeNode).attr("routetype", "approve");
                $$(oChargeNode).attr("name", "원결재자");
            	$$(oCurrentOUNode).append("step", $$(oChargeNode).json());
            }
            //담당 수신자 대결 E ----------------------------------------------

            var oResult = $$(oApvList).json();
            return JSON.stringify(oResult);              
        }
        else {
        	return arrDomainDataList[processID];
        }
    }
    catch (e) {
        alert(e.message);
    }
}

function openHandoverPopup(gridObj){
	var checkCheckList 		= gridObj.getCheckedList(1);
	var FormInstIdTemp 		= []; //임시함Form인서트아이디
	var FormInstId 	   		= "";
	var FormInstBoxIdTemp 	= []; //임시함Form인서트박스아이디
	var FormInstBoxId 		= "";
	
	if(checkCheckList.length == 0){
		Common.Warning(Common.getDic("msg_apv_003"));				//선택된 항목이 없습니다.
	}else if(checkCheckList.length > 0){
		for(var i = 0; i < checkCheckList.length; i++){
			FormInstIdTemp.push(checkCheckList[i].FormInstID)
			FormInstBoxIdTemp.push(checkCheckList[i].FormTempInstBoxID)
		}
		FormInstId = FormInstIdTemp.join(",");
		FormInstBoxId = FormInstBoxIdTemp.join(",");
		
		Common.open("","onClickHandoverPopup",Common.getDic("lbl_handover"),"/approval/user/HandoverPopup.do?FormInstId="+FormInstId+"&FormInstBoxId="+FormInstBoxId,"450px","200px","iframe",true,null,null,true);
	}else{
		Common.Error(Common.getDic("msg_ScriptApprovalError"));			// 오류 발생
	}
}

/**
 * 회람지정 (20210126 이관함 기능 추가)
 * @param gridObj
 */
function ListCirculation(gridObj){
	strPiid_List = "";
	strWiid_List = "";
	strFiid_List = "";
	
	var str_mode = g_mode.toUpperCase();
	
	// 이관문서는 양식별 일괄확인 여부 필요 없음
//		var excludeItem = false;
//		$.each(gridObj.getCheckedListWithIndex(1), function(idx,obj){
//			if(typeof obj.item.ExtInfo == 'undefined'  || obj.item.ExtInfo.UseBlocCheck != 'Y'){
//				excludeItem = true;
//				gridObj.checkedColSeq(1,false,obj.index);
//			}
//		});
	
	var msgWarning = '';
	msgWarning += Common.getDic("msg_apv_003"); //선택된 항목이 없습니다.
	
	// 체크된 항목 확인
	var checkCheckList = gridObj.getCheckedList(1);
	if(checkCheckList.length == 0){
		Common.Warning(msgWarning);
	}else if(checkCheckList.length > 0){
		// 양식 오픈
		for(var i = 0; i < checkCheckList.length; i++){
			//if(mnid_chk == "477" || mnid_chk == "478" || mnid_chk == "479" || mnid_chk == "483"){
			if(str_mode == "PREAPPROVAL" || str_mode == "APPROVAL" || str_mode == "PROCESS" || str_mode == "TCINFO" || str_mode == "DEPTTCINFO" || str_mode == "ReceiveComplete" || str_mode == "DeptComplete" ){
				strPiid_List += checkCheckList[i].ProcessID == "undefined" || checkCheckList[i].ProcessID == undefined ? ";" : checkCheckList[i].ProcessID + ";";
				strWiid_List += checkCheckList[i].WorkItemID == "undefined" || checkCheckList[i].WorkItemID == undefined ? ";" : checkCheckList[i].WorkItemID + ";";
			}else{
				strPiid_List += checkCheckList[i].ProcessArchiveID == "undefined" || checkCheckList[i].ProcessArchiveID == undefined ? ";" : checkCheckList[i].ProcessArchiveID + ";";
				strWiid_List += checkCheckList[i].WorkitemArchiveID == "undefined" || checkCheckList[i].WorkitemArchiveID == undefined ? ";" : checkCheckList[i].WorkitemArchiveID + ";";
			}

			strFiid_List += checkCheckList[i].FormInstID == "undefined" || checkCheckList[i].FormInstID == undefined ? ";" : checkCheckList[i].FormInstID + ";";
		}
		
		// 목록에서 선택한 항목이 하나일 경우 ID를 붙여주고 여러개일경우 ID를 비우고 참조/회람함을 연다.
		var ProcessID = strPiid_List.split(";").length == 2 ? strPiid_List.split(";")[0] : "";
		var WorkItemID = strWiid_List.split(";").length == 2 ? strWiid_List.split(";")[0] : "";
		var FormInstID = strFiid_List.split(";").length == 2 ? strFiid_List.split(";")[0] : "";
		g_CirculationFiid = strFiid_List;
		g_CirculationPiid = strPiid_List;
		g_CirculationWiid = strWiid_List;
		strPiid_List = "";

		var width = 1000;
		var height = 580;
		var url = "../goCirculationMgrListpage.do?piid=" + ProcessID + "&fiid=" + FormInstID
				+ "&openDo=Circulate&openType=C&pState=528"
				+ "&bstored=true&callType=List";
		
		CFN_OpenWindow(url, "", width, height, "fix");
	}else{
		Common.Error(Common.getDic("msg_ScriptApprovalError"));			// 오류 발생
	}
}

/***** 양식목록 스크립트 분리 시작 *****/
// mobile 에서도 ApprovalListCommon.js 를 사용하므로 체크
var ListGrid = window.coviGrid ? new coviGrid() : null;
var TabList;
var vValue = "";
//var sessionObj = null;

/**
 * axisj selectbox변환
 * @param gridObj
 */
function selSelectbind(){
	//사용여부selectbind
	$("#getListType").bindSelect({
		onChange: function(){
			//toast.push(Object.toJSON(this));
			getListType(this.value);
		}
	});
}

function setFormListTab(){
	$.ajax({
		url:"/approval/user/getClassificationListData.do",
		type:"post",
	/* 	data:{
				"viewAll":"T",
				"entCode":""
			}, */
		async:false,
		success:function(data) {
			setFormListTabClass(data);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getClassificationListData.do", response, status, error);
		}
	});
}

function setFavoriate(){
	$.ajax({
		url:"/approval/user/getFavoriteUsedFormListData.do",
		type:"post",
	/* 	data:{
				"userCode":sessionObj["USERID"],
			}, */
		async:false,
		success:setdivFavoriate,
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getFavoriteUsedFormListData.do", response, status, error);
		}
	});
}

function setdivFavoriate(data){
	var vHtml = "";
	if($(data.list).length > 0){
		$(data.list).each(function(idx){
			//if(idx=="4") return false;
			vHtml += "<li><a class='faList' href='javascript:openFormDraft("+this.FormID+",\""+this.FormPrefix+"\");'>"+CFN_GetDicInfo(this.LabelText)+"</a><a onclick='deleteFavorite("+this.FormID+");' class='giDel'><spring:message code='Cache.lbl_delete'/></a></li>"; //삭제
		});
	}
	else
		vHtml = "";
	$('#faGi').html(vHtml);
}

//탭  세팅
function setFormListTabClass(pObj){
	$("#writeTab").empty();
	$(pObj.list).each(function(index){
		if(index == 0)
			vValue = this.FormClassID;
		var html = "";
		if(index == 0){
			html = "<li class='on'><a onclick='javascript:changeTab(this,"+this.FormClassID+");' title='"+CFN_GetDicInfo(this.FormClassName)+"'>"+CFN_GetDicInfo(this.FormClassName)+"</a></li>";
		}else{
			html = "<li><a onclick='javascript:changeTab(this,"+this.FormClassID+");' title='"+CFN_GetDicInfo(this.FormClassName)+"'>"+CFN_GetDicInfo(this.FormClassName)+"</a></li>";
		}
		$("#writeTab").append(html);
	});
	//setFormListData(vValue);
}
function changeTab(pObj,vValue){
	$(pObj).parent().parent().find("li").attr('class','');
	$(pObj).parent().attr('class','on');
	setFormListData(vValue);
}

function setFormListData(pFromClassID, pSearchText){
	var Params = {
			FormClassID : pFromClassID,
			// viewAll: 전자결재 양식 조회 구분 T : 전체 F : 회사별 - 기존에 Config 값으로 빠져있던 값 기본 F로 사용 
			// T로 사용하고 싶을 경우 전체 양식의 EntCode를 WF로 지정.
			//viewAll : "T", // 임시로 T로 박는다.
			//entCode : "",
			FormName : pSearchText
			//userCode : sessionObj["USERID"]
	};

	$.ajax({
		url:"/approval/user/getFormListData.do",
		type:"post",
		data:Params,
		async:false,
		success:function (data) {
			var html = "";
			$("#writeTapCont").empty();
			
			if(data.list.length == 0){
				html += "<div style='width: 1300px; margin-top: 200px;' align='center'><spring:message code='Cache.msg_apv_101'/></div>";
				$("#writeTapCont").append(html);
			}
			
			for(var i =0; i< data.list.length;i++){

				if (data.list[i].Favorite=="Y") {
					html = "<li class='on'>";
				} else {
					html = "<li>";
				}
				var formname = CFN_GetDicInfo(data.list[i].FormName);
				var title = "";
				if (CFN_GetDicInfo(data.list[i].FormName).length > 24) { 
					formname = formname.substring(0,24)+"...";
					title = "title='"+CFN_GetDicInfo(data.list[i].FormName)+"'";
				}
				html += "<a onclick='javascript:openFormDraft("+data.list[i].FormID+",\""+data.list[i].FormPrefix+"\");' "+title+" class='starList'>"+formname+"</a>";
				html += "<a onclick='javascript:modifyFavorite(this,"+data.list[i].FormID+")' class='starBtn'><spring:message code='Cache.lbl_Favorite'/></a>";  //즐겨찾기
				if(data.list[i].FormDesc){
					var formDesc = Base64.b64_to_utf8(data.list[i].FormDesc.trim());
					
					html += "<a onclick='javascript:clickComment(event,\""+formDesc.replace(/\n/g, "")+"\");' class='deTxt tooltips'><spring:message code='Cache.lbl_Description'/>";   //설명
					html += "<span><div>"+formDesc.replace(/\n/g, "<br/>");
				}
				
				html += "</div></span></a>";

				html += "</li>";

				$("#writeTapCont").append(html);
			}
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getFormListData.do", response, status, error);
		}
	});
}

//즐겨찾기 수정
function modifyFavorite(pObj,FormID){
	var url;
	if($(pObj).parent().attr('class')=="on"){
		url = "/approval/user/removetFavoriteUsedFormListData.do";
	}else{
		url = "/approval/user/addFavoriteUsedFormListData.do";
	}
	var Params = {
			userCode : sessionObj["USERID"],
			formID : FormID
	};
	$.ajax({
		url:url,
		type:"post",
		data:Params,
		async:false,
		success:function (data) {
			if(!$('#writeTab').parent().is(":hidden")){
				$('#writeTab').children('.on').children().trigger('onclick');
			}else{
				onClickSearchButton();
				$('#writeTab').parent().hide();
			}

			setFavoriate();
		},
		error:function(response, status, error){
			CFN_ErrorAjax(url, response, status, error);
		}
	});
}

//즐겨찾기 삭제
function deleteFavorite(FormID){
	var url;
	url = "/approval/user/removetFavoriteUsedFormListData.do";
	var Params = {
			userCode : sessionObj["USERID"],
			formID : FormID
	};
	$.ajax({
		url:url,
		type:"post",
		data:Params,
		async:false,
		success:function (data) {
			if(!$('#writeTab').parent().is(":hidden")){
				$('#writeTab').children('.on').children().trigger('onclick');
			}else{
				onClickSearchButton();
				$('#writeTab').parent().hide();
			}

			setFavoriate();
		},
		error:function(response, status, error){
			CFN_ErrorAjax(url, response, status, error);
		}
	});
}

function onClickSearchButton(){
	var isTeams = (typeof XFN_TeamsOpenGroupware == "function" && !teams_mobile) ? true : false;
	var searchText = (isTeams) ? $('#approval_search_input').val() : $('#searchInput').val();
	var typeID = (isTeams) ? $("#selListTypeID").val() : $("#selListTypeID").attr("value");
	
	setFormListData('', searchText);
	
	if(searchText) {
		$('#writeTab').parent().hide();
	} else {
		if(typeID == "tab") getListType(typeID);
	}
	
	if(isTeams) return;
	
	// 검색어 저장
	coviCtrl.insertSearchData(vSearchText, 'Approval');
}

//팝업 오픈 함수
function openFormDraft(FormID,FormPrefix){
	var isTeams = (typeof XFN_TeamsOpenGroupware == "function" && !teams_mobile) ? true : false;
	
	var url = "/approval/approval_Form.do?formID=" + FormID + "&mode=DRAFT";
	var width = "790";
	if(IsWideOpenFormCheck(FormPrefix, FormID)) width = "1070";
	
	if(isTeams) {
		XFN_TeamsOpenWindow(url, "", "POPUP", width, (window.screen.height - 100), "both");
	} else {
		CFN_OpenWindow(url, "", width, (window.screen.height - 100), "resize", "false");
	}
}

function getListType(type) {
	var vTabChecked = type == 'tab';
	// 분류일땐 탭에 내용만 조회
	if(vTabChecked){
		setFormListData();
		$('#writeTab').parent().show();
		$('#writeTab').children('.on').children().trigger('onclick');
	} else {
		setFormListData(); // 분류 없이 전체 조회
		$('#writeTab').parent().hide();
	}
}
function getFormListDataType(){
	var isTeams = (typeof XFN_TeamsOpenGroupware == "function" && !teams_mobile) ? true : false;
	var typeID 	= (isTeams) ? $("#selListTypeID").val() : $("#selListTypeID").attr("value");
	
	// 분류일땐 탭에 내용만 조회
	if(typeID == 'tab') {
		$('#writeTab').parent().show();
		$('#writeTab').children('.on').children().trigger('onclick');
	} else {
		setFormListData(); // 분류 없이 전체 조회
		$('#writeTab').parent().hide();
	}
}

function writeListShowHide(type){
	if(type=="show"){
		$('#writeList').show();
		$('#arrOpen').hide();
		$('#arrClose').show();
	}else{
		$('#writeList').hide();
		$('#arrOpen').show();
		$('#arrClose').hide();
	}
}

//최근기안
function setCompleteAndRejectList(){
	var isTeams = (typeof XFN_TeamsOpenGroupware == "function" && !teams_mobile) ? true : false;
	var Params = {
			userCode : sessionObj["USERID"]
	};
	
	var giLeftHtml = "";
	var giRightHtml = "";
	$.ajax({
		url:"/approval/user/getCompleteAndRejectListData.do",
		type:"post",
		data:Params,
		async:false,
		success:function (data) {
			var listHtml = "";
			var liTemplate = "";
			
			if(isTeams) {
				liTemplate = "<li>"
							+ "	<button type=\"button\" class=\"arl_state {typeClass}\">{typeValue}</button>"
							+ "	<a class=\"arl_title\" onclick=\"onClickPopButton('{processArchiveID}','{workitemArchiveID}','{performerID}','{processDescriptionArchiveID}','{subKind}','','','','','{userCode}','{type}','{formPrefix}'); return false;\">{formSubject}</a>"
							+ "	<span class=\"arl_date\">{endDate}</span>"
							+ "	<button type=\"button\" class=\"arl_reuse sUse\" onclick=\"formReuse('{processArchiveID}','{workitemArchiveID}','{performerID}','{processDescriptionArchiveID}','{subKind}','','','','','{userCode}','{type}','{formPrefix}'); return false;\">{reuse}</button>"
							+ "</li>";
			} else {
				liTemplate = "{giLeft}"
							+ "<dt><input type=\"button\" class=\"{typeClass}\" value=\"{typeValue}\"></dt>"
							+ "<dd><a onclick=\"onClickPopButton('{processArchiveID}','{workitemArchiveID}','{performerID}','{processDescriptionArchiveID}','{subKind}','','','','','{userCode}','{type}','{formPrefix}'); return false;\">{formSubject}</a></dd>"
							+ "{giRight}"
							+ "<dt>{endDate}</dt>"
							+ "<dd><input type=\"button\" class=\"sUse\" onclick=\"formReuse('{processArchiveID}','{workitemArchiveID}','{performerID}','{processDescriptionArchiveID}','{subKind}','','','','','{userCode}','{type}','{formPrefix}'); return false;\" value=\"{reuse}\" /></dd>";
			}
			
			$(data.list).each(function(idx){
				if(idx=="3") return false;
				
				var type = this.TYPE;
				var endDate = (isTeams) ? XFN_getDateTimeString("yyyy.MM.dd HH:mm", new Date(this.EndDate)) : getStringDateToString("yyyy.MM.dd HH:mm",this.EndDate);
				
				var liHtml = liTemplate
					.replaceAll('{typeClass}', (type=="Complete") ? "sComplete" : "sReturn")
					.replaceAll('{typeValue}', (type=="Complete") ? Common.getDic("lbl_Completed") : Common.getDic("lbl_apv_reject"))
					.replaceAll('{endDate}', endDate)
					.replaceAll('{processArchiveID}', this.ProcessArchiveID)
					.replaceAll('{workitemArchiveID}', this.WorkitemArchiveID)
					.replaceAll('{performerID}', this.PerformerID)
					.replaceAll('{processDescriptionArchiveID}', this.ProcessDescriptionArchiveID)
					.replaceAll('{subKind}', this.FormSubKind)
					.replaceAll('{userCode}', this.UserCode)
					.replaceAll('{type}', type)
					.replaceAll('{formPrefix}', this.FormPrefix)
					.replaceAll('{formSubject}', this.FormSubject)
					.replaceAll('{reuse}', Common.getDic("btn_reuse"))
				;
				
				listHtml += liHtml;
			});

			if(isTeams) {
				$('#giList').html(listHtml);
				return;
			}
			
			var liArr = listHtml.split('{giLeft}').filter(li => li.length > 0);
			var giLeftHtml = liArr.map(li => li.split('{giRight}')[0]);
			var giRightHtml = liArr.map(li => li.split('{giRight}')[1]);
			
			$('#giLeft').html(giLeftHtml);
			$('#giRight').html(giRightHtml);
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/approval/user/getCompleteAndRejectListData.do", response, status, error);
		}
	});
}

//재사용
function formReuse(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,TYPE,FormPrefix){
	var isTeams = (typeof XFN_TeamsOpenGroupware == "function" && !teams_mobile) ? true : false;
	
	var mode = (TYPE=="Complete") ? "COMPLETE" : "REJECT";
	var gloct = (TYPE=="Complete") ? "COMPLETE" : "REJECT";
	var archived = "true";
	var url = "/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+UserCode+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+SubKind+"&editMode=Y&reuse=Y";
	
	var width = "790";
	if(IsWideOpenFormCheck(FormPrefix, FormID)) width = "1070";
	
	if(isTeams) {
		XFN_TeamsOpenWindow(url, "", "POPUP", width, (window.screen.height - 100), "both");
	} else {
		CFN_OpenWindow(url, "", width, (window.screen.height - 100), "resize");
	}
}

//최근기안팝업
function onClickPopButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,TYPE,FormPrefix){
	var isTeams = (typeof XFN_TeamsOpenGroupware == "function" && !teams_mobile) ? true : false;
	
	var archived = "true";
	var mode = (TYPE=="Complete") ? "COMPLETE" : "REJECT";
	var gloct = (TYPE=="Complete") ? "COMPLETE" : "REJECT";
	var url = "/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+UserCode+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+SubKind;
	
	var width = "790";
	if(IsWideOpenFormCheck(FormPrefix, FormID)) width = "1070";
	
	if(isTeams) {
		XFN_TeamsOpenWindow(url, "", "POPUP", width, (window.screen.height - 100), "both");
	} else {
		CFN_OpenWindow(url, "", width, (window.screen.height - 100), "resize");
	}
}

function boxShowHide(pObj,pData){
	if($(pObj).attr('class')=="opBtn"){
		$(pObj).parent().find('.opBtn').removeClass('on');
		$(pObj).addClass('on');
		if(pData=="giBox"){
			setCompleteAndRejectList();
			$("#giBox").show();
			$("#faGi").hide();
		}else{
			setFavoriate();
			$("#giBox").hide();
			$("#faGi").show();
		}
	}else{
		$(pObj).attr('class','opBtn');
		$("#giBox").hide();
		$("#faGi").hide();
	}
}

function clickSelectListBox(pObj){
	if($(pObj).parent().parent().find('.selList').css('display') == 'none'){
		$(pObj).parent().parent().find('.selList').show();
	}else{
		$(pObj).parent().parent().find('.selList').hide();
	}
	if($(pObj).attr('class')=='listTxt'||$(pObj).attr('class')=='listTxt select'){
		$(pObj).parent().find(".listTxt").attr("class","listTxt");
		$(pObj).attr("class","listTxt select");
		$(pObj).parent().parent().find(".up").html($(pObj).attr("id"));
		$(pObj).parent().parent().find(".up").attr("value",$(pObj).attr("value"));
	}
}

function clickSelectListBoxData(pObj){
	if($(pObj).parent().parent().find('.selList').css('display') == 'none'){
		$(pObj).parent().parent().find('.selList').show();
	}else{
		$(pObj).parent().parent().find('.selList').hide();
	}
	if($(pObj).hasClass("listTxt")||$(pObj).hasClass("listTxt select")){
		$(pObj).parent().find(".listTxt").attr("class","listTxt");
		$(pObj).attr("class","listTxt select");
		$(pObj).parent().parent().find(".up").html($(pObj).attr("id"));
		$(pObj).parent().parent().find(".up").attr("value",$(pObj).attr("value"));
	}
	getFormListDataType();
}

// comment 클릭
function clickComment(event, formDesc){
	var $this = $(event.target);
	
	if (formDesc != "") {
		if ($this.hasClass('tooltips-show')) {
			$this.removeClass('tooltips-show');
		} else {
			$this.addClass('tooltips-show');
		}
	}
}
/***** 양식목록 스크립트 분리 끝 *****/
